unit Draw;

interface
uses windows, graphics, types, tecmain, menus, sysutils, classes, dialogs,
     Forms, Fileops, math, ExtCtrls;

function NorthAndCircle(FCanvas : TCanvas; FCenterX, FCenterY: integer; FRadius: word): Boolean;
procedure GreatCircle(FHandle: THandle; FormCanvas : TCanvas; FCenterX,FCenterY : Integer;
          FRadius: word ; FDipDir, FDip: single; Fz : Integer;  FNumbering: boolean; FPen: HPen; FLogPen: TLogPen);
procedure PartialGreatCircle(FHandle: THandle; FormCanvas : TCanvas; FCenterX,FCenterY : Integer;
          FRadius: Word ; FDipDir, FDip, FStartPitch, FHalfOpeningAngle: Single; Fz : Integer;  FNumbering: Boolean; FPen: HPen; FLogPen: TLogPen);          
procedure SmallCircle2(FHandle: THandle; FormCanvas: TCanvas ; FCenterX,FCenterY,FRadius: Integer;
          FAzimuth, FPlunge, FAperture, FSymbolSize: Single; FFillFlag: Boolean;
          FSymbol : TPlotSymbol; FBrush: TBrush; FPen: HPen);
procedure Striae(FHandle: THandle; FormCanvas : TCanvas; FCenterX,FCenterY : Integer; FRadius : Word;
                 FDipDir,FDip,FAzimuth,FPlunge, FSymbolSize: Single; FSense,FQuality,Fz : Integer;
                 FNumbering, FQualityOn, FFillFlag: boolean; Fext: TExtension; FPen: TPen; FPenBrush, FFillBrush: TBrush);
procedure HoepSymbol2(FHandle: HDC; FormCanvas : TCanvas; FCenterX,FCenterY : Integer; FRadius : Word;
                    var FSense : Integer; FQuality: Integer; FDipDir, FDip,FAzimuth,FPlunge,FSymbolsize : Single;
                    Fz: Integer; FNumbering, FQualityOn, FFillFlag: boolean; FPen: TPen; FPenBrush,FFillBrush: TBrush);
procedure CreateMetafile(var FMetafile : TMetafile; var FEnhMetafile : TEnhMetafile;
                         Fwritewmf: boolean);
procedure SetMetafileSize(var MyGraphic: TGraphic; Fwritewmf: boolean);
procedure PrepareMetcan(var FCanvas : TCanvas;FMetafile : TMetafile; FEnhMetafile : TEnhMetafile;
                        Fwritewmf: boolean);
procedure Lineation(FHandle: THandle; FormCanvas: TCanvas; FCenterX,FCenterY,FRadius: Integer;
          FAzimuth, FPlunge, FSymbolSize : Single; Fz: Integer; FNumbering,
          FFillFlag: Boolean;FSymbol : TPlotSymbol; FBrush: TBrush; FPen: HPen);
function CalculateMousePos(FPaintBox: TPaintBox; X,Y: Integer;
          var MouseAzimuth, MouseDip :Single; FPoleflag: Boolean): Boolean;

type flinedata=class(TObject)
  MyDC: HDC;
  i, a, b, segment,npoints: Integer;
  startpoint, lineendpoint: TPoint;
  fresult: boolean;
end;

Function WMFtoDXFHGL(
    DC:hDC;	          // handle of device context
    //MetafileHandle: THandle;
    HANDLETABLE: PHandletable; // address of metafile handle table
    METARECORD: PMetarecord;  // address of metafile record
    nObj: Integer;	  // count of objects
    MyVectorFile: TVectorgraphics   // address of optional data
   ): Integer; stdcall;

Function EMFtoDXFHGL(
    DC:hDC;	          // handle of device context
    HANDLETABLE: PHandletable; // address of metafile handle table
    EnhMETARECORD: PEnhMetaRecord;  // address of metafile record
    nObj: Integer;	  // count of objects
    MyVectorFile: TVectorgraphics   // address of optional data
   ): Integer; stdcall;

   // LineDDA
Function LineDDAProc(
    X: Integer;	// x-coordinate of point being evaluated
    Y: Integer;	// y-coordinate of point being evaluated
    lpData: flinedata 	// address of application-defined data
   ): Integer; stdcall;
Function LineTest(
    X: Integer;	// x-coordinate of point being evaluated
    Y: Integer;	// y-coordinate of point being evaluated
    lpData: flinedata 	// address of application-defined data
   ): Integer; stdcall;

function Polygon(DC: HDC; var Points; Count: Integer):boolean;
function Line(DC: HDC; X1, Y1, X2, Y2: Integer; FLogPen: TLogPen): boolean;

exports WMFtoDXFHGL, EMFtoDXFHGL, LineDDAProc, linetest;

implementation

uses printdia, VirtDip, Rotate;


function Polygon(DC: HDC; var Points; Count: Integer):boolean;
begin
  Windows.Polygon(DC, Points, Count);
end;

function NorthAndCircle(FCanvas : TCanvas; FCenterX, FCenterY: integer; FRadius: word): Boolean;
var  FHandle : THandle;
//************Draws north arrow and surrounding circle of stereonet*************
begin
  FHandle := FCanvas.Handle;
  {GetMem(Points,sizeof(Points^[0])*4);}
  try
    //Draw north arrow
    {I:=0;
    Points^[I].x:=FCenterX;
    Points^[I].y:=FCenterY-FRadius;
    Inc(I);
    Points^[I].x:=FCenterX;
    Points^[I].y:=FCenterY-FRadius-FRadius div 5;
    Inc(I);
    Points^[I].x:=FCenterX-FRadius div 50;
    Points^[I].y:=FCenterY-FRadius-FRadius div 7;
    PolyLine(FHandle,Points^[0],3);
    I:=0;
    Points^[I].x:=FCenterX-FRadius div 30;
    Points^[I].y:=FCenterY-FRadius-FRadius div 25;
    Inc(I);
    Points^[I].x:=FCenterX-FRadius div 30;
    Points^[I].y:=FCenterY-FRadius-FRadius div 8;
    Inc(I);
    Points^[I].x:=FCenterX+FRadius div 30;
    Points^[I].y:=FCenterY-FRadius-FRadius div 25;
    Inc(I);
    Points^[I].x:=FCenterX+FRadius div 30;
    Points^[I].y:=FCenterY-FRadius-FRadius div 8;
    PolyLine(FHandle,Points^[0],4);
    MoveToEx(FHandle,FCenterX, FCenterY-FRadius-FRadius div 5,Nil);
    LineTo(FHandle,FCenterX+FRadius div 50, FCenterY-FRadius-FRadius div 7);}
    {Draw enveloping circle  }
    Ellipse(FHandle,FCenterX-FRadius, FCenterY-FRadius, FCenterX+FRadius, FCenterY+FRadius);
    {Draw origin}
    MoveToEx(FHandle, FCenterX-FRadius div 30, FCenterY,Nil);
    LineTo(FHandle,FCenterX+FRadius div 30+1, FCenterY);
    MoveToEx(FHandle,FCenterX, FCenterY-FRadius div 30,Nil);
    LineTo(FHandle,FCenterX, FCenterY+FRadius div 30+1);
    {Draw ticks}
    MoveToEx(FHandle,FCenterX, FCenterY-FRadius,Nil);
    LineTo(FHandle,FCenterX, FCenterY-FRadius-20);
    MoveToEx(FHandle,FCenterX, FCenterY+FRadius,Nil);
    LineTo(FHandle,FCenterX, FCenterY+FRadius+10);
    MoveToEx(FHandle,FCenterX-FRadius, FCenterY,Nil);
    LineTo(FHandle,FCenterX-FRadius-10, FCenterY);
    MoveToEx(FHandle,FCenterX+FRadius, FCenterY,Nil);
    LineTo(FHandle,FCenterX+FRadius+10, FCenterY);
  finally
    //FreeMem(Points,sizeof(Points^[0])*4);
  end;
end;

procedure GreatCircle(FHandle: THandle; FormCanvas : TCanvas; FCenterX,FCenterY : Integer;
          FRadius: Word ; FDipDir, FDip: single; Fz : Integer;  FNumbering: boolean; FPen: HPen; FLogPen: TLogPen);
var Points: POpenPointArray;
    FText: String;
    PenStore: HPen;
    RotDipDir, RotDip, RP, C, D, DegRotRhra, DegRotAzi, DegRotPlun, AM,
    E1, E2, E3, ATA, FI, CosAM, SinAM, RR,
    E1E1,E1E2, E1E3, E2E3, E2E2, E3CC, BBE1E2, AA, BB, CC, DivRatio: single;
    N, I: Integer;
    NA: Array[1..3,1..2] of single;
    yy: array [1..3] of single;
begin
  PenStore:=SelectObject(FHandle,FPen);
  //************************************
  GetMem(Points,sizeof(Points^[0])*(PolySegments+1));
  try
    E1E1:=Frac(FDipDir);
    I:=Trunc(FDipDir);
    DegRotAzi := DegToRad((I+180) mod 360 + E1E1);
    If FDip=0 then FDip:=0.01; //Bugfix 20000128 build 1.150
    DegRotPlun:= DegToRad(90-FDip);
    RotDipDir:=(I+270) mod 360 + E1E1;
    IF (RotDipDir=90) OR (RotDipDir=180) OR (RotDipDir=270) THEN AM:= DegToRad(RotDipDir+0.01)
    else AM:= DegToRad(RotDipDir);
    E1E1:=COS(DegRotPlun);
    E1:= COS(DegRotAzi)*E1E1;
    E2:= SIN(DegRotAzi)*E1E1;
    E3:= SIN(DegRotPlun);
    E1E1:=E1*E1;
    E1E2:=E1*E2;
    E1E3:=E1*E3;
    E2E2:=E2*E2;
    E2E3:=E2*E3;
    CosAM:=Cos(AM);
    SinAM:=Sin(AM);
    C:=FRadius*SinAM;
    D:=FRadius*CosAM;
    Points^[0].x:=Round(FCenterX+C);
    Points^[0].y:=Round(FCenterY-D);
    n:=PolySegments;
    Points^[n].x:=Round(FCenterX-C);
    Points^[n].y:=Round(FCenterY+D);
    DivRatio:=Pi/Polysegments;
    RR:=FRadius*SQRT2;
    For N:= 1 to PolySegments-1 do
    begin
      //Rotation algorhythm begin**************
      DegRotRhra:= N*DivRatio;
      AA:= COS(DegRotRhra);
      BB:= 1-AA;
      CC:= SIN(DegRotRhra);
      E3CC:=E3*CC;
      BBE1E2:=BB*E1E2;
      NA[1,1]:= AA+BB*E1E1;
      NA[1,2]:= BBE1E2-E3CC;
      NA[2,1]:= BBE1E2+E3CC;
      NA[2,2]:= AA+BB*E2E2;
      NA[3,1]:= BB*E1E3-CC*E2;
      NA[3,2]:= BB*E2E3+CC*E1;
      FOR I:= 1 TO 3 do
        yy[I]:= NA[I,1]*CosAM + NA[I,2]*SinAM;
      IF yy[3]<0 THEN
      begin
        yy[1]:= -yy[1];
        yy[2]:= -yy[2];
        yy[3]:= -yy[3];
      end;
      IF yy[1]<>0 THEN ATA:= ArcTan(yy[2]/yy[1]);
      IF yy[1]<=0 THEN ATA:= ATA+PI;
      IF (yy[1]>0) AND (yy[2]<0) THEN ATA:= ATA+2*PI;
      IF (yy[1]=0) AND (yy[2]>0) THEN ATA:= PI/2;
      IF yy[3]>0.9999 THEN FI:= PI/2 else FI:= ArcTan(yy[3]/SQRT(1-yy[3]*yy[3]));//***
      //Rotation algorhythm end****************
      RP:= RR*SIN((Pi/2-FI)/2);
      Points^[n].x:=Round(FCenterX+Rp*Sin(ATA));
      Points^[n].y:=Round(FCenterY-Rp*Cos(ATA));
    end; //for
    PolyLine(FHandle,Points^[0],PolySegments+1);
  finally
    FreeMem(Points,sizeof(Points^[0])*(PolySegments+1));
  end;
  If FNumbering then //Numbering planes
  begin
    FText:=IntToStr(Fz+1);
    If D>=0 then
      if C<0 then TextOut(FHandle, Round(FCenterX-C), Round(FCenterY+D), PChar(FText),Length(FText)) //Lower right quadrant
      else TextOut(FHandle,Round(FCenterX-C-FormCanvas.TextWidth(FText)), Round(FCenterY+D), PChar(FText),Length(FText)) //Lower left quadrant
    else
      If C<0 then TextOut(FHandle,Round(FCenterX-C), Round(FCenterY+D-FormCanvas.TextHeight(FText)), PChar(FText),Length(FText)) //Upper right quadrant//
      else TextOut(FHandle,Round(FCenterX-C-FormCanvas.TextWidth(FText)), Round(FCenterY+D-FormCanvas.TextHeight(FText)), PChar(FText),Length(FText)); //Upper left quadrant
  end;
  //************************************
  SelectObject(FHandle,PenStore);
end;

procedure PartialGreatCircle(FHandle: THandle; FormCanvas : TCanvas; FCenterX,FCenterY : Integer;
          FRadius: Word ; FDipDir, FDip, FStartPitch, FHalfOpeningAngle: Single; Fz : Integer;  FNumbering: Boolean; FPen: HPen; FLogPen: TLogPen);
var Points1, Points2: POpenPointArray;
    FText: String;
    PenStore: HPen;
    RotDipDir, RotDip, RP, C, D, DegRotRhra, DegRotAzi, DegRotPlun, AM,
    E1, E2, E3, ATA, FI, CosAM, SinAM, RR,
    E1E1,E1E2, E1E3, E2E3, E2E2, E3CC, BBE1E2, AA, BB, CC, DivRatio: single;
    N, I, steps: Integer;
    NA: Array[1..3,1..2] of single;
    yy: array [1..3] of single;
begin
  PenStore:=SelectObject(FHandle,FPen);
  //************************************
  GetMem(Points1,sizeof(Points1^[0])*(PolySegments+1));
  GetMem(Points2,sizeof(Points2^[0])*(PolySegments+1));
  try
    Steps:=Abs(Trunc((FHalfOpeningAngle+FStartPitch)/(180/PolySegments)));
    E1E1:=Frac(FDipDir);
    I:=Trunc(FDipDir);
    DegRotAzi := DegToRad((I+180) mod 360 + E1E1);
    DegRotPlun:= DegToRad(90-FDip);
    RotDipDir:=(I+270) mod 360 + E1E1;
    IF (RotDipDir=90) OR (RotDipDir=180) OR (RotDipDir=270) THEN AM:= DegToRad(RotDipDir+0.01)
    else AM:= DegToRad(RotDipDir);
    E1E1:=COS(DegRotPlun);
    E1:= COS(DegRotAzi)*E1E1;
    E2:= SIN(DegRotAzi)*E1E1;
    E3:= SIN(DegRotPlun);
    E1E1:=E1*E1;
    E1E2:=E1*E2;
    E1E3:=E1*E3;
    E2E2:=E2*E2;
    E2E3:=E2*E3;
    CosAM:=Cos(AM);
    SinAM:=Sin(AM);
    C:=FRadius*SinAM;
    D:=FRadius*CosAM;
    Points1^[0].x:=Round(FCenterX+C);  //starting point
    Points1^[0].y:=Round(FCenterY-D);
    n:=PolySegments;
    Points1^[n].x:=Round(FCenterX-C);  //ending point
    Points1^[n].y:=Round(FCenterY+D);
    DivRatio:=Pi/Polysegments;
    RR:=FRadius*SQRT2;
    For N:= 1 to PolySegments-1 do
    begin
      //Rotation algorhythm begin**************
      DegRotRhra:= N*DivRatio;
      AA:= COS(DegRotRhra);
      BB:= 1-AA;
      CC:= SIN(DegRotRhra);
      E3CC:=E3*CC;
      BBE1E2:=BB*E1E2;
      NA[1,1]:= AA+BB*E1E1;
      NA[1,2]:= BBE1E2-E3CC;
      NA[2,1]:= BBE1E2+E3CC;
      NA[2,2]:= AA+BB*E2E2;
      NA[3,1]:= BB*E1E3-CC*E2;
      NA[3,2]:= BB*E2E3+CC*E1;
      FOR I:= 1 TO 3 do
        yy[I]:= NA[I,1]*CosAM + NA[I,2]*SinAM;
      IF yy[3]<0 THEN
      begin
        yy[1]:= -yy[1];
        yy[2]:= -yy[2];
        yy[3]:= -yy[3];
      end;
      IF yy[1]<>0 THEN ATA:= ArcTan(yy[2]/yy[1]);
      IF yy[1]<=0 THEN ATA:= ATA+PI;
      IF (yy[1]>0) AND (yy[2]<0) THEN ATA:= ATA+2*PI;
      IF (yy[1]=0) AND (yy[2]>0) THEN ATA:= PI/2;
      IF yy[3]>0.9999 THEN FI:= PI/2 else FI:= ArcTan(yy[3]/SQRT(1-yy[3]*yy[3]));//***
      //Rotation algorhythm end****************
      RP:= RR*SIN((Pi/2-FI)/2);
      Points1^[N].x:=Round(FCenterX+Rp*Sin(ATA));
      Points1^[N].y:=Round(FCenterY-Rp*Cos(ATA));
    end; //for
    PolyLine(FHandle,Points1^[0],PolySegments+1);
  finally
    FreeMem(Points1,SizeOf(Points1^[0])*(PolySegments+1));
    FreeMem(Points2,SizeOf(Points2^[0])*(PolySegments+1));
  end;
  If FNumbering then //Numbering planes
  begin
    FText:=IntToStr(Fz+1);
    If D>=0 then
      if C<0 then TextOut(FHandle, Round(FCenterX-C), Round(FCenterY+D), PChar(FText),Length(FText)) //Lower right quadrant
      else TextOut(FHandle,Round(FCenterX-C-FormCanvas.TextWidth(FText)), Round(FCenterY+D), PChar(FText),Length(FText)) //Lower left quadrant
    else
      If C<0 then TextOut(FHandle,Round(FCenterX-C), Round(FCenterY+D-FormCanvas.TextHeight(FText)), PChar(FText),Length(FText)) //Upper right quadrant//
      else TextOut(FHandle,Round(FCenterX-C-FormCanvas.TextWidth(FText)), Round(FCenterY+D-FormCanvas.TextHeight(FText)), PChar(FText),Length(FText)); //Upper left quadrant
  end;
  //************************************
  SelectObject(FHandle,PenStore);
end;

procedure SmallCircle2(FHandle: THandle; FormCanvas: TCanvas ; FCenterX,FCenterY,FRadius: Integer;
          FAzimuth, FPlunge, FAperture, FSymbolSize: Single; FFillFlag: Boolean;
          FSymbol : TPlotSymbol; FBrush: TBrush; FPen: HPen);
var i: integer;
    dummy, x1, y1, z1,x2,y2,z2,degAperture, degplunge, degAzimuth, AI, FI, RP,
    x,y,z, xe, ye: single;
begin
  SelectObject(FHandle,FPen);
  XE:=0;YE:=0;
  For I:=0 to SmallPolySegments+1 do
  begin
    dummy:=2*I*Pi/SmallPolySegments;
    degAperture:=DegToRad(FAperture);
    degplunge:=degtorad(fplunge);
    degAzimuth:=degtorad(fazimuth);
    Z1 := -Sin(degAperture)*COS(dummy);
    X1 :=  Cos(DegAperture)*Cos(degPlunge)-Z1*Sin(degPlunge);
    y1 :=  Sin(degAperture)*SIN(dummy);
    X2 :=  X1*Cos(degAzimuth)-y1*Sin(degAzimuth);
    y2 :=  y1*Cos(degAzimuth)+X1*Sin(degAzimuth);
    z2 :=  Z1*Cos(degPlunge)+Cos(degAperture)*Sin(degPlunge);
    IF z2<0 THEN
    begin
      X2 := -X2;
      y2 := -y2;
      z2 := -z2;
    end;
    IF ABS(X2)<0.0001 THEN
    begin
      AI := PI/2;
      IF y2<0 THEN AI := PI*3/2;
    end
    else
    begin
      AI := ABS(ArcTan(y2/X2));
      IF y2<0 THEN AI := 2*PI-AI;
      IF X2<0 THEN AI := PI - AI;
      IF ABS(y2)<0.001 then If X2<0 THEN AI := PI else AI := 0;
    end;
    IF ABS(1-z2)<0.0001 THEN FI:=PI/2
    else FI := ArcTan(z2/SQRT(1-z2*z2));
    RP := FRadius*SQRT2*SIN((PI/2-FI)/2);
    x := FCenterX+RP*SIN(AI);
    y := FCenterY-RP*COS(AI);
    Z := SQRT(Sqr(XE-x)+Sqr(YE-y));
    IF Z<FRadius/2 THEN //bugfix 980928
    begin
      MoveToEx(FHandle,Round(Xe), Round(Ye), nil);
      LineTo(FHandle, Round(x), Round(y));
    end;
    XE := x;
    YE := y;
  end;
end;

procedure Striae(FHandle: THandle; FormCanvas : TCanvas; FCenterX,FCenterY : Integer; FRadius : Word;
                 FDipDir,FDip,FAzimuth,FPlunge, FSymbolSize: Single; FSense,FQuality,Fz : Integer;
                 FNumbering, FQualityOn, FFillFlag: boolean; Fext: TExtension; FPen: TPen; FPenBrush, FFillBrush: TBrush);
var  DegAzimuth,DegArrow,h : single;
     StartX1,StartY1,StartX2,StartY2,EndX1,EndY1,EndX2,EndY2,EndX3,EndY3,
     EndX4,EndY4,startx5,starty5, endx5,endy5,N,C,D,i,fpolysegments,
     indexbuffer : Integer;
     Points : POpenPointArray;
     FText: String;
     cosfazimuth,sinfazimuth,xpf,ypf,dxp1,dyp1,dxp2,dyp2,dxp3,dyp3, dxq,dyq,xq,yq,xp1,yp1,
     xp2,yp2,xp3,yp3, DegfDipdir,x,y,r,openwidth,a,b,error,errorbuffer: single;
     BrushStore: HBrush;
     PenStore: HPen;
     PenstyleStore: TPenstyle;
begin
  //Calculations for lineation
  DegAzimuth := DegToRad(FAzimuth);
  DegArrow := DegToRad(ArrowAngle);
  CosFAzimuth:=Cos(DegAzimuth);
  SinFAzimuth:=Sin(DegAzimuth);
  h := FRadius*SQRT2*SIN(DegToRad((90-FPlunge))/2);
  C:=Round(SinFAzimuth*h);
  D:=Round(CosFAzimuth*h);
  XPf:=FCenterX+C;
  YPf:=FCenterY-D;
  //Correct lineation
  {If (Fext=COR) or (Fext=PEK) or (Fext=PTF) or (Fext=HOE) or (FExt=STF) then
  begin
    DegfDipDir := DegToRad(FDipDir-90);
    A:=Round(FRadius*Sin(DegfDipDir));
    B:=Round(FRadius*Cos(DegfDipDir));
    If FDip<90 then
    begin
    h:=FRadius*SQRT2*SIN(DegToRad((90-FDip))/2);
    DegfDipDir:=-DegfDipDir;
    X:=FCenterX-(FRadius*FRadius-h*h)/2/h*Cos(DegfDipDir);
    Y:=FCenterY+(FRadius*FRadius-h*h)/2/h*Sin(DegfDipDir);
    R:=(h*h + FRadius * FRadius)/2/h;
    OpenWidth:=ArcSin(FRadius/R);
    DegfDipDir:=DegToRad(FDipDir);
    fpolysegments:=100;
    GetMem(Points,sizeof(Points^[0])*(FPolySegments+1));
    errorbuffer:=10000;
    indexbuffer:=0;
    try
      For N:= 0 to fPolySegments do
      begin
        Points^[n].x:=Round(X+R*Sin(DegfDipDir-OpenWidth*(1-2*N/fPolySegments)));
        Points^[n].y:=Round(Y-R*Cos(DegfDipDir-OpenWidth*(1-2*N/fPolySegments)));
        error:=(Points^[n].x-xpf)*(Points^[n].x- xpf)+(Points^[n].y-ypf)*(Points^[n].y- ypf);
        if error<errorbuffer then
        begin
          errorbuffer:=error;
          indexbuffer:=n;
        end;
      end;
      xpf:=Points^[indexbuffer].x;
      ypf:=Points^[indexbuffer].y;
    finally
      FreeMem(Points,sizeof(Points^[0])*(fPolySegments+1));
    end;
  end;
end;}
  //Calculations for arrows
  dXQ:=FSymbolSize*CosFAzimuth;
  dYQ:=FSymbolSize*SinFAzimuth;
  If (FQualityOn and ((FQuality=quality_1) or (FQuality=quality_0)))
      or (not FQualityOn and (GlobalArrowStyle=0)) then
        IF FPen.Color=clBlack then SelectObject(FHandle,GetStockObject(BLACK_BRUSH))
        else If FPen.Color=clWhite then SelectObject(FHandle, GetStockObject(WHITE_BRUSH))
          else BrushStore:=SelectObject(FHandle, FPenBrush.Handle);
  PenStyleStore:=FPen.Style;
  FPen.Style:=psSolid;
  PenStore:=SelectObject(FHandle,FPen.Handle);
  If (FSense=3) or (FSense=4) then
  begin
    dXP1:=(AngSSArrowLength-AngSSArrowHeadLength)*SinFAzimuth;
    dYP1:=(AngSSArrowLength-AngSSArrowHeadLength)*CosFAzimuth;
    dXP2:=AngSSArrowLength*SinFAzimuth;
    dYP2:=AngSSArrowLength*CosFAzimuth;
    dXP3:=AngSSArrowHeadLength*tan(DegAngSSArrowAngle)*CosFAzimuth;
    dYP3:=AngSSArrowHeadLength*tan(DegAngSSArrowAngle)*SinFAzimuth;
    For i:=0 to 1 do
    begin
      If i=0 then //lower arrow
      begin
        XQ:=XPf+dXQ;
        YQ:=YPf+dYQ;
      end
      else
      begin //upper arrow
        XQ:=XPf-dXQ;
        YQ:=YPf-dYQ;
      end;
      If ((i=0) and (Fsense=4)) or ((i=1) and (Fsense=3)) then
      begin
       XP1:=XQ+dXP1;
       YP1:=YQ-dYP1;
       XP2:=XQ+dXP2;
       YP2:=YQ-dYP2;
      end
      else
      begin
       XP1:=XQ-dXP1;
       YP1:=YQ+dYP1;
       XP2:=XQ-dXP2;
       YP2:=YQ+dYP2;
      end;
      If i=0 then //lower arrow
      begin
        XP3:=XP1+dXP3;
        YP3:=YP1+dYP3;
      end
      else
      begin //upper arrow
        XP3:=XP1-dXP3;
        YP3:=YP1-dYP3;
      end;
      MoveToEx(FHandle,Round(XQ),Round(YQ), Nil);
      LineTo(FHandle,Round(XP1), Round(YP1));
      GetMem(Points,sizeof(Points^[0])*4);
      try
      n:=0;
      Points^[N].X:=Round(xp1);
      Points^[N].y:=Round(yp1);
      inc(n);
      Points^[N].X:=Round(xp2);
      Points^[N].y:=Round(yp2);
      inc(n);
      //LineDDA(Round(xp1),Round(yp1),Round(xp2),Round(yp2),@LineDDAProc,Longint(nil));
      Points^[N].X:=Round(xp3);
      Points^[N].y:=Round(yp3);
      inc(n);
      Points^[N].X:=Round(xp1);
      Points^[N].y:=Round(yp1);
      If (FQualityOn and (FQuality <> quality_3)) or (not FQualityOn and (GlobalArrowStyle<>2)) then
          Polygon(FHandle,Points^[0],4)
        else
          Polyline(FHandle,Points^[0],3);
      finally
        FreeMem(Points,sizeof(Points^[0])*4);
    end;  //try-finally
  end;   //for loop
  end
  else
    begin
      dxq:=AngNRArrowheadLength*tan(DegAngNRArrowAngle)*cosfazimuth;
      dyq:=-AngNRArrowheadLength*tan(DegAngNRArrowAngle)*sinfazimuth;
      dxp1:=AngNRArrowLength*sinfazimuth/2;
      dyp1:=AngNRArrowLength*cosfazimuth/2;
      GetMem(Points,sizeof(Points^[0])*4);
  try
    Case FSense of
      1:
      begin
        xp1:=XPF+dxp1; //tip of arrow on opposite side
        yp1:=YPF-dyp1;
        xQ:=XPF-(AngNRArrowLength/2-AngNRArrowheadLength)*sinfazimuth;
        YQ:=YPF+(AngNRArrowLength/2-AngNRArrowheadLength)*cosfazimuth;
        N:=1;
        Points^[N].x:=Round(XPF-dxp1); //tip of arrow where arrowhead is located
        Points^[N].y:=Round(YPF+dyp1);
      end;
      2:
      begin
        xQ:=XPF+(AngNRArrowLength/2-AngNRArrowheadLength)*sinfazimuth;
        YQ:=YPF-(AngNRArrowLength/2-AngNRArrowheadLength)*cosfazimuth;
        xp1:=XPF-dxp1; //tip of arrow on opposite side
        yp1:=YPF+dyp1;
        N:=1;
        Points^[N].x:=Round(XPF+dxp1); //tip of arrow where arrowhead is located
        Points^[N].y:=Round(YPF-dyp1);
      end;
      0, 5:
      begin
        xp1:=XPF+dxp1; //tip of arrow on opposite side
        yp1:=YPF-dyp1;
        N:=1;
        Points^[N].x:=Round(XPF-dxp1); //tip of arrow where arrowhead is located
        Points^[N].y:=Round(YPF+dyp1);
      end;
    end;
    MoveToEx(FHandle,Round(xp1),Round(yp1), nil); //Draw Arrow line
    LineTo(FHandle,Points^[N].x,Points^[N].y);
    If (fsense<>0) and (fsense<>5) then
    begin
      Dec(N);
      Points^[N].x:=Round(XQ+dxq);
      Points^[N].y:=Round(YQ-dyq);
      Inc(N,2);
      Points^[N].x:=Round(XQ-dxq);
      Points^[N].y:=Round(YQ+dyq);
      Inc(N);
      Points^[N].x:=Points^[0].x;
      Points^[N].y:=Points^[0].y;
      If (FQualityOn and (FQuality <> quality_3)) or (not FQualityOn and (GlobalArrowStyle<>2)) then
        Polygon(FHandle,Points^[0],4)
      else
        Polyline(FHandle,Points^[0],3);
      end;
  finally
    Freemem(Points,sizeof(Points^[0])*4);
  end;
 end;
 If (FQualityOn and ((FQuality=quality_1) or (FQuality=quality_0)))
      or (not FQualityOn and (GlobalArrowStyle=0)) then
      SelectObject(FHandle,GetStockObject(HOLLOW_BRUSH));
 //Draw circle of lineation
 if FFillFlag then
   If FFillBrush.Color=clWhite then BrushStore:=SelectObject(FHandle, GetStockObject(WHITE_BRUSH))
     else if FFillBrush.Color=clBlack then BrushStore:=SelectObject(FHandle, GetStockObject(BLACK_BRUSH))
       else BrushStore:=SelectObject(FHandle,FFillBrush.Handle)
  else SelectObject(FHandle,GetStockObject(HOLLOW_BRUSH));
 FSymbolSize:=FSymbolSize+1;
 Ellipse(FHandle,Round(XPf-FSymbolSize), Round(YPf-FSymbolSize),
                 Round(XPf+FSymbolSize), Round(YPf+FSymbolSize));
 if Ffillflag then SelectObject(FHandle, BrushStore);
 FPen.Style:=PenStyleStore;
 SelectObject(FHandle, PenStore);
 If FNumbering then  //Numbering lineations
  begin
    FText:=IntToStr(Fz+1);
    TextOut(FHandle, FCenterX+C+7, FCenterY-D-FormCanvas.TextHeight(FText) div 2, PChar(FText),Length(FText));
  end;
end;


procedure HoepSymbol2(FHandle: HDC; FormCanvas : TCanvas; FCenterX,FCenterY : Integer; FRadius : Word;
                    var FSense : Integer; FQuality: Integer; FDipDir, FDip,FAzimuth,FPlunge,FSymbolsize : Single;
                    Fz: Integer; FNumbering, FQualityOn, FFillFlag: boolean; FPen: TPen; FPenBrush,FFillBrush: TBrush);

var radhoep, DegArrow, DegAzimuth, AziLin,Pitch,nazim,nplunge, h, degnazim : single;
    XDif,YDif,XPf,YPf,N,FXPT,FYPT, xpf4, ypf4,xq,yq,XPfdif,Ypfdif,x,y : Integer;
    Points : POpenPointArray;
    FText: String;
    FillBrushStore, PenBrushStore: HBrush;
    PenStore: HPen;
begin
  PenStore:=SelectObject(FHandle, FPen.Handle);
  IF FPlunge = 90 THEN FPlunge := 89.99;
  IF FDip= 90 THEN FDip := 89.99;
  CorrectLineation(FDipDir, FDip, FAzimuth, FPlunge, FAzimuth, FPlunge); //BugFix 030118
  //for the case when lineation is not aligned on fault plane
  IF FAzimuth-FDipDir=270  THEN
    FAzimuth:=FAzimuth+0.01;
  IF FAzimuth-FDipDir=-270 THEN
    FAzimuth:=FAzimuth-0.01;
  If Abs(Fazimuth-FDipDir)=0 then FAzimuth:=FAzimuth+0.01;  //bugfix 981021 to fix dipslip problem
  DegAzimuth:=DegToRad(FAzimuth);
  Pitch := ArcTan((Tan(DegAzimuth-DegToRad(FDipDir)-Pi/2))/COS(DegToRad(FDip)));
  FSense:=ConvertSense(FSense, Pitch);
  AziLin := DegToRad(Round(FDipDir + 180) MOD 360);
  FXPT := Round(FRadius * SQRT2 * SIN(DegToRad(FDip) /2) * SIN(AziLin));
  FYPT := Round(FRadius * SQRT2 * SIN(DegToRad(FDip) /2) * COS(AziLin));
  XPF:=FCenterX+FXPT;
  YPF:=FCenterY-FYPT;
  //find great circle defined by lineation and pole to plane
  FlaechLin(Round (FDipDir + 180) MOD 360,90-fdip,FAzimuth,FPlunge,true,NAzim,NPlunge);
  h:=FRadius*SQRT2*SIN(DegToRad((90-NPlunge))/2);
  if h=0 then h:=0.0001;  //bugfix, to be removed
  DegNAzim:=-DegToRad(NAzim-90);
  X:=FCenterX-Round((FRadius*FRadius-h*h)/2/h*Cos(DegNAzim));
  Y:=FCenterY+Round((FRadius*FRadius-h*h)/2/h*Sin(DegNAzim));

  DegAzimuth:=arctan2(-FRadius*SQRT2*SIN(DegToRad(FDip)/2)*COS(AziLin)-((FRadius*FRadius-h*h)/2/h*Sin(DegNAzim)),
                       FRadius*SQRT2*SIN(DegToRad(FDip)/2)*SIN(AziLin)+((FRadius*FRadius-h*h)/2/h*Cos(DegNAzim)));
  If (Abs(trunc(FAzimuth-RadToDeg(DegAzimuth)) mod 180 + frac(FAzimuth)-frac(RadToDeg(DegAzimuth)))>90) {or (Degazimuth<0)} then
  //If Abs(Round(FAzimuth-trunc(RadToDeg(DegAzimuth))) mod 180) >90 then
    if FSense=se_normal then Fsense:=1
    else if FSense=1 then Fsense:= se_normal;
  //****calculations for each dataset****
  XDIF:=Round( HoepArrowheadLength*tan(DegHoepArrowAngle)*Cos(DegAzimuth));
  YDIF:=Round(-HoepArrowheadLength*tan(DegHoepArrowAngle)*Sin(DegAzimuth));
  XPfdif:=Round(HoepArrowLength*Sin(DegAzimuth)/2);
  YPfdif:=Round(HoepArrowLength*Cos(DegAzimuth)/2);
  GetMem(Points,sizeof(Points^[0])*3);
  try
    Case FSense of
      1:
      begin
        XPF4:=XPF+XPfdif; //tip of arrow on opposite side
        YPF4:=YPF-YPfdif;
        xQ:=XPF-Round((HoepArrowLength/2-HoepArrowheadLength)*Sin(DegAzimuth));
        YQ:=YPF+Round((HoepArrowLength/2-HoepArrowheadLength)*Cos(DegAzimuth));
        N:=1;
        Points^[N].x:=XPF-XPfdif; //tip of arrow where arrowhead is located
        Points^[N].y:=YPF+YPfdif;
      end;
      2:
      begin
        xQ:=XPF+Round((HoepArrowLength/2-HoepArrowheadLength)*Sin(DegAzimuth));
        YQ:=YPF-Round((HoepArrowLength/2-HoepArrowheadLength)*Cos(DegAzimuth));
        XPF4:=XPF-XPfdif; //tip of arrow on opposite side
        YPF4:=YPF+yPfdif;
        N:=1;
        Points^[N].x:=XPF+XPfdif; //tip of arrow where arrowhead is located
        Points^[N].y:=YPF-yPfdif;
      end;
      0, 5:
      begin
        XPF4:=XPF+XPfdif; //tip of arrow on opposite side
        YPF4:=YPF-YPfdif;
        N:=1;
        Points^[N].x:=XPF-XPfdif; //tip of arrow where arrowhead is located
        Points^[N].y:=YPF+YPfdif;
      end;
    end;
    MoveToEx(FHandle,XPF4,YPF4, nil); //Draw Arrow line
    LineTo(FHandle,Points^[N].x,Points^[N].y);
    Dec(N);
    Points^[N].x:=XQ+XDIF;
    Points^[N].y:=YQ-YDIF;
    Inc(N,2);
    Points^[N].x:=XQ-XDIF;
    Points^[N].y:=YQ+YDIF;
    If (fsense=se_normal) or (FSense=se_reverse) then
    begin
      If (FQualityOn and ((FQuality=quality_1) or (FQuality=quality_0)))
        or (not FQualityOn and (GlobalArrowStyle=0)) then
        Case FPen.Color of
          clBlack: PenBrushStore:=SelectObject(FHandle,GetStockObject(BLACK_BRUSH));
          clWhite: PenBrushStore:=SelectObject(FHandle,GetStockObject(WHITE_BRUSH));
        else PenBrushStore:=SelectObject(FHandle,FPenBrush.Handle);
      end;
      If (FQualityOn and (FQuality <> quality_3)) or (not FQualityOn and (GlobalArrowStyle<>2)) then
        Polygon(FHandle,Points^[0],3)
      else
        Polyline(FHandle,Points^[0],3);
    end;
  finally
    If (FQualityOn and ((FQuality=quality_1) or (FQuality=quality_0)))
      or (not FQualityOn and (GlobalArrowStyle=0)) then SelectObject(FHandle,GetStockObject(HOLLOW_BRUSH));
    Freemem(Points,sizeof(Points^[0])*3);
  end;
  //Draw pole of fault plane
  FSymbolsize:=FSymbolsize+1;
  if FFillFlag then
  begin
    Case FFillBrush.Color of
      clBlack: FillBrushStore:=SelectObject(FHandle,GetStockObject(BLACK_BRUSH));
      clWhite: FillBrushStore:=SelectObject(FHandle,GetStockObject(WHITE_BRUSH));
    else FillBrushStore:=SelectObject(FHandle, FFillBrush.Handle);
    end;
  end else SelectObject(FHandle,GetStockObject(HOLLOW_BRUSH));
  Ellipse(FHandle,round(XPf-FSymbolsize), round(YPf-FSymbolsize),
                  round(XPf+FSymbolsize), round(YPf+FSymbolsize));
  if FFillFlag then SelectObject(FHandle, FillBrushStore);
  SelectObject(FHandle, PenStore);
  IF FNumbering THEN {Numbering}
  begin
    FText:=IntToStr(Fz+1);
    TextOut(FHandle,FCenterX+FXPT+7,FCenterY-FYPT-FormCanvas.TextHeight(FText) div 2,PChar(FText),Length(FText));
  end;
end;


procedure CreateMetafile(var FMetafile : TMetafile; var FEnhMetafile : TEnhMetafile;
          Fwritewmf: boolean);
begin
  If FwriteWMF then
  begin
    FMetafile := TMetafile.Create;
    SetMetafileSize(TGraphic(FMetafile),Fwritewmf);
  end
  else
  begin
    FEnhMetafile := TEnhMetafile.Create;
    SetMetafileSize(TGraphic(FEnhMetafile), Fwritewmf);
  end;
end;


procedure SetMetafileSize(var MyGraphic: TGraphic; fWriteWMF: boolean);
begin
  If fWriteWMF then with MyGraphic as TMetafile do
  begin
    Height := MetafileHeight;
    Width  := MetafileWidth;
    MMWidth  := MetafileMMWidth;
    MMHeight := MetafileMMHeight;
    Inch := MetafileInch;
  end
  else with MyGraphic as TEnhMetafile do
  begin
    Height := MetafileHeight;
    Width  := MetafileWidth;
    //MMWidth  := MetafileMMWidth;
    //MMHeight := MetafileMMHeight;
  end;
end;


procedure PrepareMetcan(var FCanvas : TCanvas;FMetafile : TMetafile; FEnhMetafile : TEnhMetafile;
                        Fwritewmf: boolean);
var FHandle : THandle;
begin
  If FWriteWMF then FCanvas := TMetafileCanvas.CreateWithComment(FMetafile, 0, 'LH_Plot', 'TectonicsFP')
  else FCanvas := TEnhMetafileCanvas.CreateWithComment(FEnhMetafile, 0, 'LH_Plot', 'TectonicsFP');
  FHandle:=FCanvas.Handle;
  SetMapMode(FHandle, MM_Anisotropic);
  SetWindowOrgEx(FHandle, 0, 0, nil);
  If FWriteWMF then SetWindowExtEx(FHandle,metafilewidth,metafileheight, nil)
  else SetWindowExtEx(FHandle,1, 1, nil);
  SetBkColor(FHandle,clWhite);
  SetBkMode(FHandle, TRANSPARENT);
  SelectObject(FHandle,GetStockObject(HOLLOW_BRUSH));
  SelectObject(FHandle,GetStockObject(BLACK_PEN));
  With FCanvas do
  begin
    Font := TecMainWin.FontDialog1.Font;
    //Pen.Width := 1;
  end;
end;

procedure Lineation(FHandle: THandle;FormCanvas: TCanvas; FCenterX,FCenterY,FRadius: Integer;
          FAzimuth, FPlunge, FSymbolSize : Single; Fz: Integer; FNumbering,
          FFillFlag: Boolean;FSymbol : TPlotSymbol; FBrush: TBrush; FPen: HPen);
var RP, A,B : Single;
    Points4: Array[0..4] of TPoint;
    FText: String;
    BrushStore: HBrush;
    PenStore: HPen;
    Fred, Fred2: Single;
    Fred3: Integer;
begin
  if Abs(FPlunge) >= 89 then FPlunge:=89.99*Sgn(FPlunge);
  RP := FRadius*SQRT2*SIN(DegToRad(90-FPlunge)/2);
  A:=Rp*Sin(DegToRad(FAzimuth));
  B:=Rp*Cos(DegToRad(FAzimuth));
  PenStore:=SelectObject(FHandle,FPen);
  if FFillFlag then
  begin
    if (FSymbol<>systar) and  (FSymbol<>sycross) then
      If FBrush.Color=clWhite then BrushStore:=SelectObject(FHandle, GetStockObject(WHITE_BRUSH))
        else if FBrush.Color=clBlack then BrushStore:=SelectObject(FHandle, GetStockObject(BLACK_BRUSH))
             else BrushStore:=SelectObject(FHandle,FBrush.Handle);
  end else SelectObject(FHandle,GetStockObject(HOLLOW_BRUSH));
  Case FSymbol of   {Draw pole of lineation}
    syCross :
    begin
      MoveToEx(FHandle,Round(FCenterX+A-FSymbolSize), Round(FCenterY-B),Nil);
      LineTo(FHandle,Round(FCenterX+A+FSymbolSize+1), Round(FCenterY-B));
      MoveToEx(FHandle,Round(FCenterX+A), Round(FCenterY-B-FSymbolSize), Nil);
      LineTo(FHandle,Round(FCenterX+A), Round(FCenterY-B+FSymbolSize+1));
    end;
    syCircle :
    begin
      Ellipse(FHandle,Round(FCenterX+A-FSymbolSize), Round(FCenterY-B-FSymbolSize),
                       Round(FCenterX+A+FSymbolSize), Round(FCenterY-B+FSymbolSize));
    end;
    syStar :
    begin
      MoveToEx(FHandle,Round(FCenterX+A-FSymbolSize), Round(FCenterY-B),nil);
      LineTo(FHandle,Round(FCenterX+A+FSymbolSize+1), Round(FCenterY-B));
      MoveToEx(FHandle,Round(FCenterX+A), Round(FCenterY-B-FSymbolSize),nil);
      LineTo(FHandle,Round(FCenterX+A), Round(FCenterY-B+FSymbolSize+1));
      MoveToEx(FHandle,Round(FCenterX+A-FSymbolSize), Round(FCenterY-B-FSymbolSize),nil);
      LineTo(FHandle,Round(FCenterX+A+FSymbolSize+1), Round(FCenterY-B+FSymbolSize+1));
      MoveToEx(FHandle,Round(FCenterX+A+FSymbolSize), Round(FCenterY-B-FSymbolSize),nil);
      LineTo(FHandle,Round(FCenterX+A-FSymbolSize-1), Round(FCenterY-B+FSymbolSize+1));
    end;
    syTriangle :
    begin
      Points4[0].x:=Round(FCenterX+A-FSymbolSize);
      Points4[0].y:=Round(FCenterY-B+FSymbolSize);
      Points4[1].x:=Round(FCenterX+A);
      Points4[1].y:=Round(FCenterY-B-FSymbolSize);
      Points4[2].x:=Round(FCenterX+A+FSymbolSize);
      Points4[2].y:=Round(FCenterY-B+FSymbolSize);
      Points4[3].x:=Round(FCenterX+A-FSymbolSize);
      Points4[3].y:=Round(FCenterY-B+FSymbolSize);
      Polygon(FHandle,Points4,4);
    end;
    syRectangle :
      begin
        Windows.Rectangle(FHandle,Round(FCenterX+A-FSymbolSize), Round(FCenterY-B-FSymbolSize),
                 Round(FCenterX+A+FSymbolSize), Round(FCenterY-B+FSymbolSize));
      end;
    syRhombohedron:
    begin
      Points4[0].x:=Round(FCenterX+A);
      Points4[0].y:=Round(FCenterY-B-FSymbolSize);
      Points4[1].x:=Round(FCenterX+A+FSymbolSize);
      Points4[1].y:=Round(FCenterY-B);
      Points4[2].x:=Round(FCenterX+A);
      Points4[2].y:=Round(FCenterY-B+FSymbolSize);
      Points4[3].x:=Round(FCenterX+A-FSymbolSize);
      Points4[3].y:=Round(FCenterY-B);
      Points4[4].x:=Points4[0].x;
      Points4[4].y:=Points4[0].y;
      Polygon(FHandle,Points4,5);
    end;
    syNumber:
    begin
      FText:=IntToStr(Fz+1);
      Fred:=FormCanvas.Font.Height/2;
      Fred3:=Length(FText);
      Fred2:=Fred3*Fred/2;
      TextOut(FHandle, Round(FCenterX+A+Fred2), Round(FCenterY-B+Fred), PChar(FText), Fred3);
    end;
  end;
  if FFillFlag then
    if (FSymbol<>systar) and  (FSymbol<>sycross) then
      SelectObject(FHandle,BrushStore);
       SelectObject(FHandle,GetStockObject(HOLLOW_BRUSH));
  SelectObject(FHandle,PenStore);
  If FNumbering and (FSymbol<>syNumber) then  //Numbering poles if symbol<>number
  begin
    FText:=IntToStr(Fz+1);
    SelectObject(FHandle,GetStockObject(HOLLOW_BRUSH));
    TextOut(FHandle,Round(FCenterX+A+7), Round(FCenterY-B-FormCanvas.TextHeight(FText)/2), PChar(FText), Length(FText));
  end;
end;


function CalculateMousePos(FPaintBox: TPaintBox; X,Y: Integer;
           var MouseAzimuth, MouseDip :Single; FPoleflag: Boolean): Boolean;
var Dummy1,Dummy2: LongInt;
    MouseRadius, A, B: Single;
begin
  MouseRadius := 2*Min(FPaintbox.Width,FPaintbox.Height)/5;
  Dummy1:=2*X-FPaintbox.Width;
  Dummy2:=2*Y-FPaintbox.Height;
  if Dummy1*Dummy1+Dummy2*Dummy2<=4*MouseRadius*MouseRadius then
  begin
    FPaintBox.Cursor := crCross;
    if MouseRadius= 0 then MouseRadius := 0.01;
    A:=FPaintbox.Width/2-X;
    B:=Y-FPaintbox.Height/2;
    if B<>0 then
    begin
      MouseAzimuth:=RadToDeg(ArcTan(A/B));
      If B>0 then MouseAzimuth:= MouseAzimuth+180
      else
      begin
        If A>0 then MouseAzimuth:= MouseAzimuth+360;
        If Round(MouseAzimuth)=360 then MouseAzimuth:=0; //round bugfix build 1.149
      end;
    end
    else
      If A>0 then MouseAzimuth:= 270
      else if A=0 then MouseAzimuth := 0
        else MouseAzimuth := 90;
    MouseDip:=90-2*RadToDeg(ArcSin(Sqrt((A*A+B*B)/2)/MouseRadius));
    {$DEFINE Debugging}
    {$UNDEF Debugging}
    {$IFDEF DEBUGGING}
    With TecMainWin.StatusBar1.Panels do
    begin
      Items[1].Text := 'MouseAzim';
      Items[2].Text := FloatToString(MouseAzimuth, 3,1);
    end;
    {$ELSE}
    If FPoleFlag then
    begin
      MouseAzimuth:=Trunc((MouseAzimuth +180)) mod 360+ Frac(MouseAzimuth);
      MouseDip:=90-MouseDip;
    end;
    {$ENDIF}
    Result:=true;
  end
  else
  begin
    FPaintBox.Cursor := crDefault;
    Result:=false;
  end;
end;


Function WMFtoDXFHGL(
    DC:hDC;	                    // handle of device context
    HANDLETABLE: PHandletable;      // address of metafile handle table
    METARECORD: PMetarecord;        // address of metafile record
    nObj: Integer;	            // count of objects
    MyVectorFile: TVectorgraphics   // address of optional data
   ): Integer ; stdcall;


var Stringdummy: string;
   i,j,k, FRadius: integer;
   highbyte: byte;

begin
  If not MyVectorfile.notfirstknoten then with MyVectorfile do
  begin
    NoofGDIObj:=nobj;
    j:=Sizeof(MyOBJTable^[0])*(NoofGDIObj+1);
    GetMem(MyOBJTable,j);
    For i:=0 to NoofGDIOBJ do
      MyOBJTable^[i].GDIObjType:=gdi_void;
    notfirstknoten:=true;
  end;
  With METARECORD^ do
  case rdFunction of
    META_MOVETO:
    begin
      i:=0;
      j:=1;
      MyVectorFile.MoveTo(rdParm[j],rdParm[i]);
    end;
    META_LINETO:
    begin
      i:=1;
      j:=0;
      MyVectorFile.Lineto(rdParm[i],rdParm[j]);
    end;
    META_ELLIPSE:
    begin
      i:=1;
      j:=0;
      k:=3;
      FRadius:= round((rdParm[i]-rdParm[k])/2);
      MyVectorFile.Circle(rdParm[i]-FRadius,rdParm[j]-FRadius,FRadius);
    end;
    META_POLYLINE:
    begin
      If MyVectorFile.IsDXF then with MyVectorFile as TDXFFile do
      begin
        BeginPolyLine(false);
        i:= rdSize-4;
        while i>0 do
        begin
          Vertex(rdParm[i-1], rdParm[i]);
          dec(i,2);
        end;
        SeqEnd;
      end
      else with MyVectorFile do
      begin
        i:= rdSize-4;
        MoveTo(rdParm[i-1],rdParm[i]);
        dec(i,2);
        while i>0 do
        begin
          Lineto(rdParm[i-1],rdParm[i]);
          dec(i,2);
        end;
      end;
    end;
    META_POLYGON:
    begin
      If MyVectorFile.IsDXF then with MyVectorFile as TDXFFile do
      begin
        BeginPolyLine(true);
        i:= rdSize-4;
        while i>0 do
        begin
          Vertex(rdParm[i-1], rdParm[i]);
          dec(i,2);
        end;
        SeqEnd;
      end
      else with MyVectorFile do
      begin
        i:= rdSize-4;
        MoveTo(rdParm[i-1],rdParm[i]);
        dec(i,2);
        while i>0 do
        begin
          Lineto(rdParm[i-1],rdParm[i]);
          dec(i,2);
        end;
        i:= rdSize-4;
        Lineto(rdParm[i-1],rdParm[i]);
      end;
    end;
    META_RECTANGLE:
    begin
      i:= rdSize-6;
      MyVectorFile.Rectangle(rdParm[i], rdParm[i-1], rdParm[i+2], rdParm[i+1]);
    end;
    META_TEXTOUT:
    begin
      Stringdummy:='';
      for i:= 1 to rdSize-6 do
      begin
        highbyte:=rdParm[i] div 256;
        Stringdummy:=Stringdummy+char(rdParm[i] mod 256); //lowbyte
        If highbyte<>0 then Stringdummy:=Stringdummy+char(highbyte);
      end;
      i:= rdSize-4;
      j:= rdSize-5;
      MyVectorFile.Text(rdParm[i],rdParm[j],Stringdummy);
    end;
    META_SETPIXEL:
    begin
      i:=2;
      j:=3;
      If MyVectorFile.IsDXF then with MyVectorFile as TDXFFile do
        Point(rdParm[i],rdParm[j]);
    end;
    META_SETROP2:
    begin
      //i:=0;
      //MyVectorFile.SetPenstyle(rdParm[i]);
      //MyVectorFile.SetPenstyle(META_SETROP2);
    end;
    META_CREATEPENINDIRECT: With MyVectorfile.MyOBJTable^[rdParm[rdSize]] do
    begin
      i:=0;
      GDIObjType:=gdi_Pen;
      With Pen do
      begin
        lopnStyle:=rdParm[i];
        inc(i);
        lopnWidth.x:=rdParm[i];
        inc(i,2);
        lopnColor:=rdParm[i];
      end;
    end;
    META_CREATEBRUSHINDIRECT: With MyVectorfile.MyOBJTable^[rdParm[rdSize]] do
    begin
      i:=0;
      GDIObjType:=gdi_Brush;
      With Brush do
      begin
        lbStyle:=rdParm[i];
        inc(i,2);
        lbColor:=rdParm[i];
        inc(i);
        lbHatch:=rdParm[i];
      end;
    end;
    META_CREATEFONTINDIRECT:
    begin
      {myvectorfile.ParamAsTextOut(999999);
      For i:=0 to rdsize do
        myvectorfile.ParamAsTextOut(rdParm[i]);}
    end;
    META_SELECTOBJECT: With myvectorfile do
    begin
      i:=0;
      case MyOBJTable^[rdParm[i]].GDIObjType of
        gdi_Pen: SetPenstyle(MyOBJTable^[rdParm[i]].Pen);
      end;
    end;
    META_DELETEOBJECT: With myvectorfile do
    begin
      i:=0;
      MyOBJTable^[rdParm[i]].GDIObjType:=gdi_void;
    end;
  end; //case
  result:=1;
end;

Function EMFtoDXFHGL(
    DC:hDC;	          // handle of device context
    HANDLETABLE: PHandletable; // address of metafile handle table
    EnhMETARECORD: PEnhMetaRecord;  // address of metafile record
    nObj: Integer;	  // count of objects
    MyVectorFile: TVectorgraphics   // address of optional data
   ): Integer ; stdcall;
var Stringdummy: string;
    i,j,k, FRadius: integer;

begin
  {For i:=0 to nObj-1 do
    MyVectorFile.extracthandletable(HANDLETABLE^.objectHandle[i]);}
  If not MyVectorfile.notfirstknoten then with MyVectorfile do
  begin
    NoofGDIObj:=nobj;
    j:=Sizeof(MyOBJTable^[0])*(NoofGDIObj+1);
    GetMem(MyOBJTable,j);
    For i:=0 to NoofGDIOBJ do
      MyOBJTable^[i].GDIObjType:=gdi_void;
    notfirstknoten:=true;
  end;
  with EnhMETARECORD^ do
  case iType of  //constants can be found in unit 'windows'
    EMR_MOVETOEX: //27
    begin
      i:=0;
      j:=1;
      MyVectorFile.MoveTo(dParm[i],dParm[j]);
    end;
    EMR_LINETO:
    begin
      i:=0;
      j:=1;
      MyVectorFile.Lineto(dParm[i],dParm[j])
    end;
    EMR_ELLIPSE:
    begin
      i:=0;
      j:=1;
      k:=2;
      FRadius:=round((dParm[k]-dParm[i])/2);
      MyVectorFile.Circle(dParm[i]+FRadius,dParm[j]+FRadius,FRadius);
    end;
    EMR_RECTANGLE:
    begin
      i:=0;
      MyVectorFile.Rectangle(dParm[i], dParm[i+1], dParm[i+2], dParm[i+3]);
    end;
    EMR_POLYLINE16:
    begin
      If MyVectorFile.IsDXF then with MyVectorFile as TDXFFile do
      begin
        BeginPolyLine(false);
        for i:= (nSize div 4) - 3 downto 5 do
          Vertex(dParm[i] mod 65536, dParm[i] div 65536);
        SeqEnd;
      end
      else with MyVectorFile do
      begin
        i:= (nSize div 4) - 3;
        MoveTo(dParm[i] mod 65536, dParm[i] div 65536);
        for i:= (nSize div 4) - 4 downto 5 do
          Lineto(dParm[i] mod 65536, dParm[i] div 65536);
      end;
    end;
    EMR_POLYGON16:
    begin
      If MyVectorFile.IsDXF then with MyVectorFile as TDXFFile do
      begin
        BeginPolyLine(true);
        for i:= (nSize div 4) - 3 downto 5 do
          Vertex(dParm[i] mod 65536, dParm[i] div 65536);
        SeqEnd;
      end
      else with MyVectorFile do
      begin
        i:= (nSize div 4) - 3;
        MoveTo(dParm[i] mod 65536, dParm[i] div 65536);
        for i:= (nSize div 4) - 4 downto 5 do
          Lineto(dParm[i] mod 65536, dParm[i] div 65536);
        i:= (nSize div 4) - 3;
        Lineto(dParm[i] mod 65536, dParm[i] div 65536);
      end;
    end;
    EMR_EXTTEXTOUTW:
    begin
      Stringdummy:='';
      j:=9;
      k:=0;
      for i:= 17 to 17+dParm[j] div 2 do
      begin
        Stringdummy:=Stringdummy+char((dParm[i] mod 65536) mod 256);//lowbyte of lowword
        inc(k);
        if k=dParm[j] then break;
        Stringdummy:=Stringdummy+char((dParm[i] div 65536) mod 256);//lowbyte of highword
        inc(k);
        if k=dParm[j] then break;
      end;
      i:=7;
      j:=8;
      MyVectorFile.Text(dParm[i],dParm[j],Stringdummy);
    end;
    EMR_SETPIXELV:
    begin
      i:=0;
      j:=1;
      If MyVectorFile.IsDXF then with MyVectorFile as TDXFFile do
        Point(dParm[i],dParm[j]);
    end;
    EMR_CREATEPEN:  //38
    begin
      i:=0;
      With MyVectorfile.MyOBJTable^[dParm[i]] do
      begin
        GDIObjType:=gdi_Pen;
        With Pen do
        begin
          inc(i);
          lopnStyle:=dParm[i];
          inc(i);
          lopnWidth.x:=dParm[i];
          inc(i,2);
          lopnColor:=dParm[i];
        end;
      end;
    end;
    EMR_CREATEBRUSHINDIRECT: //39
    begin
      i:=0;
      With MyVectorfile.MyOBJTable^[dParm[i]] do
      begin
        GDIObjType:=gdi_Brush;
        With Brush do
        begin
          inc(i);
          lbStyle:=dParm[i];
          inc(i);
          lbColor:=dParm[i];
          inc(i);
          lbHatch:=dParm[i];
        end;
      end;
    end;
    EMR_EXTCREATEFONTINDIRECTW: //82
    begin
      i:=0;
      With MyVectorfile.MyOBJTable^[dParm[i]] do
      begin
        GDIObjType:=gdi_Font;
        With Font do
        begin
          inc(i);
          lfheight:=dParm[i];
          inc(i);
          lfwidth:=dParm[i];
          //MyVectorFile.ParamAsTextOut(999999);
          //MyVectorFile.ParamAsTextOut(lfheight);
          //MyVectorFile.ParamAsTextOut(999999);
        end;
      end;

    end;
    EMR_SELECTOBJECT: with MyVectorfile do //37
    begin
      i:=0;
      if dParm[i]>0 then //bugfix 981109
        case MyOBJTable^[dParm[i]].GDIObjType of
          gdi_Pen: SetPenstyle(MyOBJTable^[dParm[i]].Pen);
          gdi_brush: ;
          gdi_font:;
        end;
    end;
    EMR_DELETEOBJECT: With myvectorfile do
    begin
      i:=0;
      MyOBJTable^[dParm[i]].GDIObjType:=gdi_void;
    end;
  end; //case
  result:=1;
end;

function Line(DC: HDC; X1, Y1, X2, Y2: Integer; FLogPen: TLogPen): boolean;
var mylinedata: fLinedata;
begin
  if fLogpen.lopnStyle=PS_SOLID then
  begin
    if MoveToEx(DC, X1,Y1, nil) then result:=LineTo(DC, X2, Y2)
    else result:=false;
  end
  else
  begin
    MyLinedata:=fLinedata.create;
    with mylinedata do
    begin
      MyDC:=DC;
      i:=0;
      segment:=0;
      lineendpoint.x:=x2;
      lineendpoint.y:=y2;
      npoints:=0;
    end;
    LineDDA(x1,y1,x2,y2,@LineTest, longint(mylinedata));
    dec(mylinedata.npoints);
    case fLogpen.lopnStyle of
      PS_DASH:
      begin
        mylinedata.a:=10;
        mylinedata.b:=5;
      end;
      PS_DOT:
      begin
        mylinedata.a:=flogpen.lopnwidth.x;
        mylinedata.b:=flogpen.lopnwidth.x+1;
      end;
      PS_DASHDOT:
      begin
        mylinedata.a:=10;
        mylinedata.b:=5;
      end;
      PS_DASHDOTDOT:
      begin
        mylinedata.a:=10;
        mylinedata.b:=5;
      end;
    end; //case
    LineDDA(x1,y1,x2,y2,@LineDDAProc, longint(mylinedata));
    result:=mylinedata.fresult;
    myLinedata.free;
  end;
end;

Function LineTest(
    X: Integer;	// x-coordinate of point being evaluated
    Y: Integer;	// y-coordinate of point being evaluated
    lpData: flinedata	// address of application-defined data
   ): Integer; stdcall;
begin
  inc(lpdata.npoints);
end;

Function LineDDAProc(
    X: Integer;	// x-coordinate of point being evaluated
    Y: Integer;	// y-coordinate of point being evaluated
    lpData: flinedata	// address of application-defined data
   ): Integer; stdcall;
begin
  with lpData do
  begin
    if i=segment*(a+b) then
    begin
      Startpoint.x:=x;
      Startpoint.y:=y;
    end;
    if (i=segment*(a+b)+a) or (i=npoints) then
    begin
      if movetoex(MyDC,Startpoint.x,Startpoint.y, nil) then
      fresult:=Lineto(MyDC,X,Y) else fresult:=false;
      inc(segment);
    end;
    inc(i);
  end;
end;


end.
{createpenindirect:
With MyVectorFile do
    begin
      If not notfirstKnoten then
      begin
        New(Root);
        NeuerKnoten:=Root;
        notFirstKnoten:=true;
      end
      else
      begin
        New(NeuerKnoten);
        AktuellerKnoten^.Next:=NeuerKnoten;
      end;
      AktuellerKnoten:=NeuerKnoten;
      With AktuellerKnoten^ do
      Begin
        i:=0;
        GDIObjType:=gdiPen;
        With Pen do
        begin
          lopnStyle:=rdParm[i];
          inc(i);
          lopnWidth.x:=rdParm[i];
          inc(i,2);
          lopnColor:=rdParm[i];
        end;
        GDIObj:=rdParm[rdSize];
        next:=nil;
      end;
      inc(NoOfGDIObj);
    end;}

    {deleteobject:
    With MyVectorFile do
    begin
      If NoOfGDIObj>0 then
      begin
        AktuellerKnoten:=Root;
        i:=0;
        If NoOfGDIObj=1 then
        begin
          If rdParm[i] = AktuellerKnoten^.GDIObj then
          begin
            Dispose(AktuellerKnoten);
            notfirstKnoten:=false;
            dec(NoOfGDIObj);
          end;
        end
        else
        While AktuellerKnoten^.Next<>nil do
        begin
          If rdParm[i] = AktuellerKnoten^.GDIObj then
          begin
            If AktuellerKnoten=Root then
            begin
              Root:=Root^.Next;
              Dispose(AktuellerKnoten);
            end
            else
            begin
            NeuerKnoten^.Next:=AktuellerKnoten^.Next;
            Dispose(AktuellerKnoten);
            AktuellerKnoten:=NeuerKnoten;
            end;
            dec(NoOfGDIObj);
          end;
          If AktuellerKnoten^.Next<> nil then
          begin
            NeuerKnoten:=AktuellerKnoten;
            AktuellerKnoten:=AktuellerKnoten^.Next;
          end;
        end;
      end;
    end;}

    {selectobject:
    With MyVectorFile do
    begin
      If NoOfGDIObj>0 then
      begin
        AktuellerKnoten:=Root;
        i:=0;
        If NoOfGDIObj=1 then
        begin
          If rdParm[i] = AktuellerKnoten^.GDIObj then
          case AktuellerKnoten^.GDIObjType of
            gdiPen: SetPenstyle(AktuellerKnoten^.Pen);
          end;
        end
        else
        While AktuellerKnoten^.Next<>nil do
        begin
          If rdParm[i] = AktuellerKnoten^.GDIObj then
          case AktuellerKnoten^.GDIObjType of
            gdiPen: SetPenstyle(AktuellerKnoten^.Pen);
          end;
          If AktuellerKnoten^.Next<> nil then AktuellerKnoten:=AktuellerKnoten^.Next;
        end;
      end;
    end;}
