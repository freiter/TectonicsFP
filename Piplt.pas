unit Piplt;

interface

uses Types, Windows, Graphics, SysUtils, LowHem, Inspect, math, Results, Settings;

type
  TPiPlot = class(TLHWin)
    procedure FormCreate(Sender: TObject; const AFilename: string;  const AExtension: TExtension); override;
    procedure Compute(Sender: TObject); override;
    procedure Angelier1Click(Sender: TObject); override;
    procedure Paste1Click(Sender: TObject); override;
  end;

  TSmallCircleFm = class(TLHWin)
  private
    OpeningAngle, Azimuth, Plunge: Integer;
  public
    procedure Open(Sender: TObject; FOpeningAngle, FAzimuth, FPlunge: Integer; FLabel: String);
    procedure Compute(Sender: TObject); override;
  end;


var Piplot: TPiplot;

implementation

uses Fileops, Draw, TecMain;

procedure TSmallCircleFm.Compute(Sender: TObject);
begin
  Screen.Cursor := CrHourGlass;
  try
    PrepareMetCan(LHMetCan, LHMetafile, LHEnhMetafile, LHWriteWMF);
    SetBackground(Sender, LHMetCan.Handle);
    North;
    NumberLabel;
    {**********************************************************************}
    SmallCircle2(LHMetCan.Handle, Canvas, CenterX, CenterY, Radius, Azimuth, Plunge,
      OpeningAngle, LHSymbSize, LHSymbfillflag, LHSymbType, LHFillBrush, LHPen.Handle);
    LHPen.Style:=psSolid;
    Lineation(LHMetCan.Handle,Nil,CenterX,CenterY,Radius,Azimuth,Plunge,LHSymbSize,
               plunge ,False,LHSymbFillflag,LHSymbType,LHFillBrush, LHPen.Handle);
    inherited;           
  finally
    LHMetCan.Free;
    Screen.Cursor := CrDefault;
  end;
end;


procedure TSmallCircleFm.Open(Sender: TObject; FOpeningAngle, FAzimuth, FPlunge: Integer; FLabel: String);
begin
  LHPlotType:=pt_SmallCircle;
  Number1.Visible:=False;
  TecmainWin.ArrangeMenu(Sender);
  SetLHProperties(LHPlotType);
  OpeningAngle:= FOpeningAngle;
  Azimuth:=FAzimuth;
  Plunge:=FPlunge;
  LHLabel1:=FLabel;
  Canvas.Font:=TecMainWin.Fontdialog1.font;
  LHOnceClick := False;
  LHPasteMode := False;
  LHCopyMode := False;
  LHWriteWMF:=WriteWmfGlobal;
  CreateMetafile(LHMetafile, LHEnhMetafile, LHWriteWMF);
  Label1.Checked:=GlobalLHLabel;
  Compute(Sender);
  Inc(GlobalLHPlots);
  LHPlotNumber:=GlobalLHPlots;
  Caption:='Plot '+IntToStr(LHPlotNumber)+': '+Caption;
  if ResInsp<>nil then ResInsp.Initialize(Self);
  if Inspectorform<>nil then InspectorForm.Initialize(Self);
  if SetForm<>nil then SetForm.Initialize(Self);
end;

procedure TPiplot.FormCreate(Sender: TObject; const AFilename: string;  const AExtension: TExtension);
begin
  LHTectonicData:=td_unknown;
  if Sender=TecMainWin.Lineations1 then
  begin                   //data are lineations
    LHPlotType:=pt_Lineation;
    Angelier1.Checked:=False;
    Angelier2.Checked:=Angelier1.Checked;
    If (Pos('_fa', LowerCase(ExtractFilename(AFilename)))<>0) or (Pos('-fa', LowerCase(ExtractFilename(AFilename)))<>0) then
      LHTectonicData:=td_FoldAxis; //fold axes
    if RecognizeTectonicData then
        case LHTectonicData of
          td_FoldAxis: LinSymbType:=syTriangle;
          td_unknown: PiSymbType:=syCross;
        end;
  end
  else
  begin  //data are planes
    If Pos('s0', LowerCase(ExtractFilename(AFilename)))<>0 then LHTectonicData:=td_BeddingPlane; //bedding planes
    If Pos('_fap', LowerCase(ExtractFilename(AFilename)))<>0 then LHTectonicData:=td_FoldAxialPlane; //fold axial plane
    If Pos('s1', LowerCase(ExtractFilename(AFilename)))<>0 then LHTectonicData:=td_Foliation1; //first foliation
    If Pos('s2', LowerCase(ExtractFilename(AFilename)))<>0 then LHTectonicData:=td_Foliation2; //2nd foliation
    If Pos('s3', LowerCase(ExtractFilename(AFilename)))<>0 then LHTectonicData:=td_Foliation3; //3rd foliation
    Plottype1.Enabled:=True;
    Plottype2.Enabled:=True;
    Angelier1.Caption:='&Great circles';
    Angelier2.Caption:=Angelier1.Caption;
    Hoeppener1.Caption:='P&i Plot';
    Hoeppener2.Caption:=Hoeppener1.Caption;
    //******begin changes for demo-version**********
    {PtAxes1.Caption:='Dip lines';
    PtAxes2.Caption:=PtAxes1.Caption;}
    ptaxes1.Enabled:=False;
    ptaxes1.Visible:=False;
    ptaxes2.Enabled:=ptaxes1.Enabled;
    ptaxes2.Visible:=ptaxes1.Visible;
    //******end changes for demo version*******
    if Sender=TecMainWin.PiPlot1 then
    begin  //piplot
      LHPlotType:=pt_PiPlot;
      Hoeppener1.Checked:=True;
      Hoeppener2.Checked:=True;
      if RecognizeTectonicData then
        case LHTectonicData of
          td_BeddingPlane: PiSymbType:=syCircle;
          else PiSymbType:=syStar;
        end;
    end
    else If Sender=TecMainWin.GreatCircles1 then //greatcircle
    begin
      LHPlotType:=pt_GreatCircle;
      if RecognizeTectonicData then
        case LHTectonicData of
          td_BeddingPlane: GreatPenStyle:=psDot;
          td_FoldAxialPlane: GreatPenStyle:=psDashDot;
          td_Foliation1: GreatPenStyle:=psDash;
          td_unknown: GreatPenStyle:=psSolid;
        end;
    end
    else
    begin
      PtAxes1.Checked:=True;
      PtAxes2.Checked:=True;
      LHPlotType:=pt_DipLine; //dip line
    end;
  end;
  inherited;
  if Sender=TecMainWin.PiPlot1 then LHPoleFlag:=true;
end;


procedure TPiPlot.Compute;
var
  Azimuth, Plunge : Single;
  F : TextFile;
  Nocomment : boolean;
  comment: String;
begin
  Screen.Cursor := CrHourGlass;
  try
    PrepareMetCan(LHMetCan, LHMetafile, LHEnhMetafile, LHWriteWMF);
    SetBackground(Sender, LHMetCan.Handle);
    Try {Open file and get data}
      AssignFile(F, LHFilename);
      Reset(F);
      if not Eof(F) then
      begin
        LHz := 0;
        LHMetCanHandle:=LHMetCan.Handle;
        North;
        if Angelier1.Checked then LHMetCan.Pen.Style := LHPen.Style;
        while not Eof(F) and not LHfailed do
        begin
          ReadPLNDataset(F, Azimuth, Plunge, LHFailed, NoComment, Comment);
          if not LHfailed and NoComment then
          begin
            if Angelier1.Checked then  //greatcircles
            begin
              //GreatCircle2(LHMetCanHandle,Canvas,CenterX,CenterY,Radius,Azimuth, Plunge,
                //           LHz, Number1.Checked, LHPen.Handle, LHLogPen);
              GreatCircle(LHMetCanHandle,Canvas,CenterX,CenterY,Radius,Azimuth, Plunge,
                           LHz, Number1.Checked, LHPen.Handle, LHLogPen);
            end
            else
            begin
              if (LHPlotType<>pt_Lineation) and (LHPlotType<>pt_DipLine) then //bugfix 990818
              begin                                                           //dipline added 000321
                Azimuth:=Round((Azimuth+180)) mod 360;
                Plunge:=90-Plunge;
              end;
              Lineation(LHMetCanHandle,Canvas,CenterX,CenterY,Radius,Azimuth,Plunge,
                        LHSymbSize,LHz,Number1.checked,LHSymbFillFlag,LHSymbType, LHFillBrush, LHPen.Handle);
            end;
            if not Eof(f) then Inc(LHz);
          end else if not NoComment then dec(LHz);
        end; {end of while-loop}
      end else LHfailed:= true;
      CloseFile(F);
      if not LHfailed then
      begin
        NumberLabel;
        inherited;
      end;
    except   {can not open file}
      On EInOutError do Fileused:=true;
    end;
  finally
    LHMetCan.Free;
    Screen.Cursor := CrDefault;
  end;
  if LHfailed or fileused then FileFailed(Piplot);
end;

procedure TPiPlot.Angelier1Click(Sender: TObject);
begin
  if (Sender=Angelier1) or (Sender=Angelier2) then  //Great Circle
  begin
    LHPoleFlag:=False;
    Caption:='Great circle plot - [' +ExtractFileName(LHFilename) +']';
    LHPlotType:=pt_GreatCircle;
  end
  else if (Sender=Hoeppener1) or (Sender=Hoeppener2) then  //Pi Plot
  begin
    LHPoleFlag:=True;
    Caption:= 'Pi-Plot - [' +ExtractFileName(LHFilename) +']';
    LHPlotType:=pt_PiPlot;
  end
  else begin //Dip Lines
    LHPoleFlag:=False;
    Caption:= 'Dip lines - [' +ExtractFileName(LHFilename) +']';
    LHPlotType:=pt_DipLine;
  end;
  inherited;
end;

procedure TPiPlot.Paste1Click(Sender: TObject);
begin
  inherited;
  Plottype1.Enabled:=False;
  Plottype2.Enabled:=Plottype1.Enabled;
end;

end.
