(*
  Useful classes for TCP/IP communication.
  Copyright (c) 2013 by Silvio Clecio, Gilson Nunes Rodrigues and Waldir Paim

  See the file COPYING.FPC, included in this distribution,
  for details about the copyright.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit TcpIpClient;

{$mode objfpc}{$H+}

interface

uses
{$IFDEF UNIX}
  BaseUnix,
{$ELSE}
  WinSock2,
{$ENDIF}
  TcpIpBase, TcpIpUtils, SSockets, Sockets, sysutils;

type

  { TInetSocketEx }

  TInetSocketEx = class(TInetSocket)
  private
    FClosing: Boolean;
  public
    destructor Destroy; override;
    procedure Close;
    property Closing: Boolean read FClosing;
  end;

  { TTcpIpClientSocket }

  TTcpIpClientSocket = class(TTcpIpSocket)
  private
    FSocket: TInetSocketEx;
  protected
    function GetLastError: Integer; override;
    function InternalSelect(AWriteFds, AReadFds: PFDSet;
      const ATimeOut: Integer): Boolean;
  public
    constructor Create(const AHost: string; const APort: Word); override;
    constructor Create(const ASocket: LongInt); overload;
    destructor Destroy; override;
    function IsConnected: Boolean; override;
    function Waiting: Integer; override;
    function CanWrite(const ATimeOut: Integer): Boolean; override;
    function CanRead(const ATimeOut: Integer): Boolean; override;
    function Write(const ABuffer; ACount: LongInt): LongInt; override;
    function Read(var ABuffer; ACount: LongInt): LongInt; override;
    property Socket: TInetSocketEx read FSocket;
  end;

implementation

uses termio;

{ TInetSocketEx }

destructor TInetSocketEx.Destroy;
begin
  Close;
  inherited Destroy;
end;

procedure TInetSocketEx.Close;
begin
  if FClosing then
    Exit;
  FClosing := True;
  FPShutdown(Handle, SHUT_RDWR);
end;

{ TTcpIpClientSocket }

constructor TTcpIpClientSocket.Create(const AHost: string; const APort: Word);
begin
  inherited Create(AHost, APort);
  FSocket := TInetSocketEx.Create(AHost, APort);
end;

constructor TTcpIpClientSocket.Create(const ASocket: LongInt);
begin
  FSocket := TInetSocketEx.Create(ASocket);
end;

destructor TTcpIpClientSocket.Destroy;
begin
  FSocket.Free;
  inherited Destroy;
end;

function TTcpIpClientSocket.IsConnected: Boolean;
begin
  Result := Assigned(FSocket) and (FSocket.Handle > 0);
end;

procedure  _IoctlSocket(s: TSocket; cmd: DWORD; var arg: integer);
begin
  if fpIoctl(s, cmd, @arg) <> 0 then
     raise exception.create('dada');
end;

function TTcpIpClientSocket.Waiting: Integer;
//var
 // L: DWord;
begin
  Result := 1;
  //L := 0;
  _IoctlSocket (FSocket.Handle, FIONREAD, Result) ;
//  //synsock.IoctlSocket   (
//{$IFDEF UNIX}
//  if FPIOCtl(FSocket.Handle, $541B, @L) = 0 then
//{$ELSE}
//  if IOCtlSocket(FSocket.Handle, FIONREAD, L) = 0 then
//{$ENDIF}
 //   Result := L;
  if Result > $10000 then
    Result := $10000;
end;

function TTcpIpClientSocket.InternalSelect(AWriteFds, AReadFds: PFDSet;
  const ATimeOut: Integer): Boolean;
var
  VPTimeVal: PTimeVal;
  VTimeVal: TTimeVal;
  VSelectRes: Integer;
begin
  VTimeVal.tv_usec := (ATimeOut mod $3E8) * $3E8;
  VTimeVal.tv_sec := ATimeOut div $3E8;
  VPTimeVal := @VTimeVal;
  if ATimeOut = TCP_IP_INFINITE_TIMEOUT then
    VPTimeVal := nil;
{$HINTS OFF}
 {$IFDEF UNIX}
  VSelectRes := FPSelect(FSocket.Handle + 1, AReadFds, AWriteFds, nil, VPTimeVal);
 {$ELSE}
  VSelectRes := Select(FSocket.Handle + 1, AReadFds, AWriteFds, nil, VPTimeVal);
 {$ENDIF}
{$HINTS ON}
  if GetLastError <> 0 then
    VSelectRes := 0;
  Result := VSelectRes > 0;
end;

function TTcpIpClientSocket.CanWrite(const ATimeOut: Integer): Boolean;
var
  VWriteFd: TFDSet;
begin
{$HINTS OFF}
 {$IFDEF UNIX}
  FPFD_ZERO(VWriteFd);
  FPFD_SET(FSocket.Handle, VWriteFd);
 {$ELSE}
  FD_ZERO(VWriteFd);
  FD_SET(FSocket.Handle, VWriteFd);
 {$ENDIF}
{$HINTS ON}
  Result := InternalSelect(@VWriteFd, nil, ATimeOut);
end;

function TTcpIpClientSocket.CanRead(const ATimeOut: Integer): Boolean;
var
  VReadFd: TFDSet;
begin
{$HINTS OFF}
 {$IFDEF UNIX}
  FPFD_ZERO(VReadFd);
  FPFD_SET(FSocket.Handle, VReadFd);
 {$ELSE}
  FD_ZERO(VReadFd);
  FD_SET(FSocket.Handle, VReadFd);
 {$ENDIF}
{$HINTS ON}
  Result := InternalSelect(nil, @VReadFd, ATimeOut);
end;

function TTcpIpClientSocket.GetLastError: Integer;
begin
  Result := FSocket.LastError;
end;

function TTcpIpClientSocket.Write(const ABuffer; ACount: LongInt): LongInt;
begin
  Result := FSocket.Write(ABuffer, ACount);
end;

function TTcpIpClientSocket.Read(var ABuffer; ACount: LongInt): LongInt;
begin
  Result := FSocket.Read(ABuffer, ACount);
end;

end.
