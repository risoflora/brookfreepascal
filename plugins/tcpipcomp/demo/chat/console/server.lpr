program server;

{$mode objfpc}{$H+}

uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  TcpIpServer, TcpIpClient, SysUtils, Classes;

type

  { TServerThread }

  TServerThread = class(TThread)
  private
    FClients: TThreadList;
    FServer: TTcpIpServerSocket;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Execute; override;
    procedure TerminateClients;
    property Clients: TThreadList read FClients;
  end;

  { TClientThread }

  TClientThread = class(TThread)
  private
    FData: string;
    FSocket: TTcpIpClientSocket;
    FOwner: TServerThread;
  protected
    procedure DoClientReceive;
  public
    constructor Create(AOwner: TServerThread; const ASocket: LongInt);
    destructor Destroy; override;
    procedure Execute; override;
    property Socket: TTcpIpClientSocket read FSocket;
  end;

  { TApp }

  TApp = class
  private
    FServer: TServerThread;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Run;
  end;

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
      FOwner.Clients.Add(Self);
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
    WriteLn('Connected: ', FSocket.Socket.Handle);
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
          DoClientReceive;
        end;
    finally
      WriteLn('Disconnected: ', FSocket.Socket.Handle);
    end;
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
        if VClient <> Self then
          WriteLn(FData);
      end;
    finally
      FOwner.Clients.UnlockList;
    end;
  end;

  { TApp }

  constructor TApp.Create;
  begin
    FServer := TServerThread.Create;
    FServer.Start;
  end;

  destructor TApp.Destroy;
  begin
    if Assigned(FServer) and not FServer.Finished then
    begin
      FServer.FreeOnTerminate := False;
      FServer.Terminate;
      FServer.TerminateClients;
      FreeAndNil(FServer);
    end;
    inherited Destroy;
  end;

  procedure TApp.Run;
  begin
    while not FServer.Finished do
      Sleep(100);
  end;

begin
  with TApp.Create do
  try
    Run;
  finally
    Free;
  end;
end.


