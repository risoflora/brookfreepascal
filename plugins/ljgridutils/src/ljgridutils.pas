(*
  LCLJSONGrid Utils plugin.
  Copyright (C) 2012-2014 Silvio Clecio.

  Please see the LICENSE file.
*)

unit LJGridUtils;

{$mode objfpc}{$H+}

interface

uses
  Grids, FPJSON, JSONParser, Classes, SysUtils;

{ Load JSON data to grid. }
procedure LoadJSON(AGrid: TCustomStringGrid; AJSON: TJSONData;
  const AShowErrorMsg: Boolean = False; const AAutoSizeColumns: Boolean = True;
  const AAutoClean: Boolean = True);
{ Load JSON stream to grid. }
procedure LoadJSON(AGrid: TCustomStringGrid; AStream: TStream;
  const AShowErrorMsg: Boolean = False; const AAutoSizeColumns: Boolean = True;
  const AAutoClean: Boolean = True);
{ Load JSON file to grid. }
procedure LoadJSON(AGrid: TCustomStringGrid; const AFileName: TFileName;
  const AShowErrorMsg: Boolean = False; const AAutoSizeColumns: Boolean = True;
  const AAutoClean: Boolean = True);
{ Save grid to JSON array. }
procedure SaveJSON(AGrid: TCustomStringGrid; out AJSON: TJSONArray;
  const ASaveAllAsString: Boolean = False);
{ Save grid to JSON stream. }
procedure SaveJSON(AGrid: TCustomStringGrid; AStream: TStream;
  const ASaveAllAsString: Boolean = False);
{ Save grid to JSON file. }
procedure SaveJSON(AGrid: TCustomStringGrid; const AFileName: TFileName;
  const ASaveAllAsString: Boolean = False);
{ Find item in a StringGrid. }
function FindItem(AGrid: TCustomStringGrid; const AText: string;
  const ACaseSensitive: Boolean = False;
  const AFindNext: Boolean = True): Boolean;
{ Clear grid. }
procedure ClearGrid(AGrid: TCustomStringGrid;
  const AIndicatorWidth: Integer = 12);
{ Get selected row as JSONObject. }
procedure GetSelectedRow(AGrid: TCustomStringGrid; ARow: TJSONObject);
function GetSelectedRow(AGrid: TCustomStringGrid): TJSONObject;
{ Get selected rows as JSONArray. }
procedure GetSelectedRows(AGrid: TCustomStringGrid; ARows: TJSONArray);
function GetSelectedRows(AGrid: TCustomStringGrid): TJSONArray;

var
  JSON_UNKNOWN_STR: ShortString = '[UNKNOWN]';
  JSON_NULL_STR: ShortString = '[NULL]';
  JSON_ARRAY_STR: ShortString = '[ARRAY]';
  JSON_OBJECT_STR: ShortString = '[OBJECT]';
  JSON_BOOL_FALSE_STR: ShortString = 'FALSE';
  JSON_BOOL_TRUE_STR: ShortString = 'TRUE';
  JSON_FORMAT_FLOAT_STR: ShortString = '%f';
  JSON_FORMAT_INT_STR: ShortString = '%d';

implementation

var
  _SelectedRow: TJSONObject = nil;
  _SelectedRows: TJSONArray = nil;

procedure LoadJSON(AGrid: TCustomStringGrid; AJSON: TJSONData;
  const AShowErrorMsg: Boolean; const AAutoSizeColumns: Boolean;
  const AAutoClean: Boolean);
var
  VIsObject: Boolean;
  VJSONCols: TJSONObject;
  VRecord: TJSONData = nil;
  I, J, VFixedCols, VFixedRows: Integer;
begin
  if not Assigned(AJSON) then
  begin
    if AShowErrorMsg then
      raise Exception.Create('JSON ERROR: Empty database.')
    else
      Exit;
  end;
  if AJSON.JSONType <> jtArray then
  begin
    if AShowErrorMsg then
      raise Exception.CreateFmt(
        'JSON ERROR: Got "%s", expected "TJSONArray".', [AJSON.ClassName])
    else
      Exit;
  end;
  if AJSON.Count < 1 then
  begin
    if AAutoClean then
      AGrid.Clean(0, AGrid.FixedRows, AGrid.ColCount - 1, AGrid.RowCount - 1,
        [gzNormal, gzFixedCols, gzFixedRows, gzFixedCells]);
    if AShowErrorMsg then
      raise Exception.Create('JSON ERROR: Empty array.')
    else
      Exit;
  end;
  VJSONCols := TJSONObject(AJSON.Items[0]);
  VIsObject := VJSONCols.JSONType = jtObject;
  if VIsObject and (VJSONCols.Count < 1) then
  begin
    if AShowErrorMsg then
      raise Exception.Create('JSON ERROR: Empty object.')
    else
      Exit;
  end;
  VFixedCols := AGrid.FixedCols;
  VFixedRows := AGrid.FixedRows;
  AGrid.BeginUpdate;
  try
    if not AGrid.Columns.Enabled then
      AGrid.ColCount := VFixedCols + VJSONCols.Count;
    AGrid.RowCount := VFixedRows + AJSON.Count;
    for I := 0 to Pred(AJSON.Count) do
    begin
      VJSONCols := TJSONObject(AJSON.Items[I]);
      for J := 0 to Pred(VJSONCols.Count) do
      begin
        if Pred(AGrid.ColCount - AGrid.FixedCols) < J then
          Continue;
        if (I = 0) and VIsObject then
          AGrid.Cols[VFixedCols + J].Text := VJSONCols.Names[J];
        VRecord := VJSONCols.Items[J];
        case VRecord.JSONType of
          jtUnknown: AGrid.Cells[J + VFixedCols, I + VFixedRows] := JSON_UNKNOWN_STR;
          jtNumber:
            begin
              if VRecord is TJSONFloatNumber then
                AGrid.Cells[J + VFixedCols, I + VFixedRows] :=
                  Format(JSON_FORMAT_FLOAT_STR, [VRecord.AsFloat])
              else
                AGrid.Cells[J + VFixedCols, I + VFixedRows] :=
                  Format(JSON_FORMAT_INT_STR, [VRecord.AsInt64]);
            end;
          jtString: AGrid.Cells[J + VFixedCols, I + VFixedRows] :=
            VRecord.AsString;
          jtBoolean: AGrid.Cells[J + VFixedCols, I + VFixedRows] :=
            BoolToStr(VRecord.AsBoolean, JSON_BOOL_TRUE_STR, JSON_BOOL_FALSE_STR);
          jtNull: AGrid.Cells[J + VFixedCols, I + VFixedRows] := JSON_NULL_STR;
          jtArray: AGrid.Cells[J + VFixedCols, I + VFixedRows] := JSON_ARRAY_STR;
          jtObject: AGrid.Cells[J + VFixedCols, I + VFixedRows] := JSON_OBJECT_STR;
        end;
      end;
    end;
    if AAutoSizeColumns then
      for I := 1 to Pred(AGrid.ColCount) do
        AGrid.AutoSizeColumn(I);
  finally
    AGrid.EndUpdate;
  end;
end;

procedure LoadJSON(AGrid: TCustomStringGrid; AStream: TStream;
  const AShowErrorMsg: Boolean; const AAutoSizeColumns: Boolean;
  const AAutoClean: Boolean);
var
  VJSON: TJSONData;
  VParser: TJSONParser;
begin
  VParser := TJSONParser.Create(AStream);
  try
    VJSON := VParser.Parse;
    LoadJSON(AGrid, VJSON, AShowErrorMsg, AAutoSizeColumns, AAutoClean);
  finally
    VJSON.Free;
    VParser.Free;
  end;
end;

procedure LoadJSON(AGrid: TCustomStringGrid; const AFileName: TFileName;
  const AShowErrorMsg: Boolean; const AAutoSizeColumns: Boolean;
  const AAutoClean: Boolean);
var
  VFile: TFileStream;
begin
  VFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadJSON(AGrid, VFile, AShowErrorMsg, AAutoSizeColumns, AAutoClean);
  finally
    VFile.Free;
  end;
end;

procedure SaveJSON(AGrid: TCustomStringGrid; out AJSON: TJSONArray;
  const ASaveAllAsString: Boolean);
var
  VIsObject: Boolean;
  VInt64Value: Int64;
  VFloatValue: TJSONFloat;
  I, J, VRowCount: Integer;
  VJSONArrayData: TJSONArray;
  VObjectName, VCellValue: string;
  VJSONObjectData: TJSONObject = nil;
begin
  VRowCount := AGrid.RowCount;
  VIsObject := (VRowCount > 0) and (Trim(AGrid.Rows[0].Text) <> '');
  AJSON := TJSONArray.Create;
  for J := AGrid.FixedRows to Pred(AGrid.RowCount) do
  begin
    if VIsObject then
      VJSONObjectData := TJSONObject.Create
    else
      VJSONArrayData := TJSONArray.Create;
    for I := AGrid.FixedCols to Pred(AGrid.ColCount) do
    begin
      VObjectName := AGrid.Cells[I, 0];
      VCellValue := AGrid.Cells[I, J];
      if ASaveAllAsString then
      begin
        if VIsObject then
          VJSONObjectData.Add(VObjectName, VCellValue)
        else
          VJSONArrayData.Add(VCellValue);
      end
      else
      begin
        if SameText(VCellValue, JSON_UNKNOWN_STR) or
          SameText(VCellValue, JSON_NULL_STR) then
        begin
          if VIsObject then
            VJSONObjectData.Add(VObjectName, TJSONNull.Create)
          else
            VJSONArrayData.Add(TJSONNull.Create);
        end
        else
        if SameText(VCellValue, JSON_ARRAY_STR) then
        begin
          if VIsObject then
            VJSONObjectData.Add(VObjectName, TJSONArray.Create)
          else
            VJSONArrayData.Add(TJSONArray.Create);
        end
        else
        if SameText(VCellValue, JSON_OBJECT_STR) then
        begin
          if VIsObject then
            VJSONObjectData.Add(VObjectName, TJSONObject.Create)
          else
            VJSONArrayData.Add(TJSONObject.Create);
        end
        else
        if SameText(VCellValue, JSON_BOOL_FALSE_STR) then
        begin
          if VIsObject then
            VJSONObjectData.Add(VObjectName, False)
          else
            VJSONArrayData.Add(False);
        end
        else
        if SameText(VCellValue, JSON_BOOL_TRUE_STR) then
        begin
          if VIsObject then
            VJSONObjectData.Add(VObjectName, True)
          else
            VJSONArrayData.Add(True);
        end
        else
        if TryStrToInt64(VCellValue, VInt64Value) then
        begin
          if VIsObject then
            VJSONObjectData.Add(VObjectName, VInt64Value)
          else
            VJSONArrayData.Add(VInt64Value);
        end
        else
        if TryStrToFloat(VCellValue, VFloatValue) then
        begin
          if VIsObject then
            VJSONObjectData.Add(VObjectName, VFloatValue)
          else
            VJSONArrayData.Add(VFloatValue);
        end
        else
        begin
          if VIsObject then
            VJSONObjectData.Add(VObjectName, VCellValue)
          else
            VJSONArrayData.Add(VCellValue);
        end;
      end;
    end;
    if VIsObject then
      AJSON.Add(VJSONObjectData)
    else
      AJSON.Add(VJSONArrayData);
  end;
end;

procedure SaveJSON(AGrid: TCustomStringGrid; AStream: TStream;
  const ASaveAllAsString: Boolean);
var
  L: Integer;
  VJSON: string;
  VJSONArray: TJSONArray;
begin
  SaveJSON(AGrid, VJSONArray, ASaveAllAsString);
  try
    VJSON := VJSONArray.AsJSON;
    L := Length(VJSON);
    if L > 0 then
      AStream.Write(Pointer(VJSON)^, L);
  finally
    VJSONArray.Free;
  end;
end;

procedure SaveJSON(AGrid: TCustomStringGrid; const AFileName: TFileName;
  const ASaveAllAsString: Boolean);
var
  VFile: TFileStream;
begin
  VFile := TFileStream.Create(AFileName, fmCreate);
  try
    SaveJSON(AGrid, VFile, ASaveAllAsString);
  finally
    VFile.Free;
  end;
end;

function FindItem(AGrid: TCustomStringGrid; const AText: string;
  const ACaseSensitive: Boolean; const AFindNext: Boolean): Boolean;
var
  VGridRect: TGridRect;
  VTargetText, VCellText: string;
  I, X, Y, VCurX, VCurY, VGridWidth, VGridHeight: Integer;
begin
  Result := False;
  if AFindNext then
  begin
    VCurY := AGrid.Selection.Top;
    VCurX := AGrid.Selection.Left + 1;
  end
  else
  begin
    VCurY := 0;
    VCurX := 0;
    VGridRect.Left := 0;
    VGridRect.Right := 0;
    VGridRect.Top := 0;
    VGridRect.Bottom := 0;
    AGrid.Selection := VGridRect;
  end;
  VGridWidth := AGrid.ColCount;
  VGridHeight := AGrid.RowCount;
  Y := VCurY;
  X := VCurX;
  if ACaseSensitive then
    VTargetText := AText
  else
    VTargetText := AnsiLowerCase(AText);
  while Y < VGridHeight do
  begin
    while X < VGridWidth do
    begin
      if ACaseSensitive then
        VCellText := AGrid.Cells[X, Y]
      else
        VCellText := AnsiLowerCase(AGrid.Cells[X, Y]);
      I := Pos(VTargetText, VCellText);
      if I > 0 then
      begin
        VGridRect.Left := X;
        VGridRect.Right := X;
        VGridRect.Top := Y;
        VGridRect.Bottom := Y;
        AGrid.Selection := VGridRect;
        Result := True;
        Exit;
      end;
      Inc(X);
    end;
    Inc(Y);
    X := AGrid.FixedCols;
  end;
  if AFindNext {and not Result} then
  begin
    VGridRect.Left := 0;
    VGridRect.Right := 0;
    VGridRect.Top := 0;
    VGridRect.Bottom := 0;
    AGrid.Selection := VGridRect;
  end;
end;

procedure ClearGrid(AGrid: TCustomStringGrid; const AIndicatorWidth: Integer);
var
  I: Integer;
begin
  with AGrid do
  try
    BeginUpdate;
    if not Columns.Enabled then
    begin
      ColCount := 1 + FixedCols;
      ColWidths[0] := AIndicatorWidth;
      for I := 1 to Pred(ColCount) do
        ColWidths[I] := DefaultColWidth;
    end;
    RowCount := 1 + FixedRows;
    Clean;
  finally
    EndUpdate;
  end;
end;

procedure GetSelectedRow(AGrid: TCustomStringGrid; ARow: TJSONObject);
var
  I: Integer;
begin
  ARow.Clear;
  for I := AGrid.FixedCols to Pred(AGrid.ColCount) do
    ARow.Add(AGrid.Cols[I][0], AGrid.Rows[AGrid.Row][I]);
  if (ARow.Count > 0) and (ARow.Names[0] = '') and
    (ARow.Items[0].AsString = '') then
    ARow.Clear;
end;

function GetSelectedRow(AGrid: TCustomStringGrid): TJSONObject;
begin
  if not Assigned(_SelectedRow) then
    _SelectedRow := TJSONObject.Create;
  Result := _SelectedRow;
  GetSelectedRow(AGrid, Result);
end;

procedure GetSelectedRows(AGrid: TCustomStringGrid; ARows: TJSONArray);
var
  I, J: Integer;
  VItem: TJSONObject;
begin
  ARows.Clear;
  for I := AGrid.Selection.Top to AGrid.Selection.Bottom do
  begin
    VItem := TJSONObject.Create;
    for J := AGrid.FixedCols to Pred(AGrid.ColCount) do
      VItem.Add(AGrid.Cols[J][0], AGrid.Rows[I][J]);
    ARows.Add(VItem);
  end;
  if Assigned(VItem) and (VItem.Count > 0) and
    (VItem.Names[0] = '') and (VItem.Items[0].AsString = '') then
    ARows.Clear;
end;

function GetSelectedRows(AGrid: TCustomStringGrid): TJSONArray;
begin
  if not Assigned(_SelectedRows) then
    _SelectedRows := TJSONArray.Create;
  Result := _SelectedRows;
  GetSelectedRows(AGrid, Result);
end;

finalization
  FreeAndNil(_SelectedRow);
  FreeAndNil(_SelectedRows);

end.

