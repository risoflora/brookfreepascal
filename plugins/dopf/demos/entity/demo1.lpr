program demo1;

{$mode objfpc}{$H+}

uses
  dSQLdbBroker, person, sysutils, sqlite3conn;

type
  Tcon = class(TdSQLdbConnector)
  end;

  Tqry = class(specialize TdGSQLdbEntityQuery<Tcon, TPerson>)
  end;

var
  con: Tcon;
  qry: Tqry;
begin
  con := Tcon.Create(nil);
  qry := Tqry.Create(con);
  try
    con.Logger.Active := True;
    con.Logger.FileName := 'OUTPUT.LOG';
    con.Driver := 'sqlite3';
    con.Database := '../data.sqlite3';
    con.Connect;

    qry.SQL.Text := 'delete from person';
    qry.Execute;
    qry.Apply;

    qry.SQL.Text := 'insert into person (id, name) values (:id, :name)';
    qry.Entity.Id := 1;
    qry.Entity.Name := 'Silvio';
    qry.SetParams;
    qry.Execute;
    qry.Entity.Id := 2;
    qry.Entity.Name := 'Waldir';
    qry.SetParams;
    qry.Execute;
    qry.Apply;

    qry.SQL.Text := 'select id, name from person';
    qry.Open;
    qry.First;
    while not qry.EOF do
    begin
      qry.GetFields;
      WriteLn('Record: ', qry.Entity.id, ', ', qry.Entity.Name);
      qry.Next;
    end;

    qry.Apply;

    ReadLn;
  finally
    con.Free;
  end;
end.

