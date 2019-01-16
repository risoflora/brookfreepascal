unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  BrookAction;

type
  THelloWorld = class(TBrookAction)
  public
    procedure Get; override;
  end;

implementation

procedure THelloWorld.Get;
begin
  Write('Hello world!');
end;

initialization
  THelloWorld.Register('*');

end.
