object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Aplica'#231#227'o Teste de Integra'#231#227'o com  POS Paygo'
  ClientHeight = 325
  ClientWidth = 521
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button2: TButton
    Left = 200
    Top = 141
    Width = 113
    Height = 65
    Caption = 'Parar'
    TabOrder = 0
    OnClick = Button2Click
  end
  object Button1: TButton
    Left = 200
    Top = 40
    Width = 113
    Height = 73
    Caption = 'Iniciar'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Panel1: TPanel
    Left = 0
    Top = 264
    Width = 521
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
  object MainMenu1: TMainMenu
    Left = 448
    Top = 16
    object Venda1: TMenuItem
      Caption = 'Opera'#231#245'es'
      object ConectarAutomao1: TMenuItem
        Caption = 'Conectar Automa'#231#227'o'
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object Menu1: TMenuItem
        Caption = 'Menu'
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object Venda2: TMenuItem
        Caption = 'Venda'
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Cancelamento1: TMenuItem
        Caption = 'Cancelamento'
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object DesconectarPOS1: TMenuItem
        Caption = 'Desconectar POS'
      end
      object N4: TMenuItem
        Caption = '-'
      end
    end
  end
end
