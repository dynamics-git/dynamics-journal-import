codeunit 50202 "GJ Import Utils"
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

    procedure EvaluateRecurringMethod(ValueTxt: Text): Enum "Gen. Journal Recurring Method"
    var
        RecurringMethod: Enum "Gen. Journal Recurring Method";
    begin
        if ValueTxt = '' then
            exit(RecurringMethod::" "); // default blank

        case UpperCase(DelChr(ValueTxt, '=', ' ')) of
            'F', 'FIXED', 'F  FIXED':
                exit(RecurringMethod::"F  Fixed");
            'V', 'VARIABLE', 'V  VARIABLE':
                exit(RecurringMethod::"V  Variable");
            'B', 'BALANCE', 'B  BALANCE':
                exit(RecurringMethod::"B  Balance");
            'RF', 'REVERSING FIXED', 'RF REVERSING FIXED':
                exit(RecurringMethod::"RF Reversing Fixed");
            'RV', 'REVERSING VARIABLE', 'RV REVERSING VARIABLE':
                exit(RecurringMethod::"RV Reversing Variable");
            'RB', 'REVERSING BALANCE', 'RB REVERSING BALANCE':
                exit(RecurringMethod::"RB Reversing Balance");
            'BD', 'BALANCE BY DIMENSION', 'BD BALANCE BY DIMENSION':
                exit(RecurringMethod::"BD Balance by Dimension");
            'RBD', 'REVERSING BALANCE BY DIMENSION', 'RBD REVERSING BALANCE BY DIMENSION':
                exit(RecurringMethod::"RBD Reversing Balance by Dimension");
            else
                Error('Invalid Recurring Method value: %1', ValueTxt);
        end;
    end;

    procedure EvaluateTaxCalculationType(ValueTxt: Text): Enum "Tax Calculation Type"
    var
        E: Enum "Tax Calculation Type";
    begin
        case UpperCase(DelChr(ValueTxt, '=', ' ')) of
            'NORMAL VAT':
                exit(E::"Normal VAT");
            'REVERSE CHARGE VAT', 'REVERSE', 'RC':
                exit(E::"Reverse Charge VAT");
            'FULL VAT':
                exit(E::"Full VAT");
            'SALES TAX', 'TAX':
                exit(E::"Sales Tax");
            else
                Error('Invalid Tax Calculation Type: %1', ValueTxt);
        end;
    end;

    procedure EvaluateBankPaymentType(ValueTxt: Text): Enum "Bank Payment Type"
    var
        E: Enum "Bank Payment Type";
    begin
        case UpperCase(DelChr(ValueTxt, '=', ' ')) of
            '', ' ':
                exit(E::" ");
            'COMPUTER CHECK':
                exit(E::"Computer Check");
            'MANUAL CHECK':
                exit(E::"Manual Check");
            'ELECTRONIC PAYMENT', 'EP':
                exit(E::"Electronic Payment");
            'ELECTRONIC PAYMENT-IAT', 'IAT':
                exit(E::"Electronic Payment-IAT");
            else
                Error('Invalid Bank Payment Type: %1', ValueTxt);
        end;
    end;

    procedure EvaluateGenJournalSourceType(ValueTxt: Text): Enum "Gen. Journal Source Type"
    var
        E: Enum "Gen. Journal Source Type";
    begin
        case UpperCase(DelChr(ValueTxt, '=', ' ')) of
            '', ' ':
                exit(E::" ");
            'CUSTOMER':
                exit(E::Customer);
            'VENDOR':
                exit(E::Vendor);
            'BANK ACCOUNT':
                exit(E::"Bank Account");
            'FIXED ASSET':
                exit(E::"Fixed Asset");
            'IC PARTNER':
                exit(E::"IC Partner");
            'EMPLOYEE':
                exit(E::Employee);
            else
                Error('Invalid Source Type: %1', ValueTxt);
        end;
    end;

    procedure EvaluateICDirection(ValueTxt: Text): Enum "IC Direction Type"
    var
        E: Enum "IC Direction Type";
    begin
        case UpperCase(DelChr(ValueTxt, '=', ' ')) of
            'OUTGOING':
                exit(E::Outgoing);
            'INCOMING':
                exit(E::Incoming);
            else
                Error('Invalid IC Direction: %1', ValueTxt);
        end;
    end;

    procedure EvaluateICJournalAccountType(ValueTxt: Text): Enum "IC Journal Account Type"
    var
        E: Enum "IC Journal Account Type";
    begin
        case UpperCase(DelChr(ValueTxt, '=', ' ')) of
            'G/L ACCOUNT', 'GL ACCOUNT':
                exit(E::"G/L Account");
            'BANK ACCOUNT':
                exit(E::"Bank Account");
            else
                Error('Invalid IC Account Type: %1', ValueTxt);
        end;
    end;

    procedure EvaluateJobQueueStatus(ValueTxt: Text): Enum "Document Job Queue Status"
    var
        E: Enum "Document Job Queue Status";
    begin
        case UpperCase(DelChr(ValueTxt, '=', ' ')) of
            '', ' ':
                exit(E::" ");
            'SCHEDULED FOR POSTING':
                exit(E::"Scheduled for Posting");
            'ERROR':
                exit(E::Error);
            'POSTING':
                exit(E::Posting);
            else
                Error('Invalid Job Queue Status: %1', ValueTxt);
        end;
    end;

    procedure EvaluateJobLineType(ValueTxt: Text): Enum "Job Line Type"
    var
        E: Enum "Job Line Type";
    begin
        case UpperCase(DelChr(ValueTxt, '=', ' ')) of
            '', ' ':
                exit(E::" ");
            'BUDGET':
                exit(E::Budget);
            'BILLABLE':
                exit(E::Billable);
            'BOTH', 'BOTH BUDGET AND BILLABLE':
                exit(E::"Both Budget and Billable");
            else
                Error('Invalid Job Line Type: %1', ValueTxt);
        end;
    end;

    procedure EvaluateFAPostingType(ValueTxt: Text): Enum "Gen. Journal Line FA Posting Type"
    var
        E: Enum "Gen. Journal Line FA Posting Type";
    begin
        case UpperCase(DelChr(ValueTxt, '=', ' ')) of
            '', ' ':
                exit(E::" ");
            'ACQUISITION COST':
                exit(E::"Acquisition Cost");
            'DEPRECIATION':
                exit(E::Depreciation);
            'WRITE-DOWN', 'WRITEDOWN':
                exit(E::"Write-Down");
            'APPRECIATION':
                exit(E::Appreciation);
            'CUSTOM 1':
                exit(E::"Custom 1");
            'CUSTOM 2':
                exit(E::"Custom 2");
            'DISPOSAL':
                exit(E::Disposal);
            'MAINTENANCE':
                exit(E::Maintenance);
            else
                Error('Invalid FA Posting Type: %1', ValueTxt);
        end;
    end;

    procedure EvaluateVatPosting(ValueTxt: Text): Option "Automatic VAT Entry","Manual VAT Entry"
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        case UpperCase(DelChr(ValueTxt, '=', ' ')) of
            'AUTOMATIC VAT ENTRY', 'AUTO':
                exit(GenJnlLine."VAT Posting"::"Automatic VAT Entry");
            'MANUAL VAT ENTRY', 'MANUAL':
                exit(GenJnlLine."VAT Posting"::"Manual VAT Entry");
            else
                Error('Invalid VAT Posting: %1', ValueTxt);
        end;
    end;

    procedure EvaluateAdditionalCurrencyPosting(ValueTxt: Text): Option "None","Amount Only","Additional-Currency Amount Only"
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        case UpperCase(DelChr(ValueTxt, '=', ' ')) of
            'NONE':
                exit(GenJnlLine."Additional-Currency Posting"::None);
            'AMOUNT ONLY':
                exit(GenJnlLine."Additional-Currency Posting"::"Amount Only");
            'ADDITIONAL-CURRENCY AMOUNT ONLY', 'AC AMOUNT ONLY':
                exit(GenJnlLine."Additional-Currency Posting"::"Additional-Currency Amount Only");
            else
                Error('Invalid Additional-Currency Posting: %1', ValueTxt);
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

    procedure EvaluateInteger(ValueTxt: Text): Integer
    var
        IntVal: Integer;
    begin
        if ValueTxt = '' then
            exit(0);
        Evaluate(IntVal, ValueTxt);
        exit(IntVal);
    end;

    procedure EvaluateBigInteger(ValueTxt: Text): BigInteger
    var
        BigIntVal: BigInteger;
    begin
        if ValueTxt = '' then
            exit(0);
        Evaluate(BigIntVal, ValueTxt);
        exit(BigIntVal);
    end;

    procedure EvaluateDateTime(ValueTxt: Text): DateTime
    var
        DTVal: DateTime;
    begin
        if ValueTxt = '' then
            exit(0DT);
        Evaluate(DTVal, ValueTxt);
        exit(DTVal);
    end;

    procedure EvaluateTime(ValueTxt: Text): Time
    var
        TVal: Time;
    begin
        if ValueTxt = '' then
            exit(0T);
        Evaluate(TVal, ValueTxt);
        exit(TVal);
    end;

    procedure EvaluateDateFormula(ValueTxt: Text): DateFormula
    var
        DFVal: DateFormula;
    begin
        Clear(DFVal);
        if ValueTxt = '' then
            exit(DFVal);
        Evaluate(DFVal, ValueTxt);
        exit(DFVal);
    end;

    procedure EvaluateGuid(ValueTxt: Text): Guid
    var
        GuidVal: Guid;
    begin
        Evaluate(GuidVal, ValueTxt);
        exit(GuidVal);
    end;
}
