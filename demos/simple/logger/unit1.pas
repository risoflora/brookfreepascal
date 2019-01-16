unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, Classes;

type

  { TMyAction }

  TMyAction = class(TBrookAction)
  public
    procedure Get; override;
  end;

implementation

procedure TMyAction.Get;
var
  s: TStringList;
begin
  s := nil;
  s.SaveToFile(''); // causes Access Violation - see error details in MYAPP.LOG file.
end;

initialization
  TMyAction.Register('*');

end.
