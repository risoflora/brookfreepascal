(*
  Brook framework, FCL HTTP Client Broker

  Copyright (C) 2014 Silvio Clecio.

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookFCLHttpClientBroker;

{$mode objfpc}{$H+}

interface

uses
  BrookHttpClient, BrookConsts, FPHttpClient, Classes, SysUtils;

type
  TBrookFPHttpClientDef = class(TBrookHttpDef)
  private
    FHttp: TFPHttpClient;
    FContents: TStrings;
    FDocument: TMemoryStream;
    FMethod: string;
    FUrl: string;
    class function InternalRequest(AHttp: TFPHttpClient; AResponse: TStream;
      const AMethod, AUrl: string): Boolean;
  protected
    function GetClient: TObject; override;
    function GetContents: TStrings; override;
    function GetCookies: TStrings; override;
    function GetDocument: TStream; override;
    function GetHeaders: TStrings; override;
    function GetContentType: string; override;
    procedure SetContentType(AValue: string); override;
    function GetStatusCode: Integer; override;
    function GetReasonPhrase: string; override;
    function GetMethod: string; override;
    function GetUrl: string; override;
    procedure SetMethod(AValue: string); override;
    procedure SetUrl(AValue: string); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    class function GetLibrary: string; override;
    class function Get(const AUrl: string; AResponse: TStream): Boolean; override;
    class function Post(const AUrl: string; AResponse: TStream): Boolean; override;
    class function Put(const AUrl: string; AResponse: TStream): Boolean; override;
    class function Delete(const AUrl: string; AResponse: TStream): Boolean; override;
    class function Options(const AUrl: string; AResponse: TStream): Boolean; override;
    class function Head(const AUrl: string; AHeaders: TStrings): Boolean; override;
    class function PostForm(const AUrl, AFormData: string; AResponse: TStream): Boolean; override;
    class function PostForm(const AUrl: string; AFormData, AResponse: TStream): Boolean; override;
    class function PutForm(const AUrl, AFormData: string; AResponse: TStream): Boolean; override;
    class function PutForm(const AUrl: string; AFormData, AResponse: TStream): Boolean; override;
    class function PostFile(const AUrl, AFieldName, AFileName: string;
      AResponse: TStream): Boolean; override;
    class function PostFile(const AUrl, AFieldName, AFileName: string;
      AFile, AResponse: TStream): Boolean; override;
    procedure AddHeader(const AName, AValue: string); override;
    function Request: Boolean; override;
  end;

implementation

constructor TBrookFPHttpClientDef.Create;
begin
  FHttp := TFPHttpClient.Create(nil);
  FContents := TStringList.Create;
  FDocument := TMemoryStream.Create;
  FHttp.AddHeader('User-Agent', 'Brook framework and FCL-Web.');
  FMethod := 'GET';
end;

destructor TBrookFPHttpClientDef.Destroy;
begin
  FContents.Free;
  FDocument.Free;
  FHttp.Free;
  inherited Destroy;
end;

function TBrookFPHttpClientDef.GetClient: TObject;
begin
  Result := FHttp;
end;

function TBrookFPHttpClientDef.GetContents: TStrings;
begin
  FDocument.Seek(0, 0);
  FContents.LoadFromStream(FDocument);
  Result := FContents;
end;

function TBrookFPHttpClientDef.GetCookies: TStrings;
begin
  Result := FHttp.Cookies;
end;

function TBrookFPHttpClientDef.GetDocument: TStream;
begin
  Result := FDocument;
end;

function TBrookFPHttpClientDef.GetHeaders: TStrings;
begin
  Result := FHttp.ResponseHeaders;
end;

function TBrookFPHttpClientDef.GetContentType: string;
begin
  Result := FHttp.GetHeader('Content-Type');
end;

procedure TBrookFPHttpClientDef.SetContentType(AValue: string);
begin
  FHttp.AddHeader('Content-Type', AValue);
end;

function TBrookFPHttpClientDef.GetStatusCode: Integer;
begin
  Result := FHttp.ResponseStatusCode;
end;

function TBrookFPHttpClientDef.GetReasonPhrase: string;
begin
  Result := FHttp.ResponseStatusText;
end;

function TBrookFPHttpClientDef.GetMethod: string;
begin
  Result := FMethod;
end;

function TBrookFPHttpClientDef.GetUrl: string;
begin
  Result := FUrl;
end;

procedure TBrookFPHttpClientDef.SetMethod(AValue: string);
begin
  FMethod := AValue;
end;

procedure TBrookFPHttpClientDef.SetUrl(AValue: string);
begin
  FUrl := AValue;
end;

class function TBrookFPHttpClientDef.InternalRequest(AHttp: TFPHttpClient;
  AResponse: TStream; const AMethod, AUrl: string): Boolean;
begin
  AHttp.RequestHeaders.Add('Connection: Close');
  if Assigned(AResponse) then
  begin
    AHttp.HttpMethod(AMethod, AUrl, AResponse, []);
    Result := AHttp.ResponseStatusCode = 200;
  end
  else
  begin
    AResponse := TMemoryStream.Create;
    try
      AHttp.HttpMethod(AMethod, AUrl, AResponse, []);
      Result := AHttp.ResponseStatusCode = 200;
    finally
      FreeAndNil(AResponse);
    end;
  end;
end;

class function TBrookFPHttpClientDef.GetLibrary: string;
begin
  Result := 'FCLWeb';
end;

class function TBrookFPHttpClientDef.Get(const AUrl: string;
  AResponse: TStream): Boolean;
var
  VHttp: TFPHttpClient;
begin
  VHttp := TFPHttpClient.Create(nil);
  try
    Result := InternalRequest(VHttp, AResponse, 'GET', AUrl);
  finally
    VHttp.Free;
  end;
end;

class function TBrookFPHttpClientDef.Post(const AUrl: string;
  AResponse: TStream): Boolean;
var
  VHttp: TFPHttpClient;
begin
  VHttp := TFPHttpClient.Create(nil);
  try
    Result := InternalRequest(VHttp, AResponse, 'POST', AUrl);
  finally
    VHttp.Free;
  end;
end;

class function TBrookFPHttpClientDef.Put(const AUrl: string;
  AResponse: TStream): Boolean;
var
  VHttp: TFPHttpClient;
begin
  VHttp := TFPHttpClient.Create(nil);
  try
    Result := InternalRequest(VHttp, AResponse, 'PUT', AUrl);
  finally
    VHttp.Free;
  end;
end;

class function TBrookFPHttpClientDef.Delete(const AUrl: string;
  AResponse: TStream): Boolean;
var
  VHttp: TFPHttpClient;
begin
  VHttp := TFPHttpClient.Create(nil);
  try
    Result := InternalRequest(VHttp, AResponse, 'DELETE', AUrl);
  finally
    VHttp.Free;
  end;
end;

class function TBrookFPHttpClientDef.Options(const AUrl: string;
  AResponse: TStream): Boolean;
var
  VHttp: TFPHttpClient;
begin
  VHttp := TFPHttpClient.Create(nil);
  try
    Result := InternalRequest(VHttp, AResponse, 'OPTIONS', AUrl);
  finally
    VHttp.Free;
  end;
end;

class function TBrookFPHttpClientDef.Head(const AUrl: string;
  AHeaders: TStrings): Boolean;
var
  VHttp: TFPHttpClient;
begin
  VHttp := TFPHttpClient.Create(nil);
  try
    VHttp.RequestHeaders.Add('Connection: Close');
    VHttp.HttpMethod('HEAD', AUrl, nil, []);
    AHeaders.Assign(VHttp.ResponseHeaders);
    Result := VHttp.ResponseStatusCode = 200;
  finally
    VHttp.Free;
  end;
end;

class function TBrookFPHttpClientDef.PostForm(const AUrl: string; AFormData,
  AResponse: TStream): Boolean;
var
  VHttp: TFPHttpClient;
begin
  VHttp := TFPHttpClient.Create(nil);
  try
    VHttp.RequestBody := AFormData;
    VHttp.AddHeader('Content-Type', 'application/x-www-form-urlencoded');
    Result := InternalRequest(VHttp, AResponse, 'POST', AUrl);
  finally
    VHttp.Free;
  end;
end;

class function TBrookFPHttpClientDef.PostForm(const AUrl, AFormData: string;
  AResponse: TStream): Boolean;
var
  VFormData: TStringStream;
begin
  VFormData := TStringStream.Create(AFormData);
  try
    Result := PostForm(AUrl, VFormData, AResponse);
  finally
    VFormData.Free;
    VFormData := nil;
  end;
end;

class function TBrookFPHttpClientDef.PutForm(const AUrl: string; AFormData,
  AResponse: TStream): Boolean;
var
  VHttp: TFPHttpClient;
begin
  VHttp := TFPHttpClient.Create(nil);
  try
    VHttp.RequestBody := AFormData;
    VHttp.AddHeader('Content-Type', 'application/x-www-form-urlencoded');
    Result := InternalRequest(VHttp, AResponse, 'PUT', AUrl);
  finally
    VHttp.Free;
  end;
end;

class function TBrookFPHttpClientDef.PutForm(const AUrl, AFormData: string;
  AResponse: TStream): Boolean;
var
  VFormData: TStringStream;
begin
  VFormData := TStringStream.Create(AFormData);
  try
    Result := PutForm(AUrl, VFormData, AResponse);
  finally
    VFormData.Free;
    VFormData := nil;
  end;
end;

class function TBrookFPHttpClientDef.PostFile(const AUrl, AFieldName,
  AFileName: string; AFile, AResponse: TStream): Boolean;
var
  S, VSep: string;
  VData: TMemoryStream;
  VHttp: TFPHttpClient;
begin
  VData := TMemoryStream.Create;
  VHttp := TFPHttpClient.Create(nil);
  try
    VSep := Format('%.8x_multipart_boundary', [Random($FFFFFF)]);
    S := '--' + VSep + CRLF;
    S := S + Format('Content-Disposition: form-data; name="%s"; filename="%s"' +
      CRLF, [AFieldName, ExtractFileName(AFileName)]);
    S := S + 'Content-Type: application/octet-string' + CRLF + CRLF;
    VData.Write(Pointer(S)^, Length(S));
    VData.CopyFrom(AFile, 0);
    S := CRLF + '--' + VSep + '--' + CRLF;
    VData.Write(Pointer(S)^, Length(S));
    VHttp.AddHeader('Content-Type', 'multipart/form-data; boundary=' + VSep);
    VData.Seek(0, 0);
    VHttp.RequestBody := VData;
    Result := InternalRequest(VHttp, AResponse, 'POST', AUrl);
  finally
    VData.Free;
    VHttp.RequestBody := nil;
    VHttp.Free;
  end;
end;

class function TBrookFPHttpClientDef.PostFile(const AUrl, AFieldName,
  AFileName: string; AResponse: TStream): Boolean;
var
  VFile: TFileStream;
begin
  VFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := PostFile(AUrl, AFieldName, AFileName, VFile, AResponse);
  finally
    VFile.Free;
  end;
end;

procedure TBrookFPHttpClientDef.AddHeader(const AName, AValue: string);
begin
  FHttp.AddHeader(AName, AValue);
end;

function TBrookFPHttpClientDef.Request: Boolean;
begin
  try
    if FHttp.ResponseHeaders.Count > 0 then
      FHttp.RequestHeaders.AddStrings(FHttp.ResponseHeaders);
    if FDocument.Size > 0 then
    begin
      FHttp.RequestBody := TMemoryStream.Create;
      FHttp.RequestBody.CopyFrom(FDocument, 0);
      FHttp.RequestBody.Seek(0, 0);
      FDocument.Clear;
    end;
    FHttp.RequestHeaders.Add('Connection: Close');
    FHttp.HttpMethod(FMethod, FUrl, FDocument, []);
    Result := FHttp.ResponseStatusCode = 200;
  finally
    FHttp.RequestBody.Free;
    FHttp.RequestBody := nil;
  end;
end;

initialization
  TBrookFPHttpClientDef.Register;

end.

