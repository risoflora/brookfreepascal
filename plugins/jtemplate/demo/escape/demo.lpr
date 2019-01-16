program demo;

{$mode objfpc}{$H+}

uses
  JTemplate;

var
  VView: TJTemplateStream;
begin
  VView := TJTemplateStream.Create;
  try
    VView.Parser.HtmlSupports := False;
    VView.LoadFromFile('test.html');
    VView.Parser.TagEscape := '@';
    VView.Parser.Fields.Add('title', 'Demo');
    VView.Parser.Fields.Add('hr', '<hr />');
    VView.Parser.Fields.Add('test.hello', 'JTemplate demo');
    VView.Parser.Fields.Add('escape.me.please', 'Fail');
    VView.Parser.Fields.Add('hr', '<hr />');
    VView.Parser.Replace;
    Write(VView.Parser.Content);
  finally
    VView.Free;
  end;
end.

