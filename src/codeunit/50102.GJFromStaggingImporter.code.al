codeunit 50510 "GJ From Staging Importer"
{
    TableNo = "GJ Staging Header";

    procedure RunFromStaging(UploadId: Guid)
    var
        StagingHdr: Record "GJ Staging Header";
        StagingLine: Record "GJ Staging Line";
        Tmpl: Record "GJ Import Template";
        ColMap: Record "GJ Import Column Map";
        DimMap: Record "GJ Import Dim Map";
        GenLine: Record "Gen. Journal Line";
        NextLineNo: Integer;
    begin
        if not StagingHdr.Get(UploadId) then
            Error('No staging header for %1', UploadId);

        if not Tmpl.Get(StagingHdr."Template Code") then
            Error('Template %1 not found', StagingHdr."Template Code");

        // Validate journal setup
        Tmpl.TestField("Gen. Jnl. Template Name");
        Tmpl.TestField("Gen. Jnl. Batch Name");

        StagingLine.Reset();
        StagingLine.SetRange("Upload Id", UploadId);

        if StagingLine.FindSet() then begin
            repeat
                Clear(GenLine);
                GenLine.Init();
                GenLine."Journal Template Name" := Tmpl."Gen. Jnl. Template Name";
                GenLine."Journal Batch Name" := Tmpl."Gen. Jnl. Batch Name";
                GenLine."Line No." := GetNextLineNo(Tmpl."Gen. Jnl. Template Name", Tmpl."Gen. Jnl. Batch Name");
                GenLine."Posting Date" := Tmpl."Default Posting Date"; // fallback

                // === Map core fields using Column Map ===
                ColMap.SetRange("Template Code", Tmpl.Code);
                if ColMap.FindSet() then
                    repeat
                        case ColMap."Target Field No." of
                            // Dates
                            5:
                                GenLine.Validate("Posting Date",
                                    EvaluateDate(GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value")));
                            128:
                                GenLine.Validate("VAT Reporting Date",
                                   EvaluateDate(GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value")));

                            // Document
                            6:
                                GenLine.Validate("Document Type",
                                    EvaluateEnumDocType(GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value")));
                            7:
                                GenLine.Validate("Document No.",
                                    GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value"));

                            // Account
                            3:
                                GenLine.Validate("Account Type",
                                    EvaluateEnumAccountType(GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value")));
                            4:
                                GenLine.Validate("Account No.",
                                    GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value"));
                            8001:
                                GenLine.Validate("Account Id",
                                  GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value")); // GUID (if applicable)

                            // Texts
                            8:
                                GenLine.Validate(Description,
                                    GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value"));
                            118:
                                GenLine.Validate("Sell-to/Buy-from No.",
                                   GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value")); // acts as Account Name / Customer
                            289:
                                GenLine.Validate("Message to Recipient",
                                   GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value")); // comment / free text

                            // Currency
                            12:
                                GenLine.Validate("Currency Code",
                                    GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value"));
                            61:
                                GenLine.Validate("EU 3-Party Trade",
                                    EvaluateBool(GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value")));

                            // Posting groups
                            57:
                                GenLine.Validate("Gen. Posting Type",
                                    EvaluateEnumPostingType(GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value")));
                            58:
                                GenLine.Validate("Gen. Bus. Posting Group",
                                    GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value"));
                            59:
                                GenLine.Validate("Gen. Prod. Posting Group",
                                    GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value"));
                            90:
                                GenLine.Validate("VAT Bus. Posting Group",
                                    GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value"));
                            91:
                                GenLine.Validate("VAT Prod. Posting Group",
                                    GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value"));

                            // Amounts
                            13:
                                GenLine.Validate(Amount,
                                    EvaluateDecimal(GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value")));
                            16:
                                GenLine.Validate("Amount (LCY)",
                                    EvaluateDecimal(GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value")));

                            // Balancing
                            63:
                                GenLine.Validate("Bal. Account Type",
                                    EvaluateEnumAccountType(GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value")));
                            11:
                                GenLine.Validate("Bal. Account No.",
                                    GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value"));
                            2678:
                                GenLine.Validate("Allocation Account No.",
                                  GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value"));
                            2676:
                                GenLine.Validate("Selected Alloc. Account No.",
                                  GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value"));
                            2677:
                                GenLine.Validate("Alloc. Acc. Modified by User",
                                  EvaluateBool(GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value")));
                            6210:
                                GenLine.Validate("Bal. Gen. Posting Type",
                                  EvaluateEnumPostingType(GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value")));
                            65:
                                GenLine.Validate("Bal. Gen. Bus. Posting Group",
                                    GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value"));
                            92:
                                GenLine.Validate("Bal. VAT Bus. Posting Group",
                                    GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value"));
                            66:
                                GenLine.Validate("Bal. Gen. Prod. Posting Group",
                                    GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value"));

                            // Deferral
                            1700:
                                GenLine.Validate("Deferral Code",
                                  GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value"));

                            // Boolean
                            73:
                                GenLine.Validate(Correction,
                                    EvaluateBool(GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value")));

                            // Comment
                            5618:
                                GenLine.Validate(Comment,
                                  GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value"));

                            // Dimensions (custom – assuming mapped to shortcuts)
                            24:
                                GenLine.Validate("Shortcut Dimension 1 Code",
                                    GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value")); // Department
                            25:
                                GenLine.Validate("Shortcut Dimension 2 Code",
                                    GetValue(StagingLine, ColMap."Column Index", ColMap."Constant Value")); // Project
                                                                                                            // Other custom dims like Customer Group, Area, Business Group, Sales Campaign can be validated via Dimension Map
                        end;


                    until ColMap.Next() = 0;

                // === Map Dimensions using Dimension Map ===
                DimMap.SetRange("Template Code", Tmpl.Code);
                if DimMap.FindSet() then
                    repeat
                        if DimMap."Column Index" <> 0 then begin
                            GenLine.ValidateShortcutDimCode(
                                GetDimShortcutNo(DimMap."Dimension Code"),
                                DimMap."Dimension Code");
                        end;
                    until DimMap.Next() = 0;

                GenLine.Insert(true);
                NextLineNo += 10000;

            until StagingLine.Next() = 0;
        end;
    end;

    local procedure GetValue(StagingLine: Record "GJ Staging Line"; ColIdx: Integer; ConstVal: Text): Text
    begin
        if ConstVal <> '' then
            exit(ConstVal);

        case ColIdx of
            1:
                exit(StagingLine."Col1");
            2:
                exit(StagingLine."Col2");
            3:
                exit(StagingLine."Col3");
            4:
                exit(StagingLine."Col4");
            5:
                exit(StagingLine."Col5");
            6:
                exit(StagingLine."Col6");
            7:
                exit(StagingLine."Col7");
            8:
                exit(StagingLine."Col8");
            9:
                exit(StagingLine."Col9");
            10:
                exit(StagingLine."Col10");
            11:
                exit(StagingLine."Col11");
            12:
                exit(StagingLine."Col12");
            13:
                exit(StagingLine."Col13");
            14:
                exit(StagingLine."Col14");
            15:
                exit(StagingLine."Col15");
            16:
                exit(StagingLine."Col16");
            17:
                exit(StagingLine."Col17");
            18:
                exit(StagingLine."Col18");
            19:
                exit(StagingLine."Col19");
            20:
                exit(StagingLine."Col20");
        end;
        exit('');
    end;

    local procedure EvaluateEnumAccountType(ValueTxt: Text): Enum "Gen. Journal Account Type"
    var
        EnumVal: Enum "Gen. Journal Account Type";
        IntVal: Integer;
    begin
        if ValueTxt = '' then
            exit(EnumVal::"G/L Account"); // default if empty
        // Otherwise match by text (case-insensitive)
        case UpperCase(ValueTxt) of
            'G/L', 'G/L ACCOUNT', 'GL', 'GL ACCOUNT':
                exit(EnumVal::"G/L Account");
            'CUSTOMER':
                exit(EnumVal::Customer);
            'VENDOR':
                exit(EnumVal::Vendor);
            'BANK', 'BANK ACCOUNT':
                exit(EnumVal::"Bank Account");
            'FIXED ASSET':
                exit(EnumVal::"Fixed Asset");
            'IC', 'IC PARTNER':
                exit(EnumVal::"IC Partner");
            'EMPLOYEE':
                exit(EnumVal::Employee);
            'ALLOCATION', 'ALLOCATION ACCOUNT':
                exit(EnumVal::"Allocation Account");
            else
                Error('Invalid Account Type text value: %1. Expected one of: G/L, Customer, Vendor, Bank, Fixed Asset, IC Partner, Employee, Allocation Account.', ValueTxt);
        end;
    end;


    local procedure EvaluateDate(ValueTxt: Text): Date
    var
        D: Date;
    begin
        if ValueTxt = '' then
            exit(0D);
        if not Evaluate(D, ValueTxt) then
            Error('Invalid Posting Date: %1', ValueTxt);
        exit(D);
    end;

    local procedure EvaluateDecimal(ValueTxt: Text): Decimal
    var
        Dec: Decimal;
    begin
        if ValueTxt = '' then
            exit(0);
        if not Evaluate(Dec, ValueTxt) then
            Error('Invalid Amount: %1', ValueTxt);
        exit(Dec);
    end;


    local procedure GetDimShortcutNo(DimCode: Code[20]): Integer
    var
        GLSetup: Record "General Ledger Setup";
    begin
        if not GLSetup.Get() then
            Error('General Ledger Setup not found.');

        if GLSetup."Shortcut Dimension 1 Code" = DimCode then
            exit(1);
        if GLSetup."Shortcut Dimension 2 Code" = DimCode then
            exit(2);
        if GLSetup."Shortcut Dimension 3 Code" = DimCode then
            exit(3);
        if GLSetup."Shortcut Dimension 4 Code" = DimCode then
            exit(4);
        if GLSetup."Shortcut Dimension 5 Code" = DimCode then
            exit(5);
        if GLSetup."Shortcut Dimension 6 Code" = DimCode then
            exit(6);
        if GLSetup."Shortcut Dimension 7 Code" = DimCode then
            exit(7);
        if GLSetup."Shortcut Dimension 8 Code" = DimCode then
            exit(8);

        Error('Dimension %1 is not defined as a Shortcut Dimension (1–8). Please configure it in General Ledger Setup.', DimCode);
    end;

    local procedure GetNextLineNo(TemplateName: Code[20]; BatchName: Code[20]): Integer
    var
        JnlLine: Record "Gen. Journal Line";
    begin
        JnlLine.SetRange("Journal Template Name", TemplateName);
        JnlLine.SetRange("Journal Batch Name", BatchName);
        if JnlLine.FindLast() then
            exit(JnlLine."Line No." + 10000)
        else
            exit(10000);
    end;

    local procedure EvaluateEnumDocType(ValueTxt: Text): Enum "Gen. Journal Document Type"
    var
        EnumVal: Enum "Gen. Journal Document Type";
        IntVal: Integer;
    begin
        if ValueTxt = '' then
            exit(EnumVal::" "); // blank
        case UpperCase(ValueTxt) of
            'PAYMENT':
                exit(EnumVal::Payment);
            'INVOICE':
                exit(EnumVal::Invoice);
            'CREDIT MEMO', 'CREDIT':
                exit(EnumVal::"Credit Memo");
            'FINANCE CHARGE':
                exit(EnumVal::"Finance Charge Memo");
            'REMINDER':
                exit(EnumVal::Reminder);
            'REFUND':
                exit(EnumVal::Refund);
            else
                Error('Invalid Document Type: %1', ValueTxt);
        end;
    end;

    local procedure EvaluateBool(ValueTxt: Text): Boolean
    begin
        case UpperCase(ValueTxt) of
            'YES', 'Y', 'TRUE', '1':
                exit(true);
            'NO', 'N', 'FALSE', '0':
                exit(false);
        end;
        exit(false);
    end;

    local procedure EvaluateEnumPostingType(ValueTxt: Text): Enum "General Posting Type"
    var
        EnumVal: Enum "General Posting Type";
        IntVal: Integer;
    begin
        if ValueTxt = '' then
            exit(EnumVal::" ");


        case UpperCase(ValueTxt) of
            'SALE':
                exit(EnumVal::Sale);
            'PURCHASE':
                exit(EnumVal::Purchase);
            'SETTLEMENT':
                exit(EnumVal::Settlement);
            else
                exit(EnumVal::" ");
        end;
    end;
}
