unit Edit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, ExtCtrls, Menus, Types, StdCtrls, Clipbrd, math, Printers;

type
  TTectData = (td_DipDir, td_Dip, td_fpDipDir, td_fpDip, td_Azimuth, td_plunge,
               td_sense, td_Quality, td_Comment, td_unknown, td_NDataset, td_Integer,
               td_Pitch);
  TDataValidity = (dv_valid, dv_invalid, dv_empty);
  TEdit2Frm = class(TForm)
    StringGrid1: TStringGrid;
    Panel1: TPanel;
    MainMenu1: TMainMenu;                   
    EditFile1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    Close1: TMenuItem;
    Separator1: TMenuItem;
    Save1: TMenuItem;
    Saveas1: TMenuItem;
    Separator5: TMenuItem;
    Sort1: TMenuItem;
    Convert1: TMenuItem;
    Correct1: TMenuItem;
    Separator2: TMenuItem;
    Print1: TMenuItem;
    PriStp: TMenuItem;
    Separator3: TMenuItem;
    Exit1: TMenuItem;
    EditEdit: TMenuItem;
    Undo1: TMenuItem;
    Redo1: TMenuItem;
    N3: TMenuItem;
    EditCut: TMenuItem;
    EditCopy: TMenuItem;
    EditPaste: TMenuItem;
    Delete1: TMenuItem;
    N2: TMenuItem;
    Find1: TMenuItem;
    FindNext1: TMenuItem;
    Replace1: TMenuItem;
    SelectAll1: TMenuItem;
    Settings1: TMenuItem;
    Fonts1: TMenuItem;
    N6: TMenuItem;
    Options1: TMenuItem;
    NewD2ndVersion1: TMenuItem;
    OD2ndVersion1: TMenuItem;
    SaveDialog1: TSaveDialog;
    Editor1: TMenuItem;
    PopupMenu1: TPopupMenu;
    Undo2: TMenuItem;
    Redo2: TMenuItem;
    N4: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    Delete2: TMenuItem;
    N5: TMenuItem;
    SelectAll2: TMenuItem;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    E2Y: TEdit;
    E2Z: TEdit;
    Label4: TLabel;
    E2Location: TEdit;
    E2X: TEdit;
    E2Lithology: TEdit;
    E2Date: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    N7: TMenuItem;
    Selectdataset1: TMenuItem;
    N8: TMenuItem;
    Deletedataset1: TMenuItem;
    Goto1: TMenuItem;
    First1: TMenuItem;
    Last1: TMenuItem;
    Next1: TMenuItem;
    Previous1: TMenuItem;
    New2: TMenuItem;
    Insertdataset1: TMenuItem;
    E2Formation: TEdit;
    Label8: TLabel;
    E2Remarks: TEdit;
    Label5: TLabel;
    E2Age: TEdit;
    Label9: TLabel;
    Label10: TLabel;
    E2TectUnit: TEdit;
    procedure Open(Sender: TObject; const AFilename, AParentFileName: string; const AExtension: TExtension; ANew, AReadOnly : boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure OD2ndVersion1Click(Sender: TObject);
    procedure NewD2ndVersion1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Save1Click(Sender: TObject);
    function Saveas1Click(Sender: TObject): Boolean;
    procedure Open1Click(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure StringGrid1KeyPress(Sender: TObject; var Key: Char);
    procedure StringGrid1SelectCell(Sender: TObject; Col, Row: Longint;
      var CanSelect: Boolean);
    procedure Fonts1Click(Sender: TObject);
    procedure Options1Click(Sender: TObject);
    procedure EditEditClick(Sender: TObject);
    procedure EditCopyClick(Sender: TObject);
    procedure EditPasteClick(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Sort1Click(Sender: TObject);
    procedure Convert1Click(Sender: TObject);
    procedure Correct1Click(Sender: TObject);
    procedure EditFile1Click(Sender: TObject);
    procedure StringGrid1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Undo1Click(Sender: TObject);
    procedure StringGrid1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure StringGrid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure E2YChange(Sender: TObject);
    procedure StringGrid1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure EditCutClick(Sender: TObject);
    procedure StringGrid1DblClick(Sender: TObject);
    procedure Delete1Click(Sender: TObject);
    procedure Deletedataset1Click(Sender: TObject);
    procedure DeleteRows(Sender: TObject);
    procedure DeleteRow(FRow: LongInt);
    procedure Selectdataset1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Goto1Click(Sender: TObject);
    procedure First1Click(Sender: TObject);
    procedure Last1Click(Sender: TObject);
    procedure Next1Click(Sender: TObject);
    procedure Previous1Click(Sender: TObject);
    procedure Redo1Click(Sender: TObject);
    procedure Insertdataset1Click(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure PriStpClick(Sender: TObject);
    procedure StringGrid1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FillPrintCanvas(MyCanvas: TCanvas);
  private
    FModified: boolean;
    procedure SetModified(Value: boolean);
    property Modified: boolean read FModified write SetModified;
  protected
    MyFileName, MyParentFileName: string;
    E2Extension: TExtension;
    new, failed, BeepOn, undoing, CanCloseForm, creating,
    fundo, StartSelecting, ReadOnly, FExternalFileFormat: boolean;
    Sense,Quality: Integer;
    Azimuth,Plunge, DipDir, Dip : Single;
    OldCol, OldRow: Integer;
    MouseCol, MouseRow, DeltaCol, DeltaRow, DeltaMouseCol, DeltaMouseRow, coldummy, rowdummy : LongInt;
    DrawingSelection: TGridRect;
    E2LocationInfo: TLocationInfo;
    function GetColidentifier(FCol: Integer): String;
    function CanDrop(FRange: TGridRect): Boolean;
    procedure SwapSelection(var ASelection: TRect; vertical: Boolean);
    procedure GetTargetRect(FString: String; var FGridRect: TGridRect);
    procedure NewRow(Sender: TObject);
    function CheckData(Sender: TObject; FCol, FRow: LongInt): TDatavalidity;
    function AutoFillCell(Sender: TObject; FCol, FRow: LongInt): Boolean;
    function GetDataType(FCol: Integer): TTectData;
    function CheckRow(Sender: TObject; var FCol: LongInt; FRow: Longint): TDatavalidity;
    procedure StringGrid1ShowEditor(Sender: TObject);
    procedure StringGrid1SelectCells(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    //procedure StringGrid1WMTimer; message WM_Timer;
  end;

var Edit2Frm: TEdit2Frm;

function FloatToString2(FValue: Double; digits1,digits2: Integer): String;


implementation

uses Tecmain, FileOps;
{$R *.DFM}


procedure TEdit2Frm.StringGrid1ShowEditor(Sender: TObject);
begin
  if StringGrid1.inplaceeditor<>nil then case GetDataType(StringGrid1.Col) of
    td_dipdir, td_fpDipDir, td_Azimuth: StringGrid1.InplaceEditor.Maxlength:=6;
    td_Dip, td_fpDip, td_Plunge: StringGrid1.InplaceEditor.Maxlength:=5;
    td_Sense, td_Quality: StringGrid1.InplaceEditor.Maxlength:=1;
    td_Comment: StringGrid1.InplaceEditor.Maxlength:=255;
  end;
end;

procedure TEdit2Frm.SetModified(Value: boolean);
begin
  if Value then
  begin
    TecMainWin.StatusBar1.Panels.Items[0].Text:='Modified';
    TecMainWin.SaveBtn.Enabled:=true;
  end
  else
  begin
    TecMainWin.StatusBar1.Panels.Items[0].Text:='';
    TecMainWin.SaveBtn.Enabled:=false;
  end;
  If FModified<>Value then FModified:=Value;
end;

procedure TEdit2Frm.Open(Sender: TObject; const AFilename, AParentFileName: string; const AExtension: TExtension; ANew, AReadOnly : boolean);
var f: textfile;
    i: integer;
    NoComment: boolean;
    Comment: String;
    AzimB, PlungeB,AzimP, PlungeP, AzimT, PlungeT, Pitch: Single;
    Bew: Integer;

begin
  Screen.Cursor:= crHourglass;
  Creating:= true;
  BeepOn:=E2BeepOn;
  MyFileName := AFilename;
  MyParentFileName := AParentFilename;
  ReadOnly:=AReadOnly;
  E2Extension := AExtension;
  if e2extension=ptf then
  begin
    readonly:=true;
    saveas1.enabled:=false;
  end;
  if readonly then
  begin
    Deletedataset1.enabled:=false;
    Insertdataset1.enabled:=false;
    for I := 0 to ComponentCount -1 do
      if Components[I] is TEdit then (Components[I] as TEdit).Readonly:=true;
  end;
  New:=ANew;
  Caption := Caption +' - ['+ ExtractFilename(MyFileName) +']';
  Modified:= false;
  with StringGrid1 do
  begin
    Font:=TecMainWin.Edit2FontDialog.Font;
    Case E2Extension of
      COR, FPL, HOE, PEF, PEK, STF:
      begin
        ColCount:=8;
        cells[0,0]:='Dataset';
        cells[1,0]:='DipDir';
        cells[2,0]:='Dip';
        cells[3,0]:='Azimuth';
        cells[4,0]:='Plunge';
        cells[5,0]:='Sense';
        cells[6,0]:='Quality';
        cells[7,0]:='Comment';
      end;
      PTF:
      begin
        ColCount:=15;
        cells[0,0]:='Dataset';
        cells[1,0]:='DipDir';
        cells[2,0]:='Dip';
        cells[3,0]:='Azimuth';
        cells[4,0]:='Plunge';
        cells[5,0]:='Sense';
        cells[6,0]:='Quality';
        cells[7,0]:='P-Azimuth';
        cells[8,0]:='P-Plunge';
        cells[9,0]:='T-Azimuth';
        cells[10,0]:='T-Plunge';
        cells[11,0]:='B-Azimuth';
        cells[12,0]:='B-Plunge';
        cells[13,0]:='Pitch';
        cells[14,0]:='Bew';
      end;
      PLN:
      begin
        ColCount:=4;
        cells[0,0]:='Dataset';
        cells[1,0]:='DipDir';
        cells[2,0]:='Dip';
        cells[3,0]:='Comment';
      end;
      LIN:
      begin
        ColCount:=4;
        cells[0,0]:='Dataset';
        cells[1,0]:='Azimuth';
        cells[2,0]:='Plunge';
        cells[3,0]:='Comment';
      end;
      AZI:
      begin
        ColCount:=3;
        cells[0,0]:='Dataset';
        cells[1,0]:='Azimuth';
        cells[2,0]:='Comment';
      end;
    end;  //end case
  end;
  i:=1;
  if not New then
  try
    E2LocationInfo:=GetLocInfo(MyFileName);
    with E2LocationInfo do
    begin
      E2Location.Text:=LocName;
      E2X.Text:=x;
      E2Y.Text:=y;
      E2Z.Text:=z;
      E2Date.Text:=Date;
      E2Lithology.Text:=Lithology;
      E2Formation.Text:=Formation;
      E2Age.Text:=Age;
      E2TectUnit.Text:=TectUnit;
      E2Remarks.Text:=Remarks;
    end;
    AssignFile(f,myfilename);
    try
    Reset(f);
    if not SeekEof(f) then
    begin
      while not SeekEof(F) and not failed do
      begin
        case E2Extension of
          AZI:
          begin
            ReadAZIDataset(f, Azimuth,failed, Nocomment, Comment);
            if not failed and NoComment then
            begin
              with StringGrid1 do
              begin
                cells[0,i]:=IntToStr(i);
                cells[1,i]:=floattostring2(Azimuth,3,2);
                cells[2,i]:=comment;
              end;
            end;
          end;
          COR,FPL, HOE, PEF, PEK, STF:
          begin
            ReadFPLDataset(f, Sense, Quality, DipDir, Dip, Azimuth, Plunge, failed, NoComment, E2Extension, comment);
            if not failed and NoComment then
            begin
              with StringGrid1 do
              begin
                cells[0,i]:=IntToStr(i);
                cells[1,i]:=floattostring2(DipDir,3,2);
                cells[2,i]:=floattostring2(Dip,2,2);
                cells[3,i]:=floattostring2(Azimuth,3,2);
                cells[4,i]:=floattostring2(Plunge,2,2);
                cells[5,i]:=IntToStr(Sense);
                cells[6,i]:=IntToStr(Quality);
                cells[7,i]:=comment;
              end;
            end;
          end;
          PTF:
          begin
            ReadPTFDataset(f, Sense, Quality, DipDir, Dip, Azimuth, Plunge, AzimB, PlungeB,
                              AzimP, PlungeP, AzimT, PlungeT, Pitch, Bew, failed, NoComment);
            if not failed and NoComment then
            begin
              with StringGrid1 do
              begin
                cells[0,i]:=IntToStr(i);
                cells[1,i]:=floattostring2(DipDir,3,2);
                cells[2,i]:=floattostring2(Dip,2,2);
                cells[3,i]:=floattostring2(Azimuth,3,2);
                cells[4,i]:=floattostring2(Plunge,2,2);
                cells[5,i]:=IntToStr(Sense);
                cells[6,i]:=IntToStr(Quality);
                cells[7,i]:=floattostring2(AzimP,3,2);
                cells[8,i]:=floattostring2(PlungeP,2,2);
                cells[9,i]:=floattostring2(AzimT,3,2);
                cells[10,i]:=floattostring2(PlungeT,2,2);
                cells[11,i]:=floattostring2(AzimB,3,2);
                cells[12,i]:=floattostring2(PlungeB,2,2);
                cells[13,i]:=floattostring2(Pitch,2,2);
                cells[14,i]:=IntToStr(Bew);
              end;
            end;
          end;
          PLN, LIN:
          begin
            ReadPLNDataset(f, DipDir, Dip, failed, Nocomment, Comment);
            if not failed and NoComment then
            begin
              with StringGrid1 do
              begin
                cells[0,i]:=IntToStr(i);
                cells[1,i]:=floattostring2(DipDir,3,2);
                cells[2,i]:=floattostring2(Dip,2,2);
                cells[3,i]:=comment;
              end;
            end;
          end;
        else failed:= true;
        end;
        if not failed and NoComment then
        begin
          If not seekeof(f) then inc(i);
        end
        else if not NoComment and (i>0) then dec(i);
        if i<1 then
        begin
          i:=1;
          StringGrid1.cells[0,i]:=IntToStr(i);
        end;
        StringGrid1.RowCount := i+1;
      end;
    end;
    finally
      CloseFile(F);
      Screen.Cursor:=crDefault;
    end;
    except   {can not open file}
      On EInOutError do
      begin
        Globalfailed:=true;
        Screen.Cursor:=crDefault;
        MessageDlg('Can not open '+MyFileName+' !'#$A#$D+
        'File might be in use by another application.',
        mtError,[mbOk], 0);
        Close;
        Exit;
      end;
    end //end if not new
    else
    begin
      if FileExists(MyParentFileName) then
      begin
        E2LocationInfo:=GetLocInfo(MyParentFileName);
        with E2LocationInfo do
        begin
          E2Location.Text:=LocName;
          E2X.Text:=x;
          E2Y.Text:=y;
          E2Z.Text:=z;
          E2Date.Text:=Date;
          E2Lithology.Text:=Lithology;
          E2Formation.Text:=Formation;
          E2Age.Text:=Age;
          E2TectUnit.Text:=TectUnit;
          E2Remarks.Text:=Remarks;
        end;
      end;
      StringGrid1.cells[0,1]:=IntToStr(1);
      Screen.Cursor:=crDefault; //Bugfix 990123
    end;
  If Failed then
  begin
    GlobalFailed:=True;
    ReadError(Self,MyFileName,i-1);
    Close;
  end
  else
  begin
    undoing:=false;
    //StringGrid1SelectCell(nil, 1,1, fCanselect);
    with StringGrid1 do
    begin
      OldCol:=Col;
      OldRow:=Row;
      MouseCol:=Col;
      MouseRow:=Row;
      ColWidths[ColCount-1]:=ClientWidth-(colcount-1)*DefaultColWidth-(colcount+1)*GridLineWidth;
    end;
    creating:=false; //bugfix 981029
  end;
end;

procedure TEdit2Frm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  TecMainWin.StatusBar1.Panels.Items[0].Text:='';
  TecMainWin.StatusBar1.Panels.Items[1].Text:='';
  if TecMainWin.MDIChildCount <=1 then
  TecMainWin.Window1.Enabled := false;
  TecMainWin.PrintBtn.Enabled:=false;
  TecMainWin.PasteBtn.Enabled:=false;
  TecMainWin.CopyBtn.Enabled:=false;
  TecMainWin.SaveBtn.Enabled:=false;
end;

procedure TEdit2Frm.OD2ndVersion1Click(Sender: TObject);
begin
  TecMainWin.OD2ndVersion1Click(Sender);
end;

procedure TEdit2Frm.NewD2ndVersion1Click(Sender: TObject);
begin
  TecMainWin.NewD2ndVersion1Click(Sender);
end;

procedure TEdit2Frm.FormResize(Sender: TObject);
begin
  With StringGrid1 do
    ColWidths[ColCount-1]:=ClientWidth-(colcount-1)*DefaultColWidth-(colcount+1)*GridLineWidth;
end;

procedure TEdit2Frm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
const
  SWarningText = 'Save changes to %s?';
begin
  if Modified then
  begin
    MessageBeep(MB_ICONHAND);
    case MessageDlg(Format(SWarningText, [MyFileName]), mtConfirmation,
      [mbYes, mbNo, mbCancel], 0) of
      idYes:
      begin
        Save1Click(Self);
        canclose:=CanCloseForm;
      end;
      idCancel: CanClose := False;
      idNo: Modified:=false; //bugfix 980705
    end;
  end;
end;

procedure TEdit2Frm.Save1Click(Sender: TObject);
var FCol, FRow : LongInt;
    g: TextFile;
     SenseQual, SenseDummy: integer;
    textdummy: String;
begin
  Screen.Cursor:=crHourGlass;
  textdummy:=TecMainWin.Statusbar1.Panels[0].Text;
  TecMainWin.Statusbar1.Panels[0].Text:='Checking data consistency. Please wait...';
  FRow:=1;
  Repeat with StringGrid1 do
  begin
    Case Checkrow(Sender, FCol, FRow) of
    dv_invalid:
    begin
      Col:=FCol;
      Row:=FRow;
      options:=options+[goEditing];
      editormode:=true;
      if inplaceeditor<>nil then InplaceEditor.Perform(EM_SETSEL,0,-1);
      If BeepOn then MessageBeep(0);
      TecMainWin.Statusbar1.Panels[0].Text:=textdummy;
      Screen.Cursor:=crDefault;
      MessageDlg('Invalid data in Cell '+ GetColIdentifier(FCol)+' '+IntToStr(FRow)+'.'+#$D#$A+
         'Processing stopped.', mtError, [mbOK, mbHelp], 520);
      cancloseform:=false;
      exit;
    end;
    dv_empty:
    begin
      DeleteRow(FRow);
      if fRow>FixedRows then Dec(FRow);
      SetFocus;
    end;
    end; //case
    if frow=StringGrid1.rowcount-1 then break;
    inc(FRow);
  end; // with StringGrid1 do...
  until FRow=StringGrid1.Rowcount;
  TecMainWin.Statusbar1.Panels[0].Text:=textdummy;
  If not IsTFPFileFormat(MyFilename) then
  begin
    Screen.Cursor:=crDefault;
    Case MessageDlg('Data will be converted to a TFP-fileformat.', mtWarning,[mbOk, mbHelp], 515) of
    mrOK:
    begin
      textdummy:=MyFilename;
      case extractextension(MyFilename) of
        HOE, PEK, STF: MyFilename:=ChangeFileExt(MyFilename, '.cor');
        PEF: MyFilename:=ChangeFileExt(MyFilename, '.fpl');
      end;
      E2Extension:=ExtractExtension(MyFilename);
      if not SaveAs1Click(Sender) then
      begin
        MyFilename:=Textdummy;
        E2Extension:=ExtractExtension(MyFilename);
        exit;
      end;
    end;
    else exit;
    end;
    Screen.Cursor:=crHourGlass;
  end
  else
    if New or (Sender=SaveAs1) then
    begin
      Screen.Cursor:=crDefault;
      if not SaveAs1Click(Sender) then exit;
      Screen.Cursor:=crHourGlass;
    end;
  //Extension:=ExtractExtension(MyFilename);
  With E2LocationInfo do
  begin
    LocName:=E2Location.Text;
    x:=E2X.Text;
    y:=E2Y.Text;
    z:=E2Z.Text;
    Date:=E2Date.Text;
    Lithology:=E2Lithology.Text;
    Formation:=E2Formation.Text;
    Age:=E2Age.Text;
    TectUnit:=E2TectUnit.Text;
    Remarks:=E2Remarks.Text;
  end;
  LocInfoToFile(MyFileName, E2LocationInfo);
  AssignFile(g, MyFileName);
  Append(g);
  for FRow:= 1 to StringGrid1.Rowcount-1 do
  begin
    case E2Extension of
    COR, FPL:
      begin
        try
          SenseDummy:=StrToInt(StringGrid1.Cells[5, FRow]);
        except
          on EConvertError do
            If StringGrid1.Cells[5, FRow]='+' then SenseDummy:=1
            else if StringGrid1.Cells[5, FRow]='-' then SenseDummy:=2
            else Sensedummy:=0;
        end;
        try
          if sensedummy<>0 then
          begin
            if StrToInt(StringGrid1.Cells[6, FRow])<>0 then SenseQual:=10*Sensedummy+StrToInt(StringGrid1.Cells[6, FRow])
            else SenseQual:=StrToInt(StringGrid1.Cells[5, FRow]);
          end
          else SenseQual:=0;
        except
          on EConvertError do SenseQual:=0;
        end;
        Write(g,SenseQual,filelistseparator,StringGrid1.Cells[1,FRow],filelistseparator,
                  StringGrid1.Cells[2,FRow],filelistseparator, StringGrid1.Cells[3,FRow],
                  filelistseparator, StringGrid1.Cells[4,FRow]);
        FCol:=7;
      end;
      PLN, LIN:
      begin
        Write(g,StringGrid1.Cells[1,FRow],filelistseparator,
                  StringGrid1.Cells[2,FRow]);
        FCol:=3;
      end;
      AZI:
      begin
        Write(g,StringGrid1.Cells[1,FRow]);
        FCol:=2;
      end;
    else break;
    end;
    if FRow<StringGrid1.RowCount then
      if StringGrid1.Cells[FCol,FRow]='' then writeln(g)  //comment field is empty
      else Writeln(g, filelistseparator, StringGrid1.Cells[FCol,FRow]) //write comment and begin a new line if not last dataset
    else if StringGrid1.Cells[FCol,FRow]<>'' then Write(g, filelistseparator, StringGrid1.Cells[FCol,FRow]);  //last dataset only
    end;
    Closefile(g);
    Modified := false;
    CanCloseForm:=true;
    Screen.Cursor:=crDefault;
end;


function TEdit2Frm.Saveas1Click(Sender: TObject): Boolean;
var saveflag,exitflag, retryflag: boolean;
    ext : Tstring4;
begin
  Result:=false;
  with SaveDialog1 do
  begin
    InitialDir:=GetCurrentDir; //Bugfix 20000408 (Win2000)
    FileName := MyFileName;
    FilterIndex:=1;//EditSaveFilterIndexStore;
  end;
  retryflag:=false;
  Repeat
    Exitflag:=false;
    If not retryflag then
    case E2Extension of
      FPL: SaveDialog1.Filter:='Fault plane files (*.fpl)|*.fpl|All files (*.*)|*.*';
      COR: SaveDialog1.Filter:='Corrected files (*.cor)|*.cor|All files (*.*)|*.*';
      PLN: SaveDialog1.Filter:='Plane files (*.pln)|*.pln|All files (*.*)|*.*';
      LIN: SaveDialog1.Filter:='Lineation files (*.lin)|*.lin|All files (*.*)|*.*';
      AZI: SaveDialog1.Filter:='Azimutal data files (*.azi)|*.azi|All files (*.*)|*.*';
      PTF: SaveDialog1.Filter:='pt-axes files (*.t??)|*.t??|All files (*.*)|*.*';
    end;
    SaveFlag:= SaveDialog1.Execute;
    If SaveFlag then
    begin
      if ExtractFileExt(SaveDialog1.FileName)='' then
        case E2Extension of
          fpl: ext := '.fpl';
          cor: ext := '.cor';
          pln: ext := '.pln';
          lin: ext := '.lin';
          azi: ext := '.azi';
        end
      else ext:=ExtractFileExt(SaveDialog1.Filename);
      ExitFlag:=True;
      If FileExists(ChangeFileExt(SaveDialog1.FileName,ext)) then
        Case MessageDlg(ChangeFileExt(SaveDialog1.FileName,ext)+#$A#$D+
             'already exists! Overwrite?', mtWarning,[mbYes,mbRetry,mbCancel], 0) of
          mrCancel:
          begin
            Saveflag:=false;
            exit;
          end;
          mrYes: ExitFlag:=True;
          mrRetry:
          begin
            ExitFlag:=False;
            retryflag:=true;
          end;
        end;
    end else exitflag:=true;
    until exitflag;
  if saveflag then
  begin
    SaveDialog1.FileName := ChangeFileExt(SaveDialog1.FileName,ext);
    MyFileName := SaveDialog1.FileName;
    Caption := ExtractFileName(MyFileName);
    New:=False;
    EditSaveFilterIndexStore:=SaveDialog1.FilterIndex;
    Result:=true;
  end;
end;

procedure TEdit2Frm.Open1Click(Sender: TObject);
begin
  TecMainWin.EditOpenChild(Sender);
end;

procedure TEdit2Frm.New1Click(Sender: TObject);
begin
  TecMainWin.EditNewChild(Sender);
end;

function TEdit2Frm.GetDataType(FCol: Integer): TTectData;
begin
  case fcol of
    0: begin
      Result:=td_NDataset;
      exit;
    end;
  end;
  Case E2Extension of
    fpl, cor, stf, hoe, pek, pef:
    Case FCol of
      1: Result:= td_fpDipDir;
      2: Result:= td_fpDip;
      3: Result:= td_Azimuth;
      4: Result:= td_Plunge;
      5: Result:= td_Sense;
      6: Result:= td_Quality;
      7: Result:= td_Comment;
      else Result:=td_unknown;
    end;
    ptf:
    Case FCol of
      1: Result:= td_fpDipDir;
      2: Result:= td_fpDip;
      3, 7, 9, 11: Result:= td_Azimuth;
      4,8,10,12: Result:= td_Plunge;
      5: Result:= td_Sense;
      6: Result:= td_Quality;
      13: Result:= td_Pitch;
      14: Result:= td_Integer;
      else Result:=td_unknown;
    end;
    pln:
    Case FCol of
        1: Result:=td_DipDir;
        2: Result:=td_Dip;
        3: Result:=td_Comment;
        else Result:=td_unknown;
    end;
    lin:
    Case FCol of
        1: Result:=td_Azimuth;
        2: Result:=td_Plunge;
        3: Result:=td_Comment;
        else Result:=td_unknown;
    end;
    azi:
    Case FCol of
        1: Result:= td_Azimuth;
        2: Result:= td_Comment;
        else Result:=td_unknown;
    end;
  end;
end;

function TEdit2Frm.CheckData(Sender: TObject; FCol, FRow: LongInt): TDatavalidity;
var value: Single;
    position: Integer;
    MyDatatype: TTectData;
begin
  With StringGrid1 do
  begin
    MyDatatype:=GetDataType(FCol);
    if (Cells[FCol, FRow]='') and undoing then
    begin
      undoing:=false;
      result:=dv_valid;
      exit;
    end;
    if (Cells[FCol, FRow]='') and (MyDatatype<> td_Comment) and (MyDatatype<> td_Quality) then
    begin
      result:=dv_empty;
      exit;
    end;
    if (Cells[FCol, FRow]='') and (MyDatatype= td_Quality) then  //bugfix for leaving quality cells empty
    begin                                                        //990331 f.r.
      Cells[FCol, FRow]:='0';
      result:=dv_valid;
      exit;
    end;
    result:=dv_invalid;
    val(Cells[FCol, FRow],value,position);
    If (position<>0) and (MyDatatype<> td_Comment) and (MyDatatype<>td_Sense) then exit;
    Case MyDatatype of
      td_DipDir, td_fpDipDir, td_Azimuth:
      begin
        if (Value<359.99) and (Value>=0) then
        begin
          result:=dv_valid;
          Cells[FCol, FRow]:=floattostring2(Value,3,2);
        end;
      end;
      td_Dip, td_fpDip, td_Plunge:
      begin
        if (Value<89.95) and (Value>=0.009999) then
        begin
          result:=dv_valid;
          Cells[FCol, FRow]:=floattostring2(Value,2,2);
        end;
      end;
      td_Sense: if (Value<=5) and (Value>=0) and (position=0) or (Cells[FCol, FRow]='+') or (Cells[FCol, FRow]='-')
        then result:=dv_valid;
      td_Pitch: result:=dv_valid;
      td_Integer: if abs(frac(value))<0.001 then result:=dv_valid;
      td_Quality: if (Value<=4) and (Value>=0) then result:=dv_valid;
      td_Comment: result:=dv_valid;
    end;
  end;
end;

function TEdit2Frm.AutoFillCell(Sender: TObject; FCol, FRow: LongInt): Boolean;
begin
  Result:=false;
  If StringGrid1.Cells[FCol, FRow]<>'' then exit;
  If FRow>StringGrid1.FixedRows then
  begin
   if StringGrid1.Cells[FCol, FRow-1]<>'' then
   begin
     case GetDataType(FCol) of
       td_Comment: {};
       td_Quality: if StringGrid1.Cells[FCol-1, FRow]='0' then StringGrid1.Cells[FCol, FRow]:='0'
       else StringGrid1.Cells[FCol, FRow]:=StringGrid1.Cells[FCol, FRow-1];
       else StringGrid1.Cells[FCol, FRow]:=StringGrid1.Cells[FCol, FRow-1];
     end;
   end;
  end
  else Case GetDataType(FCol) of
    td_Quality: StringGrid1.Cells[FCol, FRow]:='0';
    td_Sense: StringGrid1.Cells[FCol, FRow]:='0';
  end;
  Result:=true;
end;

function TEdit2Frm.CheckRow(Sender: TObject; var FCol: LongInt; FRow: LongInt): TDatavalidity;
var j, aempty: Integer;
    firstinvalidcell: LongInt;
begin
  aempty:=0;
  firstinvalidcell:=0;
  result:=dv_valid;
  For j:=1 to StringGrid1.Colcount-2 do
  begin
    FCol:=j;
    case CheckData(Sender, FCol, FRow) of
    dv_invalid:
    begin
      Result:=dv_invalid;
      exit;
    end;
    dv_empty: //if frow=StringGrid1.rowcount-1 then
    begin
      Result:=dv_empty;
      if firstinvalidcell=0 then firstinvalidcell:=j;
      inc(aempty);
    end;
    dv_valid:  //bugfix 990803 to delete empty last row in fpl and cor files
      if (aempty = StringGrid1.ColCount - 3) and (StringGrid1.ColCount - 3 > 0) then
      begin //bugfix 080305 to avoid accidential deleting of azimuthal data (all rows were deleted)
        Result:=dv_empty;
        if firstinvalidcell=0 then firstinvalidcell:=j;
        inc(aempty);
      end;
    {else
    begin
      Result:=dv_invalid;
      exit;
    end;}
    end;
  end;
  if (result=dv_empty) then
    if (aempty<>StringGrid1.colcount-2) then
    begin
      result:=dv_invalid;
      fcol:=firstinvalidcell;
    end;
end;

procedure TEdit2Frm.SwapSelection(var ASelection: TRect; vertical: Boolean);
var dummy: Integer;
begin
  if vertical then
  begin
    dummy:=aselection.top;
    aselection.top:=aselection.bottom;
    aselection.bottom:=dummy;
  end
  else
  begin
    dummy:=aselection.left;
    aselection.left:=aselection.right;
    aselection.right:=dummy;
  end;
end;

procedure TEdit2Frm.StringGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var OldSelection: TRect;
    myselection: TRect;
    SelChanged: Boolean;
    ACol, MyCol, MyRow: LongInt;
begin
  if readonly then case key of
    vk_delete, vk_back:
    begin
      key:=0;
      exit;
    end;
    end;
  With StringGrid1 do
  case key of
    17:
    begin
      key:=0;
      Refresh;
      exit;
    end;
    vk_delete:
    begin
      for MyRow:= Selection.Top to Selection.Bottom do
        for MyCol := Selection.Left to Selection.Right do
          Cells[MyCol, MyRow]:='';
      key:=0;
      modified:=true;
      exit;
    end;
    vk_tab:
    begin
      if not readonly then
      begin
        If E2AutoFill then AutoFillCell(Sender,Col,Row);
        If CheckData(Sender, Col, Row)<>dv_valid then
        begin
            If BeepOn then Windows.Beep(200, 50);
            MessageDlg('You entered invalid data!', mtError, [mbOK, mbHelp], 520);
            key:=0;
            options:=options+[goEditing];
            editormode:=true;
            if inplaceeditor<>nil then InplaceEditor.Perform(EM_SETSEL,0,-1);
            exit;
        end;
        If (Col=ColCount-1) and (Row=RowCount-1) then
        begin
          If CheckRow(Sender, ACol, Row)=dv_valid then  //Check all data in row
          begin
            Key:=0;
            NewRow(Sender);
          end
          else
          begin
            Key:=0;
            Col:=ACol;
            If BeepOn then Windows.Beep(200,50);    //goto cell with wrong content
            MessageDlg('Invalid data in Cell '+ GetColIdentifier(ACol)+
               ' '+IntToStr(ACol)+'.'+#$D#$A+
               'Processing stopped.', mtError , [mbOK, mbHelp], 520);
            options:=options+[goEditing];
            editormode:=true;
            If inplaceeditor<>nil then InplaceEditor.Perform(EM_SETSEL,0,-1);
          end;
        end;
      end;
    end;
    vk_return:
    begin
      if not readonly then
      begin
        If E2AutoFill then AutoFillCell(Sender,Col,Row);
        If CheckData(Sender, Col, Row)<>dv_valid then
        begin
          key:=0;
          If BeepOn then Windows.Beep(200, 50);
          MessageDlg('You entered invalid data!',mtError, [mbOK, mbHelp], 520);
          options:=options+[goEditing];
          editormode:=true;
          if inplaceeditor<>nil then InplaceEditor.Perform(EM_SETSEL, 0, -1);
          exit;
          end;
      end;
      If (Col<Colcount-2) and (E2Extension<>ptf) then col:=col+1
      else if (col<colcount-1) and (E2Extension=ptf) then col:=col+1
        else
        If Row<Rowcount-1 then
        begin
          Row:=Row+1;
          Col:=1;
        end
        else
        begin
          If CheckRow(Sender,ACol, Row)=dv_valid then  //Check all data in row
          begin
            if not readonly then NewRow(Sender);
            Key:=0;
          end
          else
          begin
            Key:=0;
            Col:=ACol;
            options:=options+[goEditing];
            editormode:=true;
            if inplaceeditor<>nil then InplaceEditor.Perform(EM_SETSEL,0,-1);
            If BeepOn then Windows.Beep(200,50);    //goto cell with wrong content
            MessageDlg('Invalid data in Cell '+ GetColIdentifier(ACol)+
               ' '+IntToStr(ACol)+'.'+#$D#$A+
               'Processing stopped.', mtError, [mbOK, mbHelp], 520);
          end;
        end;
    end;
    vk_F2: if not readonly then with StringGrid1 do //added 20000410 to allow edit mode when pressing F2
    begin //                                          this is an excel-feature 
      Options:=Options+[goEditing];
      Editormode:=true;
    end;
  end;  //Case
  OldSelection:=TRect(StringGrid1.Selection);
  if (ssShift in shift) and not StringGrid1.Editormode then
  begin
    SelChanged:=true;
    case key of
      vk_left, vk_right, vk_up, vk_down: myselection:=TRect(StringGrid1.Selection);
    end;
    case key of
    vk_left:
    begin
       if StringGrid1.row<myselection.bottom then SwapSelection(MySelection, true);
       if myselection.right>StringGrid1.col then
       begin
         swapselection(myselection, false);
         dec(myselection.left);
       end
       else if myselection.left>1 then
         dec(myselection.left)
       else selchanged:=false;
    end;
    vk_right:
      begin
      if StringGrid1.row<myselection.bottom then SwapSelection(MySelection, true);
      if myselection.left<StringGrid1.col then
        inc(myselection.left)
      else if myselection.right<StringGrid1.colcount-1 then
      begin
        if myselection.left<myselection.right then SwapSelection(MySelection, false);
        inc(myselection.left);
      end else selchanged:=false;
      end;
    vk_up:
    begin
      if StringGrid1.col<myselection.right then SwapSelection(MySelection, false);
      if myselection.bottom>StringGrid1.row then
      begin
        swapselection(myselection, true);
        dec(myselection.top);
      end
      else if myselection.top>1 then
        dec(myselection.top)
      else selchanged:=false;
    end;
    vk_down:
    begin
      if StringGrid1.col<myselection.right then SwapSelection(MySelection, false);
      if myselection.top<StringGrid1.row then
        inc(myselection.top)
      else if myselection.bottom<StringGrid1.rowcount-1 then
      begin
        if myselection.top<myselection.bottom then SwapSelection(MySelection, true);
        inc(myselection.top);
      end else selchanged:=false;
    end;
    end; //case
    case key of
      vk_left, vk_right, vk_up, vk_down:
      begin
        if selchanged then
        begin
          StringGrid1.selection:=TGridRect(Myselection);
          StringGrid1.repaint;
        end;
      end;
    end;
    case key of
      vk_down: if ((myselection.top-StringGrid1.toprow+2)*StringGrid1.RowHeights[1]+(myselection.top-StringGrid1.toprow+3)*StringGrid1.GridLineWidth) > StringGrid1.clientheight then
          StringGrid1.perform(WM_VSCROLL,SB_LINEDOWN,0);
      vk_up: if myselection.top <StringGrid1.toprow then
        StringGrid1.perform(WM_VSCROLL,SB_LINEUP,0);
    end;
    case key of
      vk_left, vk_right, vk_up, vk_down: key:=0;
    end;
  end;
  if key=vk_escape then
  begin
    //StringGrid1.Cells[TRect(StringGrid1.Selection).left, TRect(StringGrid1.Selection).top]:=mytextbuffer;
    //exit;
  end;
end;


procedure TEdit2Frm.StringGrid1KeyPress(Sender: TObject; var Key: Char);
begin
  if not readonly then
  begin
    modified:=true;
    case key of
      ',': if GetDataType(StringGrid1.Col)<>td_Comment then key:='.';
    end;
  end;
  case key of
    #$D,#9: {}
    else if not readonly then
    begin
      OldRow:=StringGrid1.Row;
      OldCol:=StringGrid1.Col;
      With StringGrid1 do if not editormode then
      begin
        Options:=Options+[goEditing];
        Editormode:=true;
        Cells[Col,Row]:='';
        Keybd_event(VkKeyScan(Key),0,0,0);
      end
      else if not (goEditing in Options) then
      begin
        Options:=Options+[goEditing];
        Keybd_event(VkKeyScan(Key),0,0,0);
      end;
      fundo:=true;
      modified:=true;
    end;
  end;
end;


procedure TEdit2Frm.StringGrid1SelectCell(Sender: TObject; Col,
  Row: Longint; var CanSelect: Boolean);

begin
  StringGrid1.Options:=StringGrid1.Options-[goEditing];
  {If StringGrid1.cursor=crdefault then
  begin
    canselect:=false;
    exit;
  end;}  
  TecMainWin.StatusBar1.Panels.Items[1].Text:=GetColIdentifier(Col)+' '+IntToStr(Row);
end;

Function TEdit2Frm.GetColidentifier(FCol: Integer): String;
begin
  Case E2Extension of
    AZI:
    Case FCol of
      1: Result:= 'Azimuth';
      2: Result:= 'Comment';
    end;
    PLN:
    Case FCol of
      1: Result:= 'DipDir';
      2: Result:= 'Dip';
      3: Result:= 'Comment';
    end;
    LIN:
    Case FCol of
      1: Result:= 'Azimuth';
      2: Result:= 'Plunge';
      3: Result:= 'Comment';
    end;
    fpl, cor, stf, hoe, pek, pef:
    Case FCol of
      1: Result:= 'DipDir';
      2: Result:= 'Dip';
      3: Result:= 'Azimuth';
      4: Result:= 'Plunge';
      5: Result:= 'Sense';
      6: Result:= 'Quality';
      7: Result:= 'Comment';
    end;
  end;
end;

procedure TEdit2Frm.Fonts1Click(Sender: TObject);
begin
  TecMainWin.Edit2FontDialog.Font := StringGrid1.Font;
  if TecMainWin.Edit2FontDialog.Execute then
    StringGrid1.Font:=TecMainWin.Edit2FontDialog.Font;
end;

procedure TEdit2Frm.Options1Click(Sender: TObject);
begin
  TecMainWin.Options1Click(Application);
end;

procedure TEdit2Frm.EditEditClick(Sender: TObject);
var canundo: Boolean;
begin
  EditPaste.Enabled:=Clipboard.HasFormat(CF_TEXT) and not Readonly;
  EditCut.Enabled:=(StringGrid1.Editormode and (goEditing in StringGrid1.Options) or
    (StringGrid1.Selection.left=1) and (StringGrid1.Selection.right=StringGrid1.Colcount-1)) and not readonly;
  Delete1.Enabled:=(StringGrid1.Editormode or
    ((StringGrid1.Selection.Left=StringGrid1.Selection.Right) and (StringGrid1.Selection.Top=StringGrid1.Selection.Bottom)) or
     (StringGrid1.Selection.Left=1) and (StringGrid1.Selection.Right=StringGrid1.Colcount-1)) and not readonly;
  TecMainWin.PasteBtn.Enabled:=EditPaste.Enabled;
  TecMainWin.CutBtn.Enabled:=EditCut.Enabled;
  If (StringGrid1.Editormode) and (goEditing in StringGrid1.Options) and (StringGrid1.InplaceEditor<>nil) then
  begin
    case StringGrid1.InplaceEditor.Perform(EM_CANUNDO,0,0) of
      0: CanUndo:=false;
      1: CanUndo:=true;
    end;
    Undo1.Enabled:=CanUndo and fUndo and not readonly;
    Redo1.Enabled:=CanUndo and not fUndo and not readonly;
  end
  else
  begin
    Undo1.Enabled:=false;
    Redo1.Enabled:=false;
  end;
  TecMainWin.UndoBtn.Enabled:=Undo1.Enabled;
  TecMainWin.RedoBtn.Enabled:=Redo1.Enabled;
end;

procedure TEdit2Frm.EditCopyClick(Sender: TObject);
var MyString: String;
    MyCol, MyRow: Integer;
begin
  If (goEditing in StringGrid1.Options) and StringGrid1.Editormode and (StringGrid1.InplaceEditor<>nil) then StringGrid1.InplaceEditor.Perform(WM_COPY,0,0)
  else
  begin
    Screen.Cursor:=crHourGlass;
    MyString:='';
    with StringGrid1 do
      for MyRow:= Selection.Top to Selection.Bottom do
      begin
        for MyCol := Selection.Left to Selection.Right do
        begin
          MyString:=concat(MyString, Cells[myCol,MyRow]);
          MyString:=concat(MyString, #9);
        end;
        MyString:=Copy(MyString,0,Length(Mystring)-1)+#$D+#$A;
      end;
    Screen.Cursor:=crDefault;
    ClipBoard.AsText:=Mystring;
  end;
end;


procedure TEdit2Frm.GetTargetRect(FString: String; var FGridRect: TGridRect);
var mystring: String;
    i,j: Integer;
begin
  MyString:=FString;
  i:=0;
  j:=0;
  While length(myString)>0 do
  begin
    if ((Pos(#9,MyString)<Pos(#$D,MyString)) and (Pos(#9,MyString)<>0) and (j=0)) then
    begin
      Delete(MyString,1,Pos(#9,Mystring));
      Inc(i);
    end
    else
    begin
      if (Pos(#$D,MyString)=0) and (Pos(#9,MyString)=0) then break;
      if (Pos(#$D,MyString)=0) then //last line
      begin
        inc(j);
        break;
      end
      else Delete(MyString,1,Pos(#$D,Mystring)+1);
      inc(j);
    end;
  end;
  FGridRect:=TGridRect(Rect(1,0,i+1,j));
end;

procedure TEdit2Frm.EditPasteClick(Sender: TObject);
var MyString: String;
    StartingCol, i, j, dummy: Integer;
    MyGridRect: TGridRect;
begin
  If Clipboard.HasFormat(CF_TEXT) then
    If (goEditing in StringGrid1.Options) and StringGrid1.Editormode and (StringGrid1.InplaceEditor<>nil) then
    begin
      (StringGrid1 as TCustomGrid).InplaceEditor.Perform(WM_PASTE,0,0);
      modified:=true;
    end
  else
  begin
    Screen.Cursor:=crHourGlass;
    MyString:=ClipBoard.AsText;
    GetTargetRect(MyString, MyGridRect);
    With StringGrid1.Selection do
      If(Bottom-Top=0) then
        If (Right-Left=0) then
        begin
          MyGridRect.Left:=MyGridRect.Left+Left;
          MyGridRect.Right:=MyGridRect.Right+Left;
          MyGridRect.Top:=MyGridRect.Top+Top;
          MyGridRect.Bottom:=MyGridRect.Bottom+Top;
        end
        else
        begin
          MyGridRect.Top:=Top;
          MyGridRect.Bottom:=bottom;
        end;
    Screen.Cursor:=crDefault;
    If not CanDrop(MyGridRect) then
      exit;
    StartingCol:= StringGrid1.Col;
    i:=0;
    j:=0;
    While length(myString)>0 do
    begin
      if (Pos(#$D,MyString)=0) and (Pos(#9,MyString)=0) then
      begin
        StringGrid1.Cells[StringGrid1.Col+i, StringGrid1.Row+j]:=MyString;
        break;
      end;
      if Pos(#$D,MyString)<>0 then //last line
        dummy:=Pos(#$D,MyString)
       else dummy:=length(Mystring);
      if (Pos(#9,MyString)<dummy) and (Pos(#9,MyString)<>0) then
      begin
        StringGrid1.Cells[StringGrid1.Col+i, StringGrid1.Row+j]:=Copy(MyString,0,Pos(#9,MyString)-1);
        Delete(MyString,1,Pos(#9,Mystring));
        Inc(i);
      end
      else
      begin
        StringGrid1.Cells[StringGrid1.Col+i, StringGrid1.Row+j]:=Copy(MyString,0,Pos(#$D,MyString)-1);
        Delete(MyString,1,Pos(#$D,Mystring)+1);
        i:=0;
        inc(j);
        if (StringGrid1.Row+j=StringGrid1.rowcount) and (MyString<>'') then
        begin
          StringGrid1.rowcount:=StringGrid1.rowcount+1;
          StringGrid1.Cells[0,StringGrid1.rowcount-1]:=IntToStr(StringGrid1.rowcount-1);
        end;
      end
    end;
    modified:=true;
    Screen.Cursor:=crDefault;
  end;
end;

procedure TEdit2Frm.Close1Click(Sender: TObject);
begin
  Close;
end;

procedure TEdit2Frm.Exit1Click(Sender: TObject);
begin
  TecMainWin.Exit1Click(Sender);
end;

procedure TEdit2Frm.Sort1Click(Sender: TObject);
begin
  TecMainWin.Sort1Click(Application);
end;

procedure TEdit2Frm.Convert1Click(Sender: TObject);
begin
  TecMainWin.Convert1Click(Sender);
end;

procedure TEdit2Frm.Correct1Click(Sender: TObject);
begin
  TecMainWin.Correct1Click(Sender);
end;

procedure TEdit2Frm.EditFile1Click(Sender: TObject);
begin
  save1.enabled:=modified and not readonly;
end;

function FloatToString2(FValue: Double; digits1,digits2: Integer): String;
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
    for i:=1 to digits2 do Result:=Result+'0';
    If digits2<>0 then Result:='.'+Result;
  end;
  if actualdigits<>0 then
  begin
    for i:=1 to digits2-trunc(log10(actualdigits)+1) do
      Result:=Result+'0';
    If actualdigits/10=actualdigits div 10 then
      actualdigits:=actualdigits div 10;
    Result:=Result+IntToStr(actualdigits);
    If digits2<>0 then Result:='.'+Result;
  end;
  //else for i:=1 to digits2 do Result:=Result+'0';
  //If digits2<>0 then Result:='.'+Result;
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

procedure TEdit2Frm.Undo1Click(Sender: TObject);
begin
  {undoing:=true;
  With StringGrid1 do
  begin
    Col:=OldCol;
    Row:=OldRow;
    Cells[Col,Row]:='';
  end;}
  If (goEditing in StringGrid1.Options) and StringGrid1.Editormode and (StringGrid1.InplaceEditor<>nil) then
  begin
    StringGrid1.InplaceEditor.Perform(EM_UNDO, 0,0);
    fundo:= false;
  end;
end;

procedure TEdit2Frm.Redo1Click(Sender: TObject);
begin
  If (goEditing in StringGrid1.Options) and StringGrid1.Editormode and (StringGrid1.InplaceEditor<>nil) then
  begin
    StringGrid1.InplaceEditor.Perform(EM_UNDO, 0,0);
    fundo:= true;
  end;
end;


procedure TEdit2Frm.StringGrid1MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var MyCol, MyRow: LongInt;
    myxdummy, myxdummy2, MyYDummy, MyYDummy2: Integer;
    noscroll: Boolean;
    MyMessage: TMessage;
    mystrdummy: String;
const  Interval = 2;
begin
  StringGrid1.MouseToCell(X,Y,MyCol, MyRow);
  If not (ssLeft in Shift) then with StringGrid1 do
  begin
    If (Coldummy<>MyCol) or (Rowdummy<>myRow) then
    begin
      With TWMMouse(MyMessage) do //show appropriate hint messages
      begin
        Coldummy:=mycol;
        rowdummy:=myrow;
        XPos:=x;
        YPos:=Y;
      end;
      case GetDataType(MyCol) of
        td_NDataset: mystrdummy:='Dataset number';
        td_dipdir: mystrdummy:='Dip direction of plane';
        td_dip: mystrdummy:='Dip angle of plane';
        td_fpdipdir: mystrdummy:='Dip direction of fault plane';
        td_fpdip: mystrdummy:='Dip angle of fault plane';
        td_azimuth: mystrdummy:='Azimuth of lineation';
        td_plunge: mystrdummy:='Plunge of lineation';
        td_sense: mystrdummy:='0: ?'+#13#10+'1: up'+#$D+#$A+'2: dn'+#$D+#$A+'3: dx'+#$D+#$A+'4: sn';
        td_Quality: MyStrDummy:='0: not recorded'+#13#10+'1: excellent'+#$D#$A+'2: good'+#$D+#$A+'3: poor';
        td_comment: mystrdummy:='Comment (optional)';
        else mystrdummy:='';
      end;
      if mystrdummy<>'' then
      begin
        Hint:=MyStrDummy+'| ';
        Application.fhintcontrol:=nil;
        Application.HintMouseMessage(StringGrid1, MyMessage);
      end else Hint:='';
    end;
    With Selection do
    begin
      MyXDummy:=(Left-LeftCol+1)*DefaultColWidth+(Left-LeftCol)*GridLineWidth;
      MyXdummy2:=(Right-LeftCol+2)*DefaultColWidth+(Right-LeftCol+1)*GridLineWidth;
      MyYDummy:=(Top-TopRow+1)*DefaultRowHeight+(Top-TopRow)*GridLineWidth;
      MyYdummy2:=(Bottom-TopRow+2)*DefaultRowHeight+(Bottom-TopRow+1)*GridLineWidth;
      If ((X>MyXDummy-Interval)  and (X<MyXDummy+Interval) or
          (X>MyXDummy2-Interval) and (X<MyXDummy2+Interval)) and
          (Y>MyYDummy) and (Y<MyYDummy2) or
         ((Y>MyYDummy-Interval)  and (Y<MyYDummy+Interval) or
          (Y>MyYDummy2-Interval) and (Y<MyYDummy2+Interval)) and
          (X>MyXDummy) and (X<MyXDummy2)
          then StringGrid1.Cursor:=crDefault
      else StringGrid1.Cursor:=crCross;
    end;
  end
  else if not creating then
  begin
    {If (StringGrid1.Cursor=crDefault) and ((MyCol<>MouseCol) or (MyRow<>MouseRow)) then with StringGrid1 do
    begin
      repaint;
      Canvas.brush.style:=bsclear;
      Canvas.pen.color:=clblack;
      Canvas.pen.width:=2;
      MyXDummy:=MyCol-DeltaMouseCol;
      MyYDummy:=MyRow-DeltaMouseRow;
      If MyXDummy<1 then MyXDummy:=1;
      If MyYDummy<1 then MyYDummy:=1;
      Canvas.Rectangle(MyXDummy*DefaultColwidth+(myxdummy-1)*Gridlinewidth,
                       MyYDummy*DefaultRowHeight+(myydummy-1)*gridlinewidth,
                       (MyXDummy+DeltaCol+1)*DefaultColWidth+(myxdummy+DeltaCol)*GridLineWidth,
                       (myydummy+DeltaRow+1)*DefaultRowHeight+(myydummy+DeltaRow)*GridLineWidth);
      isdragging:=true;
      exit;
    end;}
    if (StringGrid1.cursor=crCross) and ((MyCol<=0) or (MyRow<=0)) and StartSelecting then
    begin
      if (StringGrid1.selection.left<>drawingselection.left) or
     (StringGrid1.selection.right<>drawingselection.right) or
     (StringGrid1.selection.top<>drawingselection.top) or
     (StringGrid1.selection.bottom<>drawingselection.bottom) then
      With StringGrid1.Selection do
        If (MyCol<Left) or (MyCol>Right) or (MyRow<Top) or (MyRow>Bottom) then
        begin
          MouseCol:=MyCol;
          MouseRow:=MyRow;
          StringGrid1SelectCells(Sender, [ssshift], X, Y);
          if (((StringGrid1.selection.bottom-StringGrid1.toprow+2)*StringGrid1.RowHeights[1]+(StringGrid1.selection.bottom-StringGrid1.toprow+3)*StringGrid1.GridLineWidth) > StringGrid1.clientheight)
          and not noscroll and (myrow>=StringGrid1.fixedrows) then
            StringGrid1.perform(WM_VSCROLL,SB_LINEDOWN,0);
        end;
    end;
  end;
  creating:=false;
end;

procedure TEdit2Frm.StringGrid1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if button=mbLeft then
  begin
    StringGrid1.MouseToCell(X,Y,MouseCol, MouseRow);
    If (MouseCol=0) or (MouseRow=0) then
    begin
      StringGrid1SelectCells(Sender, Shift, X, Y);
      //Settimer(Handle, 2,60, nil);
      StartSelecting:=true;
      StringGrid1.FGridState:=gsSelecting;
    end;
    {If StringGrid1.Cursor=crDefault then with StringGrid1.Selection do  //Drag and drop, currently disabled
    begin
      DeltaCol:=right-left;
      DeltaRow:=Bottom-Top;
      DeltaMouseCol:=MouseCol-Left;
      DeltaMouseRow:=MouseRow-Top;
    end;}
  end;
end;

procedure TEdit2Frm.StringGrid1SelectCells(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var MyCol, MyRow: LongInt;
begin
    StringGrid1.MouseToCell(X,Y,MyCol, MyRow);
    if MyCol=0 then
    begin
      MyCol:=1;
      If MyRow=0 then //Select all
      begin
        MyRow:=1;
        DrawingSelection:=TGridrect(Rect(StringGrid1.Colcount-1, StringGrid1.RowCount-1, MyCol, MyRow));
      end
      else
      begin //Select row
         If ssShift in shift then
           DrawingSelection:=TGridrect(Rect(StringGrid1.Colcount-1, MyRow, MyCol, StringGrid1.row))
         else DrawingSelection:=TGridrect(Rect(StringGrid1.Colcount-1, MyRow, MyCol,MyRow));
       end;
    end
    else If MyRow=0 then //Select col
    begin
      MyRow:=1;
      If ssShift in shift then
        DrawingSelection:=TGridrect(Rect(MyCol,StringGrid1.Rowcount-1,StringGrid1.col, MyRow))
      else DrawingSelection:=TGridrect(Rect(MyCol,StringGrid1.Rowcount-1,MyCol,MyRow));
    end;
    if (StringGrid1.selection.left<>drawingselection.left) or
     (StringGrid1.selection.right<>drawingselection.right) or
     (StringGrid1.selection.top<>drawingselection.top) or
     (StringGrid1.selection.bottom<>drawingselection.bottom) then
     begin
        StringGrid1.Selection:=drawingSelection;
        If StringGrid1.Editormode then
        begin
          StringGrid1.Editormode:=false;
          StringGrid1.Options:=StringGrid1.Options-[goEditing];
        end;
        StringGrid1.Repaint;
      end;
end;

procedure TEdit2Frm.PopupMenu1Popup(Sender: TObject);
var canundo: Boolean;
begin
  Paste1.Enabled:=Clipboard.HasFormat(CF_TEXT) and not readonly;
  Cut1.Enabled:=(StringGrid1.Editormode or
    (StringGrid1.Selection.left=1) and (StringGrid1.Selection.right=StringGrid1.Colcount-1)) and not readonly;
  Delete2.Enabled:=(StringGrid1.Editormode or
    ((StringGrid1.Selection.Left=StringGrid1.Selection.Right) and (StringGrid1.Selection.Top=StringGrid1.Selection.Bottom)) or
     (StringGrid1.Selection.Left=1) and (StringGrid1.Selection.Right=StringGrid1.Colcount-1)) and not readonly;
  If (StringGrid1.Editormode) and (goEditing in StringGrid1.Options) and (StringGrid1.InplaceEditor<>nil) then
  begin
    case StringGrid1.InplaceEditor.Perform(EM_CANUNDO,0,0) of
      0: CanUndo:=false;
      1: CanUndo:=true;
    end;
    Undo2.Enabled:=CanUndo and fUndo and not readonly;
    Redo2.Enabled:=CanUndo and not fUndo and not readonly;
  end
  else
  begin
    Undo2.Enabled:=false;
    Redo2.Enabled:=false;
  end;
end;

procedure TEdit2Frm.E2YChange(Sender: TObject);
begin
  if not creating then modified:=true;
end;

procedure TEdit2Frm.StringGrid1MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var mycol,Myrow, mycol2,Myrow2: Longint;
    MyString: String;
    i,j: Integer;
begin
  If StartSelecting then
  begin
    StartSelecting:=false;
    StringGrid1.FGridState:=gsNormal;
    //KillTimer(Handle, 2);
  end;
  EditEditClick(Sender);
  {if isdragging and (Button=mbLeft) then with StringGrid1 do
  begin
    isdragging:=false;
    MouseToCell(X,Y, MyCol2, MyRow2);
    MyCol2:= MyCol2-DeltaMouseCol;
    MyRow2:=MyRow2-DeltaMouseRow;
    If MyCol2<1 then MyCol2:=1;
    If MyRow2<1 then MyRow2:=1;
    If CanDrop(TGridRect(Rect(MyCol2,MyRow2,MyCol2+Selection.Right-Selection.Left, MyRow2+Selection.Bottom-Selection.top))) then
    begin
      MyString:='';
      for MyRow:= Selection.Top to Selection.Bottom do
      begin
        for MyCol := Selection.Left to Selection.Right do
        begin
          MyString:=MyString+Cells[MyCol, MyRow]+#9;
          Cells[MyCol, MyRow]:='';
        end;
        MyString:=Copy(MyString,0,Length(Mystring)-1)+#$D+#$A;
      end;
      i:=0;
      j:=0;
      While length(myString)>0 do
      begin
        if (Pos(#9,MyString)<Pos(#$D,MyString)) and (Pos(#9,MyString)<>0) then
        begin
          Cells[MyCol2+i, MyRow2+j]:=Copy(MyString,0,Pos(#9,MyString)-1);
          Delete(MyString,1,Pos(#9,Mystring));
          Inc(i);
        end
        else
        begin
          Cells[MyCol2+i, MyRow2+j]:=Copy(MyString,0,Pos(#$D,MyString)-1);
          Delete(MyString,1,Pos(#$D,Mystring)+1);
          i:=0;
          inc(j);
          if MyRow2+j=rowcount then
          begin
            rowcount:=rowcount+1;
            Cells[0,StringGrid1.rowcount-1]:=IntToStr(rowcount-1);
          end;
        end
      end;
      With StringGrid1.Selection do
      begin
        If right=Col then
          if bottom=row then Selection:=TGridrect(Rect(MyCol2,MyRow2, MyCol2+DeltaCol,MyRow2+DeltaRow))
          else Selection:=TGridrect(Rect(MyCol2,MyRow2+DeltaRow, MyCol2+DeltaCol,MyRow2))
        else
          if bottom=row then Selection:=TGridrect(Rect(MyCol2+DeltaCol,MyRow2, MyCol2,MyRow2+DeltaRow))
          else Selection:=TGridrect(Rect(MyCol2+DeltaCol,MyRow2+DeltaRow, MyCol2,MyRow2));
      end;
      //Selection:=TGridrect(Rect(MyCol2,MyRow2, MyCol2+DeltaCol,MyRow2+DeltaRow));
    end;
    repaint;
  end;}
end;

procedure TEdit2Frm.EditCutClick(Sender: TObject);
var MyString: String;
    mydummy, MyCol, MyRow: LongInt;
begin
  {with StringGrid1 do
      for MyRow:= Selection.Top to Selection.Bottom do
      begin
        for MyCol := Selection.Left to Selection.Right do
        begin
          MyString:=concat(MyString, Cells[myCol,MyRow]);
          MyString:=concat(MyString, #9);
        end;
        MyString:=Copy(MyString,0,Length(Mystring)-1)+#$D+#$A;
      end;}

  If StringGrid1.Editormode and (StringGrid1.InplaceEditor<>nil) then (StringGrid1 as TCustomGrid).InplaceEditor.Perform(WM_CUT,0,0)
  else
  begin
    MyDummy:=StringGrid1.Selection.Bottom-StringGrid1.Selection.Top+1;
    If Application.MessageBox(PChar('You are about to remove '+IntToStr(mydummy)+' datasets.'+#$D#$A+'Continue? (No undo possible.)'), 'TectonicsFP', mb_OKCancel)=mrOK then
    begin
      MyString:='';
      with StringGrid1 do
      for MyRow:= Selection.Top to StringGrid1.Rowcount-MyDummy do
      begin
        for MyCol := Selection.Left to Selection.Right do
        begin
          If MyRow<=selection.bottom then MyString:=MyString+Cells[MyCol, MyRow]+#9; //bugfix 981202
          Cells[MyCol, MyRow]:=Cells[MyCol, MyRow+MyDummy];
        end;
        If MyRow<=selection.bottom then MyString:=Copy(MyString,0,Length(Mystring)-1)+#$D+#$A; //bugfix 981202
      end;
      ClipBoard.AsText:=Mystring;
      if StringGrid1.Rowcount-mydummy>1 then StringGrid1.RowCount:=StringGrid1.RowCount-MyDummy
      else
      begin
        StringGrid1.rowcount:=2;
        StringGrid1.col:=1;
        StringGrid1.row:=1;
      end;
      modified:=true;
    end;
  end;
end;

function TEdit2Frm.CanDrop(FRange: TGridRect): Boolean;
var i,j: Integer;
begin
  Result:=true;
  For i:=FRange.Left to FRange.Right do
    For j:=FRange.Top to FRange.Bottom do
      If StringGrid1.Cells[i,j]<>'' then Result:= False;
  If not Result then Result:=Application.MessageBox('Target area not empty. Overwrite?', 'TectonicsFP', mb_OKCancel)=mrOK;
end;

procedure TEdit2Frm.StringGrid1DblClick(Sender: TObject);
begin
  if not readonly then with StringGrid1 do
  begin
    Options:=Options+[goEditing];
    Editormode:=true;
  end;
end;

procedure TEdit2Frm.Delete1Click(Sender: TObject);
var Selection3, Selection2 : LongInt;
    PSelection : ^TSelection;
begin
  with StringGrid1 do
    If Editormode then
    begin
      if inplaceeditor<>nil then selection2:=InplaceEditor.Perform(EM_GETSEL,0,0);
      PSelection:=@Selection2;
      if PSelection^.StartPos=PSelection^.EndPos then
      begin
        inc(PSelection^.EndPos);
        if StringGrid1.InplaceEditor<>nil then InplaceEditor.Perform(EM_SETSEL,PSelection^.StartPos,PSelection^.EndPos);
      end;
      if StringGrid1.InplaceEditor<>nil then InplaceEditor.Perform(WM_CLEAR,0,0);
    end
    else
      if (Selection.Left=Selection.Right) and
         (Selection.Top=Selection.Bottom) then Cells[Col,Row]:=''
      else Deletedataset1Click(Sender);
end;

procedure TEdit2Frm.DeleteDataset1Click(Sender: TObject);
begin
  With StringGrid1 do
    If Application.MessageBox(PChar('You are about to remove '+IntToStr(Selection.Bottom-Selection.Top+1)+' datasets.'+#$D#$A+'Continue? (No undo possible.)'), 'TectonicsFP', mb_OKCancel)=mrOK then
      DeleteRows(Sender);
end;

procedure TEdit2Frm.DeleteRows(Sender: TObject);
var mydummy, MyCol, MyRow: longint;
begin
  With StringGrid1 do
  begin
    MyDummy:=Selection.Bottom-Selection.Top+1;
    If Selection.Bottom=RowCount-1 then //bugfix 990803 (cells were not cleared before)
      for MyRow:=Selection.Top to Selection.Bottom do
        for MyCol := FixedCols to Colcount-1 do
          Cells[MyCol, MyRow]:=''
    else
      for MyRow:= Selection.Top to StringGrid1.Rowcount-MyDummy-1 do  //bugfix 990803 (one dataset too much was moved before)
        for MyCol := FixedCols to Colcount-1 do
        begin
          Cells[MyCol, MyRow]:=Cells[MyCol, MyRow+MyDummy];
          Cells[MyCol, MyRow+MyDummy]:='';
        end;
      if rowcount-mydummy>1 then StringGrid1.RowCount:=StringGrid1.RowCount-MyDummy
      else
      begin
        rowcount:=2;
        col:=1;
        row:=1;
      end;
    modified:=true;
  end;
end;

procedure TEdit2Frm.DeleteRow(FRow: LongInt);
var MyCol, MyRow: longint;
begin
  With StringGrid1 do
  begin
    for MyRow:= FRow to Rowcount-1 do
      for MyCol := FixedCols to Colcount-1 do
          Cells[MyCol, MyRow]:=Cells[MyCol, MyRow+1];
      if RowCount>2 then RowCount:=RowCount-1
      else
      begin
        rowcount:=2;
        col:=1;
        row:=1;
      end;
    modified:=true;
  end;
end;

procedure TEdit2Frm.Selectdataset1Click(Sender: TObject);
var MySelection: TGridRect;
begin
  With MySelection do
  begin
    Top:=StringGrid1.Row;
    Bottom:=StringGrid1.Row;
    Left:=StringGrid1.ColCount-1;
    Right:=1;
  end;
  StringGrid1.Selection:=MySelection;
  StringGrid1.repaint;
end;

procedure TEdit2Frm.SelectAll1Click(Sender: TObject);
var MySelection: TGridRect;
begin
  With MySelection do
  begin
    Top:=StringGrid1.RowCount-1;
    Bottom:=1;
    Left:=StringGrid1.ColCount-1;
    Right:=1;
  end;
  StringGrid1.Selection:=MySelection;
  StringGrid1.repaint;
end;

procedure TEdit2Frm.FormCreate(Sender: TObject);
begin
  Coldummy:=0;
  Rowdummy:=0;
  StringGrid1.OnShowEditor:=StringGrid1ShowEditor;
  Width:=640;
  ActiveControl:=Stringgrid1;
end;

procedure TEdit2Frm.Goto1Click(Sender: TObject);
begin
  Previous1.Enabled:=StringGrid1.Row>1;
  Next1.Enabled:=StringGrid1.Row<StringGrid1.Rowcount-1;
end;

procedure TEdit2Frm.First1Click(Sender: TObject);
begin
  StringGrid1.Selection:=TGridrect(Rect(StringGrid1.Colcount-1, 1, 1,1));
  StringGrid1.repaint;
end;

procedure TEdit2Frm.Last1Click(Sender: TObject);
begin
  StringGrid1.Selection:=TGridrect(Rect(StringGrid1.Colcount-1, StringGrid1.Rowcount-1, 1,StringGrid1.Rowcount-1));
  StringGrid1.repaint;
end;

procedure TEdit2Frm.Next1Click(Sender: TObject);
begin
  StringGrid1.Selection:=TGridrect(Rect(StringGrid1.Colcount-1, StringGrid1.Row+1, 1,StringGrid1.Row+1));
  StringGrid1.repaint;
end;

procedure TEdit2Frm.Previous1Click(Sender: TObject);
begin
  StringGrid1.Selection:=TGridrect(Rect(StringGrid1.Colcount-1, StringGrid1.Row-1, 1,StringGrid1.Row-1));
  StringGrid1.repaint;
end;

Procedure TEdit2Frm.NewRow(Sender: TObject);
begin
  With StringGrid1 do
  begin
    RowCount:=RowCount+1;
    Cells[0,rowcount-1]:=IntToStr(RowCount-1);
    Row:=Row+1;
    Col:=1;
  end;
end;


procedure TEdit2Frm.Insertdataset1Click(Sender: TObject);
var mydummy, MyCol, MyRow: longint;
begin
  With StringGrid1 do
  begin
    RowCount:=RowCount+1;
    Cells[0,rowcount-1]:=IntToStr(RowCount-1);
    for MyRow:= RowCount downto Row do
      for MyCol := Fixedcols to ColCount do
        Cells[MyCol, MyRow]:=Cells[MyCol, MyRow-1];
    for MyCol := Fixedcols to ColCount do
      Cells[MyCol, Row]:='';
    col:=FixedCols;  
  end;
end;

procedure TEdit2Frm.FormActivate(Sender: TObject);
begin
  TecMainWin.SaveBtn.Enabled:=modified;
  TecMainWin.PrintBtn.Enabled:=true;
  TecMainWin.CopyBtn.Enabled:=true;
  EditEditClick(Sender);
end;

procedure TEdit2Frm.Print1Click(Sender: TObject);
begin
  if sender=tecmainwin.printbtn then
  with printer do
    begin
      title:='TectonicsFP - '+ExtractFileName(MyFilename);
      begindoc;
        SetMapMode(Canvas.handle,MM_LOMETRIC);
        SetBkMode(handle, TRANSPARENT);
        Canvas.Font.Name := 'Courier New';
        Canvas.Font.size:=-round(printfontsize * 1296/ Canvas.Font.PixelsPerInch);
        FillPrintCanvas(Canvas);
      enddoc;
   end
   else
  If TecMainWin.PrintDialog1.Execute then
  begin
    {PrntPrvForm:=TPrntPrvForm.Create(Application); //print preview for version 2.0
    With PrntPrvForm do
    begin
      PrintFilename:=MyFilename;
      Open(Self);
      showmodal;
    end;}
    with printer do
    begin
      title:='TectonicsFP - '+ExtractFileName(MyFilename);
      begindoc;
        SetMapMode(Canvas.handle,MM_LOMETRIC);
        SetBkMode(handle, TRANSPARENT);
        Canvas.Font.Name := 'Courier New';
        Canvas.Font.size:=-round(printfontsize * 1296/ Canvas.Font.PixelsPerInch);
        FillPrintCanvas(Canvas);
      enddoc;
   end;
 end;
end;

procedure TEdit2Frm.FillPrintCanvas(MyCanvas: TCanvas);
var myPageWidth, myPageHeight, myPageNumber, P_dpi_h, P_dpi_v, MyCellHeight: Integer;
    FRow : LongInt;
    MyRowcount: integer;
    vertoffset: Integer;  //in pixels
    CaretLeft, CaretTop, i: Integer;
    textdummy: string;
    MyPrintRect: TRect;
begin
  with MyCanvas do
  begin     //all canvas positions in 1/10 mm!!!
    VertOffset:=10; //offset in 1/10 mm
    MyCellHeight:=-round(printfontsize*10+vertoffset);  //cellheight in 1/10 mm
    MyPrintRect:=GetPrintRect;
    CaretLeft:=MyPrintRect.Left;
    CaretTop:=MyPrintRect.Top;
    Font.Style:=[fsBold];
    Textout(CaretLeft,CaretTop, 'Filename:');
    Font.Style:=[];
    Textout(CaretLeft+240, CaretTop, Copy(ExtractFilename(MyFileName), 0, 47));
    Font.Style:=[fsBold];
    Textout(CaretLeft+1300,CaretTop,'Page:');
    Font.Style:=[];
    Textout(CaretLeft+1420,CaretTop,InttoStr(Printer.PageNumber));
    Inc(CaretTop, round(MyCellHeight*1.5));
    if (E2Location.Text<>'') or (E2Date.Text<>'') then
    begin
      Font.Style:=[fsBold];
      Textout(CaretLeft, CaretTop, 'Location:');
      Font.Style:=[];
      Textout(CaretLeft+240, CaretTop, Copy(E2Location.Text, 0, 47));
      Font.Style:=[fsBold];
      Textout(CaretLeft+1300,CaretTop, 'Date:');
      Font.Style:=[];
      Textout(CaretLeft+1420, CaretTop, Copy(E2Date.Text, 0, 11));
      Inc(CaretTop, MyCellHeight);
    end;
    if (E2X.Text<>'') or (E2Y.Text<>'') or (E2Z.Text<>'') then
    begin
      Font.Style:=[fsBold];
      Textout(CaretLeft,CaretTop,'X:');
      Font.Style:=[];
      Textout(CaretLeft+50, CaretTop, Copy(E2X.Text, 0, 16));
      Font.Style:=[fsBold];
      Textout(CaretLeft+500, CaretTop, 'Y:');
      Font.Style:=[];
      Textout(CaretLeft+550, CaretTop, Copy(E2Y.Text, 0, 16));
      Font.Style:=[fsBold];
      Textout(CaretLeft+1000,CaretTop,'Z:');
      Font.Style:=[];
      Textout(CaretLeft+1050, CaretTop, Copy(E2Z.Text, 0, 16));
      Inc(CaretTop, MyCellHeight);
    end;
    If (E2Lithology.Text<>'') or (E2Formation.Text<>'') then
    begin
      Font.Style:=[fsBold];
      Textout(CaretLeft,CaretTop,'Lithology:');
      Font.Style:=[];
      Textout(CaretLeft+240, CaretTop, Copy(E2Lithology.Text, 0, 25));
      Font.Style:=[fsBold];
      Textout(CaretLeft+850, CaretTop, 'Formation:');
      Font.Style:=[];
      Textout(CaretLeft+1090, CaretTop, Copy(E2Formation.Text, 0, 25));
      Inc(CaretTop, MyCellHeight);
    end;
    if (E2TectUnit.Text<>'') or (E2Age.Text<>'') then
    begin
      Font.Style:=[fsBold];
      Textout(CaretLeft, CaretTop,'Tect. unit:');
      Font.Style:=[];
      Textout(CaretLeft+240, CaretTop, Copy(E2TectUnit.Text, 0, 25));
      Font.Style:=[fsBold];
      Textout(CaretLeft+850, CaretTop, 'Age:');
      Font.Style:=[];
      Textout(CaretLeft+1090, CaretTop, Copy(E2Age.Text, 0, 25));
      Inc(CaretTop, MyCellHeight);
    end;
    if E2Remarks.Text<>'' then
    begin
      Font.Style:=[fsBold];
      Textout(CaretLeft, CaretTop, 'Remarks:');
      Font.Style:=[];
      Textout(CaretLeft+240, CaretTop, Copy(E2Remarks.Text, 0, 65));
      Inc(CaretTop, MyCellHeight);
    end;
    Inc(CaretTop, Round(MyCellHeight*0.5));
    Font.Style:=[fsBold];
    case E2Extension of
      COR, FPL: Textout(CaretLeft, CaretTop, ' No.   Plane          Lineation    Se Qu   Comment');
      PLN     : Textout(CaretLeft, CaretTop, ' No. DipDir  Dip    Comment');
      LIN     : Textout(CaretLeft, CaretTop, ' No. Azimuth Plunge Comment');
      AZI     : Textout(CaretLeft, CaretTop, ' No. Azimuth  Comment');
      PTF     : Textout(CaretLeft, CaretTop, ' No.   Plane     Lineation   Se Qu P-Axis   T-Axis   B-Axis   Pi  Bw');
    end;
    CaretTop:=CaretTop+Round(MyCellHeight*0.5);
    {SetBkMode(MyCanvas.Handle, TRANSPARENT);
    with Pen do
    begin
      Style:=psSolid;
      width:=10;
    end;
    MoveTo(CaretTop,CaretLeft);
    LineTo(CaretTop,PrntPrvForm.ARight);}
    for FRow:= 1 to StringGrid1.Rowcount-1 do
    begin
      CaretTop:=CaretTop+MyCellHeight;
      If printer.printing then
        if CaretTop+MyCellHeight<MyPrintRect.Bottom then
        begin
          Printer.NewPage;
          CaretTop:=MyPrintRect.Top;
          Font.Style:=[fsBold];
          Textout(CaretLeft,CaretTop, 'Filename:');
          Font.Style:=[];
          Textout(CaretLeft+240, CaretTop, Copy(ExtractFilename(MyFileName), 0, 47));
          Font.Style:=[fsBold];
          Textout(CaretLeft+1300,CaretTop,'Page:');
          Font.Style:=[];
          Textout(CaretLeft+1420,CaretTop,InttoStr(Printer.PageNumber));
          Inc(CaretTop, round(MyCellHeight*1.5));
          Font.Style:=[fsBold];
          case E2Extension of
            COR, FPL: Textout(CaretLeft, CaretTop, ' No.   Plane          Lineation    Se Qu   Comment');
            PLN     : Textout(CaretLeft, CaretTop, ' No. DipDir  Dip    Comment');
            LIN     : Textout(CaretLeft, CaretTop, ' No. Azimuth Plunge Comment');
            AZI     : Textout(CaretLeft, CaretTop, ' No. Azimuth  Comment');
            PTF     : Textout(CaretLeft, CaretTop, ' No.   Plane     Lineation   Se Qu P-Axis   T-Axis   B-Axis   Pi  Bw');
          end;
          //MoveTo(CaretTop,CaretLeft);
          //LineTo(CaretTop,PrntPrvForm.ARight);
          Inc(CaretTop, round(MyCellHeight*1.5));
        end;
      textdummy:='   ';
      For i:=0 to trunc(log10(strtoint(StringGrid1.Cells[0,FRow]))) do Delete(Textdummy, 1, 1);
      Textdummy:=Textdummy+StringGrid1.Cells[0,FRow];
      Font.Style:=[];
      case E2Extension of
        COR, FPL: Textout(CaretLeft,CaretTop,textdummy+'  '+TrimString(StringGrid1.Cells[1,FRow],3,2)+'  '+
                    TrimString(StringGrid1.Cells[2,FRow],2,2)+'  '+TrimString(StringGrid1.Cells[3,FRow],3,2)+'  '+
                    TrimString(StringGrid1.Cells[4,FRow],2,2)+'  '+StringGrid1.Cells[5,FRow]+'  '+StringGrid1.Cells[6,FRow]+
                    '  '+Copy(StringGrid1.Cells[7,FRow], 0, 35));
        PLN, LIN:
          Textout(CaretLeft,CaretTop, textdummy+'  '+TrimString(StringGrid1.Cells[1,FRow],3,2)+'  '+
                     TrimString(StringGrid1.Cells[2,FRow],2,2)+'  '+Copy(StringGrid1.Cells[3,FRow], 0, 50));
        AZI: Textout(CaretLeft,CaretTop, textdummy+'  '+TrimString(StringGrid1.Cells[1,FRow],3,2)+'  '+Copy(StringGrid1.Cells[2,FRow], 0, 65));
        PTF: Textout(CaretLeft,CaretTop,textdummy+' '+TrimString(StringGrid1.Cells[1,FRow],3,2)+' '+
                    TrimString(StringGrid1.Cells[2,FRow],2,2)+' '+TrimString(StringGrid1.Cells[3,FRow],3,2)+' '+
                    TrimString(StringGrid1.Cells[4,FRow],2,2)+' '+StringGrid1.Cells[5,FRow]+' '+StringGrid1.Cells[6,FRow]+
                    ' '+TrimString(StringGrid1.Cells[7,FRow],3,0)+' '+TrimString(StringGrid1.Cells[8,FRow],2,0)+
                    ' '+TrimString(StringGrid1.Cells[9,FRow],3,0)+' '+TrimString(StringGrid1.Cells[10,FRow],2,0)+
                    ' '+TrimString(StringGrid1.Cells[11,FRow],3,0)+' '+TrimString(StringGrid1.Cells[12,FRow],2,0)+
                    ' '+TrimString(StringGrid1.Cells[13,FRow],2,0)+' '+TrimString(StringGrid1.Cells[14,FRow],2,0));
      else break;
    end;
  end;
  end;
end;


procedure TEdit2Frm.PriStpClick(Sender: TObject);
begin
  TecMainWin.PrinterSetupDialog1.Execute;
end;

procedure TEdit2Frm.StringGrid1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  EditEditClick(Sender);
  if key=46 then modified:=true;
end;

end.
