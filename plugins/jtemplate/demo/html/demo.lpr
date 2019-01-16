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
    VView.Parser.Fields.Add('value', 'a"b"c');
    VView.Parser.Replace;
    Write(VView.Parser.Content);
  finally
    VView.Free;
  end;
end.

