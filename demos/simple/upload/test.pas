unit Test;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, BrookHttpDefs, BrookConsts, BrookUtils, SysUtils;

type
  TTest = class(TBrookAction)
  public
    procedure Get; override;
    procedure Post; override;
  end;

const
  RESULT =
    'All files:' + BR + LF + '%s' + BR + BR + LF +
    'All files saved in:' + BR + LF + '%s';

implementation

procedure TTest.Get;
begin
  Write({$i head.inc}, [{$i form.inc}]);
end;

procedure TTest.Post;
var
  I: Integer;
  VFiles, VSep: string;
  VFormItem: TBrookUploadedFile;
begin
  VFiles := '';
  VSep := '||';
  for I := 0 to Pred(Files.Count) do
  begin
    VFormItem := Files[I];
    if VFormItem.FileName <> '' then
      VFiles += VFormItem.FileName + VSep;
  end;
  Write({$i head.inc},
    [Format(RESULT, [VFiles, BrookSettings.DirectoryForUploads])]);
end;

initialization
  TTest.Register('*');

end.
