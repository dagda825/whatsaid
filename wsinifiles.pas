unit wsinifiles;

{$mode objfpc}{$H+}

interface

uses
   SysUtils, IniFiles;

var
  baseFolder, fileExt, baseConfigFolder : String;


procedure ReadIniFile(const PathStr : String);
procedure WriteIniFile(const PathStr: String);

function resolvePathStr(const SubPath: String; const UseConfigHome: boolean = true): String;

implementation

procedure ReadIniFile(const PathStr : String);
var
  Settings: TIniFile;
  IniFolderStr : String;
begin

   IniFolderStr := resolvePathStr(PathStr);
   Settings := TIniFile.Create(IniFolderStr);
   baseFolder := Settings.ReadString('paths', 'base_folder', '');
   baseConfigFolder := Settings.ReadString('paths', 'base_config_folder', '');
   FileExt := Settings.ReadString('file_format', 'file_ext', '');
   Settings.Free;

end;

procedure WriteIniFile(const PathStr : String);
var
  Settings: TIniFile;
  IniFolderStr : String;
begin

   IniFolderStr := resolvePathStr(PathStr);
   Settings := TIniFile.Create(IniFolderStr);
   Settings.WriteString('paths', 'base_folder', '');
   Settings.WriteString('paths', 'base_config_folder', '');
   Settings.WriteString('file_format', 'file_ext', '');
   Settings.Free;

end;


function resolvePathStr(const SubPath: string; const UseConfigHome: boolean = true): string;
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

  ResultPath := BaseDir + SubPath;

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

