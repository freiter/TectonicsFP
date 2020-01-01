unit Sortman;

interface

uses Windows, Classes, Graphics, Forms, Controls, Buttons,Messages,
  StdCtrls, ExtCtrls, SysUtils, Types, Draw, Dialogs, LowHem;

type
  TSortManual = class(TLHWin)
    CancelBtn: TBitBtn;
    SrcList: TListBox;
    DstList: TListBox;
    SrcLabel: TLabel;
    DstLabel: TLabel;
    WriteToFBtn: TBitBtn;
    Label4: TLabel;
    Label3: TLabel;
    VirtSrcList: TListBox;
    VirtDstList: TListBox;
    AppendBtn: TBitBtn;
    SaveDialog1: TSaveDialog;
    Label2: TLabel;
    PaintBox2: TPaintBox;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    IncludeBtn: TButton;
    IncAllBtn: TButton;
    ExcludeBtn: TButton;
    ExAllBtn: TButton;
    procedure BtnClick(Sender: TObject);
    procedure AllBtnClick(Sender: TObject);
    procedure MoveSelected(List1,VirtList1: TListbox; List2,VirtList2: TListbox);
    procedure SetItem(List: TListBox; Index: Integer);
    procedure SetButtons;
    procedure Compute(var List: TlistBox; var PaintB: TPaintBox);
    procedure Open(const AFilename1: string);
    procedure FillVirtList;
    procedure FillVisblList(var VirtList,VisblList : TListbox);
    procedure PaintBox2Paint(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject); override;
    procedure WriteToFBtnClick(Sender: TObject);
    procedure FormResize(Sender: TObject); override;
    function GetFirstSelection(List: TListbox): Integer;
    procedure PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer); override;
    procedure FindIteminList(MyVirtList: TListbox; const Myazim, Mydip: Single; var number: integer);
    procedure SelectSelected(List,VirtList: TListbox);
    procedure ListClick(Sender: TObject);
    procedure PaintBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    Sense,Quality: Integer;
    AzimB,PlungeB,AzimP,PlungeP,AzimT,PlungeT,Pitch,Azimuth,Plunge, DipDir, Dip: Single;
    Bew: Integer;
    ext: TExtension;
    procedure WMGetMinMaxInfo(var MSG: Tmessage); message WM_GetMinMaxInfo;
  published
    procedure Angelier1Click(Sender: TObject); override;
    end;

var SortManual: TSortManual;

// bugfix 20080305: function
// ReplaceStr('.', ',', FComment)) was replaced by
// ReplaceStr('.', DecimalSeparator, FComment))
// to remove a bug if the decimal separator was set to '.'

implementation

{$R *.DFM}
uses Fileops, Tecmain, Inspect;

procedure TSortManual.WMGetMinMaxInfo(var MSG: Tmessage);
Begin
  inherited;
  with PMinMaxInfo(MSG.lparam)^ do
  begin
    with ptMinTrackSize do
    begin
      X := MDIMinWidth;
      Y := MDIMinHeight;
    end;
    {with ptMaxTrackSize do
    begin
      X := 1000;
      Y := 750;
    end; }
  end;
end;


procedure TSortManual.Open(const AFilename1: string);
begin
  LHPlotType:=pt_SortMan;
  LHFilename := AFilename1;
  Ext := ExtractExtension(LHFilename);
  Paintbox1.Align:=alnone;
  Paintbox1.bringtofront;
  Paintbox1.Popupmenu:=TecMainWin.Popupmenu1;
  Paintbox1.Hint:=Paintbox2.Hint;
  Paintbox1.ShowHint:=true;
  Paintbox1.Tag:=438;
  Edit1.Enabled:=false;
  PlotType1.Enabled:=True;
  PlotType2.Enabled:=True;
  Label1.visible:=false;
  Fonts1.visible:=false;
  Number1.Checked:=globallhnumbering;
  ChangeLabel1.visible := false;
  Export1.Enabled:=false;
  Print1.Enabled:=false;
  Copy1.Enabled:=false;
  Angelier1.OnClick:=Angelier1Click;
  Hoeppener1.OnClick:=Angelier1Click;
  PtAxes1.OnClick:=Angelier1Click;
  LHPoleflag:=false;
  case Ext of
    COR,FPL,PEF,PEK, HOE:
    begin
      ptaxes1.enabled:=false;
      if SortFPLPlotType=1 then
        Hoeppener1.Checked:=true;
    end;
    PLN:
    begin
      //ptaxes1.enabled:=True;
      Angelier1.Caption:='Great Circles';
      Hoeppener1.Caption:='Pi-plot';
      ptAxes1.Caption:='Dip lines';
      Case SortPLNPlotType of
        1: Hoeppener1.Checked:=True;
        2: ptAxes1.Checked:=True;
      end;
    end;
    LIN:
    begin
      PlotType1.Enabled:=false;
      PlotType2.Enabled:=false;
    end;
    PTF:
    begin
      case SortPTFPlotType of
        1: Hoeppener1.Checked:=true;
        2: ptaxes1.checked:=true;
      end;
      LHFillbrush.Color:=clRed;
      LHFillbrush2.Color:=clBlue;
    end;
  end;
  LHOnceClick := false;
  TecmainWin.ArrangeMenu(Nil);
  FormResize(Nil);
  SrcLabel.Caption := SrcLabel.Caption+' '+ExtractFileName(LHFilename);
  Label2.Caption := '1';
  LHfailed := false;
  SetLHProperties(LHPlotType);
  If Inspectorform<>nil then InspectorForm.Initialize(Self);
  FillVirtList;
  FillVisblList(VirtSrcList,SrcList);
  SetItem(VirtSrcList, 0);
  SetItem(SrcList, 0);
end;

procedure ReadFPLStr(Line : String; var FSense, FQuality: Integer; var FDipDir, FDip, FAzimuth, FPlunge: Single; var FComment: String; var z : Integer);
var i, err : Integer;
    ch : Char;
begin
 i := 1;
 FComment := '';
 repeat
   ch := Line[i];
   if Ch <> tfpListSeparator then FComment := FComment + Ch;
   inc(i);
 until ch = tfpListSeparator;
 Val(FComment, z, err);
 FComment := '';
 repeat
   ch := Line[i];
   if Ch <> tfpListSeparator then FComment := FComment + ch;
   inc(i);
 until ch = tfpListSeparator;
 Val(FComment, fSense, err);
 FComment := '';
 repeat
   ch := Line[i];
   if Ch <> tfpListSeparator then FComment := FComment + ch;
   inc(i);
 until ch = tfpListSeparator;
 Val(FComment, fQuality, err);
 FComment := '';
 repeat
   ch := Line[i];
   if Ch <> tfpListSeparator then FComment := FComment + ch;
   inc(i);
 until ch = tfpListSeparator;
 fDipDir:=StrToFloat(ReplaceStr('.', DecimalSeparator, FComment)); //bugfix 080429
 FComment := '';
 repeat
   ch := Line[i];
   if Ch <> tfpListSeparator then FComment := FComment + ch;
   inc(i);
 until ch = tfpListSeparator;
 fDip:=StrToFloat(ReplaceStr('.', DecimalSeparator, FComment));  //bugfix 080429
 FComment := '';
 repeat
   ch := Line[i];
   if Ch <> tfpListSeparator then FComment := FComment + ch;
   inc(i);
 until ch = tfpListSeparator;
 fAzimuth:=StrToFloat(ReplaceStr('.', DecimalSeparator, FComment));  //bugfix 080429
 FComment := '';
 repeat
   ch := Line[i];
   if Ch <> tfpListSeparator then FComment := FComment + ch;
   inc(i);
 until ch = tfpListSeparator;
 fPlunge := StrToFloat(ReplaceStr('.', DecimalSeparator, FComment));  //bugfix 080429
 FComment:='';
 if i<=Length(Line) then
 repeat
   ch:=Line[i];
   if ch<>#0 then FComment:=FComment+ch;
   inc(i);
 until ch=#0;
end;

procedure ReadPlnStr(Line : String; var FDipDir, FDip: Single; var FComment: String; var z : Integer);
var i, err : Integer;
    ch : Char;
begin
   i := 1;
   FComment := '';
   repeat
      ch := line[i];
      if Ch <> tfpListSeparator then FComment := FComment + Ch;
      inc(i);
   until ch = tfpListSeparator;
   Val(FComment, z, Err);
   FComment := '';
   repeat
       ch := Line[i];
       if Ch <> tfpListSeparator then FComment := FComment + ch;
       inc(i);
   until ch = tfpListSeparator;
   fDipDir := StrToFloat(ReplaceStr('.', DecimalSeparator, FComment));  //bugfix 080429
   FComment := '';
   repeat
     ch := Line[i];
     if Ch <> tfpListSeparator then FComment := FComment + ch;
     inc(i);
   until ch = tfpListSeparator;
   fDip := StrToFloat(ReplaceStr('.', DecimalSeparator, FComment));  //bugfix 080429
   FComment := '';
   if i<=Length(Line) then
   repeat
     ch:=Line[i];
     if ch<>#0 then FComment:=FComment+ch;
     inc(i);
   until ch=#0;
end;

procedure ReadPTFStr(Line: String; var z,FSense,FQuality: Integer; var FDipDir,FDip,
                     FAzimuth,FPlunge, FAzimB,FPlungeB,FAzimP,FPlungeP,FAzimT,
                     FPlungeT,FPitch: single; var Bew: Integer);
var i, err : Integer;
    ch : Char;
    Text : String;
begin
   i := 1;
   Text := '';
   repeat
     ch := Line[i];
     if Ch <> tfpListSeparator then Text := Text + Ch;
     inc(i);
   until ch = tfpListSeparator;
   Val(Text, z, Err);
   Text := '';
   repeat
     ch := Line[i];
     if Ch <> tfpListSeparator then Text := Text + ch;
     inc(i);
   until ch = tfpListSeparator;
   Val(Text, fSense, err);
   Text := '';
   repeat
     ch := Line[i];
     if Ch <> tfpListSeparator then Text := Text + ch;
     inc(i);
   until ch = tfpListSeparator;
   Val(Text, fquality, err);
   Text := '';
   repeat
       ch := Line[i];
       if Ch <> tfpListSeparator then Text := Text + ch;
       inc(i);
   until ch = tfpListSeparator;
   fDipDir:=StrToFloat(ReplaceStr('.', DecimalSeparator, Text));  //bugfix 080429
   Text := '';
   repeat
       ch := Line[i];
       if Ch <> tfpListSeparator then Text := Text + ch;
       inc(i);
   until ch = tfpListSeparator;
   fDip := StrToFloat(ReplaceStr('.', DecimalSeparator, Text));  //bugfix 080429
   Text := '';
   repeat
       ch := Line[i];
       if Ch <> tfpListSeparator then Text := Text + ch;
       inc(i);
   until ch = tfpListSeparator;
   fAzimuth := StrToFloat(ReplaceStr('.', DecimalSeparator, Text));  //bugfix 080429
   Text := '';
   repeat
       ch := Line[i];
       if Ch <> tfpListSeparator then Text := Text + ch;
       inc(i);
   until ch = tfpListSeparator;
   fPlunge := StrToFloat(ReplaceStr('.', DecimalSeparator, Text));  //bugfix 080429
   Text := '';
   repeat
       ch := Line[i];
       if Ch <> tfpListSeparator then Text := Text + ch;
       inc(i);
   until ch = tfpListSeparator;
   fAzimB:=StrToFloat(ReplaceStr('.', DecimalSeparator, Text));  //bugfix 080429
   Text := '';
   repeat
       ch := Line[i];
       if Ch <> tfpListSeparator then Text := Text + ch;
       inc(i);
   until ch = tfpListSeparator;
   fPlungeB:=StrToFloat(ReplaceStr('.', DecimalSeparator, Text));  //bugfix 080429
   Text := '';
   repeat
       ch := Line[i];
       if Ch <> tfpListSeparator then Text := Text + ch;
       inc(i);
   until ch = tfpListSeparator;
   fAzimP:=StrToFloat(ReplaceStr('.', DecimalSeparator, Text));  //bugfix 080429
   Text := '';
   repeat
       ch := Line[i];
       if Ch <> tfpListSeparator then Text := Text + ch;
       inc(i);
   until ch = tfpListSeparator;
   fPlungeP:=StrToFloat(ReplaceStr('.', DecimalSeparator, Text));  //bugfix 080429
   Text := '';
   repeat
     ch := Line[i];
     if Ch <> tfpListSeparator then Text := Text + ch;
     inc(i);
   until ch = tfpListSeparator;
   fAzimT:=StrToFloat(ReplaceStr('.', DecimalSeparator, Text));  //bugfix 080429
   Text := '';
   repeat
       ch := Line[i];
       if Ch <> tfpListSeparator then Text := Text + ch;
       inc(i);
   until ch = tfpListSeparator;
   fPlungeT:=StrToFloat(ReplaceStr('.', DecimalSeparator, Text));  //bugfix 080429
   Text := '';
   repeat
       ch := Line[i];
       if Ch <> tfpListSeparator then Text := Text + ch;
       inc(i);
   until ch = tfpListSeparator;
   FPitch := StrToFloat(ReplaceStr('.', DecimalSeparator, Text));  //bugfix 080429
   Text := '';
   repeat
       ch := Line[i];
       if Ch <> #0 then Text := Text + ch;
       inc(i);
   until ch =#0;
   Val(Text, Bew, err);
end;

procedure TSortManual.BtnClick(Sender: TObject);
var
  Index : Integer;
begin
  If Sender=IncludeBtn then
  begin
    Index := GetFirstSelection(SrcList);
    MoveSelected(SrcList,VirtSrcList, DstList, VirtDstList);
  end
  else
  begin
    Index := GetFirstSelection(DstList);
    MoveSelected(DstList,VirtDstList, SrcList, VirtSrcList);
  end;
  PaintBox1.Refresh;
  PaintBox2.Refresh;
end;

procedure TSortManual.AllBtnClick(Sender: TObject);
var
  I: Integer;
begin
  If sender=IncAllBtn then
  begin
    for I := 0 to DstList.Items.Count - 1 do
    begin
      DstList.Selected[i]:=false;
      VirtDstList.Selected[i]:=false;
    end;
    for I := 0 to SrcList.Items.Count - 1 do
    begin
      DstList.Items.AddObject(SrcList.Items[I], SrcList.Items.Objects[I]);
      VirtDstList.Items.AddObject(VirtSrcList.Items[I], VirtSrcList.Items.Objects[I]);
    end;
    SrcList.Items.Clear;
    VirtSrcList.Items.Clear;
    SetItem(DstList, 0);
    SetItem(VirtDstList, 0);
  end
  else
  begin
    for I := 0 to SrcList.Items.Count - 1 do
    begin
      SrcList.Selected[i]:=false;
      VirtSrcList.Selected[i]:=false;
    end;
    for I := 0 to DstList.Items.Count - 1 do
    begin
      SrcList.Items.AddObject(DstList.Items[I], DstList.Items.Objects[I]);
      VirtSrcList.Items.AddObject(virtDstList.Items[I], virtDstList.Items.Objects[I]);
    end;
    DstList.Items.Clear;
    VirtDstList.Items.Clear;
    SetItem(SrcList, 0);
    SetItem(VirtSrcList, 0);
  end;
  PaintBox1.Refresh;
  PaintBox2.Refresh;
end;

procedure TSortManual.MoveSelected(List1,VirtList1: TListbox; List2,VirtList2: TListbox);
var
  I, index: Integer;

begin
  for I:= 0 to List2.Items.Count - 1 do
  begin
    list2.selected[i]:=false;
    Virtlist2.selected[i]:=false;
  end;
  for I := List1.Items.Count - 1 downto 0 do
    if List1.Selected[I] then
    begin
      index:= List2.Items.AddObject(List1.Items[I], List1.Items.Objects[I]);
      VirtList2.Items.AddObject(VirtList1.Items[I], VirtList1.Items.Objects[I]);
      List1.Items.Delete(I);
      VirtList1.Items.Delete(I);
      setitem(list2,index);
      setitem(virtlist2,index);
      index:=i;
    end;
  setitem(list1,index);
  setitem(virtlist1,index);
end;

procedure TSortManual.SetButtons;
var
  SrcEmpty, DstEmpty: Boolean;
begin
  SrcEmpty := virtSrcList.Items.Count = 0;
  DstEmpty := virtDstList.Items.Count = 0;
  IncludeBtn.Enabled := not SrcEmpty;
  IncAllBtn.Enabled  := not SrcEmpty;
  ExcludeBtn.Enabled := not DstEmpty;
  ExAllBtn.Enabled   := not DstEmpty;
end;

function TSortManual.GetFirstSelection(List: TListbox): Integer;
begin
  for Result := 0 to List.Items.Count - 1 do
    if List.Selected[Result] then Exit;
  Result := LB_ERR;
end;

procedure TSortManual.SetItem(List: TListBox; Index: Integer);
var
  MaxIndex: Integer;
begin
  with List do
  begin
    MaxIndex := List.Items.Count - 1;
    if Index = LB_ERR then Index := 0
    else if Index > MaxIndex then Index := MaxIndex;
    Selected[Index] := True;
  end;
  SetButtons;
end;



procedure TSortManual.FillVirtList;
var F : TextFile;
    LineString : string;
    z : Integer;
    NoComment: Boolean;
    Comment: String;
begin
  Screen.Cursor := crHourGlass;
  try
    LHLocationInfo:=GetLocInfo(LHFilename);
    AssignFile(F, LHFilename);
    Reset(F);
    if not eof(f) then
    begin
      Z := 1;
      while not SeekEof(f) and not LHfailed do
      begin
        comment:='';
        case ext of
          COR, FPL, PEF, PEK, HOE:
          begin
            ReadFPLDataset(f, Sense, Quality, DipDir, Dip, Azimuth, Plunge, LHfailed, NoComment,ext,Comment);
            if not LHfailed and NoComment then
            begin
              if z < 100 then
              begin
                LineString := '0';
                if z < 10 then LineString := '00';
              end
              else LineString :='';
              //Bugfix 20071023 to make code independent from regional settings
              LineString := LineString + IntTostr(Z) + tfpListSeparator + IntToStr(Sense)+tfpListSeparator+IntToStr(Quality)+tfpListSeparator+
                ReplaceStr(',', '.', FormatFloat('##0.##',DipDir)) + tfpListSeparator +
                ReplaceStr(',', '.', FormatFloat('#0.##',Dip)) + tfpListSeparator +
                ReplaceStr(',', '.', FormatFloat('##0.##',Azimuth)) + tfpListSeparator +
                ReplaceStr(',', '.', FormatFloat('#0.##',Plunge)) + tfpListSeparator+Comment;
              VirtSrcList.Items.Add(LineString);
              inc(z);
            end; {if not failed}
          end; {case cor,fpl}
          PLN,LIN :
          begin
            ReadPLNDataset(F, DipDir, Dip, LHFailed, NoComment, Comment);
            if not LHfailed and NoComment then
            begin
              if z < 100 then
              begin
                LineString := '0';
                if z < 10 then LineString := '00';
              end
              else LineString :='';
              LineString:=LineString+IntTostr(Z)+tfpListSeparator +
                ReplaceStr(',', '.', FormatFloat('##0.##',DipDir)) + tfpListSeparator +
                ReplaceStr(',', '.', FormatFloat('#0.##',Dip)) + tfpListSeparator + Comment;
              VirtSrcList.Items.Add(LineString);
              inc(z);
            end; {if not failed}
          end;   {case pln, lin}
          PTF :
          begin
            ReadPTFDataset(F,Sense,Quality,DipDir,Dip,Azimuth,Plunge,AzimB,PlungeB,AzimP,PlungeP,
                   AzimT,PlungeT,Pitch,Bew, LHfailed,NoComment);
            if not LHfailed and NoComment then
            begin
              if z < 100 then
              begin
                LineString := '0';
                if z < 10 then LineString := '00';
              end
              else LineString :='';
              //bugfix 20071023
              LineString:=LineString+IntTostr(Z)+tfpListSeparator+IntToStr(Sense)+tfpListSeparator+ IntToStr(Quality)+tfpListSeparator+
              ReplaceStr(',', '.', FormatFloat('##0.##',DipDir)) + tfpListSeparator +
              ReplaceStr(',', '.', FormatFloat('#0.##',Dip)) + tfpListSeparator +
              ReplaceStr(',', '.', FormatFloat('##0.##',Azimuth)) + tfpListSeparator +
              ReplaceStr(',', '.', FormatFloat('#0.##',Plunge)) + tfpListSeparator +
              ReplaceStr(',', '.', FormatFloat('##0.##',AzimB)) + tfpListSeparator +
              ReplaceStr(',', '.', FormatFloat('#0.##',PlungeB))+ tfpListSeparator +
              ReplaceStr(',', '.', FormatFloat('##0.##',AzimP)) + tfpListSeparator +
              ReplaceStr(',', '.', FormatFloat('#0.##',PlungeP)) + tfpListSeparator +
              ReplaceStr(',', '.', FormatFloat('##0.##',AzimT)) + tfpListSeparator +
              ReplaceStr(',', '.', FormatFloat('#0.##',PlungeT))+ tfpListSeparator +
              ReplaceStr(',', '.', FormatFloat('#0.##',Pitch)) + tfpListSeparator + IntToStr(Bew);
              VirtSrcList.Items.Add(LineString);
              inc(z);
            end;  {if not failed}
          end;   {end case ptf}
        end;  {end case}
        if z>999 then z:=1;   //  ****   ?????????? ****
    end; //end while
  end //end if not eof
  else LHfailed := true;
  CloseFile(F);
  Screen.Cursor := crDefault;
except   //can not open file
  On EInOutError do
  begin
    GlobalFailed:=True;
    Screen.Cursor:=crDefault;
    MessageDlg('Can not open '+LHFilename+' !'#10#13+
               'Processing stopped. File might be in use by another application.',
               mtError,[mbOk], 0);
    Close;
    Exit;
  end;
end;
if LHfailed then
begin
  GlobalFailed:=True;
  MessageDlg('Error reading '+ExtractFilename(LHFilename)+', dataset '
             +IntToStr(Z)+'!'+#10#13+' Processing stopped.',
             mtError,[mbOk], 0);
  Close;
  exit;
end else
  GlobalFailed:=false;
  //SetItem(SrcList, 0);
end;  {sub}

procedure TSortManual.FillVisblList(var VirtList, VisblList : TListbox);
var Linestring, Comment : string;
    i, RoundDummy : Integer;
begin
  Screen.Cursor := crHourGlass;
  VisblList.Clear;
  for I := VirtList.Items.Count - 1 downto 0 do
  begin
    case ext of
      COR, FPL, PEF, PEK, PTF, HOE :
      begin
        If Angelier1.Checked or Hoeppener1.checked then
        begin
          If (ext=PTF) then ReadPTFStr(VirtList.Items[i],LHz,Sense,Quality,DipDir, Dip,Azimuth,Plunge,
                    AzimB,PlungeB,AzimP,PlungeP,AzimT,PlungeT,Pitch,Bew)
          else ReadFPLStr(VirtList.Items[i], Sense, Quality, DipDir, Dip, Azimuth, Plunge, Comment, LHz);
          LineString := '';
          if LHz < 100 then LineString := '0';
          if LHz < 10 then LineString := '00';
          LineString := LineString + IntToStr(LHz) + '.  ';
          RoundDummy:= Round(DipDir);
          If RoundDummy < 100 then
          begin
            LineString := Linestring+'0';
            If RoundDummy < 10 then LineString := Linestring+'0';
          end;
          LineString := LineString + InttoStr(RoundDummy)+ ' / ';
          RoundDummy:= Round(Dip);
          If RoundDummy < 10 then LineString := LineString +'0';
          LineString := LineString + InttoStr(RoundDummy)+ '    ';
          RoundDummy:= Round(Azimuth);
          If RoundDummy < 100 then
          begin
            LineString := Linestring+'0';
            If RoundDummy < 10 then LineString := Linestring+'0';
          end;
          LineString := LineString + InttoStr(RoundDummy)+ ' / ';
          RoundDummy:= Round(Plunge);
          If RoundDummy < 10 then LineString := Linestring+'0';
          LineString := LineString + InttoStr(RoundDummy)+'  ';
          case Sense of
            0: LineString := LineString + '***   ';
            1: LineString := LineString + 'up   ';
            2: LineString := LineString + 'dn   ';
            3: LineString := LineString + 'dx   ';
            4: LineString := LineString + 'sn   ';
            5: LineString := LineString + '***   ';
          end;
          Linestring:=Linestring+InttoStr(Quality);
          VisblList.Items.Add(LineString);
        end
        else
        begin
          ReadPTFStr(VirtList.Items[i],LHz,Sense,Quality,DipDir, Dip,Azimuth,Plunge,
                    AzimB,PlungeB,AzimP,PlungeP,AzimT,PlungeT,Pitch,Bew);
          LineString := '';
          if LHz < 100 then LineString := '0';
          if LHz < 10 then LineString := '00';
          LineString := LineString + InttoStr(LHz) + '. ';
          RoundDummy:= Round(AzimB);
          If RoundDummy < 100 then
          begin
            LineString := Linestring+'0';
            If RoundDummy < 10 then LineString := Linestring+'0';
          end;
          LineString := LineString + InttoStr(RoundDummy)+ '/';
          RoundDummy:= Round(PlungeB);
          If RoundDummy < 10 then LineString := Linestring+'0';
          LineString := LineString + InttoStr(RoundDummy);
          LineString := LineString + '  ';
          RoundDummy:= Round(AzimP);
          If RoundDummy < 100 then
          begin
            LineString := Linestring+'0';
            If RoundDummy < 10 then LineString := Linestring+'0';
          end;
          LineString := LineString + InttoStr(RoundDummy)+ '/';
          RoundDummy:= Round(PlungeP);
          If RoundDummy < 10 then LineString := Linestring+'0';
          LineString := LineString + InttoStr(RoundDummy);
          LineString := LineString + '  ';
          RoundDummy:= Round(AzimT);
          If RoundDummy < 100 then
          begin
            LineString := Linestring+'0';
            If RoundDummy < 10 then LineString := Linestring+'0';
          end;
          LineString := LineString + InttoStr(RoundDummy)+ '/';
          RoundDummy:= Round(PlungeT);
          If PlungeT < 10 then LineString := Linestring+'0';
          LineString := LineString + InttoStr(RoundDummy);
          VisblList.Items.Add(LineString);
        end;   //end case ptf
      end; //case cor,fpl,ptf
      PLN,LIN :
      begin
        ReadPlnStr(VirtList.Items[i],DipDir, Dip, Comment, LHz);
        LineString := '';
        if LHz < 100 then LineString := '0';
        if LHz < 10 then LineString := '00';
        LineString := LineString + InttoStr(LHz) + '.    ';
        RoundDummy:= Round(DipDir);
        If RoundDummy < 100 then
        begin
          LineString := Linestring+'0';
          If RoundDummy < 10 then LineString := Linestring+'0';
        end;
        LineString := LineString + InttoStr(RoundDummy)+ ' / ';
        RoundDummy:= Round(Dip);
        If RoundDummy < 10 then LineString := Linestring+'0';
        LineString := LineString + InttoStr(RoundDummy);
        VisblList.Items.Add(LineString);
      end;   //case pln, lin
    end;  //end case
  end; //end for
  Screen.Cursor := crDefault;
  SelectSelected(VirtList, VisblList);
end;  //sub

procedure TSortManual.Compute(var List: TlistBox; var PaintB: TPaintBox);
var k, z: Integer;
    MySense, dummy, dumy, Intdummy, CenterPX, CenterPY, CircleRad : Integer;
    Fdummy: Single;
    Comment: String;
    Mypencolordummy: Tcolor;
begin
  Screen.Cursor := crHourGlass;
  CenterPX := PaintB.Width div 2;
  CenterPY := PaintB.Height div 2;
  CircleRad := (2*PaintB.Height) div 5;
  ArrowHeadLength:=Round(CircleRad*LinearCircleRate);{=Radius*LinearCircleRate}
  ArrowLength1:=CircleRad*LengthRate1;        {=Radius*LengthRate1}
  ArrowLength2:=CircleRad*LengthRate2;
  NorthAndCircle(PaintB.Canvas, CenterPX, CenterPY, CircleRad);
  SetBkMode(PaintB.Canvas.Handle, TRANSPARENT);
  Z:=0;
  case ext of
    COR, FPL, PTF, PEF, PEK, HOE:
    begin
      if angelier1.checked or Hoeppener1.checked then
      begin
        Label3.Caption := '  No.  Fault plane     Lineation  Sen  Qual';
        Label4.Caption := Label3.Caption;
      end
      else
      begin
        Label3.Caption := 'No.     B-axes    P-axes    T-axes';
        Label4.Caption := Label3.Caption;
      end;
      if Angelier1.checked then //Angelier
      begin
        for k := 0 to List.Items.Count - 1 do
        begin
          ReadFPLStr(List.Items[k], Sense, Quality, DipDir, Dip, Azimuth, Plunge, Comment, z);
          if list.selected[k] then
          begin
            MyPenColordummy:=LHPen.Color;
            LHPen.Color:= clRed;
          end;
          GreatCircle(PaintB.Canvas.Handle,PaintB.Canvas,CenterPX,CenterPY,CircleRad,DipDir, Dip, Z-1, Number1.Checked, LHPen.Handle, LHLogPen);
          Striae(PaintB.Canvas.Handle,PaintB.Canvas,CenterPX,CenterPY,CircleRad,DipDir, Dip,Azimuth,Plunge, LHSymbSize,
                      Sense,Quality,Z-1, Number1.Checked, QualityGlobal, LHSymbFillFlag,
                      ext, LHPen, LHPenBrush, LHFillBrush);
          if list.selected[k] then LHPen.Color:= MyPenColordummy;
        end;
      end
      else
        if Hoeppener1.checked then
        begin {Hoeppener}
          for k := 0 to List.Items.Count - 1 do
          begin
            ReadFPLStr(List.Items[k], Sense, Quality, DipDir, Dip, Azimuth, Plunge, Comment, z);
            if list.selected[k] then
            begin
              MyPenColordummy:=LHPen.Color;
              LHPen.Color:= clRed;
            end;
            HoepSymbol2(PaintB.Canvas.Handle,PaintB.Canvas,CenterPX,CenterPY,CircleRad,Sense,Quality,
                        DipDir,Dip,Azimuth,Plunge,LHSymbSize,z-1, Number1.Checked, QualityGlobal, LHSymbFillFlag, LHPen, LHPenBrush, LHFillBrush);
            if list.selected[k] then LHPen.Color:= MyPenColordummy;
          end
        end
        else
        begin
          dummy:= PaintB.Canvas.Font.Height div 2-2;
          dumy:=Round(CircleRad*LinearCircleRate);
          LHFillBrush.Color:=clRed;
      for k := 0 to List.Items.Count - 1 do
      begin
        ReadPTFStr(List.Items[k],z,MySense,intdummy,Fdummy,Fdummy,Fdummy,Fdummy,AzimB,PlungeB,
                  AzimP, PlungeP, AzimT, PlungeT,Fdummy, intdummy);
        if list.selected[k] then
        begin
          MyPenColordummy:=LHPen.Color;
          LHPen.Color:= clYellow;
        end;
        {***************Draw orientation of B-axis*******************}
        Lineation(PaintB.Canvas.Handle,PaintB.Canvas,CenterPX,CenterPY,CircleRad,AzimB,PlungeB,LHSymbSize,Z-1,Number1.Checked, false,syRectangle, LHFillBrush, LHPen.Handle);
        If MySense<>0 then
        begin
          {****************Draw  orientation of P-axis******************}
          Lineation(PaintB.Canvas.Handle,PaintB.Canvas,CenterPX,CenterPY,CircleRad,AzimP,PlungeP,LHSymbSize,Z-1,Number1.Checked, LHSymbFillFlag,syCircle, LHFillBrush, LHPen.Handle);
          {****************Draw orientation of T-axis**********************}
          Lineation(PaintB.Canvas.Handle,PaintB.Canvas,CenterPX,CenterPY,CircleRad,AzimT,PlungeT,LHSymbSize,Z-1,Number1.Checked, LHSymbFillFlag,syTriangle, LHFillBrush2, LHPen.Handle);
        end
        else
        begin
          {****************Draw  orientation of P-axis******************}
          Lineation(PaintB.Canvas.Handle,PaintB.Canvas,CenterPX,CenterPY,CircleRad,AzimP,PlungeP,LHSymbSize,Z-1,Number1.Checked,false,syStar, LHFillBrush, LHPen.Handle);
          {****************Draw orientation of T-axis**********************}
          Lineation(PaintB.Canvas.Handle,PaintB.Canvas,CenterPX,CenterPY,CircleRad,AzimT,PlungeT,LHSymbSize,Z-1,Number1.Checked,false,syStar, LHFillBrush, LHPen.Handle);
        end;
        if list.selected[k] then LHPen.Color:= MyPenColorDummy;
      end;
      end; {end for}
    end;  {end case cor,fpl,ptf}
    PLN : begin
      Label3.Caption := ' No.    DipDir / Dip';
      Label4.Caption := Label3.Caption;
      if Angelier1.Checked then
      begin //draw great circle
        for k := 0 to List.Items.Count - 1 do
        begin
          ReadPlnStr(List.Items[k], DipDir, Dip, Comment, z);
          if list.selected[k] then
          begin
            MyPenColordummy:=LHPen.Color;
            LHPen.Color:= clRed;
          end;
          GreatCircle(PaintB.Canvas.Handle,PaintB.Canvas,CenterPX,CenterPY,CircleRad,DipDir, Dip, Z-1, Number1.Checked, LHPen.Handle, LHLogPen);
          if list.selected[k] then LHPen.Color:= MyPenColordummy;
        end;
      end else
      begin //Draw Pi-Plot
        for k := 0 to List.Items.Count - 1 do
        begin
          ReadplnStr(List.Items[k], DipDir, Dip, Comment, z);
          if list.selected[k] then
          begin
            MyPenColordummy:=LHPen.Color;
            LHPen.Color:= clRed;
          end;
          If SortPLNPlotType=1 then //poles to planes
          begin
            DipDir:=Round((Dipdir+180)) mod 360;
            Dip:=90-Dip;
          end;
          Lineation(PaintB.Canvas.Handle,PaintB.Canvas,CenterPX,CenterPY,CircleRad,DipDir,Dip,LHSymbSize,Z-1,Number1.Checked,LHSymbFillFlag,LHSymbType, LHFillBrush, LHPen.Handle);
          if List.Selected[k] then LHPen.Color:= MyPenColordummy;
        end;
      end; {Pi-plot}
    end;  {case pln}
    LIN : begin
      Label3.Caption := 'No.   Azimuth / Plunge';
      Label4.Caption := Label3.Caption;
      for k := 0 to List.Items.Count - 1 do
      begin
        ReadplnStr(List.Items[k], DipDir, Dip, Comment, z);
        if list.selected[k] then
          begin
            MyPenColordummy:=LHPen.Color;
            LHPen.Color:= clRed;
          end;
        Lineation(PaintB.Canvas.Handle,PaintB.Canvas,CenterPX,CenterPY,CircleRad,DipDir,Dip,LHSymbSize,Z-1,Number1.Checked,LHSymbFillFlag,LHSymbType, LHFillBrush, LHPen.Handle);
        if list.selected[k] then LHPen.Color:= MyPenColordummy;
      end;
    end;
  end;
  Screen.Cursor := CrDefault;
end;

procedure TSortManual.PaintBox2Paint(Sender: TObject);
begin
  Compute(VirtDstList, PaintBox2);
end;

procedure TSortManual.PaintBox1Paint(Sender: TObject);
begin
  Compute(VirtSrcList, PaintBox1);
end;

procedure TSortManual.WriteToFBtnClick(Sender: TObject);
var G : Textfile;
    i,z : Integer;
    Saveflag, Exitflag: boolean;
    AFilename, Comment : String;

begin
  if DstList.Items.Count > 0 then
  begin
    If (SortLastOutputPath<>'') then SaveDialog1.InitialDir:=SortLastOutputPath; //Bugfix Win2k 20000427F.R.
    If Sender=AppendBtn then
      SaveDialog1.Title:='Append selection to file'  //fix 20000425
    else
    begin
      AFilename:=ChangeFileExt(ExtractFilename(LHFilename),'');
      case Ext of
        PEF: SaveDialog1.Filename := Afilename+'-'+Label2.Caption+'.fpl';
        PEK, HOE: SaveDialog1.Filename := Afilename+'-'+Label2.Caption+'.cor';
      else
       SaveDialog1.Filename := Afilename+'-'+Label2.Caption+ExtractFileExt(LHFilename);
      end;
    end;
    case Ext of
      FPL, PEF: SaveDialog1.FilterIndex:=1;
      COR, PEK, HOE: SaveDialog1.FilterIndex:=2;
      PLN: SaveDialog1.FilterIndex:=3;
      LIN: SaveDialog1.FilterIndex:=4;
      PTF: SaveDialog1.FilterIndex:=5;
      ERR :
      begin
        MessageDlg('No valid filetype! Processing stopped ', mtWarning,[mbOk], 0);
        exit;
      end;
    end;
    Repeat
      ExitFlag:=true;
      SaveFlag:=SaveDialog1.Execute;
      If SaveFlag and (Sender=WriteToFBtn) then
      begin
        If FileExists(SaveDialog1.Filename) then
        begin
          Messagebeep(MB_ICONQUESTION); //added 20000427
          Case MessageDlg(SaveDialog1.Filename+#10#13+
             'already exists! Overwrite?', mtWarning,[mbYes,mbRetry,mbCancel], 0) of
            mrCancel:
            begin
              Saveflag:=false;
              exit;
            end;
            mrYes: ExitFlag:=True;
            mrRetry: ExitFlag:=False;
          end;
        end;
      end
      else
        if SaveFlag and (Sender=AppendBtn) then
        begin
          If not FileExists(SaveDialog1.Filename) then
            Case MessageDlg(SaveDialog1.Filename+#10#13+
               'does not exist! Create?', mtWarning,[mbYes,mbRetry,mbCancel], 0) of
              mrCancel:
              begin
                Saveflag:=false;
                exit;
              end;
              mrYes:
              begin
                ExitFlag:=True;
                Sender:=WriteToFBtn;
              end;
              mrRetry: ExitFlag:=False;
            end;
        end;
    until exitflag;
    If Saveflag then
    begin
      If Sender= WriteToFBtn then
      begin
        If ExtractFileExt(SaveDialog1.Filename)='' then //Bugfix 20000422 to avoid missing extension
          SaveDialog1.Filename:=SaveDialog1.Filename+ExtractFileExt(LHFilename);
        If LocInfoToFile(SaveDialog1.Filename, LHLocationInfo) then
        begin
          AssignFile(G, SaveDialog1.Filename);
          Append(G);
        end
        else
        begin
          AssignFile(G, SaveDialog1.Filename);
          Rewrite(G);
        end;
      end
      else
      begin
        AssignFile(G, SaveDialog1.Filename);
        Append(G);
        Writeln(G);
      end;
      case ext of
        FPL, COR, PEF, PEK, HOE:
        begin
          For i:= 0 to VirtDstList.Items.Count-1 do
          begin
            ReadFPLStr(VirtDstList.Items[i], Sense, Quality, DipDir, Dip, Azimuth, Plunge, Comment, z);
            Write(g,CombineSenseQuality(Sense,Quality),FileListSeparator, FloatToString(DipDir,3,2),FileListSeparator,
                  FloatToString(Dip,2,2),FileListSeparator,FloatToString(Azimuth,3,2),
                  FileListSeparator,FloatToString(Plunge,2,2));
            If Comment<>'' then write(g, filelistseparator,Comment);
            If i<VirtDstList.Items.Count-1 then writeln(g);
          end;
        end;
        PLN, LIN:
        begin
          For i:= 0 to VirtDstList.Items.Count-1 do
          begin
            ReadPlnStr(VirtDstList.Items[i],DipDir, Dip, Comment, z);
            Write(g,FloatToString(DipDir,3,2),FileListSeparator,FloatToString(Dip,2,2));
            If Comment<>'' then Write(g, FileListSeparator, Comment);
            if i<VirtDstList.Items.Count-1 then Writeln(g);
          end;
        end;
        PTF:
        begin
          For i:= 0 to VirtDstList.Items.Count-1 do
          begin
            ReadPTFStr(VirtDstList.Items[i],z,Sense,quality,DipDir, Dip,Azimuth,Plunge,
                      AzimB,PlungeB,AzimP,PlungeP,AzimT,PlungeT,Pitch,Bew);
            write(G,CombineSenseQuality(Sense,Quality),FileListSeparator,FloatToString(DipDir,3,2),FileListSeparator,
            FloatToString(Dip,2,2),FileListSeparator,FloatToString(Azimuth,3,2),FileListSeparator,
            FloatToString(Plunge,2,2),FileListSeparator,
            FloatToString(AzimB,3,2),FileListSeparator,FloatToString(PlungeB,2,2),FileListSeparator,
            FloatToString(AzimP,3,2),FileListSeparator,FloatToString(PlungeP,2,2),FileListSeparator,
            FloatToString(AzimT,3,2),FileListSeparator,FloatToString(PlungeT,2,2),FileListSeparator,
            FloatToString(Pitch,2,2),FileListSeparator,Bew);
            if i<VirtDstList.Items.Count-1 then writeln(g);
          end;
        end;
      end; //case
      CloseFile(G);
      DstList.Items.Clear;
      VirtDstList.Items.Clear;
      PaintBox2.Refresh;
      If sender=writetofbtn then
        TecMainWin.WriteToStatusbar(nil ,'Written to file '+SaveDialog1.Filename)
      else
        TecMainWin.WriteToStatusbar(nil ,'Appended to file '+SaveDialog1.Filename);
      if (VirtSrcList.Items.Count = 0) and (VirtDstList.Items.Count = 0) then Close
      else If Sender=WriteToFBtn then Label2.Caption:=IntToStr(1+StrToInt(Label2.Caption));  //Bugfix 20000420
      SortLastOutputPath:=ExtractFilePath(SaveDialog1.Filename);  //added 20000502
      SetCurrentDir(ExtractFilePath(LHFilename));
    end;
  end
  else
    MessageDlg('Destination is empty!'+#13#10+'Choose at least one dataset.', mtWarning,[mbOk], 0);
end;

procedure TSortManual.FormResize(Sender: TObject);
const botalign = 10;
begin
  Paintbox1.Left := 0;
  Paintbox1.Top := 0;
  Paintbox1.Height:= 2 * ClientHeight div 3;
  Paintbox1.Width:= ClientWidth div 2;
  Paintbox2.Left := ClientWidth div 2;
  Paintbox2.Top := 0;
  Paintbox2.Height := 2 * ClientHeight div 3;
  Paintbox2.Width := ClientWidth div 2;
  IncludeBtn.Left := ClientWidth div 2-2*AppendBtn.Width div 3;
  IncludeBtn.Top := ClientHeight-botalign-102-ExAllBtn.Height;
  IncAllBtn.Left := IncludeBtn.Left;
  IncAllBtn.Top := ClientHeight-botalign-68-ExAllBtn.Height;
  ExcludeBtn.Left := IncludeBtn.Left;
  ExcludeBtn.Top := ClientHeight-botalign-34-ExAllBtn.Height;
  ExAllBtn.Left := IncludeBtn.Left;
  ExAllBtn.Top := ClientHeight-botalign-ExAllBtn.Height;
  SrcList.Left:= IncludeBtn.Left-10-SrcList.Width;
  SrcList.Top:= ClientHeight-botalign-SrcList.Height;
  DstList.Left:= IncludeBtn.Left+IncludeBtn.Width+10;
  DstList.Top:= ClientHeight-botalign-DstList.Height;
  SrcLabel.Left := SrcList.Left;
  SrcLabel.Top := SrcList.Top - 2* Canvas.TextHeight('Test');
  DstLabel.Left := DstList.Left;
  DstLabel.Top := SrcLabel.Top;
  Label2.Left := DstList.Left+Canvas.TextWidth(dstlabel.caption+'A');
  Label2.Top := DstLabel.Top;
  Label3.Left := SrcList.Left;
  Label3.Top := SrcList.Top - Canvas.TextHeight('Test');
  Label4.Left := DstList.Left;
  Label4.Top := Label3.Top;
  WriteToFBtn.Left:=ClientWidth-botalign-WriteToFBtn.Width;
  WriteToFBtn.Top:=ClientHeight-botalign-60-CancelBtn.Height;
  AppendBtn.Left:=ClientWidth-botalign-AppendBtn.Width;
  AppendBtn.Top:=ClientHeight-botalign-30-CancelBtn.Height;
  CancelBtn.Left:=ClientWidth-botalign-CancelBtn.Width;
  CancelBtn.Top:=ClientHeight-botalign-CancelBtn.Height;
  bevel2.Left := 0;
  bevel2.Top := 0;
  bevel2.Height:= 2 * ClientHeight div 3;
  bevel2.Width:= ClientWidth div 2;
  bevel3.Left := ClientWidth div 2;
  bevel3.Top := 0;
  bevel3.Height := 2 * ClientHeight div 3;
  bevel3.Width := ClientWidth div 2;
  Bevel1.Top := ClientHeight-ClientHeight div 3;
  Bevel1.Left := 0;
  Bevel1.Height := ClientHeight div 3;
  Bevel1.Width := ClientWidth;
end;

procedure TSortmanual.Angelier1Click(Sender: TObject);
begin
  If Sender=Angelier1 then
  begin
    LHPoleflag:=false;
    If ext=pln then SortPLNPlotType:=0
    else If ext=ptf then SortPTFPlotType:=0
    else SortFPLPlotType:=0;
    if ptaxes1.checked then
    begin
      (Sender as TMenuItem).Checked:= true;
      LHFillbrush.Color:=clWhite;
      FillVisblList(VirtSrcList,SrcList);
      FillVisblList(VirtDstList,DstList);
    end;
  end
  else
    if Sender = Hoeppener1 then
    begin
      If ext=pln then SortPLNPlotType:=1
      else If ext=ptf then SortPTFPlotType:=1
      else SortFPLPlotType:=1;
      LHPoleflag:=true;
      if ptaxes1.checked then
      begin
        (Sender as TMenuItem).Checked:= true;
        LHFillbrush.Color:=clWhite;
        FillVisblList(VirtSrcList,SrcList);
        FillVisblList(VirtDstList,DstList);
      end;
    end
    else
    begin
      if ext=ptf then
      begin
        (Sender as TMenuItem).Checked:= true;
        SortPTFPlotType:=2;
        LHPoleflag:=false;
        LHFillbrush.Color:=clRed;
        LHFillbrush2.Color:=clBlue;
      end
      else //dip lines
      begin
        SortPLNPlotType:=2;
        LHPoleFlag:=False;
      end;
      FillVisblList(VirtSrcList,SrcList);
      FillVisblList(VirtDstList,DstList);
    end;
    (Sender as TMenuItem).Checked:= true;
    SetLHProperties(LHPlotType);
    PaintBox1.Refresh;
    PaintBox2.Refresh;
end;

procedure TSortmanual.PaintBox1MouseMove(Sender: TObject; Shift: TShiftState; X,Y: Integer);
begin
  CalculateMousePos(Sender as TPaintBox,X,Y, LHMouseAzimuth, LHMouseDip, LHPoleflag);
end;


procedure TSortManual.PaintBox1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var index,i: integer;
  MyList, MyVirtList: TListbox;
  notmultiselect: boolean;
begin
  inherited;
  begin
    If Button=mbLeft then
    begin
      If sender=paintbox1 then
      begin
        mylist:=srclist;
        MyVirtList:=Virtsrclist;
      end
      else
      begin
        mylist:=dstlist;
        MyVirtList:=Virtdstlist;
      end;
      FindIteminList(MyVirtList, LHMouseAzimuth, LHMouseDip, Index);
      if index=-1 then TecMainWin.StatusBar1.Panels.Items[3].Text := 'No target!'
      else
      begin
        If GetAsyncKeyState(VK_CONTROL)=-32767 then notmultiselect:=false else notmultiselect:=true;
        for i:=0 to mylist.items.count-1 do
        begin
          If notmultiselect then
          begin
            if mylist.selected[i] then mylist.selected[i]:=false;
            if MyVirtList.selected[i] then MyVirtList.selected[i]:=false;
          end;  
        end;
        setitem(mylist,index);
        setitem(MyVirtList,index);
        if sender= Paintbox1 then
          compute(MyVirtList, Paintbox1)
        else
          compute(MyVirtList, Paintbox2);
      end;
    end;
  end;
end;


procedure TSortmanual.FindIteminList(MyVirtList : TListbox; const MyAzim, Mydip: Single; var number: integer);
const SnapToPointRange = 2;
var i: integer;
    comment: String;
begin
  number:=-1;
  case ext of
    FPL, COR, PEF, PEK, HOE:
    begin
      For i:= 0 to MyVirtList.Items.Count-1 do
      begin
        ReadFPLStr(MyVirtList.Items[i], Sense, Quality, DipDir, Dip, Azimuth, Plunge, Comment, LHz);
        if LHPoleflag then
        begin
           if (DipDir<Myazim+SnapToPointRange) and (DipDir>Myazim-SnapToPointRange) and
              (Dip<Mydip+SnapToPointRange)and (Dip>Mydip-SnapToPointRange) then number:=i;
        end
        else
         if (Azimuth<Myazim+SnapToPointRange) and (Azimuth>Myazim-SnapToPointRange) and
            (Plunge<Mydip+SnapToPointRange) and (Plunge>Mydip-SnapToPointRange) then number:=i;
      end;
    end;
    PLN, LIN:
    begin
      For i:= 0 to MyVirtList.Items.Count-1 do
      begin
        ReadPlnStr(MyVirtList.Items[i],DipDir, Dip, Comment, LHz);
        if (dipdir<Myazim+SnapToPointRange) and (dipdir>Myazim-SnapToPointRange) and
           (dip<Mydip+SnapToPointRange) and (dip>Mydip-SnapToPointRange) then number:=i;
      end;
    end;
    PTF:
    begin
      For i:= 0 to MyVirtList.Items.Count-1 do
      begin
        ReadPTFStr(MyVirtList.Items[i],LHz,Sense,quality,DipDir, Dip,Azimuth,Plunge,
                      AzimB,PlungeB,AzimP,PlungeP,AzimT,PlungeT,Pitch,Bew);
        if Angelier1.checked or Hoeppener1.checked then
        begin
          If LHPoleflag then
          begin
            if (DipDir<Myazim+SnapToPointRange) and (DipDir>Myazim-SnapToPointRange) and
               (Dip<Mydip+SnapToPointRange)and (Dip>Mydip-SnapToPointRange) then number:=i;
          end
          else
            if (Azimuth<Myazim+SnapToPointRange) and (Azimuth>Myazim-SnapToPointRange) and
               (Plunge<Mydip+SnapToPointRange) and (Plunge>Mydip-SnapToPointRange) then number:=i;
        end
        else
        begin
          if (AzimB<Myazim+SnapToPointRange) and (AzimB>Myazim-SnapToPointRange) and
             (PlungeB<Mydip+SnapToPointRange) and (PlungeB>Mydip-SnapToPointRange) then number:=i;
          if (AzimP<Myazim+SnapToPointRange) and (AzimP>Myazim-SnapToPointRange) and
             (PlungeP<Mydip+SnapToPointRange) and (PlungeP>Mydip-SnapToPointRange) then number:=i;
          if (AzimT<Myazim+SnapToPointRange) and (AzimT>Myazim-SnapToPointRange) and
             (PlungeT<Mydip+SnapToPointRange) and (PlungeT>Mydip-SnapToPointRange) then number:=i;
        end;
      end;
    end;
  end; //case
end;

procedure TSortManual.ListClick(Sender: TObject);
var
  I: Integer;
  Myvirtlist: TListbox;
begin
  If Sender=SrcList then MyVirtList:=VirtSrcList
  else MyVirtList:=VirtDstList;
  for i:=0 to MyVirtList.Items.Count-1 do
    MyVirtList.Selected[i]:=false;
  SelectSelected((Sender as TListbox), MyVirtList);
  If Sender=SrcList then compute(MyVirtList, Paintbox1)
  else compute(MyVirtList, Paintbox2);
end;

procedure TSortManual.SelectSelected(List,VirtList: TListbox);
var
  I: Integer;
begin
  for I := List.Items.Count - 1 downto 0 do
    if List.Selected[I] then VirtList.Selected[i]:=true;
end;





procedure TSortManual.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
  if key=vk_right then
  begin
    BtnClick(includebtn);
    key:=0;
  end
  else if key=vk_left then
  begin
    BtnClick(excludebtn);
    key:=0;
  end;
end;

end.
