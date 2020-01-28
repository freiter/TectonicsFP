unit Titlepic;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, ExtCtrls, Buttons;

type
  TTitpfm = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    TitleLabel: TLabel;
    Bevel1: TBevel;
    lblLicense: TLabel;
    procedure FormCreate(Sender: TObject);
  end;

var
  Titpfm: TTitpfm;

implementation

{$R *.DFM}


procedure TTitpfm.FormCreate(Sender: TObject);
begin
  With Image1 do
  begin
    {Top:=100;
    Left:=100;
    Height:=100;
    Width:=100;
    Update;}
  end;  
end;

end.                                  
