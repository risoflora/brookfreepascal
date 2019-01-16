(*
  Brook framework, Utilities Unit

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookUtils;

{$i brook.inc}

interface

uses
  BrookException, BrookMessages, BrookConsts, BrookHTTPConsts, CustWeb,
  Classes, SysUtils, TypInfo;

type
  { Defines an array of strings. }
  TBrookArrayOfString = array of string;

  { Defines an enumerator to represent the HTTP request methods. }
  TBrookRequestMethod = (
    rmUnknown, rmAll, rmGet, rmPost, rmPut, rmDelete, rmHead, rmOptions, rmTrace
  );

  { Stores the Brook settings. }
  TBrookSettings = record
    { Enables the mapping of HTTP request methods. }
    Mapped: Boolean;
    { Set the default application Charset. }
    Charset: ShortString;
    { Set the default application Content-Type. }
    ContentType: ShortString;
    { Set the 404 HTML page. The string will be sent as is. }
    Page404: string;
    { Set the 404 HTML page file. The file content will be sent.
      This has higher precedence than @code(TBrookSettings.Page404)
      so when both are set, this will be processed first and only
      if the file is not found or cannot be read the system will
      fallback to @code(TBrookSettings.Page404) }
    Page404File: string;
    { Set the 500 HTML page. The string will be sent as is. }
    Page500: string;
    { Set the 500 HTML page file. The file content will be sent.
      This has higher precedence than @code(TBrookSettings.Page500)
      so when both are set, this will be processed first and only
      if the file is not found or cannot be read the system will
      fallback to @code(TBrookSettings.Page500) }
    Page500File: string;
    { Set the default directory for uploads. }
    DirectoryForUploads: string;
    { Defines if the temporary uploaded files will be deleted. }
    DeleteUploadedFiles: Boolean;
    { Keeps the original name of the uploaded files. }
    KeepUploadedNames: Boolean;
    { Set a configuration for the application or for its object members. }
    Configuration: string;
    { Set the default root URL. This is used by methods such as
      @code(TBrookAction.UrlFor), @code(TBrookActionHelper.LinkTo),
      @code(TBrookActionHelper.ButtonTo) etc. By default, Brook assumes
      @code(SCRIPT_NAME) as root URL. }
    RootUrl: string;
    { Set the default application port. }
    Port: Word;
    { Enables the application log. }
    LogActive: Boolean;
    { Set a name for the application log file. }
    LogFile: TFileName;
    { Handles the application exceptions. }
    OnError: TOnShowRequestException;
  end;

var
  { Global variable to store Brook settings. }
  BrookSettings: TBrookSettings = (
    Mapped: False;
    Charset: BROOK_HTTP_CHARSET_UTF_8;
    ContentType: BROOK_HTTP_CONTENT_TYPE_TEXT_HTML;
    Page404: BROOK_HTTP_RESPONSE_TEMPLATE_NOT_FOUND;
    Page404File: ES;
    Page500: BROOK_HTTP_RESPONSE_TEMPLATE_INTERNAL_SERVER_ERROR;
    Page500File: ES;
    DirectoryForUploads: ES;
    DeleteUploadedFiles: False;
    KeepUploadedNames: True;
    Configuration: ES;
    RootUrl: ES;
    Port: 0;
    LogActive: False;
    LogFile: ES;
    OnError: nil;
  );

{ Check whether a string starts with a given character. }
function BrookStartsChar(const Ch: Char; const S: string): Boolean;
{ Check whether a string ends with a given character. }
function BrookEndsChar(const Ch: Char; const S: string): Boolean;
{ Get the next pathinfo level. }
procedure BrookExtractPathLevels(S: string; var R: string; out ALvl: string;
  out AEndDelim: Boolean; const ADelimiter: Char = US);
{ Get the path level passing the respective index. Exemple:

  @code(BrookGetPathLavel('/a/b/c/', 1)) = b. }
function BrookGetPathLevel(const APath: string; const AIndex: SizeInt = 0;
  const ADelimiter: Char = US): string;
{ Get the path from the level correspondent to the index to the last level.
  Exemple:

  @code(BrookGetPathLevels('/a/b/c/', 1)) = b/c/. }
function BrookGetPathLevels(const APath: string; const AIndex: SizeInt = 0;
  const ADelimiter: Char = US): string;
{ Checks if a string is equivalent an enumerator representing a HTTP request
  method. }
function BrookMatchMethod(const ABrookMethod: TBrookRequestMethod;
  const AMethod: string): Boolean;
{ Get the datetime of a file. }
function BrookFileDate(const AFileName: TFileName): TDateTime;
{ Writes a backtrace of the current exception. }
function BrookDumpStack(const AEOL: ShortString = BR): string;
{ Writes a stack trace of the current exception. }
function BrookDumpStackTrace(const AEOL: ShortString = BR): string;
{ Ensures Url ends without delimiter. }
function BrookExcludeTrailingUrlDelimiter(const AUrl: string): string;
{ Ensures Url ends with delimiter. }
function BrookIncludeTrailingUrlDelimiter(const AUrl: string): string;
{ Checks if a string exists in an array of strings. }
function BrookExists(const S: string; const
  AParts: array of string): Boolean; overload;
{ Checks (ignoring case) if a string exists in an array of strings. }
function BrookExists(const S: string; const AParts: array of string;
  const AIgnoreCase: Boolean): Boolean; overload;
{ Fills a published property of an object passing the property as
  @code(PPropInfo) and value as @code(string). }
procedure BrookStringToObject(AObject: TObject; APropInfo: PPropInfo;
  const AValue: string); overload;
{ Fills a published property of an object passing the name and value as
  @code(string). }
procedure BrookStringToObject(AObject: TObject; const AName,
  AValue: string); overload;
{ Fills a published property of an object passing the name and value as
  string and checking the params. }
procedure BrookSafeStringToObject(AObject: TObject; const AName, AValue: string);
{ Fills the published properties of an object passing the names and values as
  a list of strings. }
procedure BrookStringsToObject(AObject: TObject; AStrings: TStrings); overload;
{ Fills the published properties of an object passing the names and values as
  a list of strings. Allows to ignore properties via an array of strings. }
procedure BrookStringsToObject(AObject: TObject; AStrings: TStrings;
  const AIgnoredProps: array of string); overload;
{ Fills the published properties of an object passing the names and values as
  a list of strings. Allows to ignore properties via a list of strings. }
procedure BrookStringsToObject(AObject: TObject; AStrings: TStrings;
  const AIgnoredProps: TStrings); overload;
{ Fills the published properties of an object passing the names and values as
  a list of strings and checking the params. }
procedure BrookSafeStringsToObject(AObject: TObject;
  AStrings: TStrings); overload;
{ Fills the published properties of an object passing the names and values as
  a list of strings and checking the params. Allows to ignore properties via an
  array of strings. }
procedure BrookSafeStringsToObject(AObject: TObject; AStrings: TStrings;
  const AIgnoredProps: array of string); overload;
{ Fills the published properties of an object passing the names and values as
  a list of strings and checking the params. Allows to ignore properties via a
  list of strings. }
procedure BrookSafeStringsToObject(AObject: TObject; AStrings: TStrings;
  const AIgnoredProps: TStrings); overload;
{ Reads a published property of an object passing the property as
  @code(PPropInfo) and getting the value as @code(string). }
procedure BrookObjectToString(AObject: TObject; APropInfo: PPropInfo;
  out AValue: string); overload;
{ Reads a published property of an object passing the name as @code(string) and
  getting the value as @code(string). }
procedure BrookObjectToString(AObject: TObject; const AName: string;
  out AValue: string); overload;
{ Reads a published property of an object passing the name, getting the value as
  string and checking the params. }
procedure BrookSafeObjectToString(AObject: TObject; const AName: string;
  out AValue: string);
{ Reads the published properties of an object getting the names and values as
  a list of strings. }
procedure BrookObjectToStrings(AObject: TObject; AStrings: TStrings); overload;
{ Reads the published properties of an object getting the names and values as
  a list of strings. Allows to ignore properties via an array of strings. }
procedure BrookObjectToStrings(AObject: TObject; AStrings: TStrings;
  const AIgnoredProps: array of string); overload;
{ Reads the published properties of an object getting the names and values as
  a list of strings. Allows to ignore properties via a list of strings. }
procedure BrookObjectToStrings(AObject: TObject; AStrings: TStrings;
  const AIgnoredProps: TStrings); overload;
{ Reads the published properties of an object getting the names and values as
  a list of strings and checking the params. }
procedure BrookSafeObjectToStrings(AObject: TObject;
  AStrings: TStrings); overload;
{ Reads the published properties of an object getting the names and values as
  a list of strings and checking the params. Allows to ignore properties via an
  array of strings. }
procedure BrookSafeObjectToStrings(AObject: TObject; AStrings: TStrings;
  const AIgnoredProps: array of string); overload;
{ Reads the published properties of an object getting the names and values as
  a list of strings and checking the params. }
procedure BrookSafeObjectToStrings(AObject: TObject; AStrings: TStrings;
  const AIgnoredProps: TStrings); overload;
{ Copies the value of all properties from one object to another passing the
  prop. list and prop. count. }
procedure BrookCopyObject(APropList: PPropList; const APropCount: Integer;
  AFrom, ATo: TObject); overload;
{ Copies the value of all properties from one object to another passing the
  prop. list and prop. count. Allows to ignore properties via an array of
  strings. }
procedure BrookCopyObject(APropList: PPropList; const APropCount: Integer;
  AFrom, ATo: TObject; const AIgnoredProps: array of string); overload;
{ Copies the value of all properties from one object to another passing the
  prop. list and prop. count. Allows to ignore properties via a list of
  strings. }
procedure BrookCopyObject(APropList: PPropList; const APropCount: Integer;
  AFrom, ATo: TObject; const AIgnoredProps: TStrings); overload;
{ Copies the value of all properties from one object to another. }
procedure BrookCopyObject(AFrom, ATo: TObject); overload;
{ Copies the value of all properties from one object to another. Allows to
  ignore properties via an array of strings. }
procedure BrookCopyObject(AFrom, ATo: TObject;
  const AIgnoredProps: array of string); overload;
{ Copies the value of all properties from one object to another. Allows to
  ignore properties via a list of strings. }
procedure BrookCopyObject(AFrom, ATo: TObject;
  const AIgnoredProps: TStrings); overload;
{ Copies the value of all properties from one object to another passing the
  prop. list and prop. count and checking the params. }
procedure BrookSafeCopyObject(APropList: PPropList; const APropCount: Integer;
  AFrom, ATo: TObject); overload;
{ Copies the value of all properties from one object to another passing the
  prop. list and prop. count and checking the params. Allows to ignore
  properties via an array of strings. }
procedure BrookSafeCopyObject(APropList: PPropList; const APropCount: Integer;
  AFrom, ATo: TObject; const AIgnoredProps: array of string); overload;
{ Copies the value of all properties from one object to another passing the
  prop. list and prop. count and checking the params. Allows to ignore
  properties via a list of strings. }
procedure BrookSafeCopyObject(APropList: PPropList; const APropCount: Integer;
  AFrom, ATo: TObject; const AIgnoredProps: TStrings); overload;
{ Copies the value of all properties from one object to another and checking the
  params. }
procedure BrookSafeCopyObject(AFrom, ATo: TObject); overload;
{ Copies the value of all properties from one object to another and checking the
  params. Allows to ignore properties via an array of strings. }
procedure BrookSafeCopyObject(AFrom, ATo: TObject;
  const AIgnoredProps: array of string); overload;
{ Copies the value of all properties from one object to another and checking the
  params. Allows to ignore properties via a list of strings. }
procedure BrookSafeCopyObject(AFrom, ATo: TObject;
  const AIgnoredProps: TStrings); overload;

implementation

function BrookStartsChar(const Ch: Char; const S: string): Boolean;
begin
  Result := (Length(S) > 0) and (S[1] = Ch);
end;

function BrookEndsChar(const Ch: Char; const S: string): Boolean;
begin
  Result := (Length(S) > 0) and (S[Length(S)] = Ch);
end;

procedure BrookExtractPathLevels(S: string; var R: string; out ALvl: string;
  out AEndDelim: Boolean; const ADelimiter: Char = US);

  function IncHttpPathDelim(const P: string): string; inline;
  var
    L: Integer;
  begin
    Result := P;
    L := Length(Result);
    if (L > 0) and (Result[L] <> US) then
      Result += US;
  end;

var
  P, L: Integer;
begin
  L := Length(S);
  AEndDelim := (S <> ES) and (S[L] = ADelimiter);
  if AEndDelim then
    Delete(S, L, 1);
  if (S <> ES) and (S[1] = ADelimiter) then
    Delete(S, 1, 1);
  Delete(S, 1, Length(IncHttpPathDelim(R)));
  P := Pos(ADelimiter, S);
  if P = 0 then
    P := Length(S) + 1;
  ALvl := Copy(S, 1, P - 1);
  R := IncHttpPathDelim(R) + ALvl;
end;

{$PUSH}{$WARN 5093 OFF}

function BrookGetPathLevel(const APath: string; const AIndex: SizeInt;
  const ADelimiter: Char): string;
var
  C, L: SizeInt;
  VSrc, VDest: PChar;
begin
  SetLength(Result, Length(APath));
  VSrc := PChar(APath);
  VDest := PChar(Result);
  C := Succ(AIndex);
  L := 0;
  while (VSrc^ <> NU) and (VSrc^ <> QU) do
  begin
    if (VSrc^ = ADelimiter) and (C <> 0) then
      Dec(C)
    else
      if C = 0 then
      begin
        if VSrc^ = ADelimiter then
          Break;
        VDest^ := VSrc^;
        Inc(VDest);
        Inc(L);
      end;
    Inc(VSrc);
  end;
  SetLength(Result, L);
end;

function BrookGetPathLevels(const APath: string; const AIndex: SizeInt;
  const ADelimiter: Char): string;
var
  C, L: Integer;
  VSrc, VDest: PChar;
begin
  SetLength(Result, Length(APath));
  VSrc := PChar(APath);
  VDest := PChar(Result);
  C := Succ(AIndex);
  L := 0;
  while (VSrc^ <> NU) and (VSrc^ <> QU) do
  begin
    if (VSrc^ = ADelimiter) and (C <> 0) then
      Dec(C)
    else
      if C = 0 then
      begin
        VDest^ := VSrc^;
        Inc(VDest);
        Inc(L);
      end;
    Inc(VSrc);
  end;
  SetLength(Result, L);
end;

{$POP}

function BrookMatchMethod(const ABrookMethod: TBrookRequestMethod;
  const AMethod: string): Boolean;
begin
  case ABrookMethod of
    rmAll: Result := True;
    rmGet: Result := AMethod = BROOK_HTTP_REQUEST_METHOD_GET;
    rmHead: Result := AMethod = BROOK_HTTP_REQUEST_METHOD_HEAD;
    rmOptions: Result := AMethod = BROOK_HTTP_REQUEST_METHOD_OPTIONS;
    rmPost: Result := AMethod = BROOK_HTTP_REQUEST_METHOD_POST;
    rmPut: Result := AMethod = BROOK_HTTP_REQUEST_METHOD_PUT;
    rmDelete: Result := AMethod = BROOK_HTTP_REQUEST_METHOD_DELETE;
  else
    Result := False;
  end;
end;

function BrookFileDate(const AFileName: TFileName): TDateTime;
begin
  if not FileExists(AFileName) then
    raise EBrook.CreateFmt('BrookFileDate',
      SBrookFileNotFoundError, [AFileName]);
  Result := FileDateToDateTime(FileAge(AFileName));
end;

function BrookDumpStack(const AEOL: ShortString): string;
var
  I: Integer;
  VReport: string;
  VFrames: PPointer;
begin
  VReport := BackTraceStrFunc(ExceptAddr);
  VFrames := ExceptFrames;
  for I := 0 to Pred(ExceptFrameCount) do
    VReport += AEOL + BackTraceStrFunc(VFrames[I]);
  Result := VReport;
end;

function BrookDumpStackTrace(const AEOL: ShortString): string;
var
  I: Longint;
  VReport: string;
  Vprevbp, VCallerFrame, VCallerAddress, Vbp: Pointer;
const
  MaxDepth = 50;
begin
  VReport := ES;
  Vbp := get_frame;
  // This trick skip SendCallstack item
  // Vbp:= get_caller_frame(get_frame);
  try
    Vprevbp := Vbp - 1;
    I := 0;
    while Vbp > Vprevbp do
    begin
      VCallerAddress := get_caller_addr(Vbp);
      VCallerFrame := get_caller_frame(Vbp);
      if VCallerAddress = nil then
        Break;
      VReport := VReport + BackTraceStrFunc(VCallerAddress) + AEOL;
      Inc(I);
      if (I >= MaxDepth) or (VCallerFrame = nil) then
        Break;
      Vprevbp := Vbp;
      Vbp := VCallerFrame;
    end;
  except
    { Prevent endless dump if an exception occured. }
  end;
  Result := VReport;
end;

function BrookExcludeTrailingUrlDelimiter(const AUrl: string): string;
var
  L: Integer;
begin
  L := Length(AUrl);
  if (L > 0) and (AUrl[L] = US) then
    Dec(L);
  Result := Copy(AUrl, 1, L);
end;

function BrookIncludeTrailingUrlDelimiter(const AUrl: string): string;
var
  L: Integer;
begin
  Result := AUrl;
  L := Length(Result);
  if (L = 0) or (Result[L] <> US) then
    Result += US;
end;

function BrookExists(const S: string; const AParts: array of string): Boolean;
var
  I: Integer;
begin
  for I := 0 to High(AParts) do
  begin
    Result := S = AParts[I];
    if Result then
      Exit;
  end;
  Result := False;
end;

function BrookExists(const S: string; const AParts: array of string;
  const AIgnoreCase: Boolean): Boolean;
var
  I: Integer;
begin
  if AIgnoreCase then
  begin
    for I := 0 to High(AParts) do
    begin
      Result := CompareText(S, AParts[I]) = 0;
      if Result then
        Exit;
    end;
    Result := False;
  end
  else
    Result := BrookUtils.BrookExists(S, AParts);
end;

procedure BrookStringToObject(AObject: TObject; APropInfo: PPropInfo;
  const AValue: string);
begin
  if Assigned(APropInfo) then
    case APropInfo^.PropType^.Kind of
      tkAString: SetStrProp(AObject, APropInfo, AValue);
      tkChar: SetOrdProp(AObject, APropInfo, Ord(PChar(AValue)^));
      tkInteger: SetOrdProp(AObject, APropInfo, StrToIntDef(AValue, DefInt));
      tkInt64, tkQWord: SetInt64Prop(AObject, APropInfo,
        StrToInt64Def(AValue, DefInt64));
      tkBool: SetOrdProp(AObject, APropInfo,
        Ord((ShortCompareText(AValue, 'on') = 0) or
          StrToBoolDef(AValue, DefBool)));
      tkFloat:
        case APropInfo^.PropType^.Name of
          'TDate': SetFloatProp(AObject, APropInfo,
            StrToDateDef(AValue, DefDate));
          'TTime': SetFloatProp(AObject, APropInfo,
            StrToTimeDef(AValue, DefTime));
          'TDateTime': SetFloatProp(AObject, APropInfo,
            StrToDateTimeDef(AValue, DefDateTime));
          'Currency': SetFloatProp(AObject, APropInfo,
            StrToCurrDef(AValue, DefCurrency));
        else
          SetFloatProp(AObject, APropInfo, StrToFloatDef(AValue, DefFloat));
        end;
      tkEnumeration: SetEnumProp(AObject, APropInfo, AValue);
      tkSet: SetSetProp(AObject, APropInfo, AValue);
    end;
end;

procedure BrookStringToObject(AObject: TObject; const AName, AValue: string);
begin
  BrookStringToObject(AObject,
    GetPropInfo(PTypeInfo(AObject.ClassInfo), AName), AValue);
end;

procedure BrookSafeStringToObject(AObject: TObject; const AName, AValue: string);
begin
  if not Assigned(AObject) then
    raise EBrook.CreateFmt('BrookSafeStringToObject',
      SBrookNotNilError, ['AObject']);
  BrookStringToObject(AObject, AName, AValue);
end;

procedure BrookStringsToObject(AObject: TObject; AStrings: TStrings);
var
  I: Integer;
  N, V: string;
begin
  for I := 0 to Pred(AStrings.Count) do
  begin
    AStrings.GetNameValue(I, N, V);
    BrookStringToObject(AObject, N, V);
  end;
end;

procedure BrookStringsToObject(AObject: TObject; AStrings: TStrings;
  const AIgnoredProps: array of string);
var
  I: Integer;
  N, V: string;
begin
  for I := 0 to Pred(AStrings.Count) do
  begin
    AStrings.GetNameValue(I, N, V);
    if not BrookExists(N, AIgnoredProps, True) then
      BrookStringToObject(AObject, N, V);
  end;
end;

procedure BrookStringsToObject(AObject: TObject; AStrings: TStrings;
  const AIgnoredProps: TStrings);
var
  I: Integer;
  N, V: string;
begin
  for I := 0 to Pred(AStrings.Count) do
  begin
    AStrings.GetNameValue(I, N, V);
    if AIgnoredProps.IndexOf(N) = -1 then
      BrookStringToObject(AObject, N, V);
  end;
end;

procedure BrookSafeStringsToObject(AObject: TObject; AStrings: TStrings);
begin
  if not Assigned(AObject) then
    raise EBrook.CreateFmt('BrookSafeStringsToObject', SBrookNotNilError,
      ['AObject']);
  if not Assigned(AStrings) then
    raise EBrook.CreateFmt('BrookSafeStringsToObject', SBrookNotNilError,
      ['AStrings']);
  BrookStringsToObject(AObject, AStrings);
end;

procedure BrookSafeStringsToObject(AObject: TObject; AStrings: TStrings;
  const AIgnoredProps: array of string);
begin
  if not Assigned(AObject) then
    raise EBrook.CreateFmt('BrookSafeStringsToObject', SBrookNotNilError,
      ['AObject']);
  if not Assigned(AStrings) then
    raise EBrook.CreateFmt('BrookSafeStringsToObject', SBrookNotNilError,
      ['AStrings']);
  BrookStringsToObject(AObject, AStrings, AIgnoredProps);
end;

procedure BrookSafeStringsToObject(AObject: TObject; AStrings: TStrings;
  const AIgnoredProps: TStrings);
begin
  if not Assigned(AObject) then
    raise EBrook.CreateFmt('BrookSafeStringsToObject', SBrookNotNilError,
      ['AObject']);
  if not Assigned(AStrings) then
    raise EBrook.CreateFmt('BrookSafeStringsToObject', SBrookNotNilError,
      ['AStrings']);
  if not Assigned(AIgnoredProps) then
    raise EBrook.CreateFmt('BrookSafeStringsToObject', SBrookNotNilError,
      ['AIgnoredProps']);
  BrookStringsToObject(AObject, AStrings, AIgnoredProps);
end;

procedure BrookObjectToString(AObject: TObject; APropInfo: PPropInfo;
  out AValue: string);
begin
  if Assigned(APropInfo) then
    case APropInfo^.PropType^.Kind of
      tkAString: AValue := GetStrProp(AObject, APropInfo);
      tkChar: AValue := Char(GetOrdProp(AObject, APropInfo));
      tkInteger: AValue := IntToStr(GetOrdProp(AObject, APropInfo));
      tkInt64, tkQWord: AValue := IntToStr(GetInt64Prop(AObject, APropInfo));
      tkBool: AValue := BoolToStr(GetOrdProp(AObject, APropInfo) <> 0, True);
      tkFloat:
        case APropInfo^.PropType^.Name of
          'TDate': AValue := DateToStr(GetFloatProp(AObject, APropInfo));
          'TTime': AValue := TimeToStr(GetFloatProp(AObject, APropInfo));
          'TDateTime': AValue := DateTimeToStr(GetFloatProp(AObject, APropInfo));
          'Currency': AValue := CurrToStr(GetFloatProp(AObject, APropInfo));
        else
          AValue := FloatToStr(GetFloatProp(AObject, APropInfo));
        end;
      tkEnumeration: AValue := GetEnumProp(AObject, APropInfo);
      tkSet: AValue := GetSetProp(AObject, APropInfo, False);
    end;
end;

procedure BrookObjectToString(AObject: TObject; const AName: string;
  out AValue: string);
begin
  BrookObjectTostring(AObject,
    GetPropInfo(PTypeInfo(AObject.ClassInfo), AName), AValue);
end;

procedure BrookSafeObjectToString(AObject: TObject; const AName: string;
  out AValue: string);
begin
  if not Assigned(AObject) then
    raise EBrook.CreateFmt('BrookSafeObjectToString', SBrookNotNilError,
      ['AObject']);
  BrookObjectToString(AObject, AName, AValue);
end;

procedure BrookObjectToStrings(AObject: TObject; AStrings: TStrings);
var
  S: Char;
  V: string;
  I, C: Integer;
  PI: PPropInfo;
  PL: PPropList = nil;
begin
  C := GetPropList(PTypeInfo(AObject.ClassInfo), PL);
  if Assigned(PL) then
    try
      S := AStrings.NameValueSeparator;
      if S = NU then
        S := EQ;
      for I := 0 to Pred(C) do
      begin
        PI := PL^[I];
        BrookObjectToString(AObject, PI, V);
        AStrings.Add(PI^.Name + S + V);
      end;
    finally
      FreeMem(PL);
    end;
end;

procedure BrookObjectToStrings(AObject: TObject; AStrings: TStrings;
  const AIgnoredProps: array of string);
var
  S: Char;
  V: string;
  I, C: Integer;
  PI: PPropInfo;
  PL: PPropList = nil;
begin
  C := GetPropList(PTypeInfo(AObject.ClassInfo), PL);
  if Assigned(PL) then
    try
      S := AStrings.NameValueSeparator;
      if S = NU then
        S := EQ;
      for I := 0 to Pred(C) do
      begin
        PI := PL^[I];
        if BrookExists(PI^.Name, AIgnoredProps, True) then
          Continue;
        BrookObjectToString(AObject, PI, V);
        AStrings.Add(PI^.Name + S + V);
      end;
    finally
      FreeMem(PL);
    end;
end;

procedure BrookObjectToStrings(AObject: TObject; AStrings: TStrings;
  const AIgnoredProps: TStrings);
var
  S: Char;
  V: string;
  I, C: Integer;
  PI: PPropInfo;
  PL: PPropList = nil;
begin
  C := GetPropList(PTypeInfo(AObject.ClassInfo), PL);
  if Assigned(PL) then
    try
      S := AStrings.NameValueSeparator;
      if S = NU then
        S := EQ;
      for I := 0 to Pred(C) do
      begin
        PI := PL^[I];
        if AIgnoredProps.IndexOf(PI^.Name) > -1 then
          Continue;
        BrookObjectToString(AObject, PI, V);
        AStrings.Add(PI^.Name + S + V);
      end;
    finally
      FreeMem(PL);
    end;
end;

procedure BrookSafeObjectToStrings(AObject: TObject; AStrings: TStrings);
begin
  if not Assigned(AObject) then
    raise EBrook.CreateFmt('BrookSafeObjectToStrings', SBrookNotNilError,
      ['AObject']);
  if not Assigned(AStrings) then
    raise EBrook.CreateFmt('BrookSafeObjectToStrings', SBrookNotNilError,
      ['AStrings']);
  BrookObjectToStrings(AObject, AStrings);
end;

procedure BrookSafeObjectToStrings(AObject: TObject; AStrings: TStrings;
  const AIgnoredProps: array of string);
begin
  if not Assigned(AObject) then
    raise EBrook.CreateFmt('BrookSafeObjectToStrings', SBrookNotNilError,
      ['AObject']);
  if not Assigned(AStrings) then
    raise EBrook.CreateFmt('BrookSafeObjectToStrings', SBrookNotNilError,
      ['AStrings']);
  BrookObjectToStrings(AObject, AStrings, AIgnoredProps);
end;

procedure BrookSafeObjectToStrings(AObject: TObject; AStrings: TStrings;
  const AIgnoredProps: TStrings);
begin
  if not Assigned(AObject) then
    raise EBrook.CreateFmt('BrookSafeObjectToStrings', SBrookNotNilError,
      ['AObject']);
  if not Assigned(AStrings) then
    raise EBrook.CreateFmt('BrookSafeObjectToStrings', SBrookNotNilError,
      ['AStrings']);
  if not Assigned(AIgnoredProps) then
    raise EBrook.CreateFmt('BrookSafeObjectToStrings', SBrookNotNilError,
      ['AIgnoredProps']);
  BrookObjectToStrings(AObject, AStrings, AIgnoredProps);
end;

procedure BrookCopyObject(APropList: PPropList; const APropCount: Integer;
  AFrom, ATo: TObject);
var
  I: Integer;
  P, PI: PPropInfo;
begin
  for I := 0 to Pred(APropCount) do
  begin
    PI := APropList^[I];
    P := GetPropInfo(PTypeInfo(ATo.ClassInfo), PI^.Name);
    if Assigned(P) then
      case PI^.PropType^.Kind of
        tkAString: SetStrProp(ATo, P, GetStrProp(AFrom, PI));
        tkInteger, tkBool, tkChar, tkEnumeration, tkSet, tkClass:
          SetOrdProp(ATo, P, GetOrdProp(AFrom, PI));
        tkInt64: SetInt64Prop(ATo, P, GetInt64Prop(AFrom, PI));
        tkFloat: SetFloatProp(ATo, P, GetFloatProp(AFrom, PI));
        tkMethod: SetMethodProp(ATo, P, GetMethodProp(AFrom, PI));
      end;
  end;
end;

procedure BrookCopyObject(APropList: PPropList; const APropCount: Integer;
  AFrom, ATo: TObject; const AIgnoredProps: array of string);
var
  I: Integer;
  P, PI: PPropInfo;
begin
  for I := 0 to Pred(APropCount) do
  begin
    PI := APropList^[I];
    if BrookExists(PI^.Name, AIgnoredProps, True) then
      Continue;
    P := GetPropInfo(PTypeInfo(ATo.ClassInfo), PI^.Name);
    if Assigned(P) then
      case PI^.PropType^.Kind of
        tkAString: SetStrProp(ATo, P, GetStrProp(AFrom, PI));
        tkInteger, tkBool, tkChar, tkEnumeration, tkSet, tkClass:
          SetOrdProp(ATo, P, GetOrdProp(AFrom, PI));
        tkInt64: SetInt64Prop(ATo, P, GetInt64Prop(AFrom, PI));
        tkFloat: SetFloatProp(ATo, P, GetFloatProp(AFrom, PI));
        tkMethod: SetMethodProp(ATo, P, GetMethodProp(AFrom, PI));
      end;
  end;
end;

procedure BrookCopyObject(APropList: PPropList; const APropCount: Integer;
  AFrom, ATo: TObject; const AIgnoredProps: TStrings);
var
  I: Integer;
  P, PI: PPropInfo;
begin
  for I := 0 to Pred(APropCount) do
  begin
    PI := APropList^[I];
    if AIgnoredProps.IndexOf(PI^.Name) > -1 then
      Continue;
    P := GetPropInfo(PTypeInfo(ATo.ClassInfo), PI^.Name);
    if Assigned(P) then
      case PI^.PropType^.Kind of
        tkAString: SetStrProp(ATo, P, GetStrProp(AFrom, PI));
        tkInteger, tkBool, tkChar, tkEnumeration, tkSet, tkClass:
          SetOrdProp(ATo, P, GetOrdProp(AFrom, PI));
        tkInt64: SetInt64Prop(ATo, P, GetInt64Prop(AFrom, PI));
        tkFloat: SetFloatProp(ATo, P, GetFloatProp(AFrom, PI));
        tkMethod: SetMethodProp(ATo, P, GetMethodProp(AFrom, PI));
      end;
  end;
end;

procedure BrookCopyObject(AFrom, ATo: TObject);
var
  C: Integer;
  PL: PPropList = nil;
begin
  C := GetPropList(AFrom, PL);
  if Assigned(PL) then
    try
      BrookCopyObject(PL, C, AFrom, ATo);
    finally
      FreeMem(PL);
    end;
end;

procedure BrookCopyObject(AFrom, ATo: TObject;
  const AIgnoredProps: array of string);
var
  C: Integer;
  PL: PPropList = nil;
begin
  C := GetPropList(AFrom, PL);
  if Assigned(PL) then
    try
      BrookCopyObject(PL, C, AFrom, ATo, AIgnoredProps);
    finally
      FreeMem(PL);
    end;
end;

procedure BrookCopyObject(AFrom, ATo: TObject; const AIgnoredProps: TStrings);
var
  C: Integer;
  PL: PPropList = nil;
begin
  C := GetPropList(AFrom, PL);
  if Assigned(PL) then
    try
      BrookCopyObject(PL, C, AFrom, ATo, AIgnoredProps);
    finally
      FreeMem(PL);
    end;
end;

procedure BrookSafeCopyObject(APropList: PPropList; const APropCount: Integer;
  AFrom, ATo: TObject);
begin
  if not Assigned(APropList) then
    raise EBrook.CreateFmt('BrookSafeCopyObject', SBrookNotNilError,
      ['APropList']);
  if not Assigned(AFrom) then
    raise EBrook.CreateFmt('BrookSafeCopyObject', SBrookNotNilError,
      ['AFrom']);
  if not Assigned(ATo) then
    raise EBrook.CreateFmt('BrookSafeCopyObject', SBrookNotNilError,
      ['ATo']);
  BrookCopyObject(APropList, APropCount, AFrom, ATo);
end;

procedure BrookSafeCopyObject(APropList: PPropList; const APropCount: Integer;
  AFrom, ATo: TObject; const AIgnoredProps: array of string);
begin
  if not Assigned(APropList) then
    raise EBrook.CreateFmt('BrookSafeCopyObject', SBrookNotNilError,
      ['APropList']);
  if not Assigned(AFrom) then
    raise EBrook.CreateFmt('BrookSafeCopyObject', SBrookNotNilError,
      ['AFrom']);
  if not Assigned(ATo) then
    raise EBrook.CreateFmt('BrookSafeCopyObject', SBrookNotNilError,
      ['ATo']);
  BrookCopyObject(APropList, APropCount, AFrom, ATo, AIgnoredProps);
end;

procedure BrookSafeCopyObject(APropList: PPropList; const APropCount: Integer;
  AFrom, ATo: TObject; const AIgnoredProps: TStrings);
begin
  if not Assigned(APropList) then
    raise EBrook.CreateFmt('BrookSafeCopyObject', SBrookNotNilError,
      ['APropList']);
  if not Assigned(AFrom) then
    raise EBrook.CreateFmt('BrookSafeCopyObject', SBrookNotNilError,
      ['AFrom']);
  if not Assigned(ATo) then
    raise EBrook.CreateFmt('BrookSafeCopyObject', SBrookNotNilError,
      ['ATo']);
  if not Assigned(AIgnoredProps) then
    raise EBrook.CreateFmt('BrookSafeCopyObject', SBrookNotNilError,
      ['AIgnoredProps']);
  BrookCopyObject(APropList, APropCount, AFrom, ATo, AIgnoredProps);
end;

procedure BrookSafeCopyObject(AFrom, ATo: TObject);
begin
  if not Assigned(AFrom) then
    raise EBrook.CreateFmt('BrookSafeCopyObject', SBrookNotNilError,
      ['AFrom']);
  if not Assigned(ATo) then
    raise EBrook.CreateFmt('BrookSafeCopyObject', SBrookNotNilError,
      ['ATo']);
  BrookCopyObject(AFrom, ATo);
end;

procedure BrookSafeCopyObject(AFrom, ATo: TObject;
  const AIgnoredProps: array of string);
begin
  if not Assigned(AFrom) then
    raise EBrook.CreateFmt('BrookSafeCopyObject', SBrookNotNilError,
      ['AFrom']);
  if not Assigned(ATo) then
    raise EBrook.CreateFmt('BrookSafeCopyObject', SBrookNotNilError,
      ['ATo']);
  BrookCopyObject(AFrom, ATo, AIgnoredProps);
end;

procedure BrookSafeCopyObject(AFrom, ATo: TObject;
  const AIgnoredProps: TStrings);
begin
  if not Assigned(AFrom) then
    raise EBrook.CreateFmt('BrookSafeCopyObject', SBrookNotNilError,
      ['AFrom']);
  if not Assigned(ATo) then
    raise EBrook.CreateFmt('BrookSafeCopyObject', SBrookNotNilError,
      ['ATo']);
  if not Assigned(AIgnoredProps) then
    raise EBrook.CreateFmt('BrookSafeCopyObject', SBrookNotNilError,
      ['AIgnoredProps']);
  BrookCopyObject(AFrom, ATo, AIgnoredProps);
end;

end.
