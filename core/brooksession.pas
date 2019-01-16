(*
  Brook framework, Session Class

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookSession;

{$i brook.inc}

interface

uses
  BrookClasses, BrookHttpDefs, BrookUtils, BrookException, BrookConsts, Classes,
  SysUtils, HTTPDefs, DateUtils;

type
  { Handles exceptions for @link(TBrookSession). }
  EBrookSession = class(EBrook);

  { Is a metaclass for @link(TBrookSession) class. }
  TBrookSessionClass = class of TBrookSession;

  { Is a type to the session start event. }
  TBrookSessionStartEvent = procedure(ASender: TObject;
    ARequest: TBrookRequest; var AHandled: Boolean) of object;
  { Defines a pointer to the session start event.}
  PBrookSessionStartEvent = ^TBrookSessionStartEvent;

  { Is a type to the session finish event. }
  TBrookSessionFinishEvent = procedure(ASender: TObject;
    AResponse: TBrookResponse; var AHandled: Boolean) of object;
  { Defines a pointer to the session finish event.}
  PBrookSessionFinishEvent = ^TBrookSessionFinishEvent;

  { Is a type to the session expire event. }
  TBrookSessionExpireEvent = procedure(ASender: TObject; ARequest: TBrookRequest;
    AResponse: TBrookResponse; var AHandled: Boolean) of object;
  { Defines a pointer to the session expire event.}
  PBrookSessionExpireEvent = ^TBrookSessionExpireEvent;

  { Defines features to the session handling. }
  TBrookSession = class(TBrookComponent)
  private
    FAfterExpire: TBrookSessionExpireEvent;
    FAfterFinish: TBrookSessionFinishEvent;
    FAfterStart: TBrookSessionStartEvent;
    FBeforeExpire: TBrookSessionExpireEvent;
    FBeforeFinish: TBrookSessionFinishEvent;
    FBeforeStart: TBrookSessionStartEvent;
    FCookieDomain: string;
    FCookieExpires: TDateTime;
    FCookieName: string;
    FCookiePath: string;
    FCookieSecure: Boolean;
    FFields: TStrings;
    FDirectory: string;
    FFileName: TFileName;
    FFilePrefix: ShortString;
    FHttpOnly: Boolean;
    FIgnoredFields: TStrings;
    FSID: string;
    FStarted: Boolean;
    FTimeout: Integer;
    function GetField(const AName: string): string;
    procedure SetField(const AName: string; const AValue: string);
    procedure SetFields(AValue: TStrings);
    procedure SetIgnoredFields(AValue: TStrings);
  protected
    function IsStarted: Boolean;
    procedure MakeSID(ARequest: TBrookRequest); virtual;
    procedure SetFileName; virtual;
    procedure SetCookie(AResponse: TBrookResponse); virtual;
    procedure Load; virtual;
    procedure Save; virtual;
  public
    { Creates an instance of a @link(TBrookSession) class. }
    constructor Create(AOwner: TComponent); override;
    { Frees an instance of @link(TBrookSession) class. }
    destructor Destroy; override;
    { Get an object with the fields coming from session. }
    procedure GetFields(AObject: TObject);
    { Returns @code(True) if the session has expired.}
    function IsExpired: Boolean; virtual;
    { Returns @code(True) if the session fieds is empty.}
    function IsEmpty: Boolean; virtual;
    { Creates an ID for the session. }
    function GenerateID: string; virtual;
    { Starts the session. }
    procedure Start(ARequest: TBrookRequest); virtual;
    { Terminates the session. }
    procedure Finish(AResponse: TBrookResponse); virtual;
    { Expires the session. }
    procedure Expire(ARequest: TBrookRequest;
      AResponse: TBrookResponse); virtual;
    { Checks if a name exists in fields. }
    function Exists(const AName: string): Boolean;
    { Set the session cookie name. }
    property CookieName: string read FCookieName write FCookieName;
    { Set the session cookie domain. }
    property CookieDomain: string read FCookieDomain write FCookieDomain;
    { Set the session cookie path. }
    property CookiePath: string read FCookiePath write FCookiePath;
    { Set the session cookie secure. }
    property CookieSecure: Boolean read FCookieSecure write FCookieSecure;
    { Set the session cookie expiration. }
    property CookieExpires: TDateTime read FCookieExpires write FCookieExpires;
    { Handles the session fields. }
    property Field[const AName: string]: string read GetField write SetField;
    { The session fields. }
    property Fields: TStrings read FFields write SetFields;
    { The ignored fields by the session. }
    property IgnoredFields: TStrings read FIgnoredFields write SetIgnoredFields;
    { Set the name of session directory. }
    property Directory: string read FDirectory write FDirectory;
    { Returns @code(True) if the session has expired.}
    property Expired: Boolean read IsExpired;
    { Returns @code(True) if the session fieds is empty.}
    property Empty: Boolean read IsEmpty;
    { Get or set the session ID. }
    property SID: string read FSID write FSID;
    { Checks if the session has started. }
    property Started: Boolean read IsStarted;
    { The session file name. }
    property FileName: TFileName read FFileName write FFileName;
    { The session file prefix. }
    property FilePrefix: ShortString read FFilePrefix write FFilePrefix;
    { The remaining seconds for the session finish. }
    property Timeout: Integer read FTimeout write FTimeout
      default BROOK_SESS_DEFAULT_TIMEOUT;
    { Informs if the session cookie is accessible only by HTTP requests,
      if @code(True), the JavaScript access is not allowed. }
    property HttpOnly: Boolean read FHttpOnly write FHttpOnly;
    { Is triggered after session start. }
    property AfterStart: TBrookSessionStartEvent read FAfterStart
      write FAfterStart;
    { Is triggered before session start. }
    property BeforeStart: TBrookSessionStartEvent read FBeforeStart
      write FBeforeStart;
    { Is triggered after session finish. }
    property AfterFinish: TBrookSessionFinishEvent read FAfterFinish
      write FAfterFinish;
    { Is triggered before session finish. }
    property BeforeFinish: TBrookSessionFinishEvent read FBeforeFinish
      write FBeforeFinish;
    { Is triggered after session expire. }
    property AfterExpire: TBrookSessionExpireEvent read FAfterExpire
      write FAfterExpire;
    { Is triggered before session expire. }
    property BeforeExpire: TBrookSessionExpireEvent read FBeforeExpire
      write FBeforeExpire;
  end;

  { Defines features to the section mapping field values to object. }
  generic TBrookGSession<T> = class(TBrookSession)
  private
    FEntity: T;
  protected
    function CreateEntity: T; virtual;
    procedure FreeEntity; virtual;
    procedure FillEntity; virtual;
    procedure ReadEntity; virtual;
    procedure Load; override;
    procedure Save; override;
  public
    { Creates an instance of a @link(TBrookGSession) class. }
    constructor Create(AOwner: TComponent); override;
    { Frees an instance of @link(TBrookGSession) class. }
    destructor Destroy; override;
    { Maps field values to object. }
    property Entity: T read FEntity write FEntity;
  end;

implementation

{ TBrookSession }

constructor TBrookSession.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFields := TStringList.Create;
  FIgnoredFields := TStringList.Create;
  FCookieName := BROOK_SESS_ID;
  FCookieExpires := -1;
  FFilePrefix := BROOK_SESS_PREFIX;
  FDirectory := GetTempDir(False);
  if FDirectory = ES then
    FDirectory := ExtractFilePath(ParamStr(0));
  FTimeout := BROOK_SESS_DEFAULT_TIMEOUT;
  FHttpOnly := True;
end;

destructor TBrookSession.Destroy;
begin
  FFields.Free;
  FIgnoredFields.Free;
  inherited Destroy;
end;

procedure TBrookSession.GetFields(AObject: TObject);
begin
  BrookSafeStringsToObject(AObject, FFields, FIgnoredFields);
end;

function TBrookSession.IsExpired: Boolean;
begin
  Result := FTimeout <> 0;
  if not Result then
    Exit;
  if FileExists(FFileName) then
  begin
    if FTimeout > 0 then
      Result := IncSecond(BrookFileDate(FFileName), FTimeout) < Now
    else
      Result := False;
  end
  else
    Result := True;
end;

function TBrookSession.IsEmpty: Boolean;
begin
  Result := FFields.Count < 1;
end;

{$PUSH}{$WARN 5093 OFF}

function TBrookSession.GenerateID: string;
var
  VGuid: TGuid;
begin
  CreateGUID(VGuid);
  SetLength(Result, 32);
  StrLFmt(PChar(Result), 32, BROOK_UUID_MASK, [VGuid.D1, VGuid.D2, VGuid.D3,
    VGuid.D4[0], VGuid.D4[1], VGuid.D4[2], VGuid.D4[3], VGuid.D4[4],
    VGuid.D4[5], VGuid.D4[6], VGuid.D4[7]]);
end;

{$POP}

procedure TBrookSession.SetFields(AValue: TStrings);
begin
  if Assigned(AValue) then
    FFields.Assign(AValue);
end;

function TBrookSession.GetField(const AName: string): string;
begin
  Result := FFields.Values[AName];
end;

procedure TBrookSession.SetField(const AName: string; const AValue: string);
begin
  FFields.Values[AName] := AValue;
end;

procedure TBrookSession.SetIgnoredFields(AValue: TStrings);
begin
  if Assigned(AValue) then
    FIgnoredFields.Assign(AValue);
end;

function TBrookSession.IsStarted: Boolean;
begin
  Result := FStarted;
end;

procedure TBrookSession.MakeSID(ARequest: TBrookRequest);
begin
  if FSID = ES then
    FSID := ARequest.CookieFields.Values[FCookieName];
  if FSID = ES then
    FSID := GenerateID;
end;

procedure TBrookSession.SetFileName;
begin
  FFileName := IncludeTrailingPathDelimiter(FDirectory) + FFilePrefix + FSID;
end;

procedure TBrookSession.SetCookie(AResponse: TBrookResponse);
var
  VCookie: TCookie;
begin
  VCookie := AResponse.Cookies.FindCookie(FCookieName);
  if not Assigned(VCookie) then
  begin
    VCookie := AResponse.Cookies.Add;
    VCookie.Name := FCookieName;
    VCookie.Expires := FCookieExpires;
    VCookie.Domain := FCookieDomain;
    VCookie.Path := FCookiePath;
    VCookie.Secure := FCookieSecure;
    VCookie.HttpOnly := FHttpOnly;
  end;
  VCookie.Value := SID;
end;

procedure TBrookSession.Load;
var
  I: Integer;
  N, V: string;
  VFields: TStrings;
begin
  if IsExpired then
    Exit;
  if FileExists(FFileName) then
    if FIgnoredFields.Count > 0 then
    begin
      VFields := TStringList.Create;
      try
        VFields.LoadFromFile(FFileName);
        for I := 0 to Pred(VFields.Count) do
        begin
          VFields.GetNameValue(I, N, V);
          if FIgnoredFields.IndexOf(N) > -1 then
            FFields.Values[N] := ES
          else
            FFields.Values[N] := V;
        end;
      finally
        VFields.Free;
      end;
    end
    else
      FFields.LoadFromFile(FFileName);
end;

procedure TBrookSession.Save;
var
  I: Integer;
  N, V: string;
  VFields: TStrings;
begin
  if FFileName <> ES then
    if FIgnoredFields.Count > 0 then
    begin
      VFields := TStringList.Create;
      try
        for I := 0 to Pred(FFields.Count) do
        begin
          FFields.GetNameValue(I, N, V);
          if FIgnoredFields.IndexOf(N) > -1 then
            VFields.Add(N + EQ)
          else
            VFields.Add(N + EQ + V);
        end;
        VFields.SaveToFile(FFileName);
      finally
        VFields.Free;
      end;
    end
    else
      FFields.SaveToFile(FFileName);
end;

procedure TBrookSession.Start(ARequest: TBrookRequest);
var
  VHandled: Boolean = False;
begin
  try
    if Assigned(FBeforeStart) then
      FBeforeStart(Self, ARequest, VHandled);
    if FStarted or VHandled then
      Exit;
    MakeSID(ARequest);
    SetFileName;
    FStarted := True;
    Load;
  finally
    if Assigned(FAfterStart) then
      FAfterStart(Self, ARequest, VHandled);
  end;
end;

procedure TBrookSession.Finish(AResponse: TBrookResponse);
var
  VHandled: Boolean = False;
begin
  try
    if Assigned(FBeforeFinish) then
      FBeforeFinish(Self, AResponse, VHandled);
    if (not FStarted) or VHandled then
      Exit;
    SetCookie(AResponse);
    Save;
    FStarted := False;
  finally
    if Assigned(FAfterFinish) then
      FAfterFinish(Self, AResponse, VHandled);
  end;
end;

procedure TBrookSession.Expire(ARequest: TBrookRequest;
  AResponse: TBrookResponse);
var
  VCookie: TCookie;
  VHandled: Boolean = False;
begin
  try
    if Assigned(FBeforeExpire) then
      FBeforeExpire(Self, ARequest, AResponse, VHandled);
    if IsExpired or (not FStarted) or VHandled then
      Exit;
    FSID := ARequest.CookieFields.Values[FCookieName];
    if FSID = ES then
      Exit;
    SetFileName;
    DeleteFile(FFileName);
    VCookie := AResponse.Cookies.Add;
    VCookie.Name := FCookieName;
    VCookie.Expire;
    FFields.Clear;
  finally
    if Assigned(FAfterExpire) then
      FAfterExpire(Self, ARequest, AResponse, VHandled);
  end;
end;

function TBrookSession.Exists(const AName: string): Boolean;
begin
  Result := FFields.IndexOfName(AName) > -1;
end;

{ TBrookGSession }

constructor TBrookGSession.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEntity := CreateEntity;
end;

destructor TBrookGSession.Destroy;
begin
  FreeEntity;
  inherited Destroy;
end;

function TBrookGSession.CreateEntity: T;
begin
  Result := T.Create;
end;

procedure TBrookGSession.FreeEntity;
begin
  FreeAndNil(FEntity);
end;

procedure TBrookGSession.FillEntity;
begin
  BrookStringsToObject(FEntity, Fields, IgnoredFields);
end;

procedure TBrookGSession.ReadEntity;
begin
  Fields.Clear;
  BrookObjectToStrings(FEntity, Fields, IgnoredFields);
end;

procedure TBrookGSession.Load;
begin
  inherited Load;
  FillEntity;
end;

procedure TBrookGSession.Save;
begin
  ReadEntity;
  inherited Save;
end;

end.
