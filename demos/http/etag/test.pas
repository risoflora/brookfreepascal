// Please see: http://en.wikipedia.org/wiki/HTTP_ETag

unit Test;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, BrookHTTPConsts, SysUtils;

const
  ETAG = 'e34db6e768884b30af72e353bfc83e6a';

type

  { TMyAction }

  TMyAction = class(TBrookAction)
  public
    procedure Get; override;
  end;

implementation

{ TMyAction }

procedure TMyAction.Get;
begin
  HttpResponse.SetCustomHeader(BROOK_HTTP_HEADER_ETAG, ETAG);
  Write('<!DOCTYPE HTML>');
  Write('<html lang="en-US">');
  Write('<head>');
  Write('	<meta charset="UTF-8">');
  Write('	<title>ETag</title>');
  Write('</head>');
  Write('<body>');
  if GetEnvironmentVariable(BROOK_CLT_ENV_HTTP_IF_NONE_MATCH) = ETAG then
    HttpResponse.Code := BROOK_HTTP_STATUS_CODE_NOT_MODIFIED
  else
    Write('	Hello world!');
  Write('</body>');
  Write('</html>');
end;

initialization
  TMyAction.Register('*');

end.
