unit Brokers;

{$mode objfpc}{$H+}

interface

uses
  BrookFCLEventLogBroker, BrookFCLCGIBroker, BrookUtils;

implementation

initialization
  BrookSettings.LogActive := True;
  BrookSettings.LogFile := 'MYAPP.LOG';

end.
