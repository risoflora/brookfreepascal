program demo1;

{$mode objfpc}{$H+}

uses
  dOpf, dSQLdbBroker, dbutils, person, sysutils;

type
  Topf = specialize TdGSQLdbEntityOpf<TPerson>;

var
  i: TPerson;
  pers: Topf.TEntities;
  opf: Topf;
begin
  opf := Topf.Create(dbutils.con, 'person');
  pers := Topf.TEntities.Create;
  try
    WriteLn('Empty table');
    opf.Empty;
    opf.Apply;
    WriteLn('Done.');

    WriteLn('Add Silvio Clécio');
    opf.Entity.Name := 'Silvio Clécio';
    opf.Add;
    WriteLn('Done.');

    WriteLn('Add Anonymous');
    opf.Entity.Id := 1000;
    opf.Entity.Name := 'Anonymous';
    opf.Add(False);
    WriteLn('Done.');

    WriteLn('Add Waldir');
    opf.Entity.Id := 1001;
    opf.Entity.Name := 'Waldir';
    opf.Add(False);
    WriteLn('Done.');

    WriteLn('Add João Morais');
    opf.Entity.Name := 'João Morais';
    opf.Add;
    WriteLn('Done.');

    WriteLn('Add Sven Barth');
    opf.Entity.Name := 'Sven Barth';
    opf.Add;
    WriteLn('Done.');

    WriteLn('Modify name of Waldir to Waldir Paim');
    opf.Entity.Id := 1001;
    opf.Entity.Name := 'Waldir Paim';
    opf.Modify;
    WriteLn('Done.');

    WriteLn('Remove Anonymous');
    opf.Entity.Id := 1000;
    opf.Remove;
    WriteLn('Done.');

    WriteLn('Get Waldir Paim');
    opf.Entity.Id := 1001;
    opf.Get;
    WriteLn(opf.Entity.Id, ', ', opf.Entity.Name);
    WriteLn('Done.');

    WriteLn('Find Silvio Clécio by name');
    opf.Entity.Name := 'Silvio Clécio';
    opf.Find('name = :name');
    WriteLn(opf.Entity.Id, ', ', opf.Entity.Name);
    WriteLn('Done.');

    WriteLn('Search for names containing "a"');
    opf.Entity.Name := '%a%';
    opf.Find(pers, 'name like (:name)');
    for i in pers do
      WriteLn(i.Id, ', ', i.Name);
    pers.Clear;
    WriteLn('Done.');

    WriteLn('List all');
    opf.List(pers);
    for i in pers do
      WriteLn(i.Id, ', ', i.Name);
    pers.Clear;
    WriteLn('Done.');

    WriteLn('Search for names containing "a" (order by id DESC)');
    opf.Entity.Name := '%a%';
    opf.Search(pers, nil,
      'select * from person where name like (:name) order by id desc');
    for i in pers do
      WriteLn(i.Id, ', ', i.Name);
    pers.Clear;
    WriteLn('Done.');

    opf.Apply;
  finally
    pers.Free;
    opf.Free;
  end;

  ReadLn;
end.

