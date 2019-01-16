unit person;

{$mode objfpc}{$H+}

interface

uses
  dbutils, sqldb, SysUtils;

type
  EPerson = class(Exception);

  { TPerson }

  TPerson = class
  private
    FId: Int64;
    FName: string;
  public
    procedure Validate;
    procedure Save;
  published
    property Id: Int64 read FId write FId;
    property Name: string read FName write FName;
  end;

implementation

{ TPerson }

procedure TPerson.Validate;
begin
  if Trim(FName) = '' then
    raise EPerson.Create('Name must not be empty.');
end;

procedure TPerson.Save;
var
  q: TSQLQuery;
  t: TSQLTransaction;
  c: TSQLConnection;
begin
  Validate;
  t := TSQLTransaction.Create(nil);
  q := TSQLQuery.Create(nil);
  try
    c := dbutils.Connection;
    t.DataBase := c;
    q.Transaction := t;
    q.DataBase := c;
    q.SQL.Text := 'insert into person (name) values (:name)';
    q.Params.ParamByName('name').AsString := FName;
    try
      q.ExecSQL;
      t.Commit;
    except
      t.Rollback;
      raise;
    end;
  finally
    q.Free;
    t.Free;
  end;
end;

end.

