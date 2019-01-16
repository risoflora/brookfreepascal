unit Brokers;

{$mode objfpc}{$H+}

interface

uses
  BrookUtils, BrookFCLCGIBroker;

implementation

initialization
  BrookSettings.DirectoryForUploads := '/your/uploads/directory';

end.
