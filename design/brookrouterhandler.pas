(*
  Brook framework, Router Handler Class

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookRouterHandler;

{$i brook.inc}

interface

uses
  BrookRouter;

type
  { Handles exceptions for @link(TBrookRouterHandler). }
  EBrookRouterHandler = class(EBrookRouter);

  { Is a metaclass for @link(BrookRouterHandler) class. }
  TBrookRouterHandlerClass = class of TBrookRouterHandler;

  { Handles the router events. }
  TBrookRouterHandler = class(TBrookRouter)
  published
    property AfterExecuteAction;
    property AfterMatchPattern;
    property AfterRoute;
    property BeforeExecuteAction;
    property BeforeMatchPattern;
    property BeforeRoute;
  end;

implementation

end.
