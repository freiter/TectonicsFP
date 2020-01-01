unit Inspect;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, StdCtrls, Numedit, ExtCtrls, LowHem, fileops, Menus, Results, Clipbrd;

type
  TInspectorForm = class(TRollup)
    PenGroupBox: TGroupBox;
    SymbolGroupBox: TGroupBox;
    Label1: TLabel;
    NumEdit1: TNumEdit;
    ApplyBtn: TBitBtn;
    PenWidthComboBox: TComboBox;
    PenStyleComboBox: TComboBox;
    PenStyleGroupBox: TGroupBox;
    PenWidthGroupBox: TGroupBox;
    GroupBox1: TGroupBox;
    Panel2: TPanel;
    GroupBox2: TGroupBox;
    Label2: TLabel;
    GroupBox3: TGroupBox;
    ComboBox1: TComboBox;
    Panel3: TPanel;
    PopupMenu1: TPopupMenu;
    Minimize1: TMenuItem;
    Arrange1: TMenuItem;
    ArrangeAll1: TMenuItem;
    CheckBox1: TCheckBox;
    GroupBox4: TGroupBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Panel4: TPanel;
    Panel1: TPanel;
    Label3: TLabel;
    Panel5: TPanel;
    CheckBox4: TCheckBox;
    Panel6: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Restore1: TMenuItem;
    Close1: TMenuItem;
    CloseAll1: TMenuItem;
    BitBtn1: TBitBtn;
    N1: TMenuItem;
    Help1: TMenuItem;
    CheckBox5: TCheckBox;
    Panel7: TPanel;
    procedure ApplyBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure PenWidthComboBoxDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure PenStyleComboBoxDrawItem(Control: TWinControl;
      Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure ComboBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure Panel3Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Arrange1Click(Sender: TObject); override;
    procedure PopupMenu1Popup(Sender: TObject);
    procedure ArrangeAll1Click(Sender: TObject); override;
    procedure SpeedButton1Click(Sender: TObject);
    procedure Panel6MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer); override;
    procedure SpeedButton2Click(Sender: TObject);
    procedure DisableAll(Sender: TObject);
    procedure Panel6MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
    procedure Minimize1Click(Sender: TObject); override;
    procedure Restore1Click(Sender: TObject); override;
    procedure CloseAll1Click(Sender: TObject);
    procedure Panel6MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BitBtn1Click(Sender: TObject);
    procedure Help2Click(Sender: TObject);
    procedure Panel2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel2DragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure Panel2DragDrop(Sender, Source: TObject; X, Y: Integer);
  protected
    procedure AppMessage(var Message: TMessage); message WM_MOVE;
  private
    procedure Initialize(AOwner: TComponent); override;
  published
    procedure Reset(Sender: TObject);
  end;


var
  InspectorForm: TInspectorForm;

implementation
uses Types, Tecmain, Settings, Rose, Fish, Contour;

{$R *.DFM}

procedure TInspectorForm.Initialize(AOwner: TComponent);
begin
  inherited;
  rollupx:= plotpropleft;
  rollupy:= plotproptop;
  if fowner=nil then DisableAll(Self)
  else
  begin
    Label2.caption:='Plot '+ IntToStr((FOwner as TLHWin).LHPlotNumber)+#13#10+
      ExtractFilename((FOwner as TLHWin).LHFilename);
    Label2.Hint:='Change appearance of '+ ExtractFilename((FOwner as TLHWin).LHFilename)+'| ';
    if ((FOwner as TLHWin).LHPastedFiles>0) or ((FOwner as TLHWin).LHPlotType=pt_SortMan) or
      ((FOwner as TLHWin).LHPlotType=pt_Rotate) then
    begin
      PenStyleComboBox.Enabled:=False;
      panel4.Enabled:=False;
      panel4.visible:=False;
      panel5.Enabled:=False;
      label3.enabled:=False;
      panel1.Enabled:=False;
      PenWidthComboBox.Enabled:=False;
      ComboBox1.Enabled:=False;
      NumEdit1.Enabled:=False;
      Label1.Enabled:=False;
      panel2.Enabled:=False;
      CheckBox1.Enabled:=False;
      CheckBox2.Enabled:=False;
      CheckBox3.Enabled:=False;
      CheckBox4.Enabled:=False;
      CheckBox5.Enabled:=False;
      panel7.enabled:=False;
      ApplyBtn.Enabled:=False;
      panel3.Enabled:=False;
      panel3.visible:=False;
      BitBtn1.Enabled:=False;
    end
    else
    begin
      panel7.enabled:=True;
      panel5.Enabled:=True;
      label3.enabled:=True;
      Panel5.color:=(FOwner as TLHWin).LHNetColor;
      Panel7.color:=(FOwner as TLHWin).LHBackgrBrush.Color;
      ApplyBtn.Enabled:=True;
      BitBtn1.Enabled:=True;
      CheckBox2.Enabled:=True;
      CheckBox3.Enabled:=True;
      CheckBox5.Enabled:=True;
      case (FOwner as TLHWin).LHPlotType of
        pt_Contour: begin
          CheckBox2.Caption:='Net';
          CheckBox2.checked:=(FOwner as TContDihFrm).blShowNet;
        end
        else
        begin
          CheckBox2.Caption:='Numbering';
          CheckBox2.checked:=(FOwner as TLHWin).Number1.Checked;
        end;
      end;

      case (FOwner as TLHWin).LHPlotType of
        pt_PiPlot, pt_Lineation, pt_DipLine:
        begin
          PenStyleComboBox.Enabled:=False;
          PenWidthComboBox.Enabled:=True;
          Panel4.Enabled:=False;
          Panel4.visible:=False;
          Panel1.Enabled:=True;
          ComboBox1.Enabled:=True;
          NumEdit1.Enabled:=True;
          Label1.Enabled:=True;
          CheckBox1.Enabled:=True;
          Panel2.Enabled:=True;
          Panel3.Enabled:=False;
          Panel3.visible:=False;
          case (FOwner as TLHWin).LHSymbType of
            syCross:        ComboBox1.ItemIndex:= 0;
            syCircle:       ComboBox1.ItemIndex:= 1;
            syStar:         ComboBox1.ItemIndex:= 2;
            syTriangle:     ComboBox1.ItemIndex:= 3;
            syRectangle:    ComboBox1.ItemIndex:= 4;
            syRhombohedron: ComboBox1.ItemIndex:= 5;
            syNumber:       ComboBox1.ItemIndex:= 6;
          end;
        end;
        pt_Bingham, pt_SmallCircle:
        begin
          PenStyleComboBox.Enabled:=True;
          PenWidthComboBox.Enabled:=True;
          panel4.Enabled:=False;
          panel4.visible:=False;
          Panel1.Enabled:=True;
          ComboBox1.Enabled:=True;
          NumEdit1.Enabled:=True;
          Label1.Enabled:=True;
          CheckBox1.Enabled:=True;
          CheckBox4.Enabled:=False;
          If (FOwner as TLHWin).LHPLotType=pt_SmallCircle then CheckBox2.enabled:=False;
          Panel2.Enabled:=True;
          panel3.Enabled:=False;
          panel3.visible:=False;
          case (FOwner as TLHWin).LHSymbType of
            syCross:        ComboBox1.ItemIndex:= 0;
            syCircle:       ComboBox1.ItemIndex:= 1;
            syStar:         ComboBox1.ItemIndex:= 2;
            syTriangle:     ComboBox1.ItemIndex:= 3;
            syRectangle:    ComboBox1.ItemIndex:= 4;
            syRhombohedron: ComboBox1.ItemIndex:= 5;
            syNumber:       ComboBox1.ItemIndex:= 6;
          end;
        end;
        pt_MeanVectFisher, pt_MeanVectRC:
        begin
          PenStyleComboBox.Enabled:=True;
          PenWidthComboBox.Enabled:=True;
          if ((fOwner as TFisherForm).lhPlotType=pt_MeanVectRC) and
            (fOwner as TFisherForm).ShowSpherDistr then
          begin
            Panel4.Visible:=True;
            Panel4.Enabled:=True;
            Panel4.Color:=(FOwner as TFisherForm).FishPen2.Color;
          end
          else
          begin
            Panel4.Visible:=False;
            Panel4.Enabled:=False;
          end;
          Panel1.Enabled:=True;
          ComboBox1.Enabled:=True;
          NumEdit1.Enabled:=True;
          Label1.Enabled:=True;
          CheckBox1.Enabled:=True;
          CheckBox4.Enabled:=False;
          CheckBox2.enabled:=False;
          Panel2.Enabled:=True;
          panel3.Enabled:=False;
          panel3.visible:=False;
          case (FOwner as TLHWin).LHSymbType of
            syCross:        ComboBox1.ItemIndex:= 0;
            syCircle:       ComboBox1.ItemIndex:= 1;
            syStar:         ComboBox1.ItemIndex:= 2;
            syTriangle:     ComboBox1.ItemIndex:= 3;
            syRectangle:    ComboBox1.ItemIndex:= 4;
            syRhombohedron: ComboBox1.ItemIndex:= 5;
            syNumber:       ComboBox1.ItemIndex:= 6;
          end;
        end;
        pt_GreatCircle:
        begin
          PenStyleComboBox.Enabled:=True;
          PenWidthComboBox.Enabled:=True;
          panel4.Enabled:=False;
          panel4.visible:=False;
          Panel1.Enabled:=True;
          NumEdit1.Text:='';
          NumEdit1.Enabled:=False;
          Label1.Enabled:=False;
          ComboBox1.Enabled:=False;
          CheckBox1.Enabled:=False;
          CheckBox4.Enabled:=False;
          Panel2.Enabled:=False;
          panel3.Enabled:=False;
          panel3.visible:=False;
        end;
        pt_Angelier:
        begin
          PenWidthComboBox.Enabled:=True;
          PenStyleComboBox.Enabled:=True;
          panel4.Enabled:=False;
          panel4.visible:=False;
          Panel1.Enabled:=True;
          ComboBox1.Enabled:=False;
          NumEdit1.Enabled:=True;
          Label1.Enabled:=True;
          CheckBox1.Enabled:=True;
          CheckBox4.Enabled:=False;
          panel2.Enabled:=True;
          panel3.Enabled:=False;
          panel3.visible:=False;
        end;
        pt_Hoeppener:
        begin
          PenStyleComboBox.Enabled:=False;
          PenWidthComboBox.Enabled:=True;
          panel4.Enabled:=False;
          panel4.visible:=False;
          Panel1.Enabled:=True;
          ComboBox1.Enabled:=False;
          NumEdit1.Enabled:=True;
          Label1.Enabled:=True;
          CheckBox1.Enabled:=True;
          CheckBox4.Enabled:=False;
          panel2.Enabled:=True;
          panel3.Enabled:=False;
          panel3.visible:=False;
        end;
        pt_ptPlot, pt_SigmaTensor, pt_LambdaTensor, pt_Dihedra:
        begin
          PenStyleComboBox.Enabled:=False;
          PenWidthComboBox.Enabled:=True;
          panel4.Enabled:=False;
          panel4.visible:=False;
          Panel1.Enabled:=True;
          ComboBox1.Enabled:=False;
          NumEdit1.Enabled:=True;
          Label1.Enabled:=True;
          CheckBox1.Enabled:=True;
          CheckBox4.Enabled:=True;
          Panel2.Enabled:=True;
          panel3.Enabled:=True;
          panel3.visible:=True;
          panel3.Color:=(FOwner as TLHWin).LHFillBrush2.Color;
          CheckBox4.Checked:=(FOwner as TLHWin).LHSymbFillFlag2;
        end;
        pt_SigmaDihedra, pt_LambdaDihedra:
        begin
          PenStyleComboBox.Enabled:=True;
          PenWidthComboBox.Enabled:=True;
          panel4.Enabled:=False;
          panel4.visible:=False;
          Panel1.Enabled:=True;
          ComboBox1.Enabled:=False;
          NumEdit1.Enabled:=False;
          Label1.Enabled:=False;
          CheckBox1.Enabled:=True;
          CheckBox2.Checked:=False;
          CheckBox2.Enabled:=False;
          CheckBox4.Enabled:=True;
          Panel2.Enabled:=True;
          panel3.Enabled:=True;
          panel3.visible:=True;
          panel3.Color:=(FOwner as TLHWin).LHFillBrush2.Color;
          CheckBox4.Checked:=(FOwner as TLHWin).LHSymbFillFlag2;
        end;
        pt_MohrSigma, pt_MohrLambda:
        begin
          PenStyleComboBox.Enabled:=True;
          PenWidthComboBox.Enabled:=True;
          panel4.Enabled:=False;
          panel4.visible:=False;
          Panel1.Enabled:=True;
          ComboBox1.Enabled:=False;
          NumEdit1.Enabled:=True;
          Label1.Enabled:=True;
          CheckBox1.Enabled:=True;
          panel2.Enabled:=True;
          panel3.Enabled:=False;
          panel3.visible:=False;
          CheckBox4.Enabled:=False;
        end;
        pt_FluHist, pt_RoseCenter, pt_RoseCorner:
        begin
          PenStyleComboBox.Enabled:=True;
          PenWidthComboBox.Enabled:=True;
          panel4.Enabled:=False;
          panel4.visible:=False;
          Panel1.Enabled:=True;
          ComboBox1.Enabled:=False;
          NumEdit1.Enabled:=False;
          Label1.Enabled:=False;
          CheckBox1.Enabled:=True;
          //if (FOwner as TLHWin).LHPlottype=pt_FluHist then
          CheckBox2.Enabled:=False;
          panel2.Enabled:=True;
          panel3.Enabled:=False;
          panel3.visible:=False;
          CheckBox4.Enabled:=False;
          CheckBox4.Visible:=False;
        end;
        pt_Contour:
        begin
          PenStyleComboBox.Enabled:=True;
          PenWidthComboBox.Enabled:=True;
          panel4.Enabled:=False;
          panel4.visible:=False;
          Panel1.Enabled:=True;
          ComboBox1.Enabled:=False;
          NumEdit1.Enabled:=True;
          Label1.Enabled:=True;
          CheckBox1.Enabled:=False;
          CheckBox2.Enabled:=True;
          panel2.Enabled:=False;
          panel3.Enabled:=False;
          panel3.visible:=False;
          CheckBox4.Enabled:=False;
        end;
        pt_BestTheta:
        begin
          PenStyleComboBox.Enabled:=False;
          PenWidthComboBox.Enabled:=True;
          panel4.Enabled:=True;
          panel4.visible:=True;
          Panel4.Color:=(FOwner as TFluMohrFm).FMPen2.Color;
          panel3.Color:=(FOwner as TLHWin).LHFillBrush2.Color;
          Panel1.Enabled:=True;
          ComboBox1.Enabled:=False;
          NumEdit1.Enabled:=True;
          Label1.Enabled:=True;
          CheckBox1.Enabled:=True;
          CheckBox4.Enabled:=True;
          panel2.Enabled:=True;
          panel3.Enabled:=True;
          panel3.visible:=True;
          panel3.Color:=(FOwner as TLHWin).LHFillBrush2.Color;
          CheckBox4.Checked:=(FOwner as TLHWin).LHSymbFillFlag2;
        end;
      end;
    end;
    Panel1.Color:=(FOwner as TLHWin).LHPen.Color;
    Panel2.Color:=(FOwner as TLHWin).LHFillBrush.Color;
    PenStyleComboBox.ItemIndex:= longint((FOwner as TLHWin).LHPen.Style);
    PenWidthComboBox.ItemIndex:= (FOwner as TLHWin).LHPen.Width-1;
    CheckBox1.checked:=(FOwner as TLHWin).LHSymbFillFlag;
    CheckBox3.checked:=(FOwner as TLHWin).Label1.Checked;
    CheckBox5.checked:=(FOwner as TLHWin).LHBackgrOn;
    Panel7.Color:=(FOwner as TLHWin).LHBackGrBrush.Color;
    Numedit1.Number:= Round(1000*(FOwner as TLHWin).LHSymbSize/Radius);
  end;
end;


procedure TInspectorForm.ApplyBtnClick(Sender: TObject);
begin
  if (FOwner as TLHWin).lhPlotType = pt_Contour then
  begin
    (FOwner as TContDihFrm).blShowNet:=CheckBox2.Checked;
    ContShowNet:=CheckBox2.Checked;
  end
  else globallhnumbering:=CheckBox2.Checked;
  globallhLabel:= CheckBox3.Checked;
  with FOwner as TLHWin do
  begin
    LHNetColor:=Panel5.color;
    GlobalNetColor:=LHNetColor;
    LHPen.Style:= TPenStyle(Self.PenStyleComboBox.ItemIndex);
    LHPen.Width:= Self.PenWidthComboBox.ItemIndex+1;
    LHLogPen.lopnStyle:=Self.PenStyleComboBox.ItemIndex;
    LHLogPen.lopnWidth.x:= Self.PenWidthComboBox.ItemIndex+1;
    case ComboBox1.ItemIndex of
      0: LHSymbType:= syCross;
      1: LHSymbType:= syCircle;
      2: LHSymbType:= syStar;
      3: LHSymbType:= syTriangle;
      4: LHSymbType:= syRectangle;
      5: LHSymbType:= syRhombohedron;
      6: LHSymbType:= syNumber;
    end;
    LHSymbFillFlag:= CheckBox1.Checked;
    LHSymbFillFlag2:= CheckBox4.Checked;
    Number1.Checked:=CheckBox2.Checked;
    Number1.Enabled:=CheckBox2.Enabled;
    Label1.Checked:=CheckBox3.checked;
    LHFillBrush.Color:= Panel2.Color;
    LHFillBrush2.Color:= Panel3.Color;
    LHBackgrBrush.Color:= Panel7.Color;
    GlobalBackColor:=Panel7.Color;
    LHBackgrOn:=CheckBox5.checked;
    GlobalLHBackOn:=CheckBox5.Checked;
    LHPen.Color:=Panel1.Color;
    LHPenBrush.Color:=Panel1.Color;
    LHSymbSize:=Radius*Self.Numedit1.Number/1000;
    //TecMainWin.FontDialog1.font.Color:=Panel5.Color; bugfix 981023
    case LHPlotType of
      pt_PiPlot:
      begin
        PiPenWidth:=LHPen.Width;
        PiPenColor:= LHPen.Color;
        PiSymbType:= LHSymbType;
        Pisymbfillflag:= CheckBox1.checked;
        PiSymbFillColor:= LHFillBrush.Color;
        PiSymbolSize:= LHSymbSize;
      end;
      pt_DipLine:
      begin
        DipPenWidth:=LHPen.Width;
        DipPenColor:= LHPen.Color;
        DipSymbType:= LHSymbType;
        DipSymbfillflag:= CheckBox1.checked;
        DipSymbFillColor:= LHFillBrush.Color;
        DipSymbolSize:= LHSymbSize;
      end;
      pt_GreatCircle:
      begin
        GreatPenStyle:= LHPen.Style;
        GreatPenWidth:= LHPen.Width;
        GreatPenColor:= LHPen.Color;
      end;
      pt_SmallCircle:
      begin
        SmallPenStyle:= LHPen.Style;
        SmallPenWidth:= LHPen.Width;
        SmallPenColor:= LHPen.Color;
        SmallSymbType:= LHSymbType;
        SmallSymbFillFlag:= CheckBox1.checked;
        SmallSymbfillColor:= LHFillBrush.Color;
        SmallSymbolSize:= LHSymbSize;
      end;
      pt_Lineation:
      begin
        LinPenWidth:= LHPen.Width;
        LinPenColor:= LHPen.Color;
        LinSymbType:= LHSymbType;
        LinSymbfillFlag:= CheckBox1.Checked;
        LinSymbfillColor:= LHFillBrush.Color;
        LinSymbolSize:= LHSymbSize;
      end;
      pt_Angelier:
      begin
        AngPenStyle:= LHPen.Style;
        AngPenWidth:= LHPen.Width;
        AngPenColor:= LHPen.Color;
        Angsymbfillflag:= CheckBox1.checked;
        AngSymbfillcolor:= LHFillBrush.Color;
        AngSymbolSize:= LHSymbSize;
      end;
      pt_Hoeppener:
      begin
        HoepPenWidth:= LHPen.Width;
        HoepPenColor:= LHPen.Color;
        HoepSymbfillFlag:= CheckBox1.checked;
        HoepSymbfillcolor:= LHFillBrush.Color;
        Hoepsymbradius:= LHSymbSize;
      end;
      pt_SigmaTensor,pt_LambdaTensor:
      begin
        SigTenSymbFillColorP:=LHFillBrush.Color;
        SigTenSymbFillColorT:=LHFillBrush2.Color;
        SigTenPenWidth:=LHPen.Width;
        SigTenSymbFillFlag:= CheckBox1.checked;
        SigTenSymbFillFlag2:= CheckBox4.checked;
        SigTenPenColor:= LHPen.Color;
        SigTenSymbolSize:= LHSymbSize;
      end;
      pt_SigmaDihedra, pt_LambdaDihedra:
      begin
        SigDihSymbFillColorP:=LHFillBrush.Color;
        SigDihSymbFillColorT:=LHFillBrush2.Color;
        SigDihPenWidth:=LHPen.Width;
        SigDihSymbFillFlag:= CheckBox1.checked;
        SigDihSymbFillFlag2:= CheckBox4.checked;
        SigDihPenColor:= LHPen.Color;
      end;
      pt_Bingham:
      begin
        BingPenStyle:= LHPen.Style;
        BingPenWidth:= LHPen.Width;
        BingPenColor:= LHPen.Color;
        BingSymbType:= LHSymbType;
        BingSymbFillFlag:= CheckBox1.checked;
        BingSymbFillColor:= LHFillBrush.Color;
        BingSymbolSize:= LHSymbSize;
      end;
      pt_MeanVectFisher, pt_MeanVectRC:
      begin
        FishPenStyle:= LHPen.Style;
        FishPenWidth:= LHPen.Width;
        FishPenColor:= LHPen.Color;
        FishSymbType:= LHSymbType;
        with FOwner as TFisherForm do
        begin
          FishPen2.Color:=Panel4.Color;
          FishPen2.Width:=LHPen.Width;
        end;
        FishPen2Color:=Panel4.Color;
        FishSymbFillFlag:= CheckBox1.checked;
        FishSymbfillColor:= LHFillBrush.Color;
        FishSymbolSize:= LHSymbSize;
      end;
      pt_ptPlot:
      begin
        PTSymbFillColorP:=LHFillBrush.Color;
        PTSymbFillColorT:=LHFillBrush2.Color;
        ptPenWidth:=LHPen.Width;
        ptSymbFillFlag:= CheckBox1.checked;
        ptSymbFillFlag2:= CheckBox4.checked;
        ptPenColor:= LHPen.Color;
        ptSymbolSize:= LHSymbSize;
      end;
      pt_MohrSigma, pt_MohrLambda:
      begin
        MohrPenStyle:= LHPen.Style;
        MohrPenWidth:= LHPen.Width;
        MohrPenColor:= LHPen.Color;
        MohrSymbFillFlag:= CheckBox1.checked;
        MohrSymbFillColor:= LHFillBrush.Color;
        MohrSymbolSize:= LHSymbSize;
      end;
      pt_FluHist:
      begin
        FluHPenStyle:= LHPen.Style;
        FluHPenWidth:= LHPen.Width;
        FluHPenColor:= LHPen.Color;
        FluHSymbFillFlag:= CheckBox1.checked;
        FluHSymbFillColor:= LHFillBrush.Color;
      end;
      pt_RoseCenter, pt_RoseCorner:
      begin
        RosePenStyle:= LHPen.Style;
        RosePenWidth:= LHPen.Width;
        RosePenColor:= LHPen.Color;
        RoseSymbFillFlag:= CheckBox1.checked;
        RoseSymbFillColor:= LHFillBrush.Color;
      end;
      pt_Contour:
      begin
        ContPenStyle:= LHPen.Style;
        ContPenWidth:= LHPen.Width;
        ContPenColor:= LHPen.Color;
        ContSymbolSize:= Round(LHSymbSize/Radius*1000);
      end;
      pt_BestTheta:
      begin
        BtPenWidth:= LHPen.Width;
        BtPenColorP:= LHPen.Color;
        (FOwner as TFluMohrFm).FMPen2.color:=Panel4.Color;
        (FOwner as TFluMohrFm).FMPen2.width:=LHPen.Width;;
        BtPenColorT:=(FOwner as TFluMohrFm).FMPen2.color;
        BtSymbFillFlag:= CheckBox1.checked;
        BtSymbFillFlag2:= CheckBox4.checked;
        BtSymbFillColorP:= LHFillBrush.Color;
        BtSymbFillColorT:= LHFillBrush2.Color;
        BtSymbolSize:= LHSymbSize;
      end;
      pt_Dihedra:
      begin
        DihSymbolsize:=LHSymbSize;
        DihSymbFillFlag:=LHSymbFillFlag;
        DihSymbFillFlag2:=LHSymbFillFlag2;
        DihSymbFillColorP:=LHFillBrush.Color;
        DihSymbFillColorT:=LHFillBrush2.Color;
        DihPenColor:=LHPen.Color;
        DihPenWidth:=LHPen.Width;
        //DihSymbType:=LHSymbType;
      end;
    end;
    Compute(Sender);
    If not LHfailed then Paintbox1.Refresh;
    TecmainWin.SetFocus;
  end;
end;

procedure TInspectorForm.Panel3Click(Sender: TObject);
begin
  TecMainWin.ColorDialog1.Color:= (Sender as TPanel).Color;
  If TecMainWin.ColorDialog1.Execute then
  begin
    (Sender as TPanel).Color:=TecMainWin.ColorDialog1.Color;
    If Sender=Panel2 then CheckBox1.checked:=True;
    If Sender=Panel3 then CheckBox4.checked:=True;
    If Sender=Panel7 then CheckBox5.checked:=True;
  end;
end;

procedure TInspectorForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  PlotPropLeft:=Left;
  PlotPropTop:=Top;
  PlotPropWidth:=Width;
  InspectorForm:=nil;
  inherited;
end;

procedure TInspectorForm.reset(Sender: TObject);
begin
  Label2.Caption:='';
  PenStyleComboBox.Enabled:=False;
  PenWidthComboBox.Enabled:=False;
  Panel1.Enabled:=False;
  panel4.Enabled:=False;
  panel4.visible:=False;
  ComboBox1.Enabled:=False;
  NumEdit1.Enabled:=False;
  Label1.Enabled:=False;
  CheckBox1.Enabled:=False;
  CheckBox2.Enabled:=False;
  CheckBox3.Enabled:=False;
  CheckBox4.Enabled:=False;
  CheckBox5.Enabled:=False;
  Panel2.Enabled:=False;
  panel3.Enabled:=False;
  panel3.visible:=False;
  panel5.Enabled:=False;
  panel7.Enabled:=False;
  label3.Enabled:=False;
  ApplyBtn.Enabled:=False;
  BitBtn1.Enabled:=False;
  FOwner:=nil;
end;

procedure TInspectorForm.PenWidthComboBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
   xofs, yofs, breite: Integer;

begin
  breite:= Rect.right - Rect.left - 50;
  xofs:= Rect.left + 10;
  yofs:= Rect.top;
  with PenWidthComboBox.Canvas do begin
   fillrect(rect);
   pen.width := index + 1;
   moveto(xofs,yofs+8);
   lineto(xofs+breite,yofs+8);
   if index=0 then textout(xofs+breite+10,yofs+2, InttoStr(index+1)+' pt')
     else textout(xofs+breite+10,yofs+2, InttoStr(index+1)+' pts');
  end;
end;

procedure TInspectorForm.PenStyleComboBoxDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var xofs,yofs,breite:integer;
begin
  breite := Rect.right-Rect.left-20;
  xofs   := Rect.left+10;
  yofs   := Rect.top;
  with PenStyleComboBox.Canvas do begin
    fillrect(rect);
    pen.style:=TPenStyle(index);
    moveto(xofs,yofs+8);
    lineto(xofs+breite,yofs+8);
  end;
end;


procedure TInspectorForm.ComboBox1DrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
   xofs, yofs{, breite}: Integer;
begin
  //breite:= Rect.right - Rect.left - 50;
  xofs:= Rect.left + 10;
  yofs:= Rect.top-1;
  with ComboBox1.Canvas do begin
   FillRect(Rect);
   case Index of
     0: //Cross
     begin
       MoveTo(xofs+4, yofs+4);
       LineTo(xofs+4, yofs+12);
       MoveTo(xofs, yofs+8);
       LineTo(xofs+8, yofs+8);
     end;
     1: //Circle
     ellipse(xofs, yofs+4,xofs+8,yofs+12);
     2: //Star
     begin
       MoveTo(xofs+4, yofs+4);
       LineTo(xofs+4, yofs+12);
       MoveTo(xofs, yofs+8);
       LineTo(xofs+8, yofs+8);
       MoveTo(xofs, yofs+4);
       LineTo(xofs+8, yofs+12);
       MoveTo(xofs+8, yofs+4);
       LineTo(xofs, yofs+12);
     end;
     3: //Triangle
     begin
       MoveTo(xofs+4, yofs+4);
       LineTo(xofs+8, yofs+12);
       LineTo(xofs, yofs+12);
       LineTo(xofs+4, yofs+4);
     end;
     4: //Rectangle
     Rectangle(xofs, yofs+4,xofs+8,yofs+12);
     5: //Rhomboedron
     begin
       MoveTo(xofs+4, yofs+4);
       LineTo(xofs+8, yofs+8);
       LineTo(xofs+4, yofs+12);
       LineTo(xofs, yofs+8);
       LineTo(xofs+4, yofs+4);
     end;
     6: //Text
     begin
       TextOut(xofs,yofs, 'Numbers');
     end;
   end;
  end;
end;



procedure TInspectorForm.FormCreate(Sender: TObject);
begin
  Rollupname:=rt_properties;
  Left:=PlotPropLeft;
  Top:=PlotPropTop;
  //Width:=PlotPropWidth;
  RollupX:=left;
  RollupY:=top;
  MyClientHeight:=ClientHeight;
  //Parent:=TecMainWin;
  //TFPRollups[0]:=Self;
end;

procedure TInspectorForm.Arrange1Click(Sender: TObject);
begin
  inherited Arrange1Click(Sender);
end;

procedure TInspectorForm.PopupMenu1Popup(Sender: TObject);
begin
  inherited Popupmenu1Popup(Sender);
end;

procedure TInspectorForm.ArrangeAll1Click(Sender: TObject);
begin
  inherited ArrangeAll1Click(Sender);
end;

procedure TInspectorform.AppMessage(var Message: TMessage);
begin
  with message do
  begin
    tecmainwin.Inspectleft:=lparamlo;
    tecmainwin.Inspecttop:=lparamhi;
  end;
  inherited;
end;

procedure TInspectorForm.SpeedButton1Click(Sender: TObject);
begin
  if not minimized then Minimize1Click(Sender)
  else Restore1Click(Sender);
  If aligned then TecMainWin.SwapRollups2(Self);
end;

procedure TInspectorForm.Panel6MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited Panel6MouseMove(Sender,Shift,X, Y);
  plotpropleft:=rollupx;
  plotproptop:=rollupy;
end;

procedure TInspectorForm.SpeedButton2Click(Sender: TObject);
begin
  Close;
end;

procedure TInspectorForm.DisableAll(Sender: TObject);
begin
  PenStyleComboBox.Enabled:=False;
  panel4.Enabled:=False;
  panel4.visible:=False;
  panel5.Enabled:=False;
  label3.enabled:=False;
  panel1.Enabled:=False;
  panel7.enabled:=False;
  PenWidthComboBox.Enabled:=False;
  ComboBox1.Enabled:=False;
  NumEdit1.Enabled:=False;
  label1.enabled:=False;
  panel2.Enabled:=False;
  CheckBox1.Enabled:=False;
  CheckBox2.Enabled:=False;
  CheckBox3.Enabled:=False;
  CheckBox4.Enabled:=False;
  CheckBox5.Enabled:=False;
  ApplyBtn.Enabled:=False;
  panel3.Enabled:=False;
  panel3.visible:=False;
  BitBtn1.Enabled:=False;
end;

procedure TInspectorForm.Restore1Click(Sender: TObject);
begin
  inherited Restore1Click(Sender);
end;

procedure TInspectorForm.Panel6MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited Panel6MouseDown(Sender, Button, Shift, X, Y);
end;

procedure TInspectorForm.Minimize1Click(Sender: TObject);
begin
  inherited Minimize1Click(Sender);
end;

procedure TInspectorForm.CloseAll1Click(Sender: TObject);
begin
  TecMainWin.CloseAllRollups(Sender);
end;

procedure TInspectorForm.Panel6MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited Panel6MouseUp(Sender, Button, Shift, X, Y);
end;

procedure TInspectorForm.BitBtn1Click(Sender: TObject);
begin
  (FOwner as TLHWin).Fonts1Click(Sender);
end;

procedure TInspectorForm.Help2Click(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;


procedure TInspectorForm.Panel2MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button= mbLeft) and not (ssdouble in Shift) then
  begin
    RollupStartDr:=True;
    (Sender as TControl).BeginDrag(False);
  end;
end;

procedure TInspectorForm.Panel2DragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
begin
  If Source=Sender then
    If RollupStartDr then
    begin
      DragGraphicsStyle.IsValid:=True;
      DragGraphicsStyle.DColor:=(Sender as TPanel).Color;
      RollupStartDr:=False;
    end
  else Accept:=DragGraphicsStyle.IsValid;
end;

procedure TInspectorForm.Panel2DragDrop(Sender, Source: TObject; X,
  Y: Integer);
begin
  (Sender as TPanel).Color:=DragGraphicsStyle.DColor;
end;

end.
