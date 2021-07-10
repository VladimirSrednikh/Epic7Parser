program Epic7xParser;
uses
  Forms,
  Windows,
  System.SysUtils,
  superobject,
  uCEFApplication,
  uCEFConstants,
  untMainForm in 'untMainForm.pas' {frmEpic7xParser},
  untCEFSearch in 'untCEFSearch.pas';

{$R *.res}
{$SetPEFlags IMAGE_FILE_LARGE_ADDRESS_AWARE}
begin
  // GlobalCEFApp creation and initialization moved to a different unit to fix the memory leak described in the bug #89
  // https://github.com/salvadordf/CEF4Delphi/issues/89
  CreateGlobalCEFApp;
  GlobalCEFApp.LogSeverity := CEF_LOG_SEVERITY_INFO;
  if not GlobalCEFApp.StartMainProcess then
  begin
    DestroyGlobalCEFApp;
    Exit;
  end;
  //ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmEpic7xParser, frmEpic7xParser);
  Application.Run;
  // This is not really necessary to fix the bug #89 but if you free GlobalCEFApp in a different unit
  // then you can call 'FreeAndNil' without adding SysUtils to this DPR.
  DestroyGlobalCEFApp;
end.
