(*
  Brook framework, Middleware Classes

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookMiddleware;

{$i brook.inc}

interface

uses
  BrookClasses, BrookAction, BrookRouter, BrookException, BrookHttpDefs,
  BrookUtils;

type
  { Handles exceptions for @link(TBrookMiddleware). }
  EBrookMiddleware = class(EBrook);

  { Is a metaclass for @link(TBrookMiddleware) class. }
  TBrookMiddlewareClass = class of TBrookMiddleware;

  { Is a type to @code(*Middleware.OnExecute) event. }
  TBrookMiddlewareExecuteEvent = procedure(ASender: TObject;
    AAction: TBrookAction; ARoute: TBrookRoute) of object;
  { Defines a pointer to the @code(TBrookMiddlewareExecuteEvent) type.}
  PBrookMiddlewareExecuteEvent = ^TBrookMiddlewareExecuteEvent;

  { Intermediates two classes through a @code(TBrookExecuteActionEvent) event. }
  TBrookMiddleware = class(TBrookComponent)
  private
    FOldExecute: TBrookExecuteActionEvent;
    FOnExecute: TBrookMiddlewareExecuteEvent;
  protected
    procedure DoExecute(ASender: TObject; AAction: TBrookAction;
      ARequest: TBrookRequest; AResponse: TBrookResponse; const ANames,
      AValues: TBrookArrayOfString; ARoute: TBrookRoute;
      var AHandled: Boolean); virtual;
  public
    { Creates an instance of a @link(TBrookMiddleware) class. }
    constructor Create(ABoundEvent: PBrookExecuteActionEvent); overload; virtual;
    { Is triggered when the @code(DoExecute) method bound in this class is
      executed. }
    procedure Execute(ASender: TObject; AAction: TBrookAction;
      ARoute: TBrookRoute); virtual;
    { Bindes a @code(TBrookExecuteActionEvent) event to this class keeping the
      implementation of a previously declared event. }
    procedure BindExecution(AEvent: PBrookExecuteActionEvent);
    { Is triggered when the @code(Execute) method bound in this class is
      executed. }
    property OnExecute: TBrookMiddlewareExecuteEvent read FOnExecute
      write FOnExecute;
  end;

implementation

{ TBrookCustomMiddleware }

constructor TBrookMiddleware.Create(ABoundEvent: PBrookExecuteActionEvent);
begin
  inherited Create(nil);
  BindExecution(ABoundEvent);
end;

procedure TBrookMiddleware.DoExecute(ASender: TObject; AAction: TBrookAction;
  ARequest: TBrookRequest; AResponse: TBrookResponse; const ANames,
  AValues: TBrookArrayOfString; ARoute: TBrookRoute; var AHandled: Boolean);
begin
  Execute(ASender, AAction, ARoute);
  if Assigned(FOldExecute) then
    FOldExecute(ASender, AAction, ARequest, AResponse, ANames, AValues, ARoute,
      AHandled);
end;

{$PUSH}{$WARN 5024 OFF}

procedure TBrookMiddleware.Execute(ASender: TObject; AAction: TBrookAction;
  ARoute: TBrookRoute);
begin
  if Assigned(FOnExecute) then
    FOnExecute(Self, AAction, ARoute);
end;

{$POP}

procedure TBrookMiddleware.BindExecution(AEvent: PBrookExecuteActionEvent);
begin
  if Assigned(AEvent) then
  begin
    FOldExecute := AEvent^;
    AEvent^ := @DoExecute;
  end;
end;

end.

