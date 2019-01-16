(*
  Brook framework, Static File Broker

  Copyright (C) 2014 Mario Ray Mahardhika

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit BrookStaticFileBroker;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, BrookUtils;

{ This is the only thing that user may know from this unit. }
procedure BrookStaticFileRegisterDirectory(ARequestPath, ADirectory: string);

implementation

uses
  StrUtils, 
  {$if fpc_fullversion >= 20701}
  ghashmap
  {$else fpc_fullversion >= 20701}
  fgl
  {$endif fpc_fullversion >= 20701}
  ,fpmimetypes, HTTPDefs, BrookAction;

resourcestring
  SEmptyRequestPathErrMsg = 'Request path may not be empty.';
  SRequestPathAlreadyRegisteredErrMsg = 'Request path "%s" already registered.';
  SDirectoryNotExistErrMsg = 'Directory not exists: %s.';

type

  {$if fpc_fullversion >= 20701}
  { TStringHash }

  TStringHash = class
    class function Hash(S: string; N: Integer): Integer;
  end;

  TRequestDirectoryMap = specialize THashmap<string, string, TStringHash>;
  
  {$else fpc_fullversion >= 20701}
  
  TStrMap = specialize TFPGMap<string, string>;
  
  TRequestDirectoryMap = class(TStrMap)
  public
    function Contains(const s: String): Boolean;
  end;
  
  {$endif fpc_fullversion >= 20701}

  { TStaticFileAction }

  TStaticFileAction = class(TBrookAction)
  public
    procedure Get; override;
  end;

var
  RequestDirectoryMap: TRequestDirectoryMap;

{$IFNDEF VER3_0}
 {$PUSH}{$WARN 6058 OFF}
{$ENDIF}

{$if fpc_fullversion >= 20701}

{ TStringHash }

class function TStringHash.Hash(S: String; N: Integer): Integer;
var
  C: Char;
begin
  Result := 0;
  for C in LowerCase(S) do
    Inc(Result, Ord(C));
  Result := Result mod N;
end;

{$else fpc_fullversion >= 20701}

function TRequestDirectoryMap.Contains(const s: String): Boolean;
var
  dummy: Integer;
begin
  Result := inherited Find(s,dummy);
end;

{$endif fpc_fullversion >= 20701}

{ TStaticFileAction }

procedure TStaticFileAction.Get;
var
  VLastSlashPos: Integer;
  VPathInfo, VFilePath, VBuffer, VContentType: string;
begin
  VBuffer := '';
  VPathInfo := HttpRequest.PathInfo;
  VLastSlashPos := RPos('/', VPathInfo);
  System.Delete(VPathInfo, VLastSlashPos + 1, Length(VPathInfo) - VLastSlashPos);
  VFilePath := RequestDirectoryMap[VPathInfo] + Variables.Values['file'];
  if FileExists(VFilePath) then
  begin
    VContentType := MimeTypes.GetMimeType(ExtractFileExt(VFilePath));
    if VContentType = '' then
      VContentType := 'application/octet-stream';
    HttpResponse.ContentType := VContentType;
    with TFileStream.Create(VFilePath, fmOpenRead) do
      try
        SetLength(VBuffer, Size);
        Read(VBuffer[1], Size);
        Self.Write(VBuffer);
      finally
        Free;
      end;
  end;
end;

procedure BrookStaticFileRegisterDirectory(ARequestPath, ADirectory: string);
begin
  if Length(ARequestPath) = 0 then
    raise Exception.Create(SEmptyRequestPathErrMsg);
  if not DirectoryExists(ADirectory) then
    raise Exception.CreateFmt(SDirectoryNotExistErrMsg, [ADirectory]);
  // add required slashes
  if ARequestPath[1] <> '/' then
    ARequestPath := '/' + ARequestPath;
  if ARequestPath[Length(ARequestPath)] <> '/' then
    ARequestPath := ARequestPath + '/';
  if RequestDirectoryMap.Contains(ARequestPath) then
    raise Exception.CreateFmt(SRequestPathAlreadyRegisteredErrMsg,[ARequestPath]);
  RequestDirectoryMap[ARequestPath] := IncludeTrailingPathDelimiter(ADirectory);
  TStaticFileAction.Register(ARequestPath + ':file', rmGet);
end;

{$IFNDEF VER3_0}
 {$POP}
{$ENDIF}

initialization
  RequestDirectoryMap := TRequestDirectoryMap.Create;

finalization
  RequestDirectoryMap.Free;

end.
