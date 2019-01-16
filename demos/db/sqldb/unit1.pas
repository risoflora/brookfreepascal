unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, person;

type

  { TPersonAction }

  TPersonAction = class(specialize TBrookGAction<TPerson>)
  public
    procedure Post; override;
  end;

implementation

procedure TPersonAction.Post;
begin
  Entity.Save;
end;

initialization
  TPersonAction.Register('*');

end.
