object ZoomWindow: TZoomWindow
  Left = 1053
  Top = 670
  BorderStyle = bsToolWindow
  Caption = 'ZoomWindow'
  ClientHeight = 128
  ClientWidth = 128
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object ZoomPB: TPaintBox
    Left = 0
    Top = 0
    Width = 128
    Height = 128
    Align = alClient
    OnPaint = ZoomPBPaint
  end
end
