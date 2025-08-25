table 50505 "GJ Dimension Mapping"
{
    Caption = 'GJ Dimension Mapping';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Dimension Code"; Code[20]) { TableRelation = Dimension.Code; }
        field(2; "External Dim Code"; Code[30]) { Caption = 'External Dimension Code'; }
        field(3; "Dimension Value Code"; Code[20])
        {
            TableRelation = "Dimension Value".Code WHERE("Dimension Code" = FIELD("Dimension Code"));
            Caption = 'BC Dimension Value';
        }
    }

    keys { key(PK; "Dimension Code", "External Dim Code") { Clustered = true; } }
}
