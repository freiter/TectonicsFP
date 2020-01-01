unit LowHem;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ExtCtrls, Clipbrd, Menus, Types, Dialogs, PrintDia, Printers;

  type
  TLHWin = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    Close1: TMenuItem;
    N1: TMenuItem;
    Save1: TMenuItem;
    Export1: TMenuItem;
    Convert1: TMenuItem;
    Cor1: TMenuItem;
    N4: TMenuItem;
    Print1: TMenuItem;
    PrintSettup1: TMenuItem;
    N5: TMenuItem;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;Delete1: TMenuItem;
    Settings1: TMenuItem;
    Fonts1: TMenuItem;
    Number1: TMenuItem;
    Label1: TMenuItem;
    Options1: TMenuItem;
    PopupMenu1: TPopupMenu;
    Copy2: TMenuItem;
    Paste1: TMenuItem;
    Paste2: TMenuItem;
    PaintBox1: TPaintBox;
    Plottype1: TMenuItem;
    Angelier1: TMenuItem;
    ptAxes1: TMenuItem;
    Hoeppener1: TMenuItem;
    N2: TMenuItem;
    N6: TMenuItem;
    Scaling2: TMenuItem;
    Sort1: TMenuItem;
    N3: TMenuItem;
    Qualitylevels1: TMenuItem;
    N7: TMenuItem;
    PlotProperties2: TMenuItem;
    N8: TMenuItem;
    Undo1: TMenuItem;
    Saveas1: TMenuItem;
    Rollups1: TMenuItem;
    Plotproperties1: TMenuItem;
    Scaling1: TMenuItem;
    Numresults1: TMenuItem;
    Numresults2: TMenuItem;
    Rollups2: TMenuItem;
    Plottype2: TMenuItem;
    Angelier2: TMenuItem;
    Hoeppener2: TMenuItem;
    ptAxes2: TMenuItem;
    Editor1: TMenuItem;
    Opendatafile1: TMenuItem;
    Newdatafile1: TMenuItem;
    ChangeLabel1: TMenuItem;
    N9: TMenuItem;
    Help2: TMenuItem;
    Mohrcircle1: TMenuItem;
    Mohrcircle2: TMenuItem;
    OpenPlot1: TMenuItem;
    procedure PaintBox1Paint(Sender: TObject); virtual;
    procedure New1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure Export1Click(Sender: TObject);
    procedure Convert1Click(Sender: TObject);
    procedure Cor1Click(Sender: TObject);
    procedure Print1Click(Sender: TObject); virtual;
    procedure PrintSettup1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject); virtual;
    procedure Paste1Click(Sender: TObject); virtual;
    procedure Edit1Click(Sender: TObject);
    procedure Fonts1Click(Sender: TObject);
    procedure Number1Click(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure FormResize(Sender: TObject); virtual;
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer); virtual;
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); virtual;
    procedure FormDeactivate(Sender: TObject); virtual;
    procedure Options1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure PaintBox1DragOver(Sender, Source: TObject; X, Y: Integer;
              State: TDragState; var Accept: Boolean);
    procedure PaintBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure Sort1Click(Sender: TObject);
    procedure FillColor1Click(Sender: TObject);
    procedure PlotProperties1Click(Sender: TObject);
    procedure BrushCreate(Sender: TObject); virtual;
    procedure Angelier1Click(Sender: TObject); virtual;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); virtual;
    procedure Scaling1Click(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure Numresults1Click(Sender: TObject);
    procedure Rollups1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Newdatafile1Click(Sender: TObject);
    procedure Opendatafile1Click(Sender: TObject);
    procedure ChangeLabel1Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Help2Click(Sender: TObject);
    procedure OpenPlot1Click(Sender: TObject);
  protected
    LHMetCanHandle: HDC;
    UndoPlotInfo1, UndoPlotInfo2, UndoPlotInfo3: String;
    LHMetafile, LHUndoWMF1, LHUndoWMF2, LHUndoWMF3 : TMetafile;
    LHEnhMetafile, LHUndoEMF1, LHUndoEMF2, LHUndoEMF3 : TEnhMetafile;
    LHMetCan : TCanvas;
    LHCreating, LHOnceClick, FileUsed, LHNoComment, LHwriteWMF, LHPoleflag,
    LHStartDr, LHDestroying : Boolean;
    LHStoreAzim, LHStoreDip, LHMouseAzimuth, LHMouseDip: Single;
    FLHPlotType: TPlot;
    procedure FormCreate(Sender: TObject; const AFilename: String; const AExtension: TExtension); virtual;
    procedure FileFailed(Sender: TObject);
    procedure FileFailed3(FClassName, FMessage: String; FErrorcode: Integer);
    procedure NumberLabel;
    procedure North;
    procedure Properties1Click(Sender: TObject); virtual; abstract;
  public
    LHLocationInfo: TLocationInfo;
    LHExtension : TExtension;
    LHz, LHPastedFiles, LHPlotNumber, LHStressaxis{rose only} : Integer;
    LHNetColor: TColor;
    LHSymbSize: Single;
    LHSymbType: TPlotSymbol;
    LHFailed, LHCopyMode, LHPasteMode,LHSymbFillFlag, LHSymbFillFlag2,
    LHBackgrOn: Boolean;
    LHPen: TPen;
    HLHGeomPEN,HLHPen: HPen;
    LHLogPen: TLogPen;
    LHPenWidth: TPoint;
    LHPenBrush, LHFillBrush, LHFillBrush2, LHBackgrBrush: TBrush;
    LHPenLogBrush: TLogBrush;
    LHInputFile : TextFile;
    LHLabel1, LHLabel2, LHFilename, LHPlotInfo: String;
    LHTectonicData: TTectonicData;
    procedure Compute(Sender: TObject); virtual;
    procedure SetLHProperties(FLHPlotType: TPlot);
    procedure SetLHPlotType(Value: TPlot);
    property LHPlotType: TPlot read FLHPlotType write SetLHPlotType;
    procedure SetBackGround(Sender: TObject; FHandle: THandle);
    procedure Saveas1Click(Sender: TObject); virtual; abstract;
    procedure AddSingleDataset(fDipDir, fDip , fAzimuth, fPlunge: Single;fSense: Integer; FPlotType: TPlot);
  end;

  TWMFWin=class(TLHWin)
    procedure FormCreate2(Sender: TObject; aFilename: String);
    procedure PaintBox1Paint(Sender: TObject); override;
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer); override;
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
    procedure Print1Click(Sender: TObject); override;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    public
      {}
    private
      CurrentPoint, RootPoint: PPointChainRecord;
      PaintboxPaintRec : TRect;
      WMFBitmap: TBitmap;
      IndexOfMidPoint, BMPRadius, BMPPointCounter: Integer;
      BMPPoints: Array[0..1000] of TPoint;
      BMPBitmapRatio: Single;
      BMPCalculated: Boolean;
      procedure CalculateFry(Sender: TObject);
  end;

var
  LHWin: TLHWin;

implementation

uses FileOps, Tecmain, Draw, Inspect, Settings, results, rose, invers, nda, contour, MD5,
     SortMan, Fish;
{$R *.DFM}

procedure TLHWin.SetBackground(Sender: TObject; FHandle: THandle);
var MyFillRect: TRect;
begin
  If LHBackgrOn and not LHCopyMode then
  begin
    If label1.checked or (lhplottype=pt_fluhist) or (lhplottype=pt_besttheta) or
      (lhplottype=pt_fluhist) or (lhplottype=pt_roseCenter) or (lhplottype=pt_rosecorner) or
      (lhplottype=pt_MohrSigma) or (lhplottype=pt_MohrLambda) then
    With MyFillRect do
    begin                                 
      Top:=0;
      Left:=0;
      Right:=MetafileWidth;
      Bottom:=MetafileHeight;
      //FillRect(FHandle, MyFillRect, LHBackgrBrush.Handle);
      //990208 bugfix for ArcView 3.0
      SelectObject(FHandle, LHBackgrBrush.Handle);
      SelectObject(FHandle, GetStockObject(null_pen));
      Rectangle(FHandle,0,0, MetafileWidth, MetafileHeight);
      SelectObject(FHandle, GetStockObject(hollow_brush));
      SelectObject(FHandle, LHPen.Handle);
    end
    else
    begin
      SelectObject(fhandle, LHBackgrBrush.Handle);
      SelectObject(fhandle, GetStockObject(null_pen));
      Ellipse(FHandle,CenterX-Radius, CenterY-Radius, CenterX+Radius, CenterY+Radius);
      SelectObject(fhandle, GetStockObject(hollow_brush));
      SelectObject(fhandle, LHPen.Handle);
    end;
  end;
end;

procedure TLHWin.SetLHPlotType(Value: TPlot);
begin
  If FLHPlotType<>Value then
    FLHPlotType:=Value;
  Case FLHPlotType of
    pt_GreatCircle: HelpContext:=525;
    pt_SmallCircle: HelpContext:=530;
    pt_PiPlot: HelpContext:=535;
    pt_DipLine: HelpContext:=537;
    pt_Lineation: HelpContext:=540;
    pt_Angelier: HelpContext:=545;
    pt_Hoeppener: HelpContext:=550;
    pt_PTPlot: HelpContext:=555;
    pt_SortMan: HelpContext:=680;
    pt_rotate: HelpContext:=710;
    pt_Meanvectfisher, pt_MeanVectRC: HelpContext:=715;
    pt_bingham: HelpContext:=720;
    pt_rosecenter, pt_rosecorner: HelpContext:= 725;
    pt_contour: HelpContext:=730;
    pt_besttheta: HelpContext:=596;
    pt_sigmatensor: if self is tinversplot then HelpContext:=735
      else helpcontext:=750;
    pt_sigmadihedra: if self is tinversplot then HelpContext:=735
       else helpcontext:=755;
    pt_lambdatensor: if self is tndaplot then HelpContext:=740
       else helpcontext:=750;
    pt_lambdadihedra: if self is tndaplot then HelpContext:=740
       else helpcontext:=755;
    pt_dihedra: HelpContext:=745;
    pt_mohrsigma, pt_mohrlambda: helpcontext:=760;
    pt_fluhist: helpcontext:=765;
  else HelpContext:=0;
  end;
end;


procedure TLHWin.Compute(Sender: TObject);
begin
  if LHPLotType<>pt_SmallCircle then LHPlotInfo:='Filename: '+LHFilename+#13#10 else LHPlotInfo:='';
  LHPlotInfo:=LHPlotInfo+'Plot name: '+LHLabel1+#13#10+'Plot type: '+ GetPlotAsString(LHPlotType, LHExtension, lhstressaxis);
  if (LHPlotType<>pt_SigmaTensor) and (LHPlotType<>pt_LambdaTensor) and
  (LHPlotType<>pt_SigmaDihedra) and
    (LHPlotType<>pt_LambdaDihedra) and (LHPlotType<>pt_Contour) and (LHPlotType<>pt_Dihedra)
    and (LHPlotType<>pt_FluHist) and (LHPlotType<>pt_MohrLambda) and (LHPlotType<>pt_MohrSigma)
    then LHPlotInfo:=LHPlotInfo+#13#10+'Datasets: '+IntToStr(LHz+1);
  if (LHPlotType=pt_Contour) or (LHPlotType=pt_Dihedra) or ((lhplottype=pt_sigmadihedra) and (self is tdihedrfrm))
  or ((lhplottype=pt_sigmatensor) and (self is TDihedrFrm))
  then LHPlotInfo:=LHPlotInfo+#13#10+'Datasets: '+IntToStr(LHz);
  if (LHPLotType<>pt_SmallCircle) and (LHPLotType<>pt_GraphicsFromDisk) then
  begin
    LHLocationInfo:=GetLocInfo(LHFileName);
    If (ResInspShowLocation) and (LHLocationInfo.LocName<>'') then
      LHPlotInfo:=LHPlotInfo+#13#10+ 'Location: '+LHLocationInfo.LocName;
    If (ResInspShowX) and (LHLocationInfo.x<>'') then
      LHPlotInfo:=LHPlotInfo+#13#10+ 'x: '+LHLocationInfo.x;
    If (ResInspShowY) and (LHLocationInfo.y<>'') then
      LHPlotInfo:=LHPlotInfo+#13#10+ 'y: '+LHLocationInfo.y;
    If (ResInspShowZ) and (LHLocationInfo.z<>'') then
      LHPlotInfo:=LHPlotInfo+#13#10+ 'z: '+LHLocationInfo.z;
    If (ResInspShowDate) and (LHLocationInfo.Date<>'') then
      LHPlotInfo:=LHPlotInfo+#13#10+ 'Date: '+LHLocationInfo.Date;
    If (ResInspShowLithology) and (LHLocationInfo.Lithology<>'') then
      LHPlotInfo:=LHPlotInfo+#13#10+ 'Lithology: '+LHLocationInfo.Lithology;
    If (ResInspShowFormation) and (LHLocationInfo.Formation<>'') then
      LHPlotInfo:=LHPlotInfo+#13#10+ 'Formation: '+LHLocationInfo.Formation;
    If (ResInspShowAge) and (LHLocationInfo.Age<>'') then
      LHPlotInfo:=LHPlotInfo+#13#10+ 'Age: '+LHLocationInfo.Age;
    If (ResInspShowTectUnit) and (LHLocationInfo.TectUnit<>'') then
      LHPlotInfo:=LHPlotInfo+#13#10+ 'Tect. unit: '+LHLocationInfo.TectUnit;
    If (ResInspShowRemarks) and (LHLocationInfo.Remarks<>'') then
      LHPlotInfo:=LHPlotInfo+#13#10+ 'Remarks: '+LHLocationInfo.Remarks;
  end;
  end;

procedure TLHWin.PaintBox1Paint(Sender: TObject);
var PaintRec : TRect;
begin
  If not LHfailed then with PaintBox1 do
  begin
    Screen.Cursor:=crHourglass;
    PaintRec := Bounds((Width - min(Height,Width)) div 2,
                       (Height- min(Height,Width)) div 2,
                       min(Height,Width),
                       min(Height,Width));
    If LHWriteWMF then Canvas.StretchDraw(PaintRec, LHMetafile)
      else Canvas.StretchDraw(PaintRec, LHEnhMetafile);
    Screen.Cursor:=crDefault;
  end;
end;

procedure TLHWin.New1Click(Sender: TObject);
begin
  TecMainWin.EditNewChild(Application);
end;

procedure TLHWin.Open1Click(Sender: TObject);
begin
  TecMainWin.EditOpenChild(Application);
end;

procedure TLHWin.Close1Click(Sender: TObject);
begin
  Close;
end;

procedure TLHWin.Export1Click(Sender: TObject);
type PHandle = ^Thandle;
var
  ext : TString4;
  SaveFlag : Boolean;
  GraphicsFile : String;
  Rect: TRect;
  MyDXFFile: TDXFFile;
  MyHPGLFile: THPGLFile;
  fSize: Integer;
  bits: Pointer;
  mfp: TMetafilePict;
  fHandle: THandle;
begin
  ManageSaveDialog(LHFilename,GraphicsFile,Saveflag,ext,LHWriteWMF);
  If Saveflag then
  begin
    Screen.Cursor:= crHourGlass;
    with MFP do
    begin
      MM := MM_ANISOTROPIC;
      xExt := 0;
      yExt := 0;
      hmf := 0;
    end;
    if ext = '.dxf' then //autocad export format
    begin
      MyDXFFile:=TDXFFile.Create;
      MyDXFFile.IsDXF:=true;
      try
        If LHWriteWMF then
        begin
          MyDXFFile.Open(GraphicsFile, LHMetafile.Height, LHMetafile.Width);
          if not EnumMetaFile(0, LHMetafile.Handle, @WMFtoDXFHGL, longint(MyDXFFile)) then //conversion fails in WinNT4.0 for WMF
          begin  //convert wmf to emf
            fSize:=GetMetaFileBitsEx(LHMetafile.Handle, 0, nil);
            If FSize<>0 then
            begin
              GetMem(Bits, fSize);
              try
                if GetMetaFileBitsEx(LHMetafile.Handle, fSize, Bits)<>0 then
                begin
                  fHandle:=SetWinMetaFileBits(fSize, Bits, 0, MFP);
                  if fHandle<>0 then
                    SaveFlag:=EnumEnhMetaFile(0, fHandle, @EMFtoDXFHGL, MyDXFFile, rect)
                  else SaveFlag:=false;
                end else SaveFlag:=false;
              finally
                FreeMem(Bits);
                if fHandle<>0 then DeleteEnhMetafile(fHandle);
              end;
            end else SaveFlag:=false;
          end;
        end
        else //EMF-file
        begin
          MyDXFFile.Open(GraphicsFile, LHEnhMetafile.Height, LHEnhMetafile.Width);
          SaveFlag:=EnumEnhMetaFile(0, LHEnhMetafile.Handle, @EMFtoDXFHGL, MyDXFFile, rect);
        end;
      finally
        MyDXFFile.Close;
        MyDXFFile.Free;
      end;
    end
    else
      if (ext='.hgl') or (ext='.plt') then
      begin
        //**************HPGL-header**************
        MyHPGLFile:=THPGLFile.Create;
        MyHPGLFile.IsDXF:=false;
        try
          If LHWriteWMF then
          begin
            MyHPGLFile.Open(GraphicsFile, LHMetafile.Height, LHMetafile.Width);
            if not EnumMetaFile(0, LHMetafile.Handle, @WMFtoDXFHGL, longint(MyHPGLFile)) then
            begin
              fSize:=GetMetaFileBitsEx(LHMetafile.Handle, 0, nil);
              If FSize<>0 then
              begin
                GetMem(Bits, fSize);
                try
                  if GetMetaFileBitsEx(LHMetafile.Handle, fSize, Bits)<>0 then
                  begin
                    fHandle:=SetWinMetaFileBits(fSize, Bits, 0, MFP);
                    if fHandle<>0 then
                      SaveFlag:=EnumEnhMetaFile(0, fHandle, @EMFtoDXFHGL, MyHPGLFile, rect)
                    else SaveFlag:=false;
                  end else SaveFlag:=false;
                finally
                  FreeMem(Bits);
                  if fHandle<>0 then DeleteEnhMetafile(fHandle);
                end;
              end else SaveFlag:=false;
            end;
          end
          else
          begin
            MyHPGLFile.Open(GraphicsFile, LHEnhMetafile.Height, LHEnhMetafile.Width);
            SaveFlag:=EnumEnhMetaFile(0, LHEnhMetafile.Handle, @EMFtoDXFHGL, MyHPGLFile, rect);
          end;
        finally
          MyHPGLFile.Close;
          MyHPGLFile.Free;
        end;
      end
      else
          If ext ='.emf' then
            If LHWriteWMF then
            begin
              LHWriteWMF:=False;     //create metafile
              CreateMetafile(LHMetafile,LHEnhMetafile,LHWriteWMF);
              Compute(Sender);
              LHWriteWMF:=True;
              LHEnhMetafile.SaveToFile(GraphicsFile);
              LHEnhMetafile.Free;
            end
            else //enhanced
              LHEnhMetafile.SaveToFile(GraphicsFile)
          else   //if ext='.wmf'
          If LHWriteWMF then
            LHMetafile.SaveToFile(GraphicsFile)  //placeable
          else  //placeable wmf
          begin
            LHWriteWMF:=true;     //create placeable metafile
            CreateMetafile(LHMetafile,LHEnhMetafile,LHWriteWMF);
            Compute(Sender);
            LHWriteWMF:=false;
            LHMetafile.SaveToFile(GraphicsFile);
            LHMetafile.Free;
          end;
    Screen.Cursor:= crDefault;
    if SaveFlag then TecMainWin.WriteToStatusbar(nil ,'Written to file '+GraphicsFile)
    else
    begin
      DeleteFile(GraphicsFile); //Delete empty file from disk
      MessageDlg('Conversion failed.', mtError, [mbOk], 0);
    end;
  end; // if SaveFlag
end;

procedure TLHWin.Sort1Click(Sender: TObject);
begin
  TecMainWin.Sort1Click(Application);
end;

procedure TLHWin.Convert1Click(Sender: TObject);
begin
  TecMainWin.Convert1Click(Application);
end;

procedure TLHWin.Cor1Click(Sender: TObject);
begin
  TecMainWin.Correct1Click(Application);
end;

procedure TLHWin.Print1Click(Sender: TObject);
var HorzPixPerInch,VertPixPerInch, PageWidth{, PageHeight}: Integer;
    PrtRec : TRect;
begin
  If Sender<>TecMainWin.PrintBtn then
  begin
    if TecMainWin.PrintDialog1.Execute then with TPrintDial.Create(Application) do
    try
      HelpBtn.HelpContext:=615;
      Caption := Caption +' - [' +
               ExtractFileName(LHFilename) +']';
      ShowModal;
      If ModalResult<>mrOK then exit;
    finally
      Release;
    end
    else exit;
  end;
  Screen.Cursor := crHourglass;
  Printer.Title:='TectonicsFP - '+ExtractFileName(LHFilename);
  Printer.BeginDoc;
    Pagewidth:=GetDeviceCaps(Printer.Canvas.Handle, horzsize);
    {Pageheight:=GetDeviceCaps(Printer.Canvas.Handle, vertsize);}
    HorzPixPerInch:=GetDeviceCaps(Printer.Canvas.Handle, LOGPIXELSX);
    VertPixPerInch:=GetDeviceCaps(Printer.Canvas.Handle, LOGPIXELSY);
    If PrintLowerHemiSize>= Pagewidth*4 div 5 then PrintLowerHemiSize:=PageWidth*4 div 5;
    PrtRec := Bounds(Round(HorzPixPerInch/25.4/2*(PageWidth-PrintLowerHemiSize/4*5)),
                     Round(VertPixPerInch/25.4*20),
                     Round(HorzPixPerInch/25.4/4*5*PrintLowerHemiSize),
                     Round(VertPixPerInch/25.4/4*5*PrintLowerHemiSize));
    If LHWriteWMF then Printer.Canvas.StretchDraw(PrtRec, LHMetafile)
    else Printer.Canvas.StretchDraw(PrtRec, LHEnhMetafile);
  Printer.EndDoc;
  Screen.Cursor := crDefault;
end; //sub

procedure TLHWin.PrintSettup1Click(Sender: TObject);
begin
  TecMainWin.PrinterSetupDialog1.Execute;
end;

procedure TLHWin.Exit1Click(Sender: TObject);
begin
  TecMainWin.Exit1Click(Application);
end;

procedure TLHWin.Copy1Click(Sender: TObject);
var GraphicsData, TextData: THandle;
    ClipbWMFBuf : PMetafilepict;
    ClipbEMFBuf: PEMFPict;
    TextDataPtr: Pointer;
    Fred1: LongInt;
    FMetaHeader: PENHMETAHEADER;
    DummyPtr: Pointer;
    StringDummy: String;
begin
  Screen.Cursor:=crHourGlass;
  Clipboard.Clear;
  Clipboard.Open;
  try
    EmptyClipboard;
      If LHWriteWMF then
      begin
        SetMetafileSize(TGraphic(LHMetafile),LHWriteWMF);
        Clipboard.Assign(LHMetafile);
      end
      else
      begin
        SetMetafileSize(TGraphic(LHEnhMetafile),LHwritewmf);
        Clipboard.Assign(LHEnhMetafile);
      end;
      If Self is TWMFWin then
      begin                                      
        If LHWriteWMF then
        begin
          //Clipboard.Assign((Self as TWMFWin).WMFBitmap);
          Clipboard.Assign(GetFormImage);
        end
        else
        begin
          with TEnhMetafileCanvas.Create(LHEnhMetafile, 0) do
          try
            Draw(0,0,(Self as TWMFWin).WMFBitmap);
          finally
            Free;
          end;
          Clipboard.Assign(LHEnhMetafile);
       end;
      end;
    //*************overlay copy begin******************
    if GlobalClipbMFH<>0 then //delete previous clipboard metafiles if existing
    begin
      If LHWriteWMF then DeleteMetaFile(GlobalClipbMFH)
      else DeleteEnhMetaFile(GlobalClipbMFH);
      GlobalClipbMFH:=0;
    end;
    if (LHPastedFiles<1) and (LHPlotType<>pt_FluHist) and (LHPlotType<>pt_MohrSigma)
      and (LHPlotType<>pt_MohrLambda) and (LHPlotType<>pt_RoseCenter) and
      (LHPlotType<>pt_RoseCorner) and (LHPlotType<>pt_BestTheta) then
    begin
      //*****text*******
      Stringdummy:=LHPlotInfo+#13#10+'LHPlotNumber: '+IntToStr(LHPlotNumber);
      TextData := GlobalAlloc(GMEM_MOVEABLE, Length(Stringdummy)+ 1);
      try
        TextDataPtr := GlobalLock(TextData);
        try
          Move(PChar(Stringdummy)^, TextDataPtr^, Length(Stringdummy)+ 1);
          SetClipboardData(TFPText, TextData);
        finally
          GlobalUnlock(TextData);
        end;
      except
        GlobalFree(TextData);
        raise;
      end;
      //*****graphics***********
      LHCopyMode:=true;
      compute(Sender);
      LHCopyMode:=false;
      If LHWriteWMF then //tfp1-wmf
      begin
        GraphicsData := GlobalAlloc(Gmem_moveable, sizeof(TMetafilepict));
        try
          ClipbWMFBuf := Globallock(GraphicsData);
          with ClipbWMFBuf^ do
          begin
            mm:=mm_anisotropic;
            xExt:=MetafileMMWidth;
            yext:=MetafileMMHeight;
            hmf:=Copymetafile(LHMetafile.Handle, nil);
            GlobalClipbMFH:=hmf;
          end;
          SetClipboardData(TFPMetafile,GraphicsData);
        finally
          GlobalUnlock(GraphicsData);
        end;
      end
      else
      begin   //tfp1-emf
        GraphicsData:= GlobalAlloc(Gmem_moveable, Sizeof(TEMFPict));
        try
          ClipbEMFBuf:= GlobalLock(GraphicsData);
          {//**************
            fred1:=GetEnhMetaFileHeader(LHEnhMetafile.Handle,fred1, nil);
            getmem(fmetaheader,fred1);
            GetEnhMetaFileHeader(LHEnhMetafile.Handle,fred1, fmetaheader);
            ClipbEMFBuf^.HEMF:=GlobalAlloc(Gmem_moveable, fmetaheader.nbytes);
            Dummyptr:=GlobalLock(ClipbEMFBuf^.HEMF);
              Move(LHEnhMetafile, Dummyptr, fmetaheader.nbytes);
            GlobalUnlock(ClipbEMFBuf^.HEMF);
            freemem(fmetaheader,fred1);
          //*************************************}
          ClipbEMFBuf^.HEMF:= CopyEnhMetaFile(LHEnhMetafile.Handle, nil);
          GlobalClipbMFH:=ClipbEMFBuf^.HEMF;
          SetClipboardData(TFPEnhMetafile, GraphicsData);
        finally
          GlobalUnlock(GraphicsData);
        end;
        {graphicsdata:= GlobalAlloc(Gmem_moveable, Sizeof(LHEnhMetafile));
        emfPtr := GlobalLock(graphicsdata);
        try
          CopyMemory(emfPtr, LHEnhMetafile, Sizeof(LHEnhMetafile));
          SetClipboardData(TFPEnhMetafile,GraphicsData);
        finally
          GlobalUnlock(GraphicsData);
        end;}
      end;
      Compute(Sender);
    end;
    //*****************overlay copy end*************+****
  finally
    clipboard.close;
  end;
  Edit1Click(Sender);
  Screen.Cursor:=crDefault;
end;

procedure TLHWin.Paste1Click(Sender: TObject);
var AData, metafiledummy: THandle;
    mfp: ^TMetafilepict;
    emfp: ^TEMFPict;
    PastePlotName, MyText: String;
    CounterMetafile: TMetafile;
    EnhCounterMetafile: TEnhMetafile;
    fred2: thandle;
begin
  Screen.Cursor:=crHourGlass;
  //***********Undo begin*********************
  If LHWriteWMF then
  begin
    If LHUndoWMF1= nil then LHUndoWMF1:= TMetafile.Create
    else
    If LHUndoWMF2= nil then
    begin
      LHUndoWMF2:= TMetafile.Create;
      LHUndoWMF2.Assign(LHUndoWMF1);
      UndoPlotInfo2:=UndoPlotInfo1;
    end
    else
    If LHUndoWMF3= nil then
    begin
      LHUndoWMF3:= TMetafile.Create;
      LHUndoWMF3.Assign(LHUndoWMF2);
      LHUndoWMF2.Assign(LHUndoWMF1);
      UndoPlotInfo3:=UndoPlotInfo2;
      UndoPlotInfo2:=UndoPlotInfo1;
    end
    else
    begin
      LHUndoWMF3.Assign(LHUndoWMF2);   //bugfix 981204
      LHUndoWMF2.Assign(LHUndoWMF1);
      UndoPlotInfo3:=UndoPlotInfo2;
      UndoPlotInfo2:=UndoPlotInfo1;
    end;
    LHUndoWMF1.Assign(LHMetafile);
  end
  else
  begin
    If LHUndoEMF1= nil then LHUndoEMF1:= TEnhMetafile.Create
    else
    If LHUndoEMF2= nil then
    begin
      LHUndoEMF2:= TEnhMetafile.Create;
      LHUndoEMF2.Assign(LHUndoEMF1);
      UndoPlotInfo2:=UndoPlotInfo1;
    end
    else
    If LHUndoEMF3= nil then
    begin
      LHUndoEMF3:= TEnhMetafile.Create;
      LHUndoEMF3.Assign(LHUndoEMF2);
      LHUndoEMF2.Assign(LHUndoEMF1);
      UndoPlotInfo3:=UndoPlotInfo2;
      UndoPlotInfo2:=UndoPlotInfo1;
    end
    else
    begin
      LHUndoEMF3.Assign(LHUndoEMF2);
      LHUndoEMF2.Assign(LHUndoEMF1);
      UndoPlotInfo3:=UndoPlotInfo2;
      UndoPlotInfo2:=UndoPlotInfo1;
    end;
    LHUndoEMF1.Assign(LHEnhMetafile);
  end;
  UndoPlotInfo1:=LHPlotInfo;
  //********************Undo end*****************
  If LHPastedFiles<1 then
  begin
    LHPasteMode := true;
    Compute(Sender);
    LHPasteMode:=false;
  end;
  OpenClipboard(Application.Handle);
  //**************Retrieve TFP-Text information begin *******
  AData := GetClipboardData(TFPText);
  try
    if AData <> 0 then
      MyText := PChar(GlobalLock(AData))
    else MyText := '';
  finally
    if AData <> 0 then GlobalUnlock(AData);
    CloseClipboard;
  end;
  PastePlotName:=Copy(MyText, Pos('Plot name: ',MyText)+length('Plot name: '), Pos('Plot type: ', MyText)-Pos('Plot name: ',MyText)-length('Plot name: ')-2);
  Delete(MyText, Pos('LHPlotNumber: ', MyText)-2, Length(MyText));
  LHPlotInfo:=LHPlotInfo+#13#10+
    '******************************************'+#13#10+
    MyText;
  //**************Retrieve TFP-Text information end *******
  If LHWriteWMF then with TMetafileCanvas.Create(LHMetafile, 0) do
  begin
    try
      Draw(0,0,LHMetafile);
      //***retrieve clipboard data as tfpmetafile***
      OpenClipboard(Application.Handle);
      try
        metafiledummy := GetClipboardData(TFPMetafile);
        if metafiledummy<>0 then
        begin
          MFP := Globallock(metafiledummy);
          AData:=MFP.hmf;
          LHMetafile.Handle := CopyMetafile(AData, nil);
          GlobalUnlock(metafiledummy);
          //GlobalFree(AData); //bugfix 981204
          Draw(0,0,LHMetafile);
        end;
      finally
        CloseClipboard;
      end;
      //********************************************
      //***Add pasted filename to graphics image
      If Label1.Checked then
      begin
        CounterMetafile:=TMetafile.Create;
        try
          With TMetaFileCanvas.Create(CounterMetafile, 0) do
          try
            SetBkMode(Handle, TRANSPARENT);
            Font:=TecMainWin.FontDialog1.Font;
            TextOut(labelleft,labeltop+(6-Font.Height)*(LHPastedFiles+1), PastePlotName);
          finally
            free;
          end;
          Draw(0,0,CounterMetafile);
        finally
          CounterMetafile.Free;
        end;
      end;
    finally
      Free;
    end;
    LHMetafile.Height := MetafileHeight;
    LHMetafile.Width  := MetafileWidth;
    LHMetafile.MMWidth  := MetafileMMWidth;
    LHMetafile.MMHeight := MetafileMMHeight;
    LHMetafile.Inch := MetafileInch;
  end
  else with TEnhMetafileCanvas.Create(LHEnhMetafile, 0) do
  begin
  try
    Draw(0,0,LHEnhMetafile);
    OpenClipboard(Application.Handle);
    try
      metafiledummy := GetClipboardData(TFPEnhMetafile);
      {if metafiledummy<>0 then
      begin
        LHEnhMetafile.Handle := CopyEnhMetafile(metafiledummy, nil);
        Draw(0,0,LHEnhMetafile);
      end;}
      if metafiledummy<>0 then
      begin
        EMFP := Globallock(metafiledummy);
        AData:=EMFP.hemf;
        LHEnhMetafile.Handle := CopyEnhMetafile(AData, nil);
        //fred2:= CopyEnhMetafile(EMFP.hemf, nil);
        //fred2:=GetEnhMetaFileBits(EMFP.hemf,0,nil);
        if LHEnhMetafile.Handle =0 then fred2:=getlasterror;
        GlobalUnlock(metafiledummy);
        Draw(0,0,LHEnhMetafile);
      end;
    finally
      CloseClipboard;
    end;
    //LHEnhMetafile.Assign(Clipboard);
    //Draw(0,0,LHEnhMetafile);
    //******Add pasted filename to graphics image*************
    If Label1.Checked then
    begin
      EnhCounterMetafile:=TEnhMetafile.Create;
      try
        With TEnhMetaFileCanvas.Create(EnhCounterMetafile, 0) do
        try
          SetBkMode(Handle, TRANSPARENT);
          Font:=TecMainWin.FontDialog1.Font;
          TextOut(labelleft,labeltop+(6-Font.Height)*(LHPastedFiles+1), PastePlotName);
        finally
          free;
        end;
        Draw(0,0,EnhCounterMetafile);
      finally
        EnhCounterMetafile.Free;
      end;
    end;
  finally
    Free;
  end;
  LHEnhMetafile.Height := MetafileHeight;
  LHEnhMetafile.Width  := MetafileWidth;
  end;
  Number1.Enabled := false;
  Label1.Enabled:= false;
  Fonts1.Enabled:= false;
  ChangeLabel1.Enabled := false;
  Inc(LHPastedFiles);
  if InspectorForm<>nil then InspectorForm.Initialize(Self);
  if resinsp<>nil then ResInsp.Initialize(Self);
  PaintBox1.Refresh;
  Edit1Click(Sender);
end;

procedure TLHWin.Edit1Click(Sender: TObject);
var adata: Integer;
    MyText: string;
    Fred: integer;
begin
  If (LHPlotType<>pt_MohrSigma) and (LHPlotType<>pt_MohrLambda) and
    (LHPlotType<>pt_FluHist) and (LHPlotType<>pt_RoseCenter) and (LHPlotType<>pt_RoseCorner)
    and (LHPlotType<>pt_BestTheta) then
    begin
      if LHWriteWMF then
        Paste1.Enabled := Clipboard.HasFormat(TFPMetafile) and (GlobalClipbMFH<>0)
      else
        Paste1.Enabled := Clipboard.HasFormat(TFPEnhMetafile) and (GlobalClipbMFH<>0);
      If Paste1.Enabled then
      begin
        OpenClipboard(Application.Handle);
        //**************Retrieve TFP-Text information begin *******
        AData := GetClipboardData(TFPText);
        try
          if AData <> 0 then MyText := PChar(GlobalLock(AData))
          else MyText := '';
        finally
          if AData <> 0 then GlobalUnlock(AData);
          CloseClipboard;
        end;
        Paste1.Enabled:=StrToInt((Copy(MyText, Pos('LHPlotNumber: ', MyText)+Length('LHPlotNumber: '), Length(MyText))))<>LHPlotNumber;
        //**************Retrieve TFP-Text information end *******
      end;
      TecMainWin.PasteBtn.Enabled:=Paste1.Enabled;
    end else TecMainWin.PasteBtn.Enabled:=false;
  Undo1.Enabled:= (LHWriteWMF and (LHUndoWMF1<> nil)) or (not LHWriteWMF and (LHUndoEMF1<> nil));
  TecMainWin.UndoBtn.Enabled:=Undo1.Enabled;
end;

procedure TLHWin.Fonts1Click(Sender: TObject);
begin
  If TecMainWin.Fontdialog1.execute then
  begin
    Screen.Cursor:=crHourGlass;
    Canvas.Font:=TecMainWin.FontDialog1.Font;
    Compute(Sender);
    PaintBox1.Refresh;
  end;
end;

procedure TLHWin.Number1Click(Sender: TObject);
begin
  Screen.Cursor:=crHourGlass;
  Number1.Checked:=not Number1.Checked;
  GlobalLHNumbering:= Number1.Checked;
  Compute(Sender);
  PaintBox1.Refresh;
  if Self is TSortmanual then (Self as TSortmanual).Paintbox2.Refresh; 
end;

procedure TLHWin.Label1Click(Sender: TObject);
begin
  Screen.Cursor:=crHourGlass;
  Label1.Checked:= not Label1.Checked;
  globallhLabel:= Label1.Checked;
  Compute(Sender);
  PaintBox1.Refresh;
end;

procedure TLHWin.FormResize(Sender: TObject);
begin
  TecMainWin.FormResize(Sender);
end;

procedure TLHWin.PopupMenu1Popup(Sender: TObject);
begin
  {If (LHPlotType<>pt_MohrSigma) and (LHPlotType<>pt_MohrLambda) and
    (LHPlotType<>pt_FluHist) and (LHPlotType<>pt_RoseCenter) and (LHPlotType<>pt_RoseCorner)
    and (LHPlotType<>pt_BestTheta) then
    If LHWriteWMF then Paste2.Enabled := Clipboard.HasFormat(TFPMetafile)
    else Paste2.Enabled := Clipboard.HasFormat(TFPEnhMetafile);}
  Edit1Click(Sender);
  Paste2.Enabled:=Paste1.Enabled;  
  PlotProperties2.Checked:=InspectorForm<>nil;
  Scaling2.checked:=SetForm<>nil;
  NumResults2.Checked:=ResInsp<>nil;
end;


procedure TLHWin.FormCreate(Sender: TObject; const AFilename : String; const AExtension: TExtension);
begin
   LHUndoWMF1:=nil;  //bugfix 981126
   LHUndoWMF2:=nil;
   LHUndoWMF3:=nil;
   LHCreating:=true;
   LHDestroying:=false;
   LHFilename := AFilename;
   LHLabel1:=ExtractFileName(LHFilename);
   LHPastedFiles:=0;
   LHExtension:=AExtension;
   export1.enabled:=true;
   print1.enabled:=true;
   TecmainWin.ArrangeMenu(Sender);
   SetLHProperties(LHPlotType);
   Canvas.Font:=TecMainWin.Fontdialog1.Font;
   LHOnceClick := false;
   LHPasteMode := false;
   LHCopyMode := false;
   LHWriteWMF:=WriteWmfGlobal;
   ArrowHeadLength:=Round(Radius*LinearCircleRate);{=Radius*LinearCircleRate}
   ArrowLength1:=Radius*LengthRate1;        {=Radius*LengthRate1}
   ArrowLength2:=Radius*LengthRate2;
   CreateMetafile(LHMetafile,LHEnhMetafile,LHWriteWMF);
   {With PenBrush do
   begin
     lbStyle:=BS_HATCHED;
     lbColor:=clgreen;
     lbHatch:= HS_VERTICAL;
   end;
   LHPen:=ExtCreatePen(PS_GEOMETRIC,PS_SOLID,PenBrush,0, nil);}
   Number1.Checked:=GlobalLHNumbering;
   Label1.Checked:=GlobalLHLabel;
   //If InspectorForm<>nil then InspectorForm.Initialize(Self);
   Compute(Sender);
   if LHfailed then
   begin
     globalfailed:=true;
     close;
     exit;
   end;
   Inc(GlobalLHPlots);
   LHPlotNumber:=GlobalLHPlots;
   Caption:='Plot '+IntToStr(LHPlotNumber)+': '+Caption;
   If InspectorForm<>nil then InspectorForm.Initialize(Self);
   If ResInsp<>nil then ResInsp.Initialize(Self);
   If SetForm<>nil then SetForm.Initialize(Self);
   lhcreating:=false;
end;

procedure TLHWin.SetLHProperties(FLHPlotType: TPlot);
begin
LHNetColor:=GlobalNetColor;
LHBackgrBrush.Color:=GlobalBackColor;
LHBackgrOn:=GlobalLHBackOn;
case FLHPlotType of
  pt_PiPlot:
  begin
    LHPen.Color:=PiPenColor;
    LHPen.Width:=PiPenWidth;
    LHPen.Style:=psSolid;
    LHSymbType:=PiSymbType;
    LHSymbFillFlag:=Pisymbfillflag;
    LHFillBrush.Color:=PiSymbFillColor;
    LHSymbSize:=PiSymbolSize;
    LHPoleflag:=true;
  end;
  pt_DipLine:
  begin
    LHPen.Color:=DipPenColor;
    LHPen.Width:=DipPenWidth;
    LHPen.Style:=psSolid;
    LHSymbType:=DipSymbType;
    LHSymbFillFlag:=DipSymbFillFlag;
    LHFillBrush.Color:=DipSymbFillColor;
    LHSymbSize:=DipSymbolSize;
    LHPoleflag:=False;
  end;
    pt_GreatCircle:
    With LHPen do
    begin
      Style:=GreatPenStyle;
      Width:=GreatPenWidth;
      Color:=GreatPenColor;
      LHPoleflag:=false;
    end;
    pt_SmallCircle:
    begin
      LHPen.Style:=SmallPenStyle;
      LHPen.Width:=SmallPenWidth;
      LHPen.Color:=SmallPenColor;
      LHSymbType:=SmallSymbType;
      LHSymbFillFlag:=SmallSymbFillFlag;
      LHFillBrush.Color:=SmallSymbFillColor;
      LHSymbSize:=SmallSymbolSize;
    end;
    pt_Lineation:
    begin
      LHPen.Width:=LinPenWidth;
      LHPen.Color:=LinPenColor;
      LHSymbType:=LinSymbType;
      LHSymbFillFlag:=LinSymbfillFlag;
      LHFillBrush.Color:=LinSymbfillColor;
      LHSymbSize:=LinSymbolSize;
      LHPoleflag:=false;
    end;
    pt_Angelier:
    begin
       LHPen.Style:=AngPenStyle;
       LHPen.Width:=AngPenWidth;
       LHPen.Color:=AngPenColor;
       LHPenBrush.Color:=AngPenColor;
       LHSymbFillFlag:=Angsymbfillflag;
       LHFillBrush.Color:=AngSymbfillcolor;
       LHSymbSize:=AngSymbolSize;
       LHPoleflag:=false;
    end;
    pt_Hoeppener:
    begin
      LHPen.Width:=HoepPenWidth;
      LHPen.Color:=HoepPenColor;
      LHPen.Style:=psSolid;
      LHPenBrush.Color:=HoepPenColor;
      LHSymbFillFlag:=HoepSymbfillFlag;
      LHFillBrush.Color:=HoepSymbfillcolor;
      LHSymbSize:=Hoepsymbradius;
      LHPoleflag:=true;
    end;
    pt_SigmaTensor, pt_LambdaTensor:
    begin
      LHPen.Width:=SigTenPenWidth;
      LHPen.Color:=SigTenPenColor;
      LHSymbFillFlag:=SigTenSymbFillFlag;
      LHSymbFillFlag2:=SigTenSymbFillFlag2;
      LHSymbSize:=SigTenSymbolSize;
      LHFillBrush.Color:=SigTenSymbFillColorP;
      LHFillBrush2.Color:=SigTenSymbFillColorT;
      LHPoleflag:=false;
    end;
    pt_SigmaDihedra, pt_LambdaDihedra:
    begin
      LHPen.Width:=SigDihPenWidth;
      LHPen.Color:=SigDihPenColor;
      LHSymbFillFlag:=SigDihSymbFillFlag;
      LHSymbFillFlag2:=SigDihSymbFillFlag2;
      LHFillBrush.Color:=SigDihSymbFillColorP;
      LHFillBrush2.Color:=SigDihSymbFillColorT;
      LHPoleflag:=false;
    end;
    pt_Bingham:
    begin
      LHPen.Style:=BingPenStyle;
      LHPen.Width:=BingPenWidth;
      LHPen.Color:=BingPenColor;
      LHSymbType:=BingSymbType;
      LHSymbFillFlag:=BingSymbFillFlag;
      LHFillBrush.Color:=BingSymbFillColor;
      LHSymbSize:=BingSymbolSize;
    end;
    pt_MeanVectFisher, pt_MeanVectRC:
    begin
      LHPen.Style:=fishPenStyle;
      LHPen.Width:=fishPenWidth;
      LHPen.Color:=fishPenColor;
      With Self as TFisherForm do
      begin
        FishPen2.Style:=psSolid;
        FishPen2.Width:=FishPenWidth;
        FishPen2.Color:=FishPen2Color;
      end;
      LHSymbType:=fishSymbType;
      LHSymbFillFlag:=fishSymbFillFlag;
      LHFillBrush.Color:=fishSymbFillColor;
      LHSymbSize:=fishSymbolSize;
    end;
    pt_PTPlot:
    begin
      LHPen.Width:=PTPenWidth;
      LHPen.Color:=PTPenColor;
      LHSymbFillFlag:=ptSymbFillFlag;
      LHSymbFillFlag2:=ptSymbFillFlag2;
      LHSymbSize:=ptSymbolSize;
      LHFillBrush.Color:=PTSymbFillColorP;
      LHFillBrush2.Color:=PTSymbFillColorT;
      LHPoleflag:=false;
    end;
    pt_SortMan:
    begin
      LHPen.Style:=pssolid;
      LHPen.Width:=1;
      LHPen.Color:=clblack;
      LHSymbType:=syCircle;
      LHSymbFillFlag:=true;
      LHFillBrush.Color:=clwhite;
      LHFillBrush2.Color:=clBlue;
      LHSymbSize:=20*Radius/1000;
    end;
    pt_Rotate:
    begin
      LHPen.Style:=pssolid;
      LHPen.Width:=1;
      LHPen.Color:=clblack;
      LHSymbType:=syCircle;
      LHSymbFillFlag:=true;
      LHFillBrush.Color:=clwhite;
      LHFillBrush2.Color:=clBlue;
      LHSymbSize:=20*Radius/1000;
    end;
    pt_MohrSigma, pt_MohrLambda:
    begin
      LHPen.Style:=MohrPenStyle;
      LHPen.Width:=MohrPenWidth;
      LHPen.Color:=MohrPenColor;
      LHSymbType:=syCircle;
      LHSymbFillFlag:=MohrSymbFillFlag;
      LHFillBrush.Color:=MohrSymbFillColor;
      LHSymbSize:=MohrSymbolSize;
    end;
    pt_FluHist:
    begin
      LHPen.Style:=FluHPenStyle;
      LHPen.Width:=FluHPenWidth;
      LHPen.Color:=FluHPenColor;
      LHSymbFillFlag:=FluHSymbFillFlag;
      LHFillBrush.Color:=FluHSymbFillColor;
    end;
    pt_RoseCenter, pt_RoseCorner:
    begin
      LHPen.Style:=RosePenStyle;
      LHPen.Width:=RosePenWidth;
      LHPen.Color:=RosePenColor;
      LHSymbFillFlag:=RoseSymbFillFlag;
      LHFillBrush.Color:=RoseSymbFillColor;
    end;
    pt_Contour:
    begin
      LHPen.Style:=ContPenStyle;
      LHPen.Width:=ContPenWidth;
      LHPen.Color:=ContPenColor;
      LHSymbSize:=ContSymbolSize*Radius/1000;
    end;
    pt_Besttheta:
    begin
      LHPen.Width:=BTPenWidth;
      LHPen.Color:=BTPenColorP;
      (Self as TFluMohrFm).FMPen2.Color:=BTPenColorT;
      (Self as TFluMohrFm).FMPen2.Width:=BTPenWidth;
      LHSymbFillFlag:=BTSymbFillFlag;
      LHSymbFillFlag2:=BTSymbFillFlag2;
      LHFillBrush.Color:=BTSymbFillColorP;
      LHFillBrush2.Color:=BTSymbFillColorT;
      LHSymbSize:=BTSymbolSize;
    end;
    pt_Dihedra:
    begin
      LHSymbSize:=DihSymbolsize;
      LHSymbFillFlag:=DihSymbFillFlag;
      LHSymbFillFlag2:=DihSymbFillFlag2;
      LHFillBrush.Color:=DihSymbFillColorP;
      LHFillBrush2.Color:=DihSymbFillColorT;
      LHPen.Color:=DihPenColor;
      LHPen.Width:=DihPenWidth;
      LHPoleflag:=false;
      //LHSymbType:=SyCircle;
    end;
  end;
end;

procedure TLHWin.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  Case LHPLotType of
    pt_MohrSigma, pt_MohrLambda, pt_FluHist:
    With TecMainWin.StatusBar1.Panels do
    begin
      Items[1].Text := '';
      Items[2].Text := '';
      Items[4].Text := '';
      PaintBox1.Cursor:=crDefault;
    end;
    else with TecMainWin.StatusBar1.Panels do
    begin
      If CalculateMousePos(Sender as TPaintBox, X, Y, LHMouseAzimuth, LHMouseDip, LHPoleflag) then
      begin //mode changed with build 1.149
        If LHPoleflag then Items[1].Text := 'Azimuth/Dip - compl. Angle!'
        else Items[1].Text := 'Azimuth/Dip';
        Items[2].Text := FloatToString(LHMouseAzimuth,3,0)+'/'+FloatToString(LHMouseDip,2,0);
        If Items[3].Text<>'' then
          Items[4].Text:='Distance: '+
            FloatToString(DihedralAngle(LHMouseAzimuth, LHMouseDip, GlobStoreAzim, GlobStoreDip, true), 2, 0)+'°';
      end
      else
      begin
        Items[1].Text := '';
        Items[2].Text := '';
        Items[4].Text := '';
      end;
    end;
  end;
end;

procedure TLHWin.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button=mbLeft then
  begin
    LHStoreAzim:=GlobStoreAzim;
    LHStoreDip:=GlobStoreDip;
    if CalculateMousePos(Sender as TPaintBox, X, Y, GlobStoreAzim, GlobStoreDip, LHPoleflag) then
      TecMainWin.StatusBar1.Panels.Items[3].Text := 'Stored: '+FloatToString(GlobStoreAzim,3,0)+'/'+FloatToString(GlobStoreDip,2,0)
    else
    begin
      TecMainWin.StatusBar1.Panels.Items[3].Text := '';
      GlobStoreAzim:=0;
      GlobStoreDip:=0;
    end;
    if Copy1.Enabled then
    begin
      LHStartDr:=True;
      DragGraphicsStyle.IsValid:=False;
      Paintbox1.BeginDrag(False);
    end;
  end;
end;

procedure TLHWin.FormDeactivate(Sender: TObject);
begin
  TecMainWin.ProgressBar1.Position:=0;
end;

procedure TLHWin.FileFailed(Sender: TObject);
begin
  Screen.Cursor:=crDefault;
  LHFailed:=true;
  GlobalFailed:=True;
  If fileused then CommonError(Sender,LHFilename,ecFileUsed)
  else ReadError(Sender,LHFilename,LHz);
  //Close;  //bugfix 980707
end;

procedure TLHWin.FileFailed3(FClassName, FMessage: String; FErrorcode: Integer);
begin
  Screen.Cursor:=crDefault;
  LHFailed:=true;
  GlobalFailed:=True;
  If FClassname='EInOutError' then CommonError(Self,LHFilename,ecFileUsed)
  else If FClassname='EFileReadError' then ReadError(Self,LHFilename,FErrorcode);
  Close;
  abort;
end;

procedure TLHWin.North;
var dummy : Integer;
    colordummy: TColor;
begin
  If not LHCopyMode then with LHMetCan.Pen do
  begin
    //Draw enveloping circle
    Colordummy := Color;
    Color := LHNetColor;
    Style := psSolid;
    dummy:=width;
    Width:=NorthPenWidth;
    NorthAndCircle(LHMetCan, CenterX, CenterY, Radius);
    Width:=dummy;
    Color:= Colordummy;
  end;
end;

procedure TLHWin.NumberLabel;
begin
  if LHCreating then
  begin
    LHLabel2:='Datasets: '+IntToStr(LHz+1);
    LHCreating:=False;
  end //else loop necessary to read actual number of datasets if label has not been changed before
  else If Copy(LHLabel2, 0, 10)='Datasets: ' then LHLabel2:='Datasets: '+IntToStr(LHz+1); //Bugfix 20000118
  If Label1.Checked then
  begin
    LHMetCan.Pen.Color:=Canvas.Font.Color;
    if not LHCopyMode then with LHMetCan do
      if LHPasteMode then Windows.TextOut(Handle,labelleft,labeltop,PChar(LHLabel1), length(LHLabel1))
      else
      begin
        Windows.TextOut(Handle,labelleft,labeltop,PChar(LHLabel1), Length(LHLabel1));
        If LHPlotType<>pt_SmallCircle then Windows.TextOut(handle,labelleft,labeltop+6-LHMetCan.Font.Height,PChar(LHLabel2),length(LHLabel2));
      end;
  end;
  GlobalFailed:=False;
end;

procedure TLHWin.Options1Click(Sender: TObject);
begin
  TecMainWin.Options1Click(Application);
end;

procedure TLHWin.PaintBox1DragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if Source<>Self.PaintBox1 then
  begin
    If DragGraphicsStyle.IsValid then
      Accept:=true
    else
    If (LHPlotType<>pt_MohrSigma) and (LHPlotType<>pt_MohrLambda) and
    (LHPlotType<>pt_FluHist) and (LHPlotType<>pt_RoseCenter) and (LHPlotType<>pt_RoseCorner)
    and (LHPlotType<>pt_BestTheta) then
      If LHWriteWMF then Accept:=Clipboard.HasFormat(TFPMetafile)
      else Accept:=Clipboard.HasFormat(TFPEnhmetafile)
    else Accept:=False;
    If Accept then Self.BringToFront;
  end
  else
  begin
    Accept:=Self.Focused;
    If LHStartDr then
    begin
      Copy1Click(Sender);
      GlobStoreAzim:=LHStoreAzim;
      GlobStoreDip :=LHStoreDip;
      if (GlobStoreAzim<>0) or (GlobStoreDip<>0) then TecMainWin.StatusBar1.Panels.Items[3].Text := 'Stored: '+FloatToString(GlobStoreAzim,3,0)+'/'+FloatToString(GlobStoreDip,2,0)
      else
      begin
        TecMainWin.StatusBar1.Panels.Items[3].Text := '';
        GlobStoreAzim:=0;
        GlobStoreDip:=0;
      end;
      LHStartDr:=False;
    end;
  end;
end;

procedure TLHWin.PaintBox1DragDrop(Sender, Source: TObject; X, Y: Integer);
var valid: boolean;
begin
  If Source<>Self.Paintbox1 then
    If DragGraphicsStyle.IsValid then
    begin
      valid:=true;
      if InspectorForm<>nil then
      begin
        If Source=InspectorForm.Panel1 then LHPen.Color:=DragGraphicsStyle.DColor
        else If Source=InspectorForm.Panel2 then LHFillBrush.Color:=DragGraphicsStyle.DColor
        else If Source=InspectorForm.Panel3 then LHFillBrush2.Color:=DragGraphicsStyle.DColor
        else If Source=InspectorForm.Panel4 then
        begin
          If Self is TFluMohrFm then (Self as TFluMohrFm).FMPen2.Color:=DragGraphicsStyle.DColor
          else valid:=false;
        end
        else If Source=InspectorForm.Panel5 then LHNetColor:=DragGraphicsStyle.DColor
        else If Source=InspectorForm.Panel7 then LHBackgrBrush.Color:=DragGraphicsStyle.DColor
        else valid:=False;
      end else valid:=False;
      if valid then
      begin
        Compute(Sender);
        If not LHfailed then Paintbox1.Refresh;
        InspectorForm.Initialize(Self);
      end;
    end
    else Paste1click(Sender);
end;



procedure TLHWin.FillColor1Click(Sender: TObject);
begin
  TecMainWin.ColorDialog1.Color:=LHFillBrush.Color;
  If TecMainWin.ColorDialog1.Execute then
  begin
    LHFillBrush.Color:=TecMainWin.ColorDialog1.Color;
    Screen.Cursor:=crHourGlass;
    case LHPlotType of
      pt_PiPlot:     PiSymbfillColor:=TecMainWin.ColorDialog1.Color;
      pt_DipLine:   DipSymbFillColor:=TecMainWin.ColorDialog1.Color;
      pt_Lineation: LinSymbfillColor:=TecMainWin.ColorDialog1.Color;
      pt_Angelier:  AngSymbfillColor:=TecMainWin.ColorDialog1.Color;
      pt_Hoeppener:HoepSymbfillColor:=TecMainWin.ColorDialog1.Color;
      pt_Bingham:  BingSymbfillColor:=TecMainWin.ColorDialog1.Color;
      pt_MeanVectFisher, pt_MeanVectRC: FishSymbfillColor:=TecMainWin.ColorDialog1.Color;
    end;
    Compute(Sender);
    PaintBox1.Refresh;
  end;
end;

procedure TLHWin.PlotProperties1Click(Sender: TObject);
begin
  Screen.Cursor:=crHourGlass;
  If InspectorForm<>nil then
    InspectorForm.close
  else
  begin
    InspectorForm:=TInspectorForm.Create(application);
    InspectorForm.Initialize(self);
    InspectorForm.visible:=true;
    TecMainWin.BringToFront;
  end;
  Screen.Cursor:=crDefault;
end;

procedure TLHWin.BrushCreate(Sender: TObject);
begin
  LHFillBrush:=TBrush.Create;
  LHFillBrush2:=TBrush.Create;
  LHPenBrush:=TBrush.Create;
  LHBackgrBrush:=TBrush.Create;
  LHPen:=TPen.Create;
  {With LHPenLogBrush do
  begin                                                
    lbStyle:=BS_SOLID;
    lbColor:=clBlack;
    lbHatch:=HS_BDIAGONAL;
  end;
  HLHGeomPEN:=ExtCreatePen(PS_GEOMETRIC or PS_SOLID or PS_ENDCAP_ROUND or PS_JOIN_BEVEL,
             10,  LHPenLogBrush,  0,nil);}
  With LHPen do
  begin
    width:=1;
    color:=clblack;
    style:=pssolid;
  end;
  LHPenWidth.x:=1;
  With LHLogPen do
  begin
    lopnwidth:=LHPenWidth;
    lopncolor:=clblack;
    lopnStyle:=PS_SOLID;
  end;
  HLHPen:=CreatePenIndirect(LHLogPen);
  With LHPenBrush do
  begin
    color:=clblack;
    style:=bssolid;
  end;
  With LHFillBrush do
  begin
    color:=clwhite;
    style:=bssolid;
  end;
end;

procedure TLHWin.Angelier1Click(Sender: TObject);
begin
  (Sender as TMenuItem).Checked:= true;
  If Sender=Angelier1 then Angelier2.Checked:=Angelier1.Checked;
  If Sender=Angelier2 then Angelier1.Checked:=Angelier2.Checked;
  If Sender=Hoeppener1 then Hoeppener2.Checked:=Hoeppener1.Checked;
  If Sender=Hoeppener2 then Hoeppener1.Checked:=Hoeppener2.Checked;
  If Sender=ptaxes1 then ptaxes2.Checked:=ptaxes1.Checked;
  If Sender=ptaxes2 then ptaxes1.Checked:=ptaxes2.Checked;
  SetLHProperties(LHPlotType);
  If InspectorForm<>nil then InspectorForm.Initialize(Self);
  Caption:='Plot '+IntToStr(LHPlotNumber)+': '+Caption;
  Compute(Sender);
  if LHfailed then
  begin
    Screen.Cursor:=crDefault;
    globalfailed:=true;
    close;
    exit;
  end
  else If ResInsp<>nil then ResInsp.Initialize(Self);
  PaintBox1.Refresh;
end;


procedure TLHWin.FormClose(Sender: TObject; var Action: TCloseAction);
var n: integer;
begin
  With TecMainWin do
  begin
    SaveBtn.Enabled:=false;
    PrintBtn.Enabled:=false;
    CopyBtn.Enabled:=false;
    PasteBtn.Enabled:=false;
    UndoBtn.Enabled:=false;
  end;
  If InspectorForm<>nil then InspectorForm.Reset(Sender);
  If ResInsp<>nil then ResInsp.Reset(Sender);
  If SetForm<>nil then SetForm.Reset(Sender);
  Screen.cursor:=crdefault;
  If LHWriteWMF then
  begin
    LHMetafile.Free;
    LHUndoWMF1.Free;
    LHUndoWMF2.Free;
    LHUndoWMF3.Free;
  end else begin
    LHEnhMetafile.Free;
    LHUndoEMF1.Free;
  end;
  LHFillBrush.Free;
  LHFillBrush2.Free;
  LHPenBrush.Free;
  LHPen.Free;
  DeleteObject(HLHPen);
  For n:=1 to 3 do
    TecMainWin.StatusBar1.Panels.Items[n].Text :='';
  if TecMainWin.MDIChildCount <=1 then
    TecMainWin.Window1.Enabled := false;
  inherited;
  Action := caFree;
  self:=nil;
end;

procedure TLHWin.Scaling1Click(Sender: TObject);
begin
  If SetForm<>nil then SetForm.Close
  else
  begin
    SetForm:=TSetForm.Create(nil);
    SetForm.Initialize(Self);
    SetForm.visible:=true;
  end;
  TecmainWin.Bringtofront;
end;

procedure TLHWin.Undo1Click(Sender: TObject);
begin
  LHPlotInfo:=UndoPlotInfo1;
  IF LHWriteWMF then
  begin
    LHMetafile.Assign(LHUndoWMF1);
    If LHUndoWMF2<>nil then
    begin
      LHUndoWMF1.Assign(LHUndoWMF2);
      UndoPlotInfo1:=UndoPlotInfo2;
      If LHUndoWMF3<>nil then
      begin
        LHUndoWMF2.Assign(LHUndoWMF3);
        UndoPlotInfo2:=UndoPlotInfo3;
        LHUndoWMF3.Free;
        LHUndoWMF3:=nil;
      end
      else
      begin
        LHUndoWMF2.Free;
        LHUndoWMF2:=nil;
      end;
    end else begin
      LHUndoWMF1.Free;
      LHUndoWMF1:=nil;
    end;
  end
  else
  begin
    LHEnhMetafile.Assign(LHUndoEMF1);
    If LHUndoEMF2<>nil then
    begin
      LHUndoEMF1.Assign(LHUndoEMF2);
      UndoPlotInfo1:=UndoPlotInfo2;
      If LHUndoWMF3<>nil then
      begin
        LHUndoEMF2.Assign(LHUndoEMF3);
        UndoPlotInfo2:=UndoPlotInfo3;
        LHUndoEMF3.Free;
        LHUndoEMF3:=nil;
      end
      else
      begin
        LHUndoEMF2.Free;
        LHUndoEMF2:=nil;
      end;
    end
    else
    begin
      LHUndoEMF1.Free;
      LHUndoEMF1:=nil;
    end;
  end;
  PaintBox1.Refresh;
  Dec(LHPastedFiles);
  If LHPastedFiles<1 then
  begin
    If InspectorForm<>nil then InspectorForm.initialize(self);
    if SetForm<>nil then SetForm.initialize(self);
    plottype1.enabled:=true;
    plottype2.enabled:=true;
    number1.enabled:=true;
    label1.enabled:=true;
    changelabel1.enabled:=true;
    Fonts1.Enabled:=true;
  end;
  if resinsp<>nil then resinsp.initialize(self);
end;

procedure TLHWin.Numresults1Click(Sender: TObject);
begin
  Screen.Cursor:=crHourGlass;
  If Resinsp<>nil then
    Resinsp.close
  else
  begin
    Resinsp:=TResinsp.Create(nil);
    Resinsp.Initialize(self);
    Resinsp.visible:=true;
    TecMainWin.BringToFront;
  end;
  Screen.Cursor:=crDefault;
end;

procedure TLHWin.Rollups1Click(Sender: TObject);
begin
  Scaling1.checked:=SetForm<>nil;
  PlotProperties1.Checked:=InspectorForm<>nil;
  NumResults1.Checked:=ResInsp<>nil;
  Case LHPlotType of
    pt_SortMan, pt_Rotate:
      PlotProperties1.Enabled:=false
    else
      PlotProperties1.Enabled:=true;
  end;
end;

procedure TLHWin.FormActivate(Sender: TObject);
begin
  With TecMainWin do
  begin
    SaveBtn.Enabled:=self.saveas1.enabled and self.saveas1.visible;
    PrintBtn.Enabled:=True;
    CopyBtn.Enabled:=true;
    CutBtn.Enabled:=False;
    RedoBtn.Enabled:=false;
  end;  
  Edit1Click(Sender);
  if not LHDestroying then
  if not LHfailed then
  begin
    If InspectorForm<>nil then if InspectorForm.visible then InspectorForm.Initialize(Self);
    If ResInsp<>nil then if ResInsp.visible then ResInsp.Initialize(Self);
    If Setform<>nil then if SetForm.visible then SetForm.Initialize(Self);
    TecMainWin.BringToFront;
  end;
end;

procedure TLHWin.FormDestroy(Sender: TObject);
begin
  LHDestroying:=true;
end;

procedure TLHWin.Newdatafile1Click(Sender: TObject);
begin
  TecMainWin.NewD2ndVersion1Click(Sender);
end;

procedure TLHWin.Opendatafile1Click(Sender: TObject);
begin
  TecMainWin.OD2ndVersion1Click(Sender);
end;

procedure TLHWin.ChangeLabel1Click(Sender: TObject);
begin
  With TPrintDial.Create(Self) do
  try
    HelpBtn.HelpContext:=135;
    Caption:= 'Change plot label';
    NumEdit1.Visible:=false;
    Label2.Visible:=false;
    Label1.visible:=false;
    Edit1.Text:=LHLabel1;
    Edit2.Text:=LHLabel2;
    Edit1.Visible:=true;
    case lhPlotType of
      pt_GreatCircle, pt_piPlot, pt_DipLine, pt_Lineation, pt_Angelier, pt_Hoeppener, pt_ptPlot, pt_RoseCenter,
      pt_RoseCorner: Edit2.Visible:=true;
      else Edit2.Visible:=false;
    end;
    ShowModal;
    If ModalResult=mrOK then
    begin
      LHLabel1:=Edit1.Text;
      LHLabel2:=Edit2.Text;
      Compute(Sender);
      Paintbox1.Refresh;
      if ResInsp<>nil then ResInsp.Initialize(Self);
    end;
  finally
    release;
  end;
end;

procedure TLHWin.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  Edit1Click(Sender);
end;

procedure TLHWin.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Edit1Click(Sender);
  DragGraphicsStyle.IsValid:=False;
end;

procedure TLHWin.Help2Click(Sender: TObject);
begin
  if HelpContext<>0 then
    if HelpContext<500 then
      Application.HelpCommand(HELP_CONTEXTPOPUP,HelpContext)
    else
      Application.HelpContext(HelpContext);
end;

procedure TLHWin.AddSingleDataset(fDipDir, fDip , fAzimuth, fPlunge: Single; fSense: Integer; FPlotType: TPlot);
var MyMetafile: TMetafile;
    MyFillBrush: TBrush;
begin
  if fPlotType<>pt_void then
  begin
    MyFillBrush:=TBrush.Create;
    If LHWriteWMF then with TMetafileCanvas.Create(LHMetafile, 0) do
    begin
      try
        Draw(0,0,LHMetafile);
        //***Add single dataset to graphics image
        MyMetafile:=TMetafile.Create;
        try
          With TMetaFileCanvas.Create(MyMetafile, 0) do
          try
            SetBkMode(Handle, TRANSPARENT);
            case FPlotType of
              pt_PiPlot:
              begin
                MyFillBrush.Color:=PiSymbFillColor;
                Lineation(Handle,Canvas,CenterX,CenterY,Radius,fAzimuth,fPlunge,
                        PiSymbolSize,LHz,False,PiSymbFillFlag,PiSymbType, MyFillBrush, LHPen.Handle);
              end;
            end;
          finally
            free;
          end;
          Draw(0,0,MyMetafile);
        finally
          MyMetafile.Free;
          MyFillBrush.Free;
        end;
      finally
        Free;
      end;
      LHMetafile.Height := MetafileHeight;
      LHMetafile.Width  := MetafileWidth;
      LHMetafile.MMWidth  := MetafileMMWidth;
      LHMetafile.MMHeight := MetafileMMHeight;
      LHMetafile.Inch := MetafileInch;
    end;
    Number1.Enabled := False;
    Label1.Enabled:= False;
    Fonts1.Enabled:= False;
    ChangeLabel1.Enabled := False;
    Inc(LHPastedFiles);
    //if InspectorForm<>nil then InspectorForm.Initialize(Self);
    //if ResInsp<>nil then ResInsp.Initialize(Self);
    PaintBox1.Refresh;
    //Edit1Click(Sender);
  end;
end;

procedure TLHWin.OpenPlot1Click(Sender: TObject);
begin
  TecMainWin.OpenPlot1Click(Sender);
end;

procedure TWMFWin.FormCreate2(Sender: TObject; aFilename: String);
begin
  LHFileName:=aFileName;
  LHOnceClick:= False;
  LHPasteMode:= False;
  LHCopyMode:= False;
  LHWriteWMF:=WriteWmfGlobal;
  LHPlotType:=pt_GraphicsFromDisk;
  Print1.Enabled:=True;
  Number1.Enabled:=False;
  Label1.Enabled:=False;
  ChangeLabel1.Enabled:=False;
  Caption := 'Fry Plot - [' +ExtractFileName(LHFileName) +']';
  CreateMetafile(LHMetafile,LHEnhMetafile,LHWriteWMF);
  BMPPointCounter:=0;
  BMPRadius:=4;
  BMPCalculated:=False;
  IndexOfMidPoint:=0;
  Paintbox1.Color:=clWhite;
  If UpperCase(ExtractFileExt(LHFileName))='.WMF' then
  begin
    If LHWriteWMF then
      LHMetafile.LoadFromFile(LHFileName)
    else
      LHEnhMetafile.LoadFromFile(LHFileName);
   end else
  If UpperCase(ExtractFileExt(LHFileName))='.BMP' then
  begin
    WMFBitmap:=TBitmap.Create;
    WMFBitmap.LoadFromFile(LHFileName);
  end;
  PaintBox1.Refresh;
end;

procedure TWMFWin.PaintBox1Paint(Sender: TObject);
var PaintRec: TRect;
    fX, fY, Dummy: LongInt;
    PaintBoxRatio: Single;
    i: Integer;
begin
  If not LHfailed then with PaintBox1 do
  begin
    Screen.Cursor:=crHourglass;
    BMPBitmapRatio:=WMFBitmap.Height/WMFBitmap.Width;
    PaintBoxRatio:= Height/Width;
    If PaintBoxRatio>BMPBitmapRatio then
    begin
      Dummy:=Round(Width*BMPBitmapRatio);
      PaintBoxPaintRec := Bounds(0, (Height - Dummy) div 2, Width, Dummy);
    end
    else
    begin
      Dummy:=Round(Height/BMPBitmapRatio);
      PaintBoxPaintRec := Bounds((Width - Dummy) div 2, 0, Dummy, Height);
    end;
    Canvas.StretchDraw(PaintBoxPaintRec, WMFBitmap);
    PaintRec := Bounds((Width - min(Height,Width)) div 2,
                       (Height- min(Height,Width)) div 2,
                       min(Height,Width),
                       min(Height,Width));
    For i:=0 to BMPPointCounter-1 do
    begin
      fX:=PaintBoxPaintRec.Left+Round(BMPPoints[i].X*(PaintBoxPaintRec.Right-PaintBoxPaintRec.Left)/1000);
      fY:=PaintBoxPaintRec.Top+Round(BMPPoints[i].Y*(PaintBoxPaintRec.Right-PaintBoxPaintRec.Left)/1000);
      PaintBox1.Canvas.Ellipse(fX-BMPRadius,fY-BMPRadius, fX+BMPRadius, fY+BMPRadius);
    end;
    //If LHWriteWMF then Canvas.StretchDraw(PaintRec, LHMetafile)
      //else Canvas.StretchDraw(PaintRec, LHEnhMetafile);
    Screen.Cursor:=crDefault;
  end;
end;

procedure TWMFWin.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var fX, fY, dX, dY: LongInt;  
begin
  If (X>PaintboxPaintRec.Left) and (X<PaintboxPaintRec.Right) then
    PaintBox1.Cursor:=crCross
  else PaintBox1.Cursor:=crDefault;
  If PaintBox1.Cursor=crCross then
  begin
    TecMainWin.StatusBar1.Panels[1].Text:='X/Y';
    If BMPCalculated then
    begin
      If (ssLeft in shift) and (ssCtrl in Shift) then
      begin
        fX:=PaintBoxPaintRec.Left+Round(BMPPoints[IndexofMidpoint].X*(PaintBoxPaintRec.Right-PaintBoxPaintRec.Left)/1000);
        fY:=PaintBoxPaintRec.Top+Round(BMPPoints[IndexofMidpoint].Y*(PaintBoxPaintRec.Right-PaintBoxPaintRec.Left)/1000);
        dX:=ABS(fX-X);
        dY:=ABS(fY-Y);
        PaintBox1.Canvas.Ellipse(fX-dX, fY-dY, fX+dX, fy+dY);
        if (dx<>0) and (dy<>0) then TecMainWin.StatusBar1.Panels[4].Text:='Shape ratio of deformation ellipse: '+FloatToString(Max(dx,dy)/Min(dx,dy), 3,1);
      end
      else
      begin
        LHMouseAzimuth:=Round(1000*(X-PaintBoxPaintRec.Left)/(PaintBoxPaintRec.Right-PaintBoxPaintRec.Left));
        LHMouseDip:=Round(1000*(Y-PaintBoxPaintRec.Top)/(PaintBoxPaintRec.Right-PaintBoxPaintRec.Left));
        TecMainWin.StatusBar1.Panels[2].Text:=FloatToString(LHMouseAzimuth, 3,0)+' / '+FloatToString(LHMouseDip, 3, 0);
      end;
    end
    else
      TecMainWin.StatusBar1.Panels[2].Text:=IntToStr(X)+' / '+IntToStr(Y);
  end;
end;

procedure TWMFWin.PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var fX, fY: LongInt;
begin
  if not ((ssShift in Shift) or (ssCtrl in Shift)) then
  begin
    if (Button=mbLeft) and (PaintBox1.Cursor=crCross) then
    begin
      BMPPoints[BMPPointCounter].X:=Round(1000*(X-PaintBoxPaintRec.Left)/(PaintBoxPaintRec.Right-PaintBoxPaintRec.Left));
      BMPPoints[BMPPointCounter].Y:=Round(1000*(Y-PaintBoxPaintRec.Top)/(PaintBoxPaintRec.Right-PaintBoxPaintRec.Left));
      fX:=PaintBoxPaintRec.Left+Round(BMPPoints[BMPPointCounter].X*(PaintBoxPaintRec.Right-PaintBoxPaintRec.Left)/1000);
      fY:=PaintBoxPaintRec.Top+Round(BMPPoints[BMPPointCounter].Y*(PaintBoxPaintRec.Right-PaintBoxPaintRec.Left)/1000);
      PaintBox1.Canvas.Ellipse(fX-BMPRadius,fY-BMPRadius, fX+BMPRadius, fY+BMPRadius);
      inc(BMPPointCounter);
      TecMainWin.StatusBar1.Panels[0].Text:='Points: '+IntToStr(BMPPointCounter);
    end;
  end
  else if (Button=mbLeft) and (ssShift in Shift) then CalculateFry(Sender);
end;

procedure TWMFWin.CalculateFry(Sender: TObject);
var i, j: Integer;
    VirtualMidPoint: TPoint;
    Deviation, Deviation2, fx, fy, DifferenceX, DifferenceY: LongInt;
begin
  VirtualMidPoint.Y:=Round(1000*BMPBitmapRatio/2);
  VirtualMidPoint.X:=500;
  Deviation:=1000000000;
  IndexOfMidPoint:=0;
  For i:=0 to BMPPointCounter-1 do
  begin
    Deviation2:=(VirtualMidPoint.X-BMPPoints[i].X)*(VirtualMidPoint.X-BMPPoints[i].X)+
    (VirtualMidPoint.Y-BMPPoints[i].Y)*(VirtualMidPoint.Y-BMPPoints[i].Y);
    If Deviation2<Deviation then
    begin
      Deviation:=Deviation2;
      IndexofMidpoint:=i;
    end;
  end;
  fX:=PaintBoxPaintRec.Left+Round(BMPPoints[IndexofMidpoint].X*(PaintBoxPaintRec.Right-PaintBoxPaintRec.Left)/1000);
  fY:=PaintBoxPaintRec.Top+Round(BMPPoints[IndexofMidpoint].Y*(PaintBoxPaintRec.Right-PaintBoxPaintRec.Left)/1000);
    PaintBox1.Canvas.Ellipse(fX-5,fY-5, fX+5, fY+5);   //midpoint
  For i:=0 to BMPPointCounter do
  begin
    if i<>IndexofMidpoint then
    begin
      DifferenceX:=BMPPoints[i].X-BMPPoints[IndexofMidpoint].X;
      DifferenceY:=BMPPoints[i].y-BMPPoints[IndexofMidpoint].y;
      For j:=0 to BMPPointCounter do
      begin
        If j<>i then
        begin
          fX:=PaintBoxPaintRec.Left+Round((BMPPoints[j].X-DifferenceX)*(PaintBoxPaintRec.Right-PaintBoxPaintRec.Left)/1000);
          fY:=PaintBoxPaintRec.Top+Round((BMPPoints[j].Y-DifferenceY)*(PaintBoxPaintRec.Right-PaintBoxPaintRec.Left)/1000);
          IF (fX>PaintBoxPaintRec.Left) and (fX<PaintBoxPaintRec.Right) and (fy>PaintBoxPaintRec.Top) and (fY<PaintBoxPaintRec.bottom) then
          begin
            PaintBox1.Canvas.Ellipse(fX-2,fY-2, fX+2, fY+2);
            {New(RootPoint);
            CurrentPoint:=RootPoint;
            With CurrentPoint^ do
            begin
              fPoint.X:=fX;
              fPoint.Y:=fY;
              NextPoint:=nil;
            end;}
          end;
        end;
      end;
    end;
  end;
  BMPCalculated:=True;
end;

procedure TWMFWin.Print1Click(Sender: TObject);
var HorzPixPerInch,VertPixPerInch, PageWidth, PageHeight: Integer;
    PrtRec : TRect;
    PrintBoxRatio: Single;
    Dummy: LongInt;
begin
  Screen.Cursor := crHourglass;
  Printer.Title:='TectonicsFP - '+ExtractFileName(LHFilename);
  Printer.BeginDoc;
    Pagewidth:=GetDeviceCaps(Printer.Canvas.Handle, horzsize);
    Pageheight:=GetDeviceCaps(Printer.Canvas.Handle, vertsize);
    HorzPixPerInch:=GetDeviceCaps(Printer.Canvas.Handle, LOGPIXELSX);
    VertPixPerInch:=GetDeviceCaps(Printer.Canvas.Handle, LOGPIXELSY);


    {If PrintLowerHemiSize>= Pagewidth*4 div 5 then PrintLowerHemiSize:=PageWidth*4 div 5;
    PrtRec := Bounds(Round(HorzPixPerInch/25.4/2*(PageWidth-PrintLowerHemiSize/4*5)),
                     Round(VertPixPerInch/25.4*20),
                     Round(HorzPixPerInch/25.4/4*5*PrintLowerHemiSize),
                     Round(VertPixPerInch/25.4/4*5*PrintLowerHemiSize));
    If LHWriteWMF then Printer.Canvas.StretchDraw(PrtRec, LHMetafile)
    else Printer.Canvas.StretchDraw(PrtRec, LHEnhMetafile);}
    BMPBitmapRatio:=WMFBitmap.Height/WMFBitmap.Width;
    PrintBoxRatio:= PageHeight/PageWidth;
    If PrintBoxRatio>=BMPBitmapRatio then
    begin
      Dummy:=Round(Width*BMPBitmapRatio);
      PrtRec := Bounds(0, (PageHeight - Dummy) div 2, PageWidth,Dummy);
    end
    else
    begin
      Dummy:=Round(Height/BMPBitmapRatio);
      PrtRec := Bounds((PageWidth - Dummy) div 2, 0,Dummy,PageHeight);
    end;
    Printer.Canvas.StretchDraw(PrtRec, WMFBitmap);
  Printer.EndDoc;
  Screen.Cursor := crDefault;
end; //sub

procedure TWMFWin.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  WMFBitMap.Free;
  inherited;
end;

end.
