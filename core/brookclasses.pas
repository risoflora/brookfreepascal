(*
  Brook framework, Base Classes

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookClasses;

{$i brook.inc}

interface

uses
  BrookConsts, Classes, RtlConsts;

type
  { Is the main interface for Brook. }
  IBrookInterface = interface(IInterface)[BROOK_GUID]
  end;

  { Is the main object for Brook. }
  TBrookObject = class(TObject)
  end;

  { Is the main class for Brook. }
  TBrookClass = class of TBrookObject;

  { Is the main interfaced object for Brook. }
  TBrookInterfacedObject = class(TInterfacedObject)
  end;

  { Is the main persistent for Brook. }
  TBrookPersistent = class(TPersistent)
  end;

  { Is the main component for Brook. }
  TBrookComponent = class(TComponent)
  end;

  { Is the main data module for Brook. }
  TBrookDataModule = class(TDataModule)
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{ TBrookDataModule }

constructor TBrookDataModule.Create(AOwner: TComponent);
begin
  CreateNew(AOwner);
  if (ClassType <> TBrookDataModule) and not (csDesigning in ComponentState) then
  begin
    if not InitInheritedComponent(Self, TBrookDataModule) then
      raise EStreamError.CreateFmt(SErrNoStreaming, [ClassName]);
    if OldCreateOrder then
      DoCreate;
  end;
end;

end.
