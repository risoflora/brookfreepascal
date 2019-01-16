unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  BrookAction;

type
  TIndex = class(TBrookAction)
  public
    procedure Get; override;
  end;

implementation

procedure TIndex.Get;
begin
  Render('template.html');
end;

initialization
  TIndex.Register('/index/', True);

end.
