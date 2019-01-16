program project1;

{$mode objfpc}{$H+}

uses
  BrookHTTPUtils, BrookHTTPClient, BrookFCLHTTPClientBroker;

const
  URL = 'http://www.google.com/humans.txt';

var
  VData: string;
  VClient: TBrookHTTPClient;
  VHttp: TBrookHTTPDef = nil;
begin
  WriteLn('utils ...');
  WriteLn(BrookHttpRequest(URL).Content);

  VClient := TBrookHTTPClient.Create('fclweb');
  try
    WriteLn('direct ...');
    WriteLn(VClient.Request(URL).Content);

    WriteLn('custom ...');
    VClient.Prepare(VHttp);
    VHttp.Method := 'GET';
    VHttp.Url := URL;
    VClient.Request(VHttp);
    VHttp.Document.Seek(0, 0);
    SetLength(VData, VHttp.Document.Size);
    VHttp.Document.Read(VData[1], Length(VData));
    WriteLn(VData);
  finally
    VHttp.Free;
    VClient.Free;
  end;
end.

