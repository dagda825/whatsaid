unit DataModule;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, Controls, ExtCtrls, ECSpinCtrls;

type

  { TDataMod }

  TDataMod = class(TDataModule)
    ControlButtonImages: TImageList;
    ListViewImages: TImageList;
    SelectDirectoryDialog: TSelectDirectoryDialog;
    Timer1: TTimer;
    procedure DataModuleCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private

  public

  end;

var
  DataMod: TDataMod;

implementation

{$R *.lfm}
 uses Main;
{ TDataMod }

procedure TDataMod.DataModuleCreate(Sender: TObject);
begin

end;

procedure TDataMod.Timer1Timer(Sender: TObject);
begin
  frmMain.AutoSaveSwitch.Caption := 'Saving...';
  frmMain.SaveBookMarks;
  frmMain.AutoSaveSwitch.Caption := 'Auto Save';
end;

end.

