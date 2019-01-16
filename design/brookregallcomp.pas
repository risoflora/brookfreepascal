(*
  Brook framework, Register all Components

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookRegAllComp;

{$i brook.inc}

interface

uses
  BrookRouterHandler, BrookSessionHandler, BrookMiddlewareHandler,
  BrookMessagesHandler_ptBR, BrookFCLEventLogHandler, BrookConfiguratorHandler,
  Classes;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Brook Core', [TBrookConfiguratorHandler,
    TBrookSessionHandler, TBrookMiddlewareHandler, TBrookRouterHandler,
    TBrookMessagesHandler_ptBR]);
  RegisterComponents('Brook Brokers', [TBrookFCLEventLogHandler]);
end;

end.
