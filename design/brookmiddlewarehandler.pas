(*
  Brook framework, Middleware Handler Class

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookMiddlewareHandler;

{$i brook.inc}

interface

uses
  BrookMiddleware, BrookRouter, BrookAction, BrookHttpDefs, BrookUtils;

type
  { Handles exceptions for @link(TBrookMiddlewareHandler). }
  EBrookMiddlewareHandler = class(EBrookMiddleware);

  { Is a metaclass for @link(TBrookMiddlewareHandler) class. }
  TBrookMiddlewareHandlerClass = class of TBrookMiddlewareHandler;

  { Defines an enumerator to represent the middleware execution modes. }
  TBrookMiddlewareExecMode = (emBefore, emAfter);

  { Handles the middleware events. }
  TBrookMiddlewareHandler = class(TBrookMiddleware)
  private
    FExecMode: TBrookMiddlewareExecMode;
    FOnExecAction: TBrookExecuteActionEvent;
  protected
    procedure Loaded; override;
    procedure DoExecute(ASender: TObject; AAction: TBrookAction;
      ARequest: TBrookRequest; AResponse: TBrookResponse; const ANames,
      AValues: TBrookArrayOfString; ARoute: TBrookRoute;
      var AHandled: Boolean); override;
  published
    property OnExecute;
    { Defines if the middleware will be executed before or after the action
      execution. }
    property ExecMode: TBrookMiddlewareExecMode read FExecMode write FExecMode
      default emBefore;
    { Is triggered when the @code(DoExecute) method bound in this class is
      executed. }
    property OnExecAction: TBrookExecuteActionEvent read FOnExecAction
      write FOnExecAction;
  end;

implementation

{ TBrookMiddlewareHandler }

procedure TBrookMiddlewareHandler.Loaded;
begin
  inherited Loaded;
  case FExecMode of
    emBefore: BindExecution(@TBrookRouter.Service.BeforeExecuteAction);
    emAfter: BindExecution(@TBrookRouter.Service.AfterExecuteAction);
  end;
end;

procedure TBrookMiddlewareHandler.DoExecute(ASender: TObject;
  AAction: TBrookAction; ARequest: TBrookRequest; AResponse: TBrookResponse;
  const ANames, AValues: TBrookArrayOfString; ARoute: TBrookRoute;
  var AHandled: Boolean);
begin
  inherited DoExecute(ASender, AAction, ARequest, AResponse, ANames, AValues,
    ARoute, AHandled);
  if Assigned(FOnExecAction) then
    FOnExecAction(ASender, AAction, ARequest, AResponse, ANames, AValues,
      ARoute, AHandled);
end;

end.
