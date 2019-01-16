unit dbutils;

{$mode objfpc}{$H+}

interface

uses
  BrookConfigurator, dSQLdbBroker, dUtils, PQConnection, SysUtils;

function con: TdSQLdbConnector;
function pgNextSeq(const ASeqName: string): Int64;
function pgCount(const ATableName: string): Int64; overload;
function pgCount(const ATableName, AWhere: string; AParams: TObject;
  const ANulls: Boolean): Int64; overload;
function pgCount(const ATableName, ASelect, AWhere: string; AParams: TObject;
  const ANulls: Boolean): Int64; overload;

implementation

var
  _con: TdSQLdbConnector = nil;

function con: TdSQLdbConnector;
var
  cfg: TBrookConfigurator;
begin
  if not Assigned(_con) then
  begin
    cfg := TBrookConfigurator.Create(nil);
    _con := TdSQLdbConnector.Create(nil);
    try
      cfg.Target := _con;
      cfg.Configure;
//      _con.Logger.Active := True;
//      _con.Logger.FileName := 'OUTPUT.LOG';
    finally
      cfg.Free;
    end;
  end;
  Result := _con;
end;

function pgNextSeq(const ASeqName: string): Int64;
var
  q: TdSQLdbQuery;
begin
  q := TdSQLdbQuery.Create(con);
  try
    q.SQL.Text := 'select nextval(''' + ASeqName + ''')';
    q.Open;
    Result := q.Fields[0].AsInteger;
  finally
    q.Free;
  end;
end;

function pgCount(const ATableName: string): Int64;
var
  q: TdSQLdbQuery;
begin
  q := TdSQLdbQuery.Create(con);
  try
    q.SQL.Text := 'select count(*) from ' + ATableName;
    q.Open;
    Result := q.Fields[0].AsInteger;
  finally
    q.Free;
  end;
end;

function pgCount(const ATableName, AWhere: string; AParams: TObject;
  const ANulls: Boolean): Int64;
var
  q: TdSQLdbQuery;
begin
  q := TdSQLdbQuery.Create(con);
  try
    q.AddSql('select count(*) from ' + ATableName);
    if AWhere <> '' then
    begin
      q.AddSql('where ' + AWhere);
      dUtils.dSetParams(AParams, q.Params, ANulls);
    end;
    q.Open;
    Result := q.Fields[0].AsInteger;
  finally
    q.Free;
  end;
end;

function pgCount(const ATableName, ASelect, AWhere: string; AParams: TObject;
  const ANulls: Boolean): Int64;
var
  q: TdSQLdbQuery;
begin
  q := TdSQLdbQuery.Create(con);
  try
    if ASelect = '' then
      q.AddSql('select count(*) from ' + ATableName)
    else
      q.AddSql(ASelect);
    if AWhere <> '' then
    begin
      q.AddSql('where ' + AWhere);
      dUtils.dSetParams(AParams, q.Params, ANulls);
    end;
    q.Open;
    Result := q.Fields[0].AsInteger;
  finally
    q.Free;
  end;
end;

finalization
  FreeAndNil(_con);

end.

