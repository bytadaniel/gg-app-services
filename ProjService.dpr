program ProjService;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms, Winapi.Windows,
  UnitService in 'UnitService.pas' {FormMain},
  UnitCashbox in 'UnitCashbox.pas';

{$R *.res}
  var
  ExtendedStyle : integer;
begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.MainFormOnTaskbar := false;
  Application.Run;
end.
