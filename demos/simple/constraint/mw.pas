unit mw;

{$mode objfpc}{$H+}

interface

uses
  BrookMiddleware, BrookRouter, BrookConstraints, BrookAction, SysUtils;

type

  { TMiddleware }

  TMiddleware = class(TBrookMiddleware)
  public
    procedure Execute(ASender: TObject; AAction: TBrookAction;
      ARoute: TBrookRoute); override;
  end;

implementation

var
  Middleware: TMiddleware;

{ TMiddleware }

procedure TMiddleware.Execute(ASender: TObject; AAction: TBrookAction;
  ARoute: TBrookRoute);
begin
  TBrookConstraints.Service.Execute(AAction, ARoute);
end;

initialization
  Middleware := TMiddleware.Create(@TBrookRouter.Service.BeforeExecuteAction);

finalization
  FreeAndNil(Middleware);

end.

