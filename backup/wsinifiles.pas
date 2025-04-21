unit WSIniFiles;

{$mode ObjFPC}{$H+}

interface
{
 Basic ini file layout -- note: the base_folder path is for example. The program will work out
                                the real base_folder by having the user pick a default folder
                                at first run.
 file_ext              -- note: file_ext defaults to .csv mainly due to StringGrid saving files
                                to .csv by default. I may, in the future, expand the capability
                                to add .tsv. We'll see.

 I'm also considering adding a themeing section to make skining the program easier.

 [paths]
 base_folder = /home/jon/.local/whatsaid/

 [file format]
 file_ext = '.csv'
}

uses
  Classes, SysUtils, Dialogs, Controls, ExtCtrls, ComCtrls;

type

  TWSIniFile = class
  private
    FIniFileStringList: TStringList;
    FBaseFolder : String;
    FFileExt : String;
    FConfigFolder: String;
    function getBaseFolder: String;
    function getFileExt: String;
    function getConfigFolder: String;

  public

    constructor Create;
    destructor Destroy; override;

    property BaseFolder: String read getBaseFolder;
    property FileExt: String read getFileExt;
    property ConfigFolder: String read getConfigFolder;

  end;

  function resolvePathStr(const WorkingDirectory: string; const UseConfigHome: boolean = true): string;

implementation

uses DataModule;

// private functions/procedures


constructor TWSIniFile.Create;
begin
  if not Assigned(FIniFileStringList) then
     FIniFileStringList := TStringList.Create;

end;

destructor TWSIniFile.Destroy;
begin
     inherited Destroy;
     FIniFileStringList.Free;
end;

function TWSIniFile.getBaseFolder: String;
begin
   Result := FBaseFolder;
end;

function TWSIniFile.getFileExt: String;
begin
  Result := FFileExt;
end;

function TWSIniFile.getConfigFolder: String;
begin
  if FConfigFolder = '' then
     resolfPathStr('/WhatSaid/WhatSaid.ini');
  Result := FConfigFolder;
end;

function resolvePathStr(const WorkingDirectory: string; const UseConfigHome: boolean = true): string;
var
  BaseDir: string;
  ResultPath: string;
begin
  BaseDir := '';

  if UseConfigHome then
  begin
    BaseDir := GetEnvironmentVariable('XDG_CONFIG_HOME');
    if BaseDir <> '' then
      BaseDir := IncludeTrailingPathDelimiter(BaseDir);
  end;

  if BaseDir = '' then
  begin
    BaseDir := GetEnvironmentVariable('HOME');
    if BaseDir <> '' then
      BaseDir := IncludeTrailingPathDelimiter(BaseDir) + '.config/'
    else
      BaseDir := IncludeTrailingPathDelimiter(ExpandFileName('~/')); // Fallback to home if HOME is not set
  end;

  ResultPath := BaseDir + WorkingDirectory;

  // Ensure the directory exists
  if not DirectoryExists(ResultPath) then
  begin
    try
      ForceDirectories(ResultPath);
    except
      on E: Exception do
        Writeln('Error creating path: ' + ResultPath + ' - ' + E.Message);
    end;
  end;

  Result := ResultPath;
end;


//
//// Example usage:
//var
//  ConfigDir: string;
//  BookmarksDir: string;
//
//begin
//  ConfigDir := resolvePathStr('WhatSaid/');
//  Writeln('Config directory: ', ConfigDir);
//
//  BookmarksDir := resolvePathStr('WhatSaid/bookmarks/');
//  Writeln('Bookmarks directory: ', BookmarksDir);
//
//  // To get a data directory using XDG_DATA_HOME:
//  function resolveDataPathStr(const SubPath: string): string;
//  var
//    BaseDir: string;
//  begin
//    BaseDir := GetEnvironmentVariable('XDG_DATA_HOME');
//    if BaseDir = '' then
//      BaseDir := GetEnvironmentVariable('HOME') + '/.local/share/';
//    if BaseDir = '' then
//      BaseDir := ExpandFileName('~/.local/share/');
//
//    Result := IncludeTrailingPathDelimiter(BaseDir) + SubPath;
//
//    if not DirectoryExists(Result) then
//    begin
//      try
//        ForceDirectories(Result);
//      except
//        on E: Exception do
//          Writeln('Error creating data path: ' + Result + ' - ' + E.Message);
//    end;
//
//    Result := Result;
//  end;
//
//  var
//    AppDataDir: string;
//  begin
//    AppDataDir := resolveDataPathStr('WhatSaid/');
//    Writeln('Application data directory: ', AppDataDir);
//  end;
//
//end.

end.
