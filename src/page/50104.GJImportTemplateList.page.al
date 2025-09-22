page 50504 "GJ Import Template List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GJ Import Template";
    Caption = 'GJ Import Template List';
    CardPageId = "GJ Import Template Card";
    Editable = false;


    layout
    {
        area(Content)
        {
            repeater(General)
            {

                field("Code"; Rec."Code")
                {
                    ToolTip = 'Specifies the value of the Template Code field.', Comment = '%';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("Gen. Jnl. Template Name"; Rec."Gen. Jnl. Template Name")
                {
                    ToolTip = 'Specifies the value of the Gen. Journal Template Name field.', Comment = '%';
                }
                field("Gen. Jnl. Batch Name"; Rec."Gen. Jnl. Batch Name")
                {
                    ToolTip = 'Specifies the value of the Gen. Journal Batch Name field.', Comment = '%';
                }

                field("Has Header Row"; Rec."Has Header Row")
                {
                    ToolTip = 'Specifies the value of the Has Header Row field.', Comment = '%';
                }
                field("Start Row"; Rec."Start Row")
                {
                    ToolTip = 'Specifies the value of the Start Row field.', Comment = '%';
                }
            }

        }
    }



    var
        myInt: Integer;
}