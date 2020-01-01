unit Tecmain;

interface

uses
  SysUtils, Windows, Classes, Graphics, Forms, Controls, Menus,
  StdCtrls, Dialogs, Buttons, Messages, ExtCtrls, Types, Edit,
  ComCtrls, ShellApi, Math, FileType, printers, Clipbrd, DdeMan;


type
  TTecMainWin = class(TForm)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    Correct1: TMenuItem;
    Convert1: TMenuItem;
    SaveAs1: TMenuItem;
    Save1: TMenuItem;
    Open1: TMenuItem;
    New1: TMenuItem;
    Draw1: TMenuItem;
    Flucthistogram1: TMenuItem;
    Mohrcircle1: TMenuItem;
    Sigma1: TMenuItem;
    Hoeppener1: TMenuItem;
    Angelier1: TMenuItem;
    N4: TMenuItem;
    Lineations1: TMenuItem;
    PiPlot1: TMenuItem;
    Greatcircles1: TMenuItem;
    Calculate1: TMenuItem;
    Dihedralangle1: TMenuItem;
    Planefromlinears1: TMenuItem;
    N6: TMenuItem;
    Binghamstatistics1: TMenuItem;
    MeanVector1: TMenuItem;
    N7: TMenuItem;
    Dihedra1: TMenuItem;
    N8: TMenuItem;
    NDA1: TMenuItem;
    Invers1: TMenuItem;
    Window1: TMenuItem;
    ArrangeIcons1: TMenuItem;
    CloseAll1: TMenuItem;
    Cascade1: TMenuItem;
    Tile1: TMenuItem;
    EditOpenDialog: TOpenDialog;
    CorSaveDialog: TSaveDialog;
    FontDialog1: TFontDialog;
    AngOpenDialog: TOpenDialog;
    GreatOpenDialog: TOpenDialog;
    CorOpenDialog: TOpenDialog;
    PTplotOpenDialog: TOpenDialog;
    PTAxes1: TMenuItem;
    PTaxesPlot: TMenuItem;
    Close1: TMenuItem;
    Sep1: TMenuItem;
    Sep2: TMenuItem;
    Print1: TMenuItem;
    PrintSetup1: TMenuItem;
    Sep3: TMenuItem;
    Edit1: TMenuItem;
    Settings1: TMenuItem;
    Options1: TMenuItem;
    LineationOpenDialog: TOpenDialog;
    NDAOpenDialog: TOpenDialog;
    MinimizeAll1: TMenuItem;
    Horizontal1: TMenuItem;
    Vertical1: TMenuItem;
    Help1: TMenuItem;
    TectonicHelp1: TMenuItem;
    About1: TMenuItem;
    EigenvectOpenDialog: TOpenDialog;
    SortManOpenDialog: TOpenDialog;
    MeanVectOpenDialog: TOpenDialog;
    FluHOpenDialog: TOpenDialog;
    RoseOpenDialog: TOpenDialog;
    Panel1: TPanel;
    StatusBar1: TStatusBar;
    RotateOpenDialog: TOpenDialog;
    ContOpenDialog: TOpenDialog;
    Virtualdip1: TMenuItem;
    OD2ndVersion1: TMenuItem;
    DihOpenDialog: TOpenDialog;
    SortManual1: TMenuItem;
    ContourPlot1: TMenuItem;
    Rosediagram1: TMenuItem;
    N5: TMenuItem;
    Rotate1: TMenuItem;
    N9: TMenuItem;
    Dihedra2: TMenuItem;
    ColorDialog1: TColorDialog;
    SmallCircles1: TMenuItem;
    Fisherstatistics1: TMenuItem;
    RandCenter1: TMenuItem;
    NewD2ndVersion1: TMenuItem;
    Editor1: TMenuItem;
    EditFontDialog: TFontDialog;
    Edit2Fontdialog: TFontDialog;
    Edit2OpenDialog: TOpenDialog;
    Rollups1: TMenuItem;
    N2: TMenuItem;
    Plotproperties1: TMenuItem;
    Scaling1: TMenuItem;
    Numresults1: TMenuItem;
    ProgressBar1: TProgressBar;
    Utilities1: TMenuItem;
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    Help2: TMenuItem;
    NewBtn: TBitBtn;
    OpenBtn: TBitBtn;
    SaveBtn: TBitBtn;
    PrintBtn: TBitBtn;
    CutBtn: TBitBtn;
    CopyBtn: TBitBtn;
    PasteBtn: TBitBtn;
    HelpBtn: TBitBtn;
    UndoBtn: TBitBtn;
    RedoBtn: TBitBtn;
    PrinterSetupDialog1: TPrinterSetupDialog;
    PrintDialog1: TPrintDialog;
    Stressaxes1: TMenuItem;
    Dihedra3: TMenuItem;
    Diplines1: TMenuItem;
    N3: TMenuItem;
    SingleDataValue1: TMenuItem;
    Plane1: TMenuItem;
    Pole1: TMenuItem;
    GreatCircle1: TMenuItem;
    Lineation1: TMenuItem;
    Faultplane1: TMenuItem;
    Angelier2: TMenuItem;
    Hoeppener2: TMenuItem;
    Openplot1: TMenuItem;
    PlotOpenDialog: TOpenDialog;
    DdeServerItem1: TDdeServerItem;
    DDEDrawAngelier: TDdeServerConv;
    StrainAnalysis1: TMenuItem;
    FryMethod1: TMenuItem;
    N10: TMenuItem;
    TectonicsFPintheWeb1: TMenuItem;
    procedure EditNewChild(Sender: TObject);
    procedure EditOpenChild(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure AngelierClick(Sender: TObject);
    procedure Cascade1Click(Sender: TObject);
    procedure CloseAll1Click(Sender: TObject);
    procedure ArrangeIcons1Click(Sender: TObject);
    procedure Correct1Click(Sender: TObject);
    procedure GreatcirclesClick(Sender: TObject);
    procedure PTaxesPlotClick(Sender: TObject);
    procedure Lineations1Click(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure NDA1Click(Sender: TObject);
    procedure TectonicHelp1Click(Sender: TObject);
    procedure UpdateItems(Sender: TObject);
    procedure MinimizeAll1Click(Sender: TObject);
    procedure Convert1Click(Sender: TObject);
    procedure Horizontal1Click(Sender: TObject);
    procedure Vertical1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Binghamstatistics1Click(Sender: TObject);
    procedure Sort1Click(Sender: TObject);
    procedure Fisherstatistics1Click(Sender: TObject);
    procedure Flucthistogram1Click(Sender: TObject);
    procedure Rosediagram1Click(Sender: TObject);
    procedure Rotate1Click(Sender: TObject);
    procedure ContourPlot1Click(Sender: TObject);
    procedure Virtualdip1Click(Sender: TObject);
    procedure OD2ndVersion1Click(Sender: TObject);
    procedure Dihedra1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ArrangeMenu(Sender : TObject);
    procedure Dihedra2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SmallCircles1Click(Sender: TObject);
    procedure NewD2ndVersion1Click(Sender: TObject);
    procedure Plotproperties1Click(Sender: TObject);
    procedure Scaling1Click(Sender: TObject);
    procedure Numresults1Click(Sender: TObject);
    procedure Rollups1Click(Sender: TObject);
    procedure Help2Click(Sender: TObject);
    procedure SaveBtnClick(Sender: TObject);
    procedure PrintBtnClick(Sender: TObject);
    procedure CutBtnClick(Sender: TObject);
    procedure CopyBtnClick(Sender: TObject);
    procedure PasteBtnClick(Sender: TObject);
    procedure UndoBtnClick(Sender: TObject);
    procedure RedoBtnClick(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure PrintSetup1Click(Sender: TObject);
    procedure Pole1Click(Sender: TObject);
    procedure Openplot1Click(Sender: TObject);
    procedure DDEDrawAngelierExecuteMacro(Sender: TObject; Msg: TStrings);
    procedure TectonicsFPintheWeb1Click(Sender: TObject);
  protected
    progressdummy,maximizing: boolean;
    procedure AppActivate(Sender: TObject);
    procedure AppDeactivate(Sender: TObject);
    procedure FormMove(var Message: TWMMove); message WM_MOVE;
    procedure SysCommand(var Message: TWMSyscommand); message WM_SYSCOMMAND;
    procedure AcceptDragFiles(var Message: TWMDropfiles); message WM_DROPFILES;
    procedure AppMessage(var Msg: TMsg; var Handled: Boolean);
    procedure ArrangeRollup(FRollup: TForm);
    procedure Initialize;
  private
    Tecmainshowhint: boolean;
    procedure ShowAppHint(Sender: TObject);
    procedure CallAngelier(Sender: TObject; AFilename: TFilename; AExtension: TExtension);
    procedure CallGreatPi(Sender: TObject; AFilename: TFilename; AExtension: TExtension);
    procedure CallptPlot(Sender: TObject; AFilename: TFilename; AExtension: TExtension);
    procedure RememberFilename(Sender: TObject; aFilename: TFilename; APlotType: TPlot);
    procedure OpenRememberedWindow(Sender: TObject);
  public
    Inspectleft,Inspecttop: Integer;
    function AppHelp(Command: Word; Data: Longint; var CallHelp: Boolean): Boolean;
    procedure CallMDIChild(Sender: TObject; Parameter: String);
    procedure ArrangeAllRollups(Sender: TObject);
    procedure ArrangeAllRollups2(Sender: TObject);
    procedure ArrangeRollups(Sender: TObject);
    procedure WriteToStatusbar(Sender: TObject; FText: String);
    procedure CloseAllRollups(Sender: TObject);
    procedure SwapRollups(Sender: TObject);
    procedure SwapRollups2(Sender: TObject);
    function  CheckExtension(Sender: TObject; FFilename: String; var FExtension: TExtension): Boolean;
  end;


TCleanStatusbar = Class(TThread)
  time: integer;
  protected
    procedure execute; override;
    procedure show;
    procedure getsystemtime;
  end;



var TecMainWin: TTecMainWin;

implementation

{$R *.DFM}
uses Angtst, About, Angle, Fileops, Ptplot,
     Piplt, Options, NDA, Invers, Convert, Sigma, Bingha,
     SortMan, Fish, Rose, RoseDlg,
     ExprtDia, Rotate,ContDlg, Contour, Virtdip, Edit2, Dihedra, Settings,
     Inspect, results;


{****************Initialisation*********************************}
procedure TTecMainWin.Initialize;
var buffer: pchar;
    customdummy: TStringList;
    maxdummy: boolean;
    i, intcchData: Integer;
begin
  //Printer assignments, to be moved into registry for version 2
  leftpagemargin:=20;
  toppagemargin:=20;
  rightpagemargin:=20;
  bottompagemargin:=20; //mm
  printfontsize:=2.5; //mm
  with TTFPRegistry.Create do
  try
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Files', False);
     SetCurrentDir(ReadString('LastworkDir', Extractfilepath(Application.Exename)+'\Samples'));
     if ReadString('LastWorkDir', ExtractFilePath(Application.Exename))=''
       then SetCurrentDir(Extractfilepath(Application.Exename)+'\Samples');
     WriteWMFGlobal:=ReadBool('WMF', true);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\MainWindow', false);
     TecMainWin.WindowState:=TWindowState(ReadInteger('WindowState',Integer(wsNormal)));
     if TecMainWin.windowstate<>wsMinimized then
       with TecMainWin do
       begin
         if windowstate=wsMaximized then  maxdummy:= true;
         Left:=ReadInteger('Left',163);
         Top:=ReadInteger('Top', 251);
         Width:=ReadInteger('Width', 680);
         Height:=ReadInteger('Height', 460);
       end;
      if maxdummy then ShowWindow(TecMainWin.handle,SW_Maximize);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Files', false);
     FileCommentSeparator:= Chr(59); //981126 fixed to semicolon
     FileListSeparator:=    Chr(ReadInteger('FileListSeparator',44));
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Printer', false);
     PrintLowerHemiSize:= ReadInteger('DiagramSize',50);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Graphics', false);
     PolySegments :=      ReadInteger('PolySegments',20);
     ClipbLowerHemiSize:= ReadInteger('DiagramSize',100);
     GlobalNetColor:= ReadInteger('GlobalNetColor',clBlack);
     GlobalBackColor:= ReadInteger('GlobalBackColor',clWhite);
     GlobalLHBackOn:=ReadBool('GlobalLHBackOn', false);
   CloseKey;
   MetafileMMWidth:= ClipbLowerHemiSize*500 div 4;
   MetafileMMHeight:= MetafileMMWidth;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Editor', false);
     TecMainWin.EditOpenDialog.FilterIndex:=ReadInteger('LastFileType',1);
     TecMainWin.Edit2OpenDialog.FilterIndex:=ReadInteger('E2LastFileType',1);
     E2LastFileType2:=ReadInteger('E2LastFileType2',1);
     E2LastParentFileType:=ReadInteger('E2LastParentFileType',1);
     E2BeepOn:=ReadBool('E2BeepOn',true);
     E2AutoFill:=ReadBool('E2AutoFill',true);
     E2LastLocInfo:=ReadString('E2LastLocInfo','');
     E2TakeLastLocInfo:=ReadBool('E2TakeLastLocInfo',false);
     With TecMainWin.Edit2Fontdialog.font do
     begin
       Name:=  ReadString('E2FontName','MS Sans Serif');
       Height:=ReadInteger('E2FontHeight',50);
       Size:=  ReadInteger('E2FontSize',8);
       Color:= ReadInteger('E2FontColor',clBlack);
       //Style:=TFontStyle(ReadInteger('E2FontStyle', ShortInt(fsNormal)));
     end;
     With TecMainWin.EditFontdialog.Font do
     begin
       Name:=  ReadString('FontName','System');  //to be removed
       Height:=ReadInteger('FontHeight',50);
       Size:=  ReadInteger('FontSize',10);
       Color:= ReadInteger('FontColor',clBlack);
       //Style:=TFontStyle(ReadInteger('FontStyle', ShortInt(fsNormal)));
     end;
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\SortMan', False);
     TecMainWin.SortmanOpenDialog.FilterIndex:=ReadInteger('LastFileType',0);
     SortFPLPlotType:=ReadInteger('SortFPLPlotType',0);
     SortPTFPlotType:=ReadInteger('SortPTFPlotType',2);
     SortPLNPlotType:=ReadInteger('SortPLNPlotType',0);
     SortLastOutputPath:=ReadString('SortOutPath', '');
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\GreatCircle', false);
     GreatPenWidth:=ReadInteger('GreatPenWidth',1);
     GreatPenColor:=ReadInteger('GreatPenColor',clBlack);
     GreatPenStyle:=TPenStyle(ReadInteger('GreatPenStyle',Longint(psSolid)));
     GreatLastFiletype:=ReadInteger('LastFileType',0);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\SmallCircle', false);
     SmallPenWidth:=ReadInteger('SmallPenWidth',1);
     SmallPenColor:=ReadInteger('SmallPenColor',clBlack);
     SmallPenStyle:=TPenStyle(ReadInteger('SmallPenStyle',Longint(psSolid)));
     SmallSymbfillFlag:=ReadBool('SmallSymbfill',true);
     SmallSymbFillColor:=ReadInteger('SmallSymbFillColor',clWhite);
     SmallSymbolSize:=Radius*ReadInteger('SmallSymbolSize',25)/1000;
     SmallSymbType:=TPlotSymbol(ReadInteger('SmallSymbType',Longint(syStar)));
     SmallAperture:=ReadInteger('SmallAperture',0);
     SmallAzimuth:=ReadInteger('SmallAzimuth',0);
     SmallPlunge:=ReadInteger('SmallPlunge',0);
     SmallComment:=ReadString('Smallcomment','');
     SmallPolySegments:=ReadInteger('SmallPolySegments',50);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\PiPlot', false);
     PiSymbfillFlag:=ReadBool('PiSymbfill',true);
     PiSymbFillColor:=ReadInteger('PiSymbFillColor',clWhite);
     PiPenColor:=ReadInteger('PiPenColor',clBlack);
     PiPenWidth:=ReadInteger('PiPenWidth',1);
     PiSymbolSize:=Radius*ReadInteger('PiSymbolSize',25)/1000;
     PiSymbType:=TPlotSymbol(ReadInteger('PiSymbType',Longint(syCross)));
     PiLastFileType:=ReadInteger('LastFileType',0);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\DipLine', False);
     DipSymbfillFlag:=ReadBool('DipSymbfill',true);
     DipSymbFillColor:=ReadInteger('DipSymbFillColor',clWhite);
     DipPenColor:=ReadInteger('DipPenColor',clBlack);
     DipPenWidth:=ReadInteger('DipPenWidth',1);
     DipSymbolSize:=Radius*ReadInteger('DipSymbolSize',25)/1000;
     DipSymbType:=TPlotSymbol(ReadInteger('DipSymbType',Longint(syRhombohedron)));
     DipLastFileType:=ReadInteger('LastFileType',0);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Lineation', false);
     LinSymbfillFlag:=ReadBool('LinSymbfill',true);
     LinSymbFillColor:=ReadInteger('LinSymbFillColor',clWhite);
     LinPenColor:=ReadInteger('LinPenColor',clBlack);
     LinPenWidth:=ReadInteger('LinPenWidth',1);
     LinSymbolSize:=Radius*ReadInteger('LinSymbolSize',25)/1000;
     LinSymbType:=TPlotSymbol(ReadInteger('LinSymbType',Longint(syStar)));
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Angelier', false);
     AngSymbolSize:=       Radius*ReadInteger('AngSymbRadius',20)/1000;
     AngSSArrowLength:=    Radius*ReadInteger('AngSSArrowLength',120)/1000;
     AngSSArrowHeadLength:=Radius*ReadInteger('AngSSArrowHeadLength',70)/1000;
     DegAngSSArrowAngle:=DegToRad(ReadInteger('AngSSArrowAngle',20));
     DegAngNRArrowAngle:=DegToRad(ReadInteger('AngNRArrowAngle',12));
     AngNRArrowLength:=    Radius*ReadInteger('AngNRArrowLength',200)/1000;
     AngNRArrowheadLength:=Radius*ReadInteger('AngNRArrowHeadLength',70)/1000;
     angsymbfillflag:=                ReadBool('angsymbfill',true);
     AngSymbFillColor:=           ReadInteger('AngSymbFillColor',clWhite);
     AngPenColor:=                ReadInteger('AngPenColor',clBlack);
     AngPenStyle:=       TPenStyle(ReadInteger('AngPenStyle',Longint(psSolid)));
     AngPenWidth:=                ReadInteger('AngPenWidth',1);
     AngLastFiletype:=             ReadInteger('LastFileType',0);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Hoeppener', false);
     HoepSymbfillFlag:=              ReadBool('HoepSymbfill',true);
     HoepSymbFillColor:=         ReadInteger('HoepSymbFillColor',clWhite);
     HoepPenColor:=              ReadInteger('HoepPenColor',clBlack);
     HoepPenWidth:=              ReadInteger('HoepPenWidth',1);
     HoepSymbRadius:=     Radius*ReadInteger('HoepSymbRadius',20)/1000;
     DegHoepArrowAngle:=DegToRad(ReadInteger('HoepArrowAngle',12));
     HoepArrowLength:=    Radius*ReadInteger('HoepArrowLength',200)/1000;
     HoepArrowheadLength:=Radius*ReadInteger('HoepArrowheadLength',70)/1000;
     HoepLastFiletype:=           ReadInteger('LastFileType',0);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\ptPlot', false);
     ptSymbFillFlag:=ReadBool('ptSymbFill',true);
     ptSymbFillFlag2:=ReadBool('ptSymbFill2',true);
     PTPenColor:=ReadInteger('PTPenColor',clBlack);
     PTPenWidth:=ReadInteger('PTPenWidth',1);
     PtSymbolSize:=Radius*ReadInteger('PtSymbolSize',25)/1000;
     PTSymbFillColorP:=ReadInteger('PTSymbFillColorP',clRed);
     PTSymbFillColorT:=ReadInteger('PTSymbFillColorT',clBlue);
     TecMainWin.PtPlotOpenDialog.FilterIndex:=ReadInteger('LastFileType',0);
     ptCalcMeanVect:=ReadBool('ptCalcMeanVect',true);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Sigma123', false);
     SigTenSymbFillFlag:=ReadBool('SigTenSymbFill',true);
     SigTenSymbfillflag2:=ReadBool('SigTenSymbFill2',true);
     SigTenPenColor:=ReadInteger('SigTenPenColor',clBlack);
     SigTenPenWidth:=ReadInteger('SigTenPenWidth',1);
     SigTenSymbolSize:=Radius*ReadInteger('SigTenSymbolSize',25)/1000;
     SigTenSymbFillColorP:=ReadInteger('SigTenSymbFillColorP',clRed);
     SigTenSymbFillColorT:=ReadInteger('SigTenSymbFillColorT',clBlue);
     SigmaLastfiletype:=ReadInteger('LastFileType',0);
     SigmaDihedraOn:=Readbool('SigmaDihedraOn',true);

     SigDihSymbFillFlag:=ReadBool('SigDihSymbFill',true);
     SigDihSymbFillFlag2:=ReadBool('SigDihSymbFill2',false);
     SigDihPenColor:=ReadInteger('SigDihPenColor',clBlack);
     SigDihPenWidth:=ReadInteger('SigDihPenWidth',1);
     SigDihSymbFillColorP:=ReadInteger('SigDihSymbFillColorP',8421504);
     SigDihSymbFillColorT:=ReadInteger('SigDihSymbFillColorT',clnone);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Mohr', false);
     MohrSymbFillColor:=ReadInteger('MohrSymbFillColor',clWhite);
     MohrPenColor:=ReadInteger('MohrPenColor',clBlack);
     MohrPenStyle:=TPenStyle(ReadInteger('MohrPenStyle',Longint(psSolid)));
     MohrPenWidth:=ReadInteger('MohrPenWidth',1);
     MohrSymbFillFlag:=ReadBool('MohrSymbFill',true);
     MohrSymbolSize:=Radius*ReadInteger('MohrSymbolSize',25)/1000;
     MohrLastfiletype:=ReadInteger('LastFileType',0);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\FluctHist', false);
     FluHLastfiletype:=ReadInteger('LastFileType',0);
     FluHPenStyle:=TPenStyle(ReadInteger('FluHPenStyle',Longint(psSolid)));
     FluHPenWidth:= ReadInteger('FluHPenWidth',1);
     FluHPenColor:= ReadInteger('FluHPenColor',clBlack);
     FluHSymbFillFlag:= ReadBool('FluHSymbFill',true);
     FluHSymbFillColor:= ReadInteger('FluHSymbFillColor',clRed);
     FluHIntervals:=ReadInteger('FluHIntervals', 10);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Rotate', false);
     RotFPLPlotType:=ReadInteger('RotFPLPlotType',0);
     RotPLNPlotType:=ReadInteger('RotPLNPlotType',0);
     LastRotAngle:=ReadInteger('LastRotAngle',0);
     LastRotAxAzim:=ReadInteger('LastRotAxAzim',0);
     LastRotAxPlunge:=ReadInteger('LastRotAxPlunge',0);
     TecMainWin.RotateOpenDialog.FilterIndex:=ReadInteger('LastFileType',0);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Fisher', false);
     FishSymbType:=TPlotSymbol(ReadInteger('FishSymbType',Longint(syStar)));
     FishSymbFillColor:=ReadInteger('FishSymbFillColor',clWhite);
     FishPenColor:=ReadInteger('FishPenColor',clBlack);
     FishPen2Color:=ReadInteger('FishPen2Color',clBlack);
     FishPenStyle:=TPenStyle(ReadInteger('FishPenStyle',Longint(psSolid)));
     FishPenWidth:=ReadInteger('FishPenWidth',1);
     FishSymbFillFlag:=ReadBool('FishSymbfill',true);
     FishSymbolSize:=Radius*ReadInteger('FishSymbolSize',25)/1000;
     FishLastConf:=ReadInteger('FishLastConf',95);
     FishShowConfCone:=ReadBool('FishShowConfCone', True);
     FishShowSpherDistr:=ReadBool('FishShowSpherDistr', True);
     TecMainWin.MeanVectOpenDialog.FilterIndex:=ReadInteger('LastFileType',0);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Bingham', false);
     BingSymbType:=TPlotSymbol(ReadInteger('BingSymbType',Longint(syTriangle)));
     BingSymbFillColor:=ReadInteger('BingSymbFillColor',clWhite);
     BingPenColor:=ReadInteger('BingPenColor',clBlack);
     BingPenStyle:=TPenStyle(ReadInteger('BingPenStyle',Longint(psSolid)));
     BingPenWidth:=ReadInteger('BingPenWidth',1);
     BingSymbFillFlag:=ReadBool('BingSymbfill',true);
     BingSymbolSize:=Radius*ReadInteger('BingSymbolSize',25)/1000;
     TecMainWin.EigenvectOpenDialog.FilterIndex:=ReadInteger('LastFileType',0);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Rose', False);
     RosePenStyle:=TPenStyle(ReadInteger('RosePenStyle',Longint(psSolid)));
     RosePenWidth:= ReadInteger('RosePenWidth',1);
     RosePenColor:= ReadInteger('RosePenColor',clBlack);
     RoseSymbFillFlag:= ReadBool('RoseSymbFill', True);
     RoseSymbFillColor:= ReadInteger('RoseSymbFillColor',clRed);
     RoseCenter:=    ReadBool('RoseCenter', False);
     RoseDipAlso:=   ReadBool('RoseDipAlso', True);
     RosePLBipol:=   ReadBool('RosePLBipol', True);
     RoseAziBipol:=  ReadBool('RoseAziBipol', False);
     RoseFPlane:=    ReadBool('RoseFPlane', True);
     RosePTUse:=  ReadInteger('RosePTUse', 0);
     RoseAziInt:= ReadInteger('RoseAziInt',20);
     RoseDipInt:= ReadInteger('RoseDipInt',10);
     TecMainWin.RoseOpenDialog.FilterIndex:=ReadInteger('LastFileType',0);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Contour', false);
     ContAutoInt:=ReadBool('ContAutoInt', True);
     ContGauss:= ReadBool('ContGauss', True);
     ContFPlane:= ReadBool('ContFPlane', True);
     ContPTUse:=ReadInteger('ContPTUse', 0);
     ContGridD:=ReadInteger('ContGridD', 2);
     ContPenStyle:=TPenStyle(ReadInteger('ContPenStyle',Longint(psSolid)));
     ContPenWidth:= ReadInteger('ContPenWidth',1);
     ContPenColor:= ReadInteger('ContPenColor',clBlack);
     ContSymbolSize:=ReadInteger('ContSymbolSize',0);
     ContShowNet:=ReadBool('ContShowNet', False);
     For i:=1 to 16 do ContValues[i]:=ReadFloat('ContValue'+IntToStr(i),0);
     TecMainWin.ContOpenDialog.FilterIndex:=ReadInteger('LastFileType',0);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Calcpt', false);
     ptTheta:=            ReadInteger('ptTheta',30);
     ptBestTheta:=          ReadBool('ptBestTheta',false);
     BT_Increment:=       ReadInteger('BT_Increment',2);
     BTSymbFillColorP:=   ReadInteger('btSymbFillColorP',clRed);
     BTSymbFillColorT:=   ReadInteger('btSymbFillColorT',clBlue);
     BTPenColorP:=        ReadInteger('btPenColorP',clBlack);
     BTPenColorT:=        ReadInteger('btPenColorT',clBlack);
     btPenWidth:=         ReadInteger('btPenWidth',1);
     btSymbFillFlag:=     ReadBool('btSymbFill',true);
     btSymbFillFlag2:=    ReadBool('btSymbFill2',true);
     btSymbolSize:=Radius*ReadInteger('btSymbolSize',15)/1000;
     btLastfiletype:=      ReadInteger('LastFileType',0);
     BT_Increment:=        ReadInteger('BT_Increment',2);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Invers', false);
     INVLastfiletype:=ReadInteger('LastFileType',0);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\NDA', false);
     NDATheta:=ReadInteger('NDATheta',30);
     NDALastfiletype:=ReadInteger('LastFileType',0);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Dihedra', false);
     DihSymbolSize:=Radius*ReadInteger('DihSymbolsize',25)/1000;
     DihSymbFillColorP:=ReadInteger('DihSymbFillColorP',clRed);
     DihSymbFillColorT:=ReadInteger('DihSymbFillColorT',clBlue);
     DihPenColor:=ReadInteger('DihPenColor',clBlack);
     //DihPenStyle:=TPenStyle(ReadInteger('DihPenStyle',Longint(psSolid)));
     DihPenWidth:=ReadInteger('DihPenWidth',1);
     DihSymbFillFlag:=ReadBool('DihSymbFill',true);
     DihSymbFillFlag2:=ReadBool('DihSymbFill2',true);
     TecMainWin.DihOpenDialog.FilterIndex:=ReadInteger('LastFileType',0);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Quality', false);
     QualityGlobal:=       ReadBool('UseQuality', true);
     GlobalArrowStyle:= ReadInteger('ArrowStyle', 0);
     QualitylevelsUsed:=ReadInteger('UseLevels', 2);
     CorrError:=ReadInteger('CorrError', 10);
   CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\LowHem', false);
     NorthPenWidth:= ReadInteger('NorthPenWidth',2);
     AxesPenWidth:=  ReadInteger('AxesPenWidth',1);
     GlobalLHNumbering:= ReadBool('GlobalLHNumbering',true);
     GlobalLHLabel:=     ReadBool('GlobalLHLabel',true);
     ExportLastFileType:= ReadInteger('ExportLastFileType',1);
     With TecMainWin.Fontdialog1.font do
     begin
       name:=ReadString('FontName','Arial');
       height:=ReadInteger('FontHeight',50);
       Size:=ReadInteger('FontSize',11);
       Color:=ReadInteger('FontColor',clBlack);
     end;
   CloseKey;
   //Customdummy:=TStringList.Create;
   //OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\CustomColors', false);
   {For i:=0 to 15 do
   begin
     colordummy:=ReadString('Color'+Chr(65+i), 'XXXXX');
     If (colordummy<>'XXXXX') and (colordummy<>'') and (colordummy<>'FFFFFFFF') then
     Customdummy.add('Color'+Chr(65+i)+'='+colordummy);
   end;}
   //TecMainWin.Colordialog1.CustomColors.add('ColorA=808022');
   //TecMainWin.Colordialog1.CustomColors.Values['ColorA']:='808022';
   //Customdummy.Values['ColorA']:=inttostr(clwhite);
   //TecMainWin.ColorDialog1.CustomColors:=Customdummy;
   //Customdummy.Free;
   //CloseKey;
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Options', false);
     LastOptPage:=ReadInteger('LastPage',0);
   CloseKey;

   //****************     Rollups    ********************************
   OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Rollups', false);
     PlotPropWidth:=ReadInteger('PlotPropWidth', 114);
     PlotPropLeft:=ReadInteger('PlotPropLeft', TecMainWin.Left+TecMainWin.Width-PlotPropWidth);
     PlotPropTop:=ReadInteger('PlotPropTop',TecMainWin.Top +TecMainWin.Height-TecMainWin.ClientHeight-1+Panel2.Height);
     If ReadBool('PlotProperties',false) then
     begin
       Inspectorform:=TInspectorForm.Create(nil);
       With Inspectorform do
       begin
         If ReadBool('PlotPropMinimized', false) then Minimize1Click2(nil);
         aligned:= ReadBool('PlotPropAligned',false);
         Initialize(nil);
         visible:=true;
       end;
     end;

     SetFormWidth:=ReadInteger('SetFormWidth', 114);
     SetFormLeft:=ReadInteger('SetFormLeft', TecMainWin.Left+TecMainWin.Width-SetFormWidth);
     SetFormTop:=ReadInteger('SetFormTop',TecMainWin.Top +TecMainWin.Height-TecMainWin.ClientHeight-1+Panel2.Height);
     If ReadBool('Scaling',false) then
     begin
       SetForm:=TSetForm.Create(nil);
       With SetForm do
       begin
         If ReadBool('SetFormMinimized', false) then Minimize1Click2(nil);
         aligned:=ReadBool('SetFormAligned',false);
         Initialize(nil);
         visible:=true;
       end;
     end;

     ResInspWidth:=ReadInteger('ResInspWidth', 150);
     ResInspHeight:=ReadInteger('ResInspHeight', 200);
     ResInspMinimized:=ReadBool('ResInspMinimized', false);
     ResInspLeft:=ReadInteger('ResInspLeft', TecMainWin.Left+TecMainWin.Width+Panel2.Height-ResInspWidth);
     ResInspTop:=ReadInteger('ResInspTop',TecMainWin.Top +TecMainWin.Height-TecMainWin.ClientHeight-1+Panel2.Height);
     ResInspAligned:=ReadBool('ResInspAligned',false);

     If ReadBool('ResInsp',false) then
     begin
       ResInsp:=TResInsp.Create(nil);
       With ResInsp do
       begin
         If ResInspMinimized then Minimize1Click2(nil);
         Initialize(nil);
         visible:=true;
       end;
     end;
     ResInspShowLocation:=ReadBool('ResInspShowLocation', false);
     ResInspShowX:=ReadBool('ResInspShowX', false);
     ResInspShowY:=ReadBool('ResInspShowY', false);
     ResInspShowZ:=ReadBool('ResInspShowZ', false);
     ResInspShowDate:=ReadBool('ResInspShowDate', false);
     ResInspShowLithology:=ReadBool('ResInspShowLithology', false);
     ResInspShowFormation:=ReadBool('ResInspShowFormation', false);
     ResInspShowAge:=ReadBool('ResInspShowAge', false);
     ResInspShowTectUnit:=ReadBool('ResInspShowTectUnit', false);
     ResInspShowRemarks:=ReadBool('ResInspShowRemarks', false);
    CloseKey;
  finally
    Free;
  end;
  //bugfix nt4 server 010525 begin
  intcchData:=GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SLIST, buffer, 0); //retrieve buffer size
  GetMem(buffer,intcchData);
  try
    if GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SLIST, buffer, Length(buffer)) = 0 then tfpListSeparator:=';'
    else tfpListSeparator:=buffer[0]; //if function fails, assign default value for english operating system
    if tfpListSeparator = #0 then tfpListSeparator := ';';  //bugfix 080313
  finally
    FreeMem(buffer,intcchData);
  end;
  intcchData:=GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SDECIMAL, buffer, 0); //retrieve buffer size
  GetMem(buffer,intcchData);
  try
    if GetLocaleInfo(LOCALE_USER_DEFAULT, LOCALE_SDECIMAL, buffer, Length(buffer)) = 0 then tfpDecimalSeparator:='.'
    else tfpDecimalSeparator:=buffer[0]; //if function fails, assign default value for english operating system
  finally
    FreeMem(buffer,intcchData);
  end;
  // variable tfpDecimalSeparator not used in program 080313
  // error: this value is taken from the windows 32 bit settings
  // delphi predefined variable decimalseparator is taken from windows 16 bit settings
  //bugfix nt4 server 010525 end
end;
{****************************************************************}
procedure TTecMainWin.CallMDIChild(Sender: TObject; Parameter: String);
begin
  Case ExtractExtension(Parameter) of
    cor: CallAngelier(Angelier1, Parameter, COR);
    fpl: CallAngelier(Angelier1, Parameter, FPL);
    pln: CallGreatPi(GreatCircles1, Parameter, PLN);
    lin: CallGreatPi(Lineations1, Parameter, LIN);
    ptf: CallptPlot(PTaxesPlot, Parameter, PTF);
    else Exit;
  end;
  if Sender is TApplication then SetCurrentDir(ExtractFilePath(Parameter)); //Bugfix 20000410 to change dir for dropped files
end;

procedure TTecMainWin.FormCreate(Sender: TObject);
begin
  DragAcceptFiles(Handle, True);  //Register for accepting dragged files from windows explorer
  if (Licensee='Peter Acs') or (Licensee='Administrator') or (Licensee='Franz Reiter') then
  begin
    Dihedra2.visible:=true;
    Dihedra2.enabled:=true;
  end;
  TecMainShowHint:=True;
  GlobStoreAzim:=0;
  GlobStoreDip:=0;
  //if not FreeVersion then Application.HintColor:=TColor($ceffff);
  ArrowHeadLength:=Round(Radius*LinearCircleRate);{=Radius*LinearCircleRate}
  ArrowLength1:=Radius*LengthRate1;               {=Radius*LengthRate1}
  ArrowLength2:=Radius*LengthRate2;               {=Radius*LengthRate2}
  Sqrt2:=Sqrt(2);
  ContObjInspectIsOpen:=false;
  UntitledCounter:=0;
  GlobalLHPlots:=0;
  GlobalRollupsOpen:=0;
  DragGraphicsStyle.IsValid:=False;
  Initialize;
  GlobalFailed:=False;
  EditSaveFilterIndexStore:=1;
  Application.OnHint := ShowAppHint;
  Application.OnHelp:=AppHelp;
  Application.OnDeactivate:=AppDeactivate;
  Application.OnActivate:=AppActivate;
  Application.HelpFile := ExtractFilepath(Application.Exename)+'Help\Tectfp32.hlp';
  Screen.OnActiveFormChange := UpdateItems;
  tecmainleft:=TecMainWin.left;
  tecmaintop:=TecMainWin.top;
  TFPMetafile:=RegisterClipboardformat(PChar('TFP1-WMF'));
  TFPEnhMetafile:=RegisterClipboardformat(PChar('TFP1-EMF'));
  TFPtext:=Registerclipboardformat(PChar('TFP1-TEXT'));
  Application.OnMessage:=AppMessage;
end;

procedure TTecMainWin.AppMessage(var Msg: TMsg; var Handled: Boolean);
var MyFileName, dummy: String;
    i: Integer;
begin
  If Msg.Message=TFPOpenMessage then
  begin
    with TTFPRegistry.create do
    try  //read filename from windows registry
      RootKey:=HKEY_LOCAL_MACHINE;
      OpenKey('SOFTWARE\GeoCompute\TectonicsFP\'+TFPRegEntryVersion, True);
        MyFileName:=ReadString('OpenFile', '');
      CloseKey;
    finally
      Free;
    end;
    For i:=1 to Msg.wParam do
    begin
      dummy:=Copy(MyFileName, 0, Pos('*', MyFileName)-1);
      Delete(MyFileName, 1, Pos('*', MyFileName));
      If dummy<>'' then CallMDIChild(Application, dummy);
    end;
    Application.Restore;
    SetForegroundWindow(Handle);
    Handled:=True;
  end;
  inherited;
end;

procedure TTecMainWin.ShowAppHint(Sender: TObject);
begin
  PrintBtn.Hint:='Print to '+Printer.Printers[Printer.PrinterIndex]+'| ';
  if TecmainShowHint and (Application.Hint<>' ') then
  With Statusbar1 do
  begin
    SimpleText := Application.Hint;
    If SimpleText <> '' then
    begin
      progressdummy:=progressbar1.visible;
      Progressbar1.visible:=false;
      SimplePanel:=true;
    end
    else
    begin
      Progressbar1.visible:=progressdummy;
      simplepanel:=false;
    end;
  end;
end;

procedure TTecMainWin.WriteToStatusbar(Sender: TObject; FText: String);
begin
  With Statusbar1 do
  begin
    SimpleText := FText;
    SimplePanel:=true;
  end;
  With TCleanStatusbar.Create(False) do
    priority:=tpIdle;
end;

procedure TCleanStatusbar.execute;
var timedummy: Integer;
begin
  TecMainWin.tecmainshowhint:=false;
  synchronize(GetSystemTime);
  timedummy:=time;
  while True and (Time<TimeDummy+5) do
    Synchronize(GetSystemTime);
  Synchronize(Show);
  TecMainWin.TecMainShowHint:=true;
end;

procedure TCleanStatusbar.GetSystemTime;
begin
  time:=GetTickCount div 1000;
end;


procedure TCleanStatusbar.show;
begin
  with TecMainWin.Statusbar1 do
  begin
    Simpletext:='';
    SimplePanel:=false;
  end;
end;

procedure TTecMainWin.Exit1Click(Sender: TObject);
begin
  close;
end;

procedure TTecMainWin.EditNewChild(Sender: TObject);
begin
  inc(UntitledCounter);
  With TEditForm.Create(Application) do
    Open('Untitled', true);
end;

procedure TTecMainWin.NewD2ndVersion1Click(Sender: TObject);
var NewExt, FParentFileName: string;
    FExtension: TExtension;
begin
  with TFileTypeDlg.Create(Application) do
  try
    NewExt:='';
    Caption:='Select file type';
    RadioGroup1.ItemIndex:=E2LastFileType2;
    Edit1.Text:=E2LastLocInfo;  
    CheckBox1.Checked:=E2TakeLastLocInfo;
    ParentFileDlg.FilterIndex:=E2LastParentFileType;
    Showmodal;
    If modalresult = mrOK then
    begin
      If CheckBox1.Checked then FParentFilename:=Edit1.Text
      else FParentFilename:='';
      E2LastParentFileType:=ParentFileDlg.FilterIndex;
      E2TakeLastLocInfo:=CheckBox1.Checked;
      case RadioGroup1.ItemIndex of
        0: begin
          NewExt:='.fpl';
          FExtension:=fpl;
        end;
        1: begin
          NewExt:='.pln';
          FExtension:=pln;
        end;
        2: begin
          NewExt:='.lin';
          FExtension:=lin;
        end;
        3: begin
          NewExt:='.azi';
          FExtension:=azi;
        end;
      end;
      E2LastFileType2:=RadioGroup1.ItemIndex;
      E2LastLocInfo:= Edit1.Text;
    end;
  finally
    release;
  end;
  if NewExt<>'' then
  with TEdit2Frm.Create(Application) do
  begin
    inc(UntitledCounter);
    Open(Sender, 'untitled'+inttoStr(UntitledCounter)+NewExt, FParentFileName, FExtension, true, false);
  end;
end;

procedure TTecMainWin.EditOpenChild(Sender: TObject);
var i: Integer;
begin
  EditOpenDialog.InitialDir:=GetCurrentDir; //Bugfix 20000408  (Win2000)
  if EditOpenDialog.Execute then
    For i:=0 to EditOpenDialog.Files.Count-1 do with TEditForm.Create(Application) do
    begin
      Open(EditOpenDialog.Files[i], not FileExists(EditOpenDialog.Files[i]));
      EditOpenDialog.Filename:='';
      EditOpenDialog.InitialDir:=GetCurrentDir; //Bugfix 20000408
    end;
end;

procedure TTecMainWin.OD2ndVersion1Click(Sender: TObject);
var FExtension: TExtension;
    i: Integer;
begin
  Edit2OpenDialog.InitialDir:=GetCurrentDir; //Bugfix 20000408 (Win2000)
  if not Edit2OpenDialog.Execute then Exit;
  For i:=0 to Edit2OpenDialog.Files.Count-1 do
    If CheckExtension(OD2ndVersion1, Edit2OpenDialog.Files[i], FExtension) then with TEdit2Frm.Create(Application) do
      Open(Sender, Edit2OpenDialog.Files[i],'', FExtension, not FileExists(Edit2OpenDialog.Files[i]), ofReadOnly in Edit2OpenDialog.Options);
  Edit2OpenDialog.Filename:='';
  Edit2OpenDialog.InitialDir:=GetCurrentDir; //Bugfix 20000408
end;

procedure TTecMainWin.AngelierClick(Sender: TObject);
var FExtension: TExtension;
    i: integer;
begin
  with AngOpenDialog do
  begin
    InitialDir:=GetCurrentDir; //Bugfix 20000408
    If Sender=Hoeppener1 then
    begin
      Title:='Draw Hoeppener-plot';
      FilterIndex:=HoepLastFiletype;
    end
    else If Sender=Angelier1 then
    begin
      Title:='Draw Angelier-plot';
      FilterIndex:=AngLastFiletype;
    end;
    if Execute then
    begin
      If Sender=Hoeppener1 then HoepLastFiletype:=FilterIndex
      else If Sender=Angelier1 then AngLastFiletype:=FilterIndex;
      For i:=0 to Files.Count-1 do
        If CheckExtension(Sender, Files[i], FExtension) then
          CallAngelier(Sender,Files[i], FExtension);
      FileName:='';
      InitialDir:=GetCurrentDir; //Bugfix 20000408
    end;
  end;

end;


procedure TTecMainWin.CallAngelier(Sender: TObject; AFilename: TFilename; AExtension: TExtension);
begin
  with TAngtstWin.Create(Application) do
  begin
    If Sender= TecMainWin.Angelier1 then
      Caption := 'Angelier-plot - [' +ExtractFileName(AFilename) +']'
    else
      Caption := 'Hoeppener-plot - [' +ExtractFileName(AFilename) +']';
    FormCreate(Sender,AFilename, AExtension);
  end;
  //RememberFilename(Sender,AFilename, pt_Angelier);
end;

procedure TTecMainWin.OpenRememberedWindow(Sender: TObject);
var Fred: String;
begin
  {Fred:=(Sender as TMenuItem).Caption;
  if pos('Angelier',Fred)<>0 then
    MessageBeep(0);}
end;

procedure TTecMainWin.RememberFilename(Sender: TObject; AFilename: TFilename; aPlotType: TPlot);
var MyMenuItem: TMenuItem;
    Franz: Integer;
begin
  {MyMenuItem:=TMenuItem.Create(File1);
  Case aPlotType of
    pt_Angelier: MyMenuItem.Caption:='Angelier-Plot: ';
  end;
  MyMenuItem.Caption:=MyMenuItem.Caption+ExtractFilename(AFilename);
  Franz:=Exit1.MenuIndex;
  File1.Insert(Franz, MyMenuItem);
  MyMenuItem:=TMenuItem.Create(File1);
  MyMenuItem.Caption:='-';
  File1.Insert(Franz+1, MyMenuItem);
  File1.Items[Franz].OnClick:=OpenRememberedWindow;
  //File1.Items}
end;

procedure TTecMainWin.CallGreatPi(Sender: TObject; AFilename: TFilename; AExtension: TExtension);
begin
  with TPiplot.Create(Application) do
  begin
    Screen.Cursor := CrHourGlass;
    If Sender= Greatcircles1 then Caption:= 'Great circle-plot - ['+ExtractFileName(AFilename) +']'
    else if Sender=PiPlot1 then Caption:= 'Pi-plot - ['+ExtractFileName(AFilename) +']'
    else if Sender=Lineations1 then Caption :=  'Lineations - ['+ExtractFileName(AFilename) +']'
    else if Sender=DipLines1 then Caption :=  'Dip Lines - ['+ExtractFileName(AFilename) +']';
    FormCreate(Sender,AFilename, AExtension);
  end;
end;

procedure TTecMainWin.GreatCirclesClick(Sender: TObject);
var FExtension: TExtension;
    i: Integer;
begin
  GreatOpenDialog.InitialDir:=GetCurrentDir; //Bugfix 20000408 (Win2000)
  if Sender=PiPlot1 then with GreatOpenDialog do
  begin
    Title:='Draw Pi-plot';
    FilterIndex:=PiLastFileType;
  end
  else if Sender=GreatCircles1 then with GreatOpenDialog do
  begin
    Title:='Draw great circles';
    FilterIndex:=GreatLastFileType;
  end
  else if Sender=DipLines1 then with GreatOpenDialog do
  begin
    Title:='Draw dip lines';
    FilterIndex:=DipLastFileType;
  end;
  if GreatOpenDialog.Execute then
  begin
    For i:=0 to GreatOpenDialog.Files.Count-1 do
      If CheckExtension(Sender, GreatOpenDialog.Files[i], FExtension) then
      begin
        CallGreatPi(Sender,  GreatOpenDialog.Files[i], FExtension);
        If Sender=GreatCircles1 then GreatLastFileType:=GreatOpenDialog.FilterIndex
        else if Sender=PiPlot1 then PiLastFileType:=GreatOpenDialog.FilterIndex
        else if Sender=DipLines1 then DipLastFileType:=GreatOpenDialog.FilterIndex;
      end;
    GreatOpenDialog.Filename:='';
    GreatOpenDialog.InitialDir:=GetCurrentDir; //Bugfix 20000408
  end;
end;

procedure TTecMainWin.PTaxesPlotClick(Sender: TObject);
var fextension: TExtension;
    i: Integer;
begin
  PTPlotOpenDialog.InitialDir:=GetCurrentDir; //Bugfix 20000408 (Win2000)
  if PTPlotOpenDialog.Execute then
  begin
    For i:=0 to PTPlotOpenDialog.Files.Count-1 do
      If CheckExtension(Sender, PTPlotOpenDialog.Files[i], FExtension) then
        CallptPlot(Sender, PTPlotOpenDialog.Files[i], FExtension);
    PTPlotOpenDialog.Filename:='';
    PTPlotOpenDialog.InitialDir:=GetCurrentDir; //Bugfix 20000408
  end;
end;

procedure TTecMainWin.CallptPlot(Sender: TObject; AFilename: TFilename; AExtension: TExtension);
begin
  with Tplotpt.Create(Application) do
  begin
    Caption :=  'pt-axes - [' +
    ExtractFileName(AFilename) +']';
    FormCreate(Sender,AFilename, AExtension);
  end;
end;

procedure TTecMainWin.Lineations1Click(Sender: TObject);
var FExtension: TExtension;
    i: Integer;
begin
  LineationOpenDialog.InitialDir:=GetCurrentDir; //Bugfix 20000408 (Win2000)
  if LineationOpenDialog.Execute then
  For i:=0 to LineationOpenDialog.Files.Count-1 do
    If CheckExtension(Sender, LineationOpenDialog.Files[i], FExtension) then
      CallGreatPi(Sender, LineationOpenDialog.Files[i], FExtension);
  LineationOpenDialog.Filename:='';
  LineationOpenDialog.InitialDir:=GetCurrentDir; //Bugfix 20000408
end;

procedure TTecMainWin.Options1Click(Sender: TObject);
begin
  With TOptionDialog.Create(Application) do
  try
    ShowModal;
  finally
    release;
  end;
end;

procedure TTecMainWin.NDA1Click(Sender: TObject);
var FExtension: TExtension;
begin
  If Sender=Invers1 then
  begin
    NDAOpenDialog.Title:= 'Calculate direct inversion';
    NDAOpenDialog.Filterindex:=INVLastfiletype;
  end
  else If Sender=PTAxes1 then
  begin
    NDAOpenDialog.Title:= 'Calculate pt-Axes';
    NDAOpenDialog.Filterindex:=BTLastfiletype;
  end
  else If Sender=NDA1 then
  begin
    NDAOpenDialog.Title:= 'Calculate NDA';
    NDAOpenDialog.Filterindex:=NDALastfiletype;
  end;
  if NDAOpenDialog.Execute then
  begin
    If Sender=NDA1 then
    begin
      If CheckExtension(Sender, NDAOpenDialog.Filename, FExtension) then
      begin
      With TExportForm.Create(Self) do
      try
        NDALastfiletype:=NDAOpenDialog.Filterindex;
        Caption :=  'Calculate NDA - [' +
                   ExtractFileName(NDAOpenDialog.Filename) +']';
        Label1.Caption:='Please enter theta-angle:';
        Label2.Caption:='°';
        NumEdit1.Number:= NDATheta;
        NumEdit1.HelpContext:=475;
        NumEdit1.Hint:='Enter theta angle';
        Label1.Tag:=475;
        Label2.Tag:=475;
        BitBtn1.HelpContext:=475;
        BitBtn2.HelpContext:=475;
        HelpBtn.HelpContext:=475;
        HelpContext:=475;
        ShowModal;
        If ModalResult=mrCancel then exit;
        NDATheta:= NumEdit1.Number;
      finally
         release;
      end;
      With TNDAPlot.Create(Application) do
      begin
        Init(Sender, NDAOpenDialog.Filename, FExtension, NDATheta);
        FormCreate(Sender, NDAOpenDialog.Filename, FExtension);
      end;
      end;
    end
    else
      If Sender=Invers1 then
      begin
        If CheckExtension(Sender, NDAOpenDialog.Filename, FExtension) then
        with TInversPlot.Create(Application) do
        begin
          INVLastfiletype:=NDAOpenDialog.Filterindex;
          Caption := Caption +' - [' +ExtractFileName(NDAOpenDialog.Filename) +']';
          FormCreate(Sender, NDAOpenDialog.Filename, FExtension);
        end;
      end
      else
        If Sender=PTAxes1 then
          If CheckExtension(Sender, NDAOpenDialog.Filename, FExtension) then
          with TThetaDialog.Create(Application) do
          try
            BTLastfiletype:=NDAOpenDialog.Filterindex;
            Caption:=Caption + ' - [' +ExtractFileName(NDAOpenDialog.Filename) +']';
            Open(NDAOpenDialog.Filename, FExtension);
            ShowModal;
          finally
            release;
          end;
    NDAOpenDialog.Filename:='';
  end;
end;

procedure TTecMainWin.Cascade1Click(Sender: TObject);
begin
  Cascade;
end;

procedure TTecMainWin.MinimizeAll1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := MDIChildCount - 1 downto 0 do
    MDIChildren[I].WindowState := wsMinimized;
end;

procedure TTecMainWin.CloseAll1Click(Sender: TObject);
var
  I: Integer;
begin
  for I := MDIChildCount - 1 downto 0 do
    MDIChildren[i].close;
  Window1.Enabled := false;
end;

procedure TTecMainWin.Horizontal1Click(Sender: TObject);
begin
  TileMode := tbHorizontal;
  Tile;
end;

procedure TTecMainWin.Vertical1Click(Sender: TObject);
begin
  TileMode := tbVertical;
  Tile;
end;

procedure TTecMainWin.ArrangeIcons1Click(Sender: TObject);
begin
  ArrangeIcons;
end;

procedure TTecMainWin.Correct1Click(Sender: TObject);
var
   Flag1, Flag2, Failed, NoComment: boolean;
   F, G: textFile;
   nAzimuth, nPlunge, Dip, Azimuth, Plunge, DipDir, dummy, Error : Single;
   sense,nsense,Quality, Z, changesensecounter, CheckCounter : Integer;
   Extension: TExtension;
   Comment, corrinfo, AddComment: String;
   MyLocInfo: TLocationInfo;
begin
  failed := false;
  flag1:=false;
  flag2:=false;
  nazimuth:= 0;
  nplunge:= 0;
  changesensecounter:=0;
  checkcounter:=0;
  CorOpenDialog.InitialDir:=GetCurrentDir; //Bugfix 20000408  (Win2000)
  if CorOpenDialog.Execute then
  begin
    flag1 := true;
    CorSaveDialog.FileName := ExtractFilename(ChangeFileExt(CorOpenDialog.FileName, '.cor'));
    if CorSaveDialog.Execute then
    begin
      flag2:= true;
      corrinfo:='Input file:  '+CorOpenDialog.FileName+#13#10+
                'Output file: '+CorSaveDialog.FileName+#13#10+
                'No.  Fault plane  Corr. lin.   (Meas. lin.)  Se Qu (Se) Err[°]';
      try
        Extension := ExtractExtension(CorOpenDialog.FileName);
        MyLocInfo:=GetLocInfo(CorOpenDialog.FileName);
        AssignFile(f, CorOpenDialog.FileName);
        Reset(f);
        try
          If LocInfoToFile(CorSaveDialog.Filename, MyLocInfo) then
          begin
            AssignFile(g, CorSaveDialog.FileName);
            Append(g);
          end
          else
          begin
            AssignFile(g, CorSaveDialog.FileName);
            Rewrite(g);
          end;
          Failed:=False;
          z:=0;
          if not eof(f) then
          begin
            try
              while not Eof(F) do
              begin
                Comment:='';
                ReadFPLDataset(f, Sense, Quality, DipDir, Dip, Azimuth, Plunge, failed, NoComment, Extension, Comment);
                if not failed and NoComment then
                begin
                  Inc(Z);
                  If Dip=90 then Dip:=89.99;
                  CorrectLineation(DipDir, Dip, Azimuth, Plunge, nAzimuth, nPlunge);
                  dummy:=abs(azimuth-nazimuth);
                  if dummy>180 then dummy:=360-dummy; // bugfix 980521
                  if dummy>90 then
                    case Sense of
                      1: nsense:=se_normal;
                      2: nsense:=se_reverse;
                      else nsense:=sense;
                    end else nsense:=sense;
                  CorrectSense(nsense, DipDir, Dip, nAzimuth, nPlunge);
                  Error:=DihedralAngle(Azimuth,Plunge,NAzimuth,NPlunge, true);
                  CorrInfo:=CorrInfo+#13#10+FloatToString(z,3,0)+' '+
                  FloatToString(DipDir,3,2)+'/'+FloatToString(Dip,2,2)+' '+FloatToString(nAzimuth,3,2)+'/'+FloatToString(nPlunge,2,2)+' ('+
                  FloatToString(Azimuth,3,2)+'/'+FloatToString(Plunge,2,2)+') '+GetSenseAsString(nsense)+'  '+IntToStr(Quality)+' ('+GetSenseAsString(sense)+') '+FloatToString(Error,2,1);
                  if sense<>nsense then
                  begin
                    inc(changesensecounter);
                    corrinfo:=corrinfo+' * ';
                  end
                  else corrinfo:=corrinfo+'   ';
                  if error>=CorrError then
                  begin
                    inc(Checkcounter);
                    AddComment:='Check!';
                    CorrInfo:=CorrInfo+' '+AddComment; //to be moved to options for version 2.0
                  end else AddComment:='';
                  write(g,CombineSenseQuality(nSense,Quality),FileListSeparator,FloatToString(DipDir,3,2),FileListSeparator,
                          FloatToString(Dip,2,2),FileListSeparator,FloatToString(nAzimuth,3,2),
                          FileListSeparator,FloatToString(nPlunge,2,2));
                  If Comment<>'' then
                    If AddComment='' then write(g, filelistseparator, Comment)
                    else write(g,filelistseparator, Comment, ' (', AddComment,')')
                  else if AddComment<>'' then write(g, filelistseparator, AddComment);
                  if not eof(f) then writeln(g);
                end; //if not failed
              end; //end of while-loop
          except
            On EZeroDivide do
              begin
                MessageDlg('Calculation stopped in line '+IntToStr(Z)+'! Use 89.9 degrees for plunge instead of 90°.',
                            mtWarning,[mbOk], 0);
                Flag1:=false;
              end;
          end;
        end else failed:=true;
      closeFile(g);
      closeFile(F);
      except
        on EInOutError do  {can not write to file}
              begin
                CloseFile(f);
                GlobalFailed:=true;
                Screen.Cursor := CrDefault;
                MessageDlg('Can not open '+CorSaveDialog.FileName+'!'+#13#10+
                'Conversion failed.', mtError,[mbOk], 0);
                Exit;
              end;
          end;
      except   {can not open file}
      On EInOutError do
      begin
        Globalfailed:=true;
        Screen.Cursor:=crDefault;
        MessageDlg('Can not open '+CorOpenDialog.Filename+' !'#10#13+
        'Processing stopped. File might be in use by another application.',
        mtError,[mbOk], 0);
        Exit;
      end;
     end;
      if flag1 and flag2 and not failed then
      begin
        If ResInsp=nil then
        begin
          ResInsp:=TResInsp.Create(nil);
          Resinsp.visible:=true;
          TecMainWin.BringToFront;
        end;
        If ChangeSenseCounter>0 then
        begin
          CorrInfo:=CorrInfo+#13#10+
            'Remarks:'+#13#10+
            '*........Sense was changed during correction for '+IntToStr(ChangeSenseCounter)+' dataset';
          If ChangeSenseCounter>1 then CorrInfo:=CorrInfo+'s.'
          else CorrInfo:=CorrInfo+'.'
        end;
        If CheckCounter>0 then
        begin
          if ChangeSenseCounter=0 then CorrInfo:=CorrInfo+#13#10+'Remarks:';
          CorrInfo:=CorrInfo+#13#10+
            'Check!...Calculated lineation differs more than '+IntToStr(CorrError)+'° from measured'+#13#10+
            '         lineation for '+IntToStr(CheckCounter)+' dataset';
          If CheckCounter>1 then CorrInfo:=CorrInfo+'s.'
          else CorrInfo:=CorrInfo+'.'
        end;
        ResInsp.Panel6.Caption:=' Results: Correction';
        If Resinsp.minimized then Resinsp.SpeedButton1Click(Sender);
        With ResInsp.Memo1.Lines do
        begin
          Clear;
          Add(CorrInfo);
        end;
        TecMainWin.WriteToStatusbar(nil , 'Written to file '+CorSaveDialog.FileName);
      end
      else MessageDlg('Error reading '+CorOpenDialog.FileName, mtError,[mbOk], 0);
      end;
      CorSaveDialog.Filename:='';
    end;
    CorOpenDialog.Filename:='';
end;

procedure TTecMainWin.TectonicHelp1Click(Sender: TObject);
begin
  If not Application.Helpcommand(Help_Finder,0) then
   MessageDlg('Can not start windows help!', mtError,[mbOk], 0);
end;

procedure TTecMainWin.UpdateItems(Sender: TObject);
var OneMinimized, AllMinimized: boolean;
    I: Integer;
begin
  if MDIChildCount > 0 then
  begin
    Window1.Enabled := true;
    If GlobalFailed=true then
    begin
      AllMinimized:=true;
      for I := MDIChildCount-1 downto 0 do
        If MDIChildren[i].WindowState <> wsMinimized then AllMinimized:= false;
      If AllMinimized then
      begin
        Tile1.Enabled:=false;
        Cascade1.Enabled:=false;
        MinimizeAll1.Enabled:=False;
      end;
    end;
    OneMinimized:=false;
    for I := MDIChildCount-1 downto 0 do
      If MDIChildren[i].WindowState = wsMinimized then OneMinimized:= true;
    If not OneMinimized then ArrangeIcons1.Enabled:=false;
  end;
end;

procedure TTecMainWin.Convert1Click(Sender: TObject);
begin
  with TConvDlg1.Create(Self) do
  try
    ShowModal;
  finally
    release;
  end;
end;

procedure TTecMainWin.About1Click(Sender: TObject);
begin
  With TAboutbox.Create(Self) do
  try
    ShowModal;
  finally
    release;
  end;
end;

procedure TTecMainWin.BinghamStatistics1Click(Sender: TObject);
var FExtension: TExtension;
    i: Integer;
begin
  EigenVectOpenDialog.InitialDir:=GetCurrentDir; //Bugfix 20000408 (Win2000)
  if EigenVectOpenDialog.Execute then
  begin
    For i:=0 to EigenVectOpenDialog.Files.Count-1 do
      if CheckExtension(Sender, EigenVectOpenDialog.Files[i], FExtension) then with TBinghamForm.Create(Application) do
      begin
        Caption :=  'Eigenvectors - [' +
                  ExtractFileName(EigenVectOpenDialog.Files[i]) +']';
        FormCreate(Sender,EigenVectOpenDialog.Files[i],FExtension);
      end;
    EigenVectOpenDialog.FileName:='';
    EigenVectOpenDialog.InitialDir:=GetCurrentDir; //Bugfix 20000408
  end;
end;

procedure TTecMainWin.Sort1Click(Sender: TObject);
var ext : TExtension;
    i: Integer;
begin
  SortManOpenDialog.InitialDir:=GetCurrentDir; //Bugfix 20000408 (Win2000)
  if SortManOpenDialog.Execute then
  begin
    For i:=0 to SortManOpenDialog.Files.Count-1 do
    begin
      ext := ExtractExtension(SortManOpenDialog.Files[i]);
      case ext of
        COR, FPL, PEF, PEK, HOE, PLN, LIN, PTF:
          With TSortManual.Create(Application) do Open(SortManOpenDialog.Files[i]);
      else
        MessageDlg(ExtractFilename(SortManOpenDialog.Files[i])+#13#10+'This type of file can not be processed!',mtError,[mbOk], 0);
      end;
    end; //for
    SortManOpenDialog.Filename:='';
    SortManOpenDialog.InitialDir:=GetCurrentDir; //Bugfix 20000408
  end;
end;

procedure TTecMainWin.SmallCircles1Click(Sender: TObject);
var done: boolean;
begin
  ExportForm:=TExportForm.Create(Self);
  With ExportForm do
  try
    HelpContext:=300;
    Caption :=  'Draw small circle';
    Label1.Caption:='Half opening angle';
    Label2.Caption:='°';
    NumEdit2.visible:= true;
    NumEdit3.visible:= true;
    Edit1.visible:= true;
    Label3.visible:= true;
    Label4.visible:= true;
    NumEdit1.Number:=SmallAperture;
    NumEdit2.Number:=SmallAzimuth;
    NumEdit3.Number:=SmallPlunge;
    Edit1.Text:=SmallComment;
    Repeat
      ShowModal;
      If ModalResult=mrCancel then Exit else Done :=True;
      If (NumEdit1.Number<1) or (NumEdit1.Number>90) or (NumEdit2.Number<0) or
        (NumEdit2.Number>359) or (NumEdit3.Number<0) or (NumEdit3.Number>90) then
        If MessageDlg('Invalid input data!',mtWarning,[mbRetry, mbCancel, mbHelp], 300)=
          mrCancel then exit else done :=false;
    until done;
    SmallAperture:=NumEdit1.Number;
    SmallAzimuth:=NumEdit2.Number;
    SmallPlunge:=NumEdit3.Number;
    SmallComment:=Edit1.Text;
    With TSmallCircleFm.Create(Application) do
    begin
      if ExportForm.Edit1.Text='' then Caption := 'Small Circles ' else
         Caption := 'Small Circles - ['+ExportForm.Edit1.Text+']';
      Open(Sender, NumEdit1.Number, NumEdit2.Number, NumEdit3.Number, ExportForm.Edit1.Text);
    end;
  finally
    release;
  end;
end;

procedure TTecMainWin.Fisherstatistics1Click(Sender: TObject);
var blDone: boolean;
    FExtension: TExtension;
    Confidence: Integer;
begin
  If Sender = FisherStatistics1 then
    MeanVectOpenDialog.Title := 'Calculate mean vector - Fisher Stat.'
  else MeanVectOpenDialog.Title :=  'Calculate mean vector - R% Center';
  blDone:= MeanVectOpenDialog.Execute;
  If blDone then
  begin
    if CheckExtension(Sender, MeanVectOpenDialog.Filename, FExtension) then
    With TExportForm.Create(Self) do
    begin
      Confidence:=FishLastConf;
      Repeat
        Caption :=  MeanVectOpenDialog.Title + ' ['+
            ExtractFileName(MeanVectOpenDialog.Filename) +']';
        NumEdit1.Number:= Confidence;
        NumEdit1.Hint:='Enter confidence [%]| ';
        NumEdit1.HelpContext:=450;
        Label1.Tag:=450;
        Label2.Tag:=450;
        BitBtn1.HelpContext:=450;
        BitBtn2.HelpContext:=450;
        HelpBtn.HelpContext:=450;
        HelpContext:=450;
        If ShowModal=mrCancel then Exit else blDone :=true;
        Confidence:= NumEdit1.Number;
        If (Confidence < 1) or (Confidence > 99) then
          If MessageDlg('Invalid number. Only integer-values from 1 to 99 are valid!',
               mtWarning,[mbRetry, mbCancel], 0)= mrCancel then exit else blDone :=false;
      until blDone;
    end
    else Exit;
    FishLastConf:=confidence;
    With TFisherForm.Create(Application) do
    begin
      If Sender=FisherStatistics1 then
      begin
        LHPlotType:=pt_MeanVectFisher;
        Caption := 'Mean vector  - Fisher Stat. [' +
               ExtractFileName(MeanVectOpenDialog.Filename) +']';
      end
      else
      begin
        LHPlotType:=pt_MeanVectRC;
        Caption := 'Mean vector  - R% Center [' +
               ExtractFileName(MeanVectOpenDialog.Filename) +']';
      end;
      Open(MeanVectOpenDialog.Filename, Confidence, FExtension);
      MeanVectOpenDialog.FileName:='';
    end;
 end;
end;


procedure TTecMainWin.Flucthistogram1Click(Sender: TObject);
var FExtension: TExtension;
    i: Integer;
begin
  With FluHOpenDialog do
  begin
    InitialDir:=GetCurrentDir; //Bugfix 20000408 (Win2000)
    If Sender=MohrCircle1 then
    begin
      Title:='Draw Mohr circle';
      Filter:='Invers files (*.inv)|*.inv|NDA files (*.n??)|*.n??|All files (*.*)|*.*';
      FilterIndex:=MohrLastfiletype;
    end
    else If (Sender=Stressaxes1) or (sender=Dihedra3) then
    begin
      Title:='Draw Sigma/Lambda123';
      FilterIndex:=SigmaLastfiletype;
    end
    else If Sender=Flucthistogram1 then
    begin
      Title:='Draw fluctuation histogram';
      Filter:= 'Invers files (*.inv)|*.inv|NDA files (*.n??)|*.n??|All files (*.*)|*.*';
      FilterIndex:=FluHLastfiletype;
    end;
    If FluHOpenDialog.Execute then
      For i:=0 to FluHOpenDialog.Files.Count-1 do
      begin
        If Sender=Flucthistogram1 then
        begin
          FluHLastfiletype:=FilterIndex;
          If CheckExtension(Sender, FluHOpenDialog.Files[i], FExtension) then with TSigmaFromFile.Create(Application) do
          begin
            Caption := 'Fluctuation - Histogram - [' +ExtractFileName(FluHOpenDialog.Files[i]) +']';
            FormCreate(Sender, FluHOpenDialog.Files[i], FExtension);
          end;
        end
        else If Sender=MohrCircle1 then
        begin
          MohrLastfiletype:=FilterIndex;
          If CheckExtension(Sender, FluHOpenDialog.Files[i], FExtension) then with TSigmaFromFile.Create(Application) do
          begin
            Caption := 'Mohr-Circle - [' +ExtractFileName(FluHOpenDialog.Files[i]) +']';
            FormCreate(Sender,FluHOpenDialog.Files[i], FExtension);
          end;
        end
        else If (Sender=Stressaxes1) or (Sender=Dihedra3) then
        begin
          SigmaLastfiletype:=FilterIndex;
          If CheckExtension(Sender, FluHOpenDialog.Files[i], FExtension) then with TSigmaFromFile.Create(Application) do
            FormCreate(Sender, FluHOpenDialog.Files[i], FExtension);
        end;
      end; //For
     FluHOpenDialog.Filename:='';
     FluHOpenDialog.InitialDir:=GetCurrentDir; //Bugfix 20000408
  end;
end;

procedure TTecMainWin.RoseDiagram1Click(Sender: TObject);
var FExtension: TExtension;
begin
  if RoseOpenDialog.Execute then
    If CheckExtension(Sender, RoseOpenDialog.Filename, FExtension) then with TRoseDial.Create(Application) do
  try
    Open(Sender, FExtension);
    Caption := Caption+' - ['+
               ExtractFileName(RoseOpenDialog.Filename)+']';
    ShowModal;
    if ModalResult = mrOk then
    begin
      with TRoseForm.Create(Application) do
      begin
        Caption := 'Rose-diagram - [' +
                   ExtractFileName(RoseOpenDialog.Filename) +']';
        Open(Sender, RoseOpenDialog.Filename, NumEdit1.Number, NumEdit2.Number,
             CheckBox1.Checked, CheckBox2.Checked, unipol, Plane, RadioGroup1.ItemIndex, FExtension);
      end;
    end;
  finally
    Release;
    RoseOpenDialog.Filename:='';
  end;
end;

procedure TTecMainWin.ContourPlot1Click(Sender: TObject);
var
FAutoFlg, FCircleFlg:boolean;
fdatatype, FDensity, FCount: Integer;
FExtension: TExtension;
FValues: TCvalArray;

begin
  if ContOpenDialog.Execute then
    if CheckExtension(Sender, ContOpenDialog.Filename, FExtension) then
  With TContDlgFrm.Create(Application) do
  begin
    Caption:= Caption+' - ['+ExtractFilename(ContOpenDialog.FileName)+']';
    Open(Sender, FExtension);
    ShowModal;
    If ModalResult=mrOk then
    begin
      if ContLevelRG.ItemIndex <> 0 then
      begin
        FCount:= CON;
        FValues:= Value;
        //ContValues:=Value;
      end;
      FAutoflg:= AAutoflg;
      FCircleFlg := ACircleFlg;
      FDensity := ADens;
      fDataType:=RadioGroup1.ItemIndex;
      Release;
      With TContPlotFrm.Create(Application) do
      try
        Caption:='Contour-plot - ['+ExtractFileName(ContOpenDialog.Filename) +']';
        LHPlotType:=pt_Contour;
        FormCreate(Sender, ContOpenDialog.FileName, FExtension);
        lhstressaxis:=fdatatype;
        ReadData(Sender);
        if not GlobalFailed then
        begin
          ContNetSetup(FAutoFlg,FCircleFlg,FDensity,FCount,FValues);
          Init(Sender);
        end;
      Except
        On EVariantError do
        begin
          MessageDlg('Plot failed.', mtError,[mbOk], 0);
          Free;
          Screen.Cursor:=crDefault;
        end;
      end;
    end else release;
  end;
  ContOpenDialog.FileName:='';
end;

procedure TTecMainWin.Rotate1Click(Sender: TObject);
var FExtension : TExtension;
    i: Integer;
begin
  RotateOpenDialog.InitialDir:=GetCurrentDir; //Bugfix 20000408 (Win2000)
  if RotateOpenDialog.Execute then
  begin
    For i:=0 to RotateOpenDialog.Files.Count-1 do
    begin
      If CheckExtension(Sender, RotateOpenDialog.Files[i], FExtension) then
      With TRotForm.Create(Application) do
      begin
        Caption:='Rotate data - ['+
                 ExtractFilename(RotateOpenDialog.Files[i])+']';
        Open(RotateOpenDialog.Files[i], FExtension);
      end;
    end; //For
    RotateOpenDialog.FileName:='';
    RotateOpenDialog.InitialDir:=GetCurrentDir; //Bugfix 20000408
  end;
end;

procedure TTecMainWin.Virtualdip1Click(Sender: TObject);
begin
  if VirtDipFrm=nil then VirtDipFrm:=TVirtDipFrm.Create(Application);
  With VirtDipFrm do
  begin
    If Sender=Virtualdip1 then Notebook1.PageIndex:=0
    else If Sender=Dihedralangle1 then Notebook1.PageIndex:=1
      else If Sender=Planefromlinears1 then Notebook1.PageIndex:=2;
    Show;
  end;
end;

procedure TTecMainWin.Dihedra1Click(Sender: TObject);
var FExtension: TExtension;
begin
  DihOpenDialog.filter:=NDAOpenDialog.Filter;
  if DihOpenDialog.Execute then
  begin
     If CheckExtension(Sender, DihOpenDialog.Filename, FExtension) then
       With TDihedrFrm.Create(Application) do
       begin
         Caption:='Dihedra-calculation (contoured) - ['+ExtractFileName(DihOpenDialog.Filename) +']';
         LHPlotType:=pt_Dihedra;
         FormCreate(Sender,DihOpenDialog.FileName, FExtension);
         ContourData;
         If not lhfailed then Init(Sender);
       end;
     DihOpenDialog.Filename:='';
  end;
end;

procedure TTecMainWin.FormResize(Sender: TObject);
var I: Integer;
    AllMinimized, OneMinimized: boolean;
begin
  If (Sender as TForm).WindowState=wsMinimized then
  begin
    ArrangeIcons1.Enabled:=True;
    AllMinimized:=true;
    for I := MDIChildCount-1 downto 0 do
      If MDIChildren[i].WindowState <> wsMinimized then AllMinimized:= false;
    If AllMinimized then
    begin
      Tile1.Enabled:=false;
      Cascade1.Enabled:=false;
      MinimizeAll1.Enabled:=False;
    end;
  end
  else
  begin
    Tile1.Enabled:=true;
    Cascade1.Enabled:=true;
    MinimizeAll1.Enabled:=true;
    OneMinimized:=false;
    for I := MDIChildCount-1 downto 0 do
      If MDIChildren[i].WindowState = wsMinimized then OneMinimized:= true;
    If not OneMinimized then ArrangeIcons1.Enabled:=false;
  end;
  If not maximizing then //resizing of form only
  begin
    maximizing:=true;
    If InspectorForm<>nil then
      If InspectorForm.Aligned then ArrangeRollup(InspectorForm);
    If SetForm<>nil then
      If SetForm.Aligned then ArrangeRollup(SetForm);
    If ResInsp<>nil then
      If ResInsp.Aligned then ArrangeRollup(ResInsp);
  end;
  maximizing:=false;
  progressbar1.left:=statusbar1.left+statusbar1.width-progressbar1.width-11;
  progressbar1.top:=statusbar1.top+4;
end;

procedure TTecMainWin.ArrangeMenu(Sender : TObject);
begin
  Tile1.Enabled:=true;
  Cascade1.Enabled:=true;
  MinimizeAll1.Enabled:=true;
end;

procedure TTecMainWin.Dihedra2Click(Sender: TObject);
begin
  DihOpenDialog.filter:=NDAOpenDialog.Filter;
  if DihOpenDialog.Execute then
  begin
    With TDihedraForm.Create(Application) do
    begin
      Caption :=  'Dihedra-plot - [' +
                  ExtractFileName(DihOpenDialog.Filename) +']';
      FormCreate(Sender,DihOpenDialog.Filename,ERR);
    end;
    DihOpenDialog.Filename:='';
  end;
end;

procedure TTecMainWin.FormClose(Sender: TObject; var Action: TCloseAction);
var keydummy, bufsize: integer;
    i: integer;
    WMFdummy: TMetafile;
    EMFdummy: TEnhMetafile;
begin
  if RegOpenKeyEx(HKEY_LOCAL_MACHINE, PChar('SOFTWARE\GeoCompute\TectonicsFP\'+TFPRegEntryVersion),
                      0, KEY_READ, keydummy)=ERROR_SUCCESS then
  begin
    RegQueryValueEx(Keydummy, 'TFPThreads', nil, nil, nil, @bufsize); //get buffer size
    RegQueryValueEx(Keydummy, 'TFPThreads', nil, nil, PByte(@i), @bufsize); //get thread counter from registry
    RegCloseKey(KeyDummy);
  end;
  If i=1 then //this is the last tfp thread currently open in system: close all open handles
  begin
    if GlobalClipbMFH<>0 then //delete clipboard metafiles
    begin
      If WriteWmfGlobal then DeleteMetaFile(GlobalClipbMFH)
      else DeleteEnhMetaFile(GlobalClipbMFH);
      GlobalClipbMFH:=0;
    end;
    if WriteWmfGlobal and Clipboard.HasFormat(TFPMetafile) or
    not WriteWmfGlobal and Clipboard.HasFormat(TFPEnhMetafile) then with Clipboard do
    try   //empty clipboard
      Open;
      If HasFormat(CF_METAFILEPICT) or HasFormat(CF_ENHMETAFILE) then
        Case MessageDlg('Leave data in Clipboard for other applications?',
              mtConfirmation,[mbYes, mbNo, mbCancel], 0) of
        mrYes:
        begin //leave data in wmf/emf format if user wants
          if WriteWmfGlobal then
          try
            WMFDummy:=TMetafile.Create;
            WMFDummy.Assign(Clipboard);
            Clear;
            Assign(WMFDummy);
          finally
            wmfdummy.free;
          end
          else
          try
            EMFDummy:=TEnhMetafile.Create;
            EMFDummy.Assign(Clipboard);
            Clear;
            Assign(EMFDummy);
          finally
            EMFDummy.Free;
          end;
        end;
        mrNo: Clear;
        mrCancel: begin
          Action:=caNone;
          Exit;
        end;
        end //case
      else Clear;
    finally
      Close;
    end;
  end;
  if RegOpenKeyEx(HKEY_LOCAL_MACHINE, PChar('SOFTWARE\GeoCompute\TectonicsFP\'+TFPRegEntryVersion),
                      0, KEY_READ, keydummy)=ERROR_SUCCESS then
  begin
    RegQueryValueEx(Keydummy, 'TFPThreads', nil, nil, nil, @bufsize); //get buffer size
    RegQueryValueEx(Keydummy, 'TFPThreads', nil, nil, PByte(@i), @bufsize); //get thread counter from registry
    RegCloseKey(KeyDummy);
    if RegOpenKeyEx(HKEY_LOCAL_MACHINE, PChar('SOFTWARE\GeoCompute\TectonicsFP\'+TFPRegEntryVersion),
                      0, KEY_SET_VALUE, keydummy)=ERROR_SUCCESS then
    begin
      dec(i);
      RegSetValueEx(Keydummy, 'TFPThreads', 0, REG_DWORD, @i, SizeOf(Integer)); //decrement thread counter
      RegCloseKey(KeyDummy);
    end;
  end;
  With TTFPRegistry.Create do
  try
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Files', true);
      WriteString('LastworkDir', GetCurrentDir);
      WriteBool   ('WMF',WriteWMFglobal);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\MainWindow', true);
     If Windowstate<>wsMaximized then
      begin
        WriteInteger('Left',Left);
        WriteInteger('Top',Top);
        WriteInteger('Width',Width);
        WriteInteger('Height',Height);
      end;
      if integer(Windowstate)<>25 then WriteInteger('WindowState',integer(Windowstate))
      else WriteInteger('WindowState',Integer(wsNormal));
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Printer', true);
      WriteInteger('DiagramSize',PrintLowerHemiSize);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Graphics', true);
      WriteInteger('PolySegments',PolySegments);
      WriteInteger('DiagramSize',ClipbLowerHemiSize);
      WriteInteger('GlobalNetColor',GlobalNetColor);
      WriteInteger('GlobalBackColor',GlobalBackColor);
      WriteBool('GlobalLHBackOn', GlobalLHBackOn);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Files', true);
      //WriteInteger('FileCommentSeparator',Ord(FileCommentSeparator)); //981126: fixed to semicolon
      WriteInteger('FileListSeparator',Ord(FileListSeparator));
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\LowHem', true);
      WriteBool   ('GlobalLHNumbering',GlobalLHNumbering);
      WriteBool   ('GlobalLHLabel',GlobalLHLabel);
      WriteInteger('NorthPenWidth',NorthPenWidth);
      WriteInteger('AxesPenWidth',AxesPenWidth);
      WriteInteger('ExportLastFileType',ExportLastFileType);
      WriteString('FontName',TecMainWin.Fontdialog1.font.name);
      WriteInteger('FontHeight',TecMainWin.Fontdialog1.font.height);
      WriteInteger('FontSize',TecMainWin.Fontdialog1.font.Size);
      WriteInteger('FontColor',TecMainWin.Fontdialog1.font.Color);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Options', true);
      WriteInteger('LastPage',LastOptPage);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Quality', true);
      WriteInteger('ArrowStyle', GlobalArrowStyle);
      WriteInteger('UseLevels', QualitylevelsUsed);
      WriteBool   ('UseQuality', QualityGlobal);
      WriteInteger('CorrError', CorrError);
    CloseKey;

     //******************************* Rollups *******************************
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Rollups', true);
      WriteBool('PlotProperties',Inspectorform<>nil);
      If Inspectorform<>nil then
      begin
        WriteInteger('PlotPropLeft', Inspectorform.Left);
        WriteInteger('PlotPropTop',  Inspectorform.Top);
        WriteInteger('PlotPropWidth',  Inspectorform.Width);
        WriteBool('PlotPropMinimized', Inspectorform.Minimized);
        WriteBool('PlotPropAligned', Inspectorform.Aligned);
      end;

      WriteBool('Scaling',SetForm<>nil);
      If SetForm<>nil then
      begin
        WriteInteger('SetFormLeft', SetForm.Left);
        WriteInteger('SetFormTop',  SetForm.Top);
        WriteInteger('SetFormWidth',  SetForm.Width);
        WriteBool('SetFormMinimized', SetForm.Minimized);
        WriteBool('SetFormAligned', SetForm.Aligned);
      end;

      WriteBool('ResInsp',ResInsp<>nil);
      If ResInsp<>nil then
      begin
        WriteInteger('ResInspLeft', ResInsp.Left);
        WriteInteger('ResInspTop',  ResInsp.Top);
        WriteInteger('ResInspWidth', ResInspWidth);
        WriteInteger('ResInspHeight', ResInspHeight);
        WriteBool('ResInspMinimized', ResInsp.Minimized);
        WriteBool('ResInspAligned', ResInsp.Aligned);
      end;
      WriteBool('ResInspShowLocation', ResInspShowLocation);
      WriteBool('ResInspShowX', ResInspShowX);
      WriteBool('ResInspShowY', ResInspShowY);
      WriteBool('ResInspShowZ', ResInspShowZ);
      WriteBool('ResInspShowDate', ResInspShowDate);
      WriteBool('ResInspShowLithology', ResInspShowLithology);
      WriteBool('ResInspShowFormation', ResInspShowFormation);
      WriteBool('ResInspShowAge', ResInspShowAge);
      WriteBool('ResInspShowTectUnit', ResInspShowTectUnit);
      WriteBool('ResInspShowRemarks', ResInspShowRemarks);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Editor', true);
      WriteInteger('LastFileType',EditOpenDialog.FilterIndex);
      WriteInteger('E2LastFileType',Edit2OpenDialog.FilterIndex);
      WriteInteger('E2LastFileType2',E2LastFileType2);
      WriteInteger('E2LastParentFileType',E2LastParentFileType);
      WriteBool('E2BeepOn', E2BeepOn);
      WriteBool('E2AutoFill', E2AutoFill);
      WriteString('E2LastLocInfo', E2LastLocInfo);
      WriteBool('E2TakeLastLocInfo', E2TakeLastLocInfo);
      WriteString('E2FontName',TecMainWin.Edit2Fontdialog.font.name);
      WriteInteger('E2FontHeight',TecMainWin.Edit2Fontdialog.font.height);
      WriteInteger('E2FontSize',TecMainWin.Edit2Fontdialog.font.Size);
      WriteInteger('E2FontColor',TecMainWin.Edit2Fontdialog.font.Color);
      //WriteInteger('E2FontStyle', ShortInt(TecMainWin.Edit2FontDialog.Font.Style));
      WriteString('FontName',TecMainWin.EditFontdialog.font.name);
      WriteInteger('FontHeight',TecMainWin.EditFontdialog.font.height);
      WriteInteger('FontSize',TecMainWin.EditFontdialog.font.Size);
      WriteInteger('FontColor',TecMainWin.EditFontdialog.font.Color);
      //WriteInteger('E2FontStyle', ShortInt(TecMainWin.EditFontDialog.Font.Style));
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\SortMan', true);
      WriteInteger('LastFileType',SortManOpenDialog.FilterIndex);
      WriteInteger('SortFPLPlotType',SortFPLPlotType);
      WriteInteger('SortPTFPlotType',SortPTFPlotType);
      WriteInteger('SortPLNPlotType',SortPLNPlotType);
      WriteString('SortOutPath', SortLastOutputPath);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\GreatCircle', true);
      WriteInteger('GreatPenColor',GreatPenColor);
      WriteInteger('GreatPenStyle',LongInt(GreatPenStyle));
      WriteInteger('GreatPenWidth',GreatPenWidth);
      WriteInteger('LastFileType',GreatLastFileType);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\SmallCircle', true);
      WriteInteger('SmallSymbType',LongInt(SmallSymbType));
      WriteInteger('SmallSymbolSize',Round(1000*SmallSymbolSize/Radius));
      WriteInteger('SmallSymbFillColor',SmallSymbFillColor);
      WriteBool   ('SmallSymbfill',SmallSymbfillflag);
      WriteInteger('SmallPenColor',SmallPenColor);
      WriteInteger('SmallPenWidth',SmallPenWidth);
      WriteInteger('SmallPenStyle',LongInt(SmallPenStyle));
      WriteInteger('SmallAperture',SmallAperture);
      WriteInteger('SmallAzimuth',SmallAzimuth);
      WriteInteger('SmallPlunge',SmallPlunge);
      WriteString ('SmallComment',SmallComment);
      WriteInteger('SmallPolySegments',SmallPolySegments);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\PiPlot', true);
      WriteInteger('PiSymbFillColor',PiSymbFillColor);
      WriteInteger('PiPenColor',PiPenColor);
      WriteInteger('PiPenWidth',PiPenWidth);
      WriteInteger('PiSymbType',LongInt(PiSymbType));
      WriteBool   ('PiSymbFill',PiSymbFillflag);
      WriteInteger('PiSymbolSize',Round(1000*PiSymbolSize/Radius));
      WriteInteger('LastFileType',PiLastFileType);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\DipLine', true);
      WriteInteger('DipSymbFillColor', DipSymbFillColor);
      WriteInteger('DipPenColor', DipPenColor);
      WriteInteger('DipPenWidth', DipPenWidth);
      WriteInteger('DipSymbType', LongInt(DipSymbType));
      WriteBool   ('DipSymbFill', DipSymbFillflag);
      WriteInteger('DipSymbolSize', Round(1000*DipSymbolSize/Radius));
      WriteInteger('LastFileType', DipLastFileType);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Lineation', true);
      WriteInteger('LinSymbType',LongInt(LinSymbType));
      WriteInteger('LinSymbolSize',Round(1000*LinSymbolSize/Radius));
      WriteInteger('LinSymbFillColor',LinSymbFillColor);
      WriteBool   ('LinSymbFill',LinSymbFillflag);
      WriteInteger('LinPenColor',LinPenColor);
      WriteInteger('LinPenWidth',LinPenWidth);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Angelier', true);
      WriteInteger('AngSymbFillColor',AngSymbFillColor);
      WriteInteger('AngPenColor',AngPenColor);
      WriteInteger('AngPenStyle',LongInt(AngPenStyle));
      WriteInteger('AngPenWidth',AngPenWidth);
      WriteInteger('AngSymbRadius',Round(1000*AngSymbolSize/Radius));
      WriteBool   ('AngSymbFill',angsymbfillflag);
      WriteInteger('LastFileType',AngLastFileType);
      WriteInteger('AngSSArrowLength',Round(1000*AngSSArrowLength/Radius));
      WriteInteger('AngSSArrowHeadLength',Round(1000*AngSSArrowHeadLength/Radius));
      WriteInteger('AngSSArrowAngle',Round(RadToDeg(DegAngSSArrowAngle)));
      WriteInteger('AngNRArrowLength',Round(1000*AngNRArrowLength/Radius));
      WriteInteger('AngNRArrowHeadLength',Round(1000*AngNRArrowHeadLength/Radius));
      WriteInteger('AngNRArrowAngle',Round(RadToDeg(DegAngNRArrowAngle)));
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Hoeppener', true);
      WriteInteger('HoepSymbFillColor',HoepSymbFillColor);
      WriteInteger('HoepPenColor',HoepPenColor);
      WriteInteger('HoepPenWidth',HoepPenWidth);
      WriteInteger('HoepSymbRadius',Round(1000*HoepSymbRadius/Radius));
      WriteBool   ('HoepSymbFill',HoepSymbFillflag);
      WriteInteger('LastFileType',HoepLastFileType);
      WriteInteger('HoepArrowLength',Round(1000*HoepArrowLength/Radius));
      WriteInteger('HoepArrowheadLength',Round(1000*HoepArrowheadLength/Radius));
      WriteInteger('HoepArrowAngle',Round(RadToDeg(DegHoepArrowAngle)));
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\ptPlot', true);
      WriteInteger('PTPenColor',PTPenColor);
      WriteInteger('PTPenWidth',PTPenWidth);
      WriteBool   ('ptSymbFill',ptSymbFillFlag);
      WriteBool   ('ptSymbFill2',ptSymbFillFlag2);
      WriteInteger('ptSymbolSize',Round(1000*ptSymbolSize/Radius));
      WriteInteger('PTSymbFillColorP',PTSymbFillColorP);
      WriteInteger('PTSymbFillColorT',PTSymbFillColorT);
      WriteInteger('LastFileType',PtPlotOpenDialog.FilterIndex);
      WriteBool   ('ptCalcMeanVect',ptCalcMeanVect);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Sigma123', true);
      WriteInteger('SigTenPenColor',SigTenPenColor);
      WriteInteger('SigTenPenWidth',SigTenPenWidth);
      WriteBool   ('SigTenSymbFill',SigTenSymbFillFlag);
      WriteBool   ('SigTenSymbFill2',SigTenSymbFillFlag2);
      WriteInteger('SigTenSymbolSize',Round(1000*SigTenSymbolSize/Radius));
      WriteInteger('SigTenSymbFillColorP',SigTenSymbFillColorP);
      WriteInteger('SigTenSymbFillColorT',SigTenSymbFillColorT);
      WriteInteger('LastFileType',SigmaLastfiletype);
      WriteBool   ('SigmaDihedraOn',SigmaDihedraOn);

      WriteInteger('SigDihPenColor',SigDihPenColor);
      WriteInteger('SigDihPenWidth',SigDihPenWidth);
      WriteBool   ('SigDihSymbFill',SigDihSymbFillFlag);
      WriteBool   ('SigDihSymbFill2',SigDihSymbFillFlag2);
      WriteInteger('SigDihSymbFillColorP',SigDihSymbFillColorP);
      WriteInteger('SigDihSymbFillColorT',SigDihSymbFillColorT);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Mohr', true);
      WriteInteger('MohrPenColor',MohrPenColor);
      WriteInteger('MohrPenWidth',MohrPenWidth);
      WriteBool   ('MohrSymbFill',MohrSymbFillFlag);
      WriteInteger('MohrSymbolSize',Round(1000*MohrSymbolSize/Radius));
      WriteInteger('MohrSymbFillColor',MohrSymbFillColor);
      WriteInteger('MohrPenStyle',LongInt(MohrPenStyle));
      WriteInteger('LastFileType',MohrLastfiletype);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\FluctHist', true);
      WriteInteger('LastFileType',FluHLastfiletype);
      WriteInteger('FluHPenColor',FluHPenColor);
      WriteInteger('FluHPenWidth',FluHPenWidth);
      WriteBool   ('FluHSymbFill',FluHSymbFillFlag);
      WriteInteger('FluHSymbFillColor',FluHSymbFillColor);
      WriteInteger('FluHPenStyle',LongInt(FluHPenStyle));
      WriteInteger('FluHIntervals', FluHIntervals);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Rotate', true);
      WriteInteger('RotFPLPlotType',RotFPLPlotType);
      WriteInteger('RotPLNPlotType',RotPLNPlotType);
      WriteInteger('LastRotAngle',LastRotAngle);
      WriteInteger('LastRotAxAzim',LastRotAxAzim);
      WriteInteger('LastRotAxPlunge',LastRotAxPlunge);
      WriteInteger('LastFileType',RotateOpenDialog.FilterIndex);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Rose', true);
      WriteInteger('LastFileType',RoseOpenDialog.FilterIndex);
      WriteInteger('RosePenColor',RosePenColor);
      WriteInteger('RosePenWidth',RosePenWidth);
      WriteBool   ('RoseSymbFill',RoseSymbFillFlag);
      WriteInteger('RoseSymbFillColor',RoseSymbFillColor);
      WriteInteger('RosePenStyle',LongInt(RosePenStyle));
      WriteBool   ('RoseCenter',RoseCenter);
      WriteBool   ('RoseDipAlso',RoseDipAlso);
      WriteBool   ('RosePLBipol',RosePLBipol);
      WriteBool   ('RoseAziBipol',RoseAziBipol);
      WriteBool   ('RoseFPlane',RoseFPlane);
      WriteInteger('RosePTUse',RosePTUse);
      WriteInteger('RoseAziInt',RoseAziInt);
      WriteInteger('RoseDipInt',RoseDipInt);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Contour', true);
      For i:=1 to 16 do
      begin
        If ContValues[i]<>0 then WriteFloat('ContValue'+IntToStr(i),ContValues[i])
        else DeleteValue('ContValue'+IntToStr(i));
      end;
      WriteBool   ('ContAutoInt',ContAutoInt);
      WriteBool   ('ContGauss' ,ContGauss);
      WriteBool   ('ContFPlane',ContFPlane);
      WriteInteger('ContPTUse',ContPTUse);
      WriteInteger('ContGridD',ContGridD);
      WriteInteger('LastFileType',ContOpenDialog.FilterIndex);
      WriteInteger('ContPenColor',ContPenColor);
      WriteInteger('ContPenWidth',ContPenWidth);
      WriteInteger('ContPenStyle',LongInt(ContPenStyle));
      WriteInteger('ContSymbolSize', ContSymbolSize);
      WriteBool   ('ContShowNet', ContShowNet);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Fisher', true);
      WriteInteger('FishSymbType',LongInt(FishSymbType));
      WriteInteger('FishSymbolSize',Round(1000*FishSymbolSize/Radius));
      WriteInteger('FishSymbFillColor',FishSymbFillColor);
      WriteBool   ('FishSymbFill',FishSymbFillflag);
      WriteInteger('FishPenColor',FishPenColor);
      WriteInteger('FishPenWidth',FishPenWidth);
      WriteInteger('FishPen2Color',FishPen2Color);
      WriteInteger('FishPenStyle',LongInt(FishPenStyle));
      WriteInteger('FishLastConf',FishLastConf);
      WriteInteger('LastFileType',MeanvectOpenDialog.FilterIndex);
      WriteBool   ('FishShowConfCone',FishShowConfCone);
      WriteBool   ('FishShowSpherDistr',FishShowSpherDistr);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Bingham', true);
      WriteInteger('BingSymbType',LongInt(BingSymbType));
      WriteInteger('BingSymbolSize',Round(1000*BingSymbolSize/Radius));
      WriteInteger('BingSymbFillColor',BingSymbFillColor);
      WriteBool   ('BingSymbFill',BingSymbFillflag);
      WriteInteger('BingPenColor',BingPenColor);
      WriteInteger('BingPenWidth',BingPenWidth);
      WriteInteger('BingPenStyle',LongInt(BingPenStyle));
      WriteInteger('LastFileType',EigenvectOpenDialog.FilterIndex);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Calcpt', true);
      WriteInteger('ptTheta',ptTheta);
      WriteBool   ('ptBestTheta',ptBestTheta);
      WriteInteger('BTSymbFillColorP',BTSymbFillColorP);
      WriteInteger('BTSymbFillColorT',BTSymbFillColorT);
      WriteInteger('BTPenColorP',BTPenColorP);
      WriteInteger('BTPenColorT',BTPenColorT);
      WriteInteger('btPenWidth',btPenWidth);
      WriteBool   ('btSymbFill',btSymbFillFlag);
      WriteBool   ('btSymbFill2',btSymbFillFlag2);
      WriteInteger('btSymbolSize',Round(1000*btSymbolSize/Radius));
      WriteInteger('LastFileType',btLastfiletype);
      WriteInteger('BT_Increment',BT_Increment);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Invers', true);
      WriteInteger('LastFileType',InvLastFileType);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\NDA', true);
      WriteInteger('NDATheta',NDATheta);
      WriteInteger('LastFileType',NDALastFileType);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\Dihedra', true);
      WriteInteger('DihSymbolsize',Round(1000*DihSymbolsize/Radius));
      WriteInteger('DihSymbFillColorP',DihSymbFillColorP);
      WriteInteger('DihSymbFillColorT',DihSymbFillColorT);
      WriteInteger('DihPenColor',DihPenColor);
      //WriteInteger('DihPenStyle',LongInt(DihPenStyle));
      WriteInteger('DihPenWidth',DihPenWidth);
      WriteBool   ('DihSymbFill',DihSymbFillFlag);
      WriteBool   ('DihSymbFill2',DihSymbFillFlag2);
      WriteInteger('LastFileType',TecMainWin.DihOpenDialog.FilterIndex);
    CloseKey;
    OpenKey('Software\GeoCompute\TectonicsFP\'+TFPRegEntryVersion+'\CustomColors', true);
      For i:=0 to Colordialog1.CustomColors.Count-1 do
        WriteString('Color'+Chr(65+i),Copy(Colordialog1.CustomColors.Strings[i],
          8, Length(Colordialog1.CustomColors.Strings[i])));
    CloseKey;
  finally
    free;
  end;
  if SetForm<>nil then Setform.close;
  if ContObjInspectIsOpen then ContDlgFrm.close;
  if Inspectorform<>nil then InspectorForm.close;
  for I := MDIChildCount-1 downto 0 do MDIChildren[I].Close;
  Application.Helpcommand(HELP_QUIT,0);
end;


procedure TTecMainWin.ArrangeAllRollups(Sender: TObject);
var i, n: Integer;
Begin
  n:=0;
  For I:=0 to 2 do
  IF TFPRollups[i]<>nil then with TFPRollups[i] do
  begin
    If not minimized then Minimize1Click(Sender);
    Left:=TecMainWin.Left+TecMainWin.Width-Width;
    Top:=TecMainWin.Top+TecMainWin.Height-TecMainWin.ClientHeight+Panel2.Height-1+n*(RollupPanelHeight+6);
    rollupx:= left;
    rollupy:= top;
    case rollupname of
    rt_properties: begin
      plotpropleft:=Left;
      plotproptop:=Top;
    end;
    rt_settings: begin
      SetFormLeft:=Left;
      SetFormtop:=Top;
    end;
    rt_results: begin
      ResInspleft:=Left;
      ResInsptop:=Top;
    end;
    end;
    aligned:=true;
    inc(n);
  end;
end;

procedure TTecMainWin.ArrangeAllRollups2(Sender: TObject);
var i, n: Integer;
Begin
  n:=0;
  For I:=0 to 2 do
  IF (TFPRollups[i]<>nil) and TFPRollups[i].aligned then with TFPRollups[i] do
  begin
    Left:=TecMainWin.Left+TecMainWin.Width-Width;
    Top:=TecMainWin.Top+TecMainWin.Height-TecMainWin.ClientHeight+Panel2.Height-1+n*(RollupPanelHeight+6);
    rollupx:= left;
    rollupy:= top;
    case rollupname of
    rt_properties: begin
      plotpropleft:=Left;
      plotproptop:=Top;
    end;
    rt_settings: begin
      SetFormLeft:=Left;
      SetFormtop:=Top;
    end;
    rt_results: begin
      ResInspleft:=Left;
      ResInsptop:=Top;
    end;
    end;
    aligned:=true;
    inc(n);
  end;
end;


procedure TTecMainWin.ArrangeRollups(Sender: TObject);
var myrollups: TRollups;
    i, n: Integer;
begin
  MyRollups[0]:=TRollup(Sender);
  MyRollups[0].Aligned:=true;
  n:=1;
  For I:=0 to 2 do
    If (TFPRollups[i]<>TRollup(Sender)) then
    begin
      MyRollups[n]:=TFPRollups[i];
      inc(n);
    end;
  n:=0;
  For I:=0 to 2 do
  begin
    TFPRollups[i]:=MyRollups[i];
    If TFPRollups[i]<>nil then TFPRollups[i].rindex:=i;
    If MyRollups[i]<>nil then
      if MyRollups[i].Aligned then
      begin
        MyRollups[i].left:=Left+Width-MyRollups[i].Width;
        MyRollups[i].Top:=Top+Height-ClientHeight+Panel2.Height-1+n*(RollupPanelHeight+6);
        MyRollups[i].Rollupx:=MyRollups[i].left;
        MyRollups[i].Rollupy:=MyRollups[i].top;
        MyRollups[i].aligned:=true;
        inc(n);
      end;
  end;
end;


procedure TTecMainWin.FormMove(var Message: TWMMove);
begin
  If (WindowState<>wsMaximized) and not maximizing then
  begin
    if InspectorForm<>nil then ArrangeRollup(InspectorForm);
    if SetForm<>nil then ArrangeRollup(SetForm);
    if ResInsp<>nil then ArrangeRollup(ResInsp);
  end
  else if maximizing then
  begin
    If InspectorForm<>nil then
      If InspectorForm.Aligned then ArrangeRollup(InspectorForm);
    If SetForm<>nil then
      If SetForm.Aligned then ArrangeRollup(SetForm);
    If ResInsp<>nil then
      If ResInsp.Aligned then ArrangeRollup(ResInsp);
  end;
  tecmainleft:=left;
  tecmaintop:=top;
  inherited;
end;

procedure TTecMainWin.SysCommand(var Message: TWMSyscommand);
begin
  case message.cmdType of
    SC_MAXIMIZE, SC_RESTORE:  maximizing:=true;
  end;
  inherited;
end;

procedure TTecMainWin.AcceptDragFiles(var Message: TWMDropFiles);
var Count, Size, i: integer;
    Buffer: Pchar;
begin
  Count:=DragQueryFile(Message.Drop, $FFFFFFFF, Buffer, Size);
  try
    For i:=0 to Count-1 do
    begin
      Size:=DragQueryFile(Message.Drop, i, nil, Size);
      GetMem(Buffer, Size+2);
      try
        DragQueryFile(Message.Drop, i, Buffer, Size+1);
        CallMDIChild(Application, Buffer);
      finally
        FreeMem(Buffer, Size+2);
      end;
    end;
  finally
    Message.Result:=0;
    DragFinish(Message.Drop);
  end;
  inherited;
end;

procedure TTecMainWin.ArrangeRollup(FRollup: TForm);
var FAligned: Boolean;
begin
  FAligned:=(FRollup as TRollup).Aligned;
  if (FRollup.left<=left+width-FRollup.width) and not maximizing then
    FRollup.left:=left+FRollup.left-tecmainleft
  else FRollup.left:=left+width-FRollup.width;
  FRollup.top:=top+FRollup.top-tecmaintop;
  (FRollup as TRollup).Aligned:=FAligned;
  (FRollup as TRollup).Rollupx:= FRollup.left;
  (FRollup as TRollup).Rollupy:= FRollup.top;
  case (FRollup as TRollup).rollupname of
    rt_properties: begin
      plotpropleft:=(FRollup as TRollup).Left;
      plotproptop:=(FRollup as TRollup).Top;
    end;
    rt_settings: begin
      SetFormLeft:=(FRollup as TRollup).Left;
      SetFormtop:=(FRollup as TRollup).Top;
    end;
    rt_results: begin
      ResInspleft:=(FRollup as TRollup).Left;
      ResInsptop:=(FRollup as TRollup).Top;
    end;
    end;
end;

procedure TTecMainWin.CloseAllRollups(Sender: TObject);
begin
  If Setform<>nil then Setform.close;
  If InspectorForm<>nil then Inspectorform.close;
  IF ResInsp<>nil then ResInsp.Close;
end;

procedure TTecMainWin.SwapRollups(Sender: TObject);
var myrollups: TRollups;
    i, n: Integer;
begin
  MyRollups[2]:=TRollup(Sender);
  n:=0;
  For I:=0 to 2 do
    If (TFPRollups[i]<>TRollup(Sender)) then
    begin
      MyRollups[n]:=TFPRollups[i];
      inc(n);
    end;
  n:=0;
  For I:=0 to 2 do
  begin
    tfprollups[i]:=myrollups[i];
    if tfprollups[i]<> nil then tfprollups[i].rindex:=i;
    If MyRollups[i]<>nil then
      if MyRollups[i].Aligned then
      begin
        If (not MyRollups[i].minimized) and (MyRollups[i]<>TRollup(Sender)) and
          MyRollups[2].Aligned then MyRollups[i].Minimize1Click(Sender);
        MyRollups[i].left:=Left+Width-MyRollups[i].Width;
        MyRollups[i].Top:=Top+Height-ClientHeight+Panel2.Height-1+n*(RollupPanelHeight+6);
        MyRollups[i].Rollupx:=MyRollups[i].left;
        MyRollups[i].Rollupy:=MyRollups[i].top;
        MyRollups[i].aligned:=true;
        inc(n);
      end;
  end;
end;


procedure TTecMainWin.SwapRollups2(Sender: TObject);
var myrollups: TRollups;
    i, j, n: Integer;
begin
  n:=0;
  for i:=0 to 2 do
    If tfprollups[i]<> nil then
      if tfpRollups[i].aligned then inc(n);
  MyRollups[n-1]:=TRollup(Sender);
  j:=n-1;
  n:=0;
  For I:=0 to j do
    If (TFPRollups[i]<>TRollup(Sender)) then
    begin
      MyRollups[n]:=TFPRollups[i];
      inc(n);
    end;
  n:=0;
  For I:=0 to j do
  begin
    tfprollups[i]:=myrollups[i];
    if tfprollups[i]<> nil then tfprollups[i].rindex:=i;
    If MyRollups[i]<>nil then
      if MyRollups[i].Aligned then
      begin
        If (not MyRollups[i].minimized) and (MyRollups[i]<>TRollup(Sender)) and
          MyRollups[j].Aligned then MyRollups[i].Minimize1Click(Sender);
        MyRollups[i].left:=Left+Width-MyRollups[i].Width;
        MyRollups[i].Top:=Top+Height-ClientHeight+Panel2.Height-1+n*(RollupPanelHeight+6);
        MyRollups[i].Rollupx:=MyRollups[i].left;
        MyRollups[i].Rollupy:=MyRollups[i].top;
        MyRollups[i].aligned:=true;
        inc(n);
      end;
  end;
end;

function TTecMainWin.CheckExtension(Sender: TObject; FFilename: String; var FExtension: TExtension): Boolean;
var FFailed: Boolean;
begin
  Result:=true;
  FExtension := ExtractExtension(FFilename);
  IF (Sender=Greatcircles1) or (Sender=PiPlot1) or (Sender=DipLines1) then
  begin
    case Fextension of
    ERR, PLN: begin
      FExtension:=PLN;
      exit;
    end;
    else FFailed:= true;
    end;
  end;
  IF (Sender=Lineations1) then
  begin
    case Fextension of
    ERR, LIN: begin
      FExtension:=LIN;
      exit;
    end;
    else FFailed:= true;
    end;
  end;
  IF (Sender=Angelier1) or (Sender=Hoeppener1) then
  begin
    case Fextension of
    ERR: FFailed:=false;
    COR, FPL, HOE, PEF, PEK, STF, PTF: exit;
    else FFailed:= true;
    end;
  end;
  IF (Sender=PTaxesPlot) then
  begin
    case Fextension of
    ERR, PTF: begin
      FExtension:=PTF;
      exit;
    end;
    else FFailed:= true;
    end;
  end;
  IF (Sender=Flucthistogram1) or (Sender=MohrCircle1) then
  begin
    case Fextension of
    ERR: FFailed:=false;
    INV, NDF: exit;
    else FFailed:= true;
    end;
  end;
  IF (Sender=Stressaxes1) or (Sender=Dihedra3) then
  begin
    case Fextension of
    ERR: FFailed:=false;
    INV, NDF, DIH: exit;
    else FFailed:= true;
    end;
  end;
  IF Sender=Rotate1 then
  begin
    case Fextension of
    ERR: FFailed:=false;
    COR, FPL, PEF, PEK, HOE, STF, LIN, PLN: exit;
    else FFailed:= true;
    end;
  end;
  IF (Sender=Fisherstatistics1) or (Sender=RandCenter1) or (Sender=Binghamstatistics1) then
  begin
    case Fextension of
    ERR: FFailed:=false;
    PLN, LIN: exit;
    else FFailed:= true;
    end;
  end;
  IF Sender=ContourPlot1 then
  begin
    case Fextension of
    ERR: FFailed:=false;
    COR, FPL, PTF, PLN, LIN: exit;
    else FFailed:= true;
    end;
  end;
  IF Sender=RoseDiagram1 then
  begin
    case Fextension of
    ERR: FFailed:=false;
    COR, FPL, PTF, LIN, PLN, AZI: exit;
    else FFailed:= true;
    end;
  end;
  IF (Sender=PTAxes1) or (Sender=Invers1) or (Sender=NDA1) or (Sender=Dihedra1) then
  begin
    case Fextension of
    ERR: FFailed:=false;
    COR, PTF, HOE, STF, PEK: exit;
    else FFailed:= true;
    end;
  end;
  IF Sender=OD2ndVersion1 then
  begin
    case Fextension of
      ERR: FFailed:=false;
      FPL, COR, PTF, HOE, STF, PEF, PEK, PLN, LIN, AZI: exit;
      else FFailed:= true;
    end;
  end;
  IF FFailed then
  begin
    MessageDlg(ExtractFileName(FFilename)+#13#10+'File type not applicable for this operation. Processing stopped.', mtError, [mbOk, mbHelp], 210);
    Result:=false;
    exit;
  end;
  with TFileTypeDlg.Create(Application) do
  begin
    Checkbox1.visible:=false;
    Button1.visible:=false;
    Edit1.visible:=false;
    Caption:=ExtractFilename(FFilename)+': Please specify file type.';
    IF (Sender=Angelier1) or (Sender=Hoeppener1) then
    begin
      RadioGroup1.Items[0]:='TFP fault planes';
      RadioGroup1.Items[1]:='TFP pt-axes';
      RadioGroup1.Items[2]:='Sperner hoe-format';
      RadioGroup1.Items[3]:='Sperner stf-format';
      RadioGroup1.Items.Add('Peresson fault planes');
    end;
    IF (Sender=Flucthistogram1) or (Sender=MohrCircle1) then
    begin
      RadioGroup1.Items[0]:='TFP Invers files';
      RadioGroup1.Items[1]:='TFP NDA-files';
      RadioGroup1.Items.Delete(3);
      RadioGroup1.Items.Delete(2);
    end;
    IF Sender=Sigma1 then
    begin
      RadioGroup1.Items[0]:='TFP Invers files';
      RadioGroup1.Items[1]:='TFP NDA-files';
      RadioGroup1.Items[2]:='TFP Dihedra-files';
      RadioGroup1.Items.Delete(3);
    end;
    IF Sender=Rotate1 then
    begin
      RadioGroup1.Items[0]:='TFP fault planes';
      RadioGroup1.Items[1]:='TFP planes';
      RadioGroup1.Items[2]:='TFP lineations';
      RadioGroup1.Items[3]:='Sperner hoe-format';
      RadioGroup1.Items.Add('Sperner stf-format');
      RadioGroup1.Items.Add('Peresson fault planes');
    end;
    IF (Sender=Fisherstatistics1) or (Sender=RandCenter1) or (Sender=Binghamstatistics1) then
    begin
      RadioGroup1.Items[0]:='TFP planes';
      RadioGroup1.Items[1]:='TFP lineations';
      RadioGroup1.Items.Delete(3);
      RadioGroup1.Items.Delete(2);
    end;
    IF Sender=RoseDiagram1 then
    begin
      RadioGroup1.Items[0]:='TFP fault planes';
      RadioGroup1.Items[1]:='TFP pt-axes';
      RadioGroup1.Items[2]:='TFP planes';
      RadioGroup1.Items[3]:='TFP lineations';
      RadioGroup1.Items.Add('TFP azimuthal data');
    end;
    IF Sender=ContourPlot1 then
    begin
      RadioGroup1.Items[0]:='TFP fault planes';
      RadioGroup1.Items[1]:='TFP pt-axes';
      RadioGroup1.Items[2]:='TFP planes';
      RadioGroup1.Items[3]:='TFP lineations';
    end;
    IF (Sender=PTAxes1) or (Sender=Invers1) or (Sender=NDA1) or (Sender=Dihedra1) then
    begin
      RadioGroup1.Items[0]:='TFP corrrected fault planes';
      RadioGroup1.Items[1]:='TFP pt-axes';
      RadioGroup1.Items[2]:='Sperner hoe-format';
      RadioGroup1.Items[3]:='Sperner stf-format';
      RadioGroup1.Items.Add('Peresson corrected fault planes');
    end;
    IF Sender=OD2ndVersion1 then
    begin
      RadioGroup1.Items[0]:='TFP fault planes';
      RadioGroup1.Items[1]:='TFP pt-axes';
      RadioGroup1.Items[2]:='TFP planes';
      RadioGroup1.Items[3]:='TFP lineations';
      RadioGroup1.Items.Add('Sperner hoe-format');
      RadioGroup1.Items.Add('Sperner stf-format');
      RadioGroup1.Items.Add('Peresson fault planes');
    end;
    Showmodal;
    If modalresult = mrOK then
    begin
      IF Sender=OD2ndVersion1 then
        case RadioGroup1.ItemIndex of
        0: FExtension:=fpl;
        1: FExtension:=ptf;
        2: FExtension:=pln;
        3: FExtension:=lin;
        4: FExtension:=hoe;
        5: FExtension:=stf;
        6: FExtension:=pek;
      end;
      IF (Sender=Angelier1) or (Sender=Hoeppener1) then
        case RadioGroup1.ItemIndex of
        0: FExtension:=fpl;
        1: FExtension:=ptf;
        2: FExtension:=hoe;
        3: FExtension:=stf;
        4: FExtension:=pek;
      end;
      IF (Sender=Flucthistogram1) or (Sender=MohrCircle1) then
      case RadioGroup1.ItemIndex of
        0: FExtension:=INV;
        1: FExtension:=NDF;
      end;
      IF Sender=Sigma1 then
      case RadioGroup1.ItemIndex of
        0: FExtension:=INV;
        1: FExtension:=NDF;
        2: FExtension:=DIH;
      end;
      IF Sender=Rotate1 then
        case RadioGroup1.ItemIndex of
        0: FExtension:=fpl;
        1: FExtension:=pln;
        2: FExtension:=lin;
        3: FExtension:=hoe;
        4: FExtension:=stf;
        5: FExtension:=pek;
      end;
      IF (Sender=Fisherstatistics1) or (Sender=RandCenter1) or (Sender=Binghamstatistics1) then
      case RadioGroup1.ItemIndex of
        0: FExtension:=PLN;
        1: FExtension:=LIN;
      end;
      IF (Sender=RoseDiagram1) or (Sender=ContourPlot1) then
        case RadioGroup1.ItemIndex of
        0: FExtension:=fpl;
        1: FExtension:=ptf;
        2: FExtension:=pln;
        3: FExtension:=lin;
        4: FExtension:=azi;
      end;
      IF (Sender=PTAxes1) or (Sender=Invers1) or (Sender=NDA1) or (Sender=Dihedra1) then
        case RadioGroup1.ItemIndex of
          0: FExtension:=cor;
          1: FExtension:=ptf;
          2: FExtension:=hoe;
          3: FExtension:=stf;
          4: FExtension:=pek;
        end;
      Result:=true;
    end else Result:=false;
   //finally
   //free;
  end;
end;

procedure TTecMainWin.Plotproperties1Click(Sender: TObject);
begin
  Screen.Cursor:=crHourGlass;
  If Inspectorform<>nil then
    Inspectorform.close
  else
  begin
    Inspectorform:=TInspectorForm.Create(nil);
    Inspectorform.visible:=true;
    TecMainWin.BringToFront;
  end;
  Screen.Cursor:=crDefault;
end;

procedure TTecMainWin.Scaling1Click(Sender: TObject);
begin
  If SetForm<>nil then setform.Close
  else
  begin
    SetForm:=Tsetform.Create(nil);
    setform.visible:=true;
  end;
  TecMainWin.Bringtofront;
end;

procedure TTecMainWin.Numresults1Click(Sender: TObject);
begin
  Screen.Cursor:=crHourGlass;
  If Resinsp<>nil then
    Resinsp.close
  else
  begin
    Resinsp:=TResinsp.Create(nil);
    Resinsp.visible:=true;
    TecMainWin.BringToFront;
  end;
  Screen.Cursor:=crDefault;
end;

procedure TTecMainWin.Rollups1Click(Sender: TObject);
begin
  Scaling1.checked:=SetForm<>nil;
  PlotProperties1.Checked:=Inspectorform<>nil;
  NumResults1.Checked:=ResInsp<>nil;
end;

procedure TTecMainWin.Help2Click(Sender: TObject);
var FreddyQueen: Integer;
begin
  If PopupMenu1.PopupComponent is TWinControl then FreddyQueen:=(PopupMenu1.PopupComponent as TWinControl).HelpContext
  else FreddyQueen:=PopupMenu1.PopupComponent.Tag;
  Application.HelpContext(FreddyQueen);
end;

procedure TTecMainWin.SaveBtnClick(Sender: TObject); //Save/Export
begin
  If ActiveMDIChild is TEdit2Frm then (ActiveMDIChild as TEdit2Frm).Save1Click(Sender)
  else If ActiveMDIChild is TEditForm then (ActiveMDIChild as TEditForm).Save1Click(Sender)
  else if ActiveMDIChild is TLHWin then if (ActiveMDIChild as TLHWin).SaveAs1.Enabled then
    (ActiveMDIChild as TLHWin).SaveAs1Click(Sender);
end;

procedure TTecMainWin.PrintBtnClick(Sender: TObject); //Print
begin
  If ActiveMDIChild is TEditForm then (ActiveMDIChild as TEditForm).Print1Click(Sender)
  else if ActiveMDIChild is TLHWin then (ActiveMDIChild as TLHWin).Print1Click(Sender)
  else if ActiveMDIChild is TEdit2Frm then (ActiveMDIChild as TEdit2Frm).Print1Click(Sender);
end;

procedure TTecMainWin.CutBtnClick(Sender: TObject); //Cut
begin
  If ActiveMDIChild is TEditForm then with (ActiveMDIChild as TEditForm) do
  begin
    CutToClipboard(Sender);
    UpdateMenus(Sender);
  end
  else If ActiveMDIChild is TEdit2Frm then with (ActiveMDIChild as TEdit2Frm) do
  begin
    EditCutClick(Sender);
    //EditEditClick(Sender);
  end
end;

procedure TTecMainWin.CopyBtnClick(Sender: TObject);
begin
  If ActiveMDIChild is TEditForm then with (ActiveMDIChild as TEditForm) do
  begin
    CopyToClipboard(Sender);
    UpdateMenus(Sender);
  end
  else If ActiveMDIChild is TEdit2Frm then with (ActiveMDIChild as TEdit2Frm) do
  begin
    EditCopyClick(Sender);
  end
  else if ActiveMDIChild is TLHWin then with (ActiveMDIChild as TLHWin) do
  begin
    Copy1Click(Sender);
    Edit1Click(Sender);
  end;
end;

procedure TTecMainWin.PasteBtnClick(Sender: TObject);
begin
  If ActiveMDIChild is TEditForm then with (ActiveMDIChild as TEditForm) do
  begin
    PasteFormClipboard(Sender);
    UpdateMenus(Sender);
  end
  else If ActiveMDIChild is TEdit2Frm then with (ActiveMDIChild as TEdit2Frm) do
  begin
    EditPasteClick(Sender);
    //EditEditClick(Sender);
  end
  else if ActiveMDIChild is TLHWin then with (ActiveMDIChild as TLHWin) do
  begin
    Paste1Click(Sender);
    Edit1Click(Sender);
  end;
end;

procedure TTecMainWin.UndoBtnClick(Sender: TObject);
begin
  If ActiveMDIChild is TEditForm then with (ActiveMDIChild as TEditForm) do
  begin
    Undo1Click(Sender);
    UpdateMenus(Sender);
  end
  else If ActiveMDIChild is TEdit2Frm then with (ActiveMDIChild as TEdit2Frm) do
  begin
    Undo1Click(Sender);
    EditEditClick(Sender);
  end
  else If ActiveMDIChild is TLHWin then with (ActiveMDIChild as TLHWin) do
  begin
    Undo1Click(Sender);
    Edit1Click(Sender);
  end;
end;

procedure TTecMainWin.RedoBtnClick(Sender: TObject);
begin
  If ActiveMDIChild is TEditForm then with (ActiveMDIChild as TEditForm) do
  begin
    Redo1Click(Sender);
    UpdateMenus(Sender);
  end
  else If ActiveMDIChild is TEdit2Frm then with (ActiveMDIChild as TEdit2Frm) do
  begin
    Redo1Click(Sender);
    EditEditClick(Sender);
  end;                                    
end;

procedure TTecMainWin.PopupMenu1Popup(Sender: TObject);
begin
  if PopupMenu1.PopupComponent is TWincontrol then
    if (PopupMenu1.PopupComponent as TWinControl).HelpContext=0 then Help2.Enabled:=false
    else Help2.Enabled:=true
  else
    if PopupMenu1.PopupComponent.Tag=0 then Help2.Enabled:=false
    else Help2.Enabled:=true;
end;

function TTecMainWin.AppHelp(Command: Word; Data: Longint; var CallHelp: Boolean): Boolean;
begin
  case command of
    HELP_CONTEXTPOPUP:
      if Data>=500 then
      begin
        CallHelp:=false;
        Application.HelpContext(Data);
      end
      else if Data=0 then CallHelp:=False;
    HELP_CONTEXT:
      if Data<500 then
      begin
        CallHelp:=False;
        If Data<>0 then Application.HelpCommand(HELP_CONTEXTPOPUP, Data)
      end;
    end;
end;

procedure TTecMainWin.PrintSetup1Click(Sender: TObject);
begin
  PrinterSetupDialog1.Execute;
end;

procedure TTecMainWin.AppDeactivate(Sender: TObject);
begin
  Application.NormalizeTopMosts;
end;

procedure TTecMainWin.AppActivate(Sender: TObject);
begin
  Application.RestoreTopMosts;
end;

procedure TTecMainWin.Pole1Click(Sender: TObject);
var aAzimuth, aPlunge: Single;
    aPlotType: TPlot;
begin
  If ActiveMDIChild<>nil then with ActiveMDIChild as TLHWin do
  begin
    If Sender=Pole1 then
    begin
      aPlotType:=pt_PiPlot;
      aAzimuth:=45;
      aPlunge:=40;
    end;
    AddSingleDataset(0, 0, aAzimuth, aPlunge, 0, aPlotType);
  end;
end;

procedure TTecMainWin.Openplot1Click(Sender: TObject);
begin
  If Sender=FryMethod1 then with PlotOpenDialog do
  begin
    Filter:='Bitmaps (*.bmp)|*.bmp';
    Title:='Strain Analysis: Fry-Method';
  end;
  if not PlotOpenDialog.Execute then Exit;
  with TWMFWin.Create(Application) do
    FormCreate2(Sender, PlotOpenDialog.Filename);
end;

procedure TTecMainWin.DDEDrawAngelierExecuteMacro(Sender: TObject;
  Msg: TStrings);
begin
    MessageBeep(0);
    //if Msg.Strings[0] = 'Beep' then MessageBeep(0);
end;

procedure TTecMainWin.TectonicsFPintheWeb1Click(Sender: TObject);
var MyStartupInfo: TStartupInfo;
    MyProcessInformation: TProcessInformation;
    Dummy1, Dummy2: String;
begin
  Dummy2:='';
  With TRegistry.Create do
  try
    RootKey:=HKEY_LOCAL_MACHINE;
    OpenKey('SOFTWARE\GeoCompute\TectonicsFP', False);
      If Sender=TectonicsFPintheWeb1 then
      begin
        If ValueExists('Home') then Dummy1:= ReadString('Home')
        else Dummy1:='http://go.to/TectonicsFP';
      end
      else
      begin
        If ValueExists('Support') then Dummy1:=ReadString('Support')
        else Dummy1:='http://homepage.uibk.ac.at/homepage/c715/c71508/support';
      end;
    CloseKey;
    RootKey:=HKEY_CLASSES_ROOT;
    OpenKey('http\shell\open\command', false);
      Dummy2:=ReadString('');
    CloseKey;
      Dummy2:=copy(Dummy2, 0, Pos('.exe', Dummy2)+ 4);
  finally
    Free;
  end;
  If (Dummy1<>'') and (Dummy2<>'') then
  begin
    with MyStartupInfo do
    begin
      lpreserved:=nil;
      lpdesktop:=nil;
      lptitle:=nil;
      cbreserved2:=0;
      lpreserved2:=nil;
    end;
    If not CreateProcess(nil, PChar(dummy2+'  '+dummy1), nil, nil, False, 0, nil,
           nil, MyStartupInfo, MyProcessInformation ) then
      MessageDlg('Can not Start Browser.', mtError, [mbOk], 0); //added 20000430
    //ShellExecute(Handle, 'open', PChar('framedem.exe'), '', PChar('E:\Michi\THTMLViewer\Neu\'), SW_SHOW);
  end;
end;

initialization
  {}
finalization
  if HTFPMutex<>0 then CloseHandle(HTFPMutex);
end.
