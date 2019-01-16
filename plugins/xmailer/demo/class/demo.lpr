program demo;

{$mode objfpc}{$H+}

uses
  XMailer, SysUtils;

var
  Mail: TSendMail;
begin
  Mail := TSendMail.Create;
  try
    try
      // Mail
      Mail.Sender := 'Your Name <test@host.com>';
      Mail.Receivers.Add('dest1@host.com');
      Mail.Receivers.Add('dest2@host.com');
      Mail.Subject := 'Your subject.';
      Mail.Message.Add('Your message.');
      // SMTP
      Mail.Smtp.UserName := 'user@host.com';
      Mail.Smtp.Password := 'abc123';
      Mail.Smtp.Host := 'smtp.host.com';
      Mail.Smtp.Port := '465';
      Mail.Smtp.SSL := True;
      Mail.Smtp.TLS := True;
      Mail.Send;
      Write('E-mail sent successfully!');
    except
      on E: Exception do
        Write(E.Message);
    end;
  finally
    Mail.Free;
  end;
end.

