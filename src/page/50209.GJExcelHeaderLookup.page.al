page 50209 "GJ Excel Header Lookup"
{
    PageType = List;
    SourceTable = "GJ Excel Header Map";
    Caption = 'Excel Headers';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Column Index"; Rec."Column Index") { }
                field("Header Text"; Rec."Header Text") { }
            }
        }
    }
}
