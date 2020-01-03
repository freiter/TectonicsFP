unit About;

interface

uses Windows, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, SysUtils, Tecmain, Types, Registry, Dialogs;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    lblVersion: TLabel;
    lblCopyright: TLabel;
    lblComments: TLabel;
    lblLicensedTo: TLabel;
    Label4: TLabel;
    lblCompany: TLabel;
    lblSerial: TLabel;
    Label2: TLabel;
    lblHP: TLabel;
    btnSerial: TButton;
    edtSerial: TEdit;
    btnRegister: TButton;
    edtLicensee: TEdit;
    edtCompany: TEdit;
    lblName: TLabel;
    lblCompany2: TLabel;
    lblSerial2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ProgramIconClick(Sender: TObject);
    procedure btnRegisterClick(Sender: TObject);
    procedure btnSerialClick(Sender: TObject);
    procedure edtSerialChange(Sender: TObject);
  end;




var
  AboutBox: TAboutBox;
implementation
{$R *.DFM}


procedure TAboutBox.FormCreate(Sender: TObject);
begin
  lblLicensedTo.Caption:= lblLicensedTo.Caption+licensee;
  lblSerial.Caption:=lblSerial.Caption+tfpserialnumber;
  lblCompany.caption:=lblCompany.caption+company;
  lblCopyright.Caption:=CopyrightMessage;
  lblVersion.Caption:=lblVersion.caption+' '+tfpversion;
  lblHP.Caption:=capHP;
  btnSerial.Visible:= False;
end;

procedure TAboutBox.ProgramIconClick(Sender: TObject);
begin
   Close;
end;



procedure TAboutBox.btnRegisterClick(Sender: TObject);
var keydummy: HKey;
    TextDummy: String;
    AppName: PChar;
begin
  if RegOpenKeyEx(HKEY_LOCAL_MACHINE, PChar('SOFTWARE\GeoCompute\TectonicsFP\'+TFPRegEntryVersion),
                    0, KEY_SET_VALUE, keydummy)=ERROR_SUCCESS then
  begin
    btnRegister.Enabled:= False;
    TextDummy:=edtSerial.Text;
    RegSetValueEx(Keydummy, 'Serial', 0, REG_SZ, PChar(TextDummy), Length(TextDummy));
    TextDummy:=edtCompany.Text;
    RegSetValueEx(Keydummy, 'Company', 0, REG_SZ, PChar(TextDummy), Length(TextDummy));
    TextDummy:=edtLicensee.Text;
    RegSetValueEx(Keydummy, 'Name', 0, REG_SZ, PChar(TextDummy), Length(TextDummy));
    RegFlushKey(KeyDummy);
    RegCloseKey(KeyDummy);
    MessageDlg('Serial registered. Please Restart TectonicsFP!', mtInformation,[mbOK], 0);
    Close;
  end;
end;  

procedure TAboutBox.btnSerialClick(Sender: TObject);
begin
  btnSerial.Enabled:= False;
  height := height + 86;
  edtSerial.Visible:= True;
  edtCompany.Visible:=True;
  edtLicensee.Visible:=True;
  btnRegister.Visible:= True;
  lblName.Visible:=True;
  lblSerial2.Visible:=TRue;
  lblCompany2.Visible:=True;
  edtLicensee.Text:=licensee;
  edtCompany.Text:=Company;
  edtSerial.Text:= tfpSerialNumber;
end;

procedure TAboutBox.edtSerialChange(Sender: TObject);
begin
  btnRegister.Enabled := Length(edtSerial.Text) = 32;
end;

end.

