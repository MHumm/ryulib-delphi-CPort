unit DebugTools;

interface

uses
  SyncValues,
  Windows, Classes, SysUtils;

var
  TagInt : TSyncInteger;
  TagStr : TSyncString;

procedure Trace(const AMsg:string; const ATag:string='[Ryu] '); overload;
procedure Trace(AMsg:integer; const ATag:string='[Ryu] '); overload;

function TraceCount:integer;

implementation

uses
  SuspensionQueue, SimpleThread;

var
  Queue : TSuspensionQueue<string>;

procedure Trace(const AMsg:string; const ATag:string);
begin
  Queue.Push(ATag + AMsg);
end;

procedure Trace(AMsg:integer; const ATag:string);
begin
  Queue.Push(ATag + IntToStr(AMsg));
end;

function TraceCount:integer;
begin
  Result := Queue.Count;
end;

initialization
  TagInt := TSyncInteger.Create;
  TagStr := TSyncString.Create;

  Queue := TSuspensionQueue<string>.Create;

  TSimpleThread.Create(
    'DebugTools',
    procedure (ASimpleThread:TSimpleThread)
    var
      Msg : string;
    begin
      while True do begin
        try
          Msg := Queue.Pop;
          OutputDebugString( PChar(Msg) );
        except
          //
        end;
      end;
    end
  );
end.
