program demo;

{$mode objfpc}{$H+}

uses
  EasyRSS;

var
  item: TRSSItem;
  rss: TRSSReader;
begin
  rss := TRSSReader.Create;
  try
    rss.LoadFromHttp('http://cyber.law.harvard.edu/rss/examples/rss2sample.xml');
    for item in rss.Items do
    begin
      WriteLn('<b>Title:</b> ', item.Title);
      WriteLn('<b>Description:</b> ', item.Description);
      Write('<hr>');
    end;
  finally
    rss.Free;
  end;
end.

