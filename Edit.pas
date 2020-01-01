unit Edit;

interface

uses
  Windows, Classes, Graphics, Controls, SysUtils,
  Messages, Forms, Dialogs, Clipbrd, Menus, Printers,
  StdCtrls, types, ComCtrls, ExtCtrls, Fileops;

type
  TMyMemo = class(TMemo)
  private
    FHasSelection: boolean;
  protected
    function GetSelection: Boolean;
    procedure SetSelection(var FHasSelection: Boolean);
  published
    property HasSelection: Boolean read GetSelection write SetSelection;
  end;

  TEditForm = class(TForm)
    MainMenu1: TMainMenu;
    EditFile1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    Close1: TMenuItem;
    Separator1: TMenuItem;
    Save1: TMenuItem;
    Separator2: TMenuItem;
    Print1: TMenuItem;
    PriStp: TMenuItem;
    Separator3: TMenuItem;
    Exit1: TMenuItem;
    EditEdit: TMenuItem;
    EditCut: TMenuItem;
    EditCopy: TMenuItem;
    EditPaste: TMenuItem;
    Delete1: TMenuItem;
    SelectAll1: TMenuItem;
    SaveDialog1: TSaveDialog;
    Separator5: TMenuItem;
    Convert1: TMenuItem;
    Correct1: TMenuItem;
    Settings1: TMenuItem;
    Fonts1: TMenuItem;
    Options1: TMenuItem;
    Find1: TMenuItem;
    Replace1: TMenuItem;
    N1: TMenuItem;
    DeleteLine1: TMenuItem;
    FindNext1: TMenuItem;
    Saveas1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    Undo1: TMenuItem;
    Redo1: TMenuItem;
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
    Memo1: TMemo;
    N6: TMenuItem;
    Sort1: TMenuItem;
    OD2ndVersion1: TMenuItem;
    NewD2ndVersion1: TMenuItem;
    Editor1: TMenuItem;
    procedure Close1Click(Sender: TObject);
    procedure New1Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure Print1Click(Sender: TObject);
    procedure PriStpClick(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure CutToClipboard(Sender: TObject);
    procedure CopyToClipboard(Sender: TObject);
    procedure PasteFormClipboard(Sender: TObject);
    procedure Delete(Sender: TObject);
    procedure SelectAll(Sender: TObject);
    procedure Open(const AFilename: string; ANew: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormResize(Sender: TObject);
    procedure Fonts1Click(Sender: TObject);
    procedure UpdateMenus(Sender: TObject);
    procedure DeleteLine1Click(Sender: TObject);
    procedure Memo1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Find1Click(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure FindNext1Click(Sender: TObject);
    procedure Replace1Click(Sender: TObject);
    procedure ReplaceDialog1Replace(Sender: TObject);
    procedure Undo1Click(Sender: TObject);
    procedure Redo1Click(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure Memo1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Memo1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormDeactivate(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure Memo1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Memo1StartDrag(Sender: TObject; var DragObject: TDragObject);
    procedure Options1Click(Sender: TObject);
    procedure Sort1Click(Sender: TObject);
    procedure NewD2ndVersion1Click(Sender: TObject);
    procedure OD2ndVersion1Click(Sender: TObject);
    procedure Convert1Click(Sender: TObject);
    procedure Correct1Click(Sender: TObject);
  private
    MyFileName: string;
    FModified, new, creating, undo,replace: boolean;
    FindDialog1: TFindDialog;
    ReplaceDialog1: TReplaceDialog;
    procedure DisplayPosition(Sender: TObject);
    procedure SetModified(Value: boolean);
    property Modified: boolean read FModified write SetModified;
  end;

const
  { Default word delimiters are any character except the core alphanumerics. }
  WordDelimiters: set of Char = [#0..#255] - ['a'..'z','A'..'Z','1'..'9','0'];
function SearchMemo(Memo: TCustomEdit;
                    const SearchString: String;
                    Options: TFindOptions): Boolean;

{ SearchBuf is a lower-level search routine for arbitrary text buffers.  Same
  rules as SearchMemo above.  If a match is found, the function returns a
  pointer to the start of the matching string in the buffer.  If no match,
  the function returns nil. }
function SearchBuf(Buf: PChar; BufLen: Integer;
                   SelStart, SelLength: Integer;
                   SearchString: String;
                   Options: TFindOptions): PChar;

//var EditForm: TEditForm;


implementation

{$R *.DFM}
uses tecmain, Edit;
function TMyMemo.GetSelection: Boolean;
begin
  result:=FHasSelection;
end;

procedure TMyMemo.SetSelection(var FHasSelection: boolean);
begin
  FHasSelection := SelLength <> 0;
end;

procedure TEditForm.Close1Click(Sender: TObject);
begin
  Close;                   
end;

procedure TEditForm.New1Click(Sender: TObject);
begin
  TecMainWin.EditNewChild(Sender);
end;

procedure TEditForm.Open1Click(Sender: TObject);
begin
  TecMainWin.EditOpenChild(Sender);
end;

procedure TEditForm.Save1Click(Sender: TObject);
begin
  if New then
    SaveAs1Click(Sender)
  else
  begin
    Memo1.Lines.SaveToFile(MyFileName);
    Modified := False;
  end;
end;

procedure TEditForm.SetModified(Value: boolean);
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
    Memo1.Modified:=False;
  end;
  If FModified<>Value then FModified:=Value;
end;

{  function IsReadOnly(const MyFileName: string): Boolean;
  begin
    Result := Boolean(FileGetAttr(MyFileName) and faReadOnly);
    if Result then MessageDlg(Format('%s is read only.',
      [ExtractMyFileName(MyFileName)]), mtWarning, [mbOK], 0);
  end;

var
    f: Textfile;
    Line: Integer;

begin
  if (MyFileName = '') or IsReadOnly(MyFileName) then SaveAs1Click(Sender)
  else
    begin
      AssignFile(F, MyFileName);
      Rewrite(F);
      Line:=-1;
      If OEMConvert then
        begin
          LineBuffer:=StrAlloc(256);
          If (Memo1.Lines.Count - 1)>=1 then
            begin
              for Line := 0 to Memo1.Lines.Count - 2 do
                begin
                  StrPCopy (LineBuffer,Memo1.Lines[Line]);
                  ANSIToOEM(LineBuffer,LineBuffer);
                  Writeln(F,LineBuffer);
                end;
            end;
          Inc(Line);
          StrPCopy (LineBuffer,Memo1.Lines[Line]);
          ANSIToOEM(LineBuffer,LineBuffer);
          Write(F,LineBuffer);
          StrDispose(LineBuffer);
        end
      else
        begin
          If (Memo1.Lines.Count - 1)>=1 then
            begin
              for Line := 0 to Memo1.Lines.Count - 2 do
                begin
                  Writeln(F,Memo1.Lines[Line]);
                end;
              end;
          Inc(Line);
          write(f, Memo1.Lines[Line]);
        end;
      CloseFile(F);
      Memo1.Modified := False;
  end;
end;}

procedure TEditForm.SaveAs1Click(Sender: TObject);
var saveflag,exitflag, retryflag: boolean;
    ext : Tstring4;
begin
  with SaveDialog1 do
  begin
    FileName := MyFileName;
    FilterIndex:=EditSaveFilterIndexStore;
  end;
  retryflag:=false;
  Repeat
    Exitflag:=false;
    If not retryflag then
    case ExtractExtension(MyFilename) of
      FPL: SaveDialog1.FilterIndex:=1;
      COR: SaveDialog1.FilterIndex:=2;
      PLN: SaveDialog1.FilterIndex:=3;
      LIN: SaveDialog1.FilterIndex:=4;
      AZI: SaveDialog1.FilterIndex:=5;
      NDF: SaveDialog1.FilterIndex:=6;
      INV: SaveDialog1.FilterIndex:=7;
      PTF: SaveDialog1.FilterIndex:=8;
      TXT: SaveDialog1.FilterIndex:=9;
      //HOE: SaveDialog1.FilterIndex:=10;
    end;
    SaveFlag:= SaveDialog1.Execute;
    If SaveFlag then
    begin
      if {(ExtractFileExt(MyFileName)='') or} (ExtractFileExt(SaveDialog1.FileName)='') then
        case SaveDialog1.filterindex of
          1: ext := '.fpl';
          2: ext := '.cor';
          3: ext := '.pln';
          4: ext := '.lin';
          5: ext := '.azi';
          6: ext := '.n00';
          7: ext := '.inv';
          8: ext := '.t00';
          9: ext := '.txt';
        end
      else ext:=ExtractFileExt(SaveDialog1.Filename);
      ExitFlag:=True;
      If FileExists(ChangeFileExt(SaveDialog1.FileName,ext)) then
        Case MessageDlg(ChangeFileExt(SaveDialog1.FileName,ext)+#10#13+
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
    Save1Click(Sender);
  end;
end;

procedure TEditForm.Print1Click(Sender: TObject);
var
  Line: Integer;
  PrintText: System.Text;
begin                                                      
  if TecMainWin.PrintDialog1.Execute then
  begin
    AssignPrn(PrintText);
    Printer.Title:='TectonicsFP - '+ExtractFilename(MyFilename);
    Rewrite(PrintText);
    Printer.Canvas.Font := Memo1.Font;
    for Line := 0 to Memo1.Lines.Count - 1 do
      Writeln(PrintText, Memo1.Lines[Line]);
    System.Close(PrintText);                                                             
  end;
end;

procedure TEditForm.PriStpClick(Sender: TObject);
begin
  TecMainWin.PrinterSetupDialog1.Execute;
end;

procedure TEditForm.Exit1Click(Sender: TObject);
begin
   TecMainWin.Exit1Click(Sender);
end;

procedure TEditForm.CutToClipboard(Sender: TObject);
begin
   Memo1.CutToClipboard;
end;

procedure TEditForm.CopyToClipboard(Sender: TObject);
begin
  Memo1.CopyToClipboard;
end;

procedure TEditForm.PasteFormClipboard(Sender : TObject);
begin
   Memo1.PasteFromClipboard;
end;

procedure TEditForm.Delete(Sender: TObject);
begin
  Memo1.ClearSelection;
end;

procedure TEditForm.SelectAll(Sender: TObject);
begin
   Memo1.SelectAll;
end;

procedure TEditForm.FormResize(Sender: TObject);
begin
  TecMainWin.FormResize(Sender);
end;


procedure TEditForm.Open(const AFilename: string; ANew : boolean);
begin
  creating:= true;
  Cursor:=crHourglass;
  MyFileName := AFilename;
  New:=ANew;
  Finddialog1:=TFinddialog.create(nil);
  Finddialog1.OnFind:=FindDialog1Find;
  Replacedialog1:=TReplacedialog.create(nil);
  Replacedialog1.OnFind:=FindDialog1Find;
  Replacedialog1.OnReplace:=ReplaceDialog1Replace;
  If MyFilename='Untitled' then
  begin
    Caption := Caption +' - ['+ MyFilename+IntToStr(UntitledCounter) +']';
    MyFilename:=MyFilename+IntToStr(UntitledCounter);
  end
  else
    Caption := Caption +' - ['+ ExtractFilename(MyFileName) +']';
  Convert1.OnClick:=TecMainWin.Convert1Click;
  Correct1.OnClick:=TecMainWin.Correct1Click;
  try
  If not new then with Memo1 do
  begin                               
    Lines.LoadFromFile(MyFileName);
    SelStart := 0;
    Self.modified := False;
  end;
  TecMainWin.StatusBar1.Panels.Items[0].Text:='';
  Cursor:=crDefault;
  except   {can not open file}
    On EFOpenError do
      begin
        Globalfailed:=true;
        Screen.Cursor:=crDefault;
        MessageDlg('Can not open '+MyFileName+' !'#10#13+
        'File might be in use by another application.',
        mtError,[mbOk], 0);
        Close;
        Exit;
      end;
     On EInvalidOperation do
      begin
        Globalfailed:=true;
        Screen.Cursor:=crDefault;
        MessageDlg(MyFileName+' !'#10#13+
        'Is too large to edit.',
        mtError,[mbOk], 0);
        Close;
        Exit;
      end;
    end;
  creating:= false;
end;

procedure TEditForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  TecMainWin.StatusBar1.Panels.Items[1].Text:='';
  TecMainWin.StatusBar1.Panels.Items[0].Text:='';
  TecMainWin.SaveBtn.Enabled:=false;
  TecMainWin.PrintBtn.Enabled:=false;
  TecMainWin.CutBtn.Enabled:=false;
  TecMainWin.PasteBtn.Enabled:=false;
  TecMainWin.UndoBtn.Enabled:=false;
  TecMainWin.RedoBtn.Enabled:=false;
  Finddialog1.closedialog;
  Replacedialog1.closedialog;
  if TecMainWin.MDIChildCount <=1 then
    TecMainWin.Window1.Enabled := false;
  Action := caFree;
end;

procedure TEditForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
const
  SWarningText = 'Save changes to %s?';           
begin
  if Modified then
  begin
    case MessageDlg(Format(SWarningText, [MyFileName]), mtConfirmation,
      [mbYes, mbNo, mbCancel], 0) of
      idYes: Save1Click(Self);
      idCancel: CanClose := False;
      idNo: Modified:=false; //bugfix 980705
    end;
  end;
end;

procedure TEditForm.Fonts1Click(Sender: TObject);
begin
  TecMainWin.EditFontDialog.Font := Memo1.Font;
  if TecMainWin.EditFontDialog.Execute then
    Memo1.Font:=TecMainWin.EditFontDialog.Font;
end;

procedure TEditForm.UpdateMenus(Sender: TObject);
var
  HasSelection, CanUndo: Boolean;
  //Selection2 : LongInt;
  //PSelection : ^TSelection;
begin
  EditPaste.Enabled := Clipboard.HasFormat(CF_TEXT);
  SelectAll1.Enabled:=Memo1.Text<>'';
  Find1.Enabled:=SelectAll1.Enabled;
  Replace1.Enabled:=Find1.Enabled;
  DeleteLine1.Enabled:=SelectAll1.Enabled;
  HasSelection := Memo1.SelLength <> 0;
  EditCut.Enabled := HasSelection;
  EditCopy.Enabled := HasSelection;
  Delete1.Enabled := HasSelection;
  TecMainWin.CutBtn.Enabled:=HasSelection;
  TecMainWin.CopyBtn.Enabled:=HasSelection;
  TecMainWin.PasteBtn.Enabled:=EditPaste.Enabled;
  case Memo1.Perform(EM_CANUNDO,0,0) of
    0: CanUndo:=false;
    1: CanUndo:=true;
  end;
  Undo1.Enabled:=CanUndo and Undo;
  Redo1.Enabled:=CanUndo and not Undo;
  TecMainWin.UndoBtn.Enabled:=Undo1.Enabled;
  TecMainWin.RedoBtn.Enabled:=Redo1.Enabled;
end;


procedure TEditForm.DeleteLine1Click(Sender: TObject);
begin
  with Memo1 do
    begin
    Perform(EM_SETSEL,
       Perform(EM_LINEINDEX,Perform(EM_LINEFROMCHAR,SelStart,0),0),
       Perform(EM_LINEINDEX,Perform(EM_LINEFROMCHAR,SelStart,0),0)+
       Perform(EM_LINELENGTH,SelStart,0)+2);
    Perform(WM_CLEAR,0,0);
    end;
end;



procedure TEditForm.Memo1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  Screen.Cursor:=crDefault;
end;

function SearchMemo(Memo: TCustomEdit;
                    const SearchString: String;
                    Options: TFindOptions): Boolean;
var
  Buffer, P: PChar;
  Size: Word;
begin
  Result := False;
  if (Length(SearchString) = 0) then Exit;
  Size := Memo.GetTextLen;
  if (Size = 0) then Exit;
  Buffer := StrAlloc(Size + 1);
  try
    Memo.GetTextBuf(Buffer, Size + 1);
    P := SearchBuf(Buffer, Size, Memo.SelStart, Memo.SelLength,
                   SearchString, Options);
    if P <> nil then
    begin
      Memo.Perform(EM_SETSEL,P-Buffer,P-Buffer+Length(Searchstring));
      Memo.Perform(EM_SCROLLCARET,0,0);
      Result := True;
    end;
  finally
    StrDispose(Buffer);
  end;
end;    


function SearchBuf(Buf: PChar; BufLen: Integer;
                   SelStart, SelLength: Integer;
                   SearchString: String;
                   Options: TFindOptions): PChar;
var
  SearchCount, I: Integer;
  C: Char;
  Direction: Shortint;
  CharMap: array [Char] of Char;

  function FindNextWordStart(var BufPtr: PChar): Boolean;
  begin                   { (True XOR N) is equivalent to (not N) }
    Result := False;      { (False XOR N) is equivalent to (N)    }
     { When Direction is forward (1), skip non delimiters, then skip delimiters. }
     { When Direction is backward (-1), skip delims, then skip non delims }
    while (SearchCount > 0) and
          ((Direction = 1) xor (BufPtr^ in WordDelimiters)) do
    begin
      Inc(BufPtr, Direction);
      Dec(SearchCount);
    end;
    while (SearchCount > 0) and
          ((Direction = -1) xor (BufPtr^ in WordDelimiters)) do
    begin
      Inc(BufPtr, Direction);
      Dec(SearchCount);
    end;
    Result := SearchCount > 0;
    if Direction = -1 then
    begin   { back up one char, to leave ptr on first non delim }
      Dec(BufPtr, Direction);
      Inc(SearchCount);
    end;
  end;

begin
  Result := nil;
  if BufLen <= 0 then Exit;
  if frDown in Options then
  begin
    Direction := 1;
    Inc(SelStart, SelLength);  { start search past end of selection }
    SearchCount := succ(BufLen - SelStart - Length(SearchString));
    if SearchCount < 0 then Exit;
    if Longint(SelStart) + SearchCount > BufLen then Exit;
  end
  else
  begin
    Direction := -1;
    Dec(SelStart, Length(SearchString));
    SearchCount := succ(SelStart);
  end;
  if (SelStart < 0) or (SelStart > BufLen) then Exit;
  Result := @Buf[SelStart];

  { Using a Char map array is faster than calling AnsiUpper on every character }
  for C := Low(CharMap) to High(CharMap) do
    CharMap[C] := C;

  if not (frMatchCase in Options) then
  begin
    AnsiUpperBuff(PChar(@CharMap), sizeof(CharMap));
    AnsiUpperBuff(@SearchString[1], Length(SearchString));
  end;

  while SearchCount > 0 do
  begin
    if frWholeWord in Options then
      if not FindNextWordStart(Result) then Break;
    I := 0;
    while (CharMap[Result[I]] = SearchString[I+1]) do
    begin
      Inc(I);
      if I >= Length(SearchString) then
      begin
        if (not (frWholeWord in Options)) or
           (SearchCount = 0) or
           (Result[I] in WordDelimiters) then
          Exit;
        Break;
      end;
    end;                                        
    Inc(Result, Direction);                  
    Dec(SearchCount);
  end;
  Result := nil;
end;

procedure TEditForm.Find1Click(Sender: TObject);
begin
  Replace:=not FindDialog1.Execute;
end;

procedure TEditForm.FindDialog1Find(Sender: TObject);
begin
  FindNext1.Enabled := True;
  with Sender as TFindDialog do
    if not SearchMemo(Memo1, FindText, Options) then
    begin
      MessageDlg('Cannot find "' + FindText + '".', mtInformation, [mbOK], 0);
      TecMainWin.BringToFront;
    end
    else
    begin
      If Sender=FindDialog1 then CloseDialog
      else TecMainWin.BringToFront;
    end;
end;

procedure TEditForm.FindNext1Click(Sender: TObject);
begin
  If Replace then FindDialog1Find(ReplaceDialog1)
  else FindDialog1Find(FindDialog1);
end;

procedure TEditForm.Replace1Click(Sender: TObject);
begin
  Replace:= ReplaceDialog1.Execute;
end;

procedure TEditForm.ReplaceDialog1Replace(Sender: TObject);
var
  Found: Boolean;
begin
  with ReplaceDialog1 do
  begin
    if AnsiCompareText(Memo1.SelText, FindText) = 0 then
      Memo1.SelText := ReplaceText;
    Found := SearchMemo(Memo1, FindText, Options);
    while Found and (frReplaceAll in Options) do
    begin
      Memo1.SelText := ReplaceText;
      Found := SearchMemo(Memo1, FindText, Options);
    end;
    if (not Found) and (frReplace in Options) then
      ShowMessage('Cannot find "' + FindText + '".')
    else TecMainWin.BringToFront;
  end;
end;

procedure TEditForm.Undo1Click(Sender: TObject);
begin
  Memo1.Perform(EM_UNDO,0,0);
  undo:= false;
end;

procedure TEditForm.Redo1Click(Sender: TObject);
begin
  Memo1.Perform(EM_UNDO,0,0);
  undo:= true;
end;

procedure TEditForm.Memo1Change(Sender: TObject);
begin
  undo:=true;
  modified:=not creating;
end;

procedure TEditForm.PopupMenu1Popup(Sender: TObject);
var
  HasSelection, CanUndo: Boolean;
begin
  Paste1.Enabled := Clipboard.HasFormat(CF_TEXT);
  HasSelection := Memo1.SelLength <> 0;
  Cut1.Enabled := HasSelection;
  Copy1.Enabled := HasSelection;
  Delete2.Enabled := HasSelection;
  SelectAll2.Enabled:=Memo1.Text<>'';
  case Memo1.Perform(EM_CANUNDO,0,0) of
    0: CanUndo:=false;
    1: CanUndo:=true;
  end;
  Undo2.Enabled:=CanUndo and Undo;
  Redo2.Enabled:=CanUndo and not Undo;
end;

procedure TEditForm.Memo1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  DisplayPosition(Sender);
  UpdateMenus(Sender);
end;

procedure TEditForm.DisplayPosition(Sender: TObject);
begin
  TecMainWin.StatusBar1.simplepanel:= false;
  With Memo1 do
  begin
    if SelStart-perform(EM_LINEINDEX,-1,0)+1<0 then
        TecMainWin.StatusBar1.Panels.Items[1].Text:=
        IntToStr(Perform(EM_LINEFROMCHAR,perform(EM_LINEINDEX,-1,0),0)+1)+
        ': '+IntToStr(SelStart-perform(EM_LINEINDEX,-1,0)+1+sellength)
    else
        TecMainWin.StatusBar1.Panels.Items[1].Text:=
            IntToStr(Perform(EM_LINEFROMCHAR,perform(EM_LINEINDEX,-1,0),0)+1)+
            ': '+IntToStr(SelStart-perform(EM_LINEINDEX,-1,0)+1);
  end;
end;

procedure TEditForm.Memo1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  DisplayPosition(Sender);
  UpdateMenus(Sender);
end;

procedure TEditForm.FormDeactivate(Sender: TObject);
begin
  TecMainWin.StatusBar1.Panels.Items[1].Text :='';
end;

procedure TEditForm.FormActivate(Sender: TObject);
begin
  TecMainWin.PrintBtn.Enabled:=True;
  DisplayPosition(Sender);
  UpdateMenus(Sender);
end;

procedure TEditForm.Memo1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  {If (button= mbLeft) and (memo1.sellength <>0) then
    Memo1.BeginDrag(true);}
end;

procedure TEditForm.Memo1StartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  //CutToClipboard(Sender);
end;

procedure TEditForm.Options1Click(Sender: TObject);
begin
  TecMainWin.Options1Click(Application);
end;

procedure TEditForm.Sort1Click(Sender: TObject);
begin
  TecMainWin.Sort1Click(Application);
end;

procedure TEditForm.NewD2ndVersion1Click(Sender: TObject);
begin
  TecMainWin.NewD2ndVersion1Click(Sender);
end;

procedure TEditForm.OD2ndVersion1Click(Sender: TObject);
begin
  TecMainWin.OD2ndVersion1Click(Sender);
end;

procedure TEditForm.Convert1Click(Sender: TObject);
begin
  TecMainWin.Convert1Click(Sender);
end;

procedure TEditForm.Correct1Click(Sender: TObject);
begin
  TecMainWin.Correct1Click(Sender);
end;

end.
