page 50207 "GJ Manage Field Lookup"
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
                        Hdr: Record "GJ Excel Header Map";
                        Map: Record "GJ Import Column Map";
                        MaxLineNo: Integer;
                        OrderCount: Integer;
                    begin
                        Rec."Processing Order" := 0;
                        Rec."Excel Header Text" := '';

                        if Rec.Selected and (Rec."Processing Order" = 0) then begin
                            // calculate processing order
                            Map.Reset();
                            Map.SetRange("Template Code", TemplateCodeCtx);
                            OrderCount := Map.Count;
                            Rec."Processing Order" := OrderCount + 1;

                            // insert into column map if not exists
                            Map.Reset();
                            Map.SetRange("Template Code", TemplateCodeCtx);
                            Map.SetRange("Target Field No.", Rec."Field No.");
                            if not Map.FindFirst() then begin
                                Map.Reset();
                                Map.SetRange("Template Code", TemplateCodeCtx);
                                if Map.FindLast() then
                                    MaxLineNo := Map."Line No."
                                else
                                    MaxLineNo := 0;

                                Map.Init();
                                Map."Template Code" := TemplateCodeCtx;
                                Map."Line No." := MaxLineNo + 1000; // auto increment by 1000
                                Map."Target Field No." := Rec."Field No.";
                                Map."Target Field Caption" := Rec."Field Name";
                                Map."Column Index" := Rec."Processing Order";
                                Map."Excel Header Text" := Rec."Excel Header Text";
                                Map.Insert();
                            end;
                        end else begin
                            // deselect -> delete from column map
                            Map.Reset();
                            Map.SetRange("Template Code", TemplateCodeCtx);
                            Map.SetRange("Target Field No.", Rec."Field No.");
                            if Map.FindFirst() then
                                Map.Delete();
                        end;

                        // update excel header text
                        if Rec."Processing Order" > 0 then begin
                            Hdr.SetRange("Template Code", TemplateCodeCtx);
                            Hdr.SetRange("Column Index", Rec."Processing Order");
                            if Hdr.FindFirst() then
                                Rec."Excel Header Text" := Hdr."Header Text";
                        end;
                    end;
                }

                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

                // field("Field Caption"; Rec."Field Caption") { ApplicationArea = All; Editable = false; }

                field("Processing Order"; Rec."Processing Order")
                {
                    ApplicationArea = All;
                    Lookup = true;
                    Caption = 'Excel Column Index';
                    Editable = Rec.Selected;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Hdr: Record "GJ Excel Header Map";
                        Map: Record "GJ Import Column Map";
                    begin
                        Hdr.Reset();
                        Hdr.SetRange("Template Code", TemplateCodeCtx);

                        if PAGE.RunModal(PAGE::"GJ Excel Header Lookup", Hdr) = Action::LookupOK then begin
                            Rec."Processing Order" := Hdr."Column Index";
                            Rec."Excel Header Text" := Hdr."Header Text"; // optional: show text for clarity

                            Map.Reset();
                            Map.SetRange("Template Code", TemplateCodeCtx);
                            Map.SetRange("Target Field No.", Rec."Field No.");
                            if Map.FindFirst() then begin
                                Map."Column Index" := Hdr."Column Index";
                                Map."Excel Header Text" := Hdr."Header Text";
                                Map.Modify();
                            end;
                        end;
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
        TmplMgt: Codeunit "GJ Template Management";

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
}
