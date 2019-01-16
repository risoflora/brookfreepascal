unit testbrookmiddleware;

{$mode objfpc}{$H+}

interface

uses
  BrookMiddleware, BrookRouter, BrookAction, BrookHttpDefs, fpcunit,
  testregistry, sysutils;

type

  { TAction1 }

  TAction1 = class(TBrookAction)
  public
    procedure Get; override;
  end;

  { TMiddleware }

  TMiddleware = class(TBrookMiddleware)
  private
    FMyContent: string;
  public
    procedure Execute(ASender: TObject; AAction: TBrookAction;
      ARoute: TBrookRoute); override;
    property MyContent: string read FMyContent;
  end;

  { TTestBrookMiddleware }

  TTestBrookMiddleware = class(TTestCase)
  published
    procedure TestExecute;
  end;

implementation

var
  Middleware: TMiddleware;

{ TAction1 }

procedure TAction1.Get;
begin
  Write('OK');
end;

{ TMiddleware }

procedure TMiddleware.Execute(ASender: TObject; AAction: TBrookAction;
  ARoute: TBrookRoute);
begin
  FMyContent := Trim(TAction1(AAction).HttpResponse.Contents.Text);
  inherited Execute(ASender, AAction, ARoute);
end;

{ TTestBrookMiddleware }

procedure TTestBrookMiddleware.TestExecute;
var
  rt: TBrookRouter;
  rq: TBrookRequest;
  rs: TBrookResponse;
begin
  rq := TBrookRequest.Create;
{$WARNINGS OFF}
  rs := TBrookResponse.Create(rq);
{$WARNINGS ON}
  try
    rt := TBrookRouter.Service;
    Middleware.BindExecution(@rt.AfterExecuteAction);
    rt.Routes.Clear;
    TAction1.Register('/action1');
    rq.Method := 'GET';
    rq.PathInfo := '/action1';
    rt.Route(rq, rs);
    AssertEquals('OK', Middleware.MyContent);
  finally
    rs.Free;
    rq.Free;
  end;
end;

initialization
  Middleware := TMiddleware.Create;
  RegisterTest(TTestBrookMiddleware);

finalization
  FreeAndNil(Middleware);

end.

