(*
  Brook framework, FCL HTTP Daemon Broker

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookFCLHttpDaemonBroker;

{$mode objfpc}{$H+}

interface

uses
{$IFDEF MSWINDOWS}
  ServiceManager,
{$ENDIF}
  BrookFCLHttpAppBroker, BrookApplication, BrookConsts, DaemonApp, Classes,
  SysUtils;

type

  { TBrookDaemonApplication }

  TBrookDaemonApplication = class(TInterfacedObject, IBrookApplication)
  private
    function GetTerminated: Boolean;
  public
    constructor Create;
    function Instance: TObject;
    procedure CreateForm(AInstanceClass: TComponentClass; out AReference);
    procedure Run;
    procedure Terminate;
    property Terminated: Boolean read GetTerminated;
  end;

  { TBrookDaemonThread }

  TBrookDaemonThread = class(TThread)
  public
    constructor Create; virtual;
    procedure Execute; override;
  end;

  { TBrookHttpDaemon }

  TBrookHttpDaemon = class(TCustomDaemon)
  private
    FThread: TThread;
  public
    function Install: Boolean; override;
    function Uninstall: Boolean; override;
    function Start: Boolean; override;
    function Stop: Boolean; override;
  end;

  { TBrookHttpDaemonMapper }

  TBrookHttpDaemonMapper = class(TCustomDaemonMapper)
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

var
  _BrookHttpApp: IBrookApplication = nil;

function BrookHttpApp: IBrookApplication;
begin
  if not Assigned(_BrookHttpApp) then
  begin
    _BrookHttpApp := TBrookApplication.Create;
    TBrookHttpApplication(_BrookHttpApp.Instance).ShowTermMsg := False;
  end;
  Result := _BrookHttpApp;
end;

{ TBrookDaemonApplication }

function TBrookDaemonApplication.GetTerminated: Boolean;
begin
  Result := Application.Terminated;
end;

constructor TBrookDaemonApplication.Create;
begin
  Application.Title := 'Brook HTTP daemon application';
end;

function TBrookDaemonApplication.Instance: TObject;
begin
  Result := BrookHttpApp.Instance;
end;

procedure TBrookDaemonApplication.CreateForm(AInstanceClass: TComponentClass;
  out AReference);
var
  VInstance: TObject;
  VReference: TComponent;
begin
  VReference := AInstanceClass.Create(nil);
  TComponent(AReference) := VReference;
  VInstance := Instance;
  if VInstance is TComponent then
    TComponent(VInstance).InsertComponent(VReference);
end;

procedure TBrookDaemonApplication.Run;
begin
  Application.Run;
end;

procedure TBrookDaemonApplication.Terminate;
begin
  Application.Terminate;
end;

{ TBrookDaemonThread }

constructor TBrookDaemonThread.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
end;

procedure TBrookDaemonThread.Execute;
begin
  BrookHttpApp.Run;
end;

{ TBrookHttpDaemon }

function TBrookHttpDaemon.Start: Boolean;
begin
  Result := inherited Start;
  FThread := TBrookDaemonThread.Create;
  FThread.Start;
end;

function TBrookHttpDaemon.Stop: Boolean;
begin
  Result := inherited Stop;
  FThread.Terminate;
end;

function TBrookHttpDaemon.Install: Boolean;
{$IFDEF MSWINDOWS}
var
  VSM: TServiceManager;
{$ENDIF}
begin
  Result := inherited Install;
{$IFDEF MSWINDOWS}
  VSM := TServiceManager.Create(nil);
  try
    VSM.Connect;
    if VSM.Connected then
      VSM.StartService(BROOK_HTTP_DAEMON_NAME, nil);
    VSM.Disconnect;
  finally
    VSM.Free;
  end;
{$ENDIF}
  WriteLn('Service installed.');
  WriteLn(BrookHttpServerTerminalMsg);
end;

function TBrookHttpDaemon.Uninstall: Boolean;
{$IFDEF MSWINDOWS}
var
  VSM: TServiceManager;
{$ENDIF}
begin
  Result := inherited Uninstall;
{$IFDEF MSWINDOWS}
  VSM := TServiceManager.Create(nil);
  try
    VSM.Connect;
    if VSM.Connected then
      VSM.StopService(BROOK_HTTP_DAEMON_NAME, True);
    VSM.Disconnect;
  finally
    VSM.Free;
  end;
{$ENDIF}
  WriteLn('Service uninstalled.');
end;

{ TBrookHttpDaemonMapper }

constructor TBrookHttpDaemonMapper.Create(AOwner: TComponent);
var
  VDaemonDef: TDaemonDef;
begin
  inherited Create(AOwner);
  VDaemonDef := DaemonDefs.Add as TDaemonDef;
  VDaemonDef.Description := BROOK_HTTP_DAEMON_DESCRIPTION;
  VDaemonDef.DisplayName := BROOK_HTTP_DAEMON_DISPLAYNAME;
  VDaemonDef.Name := BROOK_HTTP_DAEMON_NAME;
  VDaemonDef.DaemonClassName := BROOK_HTTP_DAEMON_CLASSNAME;
  VDaemonDef.WinBindings.ServiceType := stWin32;
end;

initialization
  RegisterDaemonClass(TBrookHttpDaemon);
  RegisterDaemonMapper(TBrookHttpDaemonMapper);
  BrookUnregisterApp;
  BrookRegisterApp(TBrookDaemonApplication.Create);

end.
