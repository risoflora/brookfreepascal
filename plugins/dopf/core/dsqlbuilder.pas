(*
  Duall Sistemas, SQL Builder Classes

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit dSqlBuilder;

{$i dopf.inc}

interface

uses
  dClasses, dUtils, Classes, SysUtils, TypInfo;

type
  EdTable = class(EdException);

  EdSqlBuilder = class(EdException);

  { TdGTable }

  generic TdGTable<T> = class(TdObject)
  private
    FPrimaryKeys: TStrings;
    FPropCount: Integer;
    FPropList: PPropList;
    FName: string;
    FIgnoredFields: TStrings;
    procedure SetName(const AValue: string);
  public
    constructor Create; virtual;
    destructor Destroy; override;
    property PropCount: Integer read FPropCount;
    property PropList: PPropList read FPropList;
  published
    property Name: string read FName write SetName;
    property PrimaryKeys: TStrings read FPrimaryKeys;
    property IgnoredFields: TStrings read FIgnoredFields;
  end;

  { TdSqlBuilder }

  TdSqlBuilder = class(TdComponent)
  public
    procedure Build(out ASql: string;
      const ACondition: Boolean = True); virtual; abstract;
  end;

  { TdGSqlBuilder }

  generic TdGSqlBuilder<T> = class(TdSqlBuilder)
  private
    FTable: T;
  protected
    procedure CheckTableName; virtual;
  public
    procedure SetTable(ATable: T);
  end;

  { TdGSelectBuilder }

  generic TdGSelectBuilder<T> = class(specialize TdGSqlBuilder<T>)
  public
    class function MakeFields(ATable: T; out AFields: string;
      const AIgnoreWildcard: Boolean): Boolean; virtual;
    procedure Build(out ASql: string;
      const AIgnoreWildcard: Boolean = True); override;
  end;

  { TdGInsertBuilder }

  generic TdGInsertBuilder<T> = class(specialize TdGSqlBuilder<T>)
  public
    class function MakeFields(ATable: T; out AFields, AParams: string;
      const AIgnorePrimaryKeys: Boolean): Boolean; virtual;
    procedure Build(out ASql: string;
      const AIgnorePrimaryKeys: Boolean = True); override;
  end;

  { TdGUpdateBuilder }

  generic TdGUpdateBuilder<T> = class(specialize TdGSqlBuilder<T>)
  public
    class function MakeFields(ATable: T; out AFields, AParams: string;
      const AIgnorePrimaryKeys: Boolean): Boolean; virtual;
    procedure Build(out ASql: string;
      const AIgnorePrimaryKeys: Boolean = True); override;
  end;

  { TdGDeleteBuilder }

  generic TdGDeleteBuilder<T> = class(specialize TdGSqlBuilder<T>)
  public
    class function MakeParams(ATable: T; out AParams: string;
      const AIgnoreProperties: Boolean): Boolean; virtual;
    procedure Build(out ASql: string;
      const AIgnoreProperties: Boolean = True); override;
  end;

var
  dDefaultPrimaryKeyName: ShortString = 'id';

implementation

{ TdGTable }

constructor TdGTable.Create;
begin
  inherited Create;
  FPropCount := GetPropList(PTypeInfo(T.ClassInfo), FPropList);
  FPrimaryKeys := TStringList.Create;
  FPrimaryKeys.Add(dDefaultPrimaryKeyName);
  FIgnoredFields := TStringList.Create;
end;

destructor TdGTable.Destroy;
begin
  if Assigned(FPropList) then
    FreeMem(FPropList);
  FPrimaryKeys.Free;
  FIgnoredFields.Free;
  inherited Destroy;
end;

procedure TdGTable.SetName(const AValue: string);
begin
  if Trim(AValue) = '' then
    Exit;
  if AValue <> FName then
  begin
    FName := LowerCase(AValue);
  end;
end;

{ TdGSqlBuilder }

procedure TdGSqlBuilder.CheckTableName;
begin
  if Trim(FTable.Name) = '' then
    raise EdSqlBuilder.Create('Table name must not be empty.');
end;

procedure TdGSqlBuilder.SetTable(ATable: T);
begin
  FTable := ATable;
end;

{ TdGSelectBuilder }

class function TdGSelectBuilder.MakeFields(ATable: T; out AFields: string;
  const AIgnoreWildcard: Boolean): Boolean;
var
  N: string;
  I: Integer;
begin
  Result := (ATable <> nil) and Assigned(ATable.PropList);
  if not Result then
    Exit;
  if not AIgnoreWildcard then
  begin
    AFields := '*';
    Exit;
  end;
  for I := 0 to Pred(ATable.PropCount) do
  begin
    N := ATable.PropList^[I]^.Name;
    if ATable.IgnoredFields.IndexOf(N) > -1 then
      Continue;
    N += ', ';
    AFields += N;
  end;
  SetLength(AFields, Length(AFields) - 2);
  AFields := LowerCase(AFields);
end;

procedure TdGSelectBuilder.Build(out ASql: string;
  const AIgnoreWildcard: Boolean);
var
  FS: string;
begin
  if MakeFields(FTable, FS, AIgnoreWildcard) then
  begin
    CheckTableName;
    ASql := 'select ' + FS + ' from ' + FTable.Name;
  end;
end;

{ TdGInsertBuilder }

class function TdGInsertBuilder.MakeFields(ATable: T; out AFields,
  AParams: string; const AIgnorePrimaryKeys: Boolean): Boolean;
var
  N: string;
  I: Integer;
begin
  AFields := '';
  AParams := '';
  Result := (ATable <> nil) and Assigned(ATable.PropList);
  if not Result then
    Exit;
  for I := 0 to Pred(ATable.PropCount) do
  begin
    N := ATable.PropList^[I]^.Name;
    if (ATable.IgnoredFields.IndexOf(N) > -1) or
      (AIgnorePrimaryKeys and (ATable.PrimaryKeys.IndexOf(N) > -1)) then
      Continue;
    N += ', ';
    AFields += N;
    AParams += ':' + N;
  end;
  SetLength(AFields, Length(AFields) - 2);
  SetLength(AParams, Length(AParams) - 2);
  AFields := LowerCase(AFields);
  AParams := LowerCase(AParams);
end;

procedure TdGInsertBuilder.Build(out ASql: string;
  const AIgnorePrimaryKeys: Boolean);
var
  FS, PS: string;
begin
  if MakeFields(FTable, FS, PS, AIgnorePrimaryKeys) then
  begin
    CheckTableName;
    ASql := 'insert into ' + FTable.Name + ' (' + FS + ') ' +
      'values (' + PS + ')';
  end;
end;

{ TdGUpdateBuilder }

class function TdGUpdateBuilder.MakeFields(ATable: T; out AFields,
  AParams: string; const AIgnorePrimaryKeys: Boolean): Boolean;
var
  N, P: string;
  I, X: Integer;
begin
  AFields := '';
  AParams := '';
  Result := (ATable <> nil) and Assigned(ATable.PropList);
  if not Result then
    Exit;
  for I := 0 to Pred(ATable.PropCount) do
  begin
    N := ATable.PropList^[I]^.Name;
    X := ATable.PrimaryKeys.IndexOf(N);
    if X > -1 then
    begin
      P := ATable.PrimaryKeys[X];
      AParams += P + ' = :' + P + ' and ';
      if AIgnorePrimaryKeys then
        Continue;
    end;
    if ATable.IgnoredFields.IndexOf(N) > -1 then
      Continue;
    AFields += N + ' = :' + N + ', ';
  end;
  SetLength(AFields, Length(AFields) - 2);
  AFields := LowerCase(AFields);
  SetLength(AParams, Length(AParams) - 5);
  AParams := LowerCase(AParams);
end;

procedure TdGUpdateBuilder.Build(out ASql: string;
  const AIgnorePrimaryKeys: Boolean);
var
  FS, PS: string;
begin
  if MakeFields(FTable, FS, PS, AIgnorePrimaryKeys) then
  begin
    CheckTableName;
    ASQL := 'update ' + FTable.Name + ' set ' + FS + ' where ' + PS;
  end;
end;

{ TdGDeleteBuilder }

class function TdGDeleteBuilder.MakeParams(ATable: T; out AParams: string;
  const AIgnoreProperties: Boolean): Boolean;
var
  N, P: string;
  I, X: Integer;
begin
  AParams := '';
  Result := (ATable <> nil) and Assigned(ATable.PropList);
  if not Result then
    Exit;
  for I := 0 to Pred(ATable.PropCount) do
  begin
    N := ATable.PropList^[I]^.Name;
    X := ATable.PrimaryKeys.IndexOf(N);
    if X > -1 then
    begin
      P := ATable.PrimaryKeys[X];
      AParams += P + ' = :' + P + ' and ';
    end
    else
    begin
      if ATable.IgnoredFields.IndexOf(N) > -1 then
        Continue;
      if not AIgnoreProperties then
        AParams += N + ' = :' + N + ' and ';
    end;
  end;
  SetLength(AParams, Length(AParams) - 5);
  AParams := LowerCase(AParams);
end;

procedure TdGDeleteBuilder.Build(out ASql: string;
  const AIgnoreProperties: Boolean);
var
  PS: string;
begin
  if MakeParams(FTable, PS, AIgnoreProperties) then
  begin
    CheckTableName;
    ASQL := 'delete from ' + FTable.Name + ' where ' + PS;
  end;
end;

end.

