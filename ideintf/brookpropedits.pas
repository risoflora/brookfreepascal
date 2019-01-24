(*
  Brook for Free Pascal

  Copyright (C) 2014-2019 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

{ Property editors unit. }

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
