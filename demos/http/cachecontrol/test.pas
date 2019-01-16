// Please see: http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.9.4

unit test;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, BrookHttpConsts, HTTPDefs, SysUtils;

type

  { TMyAction }

  TMyAction = class(TBrookAction)
  public
    procedure Get; override;
  end;

implementation

procedure TMyAction.Get;
begin
  HttpResponse.SetCustomHeader(BROOK_HTTP_HEADER_CACHE_CONTROL,
    BROOK_HTTP_CACHE_CONTROL_PUBLIC + ', ' +
    BROOK_HTTP_CACHE_CONTROL_MAX_AGE + '10');
  Write('<!DOCTYPE HTML>');
  Write('<html lang="en-US">');
  Write('<head>');
  Write('	<meta charset="UTF-8">');
  Write('	<title>Cache Control</title>');
  Write('</head>');
  Write('<body>');
  Write(FormatDateTime('hh:nn:ss', Now));
  Write('</body>');
  Write('</html>');
end;

initialization
  TMyAction.Register('*');

end.
