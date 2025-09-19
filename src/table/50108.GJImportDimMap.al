table 50508 "GJ Import Dim Map"
{
    Caption = 'GJ Import Dimension Map';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Template Code"; Code[20])
        {
            Caption = 'Template Code';
            TableRelation = "GJ Import Template".Code;
            NotBlank = true;
        }
        field(2; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code';
            TableRelation = Dimension.Code;
        }
        field(3; "Column Index"; Integer)
        {
            Caption = 'Excel Column (1=A, 2=B, …)';
        }
        field(9; "Excel Header Text"; Text[250])
        {
            Caption = 'Excel Header';
            Editable = false;
        }
        field(4; "Constant Value"; Text[100])
        {
            Caption = 'Constant Value';
        }
    }

    keys
    {
        key(PK; "Template Code", "Dimension Code") { Clustered = true; }
    }
}
