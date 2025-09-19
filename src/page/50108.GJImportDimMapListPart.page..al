page 50508 "GJ Dim Map ListPart"
{
    PageType = ListPart;
    SourceTable = "GJ Import Dim Map";
    Caption = 'Dimension Mapping';
    ApplicationArea = All;
    InsertAllowed = false;
    // DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Column Index"; Rec."Column Index")
                {
                    ApplicationArea = All;
                    Caption = 'Excel Column Index';
                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Hdr: Record "GJ Excel Header Map";
                    begin
                        if PAGE.RunModal(PAGE::"GJ Excel Header Lookup", Hdr) = Action::LookupOK then begin
                            Rec."Column Index" := Hdr."Column Index";
                            Rec."Excel Header Text" := Hdr."Header Text"; // optional: show text for clarity
                        end;
                    end;
                }
                field("Excel Header Text"; Rec."Excel Header Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the Excel header text for the selected column.';
                    Editable = false;
                }
                // field("Constant Value"; Rec."Constant Value")
                // {
                //     ApplicationArea = All;
                // }
            }
        }
    }

    var
        TemplateCodeCtx: Code[20];

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if Rec."Template Code" = '' then
            Rec."Template Code" := TemplateCodeCtx;
    end;

    procedure SetTemplateCode(TemplateCode: Code[20])
    begin
        TemplateCodeCtx := TemplateCode;
    end;
}
