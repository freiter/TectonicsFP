unit Settings;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Numedit, ExtCtrls, Menus, Results, Buttons, Types;

type
  TSetForm = class(TRollup)
    NumEdit1: TNumEdit;
    Label1: TLabel;
    ApplyBtn: TButton;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    NumEdit3: TNumEdit;
    NumEdit4: TNumEdit;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    NumEdit2: TNumEdit;
    PopupMenu1: TPopupMenu;
    Minimize1: TMenuItem;
    Arrange1: TMenuItem;
    ArrangeAll1: TMenuItem;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Restore1: TMenuItem;
    Close1: TMenuItem;
    Panel6: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Panel1: TPanel;
    ContLevelRG: TRadioGroup;
    Edit1: TEdit;
    MethodRG: TRadioGroup;
    DensRG: TRadioGroup;
    CloseAll1: TMenuItem;
    N1: TMenuItem;
    Help1: TMenuItem;
    procedure ApplyBtnClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure NumEdit1Change(Sender: TObject);
    procedure Reset(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Arrange1Click(Sender: TObject); override;
    procedure PopupMenu1Popup(Sender: TObject);
    procedure ArrangeAll1Click(Sender: TObject); override;
    procedure Panel6MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
    procedure Panel6MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer); override;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure Restore1Click(Sender: TObject);
    procedure Minimize1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure ContLevelRGClick(Sender: TObject);
    procedure MethodRGClick(Sender: TObject);
    procedure DensRGClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure CloseAll1Click(Sender: TObject);
    procedure Panel6MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Help1Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Edit1Click(Sender: TObject);
  public
    ADens, CON: Integer;
    ACircleFlg, BlownUp: Boolean;
    Value: TCValArray;
    procedure DisableAll(Sender: TObject);
    procedure Initialize(AOwner: TComponent); override;
  published
    MaxAzimuth,maxdip,AAziInterval,ADipInterval : Integer;
  protected
    AAutoFlg, Failed: Boolean;
    procedure ParseString;
    procedure BlowUp(Sender: TObject);
    procedure SizeDown(Sender: TObject);
    procedure CheckSize(AOwner: TComponent);
  end;

const Rollupwidth2: Integer=282;

var SetForm: TSetForm;

implementation
uses TecMain, Inspect, Contour, NDA, ptPlot, Sigma, LowHem, Rose, Fish, Invers;
{$R *.DFM}



procedure TSetForm.ApplyBtnClick(Sender: TObject);
begin
  If FOwner<>nil then
  begin
    Case (FOwner as TLHWin).LHPlotType of
      pt_RoseCenter, pt_RoseCorner:
      begin
        (FOwner as TRoseForm).Max3:=Numedit1.number;
        (FOwner as TRoseForm).Max5:=Numedit2.number;
        (FOwner as TRoseForm).AziIntervall:=Numedit3.Number;
        (FOwner as TRoseForm).DipIntervall:=Numedit4.Number;
        If NumEdit3.Number<>AAziInterval then
        begin
          (FOwner as TRoseForm).AziIntervalChanged:=true;
          RoseAziInt:=NumEdit3.Number;
        end
        else (FOwner as TRoseForm).AziIntervalChanged:=false;
        If NumEdit4.Number<>ADipinterval then
        begin
          (FOwner as TRoseForm).DipIntervalChanged:=true;
          RoseDipInt:=NumEdit4.Number;
        end  
        else (FOwner as TRoseForm).DipIntervalChanged:=false;
        (FOwner as TRoseForm).DipAlso:=Checkbox1.checked;
        RoseDipAlso:=Checkbox1.checked;
        (FOwner as TRoseForm).KlassenMitte:= Checkbox2.checked;
        If CheckBox2.Checked then
          (FOwner as TRoseForm).LHPlotType:=pt_RoseCenter
        else (FOwner as TRoseForm).LHPlotType:=pt_RoseCorner;
        RoseCenter:=CheckBox2.Checked;
        (FOwner as TRoseForm).Compute(Sender);
        (FOwner as TRoseForm).AziIntervalChanged:=true;
        (FOwner as TRoseForm).DipIntervalChanged:=true;
        (FOwner as TRoseForm).Paintbox1.refresh;
      end;
      pt_FluHist:
      begin
        IF FOwner is TSigmaForm then with FOwner as TSigmaForm do
        begin
          Max3:=Numedit1.Number;
          NoofBoxes:=Numedit3.Number;
          FluHIntervals:=NoofBoxes;
          If NumEdit3.Number<>AAziInterval then NoofBoxesChanged:=true;
        end;
        if FOwner is TSigmafromFile then
          (FOwner as TSigmafromFile).Compute(Sender)
        else If FOwner is TNDAPlot then With FOwner as TNDAPlot do
        begin
          Theta:=NumEdit2.Number;
          FormCreate(Sender, LHFilename, LHExtension);
        end
        else if fOwner is TInversPlot then (fOwner as TSigmaForm).Compute(Sender);
        If FOwner is TSigmaForm then (FOwner as TSigmaForm).Paintbox1.Refresh;
      end;
      pt_MohrLambda:
      begin
        If FOwner is TNDAPlot then With FOwner as TNDAPlot do
        begin
          Theta:=NumEdit2.Number;
          FormCreate(Sender, LHFilename, LHExtension);
        end;
        If FOwner is TSigmaForm then (FOwner as TSigmaForm).Paintbox1.refresh;
      end;
      pt_Contour:
      begin
        if ContLevelRG.ItemIndex<>0 then  //manual contour levels
        begin
          AAutoFlg:= false;
          if Edit1.Text<>'' then
          begin
            ParseString; //retrieve data from Edit1
            if failed then
            begin
              ModalResult:=mrNone;
              Edit1.SetFocus;
              exit;
            end;
          end
          else
          begin
            MessageDlg('Type at least one contour-level or switch to automatic mode!',mtError,[mbOk], 0);
            failed:=true;
            Edit1.SetFocus;
            exit;
          end;
        end
        else AAutoFlg:= true;
        if MethodRG.ItemIndex = 0 then
        begin
          ADens := 10;
          ACircleFlg := true;
        end
        else
        begin
          ACircleFlg := false;
          case DensRG.ItemIndex of
            0: ADens := 10;
            1: ADens := 15;
            2: ADens := 20;
          end;
        end;
        With (FOwner as TContPlotFrm) do
        begin
          Screen.cursor:=crHourglass;
          ContAutoInt:=ContLevelRG.ItemIndex=0;
          ContGauss:=MethodRG.ItemIndex=1;
          if ContGauss then ContGridD:=DensRG.ItemIndex;
          ContNetSetup(AAutoFlg,ACircleFlg,ADens,Con,Value);
          Paintbox1.refresh;
        end;
      end;
      pt_LambdaTensor, pt_LambdaDihedra:
      If FOwner is TNDAPlot then With FOwner as TNDAPlot do
      begin
        Theta:=NumEdit2.Number;
        if Sender=ApplyBtn then FormCreate(Sender, LHFilename, LHExtension);
        Paintbox1.refresh;
      end;
      pt_ptPlot: With FOwner as TPlotpt do
      begin
        ptACalcMeanVect:=Checkbox1.Checked;
        ptCalcMeanVect:=Checkbox1.Checked;
        Compute(Sender);
        Paintbox1.refresh;
      end;
      pt_MeanVectFisher, pt_MeanVectRC: With FOwner as TFisherForm do
      begin
        ShowConfCone:=Checkbox1.Checked;
        ShowSpherDistr:=Checkbox2.Checked;
        FishShowConfCone:=Checkbox1.Checked;
        FishShowSpherDistr:=Checkbox2.Checked;
        Compute(Sender);
        Paintbox1.refresh;
      end;
    end;
  Tecmainwin.BringToFront;
  end;
end;

procedure TSetForm.CheckBox1Click(Sender: TObject);
var i: Integer;
begin
  if ((FOwner as TLHWin).LHPlottype<>pt_ptPlot) and ((FOwner as TLHWin).LHPlottype<>pt_MeanVectFisher)
  and ((FOwner as TLHWin).LHPlottype<>pt_MeanVectRC) then
  For i:=2 to 9 do
  begin
    Case i of
      2,4,7,8,9: TControl(FindComponent('Label'+IntToStr(i))).Enabled:=Checkbox1.Checked;
    end;
    Case i of
      2,4: TControl(FindComponent('NumEdit'+IntToStr(i))).Enabled:=Checkbox1.Checked;
    end;
  end;
  NumEdit1Change(Sender);
end;

procedure TSetForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SetFormLeft:=rollupx;
  SetFormTop:=rollupy;
  SetForm:=nil;
  inherited;
end;

procedure TSetForm.NumEdit1Change(Sender: TObject);
begin
  ApplyBtn.Enabled:=true;
end;

procedure TSetForm.Reset(Sender: TObject);
begin
  Label11.caption:='';
  Label11.Hint:='';
  DisableAll(Sender);
  FOwner:=nil;
  //tecmainwin.bringtofront;
end;

procedure TSetForm.FormCreate(Sender: TObject);
begin
  Rollupname:=rt_settings;
  Left:=SetFormLeft;
  Top:=SetFormTop;
  rollupx:=left;
  rollupy:=top;
  MyClientHeight:=ClientHeight;
  //TFPRollups[1]:=Self;
end;



procedure TSetForm.Arrange1Click(Sender: TObject);
begin
  inherited Arrange1Click(Sender);
end;

procedure TSetForm.PopupMenu1Popup(Sender: TObject);
begin
  inherited Popupmenu1Popup(Sender);
end;

procedure TSetForm.ArrangeAll1Click(Sender: TObject);
begin
  inherited ArrangeAll1Click(Sender);
end;

procedure TSetform.DisableAll(Sender:TObject);
begin
  If BlownUp then SizeDown(Sender);
  NumEdit1.Enabled:=false;
  NumEdit3.Enabled:=false;
  CheckBox1.Enabled:=false;
  CheckBox2.Enabled:=false;
  NumEdit2.Enabled:=false;
  NumEdit4.Enabled:=false;
  ApplyBtn.Enabled:=false;
  ContlevelRG.Enabled:=false;
  Edit1.Enabled:=false;
  MethodRG.Enabled:=false;
  DensRG.Enabled:=false;
  Label10.Enabled:=false;
  Label6.Enabled:=false;
  Label1.Enabled:=false;
  Label2.Enabled:=false;
  Label3.Enabled:=false;
  Label4.Enabled:=false;
  Label5.Enabled:=false;
  Label9.Enabled:=false;
  helpcontext:=0;
end;

procedure TSetForm.Panel6MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited Panel6MouseDown(Sender, Button, Shift, X, Y);
end;

procedure TSetForm.Panel6MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  SetFormLeft:=rollupx;
  SetFormTop:=rollupy;
end;

procedure TSetForm.SpeedButton1Click(Sender: TObject);
begin
  if not minimized then Minimize1Click(Sender)
  else Restore1Click(Sender);
  if aligned then TecMainWin.SwapRollups2(Self);
end;

procedure TSetForm.SpeedButton2Click(Sender: TObject);
begin
  Close;
end;

procedure TSetForm.Restore1Click(Sender: TObject);
begin
  inherited Restore1Click(Sender);
  If fowner is TContPlotFrm then
    If not blownup then blowup(Sender);
  ApplyBtn.Left:=(ClientWidth-ApplyBtn.Width) div 2;
end;

procedure TSetForm.Minimize1Click(Sender: TObject);
begin
  inherited Minimize1Click(Sender);
end;

procedure TSetForm.Close1Click(Sender: TObject);
begin
  Close;
end;

procedure TSetForm.SizeDown(Sender: TObject);
begin
  BlownUp:=false;
  visible:=false;
  Left:=Left+width-Rollupwidth;
  Width:=RollupWidth;
  MyRollupwidth:=Width;
  ClientHeight:=340;
  ApplyBtn.Top:=308;
  MethodRG.visible:=false;
  Edit1.visible:=false;
  ContLevelRG.visible:=false;
  Panel1.visible:=false;
  DensRg.Visible:=false;
  ApplyBtn.Left:=(ClientWidth-ApplyBtn.Width) div 2;
  visible:=true;
end;

procedure TSetForm.BlowUp(Sender: TObject);
begin
  BlownUp:=true;
  visible:=false;
  Left:=Left+width-Rollupwidth2;
  Width:=Rollupwidth2;
  MyRollupwidth:= Width;
  ClientHeight:=268;
  //ClientHeight:=340;
  ApplyBtn.Top:=244;
  ApplyBtn.Left:=(ClientWidth-ApplyBtn.Width) div 2;
  visible:=true;
end;

procedure TSetForm.CheckSize(AOwner: TComponent);
begin
  Case (AOwner as TLHWin).LHPlottype of
    pt_RoseCenter, pt_RoseCorner, pt_FluHist, pt_ptPlot:
    begin
      If not minimized and visible then
        If BlownUp then SizeDown(nil)
      else
      begin
        MyRollupwidth:=Rollupwidth;
        MyClientHeight:=340;
        ApplyBtn.Top:=308;
      end;
      MethodRG.visible:=false;
      Edit1.visible:=false;
      ContLevelRG.visible:=false;
      Panel1.visible:=false;
      DensRg.Visible:=false;
      Label10.Caption:='%';
      Label1.Caption:='Max.';
      Label10.Enabled:=true;
      Label6.Enabled:=true;
    end;
  end;
  case (AOwner as TLHWin).LHPlottype of
    pt_FluHist, pt_LambdaTensor, pt_LambdaDihedra:
    begin
      NumEdit1.enabled:=true;
      NumEdit1.visible:=true;
      NumEdit2.enabled:=false;
      NumEdit2.visible:=false;
      NumEdit4.enabled:=false;
      NumEdit4.visible:=false;
      Checkbox1.enabled:=false;
      Checkbox1.visible:=false;
      Checkbox2.enabled:=false;
      Checkbox2.visible:=false;
      Label1.visible:=true;
      Label1.Enabled:=true;
      Label2.visible:=false;
      Label4.visible:=false;
      Label6.visible:=false;
      Label7.visible:=false;
      Label8.visible:=false;
      Label9.visible:=false;
      Label10.visible:=true;
      Bevel1.visible:=true;
    end;
  end;
end;

procedure TSetForm.Initialize(AOwner: TComponent);
var i:integer;
    NumStr: string; //Contouring only
begin
  inherited;
  If FOwner<>nil then
  begin
    Label11.Caption:='Plot '+IntToStr((FOwner as TLHWin).LHPlotNumber)+#10#13+ExtractFilename((FOwner as TLHWin).LHFilename);;
    Label11.Hint:='Change parameters of '+ ExtractFilename((FOwner as TLHWin).LHFilename)+'| ';
    if fowner is tlhwin then
    Case (FOwner as TLHWin).LHPlotType of
      pt_RoseCenter, pt_RoseCorner:
      begin
        CheckSize(AOwner);
        if not (FOwner as TRoseForm).LHPasteMode then
        begin
          Label5.Caption:='Interval';
          Label3.Caption:='Azimuth scaling';
          If Trunc((FOwner as TRoseForm).Max2)=(FOwner as TRoseForm).Max2 then
            NumEdit1.Number:=Round((FOwner as TRoseForm).Max2)
          else
            NumEdit1.Number:=Trunc((FOwner as TRoseForm).Max2)+1;
          If Trunc((FOwner as TRoseForm).Max4)=(FOwner as TRoseForm).Max4 then
            NumEdit2.Number:=Round((FOwner as TRoseForm).Max4)
          else
            NumEdit2.Number:=Trunc((FOwner as TRoseForm).Max4)+1;
          //NumEdit2.Number:=Trunc((FOwner as TRoseForm).Max4)+1;
          NumEdit1.HelpContext:=460;
          NumEdit1.Hint:='Select histogram maximum| ';
          NumEdit2.HelpContext:=460;
          NumEdit3.HelpContext:=460;
          NumEdit4.HelpContext:=460;
          Label1.Tag:=460;
          Label2.Tag:=460;
          Label3.Tag:=460;
          Label4.Tag:=460;
          Label5.Tag:=460;
          Label6.Tag:=460;
          Label7.Tag:=460;
          Label8.Tag:=460;
          Label9.Tag:=460;
          Label10.Tag:=460;
          Checkbox1.HelpContext:=460;
          Checkbox2.HelpContext:=460;
          ApplyBtn.HelpContext:=460;
          HelpContext:=460;
          If (FOwner as TRoseForm).LHExtension=AZI then with checkbox1 do
          begin
            enabled:=false;
            checked:=false;
          end
          else with checkbox1 do
          begin
            Enabled:=true;
            checked:=(FOwner as TRoseForm).dipalso;
          end;
          CheckBox1.visible:=true;
          CheckBox1.Hint:='Draw a 2nd histogram for dips| ';
          CheckBox2.visible:=true;
          CheckBox2.enabled:=true;
          CheckBox2.checked:= (FOwner as TRoseForm).klassenmitte;
          NumEdit1.visible:=true;
          NumEdit1.enabled:=true;
          NumEdit2.visible:=true;
          NumEdit3.visible:=true;
          NumEdit3.enabled:=true;
          NumEdit4.visible:=true;
          Numedit3.maxlength:=3;
          Numedit3.number:=Round((FOwner as TRoseForm).AziIntervall);
          Numedit4.number:=Round((FOwner as TRoseForm).DipIntervall);
          AAziInterval:=Round((FOwner as TRoseForm).AziIntervall);
          ADipInterval:=Round((FOwner as TRoseForm).DipIntervall);
          NumEdit2.Enabled:=CheckBox1.Checked;
          NumEdit4.Enabled:=CheckBox1.Checked;
          Label1.visible:=true;
          Label1.enabled:=true;
          Label2.visible:=true;
          Label2.Enabled:=CheckBox1.Checked;
          Label3.visible:=true;
          Label3.enabled:=true;
          Label3.Caption:='Azimuth scaling';
          Label4.visible:=true;
          Label4.Enabled:=CheckBox1.Checked;
          Label5.visible:=true;
          Label5.enabled:=true;
          Label6.visible:=true;
          Label7.visible:=true;
          Label7.Enabled:=CheckBox1.Checked;
          Label8.visible:=true;
          Label8.Enabled:=CheckBox1.Checked;
          Label9.visible:=true;
          Label9.Enabled:=CheckBox1.Checked;
          Label10.visible:=true;
          Bevel1.visible:=true;
          Bevel2.visible:=true;
          MaxAzimuth:=round((FOwner as TRoseForm).Max2);
          MaxDip:=round((FOwner as TRoseForm).Max4);
          ApplyBtn.Enabled:=false;
        end
        else Label11.Caption:='Rose-diagram'+#10#13+ExtractFilename((FOwner as TRoseForm).LHFilename);
      end;
      pt_FluHist:
      begin
        CheckSize(AOwner);
        If AOwner is TNDAPlot then
        begin
          NumEdit2.visible:=true;
          NumEdit2.enabled:=true;
          Label2.Visible:=true;
          label2.enabled:=true;
          label9.visible:=true;
          NumEdit2.Number:=(FOwner as TNDAPlot).Theta;
          NumEdit2.HelpContext:=476;
          NumEdit2.Hint:='Enter theta angle| ';
          Label2.Tag:=476;
          Label4.Tag:=476;
          NumEdit3.Visible:=false;
          Label5.Visible:=false;
          Label9.Enabled:=true;
          Label9.Caption:='°';
          Label2.Caption:='Theta';
          Label4.Visible:=true;
          Label4.Enabled:=true;
          Label4.Caption:='NDA-Calc.';
        end;
        NumEdit3.enabled:=true;
        NumEdit1.Hint:='Select histogram maximum| ';
        NumEdit3.visible:=true;
        Numedit3.maxlength:=2;
        Label3.visible:=false;
        Label5.Caption:='Intervals';
        Label5.visible:=true;
        Label5.Enabled:=true;
        If FOwner is TSigmaForm then
        begin
          NumEdit1.Number:=round((FOwner as TSigmaForm).Max2);
          Numedit3.number:=Round((FOwner as TSigmaForm).NoofBoxes);
          AAziInterval:=Round((FOwner as TSigmaForm).NoofBoxes);
          MaxAzimuth:=round((FOwner as TSigmaForm).Max2);
        end else
          ApplyBtn.Enabled:=false;
      end;
      pt_MohrLambda:
      begin
        If AOwner is TNDAPlot then
        begin
          NumEdit2.visible:=true;
          NumEdit2.enabled:=true;
          NumEdit1.Enabled:=false;
          Label1.enabled:=false;
          Label10.enabled:=false;
          Label2.Visible:=true;
          label2.enabled:=true;
          label9.visible:=true;
          NumEdit2.Number:=(FOwner as TNDAPlot).Theta;
          NumEdit2.HelpContext:=476;
          NumEdit2.Hint:='Enter theta angle| ';
          Label2.Tag:=476;
          Label4.Tag:=476;
          NumEdit3.Visible:=false;
          Label5.Visible:=false;
          Label9.Enabled:=true;
          Label9.Caption:='°';
          Label2.Caption:='Theta';
          Label4.Visible:=true;
          Label4.Enabled:=true;
          Label4.Caption:='NDA-Calc.';
        end
        else DisableAll(nil);
      end;
      pt_ptPlot:
      begin
        CheckSize(AOwner);
        NumEdit3.enabled:=false;
        NumEdit3.visible:=false;
        Label3.visible:=false;
        Label5.visible:=false;
        Label5.Enabled:=false;
        Label1.Enabled:=False;
        Label10.Enabled:=False;
        Label9.Enabled:=False;
        Checkbox1.Caption:='Mean vectors';
        Checkbox1.Hint:='Switch on/off mean vectors| ';
        Checkbox1.HelpContext:=215;
        Checkbox1.visible:=true;
        With (FOwner as Tplotpt) do
        begin
          Checkbox1.Enabled:=lhz-nosense>1;
          if Checkbox1.Enabled then
            Checkbox1.Checked:=ptACalcMeanVect
          else Checkbox1.Checked:=false;
        end;
        ApplyBtn.Enabled:=false;
      end;
      pt_MeanVectRC, pt_MeanVectFisher:
      begin
        CheckSize(AOwner);
        NumEdit3.enabled:=false;
        NumEdit3.visible:=false;
        Label3.visible:=false;
        Label5.visible:=false;
        Label5.Enabled:=false;
        Label1.Enabled:=False;
        Label10.Enabled:=False;
        Label9.Enabled:=False;
        Checkbox1.Caption:='Conf. cone';
        Checkbox1.Hint:='Show confidence cone| ';
        Checkbox1.HelpContext:=217;
        Checkbox1.visible:=true;
        Checkbox2.Caption:='Spher. distr.';
        Checkbox2.Hint:='Show small circle for normal distribution| ';
        Checkbox2.HelpContext:=217;
        Checkbox2.visible:=true;
        With (FOwner as TFisherForm) do
        begin
          Checkbox1.Enabled:=Spherical;
          Checkbox2.Enabled:=Spherical and (lhPlotType=pt_MeanVectRC);
          CheckBox1.Checked:=ShowConfCone;
          Checkbox2.Checked:=ShowSpherDistr;
        end;
        ApplyBtn.Enabled:=false;
      end;
      pt_LambdaTensor, pt_LambdaDihedra:
      begin
        If AOwner is TNDAPlot then
        begin
          CheckSize(AOwner);
          NumEdit1.Enabled:=false;
          label1.enabled:=false;
          Label10.enabled:=false;
          NumEdit2.visible:=true;
          NumEdit2.enabled:=true;
          Label2.Visible:=true;
          label2.enabled:=true;
          label9.visible:=true;
          NumEdit2.Number:=(FOwner as TNDAPlot).Theta;
          NumEdit2.HelpContext:=476;
          NumEdit2.Hint:='Enter theta angle| ';
          Label2.Tag:=476;
          Label4.Tag:=476;
          NumEdit3.Visible:=false;
          Label5.Visible:=false;
          Label9.Enabled:=true;
          Label9.Caption:='°';
          Label2.Caption:='Theta';
          Label4.Visible:=true;
          Label4.Enabled:=true;
          Label4.Caption:='NDA-Calc.';
          ApplyBtn.Enabled:=false;
        end else DisableAll(nil);
      end;
      pt_Contour:
      begin
        If not minimized and visible then
          If not BlownUp then BlowUp(nil)
        else
        begin
          MyRollupwidth:=Rollupwidth2;
          MyClientHeight:=268;
          ApplyBtn.Top:=244;
        end;
        Label1.visible:=false;
        Label2.visible:=false;
        Label3.visible:=false;
        Label4.visible:=false;
        Label5.visible:=false;
        Label6.visible:=false;
        Label7.visible:=false;
        Label8.visible:=false;
        Label9.visible:=false;
        Label10.visible:=false;
        NumEdit1.visible:=false;
        NumEdit1.enabled:=false;
        NumEdit3.visible:=false;
        NumEdit3.enabled:=false;
        NumEdit2.visible:=false;
        NumEdit2.enabled:=false;
        NumEdit4.visible:=false;
        NumEdit4.enabled:=false;
        Checkbox1.visible:=false;
        Checkbox1.enabled:=false;
        Checkbox2.visible:=false;
        Checkbox2.enabled:=false;
        Bevel1.visible:=false;
        Bevel2.visible:=false;
        MethodRG.visible:=true;
        Edit1.visible:=true;
        ContLevelRG.visible:=true;
        Panel1.visible:=true;
        DensRg.Visible:=true;
        MethodRG.enabled:=true;
        Edit1.enabled:=true;
        ContLevelRG.enabled:=true;
        if not (FOwner as TContPlotFrm).CircleMethod then
        begin
          DensRG.enabled:=true;
          MethodRG.ItemIndex:= 1;
          case (FOwner as TContPlotFrm).rings of
            10: DensRG.ItemIndex:= 0;
            15: DensRG.ItemIndex:= 1;
            20: DensRG.ItemIndex:= 2;
          end;
        end
        else
        begin
          MethodRG.ItemIndex:= 0;
          DensRG.ItemIndex:= 0;
          DensRG.enabled:=false;
        end;
        CON := (FOwner as TContPlotFrm).NCON;
        if not (FOwner as TContPlotFrm).AutoCont or ((FOwner as TContPlotFrm).NCON>1) then
        begin
          for I:=1 to CON do Value[i]:= (FOwner as TContPlotFrm).CVAL[i];
          Str(Value[1]:3:2,NumStr);
          Edit1.text:= NumStr;
          for I:=2 to CON do
          begin
            Str(Value[i]:3:2,NumStr);
            Edit1.Text := Edit1.Text + tfpListSeparator + NumStr;
          end;
        end;
        If (FOwner as TContPlotFrm).AutoCont then ContLevelrg.ItemIndex:=0
        else ContLevelRG.ItemIndex:=1;
        ApplyBtn.Enabled:=false;
      end;
    else DisableAll(nil);
    end // case
    else DisableAll(nil);
  end else DisableAll(nil);
  rollupx:=left;
  rollupy:=top;
end;

procedure TSetForm.ParseString;
var  i,err: Integer;
     NumStr: string[6];
     key: string[1];
     CValue: single;
begin
  CON:=1;
  NumStr:='';
  for i:= 1 to length(Edit1.text) do
  begin
    if CON>15 then
    begin
      MessageDlg('Please not more than 15 values!'+#13+#10+'Try again!',mtError,[mbOk], 0);
      failed:=true;
      Edit1.SetFocus;
      exit;
    end;
    key:=copy(Edit1.text,i,1);
    if key= DecimalSeparator then key := '.'; // Val function works only with '.'
    if key <> tfpListSeparator then NumStr := NumStr + Key
    else
    begin
      if NumStr='' then Value[CON]:=0
      else
        val(NumStr,CValue,err);
      if err<>0 then
      begin
        MessageDlg('Invalid floating point value!',mtError,[mbOk], 0);
        failed:=true;
        Edit1.SetFocus;
        Exit;
      end;
      Value[CON]:=CValue;
      NumStr:= '';
      inc(CON);
    end;
  end;
  if NumStr='' then Value[CON]:=0
  else
    val(NumStr,CValue,err);
  if err<>0 then
  begin
    MessageDlg('Invalid floting point value!',mtError,[mbOk], 0);
    failed:=true;
    Edit1.SetFocus;
    Exit;
  end;
  Value[CON]:=CValue;
  NumStr:= '';
  failed:=false;
end;

procedure TSetForm.ContLevelRGClick(Sender: TObject);
begin
  if visible then if ContLevelRG.ItemIndex = 1 then Edit1.SetFocus;
  ApplyBtn.Enabled:=true;
end;

procedure TSetForm.MethodRGClick(Sender: TObject);
begin
  if MethodRG.ItemIndex = 0 then DensRG.Enabled := false
  else DensRG.Enabled := true;
  ApplyBtn.Enabled:=true;
end;

procedure TSetForm.DensRGClick(Sender: TObject);
begin
  ApplyBtn.Enabled:=true;
end;

procedure TSetForm.FormResize(Sender: TObject);
begin
  inherited;
  SetformWidth:= Width;
end;

procedure TSetForm.CloseAll1Click(Sender: TObject);
begin
  TecMainWin.CloseAllRollups(Sender);
end;

procedure TSetForm.Panel6MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited Panel6MouseUp(Sender, Button, Shift, X, Y);
end;

procedure TSetForm.Help1Click(Sender: TObject);
begin
  If popupmenu1.popupcomponent is twincontrol then Application.HelpContext((popupmenu1.popupcomponent as twincontrol).HelpContext)
  else application.helpcontext(popupmenu1.popupcomponent.tag)

end;

procedure TSetForm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then key:=#0;
  if not (key in ['0'..'9', '.', DecimalSeparator, tfpListSeparator, #8]) then key:= #0;
end;

procedure TSetForm.Edit1Click(Sender: TObject);
begin
  ContLevelRG.ItemIndex:=1;
  Edit1.SetFocus;
end;

end.
