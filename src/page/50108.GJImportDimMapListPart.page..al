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
                }
                field("Constant Value"; Rec."Constant Value")
                {
                    ApplicationArea = All;
                }
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
