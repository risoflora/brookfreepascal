unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  BrookAction, person;

type

  { TPersonRESTAction }

  TPersonRESTAction = class(specialize TBrookGAction<TPerson>)
  private
    FOpf: TPersonOpf;
  public
    constructor Create; overload; override;
    destructor Destroy; override;
    procedure Get; override;
    procedure Post; override;
    procedure Put; override;
    procedure Delete; override;
    property Opf: TPersonOpf read FOpf;
  end;

implementation

{ TPersonRESTAction }

constructor TPersonRESTAction.Create;
begin
  inherited Create;
  FOpf := TPersonOpf.Create;
end;

destructor TPersonRESTAction.Destroy;
begin
  FOpf.Free;
  inherited Destroy;
end;

procedure TPersonRESTAction.Get;
var
  VPerson: TPerson;
  VPersons: TPersonOpf.TEntities;
begin
  VPersons := TPersonOpf.TEntities.Create;
  try
    FOpf.List(VPersons);
    for VPerson in VPersons do
      Write('Id: %d, Name: %s<br />', [VPerson.Id, VPerson.Name]);
  finally
    VPersons.Free;
  end;
end;

procedure TPersonRESTAction.Post;
begin
  Entity.Validate;
  FOpf.Add(Entity);
  FOpf.Apply;
end;

procedure TPersonRESTAction.Put;
begin
  Entity.Validate;
  FOpf.Modify(Entity);
  FOpf.Apply;
end;

procedure TPersonRESTAction.Delete;
begin
  FOpf.Remove(Entity);
  FOpf.Apply;
end;

initialization
  TPersonRESTAction.Register('*');

end.
