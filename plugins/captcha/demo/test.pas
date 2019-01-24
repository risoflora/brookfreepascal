unit test;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, Captcha, RUtils, Classes, SysUtils;

type
  TTest = class(TBrookAction)
  public
    procedure Get; override;
    procedure Post; override;
  end;

const
  FORM =
    '<!DOCTYPE HTML>'+lf+
    '<html lang="pt-BR">'+lf+
    '<head>'+lf+
    '	<meta charset="UTF-8">'+lf+
    '	<title></title>'+lf+
    '</head>'+lf+
    '<body>'+lf+
    '<img src="data:image/gif;base64,%s"/>'+lf+
    '	<form autocomplete="off" action="" method="post">'+lf+
    '		<input type="text" name="captcha"/>'+lf+
    '		<input type="submit"/>'+lf+
    '	</form>'+lf+
    '</body>'+lf+
    '</html>';

implementation

uses
  FPWritePNG;

procedure TTest.Get;
var
  VImage: TMemoryImage;
  VStream: TMemoryStream;
begin
  if not TCaptcha.FontExists(ftLiberationSerifRegularTTF) then
    Exit;
  VImage := TMemoryImage.Create;
  VStream := TMemoryStream.Create;
  try
    SetCookie('captcha', TCaptcha.Generate(VStream));
    VStream.Seek(0, 0);
    Write(FORM, [StreamToBase64(VStream)]);
  finally
    VStream.Free;
    VImage.Free;
  end;
end;

procedure TTest.Post;
begin
  if SameText(Fields.Values['captcha'], GetCookie('captcha')) then
    Write('OK')
  else
    Write('Fail');
end;

initialization
  TTest.Register('*');

end.
