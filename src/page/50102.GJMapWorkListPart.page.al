page 50502 "GJ Map Work ListPart"
{
    PageType = ListPart;
    SourceTable = "GJ Import Column Map";
    Caption = 'Column Mapping';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(G)
            {
                field("Column Index"; Rec."Column Index") { ApplicationArea = All; }
                field("Target Field No."; Rec."Target Field No.")
                {
                    ToolTip = 'Specifies the value of the Target Field field.', Comment = '%';
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        F: Record Field;
                        TmplMgt: Codeunit "GJ Template Management";
                    begin
                        F.SetRange(TableNo, 81);
                        F.SetRange(Class, F.Class::Normal);
                        if PAGE.RunModal(PAGE::"GJ Field Lookup", F) = Action::LookupOK then begin
                            Rec."Target Field No." := F."No.";
                            Rec."Target Field Caption" := CopyStr(TmplMgt.GetFieldCaptionOrName(F), 1, MaxStrLen(Rec."Target Field Caption"));
                        end;
                    end;
                }
                field("Target Field Caption"; Rec."Target Field Caption")
                {
                    ToolTip = 'Specifies the value of the Target Field Caption field.', Comment = '%';
                }
                field("Constant Value"; Rec."Constant Value") { ApplicationArea = All; }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(ManageFields)
            {
                Caption = 'Manage Fields…';
                Image = Setup;
                ApplicationArea = All;
                trigger OnAction()
                var
                    TempFields: Record "GJ Field Temp" temporary;
                    PageFields: Page "GJ Manage Field Lookup";
                    TmplMgt: Codeunit "GJ Template Management";
                begin
                    PageFields.SetTemplateCode(TemplateCodeCtx);

                    if PageFields.RunModal() = Action::OK then begin
                        PageFields.GetSelections(TempFields);
                        TmplMgt.SaveFieldSelections(TemplateCodeCtx, TempFields);
                    end;
                    CurrPage.Update(false);
                end;
            }
        }
    }
    trigger OnNewRecord(BelowxRec: Boolean)
    var
        MapRec: Record "GJ Import Column Map";
    begin
        // Make sure new lines inherit the Template Code from parent
        if Rec."Template Code" = '' then
            Rec."Template Code" := TemplateCodeCtx;

    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.TestField("Template Code");
        exit(true);
    end;

    var
        TemplateCodeCtx: Code[20];

    procedure SetTemplateCode(TemplateCode: Code[20])
    begin
        TemplateCodeCtx := TemplateCode;
    end;
}
