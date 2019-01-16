program client;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Interfaces, Forms, frmclient;

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  Application.CreateForm(TfrClient, frClient);
  Application.Run;
end.

