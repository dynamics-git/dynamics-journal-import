table 50500 "GJ Import Template"
{
    Caption = 'GJ Import Template';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20]) { Caption = 'Template Code'; NotBlank = true; }
        field(2; "Description"; Text[100]) { }
        field(3; "Gen. Jnl. Template Name"; Code[10])
        {
            Caption = 'Gen. Journal Template Name';
            TableRelation = "Gen. Journal Template".Name;
        }
        field(4; "Gen. Jnl. Batch Name"; Code[10])
        {
            Caption = 'Gen. Journal Batch Name';
            TableRelation = "Gen. Journal Batch".Name
                WHERE("Journal Template Name" = FIELD("Gen. Jnl. Template Name"));
        }
        field(5; "Default Posting Date"; Date) { }
        field(6; "Currency Code"; Code[10]) { TableRelation = Currency.Code; }
        field(7; "Bal. Account No."; Code[20]) { Caption = 'Default Bal. Account No.'; }
        field(8; "Has Header Row"; Boolean) { InitValue = true; }
        field(9; "Start Row"; Integer) { InitValue = 2; }
        field(10; "Sheet Name"; Text[50]) { Caption = 'Default Sheet Name'; }
    }

    keys { key(PK; "Code") { Clustered = true; } }
}
