(*
 X-Mailer plugin.

 Copyright (C) 2013 Silvio Clecio - silvioprog@gmail.com

 Please see the LICENSE file.
*)

unit XMailer;

{$mode objfpc}{$H+}
{$DEFINE OPEN_SSL}
{$DEFINE UTF_8_MIME}

interface

uses
{$IFDEF OPEN_SSL}
  SSL_OpenSSL,
{$ENDIF}
{$IFDEF UTF_8_MIME}
  MimeInln,
{$ENDIF}
  SMTPSend, MimePart, MimeMess, SynaChar, SynaUtil, Classes, SysUtils;

type
  TContentType = (ctTextPlain, ctTextHTML);

  EMailer = class(Exception);

  TMailerProgress = procedure(const AProgress, AMax: Integer;
    const AStatus: string) of object;

  { TMimeMessEx }

  TMimeMessEx = class(TMimeMess)
  public
    function AddPartText(const AValue: TStrings;
      const APartParent: TMimePart): TMimepart;
    function AddPartHTML(const AValue: TStrings;
      const APartParent: TMimePart): TMimepart;
  end;

  { TSmtp }

  TSmtp = class(TSMTPSend)
  private
    function GetHost: string;
    function GetPort: string;
    function GetSSL: Boolean;
    function GetTLS: Boolean;
    procedure SetHost(AValue: string);
    procedure SetPort(AValue: string);
    procedure SetSSL(AValue: Boolean);
    procedure SetTLS(AValue: Boolean);
  public
    property Host: string read GetHost write SetHost;
    property Port: string read GetPort write SetPort;
    property SSL: Boolean read GetSSL write SetSSL;
    property TLS: Boolean read GetTLS write SetTLS;
  end;

  { TSendMail }

  TSendMail = class
  private
    FAttachments: TStrings;
    FAttempts: Byte;
    FBCC: TStrings;
    FCC: TStrings;
    FHeader: TStrings;
    FOnProgress: TMailerProgress;
    FReadingConfirmation: Boolean;
    FMessage: TStrings;
    FContentType: TContentType;
    FPriority: TMessPriority;
    FReceivers: TStrings;
    FSender: string;
    FSmtp: TSmtp;
    FSubject: string;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Send; virtual;
    procedure Error(const AMsg: string);
    procedure Progress(const APosition, AMax: Integer;
      const AStatus: string); virtual;
    property Smtp: TSmtp read FSmtp;
    property Attempts: Byte read FAttempts write FAttempts;
    property Sender: string read FSender write FSender;
    property Receivers: TStrings read FReceivers;
    property CC: TStrings read FCC;
    property BCC: TStrings read FBCC;
    property Subject: string read FSubject write FSubject;
    property Header: TStrings read FHeader;
    property Message: TStrings read FMessage;
    property Attachments: TStrings read FAttachments;
    property Priority: TMessPriority read FPriority write FPriority;
    property ReadingConfirmation: Boolean read FReadingConfirmation
      write FReadingConfirmation;
    property ContentType: TContentType read FContentType write FContentType;
    property OnProgress: TMailerProgress read FOnProgress write FOnProgress;
  end;

{$IFDEF OPEN_SSL}
function IsAvailableOpenSSL: Boolean;
{$ENDIF}
procedure SendMail(
  // Smtp params
  const AHost, AUser, APassword: string; const ASSL, ATLS: Boolean;
  // Mail params
  const ASender, AReceivers, ASubject, AMessage: string; const ACC: string = '';
  const ABCC: string = ''; const AAttachments: string = '';
  const APriority: TMessPriority = MP_unknown;
  const AReadingConfirmation: Boolean = False;
  const AContentType: TContentType = ctTextPlain;
  AProgress: TMailerProgress = nil);
procedure SendMail(const S: string; AArgs: array of const;
  const AQuoteChar: Char = '"'; AProgress: TMailerProgress = nil);
procedure SendMail(const AParams: string; const AQuoteChar: Char = '"';
  AProgress: TMailerProgress = nil);
procedure FormatEmailAddress(const S: string; out AAddr, ADesc: string);
function DequotedStr(const S: string; AQuoteChar: Char): string;
{$IFDEF UTF_8_MIME}
function UTF8InlineEncodeEmail(const AAddr, ADesc: string): string;
function UTF8InlineEncodeEmail(const AEmail: string): string;
function UTF8InlineEncode(const S: string): string;
{$ENDIF}

implementation

{$IFDEF OPEN_SSL}
function IsAvailableOpenSSL: Boolean;
var
  VOpenSSL: TSSLOpenSSL;
begin
  VOpenSSL := TSSLOpenSSL.Create(nil);
  try
    Result := VOpenSSL.LibVersion <> '';
  finally
    VOpenSSL.Free;
  end;
end;
{$ENDIF}

procedure SendMail(
  const AHost, AUser, APassword: string; const ASSL, ATLS: Boolean;
  const ASender, AReceivers, ASubject, AMessage: string;
  const ACC: string; const ABCC: string; const AAttachments: string;
  const APriority: TMessPriority; const AReadingConfirmation: Boolean;
  const AContentType: TContentType; AProgress: TMailerProgress);
begin
  with TSendMail.Create do
  try
    FOnProgress := AProgress;
    // Smtp properties
    Smtp.Host := AHost;
    Smtp.UserName := AUser;
    Smtp.Password := APassword;
    Smtp.TLS := ATLS;
    Smtp.SSL := ASSL;
    // Mail properties
    Sender := ASender;
    Receivers.DelimitedText := AReceivers;
    Subject := ASubject;
    Message.Text := AMessage;
    CC.DelimitedText := ACC;
    BCC.DelimitedText := ABCC;
    Attachments.DelimitedText := AAttachments;
    Priority := APriority;
    ReadingConfirmation := AReadingConfirmation;
    ContentType := AContentType;
    Send;
  finally
    Free;
  end;
end;

procedure SendMail(const S: string; AArgs: array of const;
  const AQuoteChar: Char; AProgress: TMailerProgress);
begin
  SendMail(Format(S, AArgs), AQuoteChar, AProgress);
end;

procedure SendMail(const AParams: string; const AQuoteChar: Char;
  AProgress: TMailerProgress);
var
  S: TStrings;
begin
  S := TStringList.Create;
  try
    ExtractStrings([' '], [], PChar(AParams), S);
    with TSendMail.Create do
    begin
      FOnProgress := AProgress;
      // Smtp properties
      Smtp.Host := S.Values['host'];
      Smtp.UserName := S.Values['user'];
      Smtp.Password := S.Values['password'];
      Smtp.TLS := StrToBoolDef(S.Values['tls'], False);
      Smtp.SSL := StrToBoolDef(S.Values['ssl'], False);
      // Mail properties
      Sender := DequotedStr(S.Values['from'], AQuoteChar);
      Receivers.DelimitedText := DequotedStr(S.Values['to'], AQuoteChar);
      Subject := DequotedStr(S.Values['subject'], AQuoteChar);
      Message.Text := DequotedStr(S.Values['message'], AQuoteChar);
      CC.DelimitedText := DequotedStr(S.Values['cc'], AQuoteChar);
      BCC.DelimitedText := DequotedStr(S.Values['bcc'], AQuoteChar);
      Attachments.DelimitedText :=
        DequotedStr(S.Values['attachments'], AQuoteChar);
      case S.Values['priority'] of
        'unknown': Priority := MP_unknown;
        'low': Priority := MP_low;
        'normal': Priority := MP_normal;
        'high': Priority := MP_high;
      end;
      ReadingConfirmation := StrToBoolDef(S.Values['readingconfirmation'], False);
      case S.Values['contenttype'] of
        'plain': ContentType := ctTextPlain;
        'html': ContentType := ctTextHTML;
      end;
      Send;
    end;
  finally
    S.Free;
  end;
end;

procedure FormatEmailAddress(const S: string; out AAddr, ADesc: string);
begin
  AAddr := GetEmailAddr(S);
  ADesc := GetEmailDesc(S);
end;

function DequotedStr(const S: string; AQuoteChar: Char): string;
var
  L: SizeInt;
begin
  Result := S;
  L := Length(S);
  if L = 0 then
    Exit;
  if Copy(Result, 1, 1) = AQuoteChar then
    Delete(Result, 1, 1);
  if Copy(S, L, 1) = AQuoteChar then
    Delete(Result, L - 1, 1);
end;

{$IFDEF UTF_8_MIME}
function UTF8InlineEncodeEmail(const AAddr, ADesc: string): string;
begin
  if ADesc <> '' then
    Result := UTF8InlineEncode(ADesc) + ' <' + AAddr + '>'
  else
    Result := AAddr;
end;

function UTF8InlineEncodeEmail(const AEmail: string): string;
var
  VAddr, VDesc: string;
begin
  VAddr := GetEmailAddr(AEmail);
  VDesc := GetEmailDesc(AEmail);
  if VDesc <> '' then
    Result := UTF8InlineEncode(VDesc) + ' <' + VAddr + '>'
  else
    Result := VAddr;
end;

function UTF8InlineEncode(const S: string): string;
begin
  if NeedInline(S) then
    Result := InlineEncode(S, UTF_8, UTF_8)
  else
    Result := S;
end;
{$ENDIF}

{ TSmtp }

function TSmtp.GetHost: string;
begin
  Result := TargetHost;
end;

function TSmtp.GetPort: string;
begin
  Result := TargetPort;
end;

function TSmtp.GetSSL: Boolean;
begin
  Result := FullSSL;
end;

function TSmtp.GetTLS: Boolean;
begin
  Result := AutoTLS;
end;

procedure TSmtp.SetHost(AValue: string);
var
  S: string;
begin
  if Pos(':', AValue) = 0 then
    TargetHost := AValue
  else
  begin
    TargetHost := Trim(SeparateLeft(AValue, ':'));
    S := Trim(SeparateRight(AValue, ':'));
    if (S <> '') and (S <> AValue) then
      TargetPort := S;
  end;
end;

procedure TSmtp.SetPort(AValue: string);
begin
  TargetPort := AValue;
end;

procedure TSmtp.SetSSL(AValue: Boolean);
begin
  FullSSL := AValue;
end;

procedure TSmtp.SetTLS(AValue: Boolean);
begin
  AutoTLS := AValue;
end;

{ TMimeMessEx }

function TMimeMessEx.AddPartText(const AValue: TStrings;
  const APartParent: TMimePart): TMimepart;
begin
  Result := AddPart(APartParent);
  with Result do
  begin
    AValue.SaveToStream(DecodedLines);
    Primary := 'text';
    Secondary := 'plain';
    Description := 'Message text';
    CharsetCode := UTF_8;
    EncodingCode := ME_8BIT;
    TargetCharset := UTF_8;
    ConvertCharset := True;
    EncodePart;
    EncodePartHeader;
  end;
end;

function TMimeMessEx.AddPartHTML(const AValue: TStrings;
  const APartParent: TMimePart): TMimepart;
begin
  Result := AddPart(APartParent);
  with Result do
  begin
    AValue.SaveToStream(DecodedLines);
    Primary := 'text';
    Secondary := 'html';
    Description := 'HTML text';
    CharsetCode := UTF_8;
    EncodingCode := ME_8BIT;
    TargetCharset := UTF_8;
    ConvertCharset := True;
    EncodePart;
    EncodePartHeader;
  end;
end;

{ TSendMail }

constructor TSendMail.Create;
begin
  inherited Create;
  FSmtp := TSmtp.Create;
  FReceivers := TStringList.Create;
  FCC := TStringList.Create;
  FBCC := TStringList.Create;
  FHeader := TStringList.Create;
  FMessage := TStringList.Create;
  FAttachments := TStringList.Create;
  FReceivers.StrictDelimiter := True;
  FAttempts := 3;
  FReceivers.Delimiter := ';';
  FCC.StrictDelimiter := True;
  FCC.Delimiter := ';';
  FBCC.StrictDelimiter := True;
  FBCC.Delimiter := ';';
  FAttachments.StrictDelimiter := True;
  FAttachments.Delimiter := ';';
  FPriority := MP_unknown;
end;

destructor TSendMail.Destroy;
begin
  FReceivers.Free;
  FCC.Free;
  FBCC.Free;
  FHeader.Free;
  FMessage.Free;
  FAttachments.Free;
  FSmtp.Free;
  inherited Destroy;
end;

procedure TSendMail.Send;
var
  VAttempts: Byte;
  VMimePart: TMimePart;
  I, C, VPMax, VPPos: Integer;
  VSenderAddr{$IFDEF UTF_8_MIME}, VTo, VCC, VSenderDesc{$ENDIF}: string;
  VMimeMess:{$IFDEF UTF_8_MIME}TMimeMessEx{$ELSE}TMimeMess{$ENDIF};

  procedure _SetReadingConfirmation(const A: string);
  begin
    if FReadingConfirmation then
      VMimeMess.Header.CustomHeaders.Insert(0,
        'Disposition-Notification-To: ' + A);
  end;

begin
{$IFDEF OPEN_SSL}
  if not IsAvailableOpenSSL then
    raise Exception.CreateFmt('%: SSL error: %s',
      [Self.ClassName, 'Could not found the SSL library.']);
{$ENDIF}
  VPMax := 10;
  VPPos := 0;
  Inc(VPPos);
  Progress(VPPos, VPMax, 'Starting ...');
  VMimeMess :={$IFDEF UTF_8_MIME}TMimeMessEx{$ELSE}TMimeMess{$ENDIF}.Create;
  try
    case FContentType of
      ctTextPlain:
      begin
        if FAttachments.Count > 0 then
          VMimePart := VMimeMess.AddPartMultipart('mixed', nil);
        if FMessage.Count > 0 then
        begin
          if FAttachments.Count > 0 then
            VMimeMess.AddPartText(FMessage, VMimePart)
          else
            VMimePart := VMimeMess.AddPartText(FMessage, nil);
        end;
        for I := 0 to Pred(FAttachments.Count) do
          VMimeMess.AddPartBinaryFromFile(FAttachments.Strings[I], VMimePart);
      end;
      ctTextHTML:
      begin
        if FAttachments.Count > 0 then
          VMimePart := VMimeMess.AddPartMultipart('related', nil);
        if FMessage.Count > 0 then
        begin
          if FAttachments.Count > 0 then
            VMimeMess.AddPartHTML(FMessage, VMimePart)
          else
            VMimePart := VMimeMess.AddPartHTML(FMessage, nil);
        end;
        for I := 0 to Pred(FAttachments.Count) do
          VMimeMess.AddPartHTMLBinaryFromFile(FAttachments.Strings[I],
            '<' + ExtractFileName(FAttachments.Strings[I]) + '>', VMimePart);
      end;
    end;
    Inc(VPPos);
    Progress(VPPos, VPMax, 'Formating headers ...');
{$IFDEF UTF_8_MIME}
    VMimeMess.Header.CharsetCode := UTF_8;
    VMimeMess.Header.CustomHeaders.Assign(FHeader);
    VMimeMess.Header.CustomHeaders.Insert(0, 'Subject: ' +
      UTF8InlineEncode(FSubject));
    FormatEmailAddress(FSender, VSenderAddr, VSenderDesc);
    if FReadingConfirmation then
      _SetReadingConfirmation(VSenderAddr);
{$ELSE}
    VMimeMess.Header.Subject := FSubject;
    VMimeMess.Header.From := FSender;
    VSenderAddr := GetEmailAddr(FSender);
    VMimeMess.Header.ToList.AddStrings(FReceivers);
    VMimeMess.Header.CCList.AddStrings(FCC);
    if FReadingConfirmation then
      _SetReadingConfirmation(VSenderAddr);
{$ENDIF}
    VMimeMess.Header.XMailer := 'X-Mailer plugin';
    if FPriority <> MP_unknown then
      VMimeMess.Header.Priority := FPriority;
    VMimeMess.EncodeMessage;
{$IFDEF UTF_8_MIME}
    VTo := '';
    for I := 0 to Pred(FReceivers.Count) do
      VTo += UTF8InlineEncodeEmail(FReceivers.Strings[I]) + ', ';
    VCC := '';
    for I := 0 to Pred(FCC.Count) do
      VCC := UTF8InlineEncodeEmail(FCC.Strings[I]) + ', ';
    if VTo <> '' then
    begin
      SetLength(VTo, Length(VTo) - 2);
      VMimeMess.Lines.Insert(0, 'To: ' + VTo);
    end;
    if VCC <> '' then
    begin
      SetLength(VCC, Length(VCC) - 2);
      VMimeMess.Lines.Insert(0, 'CC: ' + VCC);
    end;
    VMimeMess.Lines.Delete(VMimeMess.Lines.IndexOf('From: '));
    VMimeMess.Lines.Insert(0, 'From: ' +
      UTF8InlineEncodeEmail(VSenderAddr, VSenderDesc));
{$ENDIF}
    Inc(VPPos);
    Progress(VPPos, VPMax, 'Logging on SMTP ...');
    for VAttempts := 1 to FAttempts do
    begin
      if FSmtp.Login then
        Break;
      if VAttempts >= FAttempts then
        Error('SMTP::Login');
    end;
    Inc(VPPos);
    Progress(VPPos, VPMax, 'Sending the sender data ...');
    for VAttempts := 1 to FAttempts do
    begin
      if FSmtp.MailFrom(VSenderAddr, Length(VSenderAddr)) then
        Break;
      if VAttempts >= FAttempts then
        Error('SMTP::MailFrom');
    end;
    Inc(VPPos);
    Progress(VPPos, VPMax, 'Sending receivers data ...');
    for I := 0 to Pred(FReceivers.Count) do
      for VAttempts := 1 to FAttempts do
      begin
        if FSmtp.MailTo(GetEmailAddr(FReceivers.Strings[I]))then
          Break;
        if VAttempts >= FAttempts then
          Error('SMTP::MailTo');
      end;
    Inc(VPPos);
    C := FCC.Count;
    if C > 0 then
      Progress(VPPos, VPMax, 'Sending CCs data ...');
    for I := 0 to Pred(C) do
      for VAttempts := 1 to FAttempts do
      begin
        if FSmtp.MailTo(GetEmailAddr(FCC.Strings[I])) then
          Break;
        if VAttempts >= FAttempts then
          Error('SMTP::MailCC');
      end;
    Inc(VPPos);
    C := FBCC.Count;
    if C > 0 then
      Progress(VPPos, VPMax, 'Sending BCCs data ...');
    for I := 0 to Pred(C) do
      for VAttempts := 1 to FAttempts do
      begin
        if FSmtp.MailTo(GetEmailAddr(FBCC.Strings[I])) then
          Break;
        if VAttempts >= FAttempts then
          Error('SMTP::MailBCC');
      end;
    Inc(VPPos);
    Progress(VPPos, VPMax, 'Sending the message data ...');
    for VAttempts := 1 to FAttempts do
    begin
      if FSmtp.MailData(VMimeMess.Lines) then
        Break;
      if VAttempts >= FAttempts then
        Error('SMTP::MailData');
    end;
    Inc(VPPos);
    Progress(VPPos, VPMax, 'Exiting from SMTP ...');
    for VAttempts := 1 to FAttempts do
    begin
      if FSmtp.Logout then
        Break;
      if VAttempts >= FAttempts then
        Error('SMTP::Logout');
    end;
    Inc(VPPos);
    Progress(VPPos, VPMax, 'Done.');
  finally
    VMimeMess.Free;
  end;
end;

procedure TSendMail.Error(const AMsg: string);
begin
  raise EMailer.CreateFmt('%s: SMTP error: %s' + LineEnding + '%s%s',
    [Self.ClassName, AMsg, FSmtp.EnhCodeString, FSmtp.FullResult.Text]);
end;

procedure TSendMail.Progress(const APosition, AMax: Integer;
  const AStatus: string);
begin
  if Assigned(FOnProgress) then
    FOnProgress(APosition, AMax, AStatus);
end;

end.
