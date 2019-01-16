(*
  Brook framework, FCL HTTPApp Broker

  Copyright (C) 2014 Mario Ray Mahardhika

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookFCLHttpAppBroker;

{$mode objfpc}{$H+}

interface

uses
  BrookClasses, BrookApplication, BrookLogger, BrookRouter, BrookUtils,
  BrookConsts, BrookHttpConsts, BrookHttpDefsBroker, BrookMessages, HttpDefs,
  CustWeb, CustHttpApp, FPHttpServer, Classes, SysUtils;

type
  TBrookHttpApplication = class;

  { TBrookApplication }

  TBrookApplication = class(TBrookInterfacedObject, IBrookApplication)
  private
    FApp: TBrookHttpApplication;
    function GetTerminated: Boolean;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure CreateForm(AInstanceClass: TComponentClass; out AReference);
    function Instance: TObject;
    procedure Run;
    procedure Terminate;
    property Terminated: Boolean read GetTerminated;
  end;

  { TBrookHttpApplication }

  TBrookHttpApplication = class(TCustomHttpApplication)
  private
    FShowTermMsg: Boolean;
  protected
    function InitializeWebHandler: TWebHandler; override;
  public
    property ShowTermMsg: Boolean read FShowTermMsg write FShowTermMsg;
  end;

  { TBrookHttpConnectionRequest }

  TBrookHttpConnectionRequest = class(TFPHttpConnectionRequest)
  protected
    procedure DeleteTempUploadedFiles; override;
    function GetTempUploadFileName(const AName, AFileName: string;
      ASize: Int64): string; override;
    function RequestUploadDir: string; override;
    procedure InitRequestVars; override;
  end;

  { TBrookHttpConnectionResponse }

  TBrookHttpConnectionResponse = class(TFPHttpConnectionResponse)
  protected
    procedure CollectHeaders(AHeaders: TStrings); override;
  end;

 { TBrookEmbeddedHttpServer }

  TBrookEmbeddedHttpServer = class(TEmbeddedHttpServer)
  protected
    function CreateRequest: TFPHttpConnectionRequest; override;
    function CreateResponse(
      ARequest: TFPHttpConnectionRequest): TFPHttpConnectionResponse; override;
  end;

  { TBrookHttpServerHandler }

  TBrookHttpServerHandler = class(TFPHttpServerHandler)
  protected
    function CreateServer: TEmbeddedHttpServer; override;
  public
    procedure HandleRequest(ARequest: TRequest; AResponse: TResponse); override;
    procedure ShowRequestException(R: TResponse; E: Exception); override;
  end;

var
  SBrookHttpServerTerminalMsg: string =
    'Open the ''%s'' URL in your browser.'
{$IFDEF UNIX} + LineEnding + LineEnding + 'Use [Ctrl+C] to quit ...'{$ENDIF};

function BrookHttpServerTerminalMsg: string;

implementation

function BrookHttpServerTerminalMsg: string;
var
  VUrl: string;
begin
  if BrookSettings.RootUrl = '' then
    VUrl := 'http://localhost'
  else
    VUrl := BrookSettings.RootUrl;
  if VUrl[Length(VUrl)] = US then
    System.Delete(VUrl, Length(VUrl), 1);
  if not (BrookSettings.Port in [0, 80]) then
    VUrl += ':' + IntToStr(BrookSettings.Port);
  Result := Format(SBrookHttpServerTerminalMsg, [VUrl]);
end;

{ TBrookApplication }

function TBrookApplication.GetTerminated: Boolean;
begin
  Result := FApp.Terminated;
end;

constructor TBrookApplication.Create;
begin
  FApp := TBrookHttpApplication.Create(nil);
  FApp.Initialize;
  FApp.ShowTermMsg := System.IsConsole;
end;

destructor TBrookApplication.Destroy;
begin
  FApp.Free;
  inherited Destroy;
end;

procedure TBrookApplication.CreateForm(AInstanceClass: TComponentClass;
  out AReference);
var
  VReference: TComponent;
begin
  VReference := AInstanceClass.Create(nil);
  TComponent(AReference) := VReference;
  FApp.InsertComponent(VReference);
end;

function TBrookApplication.Instance: TObject;
begin
  Result := FApp;
end;

procedure TBrookApplication.Run;
begin
  if BrookSettings.Port <> 0 then
    FApp.Port := BrookSettings.Port;
  if BrookSettings.RootUrl <> '' then
    FApp.ApplicationURL := BrookSettings.RootUrl;
  if FApp.ShowTermMsg then
    WriteLn(BrookHttpServerTerminalMsg);
  FApp.Run;
end;

procedure TBrookApplication.Terminate;
begin
  FApp.Terminate;
end;

{ TBrookHttpApplication }

function TBrookHttpApplication.InitializeWebHandler: TWebHandler;
begin
  Result := TBrookHttpServerHandler.Create(Self);
end;

{ TBrookHttpConnectionRequest }

procedure TBrookHttpConnectionRequest.DeleteTempUploadedFiles;
begin
  if BrookSettings.DeleteUploadedFiles then
    inherited;
end;

function TBrookHttpConnectionRequest.GetTempUploadFileName(const AName,
  AFileName: string; ASize: Int64): string;
begin
  if BrookSettings.KeepUploadedNames then
    Result := RequestUploadDir + AFileName
  else
    Result := inherited GetTempUploadFileName(AName, AFileName, ASize);
end;

function TBrookHttpConnectionRequest.RequestUploadDir: string;
begin
  Result := BrookSettings.DirectoryForUploads;
  if Result = '' then
    Result := GetTempDir;
  Result := IncludeTrailingPathDelimiter(Result);
end;

procedure TBrookHttpConnectionRequest.InitRequestVars;
var
  VMethod: string;
begin
  VMethod := Method;
  if VMethod = ES then
    raise Exception.Create(SBrookNoRequestMethodError);
  case VMethod of
    BROOK_HTTP_REQUEST_METHOD_DELETE, BROOK_HTTP_REQUEST_METHOD_PUT,
      BROOK_HTTP_REQUEST_METHOD_PATCH:
      begin
        InitPostVars;
        if HandleGetOnPost then
          InitGetVars;
      end;
  else
    inherited;
  end;
end;

{ TBrookHttpConnectionResponse }

procedure TBrookHttpConnectionResponse.CollectHeaders(AHeaders: TStrings);
begin
  AHeaders.Add(BROOK_HTTP_HEADER_X_POWERED_BY + HS +
    'Brook framework and FCL-Web.');
  inherited CollectHeaders(AHeaders);
end;

{ TBrookEmbeddedHttpServer }

function TBrookEmbeddedHttpServer.CreateRequest: TFPHttpConnectionRequest;
begin
  Result := TBrookHttpConnectionRequest.Create;
end;

function TBrookEmbeddedHttpServer.CreateResponse(
  ARequest: TFPHttpConnectionRequest): TFPHttpConnectionResponse;
begin
  Result := TBrookHttpConnectionResponse.Create(ARequest);
end;

{ TBrookHttpServerHandler }

function TBrookHttpServerHandler.CreateServer: TEmbeddedHttpServer;
begin
  Result := TBrookEmbeddedHttpServer.Create(Self);
end;

procedure TBrookHttpServerHandler.HandleRequest(ARequest: TRequest;
  AResponse: TResponse);
var
  VLog: string;
begin
  AResponse.ContentType := BrookFormatContentType;
  if BrookSettings.LogActive then
  begin
    VLog := LineEnding;
    if ARequest.PathInfo <> ES then
      VLog += '<PathInfo>' + LineEnding + ARequest.PathInfo + LineEnding +
        '</PathInfo>' + LineEnding;
    if ARequest.CookieFields.Count > 0 then
      VLog += '<Cookies>' + LineEnding + ARequest.CookieFields.Text +
        '</Cookies>' + LineEnding;
    if ARequest.ContentFields.Count > 0 then
      VLog += '<Fields>' + LineEnding + ARequest.ContentFields.Text +
        '</Fields>' + LineEnding;
    if ARequest.QueryFields.Count > 0 then
      VLog += '<Params>' + LineEnding + ARequest.QueryFields.Text +
        '</Params>' + LineEnding;
  end;
  try
    TBrookRouter.Service.Route(ARequest, AResponse);
    TBrookHttpConnectionRequest(ARequest).DeleteTempUploadedFiles;
    if BrookSettings.LogActive and (AResponse.Contents.Count > 0) then
    begin
      VLog += '<Content>' + LineEnding + AResponse.Contents.Text +
        '</Content>';
      TBrookLogger.Service.Info(VLog);
    end;
  except
    on E: Exception do
    begin
      if BrookSettings.LogActive then
        TBrookLogger.Service.Error(VLog, E);
      ShowRequestException(AResponse, E);
    end;
  end;
end;

procedure TBrookHttpServerHandler.ShowRequestException(R: TResponse; E: Exception);
begin
  BrookShowRequestException(Self, R, E);
end;

initialization
  BrookRegisterApp(TBrookApplication.Create);

finalization
  BrookUnregisterApp;

end.
