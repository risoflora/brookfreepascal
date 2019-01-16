program server;

{$mode objfpc}{$H+}

uses
  TcpIpServer, TcpIpClient;

var
  VData: ShortString;
  VSocket,VDataSize: LongInt;
  VClient: TTcpIpClientSocket;
  VServer: TTcpIpServerSocket;
begin
  VServer := TTcpIpServerSocket.Create(4100);
  VServer.Listen;
  VSocket := VServer.Accept;
  if VSocket = -1 then
    Exit;
  VClient := TTcpIpClientSocket.Create(VSocket);
  try
    if VClient.CanRead(60000) then
    begin
      VDataSize := VClient.Waiting;
      SetLength(VData, VDataSize);
      VClient.Read(VData[1], VDataSize);

      WriteLn('Client says: ', VData);
      VData := 'I''m fine, thank you!';
      VClient.Write(VData[1], Length(VData));
    end;
    ReadLn;
  finally
    VClient.Free;
  end;
end.

