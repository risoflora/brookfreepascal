(*
  AlgEx plugin.
  Copyright (C) 2012-2014 Silvio Clecio.

  Please see the LICENSE file.
*)

unit AlgEx;

{$mode objfpc}{$H+}

interface

uses
  Math, SysUtils;

type
  PStack = ^TStack;

  TStack = record
    Next, Prev: PStack;
    Token: Byte;
    Number: Extended;
    Func: string[20];
  end;

  TAlgEx = class
  private
    FError: Byte;
    FStack: PStack;
    FTokenStackTail: PStack;
    FTokenStackHead: PStack;
    FPrevToken: Byte;
    FRPN: string;
    FResult: Extended;
    FExpression: string;
    function PriorityToken(AToken: Byte): Integer;
    procedure PushStack(AToken: Byte);
    procedure PopStack;
    procedure PushToken;
    procedure PushTokenNumber(AValue: Extended);
    procedure FreeStack;
    procedure FreeTokenStack;
    procedure Tokenize(const AValue: string);
    procedure ProcessTokens;
  public
    function TokenToStr(APStack: PStack): string;
    procedure Calculate(const AValue: string);
    procedure CalculateGraph(const AValue: string; AExtended: Extended);
    function ErrorStr: string;
    property Expression: string read FExpression;
    property RPN: string read FRPN;
    property Result: Extended read FResult;
    property Error: Byte read FError;
  end;

const
  NO_ERROR = 0;
  EMPTY_ERROR = 1;
  EXPR_ERROR = 2;
  SOLVE_ERROR = 3;
  DIV_BY_ZERO_ERROR = 4;
  FUNC_ERROR = 5;
  FUNC_NOT_FOUND_ERROR = 6;

implementation

const
  TOKEN_UNKNOWN = Byte(-1);
  TOKEN_NUMBER = 0;
  TOKEN_FUNC = 1;
  TOKEN_BOPEN = 2;
  TOKEN_BCLOSE = 3;
  TOKEN_PLUS = 4;
  TOKEN_MINUS = 5;
  TOKEN_MUL = 6;
  TOKEN_DIVR = 7;
  TOKEN_POW = 8;

function TAlgEx.PriorityToken(AToken: Byte): Integer;
begin
  case AToken of
    TOKEN_BOPEN: Result := 0;
    TOKEN_BCLOSE: Result := 1;
    TOKEN_PLUS, TOKEN_MINUS: Result := 2;
    TOKEN_MUL, TOKEN_DIVR: Result := 3;
    TOKEN_POW: Result := 4;
    TOKEN_FUNC: Result := 5;
    else
      Result := -1;
  end;
end;

procedure TAlgEx.PushStack(AToken: Byte);
var
  P: PStack;
begin
  New(P);
  P^.Next := FStack;
  P^.Token := AToken;
  FStack := P;
end;

procedure TAlgEx.PopStack;
var
  P: PStack;
begin
  P := FStack;
  FStack := FStack^.Next;
  Dispose(P);
end;

procedure TAlgEx.PushToken;
begin
  if FTokenStackHead = nil then
  begin
    New(FTokenStackHead);
    FTokenStackTail := FTokenStackHead;
    FTokenStackTail^.Prev := nil;
  end
  else
  begin
    New(FTokenStackTail^.Next);
    FTokenStackTail^.Next^.Prev := FTokenStackTail;
    FTokenStackTail := FTokenStackTail^.Next;
  end;
  FTokenStackTail^.Next := nil;
  FTokenStackTail^.Token := FStack^.Token;
  if FStack^.Token = TOKEN_FUNC then
    FTokenStackTail^.Func := FStack^.Func;
end;

procedure TAlgEx.PushTokenNumber(AValue: Extended);
begin
  if FTokenStackHead = nil then
  begin
    New(FTokenStackHead);
    FTokenStackTail := FTokenStackHead;
    FTokenStackTail^.Prev := nil;
  end
  else
  begin
    New(FTokenStackTail^.Next);
    FTokenStackTail^.Next^.Prev := FTokenStackTail;
    FTokenStackTail := FTokenStackTail^.Next;
  end;
  FTokenStackTail^.Next := nil;
  FTokenStackTail^.Token := TOKEN_NUMBER;
  FTokenStackTail^.Number := AValue;
end;

function TAlgEx.TokenToStr(APStack: PStack): string;
begin
  case APStack^.Token of
    TOKEN_NUMBER: Result := FloatToStr(APStack^.Number);
    TOKEN_FUNC: Result := APStack^.Func;
    TOKEN_BOPEN: Result := '(';
    TOKEN_BCLOSE: Result := ')';
    TOKEN_PLUS: Result := '+';
    TOKEN_MINUS: Result := '-';
    TOKEN_MUL: Result := '*';
    TOKEN_DIVR: Result := '/';
    TOKEN_POW: Result := '^';
    else
      Result := 'UNK';
  end;
  Result += ' ';
end;

procedure TAlgEx.FreeStack;
var
  P: PStack;
begin
  while FStack <> nil do
  begin
    P := FStack^.Next;
    Dispose(FStack);
    FStack := P;
  end;
end;

procedure TAlgEx.FreeTokenStack;
var
  P: PStack;
begin
  while FTokenStackHead <> nil do
  begin
    P := FTokenStackHead^.Next;
    Dispose(FTokenStackHead);
    FTokenStackHead := P;
  end;
end;

procedure TAlgEx.Tokenize(const AValue: string);

  procedure HandleToken(const Value: string);
  var
    VToken: Byte;
  begin
    {Convert Value into VToken}
    case Value[1] of
      '0'..'9',
      ',': VToken := TOKEN_NUMBER;
      '(': VToken := TOKEN_BOPEN;
      ')': VToken := TOKEN_BCLOSE;
      '+': VToken := TOKEN_PLUS;
      '-': VToken := TOKEN_MINUS;
      '*': VToken := TOKEN_MUL;
      '/': VToken := TOKEN_DIVR;
      '^': VToken := TOKEN_POW;
      ' ': Exit;
      'a'..'z': VToken := TOKEN_FUNC;
      else
      begin
        FError := EXPR_ERROR;
        Exit;
      end;
    end;
    if VToken <> TOKEN_NUMBER then
    begin
      if FStack = nil then
      begin
        if (VToken = TOKEN_MINUS) and (FPrevToken <> TOKEN_NUMBER) and
          (FPrevToken <> TOKEN_BCLOSE) then
          PushTokenNumber(0.0);
        PushStack(VToken);
        if VToken = TOKEN_FUNC then
          FStack^.Func := Value;
      end
      else
        case VToken of
          TOKEN_BOPEN:
            PushStack(TOKEN_BOPEN);
          TOKEN_BCLOSE:
          begin
            while (FStack <> nil) and (FStack^.Token <> TOKEN_BOPEN) do
            begin
              PushToken;
              PopStack;
            end;
            if (FStack <> nil) and (FStack^.Token = TOKEN_BOPEN) then
              PopStack;
          end
          else
          begin
            if (FPrevToken = TOKEN_BOPEN) and (VToken = TOKEN_MINUS) then
              PushTokenNumber(0.0);
            while (FStack <> nil) and (PriorityToken(FStack^.Token) >=
                PriorityToken(VToken)) do
            begin
              PushToken;
              PopStack;
            end;
            PushStack(VToken);
            if VToken = TOKEN_FUNC then
              FStack^.Func := Value;
          end;
        end;
    end
    else
      PushTokenNumber(StrToFloat(Value));
    FPrevToken := VToken;
  end;

  procedure HandleRemainder;
  begin
    while (FStack <> nil) do
    begin
      if (FStack^.Token <> TOKEN_BCLOSE) and (FStack^.Token <> TOKEN_BOPEN) then
        PushToken;
      PopStack;
    end;
  end;

var
  I, VOperation, VPrevOperation: Word;
  S: string;
begin
  VOperation := $FFFF;
  FPrevToken := TOKEN_UNKNOWN;
  FTokenStackHead := nil;
  FTokenStackTail := nil;
  FStack := nil;
  S := '';
  for I := 1 to Length(AValue) do
  begin
    VPrevOperation := VOperation;
    {Extract Numbers, Functions, Operators}
    case AValue[I] of
      '0'..'9', ',': VOperation := 0; {Numbers}
      'a'..'z': VOperation := 1; {Functions}
      else
        VOperation := 2; {Operators}
    end;
    if (VPrevOperation = 0) and ((AValue[I] = 'E') or (AValue[I] = 'e')) then
      VOperation := 0;
    if ((VPrevOperation <> VOperation) and (VPrevOperation <> $FFFF)) or
      (VOperation = 2) then
    begin
      if Length(S) > 0 then
      begin
        HandleToken(S);
        if FError <> NO_ERROR then
          Exit;
      end;
      S := '';
    end;
    S := S + AValue[I];
  end;
  if Length(S) > 0 then
  begin
    HandleToken(S);
    if FError <> NO_ERROR then
      Exit;
  end;
  HandleRemainder;
end;

procedure TAlgEx.ProcessTokens;
var
  P, P1, P2: PStack;
begin
  if FTokenStackHead = nil then
  begin
    FError := EMPTY_ERROR;
    Exit;
  end;
  P := FTokenStackHead;
  while P <> nil do
  begin
    FRPN := FRPN + TokenToStr(P) + ' ';
    P := P^.Next;
  end;
  P := FTokenStackHead;
  while FTokenStackHead^.Next <> nil do
  begin
    if P = nil then
    begin
      FError := EXPR_ERROR;
      Exit;
    end;
    case P^.Token of
      TOKEN_NUMBER:
        P := P^.Next;
      TOKEN_FUNC:
      begin
        P1 := P^.Prev;  {a}
        if P1 = nil then
        begin
          FError := EXPR_ERROR;
          Exit;
        end;
        if P^.Func = 'sin' then
          P1^.Number := sin(P1^.Number)
        else if P^.Func = 'cos' then
          P1^.Number := cos(P1^.Number)
        else if P^.Func = 'abs' then
          P1^.Number := abs(P1^.Number)
        else if P^.Func = 'sqr' then
          P1^.Number := sqr(P1^.Number)
        else if P^.Func = 'tan' then
        begin
          if cos(P1^.Number) = 0 then
          begin
            FError := FUNC_ERROR;
            Exit;
          end
          else
            P1^.Number := sin(P1^.Number) / cos(P1^.Number);
        end
        else if P^.Func = 'sqrt' then
        begin
          if P1^.Number < 0 then
          begin
            FError := FUNC_ERROR;
            Exit;
          end
          else
            P1^.Number := sqrt(P1^.Number);
        end
        else
        begin
          FError := FUNC_NOT_FOUND_ERROR;
          Exit;
        end;
        P1^.Next := P^.Next;
        if P^.Next <> nil then
          P^.Next^.Prev := P^.Prev;
        Dispose(P);
        P := P1;
      end;
      else
      begin
        P1 := P^.Prev; {b}
        if P1 = nil then
        begin
          FError := EXPR_ERROR;
          Exit;
        end;
        P2 := P1^.Prev; {a}
        if P2 = nil then
        begin
          FError := EXPR_ERROR;
          Exit;
        end;
        case P^.Token of
          TOKEN_PLUS: P2^.Number := P2^.Number + P1^.Number;
          TOKEN_MINUS: P2^.Number := P2^.Number - P1^.Number;
          TOKEN_MUL: P2^.Number := P2^.Number * P1^.Number;
          TOKEN_DIVR:
            if P1^.Number = 0 then
            begin
              FError := DIV_BY_ZERO_ERROR;
              Exit;
            end
            else
              P2^.Number := P2^.Number / P1^.Number;
          TOKEN_POW:
            if (P2^.Number = 0) and (P1^.Number < 0) then
            begin
              FError := DIV_BY_ZERO_ERROR;
              Exit;
            end
            else
            if (P2^.Number < 0) and (Frac(P1^.Number) <> 0) then
            begin
              FError := SOLVE_ERROR;
              Exit;
            end
            else
              P2^.Number := Power(P2^.Number, P1^.Number);
        end;
        P2^.Next := P^.Next;
        if P^.Next <> nil then
          P^.Next^.Prev := P1^.Prev;
        Dispose(P);
        Dispose(P1);
        P := P2;
      end;
    end;
  end;
  if FTokenStackHead^.Token <> TOKEN_NUMBER then
  begin
    FError := EXPR_ERROR;
    Exit;
  end;
  FResult := FTokenStackHead^.Number;
  Dispose(FTokenStackHead);
  FTokenStackHead := nil;
end;

procedure TAlgEx.Calculate(const AValue: string);
begin
  FResult := 0;
  FRPN := '';
  FError := NO_ERROR;
  FExpression := AValue;
  if Length(AValue) = 0 then
  begin
    FError := EMPTY_ERROR;
    Exit;
  end;
  Tokenize(AValue);
  if FError = NO_ERROR then
  begin
    ProcessTokens;
    if FError <> NO_ERROR then
      FreeTokenStack;
  end
  else
  begin
    FreeStack;
    FreeTokenStack;
  end;
end;

procedure TAlgEx.CalculateGraph(const AValue: string; AExtended: Extended);
begin
  Calculate(StringReplace(AValue, 'x', '(' + FloatToStr(AExtended) + ')',
    [rfReplaceAll]));
end;

function TAlgEx.ErrorStr: string;
begin
  case FError of
    NO_ERROR: Result := 'No error';
    EMPTY_ERROR: Result := 'Empty expression';
    EXPR_ERROR: Result := 'Error in expression';
    SOLVE_ERROR: Result := 'Could not solve expression';
    DIV_BY_ZERO_ERROR: Result := 'Division by zero';
    FUNC_ERROR: Result := 'Error in function';
    FUNC_NOT_FOUND_ERROR: Result := 'Function not found';
    else
      Result := 'Unknown error';
  end;
end;

end.

