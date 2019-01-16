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
begin
  Write('I''m running under FastCGI application!');
end;

initialization
  TMyAction.Register('*');

end.
