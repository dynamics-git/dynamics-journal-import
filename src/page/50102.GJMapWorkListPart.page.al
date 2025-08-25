page 50502 "GJ Map Work ListPart"
{
    PageType = ListPart;
    SourceTable = "GJ Map Work";
    Caption = 'Column Mapping';
    ApplicationArea = All;


    layout
    {
        area(Content)
        {
            repeater(G)
            {
                field("Column Index"; Rec."Column Index") { ApplicationArea = All; Editable = false; }
                field("Detected Header"; Rec."Detected Header") { ApplicationArea = All; Editable = false; }
                field("Target Field"; Rec."Target Field") { ApplicationArea = All; }
                field("Dimension Code"; Rec."Dimension Code") { ApplicationArea = All; }
                field("Constant Value"; Rec."Constant Value") { ApplicationArea = All; }
            }
        }
    }
}
