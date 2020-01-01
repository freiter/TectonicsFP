{DEFINE debugging}
{$UNDEF debugging}
unit Contour;

interface

uses
  Windows, Forms, SysUtils, Graphics, LowHem, Types, Settings, Dialogs, Fileops,
  Math, Bingha, Results;

type PSegment = ^TSegment;
     TSegment = Record
                 XStart,
                 YStart,
                 XEnd,
                 YEnd: Integer;
                 Prev,
                 Next: PSegment;
                end;

  TContDihFrm =class(TLHWin)
    procedure FormCreate(Sender: TOBject; const AFilename:string;  const AExtension: TExtension); override;
    procedure ContIntervals;
    procedure Compute(Sender: TObject); override;
    procedure findmaxcount;
    procedure SetContours(var CVALUE: single;const CA, CB, XA, XB, YA, YB: single; var CONX, CONY: single);
    procedure DrawLine(X1, Y1, X2, Y2: single);
    procedure Init(Sender: TObject);
  public
    CircleMethod, AutoCont, blShowNet: Boolean;
    Rings, NCON: Integer;
    CVAL: TCvalArray;
  protected
    firstSegment: boolean;
    CNT, CXPT, CYPT, XPT, YPT: Variant;
    PXPT, PYPT : PZeroSingleArray;
    XX, YY,zz, skipped: integer;
    R: word;
    MaxPercent,FCT,Imax, JMax,PERC: single;
  end;

  TContPlotFrm = class(TContDihFrm)
    procedure FormCreate(Sender: TOBject; const AFilename:string;  const AExtension: TExtension); override;
    procedure ReadData(Sender: TObject);
    procedure ContourData;
    procedure CountCircle;
    procedure CountCurve;
    procedure ContGausRing(I, L : integer; AZ : single; var Checkflag: integer);
  published
    procedure ContNetSetup(const AAutoContFlag, ACircleMethod: boolean; const ADens: integer;var ANCON: integer; var ACVal:TCValArray);
  protected
    GridDensity: integer;
    AzR, ThetR, VectorData, PoleCntP: Variant;
    PAzr, PThetR: PZeroSingleArray;
    //PVectorData : P2dZeroSingleArray;
    root,Segment,Last: PSegment;
  end;

TDihedrFrm = Class(TContDihFrm)
  procedure FormCreate(Sender: TOBject; const AFilename: string;  const AExtension: TExtension); override;
  procedure ContourData;
  procedure GetMidpoint (FDipDir,FDip: Single; var MKX,MKY,RK : Single);
  procedure Convert(FCXPT,FCYPT: Single; var FBearing,FPlunge: Single);
  procedure saveas1click(Sender: TObject); override;
protected
  NA: T2Sing1by3;
  sv, g6: single;
  dummy: integer;
  vstr, svstr : String[4];
  TextDummy1, TextDummy2 : String[20];
  procedure Angelier1Click(Sender: TObject); override;
public
  AziEigenv,PlunEigenv, Eigenval :  T1Sing1by3;
published
  Savedialog1 : TSavedialog;
end;


//after Van Everdingen et al., 1993

implementation

uses Draw, TecMain, Inspect, ContDlg, VirtDip, Sigma;

procedure TContDihFrm.Init(Sender:TObject);
begin
  Inc(GlobalLHPlots);
  LHPlotNumber:=GlobalLHPlots;
  Caption:='Plot '+IntToStr(LHPlotNumber)+': '+Caption;
  If Inspectorform<>nil then InspectorForm.Initialize(Self);
  If ResInsp<>nil then ResInsp.Initialize(Self);
  If SetForm<>nil then SetForm.Initialize(Self);
end;

procedure TContDihFrm.FormCreate(Sender: TObject; const AFilename : String;  const AExtension: TExtension);
begin
  Screen.Cursor:=crHourGlass;
  TecMainWin.Progressbar1.visible:=true;
  LHcreating:=true;
  LHExtension:=AExtension;
  Export1.Enabled:=True;
  Print1.Enabled:=True;
  TecmainWin.ArrangeMenu(Sender);
  Number1.Visible:=False;
  LHWriteWMF:=WriteWmfglobal;
  LHFilename:= AFilename;
  LHLabel1:=ExtractFilename(LHFilename);
  XX := CenterX;
  YY := CenterY;
  R := Radius;
  FCT := R/1000;
  blShowNet:=ContShowNet;
  SetLHProperties(LHPlotType);
end;

procedure TContPlotFrm.FormCreate(Sender: TOBject; const AFilename : String;  const AExtension: TExtension);
begin
  LHPlotType:=pt_Contour;
  inherited;
end;

procedure TContPlotFrm.ReadData(Sender: TObject);
var F: TextFile;
    HighBound, dummy: integer;
    DipDirD, DipD, DegThetR, DegAzr, SinDegThetR, sdummy : single;
    NoComment: Boolean;
    comment: String;
begin
  try  //counting data  first
    AssignFile(F, LHFilename);
    try
    Reset(F);
    if not Eof(F) then
    begin
      LHz := 1;
      while not Eof(F) and not LHfailed do
      begin
        Case lhextension of
          pln, lin: ReadPLNDataset(F, DipDirD, DipD, LHFailed, Nocomment, Comment);
          cor, fpl: ReadFPLDataset(F, dummy, dummy, DipDirD, DipD, sdummy, sdummy,LHFailed, Nocomment, lhextension, Comment);
          ptf:      ReadPTFDataset(F, dummy, dummy, sdummy, sdummy,sdummy, sdummy, DipDirD, DipD, sdummy, sdummy, sdummy, sdummy,
                                  sdummy, dummy, LHFailed, Nocomment);
        end;
        If not LHfailed and Nocomment then
        begin
          If not eof(f) then inc(LHz);
        end else if not NoComment then dec(LHz);
      end; //end of while loop
    end else LHfailed:=true;
    finally
      CloseFile(F); //file has to be closed and opened again due to a bug of delphi 2.0
    end;
    //********************************
    AssignFile(F, LHFilename);
    try
      Reset(F);
      if not Eof(F) then
      begin
        HighBound:=LHz+1;
        LHz := 1;
        ThetR:= VarArrayCreate([1, Highbound], varSingle);
        AzR  := VarArrayCreate([1, Highbound], varSingle);
        VectorData := VarArrayCreate([1,3,1,Highbound], varsingle);
        //VectorData := VarArrayCreate([1,Highbound,1,3], varsingle);
        PAzr:=VarArrayLock(AzR);
        PThetR:=VarArrayLock(ThetR);
        //PVectorData:=VarArrayLock(VectorData);
        while not Eof(F) and not LHfailed do
        begin
          Case lhextension of
            pln, lin: ReadPLNDataset(F, DipDirD, DipD, LHFailed, Nocomment, Comment);
            cor, fpl: case lhstressaxis of
              0: ReadFPLDataset(F, dummy, dummy, DipDirD, DipD, sdummy, sdummy,LHFailed, Nocomment, lhextension, Comment);
              1: ReadFPLDataset(F, dummy, dummy, sdummy, sdummy, DipDirD, DipD,LHFailed, Nocomment, lhextension, Comment);
            end;
            ptf: case lhstressaxis of
              0: ReadPTFDataset(F, dummy, dummy, DipDirD, DipD, sdummy, sdummy,sdummy, sdummy, sdummy, sdummy, sdummy, sdummy,
                                  sdummy, dummy, LHFailed, Nocomment);
              1: ReadPTFDataset(F, dummy, dummy, sdummy, sdummy,DipDirD, DipD, sdummy, sdummy, sdummy, sdummy, sdummy, sdummy,
                                  sdummy, dummy, LHFailed, Nocomment);
              2: ReadPTFDataset(F, dummy, dummy, sdummy, sdummy,sdummy, sdummy, sdummy, sdummy, DipDirD, DipD, sdummy, sdummy,
                                  sdummy, dummy, LHFailed, Nocomment); //p
              3: ReadPTFDataset(F, dummy, dummy, sdummy, sdummy,DipDirD, DipD, sdummy, sdummy, sdummy, sdummy, DipDirD, DipD,
                                  sdummy, dummy, LHFailed, Nocomment); //t
              4: ReadPTFDataset(F, dummy, dummy, sdummy, sdummy,sdummy, sdummy, DipDirD, DipD, sdummy, sdummy, sdummy, sdummy,
                                  sdummy, dummy, LHFailed, Nocomment); //b
            end;
          end;
          If not LHfailed and Nocomment then
          begin
            case LHExtension of
              lin:
              begin
              PAzR^[LHz] := DipDirD;
              PThetR^[LHz] := 90-DipD;
            end;
            pln:
            begin
              PAzR^[LHz] := trunc(DipDirD+180) mod 360+frac(DipDirD);
              PThetR^[LHz] := DipD;
            end;
            cor,fpl: case lhstressaxis of
              0: begin  // use fault plane
                PAzR^[LHz] := trunc(DipDirD+180) mod 360+frac(DipDirD);
                PThetR^[LHz] := DipD;
              end;
              1:
              begin  //use lineation
                PAzR^[LHz] := DipDirD;
                PThetR^[LHz] := 90-DipD;
              end;
            end;
            ptf: case lhstressaxis of
              0: begin  // use fault plane
                PAzR^[LHz] := trunc(DipDirD+180) mod 360+frac(DipDirD);
                PThetR^[LHz] := DipD;
              end;
              1,2,3,4:
              begin  //use lineation
                PAzR^[LHz] := DipDirD;
                PThetR^[LHz] := 90-DipD;
              end;
            end;
          end; //case lhextension
          DegThetR:=DegToRad(PThetR^[LHz]);
          SinDegThetR:=Sin(DegThetR);
          DegAzr:=DegToRad(PAzR^[LHz]);
          {i:=1;
          PVectorData^[i,LHz] := SinDegThetR*Cos(DegAzR);
          inc(i);
          PVectorData^[i,LHz] := SinDegThetR*Sin(DegAzR);
          inc(i);
          PVectorData^[i,LHz] := Cos(DegThetR);}
          VectorData[1,LHz] := SinDegThetR*Cos(DegAzR);
          VectorData[2,LHz] := SinDegThetR*Sin(DegAzR);
          VectorData[3,LHz] := Cos(DegThetR);
          If not eof(f) then inc(LHz);
        end else if not NoComment then dec(LHz);
      end; {end of while loop}
    end else LHfailed:=true;
    finally
      CloseFile(F);
    end;
    if not LHfailed then
    begin
      If LHExtension=pln then LHPoleFlag:=true
      else LHPoleFlag:=false;
      GlobalFailed:= false;
    end;
  except   {can not open file}
    On EInOutError do
      begin
        Fileused:=true;
        CloseFile(F);
      end;
  end;
  If LHfailed or fileused then
  begin
    dec(LHz);
    FileFailed(Self);
    close;
  end
  else CreateMetafile(LHMetafile, LHEnhMetafile, LHWriteWMF);
end;



procedure TContPlotFrm.ContNetSetup(const AAutoContFlag, ACircleMethod: boolean; const ADens: integer;var ANCON: integer; var ACVal:TCValArray);
var I,J,J6 : integer;
    CAZ, RC,PIOVERI3, SinThet: single;
   {creating the counting net with rings=number of rings in a grid
   of 2000 by 2000 units (origin in the centre)}
begin
  LHPasteMode := false;
  LHCopyMode := false;
  LHFailed:=False;
  AutoCont := AAutoContFlag;
  CircleMethod := ACircleMethod;
  Rings := ADens;
  NCON:= ANCON;
  CVal:= ACVal;
  GridDensity :=0;
  XPT:=VarArrayCreate([0,LHz],varSingle);
  YPT:=VarArrayCreate([0,LHz],varSingle);
  PXPT:=VarArrayLock(XPT);
  PYPT:=VarArrayLock(YPT);
  PoleCntP:=VarArrayCreate([1, 3, 0, Rings, 0, Rings*6], varsingle);
  CNT:= VarArrayCreate([0, Rings, 0, Rings*6],varSingle);
  CXPT:=VarArrayCreate([0, Rings, 0, Rings*6],varsingle);
  CYPT:=VarArrayCreate([0, Rings, 0, Rings*6],varsingle);
  //begin of ContNetSetup
  CXPT[0,0]:= 0;
  CYPT[0,0]:= 0;
  //---- this must be done for both Circle and Gauss contouring
  FOR I:= 1 TO Rings do
  begin
    J6 := 6*I-1;
    PIOVERI3 := PI/(3*I);
    RC := I*1000/Rings;
    FOR J := 0 TO J6 do
    begin
      CAZ := J*PIOVERI3;
      CXPT[I,J]:= RC*SIN(CAZ);
      CYPT[I,J]:= RC*COS(CAZ);
    end; //NEXT J
  end; //NEXT I
  //Gauss counting method only
  if not CircleMethod and (GridDensity<>Rings) then
  begin
    GridDensity:= Rings;
    PoleCntP[1,0,0]:= 0;
    PoleCntP[2,0,0]:= 0;
    PoleCntP[3,0,0] := 1;
    for i:=1 to Rings do
    begin
      j6 := 6*i-1;
      SinThet := i* Sqrt(2* Rings*Rings-i*i)/(Rings * Rings);
      Pioveri3 := Pi / (3*i);
      for J := 0 to J6 do
      begin
        Caz := j*PIOVERI3;
        PoleCntP[1,i,J] := SinThet * Cos(CAz);
        PoleCntP[2,i,j] := SinThet * Sin(CAZ);
        PoleCntP[3,i,j] := 1-i * i/(Rings * Rings);   {CosThet}
      end; //next J
    end;  //next i
  end;  //end if
  ContourData;
end; //SUB




procedure TContDihFrm.ContIntervals;
var  MaxCont,I, J, n, k, step, divisor: integer;
     Save: single;
     ExitFlag: boolean;

begin
  If AutoCont then    {----calculate contour levels}
  begin
    if maxpercent>5 then
    begin
      MaxCont := Trunc(MAXPERCENT);
      divisor:=1;
    end
    else if maxpercent>0.5 then
    begin
      maxcont:=trunc(maxpercent*10);
      divisor:=10;
    end
    else
    begin
      maxcont:=trunc(maxpercent*100);
      divisor:=100;
    end;
    CVAL[1]:=1/divisor;
    If MaxCont <=6 then
    begin
      For I:=2 to MaxCont do CVAL[I]:=I/divisor;
      NCON:=MaxCont;
    end
    else
      If MaxCont < 12 then
      begin
        I:=2;
        While I <= MaxCont do
        begin
          CVAL[I div 2 +1] := I/divisor;
          inc(I,2);
        end;
        NCON:=MaxCont div 2 + 1;
      end
      else
        If MaxCont < 20 then
        begin
          step:=MaxCont div 4;
          For I:= 2 to 5 do CVAL[I]:= ((I-1)*Step)/divisor;
          NCON:=5;
        end
        else
          If MaxCont <= 49 then
          begin
            For I:=1 to MaxCont div 5 do CVAL[I+1]:=(I*5)/divisor;
            NCON:=MaxCont div 5 +1;
          end
          else
          begin
            For I:=1 to MaxCont div 10 do CVAL[I+1]:=I*10/divisor;
            NCON:=MaxCont div 10 + 1;
          end;
  end
  else     {manual input of contour levels}
  begin
    //----read in self-specified contour levels
    //****the program takes 15 levels max.****}
    //----sort the array in case values have not been entered in ascending order}
      {SortReals(CVal,NCON)}
    FOR k := NCON-1 downto 1 do
    begin
      J := k+1;
      Save := CVal[k];
      CVal[NCON+1] := Save;
      WHILE Save>CVal[J] do
      begin
        CVal[J-1] := CVal[J];
        J := J+1;
      end;
      CVal[J-1] := Save;
    end;
    CVal[NCON+1] := 0;
    n:= NCON;
    I:= 1;
    ExitFlag:=false;
    While (I<=N) and not Exitflag do
    begin
      If CVAL[I] > MaxPercent then
      begin
        NCON:= I-1;
        ExitFlag:=true;
      end
      else
        If i>1 then
        If CVAL[I]=CVAL[I-1] then
        begin
          NCON:= NCON-1;
          For J:=I to NCON-1 do CVAL[J]:=CVAL[J+1];
        end;
        inc(I);
    end; {****end of while-loop****}
  end; {****end of manual contours block****}
end;


procedure TContPlotFrm.ContourData;    //Main contouring procedure
var
 dd,RSQ, DegAzr : single;
 i : integer;
begin
  RSQ:=1000*Sqrt2;
  For i:= 1 to LHz do
  begin
    DegAzr:= DegToRad(PAzr^[i]);
    dd:= RSQ * Sin(DegToRad(PThetR^[i])/2);
    PXPT^[i]:= dd * Sin(DegAzr);
    PYPT^[i]:= dd * Cos(DegAzr);
  end;
  If CircleMethod then CountCircle //--- use counting circle
  else CountCurve; //--- use weighted counting with Gauss curve
  ContIntervals;   //--- find contour intervals
  Compute(LHWin);
  TecMainWin.ProgressBar1.Visible:=false;
end; //end Sub ContourData


procedure TContPlotFrm.CountCircle;

var  k,i,I1,I2,J11,J12,J21,J22,j,J6K,JEND : integer;
     dx,dy, DegAzr : single;

begin
  {----fast method}
  K:=0;
  For I:= 0 to Rings do {set counting matrix to zero}
  begin
    J6K:=6*I-K;
    For J:=0 to J6K do CNT[I,J]:=0;
    K:=1;
  end;
  {----start counting, based on data points}
  For I:= 1 to LHz do
  begin
    I1:=Abs(Trunc(Sqrt2*Sin(DegToRad(PThetR^[I])/2)*Rings));
    I2:=I1+1;
    If I1=0 then J12:=0     {----only three counting points can be determined}
    else
    begin
      If I1=10 then  {----if points lie exactly on the edge}
      begin
        I1:=9;
        I2:=10;
      end;
      DegAzr:=DegToRad(PAzr^[I]);
      J11:=Abs(Trunc(DegAzr/(Pi/(3*I1))));
      J12:=(J11+1) mod (I1*6);
      dx:=cxpt[I1,J11]-PXPT^[I];
      dy:=cypt[I1,J11]-PYPT^[I];
      If (dx*dx + dy*dy) < 10080 then CNT[I1,J11]:=CNT[I1,J11]+1;
    end; {if}
    J21:=Trunc(DegAzr/(Pi/(3*I2)));
    J22:=(J21 mod (I2*6))+1;
    dx:= cxpt[I1,J12]-PXPT^[I];
    dy:= cypt[I1,J12]-PYPT^[I];
    If (dx*dx + dy*dy) < 10080 then CNT[I1,J12]:=CNT[I1,J12]+1;
    dx:= cxpt[I2,J21]-PXPT^[I];
    dy:= cypt[I2,J21]-PYPT^[I];
    If (dx*dx + dy*dy) < 10080 then CNT[I2,J21]:=CNT[I2,J21]+1;
    dx:= cxpt[I2,J22]-PXPT^[I];
    dy:= cypt[I2,J22]-PYPT^[I];
    If (dx*dx + dy*dy) < 10080 then CNT[I2,J22]:=CNT[I2,J22]+1;
  end; {next dataset (I)}
  {----check on edge and store maximum count}
  JEND:=Rings*3;
  For J:=0 to JEND-1 do  {check on edge}
  begin
    CNT[Rings,J]:=CNT[Rings,J]+CNT[Rings,J+JEND];
    CNT[Rings,J+JEND]:=CNT[Rings,J];
  end; {next j}
  zz:=LHz;
  findmaxcount;
end;

procedure TContDihFrm.findmaxcount;
var i,j,k,j6k : integer;
begin
  MaxPercent:=0;  //find maximum count
  K:=0;
  PERC:=100/zz; //factor for conversion from number of counts to percentage of total datapoints (=LHz)
  For I:=0 to Rings do
  begin
    J6K:=6*I-K;
    For J:=0 to J6K do
    begin
      CNT[I,J]:=CNT[I,J]*PERC;
      IF CNT[I,J]>Maxpercent then
      begin
        Maxpercent:=CNT[I,J];
        IMax :=I;
        JMax :=J;
      end;
    end; //next j
    K:=1;
  end;  //next i
end;


procedure TContPlotFrm.CountCurve;
var k,J6K,Kn,I,J,I1 : integer;
    CheckFlag : integer;
    {$IFDEF debugging}
      z1,z2,z3: integer;
    {$ENDIF}
    dummy : single;
    Notnextdata: boolean;
    f: Textfile;
begin
  TecMainWin.Progressbar1.max:=LHz;
  K:=0;
  {$IFDEF debugging}
    z1:=0;
    z2:=0;
    z3:=0;
  {$ENDIF}
  For I:= 0 to Rings do //----set counting matrix to zero
  begin
    J6K:=6*I-K;
    For J:=0 to J6K do CNT[I,J]:=0;
    K:=1;
  end;  //next I
  //----start counting, based on data points
  For Kn:= 1 to LHz do
  begin
    I1:=Abs(Trunc(Sqrt2 * Sin(DegToRad(PThetR^[Kn])/2) * Rings));
    I:=I1;
    dummy := DegToRad(PAzr^[Kn]);
    For I:=I1 downto 0 do  {go from starting point inward}
    begin
      ContGausRing(I,Kn,dummy,CheckFlag);
      {$IFDEF debugging}
        inc(z1);
     {$ENDIF}
      If CheckFlag=0 then break;
    end;
    I:=I1+1;
    Notnextdata:=true;
    For I:=I1+1 to Rings do
    begin
      ContGausRing(I,Kn,dummy,CheckFlag);
      {$IFDEF debugging}
        inc(z2);
     {$ENDIF}
      If Checkflag<>0 then
      begin
        notnextdata:=false;
        break;
      end;
    end; {next I}
    If notnextdata then
    begin
      I:=Rings;
      dummy:=DegToRad(trunc(PAzr^[Kn]+180) mod 360+frac(PAzr^[Kn]));
      Repeat
        ContGausRing(I,Kn,dummy,CheckFlag);
        {$IFDEF debugging}
          inc(z3);
        {$ENDIF}
        dec(I);
      until Checkflag = 0;
    end;
    TecMainWin.Progressbar1.StepIt;
  end; {next kn}
  {----check on edge and store maximum count}
  For J:=0 to Rings*3-1 do
  begin
    CNT[Rings,J]:= Max2(CNT[Rings,J],CNT[Rings,J+Rings*3]);
    CNT[Rings,J+Rings*3]:= CNT[Rings,J];
  end;    {next j}
  //************for debugging purposes*******************
  {$IFDEF debugging}
    Assignfile(F, 'c:\tmp\hugo_neu.txt');
    Rewrite(F);
    writeln(f,'Z1=',z1);
    writeln(f,'Z2=',z2);
    writeln(f,'Z3=',z3);
    K:=0;
    For I:= 0 to Rings do //----write values to textfile
    begin
      J6K:=6*I-K;
      For J:=0 to J6K do writeln(f,FloatToString(I,2,0),'   ',FloatToString(J,3,0),'  ',CNT[I,J]);
      K:=1;
    end;
    Closefile(F);
  {$ENDIF}
  //*******************************
  zz:=LHz;
  findmaxcount;
end; {procedure}


procedure TContPlotFrm.ContGausRing(I, L : integer; AZ : single; var Checkflag: integer);
const one : integer = 1;
      two : integer = 2;
      three:integer = 3;
var
Jcount,FullRing: integer;   {Jcount----number of counted points in the ring}
J, J2 :integer;         {L: integer; ----number of datapoints}
NotEndcount : boolean;
CosTheta,PP3 : single;

begin
  Checkflag:=1;
  Jcount:=0;
  {----determine right position on the ring*******}
  If I=0 then     {----centerpoint of the ring}
  begin
    {----Cos theta = VectorData[3,L]   PoleCntP are 0,0 and 1 resp.}
    //If PVectorData^[three,L] > 0.8660254 then Cnt[0,0] := Cnt[0,0]+Exp(100*(PVectorData^[three,L]-1));
    If VectorData[3,L] > 0.8660254 then Cnt[0,0] := Cnt[0,0]+Exp(100*(VectorData[3,L]-1));
    CheckFlag:=0;
  end
  else
  begin
    FullRing:= 6*I;
    J:= Abs(Trunc(AZ/(Pi/(3*I))));
    J2:= (J+1) mod FullRing;
    //PP3:= PVectorData^[three,L] * PoleCntP[3,I,J];
    PP3:= VectorData[3,L] * PoleCntP[3,I,J];
    NotEndcount:= true;
    {----first count in anti-clockwise direction----}
    repeat
      CosTheta:=Abs(VectorData[1,L] * PoleCntP[1,I,J] + VectorData[2,L]*PoleCntP[2,I,J]+ PP3);
      //CosTheta:=Abs(PVectorData^[one,L] * PoleCntP[1,I,J] + PVectorData^[two,L]*PoleCntP[2,I,J]+ PP3);
      If CosTheta > 0.8660254 then
      begin
        Cnt[I,J] := Cnt[I,J] +  Exp(100*(CosTheta-1));
        J := (J-1+FullRing) mod FullRing;
        Inc(Jcount);
      end
      else CheckFlag :=2;
      If Jcount = FullRing then
      begin
        NotEndcount := false;
        break;
      end;
    until CheckFlag<>1;
    If NotEndcount then
    begin
      {----count in clockwise direction----}
      J:=J2;
      CheckFlag := 1;
      Repeat
        {CosTheta := Abs(PVectorData^[one,L] * PoleCntP[1,I,J] +
                       PVectorData^[two,L]*PoleCntP[2,I,J]+PP3);}
        CosTheta := Abs(VectorData[1,L] * PoleCntP[1,I,J] +
                        VectorData[2,L]*PoleCntP[2,I,J]+PP3);
        If CosTheta> 0.8660254 then
        begin
          Cnt[I,J] := Cnt[I,J] +  Exp(100*(CosTheta-1));
          J := (J+1) mod FullRing;
          Inc(JCount);
        end
        else CheckFlag := 2;
        If Jcount = FullRing then break;
      until CheckFlag <> 1;
    end; {end if Notendcount}
    If Jcount = 0 then CheckFlag:= 0; {****Label endcount:****}
  end; {if}
end;{procedure}


procedure TContDihFrm.Compute(Sender: TObject);
var KSECTOR,I,J1,J2,J, dummy,dumy, triangleheight: integer;
    M1,M2,n : integer;
    SideOneFlag, SideTwoFlag, Not3700,not2ndtriang, Not3850 : Boolean;
    m,k,J6K : integer;
    CONX1,CONY1,CONX2,CONY2,CONX3,CONY3,CONX4,CONY4 : single;
    zz, dummy2, dummy3 : integer;
    MaxAz, MaxDip: single;
    MaxStr : string[4];
    CValStr : string[4];
    strdummy1, strdummy2 : string[5];
    PenColorDummy, MetCanColorDummy : TColor;
    xpoints: array[0..2] of TPoint;
    textdummy: String;
    Step: Integer;
    R, G, B: Byte;
    strColor: String;

    const LowerEnd: Integer = 440;
          UpperEnd: Integer = 720;

begin
  PrepareMetCan(LHMetCan,LHMetafile, LHEnhMetafile, LHWriteWMF);
  SetBackground(Sender, LHMetCan.Handle);
  Case LHPlottype of
    pt_Contour, pt_Dihedra:
    begin
      north;
      firstSegment:=false;
  FOR KSECTOR := 1 TO 6 do  {ksector indicates a pie point}
  begin
    FOR I := 1 TO Rings do
    begin
      J2 := I*KSECTOR-1;
      {if i>0 then
        J2 := I*KSECTOR-1
      else j2:=0;}
      J1 := J2 - I + 1;
      For j:=J1 to J2 do
      begin
        IF I > 1 THEN
        begin
          M1 := (J-KSECTOR+1) MOD ((I-1)*6);
          M2 := (M1+1) MOD ((I-1)*6);
        end
        ELSE
        begin
          M1 := 0;
          M2 := 0;
        end;
        n := (J+1) MOD (I*6);
        IF CNT[I,J]+CNT[I,n]+CNT[I-1,M1]+CNT[I-1,M2] < CVAL[1] THEN continue;{GOTO NextPoint;}
        For k := 1 to NCON do
        begin
          CONX1 := 0;
          CONY1 := 0;
          CONX2 := 0;
          CONY2 := 0;
          CONX3 := 0;
          CONY3 := 0;
          CONX4 := 0;
          CONY4 := 0;
          SideOneFlag := false;
          SideTwoFlag := false;
          IF CNT[I,J]+CNT[I,n]+CNT[I-1,M1] >= CVAL[1] THEN
          begin
            {----check first side of the triangle}
            IF (CNT[I,J] <> CNT[I,n]) AND (CVAL[k] <= Max2(CNT[I,J],CNT[I,n])) AND
               (CVAL[k] >= MIN2(CNT[I,J],CNT[I,n])) THEN
            begin
              SideOneFlag := true;
              SetContours(CVAL[k], CNT[I,J], CNT[I,n], CXPT[I,J], CXPT[I,n],
                         CYPT[I,J], CYPT[I,n], CONX1, CONY1);
            end;
            { check second side of the triangle}
            Not3700:=true;
{triang1side2:}IF (CVAL[k] <= Max2(CNT[I,n],CNT[I - 1,M1])) AND (CVAL[k] >= Min2(CNT[I,n],CNT[I - 1,M1])) AND
              (CNT[I,n] <> CNT[I-1,M1]) THEN
            begin
              SideTwoFlag := true;
              SetContours(CVAL[k], CNT[I,n], CNT[I-1,M1], CXPT[I,n], CXPT[I-1,M1],
                         CYPT[I,n], CYPT[I-1,M1], CONX3, CONY3);
              IF SideOneFlag THEN
              begin
                CONX2 := CONX3;
                CONY2 := CONY3;
                Not3700:=false;
                {goto 3700;}
              end
              ELSE
              begin
                CONX1 := CONX3;
                CONY1 := CONY3;
              end;
            end;
            not2ndtriang:=true;
            If not3700 then
   {trils3:}  IF SideOneFlag or SideTwoFlag THEN  {else goto secondtriang}
              begin
                IF (CVAL[k]<=Max2(CNT[I,J],CNT[I-1,M1]))AND (CVAL[k]>=Min2(CNT[I,J],CNT[I-1,M1])) AND
                   (CNT[I,J]<>CNT[I-1,M1]) THEN
                   SetContours(CVAL[k], CNT[I,J], CNT[I-1,M1], CXPT[I,J], CXPT[I-1,M1],
                              CYPT[I,J], CYPT[I-1,M1], CONX2, CONY2);
              end
              else Not2ndTriang:=false;
{3700:}       IF ((CONX1<>CONX2) OR (CONY1<>CONY2)) and Not2ndTriang THEN
                DrawLine(CONX1, CONY1, CONX2, CONY2);
          end; {end if}
                  {check first side of second triangle}
{secondtriang} IF J = I*KSECTOR-1 THEN continue;
          Not3850:=true;
          IF (CVAL[k]<=Max2(CNT[I,n],CNT[I-1,M2])) AND (CVAL[k]>=Min2(CNT[I,n],CNT[I-1,M2])) AND
             (CNT[I,n]<>CNT[I-1,M2]) THEN
          begin
            IF SideTwoFlag THEN
            begin
              SetContours(CVAL[k], CNT[I,n], CNT[I-1,M2], CXPT[I,n], CXPT[I-1,M2],
                         CYPT[I,n], CYPT[I-1,M2], CONX4, CONY4);
              Not3850:=false;
            end
            ELSE SetContours(CVAL[k], CNT[I,n], CNT[I-1,M2], CXPT[I,n],
                            CXPT[I-1,M2],CYPT[I,n], CYPT[I-1,M2], CONX3, CONY3)
          end;
          {check second side of second triangle}
 {tri2S2} IF (CVAL[k]<=Max2(CNT[I-1,M1],CNT[I-1,M2])) AND (CVAL[k]>=Min2(CNT[I-1,M1],CNT[I-1,M2])) AND
            (CNT[I-1,M1]<>CNT[I-1,M2]) and Not3850 THEN
            SetContours(CVAL[k], CNT[I-1,M1], CNT[I-1,M2], CXPT[I-1,M1], CXPT[I-1,M2],
                         CYPT[I-1,M1], CYPT[I-1,M2], CONX4, CONY4);
{3850:}   IF (CONX3<>CONX4) OR (CONY3<>CONY4) THEN
            DrawLine(CONX3, CONY3, CONX4, CONY4);
        end;  {next k}
      end; {next j}
{3957:}
{Label}end; {NEXT I}
  end;  {NEXT KSECTOR}
  {******************************************************}
  {PlotPattern1:  }
  dec(LHz);
  NumberLabel;
  inc(LHz);
  k:=0;
  PenColorDummy:= LHMetCan.Pen.Color;
  FOR I := 0 TO Rings-1 do
  begin
    J6K := 6*I-k;
    FOR J := 0 TO J6K do
    begin
      WavelengthToRGB(UpperEnd, R, G, B);
      LHMetCan.Brush.Color:=RGB(R,G,B);
      LHMetCan.Pen.Color:=LHMetCan.Brush.Color;
      //MetCan.TextOut(Round(CenterX+CXPT[I,J]*FCT),Round(CenterY-CYPT[I,J]*FCT),intToStr(Round(Cnt[i,j])));
      IF CNT[I,J]<CVAL[1] THEN
      begin
        //Show counting net
        if blShowNet then SetPixel(LHMetCan.Handle,Round(XX+CXPT[I,J]*FCT),Round(YY-CYPT[I,J]*FCT),LHPen.Color);
      end
      ELSE
        IF CNT[I,J] > CVAL[NCON] THEN
        begin
          Case ContSymbolSize of
            0: SetPixel(LHMetCan.Handle,Round(XX+CXPT[I,J]*FCT),Round(YY-CYPT[I,J]*FCT),LHPen.Color);
            else Ellipse(LHMetCan.Handle,Round(XX+CXPT[I,J]*FCT)-ContSymbolSize,Round(YY-CYPT[I,J]*FCT)+ContSymbolSize,
                     Round(XX+CXPT[I,J]*FCT)+ContSymbolSize,Round(YY-CYPT[I,J]*FCT)-ContSymbolSize);
          end;
          //MetCan.Brush.Color := clRed;
          //MetCan.Brush.style:=bsSolid;
          //ExtFloodFill(LHMetCan.Handle,Round(XX+CXPT[I,J]*FCT),Round(YY-CYPT[I,J]*FCT),clBlack,
          //          FLOODFILLBORDER);
          //LHMetCan.Brush.Style:=bsClear;
          {Paint fill max concentration}
        end;
    end;  {NEXT J}
    k:=1;
  end;  {NEXT I}
  k:=0;
  Step:=Trunc((UpperEnd-LowerEnd)/ncon);
  For I:= 0 to Rings-1 do
  begin
    j6k:=6*i-K;
    For j:= 0 to j6k do
    begin
      if cnt[i,j]>cval[1] then
      begin
        for m:= ncon downto 1 do
        begin
          if (cnt[i,j]>cval[m]) and (cnt[i,j]<cval[m+1]) then
          begin
              //MetCan.Pen.Color := clBlue;
              {case m of
                1: color1:= clwhite;
                2: color1:= clyellow;
                3: color1:= clgreen;
                4: color1:= clred;
                5: color1:= clblue;
              end;}
              WavelengthToRGB(Round(LowerEnd+Step*(m-1)), R, G, B);
              //StrColor:= '$00' + IntToHex(B, 2) + IntToHex(G, 2) + IntToHex(R, 2);
              LHMetCan.Brush.Color:=RGB(R,G,B);
              //MetCan.Brush.Color:=Color1;
              //LHMetCan.Brush.Color:=Color1;
              //LHMetCan.Pen.Width:=0;
              LHMetCan.Pen.Color:=LHMetCan.Brush.Color;
              Case ContSymbolSize of
                0: SetPixel(LHMetCan.Handle,Round(XX+CXPT[I,J]*FCT),Round(YY-CYPT[I,J]*FCT),LHMetCan.Pen.Color);
                else LHMetCan.Ellipse(Round(XX+CXPT[I,J]*FCT)-ContSymbolSize,Round(YY-CYPT[I,J]*FCT)+ContSymbolSize, Round(XX+CXPT[I,J]*FCT)+ContSymbolSize,Round(YY-CYPT[I,J]*FCT)-ContSymbolSize);
              end;
              //If MetCan.pixels[Round(XX+CXPT[I,J]*FCT),Round(YY-CYPT[I,J]*FCT)] <> Color1 then
              //ExtFloodFill(MetCan.Handle,Round(XX+CXPT[I,J]*FCT),Round(yy-CYPT[I,J]*FCT),clBlack,
              //             FLOODFILLBORDER);   {FLOODFILLSURFACE oder FLOODFILLBORDER}
              //MetCan.Brush.style:=bsClear;
          end;
        end;
      end;
    end;
  end;
  LHMetCan.Brush.Style:=bsClear;
  LHMetCan.Pen.Color:=PenColorDummy;
  IF LHPlotType=pt_Dihedra then with self as tdihedrfrm do
  begin
      Lineation(LHMetCan.Handle,Canvas,xx,yy,r,AziEigenv[1],PlunEigenv[1],LHSymbSize,
                 0,Number1.checked,LHSymbFillFlag2,syCircle,LHFillBrush, LHPen.Handle);
      Lineation(LHMetCan.Handle,Canvas,xx,yy,r,AziEigenv[2],PlunEigenv[2],LHSymbSize,
                 1,Number1.checked,false,syRectangle,LHFillBrush, LHPen.Handle);
      Lineation(LHMetCan.Handle,Canvas,xx,yy,r,AziEigenv[3],PlunEigenv[3],LHSymbSize,
                 2,Number1.checked,LHSymbFillFlag,syTriangle,LHFillBrush2, LHPen.Handle);
  end;
  If Label1.Checked then With LHMetCan do
  begin
    {dummy2:=MetafileWidth-TextWidth('Max. value: 99.99');}
    dummy2:=MetafileWidth-Abs(LHMetCan.Font.Height) div 2 *20-5;
    dummy3:=6-LHMetCan.Font.Height;
    if imax = 0 then
    begin
      MaxAz := 0;
      If LHExtension=pln then maxdip:=0 else maxdip:=90;
    end
    else
    begin
      MaxAz := JMax /(3*Imax)*180;
      MaxDip := 90-(2*RadToDeg(ArcTan(Imax/Sqrt(2*Rings*Rings-Imax*Imax))));
      If LHExtension = PLN then
      begin
        MaxAz := trunc(MaxAz+180) mod 360+frac(MaxAz);
        MaxDip := 90-MaxDip;
      end;
    end;
    strdummy1:=IntToStr(Round(MaxAz));
    If MaxAz<100 then
    begin
      strdummy1:='0'+strdummy1;
      if Maxaz<10 then strdummy1:='0'+strdummy1;
    end;
    strdummy2:=IntToStr(Round(MaxDip));
    If MaxDip<10 then strdummy2:='0'+strdummy2;
    Str(Maxpercent:2:2, Maxstr);
    If not LHCopyMode then
    begin
      TextOut(dummy2,labeltop,'Max. value: '+MaxStr+ '%');
      TextOut(dummy2,labeltop+dummy3,'at : '+strdummy1+' / '+Strdummy2);
      if self is TContPlotFrm then Case LHExtension of
        cor,fpl,ptf: case lhstressaxis of
          0: Textout(Metafilewidth-200,MetafileHeight-2*dummy3,'Poles to fault planes');
          1: Textout(Metafilewidth-100,MetafileHeight-2*dummy3,'Fault lineations');
          2: Textout(Metafilewidth-100,MetafileHeight-2*dummy3,'p-axes');
          3: Textout(Metafilewidth-100,MetafileHeight-2*dummy3,'t-axes');
          4: Textout(Metafilewidth-100,MetafileHeight-2*dummy3,'b-axes');
        end;
      end;
      Textout(labelleft,MetafileHeight-3*dummy3,'Contours at:');
      {dummy2:=TextWidth('10;');}
      dummy2:=Abs(LHMetCan.Font.Height) div 2 *6;
      for zz := 0 to ncon-1 do
      begin
        Str(CVAL[zz+1]:3:2, CValStr);
        Textout(labelleft+zz*dummy2, MetafileHeight-2*dummy3,CValStr+' ');
      end;
    end;
    IF (LHPlotType=pt_Dihedra) and not LHCopyMode then with self as tdihedrfrm do
    begin
      dummy:=MetafileWidth+Font.Height div 2 *27-5;
      TextOut(dummy,MetafileHeight-6*dummy3,'            Eigenval.');
      For i:=3 downto 1 do   //**********vectors 1 to 3********
      begin
        Str(Eigenval[4-i]:2:2, vstr);
        TextDummy1:=IntToStr(Round(AziEigenv[i]));
        If Round(AziEigenv[i]) < 100 then
        begin
          TextDummy1:='0'+TextDummy1;
          If Round(AziEigenv[i]) < 10 then TextDummy1:='0'+TextDummy1;
        end;
        TextDummy2:=IntToStr(Round(PlunEigenv[i]));
        If Round(PlunEigenv[i]) < 10 then TextDummy2:='0'+TextDummy2;
        TextOut(dummy,MetafileHeight-6*dummy3+i*dummy3,'Sig'+IntToStr(i)+'  '+TextDummy1+'/'+TextDummy2+'  '+vstr);
      end;
    end;
  end;
  end;
  pt_SigmaTensor:
  begin
    north;
    DrawTensor(LHMetCan, Canvas, (Self as TDihedrFrm).AziEigenv, (Self as TDihedrFrm).PlunEigenv,
      LHSymbSize, LHSymbFillFlag, LHSymbFillFlag2, LHFillBrush, LHFillBrush2, LHPen.Handle);
  end;
  pt_SigmaDihedra:
  begin
    If not DrawDihedra(LHMetCan, (Self as TDihedrFrm).AziEigenv, (Self as TDihedrFrm).PlunEigenv,
      LHSymbFillFlag, LHSymbFillFlag2, LHFillBrush, LHFillBrush2, LHPen) then
    begin
      Screen.Cursor:=crDefault;
      Messagedlg('Plot failed.',mtError,[mbOk],0);
      LHfailed:=true;
      exit;
    end;
    north;
  end;
end; //case
Case LHPlotType of
pt_SigmaTensor, pt_SigmaDihedra:
begin
  //Write Explanation
      dummy:=6-LHMetCan.Font.Height;
      If not LHCopyMode and not LHPasteMode then
      begin
        If Label1.Checked then
        begin
          LHMetCan.Pen:=LHPen;
          IF (LHPlotType=pt_SigmaTensor) or (LHPlotType=pt_LambdaTensor) then with LHMetCan do
          begin
            dumy:=Round(LHSymbSize);//Round(Radius*LinearCircleRate);
            triangleheight:=Round(Radius*Sqrt(3)*LHSymbSize/320);
            if LHSymbFillFlag then Brush := LHFillBrush;
            Ellipse(CenterX+160-dumy, labeltop+dummy div 2-dumy,
                    CenterX+160+dumy, labeltop+dummy div 2+dumy);
            xpoints[0].x:=CenterX+160-triangleheight;
            xpoints[0].y:=labeltop+5*dummy div 2+dumy;
            xpoints[1].x:=CenterX+160+triangleheight;
            xpoints[1].y:=xpoints[0].y;
            xpoints[2].x:=CenterX+160;
            xpoints[2].y:=labeltop+5*dummy div 2-dumy;
            if LHSymbFillFlag2 then Brush := LHFillBrush2
            else Brush.Style:=bsClear;
            Polygon(xpoints);
            if LHSymbFillFlag or lhsymbfillflag2 then Brush.Style := bsClear;
            Rectangle(CenterX+160-dumy, labeltop+3*dummy div 2-dumy,
                      CenterX+160+dumy, labeltop+3*dummy div 2+dumy);
            Case LHPlotType of
              pt_SigmaDihedra, pt_SigmaTensor: Textdummy:='Sigma';
              pt_LambdaDihedra, pt_LambdaTensor: Textdummy:='Lambda';
            end;
            For dumy:=0 to 2 do
              TextOut(CenterX+180, labeltop+dummy*dumy, Textdummy+IntToStr(dumy+1));
          end;
          If (LHPlotType=pt_SigmaDihedra) or (LHPlotType=pt_LambdaDihedra) then
          begin
            dumy:=10;
            LHMetCan.Pen.Style:=psSolid;
            if lhsymbfillflag then
              SelectObject(LHMetCan.Handle,LHFillbrush.Handle)
            else LHMetCan.Brush.Style:=bsclear;
            LHMetCan.Rectangle(CenterX+160-dumy, labeltop+2*dummy div 2-dumy,
                             CenterX+160+dumy, labeltop+2*dummy div 2+dumy);
            if lhsymbfillflag2 then SelectObject(LHMetCan.Handle,LHFillbrush2.Handle)
            else LHMetCan.Brush.Style:=bsclear;

            LHMetCan.Rectangle(CenterX+160-dumy, labeltop+5*dummy div 2-dumy,
                             CenterX+160+dumy, labeltop+5*dummy div 2+dumy);
            LHMetCan.Brush.Style:=bsclear;
            LHMetCan.TextOut(CenterX+180, labeltop+2*dummy div 2-dumy, 'Compressive');
            LHMetCan.TextOut(CenterX+180, labeltop+5*dummy div 2-dumy, 'Tensile');
          end;
          LHMetCan.Brush.Style:=bsClear;
          If not LHCopyMode and not LHPasteMode then with LHMetCan do
          begin
            TextOut(labelleft,labeltop,LHLabel1);
            Case LHPlotType of
              pt_SigmaTensor, pt_SigmaDihedra: TextOut(labelleft,labeltop+dummy,'Sigma123');
              pt_LambdaTensor, pt_LambdaDihedra: TextOut(labelleft,labeltop+dummy,'Lambda123');
            end;
          end
          else with LHMetCan do
          begin
            TextOut(labelleft,labeltop, LHLabel1);
            TextOut(labelleft,labeltop+dummy,'Stresstensor');
          end;
        end;
      end;
end
end;
  LHMetCan.Free;
  inherited;
  case LHPlotType of
    pt_Contour:
    begin
      LHPlotInfo:=LHPlotInfo+#13#10+
      'Max. value: '+MaxStr+ ' %'+#13#10+
      'at : '+strdummy1+' / '+Strdummy2+#13#10+
      'Contours at:'+#13#10;
      for zz := 1 to ncon do
      begin
        Str(CVAL[zz]:3:2, CValStr);
        LHPlotInfo:=LHPlotInfo+CValStr+' ';
      end;
      if not AutoCont then  //set global contour values
      begin
        for zz:=1 to 16 do ContValues[zz]:=0;
        for zz:=1 to ncon do ContValues[zz]:=CVAL[zz];
      end;
    LHPlotInfo:=LHPlotInfo+#13#10+
      'Counting method: ';
    If Circlemethod then LHPlotInfo:=LHPlotInfo+'Circle, '+IntToStr(Rings)+' Rings'
    else LHPlotInfo:=LHPlotInfo+'Gauss, '+IntToStr(Rings)+' Rings';
    end;
    pt_Dihedra, pt_SigmaTensor, pt_SigmaDihedra:
    begin
      LHPlotInfo:=LHPlotInfo+#13#10+
        'Datasets skipped: '+IntToStr(Skipped)+#13#10+
        'Sigma1: '+FloatToString((Self as TDihedrFrm).AziEigenv[1], 3,0)+' / '+FloatToString((Self as TDihedrFrm).PlunEigenv[1],2,0)+'    '+FloatToString((Self as TDihedrFrm).Eigenval[3],1,2)+#13#10+
        'Sigma2: '+FloatToString((Self as TDihedrFrm).AziEigenv[2], 3,0)+' / '+FloatToString((Self as TDihedrFrm).PlunEigenv[2],2,0)+'    '+FloatToString((Self as TDihedrFrm).Eigenval[2],1,2)+#13#10+
        'Sigma3: '+FloatToString((Self as TDihedrFrm).AziEigenv[3], 3,0)+' / '+FloatToString((Self as TDihedrFrm).PlunEigenv[3],2,0)+'    '+FloatToString((Self as TDihedrFrm).Eigenval[1],1,2);
    end;
  end;
  Screen.Cursor := CrDefault;
END;


procedure TContDihFrm.DrawLine(X1, Y1, X2, Y2: single);
begin
  With LHMetCan do
  begin
    pen:=LHPen;
    MOVETO(Round(XX+X1*FCT), Round(yy-Y1*FCT));
    LINETO(Round(xx+X2*FCT), Round(yy-Y2*FCT));
    SetPixel(Handle,Round(xx+X2*FCT), Round(yy-Y2*FCT),clBlack);
    {if firstSegment then
    begin
     new(newSegment);
     with Segment^ do
     begin
       XStart:=X1;
       YStart:=Y1;
       XEnd:=X2;
       YEnd:=Y2;

       next:=NewSegment;
     end;
     newSegment^.prev:=segment;
     segment:=newSegment;
     segment^.next:=nil;

    end
    else
    begin
      firstSegment:=true;
      new(root);
      Segment := root;
      with Segment^ do
      begin
        XStart:=X1;
        YStart:=Y1;
        XEnd:=X2;
        YEnd:=Y2;
        prev:=nil;
        next:=nil;
     end; }
  end;
end;


procedure TContDihFrm.SetContours(var CVALUE: single;const CA, CB, XA, XB, YA, YB: single;
                                  var CONX, CONY: single);
var FACT : single;
begin
  FACT := (CVALUE-CA)/(CB-CA);  {distance away from point a in %}
  CONX := XA+FACT*(XB-XA);
  CONY := YA+FACT*(YB-YA);
end;


procedure TDihedrFrm.FormCreate(Sender: TObject; const AFilename: string;  const AExtension: TExtension);
begin
  AutoCont:=true;
  LHPlotType:=pt_Dihedra;
  saveas1.visible:=true;
  saveas1.enabled:=true;
  saveas1.onclick:=saveas1click;
  TecMainWin.SaveBtn.Enabled:=true;
  PlotType1.Enabled:=true;
  Plottype2.Enabled:=Plottype1.Enabled;
  Angelier1.Caption:='Dihedra (contoured)';
  Hoeppener1.Caption:='Stresstensor';
  ptAxes1.Caption:='Dihedra (tensor only)';
  Angelier2.Caption:=Angelier1.Caption;
  Hoeppener2.Caption:=Hoeppener1.Caption;
  ptAxes2.Caption:=ptAxes1.Caption;
  Angelier1.onclick:=angelier1click;
  Angelier2.onclick:=angelier1click;
  Hoeppener1.onclick:=angelier1click;
  Hoeppener2.onclick:=angelier1click;
  ptAxes1.onclick:=angelier1click;
  ptAxes2.onclick:=angelier1click;
  {Savedialog1:=TSavedialog.create(Self);     //for debugging purposes
  With Savedialog1 do
  begin
    Title:='Save counting points as';
    initialdir:=getworkdir;
    options:=[ofHidereadonly, ofOverwriteprompt];
    LHFilename:=Changefileext(AFilename,'.lin');
    Filter:='Lineation files (*.lin)|*.lin';
 end;
 Savedialog1.execute;}
    inherited;
  //else close;
end;

procedure TDihedrFrm.ContourData;
var f: TextFile;
    DipDir,Dip,Azimuth, Plunge,M1x,M1Y,M2X,M2Y,R1,R2,PIOVERI3,RC,CAZ,RR1,RR2,PTBearing,PTPlunge,
    AzimB,PlungeB, DipDir2,Dip2, DEgDip, DegDipDir, xxx,yyy,zzz, singledummy, dummy1, dummy2 : Single;
    i, j, j6, Sense, dummy, MyQuality, ndata : Integer;
    NoComment: boolean;
    Comment: String;

begin
  Screen.Cursor := CrHourGlass;
  Canvas.brush.style := bsClear;
  Rings:=20;
  skipped:=0;
  //CXPT:=VarArrayCreate([0,Rings*6,0,Rings],VarSingle);
  //CYPT:=VarArrayCreate([0,Rings*6,0,Rings],VarSingle);
  CXPT:=VarArrayCreate([0,Rings,0,Rings*6],VarSingle);
  CYPT:=VarArrayCreate([0,Rings,0,Rings*6],VarSingle);
  CNT:=VarArrayCreate([0,Rings,0,Rings*6],VarSingle);
  //PCXPT:=vararraylock(CXPT);
  //PCYPT:=vararraylock(CYPT);
  CreateMetafile( LHMetafile, LHEnhMetafile, LHWriteWMF);
  AssignFile(F,LHFilename);
  Reset(f);
  ndata:=0;
  while not eof(f) do
  begin
    Readln(f);
    inc(ndata)
  end;
  TecMainWin.Progressbar1.max:=ndata;
  closefile(f);
  AssignFile(F,LHFilename);
  Reset(f);
  //AssignFile(g,Savedialog1.filename);
  //rewrite(g);
  if not eof(f) then
  begin
  LHz:=1;
  //PCXPT^[0,0] := XX;
  //PCYPT^[0,0] := YY;
  CXPT[0,0] := 0;
  CYPT[0,0] := 0;
  CNT[0,0]:=0;
  zz:=0;
  FOR I := 1 TO Rings do
  begin
    J6 := 6*I-1;
    PIOVERI3:= PI/(3*I);
    RC:= I*1000/Rings;    //Radius of counting net:=1000;
    FOR J:= 0 TO J6 do
    begin
      CAZ:= J*PIOVERI3;
      //PCXPT^[I,J] := RC * SIN(CAZ)+XX;
      //PCYPT^[I,J] := RC * COS(CAZ)+YY;
      CXPT[I,J]:= RC*SIN(CAZ);
      CYPT[I,J]:= RC*COS(CAZ);
      CNT[I,J]:=0;
    end;
  end;
  //try
    WHILE NOT EOF(F) and not LHfailed do
    begin
      case LHExtension of
        COR,HOE,PEF,PEK,STF: ReadFPLDataset(f, Sense, MyQuality, DipDir, Dip,
           Azimuth, Plunge, LHfailed, NoComment, LHExtension, Comment);
        PTF: ReadPTFDataset(f,Sense,MyQuality,DipDir,Dip,Azimuth,Plunge,singledummy,singledummy,
             SingleDummy,SingleDummy,SingleDummy,SingleDummy, SingleDummy, dummy,LHFailed,NoComment);
        else LHfailed:=true;
      end;
      if not LHfailed and NoComment then
      begin
        If (Sense<>0) and (sense<>5) then
        begin
          SnDxToUpDn(Sense,DipDir,Dip, Azimuth,Plunge);
          FlaechLin(DipDir,Dip,trunc(Azimuth+180) mod 360 + frac(Azimuth),90-Plunge, false, Azimb,PlungeB);
          //IF AzimB=0 THEN AzimB:=1;
          //IF PlungeB=0 THEN PlungeB:=1;
          GetMidpoint (DipDir,Dip,M1X,M1Y,R1);
          FlaechLin(DipDir+180,90-Dip,AzimB,PlungeB,true,DipDir2,Dip2);
          GetMidpoint (DipDir2,Dip2,M2X,M2Y,R2);
          FOR I := 0 TO Rings do
          begin
            if i>0 then J6 := 6*I - 1
            else j6:=0;
            FOR J := 0 TO J6 do
            begin
              //RR1:=SQRT((M1X-PCXPT^[I,J])*(M1X-PCXPT^[I,J])+(M1Y-PCYPT^[I,J])*(M1Y-PCYPT^[I,J]));
              //RR2:=SQRT((M2X-PCXPT^[I,J])*(M2X-PCXPT^[I,J])+(M2Y-PCYPT^[I,J])*(M2Y-PCYPT^[I,J]));
              //Convert(PCXPT^[I,J],PCYPT^[I,J],PTBearing,PTPlunge);
              Convert(CXPT[I,J],CYPT[I,J],PTBearing,PTPlunge);
              RR1:=SQRT((M1X-CXPT[I,J])*(M1X-CXPT[I,J])+(M1Y-CYPT[I,J])*(M1Y-CYPT[I,J]));
              RR2:=SQRT((M2X-CXPT[I,J])*(M2X-CXPT[I,J])+(M2Y-CYPT[I,J])*(M2Y-CYPT[I,J]));
              Case sense of
                1: begin
                  IF ((RR1 >= R1) or (RR2 >= R2)) AND
                   ((RR1 <= R1) or (RR2 <= R2)) AND
                   ((RR1 > R1) OR (RR2 > R2)) THEN
                    begin
                      //Convert(PCXPT^[I,J],PCYPT^[I,J],PTBearing,PTPlunge);
                      //Convert(CXPT[I,J],CYPT[I,J],PTBearing,PTPlunge);
                      CNT[I,J]:=CNT[I,J]+1;
                      DegDipDir:=DegToRad(PTBearing);
                      DegDip:=DegToRad(PTPlunge);
                      xxx := COS(DegDipDir)*COS(DegDip);
                      yyy := SIN(DegDipDir)*COS(DegDip);
                      zzz := SIN(DegDip);
                      NA[1,1] := NA[1,1] + Sqr(xxx);
                      NA[2,2] := NA[2,2] + Sqr(yyy);
                      NA[3,3] := NA[3,3] + Sqr(zzz);
                      NA[1,2] := NA[1,2] + xxx*yyy;
                      NA[1,3] := NA[1,3] + xxx*zzz;
                      NA[2,3] := NA[2,3] + yyy*zzz;
                      NA[2,1] := NA[1,2];
                      NA[3,1] := NA[1,3];
                      NA[3,2] := NA[2,3];
                      inc(zz);
                      //WRITEln(G,round(PTBearing),',',round(PTPlunge));
                    END;
                END;
                2: begin
                  IF ((RR1 < R1) and (RR2 < R2)) or
                   ((RR1 > R1) and (RR2 > R2)) or
                   ((RR1 <= R1) AND (RR2 <= R2)) THEN
                  begin
                    //Convert(PCXPT^[I,J],PCYPT^[I,J],PTBearing,PTPlunge);
                    //Convert(CXPT[I,J],CYPT[I,J],PTBearing,PTPlunge);
                    CNT[I,J]:=CNT[I,J]+1;
                    DegDipDir:=DegToRad(PTBearing);
                    DegDip:=DegToRad(PTPlunge);
                    xxx := COS(DegDipDir)*COS(DegDip);
                    yyy := SIN(DegDipDir)*COS(DegDip);
                    zzz := SIN(DegDip);
                    NA[1,1] := NA[1,1] + Sqr(xxx);
                    NA[2,2] := NA[2,2] + Sqr(yyy);
                    NA[3,3] := NA[3,3] + Sqr(zzz);
                    NA[1,2] := NA[1,2] + xxx*yyy;
                    NA[1,3] := NA[1,3] + xxx*zzz;
                    NA[2,3] := NA[2,3] + yyy*zzz;
                    NA[2,1] := NA[1,2];
                    NA[3,1] := NA[1,3];
                    NA[3,2] := NA[2,3];
                    inc(zz);
                    //WRITEln(G,round(PTBearing),',',round(PTPlunge));
                  end;
                END; // case2
              end; //case
            end; //NEXT J
          end; //NEXT I
        end else inc(skipped); //if sense valid
        If not eof(f) then Inc(LHz);
        end else if not NoComment then dec(LHz); //if not lhfailed
      TecMainWin.Progressbar1.StepIt;
  end; //end of while-loop
  end else LHfailed:= true;
  //CLOSEFile(G);
  CLOSEFile(F);
  If LHfailed or fileused then
  begin
    dec(LHz);
    FileFailed(Self);
    TecMainWin.ProgressBar1.Visible:=false;
    close;
    exit;
  end
  else
  begin
    calceigenvect(zz,NA,AziEigenv, PlunEigenv,eigenval, SV,g6, LHfailed);
    //Bugfix 990525 swap sigma1 and sigma3 according to the convention used elsewhere
    Dummy1:=AziEigenv[1];
    Dummy2:=PlunEigenv[1];
    AziEigenv[1]:= AziEigenv[3];
    PlunEigenv[1]:=PlunEigenv[3];
    AziEigenv[3]:=Dummy1;
    PlunEigenv[3]:=Dummy2;
    findmaxcount;
    ContIntervals;
    Compute(Self);
  end;
  TecMainWin.ProgressBar1.Visible:=false;
END; {end SUB}

procedure TDihedrFrm.saveas1click(Sender: TObject);
var g: textfile;
    i: integer;
    SaveFilename: String;
begin
  with tsavedialog.create(self) do
  try
    title:='Save stress axes as';
    options:=[ofhidereadonly, ofoverwriteprompt];
    filter:='Dihedra files(*.dih)|*.dih';
    filename:=changefileext(lhfilename, '.dih');
    if execute then
    begin
      filename:=changefileext(filename,'.dih');
      assignfile(g, filename);
      try
        rewrite(g);
        For i:=1 to 3 do
          writeln(g, 'Sigma',IntToStr(i),'= ',FloatToString(AziEigenv[i],3,2),
                     FileListSeparator,FloatToString(PlunEigenv[i],2,2));
        writeln(g, 'Stress ratio= 0');
        writeln(g, 'Datasets total= ', LHz);
        write(g, 'Datasets skipped= ', skipped);
        SaveFileName:=filename;
        TecMainWin.WriteToStatusbar(nil , 'Written to file '+SaveFileName);
      finally
        closefile(g);
      end;
    end;
  finally
    free;
  end;
end;


procedure TDihedrFrm.GetMidpoint (FDipDir,FDip: Single; var MKX,MKY,RK : Single);
var degdipdir,h: single;
begin
  if fdip>=90 then fdip:=89.999;
  h:=1000*SQRT2*SIN(DegToRad((90-FDip))/2);
  RK:=(h*h+1000000)/2/h;
  DegDipDir:=DegToRad(90-FDipDir);
  MKX:=-(1000000-h*h)/2/h*Cos(DegDipDir);       //?round removed 9/1/98
  MKY:=-(1000000-h*h)/2/h*Sin(DegDipDir);       //?round removed 9/1/98
END;

procedure TDihedrFrm.Convert(FCXPT,FCYPT: Single; var FBearing,FPlunge: Single);
// var ahr, rech, rec, gqi :Single;
begin
  {IF FCYPT<XX THEN FBearing:= XX-FCYPT ELSE FBearing:= FCYPT-XX;
  IF FCXPT<YY THEN FPlunge:= YY-FCXPT ELSE FPlunge:= FCXPT-YY;
  IF FBearing=0 THEN FBearing:= 0.00000001;
  IF FPlunge=0 THEN FPlunge:= 0.00000001;
  ahr:= ArcTaN(FBearing/FPlunge);
  rech:= FBearing/(R*SQRT(2)*SIN(ahr));
  rec:= ArcTaN(rech/SQRT((-1)*rech*rech+1));
  gqi:= DegToRad(90)-(2*rec);
  FBearing:=RadToDeg(ahr);
  IF FCYPT > XX THEN
  begin
    IF FCXPT > YY THEN FBearing := (90 - FBearing) + 90;
  end
  else
    IF FCYPT < XX THEN
    begin
      IF FCXPT > YY THEN FBearing := FBearing + 180;
      IF FCXPT < YY THEN FBearing := (90 - FBearing) + 270;
    end;
    FPlunge:=RadToDeg(gqi);
    IF (FCYPT=XX) AND (FCXPT>YY) THEN FBearing:=FBearing+180;
    IF (FCXPT=YY) AND (FCYPT<XX) THEN FBearing:=FBearing+180;}
  FBearing:=RadToDeg(ArcTan2(FCXPT/1000,FCYPT/1000));
  FPlunge:=90-2*RadToDeg(ArcSin(Sqrt((sqr(FCXPT/1000)+Sqr(FCYPT/1000))/2)));
END; {end SUB}


procedure TDihedrFrm.Angelier1Click(Sender: TObject);
begin
  If (Sender=angelier1) or (Sender=Angelier2) then
  begin
    Caption:='Dihedra-calculation (contoured)- [' +ExtractFileName(LHFilename) +']';
    LHPlotType:=pt_Dihedra;
  end
  else If (Sender=Hoeppener1) or (Sender=Hoeppener2) then
  begin
    Caption:= 'Dihedra-calculation (tensor plot)- [' +ExtractFileName(LHFilename) +']';
    LHPlotType:=pt_SigmaTensor;
  end
  else If (Sender=ptAxes1) or (Sender=ptAxes2) then
  begin
    Caption:= 'Dihedra-calculation (tensor as dihedra)- [' +ExtractFileName(LHFilename) +']';
    LHPlotType:=pt_SigmaDihedra;
  end;
  inherited;
end;

end.
