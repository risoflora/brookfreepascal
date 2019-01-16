unit frmserver;

{$mode objfpc}{$H+}

interface

uses
  TcpIpServer, TcpIpClient, Classes, SysUtils, Forms, StdCtrls;

type
  TServerThread = class;

  { TfrServer }

  TfrServer = class(TForm)
    edMsg: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  protected
    procedure DoClientReceive(Sender: TObject; const AData: string);
    procedure DoClientConnect(Sender: TObject; const ASocket: LongInt);
    procedure DoClientDisconnect(Sender: TObject; const ASocket: LongInt);
  private
    FServer: TServerThread;
  end;

  TClientReceiveEvent = procedure(Sender: TObject;
    const AData: string) of object;
  TClientConnectEvent = procedure(Sender: TObject;
    const ASocket: LongInt) of object;

  { TServerThread }

  TServerThread = class(TThread)
  private
    FClients: TThreadList;
    FOnClientConnect: TClientConnectEvent;
    FOnClientDisconnect: TClientConnectEvent;
    FOnClientReceive: TClientReceiveEvent;
    FServer: TTcpIpServerSocket;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute; override;
    procedure TerminateClients;
    property Clients: TThreadList read FClients;
    property OnClientConnect: TClientConnectEvent read FOnClientConnect
      write FOnClientConnect;
    property OnClientDisconnect: TClientConnectEvent read FOnClientDisconnect
      write FOnClientDisconnect;
    property OnClientReceive: TClientReceiveEvent read FOnClientReceive
      write FOnClientReceive;
  end;

  { TClientThread }

  TClientThread = class(TThread)
  private
    FData: string;
    FOnConnect: TClientConnectEvent;
    FOnDisconnect: TClientConnectEvent;
    FOnReceive: TClientReceiveEvent;
    FSocket: TTcpIpClientSocket;
    FOwner: TServerThread;
  protected
    procedure DoClientConnect;
    procedure DoClientDisconnect;
    procedure DoClientReceive;
  public
    constructor Create(AOwner: TServerThread; const ASocket: LongInt);
    destructor Destroy; override;
    procedure Execute; override;
    property OnConnect: TClientConnectEvent read FOnConnect write FOnConnect;
    property OnDisconnect: TClientConnectEvent read FOnDisconnect write FOnDisconnect;
    property OnReceive: TClientReceiveEvent read FOnReceive write FOnReceive;
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
      if Assigned(VClient) and not VClient.Finished then
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
    FOnConnect := FOwner.OnClientConnect;
    FOnDisconnect := FOwner.OnClientDisconnect;
    FOnReceive := FOwner.OnClientReceive;
  end;
end;

destructor TClientThread.Destroy;
begin
  if Assigned(FOwner) then
    FOwner.Clients.Remove(Self);
  if not Finished then
    FSocket.Free;
  inherited Destroy;
end;

procedure TClientThread.Execute;
var
  VDataSize: Integer;
begin
  Queue(@DoClientConnect);
  try
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
        VDataSize := FSocket.Read(Pointer(FData)^, VDataSize);
        if VDataSize < 1 then
          Break;
        Queue(@DoClientReceive);
      end;
  finally
{$IFDEF UNIX}
    Sleep(100);
{$ENDIF}
    Queue(@DoClientDisconnect);
  end;
end;

procedure TClientThread.DoClientConnect;
begin
  if Assigned(FOnConnect)
{$IFDEF MSWINDOWS}and not FSocket.Socket.Closing{$ENDIF}then
    FOnConnect(Self, FSocket.Socket.Handle);
end;

procedure TClientThread.DoClientDisconnect;
begin
  if Assigned(FOnDisconnect)
{$IFDEF MSWINDOWS}and not FSocket.Socket.Closing{$ENDIF}then
    FOnDisconnect(Self, FSocket.Socket.Handle);
end;

procedure TClientThread.DoClientReceive;
var
  VList: TList;
  VItem: Pointer;
  VClient: TClientThread absolute VItem;
begin
  if not Assigned(FOwner) then
    Exit;
  if not Assigned(FOwner.FServer) then
    Exit;
  if not FOwner.FServer.IsConnected then
    Exit;
  VList := FOwner.Clients.LockList;
  try
    for VItem in VList do
    begin
      if not Assigned(VClient.Socket) then
        Continue;
      FData := DateTimeToStr(Now) + '- ' + FData;
      VClient.Socket.Write(Pointer(FData)^, Length(FData));
      if Assigned(FOnReceive) and (VClient <> Self) then
        FOnReceive(Self, FData);
    end;
  finally
    FOwner.Clients.UnlockList;
  end;
end;

{ TfrServer }

procedure TfrServer.FormCreate(Sender: TObject);
begin
  FServer := TServerThread.Create;
  FServer.Start;
  FServer.OnClientReceive := @DoClientReceive;
  FServer.OnClientConnect := @DoClientConnect;
  FServer.OnClientDisconnect := @DoClientDisconnect;
end;

procedure TfrServer.FormDestroy(Sender: TObject);
begin
  if Assigned(FServer) and not FServer.Finished then
  begin
    FServer.FreeOnTerminate := False;
    FServer.Terminate;
    FServer.TerminateClients;
    FreeAndNil(FServer);
  end;
end;

procedure TfrServer.DoClientReceive(Sender: TObject; const AData: string);
begin
  edMsg.Lines.Add(AData);
end;

procedure TfrServer.DoClientConnect(Sender: TObject; const ASocket: LongInt);
begin
  edMsg.Lines.Add('Connected: ' + IntToStr(ASocket));
end;

procedure TfrServer.DoClientDisconnect(Sender: TObject; const ASocket: LongInt);
begin
  edMsg.Lines.Add('Disconnected: ' + IntToStr(ASocket));
end;

end.
