(*
  Brook framework, Action Edit Unit

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit frmBrookActEdit;

{$i brook.inc}

interface

uses
  Forms, ExtCtrls, Buttons, StdCtrls, Controls, SysUtils, Dialogs;

type
  TfrBrookActEdit = class(TForm)
    btOK: TBitBtn;
    btCancel: TBitBtn;
    cbDefault: TCheckBox;
    edName: TEdit;
    edPattern: TEdit;
    lbInfo: TLabel;
    lbName: TLabel;
    lbPattern: TLabel;
    pnClient: TPanel;
    pnBottom: TPanel;
    sbClient: TScrollBox;
    procedure edNameExit(Sender: TObject);
    procedure edNameKeyPress(Sender: TObject; var Key: char);
    procedure edPatternKeyPress(Sender: TObject; var Key: char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FQuiet: Boolean;
  public
    class function Execute(const ACapType: ShortString;
      var AName, APattern: string; var ADefault: Boolean;
      const AQuiet: Boolean = False): Boolean;
    procedure AssertData(const AExpr: Boolean; const AMsg: string;
      AControl: TWinControl);
  end;

implementation

{$R *.lfm}

uses
  frmBrookNewProject;

procedure TfrBrookActEdit.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  VForm: TfrBrookNewProject;
begin
  if ModalResult <> mrOK then
    Exit;
  CanClose := False;
  AssertData(edName.Text <> '',
    'Please specify a name for the action.', edName);
  if not FQuiet then
  begin
    VForm := TfrBrookNewProject.Instante;
    VForm.lvActions.Selected := nil;
    VForm.ValidateData(edName.Text, edPattern.Text, cbDefault.Checked);
  end;
  CanClose := True;
end;

procedure TfrBrookActEdit.edNameKeyPress(Sender: TObject; var Key: char);
begin
  OnlyAlphaNumeric(Key);
end;

procedure TfrBrookActEdit.edNameExit(Sender: TObject);
begin
  if (edName.Text <> '') and (edPattern.Text = '') then
  begin
    edPattern.Text := '/' + LowerCase(edName.Text);
    edPattern.SetFocus;
  end;
end;

procedure TfrBrookActEdit.edPatternKeyPress(Sender: TObject; var Key: char);
begin
  case Key of
    '*', ':', '/':;
    '\': Key := '/';
  else
    OnlyAlphaNumeric(Key);
  end;
end;

class function TfrBrookActEdit.Execute(const ACapType: ShortString;
  var AName, APattern: string; var ADefault: Boolean;
  const AQuiet: Boolean): Boolean;
begin
  with Self.Create(nil) do
    try
      FQuiet := AQuiet;
      Caption := Format(Caption, [ACapType]);
      edName.Text := AName;
      edPattern.Text := APattern;
      cbDefault.Checked := ADefault;
      Result := ShowModal = mrOK;
      if Result then
      begin
        AName := edName.Text;
        APattern := edPattern.Text;
        ADefault := cbDefault.Checked;
      end;
    finally
      Free;
    end;
end;

procedure TfrBrookActEdit.AssertData(const AExpr: Boolean; const AMsg: string;
  AControl: TWinControl);
begin
  if not AExpr then
  begin
    if AControl.CanFocus then
      AControl.SetFocus;
    ShowMessage(AMsg);
    Abort;
  end;
end;

end.

