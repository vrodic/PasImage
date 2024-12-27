unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Menus,
  FileCtrl, ComCtrls, PairSplitter, Types, Math;

type
        TTrueColor = record
       Blue : byte;
       Green : byte;
       Red : Byte;
           Alpha: Byte;
    end;
    THSVColor = record
       H : integer;
       S : byte;
       V : byte;
    end;
    TCMYKColor = record
       C : byte;
       M : byte;
       Y : byte;
       K : byte;
    end;

    PRGBByteArray = ^TRGBByteArray;
    TRGBByteArray = array[0..32767] of TTrueColor;
  { TForm1 }

  TForm1 = class(TForm)
    FileListBox1: TFileListBox;
    FileListBox2: TFileListBox;
    Image1: TImage;
    Image2: TImage;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    FlipImageLeftMenuItem: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    PairSplitter1: TPairSplitter;
    FileSplitter: TPairSplitter;
    PairSplitterSide1: TPairSplitterSide;
    PairSplitterSide2: TPairSplitterSide;
    PairSplitterSide3: TPairSplitterSide;
    PairSplitterSide4: TPairSplitterSide;
    RightMaxHeightMenuItem: TMenuItem;
    ScrollBox1: TScrollBox;
    ZoomInMenuItem: TMenuItem;
    ZoomOutMenuItem: TMenuItem;
    OpenDirectoryMenuItem: TMenuItem;
    PopupMenu1: TPopupMenu;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    StatusBar1: TStatusBar;
// Define a sensible upper limit for the image width



    procedure FileListBox1Change(Sender: TObject);
    procedure FileListBox2Change(Sender: TObject);
    procedure Arrange;
    procedure FlipImageLeftMenuItemClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Image1MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure Image2MouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);


    procedure MenuItem3Click(Sender: TObject);

    procedure OpenDirectoryMenuItemClick(Sender: TObject);
    procedure FileSplitterChangeBounds(Sender: TObject);
    procedure RightMaxHeightMenuItemClick(Sender: TObject);
    procedure SelectRandomFile(FileListBox: TFileListBox);
    procedure RandomFiles;
    procedure ZoomInMenuItemClick(Sender: TObject);
    procedure Zoom1(ZoomIn: boolean);
    procedure Zoom2(ZoomIn: boolean);
    procedure FlipImageLeft(Image: TImage);
  private
    FDragging: Boolean;
    FLastX, FLastY: Integer;
    FZoomFactor1, FZoomFactor2: Double;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.MenuItem3Click(Sender: TObject);
begin
     FormCreate(Sender);
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
 StatusBar1.SimpleText :=  FileListBox1.Directory;
  Randomize;
   FDragging   := False;
  FZoomFactor1 := 1.0;
  FZoomFactor2 := 1.0;
  RandomFiles;
    Image1.Top := 0;
  Image1.Left := 0;
   Image2.Top := 0;



end;

procedure TForm1.RandomFiles;
begin
  SelectRandomFile(FileListBox1);
  SelectRandomFile(FileListBox2);
end;

procedure TForm1.ZoomInMenuItemClick(Sender: TObject);
begin
  if TControl(Sender).Name = 'Image1' then
    Zoom1(true)
  else
    Zoom2(true);
end;

procedure TForm1.FormResize(Sender: TObject);
begin
    Arrange;
    if ((FZoomFactor1 = 1.0) and (FZoomFactor2 = 1.0)) then
    begin
         //Image1.Width := ScrollBox1.Width div 2;
         //Image1.Height := ScrollBox1.Height;
         //Image2.Left := Image1.Width;
         //Image2.Width := ScrollBox1.Width div 2;
         //Image2.Height := ScrollBox1.Height;
    end;
end;

procedure TForm1.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   // Start dragging when left button is pressed
  if Button = mbLeft then
  begin
    FDragging := True;
    FLastX := X;
    FLastY := Y;
    Image1.Cursor := crHandPoint;   // for visual feedback
  end;
end;

procedure TForm1.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
   // If dragging, pan the scrollbars
  if FDragging then
  begin
   (* ScrollBox1.HorzScrollBar.Position :=
      ScrollBox1.HorzScrollBar.Position - (X - FLastX);
    ScrollBox1.VertScrollBar.Position :=
      ScrollBox1.VertScrollBar.Position - (Y - FLastY);   *)

    // Update last mouse position
    FLastX := X;
    FLastY := Y;
  end;
end;

procedure TForm1.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    // Stop dragging
  if Button = mbLeft then
  begin
    FDragging := False;
    Image1.Cursor := crDefault;
  end;
end;

procedure TForm1.Zoom1(ZoomIn: boolean);
begin
  if ZoomIn then
   FZoomFactor1 := FZoomFactor1 * 1.1
  else
    FZoomFactor1 := FZoomFactor1 / 1.1;
     // Limit minimum zoom
  if FZoomFactor1 < 0.1 then
    FZoomFactor1 := 0.1;

  // Update image size based on zoom factor
  Image1.Width  := Round(Image1.Picture.Width  * FZoomFactor1);
  Image1.Height := Round(Image1.Picture.Height * FZoomFactor1);


  //ScrollBox1.HorzScrollBar.Range := Image1.Width+Image2.Width;
  //ScrollBox1.VertScrollBar.Range := Max(Image1.Height,Image2.Height);

end;

procedure TForm1.Zoom2(ZoomIn: boolean);
begin
  if ZoomIn then
   FZoomFactor2 := FZoomFactor2 * 1.1
  else
    FZoomFactor2 := FZoomFactor2 / 1.1;
     // Limit minimum zoom
  if FZoomFactor2 < 0.1 then
    FZoomFactor2 := 0.1;

  // Update image size based on zoom factor
  Image2.Width  := Round(Image2.Picture.Width  * FZoomFactor2);
  Image2.Height := Round(Image2.Picture.Height * FZoomFactor2);



  //ScrollBox1.HorzScrollBar.Range := Image1.Width+Image2.Width;
  //ScrollBox1.VertScrollBar.Range := Max(Image1.Height,Image2.Height);

end;

procedure TForm1.Image1MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
        // Zoom in or out by mouse wheel
  if WheelDelta > 0 then
    Zoom1(true)
  else
    Zoom1(false);
  Handled := true;

end;

procedure TForm1.Image2MouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
     // Zoom in or out by mouse wheel
  if WheelDelta > 0 then
    Zoom2(true)
  else
    Zoom2(false);
  Handled := true;
end;

procedure TForm1.Arrange;
begin
  Image1.Top := 0;
  Image1.Left := 0;
   Image2.Top := 0;
   Image1.Width := Form1.Width div 2 - FileListBox1.Width;
   Image1.Width := Max(Image2.Width, Image1.Width);
   Image2.Left := Image1.Width;
   Image2.Height := Form1.Height;
   Image1.Height := Form1.Height;

end;

procedure TForm1.FlipImageLeftMenuItemClick(Sender: TObject);
begin
  FlipImageLeft(Image1);
end;

procedure TForm1.FlipImageLeft(Image: TImage);
begin
 // GD.mirror(Image.Picture.Graphic, GD.IM_HORIZONTAL);
end;

procedure TForm1.SelectRandomFile(FileListBox: TFileListBox);
var
  RandomIndex: Integer;
begin
  if FileListBox.Items.Count > 0 then
  begin
    // Generate a random index
    RandomIndex := Random(FileListBox.Items.Count);

    // Select the file at the random index
    FileListBox.ItemIndex := RandomIndex;
  end
  else
    ShowMessage('No files to select.');
end;

procedure TForm1.FileListBox1Change(Sender: TObject);
begin
  Image2.Picture.LoadFromFile(FileListBox1.FileName);
  Arrange;

end;

procedure TForm1.FileListBox2Change(Sender: TObject);
begin
  Image1.Picture.LoadFromFile(FileListBox2.FileName);

  Arrange;
end;

procedure TForm1.OpenDirectoryMenuItemClick(Sender: TObject);
begin
   if SelectDirectoryDialog1.Execute then
   begin
      FileListBox1.Directory:=SelectDirectoryDialog1.FileName;
      StatusBar1.Caption :=  FileListBox1.Directory;
   end;

end;

procedure TForm1.FileSplitterChangeBounds(Sender: TObject);
begin

end;

procedure TForm1.RightMaxHeightMenuItemClick(Sender: TObject);
begin
  Image2.Width := Image2.Picture.Width;
  //Image2.Height:= Form1.Height;
end;

end.
