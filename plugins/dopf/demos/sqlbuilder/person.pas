unit person;

{$mode objfpc}{$H+}

interface

type

  { TPerson }

  TPerson = class(TObject)
  private
    FAnotherPrimaryKey: Int64;
    FId: Int64;
    FName: string;
  published
    property Id: Int64 read FId write FId;
    property AnotherPrimaryKey: Int64 read FAnotherPrimaryKey write FAnotherPrimaryKey;
    property Name: string read FName write FName;
  end;

implementation

end.

