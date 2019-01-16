unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, XMailer, SysUtils;

type

  { TMail }

  TMail = class(TObject)
  private
    FSendMail: TSendMail;
    FMessage: string;
    FReceiver: string;
    FSender: string;
    FSubject: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Send;
  published
    property Sender: string read FSender write FSender;
    property Receiver: string read FReceiver write FReceiver;
    property Subject: string read FSubject write FSubject;
    property Message: string read FMessage write FMessage;
  end;

  { TFormAction }

  TFormAction = class(TBrookAction)
  public
    procedure Get; override;
  end;

  { TSendAction }

  TSendAction = class(specialize TBrookGAction<TMail>)
  public
    procedure Post; override;
  end;

const
  FORM = {$i form.inc};

implementation

{ TMail }

constructor TMail.Create;
begin
  inherited Create;
  FSendMail := TSendMail.Create;
end;

destructor TMail.Destroy;
begin
  FSendMail.Free;
  inherited Destroy;
end;

procedure TMail.Send;
begin
  // Mail
  FSendMail.Sender := FSender;
  FSendMail.Receivers.Text := FReceiver;
  FSendMail.Subject := FSubject;
  FSendMail.Message.Text := FMessage;
  // SMTP
  FSendMail.Smtp.UserName := 'user@host.com';
  FSendMail.Smtp.Password := 'abc123';
  FSendMail.Smtp.Host := 'smtp.host.com';
  FSendMail.Smtp.Port := '465';
  FSendMail.Smtp.SSL := True;
  FSendMail.Smtp.TLS := True;
  FSendMail.Send;
end;

{ TFormAction }

procedure TFormAction.Get;
begin
  Write(FORM);
end;

{ TSendAction }

procedure TSendAction.Post;
begin
  Entity.Send;
  Write('E-mail sent successfully!');
end;

initialization
  TFormAction.Register('/');
  TSendAction.Register('/send');

end.
