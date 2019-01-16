unit personobjs;

{$mode objfpc}{$H+}

interface

uses
  dbutils, dOpf, dSQLdbBroker, sysutils;

type
  EPerson = class(Exception);

  { TPerson }

  TPerson = class(TObject)
  private
    FId: Int64;
    FName: string;
  public
    procedure Validate;
  published
    property Id: Int64 read FId write FId;
    property Name: string read FName write FName;
  end;

  { TPersonOpf }

  TPersonOpf = class(specialize TdGSQLdbEntityOpf<TPerson>)
  protected
    procedure DoUpdating(AEntity: T3); override;
  public
    constructor Create; overload; virtual;
  end;

implementation

{ TPerson }

procedure TPerson.Validate;
begin
  if Trim(FName) = '' then
    raise EPerson.Create('Field "Name" must not be empty.');
end;

{ TPersonOpf }

constructor TPersonOpf.Create;
begin
  inherited Create(dbutils.con, 'person');
end;

procedure TPersonOpf.DoUpdating(AEntity: T3);
begin
  case UpdateKind of
    ukAdd, ukModify: AEntity.Validate;
  end;
end;

end.

