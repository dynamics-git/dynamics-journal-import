page 50503 "GJ Import Template Card"
{
    PageType = Card;
    SourceTable = "GJ Import Template";
    Caption = 'GJ Import Template';
    ApplicationArea = All;
    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Code"; Rec."Code") { }
                field("Description"; Rec."Description") { }
                field("Gen. Jnl. Template Name"; Rec."Gen. Jnl. Template Name") { }
                field("Gen. Jnl. Batch Name"; Rec."Gen. Jnl. Batch Name") { }
                field("Default Posting Date"; Rec."Default Posting Date") { }
                field("Currency Code"; Rec."Currency Code") { }
                field("Bal. Account No."; Rec."Bal. Account No.") { }
                field("Has Header Row"; Rec."Has Header Row") { }
                field("Start Row"; Rec."Start Row") { }
                field("Sheet Name"; Rec."Sheet Name") { }
            }
            part(Map; "GJ Map Work ListPart")
            {
                SubPageLink = "Template Code" = field(Code);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Import)
            {
                Caption = 'Upload & Import';
                Image = ImportExcel;
                ApplicationArea = All;
                trigger OnAction()
                var
                    Runner: Page "GJ Upload Runner";
                begin
                    Runner.SetTemplate(Rec."Code");
                    Runner.RunModal();
                end;
            }
        }
    }
}
