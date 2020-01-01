unit Bingha;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Draw, Menus, PrintDia,
  Printers, Clipbrd, Types, LowHem, math;

type
  TBinghamForm = class(TLHWin)
    procedure Compute(Sender: TObject); override;
    procedure FormCreate(Sender: TObject;const AFilename : String; const AExtension: TExtension); override;
    procedure Draw(Sender: TObject);
  protected
    AziEigenv,PlunEigenv, Eigenval :  T1Sing1by3;
    sv, g6: single;
  end;

procedure CalcEigenvect(nData: Integer; var fNA: T2Sing1by3;
          var fAziEigenv,fPlunEigenv, fEigenval: t1sing1by3;
          var fSV, fg6: single; var ffailed: boolean);

implementation

uses fileops, tecmain, Exprtdia;

procedure TBinghamForm.Compute(Sender: TObject);
var
  xxx,yyy,zzz,DipDir, Dip, DegDipDir, DegDip: single;
  Fn: TextFile;
  NA: T2Sing1by3;
  Nocomment : boolean;
  comment: String;

begin
  Screen.Cursor := CrHourGlass;
  PrepareMetCan(LHMetCan,LHMetafile, LHEnhMetafile,LHWriteWMF);
  SetBackground(Sender, LHMetCan.Handle);
  LHz:=0;
  NA[1,1]:=0;
  NA[2,2]:=0;
  NA[3,3]:=0;
  NA[1,2]:=0;                                               
  NA[1,3]:=0;
  NA[2,3]:=0;
  try
    AssignFile(Fn, LHFilename);
    Reset(Fn);
    While not Eof(Fn) and not LHfailed do
    begin
      ReadPLNDataset(Fn,DipDir,Dip,LHfailed,NoComment, Comment);
      If not LHfailed and NoComment then
      begin
        If not eof(fn) then Inc(LHz);
        IF LHExtension=PLN THEN
        begin
          DipDir := trunc(DipDir+180) MOD 360+ frac(DipDir);
          Dip := 90 - Dip;
        end;
        IF DipDir > 360 THEN DipDir:=trunc(DipDir) MOD 360+frac(dipdir);
        DegDipDir:=DegToRad(DipDir);
        DegDip:=DegToRad(Dip);
        xxx := COS(DegDipDir)*COS(DegDip);
        yyy := SIN(DegDipDir)*COS(DegDip);
        zzz := SIN(DegDip);
        NA[1,1]:= NA[1,1] + Sqr(xxx);
        NA[2,2]:= NA[2,2] + Sqr(yyy);
        NA[3,3]:= NA[3,3] + Sqr(zzz);
        NA[1,2]:= NA[1,2] + xxx*yyy;
        NA[1,3]:= NA[1,3] + xxx*zzz;
        NA[2,3]:= NA[2,3] + yyy*zzz;
        NA[2,1]:= NA[1,2];
        NA[3,1]:= NA[1,3];
        NA[3,2]:= NA[2,3];
      end else if not NoComment then dec(LHz);
    end;
    Closefile(fn);
    LHFailed:=LHz<0;
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
  If not LHfailed then
  begin
    CalcEigenVect(LHz,NA,AziEigenv, PlunEigenv, Eigenval, SV,g6, LHFailed);
    if not LHfailed then
    begin
      Draw(Sender);
      inherited;
      LHPlotInfo:=LHPlotInfo+#13#10+'     Eigenval.  Eigenvect.'+#13#10+
        'Min:  '+FloatToString(Eigenval[1],1,2)+'    '+FloatToString(AziEigenv[1],3,0)+' / '+FloatToString(PlunEigenv[1],2,0)+#13#10+
        'Int:  '+FloatToString(Eigenval[2],1,2)+'    '+FloatToString(AziEigenv[2],3,0)+' / '+FloatToString(PlunEigenv[2],2,0)+#13#10+
        'Max:  '+FloatToString(Eigenval[3],1,2)+'    '+FloatToString(AziEigenv[3],3,0)+' / '+FloatToString(PlunEigenv[3],2,0)+#13#10+
        'Great circle fit: '+IntToStr(round(G6))+' %'+#13#10;
      IF G6>=50 THEN
        LHPlotInfo:=LHPlotInfo+'Circular Aperture: '+IntToStr(Round(RadToDeg(2*(ArcSin(SQRt(2*Eigenval[2]))))))+'°'
      else LHPlotInfo:=LHPlotInfo+'Small Circle fit: '+IntToStr(Round(100*Eigenval[1]/Eigenval[2]))+' %';
    end
    else
    begin
      close;
      exit;
    end;
  end
  else
  begin
    GlobalFailed:=True;
    LHMetCan.Free;
    Screen.Cursor := CrDefault;
    MessageDlg('Error reading '+ExtractFilename(LHFilename)+', dataset '
               +IntToStr(LHz+1)+'!'+#10#13+' Processing stopped.',
                mtError,[mbOk], 0);
    //Close;
  end;
end;


procedure CalcEigenvect(nData: Integer; var fNA: T2Sing1by3;
          var fAziEigenv,fPlunEigenv,FEigenval: t1sing1by3;
          var fsv,fg6: single; var ffailed: boolean);
const
  MaxIt = 100;
  E = 0.000001;

var
  Nn, k,l,h, it, p,q,t,nothing,
  i,j,g, XPT, YPT,XX,YY,RR: Integer;
  bi,u, om, sn, cx, fr, am, ri, rj,k1,
  mp,k2,k3,ba, ci, cj, bz, Pl, RSQ, dd, gk,ddn : single;
  NB: T2Sing1by3;
  MaxItOverflow: boolean;
  JAzi, JDip, PAzi, PDip: Variant;
  
begin
  MaxItOverflow := false;
  it :=0;
    FOR p := 1 TO 3 do
      FOR t := 1 TO 3 do
        NB[p,t] := fNA[p,t];
    bi := E;
    FOR k := 1 TO 2 do
    begin
      FOR l := (k + 1) TO 3 do
      begin
        FR := ABS(fNA[k,l]);
        IF bi < FR THEN
        begin
          bi := FR;
          I := k;
          J := l;
        end;
      end;
    end;
    JAzi:=VarArrayCreate([0,maxit], varInteger);
    JDip:=VarArrayCreate([0,maxit], varInteger);
    PAzi:=VarArrayCreate([0,maxit], varDouble);
    PDip:=VarArrayCreate([0,maxit], varDouble);
    While (E < bi) and not MaxItOverflow do
    begin
      IF It < MaxIt THEN
      begin
        Inc(it);
        AM := -fNA[I,J];
        u:=0.5*(fNA[I,I]-fNA[J,J]);
        om := AM /SQRt(AM*AM+u*u);
        IF u < 0 THEN om := -om;
        sn := om/SQRt(2*(1+SQRt(1-om*om)));
        cx := SQRt(1-sn*sn);
        JAzi[it]:=I;
        JDip[it]:=J;
        PAzi[it]:=sn;
        PDip[it]:=cx;
        FOR k:= 1 TO 3 do
        begin
          ri := fNA[I,k];
          rj := fNA[J,k];
          fNA[I,k]:=cx*ri-sn*rj;
          fNA[J,k]:=sn*ri+cx*rj;
        end;
        FOR k := 1 TO 3 do
        begin
          ci := fNA[k,I];
          cj := fNA[k,J];
          fNA[k,I]:=cx*ci-sn*cj;
          fNA[k,J]:=sn*ci+cx*cj;
        end;
        bi := E;
        FOR k := 1 TO 2 do
        begin
          FOR l := (k + 1) TO 3 do
          begin
            FR := ABS(fNA[k,l]);
            IF bi < FR THEN
            begin
              bi := FR;
              I := k;
              J := l;
            end;
          end;
        end;
      end
      else
      begin
        MessageDlg('No result after '+IntToStr(MaxIt)+' iterations!',mtWarning,[mbOK],0);
        MaxItOverflow:= true;
        ffailed:=true;
        exit;
        end;
      end;
      if not MaxItOverflow then
      begin
        FOR I := 1 TO 3 do
        begin
          fEigenval[I] := fNA[I,I];
          FOR J := 1 TO 3 do fNA[I,J]:=0;
          fNA[I,I]:=1;
        end;
        IF it > 0 THEN
        begin
          FOR l := 1 TO it do
          begin
            I := JAzi[l];
            J := JDip[l];
            sn := PAzi[l];
            cx := PDip[l];
            FOR k := 1 TO 3 do
            begin
              ri := fNA[I,k];
              rj := fNA[J,k];
              fNA[I,k]:=cx*ri-sn*rj;
              fNA[J,k]:=sn*ri+cx*rj;
            end;
          end;
        end;
      end;
      FOR I := 1 TO 3 do
        FOR J := 1 TO I do
        begin
          FR := 0;
          FOR k := 1 TO 3 do FR := fNA[k,I]*fNA[k,J]*fEigenval[k]+FR;
        end;
      FOR g := 1 TO 3 do  {calculate 3 eigenvectors}
      begin
        IF fNA[g,3] > 0 THEN
        begin
          fNA[g,1]:=-fNA[g,1];
          fNA[g,2]:=-fNA[g,2];
          fNA[g,3]:=-fNA[g,3];
        end;
        IF fNA[g,2] = 0 THEN bz := PI/2 else bz := ArcTaN(fNA[g,1]/fNA[g,2]);
        BA := RadToDeg(bz);
        IF BA < 0 THEN BA := 180 + BA;
        IF fNA[g,1]<=0 THEN
          IF fNA[g,1]=0 THEN
          begin
            IF fNA[g,2]<0 THEN BA:=180
            else if fNA[g,2]=0 then BA := BA + 180
              else Ba:= 0;
          end else BA := BA + 180;
        IF BA>=360 THEN BA := BA - 360;
        IF fNA[g,3]<0 THEN fNA[g,3]:=-fNA[g,3];
        IF fNA[g,3]<1 THEN mp:=RadToDeg(ArcTaN(fNA[g,3]/SQRt(1-Sqr(fNA[g,3]))))
        else mp := 90;
        fAziEigenv[g]:=270-BA;
        IF fAziEigenv[g]<0 THEN fAziEigenv[g]:=fAziEigenv[g]+360;
        fPlunEigenv[g]:=mp;
      end;
      fsv :=0;
      FOR h := 1 TO 3 do
      begin
        fEigenval[h] := Round(fEigenval[h]/(nData+1)*100)/100;
        fsv := fsv + fEigenval[h];
      end;
      FOR q := 1 TO 2 do
        FOR nn := q+1 TO 3 do
          IF fEigenval[nn]<fEigenval[q] THEN
          begin
            K1 := fEigenval[q];
            K2 := fAziEigenv[q];
            K3 := fPlunEigenv[q];
            fEigenval[q]  := fEigenval[nn];
            fAziEigenv[q] := fAziEigenv[nn];
            fPlunEigenv[q] := fPlunEigenv[nn];
            fEigenval[nn]  := K1;
            fAziEigenv[nn] := K2;
            fPlunEigenv[nn] := K3;
          end;
     FOR g := 1 TO 3 do IF fEigenval[g]< 0.00001 THEN fEigenval[g] := 0.00001;
       fG6:=RadToGrad(ArcTan(Ln(fEigenval[2]/fEigenval[1])/Ln(fEigenval[3]/fEigenval[2])));
end;

procedure TBinghamForm.Draw(Sender: TObject);
var PenStyleDummy: TPenStyle;
    g, dummy2, dummy: Integer;
    Azimuth, Plunge: Single;
    TextDummy1, TextDummy2 : String[20];
    vstr, svstr : String[4];
    
begin
    {************Draw enveloping circle******************}
    If not LHCopyMode then
      with LHMetCan.pen do begin
        Color:=LHNetColor;
        Width := 2;
        NorthAndCircle(LHMetCan, CenterX, CenterY, Radius);
        Width := 1;
      end;
    {**********************Draw poles of eigenvectors**********************}
    LHMetCanHandle:=LHMetCan.Handle;
    {****************************Draw great circle*****************************}
    Azimuth :=trunc(180 + AziEigenv[1]) Mod 360+frac(AziEigenv[1]);
    Plunge := 90 - PlunEigenv[1];
    GreatCircle(LHMetCanHandle,Canvas,CenterX,CenterY,Radius,Azimuth, Plunge,2,false,LHPen.Handle, LHLogPen);
    //PartialGreatCircle(LHMetCanHandle,Canvas,CenterX,CenterY,Radius,Azimuth, Plunge,10, 50, 2,false,LHPen.Handle, LHLogPen);
    PenStyleDummy:=LHPen.Style;
    LHPen.Style:=psSolid;
    FOR g := 1 TO 3 do
      Lineation(LHMetCanHandle,Canvas,CenterX,CenterY,Radius,AziEigenv[g],PlunEigenv[g],LHSymbSize,
                 g-1,Number1.checked,LHSymbFillFlag,LHSymbType,LHFillBrush, LHPen.Handle);
    LHPen.Style:=PenStyleDummy;
    {*******************************Label***********************************}
    if label1.checked then
      begin
        dummy2:= 6-LHMetCan.Font.Height;
        If not LHCopyMode and not LHPasteMode then with LHMetCan do
        begin
          TextOut(labelleft,labeltop,LHLabel1);
          TextOut(labelleft,labeltop+dummy2,'Datasets: '+IntToStr(LHz+1));
        end
        else If LHPasteMode then LHMetCan.TextOut(labelleft,labeltop,ExtractFileName(LHFilename));
        {***********************Write vector table***********************}
        TextDummy1:='Eigenval. Eigenvect.';
        If not LHCopyMode then with LHMetCan do    //**********header************
        begin                                        
          dummy:=WindowExt+Font.Height div 2 *20-5;
          TextOut(dummy,labeltop,TextDummy1);
          Pen.Color:=LHNetColor;
          MoveTo(dummy,labeltop+4*dummy2-4);
          LineTo(dummy-Font.Height*18 div 2,labeltop+4*dummy2-4);
          For g:=1 to 3 do   //**********vectors 1 to 3********
          begin
            Str(Eigenval[g]:2:2, vstr);
            TextDummy1:=IntToStr(Round(AziEigenv[g]));
            If AziEigenv[g] < 100 then
            begin
              TextDummy1:='0'+TextDummy1;
              If AziEigenv[g] < 10 then TextDummy1:='0'+TextDummy1;
            end;
            TextDummy2:=IntToStr(Round(PlunEigenv[g]));
            If PlunEigenv[g] < 10 then TextDummy2:='0'+TextDummy2;
            TextOut(dummy,labeltop+g*dummy2,IntToStr(g)+'.   '+vstr+'    '+TextDummy1+'/'+TextDummy2);
          end;
          Str(sv:2:2, svstr);   //****summation of eigenvalues***
          TextOut(dummy,labeltop+4*dummy2,'      '+svstr);
          dummy:=WindowExt+Font.Height*22 div 2;
          dummy2:= 6-LHMetCan.Font.Height;
          TextOut(dummy,MetafileHeight-2*dummy2-10,'Great circle fit: '+IntToStr(round(G6))+' %');
          IF G6>=50 THEN
            TextOut(dummy,MetafileHeight-dummy2-10,'Circular Aperture: '
                   +IntToStr(Round(RadToDeg(2*(ArcSin(SQRt(2*Eigenval[2]))))))+'°')
          else TextOut(dummy,MetafileHeight-dummy2-10,'Small Circle fit: '+IntToStr(Round(100*Eigenval[1]/Eigenval[2]))+' %');
        end;
      end;
    LHMetCan.Free;
    GlobalFailed:=False;
    Screen.Cursor := CrDefault;
  end;

procedure TBinghamForm.FormCreate(Sender: TObject;const AFilename : String;  const AExtension: TExtension);
begin
  LHPlotType:=pt_Bingham;
  inherited;
end;

end.
