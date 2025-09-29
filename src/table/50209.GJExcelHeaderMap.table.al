table 50209 "GJ Excel Header Map"
{
    DataClassification = ToBeClassified;
    fields
    {
        field(1; "Upload Id"; Guid) { }
        field(2; "Template Code"; Code[20])
        {
            Caption = 'Template Code';
            TableRelation = "GJ Import Template".Code;
            NotBlank = true;
        }
        field(3; "Column Index"; Integer) { }
        field(4; "Header Text"; Text[250]) { }
    }

    keys
    {
        key(PK; "Upload Id", "Template Code", "Column Index") { Clustered = true; }
    }
}
