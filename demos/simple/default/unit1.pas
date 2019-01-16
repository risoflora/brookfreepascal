unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  BrookAction;

type

  { TAction1 }

  TAction1 = class(TBrookAction)
  public
    procedure Get; override;
  end;

  { TAction2 }

  TAction2 = class(TBrookAction)
  public
    procedure Get; override;
  end;

implementation

{ TAction1 }

procedure TAction1.Get;
begin
  Write('TAction1 - Default.');
end;

{ TAction2 }

procedure TAction2.Get;
begin
  Write('TAction2');
end;

initialization
  // the TAction1 is called by default when no action matches with informed URL
  TAction1.Register('/action1', True);
  TAction2.Register('/action2');

end.
