program demo;

{$mode objfpc}{$H+}

uses
  XMailer, SysUtils;

begin
  try
    SendMail('from="Your Name <test@host.com>" to=dest1@host.com;dest2@host.com ' +
      'subject="Your subject." message="Your message." user=user@host.com ' +
      'password=abc123 host=smtp.host.com:465 ssl=true tls=true');
    Write('E-mail sent successfully!');
  except
    on E: Exception do
      Write(E.Message);
  end;
end.

