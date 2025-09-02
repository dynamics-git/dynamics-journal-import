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
                    LookupPageId = "GJ Field Lookup";
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
