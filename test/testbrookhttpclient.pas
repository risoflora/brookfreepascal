unit testbrookhttpclient;

{$mode objfpc}{$H+}

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, fpcunit, testregistry;

const
  URL = 'http://silvioprog.github.io/brookframework/';
  LIB = 'fclweb';
  OK = 200;
  SOK = 'OK';
  GET = 'GET';

type

  { TTestBrookHTTPClient }

  TTestBrookHTTPClient = class(TTestCase)
  published
    procedure TestClient;
    procedure TestHttpDef;
  end;

implementation

{ TTestBrookHTTPClient }

procedure TTestBrookHTTPClient.TestClient;
var
  cl: TBrookHTTPClient;
  r: TBrookHTTPResult;
begin
  cl := TBrookHTTPClient.Create(LIB);
  try
    r := cl.Request(URL);
    AssertEquals(SOK, r.ReasonPhrase);
    AssertEquals(OK, r.StatusCode);
    AssertTrue(Length(r.Content) > 0);
  finally
    cl.Free
  end;
end;

{ TTestBrookHTTPClient }

procedure TTestBrookHTTPClient.TestHttpDef;
var
  cl: TBrookHTTPClient;
  ht: TBrookHTTPDef = nil;
  r: TBrookHTTPResult;
begin
  cl := TBrookHTTPClient.Create(LIB);
  try
    cl.Prepare(ht);
    ht.Method := GET;
    ht.Url := URL;
    r := cl.Request(ht);
    AssertEquals(SOK, r.ReasonPhrase);
    AssertEquals(OK, r.StatusCode);
    AssertTrue(Length(r.Content) > 0);
    AssertTrue(ht.Contents.Count > 0);
    AssertTrue(ht.Document.Size > 0);
    AssertTrue(ht.Cookies.Count = 0);
  finally
    ht.Free;
    cl.Free
  end;
end;

initialization
  RegisterTest(TTestBrookHTTPClient);

end.

