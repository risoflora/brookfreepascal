unit Brokers;

{$mode objfpc}{$H+}

interface

implementation

uses
  fpmimetypes,
  BrookFCLHTTPAppBroker,
  BrookHTTPConsts,
  BrookUtils,
  BrookStaticFileBroker,
  BrookApplication,
  Classes,
  SysUtils;

var
  PublicHTMLDir: string;

initialization
  MimeTypes.LoadFromFile('mime.types');
  PublicHTMLDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  BrookSettings.Charset := BROOK_HTTP_CHARSET_UTF_8;
  BrookSettings.Page404File := PublicHTMLDir + '404.html';
  BrookSettings.Page500File := PublicHTMLDir + '500.html';
  BrookStaticFileRegisterDirectory('/css/', PublicHTMLDir + 'css');
  BrookStaticFileRegisterDirectory('/js/', PublicHTMLDir + 'js');
  BrookStaticFileRegisterDirectory('/img/', PublicHTMLDir + 'img');
  BrookSettings.Port := 8000;

end.
