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

program isocad;

uses
  Forms,
  mainform in 'mainform.pas' {MainWindow},
  newbrick in 'newbrick.pas' {NewBrickDlg},
  objectwin in 'objectwin.pas' {ObjectPalette},
  zoomwin in 'zoomwin.pas' {ZoomWindow};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TMainWindow, MainWindow);
  Application.CreateForm(TNewBrickDlg, NewBrickDlg);
  Application.CreateForm(TObjectPalette, ObjectPalette);
  Application.CreateForm(TZoomWindow, ZoomWindow);
  Application.Run;
end.
