program demo;

{$mode objfpc}{$H+}

uses
  JTemplate;

var
  VView: TJTemplateStream;
begin
  VView := TJTemplateStream.Create;
  try
    VView.LoadFromFile('test.html');
    VView.Parser.HtmlSupports := False;
    VView.Parser.Fields.Add('title', 'Demo');
    VView.Parser.Fields.Add('hr', '<hr />');
    VView.Parser.Fields.Add('test.hello', 'JTemplate demo');
    VView.Parser.Replace(True);
    Write(VView.Parser.Content);
  finally
    VView.Free;
  end;
end.

