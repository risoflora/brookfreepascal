program server;

{$mode objfpc}{$H+}

uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  Interfaces, Forms, frmserver;

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrServer, frServer);
  Application.Run;
end.

