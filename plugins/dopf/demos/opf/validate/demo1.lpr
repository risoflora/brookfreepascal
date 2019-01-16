program demo1;

{$mode objfpc}{$H+}

uses
  personobjs;

var
  person: TPerson;
  opf: TPersonOpf;
begin
  person := TPerson.Create;
  opf := TPersonOpf.Create;
  try
//    person.Name := 'Albert Einstein';
    WriteLn('Trying to insert a record without validating it ...');
    opf.Add(person);
    opf.Commit;
    WriteLn('Done.');
  finally
    person.Free;
    opf.Free;
  end;

  ReadLn;
end.

