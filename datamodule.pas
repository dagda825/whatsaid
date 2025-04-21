unit DataModule;

{$mode ObjFPC}{$H+}

interface
{ #todo 1 -oJon -cConfiguration : I need a config file for the various settings I want  }
{ #todo 1 -oJon -cConfiguration : I need a tree structure for my csv files in order to quickly and easily save bookmarks for each video }
uses
  Classes, SysUtils, Dialogs, Controls, ExtCtrls, ComCtrls, IniFiles;

const
  IniFileName = 'whatsaid.ini';

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

    FBookMarkPathStr : String;
    // In case the config is saved to a folder other than the home folder of the program.
    FBookMarkConfigStr : String;
    // The default extension. For now I'm writing to .csv files, but I want to be able to
    // write to other types, like TSV files.
    FBookMarkExtStr : String;

    procedure ReadSettings;
    procedure WriteSettings;

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
  with frmMain do
  begin
       AutoSaveSwitch.Caption := 'Saving...';
       SaveBookMarks;
       AutoSaveSwitch.Caption := 'Auto Save';

  end;
end;

procedure TDataMod.ReadSettings
var
  Settings : TIniFile;
begin
  Settings := TIniFile.Create(IniFileName);
  FBookMarkPathStr := Settings.ReadString('paths', 'base_folder', '');
  FBookMarkExtStr := Settings.ReadString('file_format', 'file_ext', '.csv');
end;

end.


