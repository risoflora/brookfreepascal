unit testbrooklogger;

{$mode objfpc}{$H+}

interface

uses
  BrookLogger, BrookClasses, fpcunit, testregistry, Classes, sysutils;

type

  { TLog }

  TLog = class
  private
    FLogFile: TStrings;
    FLogInFile: Boolean;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure Log(const S: string);
    property LogFile: TStrings read FLogFile;
    property LogInFile: Boolean read FLogInFile write FLogInFile;
  end;

  { TBrokerLog }

  TBrokerLog = class(TBrookInterfacedObject, IBrookLogger)
  private
    FLog: TLog;
    FOutput: TBrookLogOutput;
    procedure SetOutput(const AValue: TBrookLogOutput);
    function GetOutput: TBrookLogOutput;
  public
    constructor Create;
    destructor Destroy; override;
    function Instance: TObject;
    procedure Custom(const S: string; const ACode: Word);
    procedure Info(const S: string);
    procedure Warn(const S: string);
    procedure Debug(const S: string);
    procedure Error(const S: string; E: Exception = nil);
    property Output: TBrookLogOutput read GetOutput write SetOutput;
  end;

  { TTestBrookLogger }

  TTestBrookLogger = class(TTestCase)
  published
    procedure TestCustom;
    procedure TestInfo;
    procedure TestWarn;
    procedure TestDebug;
    procedure TestError;
    procedure TestOutput;
  end;

implementation

{ TLog }

constructor TLog.Create;
begin
  inherited Create;
  FLogFile := TStringList.Create;
end;

destructor TLog.Destroy;
begin
  FLogFile.Free;
  inherited Destroy;
end;

procedure TLog.Log(const S: string);
begin
  if FLogInFile then
    FLogFile.Add(S);
end;

{ TBrokerLog }

constructor TBrokerLog.Create;
begin
  inherited Create;
  FLog := TLog.Create;
  Output := loSystem;
  SetOutput(loFile);
end;

destructor TBrokerLog.Destroy;
begin
  FLog.Free;
  inherited Destroy;
end;

function TBrokerLog.Instance: TObject;
begin
  Result := FLog;
end;

procedure TBrokerLog.SetOutput(const AValue: TBrookLogOutput);
begin
  FOutput := AValue;
  FLog.LogInFile := AValue = loFile;
end;

function TBrokerLog.GetOutput: TBrookLogOutput;
begin
  Result := FOutput;
end;

procedure TBrokerLog.Custom(const S: string; const ACode: Word);
begin
  FLog.Log(Format('Custom(%d)=%s', [ACode, S]));
end;

procedure TBrokerLog.Info(const S: string);
begin
  FLog.Log('Info=' + S);
end;

procedure TBrokerLog.Warn(const S: string);
begin
  FLog.Log('Warn=' + S);
end;

procedure TBrokerLog.Debug(const S: string);
begin
  FLog.Log('Debug=' + S);
end;

procedure TBrokerLog.Error(const S: string; E: Exception);
begin
  FLog.Log('Error=' + S + ': ' + E.Message);
end;

{ TTestBrookLogger }

procedure TTestBrookLogger.TestCustom;
begin
  BrookLog.Custom('Custom log', 1001);
  AssertEquals(TLog(BrookLog.Instance).LogFile.Values['Custom(1001)'],
    'Custom log');
end;

procedure TTestBrookLogger.TestInfo;
begin
  BrookLog.Info('Info log');
  AssertEquals(TLog(BrookLog.Instance).LogFile.Values['Info'], 'Info log');
end;

procedure TTestBrookLogger.TestWarn;
begin
  BrookLog.Warn('Warn log');
  AssertEquals(TLog(BrookLog.Instance).LogFile.Values['Warn'], 'Warn log');
end;

procedure TTestBrookLogger.TestDebug;
begin
  BrookLog.Debug('Debug log');
  AssertEquals(TLog(BrookLog.Instance).LogFile.Values['Debug'], 'Debug log');
end;

procedure TTestBrookLogger.TestError;
var
  e: Exception;
begin
  e := Exception.Create('Error');
  try
    BrookLog.Error('Error log', e);
    AssertEquals(TLog(BrookLog.Instance).LogFile.Values['Error'],
      'Error log: Error');
  finally
    e.Free;
  end;
end;

procedure TTestBrookLogger.TestOutput;
begin
  AssertTrue(BrookLog.Output = loFile);
end;

initialization
  BrookRegisterLog(TBrokerLog.Create);
  RegisterTest(TTestBrookLogger);

end.

