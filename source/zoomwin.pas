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
unit zoomwin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls;

type
  TZoomWindow = class(TForm)
    ZoomPB: TPaintBox;
    procedure ZoomPBPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ZoomWindow: TZoomWindow;

implementation

uses mainForm;

{$R *.dfm}

procedure TZoomWindow.ZoomPBPaint(Sender: TObject);
begin
  if (MainWindow.Zoomer1.checked) and (MainWindow.iDrawingCubes = false) then
  begin
    {
        buffer.StretchBlt(zoompb.canvas.handle, zoommx, zoommy, 64, 64, 0, 0,
          zoompb.width,
          zoompb.height);
    }

    //    StretchBlt(zoompb.canvas.handle,0,0,128,128,form1.canvas.handle,zoommx,zoommy,64,64,SRCCOPY);



    StretchBlt(zoompb.canvas.handle, 0, 0, MainWindow.getzoomfactor * MainWindow.getZoomRegion, MainWindow.getZoomFactor *
      MainWindow.getZoomRegion, MainWindow.getBuffer.fhdc, MainWindow.zoommx,
      MainWindow.zoommy, MainWindow.getZoomRegion, MainWindow.getZoomRegion, SRCCOPY);



    {
        buffer.StretchBlt(zoompb.canvas.handle, zoommx, zoommy, 64, 64, 0, 0,
          zoompb.width,
          zoompb.height);

        zoombuffer.Draw(zoompb.canvas.handle, 0, 0);
    }
  end;

end;

procedure TZoomWindow.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  MainWindow.zoomer1.Click;
end;

end.
