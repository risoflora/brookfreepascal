program demo1;

{$mode objfpc}{$H+}

uses
  dOpf, dSQLdbBroker, dbutils, person, sysutils;

type
  Topf = specialize TdGSQLdbOpf<TPerson>;

var
  i, per: TPerson;
  pers: Topf.TEntities;
  opf: Topf;
begin
  opf := Topf.Create(dbutils.con, 'person');
  pers := Topf.TEntities.Create;
  per := TPerson.Create;
  try
    WriteLn('Empty table');
    opf.Empty;
    opf.Apply;
    WriteLn('Done.');

    WriteLn('Add Silvio Clécio');
    per.Name := 'Silvio Clécio';
    opf.Add(per);
    WriteLn('Done.');

    WriteLn('Add Anonymous');
    per.Id := 1000;
    per.Name := 'Anonymous';
    opf.Add(per, False);
    WriteLn('Done.');

    WriteLn('Add Waldir');
    per.Id := 1001;
    per.Name := 'Waldir';
    opf.Add(per, False);
    WriteLn('Done.');

    WriteLn('Add João Morais');
    per.Name := 'João Morais';
    opf.Add(per);
    WriteLn('Done.');

    WriteLn('Add Sven Barth');
    per.Name := 'Sven Barth';
    opf.Add(per);
    WriteLn('Done.');

    WriteLn('Modify name of Waldir to Waldir Paim');
    per.Id := 1001;
    per.Name := 'Waldir Paim';
    opf.Modify(per);
    WriteLn('Done.');

    WriteLn('Remove Anonymous');
    per.Id := 1000;
    opf.Remove(per);
    WriteLn('Done.');

    WriteLn('Get Waldir Paim');
    per.Id := 1001;
    opf.Get(per);
    WriteLn(per.Id, ', ', per.Name);
    WriteLn('Done.');

    WriteLn('Find Silvio Clécio by name');
    per.Name := 'Silvio Clécio';
    opf.Find(per, 'name = :name');
    WriteLn(per.Id, ', ', per.Name);
    WriteLn('Done.');

    WriteLn('Search for names containing "a"');
    per.Name := '%a%';
    opf.Find(per, pers, 'name like (:name)');
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
    per.Name := '%a%';
    opf.Search(per, pers, nil,
      'select * from person where name like (:name) order by id desc');
    for i in pers do
      WriteLn(i.Id, ', ', i.Name);
    pers.Clear;
    WriteLn('Done.');

    opf.Apply;
  finally
    per.Free;
    pers.Free;
    opf.Free;
  end;

  ReadLn;
end.

