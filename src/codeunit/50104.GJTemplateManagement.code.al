codeunit 50504 "GJ Template Management"
{
    Access = Public;

    procedure EnsureDimMappingExists(TemplateCode: Code[20])
    var
        Dim: Record Dimension;
        Map: Record "GJ Import Dim Map";
    begin
        if TemplateCode = '' then
            exit;

        if Dim.FindSet() then
            repeat
                if not Map.Get(TemplateCode, Dim.Code) then begin
                    Map.Init();
                    Map."Template Code" := TemplateCode;
                    Map."Dimension Code" := Dim.Code;
                    Map."Column Index" := 0;
                    Map."Constant Value" := '';
                    Map.Insert();
                end;
            until Dim.Next() = 0;
    end;

    procedure GetFieldCaptionOrName(var F: Record Field): Text
    begin
        if F."Field Caption" <> '' then
            exit(Format(F."Field Caption"));
        exit(F.FieldName);
    end;

    procedure SaveFieldSelections(TemplateCode: Code[20]; var TempFields: Record "GJ Field Temp" temporary)
    var
        MapRec: Record "GJ Import Column Map";
        NextLineNo: Integer;
        OrderNo: Integer;
    begin
        if TemplateCode = '' then
            Error('Template Code is required.');
        MapRec.Reset();
        MapRec.SetRange("Template Code", TemplateCode);
        MapRec.DeleteAll();

        if TempFields.FindSet(true, true) then begin
            OrderNo := 0;
            NextLineNo := 1000;
            repeat
                if TempFields.Selected then begin
                    OrderNo += 1;
                    MapRec.Init();
                    MapRec."Template Code" := TemplateCode;
                    MapRec."Line No." := NextLineNo;
                    MapRec."Target Field No." := TempFields."Field No.";
                    MapRec."Target Field Caption" := TempFields."Field Caption";
                    MapRec."Column Index" := TempFields."Processing Order";
                    MapRec.Insert();
                    NextLineNo += 1000;
                end;
            until TempFields.Next() = 0;
        end;
    end;

    procedure LoadFieldTempBuffer(TemplateCode: Code[20]; var TempBuf: Record "GJ Field Temp" temporary)
    var
        F: Record Field;
        Map: Record "GJ Import Column Map";
        OrderNo: Integer;
    begin
        TempBuf.Reset();
        TempBuf.DeleteAll();

        // preload existing mapping for this template
        Map.SetRange("Template Code", TemplateCode);

        // STEP 1: Load mapped fields first (keep their stored order)
        if Map.FindSet() then
            repeat
                if F.Get(81, Map."Target Field No.") then begin
                    TempBuf.Init();
                    TempBuf."Field No." := F."No.";
                    TempBuf."Field Name" := F.FieldName;
                    TempBuf."Field Caption" := F."Field Caption";
                    TempBuf.Selected := true;
                    TempBuf."Processing Order" := Map."Column Index"; // keep processing order
                    TempBuf.Insert();
                end;
            until Map.Next() = 0;

        // Find current max order
        OrderNo := 0;
        if TempBuf.FindLast() then
            OrderNo := TempBuf."Processing Order";

        // STEP 2: Load unmapped fields afterwards
        F.Reset();
        F.SetRange(TableNo, 81);
        F.SetRange(Class, F.Class::Normal);

        if F.FindSet() then
            repeat
                if not TempBuf.Get(F."No.") then begin // only insert if not already mapped
                    OrderNo += 1;
                    TempBuf.Init();
                    TempBuf."Field No." := F."No.";
                    TempBuf."Field Name" := F.FieldName;
                    TempBuf."Field Caption" := F."Field Caption";
                    TempBuf.Selected := false;
                    TempBuf."Processing Order" := 0;
                    TempBuf.Insert();
                end;
            until F.Next() = 0;
    end;
}
