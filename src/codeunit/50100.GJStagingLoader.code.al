codeunit 50500 "GJ Staging Loader"
{


    procedure Stage(TemplateCode: Code[20]; NewTemplate: Code[20]; InS: InStream; FileName: Text; SheetNameIn: Text; HasHeader: Boolean; StartRow: Integer): Guid
    var
        H: Record "GJ Staging Header";
        L: Record "GJ Staging Line";
        ExcelBuf: Record "Excel Buffer";
        sheetName: Text[50];
        lastRow: Integer;
        lastCol: Integer;
        row: Integer;
        col: Integer;
        uploadId: Guid;
    begin
        // Open excel
        ExcelBuf.DeleteAll();
        ExcelBuf.OpenBookStream(InS, '');

        sheetName := SheetNameIn;
        if sheetName = '' then
            sheetName := ExcelBuf.SelectSheetsName();
        if sheetName = '' then
            Error('No sheet selected.');

        ExcelBuf.ReadSheet(sheetName, false);

        lastRow := ExcelBuf.GetLastDataRow();
        lastCol := ExcelBuf.GetLastDataColumn();

        // Header
        uploadId := CreateGuid();
        H.Init();
        H."Upload Id" := uploadId;
        H."Template Code" := TemplateCode;
        H."New Template Name" := NewTemplate;
        H."File Name" := FileName;
        H."Sheet Name" := sheetName;
        H."First Data Row" := StartRow;
        H."Last Data Row" := lastRow;
        H."Last Data Col" := lastCol;
        H."Has Header Row" := HasHeader;
        H."Created At" := CurrentDateTime;
        H."User Id" := UserId;
        H.Insert();

        // Lines
        if StartRow < 1 then StartRow := 1;
        if HasHeader and (StartRow = 1) then
            StartRow := 2;

        for row := StartRow to lastRow do begin
            L.Init();
            L."Upload Id" := uploadId;
            L."Row No." := row;

            // for col := 1 to Min(lastCol, 20) do
            //     case col of
            //         1:
            //             L."Col1" := ExcelBuf.ReadCellText(row, col);
            //         2:
            //             L."Col2" := ExcelBuf.ReadCellText(row, col);
            //         3:
            //             L."Col3" := ExcelBuf.ReadCellText(row, col);
            //         4:
            //             L."Col4" := ExcelBuf.ReadCellText(row, col);
            //         5:
            //             L."Col5" := ExcelBuf.ReadCellText(row, col);
            //         6:
            //             L."Col6" := ExcelBuf.ReadCellText(row, col);
            //         7:
            //             L."Col7" := ExcelBuf.ReadCellText(row, col);
            //         8:
            //             L."Col8" := ExcelBuf.ReadCellText(row, col);
            //         9:
            //             L."Col9" := ExcelBuf.ReadCellText(row, col);
            //         10:
            //             L."Col10" := ExcelBuf.ReadCellText(row, col);
            //         11:
            //             L."Col11" := ExcelBuf.ReadCellText(row, col);
            //         12:
            //             L."Col12" := ExcelBuf.ReadCellText(row, col);
            //         13:
            //             L."Col13" := ExcelBuf.ReadCellText(row, col);
            //         14:
            //             L."Col14" := ExcelBuf.ReadCellText(row, col);
            //         15:
            //             L."Col15" := ExcelBuf.ReadCellText(row, col);
            //         16:
            //             L."Col16" := ExcelBuf.ReadCellText(row, col);
            //         17:
            //             L."Col17" := ExcelBuf.ReadCellText(row, col);
            //         18:
            //             L."Col18" := ExcelBuf.ReadCellText(row, col);
            //         19:
            //             L."Col19" := ExcelBuf.ReadCellText(row, col);
            //         20:
            //             L."Col20" := ExcelBuf.ReadCellText(row, col);
            //     end;

            /// L.Insert();
        end;

        exit(uploadId);
    end;
}
