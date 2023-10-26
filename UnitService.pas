unit UnitService;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, System.IOUtils,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, idGlobal,
  System.JSON,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdContext,
  FMX.Platform.Win,
  System.TypInfo,
  IdHeaderList, IdCustomHTTPServer, IdCustomTCPServer, IdHTTPServer;

type
  TStringSet = (poweron, poweroff, reboot, cashboxinitialization, closeshift,
    openshift, shiftstate, cashboxsum, ofdinfo, shift, cashincome, cashoutcome,
    xreport, copylastdoc, revenue, buy, cancelreceipt, documentnumber, pingcmd,
    enableprotection, disableprotection, protectionstatus);

type
  TFormMain = class(TForm)
    Timer1: TTimer;
    Button1: TButton;
    IdTCPClient1: TIdTCPClient;
    Button2: TButton;
    IdHTTPServer1: TIdHTTPServer;
    Memo1: TMemo;
    Button3: TButton;
    Button4: TButton;
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure IdHTTPServer1CreatePostStream(AContext: TIdContext;
      AHeaders: TIdHeaderList; var VPostStream: TStream);
    procedure IdHTTPServer1DoneWithPostStream(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; var VCanFree: Boolean);
    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure Button3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

procedure logs(fileName, text, event: string);

var
  FormMain: TFormMain;
  protstatus: integer;
  init: integer = 0;

implementation

{$R *.dfm}

uses ping2, UnitCashbox;

procedure TFormMain.Button1Click(Sender: TObject);
begin

  logs('test.txt', 'info', 'event');

end;

procedure TFormMain.Button2Click(Sender: TObject);
begin
  // WakeOnLan(js);
end;

procedure TFormMain.Button3Click(Sender: TObject);
begin
  // ShowWindow(application.Handle, SW_HIDE);
  // SetWindowLong(application.Handle, GWL_EXSTYLE, GetWindowLong(application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
end;

procedure TFormMain.Button4Click(Sender: TObject);
begin
  // ShowWindow(application.Handle, SW_HIDE);
  // SetWindowLong(application.Handle, GWL_EXSTYLE, GetWindowLong(application.Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  freeandnil(map_ip_list);
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  Button4.Click;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin

  // Button1.OnClick(Button3);

end;

procedure TFormMain.IdHTTPServer1CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var

  AForm: TStringList;
  Stream: TStream;
  strR: string;
  Response, msg, dat: string;
  Rjson, Pjson, JsonPars: TJSONObject;
  request: TStringSet;
  dATA: UTF8String;
  ADatas: TStringStream;
  s: string;
  PjsonA: tjsonArray;
  body: TStringStream;
begin

  If ARequestInfo.CommandType = hcPOST then
  begin

    logs('test.txt', ARequestInfo.RemoteIP, 'event');
    Stream := TStream.Create;
    Stream := ARequestInfo.PostStream;

    if assigned(Stream) then
    begin

      Stream.Position := 0;
      dATA := ReadStringFromStream(Stream, -1, IndyTextEncoding_UTF8);

      Pjson := TJSONObject.Create;
      JsonPars := TJSONObject.Create;

      Rjson := TJSONObject.Create;
      Rjson := JsonPars.ParseJSONValue(dATA) as TJSONObject;

      logs('test.txt', Rjson.ToString, 'event');
      Memo1.Lines.Add('<- ' + Rjson.ToString);
    end;

    request := TStringSet(getEnumValue(Typeinfo(TStringSet),
      Rjson.GetValue<string>('cmd')));

    case request of

      pingcmd:
        begin

          PjsonA := Rjson.GetValue('data') as tjsonArray;
          Response := pcinfo(PjsonA.ToString);
          (* {"cmd":"pingcmd","data":[{"id":1, "ip":"192.168.0.10","mac":"50-2B-73-E6-3F-77"},{"id":2, "ip":"192.168.0.11","mac":"50-2B-73-E6-3F-77"}]} *)
        end;

      poweron:
        begin

          PjsonA := Rjson.GetValue('data') as tjsonArray;
          WakeOnLan(PjsonA.ToString);
          Response := '{"error":0}';
          (* {"cmd":"poweron","data":[{"id":1, "ip":"192.168.0.10","mac":"50-2B-73-E6-3F-77"},{"id":2, "ip":"192.168.0.11","mac":"50-2B-73-E6-3F-77"}]} *)
        end;

      poweroff:
        begin

          PjsonA := Rjson.GetValue('data') as tjsonArray;
          sendToClient(PjsonA.ToString, Rjson.GetValue<string>('cmd'));
          Response := '{"error":0}';
          (* {"cmd":"poweron","data":[{"id":1, "ip":"192.168.0.10","mac":"50-2B-73-E6-3F-77"},{"id":2, "ip":"192.168.0.11","mac":"50-2B-73-E6-3F-77"}]} *)
        end;

      reboot:
        begin

          PjsonA := Rjson.GetValue('data') as tjsonArray;
          sendToClient(PjsonA.ToString, Rjson.GetValue<string>('cmd'));
          Response := '{"error":0}';

        end;

      enableprotection:
        begin

          PjsonA := Rjson.GetValue('data') as tjsonArray;
          case sendToClient(PjsonA.ToString, Rjson.GetValue<string>('cmd')) of
            0:
              Response := '{"error":0}';
            1:
              Response := '{"error":1}';
          end;

        end;

      // disableprotection
      disableprotection:
        begin

          PjsonA := Rjson.GetValue('data') as tjsonArray;

          case sendToClient(PjsonA.ToString, Rjson.GetValue<string>('cmd')) of
            0:
              Response := '{"error":0}';
            1:
              Response := '{"error":1}';
          end;

        end;

      protectionstatus:
        begin

          PjsonA := Rjson.GetValue('data') as tjsonArray;

          case sendToClient(PjsonA.ToString, Rjson.GetValue<string>('cmd')) of
            0:
              Response := '{"error":0}';
            1:
              Response := '{"error":1}';
          end;

        end;

      cashboxinitialization:
        begin
          if init = 0 then
            Response := CashboxInit(Rjson.GetValue('setting')
              .FindValue('port').Value);
          // {"cmd":"cashboxinitialization","setting":{"port":3}}
        end;

      closeshift:
        begin
          Response := cashboxCloseshift(Rjson.GetValue('data')
            .FindValue('name').Value);
          // {"cmd":"closeshift","data":{"name":"Иванов И.И."}}                              +
        end;

      openshift:
        begin
          Response := cashboxOpenNshift(Rjson.GetValue('data')
            .FindValue('name').Value);
          // {"cmd":"openshift","data":{"name":"Иванов И.И."}}                               +
        end;

      shiftstate:
        begin // статус смены  /0-закрыта /1-открыта /2- 24 часа просрочено
          Response := CashboxshiftState;
          // {"cmd":"shiftstate","data":{"name":"Иванов И.И."}}                          +
        end;

      cashboxsum:
        begin
          /// Сумма наличных в денежном ящике  +
          Response := cashboxSum_;
          // {"cmd":"cashboxsum","data":{"name":"Иванов И.И."}}
        end;

      revenue:
        begin
          /// выручка
          Response := revenue_;
          // {"cmd":"revenue","data":{"name":"Иванов И.И."}}
        end;

      ofdinfo:
        begin // информация ОФД
          Response := ofdinfo_;
          // {"cmd":"ofdinfo","data":{"name":"Иванов И.И."}}
        end;

      shift:
        begin // номер смены
          Response := shift_;
          // {"cmd":"shift","data":{"name":"Иванов И.И."}}                              +
        end;

      cashincome:
        begin // внесение в кассу
          Response := cashincome_(Rjson.GetValue('data').FindValue('amount')
            .AsType<real>);
          // {"cmd":"cashincome","data":{"amount":100}}                                      +
        end;

      cashoutcome:
        begin // выемка в кассу
          Response := cashoutcome_(Rjson.GetValue('data').FindValue('amount')
            .AsType<real>);
          // {"cmd":"cashoutcome","data":{"amount":100}}
        end;

      xreport:
        begin // Х отчет
          Response := xreport_(Rjson.GetValue('data').FindValue('name').Value);
          // {"cmd":"xreport","data":{"name":"Иванов И.И."}}                        +
        end;

      copylastdoc:
        begin // копия последнего документа
          Response := copylastdoc_(Rjson.GetValue('data')
            .FindValue('name').Value);
          // {"cmd":"xreport","data":{"name":"Иванов И.И."}}
        end;

      buy:
        begin

          Response := buy_(Rjson.Values['data'].ToString,
            Rjson.GetValue('email').ToString, Rjson.GetValue('cash')
            .ToString.ToBoolean, Rjson.GetValue('product').ToString.ToBoolean,
            Rjson.GetValue('refund').ToString.ToBoolean,
            Rjson.GetValue('name').ToString);

          // {"cmd":"buy","data":[{"name":"pepsi","price":102,"quantity":2},{"name":"lays ikra","price":155,"quantity":1}],"email":"","tax":"","cash":true,"product":true,"refund":false,"name":"Петровский А.А"}
        end;

      cancelreceipt:
        begin
          Response := cancelreceipt_(Rjson.GetValue('data')
            .FindValue('name').Value);
          // {"cmd":"cancelreceipt","data":{"name":"Иванов И.И."}}
        end;

      documentnumber:
        begin
          Response := documentnumber_(Rjson.GetValue('data')
            .FindValue('name').Value);
          // {"cmd":"documentnumber","data":{"name":"Иванов И.И."}}
        end;

    end;

    logs('test.txt', Rjson.ToString, 'event');

  end;

  Memo1.Lines.Add(dateTimeTostr(now()) + ': Ответ-> ' + Response);
  AResponseInfo.ResponseNo := 200;
  AResponseInfo.CacheControl := 'no-cache';
  AResponseInfo.CustomHeaders.Add('Access-Control-Allow-Origin: *');
  if Response = '' then
    Response := '{"error":999,"description":"bad request", "data":{}}';

  AResponseInfo.ContentText := Response;
  AResponseInfo.ResponseText := Response;
  AResponseInfo.WriteContent;
  AResponseInfo.CloseSession;

end;

procedure TFormMain.IdHTTPServer1CreatePostStream(AContext: TIdContext;
  AHeaders: TIdHeaderList; var VPostStream: TStream);
begin
  VPostStream := TMemoryStream.Create;
end;

procedure TFormMain.IdHTTPServer1DoneWithPostStream(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; var VCanFree: Boolean);
begin
  VCanFree := false;
end;

procedure TFormMain.Timer1Timer(Sender: TObject);
begin

  // pingpclist;

end;

procedure logs(fileName, text, event: string);
var
  streamWriter: TStreamWriter;
begin

  { if not fileexists(fileName) then
    begin
    streamWriter := TFile.CreateText(fileName);
    streamWriter.Close;
    end
    else
    begin

    try
    streamWriter := TFile.AppendText(fileName);
    streamWriter.WriteLine(formatdateTime('yyyy.mm.dd hh:mm:ss', now) + ';' +
    event + ';' + text);
    streamWriter.Close;
    except

    end;

    end; }

end;

end.
