(*
  Brook framework, FCL EventLog Handler

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookFCLEventLogHandler;

{$mode objfpc}{$H+}

interface

uses
  BrookFCLEventLogBroker, BrookLogger;

type
  { Handles exceptions for @link(TBrookFCLEventLogHandler). }
  EBrookFCLEventLogHandler = class(EBrookLogger);

  { Is a metaclass for @link(TBrookFCLEventLogHandler) class. }
  TBrookFCLEventLogHandlerClass = class of TBrookFCLEventLogHandler;

  { Handles the logger features. }
  TBrookFCLEventLogHandler = class(TBrookFCLEventLog)
  published
    property Active;
    property FileName;
    property Output;
    property Types;
    property AfterLog;
    property BeforeLog;
  end;

implementation

end.

