unit Types;

interface
uses Windows, Menus, Dialogs, SysUtils, Forms, Printers, Controls, math, Graphics, IniFiles, Registry, Messages;

const
  capTitle: string = 'TectonicsFP (Open)'; //this version name will be shown in the title form on program startup
  capVer: string = '1.79.1171'; //this version number will be shown in the about box
  VerDate: string ='2019-12-31';  //Creation date of this compilation
  offVer: String ='1.7.9';  //this version number will be shown in the title form on program startup
  CopyrightMessage: String = 'TectonicsFP was written by Franz Reiter and Peter Acs, 1996-2019';
  capHP: String = 'https://github.com/freiter/TectonicsFP';
  const TFPRegEntryVersion: string ='1.0'; //used to access registry and ini-file entries
  RecognizeTectonicData: Boolean = False;  //for version 2 only: Recognize type of tectonic data in file


  //****************************************************************************************
  //2020-01-04 Copy
  //*****************************************************************************************

  //Size of lower-hemisphere plots in memory-metafile
  WindowExt = 600;
  CenterX = WindowExt div 2;
  CenterY: Integer = CenterX;
  Radius: word  = WindowExt div 5 * 2;
  //Position of label for lower-hemisphere plots in memory-metafile
  Labelleft: Integer = 10;
  Labeltop: Integer = 10;
  {Size of Windows-Metafiles for lower-hemisphere plots:}
  //**************WMF******************
  MetafileInch: Integer = 72;
  MetafileWidth: Integer = 600;
  MetafileHeight: Integer = 600;
  //**************EMF*******************
  MFileInch: Integer = 720;
  MFileWidth: Integer = 600;
  MFileHeight: Integer = 600;
  //Constants for Angelier-plot in manual sorting-form
  LinearCircleRate: Single = 0.016;
  LengthRate1: Single = 0.07;       //Rate of length of arrow related to radius of diagram
  LengthRate2: Single= 0.05;        //Rate of length or arrowhead related to radius of diagram
  //constants for angelier-plots
  ArrowAngle: Integer = 20;          //Half opening angle of arrowhead
  //for more see TecMainWin.FormCreate
  arrow: Integer =25;
  //consts for minimum and maximum size of child-windows
  MDIMinWidth: Integer = 620;
  MDIMinHeight: Integer = 450;
  //Rollups
  RollupPanelHeight: Integer = 21;
  RollupHeight: Integer = 27;
  RollupWidth: Integer = 113;
  ResInspMinHeight: Integer = 40;
  //sense definitions
  se_unknown: Integer = 0;
  se_reverse: Integer = 1;
  se_normal: Integer = 2;
  se_dextral: Integer = 3;
  se_sinistral: Integer = 4;
  se_HugoUnknown: Integer = 5;


  //Quality definitions
  quality_0: Integer =0; //if user does not use quality criteria
  quality_1: Integer =1;
  quality_2: Integer =2;
  quality_3: Integer =3;
  quality_4: Integer =4;

type
  TRollupType = (rt_properties, rt_settings, rt_results);
  TPlotSymbol = (syCross, syCircle, syStar, syTriangle, syRectangle, syRhombohedron, syNumber);
  TExtension = (AZI, COR, ERR, FPL, HOE, INV, LIN, PEF, PEK, PLN, PTF, NDF, STF, TXT, DIH);
  TPlot=(pt_Angelier, pt_GreatCircle, pt_SmallCircle, pt_Lineation, pt_PiPlot, pt_DipLine,
         pt_PTPlot, pt_SigmaTensor, pt_LambdaTensor,pt_SigmaDihedra, pt_LambdaDihedra,
         pt_Bingham, pt_MeanVectFisher, pt_MeanVectRC, pt_Hoeppener, pt_MohrSigma,
         pt_MohrLambda, pt_RoseCenter, pt_RoseCorner, pt_Contour,pt_Dihedra,
         pt_Fluhist, pt_LowHem, pt_Rotate, pt_SortMan, pt_BestTheta, pt_void, pt_GraphicsFromDisk);
  TTectonicData=(td_BeddingPlane, td_Foliation1, td_Foliation2, td_Foliation3, td_FoldAxialPlane,
         td_FoldAxis, td_CrenulationCleavage, td_StretchingLineation, td_TensionFibre,
         td_Fault, td_FaultPlaneOnly, td_FaultOnBeddingPlane,
         td_unknown);
  //TAngleArray = Array [1..85 div BT_increment] of Integer;
  T2Sing1by3= Array [1..3,1..3] of Single;
  T1Int1by3=array[1..3] of Integer;
  T1Sing1by2=array[1..2] of Single;
  T1Sing1by3=array[1..3] of Single;
  Tstring15=string[15];
  Tstring4=string[4];
  TCvalArray = array[1..16] of Single;
  TOpenPointArray = array[0..0] of TPoint;
  POpenPointArray = ^TOpenPointArray;
  TZeroIntArray = Array[0..0] of Integer;
  PZeroIntArray = ^TZeroIntArray;
  TZeroSingleArray = Array[0..0] of Single;
  PZeroSingleArray = ^TZeroSingleArray;
  T2dZeroSingleArray = Array[0..0,0..0] of Single;
  P2dZeroSingleArray = ^T2dZeroSingleArray;
  PPointChainRecord = ^TPointChainRecord;

  TPointChainRecord = Record
    fPoint: TPoint;
    NextPoint: PPointChainRecord;
  end;

  TLocationInfo = record
       X, Y, Z, LocName, Lithology, Formation, Remarks, Date, Age, TectUnit: String;
  end;

  DInfoType =(DFillColor, DLineColor, DPenStyle);

  TDragGraphicsStyle = record
    IsValid: Boolean;
    DColor: TColor;
    DInfoType: DInfoType;
  end;

  TEMFPict = packed record
     HEMF: HENHMETAFILE;
  end;
  PEMFPict = ^TEMFPict;

  TFluMohrFPLData = record
    FMSense, FMFluctuation: Integer;
    FMDipDir, FMDip: Single;
  end;

  TFluMohrFPLDataArray = array[0..0] of TFluMohrFPLData;
  PFluMohrFPLDataArray =^TFluMohrFPLDataArray;

  //Exceptions
  EFileReadError = Class(Exception)
  public
    LineNumber: Integer;
    constructor Create(const Msg: string; FLinenumber: Integer);
  end;
TSelection = record
    StartPos: word;
    EndPos : word;
  end;

TTFPRegistry = class(TRegistry)
protected
  FKeyReadonly: Boolean;
  FCurrentKey: HKEY;
  destructor Destroy;
public
  procedure CloseKey;
  function KeyExists(const Key: string): Boolean;
  function ValueExists(const Name: string): Boolean;
  function OpenKey(const Key: string; CanCreate: Boolean): Boolean;
  function ReadInteger(const Name: string; Default: Longint): Longint;
  function ReadFloat(const Name: string; Default: Double): Double;
  function ReadBool(const Name: string; Default: Boolean): Boolean;
  function ReadString(const Name: string; Default: String): String;
end;

function  Min(X, Y: Integer): Integer;
function  Min2(X, Y: Single): Single;
function  Max(X, Y: Integer): Integer;
function  Max2(X, Y: Single): Single;
function  Sgn(X: Single): Integer;
function  ArcCos2(X: Single): Single;
function  ArcSin2(X: Single): Single;
function  FloatToString(FValue: Double; digits1,digits2: Integer): String;
function  TrimString(FString: String; digits1, digits2: Integer): String;
procedure CorrectLineation(DipDir, Dip, Azimuth, Plunge: Single;
          var nAzimuth, nPlunge: Single);
procedure CorrectSense(var FSense: Integer; FDipDir, FDip, FAzimuth, FPlunge: Single);
procedure SnDxToUpDn(var FSense: Integer; FDipDir, FDip, FAzimuth, FPlunge: Single);
function  GetPlotAsString(FPlotType: TPlot; FExtension: TExtension; fstressaxis: Integer): String;
procedure PolCar (Azimuth, Dip: Single; var c1,c2,c3: double);
procedure CarPol (c1,c2,c3: double; var Azimuth, Dip: Single);
function  ConvertSense(FSense : Integer; FPitch : Single): Integer;
function  GetSenseAsString(FSense: Integer): String;
function  DihedralAngle(fAzimuth1, fDip1, fAzimuth2, fDip2: Single; fLineation: Boolean): Single;
Function ReplaceStr(fOldStr, fNewStr, fStr: String): String;
PROCEDURE WavelengthToRGB(CONST Wavelength:  Integer; VAR R,G,B:  BYTE);

//***********Standard messages******************
type TErrorCode = (ecUndefFile, ecFileUsed, ecFileNotExists);
function ReadError(Sender: TObject; FFilename: string; Fz: Integer): word;
function CommonError(Sender: TObject; FFilename: string; ErrorCode : TErrorCode): word;
function GetPrintRect: TRect;

//***************global variables*************************
var EditSaveFilterIndexStore,ArrowHeadLength, LastOptPage, tecmainleft, tecmaintop,
  GlobalLHPlots: Integer;
  ArrowLength1, ArrowLength2,Sqrt2 : Single;

  GlobalClipbMFH, HTFPMutex: THandle;

  DragGraphicsStyle: TDragGraphicsStyle;

  TFPOpenMessage, TFPThreads: Integer;

  TFPVersion,TFPserialnumber, Licensee, company, SmallComment, E2LastLocInfo,
  SortLastOutputPath: String;

  GlobalFailed, NetFlag, E2TakeLastLocInfo : Boolean;

  PrintLowerHemiSize, ClipbLowerHemiSize, GlobalArrowStyle, QualitylevelsUsed,
  PlotPropLeft, PlotPropTop, PlotPropWidth, SetFormLeft, SetFormTop, SetFormWidth,
  ResInspLeft, ResInspTop, ResInspWidth, ResInspHeight, CorrError: Integer;

  UntitledCounter, PolySegments, SmallPolySegments: Integer;

  WriteWmfGlobal, QualityGlobal, globallhnumbering, globallhLabel, globalLHBackOn: Boolean;

  BT_Increment, NDATheta, ptTheta, GlobalRollupsOpen: Integer;

  MetafileMMWidth,MetafileMMHeight: LongInt;

  ContObjInspectIsOpen: boolean;
  //double declaration removed bugfix 080313
  tfpListSeparator, {DecimalSeparator,} tfpDecimalSeparator, FileCommentSeparator, FileListSeparator: Char;

  DegHoepArrowAngle,HoepArrowLength, HoepArrowheadLength, AngSSArrowLength,
  AngSSArrowHeadLength,DegAngSSArrowAngle,
  DegAngNRArrowAngle, AngNRArrowLength, AngNRArrowHeadLength,
  GlobStoreAzim, GlobStoreDip : Single;

  ptSymbFillFlag, ptSymbFillFlag2, ptCalcMeanVect, AngSymbFillFlag, HoepSymbfillFlag,
  Pisymbfillflag,DipSymbFillFlag, LinSymbfillFlag,
  FishSymbFillFlag, FishShowConfCone, FishShowSpherDistr, BingSymbFillFlag, SigTenSymbFillFlag, SigTenSymbFillFlag2,
  SigDihSymbFillFlag, SigDihSymbFillFlag2, MohrSymbFillFlag, FluHSymbFillFlag,
  RoseSymbFillFlag, RoseCenter, RoseDipAlso, RosePLBipol, RoseAziBipol, RoseFPlane,
  ContAutoInt, ContGauss, ContFPlane, ContShowNet, BtSymbFillFlag, BTSymbFillFlag2,
  SmallSymbfillFlag, SigmaDihedraOn,
  ptBestTheta, DihSymbFillFlag, DihSymbFillFlag2, E2BeepOn, E2AutoFill,
  ResInspShowLocation, ResInspShowX, ResInspShowY, ResInspShowZ, ResInspShowDate,
  ResInspShowLithology, ResInspShowFormation, ResInspShowAge, ResInspShowTectUnit,
  ResInspShowRemarks, ResInspAligned, ResInspMinimized: Boolean;

  ptSymbolSize, PiSymbolSize, DipSymbolSize, LinSymbolSize, AngSymbolSize, Hoepsymbradius,BingSymbolSize,
  FishSymbolSize,SigTenSymbolSize, MohrSymbolSize, BtSymbolSize, SmallSymbolSize,
  DihSymbolSize: Single;

  ContSymbolSize: Integer;

  LinSymbfillColor, LinPenColor, PolePenColor, FishSymbfillColor, AngSymbfillcolor,
  AngPenColor, HoepSymbfillcolor,HoepPenColor, GreatPenColor, PiSymbFillColor, PiPenColor,
  DipSymbFillColor, DipPenColor,
  BingSymbFillColor, BingPenColor,FishPenColor, FishPen2Color, ptPenColor,PTSymbFillColorP,
  PTSymbFillColorT, SigTenPenColor, SigTenSymbFillColorP,SigTenSymbFillColorT, SigDihPenColor,
  SigDihSymbFillColorP,SigDihSymbFillColorT,DihSymbFillColorP,DihSymbFillColorT,DihPenColor,
  MohrPenColor, MohrSymbFillColor, FluHPenColor, FluHSymbFillColor, RoseSymbFillColor,
  RosePenColor, ContPenColor, BtPenColorP, BtPenColorT, BtSymbFillColorP, BtSymbFillColorT,
  SmallPenColor, SmallSymbFillColor, GlobalNetColor, GlobalbackColor : TColor;

  AngPenStyle, GreatPenStyle, BingPenStyle, FishPenStyle, MohrPenStyle, FluHPenStyle,
  RosePenStyle, ContPenStyle, SmallPenStyle: TPenStyle;

  ptPenWidth, FishPenWidth,BingPenWidth,AngPenWidth, GreatPenWidth, PiPenWidth,
  DipPenWidth, LinPenWidth, HoepPenWidth, NorthPenWidth, SigTenPenWidth,
  SigDihPenWidth, MohrPenWidth, FluHPenWidth, FluHIntervals,
  AxesPenWidth, GreatLastFiletype, PiLastFileType, DipLastFileType, AngLastFiletype, HoepLastFileType,
  SigmaLastFiletype, MohrLastFiletype, FluHLastfiletype, RosePenWidth, RoseAziInt,
  RoseDipInt, RosePTUse, ContPenWidth, ContGridD, ContPTUse,
  BtPenWidth, NDALastfiletype, INVLastfiletype, BTLastfiletype, LastRotAngle,
  LastRotAxAzim, LastRotAxPlunge, SortFPLPlotType, SortPTFPlotType, SortPLNPlotType,
  RotFPLPlotType, RotPLNPlotType, SmallPenWidth, SmallAperture, SmallAzimuth, SmallPlunge,
  FishLastConf, ExportLastFileType, DihPenWidth, E2LastFileType2, E2LastParentFileType,
  leftpagemargin, toppagemargin, rightpagemargin, bottompagemargin: Integer; //page margins in mmm

  printfontsize: Single; //

  BingSymbType, PiSymbType, DipSymbType, LinSymbType, FishSymbType, SmallSymbType: TPlotSymbol;

  TFPMetafile, TFPEnhMetafile, TFPText: Word;

  ContValues: TCValArray;

implementation

uses rotate;


//************TRegistry2 Object*******************

destructor TTFPRegistry.Destroy;
begin
  CloseKey;
  inherited Destroy;
end;

function TTFPRegistry.ValueExists(const Name: string): Boolean;
var RegDataType, BufSize: Integer;
begin
  if FKeyReadOnly then
     Result:= RegQueryValueEx(FCurrentKey, PChar(Name), nil, @RegDataType, nil,
            @BufSize)=ERROR_SUCCESS
  else
    Result:=inherited ValueExists(Name);
end;

function TTFPRegistry.KeyExists(const Key: string): Boolean;
var keydummy: HKey;
begin
  Result:=inherited KeyExists(Key);
  if Result then exit;
  Result:=RegOpenKeyEx(HKEY_LOCAL_MACHINE, PChar(Key), 0, KEY_EXECUTE, keydummy)=ERROR_SUCCESS;
end;

function TTFPRegistry.OpenKey(const Key: string; CanCreate: Boolean): Boolean;
begin
  Result:=inherited OpenKey(Key, CanCreate);
  if Result then FKeyReadOnly:=false
  else
  begin   //no creation of keys possible!!
    FKeyReadonly:=true;
    Result:=RegOpenKeyEx(HKEY_LOCAL_MACHINE, PChar(Key), 0, KEY_EXECUTE, FCurrentKey) = ERROR_SUCCESS;
  end;
end;

procedure TTFPRegistry.CloseKey;
begin
  if FKeyReadOnly then
  begin
    if FCurrentKey<>0 then
    begin
      RegClosekey(FCurrentKey);
      FCurrentKey:=0;
    end;
  end
  else inherited Closekey;
end;


function TTFPRegistry.ReadInteger(const Name: string; Default: Longint): Longint;
var RegDataType, BufSize: Integer;
begin
  If FKeyReadonly then
  try
    if ValueExists(Name) then
      if RegQueryValueEx(FCurrentKey, PChar(Name), nil, @RegDataType, nil, @BufSize) = ERROR_SUCCESS then
      begin
        BufSize:=SizeOf(Integer);
        if RegQueryValueEx(FCurrentKey, PChar(Name), nil, @RegDataType, @Result,
            @BufSize) <> ERROR_SUCCESS then raise ERegistryException.CreateResFmt(0, [FCurrentKey]);
      end
      else Result:=Default
    else Result:=Default;
  except
    on ERegistryException do Result:=Default;
  end
  else
  try
    If ValueExists(Name) then Result:=inherited ReadInteger(Name)
    else Result:=Default;
  except
    on ERegistryException do result:=default;
  end;
end;

function TTFPRegistry.ReadFloat(const Name: string; Default: Double): Double;
var RegDataType, BufSize: Integer;
begin
  If FKeyReadonly then
  try
    if ValueExists(Name) then
      if RegQueryValueEx(FCurrentKey, PChar(Name), nil, @RegDataType, nil, @BufSize) = ERROR_SUCCESS then
      begin
        BufSize:=SizeOf(Double);
        if RegQueryValueEx(FCurrentKey, PChar(Name), nil, @RegDataType, @Result,
            @BufSize) <> ERROR_SUCCESS then raise ERegistryException.CreateResFmt(0, [FCurrentKey]);
      end
      else Result:=Default
    else Result:=Default;
  except
    on ERegistryException do Result:=Default;
  end
  else
  try
    If ValueExists(Name) then Result:=inherited ReadFloat(Name)
    else Result:=Default;
  except
    on ERegistryException do Result:=Default;
  end;
end;

function TTFPRegistry.ReadBool(const Name: string; Default: Boolean): Boolean;
var RegDataType, BufSize, dummy: Integer;
begin
  If FKeyReadonly then
  try
    if ValueExists(Name) then
      if RegQueryValueEx(FCurrentKey, PChar(Name), nil, @RegDataType, nil, @BufSize) = ERROR_SUCCESS then
      begin
        BufSize:=SizeOf(Integer);
        if RegQueryValueEx(FCurrentKey, PChar(Name), nil, @RegDataType, @Dummy,
            @BufSize) <> ERROR_SUCCESS then raise ERegistryException.CreateResFmt(0, [FCurrentKey]);
        Result := dummy <> 0;
      end
      else Result:=Default
    else Result:=Default;
  except
    on ERegistryException do Result:=Default;
  end
  else
  try
    if ValueExists(Name) then
      Result:=inherited ReadBool(Name)
    else Result:=Default;
  except
    on ERegistryException do Result:=Default;
  end;
end;

function TTFPRegistry.ReadString(const Name: string; Default: String): String;
var RegDataType, BufSize: Integer;
begin
  If FKeyReadonly then
  try
    if ValueExists(Name) then
      if RegQueryValueEx(FCurrentKey, PChar(Name), nil, @RegDataType, nil, @BufSize) = ERROR_SUCCESS then
      begin
        SetString(Result, nil, BufSize);
        if RegQueryValueEx(FCurrentKey, PChar(Name), nil, @RegDataType, PByte(PChar(Result)),
            @BufSize) <> ERROR_SUCCESS then raise ERegistryException.CreateResFmt(0, [FCurrentKey]);
        SetLength(Result, StrLen(PChar(Result)));
      end
      else Result:=Default
    else Result:=Default;
  except
    on ERegistryException do Result:=Default;
  end
  else
  try
    if ValueExists(Name) then Result:=inherited ReadString(Name)
    else Result:=Default;
  except
    on ERegistryException do Result:=Default;
  end;
end;


//********************TFP-defined Exceptions*************************
constructor EFileReadError.Create(const Msg: string; FLinenumber: Integer);
begin
  inherited create(Msg);
  Linenumber:=FLinenumber;
end;

{********************Mathematical functions*******************************}
function Sgn(X: Single): Integer;
begin
  If x>0 then Sgn := 1 else
  begin
    if x=0 then Sgn:=0 else Sgn:= -1;
  end;
end;

function Min(X, Y: Integer): Integer;
begin
  if X > Y then Min := Y else Min := X;
end;

function Max(X, Y: Integer): Integer;
begin
  if X > Y then Max := x else Max := y;
end;

function Min2(X, Y: Single): Single;
begin
  if X > Y then Min2 := Y else Min2 := X;
end;

function Max2(X, Y: Single): Single;
begin
  if X > Y then Max2 := x else Max2 := y;
end;

function ArcCos2(X: Single):Single;
begin
  IF x<>0 then
  begin
    if x>0 then Result:=ArcTan(Sqrt(1-x*x)/x)
    else Result:=Pi+ArcTan(Sqrt(1-x*x)/x);
  end
  else Result:=PI/2;
end;

function ArcSin2(X: Single): Single;
begin
  IF x<>1 then
  begin
    if x>0 then Result:=ArcTan(x/Sqrt(1-x*x))
    else Result:=2*Pi-ArcTan(x/Sqrt(1-x*x));
  end
  else Result:=PI/2;
end;

function FloatToString(FValue: Double; digits1, digits2: Integer): String;
var i, actualdigits: Integer;
    negative: boolean;
begin
  Result:='';
  if fvalue<0 then
  begin
    negative:=true;
    fvalue:=abs(fvalue);
  end else negative:=false;
  actualdigits:=round(Frac(FValue)*IntPower(10,digits2));
  if actualdigits>=IntPower(10,digits2) then
  begin
    FValue:=FValue+1;
    actualdigits:=0;
  end;
  if actualdigits<>0 then
  begin
    for i:=1 to digits2-trunc(log10(actualdigits)+1) do
      Result:=Result+'0';
    Result:=Result+IntToStr(actualdigits);
  end
  else
    for i:=1 to digits2 do Result:=Result+'0';
  If digits2<>0 then Result:='.'+Result;
  if trunc(fvalue)<>0 then
  begin
    Result:=IntToStr(Trunc(FValue))+Result;
    for i:=1 to digits1-trunc(log10(FValue)+1) do
      Result:='0'+Result;
  end
  else
    for i:=1 to digits1 do Result:='0'+Result;
  if negative then result:='-'+result;
end;

function TrimString(FString: String; digits1, digits2: Integer): String;
var i, actualdigits, err: Integer;
    negative: boolean;
    fvalue: Single;
begin
  Result:='';
  val(FString, fvalue, err);
  if err<>0 then exit;
  if fvalue<0 then
  begin
    negative:=true;
    fvalue:=abs(fvalue);
  end else negative:=false;
  actualdigits:=round(Frac(FValue)*IntPower(10,digits2));
  if actualdigits>=IntPower(10,digits2) then
  begin
    FValue:=FValue+1;
    actualdigits:=0;
  end;
  if actualdigits<>0 then
  begin
    for i:=1 to digits2-trunc(log10(actualdigits)+1) do
      Result:=Result+'0';
    Result:=Result+IntToStr(actualdigits);
  end
  else
    for i:=1 to digits2 do Result:=Result+' ';
  If digits2<>0 then
  begin
    if actualdigits=0 then
      Result:=' '+Result
    else Result:='.'+Result;
  end;
  if trunc(fvalue)<>0 then
  begin
    Result:=IntToStr(Trunc(FValue))+Result;
    for i:=1 to digits1-trunc(log10(FValue)+1) do
      Result:=' '+Result;
  end
  else
  begin
    Result:='0'+Result;
    for i:=2 to digits1 do Result:=' '+Result;
  end;  
  if negative then result:='-'+result
  else if digits2=0 then result:=' '+result;
end;

//**************************Error messages*********************

//failure of file (lines can not be converted correctly)
function ReadError(Sender: TObject; FFilename: string; Fz: Integer): word;
var z: Integer;
begin
  Screen.Cursor := CrDefault;
  If Sender is TRotForm then z:=Fz+1 else z:=Fz;
  Result:= MessageDlg('Error reading '+ExtractFilename(FFilename)+', dataset '
                      +IntToStr(z)+'!'+#10#13+' Processing stopped.',
                      mtError,[mbOk], 0);
end;

function CommonError(Sender: TObject; FFilename: string; ErrorCode : TErrorCode): word;
begin
  Screen.Cursor := CrDefault;
  case ErrorCode of
    ecUndefFile: result:= MessageDlg(ExtractFilename(FFilename)+' can not be processed.'
                        +#10#13+'Undefined file type.',mtError,[mbOk], 0);
    ecFileUsed: result:= MessageDlg('Can not open '+FFilename+' !'#10#13+
                 'Processing stopped. File might be in use by another application.',
                 mtError,[mbOk], 0);
   ecFileNotExists: result:= MessageDlg(FFilename+' does not exist!'#10#13+
                 'Processing stopped.',
                 mtError,[mbOk], 0);
  end;
end;

procedure CorrectLineation(DipDir, Dip, Azimuth, Plunge: Single;
          var nAzimuth, nPlunge: Single);
var I: Integer;
    A1, A2, A3, f1, f2, PX, PY, PZ, AA: Single;
begin
  IF (dipdir= azimuth) AND (dip= plunge) THEN azimuth:= azimuth- 0.01;
  FOR I := 1 TO 2 do
  begin
    dipdir:= trunc(dipdir + 180) MOD 360 + frac(dipdir);
    dip:= 90 - dip;
    A1:= DegToRad(dipdir);
    A2:= DegToRad(azimuth);
    f1:= DegToRad(dip);
    f2:= DegToRad(plunge);
    If I=2 then
    begin
      A1:= A1 + PI;
      A2:=DegToRad(nazimuth)+Pi;
      f1:= PI/2 - f1;
      f2:=Pi/2-DegToRad(nplunge);
    end;
    PX:= Sin(A1)*Cos(f1)*Sin(f2)- Sin(f1)*Sin(A2)*Cos(f2);
    PY:= Sin(f1)*Cos(A2)*Cos(f2)- Cos(A1)*Cos(f1)*Sin(f2);
    PZ:= Cos(A1)*Cos(f1)*Sin(A2)*Cos(f2)- Sin(A1)*Cos(f1)*Cos(A2)*Cos(f2);
    IF PZ< 0 THEN
    begin
      PX:= -PX;
      PY:= -PY;
      PZ:= -PZ;
    end;
    IF PX<> 0 THEN AA:= ArcTan(PY/PX)
      Else IF PY> 0 THEN AA:= PI/2
        Else IF PY< 0 THEN AA:= 3*PI/2;
    nplunge:= RadToDeg(ArcTan(PZ/Sqrt((Sqr(PX)+Sqr(PY)+Sqr(PZ))*
                      (1-Sqr(PZ/Sqrt(Sqr(PX)+Sqr(PY)+Sqr(PZ)))))));
    nazimuth:= RadToDeg(AA);
    IF PX< 0 THEN nazimuth:= nazimuth+ 180;
    IF (PX> 0) AND (PY> 0) THEN nazimuth:= nazimuth- 360;
    if I=1 THEN
    begin
      nazimuth:= nazimuth + 180;
      nplunge:= 90 - nplunge;
    end;
    IF nazimuth > 360 THEN nazimuth:= nazimuth - 360;
    IF nazimuth < 0   THEN nazimuth:= nazimuth + 360;
  end; //for-loop
end;

procedure CorrectSense(var FSense: Integer; FDipDir, FDip, FAzimuth, FPlunge: Single);
begin
  if (FDip>35) and (FPlunge< FDip* 0.3) then
  begin
    if sin(DegToRad(FAzimuth-FDipDir)) >0 then
      Case FSense of
        1: FSense:=4;
        2:  FSense:=3;
      end
    else
      Case FSense of
        1: FSense:=3;
        2:  FSense:=4;
      end;
  end else begin
    if sin(DegToRad(FAzimuth-FDipDir))>0 then
      Case FSense of
        4: FSense:=se_reverse;
        3:   FSense:=se_normal;
      end
    else if sin(DegToRad(FAzimuth-FDipDir))<0 then
      Case FSense of
        3: FSense:=se_reverse;
        4: FSense:=se_normal;
      end;
  end;
end;


procedure SnDxToUpDn(var FSense: Integer; FDipDir, FDip, FAzimuth, FPlunge: Single);
begin
  if sin(DegToRad(FAzimuth-FDipDir))>0 then
    Case FSense of
      4: FSense:=se_reverse;
      3:  FSense:=se_normal;
    end
  else if sin(DegToRad(FAzimuth-FDipDir))<0 then
    Case FSense of
      3: FSense:=se_reverse;
      4:  FSense:=se_normal;
    end;
end;

function GetPlotAsString(FPlotType: TPlot; FExtension: TExtension; fstressaxis: Integer): String;
begin
  case FPlotType of
    pt_GreatCircle: result:='Great circles';
    pt_SmallCircle: result:='Small circle';
    pt_PiPlot: result:='Poles to great circles';
    pt_DipLine: Result:='Dip Lines';
    pt_Lineation: result:='Lineations';
    pt_Angelier: result:='Angelier';
    pt_Hoeppener: result:='Hoeppener';
    pt_ptPlot: Result:= 'pt-axes';
    pt_SigmaDihedra: Result:='Sigma123 - dihedra';
    pt_LambdaDihedra: Result:='Lambda123 - dihedra';
    pt_SigmaTensor: Result:='Sigma123 - tensor';
    pt_LambdaTensor: Result:='Lambda123 - tensor';
    pt_MohrSigma: Result:='Mohr circle';
    pt_MohrLambda: Result:='Mohr circle (strain)';
    pt_FluHist: Result:='Fluctuation histogram';
    pt_MeanVectFisher:
      Case FExtension of
        pln: Result:='Mean vector - planes (Fisher statistics)';
        lin: Result:='Mean vector - lineations (Fisher statistics)';
      end;
    pt_MeanVectRC:
      Case FExtension of
        pln: Result:='Mean vector - planes (R% and center)';
        lin: Result:='Mean vector - lineations (R% and center)';
      end;
    pt_Bingham:
      Case FExtension of
        pln: Result:= 'Eigenvectors (poles to planes)';
        lin: Result:= 'Eigenvectors (lineations)';
      end;
    pt_RoseCenter:
      Case FExtension of
        pln: Result:='Rose-diagram - poles to planes (center to center)';
        lin: Result:='Rose-diagram - lineations (center to center)';
        cor, fpl,ptf: case fstressaxis of
            0: Result:='Rose-diagram - poles to fault planes (center to center)';
            1: Result:='Rose-diagram - fault lineations (center to center)';
            2: Result:='Rose-diagram - p-axes (center to center)';
            3: Result:='Rose-diagram - t-axes (center to center)';
            4: Result:='Rose-diagram - b-axes (center to center)';
          end;
      end;
    pt_RoseCorner:
      Case FExtension of
        pln: Result:='Rose-diagram - poles to planes (corner to corner)';
        lin: Result:='Rose-diagram - lineations (corner to corner)';
        cor, fpl, ptf: case fstressaxis of
            0: Result:='Rose-diagram - poles to fault planes (corner to corner)';
            1: Result:='Rose-diagram - fault lineations (corner to corner)';
            2: Result:='Rose-diagram - p-axes (corner to corner)';
            3: Result:='Rose-diagram - t-axes (corner to corner)';
            4: Result:='Rose-diagram - b-axes (corner to corner)';
          end;
      end;
    pt_Contour: 
      Case FExtension of
        pln: Result:='Contours (poles to planes)';
        lin: Result:='Contours (lineations)';
        cor, fpl, ptf: case fstressaxis of
            0: Result:='Contours (poles to fault planes)';
            1: Result:='Contours (fault lineations)';
            2: Result:='Contours (p-axes)';
            3: Result:='Contours (t-axes)';
            4: Result:='Contours (b-axes)';
          end;
      end;
    pt_BestTheta: Result:='R% versus theta';
    pt_Dihedra: Result:= 'Dihedra (contoured)';
  else Result:='';  
  end;
end;

procedure polcar (Azimuth, Dip: Single; var c1,c2,c3: double);
begin
  c1:=COS(DegToRad(Dip))*SIN(DegToRad(Azimuth));
  c2:=COS(DegToRad(Dip))*COS(DegToRad(Azimuth));
  c3:=-SIN(DegToRad(Dip));
END;

procedure carpol (c1,c2,c3: double; var Azimuth, Dip: Single);
var magnitude, beta, pp1, pp2, cc1, cc2, cc3 : double;
begin
  magnitude := SQRt(Sqr(c1)+Sqr(c2)+Sqr(c3));
  cc1:=c1/magnitude;
  cc2:=c2/magnitude;
  cc3:=c3/magnitude;
  IF (cc1=0) AND (cc2=0) THEN
  begin
    Azimuth:=0;
    Dip:=90;
  end
  ELSE
  begin
    pp2:=SQRt(Sqr(cc1)+Sqr(cc2));
    if pp2<0.000000001 then beta:=Pi/2  //bugfix 990523
    else beta:= ArcTaN(cc3/SQRt(Sqr(cc1)+Sqr(cc2)));
    IF cc2=0 THEN
       IF cc1*cc3>0 THEN Azimuth:= 270 ELSE Azimuth:= 90
    ELSE
    begin
      pp1:=(2-SGN(cc1)-SGN(cc1)*SGN(cc2))*PI/2+ArcTan(cc1/cc2);
      IF beta > 0 THEN pp1 := pp1+PI;
      IF pp1 > 2*PI THEN pp1:=pp1-2*PI;
      Azimuth:= RadToDeg(pp1);
    END;
    Dip:= RadToDeg(ABS(beta));
  END;
END;

Function ConvertSense(FSense : Integer; FPitch : Single): Integer;
begin
  case FSense of
    3: if FPitch < 0 THEN ConvertSense := 2
       else IF FPitch > 0 THEN ConvertSense := 1
       else ConvertSense:=0;
    4: if FPitch < 0 THEN ConvertSense := 1
       else IF FPitch > 0 THEN ConvertSense := 2
       else ConvertSense:=0;
    else ConvertSense:=FSense;
  end;
end;

function GetSenseAsString(FSense: Integer): String;
begin
  Case FSense of
    0: Result:='--';
    1: Result:='up';
    2: Result:='dn';
    3: Result:='dx';
    4: Result:='sn';
    5: Result:='--';
    else Result:='';
  end;
end;

function DihedralAngle(fAzimuth1, fDip1, fAzimuth2, fDip2: Single; fLineation: Boolean): Single;
var BAW,X1,Y1,Z1,X2,Y2,Z2, Azimuth1, Azimuth2, Dip1, Dip2: Single;
begin
  if fLineation then
  begin
    Azimuth1:=fAzimuth1;
    Dip1:=fDip1;
    Azimuth2:=fAzimuth2;
    Dip2:=fDip2;
  end
  else
  begin
    Azimuth1:=trunc(fAzimuth1+180) mod 360 + frac(Azimuth1);
    Dip1:=90-fDip1;
    Azimuth2:=trunc(fAzimuth2+180) mod 360 + frac(Azimuth2);
    Dip2:=90-fDip2;
  end;
  X1 := COS(DegToRad(Azimuth2))*COS(DegToRad(Dip2));
  y1 := SIN(DegToRad(Azimuth2))*COS(DegToRad(Dip2));
  z1 := SIN(DegToRad(Dip2));
  X2 := COS(DegToRad(Azimuth1))*COS(DegToRad(Dip1));
  y2 := SIN(DegToRad(Azimuth1))*COS(DegToRad(Dip1));
  z2 := SIN(DegToRad(Dip1));
  BAW := (X1*X2+y1*y2+z1*z2)/(SQRT(Sqr(X1)+sqr(y1)+sqr(z1))*SQRT(sqr(X2)+sqr(y2)+sqr(z2)));
  //Result:=RadToDeg(Pi/2-ArcTan2(BAW,SQRT(-BAW*BAW+1)));
  Result:=90-Abs(RadToDeg(ArcTan2(BAW,SQRT(1-BAW*BAW))));
  Result := Trunc(Result) mod 90+ Frac(Result);
end;

function GetPrintRect: TRect;
begin
  With Result do
  begin
    Left:=Round(LeftpageMargin-(GetDeviceCaps(printer.handle,PHYSICALOFFSETX)/GetDeviceCaps(printer.handle,LOGPIXELSX))*25.4);
    Top:=Round(-ToppageMargin+(GetDeviceCaps(printer.handle,PHYSICALOFFSETY)/GetDeviceCaps(printer.handle,LOGPIXELSY))*25.4);
    Right:=Left+round(GetDeviceCaps(printer.handle, PHYSICALWIDTH)/GetDeviceCaps(printer.handle,LOGPIXELSX)*25.4)-leftpagemargin-rightpagemargin;
    Bottom:=Top-round(GetDeviceCaps(printer.handle, PHYSICALHEIGHT)/GetDeviceCaps(printer.handle,LOGPIXELSY)*25.4)+toppagemargin+bottompagemargin;
    Left:=Left*10;
    Top:=Top*10;
    Right:=Right*10;
    Bottom:=Bottom*10;
  end;
end;

Function ReplaceStr(fOldStr, fNewStr, fStr: String): String;
var fPos: Integer;
begin
  Result:=fStr;
  fPos:= Pos(fOldStr, fStr);
  if fPos <> 0 then
  begin
    Delete(Result, fPos, Length(fOldStr));
    Insert(fNewStr, Result, fPos);
  end;
end;

PROCEDURE WavelengthToRGB(CONST Wavelength:  Integer;
                          VAR R,G,B:  BYTE);

  CONST
    Gamma        =   0.80;
    IntensityMax = 255;

  VAR
    Blue   :  DOUBLE;
    factor :  DOUBLE;
    Green  :  DOUBLE;
    Red    :  DOUBLE;

  FUNCTION Adjust(CONST Color, Factor:  DOUBLE):  INTEGER;
  BEGIN
    IF   Color = 0.0
    THEN RESULT := 0     // Don't want 0^x = 1 for x <> 0
    ELSE RESULT := ROUND(IntensityMax * Power(Color * Factor, Gamma))
  END {Adjust};

BEGIN

  CASE TRUNC(Wavelength) OF
    380..439:
      BEGIN
        Red   := -(Wavelength - 440) / (440 - 380);
        Green := 0.0;
        Blue  := 1.0
      END;

    440..489:
      BEGIN
        Red   := 0.0;
        Green := (Wavelength - 440) / (490 - 440);
        Blue  := 1.0
      END;

    490..509:
      BEGIN
        Red   := 0.0;
        Green := 1.0;
        Blue  := -(Wavelength - 510) / (510 - 490)
      END;

    510..579:
      BEGIN
        Red   := (Wavelength - 510) / (580 - 510);
        Green := 1.0;
        Blue  := 0.0
      END;

    580..644:
      BEGIN
        Red   := 1.0;
        Green := -(Wavelength - 645) / (645 - 580);
        Blue  := 0.0
      END;

    645..780:
      BEGIN
        Red   := 1.0;
        Green := 0.0;
        Blue  := 0.0
      END;

    ELSE
      Red   := 0.0;
      Green := 0.0;
      Blue  := 0.0
  END;

  // Let the intensity fall off near the vision limits
  CASE TRUNC(Wavelength) OF
    380..419:  factor := 0.3 + 0.7*(Wavelength - 380) / (420 - 380);
    420..700:  factor := 1.0;
    701..780:  factor := 0.3 + 0.7*(780 - Wavelength) / (780 - 700)
    ELSE       factor := 0.0
  END;

  R := Adjust(Red,   Factor);
  G := Adjust(Green, Factor);
  B := Adjust(Blue,  Factor)
END {WavelengthToRGB};

end.
