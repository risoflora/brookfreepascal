unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  BrookAction;

type
  TMyAction = class(TBrookAction)
  public
    procedure Get; override;
  end;

implementation

procedure TMyAction.Get;
begin
  Write('Hello world!');
end;

initialization
  TMyAction.Register('*');

end.
