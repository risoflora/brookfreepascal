(*
  Duall Sistemas, Object Persistence Classes

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit dOpf;

{$i dopf.inc}

interface

uses
  dClasses, dSqlBuilder, dUtils, Classes, SysUtils, DB, FGL;

type
  EdNotImplemented = class(EdException);

  EdConnection = class(EdException);

  EdQuery = class(EdException);

  EdOpf = class(EdException);

  TdOpfUpdateKind = (ukAdd, ukModify, ukRemove);

  TdLogType = (ltTransaction, ltSQL, ltConnection, ltErrors, ltCustom);

  TdLogFilter = set of TdLogType;

  TdLoggingEvent = procedure(const AType: TdLogType; const AMsg: string) of object;

  { TdLogger }

  TdLogger = class(TdObject)
  private
    FActive: Boolean;
    FDirectory: string;
    FFileName: TFileName;
    FFilter: TdLogFilter;
    FOnLogging: TdLoggingEvent;
    FOverwrite: Boolean;
    FStream: TFileStream;
    procedure SetActive(AValue: Boolean);
    procedure SetFileName(AValue: TFileName);
  protected
    property Stream: TFileStream read FStream write FStream;
  public
    constructor Create(const AFileName: TFileName); overload; virtual;
    destructor Destroy; override;
    procedure Log(const AType: TdLogType; AMsg: string);
    procedure LogFmt(const AType: TdLogType; const AMsg: string;
      const AArgs: array of const);
  published
    property Active: Boolean read FActive write SetActive;
    property Directory: string read FDirectory write FDirectory;
    property Filter: TdLogFilter read FFilter write FFilter;
    property FileName: TFileName read FFileName write SetFileName;
    property Overwrite: Boolean read FOverwrite write FOverwrite;
    property OnLogging: TdLoggingEvent read FOnLogging write FOnLogging;
  end;

  { TdConnectionBroker }

  TdConnectionBroker = class(TdObject)
  protected
    function GetConnection: TObject; virtual;
    function GetTransaction: TObject; virtual;
    function GetConnected: Boolean; virtual;
    function GetDatabase: string; virtual;
    function GetDriver: string; virtual;
    function GetHost: string; virtual;
    function GetPassword: string; virtual;
    function GetPort: Integer; virtual;
    function GetUser: string; virtual;
    function GetConnectorType: string; virtual;
    procedure SetConnected(const AValue: Boolean); virtual;
    procedure SetDatabase(const AValue: string); virtual;
    procedure SetDriver(const AValue: string); virtual;
    procedure SetHost(const AValue: string); virtual;
    procedure SetPassword(const AValue: string); virtual;
    procedure SetPort(const AValue: Integer); virtual;
    procedure SetUser(const AValue: string); virtual;
    procedure SetConnectorType(const AValue: string); virtual;
  public
    constructor Create; virtual;
    procedure Connect; virtual;
    procedure Disconnect; virtual;
    procedure StartTransaction; virtual;
    procedure Commit; virtual;
    procedure CommitRetaining; virtual;
    procedure Rollback; virtual;
    procedure RollbackRetaining; virtual;
    function InTransaction: Boolean; virtual;
    property Connection: TObject read GetConnection;
    property Transaction: TObject read GetTransaction;
    property Connected: Boolean read GetConnected write SetConnected;
  published
    property Driver: string read GetDriver write SetDriver;
    property Database: string read GetDatabase write SetDatabase;
    property User: string read GetUser write SetUser;
    property Password: string read GetPassword write SetPassword;
    property Host: string read GetHost write SetHost;
    property Port: Integer read GetPort write SetPort;
    property ConnectorType: string read GetConnectorType write SetConnectorType;
  end;

  { TdGConnection }

  generic TdGConnection<T1, T2> = class(TdComponent)
  private
    FBroker: T1;
    FLogger: T2;
    function GetConnected: Boolean;
    function GetDatabase: string;
    function GetDriver: string;
    function GetHost: string;
    function GetPassword: string;
    function GetPort: Integer;
    function GetUser: string;
    function GetConnectorType: string;
    procedure SetConnected(const AValue: Boolean);
    procedure SetDatabase(const AValue: string);
    procedure SetDriver(const AValue: string);
    procedure SetHost(const AValue: string);
    procedure SetPassword(const AValue: string);
    procedure SetPort(const AValue: Integer);
    procedure SetUser(const AValue: string);
    procedure SetConnectorType(const AValue: string);
  protected
    procedure CheckBrokerClass; virtual;
    procedure CheckBroker; virtual;
    procedure CheckLoggerClass; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Connect;
    procedure Disconnect;
    procedure StartTransaction;
    procedure Commit;
    procedure CommitRetaining;
    procedure Rollback;
    procedure RollbackRetaining;
    function InTransaction: Boolean;
    property Broker: T1 read FBroker write FBroker;
    property Logger: T2 read FLogger write FLogger;
    property Connected: Boolean read GetConnected write SetConnected;
  published
    property Driver: string read GetDriver write SetDriver;
    property Database: string read GetDatabase write SetDatabase;
    property User: string read GetUser write SetUser;
    property Password: string read GetPassword write SetPassword;
    property Host: string read GetHost write SetHost;
    property Port: Integer read GetPort write SetPort;
    property ConnectorType:string read GetConnectorType write SetConnectorType;
  end;

  { TdQueryBroker }

  TdQueryBroker = class(TdObject)
  protected
    function GetActive: Boolean; virtual;
    function GetBOF: Boolean; virtual;
    function GetConnection: TObject; virtual;
    function GetDataSet: TDataSet; virtual;
    function GetDataSource: TDataSource; virtual;
    function GetEOF: Boolean; virtual;
    function GetFieldDefs: TFieldDefs; virtual;
    function GetFields: TFields; virtual;
    function GetModified: Boolean; virtual;
    function GetParams: TParams; virtual;
    function GetPosition: Int64; virtual;
    function GetSQL: TStrings; virtual;
    function GetState: TDataSetState; virtual;
    function GetNulls: Boolean; virtual;
    function GetUseUtf8: Boolean; virtual;
    procedure SetActive(const AValue: Boolean); virtual;
    procedure SetConnection(AValue: TObject); virtual;
    procedure SetDataSource(AValue: TDataSource); virtual;
    procedure SetPosition(const AValue: Int64); virtual;
    procedure SetNulls(const AValue: Boolean); virtual;
    procedure SetUseUtf8(const AValue: Boolean); virtual;
  public
    constructor Create; virtual;
    procedure ApplyUpdates; virtual;
    procedure CancelUpdates; virtual;
    procedure Apply; virtual;
    procedure ApplyRetaining; virtual;
    procedure Undo; virtual;
    procedure UndoRetaining; virtual;
    procedure Commit; virtual;
    procedure Rollback; virtual;
    procedure Append; virtual;
    procedure Insert; virtual;
    procedure Edit; virtual;
    procedure Cancel; virtual;
    procedure Delete; virtual;
    procedure Open; virtual;
    procedure Close; virtual;
    procedure Refresh; virtual;
    procedure First; virtual;
    procedure Prior; virtual;
    procedure Next; virtual;
    procedure Last; virtual;
    procedure Post; virtual;
    procedure Execute; virtual;
    function RowsAffected: Int64; virtual;
    function Locate(const AKeyFields: string;const AKeyValues: Variant;
      const AOptions: TLocateOptions = []): Boolean; virtual;
    function Param(const AName: string): TParam; virtual;
    function Field(const AName: string): TField; virtual;
    function FieldDef(const AName: string): TFieldDef; virtual;
    function Count: Int64; virtual;
    function IsEmpty: Boolean; virtual;
    function GetBookmark: TBookmark; virtual;
    procedure GotoBookmark(ABookmark: TBookmark); virtual;
    property BOF: Boolean read GetBOF;
    property EOF: Boolean read GetEOF;
    property Bookmark: TBookmark read GetBookmark write GotoBookmark;
    property Modified: Boolean read GetModified;
    property Position: Int64 read GetPosition write SetPosition;
  published
    property Active: Boolean read GetActive write SetActive;
    property SQL: TStrings read GetSQL;
    property Fields: TFields read GetFields;
    property Params: TParams read GetParams;
    property State: TDataSetState read GetState;
    property DataSet: TDataSet read GetDataSet;
    property FieldDefs: TFieldDefs read GetFieldDefs;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property Connection: TObject read GetConnection write SetConnection;
    property Nulls: Boolean read GetNulls write SetNulls;
    property UseUtf8: Boolean read GetUseUtf8 write SetUseUtf8;
  end;

  { TdGQuery }

  generic TdGQuery<T1, T2> = class(TdComponent)
  private
    FBroker: T1;
    FConnection: T2;
    function GetActive: Boolean;
    function GetBOF: Boolean;
    function GetDataSet: TDataSet;
    function GetDataSource: TDataSource;
    function GetEOF: Boolean;
    function GetFieldDefs: TFieldDefs;
    function GetFields: TFields;
    function GetModified: Boolean;
    function GetNulls: Boolean;
    function GetParams: TParams;
    function GetPosition: Int64;
    function GetSQL: TStrings;
    function GetState: TDataSetState;
    function GetUseUtf8: Boolean;
    procedure SetActive(const AValue: Boolean);
    procedure SetDataSource(AValue: TDataSource);
    procedure SetNulls(const AValue: Boolean);
    procedure SetPosition(const AValue: Int64);
    procedure SetUseUtf8(const AValue: Boolean);
  protected
    procedure CheckConnection; virtual;
    procedure CheckBrokerClass; virtual;
    procedure CheckBroker; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure GetFields(AEntity: TObject);
    procedure SetFields(AEntity: TObject);
    procedure GetParams(AEntity: TObject);
    procedure SetParams(AEntity: TObject);
    procedure ApplyUpdates;
    procedure CancelUpdates;
    procedure Apply;
    procedure ApplyRetaining;
    procedure Undo;
    procedure UndoRetaining;
    procedure Commit;
    procedure Rollback;
    procedure Append;
    procedure Insert;
    procedure Edit;
    procedure Cancel;
    procedure Delete;
    procedure Open;
    procedure Close;
    procedure Refresh;
    procedure First;
    procedure Prior;
    procedure Next;
    procedure Last;
    procedure Post;
    procedure Execute;
    function RowsAffected: Int64;
    function Locate(const AKeyFields: string;const AKeyValues: Variant;
      const AOptions: TLocateOptions = []): Boolean;
    function Param(const AName: string): TParam;
    function Field(const AName: string): TField;
    function FieldDef(const AName: string): TFieldDef;
    function Count: Int64;
    function IsEmpty: Boolean;
    function GetBookmark: TBookmark;
    procedure GotoBookmark(ABookmark: TBookmark);
    procedure AddSql(const ASql: string);
    property Connection: T2 read FConnection write FConnection;
    property Broker: T1 read FBroker write FBroker;
    property Nulls: Boolean read GetNulls write SetNulls;
    property SQL: TStrings read GetSQL;
    property Fields: TFields read GetFields;
    property FieldDefs: TFieldDefs read GetFieldDefs;
    property Params: TParams read GetParams;
    property BOF: Boolean read GetBOF;
    property EOF: Boolean read GetEOF;
    property Bookmark: TBookmark read GetBookmark write GotoBookmark;
    property Modified: Boolean read GetModified;
    property State: TDataSetState read GetState;
    property Active: Boolean read GetActive write SetActive;
    property DataSet: TDataSet read GetDataSet;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property Position: Int64 read GetPosition write SetPosition;
    property UseUtf8: Boolean read GetUseUtf8 write SetUseUtf8;
  end;

  { TdGEntityQuery }

  generic TdGEntityQuery<T1, T2, T3> = class(specialize TdGQuery<T1, T2>)
  private
    FEntity: T3;
  protected
    function CreateEntity: T3; virtual;
    procedure FreeEntity; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure GetFields;
    procedure SetFields;
    procedure GetParams;
    procedure SetParams;
    property Entity: T3 read FEntity write FEntity;
  end;

  { TdGOpf }

  generic TdGOpf<T1, T2, T3> = class(TdComponent)
  public type
    TTable = specialize TdGTable<T3>;
    TSelectBuilder = specialize TdGSelectBuilder<TTable>;
    TInsertBuilder = specialize TdGInsertBuilder<TTable>;
    TUpdateBuilder = specialize TdGUpdateBuilder<TTable>;
    TDeleteBuilder = specialize TdGDeleteBuilder<TTable>;
    TEntities = specialize TFPGObjectList<T3>;
  private
    FOnUpdated: TNotifyEvent;
    FOnUpdating: TNotifyEvent;
    FConnection: T1;
    FQuery: T2;
    FTable: TTable;
    FUpdateKind: TdOpfUpdateKind;
    function GetNulls: Boolean;
    function GetUseUtf8: Boolean;
    procedure SetNulls(const AValue: Boolean);
    procedure SetUseUtf8(const AValue: Boolean);
  protected
    function CreateTable: TTable; virtual;
    procedure FreeTable; virtual;
    procedure CheckEntity(AEntity: T3); virtual;
    procedure CheckEntities(AEntities: TEntities); virtual;
    procedure CheckTableName; virtual;
    function InternalFind(AEntity: T3; const ACondition: string;
      const AFillingObjectFilter: Boolean): Boolean;
    procedure PopulateEntities(AEntities: TEntities); virtual;
    procedure DoUpdating(AEntity: T3); virtual;
    procedure DoUpdated(AEntity: T3); virtual;
  public
    constructor Create(AConnection: T1;
      const ATableName: string); reintroduce; virtual;
    destructor Destroy; override;
    procedure GetFieldNames(out AFieldNames: string); virtual;
    procedure GetConditions(out APairs: string;
      const AIgnoreProperties: Boolean = True); virtual;
    function GetConditions(
      const AIgnoreProperties: Boolean = True): string; virtual;
    procedure SetSql(const ASql: string); virtual;
    procedure SetParams(AEntity: TObject); virtual;
    procedure GetFields(AEntity: TObject); virtual;
    function Get(AEntity: T3;
      const AFillingObjectFilter: Boolean = True): Boolean; virtual;
    function Find(AEntity: T3; const ACondition: string;
      const AFillingObjectFilter: Boolean = True): Boolean; overload; virtual;
    function Find(AEntity: T3; AEntities: TEntities; const ACondition: string;
      const AFillingObjectFilter: Boolean = True): Boolean; overload; virtual;
    function Search(AEntity: T3; AEntities: TEntities;
      AParams: TObject = nil; const ASql: string = '';
      const AFillingObjectFilter: Boolean = True): Boolean; virtual;
    function List(AEntities: TEntities; AParams: TObject = nil;
      const ASql: string = ''): Boolean; virtual;
    procedure Add(AEntity: T3;
      const AIgnorePrimaryKeys: Boolean = True); virtual;
    procedure Modify(AEntity: T3;
      const AIgnorePrimaryKeys: Boolean = True); virtual;
    procedure Remove(AEntity: T3;
      const AIgnoreProperties: Boolean = True); virtual;
    procedure Empty; virtual;
    procedure Commit; virtual;
    procedure Rollback; virtual;
    procedure Apply; virtual;
    procedure Discard; virtual;
    property Connection: T1 read FConnection;
    property Query: T2 read FQuery;
    property Table: TTable read FTable write FTable;
    property Nulls: Boolean read GetNulls write SetNulls;
    property UseUtf8: Boolean read GetUseUtf8 write SetUseUtf8;
    property UpdateKind: TdOpfUpdateKind read FUpdateKind;
    property OnUpdating: TNotifyEvent read FOnUpdating write FOnUpdating;
    property OnUpdated: TNotifyEvent read FOnUpdated write FOnUpdated;
  end;

  { TdGEntityOpf }

  generic TdGEntityOpf<T1, T2, T3> = class(specialize TdGOpf<T1, T2, T3>)
  private
    FEntity: T3;
  protected
    procedure FillEntity; virtual;
    function CreateEntity: T3; virtual;
    procedure FreeEntity; virtual;
  public
    constructor Create(AConnection: T1;
      const ATableName: string); reintroduce; override;
    destructor Destroy; override;
    function Get(const AFillingObjectFilter: Boolean = True): Boolean; overload;
    function Find(const ACondition: string;
      const AFillingObjectFilter: Boolean = True): Boolean; overload;
    function Find(AEntities: TEntities; const ACondition: string;
      const AFillingObjectFilter: Boolean = True): Boolean; overload;
    function List(AEntities: TEntities;
      AParams: TObject = nil; const ASql: string = '';
      const AFillingObjectFilter: Boolean = True): Boolean; overload;
    function Search(AEntities: TEntities;
      AParams: TObject = nil; const ASql: string = '';
      const AFillingObjectFilter: Boolean = True): Boolean; overload;
    procedure Add(const AIgnorePrimaryKeys: Boolean = True); overload;
    procedure Modify(const AIgnorePrimaryKeys: Boolean = True); overload;
    procedure Remove(const AIgnoreProperties: Boolean = True); overload;
    property Entity: T3 read FEntity write FEntity;
  end;

implementation

procedure NotImplementedError;
begin
  raise EdNotImplemented.Create('Not implemended.');
end;

{ TdLogger }

constructor TdLogger.Create(const AFileName: TFileName);
begin
  inherited Create;
  SetFileName(AFileName);
  FFilter := [ltTransaction, ltSQL, ltCustom];
end;

destructor TdLogger.Destroy;
begin
  FreeAndNil(FStream);
  inherited Destroy;
end;

procedure TdLogger.SetFileName(AValue: TFileName);
var
  D: string;
  F: TFileName;
begin
  if FActive and (Trim(AValue) <> '') and (AValue <> FFileName) then
  begin
    FFileName := AValue;
    FreeAndNil(FStream);
    if FDirectory <> '' then
      D := IncludeTrailingPathDelimiter(FDirectory)
    else
      D := '';
    F := D + ChangeFileExt(FFileName, '_' + FormatDateTime('yyyymmdd', Date) +
      ExtractFileExt(FFileName));
    if (not FOverwrite) and FileExists(F) then
    begin
      FStream := TFileStream.Create(F, fmOpenReadWrite);
      FStream.Seek(FStream.Size, soBeginning);
    end
    else
      FStream := TFileStream.Create(F, fmCreate);
  end;
end;

procedure TdLogger.SetActive(AValue: Boolean);
begin
  if AValue <> FActive then
  begin
    FActive := AValue;
    if not FActive then
      FreeAndNil(FStream);
  end;
end;

procedure TdLogger.Log(const AType: TdLogType; AMsg: string);
var
  T: string;
  LE: string[Length(LineEnding)] = LineEnding;
begin
  if FActive and (AType in FFilter) then
  begin
    WriteStr(T, AType);
    Delete(T, 1, 2);
    AMsg := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' - ' + T +
      ': ' + AMsg;
    if Assigned(FStream) then
    begin
      FStream.Write(AMsg[1], Length(AMsg));
      FStream.Write(LE[1], Length(LE));
    end;
    if Assigned(FOnLogging) then
      FOnLogging(AType, AMsg);
  end;
end;

procedure TdLogger.LogFmt(const AType: TdLogType; const AMsg: string;
  const AArgs: array of const);
begin
  Log(AType, Format(AMsg, AArgs));
end;

{ TdConnectionBroker }

constructor TdConnectionBroker.Create;
begin
  inherited Create;
end;

procedure TdConnectionBroker.Connect;
begin
  NotImplementedError;
end;

procedure TdConnectionBroker.Disconnect;
begin
  NotImplementedError;
end;

procedure TdConnectionBroker.StartTransaction;
begin
  NotImplementedError;
end;

procedure TdConnectionBroker.Commit;
begin
  NotImplementedError;
end;

procedure TdConnectionBroker.CommitRetaining;
begin
  NotImplementedError;
end;

procedure TdConnectionBroker.Rollback;
begin
  NotImplementedError;
end;

procedure TdConnectionBroker.RollbackRetaining;
begin
  NotImplementedError;
end;

function TdConnectionBroker.InTransaction: Boolean;
begin
  Result := False;
  NotImplementedError;
end;

function TdConnectionBroker.GetConnection: TObject;
begin
  Result := nil;
  NotImplementedError;
end;

function TdConnectionBroker.GetTransaction: TObject;
begin
  Result := nil;
  NotImplementedError;
end;

function TdConnectionBroker.GetConnected: Boolean;
begin
  Result := False;
  NotImplementedError;
end;

function TdConnectionBroker.GetDatabase: string;
begin
  Result := '';
  NotImplementedError;
end;

function TdConnectionBroker.GetDriver: string;
begin
  Result := '';
  NotImplementedError;
end;

function TdConnectionBroker.GetHost: string;
begin
  Result := '';
  NotImplementedError;
end;

function TdConnectionBroker.GetPassword: string;
begin
  Result := '';
  NotImplementedError;
end;

function TdConnectionBroker.GetPort: Integer;
begin
  Result := 0;
  NotImplementedError;
end;

function TdConnectionBroker.GetUser: string;
begin
  Result := '';
  NotImplementedError;
end;

function TdConnectionBroker.GetConnectorType: string;
begin
  Result := '';
  NotImplementedError;
end;

procedure TdConnectionBroker.SetConnected(const AValue: Boolean);
begin
  NotImplementedError;
end;

procedure TdConnectionBroker.SetDatabase(const AValue: string);
begin
  NotImplementedError;
end;

procedure TdConnectionBroker.SetDriver(const AValue: string);
begin
  NotImplementedError;
end;

procedure TdConnectionBroker.SetHost(const AValue: string);
begin
  NotImplementedError;
end;

procedure TdConnectionBroker.SetPassword(const AValue: string);
begin
  NotImplementedError;
end;

procedure TdConnectionBroker.SetPort(const AValue: Integer);
begin
  NotImplementedError;
end;

procedure TdConnectionBroker.SetUser(const AValue: string);
begin
  NotImplementedError;
end;

procedure TdConnectionBroker.SetConnectorType(const AValue: string);
begin
  NotImplementedError;
end;

{ TdGConnection }

constructor TdGConnection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CheckBrokerClass;
  CheckLoggerClass;
  FBroker := T1.Create;
  FLogger := T2.Create('');
end;

destructor TdGConnection.Destroy;
begin
  FBroker.Free;
  FLogger.Free;
  inherited Destroy;
end;

procedure TdGConnection.CheckBrokerClass;
begin
  if not T1.InheritsFrom(TdConnectionBroker) then
    raise EdConnection.CreateFmt('Invalid broker class: "%s".', [T1.ClassName]);
end;

procedure TdGConnection.CheckBroker;
begin
  if FBroker = nil then
    raise EdConnection.Create('Broker not assigned.');
end;

procedure TdGConnection.CheckLoggerClass;
begin
  if not T2.InheritsFrom(TdLogger) then
    raise EdConnection.CreateFmt('Invalid logger class: "%s".', [T2.ClassName]);
end;

function TdGConnection.GetConnected: Boolean;
begin
  CheckBroker;
  Result := FBroker.Connected;
end;

function TdGConnection.GetDatabase: string;
begin
  CheckBroker;
  Result := FBroker.Database;
end;

function TdGConnection.GetDriver: string;
begin
  CheckBroker;
  Result := FBroker.Driver;
end;

function TdGConnection.GetHost: string;
begin
  CheckBroker;
  Result := FBroker.Host;
end;

function TdGConnection.GetPassword: string;
begin
  CheckBroker;
  Result := FBroker.Password;
end;

function TdGConnection.GetPort: Integer;
begin
  CheckBroker;
  Result := FBroker.Port;
end;

function TdGConnection.GetUser: string;
begin
  CheckBroker;
  Result := FBroker.User;
end;

function TdGConnection.GetConnectorType: string;
begin
  CheckBroker;
  Result := FBroker.ConnectorType;
end;

procedure TdGConnection.SetConnected(const AValue: Boolean);
begin
  CheckBroker;
  FBroker.Connected := AValue;
end;

procedure TdGConnection.SetDatabase(const AValue: string);
begin
  CheckBroker;
  FBroker.Database := AValue;
end;

procedure TdGConnection.SetDriver(const AValue: string);
begin
  CheckBroker;
  FBroker.Driver := AValue;
end;

procedure TdGConnection.SetHost(const AValue: string);
begin
  CheckBroker;
  FBroker.Host := AValue;
end;

procedure TdGConnection.SetPassword(const AValue: string);
begin
  CheckBroker;
  FBroker.Password := AValue;
end;

procedure TdGConnection.SetPort(const AValue: Integer);
begin
  CheckBroker;
  FBroker.Port := AValue;
end;

procedure TdGConnection.SetUser(const AValue: string);
begin
  CheckBroker;
  FBroker.User := AValue;
end;

procedure TdGConnection.SetConnectorType(const AValue: string);
begin
  CheckBroker;
  FBroker.ConnectorType := AValue;
end;

procedure TdGConnection.Connect;
begin
  CheckBroker;
  FLogger.Log(ltConnection, 'Trying Connection.Connect');
  try
    FBroker.Connect;
  except
    on E: Exception do
    begin
      FLogger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGConnection.Disconnect;
begin
  CheckBroker;
  FLogger.Log(ltConnection, 'Trying Connection.Disconnect');
  try
    FBroker.Disconnect;
  except
    on E: Exception do
    begin
      FLogger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGConnection.StartTransaction;
begin
  CheckBroker;
  FLogger.Log(ltTransaction, 'Trying Connection.StartTransaction');
  try
    FBroker.StartTransaction;
  except
    on E: Exception do
    begin
      FLogger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGConnection.Commit;
begin
  CheckBroker;
  FLogger.Log(ltTransaction, 'Trying Connection.Commit');
  try
    FBroker.Commit;
  except
    on E: Exception do
    begin
      FLogger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGConnection.CommitRetaining;
begin
  CheckBroker;
  FLogger.Log(ltTransaction, 'Trying Connection.CommitRetaining');
  try
    FBroker.CommitRetaining;
  except
    on E: Exception do
    begin
      FLogger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGConnection.Rollback;
begin
  CheckBroker;
  FLogger.Log(ltTransaction, 'Trying Connection.Rollback');
  try
    FBroker.Rollback;
  except
    on E: Exception do
    begin
      FLogger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGConnection.RollbackRetaining;
begin
  CheckBroker;
  FLogger.Log(ltTransaction, 'Trying Connection.RollbackRetaining');
  try
    FBroker.RollbackRetaining;
  except
    on E: Exception do
    begin
      FLogger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

function TdGConnection.InTransaction: Boolean;
begin
  CheckBroker;
  Result := FBroker.InTransaction;
end;

{ TdQueryBroker }

constructor TdQueryBroker.Create;
begin
  inherited Create;
end;

procedure TdQueryBroker.ApplyUpdates;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.CancelUpdates;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.Apply;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.ApplyRetaining;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.Undo;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.UndoRetaining;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.Commit;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.Rollback;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.Append;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.Insert;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.Edit;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.Cancel;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.Delete;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.Open;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.Close;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.Refresh;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.First;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.Prior;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.Next;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.Last;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.Post;
begin
  NotImplementedError;
end;

procedure TdQueryBroker.Execute;
begin
  NotImplementedError;
end;

function TdQueryBroker.RowsAffected: Int64;
begin
  Result := 0;
  NotImplementedError;
end;

function TdQueryBroker.Locate(const AKeyFields: string;
  const AKeyValues: Variant; const AOptions: TLocateOptions): Boolean;
begin
  Result := False;
  NotImplementedError;
end;

function TdQueryBroker.Param(const AName: string): TParam;
begin
  Result := nil;
  NotImplementedError;
end;

function TdQueryBroker.Field(const AName: string): TField;
begin
  Result := nil;
  NotImplementedError;
end;

function TdQueryBroker.FieldDef(const AName: string): TFieldDef;
begin
  Result := nil;
  NotImplementedError;
end;

function TdQueryBroker.Count: Int64;
begin
  Result := 0;
  NotImplementedError;
end;

function TdQueryBroker.IsEmpty: Boolean;
begin
  Result := False;
  NotImplementedError;
end;

function TdQueryBroker.GetBookmark: TBookmark;
begin
  Result := nil;
  NotImplementedError;
end;

procedure TdQueryBroker.GotoBookmark(ABookmark: TBookmark);
begin
  NotImplementedError;
end;

function TdQueryBroker.GetConnection: TObject;
begin
  Result := nil;
  NotImplementedError;
end;

function TdQueryBroker.GetUseUtf8: Boolean;
begin
  Result := False;
  NotImplementedError;
end;

function TdQueryBroker.GetNulls: Boolean;
begin
  Result := False;
  NotImplementedError;
end;

function TdQueryBroker.GetActive: Boolean;
begin
  Result := False;
  NotImplementedError;
end;

function TdQueryBroker.GetBOF: Boolean;
begin
  Result := False;
  NotImplementedError;
end;

function TdQueryBroker.GetDataSet: TDataSet;
begin
  Result := nil;
  NotImplementedError;
end;

function TdQueryBroker.GetDataSource: TDataSource;
begin
  Result := nil;
  NotImplementedError;
end;

function TdQueryBroker.GetEOF: Boolean;
begin
  Result := False;
  NotImplementedError;
end;

function TdQueryBroker.GetFieldDefs: TFieldDefs;
begin
  Result := nil;
  NotImplementedError;
end;

function TdQueryBroker.GetFields: TFields;
begin
  Result := nil;
  NotImplementedError;
end;

function TdQueryBroker.GetModified: Boolean;
begin
  Result := False;
  NotImplementedError;
end;

function TdQueryBroker.GetParams: TParams;
begin
  Result := nil;
  NotImplementedError;
end;

function TdQueryBroker.GetPosition: Int64;
begin
  Result := 0;
  NotImplementedError;
end;

function TdQueryBroker.GetSQL: TStrings;
begin
  Result := nil;
  NotImplementedError;
end;

function TdQueryBroker.GetState: TDataSetState;
begin
  Result := dsInactive;
  NotImplementedError;
end;

procedure TdQueryBroker.SetActive(const AValue: Boolean);
begin
  NotImplementedError;
end;

procedure TdQueryBroker.SetConnection(AValue: TObject);
begin
  NotImplementedError;
end;

procedure TdQueryBroker.SetDataSource(AValue: TDataSource);
begin
  NotImplementedError;
end;

procedure TdQueryBroker.SetPosition(const AValue: Int64);
begin
  NotImplementedError;
end;

procedure TdQueryBroker.SetNulls(const AValue: Boolean);
begin
  NotImplementedError;
end;

procedure TdQueryBroker.SetUseUtf8(const AValue: Boolean);
begin
  NotImplementedError;
end;

{ TdGQuery }

constructor TdGQuery.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CheckBrokerClass;
  FBroker := T1.Create;
  FConnection := T2(AOwner);
  if Assigned(AOwner) then
    FBroker.Connection := FConnection.Broker.Connection;
end;

destructor TdGQuery.Destroy;
begin
  FBroker.Free;
  inherited Destroy;
end;

procedure TdGQuery.GetFields(AEntity: TObject);
begin
  Connection.Logger.Log(ltCustom, 'Trying Query.GetFields');
  try
    dUtils.dGetFields(AEntity, Fields, Nulls, UseUtf8);
  except
    on E: Exception do
    begin
      Connection.Logger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGQuery.SetFields(AEntity: TObject);
begin
  Connection.Logger.Log(ltCustom, 'Trying Query.SetFields');
  try
    dUtils.dSetFields(AEntity, Fields, Nulls, UseUtf8);
  except
    on E: Exception do
    begin
      Connection.Logger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGQuery.GetParams(AEntity: TObject);
begin
  Connection.Logger.Log(ltCustom, 'Trying Query.GetParams');
  try
    dUtils.dGetParams(AEntity, Params, Nulls, UseUtf8);
  except
    on E: Exception do
    begin
      Connection.Logger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGQuery.SetParams(AEntity: TObject);
begin
  Connection.Logger.Log(ltCustom, 'Trying Query.SetParams');
  try
    dUtils.dSetParams(AEntity, Params, Nulls, UseUtf8);
  except
    on E: Exception do
    begin
      Connection.Logger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGQuery.CheckBrokerClass;
begin
  if not T1.InheritsFrom(TdQueryBroker) then
    raise EdQuery.CreateFmt('Invalid broker class: "%s".', [T1.ClassName]);
end;

procedure TdGQuery.CheckBroker;
begin
  if FBroker = nil then
    raise EdQuery.Create('Broker not assigned.');
end;

procedure TdGQuery.CheckConnection;
begin
  if FConnection = nil then
    raise EdQuery.Create('Connection not assigned.');
end;

function TdGQuery.GetActive: Boolean;
begin
  CheckBroker;
  Result := FBroker.Active;
end;

function TdGQuery.GetBOF: Boolean;
begin
  CheckBroker;
  Result := FBroker.BOF;
end;

function TdGQuery.GetDataSet: TDataSet;
begin
  CheckBroker;
  Result := FBroker.DataSet;
end;

function TdGQuery.GetDataSource: TDataSource;
begin
  CheckBroker;
  Result := FBroker.DataSource;
end;

function TdGQuery.GetEOF: Boolean;
begin
  CheckBroker;
  Result := FBroker.EOF;
end;

function TdGQuery.GetFieldDefs: TFieldDefs;
begin
  CheckBroker;
  Result := FBroker.FieldDefs;
end;

function TdGQuery.GetFields: TFields;
begin
  CheckBroker;
  Result := FBroker.Fields;
end;

function TdGQuery.GetModified: Boolean;
begin
  CheckBroker;
  Result := FBroker.Modified;
end;

function TdGQuery.GetNulls: Boolean;
begin
  CheckBroker;
  Result := FBroker.Nulls;
end;

function TdGQuery.GetParams: TParams;
begin
  CheckBroker;
  Result := FBroker.Params;
end;

function TdGQuery.GetPosition: Int64;
begin
  CheckBroker;
  Result := FBroker.Position;
end;

function TdGQuery.GetSQL: TStrings;
begin
  CheckBroker;
  Result := FBroker.SQL;
end;

function TdGQuery.GetState: TDataSetState;
begin
  CheckBroker;
  Result := FBroker.State;
end;

function TdGQuery.GetUseUtf8: Boolean;
begin
  CheckBroker;
  Result := FBroker.UseUtf8;
end;

procedure TdGQuery.SetActive(const AValue: Boolean);
begin
  CheckBroker;
  FBroker.Active := AValue;
end;

procedure TdGQuery.SetDataSource(AValue: TDataSource);
begin
  CheckBroker;
  FBroker.DataSource := AValue;
end;

procedure TdGQuery.SetNulls(const AValue: Boolean);
begin
  CheckBroker;
  FBroker.Nulls := AValue;
end;

procedure TdGQuery.SetPosition(const AValue: Int64);
begin
  CheckBroker;
  FBroker.Position := AValue;
end;

procedure TdGQuery.SetUseUtf8(const AValue: Boolean);
begin
  CheckBroker;
  FBroker.UseUtf8 := AValue;
end;

procedure TdGQuery.ApplyUpdates;
begin
  CheckBroker;
  CheckConnection;
  Connection.Logger.Log(ltCustom, 'Trying Query.ApplyUpdates');
  try
    FBroker.ApplyUpdates;
  except
    on E: Exception do
    begin
      Connection.Logger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGQuery.CancelUpdates;
begin
  CheckBroker;
  CheckConnection;
  Connection.Logger.Log(ltCustom, 'Trying Query.CancelUpdates');
  try
    FBroker.CancelUpdates;
  except
    on E: Exception do
    begin
      Connection.Logger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGQuery.Apply;
begin
  CheckBroker;
  CheckConnection;
  Connection.Logger.Log(ltTransaction, 'Trying Query.Apply');
  try
    FBroker.Apply;
  except
    on E: Exception do
    begin
      Connection.Logger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGQuery.ApplyRetaining;
begin
  CheckBroker;
  CheckConnection;
  Connection.Logger.Log(ltTransaction, 'Trying Query.ApplyRetaining');
  try
    FBroker.ApplyRetaining;
  except
    on E: Exception do
    begin
      Connection.Logger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGQuery.Undo;
begin
  CheckBroker;
  CheckConnection;
  Connection.Logger.Log(ltTransaction, 'Trying Query.Undo');
  try
    FBroker.Undo;
  except
    on E: Exception do
    begin
      Connection.Logger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGQuery.UndoRetaining;
begin
  CheckBroker;
  CheckConnection;
  Connection.Logger.Log(ltTransaction, 'Trying Query.UndoRetaining');
  try
    FBroker.UndoRetaining;
  except
    on E: Exception do
    begin
      Connection.Logger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGQuery.Commit;
begin
  CheckBroker;
  CheckConnection;
  Connection.Logger.Log(ltTransaction, 'Trying Query.Commit');
  try
    FBroker.Commit;
  except
    on E: Exception do
    begin
      Connection.Logger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGQuery.Rollback;
begin
  CheckBroker;
  CheckConnection;
  Connection.Logger.Log(ltTransaction, 'Trying Query.Rollback');
  try
    FBroker.Rollback;
  except
    on E: Exception do
    begin
      Connection.Logger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGQuery.Append;
begin
  CheckBroker;
  FBroker.Append;
end;

procedure TdGQuery.Insert;
begin
  CheckBroker;
  FBroker.Insert;
end;

procedure TdGQuery.Edit;
begin
  CheckBroker;
  FBroker.Edit;
end;

procedure TdGQuery.Cancel;
begin
  CheckBroker;
  FBroker.Cancel;
end;

procedure TdGQuery.Delete;
begin
  CheckBroker;
  FBroker.Delete;
end;

procedure TdGQuery.Open;
var
  S: string;
begin
  CheckBroker;
  CheckConnection;
  S := Trim(SQL.Text);
  dUtils.dParameterizeSQL(S, Params, Nulls);
  Connection.Logger.Log(ltSQL, 'Trying Query.Open: ' + S);
  try
    FBroker.Open;
  except
    on E: Exception do
    begin
      Connection.Logger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

procedure TdGQuery.Close;
begin
  CheckBroker;
  FBroker.Close;
end;

procedure TdGQuery.Refresh;
begin
  CheckBroker;
  FBroker.Refresh;
end;

procedure TdGQuery.First;
begin
  CheckBroker;
  FBroker.First;
end;

procedure TdGQuery.Prior;
begin
  CheckBroker;
  FBroker.Prior;
end;

procedure TdGQuery.Next;
begin
  CheckBroker;
  FBroker.Next;
end;

procedure TdGQuery.Last;
begin
  CheckBroker;
  FBroker.Last;
end;

procedure TdGQuery.Post;
begin
  CheckBroker;
  FBroker.Post;
end;

procedure TdGQuery.Execute;
var
  S: string;
begin
  CheckBroker;
  CheckConnection;
  S := Trim(SQL.Text);
  dUtils.dParameterizeSQL(S, Params, Nulls);
  Connection.Logger.Log(ltSQL, 'Trying Query.Execute: ' + S);
  try
    FBroker.Execute;
  except
    on E: Exception do
    begin
      Connection.Logger.Log(ltErrors, E.Message);
      raise;
    end;
  end;
end;

function TdGQuery.RowsAffected: Int64;
begin
  CheckBroker;
  Result := FBroker.RowsAffected;
end;

function TdGQuery.Locate(const AKeyFields: string; const AKeyValues: Variant;
  const AOptions: TLocateOptions): Boolean;
begin
  CheckBroker;
  Result := FBroker.Locate(AKeyFields, AKeyValues, AOptions);
end;

function TdGQuery.Param(const AName: string): TParam;
begin
  CheckBroker;
  Result := FBroker.Param(AName);
end;

function TdGQuery.Field(const AName: string): TField;
begin
  CheckBroker;
  Result := FBroker.Field(AName);
end;

function TdGQuery.FieldDef(const AName: string): TFieldDef;
begin
  CheckBroker;
  Result := FBroker.FieldDef(AName);
end;

function TdGQuery.Count: Int64;
begin
  CheckBroker;
  Result := FBroker.Count;
end;

function TdGQuery.IsEmpty: Boolean;
begin
  CheckBroker;
  Result := FBroker.IsEmpty;
end;

function TdGQuery.GetBookmark: TBookmark;
begin
  CheckBroker;
  Result := FBroker.Bookmark;
end;

procedure TdGQuery.GotoBookmark(ABookmark: TBookmark);
begin
  CheckBroker;
  FBroker.GotoBookmark(ABookmark);
end;

procedure TdGQuery.AddSql(const ASql: string);
begin
  CheckBroker;
  CheckConnection;
  Connection.Logger.Log(ltSQL, 'Trying add SQL: ' + ASql);
  FBroker.SQL.Add(ASql);
end;

{ TdGEntityQuery }

constructor TdGEntityQuery.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FEntity := CreateEntity;
end;

destructor TdGEntityQuery.Destroy;
begin
  FreeEntity;
  inherited Destroy;
end;

function TdGEntityQuery.CreateEntity: T3;
begin
  Result := T3.Create;
end;

procedure TdGEntityQuery.FreeEntity;
begin
  FreeAndNil(FEntity);
end;

procedure TdGEntityQuery.GetFields;
begin
  inherited GetFields(FEntity);
end;

procedure TdGEntityQuery.SetFields;
begin
  inherited SetFields(FEntity);
end;

procedure TdGEntityQuery.GetParams;
begin
  inherited GetParams(FEntity);
end;

procedure TdGEntityQuery.SetParams;
begin
  inherited SetParams(FEntity);
end;

{ TdGOpf }

constructor TdGOpf.Create(AConnection: T1; const ATableName: string);
begin
  inherited Create(AConnection);
  FConnection := AConnection;
  FQuery := T2.Create(FConnection);
  FTable := CreateTable;
  FTable.Name := ATableName;
end;

destructor TdGOpf.Destroy;
begin
  FQuery.Free;
  FreeTable;
  inherited Destroy;
end;

function TdGOpf.GetNulls: Boolean;
begin
  Result := FQuery.Nulls;
end;

function TdGOpf.GetUseUtf8: Boolean;
begin
  Result := FQuery.UseUtf8;
end;

procedure TdGOpf.SetNulls(const AValue: Boolean);
begin
  FQuery.Nulls := AValue;
end;

procedure TdGOpf.SetUseUtf8(const AValue: Boolean);
begin
  FQuery.UseUtf8 := AValue;
end;

function TdGOpf.CreateTable: TTable;
begin
  Result := TTable.Create;
end;

procedure TdGOpf.FreeTable;
begin
  FreeAndNil(FTable);
end;

procedure TdGOpf.GetFieldNames(out AFieldNames: string);
begin
  TSelectBuilder.MakeFields(FTable, AFieldNames, True);
end;

procedure TdGOpf.GetConditions(out APairs: string;
  const AIgnoreProperties: Boolean);
begin
  TDeleteBuilder.MakeParams(FTable, APairs, AIgnoreProperties);
end;

function TdGOpf.GetConditions(const AIgnoreProperties: Boolean): string;
begin
  GetConditions(Result, AIgnoreProperties);
end;

procedure TdGOpf.CheckEntity(AEntity: T3);
begin
  if AEntity = nil then
    raise EdOpf.Create('Entity must not be nil.');
  if T3 = TObject then
    raise EdOpf.Create('Entity must be TObject directly.');
end;

procedure TdGOpf.CheckEntities(AEntities: TEntities);
begin
  if AEntities = nil then
    raise EdOpf.Create('Entities must not be nil.');
end;

procedure TdGOpf.CheckTableName;
begin
  if Trim(FTable.Name) = '' then
    raise EdTable.Create('Table name must not be empty.');
end;

procedure TdGOpf.Empty;
begin
  CheckTableName;
  SetSql('delete from ' + FTable.Name);
  FQuery.Execute;
end;

function TdGOpf.InternalFind(AEntity: T3; const ACondition: string;
  const AFillingObjectFilter: Boolean): Boolean;
var
  FS: string = '';
begin
  if ShortCompareText(Copy(ACondition, 1, 7), 'select ') = 0 then
    SetSql(ACondition)
  else
  begin
    CheckTableName;
    TSelectBuilder.MakeFields(FTable, FS, True);
    SetSql('select ' + FS + ' from ' + FTable.Name);
    if ACondition <> '' then
      FQuery.SQL.Add('where ' + ACondition);
  end;
  SetParams(AEntity);
  FQuery.Open;
  Result := FQuery.Count > 0;
  if Result and AFillingObjectFilter then
    GetFields(AEntity);
end;

procedure TdGOpf.PopulateEntities(AEntities: TEntities);
var
  E: T3;
begin
  FQuery.First;
  while not FQuery.EOF do
  begin
    E := T3.Create;
    GetFields(E);
    AEntities.Add(E);
    FQuery.Next;
  end;
end;

procedure TdGOpf.DoUpdating(AEntity: T3);
begin
  if Assigned(FOnUpdating) then
    FOnUpdating(AEntity);
end;

procedure TdGOpf.DoUpdated(AEntity: T3);
begin
  if Assigned(FOnUpdated) then
    FOnUpdated(AEntity);
end;

procedure TdGOpf.SetSql(const ASql: string);
begin
  FQuery.Close;
  FQuery.SQL.Text := ASql;
end;

procedure TdGOpf.SetParams(AEntity: TObject);
begin
  dUtils.dSetParams(FTable.PropList, FTable.PropCount, AEntity, FQuery.Params,
    FQuery.Nulls, FQuery.UseUtf8);
end;

procedure TdGOpf.GetFields(AEntity: TObject);
begin
  dUtils.dGetFields(AEntity, FQuery.Fields, FQuery.Nulls, FQuery.UseUtf8);
end;

function TdGOpf.Get(AEntity: T3; const AFillingObjectFilter: Boolean): Boolean;
var
  PS: string = '';
begin
  CheckEntity(AEntity);
  TDeleteBuilder.MakeParams(FTable, PS, True);
  Result := InternalFind(AEntity, PS, AFillingObjectFilter);
end;

function TdGOpf.Find(AEntity: T3; const ACondition: string;
  const AFillingObjectFilter: Boolean): Boolean;
begin
  CheckEntity(AEntity);
  Result := InternalFind(AEntity, ACondition, AFillingObjectFilter);
end;

function TdGOpf.Find(AEntity: T3; AEntities: TEntities;
  const ACondition: string; const AFillingObjectFilter: Boolean): Boolean;
begin
  CheckEntity(AEntity);
  CheckEntities(AEntities);
  Result := InternalFind(AEntity, ACondition, AFillingObjectFilter);
  if Result then
    PopulateEntities(AEntities);
end;

function TdGOpf.Search(AEntity: T3; AEntities: TEntities; AParams: TObject;
  const ASql: string; const AFillingObjectFilter: Boolean): Boolean;
var
  FS: string = '';
begin
  CheckTableName;
  CheckEntity(AEntity);
  CheckEntities(AEntities);
  if ASql = '' then
  begin
    TSelectBuilder.MakeFields(FTable, FS, True);
    SetSql('select ' + FS + ' from ' + FTable.Name);
  end
  else
    SetSql(ASql);
  SetParams(AEntity);
  if Assigned(AParams) then
    dUtils.dSetParams(AParams, FQuery.Params, FQuery.Nulls, FQuery.UseUtf8);
  FQuery.Open;
  Result := FQuery.Count > 0;
  if Result then
  begin
    if AFillingObjectFilter then
      GetFields(AEntity);
    PopulateEntities(AEntities);
  end;
end;

function TdGOpf.List(AEntities: TEntities; AParams: TObject;
  const ASql: string): Boolean;
var
  FS: string = '';
begin
  CheckTableName;
  CheckEntities(AEntities);
  if ASql = '' then
  begin
    TSelectBuilder.MakeFields(FTable, FS, True);
    SetSql('select ' + FS + ' from ' + FTable.Name);
  end
  else
    SetSql(ASql);
  if Assigned(AParams) then
    dUtils.dSetParams(AParams, FQuery.Params, FQuery.Nulls, FQuery.UseUtf8);
  FQuery.Open;
  Result := FQuery.Count > 0;
  if Result then
    PopulateEntities(AEntities);
end;

{$NOTES OFF}
procedure TdGOpf.Add(AEntity: T3; const AIgnorePrimaryKeys: Boolean);
var
  S: string = '';
  B: TInsertBuilder;
begin
  CheckEntity(AEntity);
  B := TInsertBuilder.Create(nil);
  try
    FUpdateKind := ukAdd;
    DoUpdating(AEntity);
    B.SetTable(Table);
    B.Build(S, AIgnorePrimaryKeys);
    SetSql(S);
    SetParams(AEntity);
    FQuery.Execute;
    DoUpdated(AEntity);
  finally
    B.Free;
  end;
end;
{$NOTES ON}

{$NOTES OFF}
procedure TdGOpf.Modify(AEntity: T3; const AIgnorePrimaryKeys: Boolean);
var
  S: string = '';
  B: TUpdateBuilder;
begin
  CheckEntity(AEntity);
  B := TUpdateBuilder.Create(nil);
  try
    FUpdateKind := ukModify;
    DoUpdating(AEntity);
    B.SetTable(Table);
    B.Build(S, AIgnorePrimaryKeys);
    SetSql(S);
    SetParams(AEntity);
    FQuery.Execute;
    DoUpdated(AEntity);
  finally
    B.Free;
  end;
end;
{$NOTES ON}

{$NOTES OFF}
procedure TdGOpf.Remove(AEntity: T3; const AIgnoreProperties: Boolean);
var
  S: string = '';
  B: TDeleteBuilder;
begin
  CheckEntity(AEntity);
  B := TDeleteBuilder.Create(nil);
  try
    FUpdateKind := ukRemove;
    DoUpdating(AEntity);
    B.SetTable(Table);
    B.Build(S, AIgnoreProperties);
    SetSql(S);
    SetParams(AEntity);
    FQuery.Execute;
    DoUpdated(AEntity);
  finally
    B.Free;
  end;
end;
{$NOTES ON}

procedure TdGOpf.Commit;
begin
  FQuery.Commit;
end;

procedure TdGOpf.Rollback;
begin
  FQuery.Rollback;
end;

procedure TdGOpf.Apply;
begin
  FQuery.Apply;
end;

procedure TdGOpf.Discard;
begin
  FQuery.Undo;
end;

{ TdGEntityOpf }

constructor TdGEntityOpf.Create(AConnection: T1; const ATableName: string);
begin
  inherited Create(AConnection, ATableName);
  FEntity := CreateEntity;
end;

destructor TdGEntityOpf.Destroy;
begin
  FreeEntity;
  inherited Destroy;
end;

function TdGEntityOpf.CreateEntity: T3;
begin
  Result := T3.Create;
end;

procedure TdGEntityOpf.FreeEntity;
begin
  FreeAndNil(FEntity);
end;

procedure TdGEntityOpf.FillEntity;
begin
  GetFields(FEntity);
end;

function TdGEntityOpf.Get(const AFillingObjectFilter: Boolean): Boolean;
begin
  Result := inherited Get(FEntity, AFillingObjectFilter);
end;

function TdGEntityOpf.Find(const ACondition: string;
  const AFillingObjectFilter: Boolean): Boolean;
begin
  Result := inherited Find(FEntity, ACondition, AFillingObjectFilter);
end;

function TdGEntityOpf.Find(AEntities: TEntities; const ACondition: string;
  const AFillingObjectFilter: Boolean): Boolean;
begin
  Result := inherited Find(FEntity, AEntities, ACondition, AFillingObjectFilter);
end;

function TdGEntityOpf.List(AEntities: TEntities; AParams: TObject;
  const ASql: string; const AFillingObjectFilter: Boolean): Boolean;
begin
  Result := inherited List(AEntities, AParams, ASql);
  if Result and AFillingObjectFilter then
    GetFields(FEntity);
end;

function TdGEntityOpf.Search(AEntities: TEntities; AParams: TObject;
  const ASql: string; const AFillingObjectFilter: Boolean): Boolean;
begin
  Result := inherited Search(FEntity, AEntities, AParams, ASql,
    AFillingObjectFilter);
end;

procedure TdGEntityOpf.Add(const AIgnorePrimaryKeys: Boolean);
begin
  inherited Add(FEntity, AIgnorePrimaryKeys);
end;

procedure TdGEntityOpf.Modify(const AIgnorePrimaryKeys: Boolean);
begin
  inherited Modify(FEntity, AIgnorePrimaryKeys);
end;

procedure TdGEntityOpf.Remove(const AIgnoreProperties: Boolean);
begin
  inherited Remove(FEntity, AIgnoreProperties);
end;

end.

