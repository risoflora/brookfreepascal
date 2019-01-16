object frBrookActEdit: TfrBrookActEdit
  Left = 261
  Height = 270
  Top = 172
  Width = 340
  BorderStyle = bsDialog
  Caption = 'Brook - %s action'
  ClientHeight = 270
  ClientWidth = 340
  OnCloseQuery = FormCloseQuery
  Position = poDesktopCenter
  LCLVersion = '1.2.4.0'
  object pnClient: TPanel
    Left = 0
    Height = 230
    Top = 0
    Width = 340
    Align = alClient
    Anchors = [akTop, akLeft, akBottom]
    ClientHeight = 230
    ClientWidth = 340
    TabOrder = 0
    object lbInfo: TLabel
      Left = 1
      Height = 15
      Top = 214
      Width = 338
      Align = alBottom
      Alignment = taCenter
      Caption = '(*) Required'
      Font.Color = clMaroon
      ParentColor = False
      ParentFont = False
    end
    object sbClient: TScrollBox
      Left = 1
      Height = 213
      Top = 1
      Width = 338
      HorzScrollBar.Page = 230
      VertScrollBar.Page = 137
      Align = alClient
      ClientHeight = 209
      ClientWidth = 334
      TabOrder = 0
      object lbName: TLabel
        AnchorSideLeft.Control = sbClient
        AnchorSideTop.Control = sbClient
        Left = 30
        Height = 15
        Top = 30
        Width = 40
        BorderSpacing.Left = 30
        BorderSpacing.Top = 30
        Caption = '&Name *'
        FocusControl = edName
        ParentColor = False
      end
      object edName: TEdit
        AnchorSideLeft.Control = lbName
        AnchorSideTop.Control = lbName
        AnchorSideTop.Side = asrBottom
        Left = 30
        Height = 23
        Top = 45
        Width = 200
        OnExit = edNameExit
        OnKeyPress = edNameKeyPress
        TabOrder = 0
      end
      object lbPattern: TLabel
        AnchorSideLeft.Control = edName
        AnchorSideTop.Control = edName
        AnchorSideTop.Side = asrBottom
        Left = 30
        Height = 15
        Top = 70
        Width = 38
        BorderSpacing.Top = 2
        Caption = '&Pattern'
        FocusControl = edPattern
        ParentColor = False
      end
      object edPattern: TEdit
        AnchorSideLeft.Control = lbPattern
        AnchorSideTop.Control = lbPattern
        AnchorSideTop.Side = asrBottom
        Left = 30
        Height = 23
        Top = 87
        Width = 200
        BorderSpacing.Top = 2
        CharCase = ecLowerCase
        OnKeyPress = edPatternKeyPress
        TabOrder = 1
      end
      object cbDefault: TCheckBox
        AnchorSideLeft.Control = edPattern
        AnchorSideTop.Control = edPattern
        AnchorSideTop.Side = asrBottom
        Left = 30
        Height = 19
        Top = 118
        Width = 58
        BorderSpacing.Top = 8
        Caption = '&Default'
        TabOrder = 2
      end
    end
  end
  object pnBottom: TPanel
    Left = 0
    Height = 40
    Top = 230
    Width = 340
    Align = alBottom
    AutoSize = True
    ClientHeight = 40
    ClientWidth = 340
    TabOrder = 1
    object btOK: TBitBtn
      Left = 177
      Height = 26
      Top = 7
      Width = 75
      Align = alRight
      BorderSpacing.Around = 6
      Default = True
      DefaultCaption = True
      Kind = bkOK
      ModalResult = 1
      TabOrder = 0
    end
    object btCancel: TBitBtn
      Left = 258
      Height = 26
      Top = 7
      Width = 75
      Align = alRight
      BorderSpacing.Around = 6
      Cancel = True
      Caption = '&Cancel'
      Kind = bkCancel
      ModalResult = 2
      TabOrder = 1
    end
  end
end
