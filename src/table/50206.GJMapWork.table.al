table 50206 "GJ Map Work"
{
    Caption = 'GJ Map Work';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Upload Id"; Guid) { }
        field(2; "Template Code"; Code[20]) { Caption = 'Template Code (optional)'; }
        field(3; "Line No."; Integer) { AutoIncrement = true; }
        field(4; "Column Index"; Integer) { Caption = 'Column (1=A,2=B,...)'; }
        field(5; "Detected Header"; Text[100]) { Caption = 'Detected Header (optional)'; }
        field(6; "Target Field"; Option)
        {
            Caption = 'Target Field';
            OptionMembers = "None","AccountType","AccountNo","PostingDate","DocumentNo","Description","Amount","BalAccountNo","CurrencyCode","Dimension";
        }
        field(7; "Dimension Code"; Code[20]) { TableRelation = Dimension.Code; }
        field(8; "Constant Value"; Text[100]) { }
    }

    keys { key(PK; "Upload Id", "Line No.") { Clustered = true; } }
}
