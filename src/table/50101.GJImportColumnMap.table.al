table 50501 "GJ Import Column Map"
{
    Caption = 'GJ Import Column Map';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Template Code"; Code[20]) { TableRelation = "GJ Import Template".Code; }
        field(2; "Line No."; Integer) { }
        field(3; "Column Index"; Integer) { Caption = 'Column (1=A, 2=B, …)'; }
        field(4; "Target Field No."; Integer)
        {
            Caption = 'Target Field';
        }
        field(6; "Constant Value"; Text[100]) { }
        field(7; "Notes"; Text[100]) { }
        field(8; "Target Field Caption"; Text[100])
        {
            Caption = 'Target Field Caption';
            Editable = false;
        }
        field(9; "Excel Header Text"; Text[250])
        {
            Caption = 'Excel Header';
            Editable = false;
        }
    }

    keys { key(PK; "Template Code", "Target Field No.") { Clustered = true; } }
    trigger OnInsert()
    var
        MapRec: Record "GJ Import Column Map";
    begin
        TestField("Template Code");
        if "Line No." = 0 then begin
            MapRec.Reset();
            MapRec.SetCurrentKey("Template Code", "Line No.");
            MapRec.SetRange("Template Code", "Template Code");
            if MapRec.FindLast() then
                "Line No." := MapRec."Line No." + 1000
            else
                "Line No." := 1000;
        end;
    end;
}
