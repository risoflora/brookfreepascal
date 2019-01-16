unit test;

{$mode objfpc}{$H+}

interface

uses
  BrookAction;

type

  { TMyObject }

  TMyObject = class(TObject)
  private
    Fq1: string;
    Fq2: Integer;
  published
    property q1: string read Fq1 write Fq1;
    property q2: Integer read Fq2 write Fq2;
  end;

  { TMyAction }

  TMyAction = class(specialize TBrookGAction<TMyObject>)
  public
    procedure Get; override;
  end;

implementation

{ TMyAction }

procedure TMyAction.Get;
begin
  GetParams(Entity);
  Write(Entity);
end;

initialization
  // call http://localhost/cgi-bin/cgi1.bf?q1=abc&q2=123
  TMyAction.Register('*');

end.
