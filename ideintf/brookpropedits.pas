(*
  Brook framework, Property Editors Unit

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookPropEdits;

{$i brook.inc}

interface

uses
  BrookClasses, PropEdits;

implementation

initialization
  RegisterPropertyEditor(TypeInfo(AnsiString), TBrookComponent, 'Directory',
    TDirectoryPropertyEditor);
  RegisterPropertyEditor(TypeInfo(AnsiString), TBrookComponent, 'FileName',
    TFileNamePropertyEditor);

end.
