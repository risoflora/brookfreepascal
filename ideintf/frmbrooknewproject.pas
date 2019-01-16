(*
  Brook framework, New Project Unit

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit frmBrookNewProject;

{$i brook.inc}

interface

uses
  Classes, SysUtils, Forms, Controls, Dialogs, ExtCtrls, Buttons, StdCtrls,
  ComCtrls, LCLType, LCLIntf, EditBtn, XMLPropStorage;

type

  { TfrBrookNewProject }

  TfrBrookNewProject = class(TForm)
    btAddAct: TBitBtn;
    btDeleteAct: TBitBtn;
    btEditAct: TBitBtn;
    btHelp: TBitBtn;
    btOK: TBitBtn;
    btPrior: TBitBtn;
    btNext: TBitBtn;
    btCancel: TBitBtn;
    edAppName: TEdit;
    edPubHTMLDir: TDirectoryEdit;
    imLogoRight: TImage;
    imLogoLeft: TImage;
    imLogoClient: TImage;
    lbActions: TLabel;
    lbAppName: TLabel;
    lbInfo2: TLabel;
    lbInfo1: TLabel;
    lbInfo3: TLabel;
    lbPubHTMLDir: TLabel;
    lvActions: TListView;
    pnTop: TPanel;
    pcWizard: TPageControl;
    pnActsBottom: TPanel;
    pnBottom: TPanel;
    rgAppType: TRadioGroup;
    rgCharset: TRadioGroup;
    sbApp: TScrollBox;
    sbActions: TScrollBox;
    tsFinish: TTabSheet;
    tsActions: TTabSheet;
    tsApp: TTabSheet;
    xml: TXMLPropStorage;
    procedure btAddActClick(Sender: TObject);
    procedure btDeleteActClick(Sender: TObject);
    procedure btEditActClick(Sender: TObject);
    procedure btNextClick(Sender: TObject);
    procedure btHelpClick(Sender: TObject);
    procedure btPriorClick(Sender: TObject);
    procedure edAppNameContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure edAppNameKeyPress(Sender: TObject; var Key: char);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure lvActionsClick(Sender: TObject);
    procedure lvActionsDblClick(Sender: TObject);
    procedure lvActionsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure pcWizardChange(Sender: TObject);
    procedure pcWizardChanging(Sender: TObject; var AllowChange: Boolean);
    procedure tsFinishShow(Sender: TObject);
  private
    FProjectType: Integer;
    class var FInstante: TfrBrookNewProject;
  public
    constructor Create(AOwner: TComponent;
      const AProjectType: Integer); reintroduce;
    procedure ValidateData(const AName, APattern: string;
      const ADefault: Boolean);
    class property Instante: TfrBrookNewProject read FInstante;
    property ProjectType: Integer read FProjectType write FProjectType;
  end;

procedure OnlyAlphaNumeric(var Key: Char);

implementation

{$R *.lfm}

uses
  frmBrookActEdit, BrookIDEIntf;

procedure OnlyAlphaNumeric(var Key: Char);
begin
  if not (Key in ['a'..'z', 'A'..'Z', '0'..'9', #8, #13, #27]) then
    Key := #0;
end;

constructor TfrBrookNewProject.Create(AOwner: TComponent;
  const AProjectType: Integer);
begin
  inherited Create(AOwner);
  xml.FileName := BrookGetExpertsConfigFileName;
  FInstante := Self;
  FProjectType := AProjectType;
end;

procedure TfrBrookNewProject.btNextClick(Sender: TObject);
begin
  pcWizard.PageIndex := Succ(pcWizard.PageIndex);
  pcWizardChange(Sender);
end;

procedure TfrBrookNewProject.btHelpClick(Sender: TObject);
begin
  OpenURL(
    'https://dl.dropboxusercontent.com/u/135304375/brookframework/doc/BrookAction.TBrookAction.html#Register');
end;

procedure TfrBrookNewProject.btAddActClick(Sender: TObject);
var
  VItem: TListItem;
  VDefault: Boolean;
  VName, VPattern: string;
begin
  lvActions.ItemFocused := nil;
  VName := '';
  VPattern := '';
  VDefault := False;
  if TfrBrookActEdit.Execute('Add', VName, VPattern, VDefault) then
  begin
    VItem := lvActions.Items.Add;
    VItem.Caption := VName;
    VItem.SubItems.Add(VPattern);
    VItem.SubItems.Add(BoolToStr(VDefault, True));
  end;
end;

procedure TfrBrookNewProject.btEditActClick(Sender: TObject);
var
  VItem: TListItem;
  VDefault: Boolean;
  VName, VPattern: string;
begin
  VItem := lvActions.ItemFocused;
  if Assigned(VItem) then
  begin
    VName := VItem.Caption;
    VPattern := VItem.SubItems[0];
    VDefault := StrToBool(VItem.SubItems[1]);
    if TfrBrookActEdit.Execute('Edit', VName, VPattern, VDefault) then
    begin
      VItem.Caption := VName;
      VItem.SubItems[0] := VPattern;
      VItem.SubItems[1] := BoolToStr(VDefault, True);
    end;
  end;
end;

procedure TfrBrookNewProject.btDeleteActClick(Sender: TObject);
var
  I: Integer;
begin
  I := lvActions.ItemIndex;
  if MessageDlg('Delete', Format('Delete action "%s"?',
    [lvActions.Items[I].Caption]), mtConfirmation, mbYesNo, 0) = mrYes then
  begin
    lvActions.Items.Delete(I);
    lvActions.ItemFocused := nil;
  end;
end;

procedure TfrBrookNewProject.btPriorClick(Sender: TObject);
begin
  pcWizard.PageIndex := pcWizard.PageIndex - 1;
  pcWizardChange(Sender);
end;

{$PUSH}{$WARN 5024 OFF}

procedure TfrBrookNewProject.edAppNameContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
  Handled := True;
end;

procedure TfrBrookNewProject.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_NEXT: btNext.Click;
    VK_PRIOR: btPrior.Click;
  end;
  if pcWizard.ActivePage = tsActions then
    case Key of
      VK_INSERT: btAddActClick(Sender);
      VK_F2: btEditActClick(Sender);
      VK_DELETE: btDeleteActClick(Sender);
      VK_F1: btHelpClick(Sender);
    end;
end;

procedure TfrBrookNewProject.lvActionsSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  btEditAct.Enabled := Selected;
  btDeleteAct.Enabled := Selected;
end;

{$POP}

procedure TfrBrookNewProject.edAppNameKeyPress(Sender: TObject; var Key: char);
begin
  OnlyAlphaNumeric(Key);
end;

procedure TfrBrookNewProject.FormShow(Sender: TObject);
begin
  pcWizardChange(Sender);
end;

procedure TfrBrookNewProject.lvActionsClick(Sender: TObject);
begin
  if lvActions.ItemIndex > -1 then
    lvActions.ItemFocused := lvActions.Items[lvActions.ItemIndex]
  else
    lvActions.ItemFocused := nil;
end;

procedure TfrBrookNewProject.lvActionsDblClick(Sender: TObject);
begin
  btEditAct.Click;
end;

procedure TfrBrookNewProject.pcWizardChange(Sender: TObject);
var
  I, C: Integer;
begin
  C := Pred(pcWizard.PageCount);
  I := pcWizard.PageIndex;
  btNext.Visible := I < C;
  btPrior.Visible := I < C;
  btNext.Enabled := I < C;
  btPrior.Enabled := I > 0;
  btOK.Visible := I = C;
  case I of
    0: ActiveControl := edAppName;
    1: ActiveControl := btAddAct;
    2:
      begin
        lbInfo1.Hide;
        ActiveControl := btOK;
      end;
  end;
end;

procedure TfrBrookNewProject.pcWizardChanging(Sender: TObject;
  var AllowChange: Boolean);
begin
  AllowChange := False;
  case pcWizard.PageIndex of
    0:
      begin
        if Trim(edAppName.Text) = '' then
        begin
          edAppName.SetFocus;
          ShowMessage('Please specify a name for the application.');
          Exit;
        end;
        if not DirectoryExists(edPubHTMLDir.Text) then
        begin
          edPubHTMLDir.SetFocus;
          ShowMessage('Please specify a valid directory.');
          Exit;
        end;
      end;
    1:
      if (FProjectType <> 1{designtime}) and (lvActions.Items.Count = 0) then
      begin
        ShowMessage('Please add at least one action.');
        Exit;
      end;
  end;
  AllowChange := True;
end;

procedure TfrBrookNewProject.tsFinishShow(Sender: TObject);
const
  AppType: array[0..1] of string = ('CGI', 'FastCGI');
begin
  lbInfo3.Caption := Format(lbInfo3.Caption, [AppType[rgAppType.ItemIndex]]);
end;

procedure TfrBrookNewProject.ValidateData(const AName, APattern: string;
  const ADefault: Boolean);

  function IsActionAdded(AItem: TListItem; const AFmt: string): Boolean;
  begin
    Result := SameText(AName, AItem.Caption);
    if Result then
      ShowMessage(Format(AFmt, [AItem.Caption]));
  end;

  function IsActionWithPatternAdded(AItem: TListItem;
    const AFmt: string): Boolean;
  var
    s: string;
  begin
    s := AItem.SubItems[0];
    Result := SameText(Trim(APattern), Trim(s));
    if Result then
      ShowMessage(Format(AFmt, [s]));
  end;

  function IsDefaultActionAdded(AItem: TListItem; const AFmt: string): Boolean;
  begin
    Result := ADefault and StrToBool(AItem.SubItems[1]);
    if Result then
      ShowMessage(Format(AFmt, [AItem.Caption]));
  end;

const
  CActionAdded = 'The action "%s" is already added.';
  CActionAddedWithPattern =
    'There is already an action added with the pattern "%s".';
  CDefaultActionAdded = 'There is already a default action added.';
var
  I: Integer;
  VItem, VSelected: TListItem;
begin
  VSelected := lvActions.ItemFocused;
  if Assigned(VSelected) then
    for I := 0 to Pred(lvActions.Items.Count) do
    begin
      VItem := lvActions.Items[I];
      if (VItem.Index <> VSelected.Index) and
        IsActionAdded(VItem, CActionAdded) then
        Abort;
      if (VItem.Index <> VSelected.Index) and
        IsActionWithPatternAdded(VItem, CActionAddedWithPattern) then
        Abort;
      if IsDefaultActionAdded(VItem, CDefaultActionAdded) then
        Abort;
    end
  else
    for I := 0 to Pred(lvActions.Items.Count) do
    begin
      VItem := lvActions.Items[I];
      if IsActionAdded(VItem, CActionAdded) then
        Abort;
      if IsActionWithPatternAdded(VItem, CActionAddedWithPattern) then
        Abort;
      if IsDefaultActionAdded(VItem, CDefaultActionAdded) then
        Abort;
    end;
end;

end.
