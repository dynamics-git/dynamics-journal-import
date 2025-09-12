codeunit 50500 "GJ Staging Loader"
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

    procedure ReadExcelSheet(TemplateCode: Code[20]; NewTemplate: Code[20];
                    FileName: Text; SheetNameIn: Text;
                   HasHeader: Boolean; StartRow: Integer): Guid
    var
        FileMgt: Codeunit "File Management";
        IStream: InStream;
        FromFile: Text[100];
        UploadId: Guid;
    begin
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
        LastRow: Integer;
        LastCol: Integer;
        RowIdx: Integer;
        ColIdx: Integer;
        StoredSheetName: Text[250];
    begin
        RowNo := 0;
        LineNo := 0;
        LastRow := 0;
        LastCol := 0;
        TempExcelBuffer.Reset();
        if TempExcelBuffer.FindLast() then begin
            LastRow := TempExcelBuffer."Row No.";
            LastCol := TempExcelBuffer."Column No.";
        end;

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

        if StartRow < 1 then
            StartRow := 1;
        if HasHeader and (StartRow = 1) then
            StartRow := 2;

        for RowIdx := StartRow to LastRow do begin
            L.Init();
            L."Upload Id" := UploadId;
            L."Row No." := RowIdx;
            for ColIdx := 1 to 50 do begin
                if ColIdx > LastCol then break;
                SetColByIndex(L, ColIdx, GetValueAtCell(RowIdx, ColIdx));
            end;
            L.Insert(true);
        end;

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
}



