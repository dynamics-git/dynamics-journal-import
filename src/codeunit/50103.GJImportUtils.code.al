codeunit 50503 "GJ Import Utils"
{

    procedure EvaluateEnumAccountType(ValueTxt: Text): Enum "Gen. Journal Account Type"
    var
        EnumVal: Enum "Gen. Journal Account Type";
    begin
        case UpperCase(ValueTxt) of
            '':
                exit(EnumVal::"G/L Account");
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
                Error('Invalid Account Type: %1', ValueTxt);
        end;
    end;

    procedure EvaluateEnumDocType(ValueTxt: Text): Enum "Gen. Journal Document Type"
    var
        EnumVal: Enum "Gen. Journal Document Type";
    begin
        case UpperCase(ValueTxt) of
            '':
                exit(EnumVal::" ");
            'PAYMENT':
                exit(EnumVal::Payment);
            'INVOICE':
                exit(EnumVal::Invoice);
            'CREDIT', 'CREDIT MEMO':
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

    procedure EvaluateEnumPostingType(ValueTxt: Text): Enum "General Posting Type"
    var
        EnumVal: Enum "General Posting Type";
    begin
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

    procedure EvaluateDate(ValueTxt: Text): Date
    var
        D: Date;
    begin
        if ValueTxt = '' then
            exit(0D);
        if not Evaluate(D, ValueTxt) then
            Error('Invalid Date: %1', ValueTxt);
        exit(D);
    end;

    procedure EvaluateDecimal(ValueTxt: Text): Decimal
    var
        Dec: Decimal;
    begin
        if ValueTxt = '' then
            exit(0);
        if not Evaluate(Dec, ValueTxt) then
            Error('Invalid Decimal: %1', ValueTxt);
        exit(Dec);
    end;

    procedure EvaluateBool(ValueTxt: Text): Boolean
    begin
        case UpperCase(ValueTxt) of
            'YES', 'Y', 'TRUE', '1':
                exit(true);
            'NO', 'N', 'FALSE', '0':
                exit(false);
        end;
        exit(false);
    end;

    // --- Cleanup helpers ---
    procedure CleanupStaging(UploadId: Guid)
    var
        StagingHdr: Record "GJ Staging Header";
        StagingLine: Record "GJ Staging Line";
    begin
        StagingLine.SetRange("Upload Id", UploadId);
        StagingLine.DeleteAll();

        if StagingHdr.Get(UploadId) then
            StagingHdr.Delete(true);
    end;

    // --- Generic line no helper ---
    procedure GetNextGenJnlLineNo(TemplateName: Code[20]; BatchName: Code[20]): Integer
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

    procedure GetGJStagingLineColOneFieldRef(): Integer
    begin
        exit(3);
    end;
}
