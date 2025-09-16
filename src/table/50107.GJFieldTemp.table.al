table 50507 "GJ Field Temp"
{

    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Field No."; Integer) { }
        field(2; "Field Name"; Text[100]) { }
        field(3; "Field Caption"; Text[100]) { }
        field(4; "Selected"; Boolean) { }
        field(5; "Processing Order"; Integer) { }
        field(6; "Excel Header Text"; Text[250])
        {
        }
    }

    keys { key(PK; "Field No.") { Clustered = true; } }
}
