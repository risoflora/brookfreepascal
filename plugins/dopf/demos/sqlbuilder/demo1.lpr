program demo1;

{$mode objfpc}{$H+}

uses
  dSqlBuilder, person;

type

  { Ttable }

  Ttable = class(specialize TdGTable<TPerson>)
  public
    constructor Create; override;
  end;

  Tselect = specialize TdGSelectBuilder<Ttable>;

  Tinsert = specialize TdGInsertBuilder<Ttable>;

  Tupdate = specialize TdGUpdateBuilder<Ttable>;

  Tdelete = specialize TdGDeleteBuilder<Ttable>;

  Tbuilder = specialize TdGSqlBuilder<Ttable>;

  { Ttable }

  constructor Ttable.Create;
  begin
    inherited Create;
    Name := 'person';
  end;

var
  sql: string;
  table: Ttable;
  builder: Tbuilder;
begin
  table := Ttable.Create;
  try
    builder := Tselect.Create(nil);
    try
      builder.SetTable(table);
      builder.Build(sql);
      WriteLn('Select 1: ', sql);
      builder.Build(sql, False);
      WriteLn('Select 2: ', sql);
    finally
      builder.Free;
    end;

    WriteLn;

    builder := Tinsert.Create(nil);
    try
      builder.SetTable(table);
      table.PrimaryKeys.Add('AnotherPrimaryKey');
      builder.Build(sql);
      WriteLn('Insert 1: ', sql);
      builder.Build(sql, False);
      WriteLn('Insert 2: ', sql);
    finally
      builder.Free;
    end;

    WriteLn;

    builder := Tupdate.Create(nil);
    try
      builder.SetTable(table);
      table.PrimaryKeys.Add('AnotherPrimaryKey');
      builder.Build(sql);
      WriteLn('Update 1: ', sql);
      builder.Build(sql, False);
      WriteLn('Update 2: ', sql);
    finally
      builder.Free;
    end;

    WriteLn;

    builder := Tdelete.Create(nil);
    try
      builder.SetTable(table);
      table.PrimaryKeys.Add('AnotherPrimaryKey');
      builder.Build(sql);
      WriteLn('Delete 1: ', sql);
      builder.Build(sql, False);
      WriteLn('Delete 2: ', sql);
    finally
      builder.Free;
    end;
  finally
    table.Free;
  end;

  ReadLn;
end.

