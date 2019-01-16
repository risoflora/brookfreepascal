program console;

{$mode objfpc}{$H+}

uses
  heaptrc, Classes, consoletestrunner, alltestsrt;

type

  { TMyTestRunner }

  TMyTestRunner = class(TTestRunner)
  end;

begin
  with TMyTestRunner.Create(nil) do
  try
    Initialize;
    Run;
  finally
    Free;
  end;
end.
