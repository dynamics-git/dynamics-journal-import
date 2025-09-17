codeunit 50505 "GJ Integration Event"
{
    [IntegrationEvent(false, false)]
    procedure OnBeforeReadExcelSheet(TemplateCode: Code[20]; NewTemplate: Code[20];
                                               FileName: Text; SheetNameIn: Text;
                                               HasHeader: Boolean; StartRow: Integer;
                                               var IsHandled: Boolean; var UploadId: Guid)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterReadExcelSheet(TemplateCode: Code[20]; NewTemplate: Code[20];
                                          FileName: Text; SheetNameIn: Text;
                                          HasHeader: Boolean; StartRow: Integer;
                                          UploadId: Guid)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeImportExcelData(TemplateCode: Code[20]; NewTemplate: Code[20];
                                            FileName: Text; SheetNameIn: Text;
                                            HasHeader: Boolean; StartRow: Integer;
                                            var UploadId: Guid; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterImportExcelData(TemplateCode: Code[20]; NewTemplate: Code[20];
                                           FileName: Text; SheetNameIn: Text;
                                           HasHeader: Boolean; StartRow: Integer;
                                           UploadId: Guid)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterInsertStagingHeader(var StagingHeader: Record "GJ Staging Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeStagingLineBuild(var StagingLine: Record "GJ Staging Line"; RowNo: Integer; LastCol: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeInsertStagingLine(var StagingLine: Record "GJ Staging Line"; RowNo: Integer; LastCol: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterInsertStagingLine(var StagingLine: Record "GJ Staging Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeStoreExcelHeaders(UploadId: Guid; TemplateCode: Code[20]; HeaderRowNo: Integer; LastCol: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeInsertExcelHeader(UploadId: Guid; TemplateCode: Code[20]; ColumnIndex: Integer; var HeaderText: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeExcelHeaderInsert(var HeaderMap: Record "GJ Excel Header Map")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterExcelHeaderInsert(var HeaderMap: Record "GJ Excel Header Map")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterStoreExcelHeaders(UploadId: Guid; TemplateCode: Code[20]; HeaderRowNo: Integer; LastCol: Integer)
    begin
    end;


    [IntegrationEvent(false, false)]
    procedure OnBeforeRunFromStaging(UploadId: Guid; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterRunFromStaging(UploadId: Guid; Tmpl: Record "GJ Import Template")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeProcessStagingLines(StagingHdr: Record "GJ Staging Header"; Tmpl: Record "GJ Import Template")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterProcessStagingLines(StagingHdr: Record "GJ Staging Header"; Tmpl: Record "GJ Import Template")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeInsertGJGenJournalLine(var GenLine: Record "Gen. Journal Line"; StagingLine: Record "GJ Staging Line"; Tmpl: Record "GJ Import Template")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterInsertGJGenJournalLine(var GenLine: Record "Gen. Journal Line"; StagingLine: Record "GJ Staging Line"; Tmpl: Record "GJ Import Template")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeBuildJournalLine(var GenLine: Record "Gen. Journal Line"; StagingLine: Record "GJ Staging Line"; Tmpl: Record "GJ Import Template")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterBuildJournalLine(var GenLine: Record "Gen. Journal Line"; StagingLine: Record "GJ Staging Line"; Tmpl: Record "GJ Import Template")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeMapColumnToJournal(var GenLine: Record "Gen. Journal Line"; StagingLine: Record "GJ Staging Line"; ColMap: Record "GJ Import Column Map"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterMapColumnToJournal(var GenLine: Record "Gen. Journal Line"; StagingLine: Record "GJ Staging Line"; ColMap: Record "GJ Import Column Map")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeApplyDimensionEntry(var DimMap: Record "GJ Import Dim Map"; StagingLine: Record "GJ Staging Line"; var GenLine: Record "Gen. Journal Line"; var IsHandled: Boolean; var TempDimSetEntry: Record "Dimension Set Entry" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterApplyDimensionEntry(var DimMap: Record "GJ Import Dim Map"; StagingLine: Record "GJ Staging Line"; var GenLine: Record "Gen. Journal Line"; var TempDimSetEntry: Record "Dimension Set Entry" temporary)
    begin
    end;
}