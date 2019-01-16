// Please see: http://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html#sec13.3.1

unit Test;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, HTTPDefs;

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
  HttpResponse.SetCustomHeader(fieldLastModified, '01/01/2000');
  Write('<!DOCTYPE HTML>');
  Write('<html lang="en-US">');
  Write('<head>');
  Write('	<meta charset="UTF-8">');
  Write('	<title>LastModified</title>');
  Write('</head>');
  Write('<body>');
  Write('	Hello world!');
  Write('</head>');
  Write('<body>');
end;

initialization
  TMyAction.Register('*');

end.
