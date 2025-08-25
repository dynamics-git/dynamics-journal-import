table 50501 "GJ Import Column Map"
{
    Caption = 'GJ Import Column Map';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Template Code"; Code[20]) { TableRelation = "GJ Import Template".Code; }
        field(2; "Line No."; Integer) { AutoIncrement = true; }
        field(3; "Column Index"; Integer) { Caption = 'Column (1=A, 2=B, …)'; }
        field(4; "Target Field"; Option)
        {
            Caption = 'Target Field';
            OptionMembers = "None","AccountType","AccountNo","PostingDate","DocumentNo","Description","Amount","BalAccountNo","CurrencyCode","Dimension";
            OptionCaption = 'None,Account Type,Account No.,Posting Date,Document No.,Description,Amount,Bal. Account No.,Currency Code,Dimension';
        }
        field(5; "Dimension Code"; Code[20]) { TableRelation = Dimension.Code; }
        field(6; "Constant Value"; Text[100]) { }
        field(7; "Notes"; Text[100]) { }
    }

    keys { key(PK; "Template Code", "Line No.") { Clustered = true; } }
}
