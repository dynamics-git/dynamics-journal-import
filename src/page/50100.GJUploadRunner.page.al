page 50500 "GJ Upload Runner"
{
    PageType = Card;                  // was StandardDialog
    UsageCategory = Tasks;
    Caption = 'GJ Upload Runner';
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            group(Template)
            {
                field(ExistingTemplate; ExistingTemplate)
                {
                    Caption = 'Use Existing Template (optional)';
                    TableRelation = "GJ Import Template".Code;
                    ApplicationArea = All;
                }
                field(NewTemplate; NewTemplate)
                {
                    Caption = 'Or Create New Template Name';
                    ApplicationArea = All;
                }
            }
            group(Options)
            {
                field(SheetName; SheetName) { Caption = 'Sheet Name (blank=choose)'; ApplicationArea = All; }
                field(HasHeader; HasHeader) { Caption = 'First row is header?'; ApplicationArea = All; }
                field(StartRow; StartRow) { Caption = 'Start Row (1-based)'; ApplicationArea = All; }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UploadStage)
            {
                Caption = 'Upload & Stage';
                Image = Import;
                ApplicationArea = All;

                trigger OnAction()
                var
                    InS: InStream;
                    FileName: Text;
                    Loader: Codeunit "GJ Staging Loader";
                    UploadId: Guid;
                    Wizard: Page "GJ Mapping Wizard";
                    StagingHdr: Record "GJ Staging Header";
                begin
                    if not UploadIntoStream('Select Excel file', '', '', FileName, InS) then
                        exit;

                    UploadId := Loader.Stage(ExistingTemplate, NewTemplate, InS, FileName, SheetName, HasHeader, StartRow);
                    Message('Staged. Upload Id: %1', UploadId);
                    // Next UI step: open Mapping Wizard filtered by this UploadId
                    //PAGE.RunModal(PAGE::"GJ Mapping Wizard", UploadId);
                    StagingHdr.Reset();
                    StagingHdr.SetRange("Upload Id", UploadId);
                    Wizard.SetTableView(StagingHdr);
                    Wizard.RunModal();
                end;
            }
        }
    }

    var
        ExistingTemplate: Code[20];
        NewTemplate: Code[20];
        SheetName: Text[50];
        HasHeader: Boolean;
        StartRow: Integer;
        TemplateCode: Code[20];

    trigger OnOpenPage()
    begin
        HasHeader := true;
        StartRow := 1;
    end;

    procedure SetTemplate(Code: Code[20])
    begin
        ExistingTemplate := Code;
    end;
}
