unit Ptplot;

interface

uses Types, Windows, Graphics, SysUtils, LowHem, Dialogs, Math;

type
  Tplotpt = class(TLHWin)
    procedure Compute(Sender: TObject); override;
    procedure FormCreate(Sender: TObject; const AFilename: string;  const AExtension: TExtension); override;
  public
    nosense: Integer;
    ptACalcMeanVect: Boolean;
  end;

var Plotpt: Tplotpt;

procedure CalcMeanVectRC(fAzimuth, fPlunge: Single; var fSX, fSY, fSZ: Single; var fCounter: Integer);

implementation

uses Draw,Fileops,tecmain;

procedure Tplotpt.Compute;
const  {constants to draw symbols}
  TriangleSizeRate=0.020;  {Rate of size of linear triangle related to radius of diagram}
var
  dummy, dumy,triangleheight,MySense, i : Integer;
  Fdummy: Single;
  A,n,c,myaperture: single;
  Significance: Integer;
  F : TextFile;
  Points: Array[0..2] of TPoint;
  azim, Plunge, SX, SY, SZ, MeanVectAzim, MeanVectPlunge, R: Array[1..3] of Single;
  AFill: Boolean;
  ASymbol: TPlotSymbol;
  ABrush: TBrush;
  Counter: Array[1..3] of Integer;
begin
  Screen.Cursor := CrHourGlass;
  try
    PrepareMetCan(LHMetCan, LHMetafile, LHEnhMetafile,LHWriteWMF);
    SetBackground(Sender, LHMetCan.Handle);
    LHz := 0;
    try
      AssignFile(F, LHFilename);
      Reset(F);
      if not eof(f) then
      begin
        North;
        nosense:=0;
        LHMetCanHandle:=LHMetCan.Handle;
        For i:=1 to 3 do
        begin
          Counter[i]:=0;
          SX[i]:=0;
          SY[i]:=0;
          SZ[i]:=0;
        end;
        while not Eof(F) and not LHfailed do
        begin
          ReadPTFDataset(f,MySense,dummy,Fdummy,Fdummy,Fdummy,Fdummy,Azim[1],Plunge[1],
                 Azim[2], Plunge[2], Azim[3], Plunge[3],Fdummy, dummy, LHfailed, LHNoComment);
          If not LHfailed and LHNoComment then
          begin
            //***************Draw orientation of B-axis*******************
            Lineation(LHMetCanHandle,Canvas,CenterX,CenterY,Radius,Azim[1],Plunge[1],LHSymbSize,
                         LHz, Number1.Checked,false,syRectangle,LHFillBrush, LHPen.Handle);
            If (MySense<>0) and (MySense<>5) then
            begin
              //****************Draw  orientation of P-axis******************
              Lineation(LHMetCanHandle,Canvas,CenterX,CenterY,Radius,Azim[2],Plunge[2],LHSymbSize,
                         LHz,Number1.Checked,LHSymbFillFlag,syCircle,LHFillBrush, LHPen.Handle);
              //****************Draw orientation of T-axis**********************
              Lineation(LHMetCanHandle,Canvas,CenterX,CenterY,Radius,Azim[3],Plunge[3],LHSymbSize,
                         LHz, Number1.Checked,LHSymbFillFlag2,syTriangle,LHFillBrush2, LHPen.Handle);
              if ptACalcMeanVect then //*****Calculate mean vector of p-, b and t-axes******
              begin
                CalcMeanVectRC(Azim[2], Plunge[2],SX[2], SY[2], SZ[2],Counter[2]); //p
                CalcMeanVectRC(Azim[3], Plunge[3],SX[3], SY[3], SZ[3],Counter[3]); //t
              end;
            end
            else
            begin
              {****************Draw  orientation of P or T -axis******************}
              Lineation(LHMetCanHandle,Canvas,CenterX,CenterY,Radius,Azim[2],Plunge[2],LHSymbSize,
                         LHz, Number1.Checked,true,syStar,LHFillBrush, LHPen.Handle);
              {****************Draw orientation of T or P-axis**********************}
              Lineation(LHMetCanHandle,Canvas,CenterX,CenterY,Radius,Azim[3],Plunge[3],LHSymbSize,
                         LHz, Number1.Checked,true,syStar,LHFillBrush, LHPen.Handle);
              inc(nosense);
            end;
            if ptACalcMeanVect then CalcMeanVectRC(Azim[1], Plunge[1],SX[1], SY[1], SZ[1],Counter[1]); //b
            If not eof(f) then Inc(LHz);
          end else if not LHNoComment then dec(LHz);
        end; {end of while-loop}
      end else LHfailed := true;
      CloseFile(F);
      If not LHfailed then With LHMetCan do
      begin
        If (counter[1]>1) and ptACalcMeanVect then //Calculate mean vector
        begin
          Significance:=99;
          For i:=1 to 3 do
          begin
            R[i]:=Sqrt(Sqr(SX[i])+Sqr(SY[i])+Sqr(SZ[i]));
            //***********************
            Counter[i]:=Counter[i]-1; //bugfix 080116
            n := Counter[i]+ 1 - R[i];
            If n=0 then n:=0.00000000000001;
            A := Power(1/(1-Significance/100), (1/Counter[i]));
            c := 1-(n)*(A-1)/R[i];
            If c=0 then c:=c+0.00000000000001;
            if sqr(c)<=1 then
              MyAperture := RadToDeg(ArcTan(SQRT(1-Sqr(c))/c))
            else MyAperture := RadToDeg(ArcTan(SQRT(Sqr(c)-1)/c));
            {Calculation of azimuth and plunge of normal vector}
            MeanVectAzim[i]:=RadToDeg(ArcTan2(SY[i],SX[i]));
            If MeanVectAzim[i]<0 then MeanVectAzim[i]:=MeanVectAzim[i]+360;
            MeanVectPlunge[i]:=RadToDeg(ArcTan(SZ[i]/R[i]/Sqrt(1-Sqr(SZ[i]/R[i]))));
            if meanvectplunge[i]<0 then
            begin
              meanvectplunge[i]:=abs(meanvectplunge[i]);
              MeanVectAzim[i]:=trunc(MeanVectAzim[i]+180) mod 360 + frac(MeanVectAzim[i]);
            end;
            R[i]:=(2*R[i]-Counter[i]-1)*100/(Counter[i]+1);
            case i of
              1: begin
                ASymbol:=syRectangle;
                ABrush:=LHFillBrush;
                AFill:=false;
              end;
              2: begin
                ASymbol:=syCircle;
                ABrush:=LHFillBrush;
                AFill:=LHSymbFillFlag;
              end;
              3: begin
                ASymbol:=syTriangle;
                ABrush:=LHFillBrush2;
                AFill:=LHSymbFillFlag2;
              end
            end;
            SmallCircle2(LHMetCan.Handle, Canvas, CenterX, CenterY, Radius,MeanVectAzim[i],MeanVectPlunge[i],
              MyAperture, LHSymbSize, LHSymbfillflag, LHSymbType, LHFillBrush, LHPen.Handle);
            Lineation(LHMetCanHandle,Canvas,CenterX,CenterY,Radius,MeanVectAzim[i],MeanVectPlunge[i],
              LHSymbSize*2, LHZ,false,AFill,ASymbol,ABrush, LHPen.Handle);
          end;
        end;
        //***************Write Explanation************
        //Brush.Style := bsClear;
        NumberLabel;  //Output of number of datasets (compulsory)
        if Label1.Checked then
        begin
          Pen:=LHPen;
          dummy:=LHMetCan.Font.Height div 2;
          If nosense<>0 then
          begin
            TextOut(labelleft,labeltop+2*(6-LHMetCan.Font.Height),'Bivalent datasets: '+IntToStr(nosense));
            MoveTo(CenterX+160-ArrowHeadLength, CenterY-Radius-20);
            LineTo(CenterX+160+ArrowHeadLength+1, CenterY-Radius-20);
            MoveTo(CenterX+160, CenterY-Radius-20-ArrowHeadLength);
            LineTo(CenterX+160, CenterY-Radius-20+ArrowHeadLength+1);
            MoveTo(CenterX+160-ArrowHeadLength, CenterY-Radius-20-ArrowHeadLength);
            LineTo(CenterX+160+ArrowHeadLength+1, CenterY-Radius-20+ArrowHeadLength+1);
            MoveTo(CenterX+160+ArrowHeadLength, CenterY-Radius-20-ArrowHeadLength);
            LineTo(CenterX+160-ArrowHeadLength-1, CenterY-Radius-20+ArrowHeadLength+1);
            TextOut(CenterX+180, CenterY-Radius+dummy-20,'P- or T-Axes');
          end;
          dumy:=Round(LHSymbSize);//Round(Radius*LinearCircleRate);
          triangleheight:=Round(Radius*Sqrt(3)*TriangleSizeRate);
          if LHSymbFillFlag then Brush := LHFillBrush;
          Ellipse(CenterX+Radius-80 - dumy,CenterY-Radius - dumy,
                  CenterX+Radius-80 + dumy,CenterY-radius + dumy);
          Points[0].x:=CenterX+Radius-80-triangleheight;
          Points[0].y:=CenterY-Radius+40+Round(Radius*TriangleSizeRate);
          Points[1].x:=CenterX+Radius-80+triangleheight;
          Points[1].y:=Points[0].y;
          Points[2].x:=CenterX+Radius-80;
          Points[2].y:=CenterY-Radius+40-Round(Radius*TriangleSizeRate*2);
          if LHSymbFillFlag then Brush := LHFillBrush2;
          Polygon(Points);
          if LHSymbFillFlag then Brush.Style := bsClear;
          Rectangle(CenterX+Radius-80-dumy, CenterY-Radius+20-dumy,
                    CenterX+Radius-80 + dumy, CenterY-Radius+20 + dumy);
          TextOut(CenterX+Radius-60, CenterY-Radius+dummy,'P-Axes');
          TextOut(CenterX+Radius-60, CenterY-Radius+dummy+20,'B-Axes');
          TextOut(CenterX+Radius-60, CenterY-Radius+dummy+40,'T-Axes');
          If (counter[1]>1) and ptACalcMeanVect then
          begin
            TextOut(CenterX+Radius-85, CenterY+Radius+dummy-45,'Mean vect.   R');
            TextOut(CenterX+Radius-85, CenterY+Radius+dummy-25,'P: '+FloatToString(MeanVectAzim[2], 3,0)+' / '+FloatToString(MeanVectPlunge[2],2,0)+'  '+FloatToString(R[2],2,0)+'%');
            TextOut(CenterX+Radius-85, CenterY+Radius+dummy-5,'B: '+FloatToString(MeanVectAzim[1], 3,0)+' / '+FloatToString(MeanVectPlunge[1],2,0)+'  '+FloatToString(R[1],2,0)+'%');
            TextOut(CenterX+Radius-85, CenterY+Radius+dummy+15,'T: '+FloatToString(MeanVectAzim[3], 3,0)+' / '+FloatToString(MeanVectPlunge[3],2,0)+'  '+FloatToString(R[3],2,0)+'%');
          end;
        end;
      end;
    except   {can not open file}
      On EInOutError do Fileused:=true;
    end;
  finally
    LHMetCan.Free;
    Screen.Cursor := CrDefault;
  end;
  If LHfailed or fileused then FileFailed(Plotpt)
  else
  begin
    inherited;
    if counter[1]>1 then LHPlotInfo:=LHPlotInfo+#13#10+'Mean Vector:     R'+#13#10+
      'P: '+FloatToString(MeanVectAzim[2], 3,0)+' / '+FloatToString(MeanVectPlunge[2],2,0)+'     '+FloatToString(R[2],2,0)+'%'+#13#10+
      'B: '+FloatToString(MeanVectAzim[1], 3,0)+' / '+FloatToString(MeanVectPlunge[1],2,0)+'     '+FloatToString(R[1],2,0)+'%'+#13#10+
      'T: '+FloatToString(MeanVectAzim[3], 3,0)+' / '+FloatToString(MeanVectPlunge[3],2,0)+'     '+FloatToString(R[3],2,0)+'%';
  end;
end;

procedure Tplotpt.FormCreate(Sender: TObject; const AFilename: string;  const AExtension: TExtension);
begin
  LHPlotType:=pt_ptPlot;
  ptACalcMeanVect:= ptCalcMeanVect;
  inherited;
end;


procedure CalcMeanVectRC(fAzimuth, fPlunge: Single; var fSX, fSY, fSZ: Single; var fCounter: Integer);
var DegAzimuth, DegPlunge, XX, YY, ZZ, W, XQ, YQ, ZQ: Single;
begin   //R% and center method
  DegAzimuth:=DegToRad(fAzimuth);
  DegPlunge:=DegToRad(fPlunge);
  XX:=Cos(DegAzimuth)*Cos(DegPlunge);
  YY:=Sin(DegAzimuth)*Cos(DegPlunge);
  ZZ:=Sin(DegPlunge);
  If fCounter<>0 then
  begin
    W:=Sqrt(Sqr(fSX)+Sqr(fSY)+Sqr(fSZ));
    XQ:=fSX/W;
    YQ:=fSY/W;
    ZQ:=fSZ/W;
    If Sqr(XQ+XX)+Sqr(YQ+YY)+Sqr(ZQ+ZZ)<=2 then
    begin
      XX:=-XX;
      YY:=-YY;
      ZZ:=-ZZ;
    end;
  end;
  fSX:=fSX+XX;
  fSY:=fSY+YY;
  fSZ:=fSZ+ZZ;
  inc(fCounter);
end;
end.
