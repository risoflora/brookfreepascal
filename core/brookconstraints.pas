(*
  Brook framework, Constraints Unit

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookConstraints;

{$i brook.inc}

interface

uses
  BrookClasses, BrookAction, BrookRouter, BrookException, BrookMessages,
  Classes, SysUtils;

type
  TBrookConstraint = class;

  { Handles exceptions for @link(TBrookConstraint). }
  EBrookConstraint = class(EBrook)
  private
    FConstraint: TBrookConstraint;
  public
    { Creates an instance of a @link(EBrookConstraint) class. }
    constructor Create(AConstraint: TBrookConstraint;
      const AMsg: string); overload;
    { Creates an instance of @code(EBrookConstraint) with a formated message. }
    constructor CreateFmt(AConstraint: TBrookConstraint; const AMsg: string;
      const AArgs: array of const); overload;
    { Frees an instance of @link(EBrookConstraint) class. }
    destructor Destroy; override;
    { Offers an instance of the current constraint. }
    property Constraint: TBrookConstraint read FConstraint;
  end;

  { Is a metaclass for @link(TBrookCustomConstraint) class. }
  TBrookCustomConstraintClass = class of TBrookCustomConstraint;

  { Is a metaclass for @link(TBrookConstraint) class. }
  TBrookConstraintClass = class of TBrookConstraint;

  { Is a metaclass for @link(TBrookCustomConstraints) class. }
  TBrookCustomConstraintsClass = class of TBrookCustomConstraints;

  { Is a metaclass for @link(TBrookConstraints) class. }
  TBrookConstraintsClass = class of TBrookConstraints;

  { Offers general features for constraint handling. }
  TBrookCustomConstraint = class(TBrookObject)
  public
    { Raises a message for constraint exceptions. }
    procedure Error(const AMsg: string); overload;
    { Raises a formated message for constraint exceptions. }
    procedure Error(const AMsg: string; const AArgs: array of const); overload;
    { Stops the code execution showing an exception message. }
    procedure Stop(const AMsg: string); overload;
    { Stops the code execution showing a formatted exception message. }
    procedure Stop(const AMsg: string; const AArgs: array of const); overload;
    { Offers a abstract method for the user validations. }
    procedure Execute; virtual; abstract;
  end;

  { Offers features for constraint handling. }
  TBrookConstraint = class(TBrookCustomConstraint)
  private
    FAction: TBrookAction;
    FRoute: TBrookRoute;
  public
    { Creates an instance of a @link(TBrookConstraint) class. }
    constructor Create(AAction: TBrookAction; ARoute: TBrookRoute); virtual;
    { Register the constraint class. }
    class procedure Register(AActionClass: TBrookActionClass);
    { Offers an instance of the current action. }
    property Action: TBrookAction read FAction;
    { Offers an instance of the current route. }
    property Route: TBrookRoute read FRoute;
  end;

  { Defines a constraint item. }
  TBrookConstraintItem = record
    ActionClass: TBrookActionClass;
    ConstraintClass: TBrookConstraintClass;
  end;
  PBrookConstraintItem = ^TBrookConstraintItem;

  { Registers constraint classes. }
  TBrookCustomConstraints = class(TBrookObject)
  private
    FList: TFPList;
  protected
    procedure CheckAdd(AActionClass: TBrookActionClass;
      AConstraintClass: TBrookCustomConstraintClass);
    property List: TFPList read FList;
  public
    { Creates an instance of a @link(TBrookConstraints) class. }
    constructor Create; virtual;
    { Frees an instance of @link(TBrookConstraints) class. }
    destructor Destroy; override;
  end;

  { Registers and executes constraint classes. }
  TBrookConstraints = class(TBrookCustomConstraints)
  public
    { Registers the service provided by this class. }
    class procedure RegisterService;
    { Unregisters the service  provided by this class. }
    class procedure UnregisterService;
    { Return an instance of this class. }
    class function Service: TBrookConstraints;
    { Adds a constraint item. }
    procedure Add(AActionClass: TBrookActionClass;
      AConstraintClass: TBrookConstraintClass);
    { Triggers the user validations implemented in the constraint. }
    procedure Execute(AAction: TBrookAction; ARoute: TBrookRoute); virtual;
  end;

implementation

var
  _BrookConstraintsService: TBrookConstraints = nil;
  _BrookConstraintsServiceClass: TBrookConstraintsClass = nil;

{ EBrookConstraint }

constructor EBrookConstraint.Create(AConstraint: TBrookConstraint;
  const AMsg: string);
begin
  inherited Create(AMsg);
  FConstraint := AConstraint;
end;

constructor EBrookConstraint.CreateFmt(AConstraint: TBrookConstraint;
  const AMsg: string; const AArgs: array of const);
begin
  inherited CreateFmt(AMsg, AArgs);
  FConstraint := AConstraint;
end;

destructor EBrookConstraint.Destroy;
begin
  FreeAndNil(FConstraint);
  inherited Destroy;
end;

{ TBrookCustomConstraint }

procedure TBrookCustomConstraint.Error(const AMsg: string);
begin
  raise EBrookConstraint.Create(Self, AMsg);
end;

procedure TBrookCustomConstraint.Error(const AMsg: string;
  const AArgs: array of const);
begin
  raise EBrookConstraint.CreateFmt(Self, AMsg, AArgs);
end;

procedure TBrookCustomConstraint.Stop(const AMsg: string);
begin
  raise EBrookAction.Create(AMsg);
end;

procedure TBrookCustomConstraint.Stop(const AMsg: string;
  const AArgs: array of const);
begin
  raise EBrookAction.CreateFmt(AMsg, AArgs);
end;

{ TBrookConstraint }

constructor TBrookConstraint.Create(AAction: TBrookAction; ARoute: TBrookRoute);
begin
  inherited Create;
  FAction := AAction;
  FRoute := ARoute;
end;

class procedure TBrookConstraint.Register(AActionClass: TBrookActionClass);
begin
  TBrookConstraints.Service.Add(AActionClass, Self);
end;

{ TBrookCustomConstraints }

constructor TBrookCustomConstraints.Create;
begin
  inherited Create;
  FList := TFPList.Create;
end;

destructor TBrookCustomConstraints.Destroy;
var
  PItem: PBrookConstraintItem;
begin
  for PItem in FList do
    Dispose(PItem);
  FList.Free;
  inherited Destroy;
end;

procedure TBrookCustomConstraints.CheckAdd(AActionClass: TBrookActionClass;
  AConstraintClass: TBrookCustomConstraintClass);
var
  PItem: PBrookConstraintItem;
begin
  for PItem in FList do
    if (PItem^.ActionClass = AActionClass) and
      (PItem^.ConstraintClass = AConstraintClass) then
      raise EBrookConstraint.CreateFmt(Self,
        SBrookConstraintAlreadyRegisteredError, [AConstraintClass.ClassName]);
end;

{ TBrookConstraints }

class procedure TBrookConstraints.RegisterService;
begin
  if Assigned(_BrookConstraintsServiceClass) then
    raise EBrookConstraint.Create(Self,
      SBrookConstraintsServiceAlreadyRegisteredError);
  _BrookConstraintsServiceClass := Self;
end;

class procedure TBrookConstraints.UnregisterService;
begin
  FreeAndNil(_BrookConstraintsService);
  _BrookConstraintsServiceClass := nil;
end;

class function TBrookConstraints.Service: TBrookConstraints;
begin
  if not Assigned(_BrookConstraintsService) then
  begin
    if not Assigned(_BrookConstraintsServiceClass) then
      raise EBrookConstraint.Create(Self,
        SBrookNoConstraintsServiceRegisteredError);
    _BrookConstraintsService := _BrookConstraintsServiceClass.Create;
  end;
  Result := _BrookConstraintsService;
end;

procedure TBrookConstraints.Add(AActionClass: TBrookActionClass;
  AConstraintClass: TBrookConstraintClass);
var
  PItem: PBrookConstraintItem;
begin
  CheckAdd(AActionClass, AConstraintClass);
  New(PItem);
  PItem^.ActionClass := AActionClass;
  PItem^.ConstraintClass := AConstraintClass;
  FList.Add(PItem);
end;

procedure TBrookConstraints.Execute(AAction: TBrookAction; ARoute: TBrookRoute);
var
  PItem: PBrookConstraintItem;
  VConstraint: TBrookConstraint;
begin
  for PItem in List do
    if PItem^.ActionClass = AAction.ClassType then
    begin
      VConstraint := PItem^.ConstraintClass.Create(AAction, ARoute);
      VConstraint.Execute;
      FreeAndNil(VConstraint);
    end;
end;

initialization
  TBrookConstraints.RegisterService;

finalization
  TBrookConstraints.UnregisterService;

end.
