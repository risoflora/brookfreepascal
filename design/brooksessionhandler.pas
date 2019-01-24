(*
  Brook for Free Pascal

  Copyright (C) 2014-2019 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

{ Session handler class. }

unit BrookSessionHandler;

{$i brook.inc}

interface

uses
  BrookSession;

type
  { Handles exceptions for @link(TBrookSession). }
  EBrookSessionHandler = class(EBrookSession);

  { Is a metaclass for @link(TBrookSessionHandler) class. }
  TBrookSessionHandlerClass = class of TBrookSessionHandler;

  { Handles the session features. }
  TBrookSessionHandler = class(TBrookSession)
  published
    property CookieName;
    property CookieDomain;
    property CookiePath;
    property CookieSecure;
    property CookieExpires;
    property Fields;
    property IgnoredFields;
    property Directory;
    property FilePrefix;
    property TimeOut;
    property HttpOnly;
    property AfterStart;
    property BeforeStart;
    property AfterFinish;
    property BeforeFinish;
    property AfterExpire;
    property BeforeExpire;
  end;

implementation

end.
