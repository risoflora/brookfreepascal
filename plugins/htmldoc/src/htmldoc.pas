(*
  HTML-Doc plugin.
  Copyright (C) 2012-2014 Silvio Clecio.

  Please see the LICENSE file.
*)

unit HTMLDoc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TFormMethod = (fmGet, fmPost, fmData);

  THtmlDoc = class(TStringList)
  private
    FCharset: ShortString;
    FHead: string;
    FLanguage: ShortString;
    FTitle: string;
    function GetBody: string;
    function GetContents: string;
    procedure SetBody(AValue: string);
  protected
    class function Html: string; virtual;
  public
    constructor Create;
    procedure Write(const AString: string);
    procedure Write(const ABoolean: Boolean);
    procedure Write(const ABoolean: Boolean;
      const ATrueStr, AFalseStr: string);
    procedure Write(const AInteger: Integer);
    procedure Write(const AFloat: Double);
    procedure Write(const AFloat: Double;
      const AFormatSettings: TFormatSettings); overload;
    procedure Write(AStream: TStream);
    procedure Write(const AFmt: string; const AArgs: array of const);
    procedure Write(const AFmt: string; const AArgs: array of const;
      const AFormatSettings: TFormatSettings);
    procedure WriteLn(const AString: string);
    procedure WriteLn(const ABoolean: Boolean);
    procedure WriteLn(const ABoolean: Boolean;
      const ATrueStr, AFalseStr: string);
    procedure WriteLn(const AInteger: Integer);
    procedure WriteLn(const AFloat: Double);
    procedure WriteLn(const AFloat: Double;
      const AFormatSettings: TFormatSettings); overload;
    procedure WriteLn(const AFmt: string; const AArgs: array of const);
    procedure WriteLn(const AFmt: string; const AArgs: array of const;
      const AFormatSettings: TFormatSettings);
    procedure Link(const AHRef: string; const ATitle: string = '';
      const AClass: string = ''; const AID: string = '');
    procedure Form(const AAction, AContent: string;
      const AMethod: TFormMethod = fmPOST;
      const AClass: string = ''; const AID: string = '');
    property Contents: string read GetContents;
    property Language: ShortString read FLanguage write FLanguage;
    property Charset: ShortString read FCharset write FCharset;
    property Head: string read FHead write FHead;
    property Title: string read FTitle write FTitle;
    property Body: string read GetBody write SetBody;
  end;

implementation

constructor THtmlDoc.Create;
begin
  FLanguage := 'en';
  FCharset := 'iso-8859-1';
end;

function THtmlDoc.GetBody: string;
begin
  Result := Text;
end;

function THtmlDoc.GetContents: string;
begin
  Result := Format(THtmlDoc.Html, [FLanguage, FCharset, FTitle, FHead, Text]);
end;

procedure THtmlDoc.SetBody(AValue: string);
begin
  Text := AValue;
end;

class function THtmlDoc.Html: string;
begin
  Result :=
    '<!DOCTYPE HTML>'+#10+
    '<html lang="%s">'+#10+
    '<head>'+#10+
    '	<meta charset="%s">'+#10+
    '	<title>%s</title>'+#10+
    '%s'+#10+
    '</head>'+#10+
    '<body>'+#10+
    '%s'+#10+
    '</body>'+#10+
    '</html>';
end;

procedure THtmlDoc.Write(const AString: string);
begin
  Add(AString);
end;

procedure THtmlDoc.Write(const ABoolean: Boolean);
begin
  Add(BoolToStr(ABoolean));
end;

procedure THtmlDoc.Write(const ABoolean: Boolean; const ATrueStr,
  AFalseStr: string);
begin
  Add(BoolToStr(ABoolean, ATrueStr, AFalseStr));
end;

procedure THtmlDoc.Write(const AInteger: Integer);
begin
  Add(IntToStr(AInteger));
end;

procedure THtmlDoc.Write(const AFloat: Double);
begin
  Add(FloatToStr(AFloat));
end;

procedure THtmlDoc.Write(const AFloat: Double;
  const AFormatSettings: TFormatSettings);
begin
  Add(FloatToStr(AFloat, AFormatSettings));
end;

procedure THtmlDoc.Write(AStream: TStream);
begin
  LoadFromStream(AStream);
end;

procedure THtmlDoc.Write(const AFmt: string; const AArgs: array of const);
begin
  Add(Format(AFmt, AArgs));
end;

procedure THtmlDoc.Write(const AFmt: string; const AArgs: array of const;
  const AFormatSettings: TFormatSettings);
begin
  Add(Format(AFmt, AArgs, AFormatSettings));
end;

procedure THtmlDoc.WriteLn(const AString: string);
begin
  Add(AString + '<br />');
end;

procedure THtmlDoc.WriteLn(const ABoolean: Boolean);
begin
  Add(BoolToStr(ABoolean) + '<br />');
end;

procedure THtmlDoc.WriteLn(const ABoolean: Boolean; const ATrueStr,
  AFalseStr: string);
begin
  Add(BoolToStr(ABoolean, ATrueStr, AFalseStr) + '<br />');
end;

procedure THtmlDoc.WriteLn(const AInteger: Integer);
begin
  Add(IntToStr(AInteger) + '<br />');
end;

procedure THtmlDoc.WriteLn(const AFloat: Double);
begin
  Add(FloatToStr(AFloat) + '<br />');
end;

procedure THtmlDoc.WriteLn(const AFloat: Double;
  const AFormatSettings: TFormatSettings);
begin
  Add(FloatToStr(AFloat, AFormatSettings) + '<br />');
end;

procedure THtmlDoc.WriteLn(const AFmt: string; const AArgs: array of const);
begin
  Add(Format(AFmt, AArgs) + '<br />');
end;

procedure THtmlDoc.WriteLn(const AFmt: string; const AArgs: array of const;
  const AFormatSettings: TFormatSettings);
begin
  Add(Format(AFmt, AArgs, AFormatSettings) + '<br />');
end;

procedure THtmlDoc.Link(const AHRef: string; const ATitle: string;
  const AClass: string; const AID: string);
var
  VID: string = '';
  VClass: string = '';
begin
  if AClass <> '' then
    VClass := ' class="' + AClass + '" ';
  if AID <> '' then
    VID := ' id="' + AID + '" ';
  Add('<a href="' + AHRef + '"' + VClass + VID + '>' + ATitle + '</a>');
end;

procedure THtmlDoc.Form(const AAction, AContent: string;
  const AMethod: TFormMethod; const AClass: string; const AID: string);
var
  VID: string = '';
  VClass: string = '';
begin
  if AClass <> '' then
    VClass := ' class="' + AClass + '" ';
  if AID <> '' then
    VID := ' id="' + AID + '" ';
  case AMethod of
    fmGet: Add('<form action="' + AAction + '"' + VClass + VID + '>' +
      AContent + '</form>');
    fmPost: Add('<form action="' + AAction + '" method="post"' +
      VClass + VID + '>' + AContent + '</form>');
    fmData: Add('<form action="' + AAction + '" method="post" ' +
      'enctype="multipart/form-data"' + VClass + VID + '>' +
      AContent + '</form>');
  end;
end;

end.
