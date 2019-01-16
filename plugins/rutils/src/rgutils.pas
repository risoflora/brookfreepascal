(*
  RUtils plugin.
  Copyright (C) 2012-2014 Silvio Clecio.

  Please see the LICENSE file.
*)

unit RGUtils;

{$mode objfpc}{$H+}

interface

uses
  FPimage, FPImgCanv, Classes, SysUtils;

type
  TGraphicType = (
    gtUnknown, gtBMP, gtIcon, gtJPEG, gtGIF, gtXPM, gtPNG, gtPNM, gtTiff
  );

  EGraphic = class(Exception);

var
  SCreateGraphicWriterError: string = 'CreateGraphicWriter: Unknown writer.';
  SCreateGraphicReaderError: string = 'CreateGraphicReader: Unknown reader.';

{ Math }

function GetGraphicRect(ASourceWidth, ASourceHeight, ADestinationWidth,
  ADestinationHeight: Integer; const AStretch, AProportional,
  ACenter: Boolean): TRect;

{ Graphic }

function GetGraphicWriterClass(
  const AGraphicType: TGraphicType): TFPCustomImageWriterClass;
function GetGraphicReaderClass(
  const AGraphicType: TGraphicType): TFPCustomImageReaderClass;
function GraphicTypeToString(const AGraphicType: TGraphicType): string;
function StringToGraphicType(const S: string): TGraphicType;
function TestIsBMP(AStream: TStream): Boolean; overload;
function TestIsBMP(const AFileName: TFileName): Boolean; overload;
function TestIsIcon(AStream: TStream): Boolean; overload;
function TestIsIcon(const AFileName: TFileName): Boolean; overload;
function TestIsJPEG(AStream: TStream): Boolean; overload;
function TestIsJPEG(const AFileName: TFileName): Boolean; overload;
function TestIsGIF(AStream: TStream): Boolean; overload;
function TestIsGIF(const AFileName: TFileName): Boolean; overload;
function TestIsXPM(AStream: TStream): Boolean; overload;
function TestIsXPM(const AFileName: TFileName): Boolean; overload;
function TestIsPNG(AStream: TStream): Boolean; overload;
function TestIsPNG(const AFileName: TFileName): Boolean; overload;
function TestIsPNM(AStream: TStream): Boolean; overload;
function TestIsPNM(const AFileName: TFileName): Boolean; overload;
function TestIsTiff(AStream: TStream): Boolean; overload;
function TestIsTiff(const AFileName: TFileName): Boolean; overload;
function GetGraphicType(AStream: TStream): TGraphicType; overload;
function GetGraphicType(const AFileName: TFileName): TGraphicType; overload;
function GetGraphicTypeString(AStream: TStream): string; overload;
function GetGraphicTypeString(const AFileName: TFileName): string; overload;
function IsGraphicSupported(AStream: TStream): Boolean; overload;
function IsGraphicSupported(const AFileName: TFileName): Boolean; overload;
procedure ResizeGraphic(ASource, ADestination: TFPMemoryImage;
  const AStretch: Boolean = True; const AProportional: Boolean = True;
  const ACenter: Boolean = True); overload;
function CreateGraphicWriter(
  const AGraphicType: TGraphicType): TFPCustomImageWriter;
function CreateGraphicReader(
  const AGraphicType: TGraphicType): TFPCustomImageReader;

implementation

{ Math }

function GetGraphicRect(ASourceWidth, ASourceHeight, ADestinationWidth,
  ADestinationHeight: Integer; const AStretch, AProportional,
  ACenter: Boolean): TRect;
var
  VWidth, VHeight: Integer;
begin
  if AProportional and (((ASourceWidth > ADestinationWidth) or
    (ASourceHeight > ADestinationHeight)) and (ASourceWidth > 0) and
    (ASourceHeight > 0)) then
  begin
    VWidth := ADestinationWidth;
    VHeight := (ASourceHeight * VWidth) div ASourceWidth;
    if VHeight > ADestinationHeight then
    begin
      VHeight := ADestinationHeight;
      VWidth := (ASourceWidth * VHeight) div ASourceHeight;
    end;
    ASourceWidth := VWidth;
    ASourceHeight := VHeight;
  end
  else
    if AStretch then
    begin
      ASourceWidth := ADestinationWidth;
      ASourceHeight := ADestinationHeight;
    end;
  Result := Rect(0, 0, ASourceWidth, ASourceHeight);
  if ACenter then
    Result := Rect((ADestinationWidth div 2) - (ASourceWidth div 2),
      (ADestinationHeight div 2) - (ASourceHeight div 2),
      ASourceWidth, ASourceHeight);
end;

{ Graphic }

function GetGraphicWriterClass(
  const AGraphicType: TGraphicType): TFPCustomImageWriterClass;
begin
  case AGraphicType of
    gtUnknown: Result := nil;
    gtBMP: Result := ImageHandlers.ImageWriter['BMP Format'];
    gtIcon: Result := nil;
    gtJPEG: Result := ImageHandlers.ImageWriter['JPEG graphics'];
    gtGIF: Result := ImageHandlers.ImageWriter['GIF Graphics'];
    gtXPM: Result := ImageHandlers.ImageWriter['XPM Format'];
    gtPNG: Result := ImageHandlers.ImageWriter['Portable Network Graphics'];
    gtPNM: Result := ImageHandlers.ImageWriter['Netpbm Portable aNyMap'];
    gtTiff: Result := ImageHandlers.ImageWriter['Tagged Image File Format'];
  end;
end;

function GetGraphicReaderClass(
  const AGraphicType: TGraphicType): TFPCustomImageReaderClass;
begin
  case AGraphicType of
    gtUnknown: Result := nil;
    gtBMP: Result := ImageHandlers.ImageReader['BMP Format'];
    gtIcon: Result := nil;
    gtJPEG: Result := ImageHandlers.ImageReader['JPEG Graphics'];
    gtGIF: Result := ImageHandlers.ImageReader['GIF Graphics'];
    gtXPM: Result := ImageHandlers.ImageReader['XPM Format'];
    gtPNG: Result := ImageHandlers.ImageReader['Portable Network Graphics'];
    gtPNM: Result := ImageHandlers.ImageReader['Netpbm format'];
    gtTiff: Result := ImageHandlers.ImageReader['Tagged Image File Format'];
  end;
end;

function GraphicTypeToString(const AGraphicType: TGraphicType): string;
const
  CGraphicTypes: array[TGraphicType] of string = ('Unknown', 'BMP', 'Icon',
    'JPEG', 'GIF', 'XPM', 'PNG', 'PNM', 'Tiff');
begin
  Result := CGraphicTypes[AGraphicType];
end;

function StringToGraphicType(const S: string): TGraphicType;
var
  VGT: string;
begin
  VGT := LowerCase(S);
  case VGT of
    'unknown': Result := gtUnknown;
    'bmp': Result := gtBMP;
    'ico', 'icon': Result := gtIcon;
    'jpg', 'jpeg': Result := gtJPEG;
    'gif': Result := gtGIF;
    'xpm': Result := gtXPM;
    'png': Result := gtPNG;
    'pbm', 'pgm', 'ppm': Result := gtPNM;
    'tif', 'tiff': Result := gtTiff;
  end;
end;

{$HINTS OFF}
function TestIsBMP(AStream: TStream): Boolean;
var
  VSignature: array[0..1] of Char;
  VReadSize: Integer;
  VOldPosition: Int64;
begin
  VOldPosition := AStream.Position;
  try
    VReadSize := AStream.Read(VSignature, SizeOf(VSignature));
    Result := (VReadSize = 2) and (VSignature[0] = 'B') and (VSignature[1] = 'M');
  finally
    AStream.Position := VOldPosition;
  end;
end;
{$HINTS ON}

function TestIsBMP(const AFileName: TFileName): Boolean;
var
  VFile: TFileStream;
begin
  VFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := TestIsBMP(VFile);
  finally
    VFile.Free;
  end;
end;

{$HINTS OFF}
function TestIsIcon(AStream: TStream): Boolean;
const
  CIconSignature: array [0..3] of Char = #0#0#1#0;
var
  VSignature: array[0..3] of Char;
  VReadSize: Integer;
  VOldPosition: Int64;
begin
  VOldPosition := AStream.Position;
  try
    VReadSize := AStream.Read(VSignature, SizeOf(VSignature));
    Result := (VReadSize = SizeOf(VSignature)) and
      CompareMem(@VSignature, @CIconSignature, 4);
  finally
    AStream.Position := VOldPosition;
  end;
end;
{$HINTS ON}

function TestIsIcon(const AFileName: TFileName): Boolean;
var
  VFile: TFileStream;
begin
  VFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := TestIsIcon(VFile);
  finally
    VFile.Free;
  end;
end;

function TestIsJPEG(AStream: TStream): Boolean;
var
  VSOI: Word;
  VOldPosition: Int64;
begin
  VOldPosition := AStream.Position;
  try
    VSOI := 0;
    AStream.Read(VSOI, SizeOf(VSOI));
    Result := VSOI = NtoLE($D8FF);
  finally
    AStream.Position := VOldPosition;
  end;
end;

function TestIsJPEG(const AFileName: TFileName): Boolean;
var
  VFile: TFileStream;
begin
  VFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := TestIsJPEG(VFile);
  finally
    VFile.Free;
  end;
end;

{$HINTS OFF}
function TestIsGIF(AStream: TStream): Boolean;
var
  VOldPosition: Int64;
  VSignature: array [0..5] of Char;
begin
  VOldPosition := AStream.Position;
  try
    AStream.Read(VSignature, SizeOf(VSignature));
    Result := (VSignature = 'GIF89a') or (VSignature = 'GIF87a');
  finally
    AStream.Position := VOldPosition;
  end;
end;
{$HINTS ON}

function TestIsGIF(const AFileName: TFileName): Boolean;
var
  VFile: TFileStream;
begin
  VFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := TestIsGIF(VFile);
  finally
    VFile.Free;
  end;
end;

function TestIsXPM(AStream: TStream): Boolean;
type
  TXPMRange = (xrCode, xrStaticKeyWord, xrCharKeyWord);

  function Check(const S: string): Boolean;
  var
    VBuf: string;
  begin
    Result := False;
    SetLength(VBuf, Length(S));
    if AStream.Read(VBuf[1], Length(VBuf)) <> Length(VBuf) then
      Exit;
    if VBuf <> S then
      Exit;
    Result := True;
  end;

var
  C, VLastChar: Char;
  VRange: TXPMRange;
  VOldPosition: Int64;
begin
  Result := False;
  VOldPosition := AStream.Position;
  try
    C := #0;
    VRange := xrCode;
    repeat
      if AStream.Read(C, 1) <> 1 then
        Exit;
      case C of
        ' ', #9, #10, #13: ;
        '/':
        begin
          if AStream.Read(c, 1) <> 1 then
            Exit;
          if C <> '*' then
            Exit;
          repeat
            VLastChar := C;
            if AStream.Read(C, 1) <> 1 then
              Exit;
            if C in [#0..#8, #11, #12, #14..#31] then
              Exit;
          until (C = '/') and (VLastChar = '*');
        end;
        's':
        begin
          if VRange <> xrCode then
            Exit;
          if not Check('tatic') then
            Exit;
          VRange := xrStaticKeyWord;
          if (AStream.Read(C, 1) <> 1) or (not (C in [' ', #9, #10, #13])) then
            Exit;
        end;
        'c':
        begin
          if VRange <> xrStaticKeyWord then
            Exit;
          if (AStream.Read(C, 1) <> 1) then
            Exit;
          if C = 'o' then
          begin
            if not Check('nst') then
              Exit;
          end
          else
          if C = 'h' then
          begin
            if not Check('ar') then
              Exit;
            VRange := xrCharKeyWord;
          end
          else
            Exit;
        end;
        'u':
        begin
          if VRange <> xrStaticKeyWord then
            Exit;
          if not Check('nsigned') then
            Exit;
        end;
        '*':
        begin
          if VRange <> xrCharKeyWord then
            Exit;
          Result := True;
          Exit;
        end;
        else
          Exit;
      end;
    until False;
  finally
    AStream.Position := VOldPosition;
  end;
end;

function TestIsXPM(const AFileName: TFileName): Boolean;
var
  VFile: TFileStream;
begin
  VFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := TestIsXPM(VFile);
  finally
    VFile.Free;
  end;
end;

{$HINTS OFF}
function TestIsPNG(AStream: TStream): Boolean;
const
  CSignature: array[0..7] of Byte = ($89, $50, $4E, $47, $0D, $0A, $1A, $0A);
var
  VReadSize: Integer;
  VOldPosition: Int64;
  VSigCheck: array[0..7] of Byte;
begin
  VOldPosition := AStream.Position;
  try
    AStream.Read(VSigCheck, SizeOf(VSigCheck));
    Result := False;
    for VReadSize := 0 to 7 do
      if VSigCheck[VReadSize] <> CSignature[VReadSize] then
        Exit;
    Result := True;
  finally
    AStream.Position := VOldPosition;
  end;
end;
{$HINTS ON}

function TestIsPNG(const AFileName: TFileName): Boolean;
var
  VFile: TFileStream;
begin
  VFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := TestIsPNG(VFile);
  finally
    VFile.Free;
  end;
end;

function TestIsPNM(AStream: TStream): Boolean;
var
  C: Char;
  VOldPosition: Int64;
begin
  VOldPosition := AStream.Position;
  try
    C := #0;
    AStream.ReadBuffer(C, 1);
    Result := C = 'P';
    if not Result then
      Exit;
    AStream.ReadBuffer(C, 1);
    Result := (Ord(C) - Ord('0')) in [1..6];
  finally
    AStream.Position := VOldPosition;
  end;
end;

function TestIsPNM(const AFileName: TFileName): Boolean;
var
  VFile: TFileStream;
begin
  VFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := TestIsPNM(VFile);
  finally
    VFile.Free;
  end;
end;

function TestIsTiff(AStream: TStream): Boolean;
var
  VIFDStart: DWord;
  VOldPosition: Int64;
  VReverseEndian: Boolean;

  function FixEndian(AWord: Word): Word;
  begin
    Result := AWord;
    if VReverseEndian then
      Result := ((Result and $FF) shl 8) or (Result shr 8);
  end;

  function FixEndian(ADWord: DWord): DWord;
  begin
    Result := ADWord;
    if VReverseEndian then
      Result := ((Result and $FF) shl 24) or ((Result and $FF00) shl 8) or
        ((Result and $FF0000) shr 8) or (Result shr 24);
  end;

  function ReadDWord: DWord;
  begin
    Result := FixEndian(AStream.ReadDWord);
  end;

  function ReadWord: Word;
  begin
    Result := FixEndian(AStream.ReadWord);
  end;

  function ReadTiffHeader(out AIFDStart: DWord): Boolean;
  var
    VFortyTwo: Word;
    VByteOrder: string;
    VBigEndian: Boolean;
  begin
    Result := False;
    VByteOrder := '  ';
    AStream.Read(VByteOrder[1], 2);
    case VByteOrder of
      'II': VBigEndian := False;
      'MM': VBigEndian := True;
    else
      Exit;
    end;
    VReverseEndian :={$IFDEF FPC_BIG_ENDIAN}not{$ENDIF}VBigEndian;
    VFortyTwo := ReadWord;
    if VFortyTwo <> 42 then
      Exit;
    AIFDStart := ReadDWord;
    Result := True;
  end;

begin
  try
    VOldPosition := AStream.Position;
    Result := ReadTiffHeader(VIFDStart) and (VIFDStart <> 0);
    AStream.Position := VOldPosition;
  except
    Result := False;
  end;
end;

function TestIsTiff(const AFileName: TFileName): Boolean;
var
  VFile: TFileStream;
begin
  VFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := TestIsTiff(VFile);
  finally
    VFile.Free;
  end;
end;

function GetGraphicType(AStream: TStream): TGraphicType;
begin
  Result := gtUnknown;
  if not Assigned(AStream) then
    Exit;
  if TestIsBMP(AStream) then
    Result := gtBMP
  else
  if TestIsIcon(AStream) then
    Result := gtIcon
  else
  if TestIsJPEG(AStream) then
    Result := gtJPEG
  else
  if TestIsGIF(AStream) then
    Result := gtGIF
  else
  if TestIsXPM(AStream) then
    Result := gtXPM
  else
  if TestIsPNG(AStream) then
    Result := gtPNG
  else
  if TestIsPNM(AStream) then
    Result := gtPNM
  else
  if TestIsTiff(AStream) then
    Result := gtTiff;
end;

function GetGraphicType(const AFileName: TFileName): TGraphicType;
var
  VFile: TFileStream;
begin
  VFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := GetGraphicType(VFile);
  finally
    VFile.Free;
  end;
end;

function GetGraphicTypeString(AStream: TStream): string;
begin
  Result := GraphicTypeToString(GetGraphicType(AStream));
end;

function GetGraphicTypeString(const AFileName: TFileName): string;
var
  VFile: TFileStream;
begin
  VFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := GetGraphicTypeString(VFile);
  finally
    VFile.Free;
  end;
end;

function IsGraphicSupported(AStream: TStream): Boolean;
begin
  Result := GetGraphicType(AStream) <> gtUnknown;
end;

function IsGraphicSupported(const AFileName: TFileName): Boolean;
var
  VFile: TFileStream;
begin
  VFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := IsGraphicSupported(VFile);
  finally
    VFile.Free;
  end;
end;

{$WARNINGS OFF}
procedure ResizeGraphic(ASource, ADestination: TFPMemoryImage;
  const AStretch, AProportional, ACenter: Boolean);
var
  VRect: TRect;
  VCanvas: TFPImageCanvas;
begin
  VCanvas := TFPImageCanvas.Create(ADestination);
  try
    VRect := GetGraphicRect(ASource.Width, ASource.Height, ADestination.Width,
      ADestination.Height, AStretch, AProportional, ACenter);
    VCanvas.StretchDraw(VRect.Left, VRect.Top, VRect.Right, VRect.Bottom,
      ASource);
  finally
    VCanvas.Free;
  end;
end;
{$WARNINGS ON}

function CreateGraphicWriter(
  const AGraphicType: TGraphicType): TFPCustomImageWriter;
var
  VWriterClass: TFPCustomImageWriterClass;
begin
  VWriterClass := GetGraphicWriterClass(AGraphicType);
  if not Assigned(VWriterClass) then
    raise EGraphic.Create(SCreateGraphicWriterError);
  Result := VWriterClass.Create;
end;

function CreateGraphicReader(
  const AGraphicType: TGraphicType): TFPCustomImageReader;
var
  VReaderClass: TFPCustomImageReaderClass;
begin
  VReaderClass := GetGraphicReaderClass(AGraphicType);
  if not Assigned(VReaderClass) then
    raise EGraphic.Create(SCreateGraphicReaderError);
  Result := VReaderClass.Create;
end;

end.
