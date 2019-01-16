unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Forms, Grids, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    btFind: TButton;
    StringGrid1: TStringGrid;
    procedure btFindClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure StringGrid1Selection(Sender: TObject; aCol, aRow: Integer);
  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses
  LJGridUtils;

{ TForm1 }

procedure TForm1.Button2Click(Sender: TObject);
begin
  ClearGrid(StringGrid1);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  LoadJSON(StringGrid1, 'data.json');
end;

procedure TForm1.btFindClick(Sender: TObject);
begin
  FindItem(StringGrid1, 'souza');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Button2Click(Sender);
end;

procedure TForm1.StringGrid1Selection(Sender: TObject; aCol, aRow: Integer);
begin
  Caption := GetSelectedRow(StringGrid1).AsJSON;
end;

end.

