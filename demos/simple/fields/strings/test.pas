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
    procedure Post; override;
  end;

implementation

{ TMyAction }

procedure TMyAction.Get;
begin
  Render('form.html');
end;

procedure TMyAction.Post;
var
  I: Integer;
  N, V: string;
begin
  for I := 0 to Pred(Fields.Count) do
  begin
    Fields.GetNameValue(I, N, V);
    Write('%d: %s-%s<br />', [I, N, V]);
  end;
end;

initialization
  TMyAction.Register('*');

end.
