unit RyuLibBase;

// Note :
// * ���� ���⼭ ����ϴ� ���� ��ƾ�̳� Ÿ���� ���� �Ѵ�.

interface

uses
  JsonData, ThreadQueue,
  Windows, Classes, SysUtils, Types;

type
  // ������ Data�� TMemory�� Destroy �� �� ȯ������ �ʴ´�.
  TPacket = class
  private
  public
    Size: integer;
    Data: pointer;
    Tag: pointer;

    constructor Create(ASize:integer); reintroduce; overload;
    constructor Create(AData:pointer; ASize:integer); reintroduce; overload;
    constructor Create(AData:pointer; ASize:integer; ATag:pointer); reintroduce; overload;
    constructor Create(AText:string); reintroduce; overload;

    procedure Assign(APacket:TPacket);

    function ToString:string; override;
  end;

  // ������ Data�� TMemory�� Destroy �� �� ȯ���ȴ�.
  TMemory = class (TPacket)
  private
  public
    destructor Destroy; override;

    procedure Assign(AMemory:TMemory);
  end;

  {*
    �޸𸮸� ����� �������� �ʰ� ť�� �־ �����Ѵ�.
    ���� ũ���� �޸𸮸� �����ϱ� ���� ���.
  }
  TMemoryRecylce = class
  strict private
    // ���� ���� �޸𸮸� �ٷ� �ٽ� �Ҵ����� �ʵ��� ���� ������ �д�.
    // Ȥ�ö� ���� ª�� ������ �������� �޸𸮰� �ٸ� ���μ������� ���ǰų� ���� �ٱ�� ���Ľɿ�
    // �޸𸮸� ���� �� ����� �� ������ ������ ���� �� ���Ƽ� �߰��� �ڵ� �����ص� �ȴ�.
    FSpareSpace : integer;

    FSize : integer;
    FQueue : TThreadQueue<Pointer>;
  public
    constructor Create(ASpareSpace:integer); reintroduce;
    destructor Destroy; override;

    function Get(ASize:integer):pointer; overload;
    procedure Release(AData:pointer);
  public
    property Size : integer read FSize;
  end;

  TScreenSize = record
    Width, Height : integer;
    procedure SetValue(AWidth,AHeight:integer);
    function ToPoint:TPoint;
  end;

  ExceptionWithErrorCode = class (Exception)
  private
  protected
    FErrorCode : integer;
  public
    constructor Create(const AMsg:string; AErrorCode:integer);

    property ErrorCode : integer read FErrorCode;
  end;

  TProcedureReference<T> = reference to procedure(Context:T);

  TBooleanResultEvent = function (Sender:TObject):boolean of object;
  TMemoryEvent = procedure (Sender:TObject; AMemory:TMemory) of object;
  TDataEvent = procedure (Sender:TObject; AData:pointer; ASize:integer) of object;
  TDataAndTagEvent = procedure (Sender:TObject; AData:pointer; ASize:integer; ATag:pointer) of object;
  TBooleanEvent = procedure (Sender:TObject; AResult:boolean) of object;
  TIntegerEvent = procedure (Sender:TObject; AValue:Integer) of object;
  TStringEvent = procedure (Sender:TObject; const AText:string) of object;
  TMsgAndCodeEvent = procedure (Sender:TObject; const AMsg:string; ACode:integer) of object;
  TJsonDataEvent = procedure (Sender:TObject; AJsonData:TJsonData) of object;

  TObjectClass = class of TObject;

  // ���� ī��Ʈ�� ���ؼ� �޸� ������ ������� ����
  TInterfaceBase = class (TObject, IInterface)
  private
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
  end;

procedure CreateObject(AInstanceClass: TObjectClass; var AReference);
function GetPacket(AData:pointer; ASize:integer): pointer;

implementation

uses
  Strg;

procedure CreateObject(AInstanceClass: TObjectClass; var AReference);
begin
  {$IF DEFINED(CLR)}
    TObject(AReference) := AInstanceClass.Create;
  {$ELSE}
    TObject(AReference) := AInstanceClass.NewInstance;
    TObject(AReference).Create;
  {$IFEND}
end;

function GetPacket(AData:pointer; ASize:integer): pointer;
var
  pBuffer : ^integer;
begin
  if ASize >= 0 then GetMem(Result, ASize + SizeOf(Integer))
  else GetMem(Result, SizeOf(Integer));

  pBuffer := Result;

  Move(ASize, pBuffer^, SizeOf(ASize));

  if ASize > 0 then begin
    Inc(pBuffer);
    Move(AData^, pBuffer^, ASize);
  end;
end;

{ TScreenSize }

procedure TScreenSize.SetValue(AWidth, AHeight: integer);
begin
  Width := AWidth;
  Height := AHeight;
end;

function TScreenSize.ToPoint: TPoint;
begin
  Result := Point(Width, Height);
end;

{ ExceptionWithErrorCode }

constructor ExceptionWithErrorCode.Create(const AMsg: string;
  AErrorCode: integer);
begin
  Message := AMsg;
  FErrorCode := AErrorCode;
end;

{ TPacket }

procedure TPacket.Assign(APacket: TPacket);
begin
  if Data <> nil then begin
    FreeMem(Data);
    Data := nil;
  end;

  Size := APacket.Size;
  if Size <= 0 then begin
    Data := nil;
  end else begin
    GetMem(Data, Size);
    Move(APacket.Data^, Data^, Size);
  end;

  Tag := APacket.Tag;
end;

constructor TPacket.Create(AData: pointer; ASize: integer; ATag: pointer);
begin
  Size := ASize;
  if Size <= 0 then begin
    Data := nil;
  end else begin
    GetMem(Data, Size);
    Move(AData^, Data^, Size);
  end;

  Tag := ATag;
end;

constructor TPacket.Create(AData: pointer; ASize: integer);
begin
  Size := ASize;
  if Size <= 0 then begin
    Data := nil;
  end else begin
    GetMem(Data, Size);
    if AData <> nil then Move(AData^, Data^, Size);
  end;

  Tag := nil;
end;

constructor TPacket.Create(ASize: integer);
begin
  Size := ASize;
  if Size <= 0 then begin
    Data := nil;
  end else begin
    GetMem(Data, Size);
  end;

  Tag := nil;
end;

function TPacket.ToString: string;
begin
  Result := DataToText( Data, Size );
end;

constructor TPacket.Create(AText: string);
begin
  TextToData( AText, Data, Size );

  Tag := nil;
end;

{ TMemory }

procedure TMemory.Assign(AMemory: TMemory);
begin
  inherited Assign(AMemory);
end;

destructor TMemory.Destroy;
begin
  if Data <> nil then begin
    FreeMem(Data);
    Data := nil;
  end;

  inherited;
end;

{ TMemoryRecylce }

constructor TMemoryRecylce.Create(ASpareSpace:integer);
begin
  inherited Create;

  FSpareSpace := ASpareSpace;
  FSize := 0;
  FQueue := TThreadQueue<Pointer>.Create;
end;

destructor TMemoryRecylce.Destroy;
begin
  FreeAndNil(FQueue);

  inherited;
end;

function TMemoryRecylce.Get(ASize: integer): pointer;
begin
  if FSize = 0 then begin
    FSize := ASize;
  end else begin
    if ASize <> FSize then
      raise Exception.Create('TMemoryRecylce.Get - ���� ũ���� �޸𸮸� �Ҵ� ���� �� �ֽ��ϴ�.');
  end;

  if (FQueue.Count < FSpareSpace) or (not FQueue.Pop(Result)) then GetMem(Result, ASize);
end;

procedure TMemoryRecylce.Release(AData: pointer);
begin
  FQueue.Push(AData);
end;

{ TInterfaceBase }

function TInterfaceBase.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TInterfaceBase._AddRef: Integer;
begin
  Result := -1;
end;

function TInterfaceBase._Release: Integer;
begin
  Result := -1;
end;

end.
