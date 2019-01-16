unit testbrookutils;

{$mode objfpc}{$H+}

interface

uses
  BrookUtils, BrookConsts, fpcunit, testregistry, sysutils, Classes, dateutils,
  typinfo;

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

  { TTestBrookUtils }

  TTestBrookUtils = class(TTestCase)
  published
    procedure TestStartsChar;
    procedure TestEndsChar;
    procedure TestExtractPathLevels;
    procedure TestGetPathLevel;
    procedure TestGetPathLevels;
    procedure TestMacthMethod;
    procedure TestFileDate;
    procedure TestExcludeTrailingUrlDelimiter;
    procedure TestIncludeTrailingUrlDelimiter;
    procedure TestExists;
    procedure TestStringToObject;
    procedure TestStringsToObject;
    procedure TestObjectToString;
    procedure TestObjectToStrings;
    procedure TestCopyObject;
  end;

implementation

{ TTestBrookUtils }

procedure TTestBrookUtils.TestStartsChar;
begin
  AssertTrue(BrookStartsChar('a', 'abc'));
end;

procedure TTestBrookUtils.TestEndsChar;
begin
  AssertTrue(BrookEndsChar('c', 'abc'));
end;

procedure TTestBrookUtils.TestExtractPathLevels;
var
  s, r, lv: string;
  ed: Boolean = False;
begin
  s := '/a/b/c/';
  r := '';
  lv := '';
  BrookExtractPathLevels(s, r, lv, ed);
  AssertEquals('a', r);
  AssertEquals('a', lv);
  AssertTrue(ed);
  BrookExtractPathLevels(s, r, lv, ed);
  AssertEquals('a/b', r);
  AssertEquals('b', lv);
  BrookExtractPathLevels(s, r, lv, ed);
  AssertEquals('a/b/c', r);
  AssertEquals('c', lv);
end;

procedure TTestBrookUtils.TestGetPathLevel;
begin
  AssertEquals('b', BrookGetPathLevel('/a/b/c/', 1));
end;

procedure TTestBrookUtils.TestGetPathLevels;
begin
  AssertEquals('b/c/', BrookGetPathLevels('/a/b/c/', 1));
end;

procedure TTestBrookUtils.TestMacthMethod;
begin
  AssertTrue(BrookMatchMethod(rmPost, 'POST'));
end;

procedure TTestBrookUtils.TestFileDate;
var
  f: TStringList;
  fn, VPath: string;
begin
  f := TStringList.Create;
  try
    VPath := ExtractFilePath(ParamStr(0));
    fn := VPath + 'file';
    f.SaveToFile(fn);
    AssertEquals(Trunc(Now), Trunc(BrookFileDate(fn)));
    DeleteFile(fn);
  finally
    f.Free;
  end;
end;

procedure TTestBrookUtils.TestExcludeTrailingUrlDelimiter;
begin
  AssertEquals('', BrookExcludeTrailingUrlDelimiter(''));
  AssertEquals('', BrookExcludeTrailingUrlDelimiter('/'));
  AssertEquals('http://localhost',
    BrookExcludeTrailingUrlDelimiter('http://localhost/'));
end;

procedure TTestBrookUtils.TestIncludeTrailingUrlDelimiter;
begin
  AssertEquals('/', BrookIncludeTrailingUrlDelimiter(''));
  AssertEquals('/', BrookIncludeTrailingUrlDelimiter('/'));
  AssertEquals('http://localhost/',
    BrookIncludeTrailingUrlDelimiter('http://localhost'));
end;

procedure TTestBrookUtils.TestExists;
begin
  AssertTrue(BrookExists('123', ['abc', '123', 'abc123']));
  AssertTrue(BrookExists('Abc', ['ABC', '123', 'abc123'], True));
end;

procedure TTestBrookUtils.TestStringToObject;
var
  i: Integer;
  n, v: string;
  o: TMyType;
  dt: TDateTime;
  st: TStringList;
begin
  o := TMyType.Create;
  st := TStringList.Create;
  try
    dt := EncodeDateTime(2000, 12, 31, 23, 59, 59, 999);
    st.Add('MyChar=A');
    st.Add('MyString=ABC123');
    st.Add('MyInteger=123');
    st.Add('MyInt64=456');
    st.Add('MyFloat=' + FloatToStr(123.456));
    st.Add('MyCurrency=' + CurrToStr(456.789));
    st.Add('MyBoolean=on');
    st.Add('MyDateTime=' + DateTimeToStr(dt));
    st.Add('MyEnum=enum2');
    st.Add('MySet=[enum1,enum3]');
    for i := 0 to Pred(st.Count) do
    begin
      st.GetNameValue(i, n, v);
      BrookStringToObject(o, n, v);
    end;
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
    st.Free;
  end;
end;

procedure TTestBrookUtils.TestStringsToObject;
var
  o: TMyType;
  dt: TDateTime;
  st: TStringList;
begin
  o := TMyType.Create;
  st := TStringList.Create;
  try
    dt := EncodeDateTime(2000, 12, 31, 23, 59, 59, 999);
    st.Add('MyChar=A');
    st.Add('MyString=ABC123');
    st.Add('MyInteger=123');
    st.Add('MyInt64=456');
    st.Add('MyFloat=' + FloatToStr(123.456));
    st.Add('MyCurrency=' + CurrToStr(456.789));
    st.Add('MyBoolean=on');
    st.Add('MyDateTime=' + DateTimeToStr(dt));
    st.Add('MyEnum=enum2');
    st.Add('MySet=[enum1,enum3]');
    BrookStringsToObject(o, st);
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
    st.Values['MyChar'] := 'B';
    st.Values['MyInteger'] := '456';
    st.Values['MyInt64'] := '789';
    o.MyInt64 := 0;
    BrookStringsToObject(o, st, ['myint64']);
    AssertEquals(o.MyChar, 'B');
    AssertEquals(o.MyInteger, 456);
    AssertEquals(o.MyInt64, 0);
  finally
    o.Free;
    st.Free;
  end;
end;

procedure TTestBrookUtils.TestObjectToString;
var
  v: string;
  dt: TDateTime;
  o: TMyType;
  st: TStringList;
  i, c: Integer;
  pi: PPropInfo;
  pl: PPropList = nil;
begin
  o := TMyType.Create;
  st := TStringList.Create;
  c := GetPropList(o, pl);
  try
    dt := EncodeDateTime(2000, 12, 31, 23, 59, 59, 999);
    o.MyChar := 'A';
    o.MyString := 'ABC123';
    o.MyInteger :=123;
    o.MyInt64 := 456;
    o.MyFloat := 123.456;
    o.MyCurrency := 456.789;
    o.MyBoolean := True;
    o.MyDateTime := dt;
    o.MyEnum := enum2;
    o.MySet := [enum1, enum3];
    if Assigned(pl) then
      try
        for i := 0 to Pred(c) do
        begin
          pi := pl^[i];
          BrookObjectToString(o, pi, v);
          st.Add(pi^.Name + '=' + v);
        end;
      finally
        FreeMem(pl);
      end;
    AssertEquals(st.ValueFromIndex[0], 'A');
    AssertEquals(st.ValueFromIndex[1], 'ABC123');
    AssertEquals(st.ValueFromIndex[2], '123');
    AssertEquals(st.ValueFromIndex[3], '456');
    AssertEquals(st.ValueFromIndex[4], FloatToStr(123.456));
    AssertEquals(st.ValueFromIndex[5], CurrToStr(456.789));
    AssertEquals(st.ValueFromIndex[6], 'True');
    AssertEquals(st.ValueFromIndex[7], DateTimeToStr(dt));
    AssertEquals(st.ValueFromIndex[8], 'enum2');
    AssertEquals(st.ValueFromIndex[9], 'enum1,enum3');
  finally
    o.Free;
    st.Free;
  end;
end;

procedure TTestBrookUtils.TestObjectToStrings;
var
  dt: TDateTime;
  o: TMyType;
  st: TStringList;
begin
  o := TMyType.Create;
  st := TStringList.Create;
  try
    dt := EncodeDateTime(2000, 12, 31, 23, 59, 59, 999);
    o.MyChar := 'A';
    o.MyString := 'ABC123';
    o.MyInteger :=123;
    o.MyInt64 := 456;
    o.MyFloat := 123.456;
    o.MyCurrency := 456.789;
    o.MyBoolean := True;
    o.MyDateTime := dt;
    o.MyEnum := enum2;
    o.MySet := [enum1, enum3];
    BrookObjectToStrings(o, st);
    AssertEquals(st.ValueFromIndex[0], 'A');
    AssertEquals(st.ValueFromIndex[1], 'ABC123');
    AssertEquals(st.ValueFromIndex[2], '123');
    AssertEquals(st.ValueFromIndex[3], '456');
    AssertEquals(st.ValueFromIndex[4], FloatToStr(123.456));
    AssertEquals(st.ValueFromIndex[5], CurrToStr(456.789));
    AssertEquals(st.ValueFromIndex[6], 'True');
    AssertEquals(st.ValueFromIndex[7], DateTimeToStr(dt));
    AssertEquals(st.ValueFromIndex[8], 'enum2');
    AssertEquals(st.ValueFromIndex[9], 'enum1,enum3');
    st.Clear;
    o.MyChar := 'B';
    o.MyInteger := 456;
    o.MyInt64 := 789;
    st.Values['MyInt64'] := '0';
    BrookObjectToStrings(o, st, ['myint64']);
    AssertEquals(st.Values['MyChar'], 'B');
    AssertEquals(st.Values['MyInteger'], '456');
    AssertEquals(st.Values['MyInt64'], '0');
  finally
    o.Free;
    st.Free;
  end;
end;

procedure TTestBrookUtils.TestCopyObject;
var
  o1, o2: TMyType;
begin
  o1 := TMyType.Create;
  o2 := TMyType.Create;
  try
    o1.MyChar := 'A';
    o1.MyString := 'ABC123';
    o1.MyInteger :=123;
    o1.MyInt64 := 456;
    o1.MyFloat := 123.456;
    o1.MyCurrency := 456.789;
    o1.MyBoolean := True;
    o1.MyDateTime := EncodeDateTime(2000, 12, 31, 23, 59, 59, 999);
    o1.MyEnum := enum2;
    o1.MySet := [enum1, enum3];
    BrookCopyObject(o1, o2);
    AssertEquals(o1.MyChar, o2.MyChar);
    AssertEquals(o1.MyString, o2.MyString);
    AssertEquals(o1.MyInteger, o2.MyInteger);
    AssertEquals(o1.MyInt64, o2.MyInt64);
    AssertEquals(o1.MyFloat, o2.MyFloat);
    AssertEquals(o1.MyCurrency, o2.MyCurrency);
    AssertEquals(o1.MyBoolean, o2.MyBoolean);
    AssertEquals(o1.MyDateTime, o2.MyDateTime);
    AssertTrue(o1.MyEnum = o2.MyEnum);
    AssertTrue(o1.MySet = o2.MySet);
    o1.MyChar := 'B';
    o1.MyInteger := 456;
    o1.MyInt64 := 789;
    o2.MyInt64 := 0;
    BrookCopyObject(o1, o2, ['myint64']);
    AssertEquals(o2.MyChar, 'B');
    AssertEquals(o2.MyInteger, 456);
    AssertEquals(o2.MyInt64, 0);
  finally
    o1.Free;
    o2.Free;
  end;
end;

initialization
  RegisterTest(TTestBrookUtils);

end.

