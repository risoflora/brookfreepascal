unit dbutils;

{$mode objfpc}{$H+}

interface

uses
  sysutils, pqconnection;

var
  Connection: TPQConnection;

implementation

initialization
  Connection := TPQConnection.Create(nil);
  Connection.HostName := '127.0.0.1';
  Connection.DatabaseName := 'postgres';
  Connection.UserName := 'postgres';
  Connection.Password := 'postgres';

finalization
  FreeAndNil(Connection);

end.

