unit dbutils;

{$mode objfpc}{$H+}

interface

uses
  dSQLdbBroker, SysUtils, PQConnection;

function con: TdSQLdbConnector;

implementation

var
  _con: TdSQLdbConnector = nil;

function con: TdSQLdbConnector;
begin
  if not Assigned(_con) then
  begin
    _con := TdSQLdbConnector.Create(nil);
    _con.Driver := 'postgresql';
    _con.Host := '127.0.0.1';
    _con.Database := 'postgres';
    _con.User := 'postgres';
    _con.Password := 'postgres';
  end;
  Result := _con;
end;

finalization
  FreeAndNil(_con);

end.

