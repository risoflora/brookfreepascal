unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, SysUtils;

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

  { TMyAction }

  TMyAction = class(specialize TBrookGAction<TMyType>)
  public
    procedure Post; override;
  end;

implementation

{ TMyAction }

procedure TMyAction.Post;
var
  VEnum: TMyEnum;
  VMyEnum, VMySet: string;
begin
  Write('MyChar: %s<br />', [Entity.MyChar]);
  Write('MyString: %s<br />', [Entity.MyString]);
  Write('MyInteger: %d<br />', [Entity.MyInteger]);
  Write('MyInt64: %d<br />', [Entity.MyInt64]);
  Write('MyFloat: %f<br />', [Entity.MyFloat]);
  Write('MyCurrency: %m<br />', [Entity.MyCurrency]);
  Write('MyBoolean: %s<br />', [BoolToStr(Entity.MyBoolean, True)]);
  Write('MyDateTime: %s<br />', [DateTimeToStr(Entity.MyDateTime)]);
  WriteStr(VMyEnum, Entity.MyEnum);
  Write('MyEnum: %s<br />', [VMyEnum]);
  VMySet := '';
  VMyEnum := '';
  for VEnum in Entity.MySet do
  begin
    WriteStr(VMyEnum, VEnum);
    VMySet += VMyEnum + ', ';
  end;
  SetLength(VMySet, Length(VMySet) - 2);
  Write('MySet: %s<br />', [VMySet]);
end;

initialization
  TMyAction.Register('*');

end.
