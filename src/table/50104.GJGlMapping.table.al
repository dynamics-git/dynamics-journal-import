table 50504 "GJ GL Mapping"
{
    Caption = 'GJ GL Mapping';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "External GL Code"; Code[30]) { Caption = 'External G/L Code'; }
        field(2; "G/L Account No."; Code[20]) { TableRelation = "G/L Account"."No."; }
    }

    keys { key(PK; "External GL Code") { Clustered = true; } }
}
