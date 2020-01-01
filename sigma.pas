{DEFINE Debugging} //switch on debugging mode
{$UNDEF Debugging}  //switch off debugging mode
unit Sigma;

interface

uses
  SysUtils, Windows, Graphics, ExtCtrls, LowHem, Dialogs, Math, Menus, Rotate,
  Types, VirtDip, Forms;

type
  TSigmaForm = class(TLHWin)
    procedure FormCreate(Sender: TObject; const aFileName: string; const AExtension: TExtension); override;
    procedure Compute(Sender: TObject); override;
    procedure CalculateHistograms(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure Angelier1click(Sender: TObject); override;
  private
    OldFile: Boolean;
    procedure SetCaption(Sender: TObject; const FFilename: String);
    procedure DrawFluHist(Sender: TObject);
    procedure DrawMohr(Sender: TObject);
  public
    Skipped, NoSense, Max, MaxInterval, nDatasets, Max3, NoofBoxes, Theta: Integer;
    MaxPerc, StressRatio, Max2: Single;
    SFCounts: PZeroIntArray;
    SFFluMohrFPLData: PFluMohrFPLDataArray;
    TensAzimuth, TensPlunge : T1Sing1by3;
    NoofBoxeschanged : Boolean;
  end;

  TSigmaFromFile = class(TSigmaForm)
    procedure FormCreate(Sender: TObject; const aFileName: string; const AExtension: TExtension); override;
  end;

procedure FindRighthandIndex(fIncrement, findex1, findex20, findex21: Integer; point20, point21: TPoint;
     var findex3x: Integer; var fpoint3x: TPoint; var AUpward, fspecial: Boolean);

procedure AssemblePolygon(fppoints1, fppoints2, fppoints3: POpenPointArray;
    startpoint, intsectpt3x0, intsectpt3x1, intsectpt3y0, intsectpt3y1: TPoint; fPolySegments,startindex1, startindex2,
    intsect3x0, intsect3x1, intsect3y0, intsect3y1: integer; fupward: Boolean;
    var FPolygon: POpenPointArray; var nPoints: Integer; var Aspecial: Boolean);

function DrawDihedra(var FCanvas: TCanvas; var FTensAzimuth, FTensPlunge: T1Sing1by3;
  FSymbFillFlag, FSymbFillFlag2: Boolean; FFillBrush, FFillBrush2: TBrush; FPen: TPen): Boolean;

Function DrawTensor(var FCanvas: TCanvas; FCanvas2: TCanvas; FTensAzimuth, FTensPlunge : T1Sing1by3;
  FSymbSize: Single; FSymbFillFlag, FSymbFillFlag2: Boolean; FFillBrush, FFillBrush2: TBrush; FPenHandle: THandle): Boolean;

implementation

uses FileOps, Draw, Tecmain, Invers, Nda, Settings;

procedure TSigmaFromFile.FormCreate(Sender: TObject; const aFileName: string; const AExtension: TExtension);
var Finished: Boolean;
    iDummy: Integer;
    sDummy: Single;
    fInputFile: Textfile;
begin
  lhFileName:=aFileName;
  Finished:=False;
  Skipped:=0;
  try //*************read sigma123 from file**************
    AssignFile(fInputFile, lhFileName);
    Reset(fInputFile);
    try
      lhFailed:= not ReadSigma123(fInputFile, TensAzimuth, TensPlunge, StressRatio, lhz, nDatasets, Skipped);
    finally
      CloseFile(fInputFile);
    end;
    If lhFailed or FileUsed then
    begin
      FileFailed(Self);
      Close;
      Exit;
    end;
    If AExtension<>DIH then
    begin
      AssignFile(fInputFile, lhFileName);
      Reset(fInputFile);
      If not Eof(fInputFile) then
      begin
        lhz:=0;
        While not Eof(fInputFile) and not lhFailed and not Finished do
        begin
          ReadFluMohrFPLData(fInputFile, iDummy, sDummy, sDummy, iDummy, lhFailed, Finished);
          If not Finished then Inc(lhz);
        end;   //end of while-loop
      end else lhFailed:=True;
      If lhz<1 then
      begin
        lhFailed:=True;
        OldFile:=True;
      end else OldFile:=False;
      If lhFailed then
      begin
        CloseFile(fInputFile);
        FileFailed(Self);
        Close;
        Exit;
      end;
      nDatasets:=lhz;
      GetMem(SFFluMohrFPLData, SizeOf(SFFluMohrFPLData^[0])*nDatasets);
      CloseFile(fInputFile);
      AssignFile(fInputFile, lhFileName);
      Reset(fInputFile);
      Finished:=False;
      If not Eof(fInputFile) then //read deviation from shear stress
      begin
        lhz:=0;
        While not Eof(fInputFile) and not lhFailed and not Finished do with SFFluMohrFPLData^[lhz] do
        begin
          ReadFluMohrFPLData(fInputFile, fmSense, fmDipDir, fmDip, fmfluctuation, lhFailed, Finished);
          if (fmSense=0) or (fmSense=5) then Inc(Skipped);
          If not Finished then Inc(lhz);
        end;   {end of while-loop}
      end else lhFailed:=True;
      CloseFile(fInputFile);
    end;
  except   //can not open file
    On EInOutError do FileUsed:=True;
  end;
  if not lhFailed then inherited;
end;

procedure TSigmaForm.Angelier1click(Sender: TObject);
begin
  if Self is TSigmaFromFile then
  begin
    If (Sender=Angelier1) or (Sender=Angelier2) then
    If (lhExtension=INV) or (lhExtension=DIH) then
      lhPlotType:=pt_SigmaDihedra
    else lhPlotType:=pt_LambdaDihedra
    else
    If (Sender=Hoeppener1) or (Sender=Hoeppener2) then
      If (lhExtension=INV) or (lhExtension=DIH) then lhPlotType:=pt_SigmaTensor
      else lhPlotType:=pt_LambdaTensor
    else
      if (Sender=ptAxes1) or (Sender=ptAxes2) then
        lhPlotType:=pt_FluHist
    else
      if (Sender=Mohrcircle1) or (Sender=Mohrcircle2) then
        if lhExtension=INV then
          lhPlotType:=pt_MohrSigma
        else if lhextension=ndf then
          lhplottype:=pt_MohrLambda;
  end
  else if Self is TInversPlot then
  begin
    If (Sender=Angelier1) or (Sender=Angelier2) then lhPlotType:=pt_SigmaDihedra
    else If (Sender=Hoeppener1) or (Sender=Hoeppener2) then lhPlotType:=pt_SigmaTensor
    else if (Sender=ptAxes1) or (Sender=ptAxes2) then lhPlotType:=pt_FluHist
    else if (Sender=Mohrcircle1) or (Sender=Mohrcircle2) then lhPlotType:=pt_MohrSigma;
  end
  else if Self is TNDAPlot then
  begin
    If (Sender=Angelier1) or (Sender=Angelier2) then lhPlotType:=pt_LambdaDihedra
    else If (Sender=Hoeppener1) or (Sender=Hoeppener2) then lhPlotType:=pt_LambdaTensor
    else if (Sender=ptAxes1) or (Sender=ptAxes2) then lhPlotType:=pt_FluHist
    else if (Sender=Mohrcircle1) or (Sender=Mohrcircle2) then lhplottype:=pt_MohrLambda;
  end;
  SetCaption(Sender, lhFileName);
  case lhPlotType of
  pt_MohrSigma, pt_MohrLambda: Number1.Visible:=True;
  else Number1.Visible:=False;
  end;
  inherited;
  if not lhFailed then SigmadihedraOn:=Angelier1.checked;
  if SetForm<>nil then SetForm.Initialize(Self);
end;

procedure TSigmaForm.SetCaption(Sender: TObject; const FFilename: String);
begin
  If Self is TSigmaFromFile then
  begin
    if (lhplottype=pt_SigmaDihedra) or (lhplottype=pt_SigmaTensor) then
      Caption := 'Sigma123 - [' +ExtractFileName(FFilename) +']'
    else if (lhplottype=pt_lambdaDihedra) or (lhplottype=pt_lambdaTensor) then
      Caption := 'Lambda123 - [' +ExtractFileName(FFilename) +']'
    else if lhplottype=pt_FluHist then
      Caption := 'Fluctuation histogram - [' +ExtractFileName(FFilename) +']'
    else if (lhplottype=pt_MohrSigma) or (lhplottype=pt_MohrLambda) then
      Caption := 'Mohr´s circle - [' +ExtractFileName(FFilename) +']'
  end
  else
    If Self is TInversPlot then
      Caption := 'Inverse-calculation - [' +ExtractFileName(FFilename) +']'
    else
      If Self is TNDAPlot then
        Caption := 'NDA-calculation - [' +ExtractFileName(FFilename) +']';
end;

procedure TSigmaForm.FormCreate(Sender: TObject; const aFileName: string; const AExtension: TExtension);
var MyFlag: Boolean;
begin
  If SetForm<>nil then
  begin
    if Sender<>SetForm.ApplyBtn then NoofBoxes:=FluHIntervals;
  end else NoofBoxes:=10;
  PlotType1.Enabled:=True;
  PlotType2.Enabled:=True;
  Angelier1.Caption:='&Dihedra';
  Angelier2.Caption:=Angelier1.Caption;
  Hoeppener1.Caption:='&Stress axes';
  Hoeppener2.Caption:=Hoeppener1.Caption;
  ptAxes1.Caption:='&Fluct.-histogr.';
  ptAxes2.Caption:=ptAxes1.Caption;
  Number1.Visible:=False;
  if SetForm<>nil then
    MyFlag:=Sender<>SetForm.ApplyBtn
  else Myflag:=True;
  if MyFlag then
  begin
    if Self is TSigmafromFile then
    begin
      If Sender=TecMainWin.Dihedra3 then Angelier1.checked:=True
      else if Sender=TecMainWin.Stressaxes1 then angelier1.checked:=False;
    end
    else Angelier1.checked:=SigmadihedraOn;
    Angelier2.Checked:=Angelier1.Checked;
    Hoeppener1.checked:= not Angelier1.checked;
    Hoeppener2.Checked:=Hoeppener1.Checked;
    IF AExtension<>DIH then
    begin
      MohrCircle1.Visible:=True;
      MohrCircle1.Enabled:=True;
      MohrCircle2.Visible:=True;
      MohrCircle2.Enabled:=True;
    end
    else
    begin
      ptAxes1.Visible:=False;
      ptAxes1.Enabled:=False;
      ptAxes2.Visible:=False;
      ptAxes2.Enabled:=False;
    end;
    If Sender=TecMainWin.FluctHistogram1 then
    begin
      ptAxes1.Checked:=True;
      ptAxes2.Checked:=ptAxes1.checked;
    end
    else If Sender=TecMainWin.Mohrcircle1 then
    begin
      Mohrcircle1.Checked:=True;
      Mohrcircle2.Checked:=Mohrcircle1.checked;
      Number1.Visible:=True;
    end;
    If Angelier1.Checked then
    begin
      If Self is TSigmaFromFile then
      case AExtension of
        INV, DIH: lhPlotType:=pt_SigmaDihedra;
        NDF:      lhPlotType:=pt_LambdaDihedra;
      end
      else
        If Self is TInversPlot then lhPlotType:=pt_SigmaDihedra
        else If Self is TNDAPlot then lhPlotType:=pt_LambdaDihedra;
    end
    else if Hoeppener1.Checked then
    begin
      If Self is TSigmaFromFile then
      case AExtension of
        INV, DIH: lhPlotType:=pt_SigmaTensor;
        NDF:      lhPlotType:=pt_LambdaTensor;
      end
      else
        If Self is TInversPlot then lhPlotType:=pt_SigmaTensor
        else If Self is TNDAPlot then lhPlotType:=pt_LambdaTensor;
    end
    else if ptAxes1.checked then lhplottype:=pt_fluhist
    else if Mohrcircle1.checked then
      case AExtension of
        INV: lhPlotType:=pt_MohrSigma;
        NDF: lhPlotType:=pt_MohrLambda;
      end;
  end;  //if sender <>ApplyBtn
  SetCaption(Sender, aFileName);
  inherited;
end;

procedure TSigmaForm.CalculateHistograms(Sender: TObject);
var x,i: Integer;
    sinuserror: Single;
    hit: Boolean;
begin
  NoSense:=0;
  Max:= 0;
  MaxInterval:=0;
  GetMem(SFCounts,SizeOf(SFCounts^[0])*(NoOfBoxes+1));
  for x:= 0 to NoofBoxes-1 do SFCounts^[x]:=0;
  For i:=0 to nDatasets-1 do with SFFluMohrFPLData^[i] do
  begin
    If (fmSense<>0) and (fmSense<>5) or (Self is tinversplot) or (lhextension=inv) then
    begin
      If fmFluctuation>=0 then
      begin
        SinusError:=Sin(DegToRad(fmFluctuation));
        hit := False;
        x := 0;
        while (x<=NoofBoxes-1) and not hit do
        begin
          IF (SinusError>=x/NoofBoxes) AND (SinusError<(x+1)/NoofBoxes) THEN
          begin
            Inc(SFCounts^[x]);
            hit := True;
          end;
          IF Max<SFCounts^[x] THEN
          begin
            Max := SFCounts^[x];
            MaxInterval:=x;
          end;
          Inc(X);
        end;
      end;
    end else Inc(NoSense);
  end;   //end of for-loop
end;

procedure TSigmaForm.Compute(Sender: TObject);
const
 {constants to draw symbols}
 TriangleSizeRate=0.020;  {Rate of size of linear triangle related to radius of diagram}

var dummy, dumy,triangleheight: Integer;
    textdummy: String;
    xpoints: array[0..2] of TPoint;

begin
  Screen.Cursor := CrHourGlass;
  try
    PrepareMetCan(lhMetCan, LHMetafile, LHEnhMetafile,lhWriteWMF);
    SetBackground(Sender, lhMetCan.Handle);
    If not lhFailed then
    begin
      //MetCan.Pen:=lhPen;
      IF (lhPlotType=pt_SigmaTensor) or (lhPlotType=pt_LambdaTensor) then
      begin
        North;
        DrawTensor(lhMetCan, Canvas, TensAzimuth, TensPlunge, lhSymbSize,
                   lhSymbFillFlag, lhSymbFillFlag2, lhFillBrush, lhFillBrush2, lhPen.Handle);
      end
      else
      If lhPlotType=pt_FluHist then
      begin
        CalculateHistograms(Sender);
        DrawFluHist(Sender);
        FreeMem(SFCounts,SizeOf(SFCounts^[0])*(NoOfBoxes+1));
      end
      else if (lhPlotType=pt_SigmaDihedra) or (lhPlotType=pt_LambdaDihedra) then
      begin
        If not DrawDihedra(lhMetCan, TensAzimuth, TensPlunge, lhSymbFillFlag, lhSymbFillFlag2, lhFillBrush, lhFillBrush2, lhPen) then
        begin
          Screen.Cursor:=crDefault;
          lhFailed:=True;
          SigmaDihedraOn:=False;
          messagedlg('Plot failed.',mtError,[mbOk],0);
          Exit;
        end;
        North;
      end
      else if (lhPlotType=pt_MohrSigma) or (lhPlotType=pt_MohrLambda) then
        DrawMohr(Sender);
      //Write Explanation
      dummy:=6-lhMetCan.Font.Height;
      If not lhCopyMode and not lhPasteMode then
      begin
        If Label1.Checked then
        begin
          lhMetCan.Pen:=lhPen;
          IF (lhPlotType=pt_SigmaTensor) or (lhPlotType=pt_LambdaTensor) then with lhMetCan do
          begin
            dumy:=Round(lhSymbSize);//Round(Radius*LinearCircleRate);
            triangleheight:=Round(Radius*Sqrt(3)*lhSymbSize/320);
            if lhSymbFillFlag then Brush := lhFillBrush;
            Ellipse(CenterX+160-dumy, labeltop+dummy div 2-dumy,
                    CenterX+160+dumy, labeltop+dummy div 2+dumy);
            xpoints[0].x:=CenterX+160-triangleheight;
            xpoints[0].y:=labeltop+5*dummy div 2+dumy;
            xpoints[1].x:=CenterX+160+triangleheight;
            xpoints[1].y:=xpoints[0].y;
            xpoints[2].x:=CenterX+160;
            xpoints[2].y:=labeltop+5*dummy div 2-dumy;
            if lhSymbFillFlag2 then Brush := lhFillBrush2
            else Brush.Style:=bsClear;
            Polygon(xpoints);
            if lhSymbFillFlag or lhsymbfillflag2 then Brush.Style := bsClear;
            Rectangle(CenterX+160-dumy, labeltop+3*dummy div 2-dumy,
                      CenterX+160+dumy, labeltop+3*dummy div 2+dumy);
            Case lhPlotType of
              pt_SigmaDihedra, pt_SigmaTensor: Textdummy:='Sigma';
              pt_LambdaDihedra, pt_LambdaTensor: Textdummy:='Lambda';
            end;
            For dumy:=0 to 2 do
              TextOut(CenterX+180, labeltop+dummy*dumy, Textdummy+IntToStr(dumy+1));
          end;
          If (lhPlotType=pt_SigmaDihedra) or (lhPlotType=pt_LambdaDihedra) then
          begin
            dumy:=10;
            lhMetCan.Pen.Style:=psSolid;
            if lhsymbfillflag then SelectObject(lhMetCan.Handle,lhFillbrush.Handle)
            else lhMetCan.Brush.Style:=bsclear;
            lhMetCan.Rectangle(CenterX+160-dumy, labeltop+2*dummy div 2-dumy,
                             CenterX+160+dumy, labeltop+2*dummy div 2+dumy);
            if lhsymbfillflag2 then SelectObject(lhMetCan.Handle,lhFillbrush2.Handle)
            else lhMetCan.Brush.Style:=bsclear;

            lhMetCan.Rectangle(CenterX+160-dumy, labeltop+5*dummy div 2-dumy,
                             CenterX+160+dumy, labeltop+5*dummy div 2+dumy);
            lhMetCan.Brush.Style:=bsclear;
            lhMetCan.TextOut(CenterX+180, labeltop+2*dummy div 2-dumy, 'Compressive');
            lhMetCan.TextOut(CenterX+180, labeltop+5*dummy div 2-dumy, 'Tensile');
          end;
          lhMetCan.Brush.Style:=bsClear;
          If not lhCopyMode and not lhPasteMode then with lhMetCan do
          begin
            Case lhPlotType of
              pt_MohrSigma, pt_MohrLambda:
            else  TextOut(labelleft,labeltop,lhLabel1);
            end;
            Case lhPlotType of
              pt_SigmaTensor, pt_SigmaDihedra: TextOut(labelleft,labeltop+dummy,'Sigma123');
              pt_LambdaTensor, pt_LambdaDihedra: TextOut(labelleft,labeltop+dummy,'Lambda123');
            end;
          end
          else with lhMetCan do
          begin
            TextOut(labelleft,labeltop,lhLabel1);
            TextOut(labelleft,labeltop+dummy,'Stresst axes');
          end;
        end;
      end;
      GlobalFailed:=False;
    end;
  finally
    lhMetCan.Free;
    Screen.Cursor := CrDefault;
  end;
  inherited;
  If Self is TSigmaFromFile then  //read stress data from file
  begin
    If (lhPlotType=pt_SigmaDihedra) or (lhPlotType=pt_SigmaTensor) then
    begin
      lhPlotInfo:=lhPlotInfo+#13#10+
        'Datasets total: '+IntToStr(nDatasets)+#13#10;
      If lhextension<>dih then lhPlotInfo:=lhPlotInfo+'Sense substituted: '
      else lhPlotInfo:=lhPlotInfo+'Datasets Skipped: ';
      lhPlotInfo:=lhPlotInfo+IntToStr(Skipped)+#13#10+
        'Sigma1: '+FloatToString(TensAzimuth[1], 3,0)+' / '+FloatToString(TensPlunge[1],2,0)+#13#10+
        'Sigma2: '+FloatToString(TensAzimuth[2], 3,0)+' / '+FloatToString(TensPlunge[2],2,0)+#13#10+
        'Sigma3: '+FloatToString(TensAzimuth[3], 3,0)+' / '+FloatToString(TensPlunge[3],2,0);
      If lhextension<>dih then lhPlotInfo:=lhPlotInfo+#13#10+'Stress ratio: '+FloatToString(StressRatio, 1,4);
    end
    else
    If (lhPlotType=pt_LambdaDihedra) or (lhPlotType=pt_LambdaTensor) then
      lhPlotInfo:=lhPlotInfo+#13#10+
        'Lambda1: '+FloatToString(TensAzimuth[1], 3,0)+' / '+FloatToString(TensPlunge[1],2,0)+#13#10+
        'Lambda2: '+FloatToString(TensAzimuth[2], 3,0)+' / '+FloatToString(TensPlunge[2],2,0)+#13#10+
        'Lambda3: '+FloatToString(TensAzimuth[3], 3,0)+' / '+FloatToString(TensPlunge[3],2,0)+#13#10+
        'Strain ratio: '+FloatToString(StressRatio, 1,4)+#13#10+
        'Datasets total: '+IntToStr(nDatasets)+#13#10+
        'Datasets Skipped: '+IntToStr(Skipped)
     else IF lhPlotType=pt_FluHist then lhPlotInfo:=lhPlotInfo+#13#10+
     'Datasets total: '+IntToStr(nDatasets)+#13#10+
      'Intervals: '+IntToStr(NoOfBoxes)+#$D#$A+
      'Maximum: '+IntToStr(Max)+' counts ('+FloatToString(MaxPerc,2,1)+
      ' %) in interval '+IntToStr(MaxInterval+1)
    else if (lhplottype=pt_mohrsigma) or (lhplottype=pt_mohrlambda) then
    begin
      lhPlotInfo:=lhPlotInfo+#13#10+
      'Datasets total: '+IntToStr(nDatasets)+#13#10;
      IF lhPlotType=pt_MohrSigma then lhPlotInfo:=lhPlotInfo+
        'Datasets substituted: '+IntToStr(NoSense)+#13#10+'Stress ratio: '
      else lhPlotInfo:=lhPlotInfo+'Datasets Skipped: '+IntToStr(NoSense)+#13#10'Strain ratio: ';
      lhPlotInfo:=lhPlotInfo+FloatToString(StressRatio, 1,4);
    end;
  end
  else //Sigma calculation
  begin
    If Self is TInversPlot then
    begin
      if (lhplottype=pt_sigmadihedra) or (lhplottype=pt_sigmatensor) then lhPlotInfo:=lhPlotInfo+#13#10+
        'Sigma1: '+FloatToString(TensAzimuth[1], 3,0)+' / '+FloatToString(TensPlunge[1],2,0)+#13#10+
        'Sigma2: '+FloatToString(TensAzimuth[2], 3,0)+' / '+FloatToString(TensPlunge[2],2,0)+#13#10+
        'Sigma3: '+FloatToString(TensAzimuth[3], 3,0)+' / '+FloatToString(TensPlunge[3],2,0)+#13#10+
        'Stress ratio: '+FloatToString(StressRatio, 1,4)+#13#10+
        'Datasets total: '+IntToStr(nDatasets)+#$D#$A+
        'Sense substituted: '+IntToStr(Skipped)+#13#10+
        'Negative sense expected for '+IntToStr((Self as TStressTensorPlot).negative)+' datasets'
      else if lhplottype=pt_fluhist then lhPlotInfo:=lhPlotInfo+#13#10+
        'Datasets total: '+IntToStr(nDatasets)+#13#10+
        'Intervals: '+IntToStr(NoOfBoxes)+#$D#$A+
        'Maximum: '+IntToStr(Max)+' counts ('+FloatToString(MaxPerc,2,1)+
        ' %) in interval '+IntToStr(MaxInterval+1)
      else if lhplottype=pt_mohrsigma then lhPlotInfo:=lhPlotInfo+#13#10+
        'Datasets total: '+IntToStr(nDatasets)+#13#10+
        'Datasets substituted: '+IntToStr(Skipped)+#13#10+
        'Stress ratio: '+FloatToString(StressRatio, 1,4);
    end
    else If Self is TNDAPlot then
    begin
      if (lhplottype=pt_lambdadihedra) or (lhplottype=pt_lambdatensor) then lhPlotInfo:=lhPlotInfo+#13#10+
        'Lambda1: '+FloatToString(TensAzimuth[1], 3,0)+' / '+FloatToString(TensPlunge[1],2,0)+#13#10+
        'Lambda2: '+FloatToString(TensAzimuth[2], 3,0)+' / '+FloatToString(TensPlunge[2],2,0)+#13#10+
        'Lambda3: '+FloatToString(TensAzimuth[3], 3,0)+' / '+FloatToString(TensPlunge[3],2,0)+#13#10+
        'Theta: '+IntToStr(Theta)+' °'+#13#10+
        'Strain ratio: '+FloatToString(StressRatio, 1,4)+#13#10+
        'Datasets total: '+IntToStr(nDatasets)+#$D#$A+
        'Datasets Skipped: '+IntToStr(Skipped)+#13#10+
        'Negative sense expected for '+IntToStr((Self as TStressTensorPlot).negative)+' datasets'
      else if lhplottype=pt_fluhist then lhPlotInfo:=lhPlotInfo+#13#10+
        'Datasets total: '+IntToStr(nDatasets)+#13#10+
        'Datasets Skipped: '+IntToStr(Skipped)+#13#10+
        'Intervals: '+IntToStr(NoOfBoxes)+#$D#$A+
        'Maximum: '+IntToStr(Max)+' counts ('+FloatToString(MaxPerc,2,1)+
        ' %) in interval '+IntToStr(MaxInterval+1)
      else if lhplottype=pt_mohrlambda then
        lhPlotInfo:=lhPlotInfo+#13#10+
        'Datasets total: '+IntToStr(nDatasets)+#13#10+
        'Datasets Skipped: '+IntToStr(Skipped)+#13#10+
        'Strain ratio: '+FloatToString(StressRatio, 1,4);
    end;
    lhPlotInfo:=lhPlotInfo+#13#10+(Self as TStresstensorplot).StressTenPlotInfo;
  end;
end;


procedure FindRighthandIndex(fIncrement, findex1, findex20, findex21: Integer; point20, point21: TPoint;
     var findex3x: Integer; var fpoint3x: TPoint; var AUpward, fspecial: Boolean);
var index20, index21: Integer;
begin
  index20:=findex20;
  index21:=findex21;
  if findex20<findex1 then Inc(index20, fIncrement);
  if findex21<findex1 then Inc(index21, fIncrement);
  if (index20-findex1>index21-findex1) then
    if ((index20-findex1<>fIncrement div 2) and (index21-findex1<>0)) and
       ((index21-findex1<>fIncrement div 2) and (index20-findex1<>0)) then
    begin
      findex3x:=findex21;
      fpoint3x:=point21;
      Aupward:=False;
      fspecial:=False;
    end
    else
    begin
      findex3x:= findex20;
      fpoint3x:=point20;
      Aupward:=True;
      fspecial:=True;
    end
  else
  begin
    if ((index20-findex1<>fIncrement div 2) and (index21-findex1<>0)) and
       ((index21-findex1<>fIncrement div 2) and (index20-findex1<>0)) then
    begin
      findex3x:= findex20;
      fpoint3x:=point20;
      Aupward:=True;
      fspecial:=False;
    end
    else
    begin
      findex3x:=findex21;
      fpoint3x:=point21;
      Aupward:=True;
      fspecial:=True;
    end;
  end;
end;

procedure AssemblePolygon(fppoints1, fppoints2, fppoints3: POpenPointArray;
  startpoint, intsectpt3x0, intsectpt3x1, intsectpt3y0, intsectpt3y1: TPoint; fPolySegments,startindex1, startindex2,
    intsect3x0, intsect3x1, intsect3y0, intsect3y1: integer; fupward: Boolean;
    var FPolygon: POpenPointArray; var nPoints: Integer; var Aspecial: Boolean);
var pt, i, intsect3xx: Integer;
    intsectpt3xx: TPoint;
    upward: Boolean;
begin
  npoints:=0;
  fpolygon^[0]:=startpoint;
  Inc(npoints);
  pt:=npoints;
  if fupward then
  begin
    For i:=startindex1+1 to fPolySegments-1 do
    begin
      fpolygon^[i-startindex1+pt-1]:= fppoints1^[i];
      Inc(nPoints);
    end;
    fpolygon^[nPoints]:=intsectpt3x1;
  end
  else
  begin
    For i:=startindex1 downto 0 do
    begin
      fpolygon^[startindex1+pt-i]:= fppoints1^[i];
      Inc(nPoints);
    end;
    fpolygon^[nPoints]:=intsectpt3x0;
  end;
  Inc(nPoints);
  pt:=nPoints;
  if fupward then
  begin
    FindRighthandIndex(fPolySegments*4, intsect3x1, intsect3y0,intsect3y1, intsectpt3y0, intsectpt3y1,
      intsect3xx, intsectpt3xx, upward, Aspecial);
    if Aspecial then
    begin
      if startindex1>0 then
      begin
        npoints:=0;
        Startpoint:=intsectpt3x0;
        fpolygon^[npoints]:= Startpoint;
        Inc(npoints);
        pt:=npoints;
        For i:=0 to fPolySegments-1 do
        begin
          fpolygon^[i+pt]:= fppoints1^[i];
          Inc(nPoints);
        end;
      fpolygon^[nPoints]:=intsectpt3x1;
      Inc(nPoints);
      pt:=nPoints;
      end;
      if Sqr(fpolygon^[pt-1].x-fppoints2^[0].x)+Sqr(fpolygon^[pt-1].y-fppoints2^[0].y)<
         Sqr(fpolygon^[pt-1].x-fppoints2^[fPolySegments].x)+Sqr(fpolygon^[pt-1].y-fppoints2^[fPolySegments].y) then
      For i:=0 to fPolySegments-1 do
      begin
        fpolygon^[pt+i]:= fppoints2^[i];
        Inc(nPoints);
      end
      else
      For i:=fPolySegments downto 0 do
      begin
        fpolygon^[pt+fPolySegments-i]:= fppoints2^[i];
        Inc(nPoints);
      end;
    end
    else
    begin
      if intsect3xx<intsect3x1 then intsect3xx:=intsect3xx+fPolySegments*4;
      For i:=intsect3x1+1 to intsect3xx do
      begin
        fpolygon^[pt-1-intsect3x1+i]:= fppoints3^[i mod (fPolySegments*4)];
        Inc(nPoints);
      end;
    end;
  end
  else
  begin
    FindRighthandIndex(fPolySegments*4, intsect3x0, intsect3y0,intsect3y1, intsectpt3y0, intsectpt3y1,
      intsect3xx, intsectpt3xx, upward, Aspecial);
    if intsect3xx<intsect3x0 then intsect3xx:=intsect3xx+fPolySegments*4;
    For i:=intsect3x0+1 to intsect3xx do
    begin
      fpolygon^[pt-1-intsect3x0+i]:= fppoints3^[i mod (fPolySegments*4)];
      Inc(nPoints);
    end;
  end;
  pt:=nPoints;
  if Aspecial then
  begin
    if not fupward then
    begin
      fpolygon^[npoints]:=intsectpt3xx;
      Inc(npoints);
      pt:=nPoints;
      For i:=fPolySegments-1 downto startindex1+1 do
      begin
        fpolygon^[fPolySegments-1+pt-i]:= fppoints1^[i];
        Inc(nPoints);
      end;
    end;
  end
  else
  begin
    fpolygon^[nPoints]:=intsectpt3xx;
    Inc(nPoints);
    pt:=npoints;
    if upward then
      For i:=0 to startindex2 do
      begin
        fpolygon^[pt+i]:= fppoints2^[i];
        Inc(nPoints);
      end
    else
      For i:=fPolySegments downto startindex2+1 do
      begin
        fpolygon^[pt+fPolySegments-i]:= fppoints2^[i];
        Inc(nPoints);
      end;
  end;
  fpolygon^[nPoints]:=Startpoint;
end;

function DrawDihedra(var FCanvas: TCanvas; var FTensAzimuth, FTensPlunge: T1Sing1by3;
  FSymbFillFlag, FSymbFillFlag2: Boolean; FFillBrush, FFillBrush2: TBrush; FPen: TPen): Boolean;
var h, xxx, yyy, degdipdir, x, y, rr, openwidth, rp, m1, b1, m2, b2, xs, ys, alpha : Single;
    APolysegments, i, j, z1, z2, z3, z4, lhz: Integer;
    PPoints1, PPoints2, PPoints3, PPGpoints1, PPGpoints2, PPGpoints3, PPGpoints4 : POpenPointArray;
    PGPoints1, PGPoints2, PGPoints3, PGPoints4, intsectcount, points, points1, points2, points3,
    intsect12, intsect21, intsect310, intsect311, intsect320, intsect321: Integer;
    Sigma2, intsectpt12, intsectPt310, intsectPt311, intsectPt320, intsectPt321: TPoint;
    FAzimuth, FPlunge: T1Sing1by2;
    sensechanged, special: Boolean;
    errorbuffer: array[1..3] of Single;
    index: array[1..3] of integer;
    ferror: array[1..4,1..3] of Single;
    PenStore: HDC;
    mylogpen: tlogpen;
    textdummy: string;
 const fsymbolsize: integer= 10;   

begin
  Result:=False;
  Rot(False, 45,FTensAzimuth[2],FTensPlunge[2],FTensAzimuth[1],FTensPlunge[1], FAzimuth[1], FPlunge[1], SenseChanged);
  FlaechLin(FTensAzimuth[2],FTensPlunge[2],FAzimuth[1],FPlunge[1], True, FAzimuth[1],FPlunge[1]);
  {$IFDEF Debugging}
    //GreatCircle2(FCanvas.Handle,FCanvas,CenterX,CenterY,Radius,FAzimuth[1], FPlunge[1] ,lhz,
    //            False, FPen.Handle, myLogPen);
  {$ENDIF}
  Rot(False, -45,FTensAzimuth[2],FTensPlunge[2],FTensAzimuth[1],FTensPlunge[1], FAzimuth[2], FPlunge[2], SenseChanged);
  FlaechLin(FTensAzimuth[2],FTensPlunge[2],FAzimuth[2],FPlunge[2], True, FAzimuth[2],FPlunge[2]);
  {$IFDEF Debugging}
    //GreatCircle2(FCanvas.Handle,FCanvas,CenterX,CenterY,Radius,FAzimuth[2], FPlunge[2],lhz,
      //                  False, fPen.Handle, myLogPen);
    FCanvas.Brush:=FFillBrush;
  {$ENDIF}
  //*******Find the two nearest polygon-indices for the intersecting point*****
  //FindNearPolyIndex(FCanvas,FTensAzimuth,FTensPlunge, lhsymbsize,FAzimuth, FPlunge,
  //  Radius, CenterX, CenterY, lhFillbrush);
  //*****Calculate X- and Y-position of intersecting point*********************
  if Abs(FTensPlunge[2]) >= 89 then FTensPlunge[2]:=89.99*Sgn(FTensPlunge[2]);
  h := Radius*SQRT2*Sin(DegToRad(90-FTensPlunge[2])/2);
  xxx:=Centerx+h*Sin(DegToRad(FTensAzimuth[2]));
  yyy:=CenterY-h*Cos(DegToRad(FTensAzimuth[2]));
  {$IFDEF Debugging}
    ellipse(FCanvas.handle,round(xxx-fsymbolsize), round(yyy-fsymbolsize), round(xxx+fsymbolsize),
            round(yyy+fsymbolsize));
  {$ENDIF}
  if polysegments<21 then APolySegments:=polysegments
  else APolySegments:=20;
  GetMem(PPoints1,SizeOf(PPoints1^[0])*(APolySegments+1));
  GetMem(PPoints2,SizeOf(PPoints2^[0])*(APolySegments+1));
  GetMem(PPoints3,SizeOf(PPoints3^[0])*(4*APolySegments+1));
  intsectPt310.x:=0;
  intsectPt311.x:=0;
  intsectPt320.x:=0;
  intsectPt321.x:=0;
  intsectPt12.x:=0;
  //try
    For i:=1 to 2 do
    begin
      DegDipDir:= DegToRad(FAzimuth[i]-90);
      if FPlunge[i]>=90 then FPlunge[i]:=89.9;
      If FPlunge[i]<90 then
      begin
        h:=Radius*SQRT2*Sin(DegToRad((90-FPlunge[i]))/2);
        DegDipDir:=-DegDipDir;
        X:=CenterX-(Radius*Radius-h*h)/2/h*Cos(DegDipDir);
        Y:=CenterY+(Radius*Radius-h*h)/2/h*Sin(DegDipDir);
        RR:=(h*h + Radius * Radius)/2/h;
        OpenWidth:=ArcSin(Radius/RR);
        DegDipDir:=DegToRad(FAzimuth[i]);
        For points:= 0 to APolySegments do
        begin
          Case i of
            1: begin
              PPoints1^[points].x:=Round(X+RR*Sin(DegDipDir-OpenWidth*(1-2*points/APolySegments)));
              PPoints1^[points].y:=Round(Y-RR*Cos(DegDipDir-OpenWidth*(1-2*points/APolySegments)));
            end;
            2: begin
              PPoints2^[points].x:=Round(X+RR*Sin(DegDipDir-OpenWidth*(1-2*points/APolySegments)));
              PPoints2^[points].y:=Round(Y-RR*Cos(DegDipDir-OpenWidth*(1-2*points/APolySegments)));
            end;
          end;
        end;
      end;
    end; //for
    //****find intersecting point between two polygons which are the great circles****
    intsectcount:=0;
    For points1:= 0 to APolySegments-1 do
    begin
      if PPoints1^[points1+1].x<>PPoints1^[points1].x then
      begin
        m1:=(PPoints1^[points1+1].y-PPoints1^[points1].y)/(PPoints1^[points1+1].x-PPoints1^[points1].x);
        b1:=PPoints1^[points1].y-PPoints1^[points1].x*m1;
      end;
      For points2:= 0 to APolySegments-1 do
      begin
        if PPoints2^[points2+1].x<>PPoints2^[points2].x then
        begin
          m2:=(PPoints2^[points2+1].y-PPoints2^[points2].y)/(PPoints2^[points2+1].x-PPoints2^[points2].x);
          b2:=PPoints2^[points2].y-PPoints2^[points2].x*m2;
          if PPoints1^[points1+1].x<>PPoints1^[points1].x then
          begin
            If m1<>m2 then
            begin
              xs:=(b2-b1)/(m1-m2);
              ys:=(b2*m1-b1*m2)/(m1-m2);
            end
            else
            begin
              xs:=0;
              ys:=0;
            end;
          end
          else
          begin  //limes for delta x1=0
            xs:=PPoints1^[points1].x;
            ys:=b2+m2*PPoints1^[points1].x;
          end;
        end
        else
        begin
          if PPoints1^[points1+1].x<>PPoints1^[points1].x then
          begin  //limes for delta x2=0
            xs:=PPoints2^[points2].x;
            ys:=b1+m1*PPoints2^[points2].x;
          end
          else
          begin
            xs:=0;
            ys:=0;
            end;
          end;
          if (Abs(xs-PPoints1^[points1].x) <= Abs(PPoints1^[points1+1].x-PPoints1^[points1].x))
            and (Abs(xs-PPoints1^[points1+1].x) <= Abs(PPoints1^[points1+1].x-PPoints1^[points1].x))
            and (Abs(ys-PPoints1^[points1].y) <= Abs(PPoints1^[points1+1].y-PPoints1^[points1].y))
            and (Abs(ys-PPoints1^[points1+1].y) <= Abs(PPoints1^[points1+1].y-PPoints1^[points1].y))
            and (Abs(xs-PPoints2^[points2].x) <= Abs(PPoints2^[points2+1].x-PPoints2^[points2].x))
            and (Abs(xs-PPoints2^[points2+1].x) <= Abs(PPoints2^[points2+1].x-PPoints2^[points2].x))
            and (Abs(ys-PPoints2^[points2].y) <= Abs(PPoints2^[points2+1].y-PPoints2^[points2].y))
            and (Abs(ys-PPoints2^[points2+1].y) <= Abs(PPoints2^[points2+1].y-PPoints2^[points2].y))
            and  (intsectpt12.x=0) then
          begin
            {$IFDEF Debugging}
              Ellipse(FCanvas.Handle, round(xs)-5, round(ys)-5, round(xs)+5, round(ys)+5);
              TextDummy:=IntToStr(points1)+','+IntToStr(points2);
              fcanvas.brush.style:=bsclear;
              Textout(FCanvas.Handle, round(xs), round(ys), pchar(TextDummy),Length(TextDummy));
            {$ENDIF}
            intsect12:=points1;
            intsect21:=points2;
            intsectpt12.x:=round(xs);
            intsectpt12.y:=round(ys);
            Inc(intsectcount);
          end;
        end; //For
      end;  //for
      alpha:=Pi/APolySegments/2;
      for points3:=0 to 4*APolySegments do
      begin
        PPoints3^[points3].x:=CenterX+Round(Radius*Cos(alpha*points3));
        PPoints3^[points3].y:=CenterY+Round(Radius*Sin(alpha*points3));
      end;
      //****find intersecting points between great circles and surrounding circle****
      for i:=1 to 2 do
        For points:= 0 to APolySegments-1 do
        begin
          if (points=0) or (points=APolySegments-1) then
          begin
            case i of
              1: if PPoints1^[points+1].x<>PPoints1^[points].x then
              begin
                m1:=(PPoints1^[points+1].y-PPoints1^[points].y)/(PPoints1^[points+1].x-PPoints1^[points].x);
                b1:=PPoints1^[points].y-PPoints1^[points].x*m1;
              end;
              2: if PPoints2^[points+1].x<>PPoints2^[points].x then
              begin
                m1:=(PPoints2^[points+1].y-PPoints2^[points].y)/(PPoints2^[points+1].x-PPoints2^[points].x);
                b1:=PPoints2^[points].y-PPoints2^[points].x*m1;
              end;
            end;  //case
            For points3:= 0 to 4*APolySegments-1 do
            begin
              case i of
                1: if PPoints1^[points+1].x<>PPoints1^[points].x then
                begin
                  if PPoints3^[points3+1].x<>PPoints3^[points3].x then
                  begin
                    m2:=(PPoints3^[points3+1].y-PPoints3^[points3].y)/(PPoints3^[points3+1].x-PPoints3^[points3].x);
                    b2:=PPoints3^[points3].y-PPoints3^[points3].x*m2;
                    If m1<>m2 then
                    begin
                      xs:=(b2-b1)/(m1-m2);
                      ys:=(b2*m1-b1*m2)/(m1-m2);
                    end
                    else
                    begin
                      xs:=0;
                      ys:=0;
                    end;
                  end
                  else
                  begin  //limes for delta x3=0
                    xs:=PPoints3^[points3].x;
                    ys:=b1+m1*PPoints3^[points3].x;
                  end
                end
                else
                begin
                  if PPoints3^[points3+1].x<>PPoints3^[points3].x then
                  begin
                    m2:=(PPoints3^[points3+1].y-PPoints3^[points3].y)/(PPoints3^[points3+1].x-PPoints3^[points3].x);
                    b2:=PPoints3^[points3].y-PPoints3^[points3].x*m2;
                    xs:=PPoints1^[points].x;
                    ys:=b2+m2*PPoints1^[points].x;
                  end
                  else
                  begin
                    xs:=0;
                    ys:=0;
                  end;
                end;
                2: if PPoints2^[points+1].x<>PPoints2^[points].x then
                begin
                  if PPoints3^[points3+1].x<>PPoints3^[points3].x then
                  begin
                    m2:=(PPoints3^[points3+1].y-PPoints3^[points3].y)/(PPoints3^[points3+1].x-PPoints3^[points3].x);
                    b2:=PPoints3^[points3].y-PPoints3^[points3].x*m2;
                    If m1<>m2 then
                    begin
                      xs:=(b2-b1)/(m1-m2);
                      ys:=(b2*m1-b1*m2)/(m1-m2);
                    end
                    else
                    begin
                      xs:=0;
                      ys:=0;
                    end;
                  end
                  else
                  begin  //limes for delta x3=0
                    xs:=PPoints3^[points3].x;
                    ys:=b1+m1*PPoints3^[points3].x;
                  end
                end
                else
                begin
                  if PPoints3^[points3+1].x<>PPoints3^[points3].x then
                  begin
                    m2:=(PPoints3^[points3+1].y-PPoints3^[points3].y)/(PPoints3^[points3+1].x-PPoints3^[points3].x);
                    b2:=PPoints3^[points3].y-PPoints3^[points3].x*m2;
                    xs:=PPoints2^[points].x;
                    ys:=b2+m2*PPoints2^[points].x;
                  end
                  else
                  begin
                    xs:=0;
                    ys:=0;
                  end;
                end;
              end;  //case
              case i of
                1: if (Abs(trunc(xs-PPoints1^[points].x)) <= Abs(PPoints1^[points+1].x-PPoints1^[points].x))
                  and (Abs(trunc(xs-PPoints1^[points+1].x)) <= Abs(PPoints1^[points+1].x-PPoints1^[points].x))
                  and (Abs(trunc(ys-PPoints1^[points].y)) <= Abs(PPoints1^[points+1].y-PPoints1^[points].y))
                  and (Abs(trunc(ys-PPoints1^[points+1].y)) <= Abs(PPoints1^[points+1].y-PPoints1^[points].y))
                  and (Abs(trunc(xs-PPoints3^[points3].x)) <= Abs(PPoints3^[points3+1].x-PPoints3^[points3].x))
                  and (Abs(trunc(xs-PPoints3^[points3+1].x)) <= Abs(PPoints3^[points3+1].x-PPoints3^[points3].x))
                  and (Abs(trunc(ys-PPoints3^[points3].y)) <= Abs(PPoints3^[points3+1].y-PPoints3^[points3].y))
                  and (Abs(trunc(ys-PPoints3^[points3+1].y)) <= Abs(PPoints3^[points3+1].y-PPoints3^[points3].y)) then
                begin
                  if points=0 then
                  begin
                    if intsectpt310.x=0 then
                    begin
                      {$IFDEF Debugging}
                        Ellipse(FCanvas.Handle, round(xs)-5, round(ys)-5, round(xs)+5, round(ys)+5);
                        TextDummy:=inttostr(i)+','+IntToStr(points)+','+IntToStr(points3);
                        fcanvas.brush.style:=bsclear;
                        Textout(FCanvas.Handle, round(xs), round(ys), pchar(TextDummy),Length(TextDummy));
                      {$ENDIF}
                      intsectPt310.x:=round(xs);
                      intsectPt310.y:=round(ys);
                      intsect310:=points3;
                      Inc(intsectcount);
                    end;
                  end
                  else
                  begin
                    if intsectpt311.x=0 then
                    begin
                      {$IFDEF Debugging}
                        Ellipse(FCanvas.Handle, round(xs)-5, round(ys)-5, round(xs)+5, round(ys)+5);
                        TextDummy:=inttostr(i)+','+IntToStr(points)+','+IntToStr(points3);
                        fcanvas.brush.style:=bsclear;
                        Textout(FCanvas.Handle, round(xs), round(ys), pchar(TextDummy),Length(TextDummy));
                      {$ENDIF}
                      intsectPt311.x:=round(xs);
                      intsectPt311.y:=round(ys);
                      intsect311:=points3;
                      Inc(intsectcount);
                    end;
                  end;
                end;  //case i=1
                2: if (Abs(trunc(xs-PPoints2^[points].x)) <= Abs(PPoints2^[points+1].x-PPoints2^[points].x))
                  and (Abs(trunc(xs-PPoints2^[points+1].x)) <= Abs(PPoints2^[points+1].x-PPoints2^[points].x))
                  and (Abs(trunc(ys-PPoints2^[points].y)) <= Abs(PPoints2^[points+1].y-PPoints2^[points].y))
                  and (Abs(trunc(ys-PPoints2^[points+1].y)) <= Abs(PPoints2^[points+1].y-PPoints2^[points].y))
                  and (Abs(trunc(xs-PPoints3^[points3].x)) <= Abs(PPoints3^[points3+1].x-PPoints3^[points3].x))
                  and (Abs(trunc(xs-PPoints3^[points3+1].x)) <= Abs(PPoints3^[points3+1].x-PPoints3^[points3].x))
                  and (Abs(trunc(ys-PPoints3^[points3].y)) <= Abs(PPoints3^[points3+1].y-PPoints3^[points3].y))
                  and (Abs(trunc(ys-PPoints3^[points3+1].y)) <= Abs(PPoints3^[points3+1].y-PPoints3^[points3].y)) then
                begin
                  if points=APolySegments-1 then
                  begin
                    if intsectpt321.x=0 then
                    begin
                      {$IFDEF Debugging}
                        Ellipse(FCanvas.Handle, round(xs)-5, round(ys)-5, round(xs)+5, round(ys)+5);
                        TextDummy:=inttostr(i)+','+IntToStr(points)+','+IntToStr(points3);
                        fcanvas.brush.style:=bsclear;
                        Textout(FCanvas.Handle, round(xs), round(ys),pchar(TextDummy),Length(TextDummy));
                      {$ENDIF}
                      intsectpt321.x:=round(xs);
                      intsectpt321.y:=round(ys);
                      intsect321:=points3;
                      Inc(intsectcount);
                    end;
                  end
                  else
                  begin
                    if intsectpt320.x=0 then
                    begin
                      {$IFDEF Debugging}
                        Ellipse(FCanvas.Handle, round(xs)-5, round(ys)-5, round(xs)+5, round(ys)+5);
                        TextDummy:=inttostr(i)+','+IntToStr(points)+','+IntToStr(points3);
                        fcanvas.brush.style:=bsclear;
                        Textout(FCanvas.Handle, round(xs), round(ys),pchar(TextDummy),Length(TextDummy));
                      {$ENDIF}
                      intsectpt320.x:=round(xs);
                      intsectpt320.y:=round(ys);
                      intsect320:=points3;
                      Inc(intsectcount);
                    end;
                  end;
                end;  //case i=2
              end; //case
            end;  //for points3:=0 to ...
          end; // if points=0 ...
        end; // for points:=0 to ...
        if intsectcount<> 5 then
        begin
          FreeMem(PPoints1,SizeOf(PPoints1^[0])*(APolySegments+1));
          FreeMem(PPoints2,SizeOf(PPoints2^[0])*(APolySegments+1));
          FreeMem(PPoints3,SizeOf(PPoints3^[0])*(4*APolySegments+1));
          Exit;
        end;
        //*************assemble all 4 polygons***********************************
        GetMem(PPGpoints1,SizeOf(PPGpoints1^[0])*(4*APolySegments+1));
        GetMem(PPGpoints2,SizeOf(PPGpoints2^[0])*(100*APolySegments+1));
        GetMem(PPGpoints3,SizeOf(PPGpoints3^[0])*(4*APolySegments+1));
        GetMem(PPGpoints4,SizeOf(PPGpoints4^[0])*(4*APolySegments+1));
        PGpoints1:=0;
        PGpoints2:=0;
        PGpoints3:=0;
        PGpoints4:=0;
        AssemblePolygon(ppoints1, ppoints2, ppoints3, intsectpt12, intsectpt310, intsectpt311,
          intsectpt320, intsectpt321,APolySegments,intsect12, intsect21,
          intsect310, intsect311, intsect320, intsect321, True,ppgpoints1,pgpoints1, special);
        if not special then
          AssemblePolygon(ppoints2, ppoints1, ppoints3, intsectpt12, intsectpt320, intsectpt321,
            intsectpt310, intsectpt311,APolySegments,intsect21, intsect12,
            intsect320, intsect321, intsect310, intsect311, True,ppgpoints2,pgpoints2, special);
        AssemblePolygon(ppoints1, ppoints2, ppoints3, intsectpt12, intsectpt310, intsectpt311,
          intsectpt320, intsectpt321,APolySegments,intsect12, intsect21,
          intsect310, intsect311, intsect320, intsect321, False,ppgpoints3,pgpoints3, special);
        AssemblePolygon(ppoints2, ppoints1, ppoints3, intsectpt12, intsectpt320, intsectpt321,
          intsectpt310, intsectpt311,APolySegments,intsect21, intsect12,
          intsect320, intsect321, intsect310, intsect311, False,ppgpoints4,pgpoints4, special);
        //***Calculate square distance from sigma1 and sigma3 for all points of 4 polygons*****
        for i:=1 to 3 do
        begin
          errorbuffer[i]:=10000000;
          index[i]:=0;
        end;
        z1:=0;
        z2:=0;
        z3:=0;
        z4:=0;
        for j:=1 to 4 do
        begin
          for i:=1 to 3 do
            case i of
              1,3:begin
                ferror[j,i]:=0;
                if Abs(FTensPlunge[i]) >= 89 then FTensPlunge[i]:=89.99*Sgn(FTensPlunge[i]);
                h := Radius*SQRT2*Sin(DegToRad(90-FTensPlunge[i])/2);
                xxx:=Centerx+h*Sin(DegToRad(FTensAzimuth[i]));
                yyy:=CenterY-h*Cos(DegToRad(FTensAzimuth[i]));
                case j of
                  1: begin
                    for points:=0 to pgpoints1 do
                    begin
                      ferror[j,i]:=ferror[j,i]+Sqr(PPGPoints1^[points].x-xxx)+sqr(PPGPoints1^[points].y-yyy);
                      Inc(z1);
                    end;
                    ferror[j,i]:=ferror[j,i]/z1;
                  end;
                  2: if special then ferror[j,i]:=99999999
                    else
                    begin
                      for points:=0 to pgpoints2 do
                      begin
                        ferror[j,i]:=ferror[j,i]+Sqr(PPGPoints2^[points].x-xxx)+sqr(PPGPoints2^[points].y-yyy);
                        Inc(z2);
                      end;
                      ferror[j,i]:=ferror[j,i]/z2;
                    end;
                  3: begin
                    for points:=0 to pgpoints3 do
                    begin
                      ferror[j,i]:=ferror[j,i]+Sqr(PPGPoints3^[points].x-xxx)+sqr(PPGPoints3^[points].y-yyy);
                      Inc(z3);
                    end;
                    ferror[j,i]:=ferror[j,i]/z3;
                  end;
                  4: begin
                    for points:=0 to pgpoints4 do
                    begin
                      ferror[j,i]:=ferror[j,i]+Sqr(PPGPoints4^[points].x-xxx)+sqr(PPGPoints4^[points].y-yyy);
                      Inc(z4);
                    end;
                    ferror[j,i]:=ferror[j,i]/z4;
                  end;
                end; //case
                if ferror[j,i]<errorbuffer[i] then
                begin
                  errorbuffer[i]:=ferror[j,i];
                  index[i]:=j;
                end;
                {$IFDEF Debugging}
                  textdummy:=inttostr(j)+','+IntToStr(i)+': '+IntToStr(round(ferror[j,i]));
                  fcanvas.brush.style:=bsclear;
                  Textout(FCanvas.handle, Labelleft, labeltop+40+(i-1)*9+(j-1)*40, pchar(textdummy),
                            length(textdummy));
                {$ENDIF}
              end;  //case i=1,3
            end; //case
        end; //for j:=1 to4
        {$IFDEF Debugging}
          fcanvas.brush.style:=bsclear;
          for i:=1 to 3 do
            case i of
              1,3:
              begin
                textdummy:='Sigma'+inttostr(i)+': Sector '+inttostr(index[i])+'; '+IntToStr(round(errorbuffer[i]));
                Textout(FCanvas.handle, Labelleft, labeltop+500+i*6, pchar(textdummy),
                          length(textdummy));
              end;
            end;
        {$ENDIF}
        if FSymbfillflag then
        begin
          case FFillBrush.Color of
            clWhite: SelectObject(FCanvas.Handle,GetStockObject(WHITE_BRUSH));
            clBlack: SelectObject(FCanvas.Handle,GetStockObject(BLACK_BRUSH));
          else FCanvas.Brush:=FFillBrush;
          end;
          PenStore:=SelectObject(FCanvas.Handle, GetStockObject(NULL_PEN));
          if special then
            case index[1] of
              1: begin
                Polygon(FCanvas.Handle, PPGPoints1^[0], PGPoints1+1);
              end;
              3,4: begin
                Polygon(FCanvas.Handle, PPGPoints3^[0], PGPoints3+1);
                Polygon(FCanvas.Handle, PPGPoints4^[0], PGPoints4+1);
              end;
            end //case
          else
            case index[1] of
              1,3: begin
                Polygon(FCanvas.Handle, PPGPoints1^[0], PGPoints1+1);
                Polygon(FCanvas.Handle, PPGPoints3^[0], PGPoints3+1);
              end;
              2,4: begin
                Polygon(FCanvas.Handle, PPGPoints2^[0], PGPoints2+1);
                Polygon(FCanvas.Handle, PPGPoints4^[0], PGPoints4+1);
              end;
            end; //case
        end; //if fsymbfillflag
        if fsymbfillflag2 then
        begin
          case FFillBrush2.Color of
            clWhite: SelectObject(FCanvas.Handle,GetStockObject(WHITE_BRUSH));
            clBlack: SelectObject(FCanvas.Handle,GetStockObject(BLACK_BRUSH));
          else FCanvas.Brush:=FFillBrush2;
          end;
          if not Fsymbfillflag then PenStore:=SelectObject(FCanvas.Handle, GetStockObject(NULL_PEN));
          if special then
            case index[3] of
              1: Polygon(FCanvas.Handle, PPGPoints1^[0], PGPoints1+1);
              3,4: begin
                Polygon(FCanvas.Handle, PPGPoints3^[0], PGPoints3+1);
                Polygon(FCanvas.Handle, PPGPoints4^[0], PGPoints4+1);
              end;
            end
          else
            case index[1] of
              1,3: begin
                Polygon(FCanvas.Handle, PPGPoints2^[0], PGPoints2+1);
                Polygon(FCanvas.Handle, PPGPoints4^[0], PGPoints4+1);
              end;
              2,4: begin
                Polygon(FCanvas.Handle, PPGPoints1^[0], PGPoints1+1);
                Polygon(FCanvas.Handle, PPGPoints3^[0], PGPoints3+1);
              end;
            end;
        end; // if fsymbfillflag2
        if Fsymbfillflag or Fsymbfillflag2 then
        begin
          SelectObject(FCanvas.Handle, PenStore);
          SelectObject(FCanvas.Handle, GetStockObject(HOLLOW_BRUSH));
        end;
        FCanvas.Pen:=FPen;
        {$IFDEF Debugging}
          FCanvas.Pen.Color:=clgreen;
          Polygon(FCanvas.Handle, PPGPoints1^[0], PGPoints1+1);
          if not special then
          begin
            FCanvas.Pen.Color:=clred;
            Polygon(FCanvas.Handle, PPGPoints2^[0], PGPoints2+1);
          end;
          FCanvas.Pen.Color:=clblue;
          Polygon(FCanvas.Handle, PPGPoints3^[0], PGPoints3+1);
          FCanvas.Pen.Color:=clpurple;
          Polygon(FCanvas.Handle, PPGPoints4^[0], PGPoints4+1);
        {$ENDIF}
        PolyLine(FCanvas.Handle,PPoints1^[0],APolySegments+1);
        PolyLine(FCanvas.Handle,PPoints2^[0],APolySegments+1);
        {$IFDEF Debugging}
          PolyLine(FCanvas.Handle,PPoints3^[0],4*APolySegments+1);
          fcanvas.brush.style:=bsclear;
          For i:= 0 to 4*APolySegments+1 do
            FCanvas.Textout(PPoints3^[i].x, PPoints3^[i].y, IntToStr(i));
        {$ENDIF}
        FreeMem(PPoints1,SizeOf(PPoints1^[0])*(APolySegments+1));
        FreeMem(PPoints2,SizeOf(PPoints2^[0])*(APolySegments+1));
        FreeMem(PPoints3,SizeOf(PPoints3^[0])*(4*APolySegments+1));
        FreeMem(PPGPoints1,SizeOf(PPGPoints1^[0])*(4*APolySegments+1));
        FreeMem(PPGPoints2,SizeOf(PPGPoints2^[0])*(100*APolySegments+1));
        FreeMem(PPGPoints3,SizeOf(PPGPoints3^[0])*(4*APolySegments+1));
        FreeMem(PPGPoints4,SizeOf(PPGPoints4^[0])*(4*APolySegments+1));
      //finally
      //end;
      Result:=True;
end;

Function DrawTensor(var FCanvas: TCanvas; FCanvas2: TCanvas; FTensAzimuth, FTensPlunge : T1Sing1by3;
  FSymbSize: Single; FSymbFillFlag, FSymbFillFlag2: Boolean; FFillBrush, FFillBrush2: TBrush; FPenHandle: THandle): Boolean;
var dummy: Integer;
begin
  For dummy:= 1 to 3 do
    case dummy of
      1: {Draw circle for Sigma1 }
         Lineation(FCanvas.Handle,FCanvas2,CenterX,CenterY,Radius,FTensAzimuth[dummy],FTensPlunge[dummy],FSymbSize,
                      1,False,FSymbFillFlag,syCircle,FFillBrush, FPenHandle);
      2: {Draw rectangle for Sigma2 }
         Lineation(FCanvas.Handle,FCanvas2,CenterX,CenterY,Radius,FTensAzimuth[dummy],FTensPlunge[dummy],FSymbSize,
                         1,False,False,syRectangle,FFillBrush, FPenHandle);
      3: {Draw triangle for Sigma3 }
         Lineation(FCanvas.Handle,FCanvas2,CenterX,CenterY,Radius,FTensAzimuth[dummy],FTensPlunge[dummy],FSymbSize,
                         1,False, FSymbFillFlag2, syTriangle, FFillBrush2, FPenHandle);
    end;
        {$IFDEF Debugging}
         {Rot(False, 45,FTensAzimuth[2],FTensPlunge[2],FTensAzimuth[1],FTensPlunge[1], FAzimuth[1], Plunge[1], SenseChanged);
          FlaechLin(TensAzimuth[2],TensPlunge[2],Azimuth[1],Plunge[1], True, Azimuth[1],Plunge[1]);
          GreatCircle2(MetCanHandle,Canvas,CenterX,CenterY,Radius,Azimuth[1], Plunge[1],Z,
                        False,lhPen.Handle, lhLogPen);
          Rot(False, -45,TensAzimuth[2],TensPlunge[2],TensAzimuth[1],TensPlunge[1], Azimuth[2], Plunge[2], SenseChanged);
          FlaechLin(TensAzimuth[2],TensPlunge[2],Azimuth[2],Plunge[2], True, Azimuth[2],Plunge[2]);
          GreatCircle2(MetCanHandle,Canvas,CenterX,CenterY,Radius,Azimuth[2], Plunge[2],Z,
                        False,lhPen.Handle, lhLogPen);}
       {$ENDIF}
end;

procedure TSigmaForm.DrawFluHist(Sender: TObject);
var storemax, ScaleValue, NumberOfTicks, x, dummy, lwDummy: Integer;
    BrushStore: TColor;
    Points : Array[0..3] of TPoint;
    MaximumStr : String[5];
begin
  StoreMax := Round(Max);
  MaxPerc := Max/(nDatasets-NoSense)*100;
  If (Max3<MaxPerc) or NoofBoxeschanged then Max2:=MaxPerc else Max2:=Max3;
  NoofBoxeschanged:=False;
      if Max2 > 20 then ScaleValue:=5 else ScaleValue:=2;
      NumberOfTicks:=(round(Max2) div Scalevalue);
      If (round(Max2) mod ScaleValue)<>0 then Inc(NumberOfTicks);
      Max2:=NumberOfTicks*Scalevalue;
      If lhSymbFillFlag then
      begin
        If lhFillBrush.Color<>clWhite then
        begin
          BrushStore := lhMetCan.Brush.Color;
          lhMetCan.Brush.Color := lhFillBrush.Color;
        end
        else SelectObject(lhMetCan.Handle,GetStockObject(WHITE_BRUSH));
      end;
      lhMetCan.Pen:=lhPen;
      FOR x := 0 TO NoofBoxes-1 do //Berechnung der Prozentanzahl bezogen auf den Radius
      begin
        if SFCounts^[x] <> 0 then With lhMetCan do
        begin
          dummy:= Round(Round(SFCounts^[x]*100/(nDatasets-NoSense))*2*Radius/Max2);
          Points[0].x := CenterX-Radius+round(x*20/NoOfBoxes*Radius/12);
          Points[0].y := CenterY+Radius;
          Points[1].x := CenterX-Radius+round(x*20/NoOfBoxes*Radius/12);
          Points[1].y := CenterY+Radius-dummy;
          Points[2].x := CenterX-Radius+round((x+1)*20/NoOfBoxes*Radius/12);
          Points[2].y := CenterY+Radius-dummy;
          Points[3].x := CenterX-Radius+round((x+1)*20/NoOfBoxes*Radius/12);
          Points[3].y := CenterY+Radius;
          Polygon(Points);
        end;
      end;
      With lhMetCan do
      begin
        If lhSymbFillFlag then
        begin
          Brush.Color := BrushStore;
          Brush.Style := bsClear;
        end;
        With Pen do
        begin
          Style:=psSolid;
          Width:=AxesPenWidth;
          Color:=lhNetColor;
        end;
        MoveTo(CenterX-Radius,CenterY-Radius);
        LineTo(CenterX-Radius,CenterY+Radius);
        LineTo(CenterX+Radius,CenterY+Radius);
        //ticks on y-axis
        for x:=1 to NumberOfTicks do
        begin
          Moveto(Centerx-Radius-6,CenterY+Radius-Round(2*x*Radius/NumberOfTicks));
          Lineto(Centerx-Radius,CenterY+Radius-Round(2*x*Radius/NumberOfTicks));
          If not odd(x) then
          begin
            if lhMetCan.Font.Size<17 then
              textout(Centerx-Radius-canvas.textwidth('100')-6,CenterY+Radius-Round(2*x*Radius/NumberOfTicks)-Canvas.TextHeight('text') div 2,IntToStr(x*ScaleValue))
            else
              textout(Centerx-Radius-canvas.textwidth('10'),CenterY+Radius-Round(2*x*Radius/NumberOfTicks)-Canvas.TextHeight('text') div 2,IntToStr(x*ScaleValue));
          end;
          if x=numberofticks then
            if lhMetCan.Font.Size<17 then
              textout(Centerx-Radius-canvas.textwidth('100')-6,CenterY+Radius-Round(2*x*Radius/NumberOfTicks)+2*Canvas.TextHeight('text') div 2,'%')
            else
              textout(Centerx-Radius-canvas.textwidth('10'),CenterY + Radius - (2*Canvas.Font.Size) div 3,'%');
        end;
        If lhMetCan.Font.Size<17 then
        begin
          for x := 0 to 9 do
          begin
            {ticks on x-axis}
            MoveTo(CenterX-Radius+round(x*2*Radius/12),CenterY+Radius);
            LineTo(CenterX-Radius+round(x*2*Radius/12),CenterY+Radius+5);
            if not odd(x) then TextOut(CenterX-Radius-5+round(x*2*Radius/12),
                                     CenterY+Radius+15,'0.'+IntToStr(x));
          end;
          x :=0;
          while x <= 60 do
          begin
            MoveTo(CenterX-Radius+round((10*Sin(DegToRad(x)))*2*Radius/12),CenterY+Radius+33);
            LineTo(CenterX-Radius+round((10*Sin(DegToRad(x)))*2*Radius/12),CenterY+Radius+39);
            TextOut(CenterX-Radius-5+round((10*Sin(DegToRad(x)))*2*Radius/12),CenterY+Radius+40,IntToStr(x)+'°');
            Inc(x,15);
          end;
          {last tick on x-axis}
          MoveTo(CenterX-Radius+round(20*Radius/12),CenterY+Radius);
          LineTo(CenterX-Radius+round(20*Radius/12),CenterY+Radius+5);
          TextOut(CenterX-Radius-5+round(20*Radius/12),CenterY+Radius+15,'1.0');
          MoveTo(CenterX-Radius+round(20*Radius/12),CenterY+Radius+33);
          LineTo(CenterX-Radius+round(20*Radius/12),CenterY+Radius+39);
          TextOut(CenterX-Radius-5+round(20*Radius/12),CenterY+Radius+40,'90°');
          TextOut(CenterX+Radius-20,CenterY+Radius+15,'Sin(Error)');
          TextOut(CenterX+Radius-20,CenterY+Radius+40,'Error [°]');
        end
        else
        begin //bigger text size
          x :=0;
          while x <= 60 do
          begin
            MoveTo(CenterX-Radius+round((10*Sin(DegToRad(x)))*2*Radius/12),CenterY+Radius);
            lwDummy:=lhMetCan.Pen.Width;
            lhMetCan.Pen.Width:=lhMetCan.Font.Size div 10;
            LineTo(CenterX-Radius+round((10*Sin(DegToRad(x)))*2*Radius/12),CenterY+Radius+lhMetCan.Font.Size div 5);
            lhMetCan.Pen.Width:= lwDummy;
            If x<>45 then TextOut(CenterX-Radius-lhMetCan.Font.Size div 3 * Length(IntToStr(x)) + round((10*Sin(DegToRad(x)))*2*Radius/12),CenterY+Radius,IntToStr(x));
            Inc(x,15);
          end;
          TextOut(CenterX+Radius div 2 + lhMetCan.Font.Size,CenterY+Radius,'Err°');
        end;
      end;
      //Dec(lhz);
      IF Label1.Checked THEN with lhMetCan do
      begin
        Str(MaxPerc:2:0, MaximumStr);
        TextOut(CenterX+Radius-70,CenterY-Radius,'Maximum: '+MaximumStr+'%');
        TextOut(CenterX+Radius-70,CenterY-Radius-40,'Datasets: '+IntToStr(nDatasets));
        if NoSense <>0 then
          TextOut(CenterX+Radius-70,CenterY-Radius-20,'Skipped: '+IntToStr(NoSense));
      end;
    end;

procedure TSigmaForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  If lhExtension<>DIH then FreeMem(SFFluMohrFPLData,SizeOf(SFFluMohrFPLData^[0])*(nDatasets));
  inherited;
end;


procedure TSigmaForm.DrawMohr(Sender: TObject);
var Sigma1X, Sigma1Y, Sigma1Z, Sigma3X,Sigma3y,Sigma3z, pkx, pky, pkz, baw, Winkel1,
    Winkel3, w1c, w1s, w3c, w3s, r1, r3, s, a, y1, x1: Single;
    penwidthdummy, I, m12, xpt, ypt: integer;
    centeryy: LongInt;
    penstyledummy: TPenStyle;
    points : POpenPointArray;
    rstr: String;
begin
    lhMetCanHandle:=lhMetCan.Handle;
    CenterYY := 400;
    //***************Calculate vectors of sigma1 and sigma 3**********************
    Sigma1X := Cos(DegToRad(TensAzimuth[1]))*Cos(DegToRad(TensPlunge[1]));
    Sigma1Y := Sin(DegToRad(TensAzimuth[1]))*Cos(DegToRad(TensPlunge[1]));
    Sigma1Z := Sin(DegToRad(TensPlunge[1]));
    Sigma3X := Cos(DegToRad(TensAzimuth[3]))*Cos(DegToRad(TensPlunge[3]));
    Sigma3Y := Sin(DegToRad(TensAzimuth[3]))*Cos(DegToRad(TensPlunge[3]));
    Sigma3Z := Sin(DegToRad(TensPlunge[3]));
    NoSense:=0;
    lhz := 0;

    PenStyleDummy:=lhPen.Style;
    lhPen.Style:=psSolid;
    lhPen.Width:=AxesPenWidth;

    SelectObject(lhMetCanHandle, lhPen.Handle);
    MoveToEx(lhMetCanHandle,CenterX-Radius, CenterYY, nil);
    LineTo(lhMetCanHandle,CenterX+(6*Radius) div 10, CenterYY);
    lhMetCan.Font.Name:='Symbol';
    lhMetCanHandle:=lhMetCan.Handle;
    If lhMetCan.Font.Size<17 then
    begin
      TextOut(lhMetCanHandle,CenterX+(6*Radius) div 10, CenterYY, 's', 1);
      MoveToEx(lhMetCanHandle,CenterX-Radius, CenterYY, nil);
      LineTo(lhMetCanHandle,CenterX-Radius, CenterYY - Radius);
      TextOut(lhMetCanHandle,CenterX-Radius-10,CenterYY-Radius, 't',1);
    end
    else
    begin
      TextOut(lhMetCanHandle,CenterX+(6*Radius) div 10, CenterYY-lhMetcan.Font.Size, 's', 1);
      MoveToEx(lhMetCanHandle,CenterX-Radius, CenterYY, nil);
      LineTo(lhMetCanHandle,CenterX-Radius, CenterYY - Radius);
      TextOut(lhMetCanHandle,CenterX-Radius,CenterYY-Radius, 't',1);
    end;
    lhMetCan.Font:=TecMainWin.FontDialog1.font;
    //Arc1
    PenWidthDummy:=lhPen.Width;
    If lhMetcan.Font.Size>16 then lhPen.Width:=2;
    lhPen.Style:=PenStyleDummy;
    SelectObject(lhMetCanHandle, lhPen.Handle);
    GetMem(Points,SizeOf(Points^[0])*(PolySegments+1));
    try
      For I:= 0 to PolySegments do
      begin
        Points^[I].x:=Round(CenterX-radius+11*radius/14-10/14*radius*Cos(DegToRad(180*I/PolySegments)));
        Points^[I].y:=Round(CenterYY-10/14*radius*Sin(DegToRad(180*I/PolySegments)));
      end;
      PolyLine(lhMetCanHandle,Points^[0],PolySegments+1);
      //Arc2
      For I:= 0 to PolySegments do
      begin
        Points^[I].x:=Round(CenterX-Radius+(10+StressRatio*100)*Radius/140-(StressRatio*100*Radius/140)*Cos(DegToRad(180*I/PolySegments)));
        Points^[I].y:=Round(CenterYY-(StressRatio*100*Radius/140)*Sin(DegToRad(180*I/PolySegments)));
      end;
      PolyLine(lhMetCanHandle,Points^[0],PolySegments+1);
      //Arc3
      For I:= 0 to PolySegments do
      begin
        Points^[I].x:=Round(CenterX-Radius+(110+StressRatio*100)*Radius/140-((200-StressRatio*200)/2*Radius/140*Cos(DegToRad(180*I/PolySegments))));
        Points^[I].y:=Round(CenterYY-(200-StressRatio*200)/2*Radius/140*Sin(DegToRad(180*I/PolySegments)));
      end;
      PolyLine(lhMetCanHandle,Points^[0],PolySegments+1);
    finally
      FreeMem(Points,SizeOf(Points^[0])*(PolySegments+1));
    end;
    lhPen.Width:= PenWidthDummy;
    PenStyleDummy:=lhPen.Style;
    lhPen.Style:=psSolid;
    SelectObject(lhMetCanHandle, lhPen.Handle);
    IF lhSymbFillFlag then SelectObject(lhMetCanHandle, lhFillBrush.Handle);
    lhz:=0;
    while lhz<nDatasets do
    begin
     If (SFFluMohrFPLData^[lhz].fmSense<>0) and (SFFluMohrFPLData^[lhz].fmSense<>5) or (Self is TInversPlot) or (lhextension=inv) then with SFFluMohrFPLData^[lhz] do
     begin
       if (fmDipDir=0) or (fmDipDir=90) or (fmDipDir=180)  or (fmDipDir=270) then fmDipDir:=fmDipDir+0.01;
       IF fmDip= 90 THEN fmDip:= 89.99;
       pkx := Cos(DegToRad(trunc(fmDipDir+180) MOD 360+Frac(fmDipDir+180)))*Cos(DegToRad(90-fmDip)); {Berechnung des Richtungsvektors zur Fläche}
       pky := Sin(DegToRad(trunc(fmDipDir+180) MOD 360+Frac(fmDipDir+180)))*Cos(DegToRad(90-fmDip));
       pkz := Sin(DegToRad(90-fmDip));
       //Calculate angle between direction vector and Sigma1 resp. Sigma3
       //Sigma3 is inverse. beide Daten sind nocheinmal invers (Winkel zur Fläche)
       BAW := (Sigma1X*pkx+Sigma1Y*pky+Sigma1Z*pkz)/(Sqrt(Sqr(Sigma1X)+Sqr(Sigma1Y)+sqr(Sigma1Z))*Sqrt(Sqr(pkx)+Sqr(pky)+Sqr(pkz)));
       Winkel1 := RadToDeg(-ArcTan(BAW/Sqrt(-BAW*BAW+1))+1.5708);
       IF Winkel1>90 THEN Winkel1 := 180-Winkel1;
       BAW := (Sigma3X*pkx+Sigma3Y*pky+Sigma3Z*pkz)/(Sqrt(Sqr(Sigma3X)+Sqr(Sigma3Y)+Sqr(Sigma3Z))*Sqrt(Sqr(pkx)+Sqr(pky)+Sqr(pkz)));
       Winkel3 := RadToDeg(-ArcTan(BAW/Sqrt(-BAW*BAW+1))+1.5708);
       IF Winkel3>90 THEN Winkel3 := 180-Winkel3;
       Winkel1 := 90 - Winkel1;
       w1c := 100*Cos(DegToRad(2*Winkel1));
       w1s := 100*Sin(DegToRad(2*Winkel1));
       w3c := 100*Cos(DegToRad(2*Winkel3));
       w3s := 100*Sin(DegToRad(2*Winkel3));
       //m12 := R * 100 + (200-R*200)/2;
       m12 :=100;
       R1 := Sqrt(Sqr(m12-m12*stressratio-w1c)+Sqr(w1s));
       R3 := Sqrt(Sqr(m12*stressratio+w3c)+Sqr(w3s));
       //Calculate Y coordinate of intersecting point
       s := (R1 + R3 + m12)/2;
       A := Sqrt(s*(s-R1)*(s-R3)*(s-m12));
       y1 := 2*A/m12;
       //Calculate X coordinate of intersecting point
       //CA := Sqr(R1)-Sqr(y1);
       X1 := Sqrt(Abs(Sqr(R1)-Sqr(y1))); //:PRINT r3^2,Y1^2,m12        Hugos testing
       //if lhSymbFillFlag then lhMetCan.Brush := lhFillBrush;
       If lhMetCan.Font.Size>16 then
       begin
         penwidthdummy:=lhMetCan.Pen.Width;
         lhMetCan.Pen.Width:=2;
         lhMetCanHandle:=lhMetCan.Handle;
       end;
       IF Sqrt(Abs(Sqr(R3)-Sqr(y1)))>= m12 THEN
       begin
         Ellipse(lhMetCanHandle,CenterX-Radius+round((m12*stressratio+10-X1)*Radius/140-lhSymbSize),
                             CenterYY-round(y1*Radius/140-lhSymbSize),
                             CenterX-Radius+round((m12*stressratio+10-X1)*Radius/140+lhSymbSize),
                             CenterYY-round(y1*Radius/140+lhSymbSize));
         XPT := CenterX-Radius+round((stressratio*100+10-X1)*Radius/140);
         YPT := CenterYY-round(y1*Radius/140);
       end
       else
       begin
         Ellipse(lhMetCanHandle,CenterX-Radius+round((stressratio*m12+10+X1)*Radius/140-lhSymbSize),
                           CenterYY-round(y1*Radius/140-lhSymbSize),
                           CenterX-Radius+round((stressratio*m12+10+X1)*Radius/140+lhSymbSize),
                           CenterYY-round(y1*Radius/140+lhSymbSize));
         XPT := CenterX-Radius+round((stressratio*m12+10+X1)*Radius/140);
         YPT := CenterYY-Round(y1*Radius/140);
       end;
       If lhMetCan.Font.Size>16 then
       begin
         lhMetCan.Pen.Width:=penwidthdummy;
         lhMetCanHandle:=lhMetCan.Handle;
       end;
       IF Number1.Checked THEN
       begin
         SelectObject(lhMetCanHandle, GetStockObject(HOLLOW_BRUSH));
         Textout(lhMetCanHandle,XPT+5, YPT-8, PChar(IntToStr(lhz+1)), Length(IntToStr(lhz+1)));
         IF lhSymbFillFlag then SelectObject(lhMetCanHandle, lhFillBrush.Handle);
       end;
      end else Inc(NoSense);
      Inc(lhz);
    end;  //end of while-loop
    lhPen.Style:=PenStyleDummy;
    CenterYY := CenterYY-20;{????????????????????????????????????}
    Dec(lhz,1);  //bugfix 981126
    IF Label1.Checked THEN
    begin
      SelectObject(lhMetCanHandle, GetStockObject(HOLLOW_BRUSH));
      Str(stressratio:2:4, rstr);
      TextOut(lhMetCanHandle,CenterX-Radius, CenterYY - Radius, PChar(lhLabel1),Length(lhLabel1));
      TextOut(lhMetCanHandle,CenterX + Radius - 70,CenterYY - Radius,PChar('Datasets: '+IntToStr(nDatasets)),Length('Datasets: '+IntToStr(nDatasets)));
      i:=20;
      If NoSense<>0 then
      begin
        TextOut(lhMetCanHandle,CenterX + Radius - 70,CenterYY - Radius+i,PChar('Skipped: '+IntToStr(NoSense)), Length('Skipped: '+IntToStr(NoSense)));
        Inc(i,20);
      end;
      TextOut(lhMetCanHandle,CenterX + Radius - 70,CenterYY - Radius+i, PChar('R = '+RSTR), Length('R = '+RSTR));
    end;
end;

end.
