unit test;

{$mode objfpc}{$H+}

interface

uses
  BrookAction;

type

  { TPerson }

  TPerson = class(TObject)
  private
    FId: Int64;
    FName: string;
  published
    property Id: Int64 read FId write FId;
    property Name: string read FName write FName;
  end;

  { TMyAction }

  TMyAction = class(specialize TBrookGAction<TPerson>)
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
begin
  Write(Entity);
end;

initialization
  TMyAction.Register('*');

end.
