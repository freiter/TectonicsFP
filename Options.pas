unit Options;

interface

uses Windows, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Dialogs, SysUtils, inifiles, TabNotBk, types,
  ComCtrls, Numedit, Tabs, math, fileops;

type
  TOptionDialog = class(TForm)
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    ApplyBtn: TButton;
    TabSet1: TTabSet;
    Notebook1: TNotebook;
    Bevel1: TBevel;
    Label2: TLabel;
    NumEdit1: TNumEdit;
    Label5: TLabel;
    Edit2: TEdit;
    RadioGroup3: TRadioGroup;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    NumEdit7: TNumEdit;
    NumEdit8: TNumEdit;
    NumEdit9: TNumEdit;
    NumEdit10: TNumEdit;
    Label17: TLabel;
    Label20: TLabel;
    NumEdit13: TNumEdit;
    NumEdit14: TNumEdit;
    NumEdit15: TNumEdit;
    NumEdit11: TNumEdit;
    NumEdit16: TNumEdit;
    Bevel2: TBevel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    Bevel7: TBevel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    Label30: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Label3: TLabel;
    NumEdit12: TNumEdit;
    Label18: TLabel;
    NumEdit17: TNumEdit;
    CheckBox1: TCheckBox;
    Label19: TLabel;
    NumEdit18: TNumEdit;
    CheckBox2: TCheckBox;
    RadioGroup7: TRadioGroup;
    RadioGroup5: TRadioGroup;
    RadioGroup6: TRadioGroup;
    Bevel3: TBevel;
    RadioGroup1: TRadioGroup;
    Label9: TLabel;
    Label10: TLabel;
    Bevel6: TBevel;
    Label21: TLabel;
    Bevel8: TBevel;
    Bevel9: TBevel;
    NumEdit4: TNumEdit;
    NumEdit6: TNumEdit;
    Bevel10: TBevel;
    Label7: TLabel;
    NumEdit5: TNumEdit;
    Bevel11: TBevel;
    Bevel12: TBevel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label8: TLabel;
    Bevel13: TBevel;
    Bevel14: TBevel;
    Label34: TLabel;
    Label35: TLabel;
    Bevel15: TBevel;
    Label36: TLabel;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    Label37: TLabel;
    CheckBox12: TCheckBox;
    OkBtn: TBitBtn;
    Bevel16: TBevel;
    Label38: TLabel;
    NumEdit19: TNumEdit;
    Label39: TLabel;
    Label40: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure ApplyBtnEnable(Sender: TObject);
    procedure TabSet1Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure RadioGroup3Click(Sender: TObject);
    procedure RadioGroup5Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure HelpBtnClick(Sender: TObject);
  end;

implementation

uses tecmain;
{$R *.DFM}

procedure TOptionDialog.FormCreate(Sender: TObject);
begin
  if lastoptpage>tabset1.tabs.count-1 then lastoptpage:=tabset1.tabs.count-1;
  TabSet1.TabIndex:=LastOptPage;
  Notebook1.PageIndex:= TabSet1.TabIndex;
  FormPaint(Sender);
end;

procedure TOptionDialog.FormPaint(Sender: TObject);
begin
  Checkbox1.Checked:= E2BeepOn;
  Checkbox2.Checked:= E2Autofill;
  NumEdit1.Number:= PolySegments;
  NumEdit18.Number:= SmallPolySegments;
  NumEdit19.Number:= CorrError;
  If WriteWMFGlobal then Radiogroup1.ItemIndex:=0
  else Radiogroup1.ItemIndex:=1;
  NumEdit4.Number:= PrintLowerHemiSize;
  NumEdit5.Number:= BT_Increment;
  NumEdit6.Number:= ClipbLowerHemiSize;
  NumEdit7.Number:= Round(AngSSArrowLength*1000/Radius);
  NumEdit8.Number:= Round(AngSSArrowHeadLength*1000/Radius);
  NumEdit11.Number:=Round(RadToDeg(DegAngSSArrowAngle));
  NumEdit9.Number:= Round(AngNRArrowLength*1000/Radius);
  NumEdit10.Number:=Round(AngNRArrowHeadLength*1000/Radius);
  NumEdit16.Number:=Round(RadToDeg(DegAngNRArrowAngle));
  NumEdit15.Number:=Round(RadToDeg(DegHoepArrowAngle));
  NumEdit14.Number:=Round(HoepArrowLength*1000/Radius);
  NumEdit13.Number:=Round(HoepArrowheadLength*1000/Radius);
  NumEdit12.Number:=NorthPenWidth;
  NumEdit17.Number:=AxesPenWidth;
  With Radiogroup3 do
    case ord(FileListSeparator) of
      44: ItemIndex:=0;
      59: ItemIndex:=1;
       9: ItemIndex:=2;
      32: ItemIndex:=3;
      else
      begin
        ItemIndex:=4;
        Edit2.Text:= FileListSeparator;
      end;
    end;
  With Radiogroup5 do
    If QualityGlobal then ItemIndex:=0
      else ItemIndex:=1;
    Radiogroup7.Itemindex:=QualitylevelsUsed;
    Radiogroup6.Itemindex:=GlobalArrowStyle;
    ApplyBtn.Enabled:=False;
  If not WriteWMFglobal then
  begin
    Numedit6.Enabled:=false;
    Label9.enabled:=false;
    Label10.enabled:=false;
  end;
  CheckBox3.Checked:= ResInspShowLocation;
  CheckBox4.Checked:= ResInspShowX;
  CheckBox5.Checked:= ResInspShowY;
  CheckBox6.Checked:= ResInspShowZ;
  CheckBox7.Checked:= ResInspShowDate;
  CheckBox8.Checked:= ResInspShowLithology;
  CheckBox9.Checked:= ResInspShowFormation;
  CheckBox10.Checked:=ResInspShowAge;
  CheckBox11.Checked:=ResInspShowTectUnit;
  CheckBox12.Checked:=ResInspShowRemarks;
end; {sub}

procedure TOptionDialog.ApplyBtnClick(Sender: TObject);
begin
  If (WriteWmfGlobal and (radiogroup1.itemindex=1)) or (not WriteWmfGlobal and (radiogroup1.itemindex=0)) then
    if GlobalClipbMFH<>0 then  //delete clipboard tfp-metafiles if format has changed
    begin
      If WriteWmfGlobal then DeleteMetaFile(GlobalClipbMFH)
      else DeleteEnhMetaFile(GlobalClipbMFH);
      GlobalClipbMFH:=0;
    end;
  If Radiogroup1.ItemIndex=0 then
    WriteWMFglobal:=True
  else
    WriteWMFglobal:=false;
  E2BeepOn:=Checkbox1.Checked;
  E2AutoFill:=Checkbox2.Checked;
  SmallPolySegments:=NumEdit18.Number;
  CorrError:=Abs(NumEdit19.Number);
  PrintLowerHemiSize:=NumEdit4.Number;
  BT_Increment:=NumEdit5.Number;
  ClipbLowerHemiSize:= NumEdit6.Number;
  MetafileMMWidth:=ClipbLowerHemiSize*500 div 4;
  MetafileMMHeight:=MetafileMMWidth;
  GlobalArrowStyle:=RadioGroup6.ItemIndex;
  QualitylevelsUsed:=RadioGroup7.ItemIndex;
  AngSSArrowLength:=Radius*NumEdit7.Number/1000;
  AngSSArrowHeadLength:=Radius*NumEdit8.Number/1000;
  DegAngSSArrowAngle:=DegToRad(NumEdit11.Number);
  AngNRArrowLength:=Radius*NumEdit9.Number/1000;
  AngNRArrowHeadLength:=Radius*NumEdit10.Number/1000;
  DegAngNRArrowAngle:=DegToRad(NumEdit16.Number);
  DegHoepArrowAngle:=DegToRad(NumEdit15.Number);
  HoepArrowLength:=Radius*NumEdit14.Number/1000;
  HoepArrowheadLength:=Radius*NumEdit13.Number/1000;
  QualityGlobal:=boolean(Radiogroup5.Itemindex-1);
  NorthPenWidth:=NumEdit12.Number;
  AxesPenWidth:=NumEdit17.Number;
  case Radiogroup3.ItemIndex of
    0: FileListSeparator:=',';
    1: FileListSeparator:=';';
    2: FileListSeparator:=#09;
    3: FileListSeparator:=#32;
    4: FileListSeparator:=(Edit2.Text)[1];
  end;
  ResInspShowLocation:=CheckBox3.Checked;
  ResInspShowX:=CheckBox4.Checked;
  ResInspShowY:=CheckBox5.Checked;
  ResInspShowZ:=CheckBox6.Checked;
  ResInspShowDate:=CheckBox7.Checked;
  ResInspShowLithology:=CheckBox8.Checked;
  ResInspShowFormation:=CheckBox9.Checked;
  ResInspShowAge:=CheckBox10.Checked;
  ResInspShowTectUnit:=CheckBox11.Checked;
  ResInspShowRemarks:=CheckBox12.Checked;
  
  ApplyBtn.Enabled:=False;
end;

procedure TOptionDialog.ApplyBtnEnable(Sender: TObject);
begin
  ApplyBtn.Enabled:=true;
end;

procedure TOptionDialog.TabSet1Click(Sender: TObject);
begin
  Notebook1.PageIndex := TabSet1.TabIndex;
end;

procedure TOptionDialog.RadioGroup1Click(Sender: TObject);
begin
  Case radiogroup1.Itemindex of
    0: begin
      Numedit6.Enabled:=true;
      Label10.Enabled:=true;
      Label22.Enabled:=true;
    end;
    1:begin
      Numedit6.Enabled:=false;
      Label10.Enabled:=false;
      Label22.Enabled:=false;
    end;
  end;
  ApplyBtn.Enabled:=true;
end;

procedure TOptionDialog.RadioGroup3Click(Sender: TObject);
begin
  If Radiogroup3.itemindex =4 then Edit2.Enabled:=true
  else Edit2.Enabled:=false;
end;

procedure TOptionDialog.RadioGroup5Click(Sender: TObject);
begin
  If Radiogroup5.ItemIndex=0 then
  begin
    //Radiogroup7.Enabled:=true;
    Radiogroup6.enabled:=false;
  end
  else
  begin
    Radiogroup7.Enabled:=false;
    Radiogroup6.enabled:=true;
  end;
end;

procedure TOptionDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  LastOptPage:=TabSet1.TabIndex;
end;

procedure TOptionDialog.HelpBtnClick(Sender: TObject);
begin
  Application.HelpContext(HelpBtn.HelpContext)
end;

end.
