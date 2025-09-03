page 50507 "GJ Manage Field Lookup"
{
    PageType = List;
    SourceTable = "GJ Field Temp";
    Caption = 'Gen. Journal Line Fields';
    ApplicationArea = All;
    Editable = true;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Selected; Rec.Selected)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        R: Record "GJ Field Temp";
                        MaxOrder: Integer;
                    begin
                        if Rec.Selected and (Rec."Processing Order" = 0) then begin
                            MaxOrder := 0;
                            R.Copy(Rec, true);

                            if R.FindSet() then
                                repeat
                                    if R.Selected and (R."Processing Order" > MaxOrder) then
                                        MaxOrder := R."Processing Order";
                                until R.Next() = 0;

                            Rec."Processing Order" := MaxOrder + 1;
                        end;
                    end;
                }
                field("Field No."; Rec."Field No.") { ApplicationArea = All; Editable = false; }
                field("Field Name"; Rec."Field Name") { ApplicationArea = All; Editable = false; }
                field("Field Caption"; Rec."Field Caption") { ApplicationArea = All; Editable = false; }
                field("Processing Order"; Rec."Processing Order") { ApplicationArea = All; }
            }
        }
    }

    var
        TemplateCodeCtx: Code[20];

    trigger OnOpenPage()
    var
        F: Record Field;
        Map: Record "GJ Import Column Map";
        OrderNo: Integer;
    begin
        Rec.Reset();
        Rec.DeleteAll();

        // preload existing mapping for this template
        Map.SetRange("Template Code", TemplateCodeCtx);

        // STEP 1: Load mapped fields first (keep their stored order)
        if Map.FindSet() then
            repeat
                if F.Get(81, Map."Target Field No.") then begin
                    Rec.Init();
                    Rec."Field No." := F."No.";
                    Rec."Field Name" := F.FieldName;
                    Rec."Field Caption" := F."Field Caption";
                    Rec.Selected := true;
                    Rec."Processing Order" := Map."Column Index"; // or your processing field
                    Rec.Insert();
                end;
            until Map.Next() = 0;

        // Find current max order
        OrderNo := 0;
        if Rec.FindLast() then
            OrderNo := Rec."Processing Order";

        // STEP 2: Load unmapped fields afterwards
        F.Reset();
        F.SetRange(TableNo, 81);
        F.SetRange(Class, F.Class::Normal);

        if F.FindSet() then
            repeat
                if not Rec.Get(F."No.") then begin // only insert if not already mapped
                    OrderNo += 1;
                    Rec.Init();
                    Rec."Field No." := F."No.";
                    Rec."Field Name" := F.FieldName;
                    Rec."Field Caption" := F."Field Caption";
                    Rec.Selected := false;
                    Rec."Processing Order" := 0;
                    Rec.Insert();
                end;
            until F.Next() = 0;
    end;

    procedure SetTemplateCode(TemplateCode: Code[20])
    begin
        TemplateCodeCtx := TemplateCode;
    end;

    procedure GetSelections(var TempFields: Record "GJ Field Temp" temporary)
    begin
        CurrPage.SetSelectionFilter(TempFields);
        // OR: copy all buffer back, not just selected rows
        TempFields.Copy(Rec, true);
    end;
}
