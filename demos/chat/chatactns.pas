unit chatactns;

{$mode objfpc}{$H+}

interface

uses
  BrookUtils, authactns, RUtils, SysUtils;

type

  { TChatMsg }

  TChatMsg = class(TAuth)
  public
    procedure Get; override;
  end;

  { TChatGetMsg }

  TChatGetMsg = class(TChatMsg)
  public
    procedure Get; override;
  end;

  { TChatPostMsg }

  TChatPostMsg = class(TChatMsg)
  public
    procedure Post; override;
  end;

implementation

{ TChatMsg }

procedure TChatMsg.Get;
begin
  Write(Log.Text);
end;

{ TChatGetMsg }

procedure TChatGetMsg.Get;
begin
  Render('chat.html', [Session.Fields.Values['name'], Text]);
end;

{ TChatPostMsg }

procedure TChatPostMsg.Post;
const
  MSG = '<div class="msgln">(%s) <b>%s</b>: %s<br></div>';
begin
  Add(MSG, [FormatDateTime('yyyy-mm-dd', Now),
    StripHTMLMarkup(Session.Fields.Values['name']),
    StripHTMLMarkup(Fields.Values['text'])]);
  Save;
end;

initialization
  TChatMsg.Register('/msg', rmGet);
  TChatGetMsg.Register('/msg/get', rmGet);
  TChatPostMsg.Register('/msg/post', rmPost);

end.
