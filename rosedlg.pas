unit Rosedlg;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Buttons, Numedit, Types;

type
  TRoseDial = class(TForm)
    RadioGroup1: TRadioGroup;
    CheckBox1: TCheckBox;
    Label1: TLabel;
    OkBtn: TBitBtn;
    CancelBtn: TBitBtn;
    NumEdit1: TNumEdit;
    Label2: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Bevel1: TBevel;
    Label4: TLabel;
    NumEdit2: TNumEdit;
    Label5: TLabel;
    CheckBox2: TCheckBox;
    BitBtn1: TBitBtn;
    procedure OkBtnClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  protected
    ext : TExtension;
  public
    unipol, plane : boolean;
    stressaxis: integer;
    procedure Open(Sender: TObject; const AExtension: TExtension);
  end;

var
  RoseDial: TRoseDial;

implementation

{$R *.DFM}

uses fileops, Tecmain;

procedure TRoseDial.OkBtnClick(Sender: TObject);
begin
  unipol:=true;
  RoseCenter:=CheckBox2.Checked;
  RoseAziInt:=NumEdit1.Number;
  RoseDipInt:=NumEdit2.Number;
  case ext of
    AZI: begin
      Unipol:=RadioGroup1.ItemIndex=0;
      RoseAziBipol:=not Unipol;
    end;
    COR, FPL, PTF:
    begin
      If RadioGroup1.ItemIndex=0 then
      begin
        Plane := true;
        unipol:=false;
      end
      else Plane := false;
      if ext=PTF then
        RosePTUse:=RadioGroup1.ItemIndex
      else RoseFPlane:=RadioGroup1.ItemIndex=0;
      RoseDipAlso:=CheckBox1.Checked;
    end;
    PLN:
    begin
      Unipol:=RadioGroup1.ItemIndex<>0;
      RosePLBipol:=not Unipol;
    end;
    LIN: RoseDipAlso:=CheckBox1.Checked;
  end;
end;

procedure TRoseDial.Open(Sender: TObject; const AExtension: TExtension);
begin
  Checkbox2.Checked:=RoseCenter;
  NumEdit1.Number:=RoseAziInt;
  NumEdit2.Number:=RoseDipInt;
  ext:= AExtension;
  case ext of
    AZI: begin
      Checkbox1.Enabled := false;
      Radiogroup1.HelpContext:=455;
      RadioGroup1.ItemIndex:=Ord(RoseAziBipol);
    end;
    COR, FPL:
    begin
      With RadioGroup1 do
      begin
        Caption:='Use...';
        Items[0]:='fault planes (strike, bipolar)';
        Items[1]:='fault lineations';
        HelpContext:=457;
        ItemIndex:=Ord(not RoseFPlane);
      end;
      Checkbox1.Checked:=RoseDipAlso;
      Label4.Enabled:=RoseDipAlso;
      Label5.Enabled:=RoseDipAlso;
      NumEdit2.Enabled:=RoseDipAlso;
    end;
    PTF:
    begin
      With RadioGroup1 do
      begin
        Caption:='Use...';
        Items[0]:='fault planes (strike, bipolar)';
        Items[1]:='fault lineations';
        Items.Add('p-axes');
        Items.Add('t-axes');
        Items.Add('b-axes');
        ItemIndex:=RosePTUse;
        HelpContext:=458;
      end;
      Checkbox1.Checked:=RoseDipAlso;
      Label4.Enabled:=RoseDipAlso;
      Label5.Enabled:=RoseDipAlso;
      NumEdit2.Enabled:=RoseDipAlso;
    end;
    PLN:
    begin
      With RadioGroup1 do
      begin
        Caption:='Use...';
        Items[0]:='Strike direction (bipolar)';
        Items[1]:='Poles to planes (unipolar)';
        HelpContext:=456;
      end;
      Checkbox1.Checked:=RoseDipAlso;
      Label4.Enabled:=RoseDipAlso;
      Label5.Enabled:=RoseDipAlso;
      NumEdit2.Enabled:=RoseDipAlso;
      RadioGroup1.ItemIndex:=Ord(not RosePLBipol);
    end;
    LIN:
    begin
      Radiogroup1.visible:=false;
      Radiobutton1.visible:=true;
      Radiobutton2.visible:=true;
      Bevel1.visible:=true;
      Checkbox1.Checked:=RoseDipAlso;
      Label4.Enabled:=RoseDipAlso;
      Label5.Enabled:=RoseDipAlso;
      NumEdit2.Enabled:=RoseDipAlso;
    end;
    ERR:
    begin
      MessageDlg('Invalid file extension!',mtError,[mbOk], 0);
      ModalResult := mrCancel;
      Close;
      Exit;
    end;
    else Checkbox1.Checked:=True;
  end;
end;

procedure TRoseDial.CheckBox1Click(Sender: TObject);
begin
  Label4.Enabled:=CheckBox1.Checked;
  Label5.Enabled:=CheckBox1.Checked;
  NumEdit2.Enabled:=CheckBox1.Checked;
end;

procedure TRoseDial.BitBtn1Click(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
