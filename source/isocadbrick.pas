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

unit IsoCadBrick;

interface

uses
  Windows, Classes, Graphics, IsoCadBitmap, isocadtools;

type
  PBrick = ^TBrick;
  TBrick = class(TObject)
  private
    { Private declarations }
    iPosition: TPoint;
    iOldPosition: TPoint;
    iOrigo: TPoint;
    iWidth: Integer;
    iHeight: Integer;
    iDepth: Integer;
    iColor: DWord;
    iDrawOutline: Boolean;
    iDrawFilled: Boolean;
    iP1, iP2, iP3, iP4, iP5, iP6, iP7: TPoint;
    iRectangle: TRect;
    iName: string;
    iWireFrame: boolean;
    iSelected: Boolean;
    iWhiteFill: boolean;
    iShowSelection: boolean;
    iAlphaRender: boolean;
    iRegion: HRgn;
    iPoints: TPointArray;
    iRenderBlank: Boolean;
    iCurrentStep: integer;

  protected
    { Protected declarations }
  public
    { Public declarations }
    procedure SetPosition(aPosition: TPoint);
    function Position: Tpoint;
    function OldPosition: Tpoint;
    procedure SetWidth(aWidth: Integer);
    procedure SetHeight(aHeight: Integer);
    procedure SetDepth(aDepth: Integer);
    procedure SetDimensions(aWidth, aHeight, aDepth: integer);
    function Width: integer;
    function Height: integer;
    function WidthInPixels: integer;
    function HeightInPixels: integer;

    function Depth: integer;
    procedure SetColor(aColor: DWord);
    function Color: DWord;
    procedure Calculate;
    procedure DrawCube(aTarget: TIsoCadBitmap);
    function PointInRect(aPoint: TPoint; aRect: TRect): boolean;
    //    function PointInArea(aPoint: TPoint; aRect: TRect): boolean;
    function PointInArea(aPoint: TPoint): boolean;
    function ClientRect: TRect;
    procedure SetName(aName: string);
    procedure SetOrigo(aOrigo: TPoint);
    procedure FlipHorizontal(aInPlaceFlip: boolean);
    procedure FlipX(aInPlaceFlip: boolean);
    procedure MoveLeft;
    procedure MoveRight;
    procedure MoveUp;
    procedure MoveDown;

  published
    { Published declarations }
    constructor Create(aOrigo: TPoint);
    destructor Destroy; override;
    property DrawOutline: boolean read IDrawOutline write iDrawoutline;
    property DrawFilled: boolean read iDrawFilled write iDrawFilled;
    property WhiteFill: boolean read iWhiteFill write iWhiteFill;

    property Name: string read iName write iName;
    property Selected: boolean read iSelected write iSelected;
    property ShowSelection: boolean read iShowSelection write iShowSelection;
    property AlphaRender: boolean read iAlphaRender write iAlphaRender;
    property WireFrame: boolean read iWireFrame write iWireFrame;
    property RenderBlank: boolean read iRenderBlank write iRenderBlank;
    property CurrentStep: integer read iCurrentStep write iCurrentStep;

  end;

implementation
///

constructor TBrick.Create(aOrigo: TPoint);
begin
  //
  iRegion := 0;
  iWidth := 10;
  iHeight := 10;
  iDepth := 10;
  iOrigo := aOrigo;
  iColor := $FFFFFF;
  iCurrentStep := 16;
  iposition := point(0, 0);
  DrawOutline := true;
  DrawFilled := true;
  WhiteFill := False;
  setLength(iPoints, 6);
  Calculate;

end;

destructor TBrick.Destroy;
begin
  deleteobject(iRegion);

  //
end;

procedure TBrick.SetPosition(aPosition: TPoint);
begin
  //
  iOldPosition := iPosition;
  iposition := aPosition;
  calculate;
end;

function TBrick.Position: Tpoint;
begin
  //
  result := iPosition;
end;

function TBrick.OldPosition: Tpoint;
begin
  //
  result := iOldPosition;
end;

procedure TBrick.SetWidth(aWidth: Integer);
begin
  //
  if aWidth < 1 then
    aWidth := 1;
  iWidth := aWidth;
  calculate;
end;

procedure TBrick.SetHeight(aHeight: Integer);
begin
  //
  if aHeight < 1 then
    aHeight := 1;

  iHeight := aHeight;
  calculate;
end;

procedure TBrick.SetDepth(aDepth: Integer);
begin
  //
  if aDepth < 1 then
    aDepth := 1;

  iDepth := aDepth;
  calculate;
end;

procedure TBrick.SetDimensions(aWidth, aHeight, aDepth: integer);
begin
  if aDepth < 1 then
    aDepth := 1;
  if aWidth < 1 then
    aWidth := 1;
  if aHeight < 1 then
    aHeight := 1;

  iWidth := aWidth;
  iHeight := aHeight;
  iDepth := aDepth;
  calculate;
end;

function TBrick.Width: integer;
begin
  //
  result := iWidth;
end;

function TBrick.Height: integer;
begin
  //
  result := iHeight;
end;

function TBrick.Depth: integer;
begin
  //
  result := iDepth;
end;

procedure TBrick.SetColor(aColor: DWord);
begin
  //
  iColor := aColor;

end;

function TBrick.Color: DWord;
begin
  //
  result := iCOlor;
end;

procedure TBrick.Calculate;
var
  yy, xx, xy, zx, zy: integer;
begin
  xx := 2 * iWidth;
  xy := iWidth;
  zx := 2 * iDepth;
  zy := iDepth;
  yy := iHeight * 2;

  ip7.x := iPosition.x + iOrigo.x;
  ip7.y := iPosition.y + iOrigo.y;

  ip2.x := ip7.x + 0;
  ip2.y := ip7.y + yy;

  ip3.x := ip2.x + zx;
  ip3.y := ip2.y - zy;

  ip4.x := ip3.x;
  ip4.y := ip3.y - yy;

  ip5.x := ip4.x - xx;
  ip5.y := ip4.y - xy;

  ip6.x := ip5.x - zx;
  ip6.y := ip5.y + zy;

  ip1.x := ip6.x;
  ip1.y := ip6.y + yy;

  iRectangle := Rect(ip1.x, ip5.y, ip3.x, ip2.y);

  ipoints[0] := ip1;
  ipoints[1] := ip2;
  ipoints[2] := ip3;
  ipoints[3] := ip4;
  ipoints[4] := ip5;
  ipoints[5] := ip6;

  if iRegion <> 0 then
    deleteobject(iRegion);
  iRegion := CreatePolygonRgn(iPoints, 6, winding);

  //
end;

procedure TBrick.DrawCube(aTarget: TIsoCadBitmap);
var
  color1, color2, color3: dword;
  //  p1, p2, p3: tpoint;
  i: integer;

begin

  if (iRenderBlank) then
  begin
    color1 := $FFFFFF;
    color2 := $FFFFFF;
    color3 := $FFFFFF;

    aTarget.TriangleP(ip6, ip5, ip4, color1);
    aTarget.TriangleP(ip6, ip7, ip4, color1);

    aTarget.TriangleP(ip6, ip7, ip2, color3);
    aTarget.TriangleP(ip2, ip1, ip6, color3);

    aTarget.TriangleP(ip4, ip3, ip2, color2);
    aTarget.TriangleP(ip2, ip4, ip7, color2);
    aTarget.Line(ip1.x, ip1.y, ip2.x, ip2.y, $FFFFFF);
    aTarget.Line(ip2.x, ip2.y, ip3.x, ip3.y, $FFFFFF);
    aTarget.Line(ip3.x, ip3.y, ip4.x, ip4.y, $FFFFFF);
    aTarget.Line(ip4.x, ip4.y, ip5.x, ip5.y, $FFFFFF);
    aTarget.Line(ip5.x, ip5.y, ip6.x, ip6.y, $FFFFFF);
    aTarget.Line(ip6.x, ip6.y, ip7.x, ip7.y, $FFFFFF);
    aTarget.Line(ip7.x, ip7.y, ip2.x, ip2.y, $FFFFFF);
    aTarget.Line(ip7.x, ip7.y, ip4.x, ip4.y, $FFFFFF);
    aTarget.Line(ip6.x, ip6.y, ip1.x, ip1.y, $FFFFFF);

    exit;
  end;

  color1 := iColor;
  color3 := aTarget.colordarken(icolor, 16);
  color2 := aTarget.colordarken(icolor, 32);

  // first check filled cases
  if (iDrawFilled) and (iWireFrame = false) then
  begin

    if (iWhiteFill) then
    begin
      color1 := $FFFFFF;
      color2 := $FFFFFF;
      color3 := $FFFFFF;
    end;

    if (iAlphaRender) then
    begin
      aTarget.TriangleP(ip6, ip5, ip4, color1);
      aTarget.TriangleP(ip6, ip7, ip4, color1);

      aTarget.TriangleP(ip6, ip7, ip2, color3);
      aTarget.TriangleP(ip2, ip1, ip6, color3);

      aTarget.TriangleP(ip2, ip3, ip4, color2);
      aTarget.TriangleP(ip7, ip4, ip2, color2);

    end

      // normal case
    else
    begin
      aTarget.TriangleP(ip6, ip5, ip4, color1);
      aTarget.TriangleP(ip6, ip7, ip4, color1);

      aTarget.TriangleP(ip6, ip7, ip2, color3);
      aTarget.TriangleP(ip2, ip1, ip6, color3);

      aTarget.TriangleP(ip4, ip3, ip2, color2);
      aTarget.TriangleP(ip2, ip4, ip7, color2);

    end;
  end;
  // and here if outline or wireframe mode is true just draw lines
  if (iDrawOutline) or (iWireFrame) then
  begin

    aTarget.Line(ip1.x, ip1.y, ip2.x, ip2.y, $000000);
    aTarget.Line(ip2.x, ip2.y, ip3.x, ip3.y, $000000);
    aTarget.Line(ip3.x, ip3.y, ip4.x, ip4.y, $000000);
    aTarget.Line(ip4.x, ip4.y, ip5.x, ip5.y, $000000);
    aTarget.Line(ip5.x, ip5.y, ip6.x, ip6.y, $000000);
    aTarget.Line(ip6.x, ip6.y, ip7.x, ip7.y, $000000);
    aTarget.Line(ip7.x, ip7.y, ip2.x, ip2.y, $000000);
    aTarget.Line(ip7.x, ip7.y, ip4.x, ip4.y, $000000);
    aTarget.Line(ip6.x, ip6.y, ip1.x, ip1.y, $000000);
  end;
  if ((iSelected) and (iShowSelection)) then
  begin
    for i := 0 to 4 do
    begin
      aTarget.line(iPoints[i].x, iPoints[i].y, iPoints[i + 1].x, iPoints[i +
        1].y, $FF0000);
    end;
    aTarget.line(iPoints[5].x, iPoints[5].y, iPoints[0].x, iPoints[0].y,
      $FF0000);
  end;
end;

function TBrick.PointInRect(aPoint: TPoint; aRect: TRect): boolean;
var
  x, y: integer;
begin
  x := apoint.x;
  y := apoint.y;
  result := false;
  if (x > aRect.left) and (x < aRect.Right) and (y > aRect.Top)
    and (y < aRect.Bottom) then
    result := true;
end;

function TBrick.ClientRect: TRect;
begin
  result := iRectangle;
end;

procedure TBrick.SetName(aName: string);
begin
  iname := aname;
end;

function TBrick.WidthInPixels: integer;
begin
  result := irectangle.right - irectangle.left;
end;

function TBrick.HeightInPixels: integer;
begin
  result := irectangle.bottom - irectangle.top;
end;

function TBrick.PointInArea(aPoint: TPoint): boolean;
begin
  result := PointInPolygon(iPoints, aPoint);
end;

procedure TBrick.SetOrigo(aOrigo: TPoint);
begin
  iOrigo := aOrigo;
  Calculate;
end;

procedure TBrick.FlipHorizontal(aInPlaceFlip: boolean);
var
  tmp: integer;
  P: TPoint;
begin
  if (aInPlaceFlip = false) then
  begin
    P := iPosition;
    P.X := -P.x;
    SetPosition(P);
  end;

  tmp := iwidth;
  iwidth := iDepth;
  SetDepth(tmp);
end;

procedure TBrick.FlipX(aInPlaceFlip: boolean);
var
  tmp: integer;
  P: TPoint;
begin
  {
    if (aInPlaceFlip = false) then
    begin
      P := iPosition;
      P.X := -P.x;
      SetPosition(P);
    end;
  }
  tmp := iHeight;
  iHeight := iWidth;
  iWidth := tmp;
end;

procedure TBrick.MoveLeft;
var
  p: Tpoint;
begin
  //
  p := Position;
  dec(p.x, CurrentStep);
  setposition(p);
end;

procedure TBrick.MoveRight;
var
  p: Tpoint;
begin
  //
  p := Position;
  inc(p.x, CurrentStep);
  setposition(p);
end;

procedure TBrick.MoveUp;
var
  p: Tpoint;
begin
  //
  p := Position;
  dec(p.y, CurrentStep);
  setposition(p);
end;

procedure TBrick.MoveDown;
var
  p: Tpoint;
begin
  //
  p := Position;
  inc(p.y, CurrentStep);
  setposition(p);
end;



end.

