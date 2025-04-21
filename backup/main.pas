unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, DateUtils, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Grids, DBGrids, FileCtrl, Buttons, BCExpandPanels,
  BCPanel, PasLibVlcPlayerUnit, FileUtil, BGRABitmap, DataModule, ECSwitch; //, Types, LCLType;

const
  // VideoFilePathIndex is the column where the path to the video to be run is stored.

  VideoFilePathIndex = 3;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    AutoSaveSwitch: TECSwitch;
    InfoPanel: TBCExpandPanel;
    FileListBox: TFileListBox;
    NewFolderImg: TImage;
    SaveBookmarksImg: TImage;
    ForwardBtn: TSpeedButton;
    RewindBtn: TSpeedButton;
    StopBtn: TSpeedButton;
    PlayPauseBtn: TSpeedButton;
    VidCtrlPanel: TBCPanel;
    ControlPanel: TBCPanel;
    TrackBarPanel: TBCPanel;
    BookmarkGrid: TStringGrid;
    LengthLabel: TLabel;
    PositionLabel: TLabel;
    VideoTimeIndexLable: TLabel;
    VideoLengthLable1: TLabel;
    VPlayerCtrlGrp: TGroupBox;
    PageControl1: TPageControl;
    VideoPanel: TBCPanel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    VideoTracker: TTrackBar;
    VLCPlayer: TPasLibVlcPlayer;
    procedure AutoSaveSwitchClick(Sender: TObject);
    procedure BookmarkGridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ControlPanelMouseEnter(Sender: TObject);
    procedure FForwardClick(Sender: TObject);
    procedure FileListBoxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ForwardBtnClick(Sender: TObject);
    //procedure imgMenuClick(Sender: TObject);
    procedure NewFolderImgClick(Sender: TObject);
    procedure MainMenuRedraw(Sender: TObject; Bitmap: TBGRABitmap);
    procedure PauseClick(Sender: TObject);
    procedure PlayPauseBtnClick(Sender: TObject);
    procedure SaveBookMarkButtonClick(Sender: TObject);
    procedure RewindBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
    procedure SelectFolderClick(Sender: TObject);
    procedure VideoTrackerMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure VideoTrackerMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: integer);
    procedure VLCPlayerClick(Sender: TObject);
    procedure VLCPlayerMediaPlayerLengthChanged(Sender: TObject; time: int64);
    procedure VLCPlayerMediaPlayerTimeChanged(Sender: TObject; time: int64);

  private
    //FileNameStr: string;
    VideoPathStr: string;
    procedure GetBookmarks;
    procedure UpdateVideoInfoLables;
    procedure ChangeVideo(aRow: Integer);
    function Number2DT(n: int64): TDateTime;
    function DT2Number(const dt: TDateTime): int64;
  public
    procedure LoadVideo;
    procedure SaveBookMarks;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.PauseClick(Sender: TObject);
begin
  VLCPlayer.Pause();
end;

procedure TfrmMain.PlayPauseBtnClick(Sender: TObject);
begin
  if PlayPauseBtn.ImageIndex = 2 then
  begin
    PlayPauseBtn.ImageIndex := 3;
    if VLCPlayer.GetStateName = 'Paused' then
        VLCPlayer.Resume
    else
        LoadVideo;
  end
  else
  begin
       PlayPauseBtn.ImageIndex := 2;
       VLCPlayer.Pause
  end;
end;

procedure TfrmMain.SaveBookMarkButtonClick(Sender: TObject);
begin
  SaveBookMarks;
end;

procedure TfrmMain.RewindBtnClick(Sender: TObject);
var
  TimeIndex: int64;
begin
  TimeIndex := VLCPlayer.GetVideoPosInMs() - 10000;
  if (TimeIndex < 0) then
    TimeIndex := 0;

  VLCPlayer.SetVideoPosInMs(TimeIndex);

end;

procedure TfrmMain.StopBtnClick(Sender: TObject);
begin
  VLCPlayer.Stop;
end;

procedure TfrmMain.SelectFolderClick(Sender: TObject);
begin
  if DataMod.SelectDirectoryDialog.Execute then
  begin
    FileListBox.Directory := DataMod.SelectDirectoryDialog.FileName;
    getBookmarks;
  end;
end;

procedure TfrmMain.VideoTrackerMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  VideoTracker.Tag := 1;
end;

procedure TfrmMain.VideoTrackerMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: integer);
begin
  VLCPlayer.SetVideoPosInMs(VideoTracker.Position);
  VideoTracker.Tag := 0;

end;

procedure TfrmMain.VLCPlayerClick(Sender: TObject);
begin
  BookmarkGrid.InsertRowWithValues(
    BookmarkGrid.RowCount,
    [PositionLabel.Caption, '', ExtractFileName(FileListBox.FileName), VideoPathStr] );
end;

procedure TfrmMain.VLCPlayerMediaPlayerLengthChanged(Sender: TObject; time: int64);
begin
  VideoTracker.Max := VLCPlayer.GetVideoLenInMs();
  LengthLabel.Caption := VLCPlayer.GetVideoLenStr();
end;

procedure TfrmMain.VLCPlayerMediaPlayerTimeChanged(Sender: TObject; time: int64);
begin
  if VideoTracker.Tag = 0 then
    UpdateVideoInfoLables
  { #todo 1 -oJon : I'm not sure, but I may need to update the trackbar }
end;

procedure TfrmMain.UpdateVideoInfoLables;
begin
  VideoTracker.Position := VLCPlayer.GetVideoPosInMs;
  PositionLabel.Caption := VLCPlayer.GetVideoPosStr('hh:mm:ss');
end;

{
  For now, Forward and Backward will move the position 10 seconds each click.
}
procedure TfrmMain.FForwardClick(Sender: TObject);
var
  TimeIndex, TimeEndOfVideo: int64;
begin
  TimeIndex := VLCPlayer.GetVideoPosInMs() + 10000;
  TimeEndOfVideo := VLCPlayer.GetVideoLenInMs();
  if TimeIndex <= TimeEndOfVideo then
    VLCPlayer.SetVideoPosInMS(TimeIndex)
  else
    VLCPlayer.SetVideoPosInMs(TimeEndOfVideo);
end;

procedure TfrmMain.FileListBoxChange(Sender: TObject);
begin
  VideoPathStr := FileListBox.FileName;
  //ShowMessage('New VideoPathStr is . . . ' + VideoPathStr);
  getBookmarks;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
 if Assigned(VLCPlayer) then
  begin
    VLCPlayer.StartOptions.Add('--no-xlib');
    VideoPanel.Color := clSilver;
    VideoTracker.Color:= clWhite;
    //VLCPlayer.StartOptions.Add('intf=qt');  -- No QT installed, so it won't work.
    // You can add other LibVLC options here as well
  end;

end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  if BookmarkGrid.Modified = True then
     SaveBookMarks;

end;

procedure TfrmMain.ForwardBtnClick(Sender: TObject);
var
  TimeIndex: int64;
begin
  TimeIndex := VLCPlayer.GetVideoPosInMs() + 10000;

  if (TimeIndex >= VLCPlayer.GetVideoLenInMs) then
   TimeIndex := VLCPlayer.GetVideoLenInMs;

  VLCPlayer.SetVideoPosInMs(TimeIndex);

end;

//procedure TfrmMain.imgMenuClick(Sender: TObject);
//begin
//  if (ControlPanel.Tag = 0) then // Control panel is collapsed, expand it
//  begin
//    ControlPanel.Tag := 1; // Control panel is now expanded
//    ControlPanel.Width := 140;
//  end else
//  begin
//    ControlPanel.Tag := 0;  // Control panel is now collapsed
//    ControlPanel.Width := 18;
//  end;
//end;

procedure TfrmMain.NewFolderImgClick(Sender: TObject);
var
  reply, boxstyle : integer;
begin
  if DataMod.SelectDirectoryDialog.Execute then
  begin
    with application do
    begin
        if BookMarkGrid.Modified = True then
        begin
          boxstyle := MB_YESNO;
          reply := MessageBox('Save bookmarks before switching videos?', 'Save Bookmakrs?', boxstyle);
          if (reply = IDYES) then
             saveBookmarks;
        end;
    end;
  end;
// flush the bookmarks before switching folders.
    BookmarkGrid.Clear;
    FileListBox.Directory := DataMod.SelectDirectoryDialog.FileName;
    getBookmarks;
end;


//procedure TfrmMain.imgRewindClick(Sender: TObject);
//var
//  TimeIndex, TimeBeginOfVideo: int64;
//begin
//  TimeIndex := VLCPlayer.GetVideoPosInMs() - 10000;
//  TimeBeginOfVideo := 10000;
//  if TimeIndex >= TimeBeginOfVideo then
//    VLCPlayer.SetVideoPosInMS(TimeIndex)
//  else
//    VLCPlayer.SetVideoPosInMs(0);
//
//end;

procedure TfrmMain.MainMenuRedraw(Sender: TObject; Bitmap: TBGRABitmap);
begin
  Bitmap.Fill(clBtnFace);
end;

procedure TfrmMain.BookmarkGridMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  If Button = mbRight then
  begin
     //ShowMessage('woo hoo! Grid row is: ' + BookmarkGrid.Row.ToString);
     ChangeVideo(BookmarkGrid.Row);
  end;
end;

procedure TfrmMain.AutoSaveSwitchClick(Sender: TObject);
begin
  if(AutoSaveSwitch.Checked) then
  begin
    AutoSaveSwitch.State := cbChecked;
    DataMod.Timer1.Enabled := True;
  end
  else
  begin
    AutoSaveSwitch.State := cbUnchecked;
    DataMod.Timer1.Enabled := False;
  end;
end;

procedure TfrmMain.ControlPanelMouseEnter(Sender: TObject);
begin
  ControlPanel.SetFocus;
end;

procedure TfrmMain.ChangeVideo(aRow: Integer);
var
  ResumeTime: TDateTime;
  MilliSeconds: int64;
  //TempStr: string;
begin
  // Tag the Video Change State (BookmarkGrid.Tag) as busy (1)
  BookmarkGrid.Tag := 1;
  // Update the VideoPathStr. I used to test to see if it was a new path or not. That's not needed. Just set it
  VideoPathStr := BookmarkGrid.Cells[VideoFilePAthIndex, aRow];
  ResumeTime := StrToTime(BookmarkGrid.Cells[0, aRow]);
  MilliSeconds := DT2Number(ResumeTime);
  // now, load the video.
  LoadVideo;
  VLCPlayer.SetVideoPosInMS(MilliSeconds);
  UpdateVideoInfoLables;
  // Finished, Tag the Video Change State as Not Busy
  BookmarkGrid.Tag := 0;


end;

//procedure TfrmMain.CollapseButtonClick(Sender: TObject);
//begin
//  if CollapseButton.Tag = 1 then
//  begin
//    // Set Tag to 0 meaning it's closed, and then collapse the splitter by setting it's Visible to flase.
//    CollapseButton.Tag := 0;
//    SplitSideLists.Visible := False;
//  end
//  else
//  begin
//    CollapseButton.Tag := 1;
//    SplitSideLists.Visible := True;
//  end;
//end;

procedure TfrmMain.LoadVideo;
begin
  if VideoPathStr <> '' then
  begin
     VLCPlayer.Play(WideString(VideoPathStr));
     VideoTracker.Max := VLCPlayer.GetVideoLenInMs;
  end;
end;

function TfrmMain.DT2Number(const dt: TDateTime): int64;
var
  hh, nn, ss, MilliSecond: word;
begin
  DecodeTime(dt, hh, nn, ss, MilliSecond);
  Result := {trunc(dt)*86400 +} (hh * 3600 + nn * 60 + ss) * 1000;
end;

function TfrmMain.Number2DT(n: int64): TDateTime;
var
  day, hh, nn, ss: int64;
begin
  day := n div 86400;
  n := n mod 86400;
  hh := n div 3600;
  n := n mod 3600;
  nn := n div 60;
  ss := n mod 60;
  Result := EncodeTime(hh, nn, ss, 0) + day;
end;

procedure TfrmMain.GetBookmarks;
var
  LoadFromFile: string;
begin
  LoadFromFile := FileListBox.Directory + '/Bookmarks.CSV';
  if FileExists(LoadFromFile) then
  begin
     BookmarkGrid.Clear;
     BookMarkGrid.LoadFromCSVFile(LoadFromFile);
  end;

end;
{ #todo -oJon : Problem: It's possible a new folder can be selected without first saving the current one. Bookmarks might be wrongly saved to a different video.
}
procedure TfrmMain.SaveBookmarks;
var
  SaveToFile: string;
begin
  if (FileListBox.Directory <> '') then
  begin
      SaveToFile := FileListBox.Directory + '/Bookmarks.CSV';
      CopyFile(SaveToFile, FileListBox.Directory + '/Bookmarks.BAK');
      if (BookmarkGrid.RowCount > 0 ) then
        BookMarkGrid.SaveToCSVFile(SaveToFile);
  end
  else
      ShowMessage('There is no folder selected. Bookmarks were not saved');
end;


end.
