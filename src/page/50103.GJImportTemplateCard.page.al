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
                field("Code"; Rec."Code")
                {
                    trigger OnValidate()
                    begin
                        if Rec.Code <> '' then begin
                            CurrPage.Map.PAGE.SetTemplateCode(Rec.Code);
                            CurrPage.DimMap.PAGE.SetTemplateCode(Rec.Code);
                            EnsureDimMappingExists(Rec.Code);
                        end;
                    end;
                }
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
                UpdatePropagation = Both;
            }
            part(DimMap; "GJ Dim Map ListPart")
            {
                SubPageLink = "Template Code" = field(Code);
                UpdatePropagation = Both;
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
    trigger OnAfterGetCurrRecord()
    begin
        // Pass the context so new lines are prefilled
        if Rec.Code <> '' then begin
            CurrPage.Map.PAGE.SetTemplateCode(Rec.Code);
            CurrPage.DimMap.PAGE.SetTemplateCode(Rec.Code);
            EnsureDimMappingExists(Rec.Code);
        end;

    end;


    local procedure EnsureDimMappingExists(TemplateCode: Code[20])
    var
        Dim: Record Dimension;
        Map: Record "GJ Import Dim Map";
    begin
        // Loop all dimensions
        if Dim.FindSet() then
            repeat
                if not Map.Get(TemplateCode, Dim.Code) then begin
                    Map.Init();
                    Map."Template Code" := TemplateCode;
                    Map."Dimension Code" := Dim.Code;
                    Map."Column Index" := 0; // empty until user assigns
                    Map."Constant Value" := '';
                    Map.Insert();
                end;
            until Dim.Next() = 0;
    end;


}
