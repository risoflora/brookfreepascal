program gui;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, alltestsrt;

begin
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

