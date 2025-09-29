table 50202 "GJ Staging Header"

{

    Caption = 'GJ Staging Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Upload Id"; Guid) { Caption = 'Upload Id'; }
        field(2; "Template Code"; Code[20]) { Caption = 'Template Code'; }
        field(3; "New Template Name"; Code[20]) { Caption = 'New Template Name'; }
        field(4; "File Name"; Text[250]) { }
        field(5; "Sheet Name"; Text[50]) { }
        field(6; "First Data Row"; Integer) { }
        field(7; "Last Data Row"; Integer) { }
        field(8; "Last Data Col"; Integer) { }
        field(9; "Created At"; DateTime) { }
        field(10; "User Id"; Code[50]) { }
        field(11; "Has Header Row"; Boolean) { }
    }

    keys { key(PK; "Upload Id") { Clustered = true; } }

}