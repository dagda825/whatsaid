unit WSUtils;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, Controls, ExtCtrls, ComCtrls;

type

  PVideoInfo = ^TVideoInfo;

  TVideoInfo = record
    VidePath: String; // Path relative to the video root
    CSVPath : String;
    VideoFileName: String;
    VideoCSVName: String;
  end;

  TWSVault = class
  private
    FVideoInfo : TVideoInfo;
    FBookmarksRootPath: String;
    FVideoRootNode: TTreeNode;
    FVaultTree: TTreeNodes;

  protected

  public

    constructor Create;
    destructor Destroy; override;
  published
  end;


implementation

uses
  DataModule, Main;

constructor TWSVault.Create;
begin
  if not Assigned(FVaultTree) then
     FVaultTree := TTreeNodes.Create(nil);


end;

destructor TWSVault.Destroy;
begin
  inherited Destroy;
  FVaultTree.Free;
end;


end.

