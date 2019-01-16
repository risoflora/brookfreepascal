program project1;

{$mode objfpc}{$H+}

{$DEFINE THREADED}

uses
{$IF DEFINED(UNIX) AND DEFINED(THREADED)}
  CThreads,
{$ENDIF}
  BrookApplication,
  BrookTardigradeBroker,
  Config,
  Unit1;

begin
{$IFDEF THREADED}
  Application.Server.Threaded := True;
{$ENDIF}
  Application.Server.Port := 8080;
  Application.Initialize;
  Application.Run;
end.
