// Please See: http://en.wikipedia.org/wiki/Chunked_transfer_encoding

unit Test;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, BrookHTTPConsts;

type
  TTest = class(TBrookAction)
  public
    procedure Get; override;
  end;

implementation

procedure TTest.Get;
begin
  HttpResponse.ContentType := BROOK_HTTP_CONTENT_TYPE_TEXT_PLAIN;
  HttpResponse.SetCustomHeader(BROOK_HTTP_HEADER_TRANSFER_ENCODING,
    BROOK_HTTP_TRANSFER_ENCODING_CHUNKED);
  Write('23');
  Write('This is the data in the first chunk');
  Write('1A');
  Write('and this is the second one');
  Write('A');
  Write('1234567890');
  Write('0');
  Write('');
end;

initialization
  TTest.Register('*');

end.
