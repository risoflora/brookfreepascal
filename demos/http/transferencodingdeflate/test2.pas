unit test2;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, RUtils;

type
  TTest2Action = class(TBrookAction)
  public
    procedure Get; override;
  end;

implementation

procedure TTest2Action.Get;
begin
  HttpResponse.SetCustomHeader('Content-Encoding', 'deflate');
  Write(ZCompressStr('Hello world! (compressed content)'));
end;

initialization
  TTest2Action.Register('/test2');

end.
