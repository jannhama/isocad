{
	IsoCad is an isometric, cad like program for simple 3D designs.
    Copyright (C) 2012  Janne Hämäläinen

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
}
unit mainform;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, ExtCtrls, ComCtrls, isocadbitmap, isocadbrick,  isocadtools;
const
  KZoomfactor = 2;
  KZoomregion = 128;
  KStickwidth = 5;
  KPlatewidth = 50;
  KPlateheight = 5;

type
  TMainWindow = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Resolution1: TMenuItem;
    N300x3001: TMenuItem;
    N640x4801: TMenuItem;
    N800x6001: TMenuItem;
    N1024x7681: TMenuItem;
      Export: TMenuItem;
    ed: TSaveDialog;
    Bricks1: TMenuItem;
    New1: TMenuItem;
    Edit1: TMenuItem;
    Delete1: TMenuItem;
    BrickPopup: TPopupMenu;
    Edit2: TMenuItem;
    Delete2: TMenuItem;
    Sendtoback1: TMenuItem;
    Deleteall1: TMenuItem;
    Bringtofront1: TMenuItem;
    Sendtobottom1: TMenuItem;
    Bringtotop1: TMenuItem;
    Help1: TMenuItem;
    About1: TMenuItem;
    View1: TMenuItem;
    Grid1: TMenuItem;
    Zoomer1: TMenuItem;
    Showselection1: TMenuItem;
    Alpharendering1: TMenuItem;
    Showaxes1: TMenuItem;
    Resetpositions1: TMenuItem;
    New2: TMenuItem;
    Save1: TMenuItem;
    SaveAsBMP1: TMenuItem;
    asJPEG1: TMenuItem;
    Exit1: TMenuItem;
    Load1: TMenuItem;
    od: TOpenDialog;
    sd: TSaveDialog;
    DetailsPane: TStatusBar;
    Fliphorizontal1: TMenuItem;
    Flip1: TMenuItem;
    allhorizontal1: TMenuItem;
    allvertical1: TMenuItem;
    Againstorigo1: TMenuItem;
    againstposition1: TMenuItem;
    againstorigo2: TMenuItem;
    againstposition2: TMenuItem;
    Edit3: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Alignpositions1: TMenuItem;
    Alignsizes1: TMenuItem;
    N2000x20001: TMenuItem;
    Showpalette1: TMenuItem;
    Wireframemode1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure N300x3001Click(Sender: TObject);
    procedure N640x4801Click(Sender: TObject);
    procedure N800x6001Click(Sender: TObject);
    procedure N1024x7681Click(Sender: TObject);

    procedure DrawCubes;
    procedure SaveasBMP1Click(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure Edit2Click(Sender: TObject);
    procedure Delete2Click(Sender: TObject);
    procedure Sendtoback1Click(Sender: TObject);
    procedure Deleteall1Click(Sender: TObject);
    procedure Bringtofront1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure Sendtobottom1Click(Sender: TObject);
    procedure Bringtotop1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Grid1Click(Sender: TObject);

    procedure Zoomer1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Showselection1Click(Sender: TObject);

    procedure Alpharendering1Click(Sender: TObject);
    procedure Showaxes1Click(Sender: TObject);
    procedure Resetpositions1Click(Sender: TObject);
    procedure asJPEG1Click(Sender: TObject);
    procedure SaveFile(aFileName: string);
    procedure LoadFile(aFileName: string);
    procedure Load1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure RenderBuffer(aBuffer: TIsoCadBitmap);
    procedure Fliphorizontal1Click(Sender: TObject);
    procedure allhorizontal1Click(Sender: TObject);
    procedure Againstorigo1Click(Sender: TObject);
    procedure againstorigo2Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Paste1Click(Sender: TObject);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Alignpositions1Click(Sender: TObject);
    procedure Alignsizes1Click(Sender: TObject);
    procedure N2000x20001Click(Sender: TObject);
    procedure FormDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FormDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ComponentsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Showpalette1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Wireframemode1Click(Sender: TObject);

  private
    { Private declarations }
    zoombuffer, dbuffer, buffer: TIsoCadBitmap;

    procedure ReDrawAll;

  public
    { Public declarations }
    iDrawingCubes: Boolean;
    ZoomMx, ZoomMy: integer;
    zpbcounter: integer;

    function getZoomFactor: integer;
    function getZoomRegion: integer;
    function getBuffer: TIsoCadBitmap;
  end;

var
  MainWindow: TMainWindow;
  //  pohja, kapula: TBrick;
  origo: TPoint;
  dragdelta: TPoint;
  BrickList: TList;
  CopyBrick, PasteBrick, Selected: PBrick;
  GridStep: integer;
  globalmousex, globalmousey: integer;
  oldglobalmousex, oldglobalmousey: integer;
  sizeincrement: integer;

implementation

uses NewBrick, ObjectWin, ZoomWin;

{$R *.DFM}

procedure TMainWindow.FormCreate(Sender: TObject);
var
  P: PBrick;
  i: integer;
begin
  sizeincrement := 2;
  zpbcounter := 2;
  gridstep := 5;
  zoombuffer := TIsoCadBitmap.create;
  zoombuffer.resize(128, 128);

  buffer := TIsoCadBitmap.create;
  dbuffer := TIsoCadBitmap.create;
  buffer.resize(800, 600);
  dbuffer.resize(800, 600);
  origo := point(400, 300);
  bricklist := TList.Create;
  // pohja
  P := new(PBrick);
  P^ := TBrick.Create(origo);
  P^.setdimensions(100, 2, 100);
  BrickList.Add(p);
  // kapula
  P := new(PBrick);
  P^ := TBrick.Create(origo);
  P^.setdimensions(5, 50, 5);
  BrickList.Add(p);

  for i := 0 to 5 do
  begin
    P := new(PBrick);
    P^ := TBrick.Create(origo);
    P^.setdimensions(20, 20, 20);
    P^.SetColor($100000 + random($FFFFFFF));
    P^.DrawOutline := False;
    BrickList.Add(p);
  end;
  Selected := nil;

end;

procedure TMainWindow.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var

  dx, dy, i: integer;
  realx, realy: integer;
  newposition: TPoint;
begin

  realx := x;
  realy := y;
  globalmousex := x;
  globalmousey := y;
  if grid1.checked then
  begin
    x := (x div gridstep) * gridstep;
    y := ((y div gridstep) * gridstep);
  end;

  dx := x - origo.x;
  dy := y - origo.y;

  if shift = [ssleft] then
  begin

    NewPosition := point(dx - dragdelta.x, dy - dragdelta.y);
    if selected <> nil then
    begin
      if selected^.Selected then
      begin
        if (alpharendering1.checked) then
        begin
          selected^.setposition(newPosition);
          redrawall;
        end
        else
        begin
          selected^.RenderBlank := True;
          selected^.DrawCube(buffer);
          selected^.setposition(newPosition);
          selected^.RenderBlank := False;
          drawcubes;
          renderbuffer(buffer);
        end;
      end;
    end;
    {
        if (alpharendering1.checked) then
          ReDrawAll;
    }
  end;

  if Zoomer1.checked then
  begin
    zoomMx := realx - ZoomWindow.zoompb.width div (KZoomfactor * 2);
    zoomMy := realy - ZoomWindow.zoompb.height div (KZoomfactor * 2);
    ZoomWindow.ZoomPb.Invalidate;
  end;

end;

procedure TMainWindow.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  deltax, deltay, dx, dy: integer;
  p: TPoint;
  i: integer;
  brick: PBrick;
  realx, realy: integer;
  apux, apuy: integer;
begin
  selected := nil;

  realx := x;
  realy := y;
  if grid1.checked then
  begin
    x := (x div gridstep) * gridstep;
    y := (y div gridstep) * gridstep;

  end;
  dx := x;
  dy := y;
  for i := 0 to bricklist.count - 1 do
  begin
    brick := bricklist[i];
    brick^.Selected := False;
  end;

  if shift = [ssRight] then
  begin
    for i := bricklist.count - 1 downto 0 do
    begin
      brick := bricklist[i];
      if (brick^.pointinArea(point(realx, realy))) then
      begin
        brick^.selected := true;
        selected := brick;
        redrawall;
        brickpopup.Popup(x + MainWindow.left, y + MainWindow.top + 64);
        redrawall;
        Break;

      end;
    end;

    if selected <> nil then
      selected^.DrawCUbe(buffer);
  end;

  if shift = [ssleft] then
  begin
    for i := bricklist.count - 1 downto 0 do
    begin
      brick := bricklist[i];
      if (brick^.pointinArea(point(realx, realy))) then
      begin
        brick^.selected := true;
        p := brick^.position;
        deltay := dy - p.y - origo.y;
        deltax := dx - p.x - origo.x;
        dragdelta.x := deltax;
        dragdelta.y := deltay;
        selected := brick;
        Break;
      end;
    end;
    if selected <> nil then
    begin
      if (alpharendering1.checked) then
      begin
        redrawall;
      end
      else
      begin
        drawcubes;
        renderbuffer(buffer);
      end;

    end;
  end;
  if Zoomer1.checked then
  begin
    zoomMx := realx - ZoomWindow.zoompb.width div (KZoomfactor * 2);
    zoomMy := realy - ZoomWindow.zoompb.height div (KZoomfactor * 2);
    ZoomWindow.ZoomPb.Invalidate;
  end;

end;

procedure TMainWindow.FormDestroy(Sender: TObject);
var
  i: integer;

begin
  dispose(copyBrick);
  for i := 0 to bricklist.count - 1 do
  begin
    Dispose(bricklist[i]);
  end;
  bricklist.free;
  dbuffer.free;
  buffer.free;
  zoombuffer.free;
end;

procedure TMainWindow.N300x3001Click(Sender: TObject);
begin
  N300x3001.checked := not N300x3001.checked;

  buffer.resize(300, 300);
  dbuffer.resize(300, 300);
  MainWindow.Invalidate;
end;

procedure TMainWindow.N640x4801Click(Sender: TObject);
begin
  N640x4801.checked := not N640x4801.checked;

  buffer.resize(640, 480);
  dbuffer.resize(640, 480);
  MainWindow.Invalidate;
end;

procedure TMainWindow.N800x6001Click(Sender: TObject);
begin
  N800x6001.checked := not N800x6001.checked;

  buffer.resize(800, 600);
  dbuffer.resize(800, 600);
  MainWindow.Invalidate;
end;

procedure TMainWindow.N1024x7681Click(Sender: TObject);
begin
  N1024x7681.checked := not N1024x7681.checked;
  buffer.resize(1024, 768);
  dbuffer.resize(1024, 768);
  MainWindow.Invalidate;
end;

procedure TMainWindow.DrawCubes;
var
  j, i: integer;
  P: PBrick;
begin

  if (iDrawingCubes) then
    exit;
  iDrawingCubes := True;
  if showaxes1.checked then
  begin
    buffer.Line(buffer.width div 2, buffer.height div 2 - 200, buffer.width div
      2,
      buffer.height div 2, $FF0000);
    buffer.Line(buffer.width div 2, buffer.height div 2, buffer.width div 2 +
      200,
      buffer.height div 2 + 100, $00FF00);
    buffer.Line(buffer.width div 2, buffer.height div 2, buffer.width div 2 -
      200,
      buffer.height div 2 + 100, $0000FF);

    for j := 0 to 150 do
    begin

      buffer.line(0, j * 32, j * 2 * 32, 0, $DDDDDD);
      buffer.line(0, buffer.height - j * 32, j * 2 * 32, buffer.height,
        $DDDDDD);

      {
            for i := 0 to 100 do
            begin

              if (J mod 2) = 0 then
                buffer.SetPixel(i * 16, j * 8, $0)
              else
                buffer.SetPixel((i+1) * 16, j * 8, $0)
            end;
      }
    end;
  end;
  for i := 0 to bricklist.count - 1 do
    //  for i := bricklist.count - 1 downto 0 do
  begin
    p := bricklist[i];
    p^.drawcube(buffer);
  end;
  if selected <> nil then
  begin
    DetailsPane.panels[1].text := inttostr(selected^.position.x);
    DetailsPane.panels[2].text := inttostr(selected^.position.y);
    DetailsPane.panels[4].text := inttostr(selected^.Width);
    DetailsPane.panels[6].text := inttostr(selected^.Height);
    DetailsPane.panels[8].text := inttostr(selected^.Depth);
  end;
  iDrawingCubes := False;

end;

procedure TMainWindow.SaveasBMP1Click(Sender: TObject);
begin
  if ed.execute then
  begin
    buffer.SaveToFile(ed.filename);
  end;
end;

procedure TMainWindow.New1Click(Sender: TObject);
var
  result: TModalResult;
  w, h, d: integer;
  name: string;
  color: DWord;
  b: byte;
  clr: TEXColor;
  brick: PBrick;
begin
  newbrickdlg.Caption := 'Create new brick';

  result := newbrickdlg.showmodal;
  if result = mrOk then
  begin
    w := newbrickdlg.width.Value;
    h := newbrickdlg.height.Value;
    d := newbrickdlg.depth.Value;
    name := newbrickdlg.Name.Text;

    clr := buffer.Split(newbrickdlg.color.color);
    b := clr.r;
    clr.r := clr.b;
    clr.b := b;
    color := buffer.Combine(clr);
    Brick := new(PBRick);
    Brick^ := TBrick.Create(Origo);
    Brick^.Name := Name;
    Brick^.SetDimensions(w, h, d);
    Brick^.SetColor(color);
    Brick^.DrawOutline := newbrickdlg.DrawOutLine.checked;
    Brick^.WhiteFIll := newbrickdlg.UseWhiteFill.Checked;
    BrickList.Add(Brick);
    ReDrawAll;
  end;

end;

procedure TMainWindow.Edit2Click(Sender: TObject);
var
  result: TModalResult;
  w, h, d: integer;
  name: string;
  color: DWord;
  b: byte;
  clr: TEXColor;
  brick: PBrick;

begin
  if selected = nil then
    exit;

  NewBrickDlg.width.Value := selected^.Width;
  NewBrickDlg.Height.Value := selected^.Height;
  NewBrickDlg.Depth.Value := selected^.Depth;
  NewBrickDlg.Name.text := selected^.Name;

  clr := buffer.Split(Selected^.Color);
  b := clr.r;
  clr.r := clr.b;
  clr.b := b;
  color := buffer.Combine(clr);

  NewBrickDlg.Color.Color := color;
  NewBrickDlg.Caption := 'Edit Brick';
  newbrickdlg.DrawOutLine.checked := Selected^.DrawOutline;
  newbrickdlg.UseWhiteFill.Checked := Selected^.WhiteFIll;

  if NewBrickDlg.ShowModal = mrOk then
  begin

    w := newbrickdlg.width.Value;
    h := newbrickdlg.height.Value;
    d := newbrickdlg.depth.Value;
    name := newbrickdlg.Name.Text;

    clr := buffer.Split(newbrickdlg.color.color);
    b := clr.r;
    clr.r := clr.b;
    clr.b := b;
    color := buffer.Combine(clr);

    Selected^.Name := Name;
    Selected^.SetDimensions(w, h, d);
    Selected^.SetColor(color);
    Selected^.DrawOutline := newbrickdlg.DrawOutLine.checked;
    Selected^.WhiteFIll := newbrickdlg.UseWhiteFill.Checked;
    Invalidate;
  end;

end;

procedure TMainWindow.Delete2Click(Sender: TObject);
begin
  BrickList.Remove(selected);
  selected := nil;
  redrawall;

end;

procedure TMainWindow.Sendtoback1Click(Sender: TObject);
var
  i: integer;
begin
  if selected = nil then
    exit;
  i := bricklist.IndexOf(selected);
  if i < 1 then
    exit;
  bricklist.Exchange(i, i - 1);
  redrawall;

end;

procedure TMainWindow.Deleteall1Click(Sender: TObject);
var
  i: integer;
begin
  for i := bricklist.count - 1 downto 0 do
  begin
    bricklist.remove(bricklist[i]);
  end;
  ReDrawAll;

end;

procedure TMainWindow.Bringtofront1Click(Sender: TObject);
var
  i: integer;
begin
  if selected = nil then
    exit;
  i := bricklist.IndexOf(selected);
  if i < bricklist.count - 1 then
    bricklist.Exchange(i, i + 1);
  redrawall;

end;

procedure TMainWindow.FormActivate(Sender: TObject);
begin
  redrawall;
end;

procedure TMainWindow.FormPaint(Sender: TObject);
begin
  redrawall;
end;

procedure TMainWindow.Sendtobottom1Click(Sender: TObject);
var
  i: integer;
begin
  if (selected = nil) or (bricklist.count < 2) then
    exit;
  i := bricklist.IndexOf(selected);
  if i < 1 then
    exit;
  bricklist.Move(i, 0);
  redrawall;

end;

procedure TMainWindow.Bringtotop1Click(Sender: TObject);
var
  i: integer;
begin
  if (selected = nil) and (bricklist.count < 2) then
    exit;
  i := bricklist.IndexOf(selected);
  if i < bricklist.count - 1 then
    bricklist.Move(i, bricklist.count - 1);
  redrawall;

end;

procedure TMainWindow.About1Click(Sender: TObject);
begin
  //  aboutdlg1.Execute;
end;

procedure TMainWindow.Grid1Click(Sender: TObject);
begin
  grid1.checked := not grid1.checked;
end;


procedure TMainWindow.Zoomer1Click(Sender: TObject);
begin
  Zoomer1.checked := not Zoomer1.checked;
  ZoomWindow.visible := zoomer1.checked;
end;

procedure TMainWindow.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  p: TPoint;
  width, height, depth: integer;
begin

  if selected <> nil then
  begin
    if (shift = [ssCtrl]) or (shift = [ssShift]) then
    begin
      width := selected^.width;
      Height := selected^.Height;
      Depth := selected^.Depth;
      if shift = [ssCtrl] then
      begin

        if key = 40 then
          inc(Height, sizeincrement);
        if key = 38 then
          dec(Height, sizeincrement);
        if key = 39 then
          dec(Width, sizeincrement);
        if key = 37 then
          inc(Width, sizeincrement);
      end
      else if shift = [ssShift] then
      begin
        if key = 40 then
          dec(Depth, sizeincrement);
        if key = 38 then
          inc(Depth, sizeincrement);
      end;
      selected^.Setwidth(width);
      selected^.SetHeight(Height);
      selected^.SetDepth(Depth);
    end

    else
    begin

      p := selected^.position;
      if key = 38 then
        dec(p.y, sizeincrement);
      if key = 40 then
        inc(p.y, sizeincrement);
      if key = 37 then
        dec(p.x, sizeincrement);
      if key = 39 then
        inc(p.x, sizeincrement);
      if key = Byte('P') then
        Sendtoback1Click(Self);
      if key = Byte('O') then
        Bringtofront1Click(Self);
      if key = Byte('X') then
        selected^.FlipX(false);
      if key = Byte('Z') then
        selected^.FlipHorizontal(True);
      if key = Byte('A') then
        Alignpositions1Click(self);
      if key = Byte('1') then
        sizeincrement := 1;
      if key = Byte('2') then
        sizeincrement := 2;
      if key = Byte('3') then
        sizeincrement := 3;
      if key = Byte('4') then
        sizeincrement := 4;

      selected^.setposition(p);

      if key = Byte('7') then
        selected^.moveleft;
      if key = Byte('8') then
        selected^.moveright;
      if key = Byte('9') then
        selected^.moveup;
      if key = Byte('0') then
        selected^.movedown;

    end;

    redrawall;
  end;

end;

procedure TMainWindow.RenderBuffer(aBuffer: TIsoCadBitmap);
var
  i: integer;
begin
  {
    for i := 0 to buffer.height do
    begin
  //      buffer.setpixel(globalmousex,i,buffer.ColorPixel(0,0,$ffff00,0,pmXorMode,0));
        buffer.setpixel(oldglobalmousex,i,$ffffff);
        buffer.setpixel(globalmousex,i,0);
    end;
     oldglobalmousex:=globalmousex;
    }
  aBuffer.Draw(MainWindow.canvas.handle, 0, 0);
  //  aBuffer.Draw(pb.canvas.handle, 0, 0);
end;

procedure TMainWindow.ReDrawAll;
var
  drect: TRect;
  i: integer;
begin
  buffer.SetWhite;
  DrawCubes;

  renderbuffer(buffer);
  zoomWindow.Clientwidth := KZoomregion * KZoomfactor;
  zoomWindow.ClientHeight := KZoomregion * KZoomfactor;
  //  zoompb.width := zoomregion ;
  //  zoompb.height := zoomregion ;

  if Zoomer1.checked then
  begin
    ZoomWindow.ZoomPb.Invalidate;
  end;

end;

procedure TMainWindow.Showselection1Click(Sender: TObject);
var
  i: integer;
  brick: PBrick;
begin
  Showselection1.checked := not Showselection1.checked;
  for i := 0 to bricklist.count - 1 do
  begin
    brick := bricklist[i];
    brick^.ShowSelection := Showselection1.checked;
  end;
  if selected <> nil then
    redrawall;

end;


procedure TMainWindow.Alpharendering1Click(Sender: TObject);
var
  i: integer;
  brick: PBrick;
begin
  Alpharendering1.checked := not Alpharendering1.checked;
  Buffer.AlphaRender := Alpharendering1.checked;
  for i := 0 to bricklist.count - 1 do
  begin
    brick := bricklist[i];
    brick^.Alpharender := Alpharendering1.checked;
  end;

  ReDrawAll;

end;

procedure TMainWindow.Showaxes1Click(Sender: TObject);
begin
  Showaxes1.checked := not Showaxes1.checked;
  ReDrawAll;
end;

procedure TMainWindow.Resetpositions1Click(Sender: TObject);
var
  i: integer;
  brick: PBrick;
begin

  for i := 0 to bricklist.count - 1 do
  begin
    brick := bricklist[i];
    brick^.SetPosition(point(0, 0));
  end;

  ReDrawAll;

end;

procedure TMainWindow.asJPEG1Click(Sender: TObject);
begin
  if ed.execute then
  begin
    buffer.SaveToJPegFile(ed.filename);
  end;

end;

procedure TMainWindow.SaveFile(aFileName: string);
var
  sfile: TStringList;
  i: integer;
  header: string;
  s: string;
  p: PBrick;
  daOrigo, X, Y, Width, Height, Depth, Color, Name: string;
  Outline, WhiteFill: string;
begin
  {
   format:
   # Header
   Origo;X,Y
   followed by n *
   X,Y,Width,Height,Depth,Color,DrawOutLine,DrawWhiteFill,Name
  }
  Header := '# This file describes the objects used by Iso Cad' + #13#10 +
    '# Iso Cad (C) 2002 Janne Hämäläinen';
  sfile := TStringList.Create;
  daOrigo := 'Origo:' + inttostr(origo.x) + ',' + inttostr(origo.y);
  Sfile.Add(Header);
  SFile.Add(daOrigo);
  for i := 0 to BrickList.Count - 1 do
  begin
    p := BrickList[i];
    X := inttostr(P^.Position.X);
    Y := inttostr(P^.Position.Y);
    Width := inttostr(P^.Width);
    Height := inttostr(P^.Height);
    Depth := inttostr(P^.Depth);
    color := inttostr(P^.Color);
    outline := 'No';
    WhiteFill := 'No';
    if (P^.DrawOutline) then
      Outline := 'Yes';
    if (P^.WhiteFill) then
      WhiteFill := 'Yes';

    Name := P^.Name;
    s := 'Object:' + X + ',' + Y + ',' + Width + ',' + Height + ',' + Depth + ','
      + Color + ',' + Outline + ',' + WhiteFill + ',' + Name;
    SFile.Add('# Object: ' + inttostr(i));
    SFile.Add(s);
  end;
  Sfile.SaveToFile(aFileName);
  sfile.Free;
end;

procedure TMainWindow.LoadFile(aFileName: string);
var
  SFile, origolist, objectlist: TStringList;
  Brick: PBRick;
  i, x, y, w, h, d: integer;
  daOrigo: TPoint;
  name: string;
  color: DWord;
  s: string;
  outline, whitefill: boolean;
begin

  // clear old objects
  Deleteall1.click;

  sfile := TStringList.Create;
  origolist := TStringList.Create;
  objectlist := TStringList.Create;
  SFile.LoadFromFile(aFileName);

  for i := 0 to sfile.count - 1 do
  begin
    s := Sfile[i];
    if (posi('#', s) <> 0) then
      continue;
    if s = '' then
      continue;
    if (posi('Origo', s) <> 0) then
    begin
      s := removesubstring(s, 'Origo:');
      parsestring(s, ',', origolist);
      if origolist.count <> 2 then
        exit;
      daOrigo.X := strtoint(origolist[0]);
      daOrigo.y := strtoint(origolist[1]);
    end
    else if (posi('Object', s) <> 0) then
    begin
      s := removesubstring(s, 'Object:');
      parsestring(s, ',', objectlist);
      if objectlist.count <> 9 then
        exit;
      WhiteFill := False;
      OutLine := False;

      x := strtoint(objectlist[0]);
      y := strtoint(objectlist[1]);
      w := strtoint(objectlist[2]);
      h := strtoint(objectlist[3]);
      d := strtoint(objectlist[4]);
      color := strtoint(objectlist[5]);
      if (Posi('yes', objectlist[6]) <> 0) then
        outline := true;
      if (Posi('yes', objectlist[7]) <> 0) then
        WhiteFill := true;
      name := objectlist[8];

      Brick := new(PBRick);
      Brick^ := TBrick.Create(daOrigo);
      Brick^.SetDimensions(w, h, d);
      Brick^.Name := Name;
      Brick^.SetColor(color);
      Brick^.DrawOutline := outline;
      Brick^.WhiteFIll := WhiteFill;
      Brick^.SetPosition(point(x, y));
      BrickList.Add(Brick);
    end;
  end;

  Sfile.Free;
  origolist.Free;
  objectlist.Free;
  redrawall;
end;

procedure TMainWindow.Load1Click(Sender: TObject);
begin
  if od.execute then
    loadfile(od.filename);
end;

procedure TMainWindow.Save1Click(Sender: TObject);
begin
  if sd.execute then
    Savefile(sd.filename);

end;

procedure TMainWindow.Fliphorizontal1Click(Sender: TObject);
begin
  if (selected = nil) then
    exit;
  Selected^.FlipHorizontal(AgainstPosition1.Checked);
  redrawall;

end;

procedure TMainWindow.allhorizontal1Click(Sender: TObject);
var
  i: integer;
  brick: PBrick;
begin

  for i := 0 to bricklist.count - 1 do
  begin
    brick := bricklist[i];
    brick^.FlipHorizontal(true);
  end;

  ReDrawAll;

end;

procedure TMainWindow.Againstorigo1Click(Sender: TObject);
var
  agp: boolean;
begin
  agp := ((sender as TMenuitem) = againstPosition1);

  if (selected = nil) then
    exit;
  Selected^.FlipHorizontal(agp);
  redrawall;

end;

procedure TMainWindow.againstorigo2Click(Sender: TObject);

var
  i: integer;
  brick: PBrick;
  agp: boolean;
begin
  agp := ((sender as TMenuitem) = againstPosition2);

  for i := 0 to bricklist.count - 1 do
  begin
    brick := bricklist[i];
    brick^.FlipHorizontal(agp);
  end;

  ReDrawAll;

end;

procedure TMainWindow.Copy1Click(Sender: TObject);
begin
  if selected = nil then
    exit;
  if copyBrick <> nil then
    dispose(copyBrick);
  copyBrick := New(PBrick);
  copyBrick^ := TBrick.Create(Origo);

  copyBrick^.SetWidth(selected^.Width);
  copyBrick^.SetHeight(selected^.Height);
  copyBrick^.SetDepth(selected^.Depth);
  copyBrick^.Name := 'Copy of ' + selected^.Name;
  copyBrick^.SetColor(Selected^.Color);
  copyBrick^.DrawOutline := Selected^.DrawOutline;
  copyBrick^.WhiteFIll := Selected^.WhiteFIll;

end;

procedure TMainWindow.Paste1Click(Sender: TObject);
begin
  if copyBrick = nil then
    exit;

  PasteBrick := New(PBrick);
  PasteBrick^ := TBrick.Create(Origo);

  PasteBrick^.SetWidth(CopyBrick^.Width);
  PasteBrick^.SetHeight(CopyBrick^.Height);
  PasteBrick^.SetDepth(CopyBrick^.Depth);
  PasteBrick^.Name := 'Copy of ' + CopyBrick^.Name;
  PasteBrick^.SetColor(CopyBrick^.Color);
  PasteBrick^.DrawOutline := CopyBrick^.DrawOutline;
  PasteBrick^.WhiteFIll := CopyBrick^.WhiteFIll;
  BrickList.Add(PasteBrick);
  ReDrawAll;

end;

procedure TMainWindow.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  p: TPoint;
  width, height, depth: integer;
begin
  if selected <> nil then
  begin

    if (shift = [ssCtrl]) or (shift = [ssShift]) or (shift = [ssAlt]) then
    begin
      width := selected^.width;
      Height := selected^.Height;
      Depth := selected^.Depth;
      if shift = [ssCtrl] then
      begin
        inc(Height, sizeincrement);
      end
      else if shift = [ssAlt] then
      begin
        inc(Width, sizeincrement);
      end
      else if shift = [ssShift] then
      begin
        inc(Depth, sizeincrement);
      end;
      selected^.Setwidth(width);
      selected^.SetHeight(Height);
      selected^.SetDepth(Depth);
    end;

    redrawall;
  end;

end;

procedure TMainWindow.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  p: TPoint;
  width, height, depth: integer;
begin
  if selected <> nil then
  begin

    if (shift = [ssCtrl]) or (shift = [ssShift]) or (shift = [ssAlt]) then
    begin
      width := selected^.width;
      Height := selected^.Height;
      Depth := selected^.Depth;
      if shift = [ssCtrl] then
      begin
        dec(Height, sizeincrement);
      end
      else if shift = [ssAlt] then
      begin
        dec(Width, sizeincrement);
      end
      else if shift = [ssShift] then
      begin
        dec(Depth, sizeincrement);
      end;
      selected^.Setwidth(width);
      selected^.SetHeight(Height);
      selected^.SetDepth(Depth);
    end;

    redrawall;
  end;

end;

procedure TMainWindow.Alignpositions1Click(Sender: TObject);
var
  i: integer;
  brick: PBrick;
  pos: TPoint;
begin

  for i := 0 to bricklist.count - 1 do
  begin
    brick := bricklist[i];
    pos := brick^.Position;
    pos.x := (pos.x div gridstep) * gridstep;
    pos.y := (pos.y div gridstep) * gridstep;
    brick^.SetPosition(pos);
  end;

  ReDrawAll;

end;

procedure TMainWindow.Alignsizes1Click(Sender: TObject);
var
  i: integer;
  brick: PBrick;
  pos: TPoint;
  w, d, h: integer;
begin

  for i := 0 to bricklist.count - 1 do
  begin
    brick := bricklist[i];
    w := (brick^.Width div gridstep) * gridstep;
    d := (brick^.Depth div gridstep) * gridstep;
    h := (brick^.Height div gridstep) * gridstep;
    brick^.SetDimensions(w, h, d);
  end;

  ReDrawAll;

end;

procedure TMainWindow.N2000x20001Click(Sender: TObject);
begin
  N2000x20001.checked := not N2000x20001.checked;
  buffer.resize(2000, 2000);
  dbuffer.resize(2000, 2000);
  MainWindow.Invalidate;

end;

procedure TMainWindow.FormDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  view: TListBox;
  s: string;
  newbrick: PBrick;
  p, w, h, d: integer;
begin

  view := (source as TListBox);
  if view = ObjectPalette.components then
  begin
    s := view.Items[view.itemindex];

    if posi('h-stick', s) <> 0 then
    begin
      w := KStickwidth;
      h := KStickWidth;
      d := KPlatewidth;
    end
    else if posi('v-stick', s) <> 0 then
    begin
      w := KStickwidth;
      h := KPlatewidth;
      d := KStickwidth;
    end
    else if posi('h-plate', s) <> 0 then
    begin
      w := KPlatewidth;
      h := KPlateheight;
      d := KPlatewidth;
    end
    else if posi('v-plate', s) <> 0 then
    begin
      w := KPlateheight;
      h := KPlatewidth;
      d := KPlatewidth;
    end
    else
      exit;

    newBrick := New(PBrick);
    newBrick^ := TBrick.Create(Origo);
    newBrick^.SetWidth(w);
    newBrick^.SetHeight(h);
    newBrick^.SetDepth(d);
    newBrick^.Name := 'new of object';
    newBrick^.SetColor($FFFFFF);
    newBrick^.DrawOutline := true;
    newBrick^.WhiteFIll := false;
    BrickList.Add(newbrick);
    ReDrawAll;

  end;

end;

procedure TMainWindow.FormDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin

  if source = ObjectPalette.components then
    accept := true;

end;

procedure TMainWindow.ComponentsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbLeft then { drag only if left button pressed }
    with Sender as TListBox do { treat Sender as TFileListBox }
    begin
      if ItemAtPos(Point(X, Y), True) >= 0 then { is there an item here? }
        BeginDrag(False); { if so, drag it }
    end;

end;

procedure TMainWindow.Showpalette1Click(Sender: TObject);
begin
  ObjectPalette.Show;
end;


function TMainWindow.GetZoomFactor: integer;
begin
  result := KZoomFactor;
end;

function TMainWindow.GetZoomRegion: integer;
begin
  result := KZoomRegion;
end;

function TMainWindow.getBuffer: TIsoCadBitmap;
begin
  result := buffer;
end;

procedure TMainWindow.Exit1Click(Sender: TObject);
begin
mainwindow.Close;
end;

procedure TMainWindow.Wireframemode1Click(Sender: TObject);
var
  i: integer;
  brick: PBrick;
begin
  WireFrameMode1.checked := not WireFrameMode1.checked;
  Buffer.WireFrame := WireFrameMode1.checked;
  for i := 0 to bricklist.count - 1 do
  begin
    brick := bricklist[i];
    brick^.WireFrame:= WireFrameMode1.checked;

  end;

  ReDrawAll;

end;

end.

