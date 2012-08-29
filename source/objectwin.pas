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
unit objectwin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TObjectPalette = class(TForm)
    Components: TListBox;
    procedure ComponentsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ObjectPalette: TObjectPalette;

implementation

{$R *.dfm}

procedure TObjectPalette.ComponentsMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
    if Button = mbLeft then { drag only if left button pressed }
    with Sender as TListBox do { treat Sender as TFileListBox }
    begin
      if ItemAtPos(Point(X, Y), True) >= 0 then { is there an item here? }
        BeginDrag(False); { if so, drag it }
    end;

end;

end.
