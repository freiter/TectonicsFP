unit Planelin;

interface

uses SysUtils, Windows, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls,ExtCtrls, Dialogs, Menus, Numedit, ClipBrd,math;

type
  TPlaneLinDialog = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    Label1: TLabel;
    Bevel2: TBevel;
    RadioGroup1: TRadioGroup;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Bevel1: TBevel;
    Bevel3: TBevel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Bevel4: TBevel;
    Bevel5: TBevel;
    Bevel6: TBevel;
    Bevel7: TBevel;
    NumEdit1: TNumEdit;
    NumEdit2: TNumEdit;
    NumEdit3: TNumEdit;
    NumEdit4: TNumEdit;
    CopyBtn: TBitBtn;
    PopupMenu1: TPopupMenu;
    Copy1: TMenuItem;
    procedure OKBtnClick(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CancelBtnClick(Sender: TObject);
    procedure CopyBtnClick(Sender: TObject);
  private
    PlaneL,FirstUse: Boolean;
  end;

 procedure FlaechLin(Azim1,Plunge1,Azim2,Plunge2:Single;
                    PlaneL:Boolean;
                    var NAzim,NPlunge: single);

var
  PlaneLinDialog: TPlaneLinDialog;



  implementation

{$R *.DFM}
uses TecMain, Types;


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


procedure TPlaneLinDialog.OKBtnClick(Sender: TObject);
var NewAzim,NewDip : Single;
begin
 If RadioGroup1.ItemIndex=0 then PlaneL:=True else PlaneL:=False;
 If (NumEdit1.Number=NumEdit3.Number) and (NumEdit2.Number=NumEdit4.Number) then
     begin
       MessageDlg('Two identical data sets. No valid solution!', mtError,[mbOk], 0);
       exit;
     end;
   If (NumEdit2.Number=0) and (NumEdit4.Number=0) then
     begin
       if PlaneL then
         MessageDlg('Solution is a horizontal plane!', mtCustom,[mbOk], 0)
       else
         MessageDlg('You entered two horizontal planes. No valid solution!', mtError,[mbOk], 0);
       exit;
     end;
   If (NumEdit2.Number=90) and (NumEdit4.Number=90) then
     begin
       if PlaneL then
         MessageDlg('You entered two vertical linears. No valid solution!', mtError,[mbOk], 0)
       else
         MessageDlg('Solution is a vertical linear!', mtCustom,[mbOk], 0);
      exit;
     end;
   FirstUse:=True;
   FlaechLin(NumEdit1.Number,NumEdit2.Number,NumEdit3.Number,NumEdit4.Number,
            PlaneL,NewAzim, NewDip);
  If Abs(NewAzim)>=100 then Label6.Caption := IntToStr(round(NewAzim))
    else If Abs(NewAzim)>=10 then Label6.Caption := '0'+IntToStr(round(NewAzim))
      else Label6.Caption := '00'+IntToStr(round(NewAzim));
  If Abs(NewDip)>=10 then Label7.Caption := IntToStr(round(NewDip))
  else Label7.Caption := '0'+IntToStr(round(NewDip));
  If Abs(round((NewAzim+180)) MOD 360)>=100 then Label8.Caption := IntToStr(round((NewAzim+180)) MOD 360)
    else If Abs(round((NewAzim+180)) MOD 360)>=10 then Label8.Caption := '0'+IntToStr(round((NewAzim+180)) MOD 360)
      else Label8.Caption := '00'+IntToStr(round((NewAzim+180)) MOD 360);
  If Abs(90- NewDip)>=10 then Label9.Caption := IntToStr(round(90- NewDip))
  else Label9.Caption := '0'+IntToStr(round(90- NewDip));
  CopyBtn.Enabled:=true;
  Copy1.Enabled:=true;
end;

procedure TPlaneLinDialog.RadioGroup1Click(Sender: TObject);
begin
If RadioGroup1.ItemIndex=1 then
  begin
    Label1.Enabled:=True;
    Label8.Visible:=True;
    Label9.Visible:=True;
    Label4.Caption:='Azimuth';
    Label5.Caption:='Dip';
    Label3.Caption:='Resulting lineation';
  end
  else
  begin
    Label1.Enabled:=False;
    Label8.Visible:=False;
    Label9.Visible:=False;
    Label4.Caption:='Bearing';
    Label5.Caption:='Plunge';
    Label3.Caption:='Resulting plane';
  end;
  If FirstUse then OKBtnClick(Sender);
end;

procedure TPlaneLinDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if MDIChildCount <= 1 then TecMainWin.Window1.Enabled := false;
  Action := caFree;
end;

procedure TPlaneLinDialog.CancelBtnClick(Sender: TObject);
begin
  release;
end;

procedure TPlaneLinDialog.CopyBtnClick(Sender: TObject);
begin
  Clipboard.AsText:=(Label6.Caption+FileListSeparator+Label7.Caption+#13+#10);
end;

end.
