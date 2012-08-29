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

unit IsoCadBitmap;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, math, jpeg, isocadtools;
{ -------------------------------------------------------- }
const
  KMaxCosTableSize = 1440;
const
  KMaxSinTableSize = 1440;

type

  PEXColor = ^TEXCOlor;

  TEXColor =
    record
    R: integer;
    G: integer;
    B: integer;
  end;

  PDWordArray = ^TDWordArray;
  TDWordArray = array[0..16383] of DWord;

  { -------------------------------------------------------- }
  TIsoCadBitmap = class

  protected
    { Private declarations }
    FBits: PDWordArray;

    FSArray: array[0..16384] of DWord;
    PFsArray: pointer;

    Fbmpheader: TBitmapInfoHeader;
    FBmpInfo: TBitmapInfo;
    Fwidth, Fheight: integer;
    FPenColor: DWord;
    FBrushColor: DWord;
    fpr, fpg, fpb: DWord;
    FBufferSize: DWord;

    clr, lclr: TEXColor;
    iAlphaRender: Boolean;
    iWireFrame: Boolean;

    procedure SetWidth(Value: integer);
    procedure SetHeight(Value: integer);


  public
    { -------------------------------------------------------- }
        { Public declarations }
    FHdc: HDc;
    FHandle: Integer;

    Bitmap: TBitmap;

    //    Scale: Integer;
{ -------------------------------------------------------- }
    // common functions
    constructor Create;
    constructor CreateFromFile(aFileName: string);
    constructor CreateToSize(aWidth, aHeight: integer);

    destructor Destroy; override;
    procedure Resize(Width, Height: integer);
    procedure CopySize(aOriginal: TIsoCadBitmap);
    procedure Draw(DeviceContext: hdc; x, y: integer);
    procedure BlitDraw(aDeviceContext: hdc; ax, ay: integer);


    procedure SetPixel(aX, aY: integer; aColor: DWord);
    procedure SetPixel32(ay, ax, acolor: DWord);
    function GetPixel(ax, ay: integer): DWord;

    procedure Clear(aColor: DWord);
    procedure SetWhite;
    procedure SetBlack;
    procedure SetGray(level: byte);
    function Alpha(ColorA, ColorB: DWord; factor: word): DWord;

    procedure TranspSetPixel(X, Y: integer; aTranspColor, aColor: DWord);

    procedure AlphaSetPixel(aX, Ay, aAlphavalue: integer; aColor: DWord);

    function ColorDarken(Color: DWord; CDarkenValue: integer): DWord;

    function ClientRect: TRect;

    function ValidPixel(aX, aY: integer): boolean;

    { -------------------------------------------------------- }
        //2d functions

    procedure FillRect(aX, aY, aWidth, aHeight: integer; aColor: DWord);
    procedure Rectangle(X1, Y1, X2, Y2: Integer; color: DWord);

    procedure Line(x, y, x2, y2: integer; clr: DWord);


    procedure DrawHorizontalLine(X0, X1, Y: integer; Color: DWord);
    procedure DrawVerticalLine(y0, y1, x: integer; Color: DWord);

    { --     triangle functions          ---------------------------------------------------------------------- }
    procedure Triangle(x1, y1, x2, y2, x3, y3: integer; color: DWord);
    procedure TriangleP(p1, p2, p3: TPoint; aColor: DWord);

    { -------------------------------------------------------- }
    procedure DrawCircle(X, Y, Radius: Word; filled: boolean; clr: DWord);
    procedure TransBlit(Dest: TIsoCadBitmap; STColor, DTColor: DWord; x, y:
      integer);
    procedure TranspBlit(Dest: TIsoCadBitmap; STColor: DWord; x, y:
      integer);
    procedure Blit(SourceArea: TRect; Dest: TIsoCadBitmap; dX, dY: Integer);
    procedure TBlit(SourceArea: TRect; Dest: TIsoCadBitmap; STColor: DWord;
      dx, dy:
      integer);
    procedure FastBlit(SourceArea: TRect; Dest: TIsoCadBitmap; dX, dY:
      Integer);
    procedure AlphaBlit(SourceArea: TRect; Dest: TIsoCadBitmap; dX, dY,
      alphaValue: Integer; aIgnoreColor: boolean; aColorToIgnore: DWord);

    procedure CopyRect(aRect: TRect; aDx, aDy: integer; aDst: Hdc);

    procedure Duplicate(aTarget: TIsoCadBitmap);


    // i/o functions
    procedure Loadfromfile(aFilename: string);
    procedure SaveToFile(aFilename: string);
    procedure LoadfromBmpfile(filename: string);
    procedure SaveToBmpFile(filename: string);
    procedure LoadFromJpegFile(aFilename: string);
    procedure SaveToJpegFile(aFilename: string);
    function GetBitPointer(x, y: integer): pointer;
    { -------------------------------------------------------- }
        // canvas functions
    procedure UpdateDib;
    procedure UpdateCanvas;
    { -------------------------------------------------------- }
        // backward compatibility
    function Split(Value: DWord): TEXColor;
    function Combine(Value: TEXColor): DWord;

    function Bits: PDWordArray;
    { -------------------------------------------------------- }


  published
    property Width: Integer read FWidth write setwidth;
    property Height: integer read FHeight write setheight;
    property AlphaRender: Boolean read iAlphaRender write iAlphaRender;
    property WireFrame: Boolean read iWireFrame write iWireFrame;

  end;
const
  max_x = 8192;
  max_y = 8192;

implementation

constructor TIsoCadBitmap.Create;
begin

  FWidth := 400;
  FHeight := 400;
  AlphaRender := False;
  Resize(FWidth, FHeight);


end;

constructor TIsoCadBitmap.CreateFromFile(aFileName: string);
begin
  Create;
  LoadFromFile(aFIleName);

end;

constructor TIsoCadBitmap.CreateToSize(aWidth, aHeight: integer);
begin

  FWidth := aWIdth;
  FHeight := aHeight;
  AlphaRender := False;
  Resize(FWidth, FHeight);


end;

destructor TIsoCadBitmap.Destroy;
begin
  deleteobject(Fhandle);
  deleteobject(FHdc);

  FHandle := 0;
  if bitmap <> nil then
  begin
    bitmap.free
  end;

end;

procedure TIsoCadBitmap.CopySize(aOriginal: TIsoCadBitmap);
begin
  resize(aOriginal.width, aOriginal.height);
end;

procedure TIsoCadBitmap.Resize(Width, Height: integer);
var
  i: integer;
begin

  if Fhandle <> 0 then
    deleteobject(Fhandle);
  if FHdc <> 0 then
    deletedc(fHdc);

  FHandle := 0;
  FHdc := 0;
  FWidth := Width;
  FHeight := Height;
  FHdc := CreateCompatibleDC(0);

  with FBmpHeader do
  begin
    biSize := SizeOf(FBmpHeader);
    biWidth := FWidth;
    biHeight := -FHeight;
    biPlanes := 1;
    biBitCount := 32;
    biCompression := BI_RGB;
    biSizeImage := 0;
  end;
  FBmpInfo.bmiHeader := FBmpHeader;

  FHandle := CreateDIBSection(fhdc,
    FBmpInfo,
    DIB_RGB_COLORS,
    pointer(Fbits),
    0,
    0);

  for i := 0 to fheight do
    fsarray[i] := (FWIDTH * I);
  pfsarray := @fsarray;
  SelectObject(fhdc, fhandle);
  FBufferSize := ((FWidth * 4) * FHeight);
end;

procedure TIsoCadBitmap.SetWidth(Value: integer);
begin
  resize(value, FHeight);
end;

procedure TIsoCadBitmap.SetHeight(Value: integer);
begin
  resize(FWidth, value);
end;

procedure TIsoCadBitmap.Draw(DeviceContext: hdc; x, y: integer);
begin

  SetDIBitsToDevice(DeviceContext,
    x, y, FWidth, FHeight,
    0, 0, 0, FHeight,
    FBits,
    FBmpInfo,
    DIB_RGB_COLORS);
end;

procedure TIsoCadBitmap.BlitDraw(aDeviceContext: hdc; ax, ay: integer);
begin

  bitblt(aDeviceContext, ax, ay, fwidth, fheight, fhdc, 0, 0, SRCCOPY);

end;

procedure TIsoCadBitmap.SetPixel32(ay, ax, acolor: DWord); register;
asm
     push eax
     mov eax,[EAX+FWIDTH]
     mul edx
     add eax,ecx
     mov edx,eax
     pop eax
     mov ecx,[ebp+$08]
     push esi
     mov esi,[eax+FBits]
     mov [esi+edx*4],ecx
     pop esi
end;

procedure TIsoCadBitmap.SetPixel(aX, aY: integer; aColor: DWord);
var
  offset: DWord;

begin
  if (aY < FHeight) and (ax < FWidth) and (aY >= 0) and (ax >= 0) then
  begin
    offset := fsarray[aY];
    FBits[offset + aX] := aColor;
  end;
end;

function TIsoCadBitmap.GetPixel(aX, aY: integer): DWord;
var
  offset: DWord;
begin
  result := 0;
  if (aY < FHeight) and (aX < FWidth) and (aY >= 0) and (aX >= 0) then
  begin

    offset := fsarray[aY];
    result := FBits[offset + ax];

  end;
end;

procedure TIsoCadBitmap.Clear(aColor: DWord);
var
  i, j: integer;
begin
  if aColor = 0 then
    setblack
  else if aColor = $FFFFFF then
    setwhite
  else
  begin
    for j := 0 to Fheight - 1 do
    begin
      for i := 0 to Fwidth - 1 do
      begin
        setpixel(i, j, aColor);
      end;
    end;
  end;
end;

procedure TIsoCadBitmap.SetBlack;
begin
  ZeroMemory(FBits, FBufferSize);
end;

procedure TIsoCadBitmap.SetWhite;
begin
  FillMemory(FBits, FBufferSize, $FF);
end;

procedure TIsoCadBitmap.SetGray(level: byte);
begin
  FillMemory(FBits, FBufferSize, level);
end;


// Bressenhams

procedure TIsoCadBitmap.line(x, y, x2, y2: integer; clr: DWord);
var
  d, dx, dy, ai, bi, xi, yi: integer;

begin
  if x > max_x then
    x := max_x;
  if x2 > max_x then
    x2 := max_x;
  if y > max_y then
    y := max_y;
  if y2 > max_y then
    y2 := max_y;

  if (x = x2) and (y = y2) then
    exit;
  if (x = x2) and (y <> y2) then
  begin
    if y > y2 then
    begin
      yi := y;
      y := y2;
      y2 := yi;
    end;
    for yi := y to y2 do
      setpixel(x, yi, clr);
  end
  else if (x <> x2) and (y = y2) then
  begin
    if x > x2 then
    begin
      xi := x;
      x := x2;
      x2 := xi;
    end;
    for xi := x to x2 do
      setpixel(xi, y, clr);
  end
  else // these are diagonal lines
  begin
    if (x < x2) then
    begin
      xi := 1;
      dx := x2 - x;
    end
    else
    begin
      xi := -1;
      dx := x - x2;
    end;
    if (y < y2) then
    begin
      yi := 1;
      dy := y2 - y;
    end
    else
    begin
      yi := -1;
      dy := y - y2;
    end;
    setpixel(x, y, clr);

    if dx > dy then
    begin
      ai := (dy - dx) shl 1;
      bi := dy shl 1;
      d := bi - dx;
      repeat
        if (d >= 0) then
        begin
          inc(y, yi);
          inc(d, ai);
        end
        else
          inc(d, bi);
        inc(x, xi);
        setpixel(x, y, clr);
      until (x = x2);
    end
    else
    begin
      ai := (dx - dy) shl 1;
      bi := dx shl 1;
      d := bi - dy;
      repeat
        if (d >= 0) then
        begin
          inc(x, xi);
          inc(d, ai);
        end
        else
          inc(d, bi);
        inc(y, yi);
        setpixel(x, y, clr);
      until (y = y2);
    end;
  end;

end;



// fast circle routine.

procedure TIsoCadBitmap.DrawCircle(X, Y, Radius: Word; filled: boolean; clr:
  DWord);
var
  Xs, Ys: Integer;
  oXs, oYs: Integer;
  Da, Db, S: Integer;
begin

  if (Radius = 0) then
    Exit;

  if (Radius = 1) then
  begin
    SetPixel(x, y, clr);
    Exit;
  end;

  Xs := 0;
  Ys := Radius;

  oxs := xs;
  oys := ys;

  repeat
    Da := Sqr(Xs + 1) + Sqr(Ys) - Sqr(Radius);
    Db := Sqr(Xs + 1) + Sqr(Ys - 1) - Sqr(Radius);

    S := Da + Db;

    Xs := Xs + 1;
    if (S > 0) then
      Ys := Ys - 1;

    if filled = false then
    begin
      SetPixel(X + Xs - 1, Y - Ys + 1, clr);
      SetPixel(X - Xs + 1, Y - Ys + 1, clr);
      SetPixel(X + Ys - 1, Y - Xs + 1, clr);
      SetPixel(X - Ys + 1, Y - Xs + 1, clr);
      SetPixel(X + Xs - 1, Y + Ys - 1, clr);
      SetPixel(X - Xs + 1, Y + Ys - 1, clr);
      SetPixel(X + Ys - 1, Y + Xs - 1, clr);
      SetPixel(X - Ys + 1, Y + Xs - 1, clr);
    end;

    if filled = true then
    begin
      line(X + Ys - 1, Y - Xs + 1, X - Ys + 1, Y - Xs + 1, clr);
      line(X + Ys - 1, Y + Xs - 1, X - Ys + 1, Y + Xs - 1, clr);
      if (oxs <> xs) and (oys <> ys) then
      begin
        line(X + Xs - 1, Y - Ys + 1, X - Xs + 1, Y - Ys + 1, clr);
        line(X + Xs - 1, Y + Ys - 1, X - Xs + 1, Y + Ys - 1, clr);
      end;
    end;
    oxs := xs;
    oys := ys;
  until (Xs >= Ys);

end;







function TIsoCadBitmap.Split(Value: DWord): TEXColor;

begin
  result.B := Value and 255;
  result.G := (Value shr 8) and 255;
  result.R := (Value shr 16) and 255;

end;

function TIsoCadBitmap.Combine(Value: TEXColor): DWord;

begin

  result := Value.R;
  result := result shl 8;
  result := result or Value.G;
  result := result shl 8;
  result := result or Value.B;
  result := result and $FFFFFF;

end;

procedure TIsoCadBitmap.LoadfromBmpfile(filename: string);
var
  Bmp: TBITMAP;
  //  b: TBitmap;
  //  hDC: Integer;
  hbmp: integer;
begin

  bmp := TBitmap.create;
  bmp.LoadFromFile(filename);
  hbmp := bmp.handle;
  FWidth := Bmp.Width;
  FHeight := Bmp.Height;
  resize(fwidth, fheight);

  GetDIBits(bmp.canvas.handle, hBmp, 0, FHeight, FBits, FBmpInfo,
    DIB_RGB_COLORS);
  bmp.free;
end;

procedure TIsoCadBitmap.SaveToBmpFile(filename: string);
var
  Bmp: TBITMAP;
begin

  bmp := TBitmap.create;


  Bmp.Width := FWidth;
  Bmp.Height := FHeight;
  bmp.pixelformat := pf24bit;
  //  resize( fwidth, fheight );

  SetDIBitsToDevice(bmp.canvas.handle,
    0, 0, FWidth, FHeight,
    0, 0, 0, FHeight,
    FBits,
    FBmpInfo,
    DIB_RGB_COLORS);
  bmp.savetofile(filename);
  bmp.free;
end;





procedure TIsoCadBitmap.Rectangle(X1, Y1, X2, Y2: Integer; color: DWord);
begin
  //
  line(x1, y1, x2, y1, color);
  line(x2, y1, x2, y2, color);
  line(x1, y1, x1, y2, color);
  line(x1, y2, x2, y2, color);
end;

procedure TIsoCadBitmap.FillRect(aX, aY, aWidth, aHeight: integer; aColor:
  DWord);
var
  i: integer;
begin
  for i := ay to aHeight do
  begin
    DrawHorizontalLine(ax, ax + awidth, i, aColor);

  end;

end;


procedure TIsoCadBitmap.TransBlit(Dest: TIsoCadBitmap; STColor, DTColor:
  DWord; x, y:
  integer);
var
  i, j: integer;
  sc, dc: Longint;
begin
  //
  for j := 0 to height do
  begin

    for i := 0 to width do
    begin
      dc := Dest.GetPixel(x + i, y + j);
      sc := getpixel(i, j);
      if (dc = DTColor) and (sc <> STColor) then
      begin
        dest.SetPixel(x + i, y + j, sc);
      end;
    end;
  end;

end;

// copies all the pixels but not transp. colored

procedure TIsoCadBitmap.TranspBlit(Dest: TIsoCadBitmap; STColor: DWord;
  x, y: integer);
var
  i, j: integer;
  sc: Longint;
begin
  //
  for j := 0 to height - 1 do
  begin

    for i := 0 to width - 1 do
    begin
      sc := getpixel(i, j);
      if (sc <> STColor) then
      begin
        dest.SetPixel(x + i, y + j, sc);
      end;
    end;
  end;

end;



procedure TIsoCadBitmap.LoadFromJpegFile(aFilename: string);
var
  Bmp: TBITMAP;
  jpeg: TJpegimage;
begin
  //  jpeg := nil;
  jpeg := TJPegImage.Create;
  jpeg.pixelformat := jf24bit;
  jpeg.Performance := jpBestQuality;
  //  bmp := nil;
  bmp := TBitmap.create;
  bmp.PixelFormat := pf24bit;

  try
    Jpeg.LoadFromFile(aFilename);
    bmp.width := jpeg.width;
    bmp.height := jpeg.height;
    bmp.Assign(jpeg);

  except
    jpeg.free;
    bmp.free;
    exit;
  end;

  FWidth := Bmp.Width;
  FHeight := Bmp.Height;
  resize(fwidth, fheight);
  GetDIBits(bmp.canvas.handle, bmp.handle, 0, FHeight, FBits, FBmpInfo,
    DIB_RGB_COLORS);

  bmp.free;

end;

procedure TIsoCadBitmap.SaveToJpegFile(aFilename: string);
var
  Bmp: TBITMAP;
  jpeg: TJPegImage;
begin

  bmp := TBitmap.create;
  Bmp.Width := FWidth;
  Bmp.Height := FHeight;
  bmp.pixelformat := pf24bit;

  jpeg := TJPegImage.Create;
  jpeg.pixelformat := jf24bit;
  jpeg.Performance := jpBestQuality;

  SetDIBitsToDevice(bmp.canvas.handle,
    0, 0, FWidth, FHeight,
    0, 0, 0, FHeight,
    FBits,
    FBmpInfo,
    DIB_RGB_COLORS);
  jpeg.assign(bmp);
  jpeg.savetofile(aFilename);
  jpeg.free;
  bmp.free;

end;

// normal area blit

procedure TIsoCadBitmap.Blit(SourceArea: TRect; Dest: TIsoCadBitmap; dX,
  dY: Integer);
var
  sourcepix: DWord;
  i, j: integer;
begin
  for j := SourceArea.top to SourceArea.bottom - 1 do
  begin
    for i := SourceArea.left to SourceArea.Right - 1 do
    begin
      sourcepix := GetPixel(i, j);
      Dest.SetPixel(i - SourceArea.left + dx, j - SourceArea.top + dy,
        sourcepix);
    end;
  end;

end;

// copies particular area using transpblit method

procedure TIsoCadBitmap.TBlit(SourceArea: TRect; Dest: TIsoCadBitmap;
  STColor: DWord; dx,
  dy: integer);
var
  sc: Dword;
  i, j: integer;
begin
  for j := SourceArea.top to SourceArea.bottom - 1 do
  begin
    for i := SourceArea.left to SourceArea.Right - 1 do
    begin
      sc := getpixel(i, j);
      if (sc <> STColor) then
      begin
        Dest.SetPixel(i - SourceArea.left + dx, j - SourceArea.top + dy, sc);
      end;
    end;
  end;

end;


procedure TIsoCadBitmap.UpdateCanvas;
begin
  if bitmap <> nil then
  begin
    bitmap.free
  end;
  bitmap := TBitmap.Create;
  bitmap.Width := FWidth;
  bitmap.Height := FHeight;
  bitmap.pixelformat := pf24bit;
  SetDIBitsToDevice(bitmap.canvas.handle,
    0, 0, FWidth, FHeight,
    0, 0, 0, FHeight,
    FBits,
    FBmpInfo,
    DIB_RGB_COLORS);

end;

procedure TIsoCadBitmap.UpdateDib;
begin
  if (bitmap.width <> FWidth) or (bitmap.height <> FHeight) then
    resize(bitmap.width, bitmap.height);

  GetDIBits(bitmap.canvas.handle, bitmap.handle, 0, FHeight, FBits, FBmpInfo,
    DIB_RGB_COLORS);
end;


procedure TIsoCadBitmap.FastBlit(SourceArea: TRect; Dest: TIsoCadBitmap;
  dX, dY: Integer);
var
  source, Desti: pointer;
  i: integer;
begin
  if sourcearea.right > width then
    sourcearea.right := sourcearea.left + width;
  if (sourcearea.right - sourcearea.left) > dest.Width then
    sourcearea.right := dest.width - dx - 1;
  if sourcearea.bottom > height then
    sourcearea.bottom := height - 1;
  if sourcearea.bottom - sourcearea.top > height then
    sourcearea.bottom := sourcearea.top + height - 1;
  if (sourcearea.bottom - sourcearea.top) > dest.height then
    sourcearea.bottom := dest.height - dy;

  for i := SourceArea.Top to SourceArea.Bottom do
  begin
    Source := GetBitPointer(SourceArea.left, i);
    Desti := dest.GetBitPointer(dx, (i - SourceArea.Top) + dy);
    CopyMemory(Desti, Source, ((SourceArea.Right - SourceArea.LEft) * 4));
  end;
end;




function TIsoCadBitmap.GetBitPointer(x, y: integer): pointer;
var
  offset: DWord;
begin
  result := nil;
  offset := fsarray[y] + x;
  result := addr(fbits[offset]);
end;

procedure TIsoCadBitmap.AlphaBlit(SourceArea: TRect; Dest: TIsoCadBitmap;
  dX, dY,
  alphaValue: Integer; aIgnoreColor: boolean; aColorToIgnore: DWord);
var
  sourcepix, destpixel, newpixel: dword;
  i, j: integer;
begin
  for j := SourceArea.top to SourceArea.bottom - 1 do
  begin
    for i := SourceArea.left to SourceArea.Right - 1 do
    begin
      sourcepix := GetPixel(i, j);
      destpixel := dest.GetPixel(i + dx - SourceArea.left, j + dy -
        SourceArea.top);
      if (aIgnoreColor) then
      begin
        if SourcePix = aColorToIgnore then
          Sourcepix := DestPixel;

      end;

      destpixel := dest.GetPixel(i + dx - SourceArea.left, j + dy -
        SourceArea.top);
      newpixel := alpha(sourcepix, destpixel, alphavalue);
      Dest.SetPixel(i - SourceArea.left + dx, j - SourceArea.top + dy,
        newpixel);
    end;
  end;

end;

function TIsoCadBitmap.Alpha(ColorA, ColorB: DWord; factor: word): DWord;
var
  clra, clrb, res: TExColor;
  fac: word;
begin


  if factor < 0 then
    factor := 0;
  if factor > 256 then
    factor := 256;
  clra := split(colora);
  clrb := split(colorb);

  fac := 256 - factor;
  clra.r := ((fac) * clra.r) shr 8;
  clra.g := ((fac) * clra.g) shr 8;
  clra.b := ((fac) * clra.b) shr 8;

  clrb.r := (factor * clrb.r) shr 8;
  clrb.g := (factor * clrb.g) shr 8;
  clrb.b := (factor * clrb.b) shr 8;

  // -- combp
  res.r := clra.r + clrb.r;
  if res.r > 255 then
    res.r := 255;

  res.g := clra.g + clrb.g;
  if res.g > 255 then
    res.g := 255;

  res.b := clra.b + clrb.b;
  if res.b > 255 then
    res.b := 255;
  result := combine(res);

end;


procedure TIsoCadBitmap.DrawHorizontalLine(X0, X1, Y: integer; Color: DWord);
var
  i, n: integer;
  temp: DWord;
begin
  if (X0 > FWidth) or (y > FHeight) then
    exit;
  if X0 >= X1 then
  begin
    n := x1;
    x1 := x0;
    x0 := n;
  end;
  if x1 > width then
    x1 := width;
  for i := X0 to X1 do
  begin
    if AlphaRender then
      AlphaSetPixel(i, y, $E0, color)
    else
    begin
      temp := GetPixel(i, y);
      if temp <> color then
        SetPixel(i, y, color);
    end;
  end;

end;

procedure TIsoCadBitmap.DrawVerticalLine(y0, y1, x: integer; Color: DWord);
begin
  line(x, y0, x, y1, color);
end;



function TIsoCadBitmap.ClientRect: TRect;
begin
  result := rect(0, 0, Width, Height);

end;


procedure TIsoCadBitmap.TriangleP(p1, p2, p3: TPoint; aColor: DWord);
var
  x1, y1, x2, y2, x3, y3: DWord;
begin
  x1 := p1.x;
  x2 := p2.x;
  x3 := p3.x;
  y1 := p1.y;
  y2 := p2.y;
  y3 := p3.y;
  Triangle(x1, y1, x2, y2, x3, y3, aColor);

end;

procedure TIsoCadBitmap.Triangle(x1, y1, x2, y2, x3, y3: integer; color: DWord);
var
  First, Last, xx, ax, bx, yy, p1, q1, p2, q2, p3, q3: longint;

begin
  {First we must find first and last line}
  First := y1;
  Last := y1;
  if y2 < First then
    First := y2;
  if y2 > Last then
    Last := y2;
  if y3 < First then
    First := y3;
  if y3 > Last then
    Last := y3;

  p1 := x1 - x3;
  q1 := y1 - y3;
  p2 := x2 - x1;
  q2 := y2 - y1;
  p3 := x3 - x2;
  q3 := y3 - y2;
  // this is a trick
  for yy := First to Last do
  begin
    ax := Width;
    bx := -1;
    if (y3 >= yy) or (y1 >= yy) then
      if (y3 <= yy) or (y1 <= yy) then
        if not (y3 = y1) then
        begin
          xx := (yy - y3) * p1 div q1 + x3;
          if xx < ax then
            ax := xx;
          if xx > bx then
            bx := xx;
        end;
    if (y1 >= yy) or (y2 >= yy) then
      if (y1 <= yy) or (y2 <= yy) then
        if not (y1 = y2) then
        begin
          xx := (yy - y1) * p2 div q2 + x1;
          if xx < ax then
            ax := xx;
          if xx > bx then
            bx := xx;
        end;
    if (y2 >= yy) or (y3 >= yy) then
      if (y2 <= yy) or (y3 <= yy) then
        if not (y2 = y3) then
        begin
          xx := (yy - y2) * p3 div q3 + x2;
          if xx < ax then
            ax := xx;
          if xx > bx then
            bx := xx;
        end;

    // here
    if ax <= bx then
      DrawHorizontalLine(ax, bx, yy, color);
  end;
end;


procedure TIsoCadBitmap.AlphaSetPixel(aX, Ay, aAlphavalue: integer; aColor: DWord);
var
  color, color2: DWord;
begin
  //
  color := GetPixel(ax, ay);
  if color = acolor then
    exit;
  color2 := Alpha(color, aColor, aAlphavalue);
  if color2 = color then
    exit;
  SetPixel(ax, ay, color2);

end;



procedure TIsoCadBitmap.SaveToFile(aFilename: string);
begin
  if ImageFormat(aFileName) = ifJpegFile then
    SaveToJpegFile(aFileName);
  if ImageFormat(aFileName) = ifBitmapFile then
    SaveToBmpFile(aFileName);

end;



procedure TIsoCadBitmap.TranspSetPixel(X, Y: integer; aTranspColor, aColor:
  DWord);
begin
  if aColor <> aTranspColor then
    setpixel(x, y, aColor);
  //
end;


function TIsoCadBitmap.Bits: PDWordArray;
begin
  result := FBits;
end;

procedure TIsoCadBitmap.CopyRect(aRect: TRect; aDx, aDy: integer; aDst:
  Hdc);
var
  drec: TRect;
  wid, hei, i, j: integer;
begin
  //
  drec := NormalizeRect(aRect);
  bitblt(aDst, aDx, aDy, drec.right, drec.bottom, fhdc, drec.left, drec.top,
    srccopy);


end;



procedure TIsoCadBitmap.Duplicate(aTarget: TIsoCadBitmap);
begin
  aTarget.CopySize(self);
  draw(aTarget.fhdc, 0, 0);

end;



function TIsoCadBitmap.ValidPixel(aX, aY: integer): boolean;
begin
  result := False;
  if (aX >= 0) and (aX <= fwidth) and (aY >= 0) and (aY <= fHeight) then
    result := True;

end;

function TIsoCadBitmap.ColorDarken(Color: DWord; CDarkenValue: integer):
  DWord;
var
  r: Longint;
  g: Longint;
  b: Longint;
  c: Longint;

begin
  //  b := Color;
  B := Color and 255;
  color := color shr 8;
  G := Color and 255;
  color := color shr 8;
  R := Color and 255;

  dec(r, CDarkenValue);
  if r < 0 then
    r := 0;
  dec(g, CDarkenValue);
  if g < 0 then
    g := 0;
  dec(b, CDarkenValue);
  if b < 0 then
    b := 0;

  c := r;
  c := c shl 8;
  c := c or g;
  c := c shl 8;
  c := c or b;
  c := c and $FFFFFF;
  result := C;

end;

procedure TIsoCadBitmap.Loadfromfile(aFilename: string);
begin
  if ImageFormat(aFileName) = ifJpegFile then
    LoadFromJpegFile(aFileName);
  if ImageFormat(aFileName) = ifBitmapFile then
    LoadFromBmpFile(aFileName);

end;



end.

