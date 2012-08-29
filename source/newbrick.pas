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
unit newbrick;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Spin, TB97Ctls, ExtCtrls;

type
  TNewBrickDlg = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    width: TSpinEdit;
    Label2: TLabel;
    Height: TSpinEdit;
    Label3: TLabel;
    Depth: TSpinEdit;
    cd: TColorDialog;
    Image1: TImage;
      Name: TEdit;
    UseWhiteFill: TCheckBox;
    DrawOutLine: TCheckBox;
    Label4: TLabel;
    Color: TToolbarButton97;
    procedure ColorClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  NewBrickDlg: TNewBrickDlg;

implementation

{$R *.DFM}

procedure TNewBrickDlg.ColorClick(Sender: TObject);
begin
  if cd.execute then
    Color.color := cd.Color;
end;

end.

