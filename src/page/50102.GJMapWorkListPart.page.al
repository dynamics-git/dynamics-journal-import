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
                    begin
                        F.SetRange(TableNo, 81);
                        F.SetRange(Class, F.Class::Normal);
                        if PAGE.RunModal(PAGE::"GJ Field Lookup", F) = Action::LookupOK then begin

                            Rec."Target Field No." := F."No."; // updates caption via table OnValidate
                            Rec."Target Field Caption" := CopyStr(GetFieldCaptionOrName(F), 1, MaxStrLen(Rec."Target Field Caption"));
                        end;

                    end;
                }
                field("Target Field Caption"; Rec."Target Field Caption")
                {
                    ToolTip = 'Specifies the value of the Target Field Caption field.', Comment = '%';
                }
                // field("Target Field"; Rec."Target Field") { ApplicationArea = All; }

                field("Dimension Code"; Rec."Dimension Code") { ApplicationArea = All; }
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
                    MapRec: Record "GJ Import Column Map";
                    PageFields: Page "GJ Manage Field Lookup";
                    NextLineNo: Integer;
                    OrderNo: Integer;
                begin
                    // open lookup page with current template context
                    PageFields.SetTemplateCode(TemplateCodeCtx);
                    if PageFields.RunModal() = Action::OK then begin
                        PageFields.GetSelections(TempFields); // custom proc on lookup page to expose buffer

                        // Clear existing mappings for this template
                        MapRec.Reset();
                        MapRec.SetRange("Template Code", TemplateCodeCtx);
                        MapRec.DeleteAll();
                        if TempFields.FindSet(true, true) then begin
                            OrderNo := 0;
                            NextLineNo := 1000;
                            repeat
                                if TempFields.Selected then begin
                                    OrderNo += 1;
                                    MapRec.Init();
                                    MapRec."Template Code" := TemplateCodeCtx;
                                    MapRec."Line No." := NextLineNo;
                                    MapRec."Target Field No." := TempFields."Field No.";
                                    MapRec."Target Field Caption" := TempFields."Field Caption";
                                    MapRec."Column Index" := TempFields."Processing Order";
                                    ; // optional: store processing order as Column Index
                                    MapRec.Insert();
                                    NextLineNo += 1000;
                                end;
                            until TempFields.Next() = 0;
                        end;
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

    local procedure GetFieldCaptionOrName(var F: Record Field): Text
    begin
        // Prefer Caption if available; otherwise field name
        if F."Field Caption" <> '' then
            exit(Format(F."Field Caption"));
        exit(F.FieldName);
    end;
}
