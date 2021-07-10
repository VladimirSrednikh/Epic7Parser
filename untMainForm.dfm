object frmEpic7xParser: TfrmEpic7xParser
  Left = 0
  Top = 0
  Caption = 'DOMVisitor'
  ClientHeight = 912
  ClientWidth = 977
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object CEFWindowParent1: TCEFWindowParent
    Left = 0
    Top = 39
    Width = 977
    Height = 854
    Align = alClient
    TabOrder = 1
  end
  object AddressBarPnl: TPanel
    Left = 0
    Top = 0
    Width = 977
    Height = 39
    Align = alTop
    BevelOuter = bvNone
    DoubleBuffered = True
    Enabled = False
    Padding.Left = 5
    Padding.Top = 5
    Padding.Right = 5
    Padding.Bottom = 5
    ParentDoubleBuffered = False
    TabOrder = 0
    object AddressEdt: TEdit
      Left = 5
      Top = 5
      Width = 677
      Height = 29
      Align = alClient
      TabOrder = 0
      Text = 'https://epic7x.com/tier-list/'
      ExplicitHeight = 21
    end
    object Panel1: TPanel
      AlignWithMargins = True
      Left = 685
      Top = 8
      Width = 284
      Height = 23
      Align = alRight
      BevelOuter = bvNone
      Padding.Left = 5
      TabOrder = 1
      object Splitter1: TSplitter
        Left = 5
        Top = 0
        Height = 23
        ExplicitLeft = 1
        ExplicitTop = 6
        ExplicitHeight = 100
      end
      object GoBtn: TButton
        Left = 8
        Top = 0
        Width = 31
        Height = 23
        Margins.Left = 5
        Align = alLeft
        Caption = 'Go'
        TabOrder = 0
        OnClick = GoBtnClick
      end
      object btnParseHeroInfo: TButton
        Left = 119
        Top = 0
        Width = 90
        Height = 23
        Align = alLeft
        Caption = 'Parse HeroStats'
        TabOrder = 2
        OnClick = btnParseHeroInfoClick
      end
      object btnParseHeroList: TButton
        Left = 39
        Top = 0
        Width = 80
        Height = 23
        Align = alLeft
        Caption = 'Parse HeroList'
        TabOrder = 1
        OnClick = btnParseHeroListClick
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 893
    Width = 977
    Height = 19
    Panels = <
      item
        Width = 300
      end
      item
        Width = 50
      end>
  end
  object ProgressBar1: TProgressBar
    Left = 456
    Top = 561
    Width = 150
    Height = 17
    TabOrder = 2
  end
  object Chromium1: TChromium
    OnProcessMessageReceived = Chromium1ProcessMessageReceived
    OnBeforeContextMenu = Chromium1BeforeContextMenu
    OnContextMenuCommand = Chromium1ContextMenuCommand
    OnConsoleMessage = Chromium1ConsoleMessage
    OnBeforePopup = Chromium1BeforePopup
    OnAfterCreated = Chromium1AfterCreated
    OnBeforeClose = Chromium1BeforeClose
    OnClose = Chromium1Close
    OnDocumentAvailableInMainFrame = Chromium1DocumentAvailableInMainFrame
    OnBeforeResourceLoad = Chromium1BeforeResourceLoad
    Left = 16
    Top = 40
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 300
    OnTimer = Timer1Timer
    Left = 16
    Top = 96
  end
end
