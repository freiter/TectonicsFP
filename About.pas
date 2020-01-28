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
    lblLicense: TLabel;
    Label2: TLabel;
    lblHP: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ProgramIconClick(Sender: TObject);
  end;




var
  AboutBox: TAboutBox;
implementation
{$R *.DFM}


procedure TAboutBox.FormCreate(Sender: TObject);
begin
  lblCopyright.Caption:=CopyrightMessage;
  lblVersion.Caption:=lblVersion.caption+' '+tfpversion;
  lblHP.Caption:=capHP;
  lblLicense.Caption:= capLicense;
end;

procedure TAboutBox.ProgramIconClick(Sender: TObject);
begin
   Close;
end;

end.

