unit testbrookaction;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, BrookRouter, BrookHttpDefs, BrookUtils, fpcunit, testregistry,
  HTTPDefs, Classes, sysutils, dateutils, typinfo;

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

  { TAction1 }

  TAction1 = class(TBrookAction)
  public
    procedure Get; override;
    procedure Post; override;
    procedure Put; override;
    procedure Delete; override;
    procedure Head; override;
    procedure Options; override;
  end;

  { TAction2 }

  TAction2 = class(TAction1)
  end;

  { TEntityAction }

  TEntityAction = class(specialize TBrookGAction<TMyType>)
  public
    procedure Post; override;
  end;

  { TTestBrookAction }

  TTestBrookAction = class(TTestCase)
  private
    Fac: TBrookAction;
    Fvars: TStrings;
    procedure AfterExecuteAction(ASender: TObject; AAction: TBrookAction;
      ARequest: TBrookRequest; AResponse: TBrookResponse;
      ARoute: TBrookRoute; var AHandled: Boolean);
    function Getv(const AName: string): string;
    procedure Setv(const AName: string; const AValue: string);
  public
    constructor Create; override;
    destructor Destroy; override;
    property v[const AName: string]: string read Getv write Setv;
  published
    procedure TestRegister;
    procedure TestGetPath;
    procedure TestSetCookie;
    procedure TestGetCookie;
    procedure TestDeleteCookie;
    procedure TestDoRequest;
    procedure TestRequest;
    procedure TestGetFields;
    procedure TestGetParams;
    procedure TestGetVariables;
    procedure TestUrlFor;
    procedure TestGet;
    procedure TestPost;
    procedure TestPut;
    procedure TestDelete;
    procedure TestHead;
    procedure TestOptions;
    procedure TestRedirect;
    procedure TestError;
    procedure TestStop;
    procedure TestRender;
    procedure TestClear;
    procedure TestExists;
    procedure TestWrite;
    procedure TestField;
    procedure TestParam;
    procedure TestVariable;
    procedure TestFiles;
    procedure TestFields;
    procedure TestParams;
    procedure TestVariables;
    procedure TestMethod;
    procedure TestHttpRequest;
    procedure TestHttpResponse;
  end;

  { TTestBrookGAction }

  TTestBrookGAction = class(TTestCase)
  published
    procedure TestEntity;
  end;

implementation

{ TAction1 }

procedure TAction1.Get;
begin
  Write('Test');
end;

procedure TAction1.Post;
begin
  Write('Test');
end;

procedure TAction1.Put;
begin
  Write('Test');
end;

procedure TAction1.Delete;
begin
  Write('Test');
end;

procedure TAction1.Head;
begin
  Write('Test');
end;

procedure TAction1.Options;
begin
  Write('Test');
end;

{ TEntityAction }

procedure TEntityAction.Post;
begin
  Write(Entity.MyChar);
  Write(Entity.MyString);
  Write(Entity.MyInteger);
  Write(Entity.MyInt64);
  Write(Entity.MyFloat);
  Write(Entity.MyCurrency);
  Write(Entity.MyBoolean);
  Write(DateTimeToStr(Entity.MyDateTime));
  Write(GetEnumProp(Entity, 'MyEnum'));
  Write(GetSetProp(Entity, 'MySet'));
end;

{ TTestBrookAction }

constructor TTestBrookAction.Create;
begin
  inherited Create;
  Fvars := TStringList.Create;
end;

destructor TTestBrookAction.Destroy;
begin
  Fvars.Free;
  inherited Destroy;
end;

procedure TTestBrookAction.AfterExecuteAction(ASender: TObject;
  AAction: TBrookAction; ARequest: TBrookRequest; AResponse: TBrookResponse;
  ARoute: TBrookRoute; var AHandled: Boolean);
begin
  Fac := AAction;
  Fvars.Assign(Fac.Variables);
end;

function TTestBrookAction.Getv(const AName: string): string;
begin
  Result := Fvars.Values[AName];
end;

procedure TTestBrookAction.Setv(const AName: string; const AValue: string);
begin
  Fvars.Values[AName] := AValue;
end;

procedure TTestBrookAction.TestRegister;
var
  rts: TBrookRoutes;
begin
  rts := TBrookRouter.Service.Routes;
  rts.Clear;
  TAction1.Register('/action1', rmGet, True);
  TAction2.Register('/action2', rmPost);
  AssertEquals(2, rts.Count);
  AssertEquals('TAction1', rts.Items[0]^.ActionClass.ClassName);
  AssertTrue(rts.Items[0]^.Default);
  AssertEquals('/action1', rts.Items[0]^.Pattern);
  AssertTrue(BrookSettings.Mapped);
  AssertTrue('Invalid method', rts.Items[0]^.Method = rmGet);
end;

procedure TTestBrookAction.TestGetPath;
begin
  AssertEquals('/action1', TAction1.GetPath);
end;

procedure TTestBrookAction.TestSetCookie;
var
  c: TCookie;
  a: TAction1;
  dt: TDateTime;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    dt := Now;
    a.SetCookie('mycookie', 'abc123', dt, '/mytest', 'mydomain', True, True);
    c := rs.Cookies.CookieByName('mycookie');
    AssertTrue(Assigned(c));
    AssertEquals(c.Value, 'abc123');
    AssertEquals(c.Expires, dt);
    AssertEquals(c.Path, '/mytest');
    AssertEquals(c.Domain, 'mydomain');
    AssertTrue(c.Secure);
    AssertTrue(c.HttpOnly);
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestGetCookie;
var
  a: TAction1;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    rq.CookieFields.Values['mycookie'] := 'abc123';
    AssertEquals(a.GetCookie('mycookie'), 'abc123');
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestDeleteCookie;
var
  c: TCookie;
  a: TAction1;
  dt: TDateTime;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    c := rs.Cookies.Add;
    c.Name := 'mycookie';
    c.Path := '/mypath';
    c.Domain := 'mydomain';
    c.Expire;
    c := nil;
    c := rs.Cookies.CookieByName('mycookie');
    dt := EncodeDate(1970, 1, 1);
    AssertEquals(c.Name, 'mycookie');
    AssertEquals(c.Path, '/mypath');
    AssertEquals(c.Domain, 'mydomain');
    AssertEquals(c.Expires, dt);
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestDoRequest;
var
  rq: TBrookRequest;
  rs: TBrookResponse;
  a: TBrookAction;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    rq.Method := 'GET';
    a.DoRequest(rq, rs);
    AssertEquals(Trim(rs.Contents.Text), 'Test');
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestRequest;
var
  rq: TBrookRequest;
  rs: TBrookResponse;
  a: TBrookAction;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    rq.Method := 'GET';
    a.Request(rq, rs);
    AssertEquals(Trim(rs.Contents.Text), 'Test');
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestGetFields;
var
  o: TMyType;
  dt: TDateTime;
  rq: TBrookRequest;
  rs: TBrookResponse;
  a: TBrookAction;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  o := TMyType.Create;
  try
    dt := EncodeDateTime(2000, 12, 31, 23, 59, 59, 999);
    rq.ContentFields.Add('MyChar=A');
    rq.ContentFields.Add('MyString=ABC123');
    rq.ContentFields.Add('MyInteger=123');
    rq.ContentFields.Add('MyInt64=456');
    rq.ContentFields.Add('MyFloat=' + FloatToStr(123.456));
    rq.ContentFields.Add('MyCurrency=' + CurrToStr(456.789));
    rq.ContentFields.Add('MyBoolean=on');
    rq.ContentFields.Add('MyDateTime=' + DateTimeToStr(dt));
    rq.ContentFields.Add('MyEnum=enum2');
    rq.ContentFields.Add('MySet=[enum1,enum3]');
    a.GetFields(o);
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
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestGetParams;
var
  o: TMyType;
  dt: TDateTime;
  rq: TBrookRequest;
  rs: TBrookResponse;
  a: TBrookAction;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  o := TMyType.Create;
  try
    dt := EncodeDateTime(2000, 12, 31, 23, 59, 59, 999);
    rq.QueryFields.Add('MyChar=A');
    rq.QueryFields.Add('MyString=ABC123');
    rq.QueryFields.Add('MyInteger=123');
    rq.QueryFields.Add('MyInt64=456');
    rq.QueryFields.Add('MyFloat=' + FloatToStr(123.456));
    rq.QueryFields.Add('MyCurrency=' + CurrToStr(456.789));
    rq.QueryFields.Add('MyBoolean=on');
    rq.QueryFields.Add('MyDateTime=' + DateTimeToStr(dt));
    rq.QueryFields.Add('MyEnum=enum2');
    rq.QueryFields.Add('MySet=[enum1,enum3]');
    a.GetParams(o);
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
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestGetVariables;
var
  o: TMyType;
  dt: TDateTime;
  a: TBrookAction;
begin
  a := TAction1.Create;
  o := TMyType.Create;
  try
    dt := EncodeDateTime(2000, 12, 31, 23, 59, 59, 999);
    a.Variables.Add('MyChar=A');
    a.Variables.Add('MyString=ABC123');
    a.Variables.Add('MyInteger=123');
    a.Variables.Add('MyInt64=456');
    a.Variables.Add('MyFloat=' + FloatToStr(123.456));
    a.Variables.Add('MyCurrency=' + CurrToStr(456.789));
    a.Variables.Add('MyBoolean=on');
    a.Variables.Add('MyDateTime=' + DateTimeToStr(dt));
    a.Variables.Add('MyEnum=enum2');
    a.Variables.Add('MySet=[enum1,enum3]');
    a.GetVariables(o);
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
    a.Free;
  end;
end;

procedure TTestBrookAction.TestUrlFor;
var
  a1: TAction1;
  a2: TAction2;
  rts: TBrookRoutes;
begin
  a1 := TAction1.Create;
  a2 := TAction2.Create;
  try
    rts := TBrookRouter.Service.Routes;
    rts.Clear;
    TAction1.Register('/action1', rmGet, True);
    TAction2.Register('/action2/:val', rmGet);
    AssertEquals('/action1', a1.UrlFor(TAction1));
    AssertEquals('/action2/abc', a2.UrlFor(TAction2, ['abc']));
  finally
    a1.Free;
    a2.Free;
  end;
end;

procedure TTestBrookAction.TestGet;
var
  rq: TBrookRequest;
  rs: TBrookResponse;
  a: TBrookAction;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    rq.Method := 'GET';
    a.DoRequest(rq, rs);
    AssertEquals(Trim(rs.Contents.Text), 'Test');
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestPost;
var
  rq: TBrookRequest;
  rs: TBrookResponse;
  a: TBrookAction;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    rq.Method := 'POST';
    a.DoRequest(rq, rs);
    AssertEquals(Trim(rs.Contents.Text), 'Test');
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestPut;
var
  rq: TBrookRequest;
  rs: TBrookResponse;
  a: TBrookAction;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    rq.Method := 'PUT';
    a.DoRequest(rq, rs);
    AssertEquals(Trim(rs.Contents.Text), 'Test');
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestDelete;
var
  rq: TBrookRequest;
  rs: TBrookResponse;
  a: TBrookAction;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    rq.Method := 'DELETE';
    a.DoRequest(rq, rs);
    AssertEquals(Trim(rs.Contents.Text), 'Test');
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestHead;
var
  rq: TBrookRequest;
  rs: TBrookResponse;
  a: TBrookAction;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    rq.Method := 'HEAD';
    a.DoRequest(rq, rs);
    AssertEquals(Trim(rs.Contents.Text), 'Test');
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestOptions;
var
  rq: TBrookRequest;
  rs: TBrookResponse;
  a: TBrookAction;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    rq.Method := 'OPTIONS';
    a.DoRequest(rq, rs);
    AssertEquals(Trim(rs.Contents.Text), 'Test');
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestRedirect;
var
  a: TAction1;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    a.Redirect('/some-url');
    AssertEquals('/some-url', rs.Location);
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestError;
var
  s: string;
  a: TAction1;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    try
      a.Error('Error');
    except
      on E: EBrookAction do
        s := E.Message;
    end;
    AssertEquals(s, a.ClassName + ': Error');
    try
      a.Error('Error: %s: %d', ['abc', 123]);
    except
      on E: EBrookAction do
        s := E.Message;
    end;
    AssertEquals(s, a.ClassName + ': Error: abc: 123');
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestStop;
var
  s: string;
  a: TAction1;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    try
      a.Stop('Error');
    except
      on E: EBrookAction do
        s := E.Message;
    end;
    AssertEquals(s, 'Error');
    try
      a.Stop('Error: %s: %d', ['abc', 123]);
    except
      on E: EBrookAction do
        s := E.Message;
    end;
    AssertEquals(s, 'Error: abc: 123');
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestRender;
var
  a: TAction1;
  st: TStrings;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  st := TStringList.Create;
  try
    a.Render('../LGPL.2.1.txt');
    st.LoadFromFile('../LGPL.2.1.txt');
    AssertEquals(st.Text, rs.Contents.Text);
  finally
    st.Free;
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestClear;
var
  a: TAction1;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    a.Write('Foo');
    a.Clear;
    AssertEquals('', Trim(rs.Contents.Text));
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestExists;
var
  a: TAction1;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    rq.ContentFields.Values['Foo'] := 'Value';
    AssertEquals(a.Exists('Foo'), True);
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestWrite;
var
  o: TMyType;
  a: TAction1;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  o := TMyType.Create;
  try
    a.Write('ABC');
    a.Write(123);
    a.Write(123.456);
    a.Write(True);
    AssertEquals('ABC', rs.Contents[0]);
    AssertEquals(123, StrToInt(rs.Contents[1]));
    AssertEquals(123.456, StrToFloat(rs.Contents[2]));
    AssertTrue(StrToBool(rs.Contents[3]));
    a.Clear;
    o.MyString := 'ABC';
    o.MyBoolean := True;
    o.MyInteger := 123;
    a.Write(o);
    AssertEquals('ABC', rs.Contents.Values['mystring']);
    AssertEquals(True, StrToBool(rs.Contents.Values['myboolean']));
    AssertEquals(123, StrToInt(rs.Contents.Values['myinteger']));
    a.Clear;
    o.MyString := 'ABC';
    o.MyBoolean := True;
    o.MyInteger := 123;
    a.Write(o, ['myboolean', 'myinteger']);
    AssertEquals('ABC', rs.Contents.Values['mystring']);
    AssertEquals(False, StrToBoolDef(rs.Contents.Values['myboolean'], False));
    AssertEquals(0, StrToIntDef(rs.Contents.Values['myinteger'], 0));
  finally
    o.Free;
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestField;
var
  a: TAction1;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    rq.ContentFields.Values['Foo'] := 'Value';
    AssertEquals(a.Field['Foo'], 'Value');
    a.Field['Foo'] := 'ABC123';
    AssertEquals(a.Field['Foo'], 'ABC123');
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestParam;
var
  a: TAction1;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    rq.QueryFields.Values['Foo'] := 'Value';
    AssertEquals(a.Param['Foo'], 'Value');
    a.Param['Foo'] := 'ABC123';
    AssertEquals(a.Param['Foo'], 'ABC123');
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestVariable;
var
  rq: TBrookRequest;
  rs: TBrookResponse;
  rt: TBrookRouter;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  try
    TBrookRouter.Service.Routes.Clear;
    TAction1.Register('/path/:var');
    rq.PathInfo := '/path/ABC123';
    rt := TBrookRouter.Service;
    rt.AfterExecuteAction := @AfterExecuteAction;
    rt.Route(rq, rs);
    AssertEquals(v['var'], 'ABC123');
    v['var'] := 'ABC123';
    AssertEquals(v['var'], 'ABC123');
  finally
    rs.Free;
    rq.Free;
  end;
end;

procedure TTestBrookAction.TestFiles;
var
  a: TAction1;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    AssertTrue(Assigned(a.Files));
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestFields;
var
  a: TAction1;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    rq.ContentFields.Values['Foo'] := 'Value';
    AssertEquals(a.Fields.Values['Foo'], 'Value');
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestParams;
var
  a: TAction1;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    rq.QueryFields.Values['Foo'] := 'Value';
    AssertEquals(a.Params.Values['Foo'], 'Value');
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestVariables;
var
  rq: TBrookRequest;
  rs: TBrookResponse;
  rt: TBrookRouter;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  try
    TBrookRouter.Service.Routes.Clear;
    TAction1.Register('/path/:var');
    rq.PathInfo := '/path/ABC123';
    rt := TBrookRouter.Service;
    rt.AfterExecuteAction := @AfterExecuteAction;
    rt.Route(rq, rs);
    AssertEquals(Fvars.Values['var'], 'ABC123');
  finally
    rs.Free;
    rq.Free;
  end;
end;

procedure TTestBrookAction.TestMethod;
var
  a: TBrookAction;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    rq.Method := 'TEST';
    a.DoRequest(rq, rs);
    AssertEquals(rq.Method, 'TEST');
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestHttpRequest;
var
  a: TAction1;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    AssertTrue(Assigned(a.HttpRequest));
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

procedure TTestBrookAction.TestHttpResponse;
var
  a: TAction1;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TAction1.Create(rq, rs);
  try
    AssertTrue(Assigned(a.HttpResponse));
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

{ TTestBrookGAction }

procedure TTestBrookGAction.TestEntity;
var
  a: TEntityAction;
  rq: TBrookRequest;
  rs: TBrookResponse;
  dt: TDateTime;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  a := TEntityAction.Create(rq, rs);
  try
    dt := EncodeDateTime(2000, 12, 31, 23, 59, 59, 999);
    rq.ContentFields.Add('MyChar=A');
    rq.ContentFields.Add('MyString=ABC123');
    rq.ContentFields.Add('MyInteger=123');
    rq.ContentFields.Add('MyInt64=456');
    rq.ContentFields.Add('MyFloat=' + FloatToStr(123.456));
    rq.ContentFields.Add('MyCurrency=' + CurrToStr(456.789));
    rq.ContentFields.Add('MyBoolean=on');
    rq.ContentFields.Add('MyDateTime=' + DateTimeToStr(dt));
    rq.ContentFields.Add('MyEnum=enum2');
    rq.ContentFields.Add('MySet=[enum1,enum3]');
    rq.Method := 'POST';
    a.DoRequest(rq, rs);
    AssertEquals(a.Entity.MyChar, 'A');
    AssertEquals(a.Entity.MyString, 'ABC123');
    AssertEquals(a.Entity.MyInteger, 123);
    AssertEquals(a.Entity.MyInt64, 456);
    AssertEquals(a.Entity.MyFloat, 123.456);
    AssertEquals(a.Entity.MyCurrency, 456.789);
    AssertEquals(a.Entity.MyBoolean, True);
    AssertEquals(a.Entity.MyDateTime, dt);
    AssertEquals(GetEnumProp(a.Entity, 'MyEnum'), 'enum2');
    AssertEquals(GetSetProp(a.Entity, 'MySet'), 'enum1,enum3');
  finally
    rs.Free;
    rq.Free;
    a.Free;
  end;
end;

initialization
  RegisterTest(TTestBrookAction);
  RegisterTest(TTestBrookGAction);

end.

