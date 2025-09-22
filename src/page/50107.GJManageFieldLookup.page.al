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
                    begin
                        if Rec.Selected then
                            TmplMgt.HandleFieldSelected(TemplateCodeCtx, Rec)
                        else
                            TmplMgt.HandleFieldDeselected(TemplateCodeCtx, Rec);
                    end;
                }
                field("Field No."; Rec."Field No.") { ApplicationArea = All; Editable = false; }
                field("Field Name"; Rec."Field Name") { ApplicationArea = All; Editable = false; }
                // field("Field Caption"; Rec."Field Caption") { ApplicationArea = All; Editable = false; }
                field("Processing Order"; Rec."Processing Order")
                {
                    ApplicationArea = All;
                    Lookup = true;
                    Caption = 'Excel Column Index';
                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(TmplMgt.HandleColumnLookup(TemplateCodeCtx, Rec));
                    end;
                }
                field("Excel Header Text"; Rec."Excel Header Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the Excel header text for the selected column.';
                    Editable = false;
                }
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
