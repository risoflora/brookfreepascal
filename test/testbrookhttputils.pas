unit testbrookhttputils;

{$mode objfpc}{$H+}

interface

uses
  BrookFCLHttpClientBroker, BrookHttpUtils, BrookUtils, BrookHttpClient,
  fpcunit, testregistry, sysutils;

type

  { TTestBrookHttpUtils }

  TTestBrookHttpUtils = class(TTestCase)
  published
    procedure TestDateTimeToGMT;
    procedure TestSameURL;
    procedure TestStatusCodeToReasonPhrase;
    procedure TestReasonPhraseToStatusCode;
    procedure TestGetAcceptEncodingSet;
    procedure TestGetAcceptEncoding;
    procedure TestMimeTypeFromFileExt;
    procedure TestTypeFromFileName;
    procedure TestFileExtFromMimeType;
    procedure TestExtractUrlFileName;
    procedure RequestMethodToStr;
    procedure StrToRequestMethod;
    procedure HttpRequest;
  end;

const
  TEST_DATE_TIME = 41233 + 0.6161111111;

implementation

{ TTestBrookHttpUtils }

procedure TTestBrookHttpUtils.TestDateTimeToGMT;
begin
  AssertEquals('Tue, 20 Nov 2012 14:47:12 GMT',
    BrookDateTimeToGMT(TEST_DATE_TIME));
end;

procedure TTestBrookHttpUtils.TestSameURL;
begin
  AssertTrue(BrookSameURL('http://localhost', 'http://localhost/'));
end;

procedure TTestBrookHttpUtils.TestStatusCodeToReasonPhrase;
begin
  AssertEquals('OK', BrookStatusCodeToReasonPhrase(200));
end;

procedure TTestBrookHttpUtils.TestReasonPhraseToStatusCode;
begin
  AssertEquals(200, BrookReasonPhraseToStatusCode('OK'));
end;

procedure TTestBrookHttpUtils.TestGetAcceptEncodingSet;
begin
  AssertEquals('deflate,gzip', BrookGetAcceptEncoding([aeDeflate, aeGzip]));
end;

procedure TTestBrookHttpUtils.TestGetAcceptEncoding;
begin
  AssertTrue(BrookGetAcceptEncodingSet('deflate,gzip') = [aeDeflate, aeGzip]);
end;

procedure TTestBrookHttpUtils.TestMimeTypeFromFileExt;
begin
  AssertEquals('text/plain', BrookMimeTypeFromFileExt('.txt'));
end;

procedure TTestBrookHttpUtils.TestTypeFromFileName;
begin
  AssertEquals('text/plain', BrookMimeTypeFromFileName('/foo/file.txt'));
end;

procedure TTestBrookHttpUtils.TestFileExtFromMimeType;
begin
  AssertEquals('.txt', BrookFileExtFromMimeType('text/plain'));
end;

procedure TTestBrookHttpUtils.TestExtractUrlFileName;
begin
  AssertEquals('dummy.txt',
    BrookExtractUrlFileName('http://localhost/dummy.txt'));
  AssertEquals('dummy.txt',
    BrookExtractUrlFileName('http://localhost/dummy.txt?foo=bah', True));
end;

procedure TTestBrookHttpUtils.RequestMethodToStr;
begin
  AssertEquals('GET', BrookRequestMethodToStr(rmGet));
  AssertEquals('POST', BrookRequestMethodToStr(rmPost));
  AssertEquals('PUT', BrookRequestMethodToStr(rmPut));
  AssertEquals('DELETE', BrookRequestMethodToStr(rmDelete));
  AssertEquals('HEAD', BrookRequestMethodToStr(rmHead));
  AssertEquals('OPTIONS', BrookRequestMethodToStr(rmOptions));
  AssertEquals('TRACE', BrookRequestMethodToStr(rmTrace));
end;

procedure TTestBrookHttpUtils.StrToRequestMethod;
begin
  AssertTrue(BrookStrToRequestMethod('GET') = rmGet);
  AssertTrue(BrookStrToRequestMethod('POST') = rmPost);
  AssertTrue(BrookStrToRequestMethod('PUT') = rmPut);
  AssertTrue(BrookStrToRequestMethod('DELETE') = rmDelete);
  AssertTrue(BrookStrToRequestMethod('HEAD') = rmHead);
  AssertTrue(BrookStrToRequestMethod('OPTIONS') = rmOptions);
  AssertTrue(BrookStrToRequestMethod('TRACE') = rmTrace);
end;

procedure TTestBrookHttpUtils.HttpRequest;
var
  r: TBrookHttpResult;
begin
  r := BrookHttpRequest('http://silvioprog.github.io/brookframework/');
  AssertTrue(r.Content <> '');
  r := BrookHttpRequest('http://brookframework.org/cgi-bin/cgi1.bf/' +
    'personlist?jtStartIndex=0&jtPageSize=5&jtSorting=id%20ASC', rmPost);
  AssertEquals('{ "Result" : "OK", "TotalRecordCount" : 11, "Records" : ' +
    '[{ "id" : 1, "name" : "Silvio Clecio" }, { "id" : 2, "name" : ' +
    '"Luciano Souza" }, { "id" : 3, "name" : "Joao Morais" }, { "id" : 4, ' +
    '"name" : "Waldir Paim" }, { "id" : 5, "name" : "Gilson Nunes" }] }',
    Trim(r.Content));
  AssertEquals('OK', r.ReasonPhrase);
  AssertEquals(200, r.StatusCode);
end;

initialization
  RegisterTest(TTestBrookHttpUtils);

end.

