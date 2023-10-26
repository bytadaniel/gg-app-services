object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'CashboxService'
  ClientHeight = 276
  ClientWidth = 625
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object Button1: TButton
    Left = 32
    Top = 48
    Width = 75
    Height = 25
    Caption = 'Ping'
    TabOrder = 0
    Visible = False
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 32
    Top = 88
    Width = 75
    Height = 25
    Caption = 'PowerOn'
    TabOrder = 1
    Visible = False
    OnClick = Button2Click
  end
  object Memo1: TMemo
    Left = 145
    Top = 0
    Width = 480
    Height = 276
    Align = alRight
    TabOrder = 2
    ExplicitLeft = 141
    ExplicitHeight = 275
  end
  object Button3: TButton
    Left = 32
    Top = 128
    Width = 75
    Height = 25
    Caption = 'Button3'
    TabOrder = 3
    Visible = False
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 32
    Top = 176
    Width = 75
    Height = 25
    Caption = 'hide'
    TabOrder = 4
    Visible = False
    OnClick = Button4Click
  end
  object Timer1: TTimer
    Interval = 2000
    OnTimer = Timer1Timer
    Left = 152
    Top = 248
  end
  object IdTCPClient1: TIdTCPClient
    ConnectTimeout = 0
    Host = '0'
    Port = 9901
    ReadTimeout = -1
    Left = 152
    Top = 176
  end
  object IdHTTPServer1: TIdHTTPServer
    Active = True
    Bindings = <>
    DefaultPort = 8082
    AutoStartSession = True
    KeepAlive = True
    ServerSoftware = 'commandserver'
    SessionState = True
    OnCreatePostStream = IdHTTPServer1CreatePostStream
    OnDoneWithPostStream = IdHTTPServer1DoneWithPostStream
    OnCommandGet = IdHTTPServer1CommandGet
    Left = 148
    Top = 104
  end
end
