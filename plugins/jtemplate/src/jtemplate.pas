(*
  J-Template plugin.
  Copyright (C) 2012-2014 Silvio Clecio.

  Please see the LICENSE, README and AUTHORS files.
*)

unit JTemplate;

{$mode objfpc}{$H+}

interface

uses
  SysUtils, StrUtils, Classes, FPJSON;

type
  EJTemplate = class(Exception);

  TJTemplateParserClass = class of TJTemplateParser;

  TJTemplateStreamClass = class of TJTemplateStream;

  TJTemplateLoadingFieldsEvent = procedure(Sender: TObject;
    var AVar, AValue: string) of object;

  TJTemplateReplacingEvent = procedure(Sender: TObject;
    var AValue: string) of object;

  { TJTemplateParser }

  TJTemplateParser = class
  private
    FContent: string;
    FFields: TJSONObject;
    FHtmlSupports: Boolean;
    FOnLoadingFields: TJTemplateLoadingFieldsEvent;
    FOnReplace: TNotifyEvent;
    FOnReplacing: TJTemplateReplacingEvent;
    FTagEscape: ShortString;
    FTagPrefix: ShortString;
    FTagSuffix: ShortString;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Replace(const ARecursive: Boolean = False); virtual;
    property Content: string read FContent write FContent;
    property Fields: TJSONObject read FFields write FFields;
    property HtmlSupports: Boolean read FHtmlSupports write FHtmlSupports;
    property TagPrefix: ShortString read FTagPrefix write FTagPrefix;
    property TagSuffix: ShortString read FTagSuffix write FTagSuffix;
    property TagEscape: ShortString read FTagEscape write FTagEscape;
    property OnLoadingFields: TJTemplateLoadingFieldsEvent read FOnLoadingFields
      write FOnLoadingFields;
    property OnReplacing: TJTemplateReplacingEvent read FOnReplacing
      write FOnReplacing;
    property OnReplace: TNotifyEvent read FOnReplace write FOnReplace;
  end;

  { TJTemplateStream }

  TJTemplateStream = class
  private
    FParser: TJTemplateParser;
  protected
    function CreateParser: TJTemplateParser; virtual;
    procedure FreeParser; virtual;
    function GetParserClass: TJTemplateParserClass; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure LoadFromStream(AStream: TStream);
    procedure LoadFromFile(const AFileName: TFileName);
    procedure SaveToStream(AStream: TStream);
    procedure SaveToFile(const AFileName: TFileName);
    property Parser: TJTemplateParser read FParser write FParser;
  end;

  { TJTemplate }

  TJTemplate = class(TComponent)
  private
    FContent: TStrings;
    FOnLoadingFields: TJTemplateLoadingFieldsEvent;
    FOnReplace: TNotifyEvent;
    FOnReplacing: TJTemplateReplacingEvent;
    FStream: TJTemplateStream;
    function GetContent: TStrings;
    function GetFields: TJSONObject;
    function GetHtmlSupports: Boolean;
    function GetParser: TJTemplateParser;
    function GetStream: TJTemplateStream;
    function GetTagEscape: string;
    function GetTagPrefix: string;
    function GetTagSuffix: string;
    procedure SetContent(AValue: TStrings);
    procedure SetFields(AValue: TJSONObject);
    procedure SetHtmlSupports(AValue: Boolean);
    procedure SetParser(AValue: TJTemplateParser);
    procedure SetStream(AValue: TJTemplateStream);
    procedure SetTagEscape(AValue: string);
    procedure SetTagPrefix(AValue: string);
    procedure SetTagSuffix(AValue: string);
  protected
    procedure Loaded; override;
    function CreateStream: TJTemplateStream; virtual;
    procedure FreeStream; virtual;
    function GetStreamClass: TJTemplateStreamClass;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Replace(const ARecursive: Boolean = False);
    procedure LoadFromStream(AStream: TStream);
    procedure LoadFromFile(const AFileName: TFileName);
    procedure SaveToStream(AStream: TStream);
    procedure SaveToFile(const AFileName: TFileName);
    property Fields: TJSONObject read GetFields write SetFields;
    property Parser: TJTemplateParser read GetParser write SetParser;
    property Stream: TJTemplateStream read GetStream write SetStream;
  published
    property Content: TStrings read GetContent write SetContent;
    property HtmlSupports: Boolean read GetHtmlSupports write SetHtmlSupports;
    property TagPrefix: string read GetTagPrefix write SetTagPrefix;
    property TagSuffix: string read GetTagSuffix write SetTagSuffix;
    property TagEscape: string read GetTagEscape write SetTagEscape;
    property OnLoadingFields: TJTemplateLoadingFieldsEvent read FOnLoadingFields
      write FOnLoadingFields;
    property OnReplacing: TJTemplateReplacingEvent read FOnReplacing
      write FOnReplacing;
    property OnReplace: TNotifyEvent read FOnReplace write FOnReplace;
  end;

resourcestring
  SNilParamError = '"%s" must not be nil.';

const
  LatinCharsCount = 74;
  LatinChars: array[0..LatinCharsCount] of string = (
    '"', '<', '>', '^', '~', '£', '§', '°', '²', '³', 'µ', '·', '¼', '½', '¿',
    'À', 'Á', 'Â', 'Ã', 'Ä', 'Å', 'Æ', 'Ç', 'È', 'É', 'Ê', 'Ë', 'Ì', 'Í', 'Î',
    'Ï', 'Ñ', 'Ò', 'Ó', 'Ô', 'Õ', 'Ö', 'Ù', 'Ú', 'Û', 'Ü', 'Ý', 'ß', 'á', 'à',
    'â', 'ã', 'ä', 'å', 'æ', 'ç', 'é', 'è', 'ê', 'ë', 'ì', 'í', 'î', 'ï', 'ñ',
    'ò', 'ó', 'ô', 'õ', 'ö', '÷', 'ù', 'ú', 'û', 'ü', 'ý', 'ÿ', '&', '´', '`');
  HtmlChars: array[0..LatinCharsCount] of string = (
    '&quot;', '&lt;', '&gt;', '&circ;', '&tilde;', '&pound;', '&sect;', '&deg;',
    '&sup2;', '&sup3;', '&micro;', '&middot;', '&frac14;', '&frac12;', '&iquest;',
    '&Agrave;', '&Aacute;', '&Acirc;', '&Atilde;', '&Auml;', '&Aring;', '&AElig;',
    '&Ccedil;', '&Egrave;', '&Eacute;', '&Ecirc;', '&Euml;', '&Igrave;', '&Iacute;',
    '&Icirc;', '&Iuml;', '&Ntilde;', '&Ograve;', '&Oacute;', '&Ocirc;', '&Otilde;',
    '&Ouml;', '&Ugrave;', '&Uacute;', '&Ucirc;', '&Uuml;', '&Yacute;', '&szlig;',
    '&aacute;', '&agrave;', '&acirc;', '&atilde;', '&auml;', '&aring;', '&aelig;',
    '&ccedil;', '&eacute;', '&egrave;', '&ecirc;', '&euml;', '&igrave;', '&iacute;',
    '&icirc;', '&iuml;', '&ntilde;', '&ograve;', '&oacute;', '&ocirc;', '&otilde;',
    '&ouml;', '&divide;', '&ugrave;', '&uacute;', '&ucirc;', '&uuml;', '&yacute;',
    '&yuml;', '&amp;', '&acute;', '&grave;');

function StrToHtml(const S: string): string;

implementation

function StrToHtml(const S: string): string;

  function _Found(const ABuf: PChar; const ALen: Integer): Integer; inline;
  var
    P: PString;
  begin
    for Result := Low(LatinChars) to High(LatinChars) do
    begin
      P := @LatinChars[Result];
      if Length(P^) <= ALen then
        // compare in blocks of 8(x64), 4, 2 and 1 byte
        if CompareByte(P^[1], ABuf^, Length(P^)) = 0 then
          Exit;
    end;
    Result := -1;
  end;

var
  I: Integer;
  VResStr: string;
  PComp, PLast: PChar;
begin
  VResStr := '';
  PComp := @S[1];
  PLast := PComp + Length(S);
  while PComp < PLast do
  begin
    I := _Found(PComp, PLast - PComp);
    if I > -1 then
    begin
      VResStr := VResStr + HtmlChars[I];
      Inc(PComp, Length(LatinChars[I]));
    end
    else
    begin
      // it can be optimized decreasing the concatenations
      VResStr := VResStr + PComp^;
      Inc(PComp);
    end;
  end;
  Result := VResStr;
end;

{ TJTemplateParser }

constructor TJTemplateParser.Create;
begin
  FFields := TJSONObject.Create;
  FTagPrefix := '@';
  FHtmlSupports := True;
end;

destructor TJTemplateParser.Destroy;
begin
  FreeAndNil(FFields);
  inherited Destroy;
end;

procedure TJTemplateParser.Replace(const ARecursive: Boolean);
var
  VVar, VValue: string;
  I, P, VTagLen, VEscapLen: Integer;
begin
  VEscapLen := Length(FTagEscape);
  for I := 0 to Pred(FFields.Count) do
  begin
    VVar := FTagPrefix + FFields.Names[I] + FTagSuffix;
    if FHtmlSupports then
      VValue := StrToHtml(FFields.Items[I].AsString)
    else
      VValue := FFields.Items[I].AsString;
    if Assigned(FOnLoadingFields) then
      FOnLoadingFields(Self, VVar, VValue);
    P := 1;
    VTagLen := Length(VVar);
    repeat
      P := PosEx(VVar, FContent, P);
      if P < 1 then
        Break;
      if (VEscapLen <> 0) and // no TagEscape defined
        (CompareChar(FContent[P - VEscapLen], FTagEscape[1], VEscapLen) = 0) then
      begin
        System.Delete(FContent, P - VEscapLen, VEscapLen);
        Inc(P, VTagLen - VEscapLen);
      end
      else
      begin
        System.Delete(FContent, P, VTagLen);
        if Assigned(FOnReplacing) then
          FOnReplacing(Self, VValue);
        Insert(VValue, FContent, P);
        Inc(P, Length(VValue));
        if not ARecursive then
          Break;
      end;
    until False;
  end;
  if Assigned(FOnReplace) then
    FOnReplace(Self);
end;

{ TJTemplateStream }

constructor TJTemplateStream.Create;
begin
  inherited Create;
  FParser := CreateParser;
end;

destructor TJTemplateStream.Destroy;
begin
  FreeParser;
  inherited Destroy;
end;

function TJTemplateStream.CreateParser: TJTemplateParser;
begin
  Result := GetParserClass.Create;
end;

procedure TJTemplateStream.FreeParser;
begin
  FreeAndNil(FParser);
end;

function TJTemplateStream.GetParserClass: TJTemplateParserClass;
begin
  Result := TJTemplateParser;
end;

procedure TJTemplateStream.LoadFromStream(AStream: TStream);
begin
  if not Assigned(AStream) then
    raise EJTemplate.CreateFmt(SNilParamError, ['AStream']);
  AStream.Seek(0, 0);
  SetLength(FParser.FContent, AStream.Size);
  AStream.Read(Pointer(FParser.FContent)^, Length(FParser.FContent));
end;

procedure TJTemplateStream.LoadFromFile(const AFileName: TFileName);
var
  VFile: TFileStream;
begin
  VFile := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(VFile);
  finally
    VFile.Free;
  end;
end;

procedure TJTemplateStream.SaveToStream(AStream: TStream);
begin
  if not Assigned(AStream) then
    raise EJTemplate.CreateFmt(SNilParamError, ['AStream']);
  AStream.Seek(0, 0);
  AStream.Write(Pointer(FParser.FContent)^, Length(FParser.FContent));
end;

procedure TJTemplateStream.SaveToFile(const AFileName: TFileName);
var
  VFile: TFileStream;
begin
  VFile := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStream(VFile);
  finally
    VFile.Free;
  end;
end;

{ TJTemplate }

constructor TJTemplate.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FStream := CreateStream;
  FContent := TStringList.Create;
end;

destructor TJTemplate.Destroy;
begin
  FContent.Free;
  FreeStream;
  inherited Destroy;
end;

function TJTemplate.CreateStream: TJTemplateStream;
begin
  Result := GetStreamClass.Create;
end;

procedure TJTemplate.FreeStream;
begin
  FreeAndNil(FStream);
end;

function TJTemplate.GetStreamClass: TJTemplateStreamClass;
begin
  Result := TJTemplateStream;
end;

function TJTemplate.GetContent: TStrings;
begin
  Result := FContent;
  if Assigned(FContent) then
    FContent.Text := FStream.FParser.FContent;
end;

function TJTemplate.GetFields: TJSONObject;
begin
  Result := FStream.FParser.FFields;
end;

function TJTemplate.GetHtmlSupports: Boolean;
begin
  Result := FStream.FParser.FHtmlSupports;
end;

function TJTemplate.GetParser: TJTemplateParser;
begin
  Result := FStream.FParser;
end;

function TJTemplate.GetStream: TJTemplateStream;
begin
  Result := FStream;
end;

function TJTemplate.GetTagEscape: string;
begin
  Result := FStream.FParser.FTagEscape;
end;

function TJTemplate.GetTagPrefix: string;
begin
  Result := FStream.FParser.FTagPrefix;
end;

function TJTemplate.GetTagSuffix: string;
begin
  Result := FStream.FParser.FTagSuffix;
end;

procedure TJTemplate.SetContent(AValue: TStrings);
begin
  if Assigned(AValue) then
  begin
    FContent.Assign(AValue);
    FStream.FParser.FContent := AValue.Text;
  end;
end;

procedure TJTemplate.SetFields(AValue: TJSONObject);
begin
  FStream.FParser.FFields := AValue;
end;

procedure TJTemplate.SetHtmlSupports(AValue: Boolean);
begin
  FStream.FParser.FHtmlSupports := AValue;
end;

procedure TJTemplate.SetParser(AValue: TJTemplateParser);
begin
  FStream.FParser := AValue;
  if Assigned(AValue) then
  begin
    AValue.OnLoadingFields := FOnLoadingFields;
    AValue.OnReplacing := FOnReplacing;
    AValue.OnReplace := FOnReplace;
  end;
end;

procedure TJTemplate.SetStream(AValue: TJTemplateStream);
begin
  FStream := AValue;
end;

procedure TJTemplate.SetTagEscape(AValue: string);
begin
  FStream.FParser.FTagEscape := AValue;
end;

procedure TJTemplate.SetTagPrefix(AValue: string);
begin
  FStream.FParser.FTagPrefix := AValue;
end;

procedure TJTemplate.SetTagSuffix(AValue: string);
begin
  FStream.FParser.FTagSuffix := AValue;
end;

procedure TJTemplate.Loaded;
begin
  inherited Loaded;
  if Assigned(FContent) then
    FStream.FParser.FContent := FContent.Text;
  if Assigned(FStream) and Assigned(FStream.FParser) then
  begin
    if Assigned(FOnLoadingFields) then
      FStream.FParser.OnLoadingFields := FOnLoadingFields;
    if Assigned(FOnReplacing) then
      FStream.FParser.OnReplacing := FOnReplacing;
    if Assigned(FOnReplace) then
      FStream.FParser.OnReplace := FOnReplace;
  end;
end;

procedure TJTemplate.Replace(const ARecursive: Boolean);
begin
  FStream.FParser.Replace(ARecursive);
end;

procedure TJTemplate.LoadFromStream(AStream: TStream);
begin
  FStream.LoadFromStream(AStream);
end;

procedure TJTemplate.LoadFromFile(const AFileName: TFileName);
begin
  FStream.LoadFromFile(AFileName);
end;

procedure TJTemplate.SaveToStream(AStream: TStream);
begin
  FStream.SaveToStream(AStream);
end;

procedure TJTemplate.SaveToFile(const AFileName: TFileName);
begin
  FStream.LoadFromFile(AFileName);
end;

end.
