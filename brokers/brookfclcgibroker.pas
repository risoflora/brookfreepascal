(*
  Brook framework, FCL CGI Broker

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookFCLCGIBroker;

{$mode objfpc}{$H+}

interface

uses
  BrookClasses, BrookApplication, BrookLogger, BrookMessages, BrookConsts,
  BrookHttpConsts, BrookRouter, BrookUtils, BrookHttpDefsBroker, HttpDefs,
  CustWeb, CustCGI, Classes, SysUtils;

type
  TBrookCGIApplication = class;

  { TBrookApplication }

  TBrookApplication = class(TBrookInterfacedObject, IBrookApplication)
  private
    FApp: TBrookCGIApplication;
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

  { TBrookCGIApplication }

  TBrookCGIApplication = class(TCustomCGIApplication)
  protected
    function InitializeWebHandler: TWebHandler; override;
  end;

  { TBrookCGIRequest }

  TBrookCGIRequest = class(TCGIRequest)
  protected
    procedure DeleteTempUploadedFiles; override;
    function GetTempUploadFileName(const AName, AFileName: string;
      ASize: Int64): string; override;
    function RequestUploadDir: string; override;
    procedure InitRequestVars; override;
  end;

  { TBrookCGIResponse }

  TBrookCGIResponse = class(TCGIResponse)
  protected
    procedure CollectHeaders(AHeaders: TStrings); override;
  end;

  { TBrookCGIHandler }

  TBrookCGIHandler = class(TCGIHandler)
  protected
    function CreateRequest: TCGIRequest; override;
    function CreateResponse(AOutput: TStream): TCGIResponse; override;
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
  FApp := TBrookCGIApplication.Create(nil);
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
  if BrookSettings.RootUrl <> '' then
    FApp.ApplicationURL := BrookSettings.RootUrl;
  FApp.Run;
end;

procedure TBrookApplication.Terminate;
begin
  FApp.Terminate;
end;

{ TBrookCGIApplication }

function TBrookCGIApplication.InitializeWebHandler: TWebHandler;
begin
  Result := TBrookCGIHandler.Create(Self);
end;

{ TBrookCGIRequest }

procedure TBrookCGIRequest.DeleteTempUploadedFiles;
begin
  if BrookSettings.DeleteUploadedFiles then
    inherited;
end;

function TBrookCGIRequest.GetTempUploadFileName(
  const AName, AFileName: string; ASize: Int64): string;
begin
  if BrookSettings.KeepUploadedNames then
    Result := RequestUploadDir + AFileName
  else
    Result := inherited GetTempUploadFileName(AName, AFileName, ASize);
end;

function TBrookCGIRequest.RequestUploadDir: string;
begin
  Result := BrookSettings.DirectoryForUploads;
  if Result = '' then
    Result := GetTempDir;
  Result := IncludeTrailingPathDelimiter(Result);
end;

procedure TBrookCGIRequest.InitRequestVars;
var
  VMethod: string;
begin
{$IFDEF BROOK_DEBUG}
  try
{$ENDIF}
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
{$IFDEF BROOK_DEBUG}
  except
    on E: Exception do
    begin
      WriteLn('Content-Type: text/plain');
      WriteLn;
      WriteLn('Catastrophic error: ', E.Message);
      raise;
    end;
  end;
{$ENDIF}
end;

{ TBrookCGIResponse }

procedure TBrookCGIResponse.CollectHeaders(AHeaders: TStrings);
begin
  AHeaders.Add(BROOK_HTTP_HEADER_X_POWERED_BY + HS +
    'Brook framework and FCL-Web.');
  inherited CollectHeaders(AHeaders);
end;

{ TBrookCGIHandler }

function TBrookCGIHandler.CreateRequest: TCGIRequest;
begin
  Result := TBrookCGIRequest.CreateCGI(Self);
  if ApplicationURL = ES then
    ApplicationURL := TBrookRouter.RootUrl;
end;

function TBrookCGIHandler.CreateResponse(AOutput: TStream): TCGIResponse;
begin
  Result := TBrookCGIResponse.CreateCGI(Self, AOutput);
end;

procedure TBrookCGIHandler.HandleRequest(ARequest: TRequest; AResponse: TResponse);
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
    TBrookCGIRequest(ARequest).DeleteTempUploadedFiles;
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

procedure TBrookCGIHandler.ShowRequestException(R: TResponse; E: Exception);
begin
  BrookShowRequestException(Self, R, E);
end;

initialization
  BrookRegisterApp(TBrookApplication.Create);

end.
