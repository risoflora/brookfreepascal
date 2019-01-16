// Please see: http://www.ietf.org/rfc/rfc2183.txt

unit Test;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, BrookHttpUtils, BrookHttpConsts, BrookConsts, BrookMessages,
  HTTPDefs, Classes, SysUtils;

type

  { TMyAction }

  TMyAction = class(TBrookAction)
  public
    procedure AddContentDisposition(const AContentType: string;
      const AFileName: TFileName = ES;
      const ADispositionType: string = BROOK_HTTP_CONTENT_DISPOSITION_ATTACHMENT;
      const AContentDescription: string = ES;
      const AModificationDate: TDateTime = NullDate);
    procedure Get; override;
  end;

implementation

{ TMyAction }

procedure TMyAction.AddContentDisposition(const AContentType: string;
  const AFileName: TFileName; const ADispositionType: string;
  const AContentDescription: string; const AModificationDate: TDateTime);
var
  VHeaders: string;
begin
  if not FileExists(AFileName) then
    Stop(SBrookFileNotFoundError);
  HttpResponse.ContentType := ES;
  VHeaders := fieldContentType + CO + SP + AContentType + CRLF +
    BROOK_HTTP_HEADER_CONTENT_DISPOSITION + CO + SP + ADispositionType;
  if AFileName <> ES then
  begin
    VHeaders += '; filename=' + DQ + ExtractFileName(AFileName) + DQ;
    if AModificationDate <> NullDate then
      VHeaders += '; modification-date=' + DQ +
        BrookDateTimeToGMT(AModificationDate) + DQ;
    if AContentDescription <> ES then
      VHeaders += CRLF + BROOK_HTTP_HEADER_CONTENT_DESCRIPTION +
        AContentDescription;
  end;
  HttpResponse.CustomHeaders.NameValueSeparator := CO;
  HttpResponse.CustomHeaders.Add(VHeaders);
  if FileExists(AFileName) then
  begin
    HttpResponse.ContentStream := TFileStream.Create(AFileName,
      fmOpenRead or fmShareDenyWrite);
    try
      HttpResponse.SendContent;
    finally
      HttpResponse.ContentStream.Free;
      HttpResponse.ContentStream := nil;
    end;
  end;
end;

procedure TMyAction.Get;
begin
  AddContentDisposition(BROOK_HTTP_CONTENT_TYPE_IMAGE_PNG, 'img.png',
    BROOK_HTTP_CONTENT_DISPOSITION_INLINE);
end;

initialization
  TMyAction.Register('*');

end.
