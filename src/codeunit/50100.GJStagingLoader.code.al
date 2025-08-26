// codeunit 50500 "GJ Staging Loader"
// {


//     procedure Stage(TemplateCode: Code[20]; NewTemplate: Code[20]; InS: InStream; FileName: Text; SheetNameIn: Text; HasHeader: Boolean; StartRow: Integer): Guid
//     var
//         H: Record "GJ Staging Header";
//         L: Record "GJ Staging Line";
//         ExcelBuf: Record "Excel Buffer";
//         sheetName: Text[50];
//         lastRow: Integer;
//         lastCol: Integer;
//         row: Integer;
//         col: Integer;
//         uploadId: Guid;
//     begin
//         // Open excel
//         ExcelBuf.DeleteAll();
//         ExcelBuf.OpenBookStream(InS, '');

//         sheetName := SheetNameIn;
//         if sheetName = '' then
//             sheetName := ExcelBuf.SelectSheetsName();
//         if sheetName = '' then
//             Error('No sheet selected.');

//         ExcelBuf.ReadSheet(sheetName, false);

//         lastRow := ExcelBuf.GetLastDataRow();
//         lastCol := ExcelBuf.GetLastDataColumn();

//         // Header
//         uploadId := CreateGuid();
//         H.Init();
//         H."Upload Id" := uploadId;
//         H."Template Code" := TemplateCode;
//         H."New Template Name" := NewTemplate;
//         H."File Name" := FileName;
//         H."Sheet Name" := sheetName;
//         H."First Data Row" := StartRow;
//         H."Last Data Row" := lastRow;
//         H."Last Data Col" := lastCol;
//         H."Has Header Row" := HasHeader;
//         H."Created At" := CurrentDateTime;
//         H."User Id" := UserId;
//         H.Insert();

//         // Lines
//         if StartRow < 1 then StartRow := 1;
//         if HasHeader and (StartRow = 1) then
//             StartRow := 2;

//         for row := StartRow to lastRow do begin
//             L.Init();
//             L."Upload Id" := uploadId;
//             L."Row No." := row;

//             // for col := 1 to Min(lastCol, 20) do
//             //     case col of
//             //         1:
//             //             L."Col1" := ExcelBuf.ReadCellText(row, col);
//             //         2:
//             //             L."Col2" := ExcelBuf.ReadCellText(row, col);
//             //         3:
//             //             L."Col3" := ExcelBuf.ReadCellText(row, col);
//             //         4:
//             //             L."Col4" := ExcelBuf.ReadCellText(row, col);
//             //         5:
//             //             L."Col5" := ExcelBuf.ReadCellText(row, col);
//             //         6:
//             //             L."Col6" := ExcelBuf.ReadCellText(row, col);
//             //         7:
//             //             L."Col7" := ExcelBuf.ReadCellText(row, col);
//             //         8:
//             //             L."Col8" := ExcelBuf.ReadCellText(row, col);
//             //         9:
//             //             L."Col9" := ExcelBuf.ReadCellText(row, col);
//             //         10:
//             //             L."Col10" := ExcelBuf.ReadCellText(row, col);
//             //         11:
//             //             L."Col11" := ExcelBuf.ReadCellText(row, col);
//             //         12:
//             //             L."Col12" := ExcelBuf.ReadCellText(row, col);
//             //         13:
//             //             L."Col13" := ExcelBuf.ReadCellText(row, col);
//             //         14:
//             //             L."Col14" := ExcelBuf.ReadCellText(row, col);
//             //         15:
//             //             L."Col15" := ExcelBuf.ReadCellText(row, col);
//             //         16:
//             //             L."Col16" := ExcelBuf.ReadCellText(row, col);
//             //         17:
//             //             L."Col17" := ExcelBuf.ReadCellText(row, col);
//             //         18:
//             //             L."Col18" := ExcelBuf.ReadCellText(row, col);
//             //         19:
//             //             L."Col19" := ExcelBuf.ReadCellText(row, col);
//             //         20:
//             //             L."Col20" := ExcelBuf.ReadCellText(row, col);
//             //     end;

//             /// L.Insert();
//         end;

//         exit(uploadId);
//     end;
// }
// codeunit 50500 "GJ Staging Loader"
// {
//     procedure Stage(TemplateCode: Code[20]; NewTemplate: Code[20];
//                     InS: InStream; FileName: Text; SheetNameIn: Text;
//                     HasHeader: Boolean; StartRow: Integer): Guid
//     var
//         H: Record "GJ Staging Header";
//         L: Record "GJ Staging Line";
//         ExcelBuf: Record "Excel Buffer" temporary;
//         TempBlob: Codeunit "Temp Blob";
//         OutS: OutStream;
//         InSWorkbook: InStream;
//         UploadId: Guid;
//         LastRow: Integer;
//         LastCol: Integer;
//         RowIdx: Integer;
//         ColIdx: Integer;
//         StoredSheetName: Text[250];
//     begin
//         // 0) Basic guard: must be .xlsx (OpenXML). Avoid .xls / .csv.
//         if not EndsWithCI(FileName, '.xlsx') then
//             Error('Please upload a .xlsx Excel file. File provided: %1', FileName);

//         // 1) Cache the upload so we can reopen the stream (prevents EOF issues)
//         TempBlob.CreateOutStream(OutS);
//         CopyStream(OutS, InS);

//         // 2) Open workbook from a fresh stream for Excel Buffer
//         TempBlob.CreateInStream(InSWorkbook);
//         ExcelBuf.OpenBookStream(InSWorkbook, FileName);

//         // 3) Read the current/first sheet
//         //    (No sheet selection APIs used → reads the first/active worksheet)
//         ExcelBuf.ReadSheet();

//         // 4) Determine last row/col
//         GetMaxRowAndCol(ExcelBuf, LastRow, LastCol);
//         if (LastRow = 0) or (LastCol = 0) then
//             Error('The uploaded workbook appears to be empty or unreadable: %1', FileName);

//         // 5) Store a sheet label (cannot retrieve from table in your build)
//         StoredSheetName := SelectStoredSheetName(SheetNameIn);

//         // 6) Create staging header
//         UploadId := CreateGuid();

//         H.Init();
//         H."Upload Id" := UploadId;
//         H."Template Code" := ChooseTemplate(TemplateCode, NewTemplate);
//         H."New Template Name" := NewTemplate;
//         H."File Name" := FileName;
//         H."Sheet Name" := CopyStr(StoredSheetName, 1, MaxStrLen(H."Sheet Name"));
//         H."First Data Row" := StartRow;
//         H."Last Data Row" := LastRow;
//         H."Last Data Col" := LastCol;
//         H."Has Header Row" := HasHeader;
//         H."Created At" := CurrentDateTime;
//         H."User Id" := UserId;
//         H.Insert(true);

//         // 7) Normalize start row / skip header
//         if StartRow < 1 then
//             StartRow := 1;
//         if HasHeader and (StartRow = 1) then
//             StartRow := 2;

//         // 8) Stage lines (Cols 1..20)
//         for RowIdx := StartRow to LastRow do begin
//             Clear(L);
//             L.Init();
//             L."Upload Id" := UploadId;
//             L."Row No." := RowIdx;

//             for ColIdx := 1 to 20 do begin
//                 if ColIdx > LastCol then break;
//                 SetColByIndex(L, ColIdx, GetCellText(ExcelBuf, RowIdx, ColIdx));
//             end;

//             L.Insert(true);
//         end;

//         exit(UploadId);
//     end;

//     // ---------- Helpers ----------

//     local procedure EndsWithCI(Value: Text; Suffix: Text): Boolean
//     var
//         startPos: Integer;
//         subStr: Text;
//     begin
//         if (Suffix = '') or (StrLen(Value) < StrLen(Suffix)) then
//             exit(false);

//         startPos := StrLen(Value) - StrLen(Suffix) + 1;
//         if startPos < 1 then
//             startPos := 1;

//         subStr := CopyStr(Value, startPos, StrLen(Suffix));
//         exit(UpperCase(subStr) = UpperCase(Suffix));
//     end;


//     local procedure ChooseTemplate(TemplateCode: Code[20]; NewTemplate: Code[20]): Code[20]
//     begin
//         if TemplateCode <> '' then exit(TemplateCode);
//         exit(NewTemplate);
//     end;

//     local procedure SelectStoredSheetName(SheetNameIn: Text): Text
//     begin
//         if SheetNameIn <> '' then exit(SheetNameIn);
//         exit('(first sheet)');
//     end;

//     local procedure GetMaxRowAndCol(var ExcelBuf: Record "Excel Buffer" temporary; var MaxRow: Integer; var MaxCol: Integer)
//     var
//         R: Record "Excel Buffer" temporary;
//     begin
//         MaxRow := 0;
//         MaxCol := 0;
//         R.Copy(ExcelBuf, true);
//         if R.FindSet() then
//             repeat
//                 if R."Row No." > MaxRow then MaxRow := R."Row No.";
//                 if R."Column No." > MaxCol then MaxCol := R."Column No.";
//             until R.Next() = 0;
//     end;

//     local procedure GetCellText(var ExcelBuf: Record "Excel Buffer" temporary; RowNo: Integer; ColNo: Integer): Text
//     begin
//         if (RowNo <= 0) or (ColNo <= 0) then exit('');
//         if ExcelBuf.Get(RowNo, ColNo) then
//             exit(ExcelBuf."Cell Value as Text");
//         exit('');
//     end;

//     local procedure SetColByIndex(var L: Record "GJ Staging Line"; ColIndex: Integer; Val: Text)
//     begin
//         case ColIndex of
//             1:
//                 L."Col1" := Val;
//             2:
//                 L."Col2" := Val;
//             3:
//                 L."Col3" := Val;
//             4:
//                 L."Col4" := Val;
//             5:
//                 L."Col5" := Val;
//             6:
//                 L."Col6" := Val;
//             7:
//                 L."Col7" := Val;
//             8:
//                 L."Col8" := Val;
//             9:
//                 L."Col9" := Val;
//             10:
//                 L."Col10" := Val;
//             11:
//                 L."Col11" := Val;
//             12:
//                 L."Col12" := Val;
//             13:
//                 L."Col13" := Val;
//             14:
//                 L."Col14" := Val;
//             15:
//                 L."Col15" := Val;
//             16:
//                 L."Col16" := Val;
//             17:
//                 L."Col17" := Val;
//             18:
//                 L."Col18" := Val;
//             19:
//                 L."Col19" := Val;
//             20:
//                 L."Col20" := Val;
//         end;
//     end;
// }
codeunit 50500 "GJ Staging Loader"
{
    // =========================
    // PUBLIC ENTRY (matches your page flow)
    // =========================
    // procedure Run()
    // begin


    //     ReadExcelSheet();     // loads TempExcelBuffer, FileName, SheetName, MaxRowNo
    //     //ImportExcelData(BatchName);
    // end;

    // =========================
    // READ EXCEL (your style)
    // =========================
    local procedure ReadExcelSheet()
    var
        IStream: InStream;
        FromFile: Text[250];
        TempBlob: Codeunit "Temp Blob";
        OutS: OutStream;
        InSForBuffer: InStream;
    begin
        // Ask user to pick a file
        UploadIntoStream(UploadExcelMsg, '', '', FromFile, IStream);
        if FromFile = '' then
            Error(NoFileFoundMsg);

        // Keep the file name for audit
        FileName := FromFile;

        // Copy to TempBlob so we can open a FRESH stream for ExcelBuffer
        TempBlob.CreateOutStream(OutS);
        CopyStream(OutS, IStream);

        // Fresh stream for Excel Buffer (prevents "DotNet not instantiated" crash)
        TempBlob.CreateInStream(InSForBuffer);

        // Read the workbook (first/active sheet — SaaS API is parameterless)
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        TempExcelBuffer.OpenBookStream(InSForBuffer, FileName);
        TempExcelBuffer.ReadSheet();

        // Find the last populated row
        MaxRowNo := 0;
        if TempExcelBuffer.FindLast() then
            MaxRowNo := TempExcelBuffer."Row No.";
        if MaxRowNo = 0 then
            Error('The uploaded worksheet appears to be empty.');

        // We can’t get the actual sheet name in your build; store a label
        if SheetName = '' then
            SheetName := '(first sheet)';
    end;

    // =========================
    // IMPORT (your mapping & style)
    // =========================
    local procedure ImportExcelData(BatchName: Code[20])
    var
        SOImportBuffer: Record "SO Import Buffer";
        RowNo: Integer;
        LineNo: Integer;
        D: Date;
        DecVal: Decimal;
        TypeTxt: Text;
    begin
        // Continue line numbering
        SOImportBuffer.Reset();
        if SOImportBuffer.FindLast() then
            LineNo := SOImportBuffer."Line No."
        else
            LineNo := 0;

        // If header is in row 1, start from 2 (matches your screenshot)
        for RowNo := 2 to MaxRowNo do begin
            LineNo := LineNo + 10000;
            SOImportBuffer.Init();
            SOImportBuffer.Validate("Batch Name", BatchName);
            SOImportBuffer.Validate("Line No.", LineNo);

            // --- Column-to-field mapping (exactly like your images) ---
            // Col 1: Document No.
            SOImportBuffer.Validate("Document No.", GetValueAtCell(RowNo, 1));
            // Col 2: Sell-to Customer No.
            SOImportBuffer.Validate("Sell-to Customer No.", GetValueAtCell(RowNo, 2));

            // Col 3: Posting Date (text -> date -> Validate)
            if Evaluate(D, GetValueAtCell(RowNo, 3)) then
                SOImportBuffer.Validate("Posting Date", D)
            else if GetValueAtCell(RowNo, 3) <> '' then
                Error('Invalid Posting Date "%1" at row %2.', GetValueAtCell(RowNo, 3), RowNo);

            // Col 4: Currency Code
            SOImportBuffer.Validate("Currency Code", GetValueAtCell(RowNo, 4));

            // Col 5: Document Date
            if Evaluate(D, GetValueAtCell(RowNo, 5)) then
                SOImportBuffer.Validate("Document Date", D)
            else if GetValueAtCell(RowNo, 5) <> '' then
                Error('Invalid Document Date "%1" at row %2.', GetValueAtCell(RowNo, 5), RowNo);

            // Col 6: External Document No.
            SOImportBuffer.Validate("External Document No.", GetValueAtCell(RowNo, 6));

            // Col 7: Type (if this is an enum/option, you may need mapping—keeping your pattern)
            TypeTxt := GetValueAtCell(RowNo, 7);
            if TypeTxt <> '' then
                SOImportBuffer.Validate(Type, TypeTxt);

            // Col 8: No.
            SOImportBuffer.Validate("No.", GetValueAtCell(RowNo, 8));

            // Col 9: Quantity (text -> decimal)
            if Evaluate(DecVal, GetValueAtCell(RowNo, 9)) then
                SOImportBuffer.Validate(Quantity, DecVal)
            else if GetValueAtCell(RowNo, 9) <> '' then
                Error('Invalid Quantity "%1" at row %2.', GetValueAtCell(RowNo, 9), RowNo);

            // Col 10: Unit Price (text -> decimal)
            if Evaluate(DecVal, GetValueAtCell(RowNo, 10)) then
                SOImportBuffer.Validate("Unit Price", DecVal)
            else if GetValueAtCell(RowNo, 10) <> '' then
                Error('Invalid Unit Price "%1" at row %2.', GetValueAtCell(RowNo, 10), RowNo);

            // Audit fields you set in your example
            SOImportBuffer.Validate("Sheet Name", SheetName);
            SOImportBuffer.Validate("File Name", FileName);
            SOImportBuffer.Validate("Imported Date", Today);
            SOImportBuffer.Validate("Imported Time", Time);

            SOImportBuffer.Insert(true);
        end;

        Message(ExcelImportSuccessLbl, MaxRowNo - 1);
    end;

    // =========================
    // CELL ACCESSOR (your exact pattern)
    // =========================
    local procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin
        TempExcelBuffer.Reset();
        if TempExcelBuffer.Get(RowNo, ColNo) then
            exit(TempExcelBuffer."Cell Value as Text")
        else
            exit('');
    end;

    // =========================
    // STATE (same place you had them on the page)
    // =========================
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        FileName: Text[250];
        SheetName: Text[100];
        MaxRowNo: Integer;

        UploadExcelMsg: Label 'Select Excel file (.xlsx) to import';
        NoFileFoundMsg: Label 'No file selected.';
        ExcelImportSuccessLbl: Label 'Excel import finished. %1 rows processed.';

    // =========================
    // OPTIONAL: keep your original Stage(...) signature if other code calls it
    // =========================
    procedure Stage(TemplateCode: Code[20]; NewTemplate: Code[20];
                    InS: InStream; FileName: Text; SheetNameIn: Text;
                    HasHeader: Boolean; StartRow: Integer): Guid
    var
        H: Record "GJ Staging Header";
        L: Record "GJ Staging Line";
        ExcelBuf: Record "Excel Buffer" temporary;
        TempBlob: Codeunit "Temp Blob";
        OutS: OutStream;
        InSWorkbook: InStream;
        UploadId: Guid;
        LastRow: Integer;
        LastCol: Integer;
        RowIdx: Integer;
        ColIdx: Integer;
        StoredSheetName: Text[250];
    begin
        if not EndsWithCI(FileName, '.xlsx') then
            Error('Please upload a .xlsx Excel file. File provided: %1', FileName);

        TempBlob.CreateOutStream(OutS);
        CopyStream(OutS, InS);

        TempBlob.CreateInStream(InSWorkbook);
        ExcelBuf.OpenBookStream(InSWorkbook, FileName);
        ExcelBuf.ReadSheet();

        GetMaxRowAndCol(ExcelBuf, LastRow, LastCol);
        if (LastRow = 0) or (LastCol = 0) then
            Error('The uploaded workbook appears to be empty or unreadable: %1', FileName);

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
            for ColIdx := 1 to 20 do begin
                if ColIdx > LastCol then break;
                SetColByIndex(L, ColIdx, GetCellText(ExcelBuf, RowIdx, ColIdx));
            end;
            L.Insert(true);
        end;

        exit(UploadId);
    end;

    // ---------- Helpers used by Stage(...) ----------
    local procedure EndsWithCI(Value: Text; Suffix: Text): Boolean
    var
        startPos: Integer;
        subStr: Text;
    begin
        if (Suffix = '') or (StrLen(Value) < StrLen(Suffix)) then
            exit(false);

        startPos := StrLen(Value) - StrLen(Suffix) + 1;
        if startPos < 1 then
            startPos := 1;

        subStr := CopyStr(Value, startPos, StrLen(Suffix));
        exit(UpperCase(subStr) = UpperCase(Suffix));
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

    local procedure GetMaxRowAndCol(var ExcelBuf: Record "Excel Buffer" temporary; var MaxRow: Integer; var MaxCol: Integer)
    var
        R: Record "Excel Buffer" temporary;
    begin
        MaxRow := 0;
        MaxCol := 0;
        R.Copy(ExcelBuf, true);
        if R.FindSet() then
            repeat
                if R."Row No." > MaxRow then MaxRow := R."Row No.";
                if R."Column No." > MaxCol then MaxCol := R."Column No.";
            until R.Next() = 0;
    end;

    local procedure GetCellText(var ExcelBuf: Record "Excel Buffer" temporary; RowNo: Integer; ColNo: Integer): Text
    begin
        if (RowNo <= 0) or (ColNo <= 0) then exit('');
        if ExcelBuf.Get(RowNo, ColNo) then
            exit(ExcelBuf."Cell Value as Text");
        exit('');
    end;

    local procedure SetColByIndex(var L: Record "GJ Staging Line"; ColIndex: Integer; Val: Text)
    begin
        case ColIndex of
            1:
                L."Col1" := Val;
            2:
                L."Col2" := Val;
            3:
                L."Col3" := Val;
            4:
                L."Col4" := Val;
            5:
                L."Col5" := Val;
            6:
                L."Col6" := Val;
            7:
                L."Col7" := Val;
            8:
                L."Col8" := Val;
            9:
                L."Col9" := Val;
            10:
                L."Col10" := Val;
            11:
                L."Col11" := Val;
            12:
                L."Col12" := Val;
            13:
                L."Col13" := Val;
            14:
                L."Col14" := Val;
            15:
                L."Col15" := Val;
            16:
                L."Col16" := Val;
            17:
                L."Col17" := Val;
            18:
                L."Col18" := Val;
            19:
                L."Col19" := Val;
            20:
                L."Col20" := Val;
        end;
    end;
}



