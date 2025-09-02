page 50506 "GJ Field Lookup"
{
    PageType = List;
    SourceTable = Field;
    Caption = 'Gen. Journal Line Fields';
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("No."; Rec."No.") { ApplicationArea = All; Caption = 'Field No.'; }
                field("Field Name"; Rec.FieldName) { ApplicationArea = All; }
                field(Caption; Rec."Field Caption") { ApplicationArea = All; }
            }
        }
    }

    trigger OnOpenPage()
    begin
        // Show only Gen. Journal Line fields (table 81), and only "Normal" fields
        Rec.SetRange(TableNo, 81);
        Rec.SetRange(Class, Rec.Class::Normal);
    end;
}
