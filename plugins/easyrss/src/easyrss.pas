(*
  EasyRSS plugin.
  Copyright (C) 2012-2014 Silvio Clecio.

  Please see the LICENSE file.
*)

unit EasyRSS;

{$mode objfpc}{$H+}

interface

uses
  DOM, XmlRead, FGL, HTTPDefs, FPHttpClient, Classes, SysUtils;

type

  { TRSSImage }

  TRSSImage = class
  private
    FLink: string;
    FTitle: string;
    FUrl: string;
    function GetContent: string;
  protected
    function FormatTag(const AProp, ATag: string): string;
  public
    property Content: string read GetContent;
    property Title: string read FTitle write FTitle;
    property Url: string read FUrl write FUrl;
    property Link: string read FLink write FLink;
  end;

  { TRSSItem }

  TRSSItem = class
  private
    FAuthor: string;
    FCategory: string;
    FComments: string;
    FDescription: string;
    FGuid: string;
    FIsPermaLink: Boolean;
    FLink: string;
    FPubDate: string;
    FTitle: string;
    function GetContent: string;
  protected
    function FormatTag(const AProp, ATag: string): string;
  public
    constructor Create;
    property Content: string read GetContent;
    property Title: string read FTitle write FTitle;
    property Link: string read FLink write FLink;
    property Guid: string read FGuid write FGuid;
    property IsPermaLink: Boolean read FIsPermaLink write FIsPermaLink;
    property Category: string read FCategory write FCategory;
    property PubDate: string read FPubDate write FPubDate;
    property Description: string read FDescription write FDescription;
    property Author: string read FAuthor write FAuthor;
    property Comments: string read FComments write FComments;
  end;

  TRSSItems = specialize TFPGList<TRSSItem>;

  { TRSS }

  TRSS = class
  private
    FCategory: string;
    FCopyright: string;
    FDocs: string;
    FGenerator: string;
    FImage: TRSSImage;
    FItems: TRSSItems;
    FLanguage: string;
    FLastBuildDate: string;
    FLink: string;
    FManagingEditor: string;
    FPubDate: string;
    FTitle: string;
    FUTF8: Boolean;
    FWebMaster: string;
    function GetContent: string;
    procedure FreeItems;
    function GetCount: Integer;
    function GetElements(AIndex: Integer): TRSSItem;
    procedure SetElements(AIndex: Integer; AValue: TRSSItem);
  protected
    function FormatTag(const AProp, ATag: string): string;
  public
    constructor Create;
    destructor Destroy; override;
    function Add: TRSSItem;
    procedure Clear;
    property Count: Integer read GetCount;
    property Content: string read GetContent;
    property Items: TRSSItems read FItems;
    property Elements[AIndex: Integer]: TRSSItem read GetElements
      write SetElements; default;
    property Title: string read FTitle write FTitle;
    property Link: string read FLink write FLink;
    property Language: string read FLanguage write FLanguage;
    property WebMaster: string read FWebMaster write FWebMaster;
    property Copyright: string read FCopyright write FCopyright;
    property PubDate: string read FPubDate write FPubDate;
    property LastBuildDate: string read FLastBuildDate write FLastBuildDate;
    property ManagingEditor: string read FManagingEditor write FManagingEditor;
    property Category: string read FCategory write FCategory;
    property Generator: string read FGenerator write FGenerator;
    property Docs: string read FDocs write FDocs;
    property Image: TRSSImage read FImage write FImage;
    property UTF8: Boolean read FUTF8 write FUTF8;
  end;

  { TRSSReader }

  TRSSReader = class(TRSS)
  protected
    function GetTagValue(ANode: TDOMNode; const ATagName: string): string;
  public
    procedure LoadFromStream(AStream: TStream);
    procedure LoadFromString(const S: string);
    procedure LoadFromFile(const AFileName: TFileName);
    procedure LoadFromHttp(const AUrl: string);
  end;

  { TRSSWriter }

  TRSSWriter = class(TRSS)
  public
    procedure SaveToStream(AStream: TStream);
    procedure SaveToFile(const AFileName: TFileName);
  end;

function DateTimeToGMT(const ADateTime: TDateTime): string;
function NewGuid: string;

implementation

type
  THttp = class(TFPHTTPClient)
  public
    procedure GetFeed(const AUrl: string; out AFeed: TStream);
  end;

function DateTimeToGMT(const ADateTime: TDateTime): string;
var
  VYear, VMonth, VDay, VHour, VMinute, VSecond, M: Word;
begin
  DecodeDate(ADateTime, VYear, VMonth, VDay);
  DecodeTime(ADateTime, VHour, VMinute, VSecond, M);
  Result := Format('%s, %.2d %s %d %.2d:%.2d:%.2d GMT',
    [HTTPDays[DayOfWeek(ADateTime)], VDay, HTTPMonths[VMonth], VYear, VHour,
    VMinute, VSecond]);
end;

function NewGuid: string;
var
  VGuid: TGuid;
begin
  CreateGUID(VGuid);
  SetLength(Result, 36);
  StrLFmt(PChar(Result), 36,'%.8x-%.4x-%.4x-%.2x%.2x-%.2x%.2x%.2x%.2x%.2x%.2x',
    [VGuid.D1, VGuid.D2, VGuid.D3, VGuid.D4[0], VGuid.D4[1], VGuid.D4[2],
     VGuid.D4[3], VGuid.D4[4], VGuid.D4[5], VGuid.D4[6], VGuid.D4[7]]);
end;

{ THttp }

procedure THttp.GetFeed(const AUrl: string; out AFeed: TStream);
begin
  AFeed := TMemoryStream.Create;
  DoMethod('GET', AUrl, AFeed, [200]);
end;

{ TRSSImage }

function TRSSImage.GetContent: string;
begin
  Result :=
    '		<image>'+#10+
    FormatTag(FTitle, 'title')+
    FormatTag(FUrl, 'url')+
    FormatTag(FLink, 'link')+
    '		</image>'+#10;
end;

function TRSSImage.FormatTag(const AProp, ATag: string): string;
begin
  if AProp <> '' then
    Result := '			<'+ATag+'>'+AProp+'</'+ATag+'>'+#10
  else
    Result := '';
end;

{ TRSSItem }

constructor TRSSItem.Create;
begin
  FPubDate := DateTimeToGMT(Now);
  FGuid := NewGuid;
end;

function TRSSItem.FormatTag(const AProp, ATag: string): string;
begin
  if AProp <> '' then
    Result := '			<'+ATag+'>'+AProp+'</'+ATag+'>'+#10
  else
    Result := '';
end;

function TRSSItem.GetContent: string;
begin
  Result :=
    '		<item>'+#10+
    FormatTag(FTitle, 'title')+
    FormatTag(FLink, 'link')+
    FormatTag(FAuthor, 'author')+
    FormatTag(FComments, 'comments')+
    Format('			<guid ispermalink="%s">%s</guid>',
      [BoolToStr(FIsPermaLink, 'true', 'false'), FGuid])+#10+
    FormatTag(FCategory, 'category')+
    FormatTag(FPubDate, 'pubdate')+
    FormatTag(FDescription, 'description')+
    '		</item>'+#10;
end;

{ TRSS }

constructor TRSS.Create;
begin
  FItems := TRSSItems.Create;
  FUTF8 := True;
  FLanguage := 'en-us';
  FGenerator := 'EasyRSS plugin';
  FPubDate := DateTimeToGMT(Now);
  FLastBuildDate := DateTimeToGMT(Now);
end;

destructor TRSS.Destroy;
begin
  FreeAndNil(FImage);
  FreeItems;
  FItems.Free;
  inherited Destroy;
end;

function TRSS.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TRSS.GetElements(AIndex: Integer): TRSSItem;
begin
  Result := FItems[AIndex];
end;

procedure TRSS.SetElements(AIndex: Integer; AValue: TRSSItem);
begin
  FItems[AIndex] := AValue;
end;

function TRSS.GetContent: string;
var
  I: Integer;
begin
  Result :=
    '<rss version="2.0">'+#10+
    '	<channel>'+#10+
    '		<title>'+FTitle+'</title>'+#10+
    FormatTag(FGenerator, 'generator')+
    FormatTag(FLink, 'link')+
    FormatTag(FLanguage, 'language')+
    FormatTag(FWebMaster, 'webmaster')+
    FormatTag(FCopyright, 'copyright')+
    FormatTag(FPubDate, 'pubdate')+
    FormatTag(FLastBuildDate, 'lastbuilddate')+
    FormatTag(FCategory, 'category')+
    FormatTag(FDocs, 'docs')+
    FormatTag(FManagingEditor, 'managingeditor');
  if Assigned(FImage) then
    Result += FImage.Content;
  for I := 0 to Pred(FItems.Count) do
    Result += TRSSItem(FItems[I]).Content;
  Result +=
    '	</channel>'+#10+
    '</rss>';
end;

procedure TRSS.FreeItems;
var
  I: Integer;
begin
  for I := 0 to Pred(FItems.Count) do
    TObject(FItems[I]).Free;
end;

function TRSS.FormatTag(const AProp, ATag: string): string;
begin
  if AProp <> '' then
    Result := '		<'+ATag+'>'+AProp+'</'+ATag+'>'+#10
  else
    Result := '';
end;

function TRSS.Add: TRSSItem;
begin
  Result := TRSSItem.Create;
  FItems.Add(Result);
end;

procedure TRSS.Clear;
begin
  FreeItems;
  FItems.Clear;
end;

{ TRSSReader }

function TRSSReader.GetTagValue(ANode: TDOMNode; const ATagName: string): string;
var
  VNode: TDOMNode;
begin
  Result := '';
  if Assigned(ANode) then
  begin
    VNode := ANode.FindNode(DOMString(ATagName));
    if Assigned(VNode) then
    begin
      if FUTF8 then
        Result := UTF8Encode(VNode.TextContent)
      else
        Result := string(VNode.TextContent);
    end;
  end;
end;

procedure TRSSReader.LoadFromStream(AStream: TStream);
var
  VRssItem: TRSSItem;
  VXml: TXMLDocument;
  VXmlChannel, VXmlImage, VXmlItem, VPermaLink: TDOMNode;
begin
  try
    ReadXMLFile(VXml, AStream);
    VXmlChannel := VXml.DocumentElement.FindNode('channel');
    FTitle := GetTagValue(VXmlChannel, 'title');
    FLink := GetTagValue(VXmlChannel, 'link');
    FLanguage := GetTagValue(VXmlChannel, 'language');
    FWebMaster := GetTagValue(VXmlChannel, 'webmaster');
    FCopyright := GetTagValue(VXmlChannel, 'copyright');
    FPubDate := GetTagValue(VXmlChannel, 'pubdate');
    FLastBuildDate := GetTagValue(VXmlChannel, 'lastbuilddate');
    FManagingEditor := GetTagValue(VXmlChannel, 'managingeditor');
    FCategory := GetTagValue(VXmlChannel, 'category');
    FGenerator := GetTagValue(VXmlChannel, 'generator');
    FDocs := GetTagValue(VXmlChannel, 'docs');
    VXmlImage := VXmlChannel.FindNode('image');
    if Assigned(VXmlImage) then
    begin
      if not Assigned(FImage) then
        FImage := TRSSImage.Create;
      FImage.Title := GetTagValue(VXmlImage, 'title');
      FImage.Url := GetTagValue(VXmlImage, 'url');
      FImage.Link := GetTagValue(VXmlImage, 'link');
    end;
    VXmlItem := VXmlChannel.FindNode('item');
    Clear;
    while Assigned(VXmlItem) do
    begin
      VRssItem := TRSSItem.Create;
      VRssItem.Title := GetTagValue(VXmlItem, 'title');
      VRssItem.Link := GetTagValue(VXmlItem, 'link');
      VRssItem.Guid := GetTagValue(VXmlItem, 'guid');
      VPermaLink := VXmlItem.FindNode('guid');
      if Assigned(VPermaLink) then
      begin
        VPermaLink := VPermaLink.Attributes.GetNamedItem('ispermalink');
        if Assigned(VPermaLink) then
          VRssItem.IsPermaLink := StrToBoolDef(
            string(VPermaLink.TextContent), False);
      end;
      VRssItem.Category := GetTagValue(VXmlItem, 'category');
      VRssItem.PubDate := GetTagValue(VXmlItem, 'pubdate');
      VRssItem.Description := GetTagValue(VXmlItem, 'description');
      VRssItem.Author := GetTagValue(VXmlItem, 'author');
      VRssItem.Comments := GetTagValue(VXmlItem, 'comments');
      FItems.Add(VRssItem);
      VXmlItem := VXmlItem.NextSibling;
    end;
  finally
    FreeAndNil(VXml);
  end;
end;

procedure TRSSReader.LoadFromString(const S: string);
var
  VString: TStringStream;
begin
  VString := TStringStream.Create(S);
  try
    LoadFromStream(VString);
  finally
    VString.Free;
  end;
end;

procedure TRSSReader.LoadFromFile(const AFileName: TFileName);
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

procedure TRSSReader.LoadFromHttp(const AUrl: string);
var
  VHttp: THttp;
  VFeed: TStream;
begin
  VHttp := THttp.Create(nil);
  try
    VHttp.GetFeed(AUrl, VFeed);
    VFeed.Position := 0;
    LoadFromStream(VFeed);
  finally
    FreeAndNil(VFeed);
    VHttp.Free;
  end;
end;

{ TRSSWriter }

procedure TRSSWriter.SaveToStream(AStream: TStream);
var
  S: String;
begin
  S := GetContent;
  AStream.Write(Pointer(S)^, Length(S));
end;

procedure TRSSWriter.SaveToFile(const AFileName: TFileName);
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

end.
