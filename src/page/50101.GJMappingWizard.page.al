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
                field("Template Code"; Rec."Template Code") { ApplicationArea = All; Editable = false; }
                field("File Name"; Rec."File Name") { ApplicationArea = All; Editable = false; }
                field("Sheet Name"; Rec."Sheet Name") { ApplicationArea = All; Editable = false; }
                field("First Data Row"; Rec."First Data Row") { ApplicationArea = All; Editable = false; }
                field("Last Data Row"; Rec."Last Data Row") { ApplicationArea = All; Editable = false; }
                field("Last Data Col"; Rec."Last Data Col") { ApplicationArea = All; Editable = false; }
            }
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
                    tmplCode := Rec."Template Code";
                    if tmplCode = '' then
                        Error('Please set an existing template or a new template name before saving mapping.');
                        
                    Engine.RunFromStaging(Rec."Upload Id");

                    Message('Imported to journal using template %1. Open your General Journal batch to review and post.', tmplCode);
                end;
            }
            action(OpenTemplate)
            {
                Caption = 'Open Template Card';
                ApplicationArea = All;
                Image = Card;

                trigger OnAction()
                var
                    Tmpl: Record "GJ Import Template";
                begin
                    if Rec."Template Code" = '' then
                        Error('No Template Code assigned yet.');

                    if not Tmpl.Get(Rec."Template Code") then
                        Error('Template %1 not found.', Rec."Template Code");

                    PAGE.Run(PAGE::"GJ Import Template Card", Tmpl);
                end;
            }
        }
    }
}
