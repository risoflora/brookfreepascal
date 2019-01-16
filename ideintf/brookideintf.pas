(*
  Brook framework, IDE Intf Unit

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookIDEIntf;

{$i brook.inc}

interface

uses
  BrookClasses, frmBrookChooseProjectType, frmBrookNewProject, frmBrookNewBroker,
  frmBrookActEdit, ProjectIntf, NewItemIntf, LazIDEIntf, ProjectResourcesIntf,
  FormEditingIntf, Classes, SysUtils, Controls, ComCtrls, Forms, Dialogs;

type
  TBrookBrokersFileDescPascalUnit = class;

  { TBrookCustomSimpleCGIProjectDescriptor }

  TBrookCustomSimpleCGIProjectDescriptor = class(TProjectDescriptor)
  private
    FProjectType: Integer;
  protected
    function DoInitDescriptor: TModalResult; override;
  public
    constructor Create; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    property ProjectType: Integer read FProjectType write FProjectType; // 0 - runtime, 1 - designtime
  end;

  { TBrookSimpleCGIProjectDescriptor }

  TBrookSimpleCGIProjectDescriptor = class(TBrookCustomSimpleCGIProjectDescriptor)
  protected
    procedure ConfigureBrokerItem(AItem: TBrookBrokersFileDescPascalUnit); virtual;
    procedure CreateProjectFile(AProject: TLazProject); virtual;
  public
    constructor Create; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
  end;

  { TBrookSimpleFastCGIProjectDescriptor }

  TBrookSimpleFastCGIProjectDescriptor = class(TBrookSimpleCGIProjectDescriptor)
  protected
    procedure ConfigureBrokerItem(AItem: TBrookBrokersFileDescPascalUnit); override;
  public
    constructor Create; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
  end;

  { TBrookHttpAppProjectDescriptor }

  TBrookHttpAppProjectDescriptor = class(TBrookSimpleCGIProjectDescriptor)
  protected
    procedure ConfigureBrokerItem(AItem: TBrookBrokersFileDescPascalUnit); override;
    procedure CreateProjectFile(AProject: TLazProject); override;
  public
    constructor Create; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
  end;

  { TBrookHttpDaemonProjectDescriptor }

  TBrookHttpDaemonProjectDescriptor = class(TBrookHttpAppProjectDescriptor)
  protected
    procedure ConfigureBrokerItem(AItem: TBrookBrokersFileDescPascalUnit); override;
  public
    constructor Create; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
  end;

  { TBrookProjectDescriptor }

  TBrookProjectDescriptor = class(TProjectDescriptor)
  private
    FProjectType: Integer;
  protected
    function DoInitDescriptor: TModalResult; override;
  public
    constructor Create; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    property ProjectType: Integer read FProjectType write FProjectType;
  end;

  { TBrookFileDescPascalUnit }

  TBrookFileDescPascalUnit = class(TFileDescPascalUnit)
  private
    FQuiet: Boolean;
  end;

  { TBrookFileDescPascalUnitWithResource }

  TBrookFileDescPascalUnitWithResource = class(TFileDescPascalUnitWithResource)
  protected
    function GetResourceType: TResourceType; override;
  end;

  { TBrookBrokersFileDescPascalUnit }

  TBrookBrokersFileDescPascalUnit = class(TBrookFileDescPascalUnit)
  private
    FAppType: Integer;
    FAppDefCharset: Integer;
    FFullBrk: Boolean;
  public
    constructor Create; override;
    function Init(var ANewFilename: string; ANewOwner: TObject;
       var ANewSource: string; AQuiet: Boolean): TModalResult; override;
    function CreateSource(const AFileName, ASourceName,
      AResourceName: string): string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
  end;

  { TBrookActionFileDescPascalUnit }

  TBrookActionFileDescPascalUnit = class(TBrookFileDescPascalUnit)
  private
    FActName: string;
    FActPattern: string;
    FActDefault: Boolean;
  public
    constructor Create; override;
    function Init(var ANewFilename: string; ANewOwner: TObject;
       var ANewSource: string; AQuiet: Boolean): TModalResult; override;
    function CreateSource(const AFileName, ASourceName,
      AResourceName: string): string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    property ActName: string read FActName write FActName;
    property ActPattern: string read FActPattern write FActPattern;
    property ActDefault: Boolean read FActDefault write FActDefault;
  end;

  { TBrookDataModuleFileDescPascalUnitWithResource }

  TBrookDataModuleFileDescPascalUnitWithResource = class(TBrookFileDescPascalUnitWithResource)
  public
    constructor Create; override;
    function GetInterfaceUsesSection: string; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
  end;

const
  le = LineEnding;

resourcestring
  SBrookIDEItemCategoryName = 'Brook framework';
  SBrookAppName = 'Full CGI/FastCGI Application';
  SBrookAppDesc = 'Create a full CGI or FastCGI application.';
  SBrookHttpAppName = 'Embedded server';
  SBrookHttpAppDesc = 'Create an embedded HTTP webserver.';
  SBrookHttpDaemonName = 'Embedded daemon server';
  SBrookHttpDaemonDesc = 'Create an embedded daemon HTTP webserver.';
  SBrookSimpleCGIAppName = 'Simple CGI application';
  SBrookSimpleCGIAppDesc = 'Create a simple CGI application.';
  SBrookSimpleFastCGIAppName = 'Simple FastCGI application';
  SBrookSimpleFastCGIAppDesc = 'Create a simple FastCGI application.';
  SBrookBrokersName = 'Brokers unit';
  SBrookBrokersDesc = 'Create a brokers unit.';
  SBrookActionName = 'Action unit';
  SBrookActionDesc = 'Create an action unit.';
  SBrookDataModuleName = 'Data module';
  SBrookDataModuleDesc = 'Create a new unit with a data module.';

procedure Register;
function BrookNewProjectDlg(const AProjectType: Integer): TfrBrookNewProject;
function BrookGetExpertsConfigPath: string;
function BrookGetExpertsConfigFileName: string;

implementation

var
  _NewProjectDlg: TfrBrookNewProject;

const
  PAGE_404_TPL =
    '<html><head><title>Page not found</title><style>body{margin:0;'+
    'padding:30px;font:12px/1.5 Helvetica,Arial,Verdana,sans-serif;}h1{mar'+
    'gin:0;font-size:48px;font-weight:normal;line-height:48px;}strong{disp'+
    'lay:inline-block;width:65px;}</style></head><body><h1>404 - Page not '+
    'found</h1><br />Go to <a href="@path">home page</a> ...'+
    '</body></html>';
  PAGE_500_TPL =
    '<html><head><title>Internal server error</title><style>body{margin:0;'+
    'padding:30px;font:12px/1.5 Helvetica,Arial,Verdana,sans-serif;}h1{mar'+
    'gin:0;font-size:48px;font-weight:normal;line-height:48px;}strong{disp'+
    'lay:inline-block;width:65px;}</style></head><body><h1>500 - Internal '+
    'server error</h1><br />@error'+
    '</body></html>';

procedure Register;
begin
  RegisterNewItemCategory(TNewIDEItemCategory.Create(SBrookIDEItemCategoryName));
  RegisterProjectDescriptor(TBrookSimpleCGIProjectDescriptor.Create,
    SBrookIDEItemCategoryName);
  RegisterProjectDescriptor(TBrookSimpleFastCGIProjectDescriptor.Create,
    SBrookIDEItemCategoryName);
  RegisterProjectDescriptor(TBrookHttpAppProjectDescriptor.Create,
    SBrookIDEItemCategoryName);
  RegisterProjectDescriptor(TBrookHttpDaemonProjectDescriptor.Create,
    SBrookIDEItemCategoryName);
  RegisterProjectDescriptor(TBrookProjectDescriptor.Create,
    SBrookIDEItemCategoryName);
  RegisterProjectFileDescriptor(TBrookDataModuleFileDescPascalUnitWithResource.Create,
    SBrookIDEItemCategoryName);
  RegisterProjectFileDescriptor(TBrookActionFileDescPascalUnit.Create,
    SBrookIDEItemCategoryName);
  RegisterProjectFileDescriptor(TBrookBrokersFileDescPascalUnit.Create,
    SBrookIDEItemCategoryName);
  FormEditingHook.RegisterDesignerBaseClass(TBrookDataModule);
end;

function BrookNewProjectDlg(const AProjectType: Integer): TfrBrookNewProject;
begin
  if not Assigned(_NewProjectDlg) then
    _NewProjectDlg := TfrBrookNewProject.Create(Application, AProjectType);
  Result := _NewProjectDlg;
end;

procedure BrookFreeNewProjectDlg;
begin
  FreeAndNil(_NewProjectDlg);
end;

function BrookGetExpertsConfigPath: string;
begin
  if Assigned(LazarusIDE) then
    Result := IncludeTrailingPathDelimiter(
{$IFDEF MSWINDOWS}Utf8ToAnsi({$ENDIF}LazarusIDE.GetPrimaryConfigPath
{$IFDEF MSWINDOWS}){$ENDIF})
  else
    Result := '';
end;

function BrookGetExpertsConfigFileName: string;
begin
  Result := BrookGetExpertsConfigPath + 'brook.xml';
end;

{ TBrookCustomSimpleCGIProjectDescriptor }

constructor TBrookCustomSimpleCGIProjectDescriptor.Create;
begin
  inherited Create;
  Name := '';
end;

{$PUSH}{$WARN 5024 OFF}

function TBrookCustomSimpleCGIProjectDescriptor.CreateStartFiles(
  AProject: TLazProject): TModalResult;
var
  VActItem: TBrookActionFileDescPascalUnit;
begin
  case FProjectType of
    0:
      begin
        VActItem := ProjectFileDescriptors.FindByName(
          SBrookActionName) as TBrookActionFileDescPascalUnit;
        VActItem.FQuiet := True;
        VActItem.ActName := 'MyAction';
        VActItem.ActPattern := '*';
        VActItem.ActDefault := False;
        LazarusIDE.DoNewEditorFile(VActItem, '', '',
          [nfIsPartOfProject, nfOpenInEditor, nfCreateDefaultSrc]);
      end;
    1:
      LazarusIDE.DoNewEditorFile(ProjectFileDescriptors.FindByName(
        SBrookDataModuleName), '', '', [nfIsPartOfProject, nfOpenInEditor,
        nfCreateDefaultSrc]);
  end;
  Result := mrOK;
end;

{$POP}

function TBrookCustomSimpleCGIProjectDescriptor.DoInitDescriptor: TModalResult;
begin
  FProjectType := TfrBrookChooseProjectType.Execute;
  if FProjectType > -1 then
    Result := mrOK
  else
    Result := mrCancel;
end;

function TBrookCustomSimpleCGIProjectDescriptor.InitProject(
  AProject: TLazProject): TModalResult;
begin
  AProject.AddPackageDependency('BrookRT');
  AProject.Flags := AProject.Flags - [pfRunnable];
  if FProjectType = 0 then
    AProject.Flags := AProject.Flags - [pfMainUnitHasCreateFormStatements];
  AProject.LazCompilerOptions.Win32GraphicApp := False;
  AProject.LazCompilerOptions.TargetFilenameApplyConventions := False;
  AProject.SessionStorage := pssInProjectInfo;
  AProject.MainFileID := 0;
  AProject.Title := '';
  Result := mrOK;
end;

function TBrookCustomSimpleCGIProjectDescriptor.GetLocalizedName: string;
begin
  Result := '';
end;

function TBrookCustomSimpleCGIProjectDescriptor.GetLocalizedDescription: string;
begin
  Result := '';
end;

{ TBrookSimpleCGIProjectDescriptor }

constructor TBrookSimpleCGIProjectDescriptor.Create;
begin
  inherited Create;
  Name := SBrookSimpleCGIAppName;
end;

function TBrookSimpleCGIProjectDescriptor.InitProject(
  AProject: TLazProject): TModalResult;
var
  VApp: string;
begin
  CreateProjectFile(AProject);
  Result := inherited InitProject(AProject);
  case FProjectType of
    0: VApp := 'BrookApp.Run';
    1: VApp := 'Application.Run';
  end;
  AProject.MainFile.SetSourceText(
    'program cgi1;'+le+
    le+
    '{$mode objfpc}{$H+}'+le+
    le+
    'uses'+le+
    '{$IFDEF UNIX}{$IFDEF UseCThreads}'+le+
    '  cthreads,'+le+
    '{$ENDIF}{$ENDIF}'+le+
    '  BrookApplication, Brokers;'+le+
    le+
    'begin'+le+
    '  '+VApp+';'+le+
    'end.');
  AProject.LazCompilerOptions.TargetFileName := 'cgi1.bf';
end;

function TBrookSimpleCGIProjectDescriptor.CreateStartFiles(
  AProject: TLazProject): TModalResult;
var
  VBrkItem: TBrookBrokersFileDescPascalUnit;
begin
  Result := inherited CreateStartFiles(AProject);
  VBrkItem := ProjectFileDescriptors.FindByName(
    SBrookBrokersName) as TBrookBrokersFileDescPascalUnit;
  ConfigureBrokerItem(VBrkItem);
  LazarusIDE.DoNewEditorFile(VBrkItem, '', '',
    [nfIsPartOfProject, nfOpenInEditor, nfCreateDefaultSrc]);
end;

procedure TBrookSimpleCGIProjectDescriptor.ConfigureBrokerItem(
  AItem: TBrookBrokersFileDescPascalUnit);
begin
  AItem.FQuiet := True;
  AItem.FFullBrk := False;
  AItem.FAppType := 0;
  AItem.FAppDefCharset := 0;
end;

procedure TBrookSimpleCGIProjectDescriptor.CreateProjectFile(
  AProject: TLazProject);
var
  VProject: TLazProjectFile;
begin
  VProject := AProject.CreateProjectFile('cgi1.lpr');
  VProject.IsPartOfProject := True;
  AProject.AddFile(VProject, False);
end;

function TBrookSimpleCGIProjectDescriptor.GetLocalizedName: string;
begin
  Result := SBrookSimpleCGIAppName;
end;

function TBrookSimpleCGIProjectDescriptor.GetLocalizedDescription: string;
begin
  Result := SBrookSimpleCGIAppDesc;
end;

{ TBrookSimpleFastCGIProjectDescriptor }

constructor TBrookSimpleFastCGIProjectDescriptor.Create;
begin
  inherited Create;
  Name := SBrookSimpleFastCGIAppName;
end;

function TBrookSimpleFastCGIProjectDescriptor.InitProject(
  AProject: TLazProject): TModalResult;
begin
  Result := inherited InitProject(AProject);
  AProject.Flags := AProject.Flags + [pfRunnable];
  AProject.LazCompilerOptions.TargetFileName := 'cgi1.fbf';
end;

procedure TBrookSimpleFastCGIProjectDescriptor.ConfigureBrokerItem(
  AItem: TBrookBrokersFileDescPascalUnit);
begin
  inherited;
  AItem.FAppType := 1;
end;

function TBrookSimpleFastCGIProjectDescriptor.GetLocalizedName: string;
begin
  Result := SBrookSimpleFastCGIAppName;
end;

function TBrookSimpleFastCGIProjectDescriptor.GetLocalizedDescription: string;
begin
  Result := SBrookSimpleFastCGIAppDesc;
end;

{ TBrookHttpAppProjectDescriptor }

constructor TBrookHttpAppProjectDescriptor.Create;
begin
  inherited Create;
  Name := SBrookHttpAppName;
end;

function TBrookHttpAppProjectDescriptor.InitProject(
  AProject: TLazProject): TModalResult;
var
  VApp: string;
begin
  Result := inherited InitProject(AProject);
  AProject.Flags := AProject.Flags + [pfRunnable];
  AProject.LazCompilerOptions.TargetFilenameApplyConventions := True;
  case FProjectType of
    0: VApp := 'BrookApp.Run';
    1: VApp := 'Application.Run';
  end;
  AProject.MainFile.SetSourceText(
    'program project1;'+le+
    le+
    '{$mode objfpc}{$H+}'+le+
    le+
    'uses'+le+
    '{$IFDEF UNIX}{$IFDEF UseCThreads}'+le+
    '  cthreads,'+le+
    '{$ENDIF}{$ENDIF}'+le+
    '  BrookApplication, Brokers;'+le+
    le+
    'begin'+le+
    '  '+VApp+';'+le+
    'end.');
  AProject.LazCompilerOptions.TargetFileName := 'project1';
end;

procedure TBrookHttpAppProjectDescriptor.ConfigureBrokerItem(
  AItem: TBrookBrokersFileDescPascalUnit);
begin
  inherited;
  AItem.FAppType := 2;
end;

procedure TBrookHttpAppProjectDescriptor.CreateProjectFile(
  AProject: TLazProject);
var
  VProject: TLazProjectFile;
begin
  VProject := AProject.CreateProjectFile('project1.lpr');
  VProject.IsPartOfProject := True;
  AProject.AddFile(VProject, False);
end;

function TBrookHttpAppProjectDescriptor.GetLocalizedName: string;
begin
  Result := SBrookHttpAppName;
end;

function TBrookHttpAppProjectDescriptor.GetLocalizedDescription: string;
begin
  Result := SBrookHttpAppDesc;
end;

{ TBrookHttpDaemonProjectDescriptor }

constructor TBrookHttpDaemonProjectDescriptor.Create;
begin
  inherited Create;
  Name := SBrookHttpDaemonName;
end;

function TBrookHttpDaemonProjectDescriptor.InitProject(
  AProject: TLazProject): TModalResult;
begin
  Result := inherited InitProject(AProject);
  AProject.LazCompilerOptions.Win32GraphicApp := True;
end;

procedure TBrookHttpDaemonProjectDescriptor.ConfigureBrokerItem(
  AItem: TBrookBrokersFileDescPascalUnit);
begin
  inherited;
  AItem.FAppType := 3;
end;

function TBrookHttpDaemonProjectDescriptor.GetLocalizedName: string;
begin
  Result := SBrookHttpDaemonName;
end;

function TBrookHttpDaemonProjectDescriptor.GetLocalizedDescription: string;
begin
  Result := SBrookHttpDaemonDesc;
end;

{ TBrookProjectDescriptor }

constructor TBrookProjectDescriptor.Create;
begin
  inherited Create;
  Name := SBrookAppName;
end;

function TBrookProjectDescriptor.CreateStartFiles(
  AProject: TLazProject): TModalResult;

  procedure CreateHTMLFile(const F, S: string);
  begin
    if FileExists(F) and (MessageDlg('Confirmation', Format('Replace file "%s"?',
      [F]), mtConfirmation, mbYesNo, 0) <> mrYes) then
      Exit;
    with TFileStream.Create(F, fmCreate) do
      try
        Write(Pointer(S)^, Length(S));
      finally
        Free;
      end;
  end;

var
  I: Integer;
  VItem: TListItem;
  VHTMLsDir: string;
  VDlg: TfrBrookNewProject;
  VPage404, VPage500: TFileName;
  VActItem: TBrookActionFileDescPascalUnit;
  VBrkItem: TBrookBrokersFileDescPascalUnit;
begin
  VDlg := BrookNewProjectDlg(FProjectType);
  VActItem := ProjectFileDescriptors.FindByName(SBrookActionName) as
    TBrookActionFileDescPascalUnit;
  for I := 0 to Pred(VDlg.lvActions.Items.Count) do
  begin
    VActItem.FQuiet := True;
    VItem := VDlg.lvActions.Items[I];
    VActItem.ActName := VItem.Caption;
    VActItem.ActPattern := VItem.SubItems[0];
    VActItem.ActDefault := StrToBool(VItem.SubItems[1]);
    LazarusIDE.DoNewEditorFile(VActItem, '', '',
      [nfIsPartOfProject, nfOpenInEditor, nfCreateDefaultSrc]);
  end;
  if FProjectType = 1 then
    LazarusIDE.DoNewEditorFile(ProjectFileDescriptors.FindByName(
      SBrookDataModuleName), '', '', [nfIsPartOfProject, nfOpenInEditor,
      nfCreateDefaultSrc]);
  VBrkItem := ProjectFileDescriptors.FindByName(
    SBrookBrokersName) as TBrookBrokersFileDescPascalUnit;
  VBrkItem.FQuiet := True;
  VBrkItem.FFullBrk := True;
  VBrkItem.FAppType := VDlg.rgAppType.ItemIndex;
  VBrkItem.FAppDefCharset := VDlg.rgCharset.ItemIndex;
  LazarusIDE.DoNewEditorFile(VBrkItem, '', '',
    [nfIsPartOfProject, nfOpenInEditor, nfCreateDefaultSrc]);
  if VDlg.edPubHTMLDir.Text <> '' then
  begin
    VHTMLsDir := IncludeTrailingPathDelimiter(VDlg.edPubHTMLDir.Text);
    VPage404 := VHTMLsDir + '404.html';
    VPage500 := VHTMLsDir + '500.html';
    CreateHTMLFile(VPage404, PAGE_404_TPL);
    CreateHTMLFile(VPage500, PAGE_500_TPL);
    LazarusIDE.DoOpenEditorFile(VPage404, -1, -1,
      [ofProjectLoading, ofRegularFile, ofAddToProject]);
    LazarusIDE.DoOpenEditorFile(VPage500, -1, -1,
      [ofProjectLoading, ofRegularFile, ofAddToProject]);
  end;
  Result := LazarusIDE.DoOpenEditorFile(AProject.MainFile.FileName, -1, -1,
    [ofProjectLoading, ofRegularFile]);
  BrookFreeNewProjectDlg;
end;

function TBrookProjectDescriptor.DoInitDescriptor: TModalResult;
begin
  FProjectType := TfrBrookChooseProjectType.Execute;
  if FProjectType = -1 then
    Exit(mrCancel);
  Result := BrookNewProjectDlg(FProjectType).ShowModal;
  if Result <> mrOK then
    BrookFreeNewProjectDlg;
end;

function TBrookProjectDescriptor.InitProject(
  AProject: TLazProject): TModalResult;
var
  S, VApp: string;
  VDlg: TfrBrookNewProject;
  VProject: TLazProjectFile;
begin
  VDlg := BrookNewProjectDlg(FProjectType);
  VProject := AProject.CreateProjectFile(VDlg.edAppName.Text + '.lpr');
  VProject.IsPartOfProject := True;
  AProject.AddFile(VProject, False);
  AProject.AddPackageDependency('BrookRT');
  case FProjectType of
    0:
      begin
        AProject.Flags := AProject.Flags - [pfMainUnitHasCreateFormStatements];
        VApp := 'BrookApp.Run';
      end;
    1: VApp := 'Application.Run';
  end;
  AProject.LazCompilerOptions.TargetFileName := VDlg.edAppName.Text;
  AProject.LazCompilerOptions.TargetFilenameApplyConventions := False;
  AProject.LazCompilerOptions.Win32GraphicApp := False;
  case VDlg.rgAppType.ItemIndex of
    0:
      begin
        AProject.Flags := AProject.Flags - [pfRunnable];
        AProject.LazCompilerOptions.TargetFileName := VDlg.edAppName.Text + '.bf';
      end;
    1: AProject.LazCompilerOptions.TargetFileName := VDlg.edAppName.Text + '.fbf';
    2: AProject.LazCompilerOptions.TargetFilenameApplyConventions := True;
    3:
      begin
        AProject.LazCompilerOptions.TargetFilenameApplyConventions := True;
        AProject.LazCompilerOptions.Win32GraphicApp := True;
      end;
  end;
  AProject.SessionStorage := pssInProjectInfo;
  AProject.MainFileID := 0;
  S :=
    'program '+VDlg.edAppName.Text+';'+le+
    le+
    '{$mode objfpc}{$H+}'+le+
    le+
    'uses'+le+
    '{$IFDEF UNIX}{$IFDEF UseCThreads}'+le+
    '  cthreads,'+le+
    '{$ENDIF}{$ENDIF}'+le+
    '  BrookApplication, Brokers;'+le+
    le+
    'begin'+le+
    '  '+VApp+';'+le+
    'end.';
  AProject.MainFile.SetSourceText(S);
  Result := mrOK;
end;

function TBrookProjectDescriptor.GetLocalizedName: string;
begin
  Result := SBrookAppName;
end;

function TBrookProjectDescriptor.GetLocalizedDescription: string;
begin
  Result := SBrookAppDesc;
end;

{ TBrookFileDescPascalUnitWithResource }

function TBrookFileDescPascalUnitWithResource.GetResourceType: TResourceType;
begin
  if LazarusIDE.ActiveProject.Resources is TAbstractProjectResources then
    Result := TAbstractProjectResources(
      LazarusIDE.ActiveProject.Resources).ResourceType
  else
    Result := inherited GetResourceType;
end;

{ TBrookBrokersFileDescPascalUnit }

constructor TBrookBrokersFileDescPascalUnit.Create;
begin
  inherited Create;
  Name := SBrookBrokersName;
  DefaultFileName := 'brokers.pas';
  DefaultSourceName := 'Brokers';
  FQuiet := False;
end;

function TBrookBrokersFileDescPascalUnit.Init(var ANewFilename: string;
  ANewOwner: TObject; var ANewSource: string; AQuiet: Boolean): TModalResult;
begin
  Result := inherited Init(ANewFilename, ANewOwner, ANewSource, AQuiet);
  if AQuiet or FQuiet then
    Exit;
  FAppType := TfrBrookNewBroker.Execute;
  if FAppType = -1 then
    Result := mrCancel;
end;

{$PUSH}{$WARN 5024 OFF}

function TBrookBrokersFileDescPascalUnit.CreateSource(const AFileName,
  ASourceName, AResourceName: string): string;
var
  VDlg: TfrBrookNewProject;
  VCharset, VBroker, VInitPort: string;
begin
  if FFullBrk then
  begin
    case FAppType of
      0:
        begin
          VBroker := 'BrookFCLCGIBroker';
          VInitPort := '';
        end;
      1:
        begin
          VBroker := 'BrookFCLFCGIBroker';
          VInitPort := '';
        end;
      2:
        begin
          VBroker := 'BrookFCLHttpAppBroker';
          VInitPort := '  BrookSettings.Port := 8080;'+le;
        end;
      3:
        begin
          VBroker := 'BrookFCLHttpDaemonBroker';
          VInitPort := '  BrookSettings.Port := 8080;'+le;
        end;
    end;
    case FAppDefCharset of
      0: VCharset := 'BROOK_HTTP_CHARSET_UTF_8';
      1: VCharset := 'BROOK_HTTP_CHARSET_ISO_8859_1';
    end;
    VDlg := BrookNewProjectDlg(0);
    Result :=
    'unit '+ASourceName+';'+le+
    le+
    '{$mode objfpc}{$H+}'+le+
    le+
    'interface'+le+
    le+
    'uses'+le+
    '  '+VBroker+', BrookUtils, BrookHttpConsts, Classes, SysUtils;'+le+
    le+
    'const'+le+
    '  PUBLIC_HTML = '+QuotedStr(IncludeTrailingPathDelimiter(VDlg.edPubHTMLDir.Text))+';'+le+
    le+
    'implementation'+le+
    le+
    'initialization'+le+
       VInitPort+
    '  BrookSettings.Charset := ' + VCharset + ';'+le+
    '  BrookSettings.Page404File := PUBLIC_HTML + ''404.html'';'+le+
    '  BrookSettings.Page500File := PUBLIC_HTML + ''500.html'';'+le+
    le+
    'end.';
  end
  else
  begin
    case FAppType of
      0:
        begin
          VBroker := 'BrookFCLCGIBroker';
          VInitPort := '';
        end;
      1:
        begin
          VBroker := 'BrookFCLFCGIBroker';
          VInitPort := '';
        end;
      2:
        begin
          VBroker := 'BrookFCLHttpAppBroker, BrookUtils';
          VInitPort :=
            'initialization'+le+
            '  BrookSettings.Port := 8080;'+le+
            le;
        end;
      3:
        begin
          VBroker := 'BrookFCLHttpDaemonBroker, BrookUtils';
          VInitPort :=
            'initialization'+le+
            '  BrookSettings.Port := 8080;'+le+
            le;
        end;
    end;
    Result :=
    'unit '+ASourceName+';'+le+
    le+
    '{$mode objfpc}{$H+}'+le+
    le+
    'interface'+le+
    le+
    'uses'+le+
    '  '+VBroker+';'+le+
    le+
    'implementation'+le+
    le+
      VInitPort+
    'end.';
  end;
  FAppType := 0;
  FAppDefCharset := 0;
  FFullBrk := False;
  FQuiet := False;
end;

{$POP}

function TBrookBrokersFileDescPascalUnit.GetLocalizedName: string;
begin
  Result := SBrookBrokersName;
end;

function TBrookBrokersFileDescPascalUnit.GetLocalizedDescription: string;
begin
  Result := SBrookBrokersDesc;
end;

{ TBrookActionFileDescPascalUnit }

constructor TBrookActionFileDescPascalUnit.Create;
begin
  inherited Create;
  Name := SBrookActionName;
end;

function TBrookActionFileDescPascalUnit.Init(var ANewFilename: string;
  ANewOwner: TObject; var ANewSource: string; AQuiet: Boolean): TModalResult;
begin
  Result := inherited Init(ANewFilename, ANewOwner, ANewSource, AQuiet);
  if AQuiet or FQuiet then
    Exit;
  if not TfrBrookActEdit.Execute('Add', FActName, FActPattern,
    FActDefault, True) then
    Result := mrCancel;
end;

{$PUSH}{$WARN 5024 OFF}

function TBrookActionFileDescPascalUnit.CreateSource(const AFileName,
  ASourceName, AResourceName: string): string;
var
  VClassName: ShortString = '';
  VActDefault: ShortString = '';
begin
  if FActName = '' then
    FActName := ASourceName;
  FActName := UpperCase(Copy(FActName, 1, 1)) + Copy(FActName, 2, MaxInt);
  if FActDefault then
    VActDefault := ', True';
  VClassName := 'T'+FActName;
  Result :=
    'unit '+ASourceName+';'+le+
    le+
    '{$mode objfpc}{$H+}'+le+
    le+
    'interface'+le+
    le+
    'uses'+le+
    '  BrookAction;'+le+
    le+
    'type'+le+
    le+
    '  { '+VClassName+' }'+le+
    le+
    '  '+VClassName+' = class(TBrookAction)'+le+
    '  public'+le+
    '    procedure Get; override;'+le+
    '  end;'+le+
    le+
    'implementation'+le+
    le+
    '{ '+VClassName+' }'+le+
    le+
    'procedure T'+FActName+'.Get;'+le+
    'begin'+le+
    '  Write(''Your content here ...'');'+le+
    'end;'+le+
    le+
    'initialization'+le+
    '  T'+FActName+'.Register('+QuotedStr(FActPattern)+VActDefault+');'+le+
    le+
    'end.';
  FActName := '';
  FActPattern := '';
  FActDefault := False;
  FQuiet := False;
end;

{$POP}

function TBrookActionFileDescPascalUnit.GetLocalizedName: string;
begin
  Result := SBrookActionName;
end;

function TBrookActionFileDescPascalUnit.GetLocalizedDescription: string;
begin
  Result := SBrookActionDesc;
end;

{ TBrookDataModuleFileDescPascalUnitWithResource }

constructor TBrookDataModuleFileDescPascalUnitWithResource.Create;
begin
  inherited Create;
  Name := SBrookDataModuleName;
  RequiredPackages := 'BrookRT';
  ResourceClass := TBrookDataModule;
  UseCreateFormStatements := True;
end;

function TBrookDataModuleFileDescPascalUnitWithResource.GetInterfaceUsesSection: string;
begin
  Result := 'BrookClasses';
  if GetResourceType = rtLRS then
    Result := Result + ', LResources';
  Result += ', Classes, SysUtils';
end;

function TBrookDataModuleFileDescPascalUnitWithResource.GetLocalizedName: string;
begin
  Result := SBrookDataModuleName;
end;

function TBrookDataModuleFileDescPascalUnitWithResource.GetLocalizedDescription: string;
begin
  Result := SBrookDataModuleDesc;
end;

finalization
  BrookFreeNewProjectDlg;

end.
