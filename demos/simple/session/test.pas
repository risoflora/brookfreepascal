unit Test;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, BrookSession;

type

  { TVisit }

  TVisit = class
  private
    FCount: Integer;
  published
    property Count: Integer read FCount write FCount;
  end;

  { TSession }

  TSession = specialize TBrookGSession<TVisit>;

  { TMyAction }

  TMyAction = class(TBrookAction)
  private
    FSession: TSession;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Get; override;
  end;

implementation

{ TMyAction }

constructor TMyAction.Create;
begin
  inherited Create;
  FSession := TSession.Create(nil);
end;

destructor TMyAction.Destroy;
begin
  FSession.Free;
  inherited Destroy;
end;

procedure TMyAction.Get;
begin
  FSession.Start(HttpRequest);
  Write('<!DOCTYPE HTML>');
  Write('<html lang="en-US">');
  Write('<head>');
  Write('	<meta charset="UTF-8">');
  Write('	<title>Visits</title>');
  Write('</head>');
  Write('<body>');
  if FSession.IsEmpty then
  begin
    Write('Use F5 to show created session.<br />');
    FSession.Entity.Count := 1;
  end
  else
  begin
    Write('Visit count: %d', [FSession.Entity.Count]);
    FSession.Entity.Count := FSession.Entity.Count + 1;
  end;
  Write('</body>');
  Write('</html>');
  FSession.Finish(HttpResponse);
end;

initialization
  TMyAction.Register('*');

end.
