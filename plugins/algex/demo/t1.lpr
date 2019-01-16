program t1;

{$mode objfpc}{$H+}

uses
  AlgEx;

var
  VEx: string;
  VAlgEx: TAlgEx;
begin
  VAlgEx := TAlgEx.Create;
  try
    VEx := '((17+27-52)*(-3))/2';
    VAlgEx.Calculate(VEx);
    if VAlgEx.Error = NO_ERROR then
    begin
      WriteLn('Expression: ', VEx);
      WriteLn('RPN: ', VAlgEx.RPN);
      WriteLn('Result: ', VAlgEx.Result);
    end
    else
      Write('ERROR: ', VAlgEx.ErrorStr);
  finally
    VAlgEx.Free;
  end;
end.

