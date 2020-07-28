unit u_libs;

{$mode objfpc}{$H+}
{$modeswitch typehelpers}

interface

uses
  SysUtils, Forms, StdCtrls, dateutils, Dialogs, Controls;

type

  { TPinIntHelpers }

  TPinIntHelpers = type helper for Integer
    function to_s: String;
  end;

  { TPinDblHelpers }

  TPinDblHelpers = type helper for Double
    function to_m: String;
  end;

  { TPinCurHelpers }

  TPinCurHelpers = type helper for Currency
    function to_s: String;
    function to_m: String;
    procedure Increment(AValue: Currency);
  end;

  { TPinStrHelpers }

  TPinStrHelpers = type helper for String
    function up: String;
    function down: String;
    function to_f: Extended;
    function to_i: Integer;
    function to_m: String;
    function raw: String; {=== Retira caracteres especiais (acentos e etc) ===}
    function raw_numbers: String;
    function maskPhone: String;
    function maskCellPone: String;
    function maskCpfCnpj: String;
    function maskCep: String;
  end;

  { TPinCaptionHelpers }

  TPinCaptionHelpers = type helper for TCaption
    function to_f: Extended;
    function to_m: String;
    function to_i: Integer;
    function trim: String;
    function raw: String;
    function raw_numbers: String;
    function maskPhone: String;
    function maskCpfCnpj: String;
    function maskCep: String;
  end;

  { TPinDateTimeHelpers }

  TPinDateTimeHelpers = type helper for TDateTime
    function to_s: String;
    function to_s_full: String;
  end;

  TArrayOfString = array of string;

procedure createForm(aClass: TFormClass; aForm: TForm);
procedure createFormWithTag(aClass: TFormClass; aForm: TForm; aTag: PtrInt);
function createFormGetTag(aClass: TFormClass; aForm: TForm): Integer;

{ Functions miscellaneous }
function OnlyAlphaChars(const S: string): string;
function OnlyNumbers(const S: string): string;
function OnlyKeyNumbers(key: char): char;
function OnlyKeyMoney(key: Char): Char;
function RemoveDiacritics(const S: string): string;
function TrimGlobal(const S: String): String;
function Explode(const S: string; const ADelimiter: string = #32;
  const ALimit: Integer = 0): TArrayOfString;
function FirstWord(Text: string): String;
function TwoFirstsWords(Text: string): String;
function NameDayOfWeek(data: TDateTime): string;
function GetTime(linha, base: Integer): String;
function SeparateLeft(Const S, ADelimiter: String): String;
function SeparateRight(const S, ADelimiter: string): string;
function Money(AValue: Double): String;

{ Functions for Phones}
function OnlyKeysPhoneNumbers(Key: char): char;
function GetPhoneWithMask(PhoneNumber: string): string;
function GetCellPhoneWithMask(Number: String): String;

{ Functions for CPF/CNPJ }
function OnlyKeyCPForCNPJNumbers(key: char): char;
function GetCPForCNPJWithMask(CPF_CNPJ: string): string;
function ValidateCPF_CNPJ(Doc: string): boolean;

{ Functions Format CEP (ZIPCode-Brazil)}
function OnlykeyCEPNumbers(key: char): char;
function GetCEPWithMask(CEP: string): string;

{ Functions For Date}
function OnlyKeyDate(key: char): char;
function DateTimeToInteger(d: TDateTime): integer;
function IntegerToDateTime(i: integer): TDateTime;
function GetFirstDayWeek(ADate: TDateTime): TDateTime;
function GetFirstDayMonth(Adate: TDateTime): TDateTime; overload;
function GetFirstDayMonth(AMonth, AYear: Integer): TDateTime; overload;
function GetFirstDayMonthPrevious(Adate: TDateTime): TDateTime;
function GetLastDayMonth(Adate: TDateTime): TDateTime; overload;
function GetLastDayMonth(AMonth, AYear: Integer): TDateTime; overload;
function GetLastDayMonthPrevious(Adate: TDateTime): TDateTime;

{ Functions for Cryptographia }
function EnDecryptString(AValue: String; Chave: Word): String;
function cifra(b: byte; chave, texto: string): string;
function Decifra(b: byte; chave, texto: string): string;

{=== Basics Validations functions ===}
function BasicValidateEAN13(ACode: String): Boolean;
function VerifyNeedUpdateBD(AVersionBD, AVersionApp: String): Boolean;


implementation

procedure createForm(aClass: TFormClass; aForm: TForm);
begin
  Application.CreateForm(aClass, aForm);
  try
    aForm.ShowModal;
  finally
    FreeAndNil(aForm);
  end;
end;

procedure createFormWithTag(aClass: TFormClass; aForm: TForm; aTag: PtrInt);
begin
  Application.CreateForm(aClass, aForm);
  try
    aForm.Tag := aTag;
    aForm.ShowModal;
  finally
    FreeAndNil(aForm);
  end;
end;

function createFormGetTag(aClass: TFormClass; aForm: TForm): Integer;
begin
  Application.CreateForm(aClass, aForm);
  Result := 0;
  try
    aForm.ShowModal;
  finally
    Result := aForm.Tag;
    FreeAndNil(aForm);
  end;
end;

function OnlyAlphaChars(const S: string): string;
var
  PSrc, PDest: PChar;
  I: integer;
begin
  SetLength(Result, Length(S));
  PSrc := PChar(S);
  PDest := PChar(Result);
  I := 0;
  while PSrc^ <> #0 do
  begin
    if PSrc^ in ['a'..'z', 'A'..'Z'] then
    begin
      PDest^ := PSrc^;
      Inc(PDest);
      Inc(I);
    end;
    Inc(PSrc);
  end;
  SetLength(Result, I);
end;

function OnlyNumbers(const S: string): string;
var
  I: integer;
  PSrc, PDest: PChar;
begin
  SetLength(Result, Length(S));
  PSrc := PChar(S);
  PDest := PChar(Result);
  I := 0;
  while PSrc^ <> #0 do
  begin
    if PSrc^ in ['0'..'9'] then
    begin
      PDest^ := PSrc^;
      Inc(PDest);
      Inc(I);
    end;
    Inc(PSrc);
  end;
  SetLength(Result, I);
end;

function OnlyKeyNumbers(key: char): char;
begin
  //Aceita números, Del, Backspace e Enter
  if not (Key in ['0'..'9', #8, #127, #13]) then
    key := #0;
  Result := Key;
end;

function OnlyKeyMoney(key: Char): Char;
begin
   //Aceita números, vírgula, Del, Backspace e Enter
   if not (Key in ['0'..'9', #44, #8, #127, #13]) then
    key := #0;
  Result := Key;
end;

function RemoveDiacritics(const S: string): string;
var
  F: boolean;
  I: SizeInt;
  PS, PD: PChar;
begin
  SetLength(Result, Length(S));
  PS := PChar(S);
  PD := PChar(Result);
  I := 0;
  while PS^ <> #0 do
  begin
    F := PS^ = #195;
    if F then
      case PS[1] of
        #128..#134: PD^ := 'A';
        #135: PD^ := 'C';
        #136..#139: PD^ := 'E';
        #140..#143: PD^ := 'I';
        #144: PD^ := 'D';
        #145: PD^ := 'N';
        #146..#150, #152: PD^ := 'O';
        #151: PD^ := 'x';
        #153..#156: PD^ := 'U';
        #157: PD^ := 'Y';
        #158: PD^ := 'P';
        #159: PD^ := 's';
        #160..#166: PD^ := 'a';
        #167: PD^ := 'c';
        #168..#171: PD^ := 'e';
        #172..#175: PD^ := 'i';
        #176: PD^ := 'd';
        #177: PD^ := 'n';
        #178..#182, #184: PD^ := 'o';
        #183: PD^ := '-';
        #185..#188: PD^ := 'u';
        #190: PD^ := 'p';
        #189, #191: PD^ := 'y';
        else
          F := False;
      end;
    if F then
      Inc(PS)
    else
      PD^ := PS^;
    Inc(I);
    Inc(PD);
    Inc(PS);
  end;
  SetLength(Result, I);
end;

function TrimGlobal(const S: String): String;
var
  i: Integer;
begin
  for i := 1 to Length(S) do
    if S[i] <> #32 then
      Result := Result+S[i];
end;

function Explode(const S: string; const ADelimiter: string;
  const ALimit: Integer): TArrayOfString;
var
  PFar, PSrc: PChar;
  VLen, VSepLen, VIndex: Integer;
begin
  SetLength(Result, 0);
  if (S = '') or (ALimit < 0) then
    Exit;
  if ADelimiter = '' then
  begin
    SetLength(Result, 1);
    Result[0] := S;
    Exit;
  end;
  VSepLen := Length(ADelimiter);
  VLen := ALimit;
  SetLength(Result, VLen);
  VIndex := 0;
  PSrc := PChar(S);
  while PSrc^ <> #0 do
  begin
    PFar := PSrc;
    PSrc := StrPos(PSrc, PChar(ADelimiter));
    if (PSrc = nil) or ((ALimit > 0) and (VIndex = ALimit - 1)) then
      PSrc := StrEnd(PFar);
    if VIndex >= VLen then
    begin
      Inc(VLen, 5);
      SetLength(Result, VLen);
    end;
    SetString(Result[VIndex], PFar, PSrc - PFar);
    Inc(VIndex);
    if PSrc^ <> #0 then
      Inc(PSrc, VSepLen);
  end;
  if VIndex < VLen then
    SetLength(Result, VIndex);
end;

function FirstWord(Text: string): String;
var
  words: TArrayOfString;
begin
  Result := '';
  words := Explode(Text);
  Result := words[0];
end;

function TwoFirstsWords(Text: string): String;
var
  words: TArrayOfString;
begin
  Result := '';
  words := Explode(Trim(Text));
  if (Length(Trim(Text)) > Length(words[0])) then
    Result := words[0] + ' ' + words[1]
  else
    Result := words[0];
end;

{Retorna dia da semana}
function NameDayOfWeek(data: TDateTime): string;
var
  InDay: Integer;
  numDayOfWeek: array [1..7] of String[13];
begin
{ Dias da Semana }
  numDayOfWeek[1] := 'Domingo';
  numDayOfWeek[2] := 'Segunda-feira';
  numDayOfWeek[3] := 'Terça-feira';
  numDayOfWeek[4] := 'Quarta-feira';
  numDayOfWeek[5] := 'Quinta-feira';
  numDayOfWeek[6] := 'Sexta-feira';
  numDayOfWeek[7] := 'Sábado';
  InDay := DayOfWeek(data);
  Result := numDayOfWeek[InDay];
end;

function GetTime(linha, base: Integer): String;
var
  hora, minuto: Integer;
begin
  hora := (linha*30+base) div 60;
  minuto := (linha*30+base) - (hora*60);
  Result := Format('%d:%2.2d', [hora, minuto]);
end;

function SeparateLeft(const S, ADelimiter: String): String;
var
  P: SizeInt;
begin
  P := Pos(ADelimiter, S);
  if P > 0 then
    Result := Copy(S, 1, P-1)
  else
    Result := S;
end;

function SeparateRight(const S, ADelimiter: string): string;
var
  P: SizeInt;
begin
  P := Pos(ADelimiter, S);
  if P > 0 then
    P := P + Length(ADelimiter) - 1;
  Result := Copy(S, P + 1, Length(S) - P);
end;

function Money(AValue: Double): String;
begin
  Result := FormatFloat('R$ ###,##0.00', AValue);
end;

function OnlyKeysPhoneNumbers(Key: char): char;
begin
  if not (Key in ['0'..'9', #8, #127, #40, #41, #45]) then
    key := #0;
  Result := Key;
end;

function GetPhoneWithMask(PhoneNumber: string): string;
begin
  PhoneNumber := OnlyNumbers(PhoneNumber);
  case Length(PhoneNumber) of
    8, 9: Insert('-', PhoneNumber, Length(PhoneNumber) - 3);
    10, 11:
    begin
      Insert('-', PhoneNumber, Length(PhoneNumber) - 3);
      Insert('(', PhoneNumber, 1);
      Insert(')', PhoneNumber, 4);
      Insert(' ', PhoneNumber, 5);
    end;
  end;
  Result := PhoneNumber;
end;

function GetCellPhoneWithMask(Number: String): String;
begin
  Number := OnlyNumbers(Number);
  case Length(Number) of
    9: Insert('-', Number, Length(Number) - 3);
    11, 12:
    begin
      Insert('-', Number, Length(Number) - 3);
      Insert('(', Number, 1);
      Insert(')', Number, 4);
      Insert(' ', Number, 5);
    end;
  end;
  Result := Number;
end;

function OnlyKeyCPForCNPJNumbers(key: char): char;
begin
  if not (key in ['0'..'9', #8, #127, #45, #46, #47]) then
    key := #0;
  Result := key;
end;

function GetCPForCNPJWithMask(CPF_CNPJ: string): string;
begin
  CPF_CNPJ := OnlyNumbers(CPF_CNPJ);
  case Length(CPF_CNPJ) of
    11:
    begin
      Insert('.', CPF_CNPJ, 4);
      Insert('.', CPF_CNPJ, 8);
      Insert('-', CPF_CNPJ, 12);
    end;
    14:
    begin
      Insert('.', CPF_CNPJ, 3);
      Insert('.', CPF_CNPJ, 7);
      Insert('/', CPF_CNPJ, 11);
      Insert('-', CPF_CNPJ, 16);
    end;
  end;
  Result := CPF_CNPJ;
end;

function ValidateCPF_CNPJ(Doc: string): boolean;
var
  Digits: array [1..14] of integer;
  cDV, iDV, aDoc: string;
begin
  Doc := OnlyNumbers(Doc);
  if (Length(Doc) in [11,14])  then
  begin
    case Length(Doc) of
      11:
      begin;
        aDoc := Copy(Doc, 1, 9);
        iDV := Copy(Doc, 10, 2);
        Digits[1] := StrToInt(aDoc[1]);
        Digits[2] := StrToInt(aDoc[2]);
        Digits[3] := StrToInt(aDoc[3]);
        Digits[4] := StrToInt(aDoc[4]);
        Digits[5] := StrToInt(aDoc[5]);
        Digits[6] := StrToInt(aDoc[6]);
        Digits[7] := StrToInt(aDoc[7]);
        Digits[8] := StrToInt(aDoc[8]);
        Digits[9] := StrToInt(aDoc[9]);

        Digits[10] := 11 - (((Digits[1] * 10) + (Digits[2] * 9) +
          (Digits[3] * 8) + (Digits[4] * 7) + (Digits[5] * 6) +
          (Digits[6] * 5) + (Digits[7] * 4) + (Digits[8] * 3) +
          (Digits[9] * 2)) mod 11);

        if Digits[10] > 9 then
          Digits[10] := 0;

        Digits[11] := 11 - (((Digits[1] * 11) + (Digits[2] * 10) +
          (Digits[3] * 9) + (Digits[4] * 8) + (Digits[5] * 7) +
          (Digits[6] * 6) + (Digits[7] * 5) + (Digits[8] * 4) +
          (Digits[9] * 3) + (Digits[10] * 2)) mod 11);

        if Digits[11] > 9 then
          Digits[11] := 0;

        cDV := IntToStr(Digits[10]) + IntToStr(Digits[11]);
        if cDV = iDV then
          Result := True
        else
          Result := False;

      end;
      14:
      begin
        aDoc := Copy(Doc, 1, 12);
        iDV := Copy(Doc, 13, 2);
        digits[1] := StrToInt(Doc[1]);
        digits[2] := StrToInt(Doc[2]);
        digits[3] := StrToInt(Doc[3]);
        digits[4] := StrToInt(Doc[4]);
        digits[5] := StrToInt(Doc[5]);
        digits[6] := StrToInt(Doc[6]);
        digits[7] := StrToInt(Doc[7]);
        digits[8] := StrToInt(Doc[8]);
        digits[9] := StrToInt(Doc[9]);
        digits[10] := StrToInt(Doc[10]);
        digits[11] := StrToInt(Doc[11]);
        digits[12] := StrToInt(Doc[12]);

        digits[13] := 11 - (( (digits[1] * 5) + (digits[2] * 4) +
          (digits[3] * 3) + (digits[4] * 2) + (digits[5] * 9) +
          (digits[6] * 8) + (digits[7] * 7) + (digits[8] * 6) +
          (digits[9] * 5) + (digits[10] * 4) + (digits[11] * 3) +
          (digits[12] * 2)) mod 11);


        if digits[13] > 9 then
          digits[13] := 0;

        digits[14] := 11 - (((digits[1] * 6) + (digits[2] * 5) +
          (digits[3] * 4) + (digits[4] * 3) + (digits[5] * 2) +
          (digits[6] * 9) + (digits[7] * 8) + (digits[8] * 7) +
          (digits[9] * 6) + (digits[10] * 5) + (digits[11] * 4) +
          (digits[12] * 3) + (digits[13] * 2)) mod 11);


        if digits[14] > 9 then
          digits[14] := 0;
        cDV := IntToStr(digits[13])+IntToStr(digits[14]);
        if cDV = iDV then
          Result := True
        else
          Result := False;
      end;
    end;
  end
  else
    Result := False;
end;

function OnlykeyCEPNumbers(key: char): char;
begin
  //Aceita números, hifem, Del e Backspace
  if not (key in ['0'..'9', #8, #127, #45]) then
    key := #0;
  Result := key;
end;

function GetCEPWithMask(CEP: string): string;
begin
  CEP := OnlyNumbers(CEP);
  case Length(CEP) of
    5: CEP := CEP + '-000';
    8: Insert('-', CEP, 6);
  end;
  Result := CEP;
end;

function OnlyKeyDate(key: char): char;
begin
  //Aceita números, barra, hifem, Del e Backspace
  if not (key in ['0'..'9', #8, #127, #45, #47]) then
    key := #0;
  Result := key;
end;

function DateTimeToInteger(d: TDateTime): integer;
begin
  Result := Trunc((d - 25569) * 86400);
end;

function IntegerToDateTime(i: integer): TDateTime;
begin
  Result := (i / 86400) + 25569;
end;

function GetFirstDayWeek(ADate: TDateTime): TDateTime;
begin
  Result := ADate - DayOfWeek(ADate) + 1;
end;

function GetFirstDayMonth(Adate: TDateTime): TDateTime;
begin
  Result := EncodeDate(YearOf(Adate), MonthOf(Adate), 1);
end;

function GetFirstDayMonth(AMonth, AYear: Integer): TDateTime;
begin
  Result := EncodeDate(AYear, AMonth, 1);
end;

function GetFirstDayMonthPrevious(Adate: TDateTime): TDateTime;
begin
  if MonthOf(Adate) <> 1 then
    Result := EncodeDate(YearOf(Adate), MonthOf(Adate) - 1, 1)
  else
    Result := EncodeDate(YearOf(Adate) - 1, 12, 1);
end;

function GetLastDayMonth(Adate: TDateTime): TDateTime;
begin
  Result := EncodeDate(YearOf(Adate), MonthOf(Adate), DaysInMonth(Adate));
end;

function GetLastDayMonth(AMonth, AYear: Integer): TDateTime;
begin
  Result := EncodeDate(AYear, AMonth, DaysInAMonth(AYear, AMonth));
end;

function GetLastDayMonthPrevious(Adate: TDateTime): TDateTime;
var
  M: Word;
begin
  M := MonthOf(Adate);
  if M <> 1 then
    Result := EncodeDate(YearOf(Adate), M - 1, DaysInAMonth(YearOf(Date), M - 1))
  else
    Result := EncodeDate(YearOf(Adate) - 1, 12, 31);
end;

function EnDecryptString(AValue: String; Chave: Word): String;
var
  i: Integer;
  VOutValue: String;
begin
  VOutValue := '';
  for i := 1 to Length(AValue) do
    VOutValue := VOutValue + char(Not(ord(AValue[I])- Chave));
  Result := VOutValue;
end;


{ constante alfanumerico }
const
  AlfNum: string = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  { potença }
function Pot(X, E: longint): longint;
var
  p, i: longint;
begin
  p := 1;
  if E = 0 then
    p := 1
  else
    for i := 1 to E do
      p := p * X;
  Pot := p;
end;

{ busca o length maximo para base }
function lenbase(b: byte): byte;
var
  i, j: INTEGER;
  CH, D: INTEGER;
  res: string;
begin
  CH := 255;
  if b < 2 then
    b := 2;
  if b > length(AlfNum) then
    b := length(AlfNum);
  if (CH = 0) then
    res := '0'
  else
  begin
    res := '';
    i := 0;
    while Pot(b, i + 1) <= CH do
      i := i + 1;
    for j := 0 to i do
    begin
      D := CH div Pot(b, i - j);
      res := res + AlfNum[D + 1];
      CH := CH - (D * Pot(b, i - j));
    end;
  end;
  result := length(res);
end;

{ de char para base }
function Char2Base(b, CH, len: INTEGER): string;
var
  i, j, D: INTEGER;
begin
  if b < 2 then
    b := 2;
  if b > length(AlfNum) then
    b := length(AlfNum);
  if (CH = 0) then
    result := '0'
  else
  begin
    result := '';
    i := 0;
    while Pot(b, i + 1) <= CH do
      i := i + 1;
    for j := 0 to i do
    begin
      D := CH div Pot(b, i - j);
      result := result + AlfNum[D + 1];
      CH := CH - (D * Pot(b, i - j));
    end;
  end;
  for i := length(result) + 1 to len do
    result := '0' + result;
end;

{ de base para char }
function Base2Char(b: byte; NUM: string): byte;
var
  j: INTEGER;
  dec: INTEGER;
begin
  dec := 0;
  for j := 1 to length(NUM) do
    dec := dec + (pos(NUM[j], AlfNum) - 1) * Pot(b, length(NUM) - j);
  result := dec;
end;

{ cifrando texto requer base e chave }
function cifra(b: byte; chave, texto: string): string;
var
  X: INTEGER;
  CH, PP: byte;
  len: byte;
begin
  chave := chave + '1982';
  len := lenbase(b);
  result := '';
  PP := 0;
  for X := 1 to length(texto) do
  begin
    CH := ord(texto[X]);
    PP := ord(chave[X mod length(chave) + 1]);
    CH := byte(CH + PP);
    result := result + Char2Base(b, CH, len);
  end;
end;

{ decifrando texto requer base e chave }
function Decifra(b: byte; chave, texto: string): string;
var
  X: INTEGER;
  len: byte;
  ptxt: string;
  CH, PP: byte;
begin
  chave := chave + '1982';
  len := lenbase(b);
  result := '';
  PP := 0;
  for X := 1 to length(texto) div len do
  begin
    ptxt := copy(texto, X * len - len + 1, len);
    result := result + char(Base2Char(b, ptxt));
  end;
  for X := 1 to length(result) do
  begin
    CH := ord(result[X]);
    PP := ord(chave[X mod length(chave) + 1]);
    CH := byte(CH - PP);
    result[X] := char(CH);
  end;
end;

function BasicValidateEAN13(ACode: String): Boolean;
begin
  ACode := OnlyNumbers(ACode);
  Result := (Length(ACode)=0) or (Length(ACode)>12);
end;

function VerifyNeedUpdateBD(AVersionBD, AVersionApp: String): Boolean;
var
  na, nb: array[1..4] of Integer;
  i, Ps: Integer;
  sStr, sVer1, sVer2: String;
begin
  sVer1 := Trim(AVersionApp);
  sVer2 := Trim(AVersionBD);

  if (Pos('.', sVer1) <= 0) or (Pos('.', sVer2) <= 0) then
  begin
    Result := False;
    Exit;
  end;

  {=== Decompondo a versão candidata ===}
  sStr := sVer1;
  for i := 1 to 4 do
  begin
    Ps := Pos('.', sStr);
    if Ps > 0 then
      na[i] := StrToInt(Copy(sStr, 1, Ps - 1))
    else
      na[i] := StrToInt(sStr);
    sStr := Copy(sStr, Ps + 1, Length(sStr));
  end;

  {=== Decompondo a versão atual ===}
  sStr := sVer2;
  for i := 1 to 4 do
  begin
    Ps := Pos('.', sStr);
    if Ps > 0 then
      nb[i] := StrToInt(Copy(sStr, 1, Ps - 1))
    else
      nb[i] := StrToInt(sStr);
    sStr := Copy(sStr, Ps + 1, Length(sStr));
  end;

  Result := False;
  {=== Comparando as versões ===}
  if (na[1] > nb[1]) then
    Result := True;
  if (na[1] >= nb[1]) and (na[2] > nb[2]) then
    Result := True;
  if (na[1] >= nb[1]) and (na[2] >= nb[2]) and (na[3] > nb[3]) then
    Result := True;
  if (na[1] >= nb[1]) and (na[2] >= nb[2]) and (na[3] >= nb[3]) and (na[4] > nb[4]) then
    Result := True;
end;
{ TPinDateTimeHelpers }

function TPinDateTimeHelpers.to_s: String;
begin
  Result := FormatDateTime('d/m/yyyy', Self);
end;

function TPinDateTimeHelpers.to_s_full: String;
begin
  Result := FormatDateTime('d/m/yyyy - hh:nn:zz', Self);
end;

{ TPinCaptionHelpers }

function TPinCaptionHelpers.to_f: Extended;
begin
  Result := StrToFloatDef(Self, 0);
end;

function TPinCaptionHelpers.to_m: String;
begin
  Result := FormatFloat('### ###,##0.00', Self.to_f);
end;

function TPinCaptionHelpers.to_i: Integer;
begin
  Result := StrToIntDef(Self, 0);
end;

function TPinCaptionHelpers.trim: String;
begin
  Result := TrimGlobal(Self);
end;

function TPinCaptionHelpers.raw: String;
begin
  Result := RemoveDiacritics(Self);
end;

function TPinCaptionHelpers.raw_numbers: String;
begin
  Result := OnlyNumbers(Self);
end;

function TPinCaptionHelpers.maskPhone: String;
begin
  Result := GetPhoneWithMask(Self);
end;

function TPinCaptionHelpers.maskCpfCnpj: String;
begin
  Result := GetCPForCNPJWithMask(Self);
end;

function TPinCaptionHelpers.maskCep: String;
begin
  Result := GetCEPWithMask(Self);
end;

{ TPinCurHelpers }

function TPinCurHelpers.to_s: String;
begin
  Result := CurrToStr(Self);
end;

function TPinCurHelpers.to_m: String;
begin
  Result := FormatFloat('### ###,##0.00', Self);
end;

procedure TPinCurHelpers.Increment(AValue: Currency);
begin
  Self := Self + AValue;
end;

{ TPinDblHelpers }

function TPinDblHelpers.to_m: String;
begin
  Result := FormatFloat('### ###,##0.00', Self);
end;

{ TPinStrHelpers }

function TPinStrHelpers.up: String;
begin
  Result := UpperCase(Self);
end;

function TPinStrHelpers.down: String;
begin
  Result := LowerCase(Self);
end;

function TPinStrHelpers.to_f: Extended;
begin
  Result := StrToFloatDef(Self, 0);
end;

function TPinStrHelpers.to_i: Integer;
begin
  Result := StrToIntDef(Self, 0);
end;

function TPinStrHelpers.to_m: String;
begin
  Result :=  FormatFloat('### ###,##0.00', StrToFloatDef(Self, 0));
end;

function TPinStrHelpers.raw: String;
begin
  Result := RemoveDiacritics(Self);
end;

function TPinStrHelpers.raw_numbers: String;
begin
  Result := OnlyNumbers(Self);
end;

function TPinStrHelpers.maskPhone: String;
begin
  Result := GetPhoneWithMask(Self);
end;

function TPinStrHelpers.maskCellPone: String;
begin
  Result := GetCellPhoneWithMask(Self);
end;

function TPinStrHelpers.maskCpfCnpj: String;
begin
  Result := GetCPForCNPJWithMask(Self);
end;

function TPinStrHelpers.maskCep: String;
begin
  Result := GetCEPWithMask(Self);
end;

{ TPinIntHelpers }

function TPinIntHelpers.to_s: String;
begin
  Result := IntToStr(Self);
end;



end.
