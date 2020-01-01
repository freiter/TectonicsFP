unit dihedra;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Types,
  LowHem, math;

type
  TDihedraForm = class(TLHWin)
    procedure Convert(V,Z: Single; var VA,ZA: Single);
    procedure GetMidpoint (FDipDir,FDip: Single; var MKX,MKY,RK : Single);
    procedure Compute(Sender: TObject); override;
  private
    XX, YY: Integer;
    R: Word;
  published
    Savedialog1 : TSavedialog;
    procedure FormCreate(Sender: TObject; const AFilename: string;  const AExtension: TExtension); override;
  end;


implementation

uses FileOps, TecMain, VirtDip, draw;

procedure TDihedraForm.FormCreate(Sender: TObject; const AFilename: string;  const AExtension: TExtension);
begin
  XX := Centerx;
  YY := centery;
  R:=radius;
  {Savedialog1:=TSavedialog.create(Self);
  With Savedialog1 do
  begin
    Title:='Save counting points as';
    options:=[ofHidereadonly, ofOverwriteprompt];
    Filename:=Changefileext(AFilename,'.lin');
    Filter:='Lineation files (*.lin)|*.lin';
 end; }
//  If Savedialog1.execute then
    inherited
  //else close;
end;

procedure TDihedraForm.Compute(Sender: TObject);
var rings : Integer;
    f: TextFile;
    bew, MyQuality : Integer;
    AzimB,PlungeB,SingleDummy,DipDir,Dip,Azimuth, Plunge,
    M1x,M1Y,M2X,M2Y,R1,R2,PIOVERI3,RC,CAZ,RR1,RR2,Va,Za, DipDir2,Dip2 : Single;
    i, j, j6, sense: Integer;
    NoComment: boolean;
    CXPT, CYPT, CNT : Variant;
    comment: string;
    //PCXPT, PCYPT : P2dZeroSingleArray;
label 456,457,458;    

begin
  Screen.Cursor := CrHourGlass;
  Canvas.brush.style := bsClear;
  Rings:=20;
  //CXPT:=VarArrayCreate([0,Rings*6,0,Rings],VarSingle);
  //CYPT:=VarArrayCreate([0,Rings*6,0,Rings],VarSingle);
  CXPT:=VarArrayCreate([0,Rings,0,Rings*6],VarSingle);
  CYPT:=VarArrayCreate([0,Rings,0,Rings*6],VarSingle);
  CNT:=VarArrayCreate([0,Rings,0,Rings*6],varInteger);
  //PCXPT:=vararraylock(CXPT);
  //PCYPT:=vararraylock(CYPT);
  try
  PrepareMetCan(LHMetCan, LHMetafile, LHEnhMetafile, LHWriteWMF);
  AssignFile(F,LHFilename);
  Reset(f);
  //AssignFile(g,'E:\Daten\Programs\Schwaz\hugo.lin');
  //rewrite(g);
  if not eof(f) then
  begin
  //PCXPT^[0,0] := 0;
  //PCYPT^[0,0] := 0;
  North;
  CXPT[0,0] := xx;
  CYPT[0,0] := yy;
  CNT[0,0]:=0;
  FOR I := 1 TO Rings do
  begin
    J6 := 6*I - 1;
    FOR J := 0 TO J6 do
    begin
      PIOVERI3 := PI/(3*I);
      CAZ := J*PIOVERI3;
      //PCXPT^[I,J] := RC * SIN(CAZ)+XX;
      //PCYPT^[I,J] := RC * COS(CAZ)+YY;
      RC := I*R/Rings;
      CXPT[I,J] := RC * SIN(CAZ)+XX;
      CYPT[I,J] := RC * COS(CAZ)+YY;
      CNT[I,J]:=0;
      //LHMetCan.Pixels[Round(PCXPT^[I,J]),Round(PCYPT^[I,J])]:=clred;
      LHMetCan.Pixels[Round(CXPT[I,J]),Round(CYPT[I,J])]:=clred;
    end;
  end;
  //try
    WHILE NOT EOF(F) and not LHfailed do
    begin
      case LHExtension of
        COR,HOE,PEF,PEK,STF: ReadFPLDataset(f, Sense, MyQuality, DipDir, Dip,
           Azimuth, Plunge, LHfailed, NoComment, LHExtension, Comment);
        PTF: ReadPTFDataset(f,Sense,MyQuality,DipDir,Dip,Azimuth,Plunge,singledummy,singledummy,
             SingleDummy,SingleDummy,SingleDummy,SingleDummy,SingleDummy,bew, LHFailed,NoComment);
        else LHfailed:=true;
      end;
      SnDxToUpDn(Sense,DipDir,Dip, Azimuth,Plunge);
      FlaechLin(DipDir,Dip,trunc(Azimuth+180) mod 360 + frac(Azimuth),90-Plunge, false, Azimb,PlungeB);
      if not LHfailed and NoComment then
      begin
        //IF AzimB=0 THEN AzimB:=1;
        //IF PlungeB=0 THEN PlungeB:=1;
        GetMidpoint (DipDir,Dip,M1X,M1Y,R1);
        //LHMetCan.Pen.style:=psdot;
        //LHMetCan.ellipse(round(M1X-R1),round(M1y-R1),round(m1x+r1),round(m1y+r1));
        //LHMetCan.Pen.style:=pssolid;
        if Label1.checked then GreatCircle(LHMetCan.Handle,Canvas,XX,YY,R,DipDir,Dip,0,false,LHPen.Handle, LHLogPen);
        if Label1.checked then Lineation(LHMetCan.Handle,Canvas,XX,YY,R,DipDir+180,90-Dip,LHSymbSize,0,false,
                   LHSymbFillFlag,LHSymbType, LHFillBrush,LHPen.Handle);
        FlaechLin(DipDir+180,90-Dip,AzimB,PlungeB,true,DipDir2,Dip2);
        GetMidpoint (DipDir2,Dip2,M2X,M2Y,R2);
        //LHMetCan.Pen.Color:=clRed;
        //LHMetCan.Pen.style:=psdot;
        //LHMetCan.ellipse(round(M2X-R2),round(M2y-R2),round(m2x+r2),round(m2y+r2));
        //LHMetCan.Pen.style:=pssolid;
        if Label1.checked then GreatCircle(LHMetCan.Handle,Canvas,XX,YY,R,DipDir2,Dip2,0,false,LHPen.Handle, LHLogPen);
        if Label1.checked then Lineation(LHMetCan.Handle,Canvas,XX,YY,R,DipDir2+180,90-Dip2,LHSymbSize,0,false,
                   LHSymbFillFlag,LHSymbType, LHFillBrush,LHPen.Handle);
        //LHMetCan.Pen.Color:=clBlack;
        FOR I := 0 TO Rings do
        begin
          if I>0 then J6 := 6*I - 1
          else j6:=0;
          FOR J := 0 TO J6 do
          begin
            //RR1:=SQRT((M1X-PCXPT^[I,J])*(M1X-PCXPT^[I,J])+(M1Y-PCYPT^[I,J])*(M1Y-PCYPT^[I,J]));
            //RR2:=SQRT((M2X-PCXPT^[I,J])*(M2X-PCXPT^[I,J])+(M2Y-PCYPT^[I,J])*(M2Y-PCYPT^[I,J]));
            //Convert(PCXPT^[I,J],PCYPT^[I,J],VA,ZA);
            RR1:=SQRT((M1X-CXPT[I,J])*(M1X-CXPT[I,J])+(M1Y-CYPT[I,J])*(M1Y-CYPT[I,J]));
            RR2:=SQRT((M2X-CXPT[I,J])*(M2X-CXPT[I,J])+(M2Y-CYPT[I,J])*(M2Y-CYPT[I,J]));
            Convert(CXPT[I,J],CYPT[I,J],VA,ZA);
            Case sense of
              1: begin
                IF ((RR1 >= R1) or (RR2 >= R2)) AND
                   ((RR1 <= R1) or (RR2 <= R2)) AND
                   ((RR1 > R1) OR (RR2 > R2)) THEN
                    begin
                      //Convert(PCXPT^[I,J],PCYPT^[I,J],VA,ZA);
                      //Convert(CXPT[I,J],CYPT[I,J],VA,ZA);
                      CNT[I,J]:=CNT[I,J]+1;
                      //inc(zz);
                      //WRITEln(G,round(VA+2),',',round(ZA+2));
                    END;
              END;
              2:
              begin
                IF ((RR1 < R1) and (RR2 < R2)) or
                   ((RR1 > R1) and (RR2 > R2)) or
                   ((RR1 <= R1) AND (RR2 <= R2)) THEN
                begin
                  //Convert(PCXPT^[I,J],PCYPT^[I,J],VA,ZA);
                  //Convert(CXPT[I,J],CYPT[I,J],VA,ZA);
                  CNT[I,J]:=CNT[I,J]+1;
                  //inc(zz);
                  //WRITEln(G,round(VA+2),',',round(ZA+2));
                end;
              END;
            end; //case
        end; //NEXT J
      end; //NEXT I}
      If not eof(f) then Inc(LHz);
    end else if not NoComment then dec(LHz);
  end; //end of while-loop
  end else LHfailed:= true;
  If not LHfailed and number1.checked then
  begin
    settextalign(LHMetCan.handle,ta_baseline);
    FOR I := 0 TO Rings do
    begin
      if i>0 then J6 := 6*I - 1
      else j6:=0;
      FOR J := 0 TO J6 do
        LHMetCan.TextOut(Round(CXPT[I,J]),Round(CYPT[I,J]),IntToStr(CNT[I,J]));
    end;
    settextalign(LHMetCan.handle,TA_TOP);
  end;
  //CLOSEFile(G);
  CLOSEFile(F);
  If not LHfailed then NumberLabel;
finally
  LHMetCan.Free;
  Screen.Cursor := CrDefault;
end;
If LHfailed or fileused then FileFailed(Self);
END; {end SUB}

procedure TDihedraForm.GetMidpoint (FDipDir,FDip: Single; var MKX,MKY,RK : Single);
var degdipdir,h: single;
begin
  if fdip>=90 then fdip:=89.999;
  h:=R*SQRT2*SIN(DegToRad((90-FDip))/2);
  RK:=(h*h+R*R)/2/h;
  DegDipDir:=DegToRad(90-FDipDir);
  MKX:=XX-(R*R-h*h)/2/h*Cos(DegDipDir);
  MKY:=YY+(R*R-h*h)/2/h*Sin(DegDipDir);
END;

procedure TDihedraForm.Convert(V,Z: Single; var VA,ZA: Single);
var ahr, rech, rec, gqi :Single;
begin
  IF V<XX THEN VA:= XX-V ELSE VA:= V-XX;
  IF Z<YY THEN ZA:= YY-Z ELSE ZA:= Z-YY;
  IF VA=0 THEN
    VA:= 0.00000001;
  IF ZA=0 THEN
    ZA:= 0.00000001;
  ahr:= arctan(VA/ZA);
  rech:= VA/(R*SQRT(2)*SIN(ahr));
  //bugfix 130398
  if rech<=-1 then rech:=-0.9999
  else if rech>=1 then rech:=0.9999;
  rec:= arctan(rech/SQRT((-1)*rech*rech+1));
  gqi:= DegToRad(90)-(2*rec);
  VA:=ahr*180/PI;
  IF V > XX THEN
  begin
    IF Z > YY THEN VA := (90 - VA) + 90;
  end
  else
    IF V < XX THEN
    begin
      IF Z > YY THEN VA := VA + 180;
      IF Z < YY THEN VA := (90 - VA) + 270;
    end;
  ZA:=gqi*180/PI;
  IF (V=XX) AND (Z>YY) THEN VA:=VA+180;
  IF (Z=YY) AND (V<XX) THEN VA:=VA+180;
END; {end SUB}

end.
