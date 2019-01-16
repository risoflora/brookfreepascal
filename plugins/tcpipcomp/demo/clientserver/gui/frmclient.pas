unit frmclient;

{$mode objfpc}{$H+}

interface

uses
  TcpIpClient, Forms, StdCtrls;

type

  { TfrClient }

  TfrClient = class(TForm)
    btSay: TButton;
    edMsg: TMemo;
    procedure btSayClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FClient: TTcpIpClientSocket;
  end;

var
  frClient: TfrClient;

implementation

{$R *.lfm}

{ TfrClient }

procedure TfrClient.FormCreate(Sender: TObject);
begin
  FClient := TTcpIpClientSocket.Create('localhost', 4100);
end;

procedure TfrClient.FormDestroy(Sender: TObject);
begin
  FClient.Free;
end;

procedure TfrClient.btSayClick(Sender: TObject);
var
  VData: ShortString;
  VDataSize: Integer;
begin
  VData := 'How are you?';
  FClient.Write(VData[1], Length(VData));
  if FClient.CanRead(60000) then
  begin
    VData := '';
    VDataSize := FClient.Waiting;
    SetLength(VData, VDataSize);
    FClient.Read(VData[1], VDataSize);
    edMsg.Lines.Add('Server says: ' + VData);
  end;
end;

end.

