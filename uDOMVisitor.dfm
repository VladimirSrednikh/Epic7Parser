object DOMVisitorFrm: TDOMVisitorFrm
  Left = 0
  Top = 0
  Caption = 'DOMVisitor'
  ClientHeight = 579
  ClientWidth = 878
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object CEFWindowParent1: TCEFWindowParent
    Left = 0
    Top = 30
    Width = 878
    Height = 530
    Align = alClient
    TabOrder = 0
  end
  object AddressBarPnl: TPanel
    Left = 0
    Top = 0
    Width = 878
    Height = 30
    Align = alTop
    BevelOuter = bvNone
    DoubleBuffered = True
    Enabled = False
    Padding.Left = 5
    Padding.Top = 5
    Padding.Right = 5
    Padding.Bottom = 5
    ParentDoubleBuffered = False
    TabOrder = 1
    object AddressEdt: TEdit
      Left = 5
      Top = 5
      Width = 667
      Height = 20
      Align = alClient
      TabOrder = 0
      Text = 'https://epic7x.com/tier-list/'
      ExplicitWidth = 628
    end
    object Panel1: TPanel
      Left = 672
      Top = 5
      Width = 201
      Height = 20
      Align = alRight
      BevelOuter = bvNone
      Padding.Left = 5
      TabOrder = 1
      object GoBtn: TButton
        Left = 5
        Top = 0
        Width = 31
        Height = 20
        Margins.Left = 5
        Align = alLeft
        Caption = 'Go'
        TabOrder = 0
        OnClick = GoBtnClick
      end
      object VisitDOMBtn: TButton
        Left = 126
        Top = 0
        Width = 75
        Height = 20
        Align = alRight
        Caption = 'Visit DOM'
        TabOrder = 1
        OnClick = VisitDOMBtnClick
        ExplicitLeft = 39
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 560
    Width = 878
    Height = 19
    Panels = <
      item
        Width = 50
      end>
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
