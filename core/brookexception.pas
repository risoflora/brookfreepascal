(*
  Brook framework, Exceptions Classes

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookException;

{$i brook.inc}

interface

uses
  BrookConsts, SysUtils;

type
  { Is a metaclass for @link(EBrook) class. }
  EBrookClass = class of EBrook;

  { Handles general exception in Brook. }
  EBrook = class(Exception)
  public
    { Creates an instance of @code(EBrook). }
    constructor Create(AInstance: TObject; const AMsg: string); overload;
    { Creates an instance of @code(EBrook). }
    constructor Create(AClass: TClass; const AMsg: string); overload;
    { Creates an instance of @code(EBrook). }
    constructor Create(AName: string; const AMsg: string); overload;
    { Creates an instance of @code(EBrook) with a formated message. }
    constructor CreateFmt(AInstance: TObject; const AMsg: string;
      const AArgs: array of const); overload;
    { Creates an instance of @code(EBrook) with a formated message. }
    constructor CreateFmt(AClass: TClass; const AMsg: string;
      const AArgs: array of const); overload;
    { Creates an instance of @code(EBrook) with a formated message. }
    constructor CreateFmt(AName: string; const AMsg: string;
      const AArgs: array of const); overload;
  end;

  { Handles the exception for 404 error. }
  EBrookHttp404 = class(EBrook);

  { Handles the exception for 500 error. }
  EBrookHttp500 = class(EBrook);

implementation

constructor EBrook.Create(AInstance: TObject; const AMsg: string);
var
  VClassName: string;
begin
  if Assigned(AInstance) then
    VClassName := AInstance.ClassName
  else
    VClassName := ES;
  inherited CreateFmt(BROOK_ERROR_MASK, [VClassName, AMsg]);
end;

constructor EBrook.Create(AClass: TClass; const AMsg: string);
var
  VClassName: string;
begin
  if Assigned(AClass) then
    VClassName := AClass.ClassName
  else
    VClassName := ES;
  inherited CreateFmt(BROOK_ERROR_MASK, [VClassName, AMsg]);
end;

constructor EBrook.Create(AName: string; const AMsg: string);
begin
  inherited CreateFmt(BROOK_ERROR_MASK, [AName, AMsg]);
end;

constructor EBrook.CreateFmt(AInstance: TObject; const AMsg: string;
  const AArgs: array of const);
var
  VClassName: string;
begin
  if Assigned(AInstance) then
    VClassName := AInstance.ClassName
  else
    VClassName := ES;
  inherited CreateFmt(Format(BROOK_ERROR_MASK, [VClassName, AMsg]), AArgs);
end;

constructor EBrook.CreateFmt(AClass: TClass; const AMsg: string;
  const AArgs: array of const);
var
  VClassName: string;
begin
  if Assigned(AClass) then
    VClassName := AClass.ClassName
  else
    VClassName := ES;
  inherited CreateFmt(Format(BROOK_ERROR_MASK, [VClassName, AMsg]), AArgs);
end;

constructor EBrook.CreateFmt(AName: string; const AMsg: string;
  const AArgs: array of const);
begin
  inherited CreateFmt(Format(BROOK_ERROR_MASK, [AName, AMsg]), AArgs);
end;

end.
