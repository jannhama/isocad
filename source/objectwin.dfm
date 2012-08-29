object ObjectPalette: TObjectPalette
  Left = 986
  Top = 469
  Width = 392
  Height = 336
  Caption = 'Object palette'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Components: TListBox
    Left = 0
    Top = 0
    Width = 376
    Height = 300
    Align = alClient
    ItemHeight = 13
    Items.Strings = (
      'H-STICK'
      'V-STICK'
      'H-PLATE'
      'V-PLATE')
    TabOrder = 0
    OnMouseDown = ComponentsMouseDown
  end
end
