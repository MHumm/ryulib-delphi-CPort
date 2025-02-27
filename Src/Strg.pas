Unit Strg;

Interface

uses
  ShLwApi,
  Windows, SysUtils, Classes;

{** AText에서 ABorder를 찾아서 그 전까지 복사한다.
  @param AText 원본 문자열
  @param ABorder 복사를 할 경계선(문자열)
  @param AIgnoreCase ABorder를 찾을 때 대소 문자를 구별할 것인가
  @return ABorder가 없으면 null 문자열을 리턴. 있으면 그 이전까지 복사
*}
function CopyLeft(const AText,ABorder:string; AIgnoreCase:boolean=false):string;

{** AText를 ADelimiter로 잘라서 AIndex번째 문자열을 리턴한다.
  @param AText 원본 문자열
  @param ADelimiter 문자열을 자를 경계선 (문자)
  @param AIndex 잘라진 문자열 중 가져와야 할 순서 (0번부터 시작)
  @return AText를 ADelimiter로 자른 AIndex번째 문자열
*}
function TextInLines(const AText:string; ADelimiter:char; AIndex:integer):string;

function LastString(const AText:string; ACount:integer):string;
function StrPos(SubStr,stText:string; IgnoreCase:boolean=true):integer;
function CharString(Ch:Char; Length:integer):string;
Procedure DeleteChar(var Strg:String; C:Char);

function MiddleStr(Text,stStart,stEnd:string; IgnoreCase:boolean=true):string;

function DeleteLeft(Text,Border:string; IgnoreCase:boolean=true):string;
function DeleteLeftPlus(Text:string; Border:string; IgnoreCase:boolean=true):string;

function DeleteRight(Text:string; Border:string; IgnoreCase:boolean=true):string;
function DeleteRightPlus(Text:string; Border:string; IgnoreCase:boolean=true):string;

Procedure DeleteSpcLeft(var Strg:String);
Procedure DeleteSpcRight(var Strg:String);

function  SetLengthTo(Text,stEnd:string):string;
function  SetLengthBefore(Text,stEnd:string):string;

/// 한글 문자열을 복사한다.  잘림방지
Function  CopyHan(St:String; Count:Integer):String;
Function  CopyHanStr(St:String; Start,No:Integer):String;

Function  CheckJumin(No:String):Boolean;
Function  MakeJuminCRC(No:String):Char;

Function  MoneyStr(Value:int64):String;

Function  MoveDataToHexStr(Src:Pointer; Size:Integer):String;
Function  DataToText(Data:Pointer; DataSize:Integer):String;
Procedure TextToData(Text:String; var Data:Pointer; var DataSize:Integer);

function IndexOf(Selector:string; StrList:array of string):integer;
function StrToPos(Value:string):TPoint;

procedure SaveStringToBuffer(AText:string; var AData:pointer; var ASize:integer);

function CopyLast(const AText:string):char;
procedure SetLastChar(var AText:string; Ch:Char);

function RandomStr(ASize:integer=32):string;

function IntToTimeStr(ATime:integer):string;
function TimeStrToInt(ATime:string):integer;

function MemoryStr(AValue:int64):string;

function ByteValueToSizeString(Value:Int64):string;

function StringPointer(const AText:string):PString;

Implementation

function CopyLeft(const AText,ABorder:string; AIgnoreCase:boolean):string;
var
  iIndex : integer;
begin
  if AIgnoreCase then begin
    iIndex := Pos(LowerCase(ABorder), LowerCase(AText));
  end else begin
    iIndex := Pos(ABorder, AText);
  end;

  if iIndex <= 0 then begin
    Result := '';
    Exit;
  end;

  Result := Copy(AText, 1, iIndex-1);
end;

function TextInLines(const AText:string; ADelimiter:char; AIndex:integer):string;
var
  list : TSTringList;
begin
  Result := '';

  list := TSTringList.Create;
  try
    list.StrictDelimiter := true;
    list.Delimiter := ADelimiter;
    list.DelimitedText := AText;

    if list.Count = 0 then Exit;
    if AIndex >= list.Count then Exit;

    Result := list[AIndex];
  finally
    list.Free;
  end;
end;

function LastString(const AText:string; ACount:integer):string;
begin
  Result := Copy(AText, Length(AText)+1-ACount, ACount);
end;

function StrPos(SubStr,stText:string; IgnoreCase:boolean=true):integer;
begin
  if IgnoreCase then begin
    SubStr := LowerCase(SubStr);
    stText := LowerCase(stText);
  end;

  Result := Pos(SubStr, stText);
end;

Function  GetMiddleStr(stText,stStart,stEnd:String):String;
Var
   iStart, iEnd : Integer;
Begin
  Result:= '';
  iStart:= StrPos(stStart, stText);
  iEnd:=   iStart+StrPos(stEnd, Copy(stText, iStart+Length(stStart)+1, Length(stText)));
  If iStart*iEnd > 0 then
     Result:= Copy(stText, iStart+Length(stStart), iEnd+1-(iStart+Length(stStart)));
End;

Function  CharString(Ch:Char; Length:Integer):String;
var
  Loop: Integer;
Begin
  SetLength(Result, Length);
  for Loop := 1 to Length do Result[Loop] := Ch;
End;

Function  SizeOut(St:String; Size:Integer):String;
Var
   StSize                    : Integer;
Begin
     StSize:= Length(St);
     If StSize > Size then SizeOut:=Copy(St,StSize+1-Size,Size)
     Else SizeOut:=St+CharString(' ',Size-StSize);
End;

Procedure DeleteChar(var Strg:String; C:Char);
Var
   Loop : Integer;
   stTemp : String;
Begin
  stTemp:= Strg;
  Strg:= '';
  For Loop:= 1 to Length(stTemp) do
      If stTemp[Loop] <> C then Strg:= Strg+stTemp[Loop];
End;

function MiddleStr(Text,stStart,stEnd:string; IgnoreCase:boolean=true):string;
var
  src : string;
  iStartPos, iEndPos : Integer;
begin
  Result := '';

  src := Text;
  if IgnoreCase then begin
    src := LowerCase(src);
    stStart := LowerCase(stStart);
    stEnd := LowerCase(stEnd);
  end;

  iStartPos := Pos(stStart, src);
  if iStartPos = 0 then Exit;

  Delete(src,  1, iStartPos + Length(stStart)-1);
  Delete(Text, 1, iStartPos + Length(stStart)-1);

  iEndPos := Pos(stEnd, src);
  if iEndPos = 0 then Exit;

  Result := Copy(Text, 1, iEndPos - 1);
end;

function DeleteLeft(Text,Border:string; IgnoreCase:boolean=true):string;
var
  iPos : Integer;
begin
  Result := Text;

  if IgnoreCase then begin
    Text := LowerCase(Text);
    Border := LowerCase(Border);
  end;

  iPos := Pos(Border, Text);
  if iPos > 0 then Delete(Result, 1, iPos-1);
end;

function DeleteLeftPlus(Text:string; Border:string; IgnoreCase:boolean=true):string;
var
  iPos : Integer;
begin
  Result := Text;

  if IgnoreCase then begin
    Text := LowerCase(Text);
    Border := LowerCase(Border);
  end;

  iPos := Pos(Border, Text);
  if iPos > 0 then Delete(Result, 1, iPos+Length(Border)-1);
end;

function DeleteRight(Text:string; Border:string; IgnoreCase:boolean=true):string;
var
  Loop : Integer;
begin
  Result := Text;

  if IgnoreCase then begin
    Text := LowerCase(Text);
    Border := LowerCase(Border);
  end;

  for Loop := Length(Result) downto 1 do begin
    if Copy(Text, Loop, Length(Border)) = Border then begin
      SetLength(Result, Loop+Length(Border)-1);
      Exit;
    end;
  end;
end;

function DeleteRightPlus(Text:string; Border:string; IgnoreCase:boolean=true):string;
var
  Loop : Integer;
begin
  Result := Text;

  if IgnoreCase then begin
    Text := LowerCase(Text);
    Border := LowerCase(Border);
  end;

  for Loop := Length(Result) downto 1 do begin
    if Copy(Text, Loop, Length(Border)) = Border then begin
      SetLength(Result, Loop-1);
      Exit;
    end;
  end;
end;

Procedure DeleteSpcLeft(var Strg:String);
Begin
  While Copy(Strg, 1, 1) = ' ' do Delete(Strg, 1, 1);
End;

Procedure DeleteSpcRight(Var Strg:String);
Begin
  While Copy(Strg, Length(Strg), 1) = ' ' do Delete(Strg, Length(Strg), 1);
End;

Function  SetLengthTo(Text,stEnd:String):String;
var
  iPos : Integer;
Begin
  Result:= Text;
  iPos:= Pos(stEnd, Result);
  If iPos > 0 then SetLength(Result, iPos);
End;

function  SetLengthBefore(Text,stEnd:string):string;
var
  iPos : Integer;
begin
  Result:= Text;
  iPos:= Pos(stEnd, Result);
  if iPos > 0 then SetLength(Result, iPos-1);
end;

function  CopyHan(St:String; Count:Integer):String;
var
  Loop : Integer;
  sWide : WideString;
  sTemp : string;
begin
  sWide := St;
  sTemp := '';
  Result := '';

  for Loop := 1 to Length(sWide) do begin
    sTemp := sTemp + sWide[Loop];
    if Length(sTemp) > Count then Break;    
    Result := Result + sWide[Loop];
  end;
end;

Function  CopyHanStr(St:String; Start,No:Integer):String;
Var
   iPos : Integer;
Begin
  Result:= CopyHan(St, Start-1);
  iPos:= Length(Result);
  Result:= St;
  Delete(Result, 1, iPos);
  Result:= CopyHan(Result, No+1-Start);
End;

Function  CheckJumin(No:String):Boolean;
Const
     Weight : Packed Array [1..12] of Integer =
            ( 2, 3, 4, 5, 6, 7, 8, 9, 2, 3, 4, 5 );
Var
   Loop, Sum, Rest : Integer;
Begin
  If Length(No) <> 13 then Result:= False
  Else
    Try
       Sum:= 0;
       For Loop:= 1 to  12 do
           Sum:= Sum + StrToInt(No[Loop])*Weight[Loop];
           Rest:= 11-(Sum Mod 11);
           If Rest = 11 then Rest:= 1;
           If Rest = 10 then Rest:= 0;
           Result:= Char(Rest+48) = No[13];
    Except
      Result:= False;
    End;
End;

Function  MakeJuminCRC(No:String):Char;
Const
     Weight : Packed Array [1..12] of Integer =
            ( 2, 3, 4, 5, 6, 7, 8, 9, 2, 3, 4, 5 );
Var
   Loop, Sum, Rest : Integer;
Begin
  If Length(No) <> 12 then Result:= '*'
  Else
    Try
       Sum:= 0;
       For Loop:= 1 to  12 do
           Sum:= Sum + StrToInt(No[Loop])*Weight[Loop];
           Rest:= 11-(Sum Mod 11);
           If Rest = 11 then Rest:= 1;
           If Rest = 10 then Rest:= 0;
           Result:= Char(Rest+48);
    Except
      Result:= '*';
    End;
End;

Function  MoneyStr(Value:int64):String;
Var
  stTemp : String;
Begin
  stTemp:= IntToStr(Value);
  Result:= '';

  While Length(stTemp) > 3 do Begin
    Result:= Copy(stTemp, Length(stTemp)-2, 3) + ',' + Result;
    SetLength(stTemp, Length(stTemp)-3);
  End;

  Result:=stTemp + ',' + Result;

  SetLength(Result, Length(Result)-1);
End;

Function  MoveDataToHexStr(Src:Pointer; Size:Integer):String;
Var
  pData :^Byte;
  Loop : Integer;
Begin
  pData:= Src;
  Result:= '';
  For Loop:= 1 to Size do Begin
    Result:= Result + IntToHex(pData^, 2);
    Inc(pData);
  End;
End;

Function  DataToText(Data:Pointer; DataSize:Integer):String;
var
  ssData : TStringStream;
Begin
  If (Data = Nil) or (DataSize = 0) then Begin
    Result:= '';
    Exit;
  End;

  ssData:= TStringStream.Create('');
  Try
    ssData.Write(Data^, DataSize);
    ssData.Position:= 0;
    Result:= ssData.DataString;
  Finally
    ssData.Free;
  End;
End;

Procedure TextToData(Text:String; var Data:Pointer; var DataSize:Integer);
var
  ssData : TStringStream;
Begin
  If Text = '' then Begin
    Data:= Nil;
    DataSize:= 0;
    Exit;
  End;

  ssData:= TStringStream.Create(Text);
  Try
    ssData.Position:= 0;
    DataSize:= ssData.Size;
    If DataSize > 0 then
      Try
        GetMem(Data, DataSize);
      Except
        Data:= Nil;
        DataSize:= 0;
      End
    Else Data:= Nil;
    If Data <> Nil then ssData.Read(Data^, DataSize);
  Finally
    ssData.Free;
  End;
End;

function IndexOf(Selector:string; StrList:array of string):integer;
var
  Loop : integer;
begin
  Result := -1;
  for Loop := 0 to High(StrList) do begin
    if Selector = StrList[Loop] then begin
      Result:= Loop;
      Break;
    end;
  end;
end;

{ Note:
  IndexOf : 지정된 범위의 구간만 FileDst 파일로 저장
    - Selector : 문자열의 목록 중 찾아야할 문자열
    - StrList : 문자열의 목록
    - 사용예제
      procedure TestString(StringToTest: string);
      begin
        case IndexOf(StringToTest, ['First', 'Second', 'Third']) of
             0: ShowMessage('1: ' + s);
             1: ShowMessage('2: ' + s);
             2: ShowMessage('3: ' + s);
        else
          ShowMessage('else: ' + s);
        end;
      end;
}

function StrToPos(Value:string):TPoint;
var
  stlTemp : TStringList;
begin
  stlTemp := TStringList.Create;
  try
    stlTemp.StrictDelimiter := true;
    stlTemp.Delimiter := ',';
    stlTemp.DelimitedText := Value;

    if stlTemp.Count < 2 then Exit;

    Result.X := StrToIntDef(stlTemp.Strings[0], 0);
    Result.Y := StrToIntDef(stlTemp.Strings[1], 0);
  finally
    stlTemp.Free;
  end;
end;

procedure SaveStringToBuffer(AText:string; var AData:pointer; var ASize:integer);
var
  ssData : TStringStream;
begin
  ssData := TStringStream.Create(AText);
  try
    ASize := ssData.Size;

    if ASize > 0 then begin
      GetMem(AData, ASize);

      ssData.Position := 0;
      ssData.Read(AData^, ASize);
    end else begin
      AData := nil;
    end;
  finally
    ssData.Free;
  end;
end;

function CopyLast(const AText:string):char;
begin
  if AText = '' then Result := #0
  else Result := AText[Length(AText)];
end;

procedure SetLastChar(var AText:string; Ch:Char);
begin
  if Copy(AText, Length(AText), 1) <> Ch then AText := AText + Ch;
end;

function RandomStr(ASize:integer=32):string;
const
  Chars : string = 'abcdefghijzlmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
var
  Loop : integer;
begin
  Result := '';

  Randomize;
  for Loop := 1 to ASize do Result := Result + Chars[Random(Length(Chars)) + 1];
end;

function IntToTimeStr(ATime:integer):string;
var
  h, m, s : integer;
begin
  ATime := ATime div 1000;

  h := ATime div 3600;
  ATime := ATime - h * 3600;

  m := ATime div 60;
  ATime := ATime - m * 60;

  s := ATime;

  Result := Format('%2d:%2d:%2d', [h, m, s]);

  Result := StringReplace(Result, ' ', '0', [rfReplaceAll]);
end;

function TimeStrToInt(ATime:string):integer;
var
  h, m, s : integer;
  Times : TStringList;
begin
  Times := TStringList.Create;
  try
    Times.StrictDelimiter := true;
    Times.Delimiter := ':';
    Times.DelimitedText := Trim(ATime);

    h := 0;
    m := 0;
    s := 0;

    if Times.Count > 0 then h := StrToIntDef(Times[0], 0);
    if Times.Count > 1 then m := StrToIntDef(Times[1], 0);
    if Times.Count > 2 then s := StrToIntDef(Times[2], 0);

    Result := (h * 60 * 60 + m * 60 + s) * 1000;
  finally
    Times.Free;
  end;
end;

function MemoryStr(AValue:int64):string;
var
  iKB, iMB, iGB : int64;
begin
  Result := '';

  iGB := AValue div (1024 * 1024 * 1024);
  if iGB > 0 then begin
    Result := Result + IntToStr(iGB) + ' GB';
    AValue := AValue - iGB * 1024 * 1024 * 1024;
  end;

  iMB := AValue div (1024 * 1024);
  if iMB > 0 then begin
    Result := Result + ' ' + IntToStr(iMB) + ' MB';
    AValue := AValue - iMB * 1024 * 1024;
  end;

  iKB := AValue div (1024);
  if iKB > 0 then begin
    Result := Result + ' ' + IntToStr(iKB) + ' KB';
    AValue := AValue - iKB * 1024;
  end;

  if AValue > 0 then Result := Result + ' ' +IntToStr(AValue) + ' B';
end;

function ByteValueToSizeString(Value:Int64):string;
var
  stFileSize: ansistring;
begin
  setlength(stFileSize,255);
  setlength(stFileSize, length(ShLwApi.StrFormatByteSize64A(Value, pansichar(stFileSize),length(stFileSize))));
  Result:= String(stFileSize);
end;

function StringPointer(const AText:string):PString;
begin
  New(Result);
  Result^ := AText;
end;

end.
