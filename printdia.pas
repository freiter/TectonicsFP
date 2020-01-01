unit Printdia;

interface

uses SysUtils, Windows, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Numedit;

type
  TPrintDial = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    NumEdit1: TNumEdit;
    Edit1: TEdit;
    Edit2: TEdit;
    HelpBtn: TBitBtn;
    procedure OKBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure HelpBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses types, LowHem, TecMain;
{$R *.DFM}

procedure TPrintDial.OKBtnClick(Sender: TObject);
begin
  PrintLowerHemiSize:=Numedit1.Number;
end;

procedure TPrintDial.FormCreate(Sender: TObject);
begin
  NumEdit1.Number:=PrintLowerHemiSize;
end;

procedure TPrintDial.HelpBtnClick(Sender: TObject);
begin
  Application.HelpCommand(HELP_CONTEXTPOPUP,HelpContext);
end;

end.
