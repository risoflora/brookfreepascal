program demo;

{$mode objfpc}{$H+}

uses
  TcpIpClient;

const
  CRLF = #13#10;
var
  VBufferSize: LongInt;
  VBuffer, VOutput, VGet: string;
  VSocket: TTcpIpClientSocket;
begin
  VSocket := TTcpIpClientSocket.Create('www.google.com', 80);
  try
    VGet := 'GET /index.html HTTP/1.1' + CRLF;
    VGet += 'Host: www.google.com' + CRLF + CRLF;
    VSocket.Write(Pointer(VGet)^, Length(VGet));
    if VSocket.CanRead($3E8) then
    begin
      VOutput := '';
      while VSocket.LastError = 0 do
        begin
          VBufferSize := VSocket.Waiting;
          if VBufferSize < 1 then
            Break;
          SetLength(VBuffer, VBufferSize);
          VSocket.Read(Pointer(VBuffer)^, VBufferSize);
          VOutput += VBuffer;
        end;
      WriteLn(VOutput);
    end;
  finally
    VSocket.Free;
  end;
end.

