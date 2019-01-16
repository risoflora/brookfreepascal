(*
  Brook framework, FCL EventLog Broker

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookFCLEventLogBroker;

{$mode objfpc}{$H+}

interface

uses
  BrookLogger, BrookUtils, EventLog, SysUtils, Classes;

type

  { TBrookFCLEventLog }

  TBrookFCLEventLog = class(TBrookLogger)
  private
    FLogger: TEventLog;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Prepare; override;
    procedure Log(const AType: TBrookLogType; const S: string;
      const ACode: Word; const E: Exception = nil); override;
  end;

implementation

{ TBrookFCLEventLog }

constructor TBrookFCLEventLog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FLogger := TEventLog.Create(nil);
  FLogger.Identification := ApplicationName;
end;

destructor TBrookFCLEventLog.Destroy;
begin
  FreeAndNil(FLogger);
  inherited Destroy;
end;

procedure TBrookFCLEventLog.Prepare;
begin
  inherited Prepare;
  FLogger.Active := False;
  case Output of
    loFile: FLogger.LogType := EventLog.ltFile;
    loSystem: FLogger.LogType := EventLog.ltSystem;
  end;
  if FileName = '' then
    FLogger.FileName := BrookSettings.LogFile
  else
    FLogger.FileName := FileName;
  FLogger.RaiseExceptionOnError := False;
  FLogger.AppendContent := True;
  if Active then
    FLogger.Active := Active
  else
    FLogger.Active := BrookSettings.LogActive;
end;

procedure TBrookFCLEventLog.Log(const AType: TBrookLogType; const S: string;
  const ACode: Word; const E: Exception);
var
  X: string;
begin
  if not (AType in Types) then
    Exit;
  if FLogger.Active then
  begin
    X := S;
    if Assigned(E) then
      X += '<Error>' + LineEnding +
        Format('%s exception was raised with the following message: %s',
        [E.ClassName, E.Message]) + LineEnding +
        BrookDumpStack(LineEnding) + LineEnding +
        BrookDumpStackTrace(LineEnding) + '</Error>';
    case AType of
      ltCustom:
        begin
          FLogger.CustomLogType := ACode;
          FLogger.Log(etCustom, X);
        end;
      ltInfo: FLogger.Log(etInfo, X);
      ltWarning: FLogger.Log(etWarning, X);
      ltError: FLogger.Log(etError, X);
      ltDebug: FLogger.Log(etDebug, X);
    end;
  end;
end;

initialization
  TBrookFCLEventLog.RegisterService;

finalization
  TBrookFCLEventLog.UnregisterService;

end.

