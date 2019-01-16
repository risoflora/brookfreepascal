program demo;

{$mode objfpc}{$H+}

uses
  ConvUtils;

begin
  WriteLn('30 Celsius to Fahrenheit: ', CelsiusToFahrenheit(30));
  WriteLn('10 cm to inch: ', CmToInch(10));
end.

