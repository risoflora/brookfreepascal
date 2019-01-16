program client;

{$mode objfpc}{$H+}

uses
  TcpIpClient;

var
  VData: ShortString;
  VDataSize: Integer;
  VClient: TTcpIpClientSocket;
begin
  VClient := TTcpIpClientSocket.Create('localhost', 4100);
  try
    VData := 'How are you?';
    VClient.Write(VData[1], Length(VData));
    if VClient.CanRead(60000) then
    begin
      VData := '';
      VDataSize := VClient.Waiting;
      SetLength(VData, VDataSize);
      VClient.Read(VData[1], VDataSize);
      WriteLn('Server says: ', VData);
    end;
    ReadLn;
  finally
    VClient.Free;
  end;
end.

