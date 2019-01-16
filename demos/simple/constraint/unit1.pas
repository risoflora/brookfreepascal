unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, BrookConstraints;

type

  { TMyConstraint }

  TMyConstraint = class(TBrookConstraint)
  public
    procedure Execute; override;
  end;

  { TMyAction }

  TMyAction = class(TBrookAction)
  public
    procedure Get; override;
  end;

implementation

{ TMyConstraint }

procedure TMyConstraint.Execute;
begin
  if Action.Params.Count = 0 then
    Stop('<a href="%s">Click here to continue...</a>',
      [Action.UrlFor(TMyAction) + '?a=b']);
end;

{ TMyAction }

procedure TMyAction.Get;
begin
  Write('OK');
end;

initialization
  TMyAction.Register('*');
  TMyConstraint.Register(TMyAction);

end.
