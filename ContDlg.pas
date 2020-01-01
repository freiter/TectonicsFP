unit ContDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Types;

type
  TContDlgFrm = class(TForm)
    ContLevelRG: TRadioGroup;
    MethodRG: TRadioGroup;
    DensRG: TRadioGroup;
    OkBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    Edit1: TEdit;
    Panel1: TPanel;
    RadioGroup1: TRadioGroup;
    procedure ContLevelRGClick(Sender: TObject);
    procedure OkBtnClick(Sender: TObject);
    procedure MethodRGClick(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure ParseString;
    procedure Edit1Click(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
    FileName: string;
    ContFailed: Boolean;
    fExtension: TExtension;
    procedure FillEditField;
  public
    Aautoflg, ACircleFlg : boolean;
    ADens : Integer;
    CON : Integer;
    Value: TCValArray;
    procedure Open(Sender: TObject; const aExtension: TExtension);
  end;

var
  ContDlgFrm: TContDlgFrm;

implementation


{$R *.DFM}

procedure TContDlgFrm.Open(Sender: TObject; const aExtension: TExtension);
begin
  fExtension:=AExtension;
  case fExtension of
    fpl, cor: with RadioGroup1 do begin
      HelpContext:=466;
      Visible:=True;
      ItemIndex:=Ord(not ContFPlane);
    end;
    ptf: With RadioGroup1 do begin
      HelpContext:=467;
      Items.Add('p-axes');
      Items.Add('t-axes');
      Items.Add('b-axes');
      Visible:=True;
      if ContPTUse<5 then ItemIndex:=ContPTUse;
    end;
  end;
  ContLevelRG.ItemIndex:=Ord(not ContAutoInt);
  MethodRG.ItemIndex:=Ord(ContGauss);
  If ContGauss then DensRG.ItemIndex:= ContGridD;
  if not ContAutoInt then FillEditField;
end;

procedure TContDlgFrm.FillEditField;
var i: Integer;
begin
  For i:=1 to 15 do
    begin
      If ContValues[i]<>0 then
      begin
        If Edit1.Text<>'' then Edit1.Text:=Edit1.Text+';';
        Edit1.Text:=Edit1.Text+FloatToString(ContValues[i],1,2);
      end;
    end;
end;

procedure TContDlgFrm.ContLevelRGClick(Sender: TObject);
begin
  if (ContLevelRG.ItemIndex=1) and Visible then
  begin
    If Edit1.Text='' then FillEditField;
    Edit1.SetFocus;
  end;  
end;

procedure TContDlgFrm.OkBtnClick(Sender: TObject);
begin
  if ContLevelRG.ItemIndex<>0 then //manual contouring intervals
  begin
    AAutoFlg:= False;
    if Edit1.Text<>'' then
    begin
      ParseString; //retrieve text from Edit1
      if ContFailed then
      begin
        ModalResult:=mrNone;
        Edit1.SetFocus;
        Exit;
      end;
    end
    else
    begin
      MessageDlg('Type at least one contour-level or switch to automatic mode!',mtError,[mbOk], 0);
      ContFailed:=True;
      ModalResult:=mrNone;
      Edit1.SetFocus;
      Exit;
    end;
  end
  else
  begin //Automatic Contouring
    AAutoFlg:= True;
    ModalResult:= mrOk;
  end;
  if MethodRG.ItemIndex = 0 then
  begin
    ADens := 10;
    ACircleFlg := True;
  end
  else
  begin
    ACircleFlg := False;
    case DensRG.ItemIndex of
      0: ADens := 10;
      1: ADens := 15;
      2: ADens := 20;
    end;
  end;
  if not ContFailed then
  begin
    ContAutoInt:=ContLevelRG.ItemIndex=0;
    ContGauss:=MethodRG.ItemIndex=1;
    if ContGauss then ContGridD:=DensRG.ItemIndex;
    if RadioGroup1.Visible then
      Case fExtension of
        cor, fpl: ContFPlane:=RadioGroup1.ItemIndex=0;
        ptf: ContPTUse:=RadioGroup1.ItemIndex;
      end;
    ModalResult:= mrOk;
  end;
end;

procedure TContDlgFrm.MethodRGClick(Sender: TObject);
begin
    if MethodRG.ItemIndex = 0 then DensRG.Enabled := False
    else DensRG.Enabled := True;
end;

procedure TContDlgFrm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if key=#13 then key:=#0;
  if not (key in ['0'..'9', '.', DecimalSeparator, tfpListSeparator, #8]) then key:= #0;
end;

procedure TContDlgFrm.ParseString;
var  i,err: Integer;
     NumStr: string[6];
     key: string[1];
     CValue: single;
begin
  CON:=1;
  NumStr:='';
  for i:= 1 to Length(Edit1.text) do
  begin
    if CON>15 then
    begin
      MessageDlg('Please not more than 15 values!'+#13+#10+'Try again!',mtError,[mbOk], 0);
      ContFailed:=True;
      Edit1.SetFocus;
      exit;
    end;
    Key:=Copy(Edit1.text,i,1);
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
        ContFailed:=True;
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
    ContFailed:=True;
    Edit1.SetFocus;
    Exit;
  end;
  Value[CON]:=CValue;
  NumStr:= '';
  ContFailed:=False;
end;

procedure TContDlgFrm.Edit1Click(Sender: TObject);
begin
  ContLevelRG.ItemIndex:=1;
  Edit1.SetFocus;
end;

procedure TContDlgFrm.HelpBtnClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
