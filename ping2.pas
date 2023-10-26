unit ping2;

interface

uses Windows, SysUtils, WinSock, system.Threading, system.Classes, system.JSON,
  UnitService, IdUDPClient, system.UITypes, system.Variants, idGlobal;

const
  js: string =
    '[{"id":1, "ip":"192.168.0.10","mac":"50-2B-73-E6-3F-77"},{"id":2, "ip":"192.168.0.11","mac":"502B73E63F77"}]';

function pingpclist: string;
function PingHost(const HostName: AnsiString;
  TimeoutMS: cardinal = 500): boolean;
function pcinfo(j: string): string;
procedure WakeOnLan(macArray: string);
function sendToClient(ipArray, cmd: string): integer;

var
  map_status: array [1 .. 200] of integer;
  map_ip_list: TstringList;

implementation

function IcmpCreateFile: THandle; stdcall; external 'iphlpapi.dll';
function IcmpCloseHandle(icmpHandle: THandle): boolean; stdcall;
  external 'iphlpapi.dll';
function IcmpSendEcho(icmpHandle: THandle; DestinationAddress: In_Addr;
  RequestData: Pointer; RequestSize: Smallint; RequestOptions: Pointer;
  ReplyBuffer: Pointer; ReplySize: DWORD; Timeout: DWORD): DWORD; stdcall;
  external 'iphlpapi.dll';

type
  TEchoReply = packed record
    Addr: In_Addr;
    Status: DWORD;
    RoundTripTime: DWORD;
  end;

  PEchoReply = ^TEchoReply;

var
  WSAData: TWSAData;
  gJson: TJsonArray;

procedure Startup;
begin
  if WSAStartup($0101, WSAData) <> 0 then
    raise Exception.Create('WSAStartup');
end;

procedure Cleanup;
begin
  if WSACleanup <> 0 then
    raise Exception.Create('WSACleanup');
end;

function PingHost(const HostName: AnsiString;
  TimeoutMS: cardinal = 500): boolean;
const
  rSize = $400;
var
  e: PHostEnt;
  a: PInAddr;
  h: THandle;
  d: string;
  r: array [0 .. rSize - 1] of byte;
  i: cardinal;
begin
  Startup;
  e := gethostbyname(PAnsiChar(HostName));
  if e = nil then
  // RaiseLastOSError;
  begin
    result := false;
    exit;
  end;
  if e.h_addrtype = AF_INET then
    Pointer(a) := e.h_addr^
  else
  // raise Exception.Create('Name doesn''t resolve to an IPv4 address');
  begin
    result := false;
    exit;
  end;

  d := FormatDateTime('yyyymmddhhnnsszzz', Now);

  h := IcmpCreateFile;
  if h = INVALID_HANDLE_VALUE then
    RaiseLastOSError;
  try
    i := IcmpSendEcho(h, a^, PChar(d), Length(d), nil, @r[0], rSize, TimeoutMS);
    result := (i <> 0) and (PEchoReply(@r[0]).Status = 0);
  finally
    IcmpCloseHandle(h);
  end;
  Cleanup;

end;

function pcinfo(j: string): string;
begin

  gJson := TJsonArray.ParseJSONValue(j) as TJsonArray;

  map_ip_list := TstringList.Create;

  for var x := 1 to gJson.Count do
  begin
    map_ip_list.Add(gJson.Items[x - 1].p['ip'].Value);
  end;

  result := pingpclist;

end;

function pingpclist: string;
var
  myJSONObject: TJSONObject;
  JSONArray, jsa: TJsonArray;
  JSON: TJSONObject;
begin

  // myJSONObject:=TJSONObject.Create;
  JSONArray := TJsonArray.Create;
  JSON := TJSONObject.Create;
  jsa := TJsonArray.Create;
  for var I09 := 1 to map_ip_list.Count do
  begin
    myJSONObject := TJSONObject.Create;
    // JSONArray.AddElement(TJSONObject.Create);
    // myJSONObject:=JSONArray.Items[pred(JSONArray.Count)] as TJSONObject;
    // jsa:=TJSONArray.Create;
    if PingHost(map_ip_list[I09 - 1], 300) = true then
    begin

      myJSONObject.AddPair('ip', map_ip_list[I09 - 1]);
      myJSONObject.AddPair('status', true);
      jsa.AddElement(myJSONObject);
    end

    else
    begin

      myJSONObject.AddPair('ip', map_ip_list[I09 - 1]);
      myJSONObject.AddPair('status', false);
      jsa.AddElement(myJSONObject);
    end;
    // myJSONObject.Free;
  end;

  JSON.AddPair('ping', jsa);

  logs('test.txt', JSON.ToString, 'ping');

  result := stringreplace(JSON.ToString, '\', '', [rfReplaceAll, rfIgnoreCase]);

  // freeAndnil(myJSONObject);
  // freeAndnil(JSONArray);
  // freeAndnil(JSON);
end;

procedure rebootpc(jstext: string);
begin

  TThread.CreateAnonymousThread(
    procedure()
    var
      myJSONObject: TJSONObject;
      JSONArray: TJsonArray;
      JSON: TJSONObject;
    begin

      myJSONObject := TJSONObject.Create;
      JSONArray := TJsonArray.Create;
      JSON := TJSONObject.Create;

      { for var I09 :=1 to map_ip_list.Count do
        begin

        JSONArray.AddElement(TJSONObject.Create);
        myJSONObject:=JSONArray.Items[pred(JSONArray.Count)] as TJSONObject;

        if PingHost(map_ip_list[i09-1],300)=true then begin

        myJSONObject.AddPair('ip',map_ip_list[i09-1]);
        myJSONObject.AddPair('status',true);

        end

        else begin

        myJSONObject.AddPair('ip',map_ip_list[i09-1]);
        myJSONObject.AddPair('status',false);

        end;

        end; }

      JSON.AddPair('ping', JSONArray.ToString);
      logs('test.txt', JSON.ToString, 'ping');

      freeAndnil(myJSONObject);
      freeAndnil(JSONArray);
      freeAndnil(JSON);

    end).Start;

end;

function sendToClient(ipArray, cmd: string): integer;
var
  resp2: string;
  err: integer;
  JSONOArr: TJsonArray;
  JSONPars: TJSONObject;
begin

  JSONOArr := TJsonArray.Create;
  JSONOArr := JSONPars.ParseJSONValue(ipArray) as TJsonArray;

  for var z := 0 to JSONOArr.Count - 1 do
  begin

    err := 0;
    try

      FormMain.IdTCPClient1.Host := JSONOArr.Items[z].p['ip'].Value;
      FormMain.IdTCPClient1.Connect;
      FormMain.IdTCPClient1.Socket.WriteLn(cmd,
        IndyTextEncoding(IdTextEncodingType.encUTF8));
      resp2 := FormMain.IdTCPClient1.Socket.ReadLn(IndyTextEncoding_UTF8);

      if resp2='#0' then err:=0;
      if resp2='#1' then err:=1;

      FormMain.IdTCPClient1.Disconnect;

    except
      err := 1;
    end;

    result := err;

  end;

end;

procedure WakeOnLan(macArray: string);

type
  TMacAddress = array [1 .. 6] of byte;

  TWakeRecord = packed record
    Waker: TMacAddress;
    MAC: array [0 .. 15] of TMacAddress;
  end;

var

  i: integer;
  WR: TWakeRecord;
  MacAddress: TMacAddress;
  UDPClient: TIdUDPClient;
  sData: string;
  AMacAddress: string;

  JSONOArr: TJsonArray;
  JSONPars: TJSONObject;

begin

  JSONOArr := TJsonArray.Create;
  JSONOArr := JSONPars.ParseJSONValue(macArray) as TJsonArray;

  for var z := 0 to JSONOArr.Count - 1 do
  begin

    AMacAddress := JSONOArr.Items[z].p['mac'].Value;
    FillChar(MacAddress, SizeOf(TMacAddress), 0);
    sData := Trim(AMacAddress);

    if Length(sData) = 17 then
    begin

      for i := 1 to 6 do
      begin
        MacAddress[i] := StrToIntDef('$' + Copy(sData, 1, 2), 0);
        sData := Copy(sData, 4, 17);
      end;

    end;

    for i := 1 to 6 do
      WR.Waker[i] := $FF;
    for i := 0 to 15 do
      WR.MAC[i] := MacAddress;

    for var I2 := 1 to 6 do
    BEGIN

      UDPClient := TIdUDPClient.Create(nil);
      try

        UDPClient.Host := '255.255.255.255';
        UDPClient.Port := 32767;

        UDPClient.BroadCastEnabled := true;
        UDPClient.Broadcast(RawToBytes(WR, SizeOf(TWakeRecord)), 7);
        UDPClient.Broadcast(RawToBytes(WR, SizeOf(TWakeRecord)), 9);
        UDPClient.SendBuffer(JSONOArr.Items[z].p['ip'].Value, 9,
          RawToBytes(WR, SizeOf(TWakeRecord)));
        UDPClient.SendBuffer(RawToBytes(WR, SizeOf(TWakeRecord)));
        UDPClient.BroadCastEnabled := false;

      finally
        UDPClient.Free;
      end;

    END;

  end;

end;

end.
