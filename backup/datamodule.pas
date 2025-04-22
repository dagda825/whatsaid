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


procedure TDataMod.Timer1Timer(Sender: TObject);
begin
  with frmMain do
  begin
       AutoSaveSwitch.Caption := 'Saving...';
       SaveBookMarks;
       AutoSaveSwitch.Caption := 'Auto Save';

  end;
end;



end.


