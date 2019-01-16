unit test;

{$mode objfpc}{$H+}

interface

uses
  BrookAction;

type

  { TMyAction }

  TMyAction = class(TBrookAction)
  public
    procedure Get; override;
  end;

implementation

{ TMyAction }

procedure TMyAction.Get;
var
  I: Integer;
  N, V: string;
begin
  for I := 0 to Pred(Params.Count) do
  begin
    Params.GetNameValue(I, N, V);
    Write('%d: %s-%s<br />', [I, N, V]);
  end;
end;

initialization
  // call http://localhost/cgi-bin/cgi1.bf?q1=abc&q2=123
  TMyAction.Register('*');

end.
