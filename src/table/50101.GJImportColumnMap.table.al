table 50501 "GJ Import Column Map"
{
    Caption = 'GJ Import Column Map';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Template Code"; Code[20]) { TableRelation = "GJ Import Template".Code; }
        field(2; "Line No."; Integer) { }
        field(3; "Column Index"; Integer) { Caption = 'Column (1=A, 2=B, …)'; }
        // field(4; "Target Field"; Option)
        // {
        //     Caption = 'Target Field';
        //     OptionMembers = "None","AccountType","AccountNo","PostingDate","DocumentNo","Description","Amount","BalAccountNo","CurrencyCode","Dimension";
        //     OptionCaption = 'None,Account Type,Account No.,Posting Date,Document No.,Description,Amount,Bal. Account No.,Currency Code,Dimension';
        // }
        field(4; "Target Field No."; Integer)
        {
            Caption = 'Target Field';
            // Virtual table "Field" (2000000041); show only fields from table 81 (Gen. Journal Line)
            TableRelation = Field."No." WHERE(TableNo = CONST(81));
            // LookupPageId = "GJ Field Lookup";
            trigger OnValidate()
            var
                F: Record Field;
            begin
                Clear("Target Field Caption");
                F.SetRange(TableNo, 81);
                F.SetRange("No.", "Target Field No.");
                if F.FindFirst() then
                    "Target Field Caption" := CopyStr(GetFieldCaptionOrName(F), 1, MaxStrLen("Target Field Caption"));
            end;
        }

        // Readable caption for the chosen field (auto-filled on validate)
        field(8; "Target Field Caption"; Text[100])
        {
            Caption = 'Target Field Caption';
            Editable = false;
        }
        field(5; "Dimension Code"; Code[20]) { TableRelation = Dimension.Code; }
        field(6; "Constant Value"; Text[100]) { }
        field(7; "Notes"; Text[100]) { }
    }

    keys { key(PK; "Template Code", "Line No.") { Clustered = true; } }
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

    local procedure GetFieldCaptionOrName(var F: Record Field): Text
    begin
        // Prefer Caption if available; otherwise field name
        if F."Field Caption" <> '' then
            exit(Format(F."Field Caption"));
        exit(F.FieldName);
    end;
}
