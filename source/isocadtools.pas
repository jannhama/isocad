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

unit IsoCadTools;

interface
uses
  Windows, Messages, SysUtils, Classes, Dialogs, StdCtrls, filectrl, forms;

type

  TImageFormat = (ifBitmapFile, ifJpegFile, ifUnknown);
  TPointArray = array of TPoint;


procedure ParseString(s: string; delimiter: char; dest: TStringlist);
procedure ParseStrings(aString: string; aDelimiter: string; aTarget: TStrings);

function PosI(pattern, source: string): longint;
function RemoveSubstring(Source, Substring: string): string;
function RemoveAllSubstrings(Source, Substring: string): string;
function ReplaceChars(Source: string; PatternChar, ReplaceChar: char): string;
function ReplaceString(aSourceString, aPattern, aReplaceString: string): string;
function RandomN(aRange: integer): integer;
function ApplicationPath: string;
function ImageFormat(aFileName: string): TImageFormat;
function NormalizeRect(R: TRect): TRect;
function pointInPolygon(const aPolygon: TPointArray; const aPoint: TPoint): Boolean;



implementation


procedure ParseString(s: string; delimiter: char; dest: TStringlist);
var
  comma: integer;
  word, stringi: string;
begin
  dest.clear;
  stringi := s;
  word := '';
  while (true) do
  begin
    comma := pos(delimiter, stringi);
    if comma = 0 then
      break;
    word := copy(stringi, 1, comma - 1);
    dest.Add(word);
    delete(stringi, 1, comma);
  end;
  word := stringi;
  dest.add(word);
end;


procedure ParseStrings(aString: string; aDelimiter: string; aTarget: TStrings);
var
  comma: integer;
  word, stringi: string;
begin
  aTarget.clear;
  stringi := aString;
  word := '';
  while (true) do
  begin
    comma := posi(aDelimiter, stringi);
    if comma = 0 then
      break;
    word := copy(stringi, 1, comma - 1);
    aTarget.Add(word);
    delete(stringi, 1, comma + length(aDelimiter) - 1);
  end;
  word := stringi;
  aTarget.add(word);

end;




function PosI(pattern, source: string): longint;
var
  current: string;
  i, sourcelen, patlen: longint;
  found: boolean;
begin
  found := false;
  i := 1;
  sourcelen := length(source);
  patlen := length(pattern);
  while ((i + patlen) <= sourcelen + 1) do
  begin
    current := copy(source, i, patlen);
    if (strIcomp(pchar(pattern), pchar(current)) = 0) then
    begin
      found := true;
      break;
    end;
    inc(i);
  end;
  if found = false then
    i := 0;
  result := i;
end;





function RemoveSubstring(Source, Substring: string): string;
var
  i: dword;
begin
  i := posi(Substring, source);
  if i <> 0 then
  begin
    delete(source, i, length(substring));
  end;
  result := source;
end;

function ReplaceChars(Source: string; PatternChar, ReplaceChar: char): string;
var
  i: integer;
  s: string;
begin
  s := source;
  while (true) do
  begin
    i := pos(patternchar, s);
    if i = 0 then
      break;
    S[i] := replacechar;
  end;
  result := s;

end;



function ReplaceString(aSourceString, aPattern, aReplaceString: string): string;
var
  i: integer;
begin
  //
  result := aSourceString;

  while (true) do
  begin
    i := posi(apattern, asourcestring);
    if i <> 0 then
    begin
      delete(asourcestring, i, length(apattern));
      insert(aReplaceString, aSourceString, i);
    end
    else
      break;
  end;
  result := aSourceString;
end;


function RandomN(aRange: integer): integer;
begin
  result := random(aRange + 1);
  if result = 0 then
    result := 1;
  if result > aRange then
    result := arange;

end;





function ApplicationPath: string;
begin
  result := extractfilepath(paramstr(0));
end;



function RemoveAllSubstrings(Source, Substring: string): string;
var
  s: string;
begin
  s := source;

  while (posi(substring, s) > 0) do
  begin
    s := removesubstring(s, substring);
  end;
  result := s;
end;



function ImageFormat(aFileName: string): TImageFormat;
var
  ext: string;
begin
  ext := extractfileext(afilename);
  result := ifunknown;
  if posi('.jpeg', ext) <> 0 then
    result := ifJpegFile;
  if posi('.jpg', ext) <> 0 then
    result := ifJpegFile;
  if posi('.jpe', ext) <> 0 then
    result := ifJpegFile;
  if posi('.bmp', ext) <> 0 then
    result := ifBitmapFile;

end;



function NormalizeRect(R: TRect): TRect;
begin
  // This routine normalizes a rectangle. It makes sure that the Left,Top
  // coords are always above and to the left of the Bottom,Right coords.
  with R do
    if Left > Right then
      if Top > Bottom then
        Result := Rect(Right, Bottom, Left, Top)
      else
        Result := Rect(Right, Top, Left, Bottom)
    else if Top > Bottom then
      Result := Rect(Left, Bottom, Right, Top)
    else
      Result := Rect(Left, Top, Right, Bottom);
end;



function pointInPolygon(const aPolygon: TPointArray; const aPoint: TPoint): Boolean;
var
  xi, yi, xj, yj, x, y, i, j: integer;
  arrayLength: integer;
  c: boolean;
begin
  i := 0;
  j := 0;
  c := false;
  arrayLength := length(aPolygon);
  j := arrayLength - 1;
  x := aPoint.x;
  y := aPoint.Y;
  for i := 0 to arrayLength - 1 do
  begin
    xi := aPolygon[i].X;
    yi := aPolygon[i].y;
    xj := aPolygon[j].x;
    yj := aPolygon[j].y;


    if ((((yi <= y) and (Y < yj)) or
      ((yj <= Y) and (Y < yi))) and
      (X < (xj - xi) *
      (Y - yi) / (yj - yi) + xi)) then
    begin
      c := not c;
    end;
    j := i;
  end;
  result := c;
end;
end.

