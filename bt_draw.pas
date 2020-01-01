unit Bt_draw;

interface

uses
  SysUtils, Windows, Graphics,Forms, Dialogs, StdCtrls, Angle,
  Menus, Clipbrd, Types, LowHem, Numedit, Classes, Controls, ExtCtrls, rose;

type
  Tbtdraw = class(TFluMohrFm)
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Bevel1: TBevel;
    Bevel3: TBevel;
    Label11: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    NumEdit1: TNumEdit;
    WriteBtn: TButton;
    Button2: TButton;
    SaveDialog1: TSaveDialog;
    Label20: TLabel;
    Label2: TLabel;
    Bevel2: TBevel;
    Button1: TButton;
    procedure Open(const AFilename:String; PRofPAx,PRofTAx: PZeroIntArray;
                   const increm,btp,btt,btboth,nn, anosense: Integer; var x: Integer);
    procedure Compute(Sender: TObject); override;
    procedure WriteBtnClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject); override;
    procedure FormCreate2(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure Button1Click(Sender: TObject);
  protected
    PRofPAxis,PRofTAxis: PZeroIntArray;
    increment: Integer;
    bthetap, bthetat, bthetaboth, nosense,x: integer;
  end;
  const margin1 = 30;
      margin2 = 20;
      boxleft = 0;
      boxtop =  0;
      boxright = 400+margin1+margin2;
      boxbottom = 400+margin1+margin2;
      zerox = margin1;
      zeroy = boxbottom-margin1;
      maxx = boxright-margin2;
      maxy = boxbottom-margin2;


 { var
  btdraw: Tbtdraw; }

implementation
{$R *.DFM}

uses draw, tecmain, Inspect;

procedure TBtdraw.Open(const AFilename:String; PRofPAx,PRofTAx: PZeroIntArray;
       const increm,btp,btt,btboth,nn, anosense: Integer; var x: Integer);
var i : integer;
begin
    Inc(GlobalLHPlots);
    LHPlotNumber:=GlobalLHPlots;
    Caption :=  'Plot '+IntToStr(LHPlotNumber)+': '+Caption +' - [' +
                 ExtractFileName(ThetaFileName) +']';
    LHPlotType:=pt_BestTheta;
    for i:=0 to (85 div BT_increment) do
    begin
      PRofPAxis^[i]:=PRofPAx^[i];
      PRofTAxis^[i]:=PRofTAx^[i];
    end;
    brushcreate(nil);
    SetLHProperties(LHPlotType);
    LHFilename:=AFilename;
    LHLabel1:=ExtractFilename(LHFilename);
    increment:=increm;
    Bthetap:=btp;
    Bthetat:=btt;
    Bthetaboth:=btboth;
    LHz:=nn;
    nosense:=anosense;
    If LHWriteWMF then
    begin
      LHMetafile := TMetafile.Create;
      LHMetafile.Height := boxbottom;
      LHMetafile.Width  := boxright;
      LHMetafile.MMWidth  := MetafileMMWidth;
      LHMetafile.MMHeight := MetafileMMHeight;
      LHMetafile.Inch := MetafileInch;
    end
    else
    begin
      LHEnhMetafile := TEnhMetafile.Create;
      LHEnhMetafile.Height := boxbottom;
      LHEnhMetafile.Width  := boxright;
      //MyEnhMetafile.MMWidth  := MetafileMMWidth;
      //MyEnhMetafile.MMHeight := MetafileMMHeight;
    end;
    compute(nil);
  end;

procedure Tbtdraw.Compute;


var Angle1, CenterX, CenterY,StartAngle,Index1: Integer;
    points4: Array[0..3] of TPoint;

begin
  If LHWriteWMF then
    LHMetCan:= TMetafileCanvas.CreateWithComment(LHMetafile, 0, 'BestTheta', 'TectonicsFP')
  else
    LHMetCan:= TEnhMetafileCanvas.CreateWithComment(LHEnhMetafile, 0, 'LH_Plot', 'TectonicsFP');
  SetMapMode(LHMetCan.Handle, MM_Anisotropic);
  SetWindowOrgEx(LHMetCan.Handle, 0, 0, nil);
  If LHWriteWMF then SetWindowExtEx(LHMetCan.Handle,boxright,boxbottom, nil)
  else SetWindowExtEx(LHMetCan.Handle,1, 1, nil);
  SetBkColor(LHMetCan.Handle,clWhite);
  SetBkMode(LHMetCan.Handle, TRANSPARENT);
  SelectObject(LHMetCan.Handle,GetStockObject(HOLLOW_BRUSH));
  If LHBackgrOn then
  begin
    SelectObject(LHMetCan.Handle, LHBackgrBrush.Handle);
    SelectObject(LHMetCan.Handle, GetStockObject(null_pen));
    Windows.Rectangle(LHMetCan.Handle, 0, 0, boxright, boxbottom);
    SelectObject(LHMetCan.Handle, GetStockObject(hollow_brush));
    SelectObject(LHMetCan.Handle, LHPen.Handle);
  end;
  LHMetCan.Font := TecMainWin.FontDialog1.Font;
  with LHMetCan.pen do
  begin
    color:=LHNetColor;
    width:=AxesPenWidth;
  end;
  {**************Draw X-axis************************}
  LHMetCan.MoveTo(margin2, zeroy);
  LHMetCan.LineTo(maxx, zeroy);
  {**************Draw Y-axis************************}
  LHMetCan.MoveTo(zerox, margin2);
  LHMetCan.LineTo(zerox, maxy);
  {**************Draw ticks on x-axis****************}
  Angle1:=20;
  Repeat
    LHMetCan.MoveTo(zerox + 18 * (Angle1-10) div 4, zeroy-3);
    LHMetCan.LineTo(zerox + 18 * (Angle1-10) div 4, zeroy+3);
    Inc(Angle1,10);
  until Angle1>=85;
  {**************Draw ticks on y-axis****************}
  Angle1:=10;
  Repeat
    LHMetCan.MoveTo(zerox-3, zeroy - 4 * Angle1);
    LHMetCan.LineTo(zerox+3, zeroy - 4 * Angle1);
    Inc(Angle1,10);
  until Angle1>90;
  {************Draw R% of P-axes********************}
  StartAngle:=(10 div increment)*increment;
  Angle1:=StartAngle;
  LHMetCan.Pen:=LHPen;
  If LHSymbFillflag then LHMetCan.Brush:=LHFillBrush;
  repeat
    Index1:=Angle1 div Increment;
    CenterX:=zerox + 18 * (Angle1-10) div 4;
    CenterY:=zeroy - 4 * PRofPAxis^[Index1];
    {************Draw R% of P-axes*****************}
    LHMetCan.Ellipse(CenterX-Round(LHSymbSize),CenterY-Round(LHSymbSize),CenterX+Round(LHSymbSize), CenterY+Round(LHSymbSize));
    Inc(Angle1, Increment);
  until Angle1>=85;
  If Label1.checked then
  begin
    CenterX:=boxleft+370 - 6*Round(LHSymbSize);
    CenterY:=boxtop+10 - LHMetCan.Font.Height div 2;
    LHMetCan.Ellipse(CenterX-Round(LHSymbSize),CenterY-Round(LHSymbSize),CenterX+Round(LHSymbSize), CenterY+Round(LHSymbSize));
  end;
  Angle1:=StartAngle;
  LHMetCan.Pen:=FMPen2;
  If LHSymbFillflag2 then LHMetCan.Brush:=LHFillBrush2
  else SelectObject(LHMetCan.Handle, GetStockObject(HOLLOW_BRUSH));
  repeat
    Index1:=Angle1 div Increment;
    CenterX:=zerox + 18 * (Angle1-10) div 4;
    CenterY:= zeroy - 4 * PRofTAxis^[Index1];
    {************Draw R% of T-axes*****************}
    Points4[0].x:=Round(CenterX-LHSymbSize);
    Points4[0].y:=Round(CenterY+LHSymbSize);
    Points4[1].x:=Round(CenterX);
    Points4[1].y:=Round(CenterY-LHSymbSize);
    Points4[2].x:=Round(CenterX+LHSymbSize);
    Points4[2].y:=Round(CenterY+LHSymbSize);
    Points4[3].x:=Round(CenterX-LHSymbSize);
    Points4[3].y:=Round(CenterY+LHSymbSize);
    LHMetCan.Polygon(Points4);
    Inc(Angle1, Increment);
  until Angle1>=85;
  If Label1.checked then
  begin
    CenterX:=boxleft+370 - 6*Round(LHSymbSize);
    CenterY:=boxtop+30 - LHMetCan.Font.Height div 2;
    Points4[0].x:=Round(CenterX-LHSymbSize);
    Points4[0].y:=Round(CenterY+LHSymbSize);
    Points4[1].x:=Round(CenterX);
    Points4[1].y:=Round(CenterY-LHSymbSize);
    Points4[2].x:=Round(CenterX+LHSymbSize);
    Points4[2].y:=Round(CenterY+LHSymbSize);
    Points4[3].x:=Round(CenterX-LHSymbSize);
    Points4[3].y:=Round(CenterY+LHSymbSize);
    LHMetCan.Polygon(Points4);
  end;
  If LHSymbFillflag or lhsymbfillflag2 then LHMetCan.Brush.style:=bsclear;
  {********************Labelling***********************}
  If Label1.checked then
  begin
    LHMetCan.TextOut(55, 10, 'Datasets: '+IntToStr(LHz+1));
    LHMetCan.TextOut(170, 10, LHLabel1);
    LHMetCan.TextOut(55, 25,'Skipped:     '+IntToStr(Nosense));
    LHMetCan.TextOut(boxleft+370, boxtop+10,'p-axes');
    LHMetCan.TextOut(boxleft+370, boxtop+30,'t-axes');
  end;
    {*****************Numbering R%-axis(y)**********************}
  If Number1.Checked then
  begin
    Angle1:=0;
    Repeat
      LHMetCan.TextOut(zerox-20, zeroy - 4 * Angle1 +
      LHMetCan.Font.Height div 2,IntToStr(Angle1));
      Inc(Angle1,20);
    until Angle1>80;
    LHMetCan.TextOut(zerox-20, boxtop+25,'R [%]');
    {*****************Numbering theta-axis(x)**********************}
    Angle1:=10;
    Repeat
      SetTextAlign(LHMetCan.Handle, TA_CENTER);
      LHMetCan.TextOut(zerox + 18 * (Angle1-10) div 4 ,boxbottom-29, IntToStr(Angle1));
      Inc(Angle1,10);
    until Angle1>=85;
    SetTextAlign(LHMetCan.Handle, TA_LEFT);
    LHMetCan.TextOut(boxleft+360, boxbottom-29,'Theta [°]');
  end;
  {***************Assign data to display*********************}
  Label11.Caption:=IntToStr(BThetaP)+'°';
  Label7.Caption:=IntToStr(BThetaT)+'°';
  Label8.Caption:=IntToStr(BThetaBoth)+'°';
  NumEdit1.Number := BThetaBoth;
  Label9.Caption:=IntToStr(PRofPAxis^[BThetaP div Increment])+'%';
  Label14.Caption:=IntToStr(PRofTAxis^[BThetaP div Increment])+'%';
  Label12.Caption:=IntToStr(PRofPAxis^[BThetaT div Increment])+'%';
  Label15.Caption:=IntToStr(PRofTAxis^[BThetaT div Increment])+'%';
  Label13.Caption:=IntToStr(PRofPAxis^[BThetaBoth div Increment])+'%';
  Label16.Caption:=IntToStr(PRofTAxis^[BThetaBoth div Increment])+'%';
  LHMetCan.Free;
  inherited;
  LHPlotInfo:=LHPlotInfo+#13#10+
    'Skipped: '+IntToStr(Nosense);
  GlobalFailed:=False;
end;

procedure Tbtdraw.FormCreate2(Sender: TObject);
begin
   TecMainWin.ArrangeMenu(Sender);
   Paintbox1.align:=alnone;
   Paintbox1.boundsrect:=Bevel3.boundsrect;
   Paintbox1.bringtofront;
   LHWriteWMF:=writewmfglobal;
   GetMem(PRofPAxis, SizeOf(PRofPAxis^[0])*(85 div BT_increment+1));
   GetMem(PRofTAxis, SizeOf(PRofTAxis^[0])*(85 div BT_increment+1));
end;

procedure Tbtdraw.WriteBtnClick(Sender: TObject);
var Ext : String[4];
    Saveflag,Exitflag : Boolean;
begin
  Ext:='.t'+IntToStr(NumEdit1.Number);
  SaveDialog1.Filename:=ChangeFileExt(LHFileName, Ext);
  repeat
    Saveflag:= SaveDialog1.Execute;
    if saveflag then
    begin
      Case SaveDialog1.FilterIndex of
        1: SaveDialog1.FileName := ChangeFileExt(SaveDialog1.FileName,Ext);
      end;
      If FileExists(SaveDialog1.Filename) then
      Case MessageDlg('File '+SaveDialog1.Filename+' already exists! Overwrite?', mtWarning,[mbOk,mbCancel, mbRetry], 0) of
        mrRetry: Exitflag:=false;
        mrCancel: exit;
        mrOK: Exitflag:=true;
      end else exitflag:=true;
    end else exitflag:=true;
  until exitflag;
  If saveflag then
  begin
    x:=NumEdit1.Number;
    BackToTheta(x,SaveDialog1.Filename);
    Close;
  end;
end;

procedure Tbtdraw.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure Tbtdraw.PaintBox1Paint(Sender: TObject);
begin
   Screen.Cursor:=crHourglass;
   with Paintbox1 do
     If LHWriteWMF then
       Canvas.StretchDraw(BoundsRect, LHMetafile)
     else Canvas.StretchDraw(BoundsRect, LHEnhMetafile);
   Screen.Cursor:=crDefault;
end;

procedure Tbtdraw.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeMem(PRofPAxis, SizeOf(PRofPAxis^[0])*(85 div BT_increment+1));
  FreeMem(PRofTAxis, SizeOf(PRofTAxis^[0])*(85 div BT_increment+1));
  inherited;
end;

procedure Tbtdraw.Button1Click(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
