unit frmserver;

{$mode objfpc}{$H+}

interface

uses
  TcpIpServer, TcpIpClient, Classes, Forms, StdCtrls, SysUtils;

type
  TClientReceiveEvent = procedure(const AData: ShortString) of object;

  TServerThread = class;

  { TfrServer }

  TfrServer = class(TForm)
    edMsg: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FServer: TServerThread;
  protected
    procedure DoClientReceive(const AData: ShortString);
  end;

  { TServerThread }

  TServerThread = class(TThread)
  private
    FClients: TThreadList;
    FOnClientReceive: TClientReceiveEvent;
    FServer: TTcpIpServerSocket;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute; override;
    procedure TerminateClients;
    property Clients: TThreadList read FClients;
    property OnClientReceive: TClientReceiveEvent read FOnClientReceive
      write FOnClientReceive;
  end;

  { TClientThread }

  TClientThread = class(TThread)
  private
    FData: ShortString;
    FOnClientReceive: TClientReceiveEvent;
    FSocket: TTcpIpClientSocket;
    FOwner: TServerThread;
  protected
    procedure DoClientReceive;
  public
    constructor Create(AOwner: TServerThread; const ASocket: LongInt);
    destructor Destroy; override;
    procedure Execute; override;
    property OnClientReceive: TClientReceiveEvent read FOnClientReceive
      write FOnClientReceive;
    property Socket: TTcpIpClientSocket read FSocket;
  end;

var
  frServer: TfrServer;

implementation

{$R *.lfm}

{ TServerThread }

constructor TServerThread.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FClients := TThreadList.Create;
  FServer := TTcpIpServerSocket.Create(4100);
end;

destructor TServerThread.Destroy;
begin
  FClients.Free;
  FServer.Free;
  inherited Destroy;
end;

procedure TServerThread.Execute;
var
  VSocket: LongInt;
  VClient: TClientThread;
begin
  FServer.Bind;
  FServer.Listen;
  while (not Terminated) or (FServer.LastError = 0) do
  begin
    VSocket := FServer.Accept;
    if VSocket = -1 then
      Break;
    VClient := TClientThread.Create(Self, VSocket);
    if Assigned(VClient) then
      VClient.Start;
  end;
end;

procedure TServerThread.TerminateClients;
var
  VList: TList;
  VItem: Pointer;
  VClient: TClientThread absolute VItem;
begin
  VList := FClients.LockList;
  try
    for VItem in VList do
      if Assigned(VClient) and not VClient.FreeOnTerminate then
      begin
        VClient.FreeOnTerminate := False;
        VClient.Terminate;
        if Assigned(VClient.Socket) then
          VClient.Socket.Free;
        VClient.WaitFor;
        FreeAndNil(VClient);
      end;
  finally
    FClients.UnlockList;
  end;
end;

{ TClientThread }

constructor TClientThread.Create(AOwner: TServerThread; const ASocket: LongInt);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FOwner := AOwner;
  FSocket := TTcpIpClientSocket.Create(ASocket);
  if Assigned(FOwner) then
  begin
    FOwner.Clients.Add(Self);
    FOnClientReceive := FOwner.OnClientReceive;
  end;
end;

destructor TClientThread.Destroy;
begin
  if Assigned(FOwner) then
    FOwner.Clients.Remove(Self);
  if not FreeOnTerminate then
    FSocket.Free;
  inherited Destroy;
end;

procedure TClientThread.Execute;
var
  VDataSize: Integer;
begin
  while (not Terminated) or (FSocket.LastError = 0) do
    if FSocket.CanRead(1000) then
    begin
//{$IFDEF UNIX}
      if FSocket.Socket.Closing then
        Break;
//{$ENDIF}
      FData := '';
      VDataSize := FSocket.Waiting;
      if VDataSize < 1 then
        Break;
      SetLength(FData, VDataSize);
      VDataSize := FSocket.Read(FData[1], VDataSize);
      if VDataSize < 1 then
        Break;
      Synchronize(@DoClientReceive);
      FData := 'I''m fine, thank you!';
      FSocket.Write(FData[1], Length(FData));
    end;
end;

procedure TClientThread.DoClientReceive;
begin
  if Assigned(FOnClientReceive) then
    FOnClientReceive(FData);
end;

{ TfrServer }

procedure TfrServer.FormCreate(Sender: TObject);
begin
  FServer := TServerThread.Create;
  FServer.OnClientReceive := @DoClientReceive;
  FServer.Start;
end;

procedure TfrServer.FormDestroy(Sender: TObject);
begin
  if Assigned(FServer) and not FServer.FreeOnTerminate then
  begin
    FServer.FreeOnTerminate := False;
    FServer.Terminate;
    FServer.TerminateClients;
    FreeAndNil(FServer);
  end;
end;

procedure TfrServer.DoClientReceive(const AData: ShortString);
begin
  edMsg.Lines.Add(AData);
end;

end.

