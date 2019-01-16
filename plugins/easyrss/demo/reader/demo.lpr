program demo;

{$mode objfpc}{$H+}

uses
  EasyRSS;

var
  rss: TRSSReader;
begin
  rss := TRSSReader.Create;
  try
    rss.LoadFromHttp('http://cyber.law.harvard.edu/rss/examples/rss2sample.xml');
    Write(rss.Content);
  finally
    rss.Free;
  end;
end.

