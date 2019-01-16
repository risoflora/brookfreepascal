(*
  Brook framework, Choose Project Type Unit

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit frmBrookChooseProjectType;

{$i brook.inc}

interface

uses
  Forms, ExtCtrls, Buttons, Controls;

type
  TfrBrookChooseProjectType = class(TForm)
    btOK: TBitBtn;
    btCancel: TBitBtn;
    pnCliente: TPanel;
    pnBottom: TPanel;
    rgType: TRadioGroup;
    sbClient: TScrollBox;
  public
    class function Execute: Integer;
  end;

implementation

{$R *.lfm}

class function TfrBrookChooseProjectType.Execute: Integer;
begin
  with Self.Create(nil) do
    try
      Result := -1;
      ShowModal;
      if ModalResult <> mrOK then
        Exit;
      Result := rgType.ItemIndex;
    finally
      Free;
    end;
end;

end.

