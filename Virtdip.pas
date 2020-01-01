unit Virtdip;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Numedit, Buttons, Tabs, Menus, Clipbrd;

type
  TVirtDipFrm = class(TForm)
    TabSet1: TTabSet;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    Notebook1: TNotebook;
    Label03: TLabel;
    Label06: TLabel;
    Label07: TLabel;
    Label01: TLabel;
    Label02: TLabel;
    Bevel01: TBevel;
    Label05: TLabel;
    Label04: TLabel;
    NumEdit01: TNumEdit;
    NumEdit02: TNumEdit;
    NumEdit03: TNumEdit;
    Bevel3: TBevel;
    Bevel26: TBevel;
    Label21: TLabel;
    Bevel1: TBevel;
    Bevel25: TBevel;
    Bevel24: TBevel;
    Bevel27: TBevel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label29: TLabel;
    RadioGroup21: TRadioGroup;
    NumEdit21: TNumEdit;
    NumEdit22: TNumEdit;
    NumEdit23: TNumEdit;
    NumEdit24: TNumEdit;
    CopyBtn: TBitBtn;
    NumEdit11: TNumEdit;
    NumEdit12: TNumEdit;
    NumEdit13: TNumEdit;
    NumEdit14: TNumEdit;
    RadioGroup11: TRadioGroup;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    NumEdit15: TNumEdit;
    Label15: TLabel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    procedure BitBtn1Click(Sender: TObject);
    procedure TabSet1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BitBtn2Click(Sender: TObject);
    procedure Notebook1PageChanged(Sender: TObject);
    procedure RadioGroup21Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
  private
    { Private-Deklarationen }
    c : Single;
    Deviation, CrossSection: Integer;
  protected
    PlaneL,FirstUse: Boolean;
  end;

procedure FlaechLin(Azim1,Plunge1,Azim2,Plunge2:Single; PlaneL:Boolean;
                    var NAzim,NPlunge: single);

var
  VirtDipFrm: TVirtDipFrm;

implementation

uses Tecmain, Types, Math, draw;

{$R *.DFM}

procedure FlaechLin(Azim1,Plunge1,Azim2,Plunge2:Single;
                    PlaneL:Boolean;
                    var NAzim,NPlunge: single);
 var px,py,pz,pp,RAzim1,RAzim2,RPlunge1,RPlunge2: single;

 begin
   IF Azim1 > 360 THEN Azim1:= Round(Azim1) MOD 360;
   IF Azim2 > 360 THEN Azim2:= Round(Azim2) MOD 360;
   IF not PlaneL THEN
   begin
     Azim1:=Azim1+180;
     Azim2:=Azim2+180;
     Plunge1:=90-Plunge1;
     Plunge2:=90-Plunge2;
   end;
   RAzim1:=DegToRad(Azim1);
   RAzim2:=DegToRad(Azim2);
   RPlunge1:=DegToRad(Plunge1);
   RPlunge2:=DegToRad(Plunge2);
   PX := Sin(RAzim1)*  Cos(RPlunge1)*Sin(RPlunge2) -
         Sin(RPlunge1)*Sin(RAzim2)*  Cos(RPlunge2);
   PY := Sin(RPlunge1)*Cos(RAzim2)*  Cos(RPlunge2) -
         Cos(RAzim1)*  Cos(RPlunge1)*Sin(RPlunge2);
   PZ := Cos(RAzim1)*  Cos(RPlunge1)*Sin(RAzim2)*Cos(RPlunge2) -
         Sin(RAzim1)*  Cos(RPlunge1)*Cos(RAzim2)*Cos(RPlunge2);
   IF PZ < 0 THEN
     begin
       PX := -PX;
       PY := -PY;
       PZ := -PZ;
     end;
   try
     PP:= PZ/SQRt(Sqr(PX)+Sqr(PY)+Sqr(PZ));
     NPlunge:= ArcSin(PP);
   except
     On EZeroDivide do MessageDlg('Division by zero! Use 89 degrees instead of 90°.', mtError,[mbOk], 0);
   end;
   IF PX <> 0 THEN NAzim := ArcTan(PY/PX)
       else
        begin
         IF PY > 0 THEN NAzim := PI/2;
         IF PY < 0 THEN NAzim := 3*PI/2;
     end;
   NAzim:= RadToDeg(NAzim);
   NPlunge := RadToDeg(NPlunge);
   IF PX < 0 THEN NAzim := NAzim + 180;
   IF (PX > 0) AND (PY > 0) THEN NAzim := NAzim - 360;
   IF PlaneL THEN
   begin
     NAzim := NAzim + 180;
     NPlunge := 90 - NPlunge;
   end;
   IF NAzim > 360 THEN NAzim := NAzim - 360;
   IF NAzim < 0   THEN NAzim := NAzim + 360;
 END;

procedure TVirtDipFrm.BitBtn1Click(Sender: TObject);
var reverse: boolean;
    NewAzim,NewDip : Single;
begin
  Case NoteBook1.PageIndex of
  0: Begin  //apparent dip
  If Numedit03.Number <> 0 then
    begin
      If ABS(Numedit03.Number mod 90)=0 then Numedit03.Number:= 89;
      If Numedit01.Number > 180 then Numedit01.Number := Numedit01.Number mod 180;
      Deviation:=Abs (Numedit01.Number-NumEdit02.Number);
      If Deviation > 180 then Deviation := 360-Deviation;
      C:=Abs(180/Pi*ArcTan(Sin(Pi*NumEdit03.Number/180)/Cos(Pi*NumEdit03.Number/180)*Sin(Pi*(90-Deviation)/180)));
    end
  else C:=0;
  Label03.Caption:='Apparent Dip: '+IntToStr (Round(C))+'°';
  CrossSection:=Numedit01.Number mod 180;
  reverse:=Deviation > 90;
  If (CrossSection <= 11.25) or (CrossSection >= 168.75) then
    begin
      Label06.Caption := 'S';
      Label07.Caption := 'N';
    end
  else
      If CrossSection <= 33.75 then
        begin
          Label06.Caption := 'SSW';
          Label07.Caption := 'NNE';
        end
      else
        If CrossSection <= 56.25 then
          begin
            Label06.Caption := 'SW';
            Label07.Caption := 'NE';
          end
        else
          If CrossSection <= 78.75 then
            begin
              Label06.Caption := 'WSW';
              Label07.Caption := 'ENE';
            end
          else
            If CrossSection <= 101.25 then
              begin
                Label06.Caption := 'W';
                Label07.Caption := 'E';
              end
            else
              If CrossSection <= 123.75 then
                begin
                  Label06.Caption := 'WNW';
                  Label07.Caption := 'ESE';
                end
              else
                If CrossSection <= 146.25 then
                  begin
                    Label06.Caption := 'NW';
                    Label07.Caption := 'SE';
                  end
                else
                  begin
                    Label06.Caption := 'NNW';
                    Label07.Caption := 'SSE';
                  end;
  Image1.picture:=nil; //bugfix 990125
  If not reverse then
    With Image1.Canvas do
      begin
        Moveto (Image1.Width,0);
        LineTo (0,0);
        LineTo (0,Image1.Height);
        Moveto (Image1.Width,Round(Image1.Width*Sin(Pi/180*NumEdit03.Number)/Cos(Pi/180*NumEdit03.Number)));
        LineTo (0,0);
        Pen.Color:=clRed;
        LineTo (Image1.Width,Round(Image1.Width*Sin(Pi/180*C)/Cos(Pi/180*C)));
        Pen.Color:=clBlack;
      end
  else
    With Image1.Canvas do
      begin
        Moveto (0,0);
        LineTo (Image1.Width-1,0);
        LineTo (Image1.Width-1,Image1.Height);
        Moveto (0,Round((Image1.Width-1)*Sin(Pi/180*NumEdit03.Number)/Cos(Pi/180*NumEdit03.Number)));
        LineTo (Image1.Width,0);
        Pen.Color:=clRed;
        LineTo (0,Round((Image1.Width-1)*Sin(Pi/180*C)/Cos(Pi/180*C)));
        Pen.Color:=clBlack;
      end;
    If not reverse then
  end;
  1: begin //dihedral angle
     NumEdit15.Number:=Round(DihedralAngle(NumEdit11.Number, NumEdit12.Number,
       NumEdit13.Number, NumEdit14.Number, Radiogroup11.Itemindex=0));
  end;
  2: begin //plane from lineations
    If RadioGroup21.ItemIndex=0 then PlaneL:=True {Plane from lin} else PlaneL:=False; {lin from plane}
 If (NumEdit21.Number=NumEdit23.Number) and (NumEdit22.Number=NumEdit24.Number) then
     begin
       MessageDlg('Two identical data sets. No valid solution!', mtError,[mbOk], 0);
       exit;
     end;
   If (NumEdit22.Number=0) and (NumEdit24.Number=0) then
     begin
       if PlaneL then
         MessageDlg('Solution is a horizontal plane!', mtCustom,[mbOk], 0)
       else
         MessageDlg('You entered two horizontal planes. No valid solution!', mtError,[mbOk], 0);
       exit;
     end;
   If (NumEdit22.Number=90) and (NumEdit24.Number=90) then
     begin
       if PlaneL then
         MessageDlg('You entered two vertical lineations. No valid solution!', mtError,[mbOk], 0)
       else
         MessageDlg('Solution is a vertical lineation!', mtCustom,[mbOk], 0);
      exit;
     end;
   FirstUse:=True;
   FlaechLin(NumEdit21.Number,NumEdit22.Number,NumEdit23.Number,NumEdit24.Number,
            PlaneL,NewAzim, NewDip);
   If RadioGroup21.ItemIndex=2 then
     FlaechLin(NumEdit21.Number, NumEdit22.Number, Trunc(NewAzim+180) mod 360+ Frac (NewAzim), 90-NewDip,
            PlaneL,NewAzim, NewDip);
  If Abs(NewAzim)>=100 then Label26.Caption := IntToStr(round(NewAzim))
    else If Abs(NewAzim)>=10 then Label26.Caption := '0'+IntToStr(round(NewAzim))
      else Label26.Caption := '00'+IntToStr(round(NewAzim));
  If Abs(NewDip)>=10 then Label27.Caption := IntToStr(round(NewDip))
  else Label27.Caption := '0'+IntToStr(round(NewDip));
  If Abs(round((NewAzim+180)) MOD 360)>=100 then Label28.Caption := IntToStr(round((NewAzim+180)) MOD 360)
    else If Abs(round((NewAzim+180)) MOD 360)>=10 then Label28.Caption := '0'+IntToStr(round((NewAzim+180)) MOD 360)
      else Label28.Caption := '00'+IntToStr(round((NewAzim+180)) MOD 360);
  If Abs(90- NewDip)>=10 then Label29.Caption := IntToStr(round(90- NewDip))
  else Label29.Caption := '0'+IntToStr(round(90- NewDip));
  CopyBtn.Enabled:=true;
  end;
  end;
end;

procedure TVirtDipFrm.TabSet1Click(Sender: TObject);
begin
  Notebook1.PageIndex := TabSet1.TabIndex;
end;

procedure TVirtDipFrm.FormCreate(Sender: TObject);
begin
  Notebook1.PageIndex := TabSet1.TabIndex;
  Notebook1PageChanged(Sender);
end;

procedure TVirtDipFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action:=caFree;
  VirtDipFrm:=nil;
  if MDIChildCount <= 1 then TecMainWin.Window1.Enabled := false;
end;

procedure TVirtDipFrm.BitBtn2Click(Sender: TObject);
begin
  Close;
end;

procedure TVirtDipFrm.Notebook1PageChanged(Sender: TObject);
begin
  If Notebook1.Pageindex=0 then Image1.Repaint;
  Tabset1.Tabindex:=notebook1.pageindex;
  Case NoteBook1.PageIndex of
    0:  //apparent dip
    begin
      BitBtn1.HelpContext:=490;
      BitBtn2.HelpContext:=490;
      CopyBtn.HelpContext:=491;
    end;
    1: //dihedral angle
    begin
      BitBtn1.HelpContext:=485;
      BitBtn2.HelpContext:=485;
      CopyBtn.HelpContext:=486;
    end;
    2: //plane from lineations
    begin
      BitBtn1.HelpContext:=480;
      BitBtn2.HelpContext:=480;
      CopyBtn.HelpContext:=481;
    end;
  end;
end;

procedure TVirtDipFrm.RadioGroup21Click(Sender: TObject);
var dummy: Integer;
begin
  dummy:=0;
  if sender is TRadiogroup then dummy:=(Sender as TRadioGroup).ItemIndex;
  Case Dummy of
  0: begin
    Label1.Visible:=False;
    Label2.Visible:=False;
    Label21.Enabled:=False;
    Label28.Visible:=False;
    Label29.Visible:=False;
    Label24.Caption:='Bearing';
    Label25.Caption:='Plunge';
    Label23.Caption:='Resulting plane';
  end;
  1:
  begin
    Label1.Visible:=False;
    Label2.Visible:=False;
    Label21.Enabled:=True;
    Label28.Visible:=True;
    Label29.Visible:=True;
    Label24.Caption:='Dip dir.';
    Label25.Caption:='Dip';
    Label23.Caption:='Resulting lineation';
  end;
  2:
  begin
    Label1.Visible:=True;
    Label2.Visible:=True;
    Label21.Enabled:=False;
    Label28.Visible:=False;
    Label29.Visible:=False;
    Label24.Caption:='Dip dir.';
    Label25.Caption:='Dip';
    Label23.Caption:='Fault slip lineation';
  end;
  end;
  Label13.Caption:=Label24.Caption;
  Label14.Caption:=Label25.Caption;
  If FirstUse then BitBtn1Click(Sender);
end;

procedure TVirtDipFrm.Copy1Click(Sender: TObject);
begin
  Clipboard.AsText:=Label26.Caption+#9+Label27.Caption+#$D+#$A;
end;

procedure TVirtDipFrm.BitBtn3Click(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
