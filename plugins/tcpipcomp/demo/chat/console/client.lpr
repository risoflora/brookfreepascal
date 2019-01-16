program client;

{$mode objfpc}{$H+}

uses
{$IFDEF UNIX}
  CThreads,
{$ENDIF}
  TcpIpClient, SysUtils, Classes;

type

  { TClientThread }

  TClientThread = class(TThread)
  private
    FSocket: TTcpIpClientSocket;
  public
    constructor Create(ASocket: TTcpIpClientSocket);
    procedure Execute; override;
  end;

  { TClientThread }

  constructor TClientThread.Create(ASocket: TTcpIpClientSocket);
  begin
    inherited Create(False);
    FreeOnTerminate := True;
    FSocket := ASocket;
  end;

  procedure TClientThread.Execute;
  var
    VData: string;
    VDataSize: Integer;
  begin
    while not Terminated do
    begin
      if not FSocket.CanRead(1000) then
        Continue;
      VDataSize := FSocket.Waiting;
      SetLength(VData, VDataSize);
      VDataSize := FSocket.Read(Pointer(VData)^, VDataSize);
      if VDataSize < 1 then
        Exit;
      WriteLn(VData);
    end;
  end;

var
  VNickName, VData: string;
  VClient: TTcpIpClientSocket;
begin
  WriteLn('Put your nick name: ');
  Read(VNickName);
  if Trim(VNickName) = '' then
    Halt;
  VClient := TTcpIpClientSocket.Create('localhost', 4100);
  try
    TClientThread.Create(VClient);
    repeat
      ReadLn(VData);
      if Trim(VData) = '' then
        Continue;
      VData := VNickName + ': ' + VData;
      VClient.Write(Pointer(VData)^, Length(VData));
    until False;
  finally
    VClient.Free;
  end;
end.
