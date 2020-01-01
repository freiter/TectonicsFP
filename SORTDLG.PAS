unit Sortdlg;

interface

uses Windows, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls{, Numedit};

type
  TSortDialog = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    RadioGroup1: TRadioGroup;
    procedure OKBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Opt1 : Boolean;
  end;

var
  SortDialog: TSortDialog;


implementation

{$R *.DFM}
uses types;

procedure TSortDialog.OKBtnClick(Sender: TObject);
begin
  If RadioGroup1.ItemIndex=0 then
    Opt1 := true
  else
    Opt1 := false;
end;
end.
