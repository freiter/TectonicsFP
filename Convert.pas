unit Convert;

interface

uses Windows, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Dialogs,SysUtils, fileops;

type
  TConvDlg1 = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    Bevel1: TBevel;
    RadioGroup1: TRadioGroup;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    procedure OKBtnClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ConvDlg1: TConvDlg1;

implementation

{$R *.DFM}
uses TecMain, Types;

procedure TConvDlg1.OKBtnClick(Sender: TObject);
var f, g : textfile;
    ch : Char;
    exitflag, saveflag: boolean;
    dummy: string;
begin
  if OpenDialog1.Execute then
    begin
      repeat
       saveflag:= SaveDialog1.Execute;
       if saveflag then
       begin
         exitflag:=true;
         if SaveDialog1.filename=OpenDialog1.filename then
           Case MessageDlg('Select a filename different from the input file!', mtWarning,[mbCancel,mbRetry], 0) of
          mrCancel:
          begin
            Saveflag:=false;
            exit;
          end;
          mrRetry: ExitFlag:=False;
        end;
       end;
      until exitflag;
      if saveflag then
        begin
          Screen.Cursor := CrHourGlass;
          try
          AssignFile(f, OpenDialog1.FileName);
          Reset(f);
          try
            AssignFile(g, SaveDialog1.FileName);
            Rewrite(g);
            if RadioGroup1.ItemIndex = 0 then
              begin
                While not eof(f) do
                  begin
                    readln(f, dummy);
                    dummy:=AdjustLineBreaks(Dummy);
                    writeln(g, dummy);
                  end;
               end
            else
              begin
                While not eof(f) do
                  begin
                    read(f, ch);
                    if ch <> #10 then write(g, ch);
                  end;
              end;
            CloseFile(g);
            Screen.Cursor := CrDefault;
            TecMainWin.WriteToStatusbar(nil ,'Written to file '+SaveDialog1.FileName);
          except
            on EInOutError do  {can not write to file}
              begin
                CloseFile(f);
                Screen.Cursor := CrDefault;
                MessageDlg('Conversion of '+OpenDialog1.FileName+' failed!', mtInformation,[mbOk], 0);
              end;
          end;
          CloseFile(f);
          except   {can not open file}
    On EInOutError do
      begin
        Globalfailed:=true;
        Screen.Cursor:=crDefault;
        MessageDlg('Can not open '+OpenDialog1.Filename+' !'#10#13+
        'Processing stopped. File might be in use by another application.',
        mtError,[mbOk], 0);
        Close;
        Exit;
      end;
    end;
        end;
    end;
end;

procedure TConvDlg1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if MDIChildCount <= 1 then TecMainWin.Window1.Enabled := false;
  Action := caFree;
end;

end.
