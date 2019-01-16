(*
  Duall Sistemas, Base Classes Unit

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit dClasses;

{$i dopf.inc}

interface

uses
  Classes, SysUtils;

type

  { EdException }

  EdException = class(Exception);

  { TdObject }

  TdObject = class(TObject)
  end;

  { TdComponent }

  TdComponent = class(TComponent)
  end;

implementation

end.

