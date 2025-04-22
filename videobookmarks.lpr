program videobookmarks;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, datetimectrls, Main, PasLibVlcPlayer, DataModule, wsinifiles;

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Title:='What Said?';
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TDataMod, DataMod);
  Application.Run;
end.

