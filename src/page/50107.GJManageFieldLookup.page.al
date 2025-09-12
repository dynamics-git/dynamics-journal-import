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

    begin
        TmplMgt.LoadFieldTempBuffer(TemplateCodeCtx, Rec);
    end;

    procedure SetTemplateCode(TemplateCode: Code[20])
    begin
        TemplateCodeCtx := TemplateCode;
    end;

    procedure GetSelections(var TempFields: Record "GJ Field Temp" temporary)
    begin
        CurrPage.SetSelectionFilter(TempFields);
        TempFields.Copy(Rec, true);
    end;

    var
        TmplMgt: Codeunit "GJ Template Management";
}
