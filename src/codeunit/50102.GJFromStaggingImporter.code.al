codeunit 50501 "GJ From Staging Importer"
{


    procedure RunFromStaging(UploadId: Guid)
    var
        H: Record "GJ Staging Header";
        L: Record "GJ Staging Line";
        Tmpl: Record "GJ Import Template";
        Map: Record "GJ Import Column Map";
        GLMap: Record "GJ GL Mapping";
        DimMap: Record "GJ Dimension Mapping";
        GenJnlLine: Record "Gen. Journal Line";
        TempDimSet: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;

        acctType: Enum "Gen. Journal Account Type";
        acctNo: Code[20];
        acctNoMapped: Code[20];
        balAcctNo: Code[20];
        curCode: Code[10];
        docNo: Code[20];
        descr: Text[100];
        postDate: Date;
        amount: Decimal;
        lineHasData: Boolean;
        colVal: Text;
    begin
        if not H.Get(UploadId) then
            Error('Staging header not found.');

        if (H."Template Code" = '') and (H."New Template Name" = '') then
            Error('No template assigned.');

        if not Tmpl.Get(ChooseTemplateCode(H)) then
            Error('Template %1 not found.', ChooseTemplateCode(H));

        // Validate journal batch is set
        if (Tmpl."Gen. Jnl. Template Name" = '') or (Tmpl."Gen. Jnl. Batch Name" = '') then
            Error('Please set Gen. Journal Template/Batch on template %1 before importing.', Tmpl.Code);

        // Ensure mapping exists
        Map.Reset();
        Map.SetRange("Template Code", Tmpl.Code);
        if not Map.FindFirst() then
            Error('No Column Mapping found for template %1.', Tmpl.Code);

        // Iterate staged lines
        L.Reset();
        L.SetRange("Upload Id", UploadId);
        if L.FindSet() then
            repeat
                Clear(acctType);
                Clear(acctNo);
                Clear(acctNoMapped);
                Clear(balAcctNo);
                Clear(curCode);
                Clear(docNo);
                Clear(descr);
                Clear(postDate);
                amount := 0;
                if not TempDimSet.IsEmpty() then TempDimSet.DeleteAll();
                lineHasData := false;

                Map.Reset();
                Map.SetRange("Template Code", Tmpl.Code);
                if Map.FindSet() then
                    repeat
                        colVal := GetCol(L, Map."Column Index");
                        if Map."Constant Value" <> '' then
                            colVal := Map."Constant Value";

                        case Map."Target Field" of
                            Map."Target Field"::AccountType:
                                if colVal <> '' then begin
                                    acctType := ParseAcctType(colVal);
                                    lineHasData := true;
                                end;

                            Map."Target Field"::AccountNo:
                                begin
                                    acctNo := CopyStr(colVal, 1, MaxStrLen(acctNo));
                                    lineHasData := true;
                                end;

                            Map."Target Field"::PostingDate:
                                begin
                                    if colVal <> '' then Evaluate(postDate, colVal);
                                    lineHasData := true;
                                end;

                            Map."Target Field"::DocumentNo:
                                begin
                                    docNo := CopyStr(colVal, 1, MaxStrLen(docNo));
                                    lineHasData := true;
                                end;

                            Map."Target Field"::Description:
                                begin
                                    descr := CopyStr(colVal, 1, MaxStrLen(descr));
                                    lineHasData := true;
                                end;

                            Map."Target Field"::Amount:
                                begin
                                    if colVal <> '' then Evaluate(amount, colVal);
                                    lineHasData := true;
                                end;

                            Map."Target Field"::BalAccountNo:
                                begin
                                    balAcctNo := CopyStr(colVal, 1, MaxStrLen(balAcctNo));
                                    lineHasData := true;
                                end;

                            Map."Target Field"::CurrencyCode:
                                begin
                                    curCode := CopyStr(colVal, 1, MaxStrLen(curCode));
                                    lineHasData := true;
                                end;

                            Map."Target Field"::Dimension:
                                if (Map."Dimension Code" <> '') and (colVal <> '') then begin
                                    if DimMap.Get(Map."Dimension Code", colVal) then
                                        AddDim(TempDimSet, Map."Dimension Code", DimMap."Dimension Value Code")
                                    else
                                        AddDim(TempDimSet, Map."Dimension Code", CopyStr(colVal, 1, 20)); // fallback
                                    lineHasData := true;
                                end;
                        end;
                    until Map.Next() = 0;

                if not lineHasData then
                    continue;

                // defaults
                if (postDate = 0D) and (Tmpl."Default Posting Date" <> 0D) then
                    postDate := Tmpl."Default Posting Date";
                if (curCode = '') and (Tmpl."Currency Code" <> '') then
                    curCode := Tmpl."Currency Code";

                // GL mapping if G/L Account
                if acctType = acctType::"G/L Account" then begin
                    acctNoMapped := acctNo;
                    if (acctNo <> '') and GLMap.Get(acctNo) then
                        acctNoMapped := GLMap."G/L Account No.";
                end else
                    acctNoMapped := acctNo;

                // Insert journal line
                GenJnlLine.Init();
                GenJnlLine.Validate("Journal Template Name", Tmpl."Gen. Jnl. Template Name");
                GenJnlLine.Validate("Journal Batch Name", Tmpl."Gen. Jnl. Batch Name");
                if postDate <> 0D then GenJnlLine.Validate("Posting Date", postDate);
                if docNo <> '' then GenJnlLine.Validate("Document No.", docNo);
                if descr <> '' then GenJnlLine.Validate(Description, descr);
                if curCode <> '' then GenJnlLine.Validate("Currency Code", curCode);

                // if acctType <> acctType::" " then
                //     GenJnlLine.Validate("Account Type", acctType)
                // else
                //     GenJnlLine.Validate("Account Type", GenJnlLine."Account Type"::"G/L Account");

                if acctNoMapped <> '' then GenJnlLine.Validate("Account No.", acctNoMapped);
                if balAcctNo <> '' then GenJnlLine.Validate("Bal. Account No.", balAcctNo);
                if amount <> 0 then GenJnlLine.Validate(Amount, amount);

                ApplyDims(DimMgt, TempDimSet, GenJnlLine);
                GenJnlLine.Insert(true);

            until L.Next() = 0;
    end;

    local procedure ChooseTemplateCode(H: Record "GJ Staging Header"): Code[20]
    begin
        if H."Template Code" <> '' then
            exit(H."Template Code");
        exit(H."New Template Name");
    end;

    local procedure GetCol(L: Record "GJ Staging Line"; Index: Integer): Text
    begin
        case Index of
            1:
                exit(L."Col1");
            2:
                exit(L."Col2");
            3:
                exit(L."Col3");
            4:
                exit(L."Col4");
            5:
                exit(L."Col5");
            6:
                exit(L."Col6");
            7:
                exit(L."Col7");
            8:
                exit(L."Col8");
            9:
                exit(L."Col9");
            10:
                exit(L."Col10");
            11:
                exit(L."Col11");
            12:
                exit(L."Col12");
            13:
                exit(L."Col13");
            14:
                exit(L."Col14");
            15:
                exit(L."Col15");
            16:
                exit(L."Col16");
            17:
                exit(L."Col17");
            18:
                exit(L."Col18");
            19:
                exit(L."Col19");
            20:
                exit(L."Col20");
        end;
        exit('');
    end;

    local procedure ParseAcctType(v: Text): Enum "Gen. Journal Account Type"
    var
        e: Enum "Gen. Journal Account Type";
        u: Text;
    begin
        u := UpperCase(DelChr(v, '<>'));
        if (u = 'G/L') or (u = 'GL') or (u = 'G/L ACCOUNT') then exit(e::"G/L Account");
        if (u = 'VENDOR') or (u = 'SUPPLIER') then exit(e::Vendor);
        if (u = 'CUSTOMER') then exit(e::Customer);
        if (u = 'BANK') or (u = 'BANK ACCOUNT') then exit(e::"Bank Account");
        exit(e::"G/L Account");
    end;

    local procedure AddDim(var TempSet: Record "Dimension Set Entry" temporary; DimCode: Code[20]; DimValue: Code[20])
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        if (DimCode = '') or (DimValue = '') then exit;
        //DimMgt.AddDimToDimSet(TempSet, DimCode, DimValue);
    end;

    local procedure ApplyDims(var DimMgt: Codeunit DimensionManagement; var TempSet: Record "Dimension Set Entry" temporary; var Line: Record "Gen. Journal Line")
    var
        id: Integer;
    begin
        if TempSet.IsEmpty() then exit;
        id := DimMgt.GetDimensionSetID(TempSet);
        if id <> 0 then Line.Validate("Dimension Set ID", id);
    end;
}
