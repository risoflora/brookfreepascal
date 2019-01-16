// Please see: http://en.wikipedia.org/wiki/HTTP_location

unit Test;

{$mode objfpc}{$H+}

interface

uses
  BrookAction;

type
  TTest = class(TBrookAction)
  public
    procedure Get; override;
  end;

implementation

procedure TTest.Get;
begin
  Redirect('https://www.google.com/');
end;

initialization
  TTest.Register('*');

end.
