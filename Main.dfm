object TMainForm: TTMainForm
  Left = 0
  Top = 0
  Caption = 'TMainForm'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object Label1: TLabel
    Left = 104
    Top = 40
    Width = 34
    Height = 15
    Caption = 'Label1'
  end
  object Label2: TLabel
    Left = 104
    Top = 90
    Width = 34
    Height = 15
    Caption = 'Label2'
  end
  object Button1: TButton
    Left = 312
    Top = 168
    Width = 75
    Height = 25
    Caption = 'Button1'
    TabOrder = 0
    OnClick = Button1Click
  end
  object ComboBox1: TComboBox
    Left = 104
    Top = 61
    Width = 145
    Height = 23
    TabOrder = 1
    Text = 'ComboBox1'
  end
  object ComboBox2: TComboBox
    Left = 104
    Top = 112
    Width = 145
    Height = 23
    TabOrder = 2
    Text = 'ComboBox2'
  end
end
