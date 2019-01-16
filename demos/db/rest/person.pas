unit person;

{$mode objfpc}{$H+}

interface

uses
  dSQLdbBroker, dbutils, SysUtils;

type
  EPerson = class(Exception);

  { TPerson }

  TPerson = class
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

  TPersonOpf = class(specialize TdGSQLdbOpf<TPerson>)
  public
    constructor Create; overload;
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

end.

