unit Exprtdia;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Numedit;

type
  TExportForm = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Label1: TLabel;
    NumEdit1: TNumEdit;
    Label2: TLabel;
    HelpBtn: TButton;
    Label3: TLabel;
    NumEdit2: TNumEdit;
    NumEdit3: TNumEdit;
    Label4: TLabel;
    Edit1: TEdit;
    procedure HelpBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ExportForm: TExportForm;

implementation

uses tecmain;
{$R *.DFM}


procedure TExportForm.HelpBtnClick(Sender: TObject);
begin
  Application.HelpContext(HelpContext);
end;

end.
