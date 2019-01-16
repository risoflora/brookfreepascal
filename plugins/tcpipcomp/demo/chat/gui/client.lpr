program client;

{$mode objfpc}{$H+}

uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  Interfaces, Forms, frmclient, SysUtils, Dialogs;

begin
  RequireDerivedFormResource := True;
  Application.Initialize;
  NickName := '';
  if not InputQuery('Nickname', 'Put your nick name: ', NickName) then
    Exit;
  if Trim(NickName) = '' then
    Exit;
  Application.CreateForm(TfrClient, frClient);
  Application.Run;
end.

