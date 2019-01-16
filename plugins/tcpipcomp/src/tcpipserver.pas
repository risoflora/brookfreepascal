(*
  Useful classes for TCP/IP communication.
  Copyright (c) 2013 by Silvio Clecio, Gilson Nunes Rodrigues and Waldir Paim

  See the file COPYING.FPC, included in this distribution,
  for details about the copyright.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit TcpIpServer;

{$mode objfpc}{$H+}

interface

uses
{$IFDEF UNIX}
  BaseUnix,
{$ENDIF}
  TcpIpBase, SSockets, Sockets;

type

  { TInetServerEx }

  TInetServerEx = class(TInetServer)
  private
    FClosing: Boolean;
  protected
    procedure InternalClose; virtual;
  public
    destructor Destroy; override;
    function Accept: LongInt; override;
    property Closing: Boolean read FClosing;
  end;

  { TTcpIpServerSocket }

  TTcpIpServerSocket = class(TTcpIpBaseSocket)
  private
    FSocket: TInetServerEx;
  protected
    function GetLastError: Integer; override;
  public
    constructor Create(const AHost: string; const APort: Word); override;
    constructor Create(const APort: Word); overload;
    destructor Destroy; override;
    function Accept: LongInt;
    procedure Bind;
    procedure Listen;
    function IsConnected: Boolean; override;
    property Socket: TInetServerEx read FSocket;
  end;

implementation

{ TInetServerEx }

procedure TInetServerEx.InternalClose;
begin
  FClosing := True;
  StopAccepting;
  FPShutdown(Socket, SHUT_RDWR);
  inherited Close;
end;

destructor TInetServerEx.Destroy;
begin
  InternalClose;
  inherited Destroy;
end;

function TInetServerEx.Accept: LongInt;
var
  L: LongInt;
begin
  L := SizeOf(FAddr);
  Result := FPAccept(Socket, @FAddr, @L);
  if FClosing then
    Exit;
  if Result < 0 then
{$IFDEF UNIX}
    if SocketError = ESysEWOULDBLOCK then
      raise ESocketError.Create(seAcceptWouldBlock, [Socket])
    else
{$ENDIF}
      raise ESocketError.Create(seAcceptFailed, [Socket, SocketError]);
end;

{ TTcpIpServerSocket }

constructor TTcpIpServerSocket.Create(const AHost: string; const APort: Word);
begin
  inherited Create(AHost, APort);
  FSocket := TInetServerEx.Create(AHost, APort);
end;

constructor TTcpIpServerSocket.Create(const APort: Word);
begin
  Create('', APort);
end;

destructor TTcpIpServerSocket.Destroy;
begin
  FSocket.Free;
  inherited Destroy;
end;

function TTcpIpServerSocket.Accept: LongInt;
begin
  Result := FSocket.Accept;
end;

procedure TTcpIpServerSocket.Bind;
begin
  FSocket.Bind;
end;

procedure TTcpIpServerSocket.Listen;
begin
  FSocket.Listen;
end;

function TTcpIpServerSocket.IsConnected: Boolean;
begin
  Result := Assigned(FSocket) and (FSocket.Socket > 0);
end;

function TTcpIpServerSocket.GetLastError: Integer;
begin
  Result := SocketError;
end;

end.
