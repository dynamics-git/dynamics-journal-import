codeunit 50510 "GJ From Staging Importer"
{
    var
        ImportUtils: Codeunit "GJ Import Utils";
    procedure RunFromStaging(UploadId: Guid)
    var
        StagingHdr: Record "GJ Staging Header";
        Tmpl: Record "GJ Import Template";
    begin
        if not StagingHdr.Get(UploadId) then
            Error('No staging header for %1', UploadId);

        if not Tmpl.Get(StagingHdr."Template Code") then
            Error('Template %1 not found', StagingHdr."Template Code");

        Tmpl.TestField("Gen. Jnl. Template Name");
        Tmpl.TestField("Gen. Jnl. Batch Name");

        ProcessStagingLines(StagingHdr, Tmpl);
        ImportUtils.CleanupStaging(StagingHdr."Upload Id");
    end;


    local procedure ProcessStagingLines(StagingHdr: Record "GJ Staging Header"; Tmpl: Record "GJ Import Template")
    var
        StagingLine: Record "GJ Staging Line";
        GenLine: Record "Gen. Journal Line";
    begin
        StagingLine.SetRange("Upload Id", StagingHdr."Upload Id");

        if not StagingLine.FindSet() then
            exit;

        repeat
            GenLine := BuildJournalLine(StagingLine, Tmpl);
            GenLine.Insert(true);
        until StagingLine.Next() = 0;
    end;

    local procedure BuildJournalLine(StagingLine: Record "GJ Staging Line"; Tmpl: Record "GJ Import Template"): Record "Gen. Journal Line"
    var
        GenLine: Record "Gen. Journal Line";
        ColMap: Record "GJ Import Column Map";
        DimMap: Record "GJ Import Dim Map";
    begin
        // --- Init ---
        Clear(GenLine);
        GenLine.Init();
        GenLine."Journal Template Name" := Tmpl."Gen. Jnl. Template Name";
        GenLine."Journal Batch Name" := Tmpl."Gen. Jnl. Batch Name";
        GenLine."Line No." := ImportUtils.GetNextGenJnlLineNo(Tmpl."Gen. Jnl. Template Name", Tmpl."Gen. Jnl. Batch Name");
        GenLine."Posting Date" := Tmpl."Default Posting Date"; // fallback

        // --- Map fields ---
        ApplyColumnMapping(GenLine, StagingLine, Tmpl.Code);
        ApplyDimensionMapping(GenLine, StagingLine, Tmpl.Code);

        exit(GenLine);
    end;

    local procedure ApplyColumnMapping(var GenLine: Record "Gen. Journal Line"; StagingLine: Record "GJ Staging Line"; TemplateCode: Code[20])
    var
        ColMap: Record "GJ Import Column Map";
    begin
        ColMap.SetRange("Template Code", TemplateCode);

        if ColMap.FindSet() then
            repeat
                MapColumnToJournal(GenLine, StagingLine, ColMap);
            until ColMap.Next() = 0;
    end;

    local procedure MapColumnToJournal(var GenLine: Record "Gen. Journal Line"; StagingLine: Record "GJ Staging Line"; ColMap: Record "GJ Import Column Map")
    var
        ValueTxt: Text;
    begin
        ValueTxt := GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value");

        case ColMap."Target Field No." of
            // Dates
            5:
                GenLine.Validate("Posting Date", ImportUtils.EvaluateDate(ValueTxt));
            128:
                GenLine.Validate("VAT Reporting Date", ImportUtils.EvaluateDate(ValueTxt));

            // Document
            6:
                GenLine.Validate("Document Type", ImportUtils.EvaluateEnumDocType(ValueTxt));
            7:
                GenLine.Validate("Document No.", ValueTxt);

            // Account
            3:
                GenLine.Validate("Account Type", ImportUtils.EvaluateEnumAccountType(ValueTxt));
            4:
                GenLine.Validate("Account No.", ValueTxt);
            8001:
                GenLine.Validate("Account Id", ValueTxt);

            // Texts
            8:
                GenLine.Validate(Description, ValueTxt);
            118:
                GenLine.Validate("Sell-to/Buy-from No.", ValueTxt);
            289:
                GenLine.Validate("Message to Recipient", ValueTxt);

            // Currency
            12:
                GenLine.Validate("Currency Code", ValueTxt);
            61:
                GenLine.Validate("EU 3-Party Trade", ImportUtils.EvaluateBool(ValueTxt));

            // Posting groups
            57:
                GenLine.Validate("Gen. Posting Type", ImportUtils.EvaluateEnumPostingType(ValueTxt));
            58:
                GenLine.Validate("Gen. Bus. Posting Group", ValueTxt);
            59:
                GenLine.Validate("Gen. Prod. Posting Group", ValueTxt);
            90:
                GenLine.Validate("VAT Bus. Posting Group", ValueTxt);
            91:
                GenLine.Validate("VAT Prod. Posting Group", ValueTxt);

            // Amounts
            13:
                GenLine.Validate(Amount, ImportUtils.EvaluateDecimal(ValueTxt));
            16:
                GenLine.Validate("Amount (LCY)", ImportUtils.EvaluateDecimal(ValueTxt));

            // Balancing
            63:
                GenLine.Validate("Bal. Account Type", ImportUtils.EvaluateEnumAccountType(ValueTxt));
            11:
                GenLine.Validate("Bal. Account No.", ValueTxt);
            2678:
                GenLine.Validate("Allocation Account No.", ValueTxt);
            2676:
                GenLine.Validate("Selected Alloc. Account No.", ValueTxt);
            2677:
                GenLine.Validate("Alloc. Acc. Modified by User", ImportUtils.EvaluateBool(ValueTxt));
            6210:
                GenLine.Validate("Bal. Gen. Posting Type", ImportUtils.EvaluateEnumPostingType(ValueTxt));
            65:
                GenLine.Validate("Bal. Gen. Bus. Posting Group", ValueTxt);
            92:
                GenLine.Validate("Bal. VAT Bus. Posting Group", ValueTxt);
            66:
                GenLine.Validate("Bal. Gen. Prod. Posting Group", ValueTxt);

            // Deferral
            1700:
                GenLine.Validate("Deferral Code", ValueTxt);

            // Boolean
            73:
                GenLine.Validate(Correction, ImportUtils.EvaluateBool(ValueTxt));

            // Comment
            5618:
                GenLine.Validate(Comment, ValueTxt);

            // Dimensions (shortcuts only!)
            24:
                GenLine.Validate("Shortcut Dimension 1 Code", ValueTxt);
            25:
                GenLine.Validate("Shortcut Dimension 2 Code", ValueTxt);
        end;
    end;

    local procedure ApplyDimensionMapping(var GenLine: Record "Gen. Journal Line"; StagingLine: Record "GJ Staging Line"; TemplateCode: Code[20])
    var
        DimMap: Record "GJ Import Dim Map";
        DimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
        DimValueCode: Code[20];
        NewDimSetID: Integer;
    begin
        DimMap.SetRange("Template Code", TemplateCode);
        DimMap.SetFilter("Column Index", '<>%1', 0);
        DimSetEntry.DeleteAll();

        if DimMap.FindSet() then
            repeat
                DimValueCode := CopyStr(GetValue(StagingLine, DimMap."Column Index", DimMap."Constant Value"), 1, MaxStrLen(DimValueCode));
                if DimValueCode <> '' then begin
                    DimSetEntry.Init();
                    DimSetEntry."Dimension Set ID" := 0;
                    DimSetEntry.Validate("Dimension Code", DimMap."Dimension Code");
                    DimSetEntry.Validate("Dimension Value Code", DimValueCode);
                    DimSetEntry.Insert();
                end;
            until DimMap.Next() = 0;

        if not DimSetEntry.IsEmpty() then begin
            NewDimSetID := DimMgt.GetDimensionSetID(DimSetEntry);
            GenLine.Validate("Dimension Set ID", NewDimSetID);
        end;
    end;

    local procedure GetValue(StagingLine: Record "GJ Staging Line"; ColIndex: Integer; ConstVal: Text): Text
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        BaseFieldId: Integer;
    begin
        if ConstVal <> '' then
            exit(ConstVal);

        if (ColIndex < 1) or (ColIndex > 50) then
            Error('Column index %1 is out of supported range (1..50).', ColIndex);

        BaseFieldId := ImportUtils.GetGJStagingLineColOneFieldRef(); // same starting field number as above
        RecRef.GetTable(StagingLine);
        FldRef := RecRef.Field(BaseFieldId + (ColIndex - 1));
        exit(Format(FldRef.Value));
    end;
}
