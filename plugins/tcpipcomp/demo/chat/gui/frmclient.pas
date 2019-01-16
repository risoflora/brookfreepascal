unit frmclient;

{$mode objfpc}{$H+}

interface

uses
  TcpIpClient, Classes, SysUtils, Forms, StdCtrls, Controls;

type

  { TfrClient }

  TfrClient = class(TForm)
    btSend: TButton;
    edText: TEdit;
    edMsg: TMemo;
    procedure btSendClick(Sender: TObject);
    procedure edTextKeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  protected
    procedure DoClientReceive(Sender: TObject; const AData: string);
  private
    FClient: TTcpIpClientSocket;
  end;

  TClientReceiveEvent = procedure(Sender: TObject;
    const AData: string) of object;

  { TClientThread }

  TClientThread = class(TThread)
  private
    FData: string;
    FOnReceive: TClientReceiveEvent;
    FSocket: TTcpIpClientSocket;
  protected
    procedure DoReceive;
  public
    constructor Create(ASocket: TTcpIpClientSocket);
    procedure Execute; override;
    property OnReceive: TClientReceiveEvent read FOnReceive write FOnReceive;
  end;

var
  frClient: TfrClient;
  NickName: string;

implementation

{$R *.lfm}

{ TClientThread }

constructor TClientThread.Create(ASocket: TTcpIpClientSocket);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FSocket := ASocket;
end;

procedure TClientThread.Execute;
var
  VDataSize: Integer;
begin
  while (not Terminated) or (FSocket.LastError = 0) do
  begin
    if FSocket.Socket.Closing then
      Break;
    if not FSocket.CanRead(1000) then
      Continue;
    FData := '';
    VDataSize := FSocket.Waiting;
    if VDataSize < 1 then
      Break;
    SetLength(FData, VDataSize);
    VDataSize := FSocket.Read(Pointer(FData)^, VDataSize);
    if VDataSize < 1 then
      Exit;
    Queue(@DoReceive);
  end;
end;

procedure TClientThread.DoReceive;
begin
  if Assigned(FOnReceive) then
    FOnReceive(Self, FData);
end;

{ TfrClient }

procedure TfrClient.FormCreate(Sender: TObject);
begin
  FClient := TTcpIpClientSocket.Create('localhost', 4100);
  TClientThread.Create(FClient).OnReceive := @DoClientReceive;
end;

procedure TfrClient.FormDestroy(Sender: TObject);
begin
  FClient.Free;
end;

procedure TfrClient.DoClientReceive(Sender: TObject; const AData: string);
begin
  edMsg.Lines.Add(AData);
end;

procedure TfrClient.btSendClick(Sender: TObject);
var
  VData: string;
begin
  if Trim(edText.Text) = '' then
    Exit;
  VData := NickName + ': ' + edText.Text;
  FClient.Write(Pointer(VData)^, Length(VData));
  edText.Clear;
  if edText.CanFocus then
    edText.SetFocus;
end;

procedure TfrClient.edTextKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
  begin
    Key := #0;
    btSendClick(Sender);
  end;
end;

end.

