unit testbrookconfigurator;

{$mode objfpc}{$H+}

interface

uses
  BrookConfigurator, BrookUtils, BrookConsts, fpcunit, testregistry, sysutils;

type
  TMyEnum = (enum1, enum2, enum3);

  TMySet = set of TMyEnum;

  { TTarget1 }

  TTarget1 = class
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

  { TTarget2 }

  TTarget2 = class(TTarget1)
  end;

  { TTestBrookConfigurator }

  TTestBrookConfigurator = class(TTestCase)
  public
    constructor Create; override;
  published
    procedure TestConfigureFromString;
    procedure TestConfigureFromFile;
    procedure TestClassChecking;
  end;

implementation

{ TTestBrookConfigurator }

constructor TTestBrookConfigurator.Create;
begin
  inherited Create;
  BrookSettings.Configuration := '';
  with DefaultFormatSettings do
  begin
    DecimalSeparator := ',';
    ThousandSeparator := '.';
    ShortDateFormat := 'yyyy/mm/dd';
    ShortTimeFormat := 'hh:nn:ss';
    DateSeparator := '/';
    TimeSeparator := ':';
  end;
end;

procedure TTestBrookConfigurator.TestConfigureFromString;
var
  tg: TTarget1;
  cf: TBrookConfigurator;
begin
  cf := TBrookConfigurator.Create(
    'mychar=A;mystring=ABC;myinteger=123;myint64=456;myfloat=12,3;' +
    'mycurrency=45,6;myboolean=true;mydatetime=2014/02/01 11:59:01;' +
    'myenum=enum2;myset=[enum1, enum3]');
  tg := TTarget1.Create;
  try
    cf.Target := tg;
    cf.Configure;
    AssertEquals('A', tg.MyChar);
    AssertEquals('ABC', tg.MyString);
    AssertEquals(123, tg.MyInteger);
    AssertEquals(456, tg.MyInt64);
    AssertEquals(12.3, tg.MyFloat);
    AssertEquals(45.6, tg.MyCurrency);
    AssertTrue(tg.MyBoolean);
    AssertEquals(StrToDateTime('2014/02/01 11:59:01'), tg.MyDateTime);
    AssertTrue(tg.MyEnum = enum2);
    AssertTrue(tg.MySet = [enum1, enum3]);
  finally
    tg.Free;
    cf.Free;
  end;
end;

procedure TTestBrookConfigurator.TestConfigureFromFile;
var
  tg: TTarget1;
  cf: TBrookConfigurator;
begin
  BrookSettings.Configuration := '';
  cf := TBrookConfigurator.Create(ExtractFilePath(ParamStr(0)) + 'test.cfg');
  tg := TTarget1.Create;
  try
    cf.Target := tg;
    cf.Configure;
    AssertEquals('A', tg.MyChar);
    AssertEquals('ABC', tg.MyString);
    AssertEquals(123, tg.MyInteger);
    AssertEquals(456, tg.MyInt64);
    AssertEquals(12.3, tg.MyFloat);
    AssertEquals(45.6, tg.MyCurrency);
    AssertTrue(tg.MyBoolean);
    AssertEquals(StrToDateTime('2014/02/01 11:59:01'), tg.MyDateTime);
    AssertTrue(tg.MyEnum = enum2);
    AssertTrue(tg.MySet = [enum1, enum3]);
  finally
    tg.Free;
    cf.Free;
  end;
end;

procedure TTestBrookConfigurator.TestClassChecking;
var
  tg1: TTarget1;
  tg2: TTarget2;
  cf: TBrookConfigurator;
begin
  cf := TBrookConfigurator.Create(
    'ttarget2.mychar=A;ttarget2.mystring=ABC;ttarget2.myinteger=123;' +
    'ttarget2.myint64=456;ttarget2.myfloat=12,3;ttarget2.mycurrency=45,6;' +
    'ttarget2.myboolean=true;ttarget2.mydatetime=2014/02/01 11:59:01;' +
    'ttarget2.myenum=enum2;ttarget2.myset=[enum1, enum3]');
  tg1 := TTarget1.Create;
  tg2 := TTarget2.Create;
  try
    cf.ClassChecking := True;
    cf.Target := tg1;
    cf.Configure;
    AssertEquals(#0, tg1.MyChar);
    AssertEquals('', tg1.MyString);
    AssertEquals(0, tg1.MyInteger);
    AssertEquals(0, tg1.MyInt64);
    AssertEquals(0, tg1.MyFloat);
    AssertEquals(0, tg1.MyCurrency);
    AssertFalse(tg1.MyBoolean);
    AssertEquals(NullDateTime, tg1.MyDateTime);
    AssertTrue(tg1.MyEnum = enum1);
    AssertTrue(tg1.MySet = []);
    cf.Target := tg2;
    cf.Configure;
    AssertEquals('A', tg2.MyChar);
    AssertEquals('ABC', tg2.MyString);
    AssertEquals(123, tg2.MyInteger);
    AssertEquals(456, tg2.MyInt64);
    AssertEquals(12.3, tg2.MyFloat);
    AssertEquals(45.6, tg2.MyCurrency);
    AssertTrue(tg2.MyBoolean);
    AssertEquals(StrToDateTime('2014/02/01 11:59:01'), tg2.MyDateTime);
    AssertTrue(tg2.MyEnum = enum2);
    AssertTrue(tg2.MySet = [enum1, enum3]);
  finally
    tg1.Free;
    tg2.Free;
    cf.Free;
  end;
end;

initialization
  RegisterTest(TTestBrookConfigurator);

end.

