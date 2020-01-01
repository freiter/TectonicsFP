unit results;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, LowHem, types, Menus, ExtCtrls, Buttons;

type
TRollup = Class(TForm)
  protected
    procedure FormMove(var Message: TWMMove); message WM_MOVE;
    procedure FormActivate(var Message: TWMActivate); message WM_ACTIVATE;
    procedure FormCreate(var Message: TWMCreate); message WM_CREATE;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    FOwner : TComponent;
    rindex, MyClientHeight, relx,rely, MyRollupWidth, Rollupx, Rollupy : Integer;
    minimized, Aligned, Deactivating, RollupStartDr: Boolean;
    RollupName: TRollupType;
    procedure Initialize(AOwner: TComponent); virtual;
    procedure Minimize1Click(Sender: TObject); virtual;
    procedure Minimize1Click2(Sender: TObject);
    procedure Restore1Click(Sender: TObject); virtual;
    procedure FormResize(Sender: TObject); virtual;
    procedure Panel6MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure Panel6MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); virtual;
    procedure PopupMenu1Popup(Sender: TObject); virtual;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); virtual;
    procedure ArrangeAll1Click(Sender: TObject); virtual;
    procedure Panel6MouseUp(Sender: TObject; Button: TMouseButton;
              Shift: TShiftState; X, Y: Integer); virtual;
    procedure Arrange1Click(Sender: TObject); virtual;
end;

type
  TResinsp = class(TRollup)
    Memo1: TMemo;
    PopupMenu1: TPopupMenu;
    Close1: TMenuItem;
    Minimize1: TMenuItem;
    Panel6: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Restore1: TMenuItem;
    Arrange1: TMenuItem;
    ArrangeAll1: TMenuItem;
    PopupMenu2: TPopupMenu;
    Copy1: TMenuItem;
    SelectAll1: TMenuItem;
    MenuItem3: TMenuItem;
    Restore2: TMenuItem;
    Minimize2: TMenuItem;
    Arrange2: TMenuItem;
    ArrangeAll2: TMenuItem;
    Close2: TMenuItem;
    CloseAll1: TMenuItem;
    CloseAll2: TMenuItem;
    N1: TMenuItem;
    Help2: TMenuItem;
    N2: TMenuItem;
    Help1: TMenuItem;
    procedure FormClose(Sender: TObject; var Action: TCloseAction); override;
    procedure Copy1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure Panel6MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Panel6MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Restore1Click(Sender: TObject);
    procedure Minimize1Click(Sender: TObject); override;
    procedure SpeedButton2Click(Sender: TObject);
    procedure ArrangeAll1Click(Sender: TObject); override;
    procedure CloseAll1Click(Sender: TObject);
    procedure Arrange1Click(Sender: TObject); override;
    procedure Panel6MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
    procedure FormResize(Sender: TObject); override;
    procedure Help1Click(Sender: TObject);
    procedure PopupMenu2Popup(Sender: TObject);
    procedure Help2Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
  public
    procedure Initialize(AOwner: TComponent); override;
    procedure Reset(Sender: TObject);
  protected
    creating, button_clicked: boolean;
    procedure CreateParams(var Params: TCreateParams); override;
  end;
  TRollups = Array[0..2] of TRollup;

var
  ResInsp: TResInsp;
  TFPRollups: TRollups;

implementation

uses Tecmain, Settings;

{$R *.DFM}

procedure TRollup.FormMove(var Message: TWMMove);
begin
  //If (left+width<>rollupx+rollupwidth) or (top<>rollupy) then Aligned:=false;
end;

procedure TRollup.CreateParams(var Params: TCreateParams);
begin
  inherited;
  With Params do
  begin
    //Style:=style or WS_EX_TOOLWINDOW;
    Style:=Style or WS_DLGFRAME;
    //WndParent:=TecMainWin.Handle;
  end;
end;

procedure TRollup.Initialize(AOwner: TComponent);
begin
  FOwner:=AOwner;
end;

procedure TRollup.FormCreate(var Message: TWMCreate);
var i: Integer;
begin
  inherited;
  relx:=0;
  rely:=0;
  inc(GlobalRollupsOpen);
  aligned:=false;
  if not minimized then (FindComponent('SpeedButton1') as TSpeedButton).down:=true;
  For i:=0 to 2 do
    if TFPRollups[i]=nil then
    begin
      tfprollups[i]:=self;
      rindex:=i;
      exit;
    end;
end;

procedure TRollup.Minimize1Click(Sender: TObject);
var faligned: boolean;
begin
  faligned:=aligned;
  minimized:=true;
  visible:=false;
  (Findcomponent('Minimize1') as TMenuItem).Enabled:=false;
  (Findcomponent('Restore1') as TMenuItem).Enabled:=true;
  (Findcomponent('Speedbutton1') as TSpeedbutton).down:=false;
  MyRollupwidth:=width;
  MyClientHeight:=ClientHeight;
  ClientHeight:=RollupPanelHeight;
  Left:=left+width-rollupwidth;
  RollupX:=Left;
  Width:=RollupWidth;
  visible:=true;
  aligned:=faligned;
  TecMainWin.BringToFront;
end;

procedure TRollup.Minimize1Click2(Sender: TObject);
var faligned: boolean;
begin
  faligned:=aligned;
  minimized:=true;
  visible:=false;
  (Findcomponent('Minimize1') as TMenuItem).Enabled:=false;
  (Findcomponent('Restore1') as TMenuItem).Enabled:=true;
  (Findcomponent('Speedbutton1') as TSpeedbutton).down:=false;
  MyRollupwidth:=width;
  MyClientHeight:=ClientHeight;
  ClientHeight:=RollupPanelHeight;
  if faligned then Left:=left+width-rollupwidth;  //bugfix  20000421 F.R.
  RollupX:=Left;
  Width:=RollupWidth;
  visible:=true;
  aligned:=faligned;
  TecMainWin.BringToFront;
end;

procedure TRollup.Restore1Click(Sender: TObject);
var faligned: boolean;
begin
  faligned:=aligned;
  minimized:=false;
  visible:=false;
  width:=MyRollupwidth;
  Clientheight:=MyClientHeight;
  left:=left+rollupwidth-width;
  RollupX:=Left;
  (Findcomponent('Speedbutton1') as TSpeedbutton).down:=true;
  (Findcomponent('Arrange1') as TMenuItem).Enabled:=True;
  visible:=true;
  aligned:=faligned;
end;

 procedure TRollup.FormResize(Sender: TObject);
 begin
   (Findcomponent('Speedbutton1') as TSpeedButton).Left:=ClientWidth-38;
   (Findcomponent('Speedbutton2') as TSpeedButton).Left:=ClientWidth-20;
 end;

procedure TRollup.FormActivate(var Message: TWMActivate);
begin
  inherited;
  If Message.Active=WA_INACTIVE then With FindComponent('Panel6') as TPanel do
  begin
    Color:= clInactiveCaption;
    Font.Color:= clInactiveCaptionText;
  end
  else
  begin
    {if SetForm<>nil then
      ArrangeAll1.Enabled:=True
    else ArrangeAll1.Enabled:=false;}
    With FindComponent('Panel6') as TPanel do
    begin
      Color:=  clActiveCaption;
      Font.Color:= clCaptionText;
      TecMainWin.CopyBtn.Enabled:=False;
      TecMainWin.CutBtn.Enabled:=False;
      TecMainWin.PasteBtn.Enabled:=False;
      TecMainWin.UndoBtn.Enabled:=False;
      TecMainWin.RedoBtn.Enabled:=False;
      TecMainWin.PrintBtn.Enabled:=False;
    end;
  end;
end;

procedure TRollup.Panel6MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  relX:=X;
  relY:=Y;
  if x<RollupPanelHeight then
  begin
    (FindComponent('popupmenu1') as TPopupmenu).popupcomponent:=Sender as TComponent;
    (FindComponent('popupmenu1') as TPopupmenu).popup(Rollupx,Rollupy+RollupPanelHeight);
  end;
end;

procedure TRollup.Panel6MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if ssLeft in Shift then
    MoveWindow(Handle, x-relX+left, y-rely+top, width, height, true);
end;

procedure TRollup.PopupMenu1Popup(Sender: TObject);
begin
  (Findcomponent('Restore1') as TMenuItem).Enabled:=minimized;
  (Findcomponent('Minimize1') as TMenuItem).Enabled:=not minimized;
  (Findcomponent('ArrangeAll1') as TMenuItem).Enabled:=GlobalRollupsOpen>1;
  (Findcomponent('CloseAll1') as TMenuItem).Enabled:=GlobalRollupsOpen>1;
end;

procedure TRollup.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  dec(GlobalRollupsOpen);
  TFPRollups[rindex]:=nil;
  Action:=caFree;
end;

procedure TRollup.ArrangeAll1Click(Sender:TObject);
begin
  TecMainWin.ArrangeAllRollups(Sender);
end;

procedure TRollup.Panel6MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const range = 10;
begin
  if aligned then
    if (abs(Rollupx-left)> range) or (abs(Rollupy-top)>range) then
    begin
      aligned:=false;
      TecMainWin.SwapRollups(Self);
      RollupX:=left;
      RollupY:=top;
    end
    else
    begin
      left:= Rollupx;
      top:= Rollupy;
      aligned:= true;
    end
  else
  begin
    RollupX:=left;
    RollupY:=top;
  end;
end;

procedure TRollup.Arrange1Click(Sender: TObject);
var i: Integer;
begin
  If not minimized then
  begin
    For i:= 0 to 2 do
    begin
      If tfprollups[i]<>nil then
      begin
        if tfprollups[i].aligned and (tfprollups[i]<>self) and not tfprollups[i].minimized then
          tfprollups[i].Minimize1Click(Sender);
      end;
    end;
    aligned:=true;
    TecMainWin.ArrangeAllRollups2(Sender);
  end
  else TecMainWin.ArrangeRollups(Self);
end;

//*****************************End TRollup**************************************


procedure TResinsp.CreateParams(var Params: TCreateParams);
begin
  inherited;
  With Params do Style:=Style or WS_SIZEBOX;
end;

procedure TResinsp.FormCreate(Sender: TObject);
begin
  creating:=true;
  button_clicked:=true;
  aligned:=ResInspAligned;
  minimized:=ResInspMinimized;
  Rollupname:=rt_results;
  MyRollupWidth:=ResInspWidth;
  Width:= ResInspWidth;
  Height:=ResInspHeight;
  if not minimized or not aligned then Left:=ResInspLeft   //Bugfix 990803
  else Left:=ResInspLeft-width+rollupwidth;
  Top:=ResInspTop;
  rollupx:=Left;
  rollupy:=Top;
  creating:=false;
end;

procedure TResInsp.Initialize(AOwner: TComponent);
begin
  inherited;
  rollupx:= ResInspLeft;
  rollupy:= ResInspTop;
  Memo1.Clear;
  if FOwner<>nil then
  begin
    Memo1.Lines.Add((FOwner as TLHWin).LHPlotInfo);
    Case (FOwner as TLHWin).LHPlotType of
      pt_GreatCircle, pt_smallCircle, pt_PiPlot, pt_DipLine: Memo1.HelpContext:=150;
      else Memo1.HelpContext:=HelpContext;
    end;
    If Minimized then
    begin
      Panel6.Caption:=' Results';
      button_clicked:=false;
    end
    else
    begin
      //If Aligned then open in left direction
      Panel6.Caption:=' Results: Plot '+ IntToStr((FOwner as TLHWin).LHPlotNumber);
      Memo1.Hint:=ExtractFilename((FOwner as TLHWin).LHFilename)+': results as text.| ';
      button_clicked:=false;
    end;
  end
  else Memo1.HelpContext:=HelpContext;
end;

procedure TResinsp.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  ResInspLeft:= RollupX;
  ResInspTop:= RollupY;
  ResInspAligned:=aligned;
  ResInspMinimized:=Minimized;
  ResInsp:=nil;
  inherited;
end;

procedure TResinsp.Reset(Sender: TObject);
begin
  Panel6.Caption:=' Results';
  Memo1.Clear;
  FOwner:=nil;
end;

procedure TResinsp.Copy1Click(Sender: TObject);
begin
  Memo1.CopyToClipboard;
end;

procedure TResinsp.SelectAll1Click(Sender: TObject);
begin
  Memo1.SelectAll;
end;

procedure TResinsp.Close1Click(Sender: TObject);
begin
  Close;
end;

procedure TResinsp.SpeedButton1Click(Sender: TObject);
begin
  button_clicked:=true;
  if not minimized then
     Minimize1Click(Sender)
  else
     Restore1Click(Sender);
  If aligned then TecMainWin.SwapRollups2(Self);
  button_clicked:=false;
end;

procedure TResinsp.Panel6MouseMove(Sender: TObject; Shift: TShiftState;
                                   X,Y: Integer);
begin
  inherited Panel6MouseMove(Sender,Shift,X, Y);
  ResInspLeft:= rollupx;
  ResInspTop:= rollupy;
end;

procedure TResinsp.Panel6MouseDown(Sender: TObject; Button: TMouseButton;
                                   Shift: TShiftState; X, Y: Integer);
begin
  inherited Panel6MouseDown(Sender, Button, Shift, X, Y);
end;

procedure TResinsp.Restore1Click(Sender: TObject);
begin
  button_clicked:=true;
  inherited;
  If FOwner<>nil then Panel6.Caption:=' Results: Plot '+ IntToStr((FOwner as TLHWin).LHPlotNumber);
  button_clicked:=false;
end;

procedure TResinsp.Minimize1Click(Sender: TObject);
begin
  button_clicked:=true;
  inherited;
  Panel6.Caption:=' Results';
  button_clicked:=false;
end;

procedure TResinsp.SpeedButton2Click(Sender: TObject);
begin
  Close;
end;

procedure TResinsp.ArrangeAll1Click(Sender: TObject);
begin
  inherited ArrangeAll1Click(Sender);
end;

procedure TResinsp.CloseAll1Click(Sender: TObject);
begin
  TecMainWin.CloseAllRollups(Sender);
end;

procedure TResinsp.Arrange1Click(Sender: TObject);
begin
  inherited Arrange1Click(Sender);
end;

procedure TResinsp.Panel6MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited Panel6MouseUp(Sender, Button, Shift, X, Y);
end;

procedure TResinsp.FormResize(Sender: TObject);
var faligned: boolean;
begin
  inherited;
  if not minimized and not creating then
  begin
    ResInspWidth:= Width;
    ResInspHeight:= Height;
  end
  else
    begin
      if not button_clicked then
      begin
        ResInspWidth:= Width;
        ResInspHeight:= Height;
        faligned:=aligned;
        visible:=false;
        minimized:=false;
        Speedbutton1.down:=true;
        Arrange1.Enabled:=True;
        visible:=true;
        aligned:=faligned;
      end;
    end;
  rollupx:=left;
  rollupy:=top;
end;

procedure TResinsp.Help1Click(Sender: TObject);
begin
  if Panel6.HelpContext<>0 then
  if Panel6.HelpContext<500 then
    Application.HelpCommand(HELP_CONTEXTPOPUP,(Panel6.HelpContext))
  else
    Application.HelpContext(Panel6.HelpContext);
end;

procedure TResinsp.PopupMenu2Popup(Sender: TObject);
begin
  Copy1.Enabled := Memo1.SelLength <> 0;
  SelectAll1.Enabled:=Memo1.Text<>'';
  Restore2.Enabled:=Minimized;
  Minimize2.Enabled:=not minimized;
  if sender is TPopupMenu then
    if (Sender as TPopupMenu).PopupComponent is TWinControl then
      Help2.Enabled:=((Sender as TPopupMenu).PopupComponent as TWinControl).HelpContext<>0
    else Help2.Enabled:=false
  else Help2.Enabled:=false;
end;

procedure TResinsp.Help2Click(Sender: TObject);
begin
  if Memo1.HelpContext<>0 then
  if Memo1.HelpContext<500 then
    Application.HelpCommand(HELP_CONTEXTPOPUP,Memo1.HelpContext)
  else
    Application.HelpContext(Memo1.HelpContext);
end;

procedure TResinsp.PopupMenu1Popup(Sender: TObject);
begin
  inherited PopupMenu1Popup(Sender);
end;

end.
