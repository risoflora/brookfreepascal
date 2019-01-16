program t1;

{$mode objfpc}{$H+}

uses
  HTMLDoc;

var
  VHtml: THtmlDoc;
begin
  VHtml := THtmlDoc.Create;
  try
    VHtml.Title := 'HtmlDoc basic demo';
    VHtml.Body := 'Hello world!';
    Write(VHtml.Contents);
  finally
    VHtml.Free;
  end;
end.

