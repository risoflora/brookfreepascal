unit frmmain;

{$mode objfpc}{$H+}

interface

uses
  TcpIpClient, Forms, StdCtrls;

type

  { TfrMain }

  TfrMain = class(TForm)
    btGet: TButton;
    edResponse: TMemo;
    procedure btGetClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FSocket: TTcpIpClientSocket;
  end;

var
  frMain: TfrMain;

implementation

{$R *.lfm}

{ TfrMain }

procedure TfrMain.FormCreate(Sender: TObject);
begin
  FSocket := TTcpIpClientSocket.Create('www.google.com', 80);
end;

procedure TfrMain.FormDestroy(Sender: TObject);
begin
  FSocket.Free;
end;

procedure TfrMain.btGetClick(Sender: TObject);
const
  CRLF = #13#10;
var
  VBufferSize: LongInt;
  VBuffer, VGet: string;
begin
  VGet := 'GET /index.html HTTP/1.1' + CRLF;
  VGet += 'Host: www.google.com' + CRLF + CRLF;
  FSocket.Write(Pointer(VGet)^, Length(VGet));
  if FSocket.CanRead($3E8) then
  begin
    edResponse.Clear;
    while FSocket.LastError = 0 do
      begin
        VBufferSize := FSocket.Waiting;
        if VBufferSize < 1 then
          Break;
        SetLength(VBuffer, VBufferSize);
        FSocket.Read(Pointer(VBuffer)^, VBufferSize);
        edResponse.Lines.Add(VBuffer);
      end;
  end;
end;

end.

