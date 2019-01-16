unit testbrooksession;

{$mode objfpc}{$H+}

interface

uses
  BrookSession, BrookHttpDefs, BrookConsts, BrookUtils, fpcunit, testregistry,
  sysutils, dateutils;

type
  TMyEnum = (enum1, enum2, enum3);

  TMySet = set of TMyEnum;

  { TMyType }

  TMyType = class
  private
    FMyBoolean: Boolean;
    FMyChar: Char;
    FMyCurrency: Currency;
    FMyDateTime: TDateTime;
    FMyEnum: TMyEnum;
    FMyFloat: Double;
    FMyInt64: Int64;
    FMyInteger: Integer;
    FMySet: TMySet;
    FMyString: string;
  published
    property MyChar: Char read FMyChar write FMyChar;
    property MyString: string read FMyString write FMyString;
    property MyInteger: Integer read FMyInteger write FMyInteger;
    property MyInt64: Int64 read FMyInt64 write FMyInt64;
    property MyFloat: Double read FMyFloat write FMyFloat;
    property MyCurrency: Currency read FMyCurrency write FMyCurrency;
    property MyBoolean: Boolean read FMyBoolean write FMyBoolean;
    property MyDateTime: TDateTime read FMyDateTime write FMyDateTime;
    property MyEnum: TMyEnum read FMyEnum write FMyEnum;
    property MySet: TMySet read FMySet write FMySet;
  end;

  { TTestBrookSession }

  TTestBrookSession = class(TTestCase)
  published
    procedure TestGetFields;
    procedure TestIsExpired;
    procedure TestIsEmpty;
    procedure TestGenerateID;
    procedure TestExpire;
    procedure TestExists;
    procedure TestExpired;
  end;

var
  TEST_COOKIE: string = '';
  TEST_SESS_PATH: string = '';

implementation

procedure DeleteFiles(APath: string; const ABeforeOf: TDateTime;
  const ASkippedFile: TFileName; const AContains: string);

  function IsOldFile(const fn: TFileName; const dt: TDateTime): Boolean; inline;
  begin
    if dt = NullDate then
      Result := True
    else
      Result := BrookFileDate(fn) < dt;
  end;

var
  r: Integer;
  fn: TFileName;
  sr: TSearchRec;
begin
  APath := IncludeTrailingPathDelimiter(APath);
  r := FindFirst(APath + AK, faArchive, sr);
  try
    if AContains = ES then
      while r = 0 do
      begin
        fn := APath + sr.Name;
        if (fn <> ASkippedFile) and (sr.Name <> '..') and
          (sr.Name <> dt) and IsOldFile(fn, ABeforeOf) then
          DeleteFile(fn);
        r := FindNext(sr);
      end
    else
      while r = 0 do
      begin
        fn := APath + sr.Name;
        if (fn <> ASkippedFile) and (sr.Name <> '..') and
          (Pos(AContains, sr.Name) <> 0) and (sr.Name <> dt) and
          IsOldFile(fn, ABeforeOf) then
          DeleteFile(fn);
        r := FindNext(sr);
      end;
  finally
    FindClose(sr);
  end;
end;

{ TTestBrookSession }

procedure TTestBrookSession.TestGetFields;
var
  o: TMyType;
  se: TBrookSession;
  dt: TDateTime;
begin
  o := TMyType.Create;
  se := TBrookSession.Create(nil);
  try
    dt := EncodeDateTime(2000, 12, 31, 23, 59, 59, 999);
    se.Fields.Add('MyChar=A');
    se.Fields.Add('MyString=ABC123');
    se.Fields.Add('MyInteger=123');
    se.Fields.Add('MyInt64=456');
    se.Fields.Add('MyFloat=' + FloatToStr(123.456));
    se.Fields.Add('MyCurrency=' + CurrToStr(456.789));
    se.Fields.Add('MyBoolean=on');
    se.Fields.Add('MyDateTime=' + DateTimeToStr(dt));
    se.Fields.Add('MyEnum=enum2');
    se.Fields.Add('MySet=[enum1,enum3]');
    se.GetFields(o);
    AssertEquals(o.MyChar, 'A');
    AssertEquals(o.MyString, 'ABC123');
    AssertEquals(o.MyInteger, 123);
    AssertEquals(o.MyInt64, 456);
    AssertEquals(o.MyFloat, 123.456);
    AssertEquals(o.MyCurrency, 456.789);
    AssertEquals(o.MyBoolean, True);
    AssertEquals(o.MyDateTime, dt);
    AssertTrue(o.MyEnum = enum2);
    AssertTrue(o.MySet = [enum1, enum3]);
  finally
    o.Free;
    se.Free;
  end;
end;

procedure TTestBrookSession.TestIsExpired;
var
  co: string;
  rq: TBrookRequest;
  rs: TBrookResponse;
  se: TBrookSession;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  se := TBrookSession.Create(nil);
  try
    se.Directory := TEST_SESS_PATH;
    se.Start(rq);
    se.Finish(rs);
    co := rs.Cookies.CookieByName(BROOK_SESS_ID).Value;
    if co <> '' then
      rq.CookieFields.Values[BROOK_SESS_ID] := co;
    se.Start(rq);
    FileSetDate(se.FileName, DateTimeToFileDate(EncodeDate(2000, 1, 1)));
    AssertTrue(se.IsExpired);
    DeleteFiles(se.Directory, NullDate, ES, BROOK_SESS_PREFIX);
  finally
    rs.Free;
    rq.Free;
    se.Free;
  end;
end;

procedure TTestBrookSession.TestIsEmpty;
var
  se: TBrookSession;
begin
  se := TBrookSession.Create(nil);
  try
    AssertTrue(se.IsEmpty);
  finally
    se.Free;
  end;
end;

procedure TTestBrookSession.TestGenerateID;
var
  rq: TBrookRequest;
  rs: TBrookResponse;
  se: TBrookSession;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  se := TBrookSession.Create(nil);
  try
    se.Directory := TEST_SESS_PATH;
    se.Start(rq);
    AssertEquals(32, Length(se.GenerateID));
    se.Finish(rs);
  finally
    rs.Free;
    rq.Free;
    se.Free;
  end;
end;

procedure TTestBrookSession.TestExpire;
var
  rq: TBrookRequest;
  rs: TBrookResponse;
  se: TBrookSession;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  se := TBrookSession.Create(nil);
  try
    se.Directory := TEST_SESS_PATH;
    if TEST_COOKIE <> '' then
      rq.CookieFields.Values[BROOK_SESS_ID] := TEST_COOKIE;
    se.Start(rq);
    if se.Fields.Count = 0 then
    begin
      se.Fields.Add('field1=abc');
      se.Fields.Add('field2=123');
    end;
    se.Finish(rs);
    TEST_COOKIE := rs.Cookies.CookieByName(BROOK_SESS_ID).Value;
    if TEST_COOKIE <> '' then
      rq.CookieFields.Values[BROOK_SESS_ID] := TEST_COOKIE;
    se.Start(rq);
    AssertEquals('abc', se.Fields.Values['field1']);
    AssertEquals('123', se.Fields.Values['field2']);
    se.Expire(rq, rs);
    se.Finish(rs);
    if rs.Cookies.CookieByName(BROOK_SESS_ID).Expires =
      EncodeDate(1970, 1, 1) then
      rs.Cookies.Clear;
    se.Start(rq);
    AssertTrue(se.Fields.Count = 0);
    se.Finish(rs);
  finally
    rs.Free;
    rq.Free;
    se.Free;
  end;
end;

procedure TTestBrookSession.TestExists;
var
  se: TBrookSession;
begin
  se := TBrookSession.Create(nil);
  try
    se.Fields.Add('foo=abc');
    AssertTrue(se.Exists('foo'));
  finally
    se.Free;
  end;
end;

procedure TTestBrookSession.TestExpired;
var
  rq: TBrookRequest;
  rs: TBrookResponse;
  se: TBrookSession;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  se := TBrookSession.Create(nil);
  try
    se.Directory := TEST_SESS_PATH;
    if TEST_COOKIE <> '' then
      rq.CookieFields.Values[BROOK_SESS_ID] := TEST_COOKIE;
    se.Start(rq);
    se.Expire(rq, rs);
    AssertTrue(se.Expired);
    se.Finish(rs);
  finally
    rs.Free;
    rq.Free;
    se.Free;
  end;
end;

initialization
  TEST_SESS_PATH := ExtractFilePath(ParamStr(0));
  RegisterTest(TTestBrookSession);

finalization
  DeleteFiles(TEST_SESS_PATH, NullDate, '', BROOK_SESS_PREFIX);

end.

