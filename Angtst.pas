unit Angtst;

interface

uses Types, Windows, Graphics, SysUtils, LowHem;

type
  TAngtstWin = class(TLHWin)
    procedure FormCreate(Sender: TObject; const AFilename: string;  const AExtension: TExtension); override;
    procedure Compute(Sender: TObject); override;
    procedure Angelier1Click(Sender: TObject); override;
    procedure Paste1click(Sender: TObject); override;
  protected
    procedure QualityLevels1Click(Sender: TObject);
  end;

var AngtstWin: TAngtstWin;
                                                                   
implementation

uses Draw,Fileops,tecmain;

procedure TAngtstWin.FormCreate(Sender: TObject; const AFilename: string;  const AExtension: TExtension);
begin
  LHTectonicData:=td_Fault;
  Plottype1.Enabled:=true;
  Plottype2.Enabled:=Plottype1.Enabled;
  ptaxes1.Enabled:=False;
  ptaxes1.Visible:=False;
  ptaxes2.Enabled:=ptaxes1.Enabled;
  ptaxes2.Visible:=ptaxes1.Visible;
  Qualitylevels1.visible:=true;
  Qualitylevels1.enabled:=true;
  Qualitylevels1.OnClick:=QualityLevels1Click;
  Qualitylevels1.checked:=QualityGlobal;
  If Sender = TecMainWin.Hoeppener1 then
  begin
    LHPlotType:=pt_Hoeppener;
    Hoeppener1.Checked:=True;
    Hoeppener2.Checked:=True;
  end
  else
  begin
    LHPlotType:=pt_Angelier;
    If (Pos('_s0', LowerCase(ExtractFilename(AFilename)))<>0) or (Pos('-s0', LowerCase(ExtractFilename(AFilename)))<>0) then
      LHTectonicData:=td_FaultOnBeddingPlane;
    if RecognizeTectonicData then
      case LHTectonicData of
        td_Fault: AngPenStyle:=psSolid;
        td_FaultOnBeddingPlane: AngPenStyle:=psDot;
      end;
  end;
  inherited;
end;

procedure TAngtstWin.QualityLevels1Click(Sender: TObject);
begin
  Screen.Cursor:=crHourGlass;
  Qualitylevels1.checked:= not Qualitylevels1.checked;
  Compute(Sender);
  Paintbox1.Refresh;
end;

procedure TAngtstWin.Compute(Sender: TObject);
var
    Sense, Quality, intdummy: Integer;
    Azimuth,Plunge,DipDir,Dip, dummy: Single;
    comment: String;
begin
  Screen.Cursor := CrHourGlass;
  try
    PrepareMetCan(LHMetCan, LHMetafile, LHEnhMetafile, LHWriteWMF);
    SetBackground(Sender, LHMetCan.Handle);
    try {Open file and retrieve data}
      AssignFile(LHInputFile, LHFilename);
      Reset(LHInputFile);
      if not SeekEof(LHInputFile) then
      begin
        LHz := 0;
        North;
        LHMetCanHandle:=LHMetCan.Handle;
        while not SeekEof(LHInputFile) and not LHfailed do
        begin
          case LHExtension of
            PTF: ReadPTFDataset(LHInputFile,Sense,Quality,DipDir,Dip,Azimuth,Plunge,dummy,dummy,dummy,
                        dummy,dummy,dummy, dummy, intdummy, LHfailed, LHNoComment);
            COR,FPL,HOE,PEF,PEK,STF: ReadFPLDataset(LHInputFile, Sense, Quality, DipDir, Dip, Azimuth, Plunge, LHfailed, LHNoComment, LHExtension, Comment);
          else LHfailed:= true;
          end;
          //if failed then raise EFileReadError.Create('ReadError', z);
          if not LHfailed and LHNoComment then
          begin
            If Angelier1.checked then
              GreatCircle(LHMetCanHandle,Canvas,CenterX,CenterY,Radius,DipDir, Dip, LHz, Number1.Checked, {HLHGeomPEN} LHPen.Handle, LHLogPen)
            else
              HoepSymbol2(LHMetCanHandle,Canvas,CenterX,CenterY,Radius,Sense,Quality, DipDir,Dip,
                          Azimuth,Plunge,LHSymbSize, LHz,Number1.Checked,QualityLevels1.Checked, LHSymbFillFlag,
                          LHPen, LHPenBrush, LHFillBrush);
            If not seekeof(LHInputFile) then Inc(LHz);
          end else if not LHNoComment and (LHz>0) then dec(LHz);
        end; //end of while-loop1
        If Angelier1.checked and not lhfailed then
        begin
          LHz := 0;
          //**************** BUGFIX 130702 close and reopen file again to avoid eof error
          CloseFile(LHInputFile);
          AssignFile(LHInputFile, LHFilename);
          //*********************
          Reset(LHInputFile);
          while not SeekEof(LHInputFile) and not LHfailed do
          begin
            case LHExtension of
              PTF: ReadPTFDataset(LHInputFile,Sense,Quality,DipDir,Dip,Azimuth,Plunge,dummy,dummy,dummy,
                        dummy,dummy,dummy, dummy,intdummy, LHfailed, LHNoComment);
              COR,FPL,HOE,PEF,PEK,STF: ReadFPLDataset(LHInputFile, Sense, Quality, DipDir, Dip, Azimuth, Plunge, LHfailed, LHNoComment, LHExtension, Comment);
            else LHfailed:= true;
            end;
            //if failed then raise EFileReadError.Create('ReadError', z);
            if not LHfailed and LHNoComment then
            begin
              Striae(LHMetCanHandle,Canvas,CenterX,CenterY,Radius,DipDir, Dip,Azimuth,Plunge,LHSymbSize,
                      Sense,Quality, LHz, Number1.Checked, QualityLevels1.Checked, LHSymbFillFlag,
                      LHExtension, LHPen, LHPenBrush, LHFillBrush);
              If not seekeof(LHInputFile) then Inc(LHZ);
            end
            else if not LHNoComment and (LHz>0) then dec(LHz);
          end; //end of while-loop2
        end;
      end else LHfailed:= true;
      CloseFile(LHInputFile);
    except   {can not open file}
      On E: EInOutError do
      begin
        //FileFailed3(E.ClassName, E.Message, (E as EInOutError).Errorcode);
        LHfailed:=true;
        fileused:=true;
      end;
      On E: EFileReadError do
      begin
        CloseFile(LHInputFile);
        FileFailed3(E.ClassName, E.Message, (E as EFileReadError).LineNumber);
      end;
    end;
    If not LHfailed then
    begin
      numberlabel;
      inherited;
    end;
  finally
    LHMetCan.Free;
    Screen.Cursor := CrDefault;
  end;
  If LHfailed then FileFailed(Self);
end;

procedure TAngtstWin.Angelier1Click(Sender: TObject);
begin
  If (Sender=angelier1) or (Sender=Angelier2) then
  begin
    Caption:='Angelier-plot - [' +ExtractFileName(LHFilename) +']';
    LHPlotType:=pt_Angelier;
  end
  else
  begin
    Caption:= 'Hoeppener-plot - [' +ExtractFileName(LHFilename) +']';
    LHPlotType:=pt_Hoeppener;
  end;
  inherited;
end;

procedure TAngtstWin.Paste1click(Sender: TObject);
begin
  inherited;
  Plottype1.enabled:=false;
  Qualitylevels1.enabled:=false;
end;
end.
