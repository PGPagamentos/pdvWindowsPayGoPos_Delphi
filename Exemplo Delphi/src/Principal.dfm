object FPrincipal: TFPrincipal
  Left = 0
  Top = 0
  Caption = 'Aplica'#231#227'o Teste de Integra'#231#227'o com  POS Paygo'
  ClientHeight = 505
  ClientWidth = 563
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button2: TButton
    Left = 280
    Top = 8
    Width = 113
    Height = 73
    Caption = 'Parar'
    TabOrder = 0
    OnClick = Button2Click
  end
  object Button1: TButton
    Left = 112
    Top = 8
    Width = 113
    Height = 73
    Caption = 'Iniciar'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Panel1: TPanel
    Left = -1
    Top = 427
    Width = 563
    Height = 60
    TabOrder = 2
    object Label1: TLabel
      Left = 16
      Top = 9
      Width = 31
      Height = 13
      Caption = 'Label1'
    end
    object Label3: TLabel
      Left = 16
      Top = 42
      Width = 31
      Height = 13
      Caption = 'Label3'
    end
  end
  object Memo1: TMemo
    Left = 8
    Top = 101
    Width = 547
    Height = 246
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object Button3: TButton
    Left = 195
    Top = 368
    Width = 142
    Height = 42
    Caption = 'Limpar Log'
    TabOrder = 4
    OnClick = Button3Click
  end
end
