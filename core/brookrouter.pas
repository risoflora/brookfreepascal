(*
  Brook framework, Router Classes

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookRouter;

{$i brook.inc}

interface

uses
  BrookClasses, BrookHttpDefs, BrookException, BrookAction, BrookUtils,
  BrookConsts, BrookMessages, BrookHTTPConsts, HTTPDefs, Classes, SysUtils,
  StrUtils;

type
  { Handles exceptions for @link(TBrookRoutes). }
  EBrookRoutes = class(EBrook);

  { Handles exceptions for @link(TBrookRouter). }
  EBrookRouter = class(EBrook);

  { Is a metaclass for @link(TBrookRoutes) class. }
  TBrookRoutesClass = class of TBrookRoutes;

  { Is a metaclass for @link(TBrookRouter) class. }
  TBrookRouterClass = class of TBrookRouter;

  { Defines a route item. }
  TBrookRoute = record
    { Specifies the class of the action to be called. }
    ActionClass: TBrookActionClass;
    { Checks if the action is default. }
    Default: Boolean;
    { Specifies a HTTP request method of the action to be called. }
    Method: TBrookRequestMethod;
    { Specifies the patter of the action to be called. }
    Pattern: string;
  end;
  { Defines a pointer to the route item.}
  PBrookRoute = ^TBrookRoute;

  { Is a type to @code(*MatchPattern) event. }
  TBrookMatchPatternEvent = function(ASender: TObject;
    APattern, APathInfo: string; out ARedirect: Boolean;
    out ANames, AValues: TBrookArrayOfString;
    var AHandled: Boolean): Boolean of object;
  { Defines a pointer to the match pattern event.}
  PBrookMatchPatternEvent = ^TBrookMatchPatternEvent;

  { Is a type to @code(*Route) event. }
  TBrookRouteEvent = procedure(ASender: TObject; ARequest: TBrookRequest;
    AResponse: TBrookResponse; var AHandled: Boolean) of object;
  { Defines a pointer to the route event.}
  PBrookRouteEvent = ^TBrookRouteEvent;

  { Is a type to @code(*ExecuteAction) event. }
  TBrookExecuteActionEvent = procedure(ASender: TObject; AAction: TBrookAction;
    ARequest: TBrookRequest; AResponse: TBrookResponse; const ANames,
    AValues: TBrookArrayOfString; ARoute: TBrookRoute;
    var AHandled: Boolean) of object;
  { Defines a pointer to the execute action event.}
  PBrookExecuteActionEvent = ^TBrookExecuteActionEvent;

  { Defines a list of routes. }
  TBrookRoutes = class(TBrookPersistent)
  private
    FList: TFPList;
    function GetItems(const AIndex: Integer): PBrookRoute;
    procedure SetItems(const AIndex: Integer; const AValue: PBrookRoute);
  protected
    procedure FreeRoutes; virtual;
    property List: TFPList read FList;
  public
    { Creates an instance of a @link(TBrookRoutes) class. }
    constructor Create; virtual;
    { Frees an instance of @link(TBrookRoutes) class. }
    destructor Destroy; override;
    { Clears all routes. }
    procedure Clear;
    { Returns the number of registered routes. }
    function Count: Integer;
    { Adds a route item. }
    function Add(AActionClass: TBrookActionClass; const APattern: string;
      const AMethod: TBrookRequestMethod; const ADefault: Boolean): Integer;
    { Get the default action class. }
    procedure GetDefaultActionClass(out AClass: TBrookActionClass;
      out AIndex: Integer);
    { Get the action class with empty pattern. }
    procedure GetEmptyPatternActionClass(out AClass: TBrookActionClass;
      out AIndex: Integer);
    { Get the registered pattern of a class. }
    function PatternByActionClass(AClass: TBrookActionClass): string;
    { Get the action class from a patter. }
    function ActionClassByPattern(const APattern: string): TBrookActionClass;
    { Get an action class from its class name. }
    function ActionClassByClassName(const AName: string): TBrookActionClass;
    { The list of routes. }
    property Items[const AIndex: Integer]: PBrookRoute read GetItems
      write SetItems; default;
  end;

  { Provides features for the route handling. }
  TBrookRouter = class(TBrookComponent)
  private
    FAfterExecuteAction: TBrookExecuteActionEvent;
    FAfterMatchPattern: TBrookMatchPatternEvent;
    FAfterRoute: TBrookRouteEvent;
    FBeforeExecuteAction: TBrookExecuteActionEvent;
    FBeforeMatchPattern: TBrookMatchPatternEvent;
    FBeforeRoute: TBrookRouteEvent;
    FRoutes: TBrookRoutes;
  protected
    function CreateRoutes: TBrookRoutes; virtual;
    procedure FreeRoutes(ARoutes: TBrookRoutes); virtual;
    function CreateAction(out AActionClass: TBrookActionClass;
      ARequest: TBrookRequest; AResponse: TBrookResponse): TBrookAction; virtual;
    procedure FreeAction(AAction: TBrookAction); virtual;
    procedure ExecuteAction(AAction: TBrookAction; ARequest: TBrookRequest;
      AResponse: TBrookResponse; const ANames, AValues: TBrookArrayOfString;
      ARoute: TBrookRoute); overload; virtual;
  public
    { Creates an instance of a @link(TBrookRouter) class. }
    constructor Create(AOwner: TComponent); override;
    { Frees an instance of @link(TBrookRouter) class. }
    destructor Destroy; override;
    { Return the service class provided by this class. }
    class function GetServiceClass: TBrookRouterClass;
    { Registers the service provided by this class. }
    class procedure RegisterService;
    { Unregisters the service  provided by this class. }
    class procedure UnregisterService;
    { Return an instance of this class. }
    class function Service: TBrookRouter;
    { Return the root URL. }
    class function RootUrl: string;
    { Return the root URL passing @code(TBrookRequest) as param. }
    class function RootUrl(ARequest: TBrookRequest): string;
    { Sends the HTTP "NotAllowed" status code to the response. }
    class procedure MethodNotAllowed(AResponse: TBrookResponse);
    { Creates an URL for an action informing an array of parameters. Exemple:

      @longCode(
      procedure TMyAction.Get;
      begin
        // When calling with http://localhost/cgi-bin/cgi1/foo/myvalue
        // the output will be /cgi-bin/cgi1/foo/myvalue
        Write(UrlFor(TMyAction, ['myvalue']));
      end;

      initialization
        TMyAction.Register('/foo/:myvar');) }
    function UrlFor(AActionClass: TBrookActionClass;
      const AParams: array of string): string; overload;
    { Creates an URL for an action passing an array of parameters however
      informing the class name as string }
    function UrlFor(AClassName: string;
      const AParams: array of string): string; overload;
    { Adds an slash to the end of the URL if does not exist. }
    function Canonicalize(ARequest: TBrookRequest;
      AResponse: TBrookResponse): Boolean;
    { Checks if the given parameters match with a registered route. }
    function MatchPattern(APattern, APathInfo: string; out ARedirect: Boolean;
      out ANames, AValues: TBrookArrayOfString): Boolean; virtual;
    { Runs the route processing. }
    procedure Route(ARequest: TBrookRequest; AResponse: TBrookResponse); virtual;
    { List of available routes. }
    property Routes: TBrookRoutes read FRoutes write FRoutes;
    { Is triggered after the router executes a action. }
    property AfterExecuteAction: TBrookExecuteActionEvent
      read FAfterExecuteAction write FAfterExecuteAction;
    { Is triggered after the router matches a pattern. }
    property AfterMatchPattern: TBrookMatchPatternEvent
      read FAfterMatchPattern write FAfterMatchPattern;
    { Is triggered after the router is routing. }
    property AfterRoute: TBrookRouteEvent read FAfterRoute
      write FAfterRoute;
    { Is triggered before the router executes a action. }
    property BeforeExecuteAction: TBrookExecuteActionEvent
      read FBeforeExecuteAction write FBeforeExecuteAction;
    { Is triggered before the router matches a pattern. }
    property BeforeMatchPattern: TBrookMatchPatternEvent
      read FBeforeMatchPattern write FBeforeMatchPattern;
    { Is triggered before the router is routing. }
    property BeforeRoute: TBrookRouteEvent read FBeforeRoute
      write FBeforeRoute;
  end;

implementation

var
  _BrookRouterService: TBrookRouter = nil;
  _BrookRouterServiceClass: TBrookRouterClass = nil;

{ TBrookRoutes }

constructor TBrookRoutes.Create;
begin
  inherited Create;
  FList := TFPList.Create;
end;

destructor TBrookRoutes.Destroy;
begin
  FreeRoutes;
  FList.Free;
  inherited Destroy;
end;

procedure TBrookRoutes.Clear;
begin
  FreeRoutes;
  FList.Clear;
end;

function TBrookRoutes.Count: Integer;
begin
  Result := FList.Count;
end;

function TBrookRoutes.GetItems(const AIndex: Integer): PBrookRoute;
begin
  Result := FList.Items[AIndex];
end;

procedure TBrookRoutes.SetItems(const AIndex: Integer; const AValue: PBrookRoute);
begin
  FList.Items[AIndex] := AValue;
end;

procedure TBrookRoutes.FreeRoutes;
var
  P: PBrookRoute;
begin
  for P in FList do
    Dispose(P);
end;

function TBrookRoutes.Add(AActionClass: TBrookActionClass;
  const APattern: string; const AMethod: TBrookRequestMethod;
  const ADefault: Boolean): Integer;
var
  PRoute: PBrookRoute;
begin
  for PRoute in FList do
  begin
    if BrookSettings.Mapped then
    begin
      if (PRoute^.ActionClass = AActionClass) and
        (PRoute^.Pattern = APattern) and (PRoute^.Method = AMethod) then
        raise EBrookRoutes.CreateFmt(Self, SBrookActionAlreadyRegisteredError,
          [AActionClass.ClassName]);
      if (PRoute^.Pattern = APattern) and (PRoute^.Method = AMethod) then
        raise EBrookRoutes.CreateFmt(Self, SBrookPatternAlreadyRegisteredError,
          [APattern]);
    end
    else
    begin
      if (PRoute^.ActionClass = AActionClass) and
        (PRoute^.Pattern = APattern) then
        raise EBrookRoutes.CreateFmt(Self, SBrookActionAlreadyRegisteredError,
          [AActionClass.ClassName]);
      if PRoute^.Pattern = APattern then
        raise EBrookRoutes.CreateFmt(Self, SBrookPatternAlreadyRegisteredError,
          [APattern]);
    end;
    if ADefault and PRoute^.Default and (PRoute^.ActionClass <> AActionClass) then
      raise EBrookRoutes.Create(Self, SBrookDefaultActionAlreadyRegisteredError);
  end;
  New(PRoute);
  PRoute^.ActionClass := AActionClass;
  PRoute^.Default := ADefault;
  PRoute^.Method := AMethod;
  PRoute^.Pattern := APattern;
  Result := FList.Add(PRoute);
end;

procedure TBrookRoutes.GetDefaultActionClass(out AClass: TBrookActionClass;
  out AIndex: Integer);
var
  I: Integer;
  PRoute: PBrookRoute;
begin
  for I := 0 to Pred(FList.Count) do
  begin
    PRoute := FList[I];
    if PRoute^.Default then
    begin
      AIndex := I;
      AClass := PRoute^.ActionClass;
      Exit;
    end;
  end;
  AIndex := -1;
  AClass := nil;
end;

procedure TBrookRoutes.GetEmptyPatternActionClass(out
  AClass: TBrookActionClass; out AIndex: Integer);
var
  I: Integer;
  PRoute: PBrookRoute;
begin
  for I := 0 to Pred(FList.Count) do
  begin
    PRoute := FList[I];
    if PRoute^.Pattern = ES then
    begin
      AIndex := I;
      AClass := PRoute^.ActionClass;
      Exit;
    end;
  end;
  AIndex := -1;
  AClass := nil;
end;

function TBrookRoutes.PatternByActionClass(AClass: TBrookActionClass): string;
var
  PRoute: PBrookRoute;
begin
  for PRoute in FList do
    if PRoute^.ActionClass = AClass then
    begin
      Result := PRoute^.Pattern;
      Exit;
    end;
  Result := ES;
end;

function TBrookRoutes.ActionClassByPattern(
  const APattern: string): TBrookActionClass;
var
  PRoute: PBrookRoute;
begin
  for PRoute in FList do
    if PRoute^.Pattern = APattern then
    begin
      Result := PRoute^.ActionClass;
      Exit;
    end;
  Result := nil;
end;

function TBrookRoutes.ActionClassByClassName(
  const AName: string): TBrookActionClass;
var
  PRoute: PBrookRoute;
begin
  for PRoute in FList do
    if SameText(PRoute^.ActionClass.ClassName, AName) then
    begin
      Result := PRoute^.ActionClass;
      Exit;
    end;
  Result := nil;
end;

{ TBrookRouter }

constructor TBrookRouter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FRoutes := CreateRoutes;
end;

destructor TBrookRouter.Destroy;
begin
  FreeRoutes(FRoutes);
  inherited Destroy;
end;

class function TBrookRouter.GetServiceClass: TBrookRouterClass;
begin
  Result := _BrookRouterServiceClass;
end;

function TBrookRouter.CreateRoutes: TBrookRoutes;
begin
  Result := TBrookRoutes.Create;
end;

procedure TBrookRouter.FreeRoutes(ARoutes: TBrookRoutes);
begin
  FreeAndNil(ARoutes);
end;

function TBrookRouter.CreateAction(out AActionClass: TBrookActionClass;
  ARequest: TBrookRequest; AResponse: TBrookResponse): TBrookAction;
begin
  Result := AActionClass.Create(ARequest, AResponse);
end;

procedure TBrookRouter.FreeAction(AAction: TBrookAction);
begin
  AAction.Free;
end;

procedure TBrookRouter.ExecuteAction(AAction: TBrookAction;
  ARequest: TBrookRequest; AResponse: TBrookResponse; const ANames,
  AValues: TBrookArrayOfString; ARoute: TBrookRoute);
var
  VHandled: Boolean = False;
begin
  try
    if Assigned(FBeforeExecuteAction) then
      FBeforeExecuteAction(Self, AAction, ARequest, AResponse, ANames, AValues,
        ARoute, VHandled);
    if not VHandled then
    begin
      AAction.DoFillVariables(ANames, AValues);
      AAction.DoRequest(ARequest, AResponse);
    end;
  finally
    if Assigned(FAfterExecuteAction) then
      FAfterExecuteAction(Self, AAction, ARequest, AResponse, ANames, AValues,
        ARoute, VHandled);
  end;
end;

class procedure TBrookRouter.RegisterService;
begin
  if Assigned(_BrookRouterServiceClass) then
    raise EBrookRouter.Create(Self, SBrookRouterServiceAlreadyRegisteredError);
  _BrookRouterServiceClass := Self;
end;

class procedure TBrookRouter.UnregisterService;
begin
  FreeAndNil(_BrookRouterService);
  _BrookRouterServiceClass := nil;
end;

class function TBrookRouter.Service: TBrookRouter;
begin
  if not Assigned(_BrookRouterService) then
  begin
    if not Assigned(_BrookRouterServiceClass) then
      raise EBrookRouter.Create(Self, SBrookNoRouterServiceRegisteredError);
    _BrookRouterService := _BrookRouterServiceClass.Create(nil);
  end;
  Result := _BrookRouterService;
end;

class function TBrookRouter.RootUrl: string;
begin
  if BrookSettings.RootUrl = ES then
    Result := GetEnvironmentVariable(BROOK_SRV_ENV_SCRIPT_NAME)
  else
    Result := BrookSettings.RootUrl;
end;

class function TBrookRouter.RootUrl(ARequest: TBrookRequest): string;
begin
  if BrookSettings.RootUrl = ES then
    Result := ARequest.ScriptName
  else
    Result := BrookSettings.RootUrl;
end;

class procedure TBrookRouter.MethodNotAllowed(AResponse: TBrookResponse);
begin
  AResponse.Code := BROOK_HTTP_STATUS_CODE_METHOD_NOT_ALLOWED;
  AResponse.CodeText := BROOK_HTTP_REASON_PHRASE_METHOD_NOT_ALLOWED;
  AResponse.Contents.Add(SBrookMethodNotAllowedError);
end;

function TBrookRouter.UrlFor(AActionClass: TBrookActionClass;
  const AParams: array of string): string;
var
  S, VVal: string;
  I, B, E: Integer;
begin
  Result := ES;
  S := FRoutes.PatternByActionClass(AActionClass);
  if Length(S) = 0 then
    Exit;
  if S[1] = AK then
    Delete(S, 1, 1);
  for I := 0 to High(AParams) do
  begin
    VVal := HTTPEncode(AParams[I]);
    B := Pos(CO, S);
    if B = 0 then
      B := Pos(AK,S);
    if B <> 0 then
    begin
      E := PosEx(US, S, B);
      if E <> 0 then
      begin
        Delete(S, B, E - B);
        Insert(VVal, S, B);
      end
      else
      begin
        Delete(S, B, MaxInt);
        Insert(VVal, S, MaxInt);
      end;
    end;
  end;
  Result := BrookExcludeTrailingUrlDelimiter(TBrookRouter.RootUrl) + S;
end;

function TBrookRouter.UrlFor(AClassName: string;
  const AParams: array of string): string;
begin
  Result := UrlFor(FRoutes.ActionClassByClassName(AClassName), AParams);
end;

function TBrookRouter.Canonicalize(ARequest: TBrookRequest;
  AResponse: TBrookResponse): Boolean;
var
  L: LongInt;
  VURL, VQueryStr, VPathInfo: string;
begin
  VQueryStr := ARequest.QueryString;
  if VQueryStr <> ES then
    VQueryStr := QU + VQueryStr;
  VPathInfo := Copy(ARequest.PathInfo, 1, Pos(QU, ARequest.PathInfo) - 1);
  if VPathInfo = ES then
    VPathInfo := ARequest.PathInfo;
  VURL := TBrookRouter.RootUrl(ARequest) + VPathInfo;
  L := Length(VURL);
  Result := ((L > 0) and (VURL[L] <> US)) or (VURL = ES);
  if Result then
    AResponse.SendRedirect(LowerCase(VURL) + US + VQueryStr);
end;

function TBrookRouter.MatchPattern(APattern, APathInfo: string;
  out ARedirect: Boolean; out ANames, AValues: TBrookArrayOfString): Boolean;

  procedure ExtractNextPathLevel(var ALeftPart: string;
    var ALvl: string; var ARightPart: string; const ADelimiter: Char = US);
  var
    P: Integer;
  begin
    if ALvl <> ADelimiter then
    begin
      ALeftPart := ALeftPart + ALvl;
      if BrookStartsChar(ADelimiter, ARightPart) then
      begin
        ALeftPart := ALeftPart + ADelimiter;
        Delete(ARightPart, 1, 1);
      end;
    end;
    P := Pos(ADelimiter, ARightPart);
    if P = 0 then
      P := Length(ARightPart) + 1;
    ALvl := Copy(ARightPart, 1, P - 1);
    ARightPart := Copy(ARightPart, P, MaxInt);
  end;

  procedure ExtractPrevPathLevel(var ALeftPart: string;
    var ALvl: string; var ARightPart: string; const ADelimiter: Char = US);
  var
    P: Integer;
  begin
    if ALvl <> ADelimiter then
    begin
      ARightPart := ALvl + ARightPart;
      if BrookEndsChar(ADelimiter, ALeftPart) then
      begin
        ARightPart := ADelimiter + ARightPart;
        Delete(ALeftPart, Length(ALeftPart), 1);
      end;
    end;
    P := RPos(ADelimiter, ALeftPart);
    ALvl := Copy(ALeftPart, P + 1, MaxInt);
    ALeftPart := Copy(ALeftPart, 1, P);
  end;

var
  VCount: Integer;
  VResult: Boolean;
  VHandled: Boolean = False;
  VLeftPat, VRightPat, VLeftVal, VRightVal, VVal, VPat, VName: string;
begin
  try
    if Assigned(FBeforeMatchPattern) then
      VResult := FBeforeMatchPattern(Self, APattern, APathInfo, ARedirect,
        ANames, AValues, VHandled);
    if VHandled then
      Exit(VResult);
    Result := False;
    ARedirect := False;
    if APattern = ES then
      Exit;
    if (APattern = US) and (APathInfo = ES) then
    begin
      ARedirect := True;
      Exit(True);
    end;
    Delete(APattern, Pos(QU, APattern), MaxInt);
    Delete(APathInfo, Pos(QU, APathInfo), MaxInt);
    if BrookStartsChar(US, APattern) then
      Delete(APattern, 1, 1);
    if BrookStartsChar(US, APathInfo) then
      Delete(APathInfo, 1, 1);
    VLeftPat := ES;
    VLeftVal := ES;
    VPat := US; // init value is '/', not ''
    VVal := US; // init value is '/', not ''
    VRightPat := APattern;
    VRightVal := APathInfo;
    VCount := 1;
    repeat
      // Extract next part
      ExtractNextPathLevel(VLeftPat, VPat, VRightPat);
      ExtractNextPathLevel(VLeftVal, VVal, VRightVal);
      if BrookStartsChar(CO, VPat) then
      begin
        // :field
        SetLength(ANames, VCount);
        SetLength(AValues, VCount);
        ANames[VCount - 1] := Copy(VPat, 2, MaxInt);
        AValues[VCount - 1] := VVal;
        Inc(VCount);
      end
      else
        if BrookStartsChar(AK, VPat) then
        begin
          // *path
          VName := Copy(VPat, 2, MaxInt);
          VLeftPat := VRightPat;
          VLeftVal := VVal + VRightVal;
          VPat := US; // init value is '/', not ''
          VVal := US; // init value is '/', not ''
          VRightPat := ES;
          VRightVal := ES;
          // if AutoAddSlash ...
          if BrookEndsChar(US, VLeftPat) and not BrookEndsChar(US, VLeftVal) then
          begin
            Delete(VLeftPat, Length(VLeftPat), 1);
            ARedirect := True; // Will be Redirect if match
          end;
          repeat
            // Extract backwards
            ExtractPrevPathLevel(VLeftPat, VPat, VRightPat);
            ExtractPrevPathLevel(VLeftVal, VVal, VRightVal);
            if BrookStartsChar(CO, VPat) then
            begin
              // *path/:field
              SetLength(ANames, VCount);
              SetLength(AValues, VCount);
              ANames[VCount - 1] := Copy(VPat, 2, MaxInt);
              AValues[VCount - 1] := VVal;
              Inc(VCount);
            end
            else
              // *path/const
              if not ((VPat = ES) and (VLeftPat = ES)) and (VPat <> VVal) then
                Exit(False);
            // Check if we already done
            if (VLeftPat = ES) or (VLeftVal = ES) then
            begin
              if VLeftPat = ES then
              begin
                SetLength(ANames, VCount);
                SetLength(AValues, VCount);
                ANames[VCount - 1] := VName;
                AValues[VCount - 1] := VLeftVal + VVal;
                Inc(VCount);
                Exit(True);
              end;
              Exit(False);
            end;
          until False;
        end
        else
          // const
          if VPat <> VVal then
            Exit(False);
      // Check if we already done
      if (VRightPat = ES) or (VRightVal = ES) then
      begin
        if (VRightPat = ES) and (VRightVal = ES) then
          Exit(True)
        else
        // if AutoAddSlash ...
        if VRightPat = US then
        begin
          ARedirect := True;
          Exit(True);
        end;
        Exit(False);
      end;
    until False;
  finally
    if Assigned(FAfterMatchPattern) then
      FAfterMatchPattern(Self, APattern, APathInfo, ARedirect, ANames, AValues,
        VHandled);
  end;
end;

procedure TBrookRouter.Route(ARequest: TBrookRequest; AResponse: TBrookResponse);
var
  I, C: Integer;
  PRoute: PBrookRoute;
  VAct: TBrookAction;
  VHandled: Boolean = False;
  VActClass: TBrookActionClass = nil;
  VNames, VValues: TBrookArrayOfString;
  VTempActClass: TBrookActionClass = nil;
  VRedirect, VMatchMethod, VMatchPattern: Boolean;
begin
  try
    if Assigned(FBeforeRoute) then
      FBeforeRoute(Self, ARequest, AResponse, VHandled);
    if VHandled then
      Exit;
    C := FRoutes.List.Count;
    if C = 0 then
      raise EBrookRouter.Create(Self, SBrookNoRouteRegisteredError);
    if ARequest.PathInfo = ES then
    begin
      FRoutes.GetEmptyPatternActionClass(VTempActClass, I);
      if I > -1 then
        FRoutes.List.Move(I, C - 1);
    end;
    if not Assigned(VTempActClass) then
    begin
      FRoutes.GetDefaultActionClass(VTempActClass, I);
      if I > -1 then
        FRoutes.List.Move(I, C - 1);
    end;
    if BrookSettings.Mapped then
    begin
      VMatchMethod := False;
      VMatchPattern := False;
      for PRoute in FRoutes.List do
        if MatchPattern(PRoute^.Pattern, ARequest.PathInfo, VRedirect,
          VNames, VValues) then
        begin
          if VRedirect and Canonicalize(ARequest, AResponse) then
            Exit;
          VMatchPattern := True;
          if not BrookMatchMethod(PRoute^.Method, ARequest.Method) then
            Continue;
          VMatchMethod := True;
          VActClass := PRoute^.ActionClass;
//          if PRoute^.Method <> rmAll then Please see issue #64
            Break;
        end;
      if VMatchPattern then
      begin
        if VMatchMethod then
        begin
          if not Assigned(VActClass) then
            if Assigned(VTempActClass) then
              VActClass := VTempActClass;
        end
        else
        begin
          TBrookRouter.MethodNotAllowed(AResponse);
          Exit;
        end;
      end
      else
        raise EBrookHTTP404.Create(ARequest.PathInfo);
    end
    else
    begin
      for PRoute in FRoutes.List do
        if MatchPattern(PRoute^.Pattern, ARequest.PathInfo, VRedirect,
          VNames, VValues) then
        begin
          if VRedirect and Canonicalize(ARequest, AResponse) then
            Exit;
          VActClass := PRoute^.ActionClass;
          Break;
        end;
      if not Assigned(VActClass) then
        if Assigned(VTempActClass) then
          VActClass := VTempActClass
        else
          raise EBrookHTTP404.Create(ARequest.PathInfo);
    end;
  finally
    if Assigned(FAfterRoute) then
      FAfterRoute(Self, ARequest, AResponse, VHandled);
  end;
  VAct := CreateAction(VActClass, ARequest, AResponse);
  try
    ExecuteAction(VAct, ARequest, AResponse, VNames, VValues, PRoute^);
  finally
    FreeAction(VAct);
  end;
end;

initialization
  TBrookRouter.RegisterService;

finalization
  TBrookRouter.UnregisterService;

end.
