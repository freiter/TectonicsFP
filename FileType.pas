unit FileType;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls, 
  Buttons, ExtCtrls, Dialogs, Types;

type
  TFileTypeDlg = class(TForm)
    HelpBtn: TButton;
    RadioGroup1: TRadioGroup;
    Bevel1: TBevel;
    Button1: TButton;
    Edit1: TEdit;
    ParentFileDlg: TOpenDialog;
    CheckBox1: TCheckBox;
    procedure HelpBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  end;

var
  FileTypeDlg: TFileTypeDlg;

implementation

{$R *.DFM}

procedure TFileTypeDlg.HelpBtnClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

procedure TFileTypeDlg.Button1Click(Sender: TObject);
begin
  With ParentFileDlg do
  begin
    FileName:=Edit1.Text;
    If Execute then Edit1.Text:=Filename
    else Edit1.Text:='';
  end;
end;

procedure TFileTypeDlg.CheckBox1Click(Sender: TObject);
begin
  Button1.Enabled:=Checkbox1.checked;
  Edit1.Enabled:=Checkbox1.checked;
end;

end.

