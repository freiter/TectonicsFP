unit rotate;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,Forms, Dialogs,
  StdCtrls, Numedit, Buttons, ExtCtrls, Spin, ComCtrls, Types, Draw, LowHem, math;

type
  TRotForm = class(TLHWin)
    Bevel1: TBevel;
    WriteTfileBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Label11: TLabel;
    NumEdit2: TNumEdit;
    NumEdit3: TNumEdit;
    SaveDialog1: TSaveDialog;
    Label2: TLabel;
    Label3: TLabel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    SpinEdit1: TSpinEdit;
    Label4: TLabel;
    PaintBox2: TPaintBox;
    ApplyBtn: TButton;
    CheckBox1: TCheckBox;
    procedure FormResize(Sender : TObject); override;
    procedure Open(const AFilename: string; const AExtension: TExtension);
    procedure Draw(var PaintB: TPaintBox);
    procedure PaintBox1Paint(Sender: TObject);override;
    procedure PaintBox2Paint(Sender: TObject);
    procedure WriteTfileBtnClick(Sender: TObject);
    procedure ApplyBtnClick(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure Angelier1Click(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure NumEdit2Change(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure SpinEdit1Click(Sender: TObject);
  private
    rotated, calculated, planeflg,A1, A2: boolean;
    RotAxPlunge,rotangle: integer;
    RotAxAzim : single;
    Sense, DextrRotAng, Quality, DipDir, Dip, Azimuth, Plunge: Variant;
    PSense, PQuality: PZeroIntArray;
    PDipDir, PDip, PAzimuth, PPlunge, PRotDipDir,PRotDip,PRotAzim,PRotPlunge: PZeroSingleArray;
    RotSense, RotDipDir,RotDip,RotAzim,RotPlunge: Variant;
    PRotSense: PZeroIntArray;
    procedure WMGetMinMaxInfo(var MSG: Tmessage); message WM_GetMinMaxInfo;
  end;
  procedure Rot(planeflg: boolean; DextrRotAng, RotAxAzim, RotAxPlunge,
                DipDirX, DipX: Single; var RotatedAzimuth, RotatedPlunge: Single;
                var FSenseChanged: boolean);

//var rotform : TRotform;

implementation
{$R *.DFM}

uses Fileops, Tecmain, Inspect, rotate;


procedure TRotForm.WMGetMinMaxInfo(var MSG: Tmessage);
Begin
  inherited;
  with PMinMaxInfo(MSG.lparam)^ do
  begin
    with ptMinTrackSize do
    begin
      X:= MDIMinWidth-20;
      Y:= MDIMinHeight-40;
    end;
    {with ptMaxTrackSize do
    begin
      X := 1000;
      Y := 750;
    end; }
  end;
end;

procedure Rot(planeflg: boolean; DextrRotAng, RotAxAzim, RotAxPlunge,
              DipDirX,DipX: Single; var RotatedAzimuth, RotatedPlunge: Single;
              var FSenseChanged: boolean);
var
 NA: Array[1..3,1..3] of single;
 DegRotRhra,DegRotAzi,DegRotPlun, RDipDir: single;
 AM, FM, ATA, FI, E1, E2, E3, TA: single;
 A, B, C: array [1..2] of single;
 I,J,Z: Integer;
 x,y: array [1..3] of single;

begin
  IF DextrRotAng<0 THEN DextrRotAng:= DextrRotAng+360;
  DegRotRhra := DegToRad(DextrRotAng);
  DegRotAzi :=  DegToRad(RotAxAzim);
  DegRotPlun := DegToRad(RotAxPlunge);
  IF DextrRotAng>180 THEN
  begin
    A[1]:= -1;
    B[1]:= 2;
    c[1]:= 0;
    A[2]:= COS(DegRotRhra-PI);
    B[2]:= 1-A[2];
    c[2]:= SIN(DegRotRhra-PI);
    Z:= 2;
  end
  else
  begin
    A[1]:= COS(DegRotRhra);
    B[1]:= 1-A[1];
    c[1]:= SIN(DegRotRhra);
    Z:= 1;
  end;
  IF planeflg THEN
  begin
    DipX:= 90-DipX;
    DipDirX:= trunc(DipDirX+180) MOD 360+ frac(DipDirX);
  end;
  IF (DipDirX=90) OR (DipDirX=180) OR (DipDirX=270) THEN RDipDir:= DipDirX+0.05 else RDipDir:= DipDirX;   // RDipDir : Single
  AM:= DegToRad(RDipDir);
  FM:= DegToRad(DipX);
  FOR J:= 1 TO Z do //---Rotation-algorithm
  begin
    IF J=2 THEN
    begin
      AM:= ATA;
      FM:= FI;
    end;
    E1:= COS(DegRotAzi)*COS(DegRotPlun);  // VectorData
    E2:= SIN(DegRotAzi)*COS(DegRotPlun);
    E3:= SIN(DegRotPlun);
    NA[1,1]:= A[J]+B[J]*E1*E1;
    NA[1,2]:= B[J]*E1*E2-c[J]*E3;
    NA[1,3]:= B[J]*E1*E3+c[J]*E2;
    NA[2,1]:= B[J]*E1*E2+c[J]*E3;
    NA[2,2]:= A[J]+B[J]*E2*E2;
    NA[2,3]:= B[J]*E2*E3-c[J]*E1;
    NA[3,1]:= B[J]*E1*E3-c[J]*E2;
    NA[3,2]:= B[J]*E2*E3+c[J]*E1;
    NA[3,3]:= A[J]+B[J]*E3*E3;
    x[1]:= COS(AM)*COS(FM);
    x[2]:= COS(FM)*SIN(AM);
    x[3]:= SIN(FM);
    FOR I:= 1 TO 3 do y[I]:= NA[I,1]*x[1]+NA[I,2]*x[2]+NA[I,3]*x[3];
    IF (y[1]=0) AND (y[2]<0) THEN TA:= 3*pi/2; //Ta never used ?????????????
    IF (y[1]=0) AND (y[2]>0) THEN TA:= pi/2;
    IF (y[3]<0) THEN
    begin
      case j of
        1: FSenseChanged:=true;
        2: FSenseChanged:=not FSenseChanged;
      end;
      y[1]:= -y[1];
      y[2]:= -y[2];
      y[3]:= -y[3];
    end else
      if j=1 then FSenseChanged:=false;
    IF y[1]<>0 THEN ATA:= ArcTan(y[2]/y[1]);
    IF y[1]<=0 THEN ATA:= ATA+PI;
    IF (y[1]>0) AND (y[2]<0) THEN ATA:= ATA+2*PI;
    IF (y[1]=0) AND (y[2]>0) THEN ATA:= PI/2;
    IF y[3]>0.9999 THEN FI:= PI/2 else FI:= ArcTan(y[3]/SQRt(1-y[3]*y[3]));
  end;
  RotatedAzimuth:= Trunc(RadToDeg(ATA)) mod 360+ Frac(RadToDeg(ATA));
  RotatedPlunge:= RadToDeg(FI);
  IF planeflg THEN
  begin
    RotatedAzimuth:= Trunc(RotatedAzimuth+180) MOD 360+Frac(RotatedAzimuth+180);
    RotatedPlunge:= 90 - RotatedPlunge;
  end;
  If Round(RotatedPlunge)=0 then     //Bugfix 20000128 build 1.150
    If Abs(Frac(RotatedPlunge))<0.01 then
      If RotatedPlunge=0 then RotatedPlunge:=0.01
      else RotatedPlunge:=Sgn(RotatedPlunge)*0.01;
end;



procedure TRotForm.FormResize(Sender : TObject);
const botalign = 30;
begin
  {Initialize form}
  Paintbox1.Left:= 0;
  Paintbox1.Top:= 0;
  Paintbox1.Height:= 2*ClientHeight div 3;
  Paintbox1.Width:= ClientWidth div 2;
  bevel2.Left:= 0;
  bevel2.Top:= 0;
  bevel2.Height:= 2*ClientHeight div 3;
  bevel2.Width:= ClientWidth div 2;
  Paintbox2.Left:= ClientWidth div 2;
  Paintbox2.Top:= 0;
  Paintbox2.Height:= 2*ClientHeight div 3;
  Paintbox2.Width:= ClientWidth div 2;
  bevel3.Left:= ClientWidth div 2;
  bevel3.Top:= 0;
  bevel3.Height:= 2*ClientHeight div 3;
  bevel3.Width:= ClientWidth div 2;
  Bevel1.Top:= ClientHeight-ClientHeight div 3;
  Bevel1.Left:= 0;
  Bevel1.Height:= ClientHeight div 3;
  Bevel1.Width:= ClientWidth;
  Label2.Top:= 2*ClientHeight div 3+botalign;
  Label2.Left:= Bevel1.Left+botalign;
  Label3.Top:= 2*ClientHeight div 3+botalign;
  Label3.Left:= Label2.Left+label2.Width+botalign;
  Label4.Top:= 2*ClientHeight div 3+botalign-20;
  Label4.Left:= Bevel1.Left+botalign;
  Label11.Top:=  2*ClientHeight div 3+botalign;
  Label11.Left:= Label3.Left+Label3.width+botalign;
  NumEdit2.Top:= Label11.Top+40;
  NumEdit2.Left:= Label2.Left;
  NumEdit3.Top:= Label11.Top+40;
  NumEdit3.Left:= Label3.Left;
  SpinEdit1.Top:= Label11.Top+40;
  SpinEdit1.Left:=Label11.Left;
  Checkbox1.Left:=SpinEdit1.Left;
  Checkbox1.Top:=SpinEdit1.Top-60;
  ApplyBtn.Top:= Label11.Top+40;
  ApplyBtn.Left:= SpinEdit1.Left+SpinEdit1.width+10;
  WriteTfileBtn.Top:= 2*ClientHeight div 3+botalign;
  WriteTfileBtn.Left:= ClientWidth-WriteTfileBtn.Width-botalign;
  CancelBtn.Top:= WriteTfileBtn.Top+40;
  CancelBtn.Left := WriteTfileBtn.Left;
end;


procedure TRotForm.Draw(var PaintB: TPaintBox);
var k, CenterPX, CenterPY,
    CircleRad : Integer;
    DipD, DipDirD: Single;
begin
  With PaintB do
  begin
    CenterPX := Width div 2;
    CenterPY := Height div 2;
    CircleRad := (2*Height) div 5;
    ArrowHeadLength:=Round(CircleRad*LinearCircleRate);{=Radius*LinearCircleRate}
    ArrowLength1:=CircleRad*LengthRate1;        {=Radius*LengthRate1}
    ArrowLength2:=CircleRad*LengthRate2;
    {With Canvas do
    begin
      Brush.Style := bsClear;
      Pen.Width := 1;
      Pen.Style := psSolid;
    end;}
  end;    
  if calculated then
  begin
    SetBkMode(PaintB.Canvas.Handle, TRANSPARENT);
    NorthAndCircle(PaintB.Canvas, CenterPX, CenterPY, CircleRad);
    Case LHExtension of
      COR, FPL, PEF, PEK, HOE, STF:
      begin
        if Angelier1.checked then    //Angelier Plot
        begin
          for k := 0 to LHz-1 do
          begin
            if rotated then
            begin
              GreatCircle(PaintB.Canvas.Handle,PaintB.Canvas,CenterPX,CenterPY,CircleRad,PRotDipDir^[k], PRotDip^[k], k, true, LHPen.Handle, LHLogPen);
              Striae(PaintB.Canvas.Handle,PaintB.Canvas,CenterPX,CenterPY,CircleRad,PRotDipDir^[k], PRotDip^[k],PRotAzim^[k],PRotPlunge^[k],LHSymbSize,
                      PRotSense^[k],PQuality^[k],k, true, QualityGlobal, LHSymbFillFlag,
                      LHExtension, LHPen, LHPenBrush, LHFillBrush);
            end
            else
            begin
              GreatCircle(PaintB.Canvas.Handle,PaintB.Canvas,CenterPX,CenterPY,CircleRad,PDipDir^[k], PDip^[k], k, true, LHPen.Handle, LHLogPen);
              Striae(PaintB.Canvas.Handle,PaintB.Canvas,CenterPX,CenterPY,CircleRad,PDipDir^[k], PDip^[k],PAzimuth^[k],PPlunge^[k],LHSymbSize,
                      PSense^[k],PQuality^[k],k, true, QualityGlobal, LHSymbFillFlag,
                      LHExtension, LHPen, LHPenBrush, LHFillBrush);
            end;
          end; {end FOR}
        end
        else  {end IF opt1}
        begin  {Hoeppener}
          for k := 0 to LHz-1 do
          begin
            If rotated then
              HoepSymbol2(Paintb.Canvas.Handle,Paintb.Canvas,CenterPX,CenterPY,CircleRad,PRotSense^[k],PQuality^[k],
                          PRotDipDir^[k],PRotDip^[k],PRotAzim^[k],PRotPlunge^[k],LHSymbSize,k,true,QualityGlobal,
                          LHSymbFillFlag,LHPen, LHPenBrush, LHFillBrush)
            else
              HoepSymbol2(Paintb.Canvas.Handle,Paintb.Canvas,CenterPX,CenterPY,CircleRad,PSense^[k],PQuality^[k],
                          PDipDir^[k],PDip^[k],PAzimuth^[k],PPlunge^[k],LHSymbSize,k,true,QualityGlobal,
                          LHSymbFillFlag,LHPen, LHPenBrush, LHFillBrush);
          end; {end FOR}
        end; {end ELSE}
      end; {end Case cor,fpl}
      PLN, LIN:
      begin
        if (LHExtension=PLN) and Angelier1.Checked then
        begin   //great circles
          for k := 0 to LHz-1 do
          begin
            if rotated then
              GreatCircle(PaintB.Canvas.Handle,PaintB.Canvas,CenterPX,CenterPY,CircleRad,PRotDipDir^[k], PRotDip^[k], k, true, LHPen.Handle, LHLogPen)
            else
              GreatCircle(PaintB.Canvas.Handle,PaintB.Canvas,CenterPX,CenterPY,CircleRad,PDipDir^[k], PDip^[k], k, true, LHPen.Handle, LHLogPen);
          end; {end FOR}
        end {end IF}
        else
        begin
          for k := 0 to LHz-1 do
          begin
            if rotated then
            begin
              If (LHExtension=pln) and (Hoeppener1.Checked) then
              begin
                DipDirD:=trunc(PRotDipDir^[k]+180) mod 360+ frac(PRotDipDir^[k]);  //Pi-Plot
                DipD:=90-PRotDip^[k];
              end
              else
              begin
                DipDirD:=PRotDipDir^[k]; //dip lines and lineations
                DipD:=PRotDip^[k];
              end
            end
            else
            begin
              If (LHExtension=pln) and (Hoeppener1.Checked) then
              begin  //Pi-Plot
                DipDirD:=trunc(PDipDir^[k]+180) mod 360+ frac(PDipDir^[k]);
                DipD:=90-PDip^[k];
              end
              else
              begin //dip lines and lineations
                DipDirD:=PDipDir^[k];
                DipD:=PDip^[k];
              end;
            end;
            If not Checkbox1.checked then Lineation(PaintB.Canvas.Handle,PaintB.Canvas,CenterPX,CenterPY,CircleRad,DipDirD,DipD,LHSymbSize,k,true,LHSymbFillFlag,LHSymbType, LHFillBrush, LHPen.Handle);
          end; {end For}
        end;{end else}
      end;
    end; {end case}
  end; {Draw enveloping circle}
  if rotated then
  begin
    lhpen.Color := clRed;
    If not CheckBox1.Checked then  Lineation(Paintb.Canvas.Handle,Paintb.Canvas,CenterPX,CenterPY,CircleRad,NumEdit2.number,Numedit3.number,LHSymbSize,0,false,LHSymbFillFlag,systar, LHFillBrush, LHPen.Handle);
    LHPen.color:=clblack;
  end;
end;


procedure TRotForm.Open(const AFilename: string; const AExtension: TExtension);
 var F :TextFile;
    NoComment: boolean;
    HighBound, myidummy : Integer;
    Comment: String;
    mysdummy: Single;

begin
  LHPlotType:=pt_Rotate;
  LHFilename := AFilename;
  LHExtension:=AExtension;
  Label11.Caption:='right-handed'+#10#13+'rotation angle:';
  Paintbox1.align:=alNone;
  Paintbox1.bringtofront;
  Paintbox1.Popupmenu:=TecMainwin.Popupmenu1;
  PaintBox1.Hint:='Original data| ';
  Paintbox1.ShowHint:=true;
  PaintBox1.Tag:=710;
  FormResize(Nil);
  Edit1.Enabled:=false;
  Plottype1.Enabled:=True;
  PlotType2.Enabled:=True;
  Label1.visible:=false;
  Fonts1.visible:=false;
  ChangeLabel1.visible := false;
  Export1.Enabled:=false;
  Print1.Enabled:=false;
  Number1.visible:=false;
  Copy1.Enabled:=false;
  Angelier1.OnClick:=Angelier1Click;
  Hoeppener1.OnClick:=Angelier1Click;
  ptAxes1.OnClick:=Angelier1Click;
  LHPoleflag:=false;
  case LHExtension of
    COR,FPL,PEF,PEK,HOE,STF:
    begin
      If RotFPLPlotType=1 then Hoeppener1.Checked:=true;
      ptAxes1.Enabled:=False;
    end;
    PLN:
    begin
      ptAxes1.Enabled:=True;
      Case RotPLNPlotType of //last plot type for sorting stored in registry
        1: Hoeppener1.Checked:=true;
        2: ptAxes1.Checked:=true;
      end;
      Angelier1.Caption:='Great Circles';
      Hoeppener1.Caption:='Pi-plot';
      PTAxes1.Caption:='Dip Lines';
    end;
    LIN:
    begin
      PlotType1.Enabled:=false;
      PlotType2.Enabled:=false;
    end;
    {PTF:
    begin
      Angelier1.Checked:=false;
      ptaxes1.checked:=true;
      ptaxes1.OnClick:=Angelier1Click;
    end;}
  end;
  SetLHProperties(LHPlotType);
  If Inspectorform<>nil then InspectorForm.Initialize(Self);
  Spinedit1.value:=LastRotAngle;
  Numedit2.number:=LastRotAxAzim;
  Numedit3.number:=LastRotAxPlunge;
  LHOnceClick := false;
  TecmainWin.ArrangeMenu(Nil);
  {Retrieve data}
  calculated := false;
  LHfailed:=false;
  try
    LHLocationInfo:=GetLocInfo(LHFilename);
    //********************   Count data first
    AssignFile(F, LHFilename);
    Reset(F);
    case LHExtension of
      COR, FPL, PEF, PEK, HOE, STF:
      begin
        if not eof(f) then
        begin
          LHz := 0; // counter
          while not Eof(F) and not LHfailed do
          begin
            ReadFPLDataset(f, myidummy, myidummy, mysdummy, mysdummy, mysdummy, mysdummy, LHfailed, NoComment, LHExtension, comment);
            if not LHfailed and NoComment then inc(LHz);
          end; {end of While loop}
        end else LHfailed:=true; {if not eof}
      end; {end of case1}
      LIN, PLN :
      begin
        if not Eof(F) then
        begin
          LHz := 0;
          while not Eof(F) and not LHfailed do
          begin
            ReadPLNDataset(F, mysdummy, mysdummy, LHFailed, Nocomment, comment);
            If not LHfailed and Nocomment then inc(LHz);
          end; {end of while loop}
        end else LHfailed:=true;
      end; {end of case2}
    else  //undefined file type
    begin
      LHfailed:=true;
      LHz:=3412;
    end;
    end; {end of case}
    CloseFile(F);
    //********************
    AssignFile(F, LHFilename);
    Reset(F);
    case LHExtension of
      COR, FPL, PEF, PEK, HOE, STF:
      begin
        if not eof(f) then
        begin
          HighBound:=lhz;
          Sense:=VarArrayCreate([0,HighBound], varInteger);
          Quality:=VarArrayCreate([0,HighBound], varInteger);
          DipDir:=VarArrayCreate([0,HighBound], varSingle);
          Dip:=VarArrayCreate([0,HighBound], varSingle);
          Azimuth:=VarArrayCreate([0,HighBound], varSingle);
          Plunge:=VarArrayCreate([0,HighBound], varSingle);
          PSense:=VarArrayLock(Sense);
          PQuality:=VarArrayLock(Quality);
          PDipDir:=VarArrayLock(DipDir);
          PDip:=VarArrayLock(Dip);
          PAzimuth:=VarArrayLock(Azimuth);
          PPlunge:=VarArrayLock(Plunge);
          LHz := 0; // counter
          while not Eof(F) and not LHfailed do
          begin
            ReadFPLDataset(f, PSense^[LHz], PQuality^[LHz], PDipDir^[LHz], PDip^[LHz], PAzimuth^[LHz], PPlunge^[LHz], LHfailed, NoComment, LHExtension, comment);
            if not LHfailed and NoComment then inc(LHz);
          end; {end of While loop}
        end else LHfailed:=true; {if not eof}
      end; {end of case1}
      LIN, PLN :
      begin
        if not Eof(F) then
        begin
          HighBound:=lhz;
          LHz := 0;
          DipDir:=VarArrayCreate([0,HighBound], varSingle);
          Dip:=VarArrayCreate([0,HighBound], varSingle);
          PDipDir:=VarArrayLock(DipDir);
          PDip:=VarArrayLock(Dip);
          while not Eof(F) and not LHfailed do
          begin
            ReadPLNDataset(F, PDipDir^[LHz], PDip^[LHz], LHFailed, Nocomment, comment);
            If not LHfailed and Nocomment then inc(LHz);
          end; {end of while loop}
        end else LHfailed:=true;
      end; {end of case2}
    else  //undefined file type
    begin
      LHfailed:=true;
      LHz:=3412;
    end;
    end; {end of case}
    CloseFile(F);
  except   {can not open file}
    On EInOutError do
    begin
      GlobalFailed:=True;
      Screen.Cursor:=crDefault;
      MessageDlg('Can not open '+LHFilename+' !'#10#13+
                 'Processing stopped. File might be in use by another application.',
                 mtError,[mbOk], 0);
      Close;
      exit;
    end;
  end;
  if not LHfailed then
  begin
    rotated := false;
    Globalfailed := false;
    case LHExtension of
      cor,fpl,pef,pek,hoe,stf:
      begin
        RotSense:=VarArrayCreate([0,LHz], varInteger);
        RotDipDir:=VarArrayCreate([0,LHz], varSingle);
        RotDip:=VarArrayCreate([0,LHz], varSingle);
        RotAzim:=VarArrayCreate([0,LHz], varSingle);
        RotPlunge:=VarArrayCreate([0,LHz], varSingle);
        PRotSense:=VarArrayLock(RotSense);
        PRotDipDir:=VarArrayLock(RotDipDir);
        PRotDip:=VarArrayLock(RotDip);
        PRotAzim:=VarArrayLock(RotAzim);
        PRotPlunge:=VarArrayLock(RotPlunge);
      end;
      pln,lin:
      begin
        RotDipDir:=VarArrayCreate([0,LHz], varSingle);
        RotDip:=VarArrayCreate([0,LHz], varSingle);
        PRotDipDir:=VarArrayLock(RotDipDir);
        PRotDip:=VarArrayLock(RotDip);
      end;
    end; {case}
    Screen.Cursor := CrDefault;
  end  {if}
  else
  begin
    GlobalFailed:=True;
    case LHz of
      3412: CommonError(Self,LHFilename,ecUndefFile);
    else
      ReadError(Self,LHFilename,LHz);
    end;
    close;
    exit;
  end;
end;   {sub}

procedure TRotForm.WriteTfileBtnClick(Sender: TObject);
var Exitflag, Saveflag : boolean;
    G: Textfile;
    i: integer;
    AFilename : String;
    ARotangle : Integer;
begin
  If Rotangle<0 then
    Repeat
      ARotangle:=360+Rotangle;
    until ARotangle>=0
  else ARotangle:=Rotangle;
  AFilename:=ChangeFileExt(ExtractFilename(LHFilename),'');
  SaveDialog1.Filename:=Afilename+'R'+IntToStr(arotangle)+ExtractFileExt(LHFilename);
  Case LHExtension of
    cor: Savedialog1.Filterindex:=1;
    fpl: Savedialog1.Filterindex:=2;
    pln: Savedialog1.Filterindex:=3;
    lin: Savedialog1.Filterindex:=4;
    pef: SaveDialog1.FilterIndex:=1;
    pek: Savedialog1.Filterindex:=2;
    hoe: SaveDialog1.FilterIndex:=1;
    stf: SaveDialog1.FilterIndex:=2;
   else Savedialog1.Filterindex:=7;
  end;
  Repeat
    Exitflag:=true;
    SaveFlag:= SaveDialog1.Execute;
    If SaveFlag then
    begin
      If FileExists(SaveDialog1.FileName) then
      begin
        MessageBeep(MB_ICONQUESTION);  //added 20000425
        Case MessageDlg(SaveDialog1.FileName+#10#13+
             'already exists! Overwrite?', mtWarning,[mbYes,mbRetry,mbCancel], 0) of
          mrCancel:
          begin
            Saveflag:=false;
            exit;
          end;
          mrYes: ExitFlag:=True;
          mrRetry: ExitFlag:=False;
        end;
      end;
    end;
  until exitflag;
  If Saveflag then
  begin
    Screen.Cursor := crHourGlass;
    If LocInfoToFile(SaveDialog1.Filename, LHLocationInfo) then
    begin
      AssignFile(G, SaveDialog1.Filename);
      Append(G);
    end
    else
    begin
      AssignFile(G, SaveDialog1.Filename);
      Rewrite(G);
    end;
    case LHExtension of
      COR, FPL, PEF, PEK, HOE, STF:
      begin
        For i:=0 to LHz-1 do
        begin
          write(G,CombineSenseQuality(PRotSense^[i],PQuality^[i]),FileListSeparator,FloatToString(PRotDipDir^[i],3,2),
                FileListSeparator,FloatToString(PRotDip^[i],2,2),FileListSeparator,
                FloatToString(PRotAzim^[i],3,2),FileListSeparator,FloatToString(PRotPlunge^[i],2,2));
          if i<LHz-1 then writeln(G);
        end;
      end;
      LIN, PLN:
      begin
        For i:=0 to LHz-1 do
          begin
            write(G,FloatToString(PRotDipDir^[i],3,2),FileListSeparator,FloatToString(PRotDip^[i],2,2));
            if i<LHz-1 then writeln(G);
          end;
        end;
    end; {end Case}
    CloseFile(G);
    GlobalFailed:=false;
    WriteTfileBtn.Enabled:=false;
    Screen.Cursor := CrDefault;
    TecMainWin.WriteToStatusbar(nil ,'Written to file '+SaveDialog1.Filename);
  end;
end;

procedure TRotForm.PaintBox1Paint(Sender: TObject);
var store, store2:boolean;
begin
  store2 := calculated;
  store := rotated;
  rotated := false;
  calculated := true;
  Draw(PaintBox1);
  rotated := store;
  calculated := store2;
end;

procedure TRotForm.PaintBox2Paint(Sender: TObject);
begin
  Draw(PaintBox2);
end;

procedure TRotForm.ApplyBtnClick(Sender: TObject);
var i: integer;
    PlaneSenseChanged, LineationSenseChanged: boolean;
begin
  Screen.Cursor := crHourGlass;
  rotangle:=SpinEdit1.Value mod 360;
  if (rotangle=0) and not checkbox1.checked then
    begin
      case LHExtension of
        cor,fpl,pef,pek,hoe,stf:
            For i:=0 to LHz-1 do
            begin
              PRotSense^[i]:=PSense^[i];
              PRotDipDir^[i]:=PDipDir^[i];
              PRotDip^[i]:=PDip^[i];
              PRotAzim^[i]:=PAzimuth^[i];
              PRotPlunge^[i]:=PPlunge^[i];
            end;
          pln, lin: For i:=0 to LHz-1 do
        begin
          PRotDipDir^[i]:=PDipDir^[i];
          PRotDip^[i]:=PDip^[i];
        end;
      end;
    WriteTfileBtn.Enabled := false;
    PaintBox2.refresh;
    end
  else
    begin
      If not Checkbox1.checked then
      begin
        SpinEdit1.Value:=SpinEdit1.Value mod 360;
        RotAxAzim := NumEdit2.Number mod 360;
        If Numedit3.Number<=90 then RotAxPlunge := NumEdit3.Number
        else RotAxPlunge := NumEdit3.Number mod 90;
        DextrRotAng := rotangle;
        case LHExtension of
        COR, FPL, PEF, PEK, HOE, STF:
         begin
           For i:=0 to LHz-1 do
             begin
               planeflg := true;
               Rot(planeflg,DextrRotAng,RotAxAzim,RotAxPlunge,
                   PDipDir^[i],PDip^[i],PRotDipDir^[i],PRotDip^[i], PlaneSenseChanged);
                planeflg := false;
                Rot(planeflg,DextrRotAng,RotAxAzim,RotAxPlunge,PAzimuth^[i],PPlunge^[i],
                    PRotAzim^[i],PRotPlunge^[i], LineationSenseChanged);
                PRotSense^[i]:=PSense[i];
                SnDxToUpDn(PRotSense^[i],PDipDir^[i],PDip^[i], PAzimuth^[i],PPlunge^[i]);
                If PlaneSenseChanged xor LineationSenseChanged then
                  Case PRotSense^[i] of
                    1: PRotSense^[i]:=se_normal;
                    2: PRotSense^[i]:=se_reverse;
                  end;
                CorrectSense(PRotSense^[i],PRotDipDir^[i],PRotDip^[i], PRotAzim^[i],PRotPlunge^[i]);
             end; {end of for-loop}
         end; {end Case}
        LIN, PLN :
         begin
           if LHExtension = LIN then planeflg := false else planeflg := true;
           For i:=0 to LHz-1 do
             Rot(planeflg,DextrRotAng,RotAxAzim,RotAxPlunge,PDipDir^[i],PDip^[i],
                 PRotDipDir^[i],PRotDip^[i], LineationSenseChanged);
         end;
        end; {end CASE}
      end
      else
      begin
        case LHExtension of
        COR, FPL, PEF, PEK, HOE, STF:
          begin
            For i:=0 to LHz-1 do
            begin
              RotAxAzim:=trunc(PDipDir^[i]+90) MOD 360+ frac(PDipDir^[i]+90);
              RotAxPlunge:=0;
              DextrRotAng:=PDip^[i];
              planeflg := true;
              Rot(planeflg,DextrRotAng,RotAxAzim,RotAxPlunge,
                   PDipDir^[i],PDip^[i],PRotDipDir^[i],PRotDip^[i], PlaneSenseChanged);
              planeflg := false;
              Rot(planeflg,DextrRotAng,RotAxAzim,RotAxPlunge,PAzimuth^[i],PPlunge^[i],
                  PRotAzim^[i],PRotPlunge^[i], LineationSenseChanged);
              PRotSense^[i]:=PSense[i];
              SnDxToUpDn(PRotSense^[i],PDipDir^[i],PDip^[i], PAzimuth^[i],PPlunge^[i]);
              If PlaneSenseChanged xor LineationSenseChanged then
                Case PRotSense^[i] of
                  1: PRotSense^[i]:=se_normal;
                  2: PRotSense^[i]:=se_reverse;
                end;
              CorrectSense(PRotSense^[i],PRotDipDir^[i],PRotDip^[i], PRotAzim^[i],PRotPlunge^[i]);
             end; {end of for-loop}
         end; {end Case 1}
        LIN, PLN :
        begin
          if LHExtension = LIN then planeflg := false else planeflg := true;
          For i:=0 to LHz-1 do
          begin
            RotAxAzim:=trunc(PDipDir^[i]+90) MOD 360+ frac(PDipDir^[i]+90);
            RotAxPlunge:=0;
            DextrRotAng:=PDip^[i];
            Rot(planeflg,DextrRotAng,RotAxAzim,RotAxPlunge,PDipDir^[i],PDip^[i],
                PRotDipDir^[i],PRotDip^[i], LineationSenseChanged);
          end;
        end;
        end; {end CASE}
      end;
    calculated := true;
    rotated := true;
    WriteTfileBtn.Enabled := true;
    WriteTFileBtn.SetFocus;
    PaintBox2.refresh;
    end; {end else}
    ApplyBtn.Enabled:=false;
    LastRotAngle:=Spinedit1.value;
    LastRotAxAzim:=Numedit2.number;
    LastRotAxPlunge:=Numedit3.number;
    Screen.Cursor := crDefault;
end;

procedure TRotForm.Angelier1Click(Sender: TObject);
begin
  If Sender=Angelier1 then
  begin
    If LHExtension=pln then RotPLNPlotType:=0 //draw great circles
    else RotFPLPlotType:=0;  //draw Angelier plot
    LHPoleflag:=false;
  end
  else
    if Sender = Hoeppener1 then
      If LHExtension=pln then
      begin //draw poles to planes
        LHPoleflag:=true;
        RotPLNPlotType:=1;
      end
      else RotFPLPlotType:=1
    else
    If (Sender = ptAxes1) and (LHExtension=pln) then
    begin
      LHPoleflag:=False;
      RotPlnPlotType:=2;
    end;
  (Sender as TMenuItem).Checked:= true;
  SetLHProperties(LHPlotType);
  PaintBox1.Refresh;
  PaintBox2.Refresh;
end;

procedure TRotForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  Screen.cursor:=crDefault;
end;

procedure TRotForm.NumEdit2Change(Sender: TObject);
begin
  inherited;
  if SpinEdit1.Value<>0 then ApplyBtn.Enabled:=true;
end;

procedure TRotForm.SpinEdit1Change(Sender: TObject);
begin
  ApplyBtn.Enabled:=true;
  Checkbox1.checked:=false;
end;

procedure TRotForm.CheckBox1Click(Sender: TObject);
begin
  inherited;
  Label11.Enabled:= not checkbox1.checked;
  Label2.Enabled:= not checkbox1.checked;
  Label3.Enabled:= not checkbox1.checked;
  Label4.Enabled:= not checkbox1.checked;
  ApplyBtn.Enabled:=true;
end;

procedure TRotForm.SpinEdit1Click(Sender: TObject);
begin
  inherited;
  Checkbox1.checked:=false;
end;

end.
