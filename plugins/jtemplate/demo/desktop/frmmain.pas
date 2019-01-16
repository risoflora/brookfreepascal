unit frmmain;

{$mode objfpc}{$H+}

interface

uses
  Ipfilebroker, IpHtml, Forms, StdCtrls, SysUtils, JTemplate;

type

  { TfrMain }

  TfrMain = class(TForm)
    btReplace: TButton;
    dp: TIpFileDataProvider;
    edResult: TIpHtmlPanel;
    JTemplate1: TJTemplate;
    edLog: TMemo;
    procedure btReplaceClick(Sender: TObject);
    procedure JTemplate1LoadingFields(Sender: TObject; var AVar, AValue: string);
    procedure JTemplate1Replace(Sender: TObject);
    procedure JTemplate1Replacing(Sender: TObject; var AValue: string);
  end;

var
  frMain: TfrMain;

implementation

{$R *.lfm}

{ TfrMain }

procedure TfrMain.btReplaceClick(Sender: TObject);
begin
  JTemplate1.Fields.Strings['title'] := 'My title';
  JTemplate1.Fields.Strings['body'] := 'My body';
  JTemplate1.Replace;
end;

procedure TfrMain.JTemplate1LoadingFields(Sender: TObject; var AVar,
  AValue: string);
begin
  edLog.Lines.Add(Format('Var: %s; Value: %s', [AVar, AValue]));
end;

procedure TfrMain.JTemplate1Replace(Sender: TObject);
begin
  edResult.SetHtmlFromStr(JTemplate1.Content.Text);
  Caption := edResult.Title;
end;

procedure TfrMain.JTemplate1Replacing(Sender: TObject; var AValue: string);
var
  VValue: string;
begin
  VValue := AValue;
  AValue := '-' + AValue + '-';
  edLog.Lines.Add(Format('Old value: %s; New value: %s', [VValue, AValue]));
end;

end.

