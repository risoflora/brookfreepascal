(*
  Captcha plugin.
  Copyright (C) 2012-2014 Silvio Clecio.

  Please see the LICENSE file.
*)

unit Captcha;

{$mode objfpc}{$H+}

interface

uses
  FPCanvas, FPImage, FPImgCanv, FTFont, Classes, SysUtils;

const
  colDkTeal: TFPColor = (Red: $0000; Green: $2000; Blue: $5000;
    Alpha: AlphaOpaque);
  ftLiberationSerifRegularTTF = 'LiberationSerif-Regular.ttf';

type
  TCaptchaType = (ctNoise, ctLine);

  { TMemoryImage }

  TMemoryImage = class(TFPMemoryImage)
  public
    constructor Create; overload;
  end;

  { TCaptcha }

  TCaptcha = class
  public
    class function FontExists(const AFileName: TFileName): Boolean;
    class function Generate(AImage: TMemoryImage;
      const AFontColor: TFPColor; const AFontName: ShortString =
      ftLiberationSerifRegularTTF; const AFontSize: Byte = 18;
      const AEasyRead: Byte = 3; const ABackground: Boolean = True;
      const ACaptchaType: TCaptchaType = ctLine): string; overload;
    class function Generate(AImage: TMemoryImage;
      const ACaptchaType: TCaptchaType = ctLine): string; overload;
    class function Generate(AStream: TStream;
      const ACaptchaType: TCaptchaType = ctLine): string; overload;
  end;

implementation

{ TMemoryImage }

constructor TMemoryImage.Create;
begin
  inherited Create(100, 100);
end;

{ TCaptcha }

class function TCaptcha.FontExists(const AFileName: TFileName): Boolean;
{$IFDEF UNIX}
const
  VFontPath = '/usr/share/fonts';
{$ENDIF}
begin
  Result := FileExists(AFileName) or
{$IFDEF UNIX}
   (FileExists(IncludeTrailingPathDelimiter(GetEnvironmentVariable('HOME')) +
     '.fonts/' + AFileName)) or
   (FileExists(VFontPath + AFileName)) or
   (FileExists(VFontPath + '/truetype/' + AFileName)) or
   (FileExists(VFontPath + '/truetype/freefont/')) ;
{$ENDIF}
{$IFDEF MSWINDOWS}
    FileExists(IncludeTrailingPathDelimiter(GetEnvironmentVariable('windir')) +
      'Fonts' + DirectorySeparator + AFileName);
{$ENDIF}
end;

{$WARNINGS OFF}
class function TCaptcha.Generate(AImage: TMemoryImage;
  const AFontColor: TFPColor; const AFontName: ShortString;
  const AFontSize: Byte; const AEasyRead: Byte; const ABackground: Boolean;
  const ACaptchaType: TCaptchaType): string;

  function _Min(A, B: Integer): Integer;
  begin
    if A < B then
      Result := A
    else
      Result := B;
  end;

  function _RandomRange(const AFrom, ATo: Integer): Integer;
  begin
    Result := Random(Abs(AFrom - ATo)) + _Min(ATo, AFrom);
  end;

const
  NUMBERS = '0123456789';
  ALPHA_NUMERIC = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' + NUMBERS;
var
  I: Integer;
  VFont: TFreeTypeFont;
  VCanvas: TFPImageCanvas;
begin
  VFont := TFreeTypeFont.Create;
  VCanvas := TFPImageCanvas.Create(AImage);
  AImage.SetSize(80, 20);
  try
    VFont.Name := AFontName;
    VFont.Size := AFontSize;
    VFont.FPColor := AFontColor;
    VCanvas.Font := VFont;
    if ABackground then
    begin
      VCanvas.Brush.FPColor := colWhite;
      VCanvas.Brush.Style := bsSolid;
      VCanvas.FillRect(0, 0, VCanvas.Width, VCanvas.Height);
    end;
    VCanvas.Clear;
    VCanvas.Pen.FPColor := VFont.FPColor;
    if ACaptchaType = ctNoise then
    begin
      for I := 0 to (AImage.Width * AImage.Height) div AEasyRead do
        VCanvas.EllipseC(_RandomRange(0, AImage.Width),
          _RandomRange(0, AImage.Height), 0, 0);
      for I := 1 to 6 do
        Result += Copy(NUMBERS, _RandomRange(0, Length(NUMBERS) - 1), 1);
      VCanvas.TextOut((VCanvas.Width div 2) -
        (VCanvas.GetTextWidth(Result) div 2),
        (VCanvas.Height div 2) + (VCanvas.GetTextHeight(Result) div 2),
        Result);
    end
    else
    begin
      for I := 0 to 3 do
        Result += ALPHA_NUMERIC[Random(Length(ALPHA_NUMERIC) - 1) + 1];
      for I := 0 to 3 do
      begin
        VCanvas.Font.Size := _RandomRange(4, 12) + 6;
        VCanvas.TextOut(I * 22, 16, Result[I + 1]);
      end;
      for I := 0 to AEasyRead do
      begin
        VCanvas.MoveTo(Random(AImage.Width), 0);
        VCanvas.LineTo(Random(AImage.Width), AImage.Height);
      end;
    end;
  finally
    VFont.Free;
    VCanvas.Free;
  end;
end;
{$WARNINGS ON}

class function TCaptcha.Generate(AImage: TMemoryImage;
  const ACaptchaType: TCaptchaType): string;
begin
  Result := Generate(AImage, colDkTeal, ftLiberationSerifRegularTTF, 18, 3,
    True, ACaptchaType);
end;

class function TCaptcha.Generate(AStream: TStream;
  const ACaptchaType: TCaptchaType): string;
var
  VImage: TMemoryImage;
  VWriter: TFPCustomImageWriter;
begin
  VImage := TMemoryImage.Create;
  VWriter := ImageHandlers.ImageWriter[ImageHandlers.TypeNames[0]].Create;
  try
    Result := Generate(VImage, ACaptchaType);
    VImage.SaveToStream(AStream, VWriter);
  finally
    VImage.Free;
    VWriter.Free;
  end;
end;

initialization
  Randomize;

end.
