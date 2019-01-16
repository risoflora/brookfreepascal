(*
  Brook framework, Messages (pt-BR) Handler Unit

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookMessagesHandler_ptBR;

{$i brook.inc}

interface

uses
  BrookMessages_ptBR, BrookException, BrookMessages, BrookClasses;

type
  { Handles exceptions for @link(TBrookMessagesHandler_ptBR). }
  EBrookMessagesHandler_ptBR = class(EBrook);

  { Is a metaclass for @link(TBrookMessagesHandler_ptBR) class. }
  TBrookMessagesHandler_ptBRClass = class of TBrookMessagesHandler_ptBR;

  { Handles the pt-BR messages. }
  TBrookMessagesHandler_ptBR = class(TBrookComponent)
  private
    function GetLocale: string;
  public
    { Translates all the internal messages of the framework. }
    procedure Translate;
    { Shows the default locale selected to the framework. }
    property Locale: string read GetLocale;
  end;

implementation

{ TBrookMessagesHandler_ptBR }

function TBrookMessagesHandler_ptBR.GetLocale: string;
begin
  Result := BrookMessages.SBrookDefaultLocale;
end;

procedure TBrookMessagesHandler_ptBR.Translate;
begin
  BrookMessages_ptBR.BrookTranslate;
  BrookMessages_ptBR.BrookHttpTranslate;
end;

end.
