unit Fileops;

interface
uses Types, SysUtils, Dialogs, Forms, Controls, Graphics, Windows, Classes;
type

 TGDIObjType = (gdi_Pen, gdi_Brush, gdi_Font, gdi_void);

 PPenList = ^TPenlist;

 TPenList = record
   GDIObj : HGDIObj;
   GDIObjType: TGDIObjType;
   Pen: TLogPen;
   Brush: TLogBrush;
   Font: TLogFont;
   next: PPenList;
end;

TGDIOBJ = record
   GDIObjType: TGDIObjType;
   Pen: TLogPen;
   Brush: TLogBrush;
   Font: TLogFont;
 end;

TGDIOBJTable = Array[0..0] of TGDIOBJ;
PGDIOBJTable = ^TGDIOBJTable;

TVectorGraphics = class(TObject)
    IsDXF, notfirstKnoten: Boolean;
    Root, AktuellerKnoten, NeuerKnoten: PPenList;
    NoofGDIObj: Integer;
    MyOBJTable : PGDIObjTable;
    CurrentPenColor: TColor;
    CurrentPenStyle: Integer;
    f: Textfile;
  public
    procedure MoveTo(X,Y: Integer); virtual; abstract;
    procedure Lineto(X,Y: Integer); virtual; abstract;
    Procedure Circle(X,Y,R: Integer); virtual; abstract;
    Procedure Rectangle(X1,Y1,X2,Y2: Integer); virtual; abstract;
    Procedure Text(X,Y: Integer; TextString: String); virtual; abstract;
    Procedure SetPenstyle(MyPen: TLogPen); virtual; abstract;
    procedure SelectObject(x: Integer); virtual; abstract;
    procedure DeleteObject(x: Integer); virtual; abstract;
    procedure close; virtual;
    procedure ParamAsTextOut(Param: integer);
  end;

TDXFFile = class(TVectorGraphics)
   DXFilename, linestring: String;
   g: Textfile;
   CurrentX,CurrentY,DXFHeight,DXFWidth, Layer, TextHeight: Integer;
 protected
   procedure Section(Sectionname: String);
   procedure Endsec;
   procedure Variable(Varname: String);
   procedure DXFHeader;
   procedure DXFTables;
   procedure DXFBlocks;
   procedure DXFEntities;
   procedure CoordinateOut(CoordType, Value: Integer);
   procedure Entity(EntityName: String);
   procedure SetLayer;
 public
   procedure Open(AFilename: String; AHeight, AWidth: Integer);
   procedure Close; override;
   procedure Point(X,Y: Integer);
   procedure MoveTo(X,Y: Integer); override;
   procedure Lineto(X,Y: Integer); override;
   Procedure Circle(X,Y,R: Integer); override;
   Procedure Rectangle(X1,Y1,X2,Y2: Integer); override;
   Procedure BeginPolyLine(Closed: Boolean);
   Procedure Vertex(X,Y: Integer);
   Procedure SeqEnd;
   Procedure Text(X,Y: Integer; TextString: String); override;
   Procedure SetPenstyle(MyPen: TLogPen); override;
   procedure SelectObject(x:Integer); override;
   procedure DeleteObject(x:Integer); override;
 end;

  THPGLFile = class(TVectorGraphics)
   HPGLFilename: String;
   ScaleFactor: Single;
 public
   procedure open(AFilename: String; HPGLHeight, HPGLWidth: Integer);
   procedure close; override;
   procedure MoveTo(X,Y: Integer); override;
   procedure LineTo(X,Y: Integer); override;
   Procedure Circle(X,Y,R: Integer); override;
   Procedure Rectangle(X1,Y1,X2,Y2: Integer); override;
   Procedure Text(X,Y: Integer; TextString: String); override;
   Procedure SetPenstyle(MyPen: TLogPen); override;
   procedure SelectObject(x:Integer); override;
   procedure DeleteObject(x:Integer); override;
 end;

//function getinidir:String;
function ExtractExtension(const AFilename : string): TExtension;
function IsTFPFileFormat(FFilename: String): Boolean;
function CombineSenseQuality(FSense, FQuality: Integer):Integer;
function ReadSingle (var F: TextFile; var Value :single): integer;
function ReadSinglePeresson (var F: TextFile; var Value: single): integer;
function ParseQuality(var FSense, FQuality: Integer ): boolean;
procedure ReadFPLDataset(var f: textfile; var FSense, FQuality: Integer; var FDipDir, FDip, FAzimuth, FPlunge: Single;
                         var failed, NoComment: boolean; FExtension: TExtension; var FComment: String);
procedure ReadFPLFile (FFileName: String; FExtension: TExtension; var PFSense, PFQuality: PZeroIntArray;
                   var PFDipDir, PFDip, PFAzimuth, PFPlunge: PZeroSingleArray;
                   var failed: boolean; var n: integer; var IOError: boolean);
procedure ReadPLNDataset(var f: textfile; var FDipDir, FDip: Single; var failed, Nocomment: boolean; var FComment: String);
procedure ReadPTFDataset(var f: textfile; var FSense, FQuality: Integer; var FDipDir,FDip,FAzimuth,FPlunge, FAzimB,FPlungeB,
                         FAzimP,FPlungeP, FAzimT,FPlungeT, FPitch: Single; var FBew: Integer; var Failed, NoComment: boolean);
function ReadSigma123(var F : TextFile; var FSigmaAzimuth, FSigmaPlunge : T1Sing1by3;
                      var FStressRatio: Single; var z, FDatasetsTot, FDatasetsSki : integer): Boolean;
procedure ReadFluMohrFPLData(var f: textfile; var FSense: Integer; var FDipDir, FDip: Single;
                    var FFluctuation: Integer; var failed, Finished: boolean);
procedure ReadSenseErrFromINVNDAFile(var f: textfile; var FSense, FFluctuation: Integer; var failed, finished : boolean);
procedure ReadAZIDataset(var f: textfile; var FAzimuth: Single; var failed, NoComment: boolean; var FComment: String);
procedure ManageSaveDialog(var Filename : String; var FGraphicsFile : String;
          var saveflag : boolean; var ext : TString4; writewmf: boolean);
function GetLocInfo(const AFilename: String): TLocationInfo;
function LocInfoToFile(const AFilename: String; ALocationInfo: TLocationInfo): Boolean;

implementation
uses draw;

function GetLocInfo(const AFilename: String): TLocationInfo;
var f: textfile;
    dummy : String;
    dummy2: String[1];
begin
  With Result do
  begin
    x:='';
    y:='';
    z:='';
    LocName:='';
    Lithology:='';
    Formation:='';
    Date:='';
    Remarks:='';
    Age:='';
    TectUnit:='';
  end;
  AssignFile(F, AFilename);
  try
    Reset(f);
    dummy:='';
    while not eof(f) do with Result do
    begin
      //for unix-based text: #$A only is not recognized by delphi as eoln-marker
      {dummy2:='';
      dummy:='';
      read(f,dummy2);
      repeat
        if dummy2<>#$A then dummy:=dummy+dummy2;
        read(f,dummy2);
      until (dummy2=#$A);}
      readln(f, dummy);
      if pos('X=', Dummy)<>0 then x:=Copy(Dummy, Pos('X=', Dummy)+Length('X='), Length(Dummy));
      if pos('Y=', Dummy)<>0 then y:=Copy(Dummy, Pos('Y=', Dummy)+Length('Y='), Length(Dummy));
      if pos('Z=', Dummy)<>0 then z:=Copy(Dummy, Pos('Z=', Dummy)+Length('Z='), Length(Dummy));
      if pos('LocName=', Dummy)<>0 then LocName:=Copy(Dummy, Pos('LocName=', Dummy)+Length('LocName='), Length(Dummy));
      if pos('Lithology=', Dummy)<>0 then Lithology:=Copy(Dummy, Pos('Lithology=', Dummy)+Length('Lithology='), Length(Dummy));
      if pos('Formation=', Dummy)<>0 then Formation:=Copy(Dummy, Pos('Formation=', Dummy)+Length('Formation='), Length(Dummy));
      if pos('Date=', Dummy)<>0 then Date:=Copy(Dummy, Pos('Date=', Dummy)+Length('Date='), Length(Dummy));
      if pos('Remarks=', Dummy)<>0 then Remarks:=Copy(Dummy, Pos('Remarks=', Dummy)+Length('Remarks='), Length(Dummy));
      if pos('Age=', Dummy)<>0 then Age:=Copy(Dummy, Pos('Age=', Dummy)+Length('Age='), Length(Dummy));
      if pos('TectUnit=', Dummy)<>0 then TectUnit:=Copy(Dummy, Pos('TectUnit=', Dummy)+Length('TectUnit='), Length(Dummy));
    end;
  finally
    CloseFile(f);
  end;
end;


function LocInfoToFile(const AFilename: String; ALocationInfo: TLocationInfo): Boolean;
var g: TextFile;
begin
  Result:=false;
  AssignFile(g, AFilename);
  Rewrite(g);
  with ALocationInfo do
  try
    If X<>'' then
    begin
      writeln(g, FileCommentSeparator, 'X=', X);
      result:=true;
    end;
    If Y<>'' then
    begin
      writeln(g, FileCommentSeparator, 'Y=', Y);
      result:=true;
    end;
    If Z<>'' then
    begin
      writeln(g, FileCommentSeparator, 'Z=', Z);
      result:=true;
    end;
    If LocName<>'' then
    begin
      writeln(g, FileCommentSeparator, 'LocName=',LocName);
      result:=true;
    end;
    If Lithology<>'' then
    begin
      writeln(g, FileCommentSeparator, 'Lithology=',Lithology);
      result:=true;
    end;
    If Formation<>'' then
    begin
      writeln(g, FileCommentSeparator, 'Formation=',Formation);
      result:=true;
    end;
    If Date<>'' then
    begin
      writeln(g, FileCommentSeparator, 'Date=',Date);
      result:=true;
    end;
    If Remarks<>'' then
    begin
      writeln(g, FileCommentSeparator, 'Remarks=',Remarks);
      result:=true;
    end;
    If Age<>'' then
    begin
      writeln(g, FileCommentSeparator, 'Age=',Age);
      result:=true;
    end;
    If TectUnit<>'' then
    begin
      writeln(g, FileCommentSeparator, 'TectUnit=',TectUnit);
      result:=true;
    end;
  finally
    closefile(g);
  end;
end;

{function getinidir: String;
var puffer: PChar;
begin
  puffer:=StrAlloc(MAX_PATH+1);
  GetWindowsDirectory(puffer,MAX_PATH);
  StrCat(Puffer, '\TectFP32.ini');
  result:=string(Puffer);
  If not fileexists(result) then
  begin
    If fileexists(extractfilepath(application.exename)+'\TECTFP32.INI') then
      result:=extractfilepath(application.exename)+'\TECTFP32.INI';
  end;
  StrDispose(puffer);
end;}

function ExtractExtension(const AFilename : string): TExtension;
var  Buffer1 : String[4];
     Buffer2 : Array [0..4] of Char;
     numberstrg : string[2];
     I, ErrCode: Integer;
begin
  Result:=ERR;
  Buffer1:=ExtractFileExt(AFilename);
  If Buffer1='' then exit
  else If CompareText(Buffer1,'.AZI')=0 then Result := AZI
  else If CompareText(Buffer1,'.COR')=0 then Result := COR
  else If CompareText(Buffer1,'.FPL')=0 then Result := FPL
  else If CompareText(Buffer1,'.HOE')=0 then Result := HOE
  else If CompareText(Buffer1,'.STF')=0 then Result := STF
  else If CompareText(Buffer1,'.HF') =0 then Result := PEF
  else If CompareText(Buffer1,'.HK') =0 then Result := PEK
  else If CompareText(Buffer1,'.INV')=0 then Result := INV
  else If CompareText(Buffer1,'.LIN')=0 then Result := LIN
  else If CompareText(Buffer1,'.PLN')=0 then Result := PLN
  else If CompareText(Buffer1,'.TXT')=0 then Result := TXT
  else If CompareText(Buffer1,'.DIH')=0 then Result := DIH
  else
  begin
    StrPCopy (Buffer2, Buffer1);
    if StrLIComp(Buffer2, '.T', 2)=0 then
    begin
      NumberStrg:=Copy(Buffer1,3,2);
      Val(NumberStrg, I, ErrCode);
      if ErrCode = 0 then Result := PTF;
    end
    else
      if StrLIComp(Buffer2, '.N', 2)=0 then
      begin
        NumberStrg:=Copy(Buffer1,3,2);
        Val(NumberStrg, I, ErrCode);
        if ErrCode = 0 then Result := NDF;
      end;
  end;
end;

function IsTFPFileFormat(FFilename: String): Boolean;
begin
  Case ExtractExtension(FFilename) of
    AZI, COR, FPL, INV, LIN, PLN, DIH: Result:=true
  else Result:=false;
  end;  
end;

function ReadSingle (var F: TextFile; var Value: single): integer;
var Ch: Char;
    ValueStr: String[10];
begin
    ValueStr:='';
    Read(F, Ch);
    while (Ch<>FileListSeparator) and not eof(f) do
    begin
      if ch<>' ' then ValueStr := ValueStr + Ch;
      Read(F, Ch);
    end;
    val(ValueStr,Value,Result);
end;

Function ReadSinglePeresson (var F: TextFile; var Value: single): integer;
var Ch: Char;
    ValueStr: String[10];
begin
    ValueStr:='';
    Read(F, Ch);
    while (Ch<>',') and not eof(f) do
    begin
      if ch<>' ' then ValueStr := ValueStr + Ch;
      Read(F, Ch);
    end;
    val(ValueStr,Value,Result);
end;


procedure ReadFPLDataset(var f: textfile; var FSense, FQuality: Integer; var FDipDir, FDip, FAzimuth, FPlunge: Single;
                  var failed, NoComment: boolean; FExtension: TExtension; var FComment: String);

var sestr: string;
    sestr2:string[2];
    err,i: integer;
    Ch: Char;
    s1: String[1];
begin
  NoComment := true;
  failed := true;
  Case FExtension of
    Cor,FPl:       //*************COR,FPL***********
    begin
      err := 0;
      sestr := '';
      read(F, Ch);
      fcomment:='';
      while ((ch=FileCommentSeparator) or (ch=FileListSeparator) or Eoln(F)) and not eof(f) do
      begin
        readln(F);
        If not eof(f) and not Eoln(F) then read(F, Ch);
      end;
      if eof(f) then
      begin
        NoComment := false;
        failed:=false;
        exit;
      end;
      while (Ch<>FileListSeparator) and not eof(f) and not Eoln(F) do
      begin
        if ch<>' ' then sestr := sestr + Ch;
        read(F, Ch);
      end;
      val(sestr, FSense, err);
      if (err <> 0) or eof(f) then exit;
      If not ParseQuality(FSense, FQuality) then exit;
      if (ReadSingle(F, FDipDir) <> 0) or eof(f) then exit;
      if (ReadSingle(F, FDip) <> 0) or eof(f) then exit;
      if ReadSingle(F, FAzimuth) <> 0 then exit;
      Sestr := '';
      Ch:=#0; //bugfix 981109
      while (Ch<>FileCommentSeparator) and (Ch<>FileListSeparator) and not eof(F) and not eoln(f) do
      begin
        read(F, Ch);
        if (Ch<>FileCommentSeparator) and (Ch<>FileListSeparator) and (ch<>' ') then sestr := sestr + Ch;
      end;
      val(sestr, FPlunge, err);
      if err <> 0 then exit;
      If ((Ch=FileCommentSeparator) or (Ch=FileListSeparator)) and not eof(f) then //bugfix 980525
        while not eoln(f) and not eof(f) and (Ch<>#$D) and (Ch<>#$A) do
        begin
          read(F, Ch);
          If (Ch<>#$D) and (Ch<>#$A) then FComment:=FComment+Ch; //bugfix 980926
        end;
      while Eoln(F) and not eof(f) do readln(F);
    end; //case cor,fpl
    HOE, STF: //********************HOE**STF*************
    begin
      try
        readln(f,FDipDir,FDip,FAzimuth,FPlunge,Sestr);
      except
        on EInOutError do exit;
      end;
      FQuality:=0;
      err:=Pos('-', Sestr);
      If err<>0 then FSense:=se_normal
      else
      begin
        err:=Pos('+', Sestr);
        If err<>0 then FSense:=1
        else
        begin
          FSense:=0;
          FQuality:=0;
          failed:=false;
          exit;
        end;
      end;
      Sestr:=Copy(Sestr, err+1, Length(Sestr));
      i:=1;
      s1:=Copy(Sestr,i,1);
      while (s1=' ') or (s1='   ') do
      begin
        i:=i+1;
        s1:=Copy(Sestr,i,1);
      end;
      if (s1>='0') and (s1<='4') then Val(s1,FQuality,err);
      if fquality=4 then fquality:=3;
    end; //case hoe , stf
    PEK,PEF:  //********************PEK,PEF**************
    begin
      Sestr:='';
      err := 0;
      read(F, Ch);
      while (Ch<>',') and not eof(f) do
      begin
        If ch<>' ' then Sestr := Sestr + Ch;
        Read(F, Ch);
      end;
      if eof(f) then
      begin
        NoComment := false;
        failed:=false;
        exit;
      end;
      val(Sestr,FDipDir,err);
      Sestr:='';
      if (err <> 0) or eof(f) then exit;
      if (ReadSinglePeresson(F, FDip) <> 0) or eof(f) then exit;
      if (ReadSinglePeresson(F, FAzimuth) <> 0) or eof(f) then exit;
      if (ReadSinglePeresson(F, FPlunge) <> 0) or eof(f) then exit;
      while not eoln(f) and not eof(f) and (ch<>'"') do read (f,Ch);
      if not eoln(f) and not eof(f) then
      begin
        read (f,Ch);
        If (ch<>'"') and (ch<>' ') then Sestr:=Sestr+ ch;
      end else exit;
      while not eoln(f) and not eof(f) and (ch<>'"') do
      begin
        read (f,Ch);
        If (ch<>'"')  and (ch<>' ') then Sestr:=Sestr+ ch;
      end;
      if not eof(f) then readln(f);
      if (Sestr='R') or (Sestr='RD') or (Sestr='RS') then FSense := 11
      else if (Sestr='r') or (Sestr='rd') or (Sestr='rs') then FSense := 13
      else if (Sestr='N') or (Sestr='ND') or (Sestr='NS') then FSense := 21
      else if (Sestr='n') or (Sestr='nd') or (Sestr='ns') then FSense := 23
      else if (Sestr='S') or (Sestr='SN') or (Sestr='SR') then FSense := 41
      else if (Sestr='s') or (Sestr='sn') or (Sestr='sr') then FSense := 43
      else if (Sestr='D') or (Sestr='DN') or (Sestr='DR') then FSense := 31
      else if (Sestr='d') or (Sestr='dn') or (Sestr='dr') then FSense := 33
      else FSense := 0;
      ParseQuality(FSense, FQuality);
    end; // end case pek,pef
  end; // end case
  failed:=false;
end;

function ParseQuality(var FSense, FQuality: Integer): boolean;
begin
  Result:=true;
  if Fsense < 6 then
  begin
    if Fsense >=0 then FQuality:=quality_0;
  end
  else
   if Fsense >10 then
   begin
     FQuality:=FSense mod 10;
     FSense:=Fsense div 10;
   end
   else Result:=false;
  If FQuality>4 then result:=false;
end;

procedure ReadPLNDataset(var f: textfile; var FDipDir, FDip: Single; var failed, Nocomment: boolean; var FComment: String);
var err : integer;
    sestr : string[10];
    Ch : Char;
begin
  NoComment := true;
  fcomment:='';
  failed := true;
  sestr := '';
  read(F, Ch);
  while ((Ch=FileCommentSeparator) or (Ch=FileListSeparator) or Eoln(F)) and not Eof(F) do
  begin
    readln(F);
    If not Eof(F) and not Eoln(F) then read(F, Ch);
  end;
  if eof(f) then
  begin
    NoComment := false;
    failed:=false;
    exit;
  end;
  while (Ch<>FileListSeparator) and not Eof(F) and not Eoln(F) do
  begin
    if ch<>' ' then sestr := sestr + Ch;
    read(F, Ch);
  end;
  val(sestr,FDipDir,err);
  If err<>0 then exit;
  Sestr:='';
  Ch:=#0; //bugfix 981109
  while (Ch<>FileCommentSeparator) and (Ch<>FileListSeparator) and not Eof(F) and not Eoln(F) do
  begin
    read(F, Ch);
    if (Ch<>FileCommentSeparator) and (Ch<>FileListSeparator) and (ch<>' ') then Sestr := Sestr + Ch;
  end;
  val(Sestr, FDip, err);
  if err <> 0 then exit;
  If ((Ch=FileCommentSeparator) or (Ch=FileListSeparator)) and not eof(f) then //bugfix  980525
  while not eoln(f) and not eof(f) and (Ch<>#13) and (Ch<>#10) do
  begin
    read(F, Ch);
    FComment:=FComment+Ch;
  end;
  while Eoln(F) and not eof(f) do readln(F);
  failed:=false;
end;

procedure ReadFPLFile (FFileName: String; FExtension: TExtension; var PFSense, PFQuality: PZeroIntArray;
                   var PFDipDir, PFDip, PFAzimuth, PFPlunge: PZeroSingleArray;
                   var failed: boolean; var n: integer; var IOError: boolean);
  var
    f: TextFile;
    dummy: integer;
    FSense,FQuality,FDipDir,FDip,FAzimuth,FPlunge : Variant;
    NoComment : Boolean;
    singdummy: single;
    Comment: String;
begin
  IOError:=false;
  try
   //****************************** Retrieve no of datasets first
   AssignFile(F, FFileName);
   Reset(F);
   if Eof(f) then
   begin
     failed:=true;
     CloseFile(F);
     exit;
   end;
   failed:=false;
   n:= 0;
   while not SeekEof(F) and not failed do
   begin
     if FExtension = PTF then
       ReadPTFDataset(f,dummy,dummy,singdummy,singdummy,singdummy,singdummy,
              singdummy,singdummy,singdummy,singdummy,singdummy,singdummy,singdummy,dummy,failed,NoComment)
     else
       ReadFPLDataset(f,dummy, dummy, singdummy, singdummy, singdummy, singdummy,
               failed, NoComment, FExtension, Comment);
     If not failed and Nocomment then
     begin
       if not Seekeof(f) then inc(n);
     end else if not NoComment then dec(n);
   end; //end of while-loop
   CloseFile(F);
   //******************************
   AssignFile(F, FFileName);
   Reset(F);
   if Eof(f) then
   begin
     Failed:=true;
     CloseFile(F);
     Exit;
   end;
   inc(n);
   FSense := VarArrayCreate([0,n], varInteger);
   FQuality := VarArrayCreate([0,n], varInteger);
   FDipDir := VarArrayCreate([0,n], varInteger);
   FDip    := VarArrayCreate([0,n], varInteger);
   FAzimuth := VarArrayCreate([0,n], varInteger);
   FPlunge := VarArrayCreate([0,n], varInteger);
   PFSense:=VarArrayLock(FSense);
   PFQuality:=VarArrayLock(FQuality);
   PFDipDir:=VarArrayLock(FDipDir);
   PFDip:=VarArrayLock(FDip);
   PFAzimuth:=VarArrayLock(FAzimuth);
   PFPlunge:=VarArrayLock(FPlunge);
   failed:=false;
   n:= 0;
   while not SeekEof(F) and not failed do
   begin
     if FExtension = PTF then
       ReadPTFDataset(f,PFSense^[N],PFQuality^[N],PFDipDir^[N],PFDip^[N],PFAzimuth^[N],PFPlunge^[N],
              singdummy,singdummy,singdummy,singdummy,singdummy,singdummy,singdummy,dummy,failed,NoComment)
     else
       ReadFPLDataset(f,PFSense^[N], PFQuality^[N], PFDipDir^[N], PFDip^[N], PFAzimuth^[N], PFPlunge^[N],
               failed, NoComment, FExtension, Comment);
     If not failed and Nocomment then
     begin
       IF PFDip^[N]>= 89.99 THEN PFDip^[N] := 89.99;
       IF PFPlunge^[N]<= 0.01 THEN PFPlunge^[N]:= 0.01;
       IF PFDipDir^[N] = PFAzimuth^[N] THEN PFAzimuth^[N] := PFAzimuth^[N]+0.01;
       if not Seekeof(f) then inc(n);
     end else if not NoComment then dec(n);
   end; {end of while-loop}
   CloseFile(F);
  except   {can not open file}
   On EInOutError do
   begin
     IOError:=True;
     failed:=true;
     Screen.Cursor:=crDefault;
     MessageDlg('Can not open '+FFilename+' !'#10#13+
                'Processing stopped. File might be in use by another application.',
                mtError,[mbOk], 0);
     exit;
   end;
  end;
end;  {sub}

procedure ReadPTFDataset(var f: textfile; var FSense, FQuality: Integer; var FDipDir,FDip,FAzimuth,FPlunge, FAzimB,FPlungeB,
                         FAzimP,FPlungeP, FAzimT,FPlungeT, FPitch: Single; var FBew: Integer; var Failed, NoComment: boolean);
var
  err: integer;
  sestr: string[10];
  Ch : Char;

begin
  NoComment := true;
  failed := true;
  err := 0;
  sestr := '';
  read(F, Ch);
  while ((ch=FileCommentSeparator) or (ch=FileListSeparator) or Eoln(F)) and not eof(f) do
  begin
    readln(F);
    If not eof(f) and not Eoln(F) then read(F, Ch);
  end;
  if eof(f) then
  begin
    NoComment := false;
    failed:=false;
    exit;
  end;
  while (Ch<>FileListSeparator) and not eof(f) and not Eoln(F) do
  begin
       if ch<>' ' then sestr := sestr + Ch;
       read(F, Ch);
     end;
   val(sestr, FSense, err);
   if (err <> 0) or eof(f) then exit;
   If not ParseQuality(FSense, FQuality) then exit;
   if (ReadSingle(F, FDipDir) <> 0) or eof(f) then exit;
   if (ReadSingle(F, FDip) <> 0) or eof(f) then exit;
   if (ReadSingle(F, FAzimuth) <> 0) or eof(f) then exit;
   if (ReadSingle(F, FPlunge) <> 0) or eof(f) then exit;
   if (ReadSingle(F, FAzimB) <> 0) or eof(f) then exit;
   if (ReadSingle(F, FPlungeB) <> 0) or eof(f) then exit;
   if (ReadSingle(F, FAzimP) <> 0) or eof(f) then exit;
   if (ReadSingle(F, FPlungeP) <> 0) or eof(f) then exit;
   if (ReadSingle(F, FAzimT) <> 0) or eof(f) then exit;
   if (ReadSingle(F, FPlungeT) <> 0) or eof(f) then exit;
   if ReadSingle(F, FPitch) <> 0 then exit;
   sestr := '';
   Ch:=#0;  //bugfix 981109
   while (Ch<>FileCommentSeparator) and (Ch<>FileListSeparator) and not eof(F) and not eoln(f) do
     begin
       read(F, Ch);
       if (Ch<>FileCommentSeparator) and (Ch<>FileListSeparator) and (ch<>' ') then Sestr := Sestr + Ch;
     end;
   val(Sestr,FBew,err);
   if err <> 0 then exit;
   if not eof(f) then readln(f);
   failed:=false;
end;

function ReadSigma123(var F : TextFile; var FSigmaAzimuth, FSigmaPlunge : T1Sing1by3;
                      var FStressRatio: Single; var z, FDatasetsTot, FDatasetsSki : integer): Boolean;
var  fcode, i: integer;
     fline, fvalue: string;
begin
  result:=false;
  z:=0;
  if eof(F) then exit;
  while not seekeof(f) do
  begin
    readln(f, fline);
    fvalue:='Sigma';
    If Pos(fvalue, fline)<>0 then
    begin
      i:=StrToInt(Copy(fline, Pos(fvalue, fline)+length(fvalue),1));
      fline:=copy(fline, Pos(fvalue, fline)+length(fvalue)+2,length(fline));
      fline:=trimleft(fline); //bugfix 981124
      Val(Copy(fline, 0, Pos(FileListSeparator, fline)-1), FSigmaAzimuth[i], fcode);
      Delete(FLine, 1, Pos(FileListSeparator, fline));
      Val(FLine, FSigmaPlunge[i], fcode);
      if fcode=0 then inc(z);
    end
    else
    begin
      fvalue:='Lambda';
      If Pos(fvalue, fline)<>0 then
      begin
        i:=StrToInt(Copy(fline, Pos(fvalue, fline)+length(fvalue),1));
        fline:=copy(fline, Pos(fvalue, fline)+length(fvalue)+2,length(fline));
        fline:=trimleft(fline); //bugfix 981124
        Val(Copy(fline, 0, Pos(FileListSeparator, fline)-1), FSigmaAzimuth[i], fcode);
        Delete(FLine, 1, Pos(FileListSeparator, fline));
        Val(FLine, FSigmaPlunge[i], fcode);
        if fcode=0 then inc(z);
      end
      else
      begin
        fvalue:='Stress ratio';
        If Pos(fvalue, fline)<>0 then
        begin
          fline:=copy(fline, Pos(fvalue, fline)+length(fvalue)+2,length(fline));
          Val(FLine, FStressratio, fcode);
          if fcode=0 then inc(z);
        end
        else
        begin
          fvalue:='Strain ratio';
          If Pos(fvalue, fline)<>0 then
          begin
            fline:=copy(fline, Pos(fvalue, fline)+length(fvalue)+2,length(fline));
            Val(FLine, FStressratio, fcode);
            if fcode=0 then inc(z);
          end
          else
          begin
            fvalue:='Datasets total';
            If Pos(fvalue, fline)<>0 then
            begin
              fline:=copy(fline, Pos(fvalue, fline)+length(fvalue)+2,length(fline));
              Val(FLine, FDatasetstot, fcode);
              if fcode<>0 then FDatasetstot:=0;
              //if fcode=0 then inc(z);
            end
            else
            begin
              fvalue:='Datasets skipped';
              If Pos(fvalue, fline)<>0 then
              begin
                fline:=copy(fline, Pos(fvalue, fline)+length(fvalue)+2,length(fline));
                Val(FLine, FDatasetsski, fcode);
                if fcode<>0 then FDatasetsski:=0;
                //if fcode=0 then inc(z);
              end;
            end;
          end;
        end;
      end;
    end;        
  end; //while
  if z=4 then result:=true;
end;


procedure ReadFluMohrFPLData(var f: textfile; var FSense: Integer; var FDipDir, FDip: Single;
                             var FFluctuation: Integer; var failed, Finished: boolean);
var sestr: string[10];
    err: integer;
    Ch: Char;
    sdummy: single;
 begin
   read(F, Ch);
   If (Ch='S') or (Ch='L') then
     begin
       failed:=false;
       Finished:=true;
       exit;
     end;
   Finished:= false;
   failed := true;
   err := 0;
   sestr := '';
   while ((ch=FileCommentSeparator) or (ch=FileListSeparator) or Eoln(F)) and not eof(f) do
     begin
       readln(F);
       If not eof(f) and not Eoln(F) then read(F, Ch);
     end;
   if eof(f) then
     begin
       failed:=false;
       exit;
     end;
   while (Ch<>FileListSeparator) and not eof(f) and not Eoln(F) do
     begin
       if ch<>' ' then sestr := sestr + Ch;
       read(F, Ch);
     end;
   val(sestr, FSense, err);
   if (err <> 0) or eof(f) then exit;
   if (ReadSingle(F, FDipDir) <> 0) or eof(f) then exit;
   if (ReadSingle(F, FDip) <> 0) or eof(f) then exit;
   if (ReadSingle(F, sdummy) <> 0) or eof(f) then exit;
   if (ReadSingle(F, sdummy) <> 0) or eof(f) then exit;
   if (ReadSingle(F, sdummy)<>0) or eof(f) then exit;
   ffluctuation:=round(sdummy);
   Readln(F);
   while Eoln(F) and not eof(f) do readln(F);
   failed:=false;
end;


procedure ReadSenseErrFromINVNDAFile(var f: textfile; var FSense, FFluctuation: Integer; var failed, finished : boolean);
var sestr: string[10];
    err: integer;
    dummy, twdummy: single;
    Ch: Char;
begin
  err := 0;
  sestr := '';
  read(F, Ch);
  If (Ch='S') or (Ch='L') then
  begin
    Finished:=true;
    failed:=false;
    exit;
  end;
  failed := true;
  while ((ch=FileCommentSeparator) or (ch=FileListSeparator) or Eoln(F)) and not eof(f) do
  begin
    readln(F);
    If not eof(f) and not Eoln(F) then read(F, Ch);
  end;
  if eof(f) then
  begin
    failed:=false;
    exit;
  end;
  while (Ch<>FileListSeparator) and not eof(f) and not Eoln(F) do
  begin
    if ch<>' ' then sestr := sestr + Ch;
    read(F, Ch);
  end;
  val(sestr, Fsense, err);    {sense}
  if (err <> 0) or eof(f) then exit;
  if (ReadSingle(F, dummy) <> 0) or eof(f) then exit; {DipDir}
  if (ReadSingle(F, dummy) <> 0) or eof(f) then exit; {Dip}
  if (ReadSingle(F, dummy) <> 0) or eof(f) then exit; {Azimuth}
  if (ReadSingle(F, dummy) <> 0) or eof(f) then exit; {plunge}
  if ReadSingle(F, twdummy) <> 0 then exit; {angle between measured striae and orientation of calc shear stress}
  FFluctuation:=round(twdummy);
  Sestr := '';
  Ch:=#0; //bugfix 981111
  while ((Ch<>FileCommentSeparator) and (Ch<>FileListSeparator)) and not eof(F) and not eoln(f) do
  begin
    read(F, Ch);
    if (Ch<>FileCommentSeparator) and (Ch<>FileListSeparator) and (ch<>' ') then sestr := sestr + Ch;
  end;
  val(sestr, dummy, err);    {angle between stress vector and fault}
  if err <> 0 then exit;
  If ((Ch=FileCommentSeparator) or (Ch=FileListSeparator)) and not eof(f) then readln(F);
  while Eoln(F) and not eof(f) do readln(F);
  failed := false;
end;

procedure ReadAZIDataset(var f: textfile; var FAzimuth: Single; var failed, NoComment: boolean; var FComment: String);
  var
    err : integer;
    sestr : string[10];
    Ch : Char;

begin
    failed := true;
    NoComment:=True;
    fcomment:='';
    err:=0;
    sestr := '';
    read(F, Ch);
    while ((Ch=FileCommentSeparator) or (Ch=FileListSeparator) or Eoln(F)) and not Eof(F) do
    begin
      readln(F);
      If not Eof(F) and not Eoln(F) then read(F, Ch);
    end;
    if eof(f) then
    begin
      NoComment := false;
      failed:=false;
      exit;
    end;
    if (Ch<>FileCommentSeparator) and (Ch<>FileListSeparator) and (ch<>' ') then sestr := sestr + Ch;
    while (Ch<>FileCommentSeparator) and (Ch<>FileListSeparator) and not Eof(F) and not Eoln(F) do
    begin
      read(F, Ch);
      if (Ch<>FileCommentSeparator) and (Ch<>FileListSeparator) and (ch<>' ') then sestr := sestr + Ch;
    end;
    val(Sestr, FAzimuth, err);
    if err <> 0 then exit;
    If ((Ch=FileCommentSeparator) or (Ch=FileListSeparator)) and not eof(f) then //bugfix  980525
    while not eoln(f) and not eof(f) and (Ch<>#13) and (Ch<>#10) do
    begin
      read(F, Ch);
      FComment:=FComment+Ch;
    end;
    while Eoln(F) and not eof(f) do readln(F);
    failed:=false;
end;

procedure ManageSaveDialog(var Filename : String; var FGraphicsFile : String;
          var saveflag : boolean; var ext : TString4; writewmf: boolean);
var
  exitflag : boolean;
  SaveDialog1 : TSaveDialog;
begin
  SaveDialog1:=TSaveDialog.Create(Application);
  try
    With Savedialog1 do
    begin
      Filter:='Enhanced Windows Metafile (*.emf)|*.emf|Windows Metafile (*.wmf)|*.wmf|Autocad format (*.dxf)|*.dxf|HP graphics language (*.plt)|*.plt|All files (*.*)|*.*';
      Title:='Export lower hemisphere plot as';
      Options:=[ofHideReadOnly];
      FilterIndex:=ExportLastFileType;
    end;
    If not WriteWmf then with SaveDialog1 do
    begin
      //FilterIndex:=1;
      ext:= '.emf'
    end
    else with SaveDialog1 do
    begin
      ext:= '.wmf';
      //else FilterIndex:=2;
    end;
    SaveDialog1.FileName :=ExtractFileName(ChangeFileExt(Filename, ''));
    Repeat
      Exitflag:=false;
      SaveFlag:= SaveDialog1.Execute;
      If SaveFlag then
      begin
        Case SaveDialog1.FilterIndex of
          1: ext:= '.emf';
          2: ext:= '.wmf';
          3: ext:= '.dxf';
          4: ext:= '.plt';
        end;
      SaveDialog1.FileName := ChangeFileExt(SaveDialog1.FileName,ext);
      If (ext<>'.wmf') and (ext <>'.emf') and (ext <>'.dxf') and (ext <>'.hgl')
          and (ext <>'.plt') then
      begin
          If MessageDlg('Wrong extension!'+
              #10#13+'File not written.', mtWarning,[mbRetry,mbCancel], 0) =
              mrCancel then
          begin
            saveflag:=false;
            exit;
          end;
        end else ExitFlag:=True;
        If FileExists(SaveDialog1.FileName) then
          Case MessageDlg(SaveDialog1.FileName+#10#13+
               'already exists! Overwrite?', mtWarning,[mbYes,mbRetry,mbCancel], 0) of
           mrCancel:
            begin
              Saveflag:=false;
              exit;
            end;
            mrYes: ExitFlag:=True;
            mrRetry: ExitFlag:=False;
          end;
      end else exitflag:=true;
    until exitflag;
    FGraphicsFile:=SaveDialog1.Filename;
    if saveflag then ExportLastFileType:=SaveDialog1.FilterIndex;
  finally
    SaveDialog1.Free;
  end;
end;

procedure TVectorGraphics.Close;
begin
  FreeMem(MyOBJTable,Sizeof(MyOBJTable^[0])*(NoofGDIObj+1));
end;

procedure TVectorGraphics.ParamAsTextOut(Param: Integer);
begin
  case Param of
    clred: writeln(f,'clred');
    else writeln(f,Param);
  end;
end;

procedure TDXFFile.Section(Sectionname: String);
begin
  writeln(F,'  0');
  writeln(F,'SECTION');
  writeln(F,'  2');
  writeln(F,Sectionname);
end;

procedure TDXFFile.Endsec;
begin
  writeln(F,'  0');
  writeln(F,'ENDSEC');
end;

procedure TDXFFile.Open(AFilename: String; AHeight, AWidth: Integer);
begin
  DXFilename:=AFilename;
  DXFHeight:=AHeight;
  DXFWidth:=AWidth;
  Layer:=0;
  TextHeight:=10;
  AssignFile(F, DXFilename);
  Rewrite(F);
  //DXFHeader;
  //DXFTables;
  //DXFBlocks;
  DXFEntities;
end;

procedure TDXFFile.Variable(Varname: String);
begin
  writeln(F,'  9');
  writeln(F,Varname);
end;

procedure TDXFFile.CoordinateOut(CoordType,Value: Integer);
begin
  writeln(F,' '+IntToStr(CoordType));
  writeln(F,Value);
end;

procedure TDXFFile.DXFHeader;
begin
  Section('HEADER');
  Variable('$INSBASE');
  CoordinateOut(10,0);
  CoordinateOut(20,0);
  Variable('$EXTMIN');
  CoordinateOut(10,0);
  CoordinateOut(20,DXFHeight);
  Variable('$EXTMAX');
  CoordinateOut(10,DXFWidth);
  CoordinateOut(20,0);
  AssignFile(g, 'E:\daten\programs\schwaz\header.dxf');
  Reset(g);
  while not eof(g) do
  begin
    readln(g,linestring);
    writeln(f,linestring);
  end;
  closefile(g);
  EndSec;
end;

procedure TDXFFile.DXFTables;
begin
  Section('TABLES');
  assignfile(g, 'E:\daten\programs\schwaz\tables.dxf');
  reset(g);
  while not eof(g) do
  begin
    readln(g,linestring);
    writeln(f,linestring);
  end;
  closefile(g);
  Endsec;
end;

procedure TDXFFile.DXFBlocks;
begin
  Section('BLOCKS');
  EndSec;
end;

procedure TDXFFile.DXFEntities;
begin
  Section('ENTITIES');
end;

procedure TDXFFile.Close;
begin
  //dxf end-sequence************************
  Endsec; //End of ENTITIES-Block
  writeln(F,'  0');
  writeln(F,'EOF');
  //****************************************
  CloseFile(f);
  inherited;
end;

Procedure TDXFFile.Entity(EntityName: String);
begin
  writeln(F, '  0');
  writeln(F, EntityName);
end;

Procedure TDXFFile.SetLayer;
begin
  writeln(F, '  8');
  writeln(F, Layer);
end;

Procedure TDXFFile.Point(X,Y: Integer);
begin
  {Entity('POINT');  //skipped because points are drawn as crosses.
  SetLayer;
  XOut(X);
  YOut(MetafileHeight-Y);}
end;

Procedure TDXFFile.MoveTo(X,Y: Integer);
begin
  CurrentX:=x;
  CurrentY:=y;
end;  

Procedure TDXFFile.Lineto(X,Y: Integer);
begin
  Entity('LINE');
  SetLayer;
  CoordinateOut(10,CurrentX);
  CoordinateOut(20,MetafileHeight-CurrentY);
  CoordinateOut(11,X);
  CoordinateOut(21,MetafileHeight-Y);
end;

Procedure TDXFFile.Circle(X,Y,R: Integer);
begin
  Entity('CIRCLE');
  SetLayer;
  CoordinateOut(10,X);
  CoordinateOut(20,MetafileHeight-Y);
  CoordinateOut(40,R);
end;

procedure TDXFFile.Rectangle(X1,Y1,X2,Y2: Integer);
begin
  BeginPolyLine(true);
  Vertex(X1,Y1);
  Vertex(X2,Y1);
  Vertex(X2,Y2);
  Vertex(X1,Y2);
  SeqEnd;
  {Entity('TRACE');
  SetLayer;
  CoordinateOut(10,X1);
  CoordinateOut(20,MetafileHeight-Y1);
  CoordinateOut(11,X2);
  CoordinateOut(21,MetafileHeight-Y1);
  CoordinateOut(12,X1);
  CoordinateOut(22,MetafileHeight-Y2);
  CoordinateOut(13,X2);
  CoordinateOut(23,MetafileHeight-Y2);}
end;

procedure TDXFFile.BeginPolyLine(Closed: Boolean);
begin
  Entity('POLYLINE');
  SetLayer;
  If Closed then
  begin
    writeln(F, ' 70');
    writeln(F, '  1');
  end;  
  //writeln(F, '  6');
  //writeln(F, 'Dashed line');
  writeln(F, ' 66');
  writeln(F, '  1');
end;

procedure TDXFFile.Vertex(X,Y: Integer);
begin
  Entity('VERTEX');
  SetLayer;
  CoordinateOut(10,X);
  CoordinateOut(20,MetafileHeight-Y);
end;

procedure TDXFFile.Text(X,Y: Integer; TextString: String);
begin
  Entity('TEXT');
  SetLayer;
  CoordinateOut(10,X);
  CoordinateOut(20,MetafileHeight-Y);
  CoordinateOut(40,TextHeight);
  writeln(F,'  1');
  writeln(F,TextString);
  //writeln(F, ' 72');
  //writeln(F, '  0');   //alignment left
  //writeln(F, ' 73');
  //writeln(F, '  3');   //alignment top
end;

procedure TDXFFile.SetPenstyle(MyPen: TLogPen);
begin
  {With MyPen do
  begin
    If CurrentPenStyle<>lopnStyle then
    begin
      case lopnStyle of
        PS_SOLID: LT:=9;
        PS_DASH: LT:=5;
        PS_DOT: LT:=3;
        PS_DASHDOT: LT:=8;
        PS_DASHDOTDOT: LT:=7;
      end;
      CurrentPenStyle:=lopnStyle;
      writeln(F,'LT ',LT,' 0;');
    end;
    If Currentpencolor<>lopnColor then
    begin
      case lopnColor of
        clBlack: writeln(F,'SP1;');
        clRed: writeln(F,'SP2;');
        clBlue: writeln(F,'SP3;');
        clgreen: writeln(F,'SP4;');
        clyellow: writeln(F,'SP5;');
      end;
      Currentpencolor:=lopnColor;
    end;
  end;}
end;

procedure TDXFFile.SelectObject(x:Integer);
begin
  //writeln(F,'SelectObject ',x);
end;

procedure TDXFFile.DeleteObject(x:Integer);
begin
  //writeln(F,'DeleteObject ',x);
end;

procedure TDXFFile.SeqEnd;
begin
  writeln(F, '  0');
  writeln(F, 'SEQEND');
end;


//********************HPGL-File********************

procedure THPGLFile.Open(AFilename: String; HPGLHeight, HPGLWidth: Integer);
begin
  NoofGDIObj:=0;
  CurrentPenStyle:=ps_solid;
  Currentpencolor:=clBlack;
  HPGLFilename:=AFilename;
  AssignFile(F, HPGLFilename);
  Rewrite(F);
  //**************HPGL-header
  Writeln(F,'IN;CS2;SP1;');
  //Writeln(F,'SI 0.12 0.2;');  //Textsize
  ScaleFactor:=ClipbLowerHemisize/12;
end;

procedure THPGLFile.Close;
begin
  //HPGL end-sequence************************
  Writeln(F,'PU;');
  Writeln(F,'SP0;');
  //****************************************
  CloseFile(f);
  inherited;
end;

procedure THPGLFile.MoveTo(X,Y: Integer);
begin
  Writeln(F,'PU ',Round(ScaleFactor*x),' ',Round(ScaleFactor*(MetafileHeight-y)),';');
end;

procedure THPGLFile.LineTo(X,Y: Integer);
begin
  Writeln(F,'PD ',Round(ScaleFactor*x),' ',Round(ScaleFactor*(MetafileHeight-y)),';');
end;

Procedure THPGLFile.Circle(X,Y,R: Integer);
begin
  Writeln(F,'PU ',Round(ScaleFactor*x),' ',Round(ScaleFactor*(MetafileHeight-y)),
          ' CI ',Round(ScaleFactor*R),';');
end;

procedure THPGLFile.Rectangle(X1,Y1,X2,Y2: Integer);
begin
  MoveTo(X1,Y1);
  Writeln(F,'EA ',Round(ScaleFactor*x2),' ',Round(ScaleFactor*(MetafileHeight-y2)),';');
end;

procedure THPGLFile.Text(X,Y: Integer; TextString: String);
begin
  MoveTo(x,y);
  writeln(F,'LB '+TextString+#003);
end;

procedure THPGLFile.SetPenstyle(MyPen: TLogPen);
var LT :Integer;
begin
  With MyPen do
  begin
    If CurrentPenStyle<>lopnStyle then
    begin
      case lopnStyle of
        PS_SOLID: LT:=9;
        PS_DASH: LT:=5;
        PS_DOT: LT:=3;
        PS_DASHDOT: LT:=8;
        PS_DASHDOTDOT: LT:=7;
      end;
      CurrentPenStyle:=lopnStyle;
      writeln(F,'LT ',LT,' 0;');
    end;
    If Currentpencolor<>lopnColor then
    begin
      case lopnColor of
        clBlack: writeln(F,'SP1;');
        clRed: writeln(F,'SP2;');
        clBlue: writeln(F,'SP3;');
        clgreen: writeln(F,'SP4;');
        clyellow: writeln(F,'SP5;');
      end;
      Currentpencolor:=lopnColor;
    end;
  end;
end;

procedure THPGLFile.SelectObject(x:Integer);
begin
  writeln(F,'SelectObject ',x);
end;

procedure THPGLFile.DeleteObject(x:Integer);
begin
  writeln(F,'DeleteObject ',x);
end;

//*********other functions
function CombineSenseQuality(FSense, FQuality: Integer):Integer;
begin
  If FQuality <4 then
  begin
    If FQuality <> Quality_0 then
      result:=FSense*10+FQuality
    else result:=FSense;
  end
  else
  If Fquality=4 then
  begin //changed 20170818
    if fSense=se_unknown then result:=0
    else Result:=FSense*10+FQuality;
  end
  else
    result:=FSense;
end;

end.
