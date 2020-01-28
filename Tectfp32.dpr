program TectFP32;

uses
  Forms,
  SysUtils,
  Windows,
  Dialogs,
  IniFiles,
  Messages,
  Clipbrd,
  Titlepic in 'Titlepic.pas' {Titpfm},
  Angle in 'Angle.pas' {ThetaDialog},
  bt_draw in 'bt_draw.pas' {btdraw},
  Convert in 'Convert.pas' {ConvDlg1},
  Edit in 'Edit.pas' {EditForm},
  Draw in 'Draw.pas',
  Tecmain in 'Tecmain.pas' {TecMainWin},
  Fileops in 'fileops.pas',
  Printdia in 'printdia.pas' {PrintDial},
  Rosedlg in 'rosedlg.pas' {RoseDial},
  Types in 'types.pas',
  Exprtdia in 'Exprtdia.pas' {ExportForm},
  ContDlg in 'ContDlg.pas' {ContDlgFrm},
  Virtdip in 'Virtdip.pas' {VirtDipFrm},
  Edit2 in 'Edit2.pas' {Edit2Frm},
  LowHem in 'LowHem.pas' {LHWin},
  Angtst in 'Angtst.pas',
  Piplt in 'Piplt.pas',
  Contour in 'Contour.pas',
  Ptplot in 'Ptplot.pas',
  Sigma in 'sigma.pas',
  Fish in 'Fish.pas',
  Bingha in 'bingha.pas',
  Sortman in 'Sortman.pas' {SortManual},
  rotate in 'rotate.pas' {RotForm},
  About in 'About.pas' {AboutBox},
  Settings in 'Settings.pas' {SetForm},
  rose in 'rose.pas',
  Inspect in 'Inspect.pas' {InspectorForm},
  Options in 'Options.pas' {OptionDialog},
  results in 'results.pas' {Resinsp},
  FileType in 'FileType.pas' {FileTypeDlg},
  Invers in 'Invers.pas',
  NDA in 'Nda.pas',
  MD5 in 'MD5.pas';


{$R tfp175.RES}
{$R *.RES}
{$H+}

var
  CurrentTime: LongInt;
  failed, firstrun: boolean;
  memory : TMEMORYSTATUS;
  os : TOSVERSIONINFO;
  systeminfo : TSystemInfo;
  dw1,dw2,dw3,dw4: dword;
  Username, strDummy: string;
  TotPhysMem, TotPhysMem2,Processor,SectperClust,BytesperClust,TotNumofClust, WinPlatform: Integer;
  s : string[255];
  c : array[0..255] of byte absolute s;
  i : Integer;
  dummy: string;
  f: Textfile;
  keydummy: HKey;
  bufsize: Integer;
  puffer: PChar;
  FirstTFPThread, fred, datatype: dword;
  TestString: String;

begin
  //******Startup handler begin*****************
  TFPOpenMessage:=RegisterWindowMessage('WM_TFPOPENFILE');
  HTFPMutex:=CreateMutex(nil, True, 'TectFP_1.5');
  IF GetLastError= ERROR_ALREADY_EXISTS then
  begin
    HTFPMutex:=0;
    if RegOpenKeyEx(HKEY_LOCAL_MACHINE, PChar('SOFTWARE\GeoCompute\TectonicsFP\'+TFPRegEntryVersion),
                    0, KEY_READ, keydummy)=ERROR_SUCCESS then
    begin
      FirstTFPThread:=0;
      RegQueryValueEx(Keydummy, 'FirstThreadId', nil, nil, nil, @BufSize); //get buffer size
      RegQueryValueEx(Keydummy, 'FirstThreadId', nil, nil, PByte(@FirstTFPThread), @BufSize); //Retrieve first thread id from windows registry
      Fred:=0;
      RegQueryValueEx(Keydummy, 'TFPThreads', nil, @datatype, PByte(@Fred), @BufSize); //increment thread counter
      inc(Fred);
      RegCloseKey(KeyDummy);
    end;
    if RegOpenKeyEx(HKEY_LOCAL_MACHINE, PChar('SOFTWARE\GeoCompute\TectonicsFP\'+TFPRegEntryVersion),
                    0, KEY_SET_VALUE, keydummy)=ERROR_SUCCESS then
    begin
      RegSetValueEx(Keydummy, 'TFPThreads', 0, REG_DWORD, @Fred, SizeOf(DWord)); //Set tfp thread counter to 1
      RegFlushKey(KeyDummy);
      RegCloseKey(KeyDummy);
    end;
    dummy:='';
    if (FirstTFPThread<>0) and (TFPOpenMessage<>0) and (ParamCount>0) then  //if a TectonicsFP-thread already exists then send data to this if paramstr not empty
    begin
      for i:=1 to ParamCount do
        if ParamStr(i)<>'' then dummy:=dummy+ParamStr(i)+'*';
      //application.messagebox(PChar(Dummy) , 'TectonicsFP', mb_ok);
      if RegOpenKeyEx(HKEY_LOCAL_MACHINE, PChar('SOFTWARE\GeoCompute\TectonicsFP\'+TFPRegEntryVersion),
                    0, KEY_SET_VALUE, keydummy)=ERROR_SUCCESS then
      begin
        RegSetValueEx(Keydummy, 'OpenFile', 0, REG_SZ, PChar(dummy), Length(dummy));
        RegFlushKey(KeyDummy);
        RegCloseKey(KeyDummy);
        PostThreadMessage(FirstTFPThread, TFPOpenMessage, i-1, 0); //send open command to first TectonicsFP thread
        If GetLastError<> ERROR_INVALID_THREAD_ID then Exit;
      end;
    end;
  end //this is the first program running
  else
    if RegOpenKeyEx(HKEY_LOCAL_MACHINE, PChar('SOFTWARE\GeoCompute\TectonicsFP\'+TFPRegEntryVersion),
                    0, KEY_SET_VALUE, keydummy)=ERROR_SUCCESS then
    begin
      Fred:=GetCurrentThreadID;
      RegSetValueEx(Keydummy, 'FirstThreadId', 0, REG_DWORD, @Fred, SizeOf(DWord)); //write thread id to registry
      Fred:=1;
      RegSetValueEx(Keydummy, 'TFPThreads', 0, REG_DWORD, @Fred, SizeOf(DWord)); //Set tfp thread counter to 1
      RegFlushKey(KeyDummy);
      RegCloseKey(KeyDummy);
    end;
  //*****startup handler end******************
  Titpfm:=TTitpfm.Create(Application);
  With Titpfm do
  begin
    TitleLabel.Caption:= capTitle+' '+offVer;
    lblLicense.Caption:= capLicense;
    Update;
    Show;
  end;
  failed:=false;
  {with TTFPRegistry.create do //retrieve license data from registry
  try
    RootKey:=HKEY_LOCAL_MACHINE;
    Failed:= not keyexists('SOFTWARE\GeoCompute\TectonicsFP\'+TFPRegEntryVersion);
    if not failed then
    begin
      OpenKey('SOFTWARE\GeoCompute\TectonicsFP\'+TFPRegEntryVersion, false);
      Failed := not ValueExists('Name') or not ValueExists('Company')
             or not ValueExists('Serial');
      If not Failed then
      begin
        Username:=ReadString('Name','');
        Company:=ReadString('Company','');
        TFPSerialNumber:=ReadString('Serial','');
      end;
      CloseKey;
    end;
  finally
    Free;
  end;
  if Failed then
  begin  //HKEY_LOCAL_MACHINE does not exist
    MessageDlg('TectonicsFP is not properly installed.'+#13+#10+
                  'Please run the setup-program to install the application.',
                  mtError,[mbOK], 0);
    Titpfm.Hide;
    Titpfm.Free;
    Exit;
  end;}
  TFPVersion:=Copy(TFPSerialNumber,0,4);
  TFPVersion:=Capver;
  CurrentTime := GetTickCount div 1000;
  TitPfm.Update;
  //************************************************************************
  Dummy:=TFPVersion;
  Delete(Dummy, 8, 3);
  Dummy:=Dummy+'STU';
  Application.Initialize;
  Application.Title := 'TectonicsFP';
  Application.HelpFile := 'Tectfp32.hlp';
  Application.CreateForm(TTecMainWin, TecMainWin);
  TecMainWin.Caption:=CapTitle+' '+offVer;
  CurrentTime:=CurrentTime + 2;
  while ( (GetTickCount div 1000) < (CurrentTime) ) do
    begin { nothing }
    end;
  i:=0;
  Repeat
    inc(i);
    If ParamStr(i)<>'' then TecMainWin.CallMDIChild(Application, ParamStr(i));
  until ParamStr(i)='';
  Titpfm.Hide;
  Titpfm.Free;
  TecMainWin.Bringtofront;
  Application.Run;
end.
