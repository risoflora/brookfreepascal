(*
  Useful classes for TCP/IP communication.
  Copyright (c) 2013 by Silvio Clecio, Gilson Nunes Rodrigues and Waldir Paim

  See the file COPYING.FPC, included in this distribution,
  for details about the copyright.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit TcpIpUtils;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

const
  TCP_IP_INFINITE_TIMEOUT = $FFFFFFFFFFFFFFFF;
  TCP_IP_DEFAULT_TIMEOUT = $3E8;

type
  ETcpIpError = class(Exception);

implementation

end.

