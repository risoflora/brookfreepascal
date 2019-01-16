program demo;

{$mode objfpc}{$H+}

uses
  EasyRSS;

var
  rss: TRSS;
  item: TRSSItem;
begin
  rss := TRSS.Create;
  try
    rss.Title := 'News';
    rss.Copyright := 'EasyRSS';
    item := rss.Add;
    item.Title := 'Test 1';
    item.Description := '1 - Testing RSS ...';
    item := rss.Add;
    item.Title := 'Test 2';
    item.Description := '2 - Testing RSS ...';
    Write(rss.Content);
  finally
    rss.Free;
  end;
end.

