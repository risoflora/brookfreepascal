(*
  Duall Sistemas, Object Persistence SQLdb Broker

  Copyright (C) 2014 Silvio Clecio

  See the file LICENSE.txt, included in this distribution,
  for details about the copyright.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*)

unit dSQLdbBroker;

{$i dopf.inc}

interface

uses
  dOpf, Classes, SysUtils, SQLdb, DB;

type

  { TdSQLdbConnectionBroker }

  TdSQLdbConnectionBroker = class(TdConnectionBroker)
  private
    FCon: TSQLConnector;
  protected
    function GetConnection: TObject; override;
    function GetTransaction: TObject; override;
    function GetConnected: Boolean; override;
    function GetDatabase: string; override;
    function GetDriver: string; override;
    function GetHost: string; override;
    function GetPassword: string; override;
    function GetPort: Integer; override;
    function GetUser: string; override;
    function GetConnectorType: string; override;
    procedure SetConnected(const AValue: Boolean); override;
    procedure SetDatabase(const AValue: string); override;
    procedure SetDriver(const AValue: string); override;
    procedure SetHost(const AValue: string); override;
    procedure SetPassword(const AValue: string); override;
    procedure SetPort(const AValue: Integer); override;
    procedure SetUser(const AValue: string); override;
    procedure SetConnectorType(const AValue: String); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure StartTransaction; override;
    procedure Commit; override;
    procedure CommitRetaining; override;
    procedure Rollback; override;
    procedure RollbackRetaining; override;
    function InTransaction: Boolean; override;
  end;

  { TdSQLdbConnector }

  TdSQLdbConnector = class(specialize TdGConnection<TdSQLdbConnectionBroker, TdLogger>)
  end;

  { TdSQLdbQueryBroker }

  TdSQLdbQueryBroker = class(TdQueryBroker)
  private
    FNulls: Boolean;
    FUseUtf8: Boolean;
    FCon: TSQLConnector;
    FQuery: TSQLQuery;
  protected
    function GetActive: Boolean; override;
    function GetBOF: Boolean; override;
    function GetConnection: TObject; override;
    function GetDataSet: TDataSet; override;
    function GetDataSource: TDataSource; override;
    function GetEOF: Boolean; override;
    function GetFieldDefs: TFieldDefs; override;
    function GetFields: TFields; override;
    function GetModified: Boolean; override;
    function GetParams: TParams; override;
    function GetPosition: Int64; override;
    function GetSQL: TStrings; override;
    function GetState: TDataSetState; override;
    function GetNulls: Boolean; override;
    function GetUseUtf8: Boolean; override;
    procedure SetActive(const AValue: Boolean); override;
    procedure SetConnection(AValue: TObject); override;
    procedure SetDataSource(AValue: TDataSource); override;
    procedure SetPosition(const AValue: Int64); override;
    procedure SetNulls(const AValue: Boolean); override;
    procedure SetUseUtf8(const AValue: Boolean); override;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure ApplyUpdates; override;
    procedure CancelUpdates; override;
    procedure Apply; override;
    procedure ApplyRetaining; override;
    procedure Undo; override;
    procedure UndoRetaining; override;
    procedure Commit; override;
    procedure Rollback; override;
    procedure Append; override;
    procedure Insert; override;
    procedure Edit; override;
    procedure Cancel; override;
    procedure Delete; override;
    procedure Open; override;
    procedure Close; override;
    procedure Refresh; override;
    procedure First; override;
    procedure Prior; override;
    procedure Next; override;
    procedure Last; override;
    procedure Post; override;
    procedure Execute; override;
    function RowsAffected: Int64; override;
    function Locate(const AKeyFields: string;const AKeyValues: Variant;
      const AOptions: TLocateOptions = []): Boolean; override;
    function Param(const AName: string): TParam; override;
    function Field(const AName: string): TField; override;
    function FieldDef(const AName: string): TFieldDef; override;
    function Count: Int64; override;
    function IsEmpty: Boolean; override;
    function GetBookmark: TBookmark; override;
    procedure GotoBookmark(ABookmark: TBookmark); override;
  end;

  { TdSQLdbQuery }

  TdSQLdbQuery = class(specialize TdGQuery<TdSQLdbQueryBroker, TdSQLdbConnector>)
  end;

  { TdGSQLdbEntityQuery }

  generic TdGSQLdbEntityQuery<T1, T2> = class(specialize TdGEntityQuery<TdSQLdbQueryBroker, T1, T2>)
  end;

  { TdGSQLdbOpf }

  generic TdGSQLdbOpf<T> = class(specialize TdGOpf<TdSQLdbConnector, TdSQLdbQuery, T>)
  end;

  { TdGSQLdbEntityOpf }

  generic TdGSQLdbEntityOpf<T> = class(specialize TdGEntityOpf<TdSQLdbConnector, TdSQLdbQuery, T>)
  end;

implementation

{ TdSQLdbConnectionBroker }

constructor TdSQLdbConnectionBroker.Create;
begin
  inherited Create;
  FCon := TSQLConnector.Create(nil);
  FCon.Transaction := TSQLTransaction.Create(FCon);
end;

destructor TdSQLdbConnectionBroker.Destroy;
begin
  FreeAndNil(FCon);
  inherited Destroy;
end;

procedure TdSQLdbConnectionBroker.Connect;
begin
  FCon.Connected := True;
end;

procedure TdSQLdbConnectionBroker.Disconnect;
begin
  FCon.Connected := False;
end;

procedure TdSQLdbConnectionBroker.StartTransaction;
begin
  FCon.Transaction.StartTransaction;
end;

procedure TdSQLdbConnectionBroker.Commit;
begin
  FCon.Transaction.Commit;
end;

procedure TdSQLdbConnectionBroker.CommitRetaining;
begin
  FCon.Transaction.CommitRetaining;
end;

procedure TdSQLdbConnectionBroker.Rollback;
begin
  FCon.Transaction.Rollback;
end;

procedure TdSQLdbConnectionBroker.RollbackRetaining;
begin
  FCon.Transaction.RollbackRetaining;
end;

function TdSQLdbConnectionBroker.InTransaction: Boolean;
begin
  Result := FCon.Transaction.Active;
end;

function TdSQLdbConnectionBroker.GetConnection: TObject;
begin
  Result := FCon;
end;

function TdSQLdbConnectionBroker.GetTransaction: TObject;
begin
  Result := FCon.Transaction;
end;

function TdSQLdbConnectionBroker.GetConnected: Boolean;
begin
  Result := FCon.Connected;
end;

function TdSQLdbConnectionBroker.GetDatabase: string;
begin
  Result := FCon.DatabaseName;
end;

function TdSQLdbConnectionBroker.GetDriver: string;
begin
  Result := FCon.ConnectorType;
end;

function TdSQLdbConnectionBroker.GetHost: string;
begin
  Result := FCon.HostName;
end;

function TdSQLdbConnectionBroker.GetPassword: string;
begin
  Result := FCon.Password;
end;

function TdSQLdbConnectionBroker.GetPort: Integer;
begin
  Result := StrToIntDef(FCon.Params.Values['port'], 0);
end;

function TdSQLdbConnectionBroker.GetUser: string;
begin
  Result := FCon.UserName;
end;

function TdSQLdbConnectionBroker.GetConnectorType: string;
begin
  Result := FCon.ConnectorType;
end;

procedure TdSQLdbConnectionBroker.SetConnected(const AValue: Boolean);
begin
  FCon.Connected := AValue;
end;

procedure TdSQLdbConnectionBroker.SetDatabase(const AValue: string);
begin
  FCon.DatabaseName := AValue;
end;

procedure TdSQLdbConnectionBroker.SetDriver(const AValue: string);
begin
  FCon.ConnectorType := AValue;
end;

procedure TdSQLdbConnectionBroker.SetHost(const AValue: string);
begin
  FCon.HostName := AValue;
end;

procedure TdSQLdbConnectionBroker.SetPassword(const AValue: string);
begin
  FCon.Password := AValue;
end;

procedure TdSQLdbConnectionBroker.SetPort(const AValue: Integer);
begin
  FCon.Params.Values['port'] := IntToStr(AValue);
end;

procedure TdSQLdbConnectionBroker.SetUser(const AValue: string);
begin
  FCon.UserName := AValue;
end;

procedure TdSQLdbConnectionBroker.SetConnectorType(const AValue: String);
begin
  FCon.ConnectorType := AValue;
end;

{ TdSQLdbQueryBroker }

constructor TdSQLdbQueryBroker.Create;
begin
  inherited Create;
  FQuery := TSQLQuery.Create(nil);
end;

destructor TdSQLdbQueryBroker.Destroy;
begin
  FreeAndNil(FQuery);
  inherited Destroy;
end;

function TdSQLdbQueryBroker.GetActive: Boolean;
begin
  Result := FQuery.Active;
end;

function TdSQLdbQueryBroker.GetBOF: Boolean;
begin
  Result := FQuery.BOF;
end;

function TdSQLdbQueryBroker.GetConnection: TObject;
begin
  Result := FCon;
end;

function TdSQLdbQueryBroker.GetDataSet: TDataSet;
begin
  Result := FQuery;
end;

function TdSQLdbQueryBroker.GetDataSource: TDataSource;
begin
  Result := FQuery.DataSource;
end;

function TdSQLdbQueryBroker.GetEOF: Boolean;
begin
  Result := FQuery.EOF;
end;

function TdSQLdbQueryBroker.GetFieldDefs: TFieldDefs;
begin
  Result := FQuery.FieldDefs;
end;

function TdSQLdbQueryBroker.GetFields: TFields;
begin
  Result := FQuery.Fields;
end;

function TdSQLdbQueryBroker.GetModified: Boolean;
begin
  Result := FQuery.Modified;
end;

function TdSQLdbQueryBroker.GetParams: TParams;
begin
  Result := FQuery.Params;
end;

function TdSQLdbQueryBroker.GetPosition: Int64;
begin
  Result := FQuery.RecNo;
end;

function TdSQLdbQueryBroker.GetSQL: TStrings;
begin
  Result := FQuery.SQL;
end;

function TdSQLdbQueryBroker.GetState: TDataSetState;
begin
  Result := FQuery.State;
end;

function TdSQLdbQueryBroker.GetNulls: Boolean;
begin
  Result := FNulls;
end;

function TdSQLdbQueryBroker.GetUseUtf8: Boolean;
begin
  Result := FUseUtf8;
end;

procedure TdSQLdbQueryBroker.SetActive(const AValue: Boolean);
begin
  FQuery.Active := AValue;
end;

procedure TdSQLdbQueryBroker.SetConnection(AValue: TObject);
begin
  if Assigned(AValue) and (AValue is TSQLConnector) then
  begin
    FCon := AValue as TSQLConnector;
    FQuery.DataBase := FCon;
    FQuery.Transaction := FCon.Transaction;
  end
  else
  begin
    FCon := nil;
    FQuery.Transaction := nil;
    FQuery.DataBase := nil;
  end;
end;

procedure TdSQLdbQueryBroker.SetDataSource(AValue: TDataSource);
begin
  FQuery.DataSource := AValue;
end;

procedure TdSQLdbQueryBroker.SetPosition(const AValue: Int64);
begin
  FQuery.RecNo := AValue;
end;

procedure TdSQLdbQueryBroker.SetNulls(const AValue: Boolean);
begin
  FNulls := AValue;
end;

procedure TdSQLdbQueryBroker.SetUseUtf8(const AValue: Boolean);
begin
  FUseUtf8 := AValue;
end;

procedure TdSQLdbQueryBroker.ApplyUpdates;
begin
  FQuery.ApplyUpdates(0);
end;

procedure TdSQLdbQueryBroker.CancelUpdates;
begin
  FQuery.CancelUpdates;
end;

procedure TdSQLdbQueryBroker.Apply;
begin
  if Assigned(FCon) and FCon.Transaction.Active then
    try
      if FQuery.Modified then
        FQuery.ApplyUpdates(0);
      FCon.Transaction.Commit;
    except
      FCon.Transaction.Rollback;
      raise;
    end;
end;

procedure TdSQLdbQueryBroker.ApplyRetaining;
begin
  if Assigned(FCon) and FCon.Transaction.Active then
  try
    if FQuery.Modified then
      FQuery.ApplyUpdates(0);
    FCon.Transaction.CommitRetaining;
  except
    FCon.Transaction.RollbackRetaining;
    raise;
  end;
end;

procedure TdSQLdbQueryBroker.Undo;
begin
  if Assigned(FCon) and FCon.Transaction.Active then
  begin
    if FQuery.Modified then
      FQuery.CancelUpdates;
    FCon.Transaction.Rollback;
  end;
end;

procedure TdSQLdbQueryBroker.UndoRetaining;
begin
  if Assigned(FCon) and FCon.Transaction.Active then
  begin
    if FQuery.Modified then
      FQuery.CancelUpdates;
    FCon.Transaction.RollbackRetaining;
  end;
end;

procedure TdSQLdbQueryBroker.Commit;
begin
  if Assigned(FCon) and FCon.Transaction.Active then
    try
      FCon.Transaction.Commit;
    except
      FCon.Transaction.Rollback;
      raise;
    end;
end;

procedure TdSQLdbQueryBroker.Rollback;
begin
  if Assigned(FCon) and FCon.Transaction.Active then
    FCon.Transaction.Rollback;
end;

procedure TdSQLdbQueryBroker.Append;
begin
  FQuery.Append;
end;

procedure TdSQLdbQueryBroker.Insert;
begin
  FQuery.Insert;
end;

procedure TdSQLdbQueryBroker.Edit;
begin
  FQuery.Edit;
end;

procedure TdSQLdbQueryBroker.Cancel;
begin
  FQuery.Cancel;
end;

procedure TdSQLdbQueryBroker.Delete;
begin
  FQuery.Delete;
end;

procedure TdSQLdbQueryBroker.Open;
begin
  FQuery.Open;
end;

procedure TdSQLdbQueryBroker.Close;
begin
  FQuery.Close;
end;

procedure TdSQLdbQueryBroker.Refresh;
begin
  FQuery.Refresh;
end;

procedure TdSQLdbQueryBroker.First;
begin
  FQuery.First;
end;

procedure TdSQLdbQueryBroker.Prior;
begin
  FQuery.Prior;
end;

procedure TdSQLdbQueryBroker.Next;
begin
  FQuery.Next;
end;

procedure TdSQLdbQueryBroker.Last;
begin
  FQuery.Last;
end;

procedure TdSQLdbQueryBroker.Post;
begin
  FQuery.Post;
end;

procedure TdSQLdbQueryBroker.Execute;
begin
  FQuery.ExecSQL;
end;

function TdSQLdbQueryBroker.RowsAffected: Int64;
begin
  Result := FQuery.RowsAffected;
end;

function TdSQLdbQueryBroker.Locate(const AKeyFields: string;
  const AKeyValues: Variant; const AOptions: TLocateOptions): Boolean;
begin
  Result := FQuery.Locate(AKeyFields, AKeyValues, AOptions);
end;

function TdSQLdbQueryBroker.Param(const AName: string): TParam;
begin
  Result := FQuery.Params.ParamByName(AName);
end;

function TdSQLdbQueryBroker.Field(const AName: string): TField;
begin
  Result := FQuery.Fields.FieldByName(AName);
end;

function TdSQLdbQueryBroker.FieldDef(const AName: string): TFieldDef;
begin
  Result := FQuery.FieldDefs.Find(AName);
end;

function TdSQLdbQueryBroker.Count: Int64;
begin
  Result := FQuery.RecordCount;
end;

function TdSQLdbQueryBroker.IsEmpty: Boolean;
begin
  Result := FQuery.IsEmpty;
end;

function TdSQLdbQueryBroker.GetBookmark: TBookmark;
begin
  Result := FQuery.GetBookmark;
end;

procedure TdSQLdbQueryBroker.GotoBookmark(ABookmark: TBookmark);
begin
  FQuery.GotoBookmark(ABookmark);
end;

end.

