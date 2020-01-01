unit Fish;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Forms,
  Types, LowHem, Dialogs, Math;

type
  TFisherForm = class(TLHWin)
    procedure Fisherstats(q: Integer);
    procedure FisherGraph(q: Integer);
    procedure Open(const AFileName : string; AConfidence: Integer; const AExtension: TExtension);
    procedure Compute(Sender: TObject); override;
    procedure BrushCreate(Sender: TObject); override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
  public
    spherical, ShowConfCone, ShowSpherDistr: Boolean;
    FishPen2: TPen;
  private
    Azim, DipF: Variant;//TIntArray
    Significance,AzimuthX, DipY: integer;
  protected
    Azimuth, Plunge, Aperture, C, SpherApert, RWal, KFish, NAzi, NDip : Single;
  end;


implementation

uses FileOps, Draw;

procedure TFisherForm.Open(const AFileName : string; AConfidence: Integer; const AExtension: TExtension);
begin
  Number1.Visible:=false;
  LHExtension:=AExtension;
  LHPoleFlag:=LHExtension=pln;
  Significance:=AConfidence;
  ShowConfCone:=FishShowConfCone;
  ShowSpherDistr:=FishShowSpherDistr;
  inherited Formcreate(Nil, AFilename, AExtension);
end;

procedure TFisherForm.BrushCreate(Sender: TObject);
begin
  inherited;
  FishPen2:=TPen.Create;
end;

procedure TFisherForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FishPen2.Free;
  inherited;
end;

procedure TFisherForm.Compute;
var  F: TextFile;
     Toolessdata: boolean;
     DipDir, Dip: Single;
     Nocomment : boolean;
     comment: String;

begin
  Screen.Cursor := CrHourGlass;
  LHZ := 0;
  LHfailed:=false;
  try
    AssignFile(F, LHFilename);
    Reset(F);
    Azim:= VarArrayCreate([0,0], varSingle);
    DipF:= VarArrayCreate([0,0], varSingle);
    WHILE NOT EOF(F) and not LHfailed do
    begin
      ReadPLNDataset(F,DipDir,Dip, LHfailed,Nocomment, Comment);
      If not LHfailed and NoComment then
      begin
        try
          VarArrayRedim(Azim,LHZ);
          VarArrayRedim(DipF,LHZ);
        except
          on EVariantError do
          begin
            MessageDlg('System running low in memory'+#10#13+' Processing stopped.',
                       mtError,[mbOk], 0);
            LHfailed := true;
          end;
        end;
        if not LHfailed then
        begin
          if LHPoleFlag then
          begin
            Azim[LHZ] := Trunc(DipDir+180) Mod 360+ Frac(Dipdir);
            DipF[LHZ] := 90-Dip;
          end
          else
          begin
            Azim[LHZ] := DipDir;
            DipF[LHZ] := Dip;
          end;
          If not eof(f) then inc(LHZ);
        end;
      end
      else if not NoComment then dec(LHZ);
    end;
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
  If LHZ<=1 then
  begin
    LHfailed:=true;
    toolessdata:=true;
  end
  else toolessdata:=false;
  If not LHfailed then
  begin
    FisherStats (LHZ);
    FisherGraph (LHZ);
    GlobalFailed:=False;
    inherited;
    LHPlotInfo:=LHPlotInfo+#13#10+'Mean vector: '+FloatToString(Azimuth,3,0)+' / '+FloatToString(Plunge,2,0);
    If Spherical then LHPlotInfo:=LHPlotInfo+#13#10+
      'Significance: '+IntToStr(Significance)+' %'+#13#10+
      'Aperture of conf. cone: '+FloatToString(Aperture, 1,1)+'°';
    LHPlotInfo:=LHPlotInfo+#13#10+'K: '+FloatToString(KFish, 1,1);
    if (LHPlotType=pt_MeanVectRC) then
    begin
      LHPlotInfo:=LHPlotInfo+#13#10+'R: '+FloatToString(RWal, 1,1)+'%';
      if Spherical then LHPlotInfo:=LHPlotInfo+#13#10+
        'Spherical Aperture: '+FloatToString(SpherApert,1,1)+'°';
    end;
    //'R: '+FloatToString(R, 1,4)+#13#10+ removed 991125
    Screen.Cursor := CrDefault;
  end
  else
  begin
    GlobalFailed:=True;
    Screen.Cursor := CrDefault;
    If not toolessdata then
      MessageDlg('Error reading '+ExtractFilename(LHFilename)+', dataset '
                  +IntToStr(LHZ+1)+'!'+#10#13+' Processing stopped.',
                  mtError,[mbOk], 0)
    else
      MessageDlg('Error computing '+ExtractFilename(LHFilename)+'! Too less datasets, processing stopped.',
                  mtError,[mbOk], 0);
  end;
end;

procedure TFisherForm.Fisherstats(q: Integer);
var  T1, T2, T3, T6, n, Vector, A,xx,yy,zz,W, RadAzim, RadDip: Single;
     nn : Integer;
begin
  T1 := 0;
  T2 := 0;
  T3 := 0;
  Case LHPlotType of
  pt_MeanVectFisher:
    for nn := 0 to q do
    begin
      RadAzim:=DegToRad(Azim[nn]);
      RadDip:=DegToRad(DipF[nn]);
      T1 := T1 + COS(RadAzim)*COS(RadDip);
      T2 := T2 + SIN(RadAzim)*COS(RadDip);
      T3 := T3 + SIN(RadDip);
    end;
   pt_MeanVectRC:
    for nn := 0 to q do
    begin
      RadAzim:=DegToRad(Azim[nn]);
      RadDip:=DegToRad(DipF[nn]);
      XX:=COS(RadAzim)*COS(RadDip);
      YY:=SIN(RadAzim)*COS(RadDip);
      ZZ:=SIN(RadDip);
      If nn<>0 then
      begin
        W:=Sqrt(Sqr(T1)+Sqr(T2)+Sqr(T3));
        If Sqr(T1/W+XX)+Sqr(T2/W+YY)+Sqr(T3/W+ZZ)<=2 then
        begin
          XX:=-XX;
          YY:=-YY;
          ZZ:=-ZZ;
        end;
      end; //if
      T1:=T1+XX;
      T2:=T2+YY;
      T3:=T3+ZZ;
    end; //for
  end; //case
  Vector := SQRT(Sqr(T1) + Sqr(T2) + Sqr(T3)); //betrag summenvektor
  N := q + 1 - Vector;                      //q+1...nData
  If N = 0 then N := 0.00000000000001;
  Azimuth := T1 / Vector;
  Plunge := T2 / Vector;
  T6 := T3 / Vector;
  A := Power(1 / (1-Significance / 100), (1 / q));
  C := 1 - N * (A-1) / Vector;
  KFish := q / N; //strength of clustering after Fisher(1953)
  Spherical := KFish >= 4;
  RWal := (2 * Vector - q - 1) / (q + 1) * 100; //R% after Wallberecher(1986)
  If C = 0 then C := 0.00000000000001;
  If Sqr(C) <= 1 then Aperture := RadToDeg(ArcTan(SQRT(1 - Sqr(C)) / C))
  else Aperture := RadToDeg(ArcTan(SQRT(Sqr(C)-1)/C));//aperture of conf. cone
  If (lhPlotType=pt_MeanVectRC) and spherical then //Calculate spherical aperture of normal distribution
    SpherApert:=RadToDeg(ArcSin(Sqrt(2*(1-1/(q+1))/KFish)));
  //Calculation of azimuth and plunge of normal vector
  NDip := ArcTan(T6/Sqrt(1-Sqr(T6)));
  NAzi := ArcTan(Plunge/Sqrt(Sqr(Cos(NDip))-Sqr(Plunge)));
  NDip := ABS(RadToDeg(NDip));
  NAzi :=(RadToDeg(NAzi));
  IF SGN(Azimuth) <> -1 THEN
    IF SGN(Plunge) <> -1 THEN NAzi := (trunc(NAzi + 180)) MOD 360 +frac(NAzi)
    ELSE NAzi := 180 + NAzi
  ELSE
    IF SGN(Plunge) <> -1 THEN NAzi := 270 + (90 - NAzi)
    ELSE NAzi := -NAzi;
  NAzi:= trunc(NAzi+180) MOD 360+ frac(NAzi);
  IF LHPoleFlag then //planes
  begin
    Azimuth:=Trunc(NAzi+180) mod 360+Frac(NAzi);
    Plunge:=90-NDip;
  end
  else
  begin
    Azimuth:=NAzi;
    Plunge:=NDip;
  end;
end;

procedure TFisherForm.FisherGraph(q: Integer);
const NoOfSteps = 50;
var  z2, x2, y2, AI, Rp, FI: Single;
     I, dummy2,dummy3 :Integer;
     psDummy: TPenStyle;
begin
  try
    PrepareMetCan(LHMetCan, LHMetafile, LHEnhMetafile,LHWriteWMF);
    SetBackground(nil, LHMetCan.Handle);
    If Label1.Checked then
    begin
      If not LHCopyMode then with LHMetCan do
      begin
        {dummy2:=MetafileWidth-TextWidth('Spherical apert.: 133° ');}
        dummy2:=MetafileWidth-Abs(LHMetCan.Font.Height) div 2 *20-5;
        {dummy 2 should be 450 for filesize of 600}
        dummy3:= 6-LHMetCan.Font.Height;
        i:=0;
        If Spherical then
        begin
          TextOut(dummy2,labeltop,'Significance:  '+IntToStr(Significance)+'%');
          inc(i);
        end;
        TextOut(dummy2,labeltop+dummy3*i,'K: '+FloatToString(KFish,1,0));
        inc(i);
        if lhPlotType=pt_MeanVectRC then
        begin
          TextOut(dummy2,labeltop+i*dummy3,'R: '+FloatToString(RWal,1,0)+'%');
          inc(i);
          If Spherical then TextOut(dummy2,labeltop+i*dummy3,'Sph.Ap.: '+FloatToString(SpherApert,1,1)+'°');
        end;
      end;
      If not LHCopyMode and not LHPasteMode then With LHMetCan do
      begin
        TextOut(labelleft,labeltop,LHLabel1);
        TextOut(labelleft,labeltop+dummy3,'Datasets: '+IntToStr(q+1));
        TextOut(labelleft,labeltop+2*dummy3,'Mean vector: '+FloatToString(Azimuth,3,0)+
                ' / '+FloatToString(Plunge,2,0));
      end
      else if LHPasteMode then LHMetCan.TextOut(labelleft,labeltop,ExtractFileName(LHFileName));
    end;
    //IF NDip = 90 THEN NDip := 89.99;
    //IF (NAzi = 90) OR (NAzi = 270) THEN NAzi:= -0.01;
    {****************************Draw Symbol**************************}
    //LHMetCan.Pen.Color:=LHPen.Color;
    //FillColorDummy:=LHFillBrush.Color;
    //SymbolSizeDummy:=LHSymbSize;
    psDummy:=LHPen.Style;
    LHPen.Style:=psSolid;
    Lineation(LHMetCan.Handle,Nil,CenterX,CenterY,Radius,NAzi,NDip,LHSymbSize,
               I,false,LHSymbFillflag,LHSymbType,LHFillBrush, LHPen.Handle);
    LHPen.Style:=psDummy;
    //LHMetCan.Pen := LHPen;
    if Spherical then
    begin
      //Draw Small Circle for circular aperture (cone of confidence)
      if ShowConfCone then SmallCircle2(LHMetCan.Handle, Canvas, CenterX, CenterY, Radius, NAzi, NDip,
        Aperture, LHSymbSize, LHSymbfillflag, LHSymbType, LHFillBrush, LHPen.Handle);
      //Draw Small Circle for spherical aperture (normal distribution)
      psDummy:=LHPen.Style;
      LHPen.Style:=psSolid;
      if (lhPlotType=pt_MeanVectRC) and ShowSpherDistr then
        SmallCircle2(LHMetCan.Handle, Canvas, CenterX, CenterY, Radius, NAzi, NDip,
          SpherApert, LHSymbSize, LHSymbfillflag, LHSymbType, LHFillBrush, FishPen2.Handle);
      LHPen.Style:=psDummy;    
    end;
    With LHMetCan.Pen do
    begin
      color:=LHNetColor;
      Style := psSolid;
      Width := 2;
      NorthAndCircle(LHMetCan, CenterX, CenterY, Radius);
      Width := 1;
    end;
  finally
    LHMetCan.Free;
  end;
end;

end.
