(*
  Brook framework, FCL FastCGI Broker

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookFCLFCGIBroker;

{$mode objfpc}{$H+}

interface

uses
  BrookClasses, BrookApplication, BrookLogger, BrookMessages, BrookConsts,
  BrookHttpConsts, BrookRouter, BrookUtils, BrookHttpDefsBroker, HttpDefs,
  CustWeb, CustFCGI, Classes, SysUtils;

type
  TBrookFCGIApplication = class;

  { TBrookApplication }

  TBrookApplication = class(TBrookInterfacedObject, IBrookApplication)
  private
    FApp: TBrookFCGIApplication;
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

  { TBrookFCGIApplication }

  TBrookFCGIApplication = class(TCustomFCGIApplication)
  protected
    function InitializeWebHandler: TWebHandler; override;
  end;

  { TBrookFCGIRequest }

  TBrookFCGIRequest = class(TFCGIRequest)
  protected
    procedure DeleteTempUploadedFiles; override;
    function GetTempUploadFileName(const AName, AFileName: string;
      ASize: Int64): string; override;
    function RequestUploadDir: string; override;
    procedure InitRequestVars; override;
  end;

  { TBrookFCGIResponse }

  TBrookFCGIResponse = class(TFCGIResponse)
  protected
    procedure CollectHeaders(AHeaders: TStrings); override;
  end;

  { TBrookFCGIHandler }

  TBrookFCGIHandler = class(TFCGIHandler)
  protected
    function CreateRequest: TFCGIRequest; override;
    function CreateResponse(ARequest: TFCGIRequest): TFCGIResponse; override;
  public
    procedure HandleRequest(ARequest: TRequest; AResponse: TResponse); override;
    procedure ShowRequestException(R: TResponse; E: Exception); override;
  end;

implementation

{ TBrookApplication }

function TBrookApplication.GetTerminated: Boolean;
begin
  Result := FApp.Terminated;
end;

constructor TBrookApplication.Create;
begin
  FApp := TBrookFCGIApplication.Create(nil);
  FApp.Initialize;
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
  FApp.Run;
end;

procedure TBrookApplication.Terminate;
begin
  FApp.Terminate;
end;

{ TBrookFCGIApplication }

function TBrookFCGIApplication.InitializeWebHandler: TWebHandler;
begin
  Result := TBrookFCGIHandler.Create(Self);
end;

{ TBrookFCGIRequest }

procedure TBrookFCGIRequest.DeleteTempUploadedFiles;
begin
  if BrookSettings.DeleteUploadedFiles then
    inherited;
end;

function TBrookFCGIRequest.GetTempUploadFileName(
  const AName, AFileName: string; ASize: Int64): string;
begin
  if BrookSettings.KeepUploadedNames then
    Result := RequestUploadDir + AFileName
  else
    Result := inherited GetTempUploadFileName(AName, AFileName, ASize);
end;

function TBrookFCGIRequest.RequestUploadDir: string;
begin
  Result := BrookSettings.DirectoryForUploads;
  if Result = '' then
    Result := GetTempDir;
  Result := IncludeTrailingPathDelimiter(Result);
end;

procedure TBrookFCGIRequest.InitRequestVars;
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

{ TBrookFCGIResponse }

procedure TBrookFCGIResponse.CollectHeaders(AHeaders: TStrings);
begin
  AHeaders.Add(BROOK_HTTP_HEADER_X_POWERED_BY + HS +
    'Brook framework and FCL-Web.');
  inherited CollectHeaders(AHeaders);
end;

{ TBrookFCGIHandler }

function TBrookFCGIHandler.CreateRequest: TFCGIRequest;
begin
  Result := TBrookFCGIRequest.Create;
  if ApplicationURL = ES then
    ApplicationURL := TBrookRouter.RootUrl;
end;

function TBrookFCGIHandler.CreateResponse(ARequest: TFCGIRequest): TFCGIResponse;
begin
  Result := TBrookFCGIResponse.Create(ARequest);
end;

procedure TBrookFCGIHandler.HandleRequest(ARequest: TRequest; AResponse: TResponse);
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
    TBrookFCGIRequest(ARequest).DeleteTempUploadedFiles;
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

procedure TBrookFCGIHandler.ShowRequestException(R: TResponse; E: Exception);
begin
  BrookShowRequestException(Self, R, E);
end;

initialization
  BrookRegisterApp(TBrookApplication.Create);

finalization
  BrookUnregisterApp;

end.
