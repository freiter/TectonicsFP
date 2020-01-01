unit Angle;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  StdCtrls, ExtCtrls, Forms, Buttons, Dialogs, Types,
  Numedit, math;



type
  TThetaDialog = class(TForm)
    OkButton: TBitBtn;
    CancelButton: TBitBtn;
    RadioGroup1: TRadioGroup;
    NumEdit1: TNumEdit;
    BitBtn1: TBitBtn;
    SaveDialog1: TSaveDialog;
    procedure OkButtonClick(Sender: TObject);
    procedure Open(const AFilename : string; const AExtension: TExtension);
    procedure RadioGroup1Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
  private
    procedure TektDoit(PDipDir, PDip: PZeroSingleArray; nn: Integer;var AZ,FZ: single;
                                var RP: integer);
  end;
  Procedure Rotate(Plane:Boolean;
                 RotAngle: Integer; RotAxAzim,RotAxPlunge,OldAzim,OldPlunge:Single;
                 var NewAzim,NewPlunge: Single);
  procedure CalculatePTAxes;
  procedure BackToTheta(const XX:Integer; const AFilename:String);

var
  ThetaDialog: TThetaDialog;
  Besttheta : boolean;
  ThetaFileName, Filename2 : string;
  ThetaExtension: TExtension;
  Angle1: Integer;
  PSense, PQuality : PZeroIntArray;
  PDip, PDipDir, PAzimuth, PPlunge: PZeroSingleArray;

implementation

{$R *.DFM}
uses bt_draw, fileops, TecMain;

Procedure Rotate(Plane:Boolean;
                 RotAngle: Integer; RotAxAzim,RotAxPlunge,OldAzim,OldPlunge:Single;
                 var NewAzim,NewPlunge: Single);
var
    al,am,fm,ata,fi,e1,e2,e3,TA,dummy1,dummy2,DegRotAngle: Single;
    z,J,I: integer;
    a,b,c : array [0..2] of Single;
    x,y   : array [0..3] of Single;
    NA    : array [0..3,0..3] of Single;

begin
  IF RotAngle < 0 THEN RotAngle := RotAngle + 360;
  DegRotAngle:=DegToRad(RotAngle);
  IF RotAngle > 180 THEN
  begin
    DegRotAngle:=DegRotAngle - PI;
    A[2] := COS(DegRotAngle);
    B[2] := 1 - A[2];
    c[2] := SIN(DegRotAngle);
    Z := 2;
    A[1] := -1;
    B[1] := 2;
    c[1] := 0;
  end
  else
  begin
    A[1] := COS(DegRotAngle);
    B[1] := 1 - A[1];
    c[1] := SIN(DegRotAngle);
    Z:=1;
  end;
  IF Plane THEN
  begin
    OldPlunge := 90 - OldPlunge;
    OldAzim := trunc(OldAzim +180) MOD 360 + Frac(OldAzim);
  end;
  al:=OldAzim;
  IF (Al = 90) OR (Al = 180) OR (Al = 270) THEN am := DegToRad(Al + 0.05)
  else am:=DegToRad(Al);
  FM := DegToRad(OldPlunge);
  {****************** Rotation-algorithm ***********************}
  FOR J:= 1 TO Z do
  begin
    IF J = 2 THEN
    begin
      am := ATA;
      FM := FI;
    end;
    dummy1:= DegToRad(RotAxAzim);
    dummy2:= DegToRad(RotAxPlunge);
    E1 := COS(dummy1)*COS(dummy2);
    E2 := SIN(dummy1)*COS(dummy2);
    E3 := SIN(dummy2);
    NA[1,1] := A[J]+B[J]*Sqr(E1);
    NA[1,2] := B[J]*E1*E2-c[J]*E3;
    NA[1,3] := B[J]*E1*E3+c[J]*E2;
    NA[2,1] := B[J]*E1*E2 + c[J]*E3;
    NA[2,2] := A[J]+B[J]*Sqr(E2);
    NA[2,3] := B[J]*E2*E3-c[J]*E1;
    NA[3,1] := B[J]*E1*E3 - c[J]*E2;
    NA[3,2] := B[J]*E2*E3 + c[J]*E1;
    NA[3,3] := A[J] + B[J]*Sqr(E3);
    x[1] := COS(am)*COS(FM);
    x[2] := COS(FM)*SIN(am);
    x[3] := SIN(FM);
    FOR I:= 1 TO 3 do
      y[I] := NA[I,1]*x[1]+NA[I,2]*x[2]+NA[I,3]*x[3];
    IF y[1] = 0 then
      if y[2] < 0 THEN TA := 3*PI/2
      else IF y[2] > 0 THEN TA := PI/2;
    IF y[3] < 0 THEN
    begin
      y[1] := -y[1];
      y[2] := -y[2];
      y[3] := -y[3];
    end;
    IF y[1] <> 0 THEN ATA := ArcTan(y[2]/y[1]);
    IF y[1] <= 0 THEN ATA := ATA + PI    {???not defined for y[1]=0 and y[2]<0!!!}
    else If y[2] < 0 THEN ATA := ATA + 2*PI;
    IF (y[1] = 0) AND (y[2] > 0) THEN ATA := PI/2;
    IF y[3] > 0.999 THEN FI := PI/2 else FI := ArcSin(y[3]);
  end;
  NewAzim := trunc(RadToDeg(ATA)) mod 360 + frac(RadToDeg(ATA));;
  NewPlunge := RadToDeg(FI);
  IF Plane THEN
  begin
    NewAzim := trunc(NewAzim+180) MOD 360 + frac(NewAzim);
    NewPlunge := 90 - NewPlunge;
  end;
END;

procedure TThetaDialog.TektDoit(PDipDir, PDip: PZeroSingleArray; nn: Integer;var AZ,FZ: single;
                                var RP: integer);
var
  SX,SY,SZ,w,x,y,z,dummy1,dummy2: Single;
  j, ValidSet: Integer;
  notfirstrun: boolean;
begin
  j:=0;
  ValidSet:=0;
  SX:=0;
  SY:=0;
  SZ:=0;
  notfirstrun:=false;
  While j<(nn+1) do
  begin
    If (PSense^[j]<> 0) and (PSense^[j]<> 5) then
    begin
      dummy1:=DegToRad(PDipDir^[j]);
      dummy2:=DegToRad(PDip^[j]);
      x:= COS(dummy1)*COS(dummy2);
      y:= SIN(dummy1)*COS(dummy2);
      Z:= SIN(dummy2);
      IF notfirstrun THEN
      begin
        W := SQRT(Sqr(SX)+Sqr(SY)+Sqr(SZ));
        IF Sqr(SX/W+x)+Sqr(SY/W+y)+Sqr(SZ/W+Z) <= 2 THEN
        begin
          x:=-x;
          y:=-y;
          Z:=-Z;
        end;
      end else notfirstrun:=true;
      SX:=SX+x;
      SY:=SY+y;
      SZ:=SZ+Z;
      inc(ValidSet);
    end;
    Inc(j);
  end; {end of while-loop}
  W := SQRT(Sqr(SX)+Sqr(SY)+Sqr(SZ));
  RP := round((2*W-ValidSet)*100/ValidSet);
  IF SX = 0 THEN AZ := 90 else AZ := RadToDeg(ArcTan(SY/SX));
  IF AZ <0 THEN AZ := AZ + 180;
  IF SY < 0 THEN
  begin
    AZ := AZ + 180;
    IF AZ >360 THEN AZ := AZ-360;
  end;
  FZ:= RadToDeg(ArcSin(SZ/W));
  IF FZ < 0 THEN
  begin
    AZ := Trunc(AZ + 180) MOD 360 + frac(az);
    FZ := -FZ;
  end;
END;

procedure TThetaDialog.OkButtonClick(Sender: TObject);
var NewExt : String[4];
    Saveflag,Exitflag : Boolean;
begin
  ptTheta:=NumEdit1.Number;
  ptbesttheta:=boolean(radiogroup1.itemindex);
  Besttheta:=ptbesttheta;
  If not Besttheta then
  begin
    Besttheta:=false;
    NewExt:='.t'+IntToStr(NumEdit1.Number);
    SaveDialog1.Filename:=ChangeFileExt(ThetaFileName, NewExt);
    repeat
      Saveflag:= SaveDialog1.Execute;
      if saveflag then
      begin
        Case SaveDialog1.FilterIndex of
          1: SaveDialog1.FileName := ChangeFileExt(SaveDialog1.FileName,NewExt);
        end;
        If FileExists(SaveDialog1.Filename) then
        Case MessageDlg('File '+SaveDialog1.Filename+' already exists! Overwrite?', mtWarning,[mbOk,mbCancel, mbRetry], 0) of
          mrRetry: Exitflag:=false;
          mrCancel: exit;
          mrOK: Exitflag:=true;
        end else exitflag:=true;
      end else exitflag:=true;
    until exitflag;
  end;
  If saveflag or besttheta then
  begin
    Angle1:=Numedit1.Number;
    Filename2:=SaveDialog1.FileName;
    CalculatePTAxes;
  end;
end;


procedure CalculatePTAxes;
var
    f, g : TextFile;
    I,Bew,TTH,
    Reg, Theta, nosense :integer;
    MeanAzi, MeanPlunge,RetDipDir,RetDip,NewDipDir,NewDip,Pitch, Azim2, Plunge2 : Single;
    PoleDipDir,PoleDip,px,py,pz,pp,ff,AA,Nazim,Nplunge,RAzim1,RAzim2,RPlunge1,RPlunge2: Single;
    Plane, failed: Boolean;
    PRofPAxis, PROfTAxis: PZeroIntArray;
    PPAxAzi,PPAxPlunge,PTAxAzi,PTAxPlunge: PZeroSingleArray;
    x: Integer;
    bthetap,bthetat,bthetaboth,Index : Integer;
    PlaneL, err, IOError, SenseUnknown : boolean;
    n : Integer;

begin
  Screen.Cursor:=crHourGlass;
  ReadFPLFile(ThetaFileName, ThetaExtension, PSense, PQuality, PDipdir, PDip, PAzimuth, PPlunge, failed, n, IOError);
  If failed then
  begin
    GlobalFailed:=true;
    If IOError then exit
    else
    begin
      Screen.Cursor:=crDefault;
      MessageDlg('Error reading '+ExtractFilename(ThetaFileName)+', dataset '
                 +IntToStr(n+1)+'!'+#10#13+' Processing stopped.',
                 mtError,[mbOk], 0);
      exit;
    end;
  end;
  If besttheta then
  begin
    Angle1:=(10 div BT_increment)*BT_increment;
    bthetap:=(10 div BT_increment)*BT_increment;
    bthetat:=(10 div BT_increment)*BT_increment;
    bthetaboth:=(10 div BT_increment)*BT_increment;
  end
  else
  try
    AssignFile(g, FileName2);
    Rewrite(g);
  except   {can not write to file}
    On EInOutError do
    begin
      GlobalFailed:=True;
      Screen.Cursor:=crDefault;
      MessageDlg('Can not write to '+Filename2+' !'#10#13+
                 'Processing stopped. File might be in use by another application.',
                 mtError,[mbOk], 0);
      exit;
    end;
  end;
  GetMem(PPAxAzi, SizeOf(PPAxAzi^[0])*(N+1));
  GetMem(PPAxPlunge, SizeOf(PPAxPlunge^[0])*(N+1));
  GetMem(PTAxAzi, SizeOf(PTAxAzi^[0])*(N+1));
  GetMem(PTAxPlunge, SizeOf(PTAxPlunge^[0])*(N+1));
  GetMem(PRofPAxis, SizeOf(PRofPAxis^[0])*(85 div BT_increment+1));
  GetMem(PRofTAxis, SizeOf(PRofTAxis^[0])*(85 div BT_increment+1));
  try
  repeat
    nosense:=0;
    FOR I:=0 TO N do
    begin
      if (PSense^[i]<>5) and (PSense^[i]<>0) then SenseUnknown:=false
      else
      begin
        SenseUnknown:=true;
        PSense^[i]:=1;
      end;
      Index:=Angle1 div BT_Increment;
      Theta := Angle1;
      PoleDipDir := trunc((PDipdir^[I]+180)) MOD 360 +frac(PoleDipDir);
      PoleDip := 90-PDip^[I];
      {****find plane defined by azi, plunge and corresponding poles****}
      Azim2:=PAzimuth^[I];
      Plunge2:=PPlunge^[I];
      IF PoleDipDir > 360 THEN PoleDipDir:= trunc(PoleDipDir) MOD 360 +frac(PoleDipDir);;
      IF Azim2 > 360 THEN Azim2:= trunc(Azim2) MOD 360 +frac(Azim2);;
      RAzim1:=DegToRad(PoleDipDir);
      RAzim2:=DegToRad(Azim2);
      RPlunge1:=DegToRad(PoleDip);
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
        On EZeroDivide do
        begin
          If not besttheta then CloseFile(g);
          Screen.Cursor:=crDefault;
          GlobalFailed:=true;
          MessageDlg('Division by zero for Dataset '+IntToStr(N+1)+#13#10+
                     '. Use 89 degrees instead of 90°.', mtError,[mbOk], 0);
          exit;
        end;
      end;
      IF PX <> 0 THEN NAzim := ArcTan(PY/PX)
      else
      begin
        IF PY > 0 THEN NAzim := PI/2;
        IF PY < 0 THEN NAzim := 3*PI/2;
      end;
      NAzim:= RadToDeg(NAzim);
      NPlunge := RadToDeg(NPlunge);
      IF PX < 0 THEN NAzim := NAzim + 180
      else IF (PX > 0) AND (PY > 0) THEN NAzim := NAzim - 360;
      NAzim := NAzim + 180;
      NPlunge := 90 - NPlunge;
      IF NAzim > 360 THEN NAzim := NAzim - 360
      else IF NAzim < 0   THEN NAzim := NAzim + 360;
      {****************************************************************************}
      RetDipDir:=(trunc(Nazim)+180) MOD 360+frac(Nazim);
      RetDip:=90-NPlunge;
      NewDipDir := trunc(180+PDipdir^[I]) MOD 360 + frac(PDipdir^[I]);
      NewDip := 90 - PDip^[I];
      IF PAzimuth^[I]-PDipdir^[I]= 270 THEN PAzimuth^[I]:=PAzimuth^[I]+1
      else IF PAzimuth^[I]-PDipdir^[I]=-270 THEN PAzimuth^[I]:=PAzimuth^[I]-1;
      Pitch := ArcTan(tan(DegToRad(PAzimuth^[I]-PDipdir^[I]-90))/COS(DegToRad(PDip^[I])));
      //IF PDip^[I] >= 89 THEN Pitch := SGN(Pitch)*DegToRad(PPlunge^[I]);
      IF PSense^[I] = 3 then
      begin
        if Pitch < 0 THEN Bew := 2
        else if Pitch > 0 THEN Bew := 1;
      end
      else
        IF PSense^[I] = 4 then
          If Pitch < 0 THEN Bew := 1
          else if Pitch > 0 THEN Bew := 2;
      IF (PSense^[I] = 1) OR (PSense^[I] = 2) or (Pitch = 0) THEN Bew := PSense^[I];
      IF Pitch < 0 THEN Theta:=-Theta;
      IF Bew = 4 THEN Theta := Theta +180
      else If bew = 2 THEN Theta :=-Theta;
      IF Pitch = 0 THEN
      begin
        IF PSense^[I] = 3 THEN Theta := -Theta;
        IF (trunc(PDipdir^[I]+180) MOD 360 + frac(PDipdir^[I])> 270) AND (PAzimuth^[I] < 90) THEN PAzimuth^[I] := PAzimuth^[I]+360;
        IF (trunc(PDipdir^[I]+180) MOD 360 + frac(PDipdir^[I])< PAzimuth^[I]) AND (Bew= 4) THEN Theta:=-Theta
        else IF (trunc(PDipdir^[I]+180) MOD 360 + frac(PDipdir^[I])> PAzimuth^[I]) AND (Bew= 3) THEN Theta:=-Theta;
      END;
      {*********************Rotate Data****************************************}
      Plane := False;
      Rotate (Plane,Theta,RetDipDir,RetDip,PAzimuth^[I],PPlunge^[I],PPAxAzi^[i],PPAxPlunge^[i]);
      Rotate (Plane,Theta,RetDipDir,RetDip,NewDipDir,NewDip,PTAxAzi^[i],PTAxPlunge^[i]);
      Case PSense^[I] of
        1: begin
          IF Pitch < 0 THEN Bew := 6
          else
            if Pitch > 0 THEN
            If Round(RadToDeg(Pitch)) = 90 THEN Bew := 1 else Bew := 8;
        end;
        2: begin
          If Pitch < 0 THEN Bew := 7
          else
            IF Pitch > 0 THEN
              If Round(RadToDeg(Pitch)) = 90 THEN Bew := 2 else Bew := 5;
        end;
        3: begin
          IF Pitch < 0 THEN Bew := 7;
          IF Pitch > 0 THEN Bew := 8;
          IF (PPlunge^[I] = 0) OR (PDip^[I] = 90) THEN Bew := 3;
        end;
        4: begin
          If Pitch < 0 THEN Bew := 6
          else IF Pitch > 0 THEN Bew := 5;
          IF (PPlunge^[I] = 0) OR (PDip^[I] = 90) THEN Bew := 4;
        end;
      end;
      If SenseUnknown then
      begin
        PSense^[I]:=0;
        Bew:=0;
        inc(nosense);
      end;
      If not besttheta then
      begin
        write(g, CombineSenseQuality(PSense^[I],PQuality^[I]),FileListSeparator,
        FloatToString(PDipdir^[i],3,2),FileListSeparator,FloatToString(PDip^[i],2,2),FileListSeparator,
        FloatToString(PAzimuth^[i],3,2),FileListSeparator,FloatToString(PPlunge^[i],2,2),FileListSeparator,
        FloatToString(RetDipDir,3,2),FileListSeparator,FloatToString(RetDip,2,2),FileListSeparator,
        FloatToString(PPAxAzi^[i],3,2),FileListSeparator,FloatToString(PPAxPlunge^[i],2,2),FileListSeparator,
        FloatToString(PTAxAzi^[i],3,2),FileListSeparator,FloatToString(PTAxPlunge^[i],2,2),FileListSeparator,
        FloatToString(RadToDeg(Pitch),2,2),FileListSeparator,Bew);
        {If I<N then} Writeln(g);
      end;
    end;  {end of for loop}
    ThetaDialog.TektDoit (PPAxAzi,PPAxPlunge,n,MeanAzi,MeanPlunge,PRofPAxis^[Index]);
    ThetaDialog.TektDoit (PTAxAzi,PTAxPlunge,n,MeanAzi,MeanPlunge,PRofTAxis^[Index]);
    If besttheta then
    begin
      {IF PRofPAxis^[Index]+PRofTAxis^[Index] >=
          PRofPAxis^[BThetaBoth div Increment]*PRofTAxis^[BThetaBoth div Increment] THEN
          BThetaBoth := Angle1;}
      IF PRofPAxis^[Index]*PRofTAxis^[Index] >=
         PRofPAxis^[BThetaBoth div BT_Increment]*PRofTAxis^[BThetaBoth div BT_Increment] THEN
         BThetaBoth := Angle1;
      IF PRofPAxis^[Index] >= PRofPAxis^[BThetaP div BT_Increment] THEN BThetaP := Angle1;
      IF PRofTAxis^[Index] >= PRofTAxis^[BThetaT div BT_Increment] THEN BThetaT := Angle1;
      inc(Angle1, BT_increment);
    end;
  until (Angle1>=85) or not besttheta;
  Screen.Cursor := CrDefault;
  If besttheta then
  begin
    with Tbtdraw.Create(Application) do
      open(ThetaFileName,PRofPAxis,PRofTAxis,BT_increment,
                bthetap,bthetat,bthetaboth,n,nosense,x);
  end
  else
  begin
    Write(g,FileListSeparator,'Bivalent datasets= ',nosense);
    closeFile(g);
    TecMainWin.WriteToStatusbar(nil , 'Written to file '+FileName2+'.'+#10#13+'R of p: '+IntToStr(PRofPAxis^[Index])+' %'+
      ',  R of t: '+IntToStr(PRofTAxis^[Index])+' %');
  end;
  finally
    FreeMem(PPAxAzi, SizeOf(PPAxAzi^[0])*(N+1));
    FreeMem(PPAxPlunge, SizeOf(PPAxPlunge^[0])*(N+1));
    FreeMem(PTAxAzi, SizeOf(PTAxAzi^[0])*(N+1));
    FreeMem(PTAxPlunge, SizeOf(PTAxPlunge^[0])*(N+1));
    FreeMem(PRofPAxis, SizeOf(PRofPAxis^[0])*(85 div BT_increment+1));
    FreeMem(PRofTAxis, SizeOf(PRofTAxis^[0])*(85 div BT_increment+1));
  end;
end;

procedure TThetaDialog.Open(const AFilename : string; const AExtension: TExtension);
begin
  ThetaFileName := AFileName;
  ThetaExtension := AExtension;
  NumEdit1.Number:=ptTheta;
  radiogroup1.itemindex:=integer(ptbesttheta);
end;

procedure TThetaDialog.RadioGroup1Click(Sender: TObject);
begin
    If RadioGroup1.ItemIndex = 1 then NumEdit1.Enabled:=false
    else NumEdit1.Enabled:=True;
end;

procedure BackToTheta(const XX:Integer; const AFilename:String);
  begin
    Angle1:=xx;
    Filename2:=AFilename;
    BestTheta:=false;
    CalculatePTAxes;
  end;

procedure TThetaDialog.BitBtn1Click(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
