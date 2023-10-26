unit UnitCashbox;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, TypInfo,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ComObj, Vcl.StdCtrls, System.Threading,
  ActiveX, System.JSON;

function cashboxInit(port: string): string;
function cashboxCloseshift(name: string): string;
function cashboxOpenNshift(name: string): string;
function CashboxshiftState: string;
function cashboxSum_: string;
function ofdinfo_: string;
function shift_: string;
function cashincome_(amount: real): string;
function cashoutcome_(amount: real): string;
function xreport_(name: string): string;
function copylastdoc_(name: string): string;
function revenue_: string;
function buy_(data, email: string; cash, product, refund: boolean;
  name: string): string;
function cancelreceipt_(name: string): string;
function documentNumber_(name: string): string;
function documentNumber_2(name: string): string;

var
  fptr: OleVariant;

implementation

uses UnitService;

function cashboxCloseshift(name: string): string;
begin
  try
    fptr.setParam(1021, name);
    fptr.setParam(1203, '123456789047');
    fptr.operatorLogin;

    fptr.setParam(fptr.LIBFPTR_PARAM_REPORT_TYPE, fptr.LIBFPTR_RT_CLOSE_SHIFT);
    fptr.report;

    fptr.checkDocumentClosed;
    result := '{"errorcode":"1-002","error":"' + fptr.errorDescription +
      '","errorindex":' + inttostr(fptr.errorCode) + '}';

  except

    on E: Exception do
      result := '{"errorcode":"2-002","error":"' + E.Message + '"}';

  end;

end;

function cashboxOpenshift(name: string): string;
begin
  try
    fptr.setParam(1021, name);
    fptr.setParam(1203, '123456789047');
    fptr.operatorLogin;

    fptr.openShift;

    fptr.checkDocumentClosed;
    result := '{"errorcode":"1-010","error":"' + fptr.errorDescription +
      '","errorindex":' + inttostr(fptr.errorCode) + '}';

  except

    on E: Exception do
      result := '{"errorcode":"2-010","error":"' + E.Message + '"}';

  end;

end;

// documentNumber

function documentNumber_(name: string): string;
var
  documentNumber: Longint;
  hasOfdTicket: LongBool;
  dateTime: TDateTime;
  fiscalSign: String;
begin

  try
    fptr.setParam(fptr.LIBFPTR_PARAM_FN_DATA_TYPE,
      fptr.LIBFPTR_FNDT_LAST_DOCUMENT);
    fptr.fnQueryData;
    documentNumber := fptr.getParamInt(fptr.LIBFPTR_PARAM_DOCUMENT_NUMBER);

    result := '{"errorcode":"1-015","error":"' + fptr.errorDescription +
      '","errorindex":' + inttostr(fptr.errorCode) + ',"":{"documentnumber":' +
      documentNumber.ToString + '}}';

  except

    on E: Exception do
      result := '{"errorcode":"2-015","error":"' + E.Message + '"}';

  end;

end;

function documentNumber_2(name: string): string;
var
  documentNumber: Longint;
  hasOfdTicket: LongBool;
  dateTime: TDateTime;
  fiscalSign: String;
begin

  try
    fptr.setParam(fptr.LIBFPTR_PARAM_FN_DATA_TYPE,
      fptr.LIBFPTR_FNDT_LAST_DOCUMENT);
    fptr.fnQueryData;
    documentNumber := fptr.getParamInt(fptr.LIBFPTR_PARAM_DOCUMENT_NUMBER);

    result := documentNumber.ToString;

  except

    on E: Exception do
      result := '{"errorcode":"2-015","error":"' + E.Message + '"}';

  end;

end;

function cashboxOpenNshift(name: string): string;
begin

  try
    fptr.setParam(1021, name);
    fptr.setParam(1203, '123456789047');
    fptr.operatorLogin;

    fptr.openShift;

    fptr.checkDocumentClosed;
    result := '{"errorcode":"1-003","error":"' + fptr.errorDescription +
      '","errorindex":' + inttostr(fptr.errorCode) + '}';

  except

    on E: Exception do
      result := '{"errorcode":"2-003","error":"' + E.Message + '"}';

  end;

end;

function ofdinfo_: string;
var
  unsentCount: Longint;
  firstUnsentNumber: Longint;
  dateTime: TDateTime;
begin

  try

    fptr.setParam(fptr.LIBFPTR_PARAM_FN_DATA_TYPE,
      fptr.LIBFPTR_FNDT_ISM_EXCHANGE_STATUS);
    fptr.fnQueryData;

    unsentCount := fptr.getParamInt(fptr.LIBFPTR_PARAM_DOCUMENTS_COUNT);
    firstUnsentNumber := fptr.getParamInt(fptr.LIBFPTR_PARAM_DOCUMENT_NUMBER);
    dateTime := fptr.getParamDateTime(fptr.LIBFPTR_PARAM_DATE_TIME);
    result := '{"errorcode":"1-005","error":"' + fptr.errorDescription +
      '","errorindex":' + inttostr(fptr.errorCode) + ',"data":{"unsentcount":' +
      unsentCount.ToString + ',"firstunsentnumber":' +
      firstUnsentNumber.ToString + ',"datetime":"' +
      datetimetostr(dateTime) + '"}}';

  except

    on E: Exception do
      result := '{"errorcode":"2-005","error":"' + E.Message + '"}';

  end;

end;

function revenue_: string;
/// выручка
var
  revenue: Double;
begin
  try
    fptr.setParam(fptr.LIBFPTR_PARAM_DATA_TYPE, fptr.LIBFPTR_DT_REVENUE);
    fptr.queryData;

    revenue := fptr.getParamDouble(fptr.LIBFPTR_PARAM_SUM);

    result := '{"errorcode":"1-011","error":"' + fptr.errorDescription +
      '","errorindex":' + inttostr(fptr.errorCode) + ',"data":{"sum":"' +
      floattostr(revenue) + '"}}';

  except

    on E: Exception do
      result := '{"errorcode":"2-011","error":"' + E.Message + '"}';

  end;

end;

function cashboxSum_: string;
/// Сумма наличных в денежном ящике
var
  cashSum: Double;
begin

  try

    fptr.setParam(fptr.LIBFPTR_PARAM_DATA_TYPE, fptr.LIBFPTR_DT_CASH_SUM);
    fptr.queryData;

    cashSum := fptr.getParamDouble(fptr.LIBFPTR_PARAM_SUM);

    result := '{"errorcode":"1-004","error":"' + fptr.errorDescription +
      '","errorindex":' + inttostr(fptr.errorCode) + ',"data":{"sum":"' +
      floattostr(cashSum) + '"}}';

  except

    on E: Exception do
      result := '{"errorcode":"2-004","error":"' + E.Message + '"}';

  end;

end;

function shift_: string;
var
  shiftNumber: Longint;
begin
  try
    fptr.setParam(fptr.LIBFPTR_PARAM_DATA_TYPE, fptr.LIBFPTR_DT_STATUS);
    fptr.queryData;
    shiftNumber := fptr.getParamInt(fptr.LIBFPTR_PARAM_SHIFT_NUMBER);

    result := '{"errorcode":"1-007","error":"' + fptr.errorDescription +
      '","errorindex":' + inttostr(fptr.errorCode) + ',"data":{"shift":' +
      shiftNumber.ToString + '}}';

  except

    on E: Exception do
      result := '{"errorcode":"2-007","error":"' + E.Message + '"}';

  end;
end;

function cashincome_(amount: real): string;
var
  shiftNumber: Longint;
  cashSum: real;
begin
  try
    fptr.setParam(fptr.LIBFPTR_PARAM_SUM, amount);
    fptr.cashIncome;

    fptr.setParam(fptr.LIBFPTR_PARAM_DATA_TYPE, fptr.LIBFPTR_DT_CASH_SUM);
    fptr.queryData;

    cashSum := fptr.getParamDouble(fptr.LIBFPTR_PARAM_SUM);

    result := '{"errorcode":"1-008","error":"' + fptr.errorDescription +
      '","errorindex":' + inttostr(fptr.errorCode) + ',"data":{"sum":"' +
      floattostr(cashSum) + '"}}';

  except

    on E: Exception do
      result := '{"errorcode":"2-008","error":"' + E.Message + '"}';

  end;
end;

function cashoutcome_(amount: real): string;
var
  shiftNumber: Longint;
  cashSum: real;
begin
  try
    fptr.setParam(fptr.LIBFPTR_PARAM_SUM, amount);
    fptr.cashOutcome;

    fptr.setParam(fptr.LIBFPTR_PARAM_DATA_TYPE, fptr.LIBFPTR_DT_CASH_SUM);
    fptr.queryData;

    cashSum := fptr.getParamDouble(fptr.LIBFPTR_PARAM_SUM);

    result := '{"errorcode":"1-009","error":"' + fptr.errorDescription +
      '","errorindex":' + inttostr(fptr.errorCode) + ',"data":{"sum":"' +
      floattostr(cashSum) + '"}}';

  except

    on E: Exception do
      result := '{"errorcode":"2-009","error":"' + E.Message + '"}';

  end;
end;

function xreport_(name: string): string;
var
  shiftNumber: Longint;
begin
  try
    fptr.setParam(fptr.LIBFPTR_PARAM_REPORT_TYPE, fptr.LIBFPTR_RT_X);
    fptr.report;

    result := '{"errorcode":"1-007","error":"' + fptr.errorDescription +
      '","errorindex":' + inttostr(fptr.errorCode) + ',"data":{"shift":' +
      shiftNumber.ToString + '}}';

  except

    on E: Exception do
      result := '{"errorcode":"2-007","error":"' + E.Message + '"}';

  end;
end;

function copylastdoc_(name: string): string;
var
  shiftNumber: Longint;
begin

  try
    fptr.setParam(fptr.LIBFPTR_PARAM_REPORT_TYPE,
      fptr.LIBFPTR_RT_LAST_DOCUMENT);
    fptr.report;
    result := '{"errorcode":"1-007","error":"' + fptr.errorDescription +
      '","errorindex":' + inttostr(fptr.errorCode) + ',"data":{"shift":' +
      shiftNumber.ToString + '}}';

  except

    on E: Exception do
      result := '{"errorcode":"2-007","error":"' + E.Message + '"}';

  end;

end;

function cancelreceipt_(name: string): string;
var
  shiftNumber: Longint;
begin

  try

    fptr.cancelReceipt;
    result := '{"errorcode":"1-013","error":"' + fptr.errorDescription +
      '","errorindex":' + inttostr(fptr.errorCode) + ',"data":{"shift":' +
      shiftNumber.ToString + '}}';

  except

    on E: Exception do
      result := '{"errorcode":"2-013","error":"' + E.Message + '"}';

  end;

end;

function buy_(data, email: string; cash, product, refund: boolean;
  name: string): string;
var
  shiftNumber: Longint;
  jsonArray: tjsonArray;
  summTotal: real;
  documentNumber: integer;
begin

  try
    jsonArray := tjsonArray.Create;
    jsonArray := TJSONObject.ParseJSONValue(data) as tjsonArray;

    fptr.getParamInt(fptr.LIBFPTR_PARAM_RECEIPT_TYPE);

    fptr.setParam(fptr.LIBFPTR_PARAM_FN_DATA_TYPE, fptr.LIBFPTR_FNDT_TAG_VALUE);
    fptr.setParam(fptr.LIBFPTR_PARAM_TAG_NUMBER, 1018);
    fptr.fnQueryData;

    fptr.setParam(1021, name);
    fptr.setParam(1203, fptr.getParamString(fptr.LIBFPTR_PARAM_TAG_VALUE));
    fptr.operatorLogin;

    // возврат
    if refund = true then
      fptr.setParam(fptr.LIBFPTR_PARAM_RECEIPT_TYPE,
        fptr.LIBFPTR_RT_SELL_RETURN)
    else
      fptr.setParam(fptr.LIBFPTR_PARAM_RECEIPT_TYPE, fptr.LIBFPTR_RT_SELL);

    if email <> '""' then
    begin
      fptr.setParam(fptr.LIBFPTR_PARAM_RECEIPT_ELECTRONICALLY, true);
      fptr.setParam(1008, email);
    end;

    fptr.setParam(1055, fptr.LIBFPTR_TT_PATENT);

    { if form1.StringGrid1.Cells[6,1]='LIBFPTR_TT_PATENT' then fptr.setParam(1055,  fptr.LIBFPTR_TT_PATENT);
      if form1.StringGrid1.Cells[6,1]='LIBFPTR_TT_OSN' then fptr.setParam(1055,  fptr.LIBFPTR_TT_OSN);
      if form1.StringGrid1.Cells[6,1]='LIBFPTR_TT_USN_INCOME' then fptr.setParam(1055,  fptr.LIBFPTR_TT_USN_INCOME);
      if form1.StringGrid1.Cells[6,1]='LIBFPTR_TT_USN_INCOME_OUTCOME' then fptr.setParam(1055,  fptr.LIBFPTR_TT_USN_INCOME_OUTCOME); }
    fptr.openReceipt;
    // save_log_error('Чек открыт -----------------------------------------------------------------------------> ');
    summTotal := jsonArray.Count;
    summTotal := 0;
    for var x := 1 to jsonArray.Count do
    begin

      fptr.setParam(fptr.LIBFPTR_PARAM_COMMODITY_NAME,
        jsonArray.Items[x - 1].P['name'].Value);
      fptr.setParam(fptr.LIBFPTR_PARAM_PRICE, jsonArray.Items[x - 1].P['price']
        .AsType<currency>);
      fptr.setParam(fptr.LIBFPTR_PARAM_QUANTITY,
        jsonArray.Items[x - 1].P['quantity'].Value.ToInteger);
      fptr.setParam(fptr.LIBFPTR_PARAM_TAX_TYPE, fptr.LIBFPTR_TAX_NO);
      if product = true then
        fptr.setParam(1212, 1)
      else
        fptr.setParam(1212, 4);

      if product = true then
        fptr.setParam(1212, 1)
      else
        fptr.setParam(1212, 4);

      summTotal := summTotal + jsonArray.Items[x - 1].P['price']
        .AsType<currency> * jsonArray.Items[x - 1].P['quantity']
        .Value.ToInteger;

      fptr.setParam(fptr.LIBFPTR_PARAM_TAX_TYPE, fptr.LIBFPTR_TAX_NO);

      fptr.registration;

    end;

    fptr.setParam(1055, fptr.LIBFPTR_TT_PATENT);
    { if form1.StringGrid1.Cells[6,1]='LIBFPTR_TT_PATENT' then fptr.setParam(1055,  fptr.LIBFPTR_TT_PATENT);

      if form1.StringGrid1.Cells[6,1]='LIBFPTR_TT_OSN' then fptr.setParam(1055,  fptr.LIBFPTR_TT_OSN);
      if form1.StringGrid1.Cells[6,1]='LIBFPTR_TT_USN_INCOME' then fptr.setParam(1055,  fptr.LIBFPTR_TT_USN_INCOME);
      if form1.StringGrid1.Cells[6,1]='LIBFPTR_TT_USN_INCOME_OUTCOME' then fptr.setParam(1055,  fptr.LIBFPTR_TT_USN_INCOME_OUTCOME); }

    // fptr.setParam(1055,  'fptr.'+nalog);

    if cash = true then
      fptr.setParam(fptr.LIBFPTR_PARAM_PAYMENT_TYPE, fptr.LIBFPTR_PT_CASH)
    else
      fptr.setParam(fptr.LIBFPTR_PARAM_PAYMENT_TYPE,
        fptr.LIBFPTR_PT_ELECTRONICALLY);

    fptr.setParam(fptr.LIBFPTR_PARAM_PAYMENT_SUM, summTotal);
    fptr.payment;

    fptr.setParam(fptr.LIBFPTR_PARAM_TAX_TYPE, fptr.LIBFPTR_TAX_NO);
    fptr.receiptTax;

    fptr.setParam(fptr.LIBFPTR_PARAM_SUM, summTotal);
    fptr.receiptTotal;
    fptr.closeReceipt;

    documentNumber_('');

    result := '{"errorcode":"1-012","error":"' + fptr.errorDescription +
      '","errorindex":' + inttostr(fptr.errorCode) +
      ',"data":{"documentnumber":' + documentNumber_2('') + '}}';

  except

    on E: Exception do
      result := '{"errorcode":"2-012","error":"' + E.Message + '"}';

  end;

end;

function cashboxInit(port: string): string;
var

  isCashDrawerOpened: LongBool;
  isPaperPresent: LongBool;
  isPaperNearEnd: LongBool;
  isCoverOpened: LongBool;
  isOpened: LongBool;
  serialNum: string;
  err: byte;

  Rjson: TJSONObject;

begin

  try
    CoInitialize(nil);
    fptr := CreateOleObject('AddIn.Fptr10');
    CoUninitialize;

    fptr.setParam(fptr.LIBFPTR_PARAM_DATA_TYPE, fptr.LIBFPTR_DT_SHORT_STATUS);
    fptr.queryData;

    isPaperPresent := fptr.getParamBool
      (fptr.LIBFPTR_PARAM_RECEIPT_PAPER_PRESENT);
    isPaperNearEnd := fptr.getParamBool(fptr.LIBFPTR_PARAM_PAPER_NEAR_END);
    isCoverOpened := fptr.getParamBool(fptr.LIBFPTR_PARAM_COVER_OPENED);

    fptr.open;

    isOpened := fptr.isOpened;
    fptr.setSingleSetting(fptr.LIBFPTR_SETTING_COM_FILE, 'COM' + port);

    fptr.setSingleSetting(fptr.LIBFPTR_SETTING_MODEL,
      inttostr(fptr.LIBFPTR_MODEL_ATOL_AUTO));
    fptr.setSingleSetting(fptr.LIBFPTR_SETTING_PORT,
      inttostr(fptr.LIBFPTR_PORT_COM));
    fptr.setSingleSetting(fptr.LIBFPTR_SETTING_BAUDRATE,
      inttostr(fptr.LIBFPTR_PORT_BR_115200));
    fptr.setSingleSetting(fptr.LIBFPTR_SETTING_USER_PASSWORD, inttostr(30));
    fptr.applySingleSettings;

    fptr.setParam(fptr.LIBFPTR_PARAM_DATA_TYPE, fptr.LIBFPTR_DT_SERIAL_NUMBER);
    fptr.queryData;
    serialNum := fptr.getParamString(fptr.LIBFPTR_PARAM_SERIAL_NUMBER);

    if integer(isOpened) = 0 then
    begin
      TThread.Synchronize(nil,
        procedure
        begin
          // form1.Text_cashboxconnect.text:='Соединение с кассой: нет'; вернуть!
        end);

    end;

    fptr.disableOfdChannel;
    fptr.enableOfdChannel;
    init := 1;
    result := '{"errorcode":"1-001","error":"' + fptr.errorDescription +
      '","errorindex":' + inttostr(fptr.errorCode) + ',"serialnumber":"' +
      serialNum + '"}';

  except

    on E: Exception do
      result := '{"errorcode":"2-001","error":"' + E.Message + '"}';

  end;

end;

function CashboxshiftState: string;
var
  shiftState: integer;
begin

  try
    fptr.setParam(fptr.LIBFPTR_PARAM_DATA_TYPE, fptr.LIBFPTR_DT_STATUS);
    fptr.queryData;

    shiftState := fptr.getParamInt(fptr.LIBFPTR_PARAM_SHIFT_STATE);
    result := '{"errorcode":"1-004","error":"' + fptr.errorDescription +
      '","errorindex":' + inttostr(fptr.errorCode) + ',"shiftstate":"' +
      inttostr(shiftState) + '"}';

  except

    on E: Exception do
      result := '{"errorcode":"2-004","error":"' + E.Message + '"}';

  end;

end;

end.
