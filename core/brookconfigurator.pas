(*
  Brook framework, Configurator Class

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookConfigurator;

{$i brook.inc}

interface

uses
  BrookClasses, BrookUtils, BrookException, BrookMessages, BrookConsts, Classes,
  SysUtils;

type
  { Handles exceptions for @link(TBrookConfigurator). }
  EBrookConfigurator = class(EBrook);

  { Is a metaclass for @link(TBrookConfigurator) class. }
  TBrookConfiguratorClass = class of TBrookConfigurator;

  { Is a type to configure event. }
  TBrookConfigureEvent = procedure(ASender: TObject;
    var AHandled: Boolean) of object;
  { Defines a pointer to the configure event.}
  PBrookConfigureEvent = ^TBrookConfigureEvent;

  { Configures objects by means of string or file. }
  TBrookConfigurator = class(TBrookComponent)
  private
    FAfterConfigure: TBrookConfigureEvent;
    FBeforeConfgure: TBrookConfigureEvent;
    FIgnoredParams: TStrings;
    FParams: TStrings;
    FTarget: TObject;
    function GetProp(const AName: string): string;
    function GetParam(const AName: string): string;
    procedure SetIgnoredParams(AValue: TStrings);
    procedure SetProp(const AName: string; const AValue: string);
    procedure SetParam(const AName: string; const AValue: string);
    procedure SetParams(AValue: TStrings);
  protected
    function GetTarget: TObject; virtual;
    procedure SetTarget(AValue: TObject); virtual;
  public
    { Creates an instance of a @link(TBrookConfigurator) class. }
    constructor Create(AOwner: TComponent); override;
    { Frees an instance of @link(TBrookConfigurator) class. }
    destructor Destroy; override;
    { Configures the target property. }
    procedure Configure;
    { Defines the object to be configured. }
    property Target: TObject read GetTarget write SetTarget;
    { Handles the target properties. }
    property Prop[const AName: string]: string read GetProp write SetProp;
    { Handles a string list of params of a configuration.  }
    property Param[const AName: string]: string read GetParam
      write SetParam; default;
    { Ignored params in the configuration. }
    property IgnoredParams: TStrings read FIgnoredParams write SetIgnoredParams;
    { Params of the configuration. }
    property Params: TStrings read FParams write SetParams;
    { Is triggered after configure. }
    property AfterConfigure: TBrookConfigureEvent read FAfterConfigure
      write FAfterConfigure;
    { Is triggered before configure. }
    property BeforeConfgure: TBrookConfigureEvent read FBeforeConfgure
      write FBeforeConfgure;
  end;

implementation

constructor TBrookConfigurator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FParams := TStringList.Create;
  FIgnoredParams := TStringList.Create;
end;

destructor TBrookConfigurator.Destroy;
begin
  FTarget := nil;
  FIgnoredParams.Free;
  FParams.Free;
  inherited Destroy;
end;

function TBrookConfigurator.GetParam(const AName: string): string;
begin
  Result := FParams.Values[AName];
end;

procedure TBrookConfigurator.SetIgnoredParams(AValue: TStrings);
begin
  if Assigned(AValue) then
    FIgnoredParams.Assign(AValue);
end;

function TBrookConfigurator.GetProp(const AName: string): string;
begin
  if Assigned(FTarget) then
    BrookObjectToString(FTarget, AName, Result)
  else
    Result := ES;
end;

procedure TBrookConfigurator.SetProp(const AName: string;
  const AValue: string);
begin
  if Assigned(FTarget) then
    BrookStringToObject(FTarget, AName, AValue);
end;

function TBrookConfigurator.GetTarget: TObject;
begin
  Result := FTarget;
end;

procedure TBrookConfigurator.SetParam(const AName: string; const AValue: string);
begin
  FParams.Values[AName] := AValue;
end;

procedure TBrookConfigurator.SetParams(AValue: TStrings);
begin
  if Assigned(AValue) then
    FParams.Assign(AValue);
end;

procedure TBrookConfigurator.SetTarget(AValue: TObject);
begin
  if AValue = Self then
    FTarget := nil
  else
    FTarget := AValue;
end;

procedure TBrookConfigurator.Configure;
var
  VOldDelim: Char;
  VOldStrictDelim: Boolean;
  VHandled: Boolean = False;
begin
  if (csDesigning in ComponentState) then
    Exit;
  try
    if Assigned(FBeforeConfgure) then
      FBeforeConfgure(Self, VHandled);
    if (not Assigned(FTarget)) or VHandled then
      Exit;
    if (FParams.Count = 0) and (BrookSettings.Configuration <> ES) then
    begin
      VOldStrictDelim := FParams.StrictDelimiter;
      VOldDelim := FParams.Delimiter;
      try
        FParams.StrictDelimiter := True;
        FParams.Delimiter := SC;
        if (Pos(SC, BrookSettings.Configuration) <> 0) or
          (Pos(EQ, BrookSettings.Configuration) <> 0) then
          FParams.DelimitedText := BrookSettings.Configuration
        else
        begin
          if not FileExists(BrookSettings.Configuration) then
            raise EBrookConfigurator.CreateFmt(Self,
              SBrookCfgFileNotFoundError, [BrookSettings.Configuration]);
          FParams.LoadFromFile(BrookSettings.Configuration);
        end;
      finally
        FParams.StrictDelimiter := VOldStrictDelim;
        FParams.Delimiter := VOldDelim;
      end;
    end;
    BrookStringsToObject(FTarget, FParams, FIgnoredParams);
  finally
    if Assigned(FAfterConfigure) then
      FAfterConfigure(Self, VHandled);
  end;
end;

end.

