unit testbrookrouter;

{$mode objfpc}{$H+}

interface

uses
  BrookRouter, BrookAction, BrookHttpDefs, BrookUtils, BrookHTTPConsts, fpcunit,
  testregistry, sysutils;

type

  { TAction1 }

  TAction1 = class(TBrookAction)
  public
    procedure Get; override;
  end;

  { TAction2 }

  TAction2 = class(TAction1)
  public
    procedure Post; override;
  end;

  { TAction3 }

  TAction3 = class(TAction1)
  public
    procedure Get; override;
  end;

  { TAction4 }

  TAction4 = class(TAction1)
  public
    procedure Get; override;
  end;

  { TReq }

  TReq = class(TBrookRequest)
  private
    FQueryString: string;
  public
    function GetFieldValue(AIndex: Integer): string; override;
    procedure SetFieldValue(AIndex: Integer; AValue: string); override;
  end;

  { TTestBrookRoutes }

  TTestBrookRoutes = class(TTestCase)
  published
    procedure TestClear;
    procedure TestCount;
    procedure TestAdd;
    procedure TestGetDefaultActionClass;
    procedure TestPatternByActionClass;
    procedure TestActionClassByPattern;
    procedure TestActionClassByClassName;
  end;

  { TTestBrookRouter }

  TTestBrookRouter = class(TTestCase)
  published
    procedure TestUrlFor;
    procedure TestCanonicalize;
    procedure TestMatchPattern;
    procedure TestRoute;
  end;

implementation

{ TAction1 }

procedure TAction1.Get;
begin
  Write('OK 1');
end;

{ TAction2 }

procedure TAction2.Post;
begin
  Write('OK 2');
end;

{ TAction3 }

procedure TAction3.Get;
begin
  Write('OK 3');
end;

{ TAction4 }

procedure TAction4.Get;
begin
  Write('OK 4');
end;

{ TReq }

function TReq.GetFieldValue(AIndex: Integer): string;
begin
  case AIndex of
    33{QUERY_STRING}: Result := FQueryString;
  else
    Result := inherited GetFieldValue(AIndex);
  end;
end;

procedure TReq.SetFieldValue(AIndex: Integer; AValue: string);
begin
  case AIndex of
    33{QUERY_STRING}: FQueryString := AValue;
  else
    inherited SetFieldValue(AIndex, AValue);
  end;
end;

{ TTestBrookRoutes }

procedure TTestBrookRoutes.TestClear;
var
  rts: TBrookRoutes;
begin
  rts := TBrookRouter.Service.Routes;
  rts.Clear;
  rts.Add(TAction1, '/action1', rmGet, False);
  rts.Add(TAction2, '/action2', rmGet, False);
  rts.Clear;
  AssertEquals(0, rts.Count);
end;

procedure TTestBrookRoutes.TestCount;
var
  rts: TBrookRoutes;
begin
  rts := TBrookRouter.Service.Routes;
  rts.Clear;
  rts.Add(TAction1, '/action1', rmGet, False);
  rts.Add(TAction2, '/action2', rmGet, False);
  AssertEquals(2, rts.Count);
end;

procedure TTestBrookRoutes.TestAdd;
var
  rts: TBrookRoutes;
begin
  rts := TBrookRouter.Service.Routes;
  rts.Clear;
  rts.Add(TAction1, '/action1', rmGet, False);
  rts.Add(TAction2, '/action2', rmGet, False);
  AssertEquals(TAction1, rts.ActionClassByClassName('taction1'));
  AssertEquals(TAction2, rts.ActionClassByClassName('taction2'));
end;

procedure TTestBrookRoutes.TestGetDefaultActionClass;
var
  idx: Integer = -1;
  rts: TBrookRoutes;
  cls: TBrookActionClass = nil;
begin
  rts := TBrookRouter.Service.Routes;
  rts.Clear;
  rts.Add(TAction1, '/action1', rmGet, False);
  rts.Add(TAction2, '/action2', rmGet, True);
  rts.GetDefaultActionClass(cls, idx);
  AssertEquals('TAction2 - 1', cls.ClassName + ' - ' + IntToStr(idx));
end;

procedure TTestBrookRoutes.TestPatternByActionClass;
var
  rts: TBrookRoutes;
begin
  rts := TBrookRouter.Service.Routes;
  rts.Clear;
  rts.Add(TAction1, '/action1', rmGet, False);
  rts.Add(TAction2, '/action2', rmGet, False);
  AssertEquals('/action2', rts.PatternByActionClass(TAction2));
end;

procedure TTestBrookRoutes.TestActionClassByPattern;
var
  rts: TBrookRoutes;
begin
  rts := TBrookRouter.Service.Routes;
  rts.Clear;
  rts.Add(TAction1, '/action1', rmGet, False);
  rts.Add(TAction2, '/action2', rmGet, False);
  AssertEquals(TAction2, rts.ActionClassByPattern('/action2'));
end;

procedure TTestBrookRoutes.TestActionClassByClassName;
var
  rts: TBrookRoutes;
begin
  rts := TBrookRouter.Service.Routes;
  rts.Clear;
  rts.Add(TAction1, '/action1', rmGet, False);
  rts.Add(TAction2, '/action2', rmGet, False);
  AssertEquals(TAction2, rts.ActionClassByClassName('TAction2'));
end;

{ TTestBrookRouter }

procedure TTestBrookRouter.TestUrlFor;
var
  rt: TBrookRouter;
begin
  rt := TBrookRouter.Service;
  rt.Routes.Clear;
  TAction1.Register('/action1');
  TAction2.Register('/action2/:myvar1/:myvar2');
  AssertEquals('/action1', rt.UrlFor(TAction1, []));
  AssertEquals('/action1', rt.UrlFor('TAction1', []));
  AssertEquals('/action2/abc/123', rt.UrlFor(TAction2, ['abc', '123']));
  AssertEquals('/action2/abc/123', rt.UrlFor('TAction2', ['abc', '123']));
end;

procedure TTestBrookRouter.TestCanonicalize;
var
  rq: TReq;
  rs: TBrookResponse;
  rt: TBrookRouter;
begin
  rq := TReq.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  try
    rt := TBrookRouter.Service;
    rq.PathInfo := '/action';
    rt.Canonicalize(rq, rs);
    AssertEquals(BROOK_HTTP_STATUS_CODE_TEMPORARY_REDIRECT, rs.Code);
    AssertEquals(BROOK_HTTP_REASON_PHRASE_TEMPORARY_REDIRECT, rs.CodeText);
    AssertEquals('/action/', rs.Location);
    rq.PathInfo := '/action/';
    rt.Canonicalize(rq, rs);
    AssertEquals(BROOK_HTTP_STATUS_CODE_TEMPORARY_REDIRECT, rs.Code);
    AssertEquals(BROOK_HTTP_REASON_PHRASE_TEMPORARY_REDIRECT, rs.CodeText);
    AssertEquals('/action/', rs.Location);
    rq.PathInfo := '/action';
    rq.QueryString := 'q=abc123';
    rt.Canonicalize(rq, rs);
    AssertEquals(BROOK_HTTP_STATUS_CODE_TEMPORARY_REDIRECT, rs.Code);
    AssertEquals(BROOK_HTTP_REASON_PHRASE_TEMPORARY_REDIRECT, rs.CodeText);
    AssertEquals('/action/?q=abc123', rs.Location);
    rq.PathInfo := '/action/';
    rq.QueryString := 'q=abc123';
    rt.Canonicalize(rq, rs);
    AssertEquals(BROOK_HTTP_STATUS_CODE_TEMPORARY_REDIRECT, rs.Code);
    AssertEquals(BROOK_HTTP_REASON_PHRASE_TEMPORARY_REDIRECT, rs.CodeText);
    AssertEquals('/action/?q=abc123', rs.Location);
  finally
    rq.Free;
    rs.Free;
  end;
end;

procedure TTestBrookRouter.TestMatchPattern;
var
  rt: TBrookRouter;
  mp, rd: Boolean;
  ns, vls: TBrookArrayOfString;
begin
  rt := TBrookRouter.Service;
  mp := rt.MatchPattern('/action', '/action/', rd, ns, vls);
  AssertFalse(mp);
  mp := rt.MatchPattern('/action', '/action', rd, ns, vls);
  AssertTrue(mp);
  AssertFalse(rd);
  AssertEquals(-1, High(ns));
  AssertEquals(-1, High(vls));
  mp := rt.MatchPattern('/action/', '/action', rd, ns, vls);
  AssertTrue(mp);
  AssertTrue(rd);
  mp := rt.MatchPattern('/action/:myvar1/:myvar2', '/action/abc/123', rd, ns,
    vls);
  AssertEquals('myvar1', ns[0]);
  AssertEquals('myvar2', ns[1]);
  AssertEquals('abc', vls[0]);
  AssertEquals('123', vls[1]);
  mp := rt.MatchPattern('/action/:myvar1/:myvar2/', '/action/abc/123/?q=abc123',
    rd, ns, vls);
  AssertEquals('myvar1', ns[0]);
  AssertEquals('myvar2', ns[1]);
  AssertEquals('abc', vls[0]);
  AssertEquals('123', vls[1]);
  mp := rt.MatchPattern('/action/*', '/action/abc/123', rd, ns, vls);
  AssertTrue(mp);
end;

procedure TTestBrookRouter.TestRoute;
var
  rq: TReq;
  rs: TBrookResponse;
  rt: TBrookRouter;
begin
  rq := TReq.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  try
    rt := TBrookRouter.Service;
    rt.Routes.Clear;
    TAction1.Register('/action1');
    TAction2.Register('/action2', rmPost);
    TAction3.Register('/action3/*/foo');
    TAction4.Register('/action4/*');
    rq.Method := 'GET';
    rq.PathInfo := '/action1';
    rt.Route(rq, rs);
    AssertEquals('OK 1', Trim(rs.Contents.Text));
    rs.Contents.Clear;
    rq.Method := 'POST';
    rq.PathInfo := '/action2';
    rt.Route(rq, rs);
    AssertEquals('OK 2', Trim(rs.Contents.Text));
    rs.Contents.Clear;
    rq.Method := 'GET';
    rq.PathInfo := '/action3/abc123/foo';
    rt.Route(rq, rs);
    AssertEquals('OK 3', Trim(rs.Contents.Text));
    rs.Contents.Clear;
    rq.Method := 'GET';
    rq.PathInfo := '/action4/foo/bar/abc123';
    rt.Route(rq, rs);
    AssertEquals('OK 4', Trim(rs.Contents.Text));
  finally
    rq.Free;
    rs.Free;
  end;
end;

initialization
  RegisterTest(TTestBrookRoutes);
  RegisterTest(TTestBrookRouter);

end.

