codeunit 50200 "GJ Staging Loader"
{
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        FileName: Text[250];
        SheetName: Text[100];
        MaxRowNo: Integer;
        UploadExcelMsg: Label 'Select Excel file (.xlsx) to import';
        NoFileFoundMsg: Label 'No file selected.';
        ExcelImportSuccessLbl: Label 'Excel import finished. %1 rows processed.';
        ImportUtils: Codeunit "GJ Import Utils";
        IntegrationEvent: Codeunit "GJ Integration Event";

    procedure ReadExcelSheet(TemplateCode: Code[20]; NewTemplate: Code[20];
                    FileName: Text; SheetNameIn: Text;
                   HasHeader: Boolean; StartRow: Integer): Guid
    var
        FileMgt: Codeunit "File Management";
        IStream: InStream;
        FromFile: Text[100];
        UploadId: Guid;
        IsHandled: Boolean;
    begin
        IntegrationEvent.OnBeforeReadExcelSheet(TemplateCode, NewTemplate, FileName, SheetNameIn, HasHeader, StartRow, IsHandled, UploadId);
        if IsHandled then
            exit(UploadId);
        UploadIntoStream(UploadExcelMsg, '', '', FromFile, IStream);
        if FromFile <> '' then begin
            FileName := FileMgt.GetFileName(FromFile);
            SheetName := TempExcelBuffer.SelectSheetsNameStream(IStream);
        end else
            Error(NoFileFoundMsg);
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.OpenBookStream(IStream, SheetName);
        TempExcelBuffer.ReadSheet();
        UploadId := ImportExcelData(TemplateCode, NewTemplate, FileName, SheetNameIn, HasHeader, StartRow);
        IntegrationEvent.OnAfterReadExcelSheet(TemplateCode, NewTemplate, FileName, SheetNameIn, HasHeader, StartRow, UploadId);
        exit(UploadId);
    end;

    local procedure ImportExcelData(TemplateCode: Code[20]; NewTemplate: Code[20];
                     FileName: Text; SheetNameIn: Text;
                    HasHeader: Boolean; StartRow: Integer): Guid
    var
        RowNo: Integer;
        ColNo: Integer;
        LineNo: Integer;
        MaxRowNo: Integer;
        H: Record "GJ Staging Header";
        L: Record "GJ Staging Line";
        UploadId: Guid;
        RowIdx: Integer;
        ColIdx: Integer;
        StoredSheetName: Text[250];
        IsHandled: Boolean;
        LastRow: Integer;
        LastCol: Integer;
    begin
        IntegrationEvent.OnBeforeImportExcelData(TemplateCode, NewTemplate, FileName, SheetNameIn, HasHeader, StartRow, UploadId, IsHandled);
        if IsHandled then
            exit(UploadId);
        RowNo := 0;
        LineNo := 0;

        TempExcelBuffer.Reset();
        CalcMaxRowAndCol(LastRow, LastCol);

        StoredSheetName := SelectStoredSheetName(SheetNameIn);
        UploadId := CreateGuid();
        H.Init();
        H."Upload Id" := UploadId;
        H."Template Code" := ChooseTemplate(TemplateCode, NewTemplate);
        H."New Template Name" := NewTemplate;
        H."File Name" := FileName;
        H."Sheet Name" := CopyStr(StoredSheetName, 1, MaxStrLen(H."Sheet Name"));
        H."First Data Row" := StartRow;
        H."Last Data Row" := LastRow;
        H."Last Data Col" := LastCol;
        H."Has Header Row" := HasHeader;
        H."Created At" := CurrentDateTime;
        H."User Id" := UserId;
        H.Insert(true);
        IntegrationEvent.OnAfterInsertStagingHeader(H);
        if HasHeader then
            StoreExcelHeaders(UploadId, TemplateCode, 1, LastCol);
        if StartRow < 1 then
            StartRow := 1;
        if HasHeader and (StartRow = 1) then
            StartRow := 2;

        for RowIdx := StartRow to LastRow do begin
            L.Init();
            L."Upload Id" := UploadId;
            L."Row No." := RowIdx;
            IntegrationEvent.OnBeforeStagingLineBuild(L, RowIdx, LastCol);
            for ColIdx := 1 to 50 do begin
                if ColIdx > LastCol then break;
                SetColByIndex(L, ColIdx, GetValueAtCell(RowIdx, ColIdx));
            end;
            IntegrationEvent.OnBeforeInsertStagingLine(L, RowIdx, LastCol, IsHandled);
            if not IsHandled then
                L.Insert(true);
            IntegrationEvent.OnAfterInsertStagingLine(L);
        end;
        IntegrationEvent.OnAfterImportExcelData(TemplateCode, NewTemplate, FileName, SheetNameIn, HasHeader, StartRow, UploadId);
        exit(UploadId);
    end;

    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin

        TempExcelBuffer.Reset();
        If TempExcelBuffer.Get(RowNo, ColNo) then
            exit(TempExcelBuffer."Cell Value as Text")
        else
            exit('');
    end;

    local procedure ChooseTemplate(TemplateCode: Code[20]; NewTemplate: Code[20]): Code[20]
    begin
        if TemplateCode <> '' then
            exit(TemplateCode);
        exit(NewTemplate);
    end;

    local procedure SelectStoredSheetName(SheetNameIn: Text): Text
    begin
        if SheetNameIn <> '' then
            exit(SheetNameIn);
        exit('(first sheet)');
    end;

    local procedure SetColByIndex(var L: Record "GJ Staging Line"; ColIndex: Integer; Val: Text)
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        BaseFieldId: Integer;
    begin
        if (ColIndex < 1) or (ColIndex > 50) then
            Error('Column index %1 is out of supported range (1..50).', ColIndex);
        RecRef.GetTable(L);
        BaseFieldId := ImportUtils.GetGJStagingLineColOneFieldRef();
        FldRef := RecRef.Field((BaseFieldId + (ColIndex - 1)));
        FldRef.Value := Val;
        RecRef.SetTable(L);
    end;

    local procedure CalcMaxRowAndCol(var OutLastRow: Integer; var OutLastCol: Integer)
    var
        R: Record "Excel Buffer" temporary;
    begin
        OutLastRow := 0;
        OutLastCol := 0;

        R.Copy(TempExcelBuffer, true);
        if R.FindSet() then
            repeat
                if R."Row No." > OutLastRow then
                    OutLastRow := R."Row No.";
                if R."Column No." > OutLastCol then
                    OutLastCol := R."Column No.";
            until R.Next() = 0;
    end;

    local procedure StoreExcelHeaders(UploadId: Guid; TemplateCode: Code[20]; HeaderRowNo: Integer; LastCol: Integer)
    var
        HeaderMap: Record "GJ Excel Header Map";
        Col: Integer;
        HeaderText: Text;
        IsHandled: Boolean;
    begin
        IntegrationEvent.OnBeforeStoreExcelHeaders(UploadId, TemplateCode, HeaderRowNo, LastCol, IsHandled);
        if IsHandled then
            exit;

        // Clear existing headers for this upload
        HeaderMap.Reset();
        HeaderMap.SetRange("Template Code", TemplateCode);
        HeaderMap.DeleteAll();

        // Loop through each column and capture header text
        for Col := 1 to LastCol do begin
            HeaderText := GetValueAtCell(HeaderRowNo, Col);
            IntegrationEvent.OnBeforeInsertExcelHeader(UploadId, TemplateCode, Col, HeaderText);
            if HeaderText <> '' then begin
                HeaderMap.Init();
                HeaderMap."Upload Id" := UploadId;
                HeaderMap."Template Code" := TemplateCode;
                HeaderMap."Column Index" := Col;
                HeaderMap."Header Text" := CopyStr(HeaderText, 1, MaxStrLen(HeaderMap."Header Text"));
                IntegrationEvent.OnBeforeExcelHeaderInsert(HeaderMap);
                HeaderMap.Insert();
                IntegrationEvent.OnAfterExcelHeaderInsert(HeaderMap);
            end;
        end;
        IntegrationEvent.OnAfterStoreExcelHeaders(UploadId, TemplateCode, HeaderRowNo, LastCol);
    end;

}



