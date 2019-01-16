(*
  Brook framework, Configurator Handler Class

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookConfiguratorHandler;

{$i brook.inc}

interface

uses
  BrookConfigurator, Classes;

type

  { Handles exceptions for @link(TBrookConfiguratorHandler). }
  EBrookConfiguratorHandler = class(EBrookConfigurator);

  { Is a metaclass for @link(TBrookConfiguratorHandler) class. }
  TBrookConfiguratorHandlerClass = class of TBrookConfiguratorHandler;

  { Handles the configurator features. }
  TBrookConfiguratorHandler = class(TBrookConfigurator)
  private
    FAutoConfig: Boolean;
    function GetTargetComp: TComponent;
    procedure SetTargetComp(AValue: TComponent);
  protected
    procedure Loaded; override;
    procedure Notification(AComponent: TComponent;
      AOperation: TOperation); override;
  published
    { Defines if the configuration is done automatically. }
    property AutoConfig: Boolean read FAutoConfig write FAutoConfig;
    property IgnoredParams;
    property Params;
    property Target: TComponent read GetTargetComp write SetTargetComp;
    property AfterConfigure;
    property BeforeConfgure;
  end;

implementation

{ TBrookConfiguratorHandler }

procedure TBrookConfiguratorHandler.Loaded;
begin
  inherited Loaded;
  if FAutoConfig then
    Configure;
end;

procedure TBrookConfiguratorHandler.Notification(AComponent: TComponent;
  AOperation: TOperation);
begin
  inherited Notification(AComponent, AOperation);
  if (AOperation = opRemove) and (AComponent = Target) then
    Target := nil;
end;

function TBrookConfiguratorHandler.GetTargetComp: TComponent;
begin
  Result := TComponent(inherited GetTarget);
end;

procedure TBrookConfiguratorHandler.SetTargetComp(AValue: TComponent);
begin
  inherited SetTarget(AValue);
end;

end.

