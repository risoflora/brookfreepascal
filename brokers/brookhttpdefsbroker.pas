(*
  Brook framework, FCL HttpDefs Broker

  Copyright (C) 2014 Yuriy Pilgun

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookHttpDefsBroker;

{$mode objfpc}{$H+}

interface

uses
  BrookConsts, BrookHttpConsts, BrookException, BrookUtils, HttpDefs, CustWeb,
  Classes, SysUtils, StrUtils;

function BrookFormatContentType: string;
procedure BrookShowRequestException(AHandler: TWebHandler;
  R: TResponse; E: Exception);

implementation

function BrookFormatContentType: string;
begin
  if BrookSettings.Charset <> ES then
    Result := BrookSettings.ContentType + BROOK_HTTP_HEADER_CHARSET +
      BrookSettings.Charset
  else
    Result := BrookSettings.ContentType;
end;

procedure BrookShowRequestException(AHandler: TWebHandler;
  R: TResponse; E: Exception);
var
  VHandled: Boolean = False;

  procedure HandleHttp404;
  begin
    if not R.HeadersSent then
    begin
      R.Code := BROOK_HTTP_STATUS_CODE_NOT_FOUND;
      R.CodeText := BROOK_HTTP_REASON_PHRASE_NOT_FOUND;
      R.ContentType := BrookFormatContentType;
    end;
    if (BrookSettings.Page404File <> ES) and
      FileExists(BrookSettings.Page404File) then
      R.Contents.LoadFromFile(BrookSettings.Page404File)
    else
      R.Content := BrookSettings.Page404;
    R.Content := StringsReplace(R.Content, ['@root', '@path'],
      [BrookSettings.RootUrl, E.Message], [rfIgnoreCase, rfReplaceAll]);
    R.SendContent;
    VHandled := True;
  end;

  procedure HandleHttp500;
  begin
    if not R.HeadersSent then
    begin
      R.Code := BROOK_HTTP_STATUS_CODE_INTERNAL_SERVER_ERROR;
      R.CodeText := BROOK_HTTP_REASON_PHRASE_INTERNAL_SERVER_ERROR;
      R.ContentType := BrookFormatContentType;
    end;
    if (BrookSettings.Page500File <> ES) and
      FileExists(BrookSettings.Page500File) then
    begin
      R.Contents.LoadFromFile(BrookSettings.Page500File);
      R.Content := StringReplace(R.Content, '@error', E.Message,
        [rfIgnoreCase, rfReplaceAll]);
    end
    else
    begin
      R.Content := BrookSettings.Page500;
      R.Content := StringReplace(BrookSettings.Page500, '@error', E.Message,
        [rfIgnoreCase, rfReplaceAll]);
    end;
    R.SendContent;
    VHandled := True;
  end;

begin
  if R.ContentSent then
    Exit;
  if Assigned(BrookSettings.OnError) then
  begin
    BrookSettings.OnError(R, E, VHandled);
    if VHandled then
      Exit;
  end;
  if Assigned(AHandler.OnShowRequestException) then
  begin
    AHandler.OnShowRequestException(R, E, VHandled);
    if VHandled then
      Exit;
  end;
  if AHandler.RedirectOnError and not R.HeadersSent then
  begin
    R.SendRedirect(Format(AHandler.RedirectOnErrorURL, [HttpEncode(E.Message)]));
    R.SendContent;
    Exit;
  end;
  if E is EBrookHttp404 then
    HandleHttp404
  else
    HandleHttp500;
end;

end.
