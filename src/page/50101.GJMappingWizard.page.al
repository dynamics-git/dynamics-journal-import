page 50501 "GJ Mapping Wizard"
{
    PageType = Card;
    Caption = 'Mapping Wizard';
    SourceTable = "GJ Staging Header";
    ApplicationArea = All;
    layout
    {
        area(Content)
        {
            group(Info)
            {
                field("Upload Id"; Rec."Upload Id") { ApplicationArea = All; Editable = false; }
                field("File Name"; Rec."File Name") { ApplicationArea = All; Editable = false; }
                field("Sheet Name"; Rec."Sheet Name") { ApplicationArea = All; Editable = false; }
                field("First Data Row"; Rec."First Data Row") { ApplicationArea = All; Editable = false; }
                field("Last Data Row"; Rec."Last Data Row") { ApplicationArea = All; Editable = false; }
                field("Last Data Col"; Rec."Last Data Col") { ApplicationArea = All; Editable = false; }
            }
            // part(MapLines; "GJ Map Work ListPart")
            // {
            //     SubPageLink = "Upload Id" = FIELD("Upload Id");
            //     ApplicationArea = All;
            // }
            part(StagingLines; "GJ Staging Line ListPart")
            {
                SubPageLink = "Upload Id" = FIELD("Upload Id");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Processing)
        {


            action(CreateGenJnlLine)
            {
                Caption = 'Create Gen. Jnl Line';
                ApplicationArea = All;
                Image = Import;

                trigger OnAction()
                var
                    Work: Record "GJ Map Work";
                    Tmpl: Record "GJ Import Template";
                    Map: Record "GJ Import Column Map";
                    Engine: Codeunit "GJ From Staging Importer";
                    tmplCode: Code[20];
                begin
                    // Resolve template code (existing or new)
                    tmplCode := Rec."Template Code";
                    if tmplCode = '' then
                        Error('Please set an existing template or a new template name before saving mapping.');

                    // Call importer (staging -> journal) using this template
                    Engine.RunFromStaging(Rec."Upload Id");

                    Message('Imported to journal using template %1. Open your General Journal batch to review and post.', tmplCode);
                end;
            }
        }
    }
}
