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
            action(GenerateMapRows)
            {
                Caption = 'Load Columns';
                ApplicationArea = All;
                Image = Setup;

                trigger OnAction()
                var
                    Work: Record "GJ Map Work";
                    ExcelBuf: Record "Excel Buffer";
                    InS: InStream;
                    FN: Text; // not used here; we’ll pull headers from row 1 via a helper if needed
                    col: Integer;
                    hdrTxt: Text;
                    SL: Record "GJ Staging Line";
                begin
                    // Clear old work rows
                    Work.Reset();
                    Work.SetRange("Upload Id", Rec."Upload Id");
                    if Work.FindSet() then Work.DeleteAll();

                    // If file had headers (row 1), try to pull them from the actual Excel:
                    // For simplicity, we derive header text from the first staged data row's values
                    // or leave blank (you can enhance if you want exact row1 read).
                    for col := 1 to Rec."Last Data Col" do begin
                        Work.Init();
                        Work."Upload Id" := Rec."Upload Id";
                        Work."Column Index" := col;
                        // Try to show sample value from first staged row to help mapping
                        SL.Reset();
                        SL.SetRange("Upload Id", Rec."Upload Id");
                        if SL.FindFirst() then begin
                            case col of
                                1:
                                    hdrTxt := SL."Col1";
                                2:
                                    hdrTxt := SL."Col2";
                                3:
                                    hdrTxt := SL."Col3";
                                4:
                                    hdrTxt := SL."Col4";
                                5:
                                    hdrTxt := SL."Col5";
                                6:
                                    hdrTxt := SL."Col6";
                                7:
                                    hdrTxt := SL."Col7";
                                8:
                                    hdrTxt := SL."Col8";
                                9:
                                    hdrTxt := SL."Col9";
                                10:
                                    hdrTxt := SL."Col10";
                                11:
                                    hdrTxt := SL."Col11";
                                12:
                                    hdrTxt := SL."Col12";
                                13:
                                    hdrTxt := SL."Col13";
                                14:
                                    hdrTxt := SL."Col14";
                                15:
                                    hdrTxt := SL."Col15";
                                16:
                                    hdrTxt := SL."Col16";
                                17:
                                    hdrTxt := SL."Col17";
                                18:
                                    hdrTxt := SL."Col18";
                                19:
                                    hdrTxt := SL."Col19";
                                20:
                                    hdrTxt := SL."Col20";
                            end;
                        end;
                        Work."Detected Header" := CopyStr(hdrTxt, 1, 100);
                        Work.Insert();
                    end;

                    Message('Columns loaded. Please map Target Fields, set Dimension Code (if Dimension), and constants as needed.');
                end;
            }

            action(SaveMapAndImport)
            {
                Caption = 'Save Mapping & Import to Journal';
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
                        tmplCode := Rec."New Template Name";
                    if tmplCode = '' then
                        Error('Please set an existing template or a new template name before saving mapping.');

                    // Create template header if new
                    if not Tmpl.Get(tmplCode) then begin
                        Tmpl.Init();
                        Tmpl.Code := tmplCode;
                        Tmpl.Description := StrSubstNo('Auto-created from upload %1', Rec."Upload Id");
                        // User can adjust later in Template Card; for now set minimal batch (must be set before using!)
                        // You may set defaults or ask user elsewhere. For demo, leave empty; Engine will error if missing.
                        Tmpl."Has Header Row" := Rec."Has Header Row";
                        Tmpl."Start Row" := Rec."First Data Row";
                        Tmpl.Insert();
                    end;

                    // Save column mappings (overwrite existing for this template)
                    Map.Reset();
                    Map.SetRange("Template Code", tmplCode);
                    if Map.FindSet() then Map.DeleteAll();

                    Work.Reset();
                    Work.SetRange("Upload Id", Rec."Upload Id");
                    if Work.FindSet() then
                        repeat
                            Map.Init();
                            Map."Template Code" := tmplCode;
                            Map."Column Index" := Work."Column Index";
                            Map."Target Field" := Work."Target Field";
                            Map."Dimension Code" := Work."Dimension Code";
                            Map."Constant Value" := Work."Constant Value";
                            Map.Insert(true);
                        until Work.Next() = 0;

                    // Persist back chosen template code
                    Rec."Template Code" := tmplCode;
                    Rec.Modify(true);

                    // Call importer (staging -> journal) using this template
                    Engine.RunFromStaging(Rec."Upload Id");

                    Message('Imported to journal using template %1. Open your General Journal batch to review and post.', tmplCode);
                end;
            }
        }
    }
}
