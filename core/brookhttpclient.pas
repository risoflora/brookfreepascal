(*
  Brook framework, HTTP Client Classes

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookHttpClient;

{$i brook.inc}

interface

uses
  BrookClasses, BrookException, BrookMessages, BrookConsts, BrookHttpConsts,
  Classes, SysUtils, FGL;

type
  { Handles exceptions for @link(TBrookHttpDef). }
  EBrookHttpDef = class(EBrook);

  { Handles exceptions for @link(TBrookHttpDefs). }
  EBrookHttpDefs = class(EBrook);

  { Handles exceptions for @link(EBrookHttpClient). }
  EBrookHttpClient = class(EBrook);

  { Is a metaclass for @link(TBrookHttpDef) class. }
  TBrookHttpDefClass = class of TBrookHttpDef;

  { Is a metaclass for @link(TBrookHttpDefs) class. }
  TBrookHttpDefsClass = class of TBrookHttpDefs;

  { Is a metaclass for @link(TBrookHttpClient) class. }
  TBrookHttpClientClass = class of TBrookHttpClient;

  { Information returned after a request. }
  TBrookHttpResult = record
    StatusCode: Integer;
    ReasonPhrase, Header, Content: string;
  end;

  { Offers general abstract features for HTTP handling. }
  TBrookHttpDef = class(TBrookObject)
  protected
    procedure SetContentType(AValue: string); virtual; abstract;
    function GetContentType: string; virtual; abstract;
    function GetClient: TObject; virtual; abstract;
    function GetContents: TStrings; virtual; abstract;
    function GetCookies: TStrings; virtual; abstract;
    function GetDocument: TStream; virtual; abstract;
    function GetHeaders: TStrings; virtual; abstract;
    function GetReasonPhrase: string; virtual; abstract;
    function GetStatusCode: Integer; virtual; abstract;
    function GetMethod: string; virtual; abstract;
    function GetUrl: string; virtual; abstract;
    procedure SetMethod(AValue: string); virtual; abstract;
    procedure SetUrl(AValue: string); virtual; abstract;
  public
    { Creates an instance of a @link(TBrookHttpDef) class. }
    constructor Create; virtual; abstract;
    { Register the broker class. }
    class procedure Register;
    { Unregister the broker class. }
    class procedure Unregister;
    { Get the broker library name, for example: FCLWeb, Synapse, LNet, Indy etc. }
    class function GetLibrary: string; virtual; abstract;
    { Adds header, replacing an existing one if it exists. }
    procedure AddHeader(const AName, AValue: string); virtual; abstract;
    { Sends request to server. }
    function Request: Boolean; virtual; abstract;
    { Sends request by a GET HTTP request method. }
    class function Get(const AUrl: string;
      AResponse: TStream): Boolean; virtual; abstract;
    { Sends request by a POST HTTP request method. }
    class function Post(const AUrl: string;
      AResponse: TStream): Boolean; virtual; abstract;
    { Sends request by a PUT HTTP request method. }
    class function Put(const AUrl: string;
      AResponse: TStream): Boolean; virtual; abstract;
    { Sends request by a DELETE HTTP request method. }
    class function Delete(const AUrl: string;
      AResponse: TStream): Boolean; virtual; abstract;
    { Sends request by an OPTIONS HTTP request method. }
    class function Options(const AUrl: string;
      AResponse: TStream): Boolean; virtual; abstract;
    { Sends request by a HEAD HTTP request method. }
    class function Head(const AUrl: string;
      AHeaders: TStrings): Boolean; virtual; abstract;
    { Sends request by a POST HTTP request method, passing a form-data as
      parameter. }
    class function PostForm(const AUrl: string;
      AFormData, AResponse: TStream): Boolean; virtual; abstract;
    { Sends request by a POST HTTP request method, passing a form-data as
      parameter. }
    class function PostForm(const AUrl, AFormData: string;
      AResponse: TStream): Boolean; virtual; abstract;
    { Sends request by a PUT HTTP request method, passing a form-data as
      parameter. }
    class function PutForm(const AUrl: string;
      AFormData, AResponse: TStream): Boolean; virtual; abstract;
    { Sends request by a PUT HTTP request method, passing a form-data as
      parameter. }
    class function PutForm(const AUrl, AFormData: string;
      AResponse: TStream): Boolean; virtual; abstract;
    { Sends request by a POST HTTP request method, passing a file as
      parameter. }
    class function PostFile(const AUrl, AFieldName, AFileName: string;
      AFile, AResponse: TStream): Boolean; virtual; abstract;
    { Sends request by a POST HTTP request method, passing a file as
      parameter. }
    class function PostFile(const AUrl, AFieldName, AFileName: string;
      AResponse: TStream): Boolean; virtual; abstract;
    { Content type of sending data. }
    property ContentType: string read GetContentType write SetContentType;
    { Strings received from the request. }
    property Contents: TStrings read GetContents;
    { Set cookies to be sent and/or received from the server. }
    property Cookies: TStrings read GetCookies;
    { Document received from the request. }
    property Document: TStream read GetDocument;
    { Request headers. }
    property Headers: TStrings read GetHeaders;
    { Result code after successful request. }
    property StatusCode: Integer read GetStatusCode;
    { Result text after successful request. }
    property ReasonPhrase: string read GetReasonPhrase;
    { Method for requests. }
    property Method: string read GetMethod write SetMethod;
    { URL that request is driven to. }
    property Url: string read GetUrl write SetUrl;
    { Is the instance of the HTTP client broker. }
    property Client: TObject read GetClient;
  end;

  { Registers HTTP definitions. }
  TBrookHttpDefs = class(specialize TFPGList<TBrookHttpDefClass>)
  private
    class var _List: TBrookHttpDefs;
  public
    { Registers the service provided by this class. }
    class function Service: TBrookHttpDefs;
    { Finds a database item by its library name. }
    function Find(const ALibrary: string): TBrookHttpDefClass;
    { Returns a database item by its library name. }
    function ItemByLibrary(const ALibrary: string): TBrookHttpDefClass;
  end;

  { Client to perform HTTP requests. }
  TBrookHttpClient = class(TBrookObject)
  private
    class var _Library: string;
  public
    { Creates an instance of a @link(TBrookHttpClient) class. }
    constructor Create(const ALibrary: string);
    { Specifies the library to be used by this class. }
    class procedure SetLibrary(const ALibrary: string);
    { Prepares an instance of @code(TBrookHttpDef). }
    class procedure Prepare(out AHttp: TBrookHttpDef);
    { Sends request by a GET HTTP request method. }
    class function Get(const AUrl: string; AResponse: TStream): Boolean;
    { Sends request by a POST HTTP request method. }
    class function Post(const AUrl: string; AResponse: TStream): Boolean;
    { Sends request by a PUT HTTP request method. }
    class function Put(const AUrl: string; AResponse: TStream): Boolean;
    { Sends request by a DELETE HTTP request method. }
    class function Delete(const AUrl: string; AResponse: TStream): Boolean;
    { Sends request by an OPTIONS HTTP request method. }
    class function Options(const AUrl: string; AResponse: TStream): Boolean;
    { Sends request by a HEAD HTTP request method. }
    class function Head(const AUrl: string; AHeaders: TStrings): Boolean;
    { Sends request by a POST HTTP request method, passing a form-data as
      parameter. }
    class function PostForm(const AUrl: string; AFormData,
      AResponse: TStream): Boolean;
    { Sends request by a POST HTTP request method, passing a form-data as
      parameter. }
    class function PostForm(const AUrl, AFormData: string;
      AResponse: TStream): Boolean;
    { Sends request by a PUT HTTP request method, passing a form-data as
      parameter. }
    class function PutForm(const AUrl: string; AFormData,
      AResponse: TStream): Boolean;
    { Sends request by a PUT HTTP request method, passing a form-data as
      parameter. }
    class function PutForm(const AUrl, AFormData: string;
      AResponse: TStream): Boolean;
    { Sends request by a POST HTTP request method, passing a file as
      parameter. }
    class function PostFile(const AUrl, AFieldName, AFileName: string;
      AFile, AResponse: TStream): Boolean;
    { Sends request by a POST HTTP request method, passing a file as
      parameter. }
    class function PostFile(const AUrl, AFieldName, AFileName: string;
      AResponse: TStream): Boolean;
    { Performs the request, passing a @code(TBrookHttpDef) as parameter. }
    function Request(AHttp: TBrookHttpDef): TBrookHttpResult;
    { Performs the request, passing the method and URL as parameter. }
    function Request(const AMethod, AUrl: string): TBrookHttpResult;
    { Performs the request, passing URL as parameter. }
    function Request(const AUrl: string): TBrookHttpResult;
  end;

implementation

{ TBrookHttpDef }

{$IFNDEF VER3_0}
 {$PUSH}{$WARN 6058 OFF}
{$ENDIF}

class procedure TBrookHttpDef.Register;
begin
  TBrookHttpDefs.Service.Add(Self);
  BROOK_HTTP_CLIENT_DEFAULT_LIBRARY := GetLibrary;
end;

{$IFNDEF VER3_0}
 {$POP}
{$ENDIF}

class procedure TBrookHttpDef.Unregister;
begin
  TBrookHttpDefs.Service.Remove(Self);
end;

{ TBrookHttpDefs }

class function TBrookHttpDefs.Service: TBrookHttpDefs;
begin
  if not Assigned(TBrookHttpDefs._List) then
    TBrookHttpDefs._List := TBrookHttpDefs.Create;
  Result := TBrookHttpDefs._List;
end;

function TBrookHttpDefs.Find(const ALibrary: string): TBrookHttpDefClass;
begin
  for Result in Self do
    if SameText(Result.GetLibrary, ALibrary) then
      Exit;
  Result := nil;
end;

function TBrookHttpDefs.ItemByLibrary(
  const ALibrary: string): TBrookHttpDefClass;
begin
  if ALibrary = ES then
    raise EBrookHttpDefs.Create(Self, SBrookEmptyLibraryNameError);
  Result := Find(ALibrary);
  if not Assigned(Result) then
    raise EBrookHttpDefs.CreateFmt(Self, SBrookItemNotFoundError, [ALibrary]);
end;

{ TBrookHttpClient }

constructor TBrookHttpClient.Create(const ALibrary: string);
begin
  _Library := ALibrary;
end;

class procedure TBrookHttpClient.SetLibrary(const ALibrary: string);
begin
  _Library := ALibrary;
end;

class procedure TBrookHttpClient.Prepare(out AHttp: TBrookHttpDef);
begin
  AHttp := TBrookHttpDefs.Service.ItemByLibrary(_Library).Create;
end;

class function TBrookHttpClient.Get(const AUrl: string;
  AResponse: TStream): Boolean;
var
  VHttp: TBrookHttpDef = nil;
begin
  Prepare(VHttp);
  try
    Result := VHttp.Get(AUrl, AResponse);
  finally
    VHttp.Free;
  end;
end;

class function TBrookHttpClient.Post(const AUrl: string;
  AResponse: TStream): Boolean;
var
  VHttp: TBrookHttpDef = nil;
begin
  Prepare(VHttp);
  try
    Result := VHttp.Post(AUrl, AResponse);
  finally
    VHttp.Free;
  end;
end;

class function TBrookHttpClient.Put(const AUrl: string;
  AResponse: TStream): Boolean;
var
  VHttp: TBrookHttpDef = nil;
begin
  Prepare(VHttp);
  try
    Result := VHttp.Put(AUrl, AResponse);
  finally
    VHttp.Free;
  end;
end;

class function TBrookHttpClient.Delete(const AUrl: string;
  AResponse: TStream): Boolean;
var
  VHttp: TBrookHttpDef = nil;
begin
  Prepare(VHttp);
  try
    Result := VHttp.Delete(AUrl, AResponse);
  finally
    VHttp.Free;
  end;
end;

class function TBrookHttpClient.Options(const AUrl: string;
  AResponse: TStream): Boolean;
var
  VHttp: TBrookHttpDef = nil;
begin
  Prepare(VHttp);
  try
    Result := VHttp.Options(AUrl, AResponse);
  finally
    VHttp.Free;
  end;
end;

class function TBrookHttpClient.Head(const AUrl: string;
  AHeaders: TStrings): Boolean;
var
  VHttp: TBrookHttpDef = nil;
begin
  Prepare(VHttp);
  try
    Result := VHttp.Head(AUrl, AHeaders);
  finally
    VHttp.Free;
  end;
end;

class function TBrookHttpClient.PostForm(const AUrl: string; AFormData,
  AResponse: TStream): Boolean;
var
  VHttp: TBrookHttpDef = nil;
begin
  Prepare(VHttp);
  try
    Result := VHttp.PostForm(AUrl, AFormData, AResponse);
  finally
    VHttp.Free;
  end;
end;

class function TBrookHttpClient.PostForm(const AUrl, AFormData: string;
  AResponse: TStream): Boolean;
var
  VHttp: TBrookHttpDef = nil;
begin
  Prepare(VHttp);
  try
    Result := VHttp.PostForm(AUrl, AFormData, AResponse);
  finally
    VHttp.Free;
  end;
end;

class function TBrookHttpClient.PutForm(const AUrl: string; AFormData,
  AResponse: TStream): Boolean;
var
  VHttp: TBrookHttpDef = nil;
begin
  Prepare(VHttp);
  try
    Result := VHttp.PutForm(AUrl, AFormData, AResponse);
  finally
    VHttp.Free;
  end;
end;

class function TBrookHttpClient.PutForm(const AUrl, AFormData: string;
  AResponse: TStream): Boolean;
var
  VHttp: TBrookHttpDef = nil;
begin
  Prepare(VHttp);
  try
    Result := VHttp.PutForm(AUrl, AFormData, AResponse);
  finally
    VHttp.Free;
  end;
end;

class function TBrookHttpClient.PostFile(const AUrl, AFieldName,
  AFileName: string; AFile, AResponse: TStream): Boolean;
var
  VHttp: TBrookHttpDef = nil;
begin
  Prepare(VHttp);
  try
    Result := VHttp.PostFile(AUrl, AFieldName, AFileName, AFile, AResponse);
  finally
    VHttp.Free;
  end;
end;

class function TBrookHttpClient.PostFile(const AUrl, AFieldName,
  AFileName: string; AResponse: TStream): Boolean;
var
  VHttp: TBrookHttpDef = nil;
begin
  Prepare(VHttp);
  try
    Result := VHttp.PostFile(AUrl, AFieldName, AFileName, AResponse);
  finally
    VHttp.Free;
  end;
end;

function TBrookHttpClient.Request(AHttp: TBrookHttpDef): TBrookHttpResult;
begin
  AHttp.Request;
  Result.Content := AHttp.Contents.Text;
  Result.Header := AHttp.Headers.Text;
  Result.StatusCode := AHttp.StatusCode;
  Result.ReasonPhrase := AHttp.ReasonPhrase;
end;

function TBrookHttpClient.Request(const AMethod, AUrl: string): TBrookHttpResult;
var
  VHttp: TBrookHttpDef = nil;
begin
  Prepare(VHttp);
  try
    VHttp.Method := AMethod;
    VHttp.Url := AUrl;
    Result := Request(VHttp);
  finally
    VHttp.Free;
  end;
end;

function TBrookHttpClient.Request(const AUrl: string): TBrookHttpResult;
begin
  Result := Request(BROOK_HTTP_REQUEST_METHOD_GET, AUrl);
end;

finalization
  FreeAndNil(TBrookHttpDefs._List);

end.
