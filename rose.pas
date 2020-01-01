unit rose;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Clipbrd, LowHem, Types;

type
  TFluMohrFm = class(TLHWin)
  published
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer); override;
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
    procedure FormCreate(Sender: TObject; const AFilename: string; const AExtension: TExtension); override;
    procedure FileFailed2(Sender: TObject);
    procedure BrushCreate(Sender: TObject); override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
  protected
    oldfile: boolean;
  public
    FMPen2: TPen;
  end;

  TRoseForm = class(TFluMohrFm)
    procedure Copy1Click(Sender: TObject); override;
    procedure Print1Click(Sender: TObject); override;
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer); override;
  private
    Fallwert, Unipolar, Planes : boolean;
    Azim, Plun : Variant;
    CenterX1, CenterY1, CenterX2,CenterY2: Integer;
    Radius1, Radius2 : Word;
    procedure Init;
    procedure CloseQuery(Sender: TObject; var CanClose: Boolean);
  public
    AziIntervall, DipIntervall: Single;
    max3,max5 : Integer;
    Max2,max4 : Single;
    Klassenmitte, AziIntervalChanged, DipIntervalChanged, DipAlso: Boolean;
    procedure Open(Sender: TObject; const AFilename: string; AIntervall, DIntervall : Integer; AAuswertung,
                   AKlassenmitte, AUnipolar, APlane : boolean; const AStressAxis: Integer; const AExtension: TExtension);
    procedure Compute(Sender: TObject); override;
  published
    procedure PaintBox1Paint(Sender: TObject); override;
  end;

//var roseform: TRoseForm;

implementation


uses TecMain, FileOps, PrintDia, Settings, Printers, Math, Inspect, Results, Draw;

//************************FluMohrForm****************************
procedure TFluMohrFm.BrushCreate(Sender: TObject);
begin
  inherited;
  FMPen2:=TPen.Create;
end;

procedure TFluMohrFm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FMPen2.free;
  inherited;
end;

procedure TFluMohrFm.FileFailed2(Sender: TObject);
begin
  GlobalFailed:=True;
  if oldfile then
    MessageDlg(ExtractFilename(LHFilename)+' has old fileformat!'+#10#13+
               'Run invers/NDA routine once more.',mtError,[mbOk], 0)
  else
    if fileused then
      CommonError(Sender,LHFilename,ecFileUsed)
    else
      ReadError(Sender,LHFilename,LHz);
  //Close;
end;

procedure TFluMohrFm.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
begin
  {}
end;

procedure TFluMohrFm.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
begin
  {}
end;

procedure TFluMohrFm.FormCreate(Sender: TObject; const AFilename: string; const AExtension: TExtension);
begin
  inherited;
end;


//TRoseForm

procedure TRoseForm.CloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  RoseCenter:=Klassenmitte;
end;

procedure TRoseForm.Open(Sender: TObject; const AFilename: string; AIntervall,DIntervall : Integer;
                         AAuswertung, AKlassenmitte, AUnipolar, APlane : boolean; const AStressAxis: Integer; const AExtension: TExtension);
begin
  Screen.Cursor := CrHourGlass;
  LHStressaxis:=astressaxis;
  If AKlassenmitte then LHPlotType:=pt_RoseCenter
  else LHPlotType:=pt_RoseCorner;
  OnCloseQuery:=CloseQuery;
  LHfailed := false;
  LHFilename := AFilename;
  LHLabel1:=ExtractFileName(LHFilename);
  Label1.checked:=GlobalLHLabel;
  Unipolar := AUnipolar;
  Planes:=APlane;
  LHExtension:= AExtension;
  if lhextension=ptf then
    case LHstressaxis of
      2: lhlabel2:='(p-axes)';
      3: lhlabel2:='(t-axes)';
      4: lhlabel2:='(b-axes)';
    end;
  Klassenmitte:= AKlassenmitte;
  lhcreating:=true;
  Init;
  If not LHfailed and not fileused then
  begin
    export1.enabled:=true;
    print1.enabled:=true;
    TecmainWin.ArrangeMenu(Sender);
    LHCopyMode:=false;
    AziIntervall := AIntervall;
    DipIntervall := DIntervall;
    DipAlso := AAuswertung;

    Number1.Visible:=false;
    LHWriteWMF:=WriteWmfglobal;
    Aziintervalchanged:=true;
    Dipintervalchanged:=true;
    SetLHProperties(LHPlotType);
    Compute(Sender);
    Inc(GlobalLHPlots);
    LHPlotNumber:=GlobalLHPlots;
    Caption:='Plot '+IntToStr(LHPlotNumber)+': '+Caption;
    If Inspectorform<>nil then InspectorForm.Initialize(Self);
    If SetForm<>nil then SetForm.Initialize(Self);
    If ResInsp<>nil then ResInsp.Initialize(Self);
    GlobalFailed:=False;
  end
  else
  begin
    screen.cursor:=crdefault;
    filefailed2(self);
    Close;
    Exit;
  end;
end;


procedure TRoseForm.Init;
var
  F : TextFile;
  Sense,Quality, intdummy : Integer;
  dummy,DipDir, Dip, Azimuth, Plunge, pazim, pplunge, tazim, tplunge, bazim, bplunge: Single;
  Nocomment : boolean;
  Comment: String;

begin
  LHz := 1;
  //************************
  AssignFile(F, LHFilename); //retrieve number of datasets first
  try
    Reset(F);
    if not eof(f) then
    begin
      while not Eof(F) and not LHfailed do
      begin
        Case LHExtension of
          COR, FPL, PTF:
          begin
            if LHExtension = PTF then
             ReadPTFDataset(f,Sense,Quality,DipDir,Dip,Azimuth,Plunge,
                  bazim,bplunge,pazim,pplunge,tazim,tplunge, dummy, intdummy, LHfailed, NoComment)
            else
             ReadFPLDataset(f, Sense, Quality, DipDir, Dip, Azimuth, Plunge, LHfailed, NoComment, LHExtension, comment);
            if not LHfailed and NoComment then
            begin
              If not eof(f) then inc(LHz);
            end else if not NoComment then dec(LHz);
          end;
          PLN, LIN:
          begin
            ReadPLNDataset(F, DipDir, Dip, LHfailed, NoComment, Comment);
            if not LHfailed and NoComment then
            begin
              if not eof(f) then inc(LHz);
            end else if not NoComment then dec(LHz);
          end;
          AZI : begin
            ReadAZIDataset(F, DipDir, LHfailed, NoComment, Comment);
            if not LHfailed and NoComment then
            begin
              if not eof(f) then inc(LHz);
            end else if not NoComment then dec(LHz);
          end;
          ERR : LHfailed:= true;
        end;
      end;
    end else LHfailed:=true;
    CloseFile(F);
    //************************
    AssignFile(F, LHFilename);
    Reset(F);
    if not eof(f) then
    begin
      inc(Lhz);
      Azim:=VarArrayCreate([1, LHz], varSingle);
      Plun:=VarArrayCreate([1, LHz], varSingle);
      LHz:= 1;
      while not Eof(F) and not LHfailed do
      begin
        Case LHExtension of
          COR, FPL, PTF :
          begin
            if LHExtension = PTF then
             ReadPTFDataset(f,Sense,Quality,DipDir,Dip,Azimuth,Plunge,
                  bazim,bplunge,pazim,pplunge,tazim,tplunge, dummy, intdummy, LHfailed, NoComment)
            else
             ReadFPLDataset(f, Sense, Quality, DipDir, Dip, Azimuth, Plunge, LHfailed, NoComment, LHExtension, comment);
            if not LHfailed and NoComment then
            begin
              If Planes then
              begin
                Azim[LHz]:=trunc(DipDir+90) mod 180+frac(DipDir);
                Plun[LHz]:=Dip;
              end else begin
                Azim[LHz]:=Azimuth;
                Plun[LHz]:=Plunge;
              end;
              if lhextension=ptf then
                case LHstressaxis of
                  2: begin  //p-axis
                    Azim[LHz]:=pazim;
                    Plun[LHz]:=pPlunge;
                  end;
                  3: begin  //t-axis
                    Azim[LHz]:=tazim;
                    Plun[LHz]:=tPlunge;
                  end;
                  4: begin  //b-axis
                    Azim[LHz]:=bazim;
                    Plun[LHz]:=bPlunge;
                  end;
                end;
              if Azim[LHz] > 359.99 then Azim[LHz] := trunc(Azim[LHz]) mod 360+frac(Azim[LHz]);
              if Plun[LHz] >= 90 then Plun[LHz] := 89.99;
              If not eof(f) then inc(LHz);
            end else if not NoComment then dec(LHz);
          end;
          PLN:
          begin
            ReadPLNDataset(F, DipDir, Dip, LHfailed, NoComment, Comment);
            if not LHfailed and NoComment then
            begin
              If unipolar then
                Azim[LHz]:=DipDir
              else
                Azim[LHz]:=trunc(DipDir+90) mod 180+frac(DipDir);
              Plun[LHz]:=Dip;
              if Azim[LHz]>359 then Azim[LHz] := trunc(Azim[LHz]) mod 360+frac(Azim[LHz]);
              if Plun[LHz] >= 90 then Plun[LHz] := 89;
              if not eof(f) then inc(LHz);
            end else if not NoComment then dec(LHz);
          end;
          LIN :
          begin
            ReadPLNDataset(F, DipDir, Dip, LHfailed, NoComment, Comment);
            if not LHfailed and NoComment then
            begin
              Azim[LHz]:=DipDir;
              Plun[LHz]:=Dip;
              if Azim[LHz]>359 then Azim[LHz] := trunc(Azim[LHz]) mod 360+ frac(Azim[LHz]);
              if Plun[LHz] >= 90 then Plun[LHz] := 89;
              if not eof(f) then inc(LHz);
            end else if not NoComment then dec(LHz);
          end;
          AZI : begin
            ReadAZIDataset(F, DipDir, LHfailed, NoComment, Comment);
            if not LHfailed and NoComment then
            begin
              Azim[LHz]:=DipDir;
              if Azim[LHz]>359 then Azim[LHz] := trunc(Azim[LHz]) mod 360+ frac(Azim[LHz]);
              IF not Unipolar THEN Azim[LHz] := trunc(Azim[LHz]) MOD 180+ frac(Azim[LHz]);
              if not eof(f) then inc(LHz);
            end else if not NoComment then dec(LHz);
          end;
          ERR : LHfailed:= true;
        end;
      end;
    end else LHfailed:=true;
    CloseFile(F);
    LHMetafile := TMetafile.Create;
  except   {can not open file}
    On EInOutError do fileused:=true;
  end;
end;

procedure TRoseForm.Compute(Sender: TObject);
const
  Lines  = 10;  {number of lines to resemble circle for pie}
  lines2 = 40;
  lines3 = 300;

var
  Mitte : Integer;
  AzimMax, DipMax, R,nn,x: Integer;
  d, gu : single;
  t : Array[1..361] of Integer;
  xpt: Array[1..361] of Single;
  Points : Array[0..Lines+1] of TPoint;
  Points2 : Array[0..Lines2] of TPoint;
  Points3 : Array[0..Lines3] of TPoint;
  dStr: string[10];
  BrushStore : TColor;

begin
  If LHWriteWMF then
  begin
    LHMetafile.Height := MetafileHeight;
    LHMetafile.mmWidth:=MetafilemmWidth;
    If DipAlso then
    begin
      If not LHCopyMode then
      begin
        LHMetafile.Width := MetafileWidth*2;
        LHMetafile.mmHeight:=MetafilemmHeight div 2;
        LHMetafile.Inch:=Metafileinch; //bugfix 990803
      end
      else
      begin
        LHMetafile.Width := MetafileWidth;
        LHMetafile.mmHeight:=MetafilemmHeight;
      end;
      CenterX1 := LHMetafile.Width div 4;
      CenterY1 := LHMetafile.Height div 2;
      Radius1:= (CenterX1 div 5) * 4;
      Radius2:= (CenterX1 div 5) * 8;
      CenterX2 := 2*CenterX1;
      CenterY2 := CenterY1-Radius1;
    end
    else
    begin
      LHMetafile.Width  := MetafileWidth;
      LHMetafile.mmHeight:=MetafilemmHeight;
      CenterX1 := CenterX;
      CenterY1 := CenterY;
      Radius1:= (CenterX1 div 5) * 4;
    end;
    LHMetCan := TMetafileCanvas.CreateWithComment(LHMetafile, 0, 'pt_Rose', 'TectonicsFP');
  end
  else  //Enhanced Windows Metafile
  begin
    LHEnhMetafile := TEnhMetafile.Create;
    LHEnhMetafile.Height := MetafileHeight;
    //MyEnhMetafile.mmWidth:=MetafilemmWidth;
    If DipAlso then
    begin
      If LHCopyMode then
      begin
        LHEnhMetafile.Width := MetafileWidth;
        //MyEnhMetafile.mmHeight:=MetafilemmHeight div 2;
      end
      else
      begin
        LHEnhMetafile.Width := MetafileWidth*2;
        //MyEnhMetafile.mmHeight:=MetafilemmHeight;
      end;
      CenterX1 := LHEnhMetafile.Width div 4;
      CenterY1 := LHEnhMetafile.Height div 2;
      Radius1:= (CenterX1 div 5) * 4;
      Radius2:= (CenterX1 div 5) * 8;
      CenterX2 := 2*CenterX1;
      CenterY2 := CenterY1-Radius1;
    end
    else
    begin
      LHEnhMetafile.Width  := MetafileWidth;
      CenterX1 := CenterX;
      CenterY1 := CenterY;
      Radius1:= (CenterX1 div 5) * 4;
    end;
    LHMetCan := TEnhMetafileCanvas.CreateWithComment(LHEnhMetafile, 0, 'pt_Rose', 'TectonicsFP');
  end;
  SetMapMode(LHMetCan.Handle, MM_Anisotropic);
  SetWindowOrgEx(LHMetCan.handle, 0, 0, nil);
  If LHWriteWMF then SetWindowExtEx(LHMetCan.handle, LHMetafile.Width, LHMetafile.Height, nil)
  else SetWindowExtEx(LHMetCan.handle,1,1, nil);
  SetBkMode(LHMetCan.Handle, TRANSPARENT);
  SelectObject(LHMetCan.Handle,GetStockObject(HOLLOW_BRUSH));
  LHMetCan.Font := TecMainWin.FontDialog1.Font;
  If LHBackgrOn then
  begin
    SelectObject(LHMetCan.Handle, LHBackgrBrush.Handle);
    SelectObject(LHMetCan.Handle, GetStockObject(null_pen));
    If LHWriteWMF then
      Windows.Rectangle(LHMetCan.Handle, 0, 0, LHMetafile.Width, LHMetafile.Height)
    else
      If dipalso and not LHCopyMode then
        Windows.Rectangle(LHMetCan.Handle, 0, 0, MetafileWidth*2, MetafileWidth)
      else
        Windows.Rectangle(LHMetCan.Handle, 0, 0, MetafileWidth, MetafileWidth);
    SelectObject(LHMetCan.Handle, GetStockObject(hollow_brush));
    SelectObject(LHMetCan.Handle, LHPen.Handle);
  end;
  If AziIntervall<=0 then AziIntervall:=1;
  If unipolar then AziIntervall:= 360/(360 div Round(AziIntervall))
  else begin
    Mitte := 180 div Round(AziIntervall);
    AziIntervall:= 180/Mitte;
  end;
  R := 0;
  GU := 0;
  AzimMax:= 0;
  FOR NN:=1 TO 361 do
  begin
    t[NN]:=0;
    XPT[NN]:=0;
  end;
  While GU<=360 do //fill histogram boxes
  begin
    inc(R);
    FOR nn := 1 TO LHz do
    begin
      IF ((Azim[nn] >= GU) AND (Azim[nn] < GU+AziIntervall)) THEN Inc(t[R]);
      IF AzimMax<t[R] THEN AzimMax := t[R];
    end;
    GU:=GU+AziIntervall;
  end; {fill 180-360° for bipolar data}
  If not unipolar then for nn := 1 to mitte do t[nn+mitte]:= t[nn];
  d := AzimMax/LHz*100;  //max of data [%]
  If (max3<d) or Aziintervalchanged then Max2:=d else Max2:=max3;
  GU := 90;
  If LHSymbFillFlag then
  begin
    If LHFillBrush.Color<>clWhite then
    begin
      BrushStore := LHMetCan.Brush.Color;
      LHMetCan.Brush.Color := LHFillBrush.Color;
    end
    else SelectObject(LHMetCan.Handle,GetStockObject(WHITE_BRUSH));
  end;
  LHMetCan.Pen:=LHPen;
  FOR x := 1 TO R-1 do
  begin
    if t[x] <> 0 then
    begin
      XPT[x] := t[x]*100*Radius1/Max2/LHz; //Calculate height of box related to maximum value
      Points[0].x := CenterX1;
      Points[0].y := CenterY1;
      Points[1].x := Round(CenterX1-(XPT[x]-1)*cos(DegToRad(Gu)));
      Points[1].y := Round(CenterY1-(XPT[x]-1)*sin(DegToRad(Gu)));
      For NN:= 1 to Lines do
      begin
        Points[nn+1].x := Round(CenterX1-(XPT[x]-1)*cos(DegToRad(Gu+NN*AziIntervall/Lines)));
        Points[nn+1].y := Round(CenterY1-(XPT[x]-1)*sin(DegToRad(Gu+NN*AziIntervall/Lines)));
      end;
      if not klassenmitte then LHMetCan.Polygon(Points);
    end;
    if x=1 then
    begin
      Points3[0].x:= Round(CenterX1-(XPT[x]-1)*cos(DegToRad(Gu+AziIntervall/2)));
      Points3[0].y:= Round(CenterY1-(XPT[x]-1)*sin(DegToRad(Gu+AziIntervall/2)));
    end
    else
    begin
      Points3[x-1].x:= Round(CenterX1-(XPT[x]-1)*cos(DegToRad(Gu+AziIntervall/2)));
      Points3[x-1].y:= Round(CenterY1-(XPT[x]-1)*sin(DegToRad(Gu+AziIntervall/2)));
    end;
    GU := GU + AziIntervall;
  end; {end of for-loop}
  if klassenmitte then LHMetCan.Polygon(Slice(points3, x-1));
  If LHSymbFillFlag then
  begin
    LHMetCan.Brush.Color := BrushStore;
    LHMetCan.Brush.Style := bsClear;
  end;
  With LHMetCan.Pen do
  begin
    Style:=psSolid;
    Width:=AxesPenWidth;
  end;
  Str(d:2:2, dStr);
  If Label1.checked then
    LHMetCan.TextOut(CenterX1-30+Radius1 div 2, CenterY1+radius1+5,'max = '+dStr+'%');
  Gu:=0;
  While GU<360 do
  begin
    //Ticks on Circle
    With LHMetCan do
    begin
      MoveTo(CenterX1-round(Radius1*cos(DegToRad(GU))),
             CenterY1-round(Radius1*sin(DegToRad(Gu))));
      LineTo(CenterX1-round((5+Radius1)*cos(DegToRad(GU))),
             CenterY1-round((5+Radius1)*sin(DegToRad(Gu))));
    end;
    Gu:=Gu+10;
  end;
  {****************Computing dip values**************************}
  IF DipAlso THEN
  begin
    If DipIntervall<=0 then DipIntervall:=1;
    DipIntervall:= 90/(90 div Round(DipIntervall));
    FOR NN:=1 TO 361 do
    begin
      t[NN]:=0;
      XPT[NN]:=0;
    end;
    R := 0;
    GU := 0;
    DipMax:= 0;
    While GU<90 do {fill histogram boxes}
    begin
      Inc(R);
      FOR nn := 1 TO LHz do
      begin
        IF ((Plun[nn] >= GU) AND (Plun[nn] < GU+ DipIntervall))  THEN inc(t[R]);
        IF DipMax<t[R] THEN DipMax := t[R];
      end;
      GU := GU + DipIntervall;
    end;
    d := DipMax/LHz*100;  {max of data [%]}
    If (max5<d) or Dipintervalchanged then Max4:=d else max4:=max5;
    With LHMetCan do
    begin
      Points2[0].x := Round(CenterX2);
      Points2[0].y := Round(CenterY1+Radius1);
      For NN:= 1 to Lines2 do
      begin
        Points2[nn].x := Round(CenterX2+Radius1*sin(DegToRad(NN*90/Lines2)));
        Points2[nn].y := Round(CenterY1+Radius1*cos(DegToRad(NN*90/Lines2)));
      end;
      LHMetCan.PolyLine(Points2);
    end;
    GU := 90+DipIntervall;
    If LHSymbFillFlag then
    begin
      If LHFillBrush.Color<>clWhite then
      begin
        BrushStore := LHMetCan.Brush.Color;
        LHMetCan.Brush.Color := LHFillBrush.Color;
      end
      else SelectObject(LHMetCan.Handle,GetStockObject(WHITE_BRUSH));
    end;
    LHMetCan.Pen:=LHPen;
    FOR x := 1 TO R do
    begin
      if t[x] <> 0 then
      begin
        XPT[x] := Round(t[x]/LHz*100*Radius1/max4);
        Points3[0].x:= CenterX2;
        Points3[0].y:= CenterY1;
        Points[0].x := CenterX2;
        Points[0].y := CenterY1;
        Points[1].x := Round(CenterX2-(XPT[x]-1)*cos(DegToRad(90+Gu)));
        Points[1].y := Round(CenterY1-(XPT[x]-1)*sin(DegToRad(90+Gu)));
        For NN:= 1 to Lines do
        begin
          Points[nn+1].x := Round(CenterX2-(XPT[x]-1)*cos(DegToRad(90+Gu-NN*DipIntervall/Lines)));
          Points[nn+1].y := Round(CenterY1-(XPT[x]-1)*sin(DegToRad(90+Gu-NN*DipIntervall/Lines)));
        end;
        if not klassenmitte then LHMetCan.Polygon(Points);
      end;
      Points3[x].x:= Round(CenterX2-(XPT[x]-1)*cos(DegToRad(90+Gu-DipIntervall/2)));
      Points3[x].y:= Round(CenterY1-(XPT[x]-1)*sin(DegToRad(90+Gu-DipIntervall/2)));
      GU:=GU+ DipIntervall;
    end;   {end of for-loop}
    if Klassenmitte then LHMetCan.Polygon(Slice(points3, x));
    If LHSymbFillFlag then
    begin
      LHMetCan.Brush.Color := BrushStore;
      LHMetCan.Brush.Style := bsClear;
    end;
    With LHMetCan.Pen do
    begin
      Style:=psSolid;
      Width:=AxesPenWidth;
    end;
  end; {end if dip also}
  IF DipAlso THEN
  begin
    GU:= 90;
    While GU<180 do {tics on dip-also}
    begin
      With LHMetCan do
      begin
        MoveTo(CenterX2-round(Radius1*cos(DegToRad(90+GU))),
               CenterY1-round(Radius1*sin(DegToRad(90+Gu))));
        LineTo(CenterX2-round((5+Radius1)*cos(DegToRad(90+GU))),
               CenterY1-round((5+Radius1)*sin(DegToRad(90+Gu))));
      end;
      GU := GU + 10;
    end;
  end;
  With LHMetCan do
  begin
    Font := TecMainWin.FontDialog1.Font;
    //*************Enveloping Circle of Rose Diagram and description*********
    Ellipse(CenterX1-Radius1,CenterY1-Radius1, CenterX1+Radius1,CenterY1+Radius1);
    MoveTo(CenterX1,CenterY1-Radius1);
    LineTo(CenterX1,CenterY1+Radius1);
    MoveTo(CenterX1-Radius1, CenterY1);
    LineTo(CenterX1+Radius1, CenterY1);
    TextOut(CenterX1-3,CenterY1-radius1-20,'0');
    TextOut(CenterX1+8+Radius1,CenterY1-8,'90');
    TextOut(CenterX1-10,CenterY1+radius1+5,'180');
    TextOut(CenterX1-Radius1-30,CenterY1-8,'270');
    if DipAlso then
    begin
      MoveTo(CenterX2+Radius1+5,CenterY1);
      LineTo(CenterX2,CenterY1);
      LineTo(CenterX2,CenterY1+Radius1);
      TextOut(CenterX2-10,CenterY1+radius1+5,'90');
      TextOut(CenterX2+10+Radius1,CenterY1-9,'0');
    end;
  end;
  Str(d:2:2, dStr);
  Dec(LHz);
  IF Label1.Checked THEN
  begin
    with LHMetCan do begin
      if lhcreating then
      begin
        LHLabel2:='Datasets: '+IntToStr(LHz+1);
        lhcreating:=false;
      end;
      TextOut(CenterX1-Radius1,CenterY1-Radius1-20,ExtractFileName(LHFilename));
      TextOut(CenterX1+Radius1-70,CenterY1-Radius1-20,LHLabel2);
      TextOut(CenterX1-Radius1, CenterY1+radius1+5,'Interval: '+IntToStr(Round(AziIntervall))+'°');
      If DipAlso then
      begin
        TextOut(CenterX2-10,CenterY1-70,'Interval: '+IntToStr(Round(DipIntervall))+'°');
        TextOut(CenterX2-10,CenterY1-40,'max = '+dStr+'%');
      end;
    end;
    Case LHExtension of
      COR, FPL :
        If Planes then LHMetCan.TextOut(CenterX1-Radius1,CenterY1-Radius1,'Fault planes')
        else LHMetCan.TextOut(CenterX1-Radius1,CenterY1-Radius1,'Lineations');
      PTF: case LHstressaxis of
          0, 1: If Planes then LHMetCan.TextOut(CenterX1-Radius1,CenterY1-Radius1,'Fault planes')
            else LHMetCan.TextOut(CenterX1-Radius1,CenterY1-Radius1,'Fault lineations');
          2: LHMetCan.TextOut(CenterX1-Radius1,CenterY1-Radius1,'P-Axes');
          3: LHMetCan.TextOut(CenterX1-Radius1,CenterY1-Radius1,'T-Axes');
          4: LHMetCan.TextOut(CenterX1-Radius1,CenterY1-Radius1,'B-Axes');
        end;
    end;
  end;
  inherited;
  LHPlotInfo:=LHPlotInfo+#13#10+
    'Azimuth interval: '+IntToStr(Round(AziIntervall))+'°'+#13#10+
    'Azimuth maximum: '+FloatToString(Max2, 2, 2)+' % ('+IntToStr(AzimMax)+' counts)';
  Inc(LHz);
  If DipAlso then
  begin
    LHPlotInfo:=LHPlotInfo+#13#10+
      'Dip interval: '+IntToStr(Round(DipIntervall))+'°'+#13#10+
      'Dip maximum: '+dStr+' % ('+IntToStr(DipMax)+' counts)';
  end;
  LHMetCan.Free;
end;


procedure TRoseForm.Copy1Click(Sender: TObject);
begin
  Screen.Cursor:=crHourglass;
  If dipalso then
  begin
    LHCopyMode:=True;
    if not LHPasteMode then Compute(Sender);
    If LHWriteWMF then Clipboard.Assign(LHMetafile)
    else Clipboard.Assign(LHEnhMetafile);
    LHCopyMode:=false;
    if not LHPasteMode then Compute(Sender);
  end
  else If LHWriteWMF then Clipboard.Assign(LHMetafile)
    else Clipboard.Assign(LHEnhMetafile);
  Screen.Cursor:=crDefault;
end;


procedure TRoseForm.Print1Click(Sender: TObject);
var PrtRec : TRect;
    HorzPixPerInch,VertPixPerInch, PageWidth{, PageHeight}: Integer;
    //PrintDial : TPrintDial;
    PrintDialog1 : TPrintDialog;
begin
  PrintDialog1:= TPrintdialog.Create(Self);
  try
  if PrintDialog1.Execute then with TPrintDial.Create(Self) do
  begin
    Caption := Caption +' - [' +
               ExtractFileName(LHFilename) +']';
    Label1.Caption:='Diagram width: ';
    ShowModal;
    If ModalResult=mrOK then
    begin
      Screen.Cursor := crHourglass;
      Printer.BeginDoc;
      Pagewidth:=GetDeviceCaps(Printer.Canvas.Handle, horzsize);
      {Pageheight:=GetDeviceCaps(Printer.Canvas.Handle, vertsize);}
      HorzPixPerInch:=GetDeviceCaps(Printer.Canvas.Handle, LOGPIXELSX);
      VertPixPerInch:=GetDeviceCaps(Printer.Canvas.Handle, LOGPIXELSY);
      If PrintLowerHemiSize>= Pagewidth div 5*4 then PrintLowerHemiSize:=PageWidth div 5*4;
      If DipAlso then
      PrtRec := Bounds(Round(HorzPixPerInch/25.4/2*(PageWidth-PrintLowerHemiSize/4*5)),
                       Round(VertPixPerInch/25.4*10),
                       Round(HorzPixPerInch/25.4/4*5*PrintLowerHemiSize),
                       Round(VertPixPerInch/25.4/8*5*PrintLowerHemiSize))
      else
      PrtRec := Bounds(Round(HorzPixPerInch/25.4/2*(PageWidth-PrintLowerHemiSize/4*5)),
                       Round(VertPixPerInch/25.4*20),
                       Round(HorzPixPerInch/25.4/4*5*PrintLowerHemiSize),
                       Round(VertPixPerInch/25.4/4*5*PrintLowerHemiSize));
      If LHWriteWMF then Printer.Canvas.StretchDraw(PrtRec, LHMetafile)
      else Printer.Canvas.StretchDraw(PrtRec, LHEnhMetafile);
      Printer.EndDoc;
      Screen.Cursor := crDefault;
    end;
  end;
 finally
 Printdialog1.free;
 end;
end;


procedure TRoseForm.PaintBox1Paint(Sender: TObject);
var PaintRec : TRect;
begin
  If not LHFailed then with PaintBox1 do
  begin
    Screen.Cursor:=crHourGlass;
    If DipAlso then
      if Width > 2 * Height then
        PaintRec:= Rect(Width div 2 - Height, 0,
                        Width div 2 + Height, Height)
      else
        PaintRec:= Rect(0, Height div 2 - Width div 4,
                        Width, Height div 2 + Width div 4)
    else
      PaintRec := Bounds((Width - min(Height,Width)) div 2,
                         (Height - min(Height,Width)) div 2,
                          min(Height,Width),
                          min(Height,Width));
    If LHWriteWMF then Canvas.StretchDraw(PaintRec, LHMetafile)
    else Canvas.StretchDraw(PaintRec, LHEnhMetafile);
    Screen.Cursor:=crDefault;
  end;
end;

procedure TRoseForm.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
var Dummy1, Dummy2, Dummy3: Longint;
    MouseRadius: Single;
    Midpoint1, Midpoint2: TPoint;
    Dummy4: Single;
begin
  if DipAlso then
  begin
    Midpoint1.X:= Paintbox1.Width div 4;
    Midpoint1.Y:= Paintbox1.Height div 2;
    Midpoint2.X:= Midpoint1.X*2;
    Midpoint2.Y:= Midpoint1.Y;
    MouseRadius:= Paintbox1.Width/5;
  end
  else
  begin
    Midpoint1.X:=Round(Paintbox1.Width/2);
    Midpoint1.Y:=Round(Paintbox1.Height/2);
    MouseRadius := 2*Min(Paintbox1.Width, Paintbox1.Height)/5;
  end;
  Dummy1:=X-Midpoint1.X;
  Dummy2:=Y-Midpoint1.Y;
  if Dummy1*Dummy1+Dummy2*Dummy2<=MouseRadius*MouseRadius then
  begin //Cursor position over main diagram
    Paintbox1.Cursor:=crCross;
    Dummy3:=0;
    Dummy4:=Max2;
  end
  else if dipalso then
  begin
    Dummy1:=X-Midpoint2.X;
    Dummy2:=Y-Midpoint2.Y;
    If (Dummy1*Dummy1+Dummy2*Dummy2<=MouseRadius*MouseRadius) and (Dummy1>0) and (Dummy2>0) then
    begin  //Cursor position over dip diagram
      Paintbox1.Cursor:=crCross;
      Dummy3:=-90;
      Dummy4:=Max4;
    end
    else Paintbox1.Cursor:=crDefault;
  end else Paintbox1.Cursor:=crDefault;
  If Paintbox1.Cursor=crCross then
  begin
    If Dummy1<>0 then LHMouseAzimuth:=(Round(450+RadToDeg(ArcTan2(Dummy2,Dummy1)))+Dummy3) mod 360
    else
      case Sgn(Dummy2) of
       -1,0: LHMouseAzimuth:=0;
        1: LHMouseAzimuth:=180;
      end;
    If MouseRadius<>0 then
      LHMouseDip:=Sqrt(Sqr(Dummy1)+Sqr(Dummy2))/MouseRadius*Dummy4
    else LHMouseDip:=90;
    With TecMainWin.StatusBar1.Panels do
      begin
        Items[1].Text:= 'Azimuth: '+FloatToString(LHMouseAzimuth,3,0)+'°';
        Items[2].Text:= 'Value: '+FloatToString(LHMouseDip,2,0)+'%';
      end;
  end
  else with TecMainWin.StatusBar1.Panels do
  begin
    Items[1].Text := '';
    Items[2].Text := '';
    Items[4].Text := '';
  end;
  {$DEFINE Debugging}
  {$UNDEF Debugging}
  {$IFDEF DEBUGGING}
  With TecMainWin.StatusBar1.Panels do
  begin
    Items[2].Text := 'X/Y'+' '+IntToStr(X)+'/'+IntToStr(Y);
    Items[3].Text := 'MP1 X/Y'+' '+IntToStr(Midpoint1.X)+'/'+IntToStr(Midpoint1.Y);
    Items[4].Text := 'MP2 X/Y'+' '+IntToStr(Midpoint2.X)+'/'+IntToStr(Midpoint2.Y);
  end;
  {$ENDIF}
end;

end.
