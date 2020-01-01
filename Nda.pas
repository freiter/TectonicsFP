unit NDA;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Buttons, Types, Numedit, math, Invers;


type
   TNDAPlot = class(TStressTensorPlot)
   public
     procedure Init(Sender: TObject; const AFilename: String; const AExtension: TExtension; FTheta: Integer);
     procedure FormCreate(Sender: TObject; const AFilename: String; const AExtension: TExtension); override;
   private
     procedure SaveAs1Click(Sender: TObject); override;
   end;

procedure exco (azimuthF,dipF,bearingS,plungeS: single; sense,angle1 : Integer;
                var bearingP,plungeP,bearingT,plungeT: single);

implementation

uses tecmain, fileops;


procedure exco (azimuthF,dipF,bearingS,plungeS: single; sense,angle1 : Integer;
                var bearingP,plungeP,bearingT,plungeT: single);
  var
    f1,f2,f3,s1,s2,s3,p1,p2,p3,t1,t2,t3 : double;
  begin
    polcar(azimuthF, dipF-90,f1,f2,f3);
    polcar(bearingS,plungeS,s1,s2,s3);
    s1:=-sense*s1;
    s2:=-sense*s2;
    s3:=-sense*s3;
    p1:=f1-1/TAN(DegToRad(angle1))*s1;
    p2:=f2-1/TAN(DegToRad(angle1))*s2;
    p3:=f3-1/TAN(DegToRad(angle1))*s3;
    t1:=f1+TAN(DegToRad(angle1))*s1;
    t2:=f2+TAN(DegToRad(angle1))*s2;
    t3:=f3+TAN(DegToRad(angle1))*s3;
    carpol(p1,p2,p3,bearingP,plungeP);
    carpol(t1,t2,t3,bearingT,plungeT);
  END;

//*********************TNDAPlot*********************************************


procedure TNDAPlot.Init(Sender: TObject; const AFilename: String; const AExtension: TExtension; FTheta: Integer);
begin
  Theta:=FTheta;
  LHExtension:=AExtension;
  LHFilename:= AFilename;
  SaveAs1.Visible:=true;
  SaveAs1.enabled:=true;
  SaveAs1.OnClick:=SaveAs1Click;
  TecMainWin.SaveBtn.Enabled:=true;
end;


procedure TNDAPlot.FormCreate(Sender: TObject; const AFilename: String; const AExtension: TExtension);
var
    p1,p2,p3,t1,t2,t3: double;
    bearingP, PlungeP, bearingT, plungeT,e,f, alpha, dummy, pitch,
      DipDir, Dip, Azimuth, Plunge, dumy: single;
    magnitudePS : array[1..3] of single;
    z1, z2 : integer;
    { reverse,} intdumy : Integer;
    Sense, Quality,I, nbivalent: Integer;
    sensestr: Tstring4;
    om,ev : T2Sing1by3;
    Fn: Textfile;
    NoComment: boolean;
    Comment, rstr: String;

begin
  Screen.Cursor := CrHourGlass;
  If Theta=0  then Theta:=1
  else
  begin
    If Theta<0  then Theta:=Abs(Theta);
    If Theta>89 then Theta:=89;
  end;
  lhfailed:=false;
  stt11:=0;
  stt12:=0;
  stt13:=0;
  stt21:=0;
  stt22:=0;
  stt23:=0;
  stt33:=0;
  lhz := 0;
  nbivalent:=0;
  try
    AssignFile(Fn, LHFilename);
    Reset(Fn);
    if not eof(fn) then
    begin
      while not Eof(Fn) and not lhfailed do
      begin
        if LHExtension = PTF then
          ReadPTFDataset(fn,Sense,Quality,DipDir,Dip,Azimuth,Plunge,
                dumy,dumy,dumy,dumy,dumy,dumy,dumy, intdumy, lhfailed,NoComment)
        else
          ReadFPLDataset(fn, Sense, Quality, DipDir, Dip, Azimuth, Plunge, lhfailed, NoComment, LHExtension, Comment);
        if not lhfailed and NoComment then
        begin
          If not eof(fn) then Inc(lhz);
          IF dip=90 THEN dip:=89;
          IF plunge=0 THEN plunge:=1;
          IF (Azimuth-DipDir=270) or (Azimuth-DipDir=-90)  THEN Azimuth:=Azimuth+0.1
          else IF (Azimuth-DipDir=-270) or (Azimuth-DipDir=90) THEN Azimuth:=Azimuth-0.1;
          Pitch:= ArcTaN(TAN(DegToRad(Azimuth)-DegToRad(DipDir)-PI/2)/COS(DegToRad(plunge)));
          {*****************convert sense to sperner's notation*************}
          IF Sense = 3 then
          begin
            if Pitch < 0 THEN Sense:= 2
            else if Pitch > 0 THEN Sense:= 1
            else sense:=0;
          end
          else
            IF Sense = 4 then
              if Pitch < 0 THEN Sense:= 1
              else if Pitch > 0 THEN Sense:= 2
              else sense:=0;
          IF Sense = 2 THEN
          begin
            Sense:= -1;
            sensestr:='-';
          end
          else IF Sense=1 THEN sensestr:='+';
          IF (Sense<>5) and (sense<>0) THEN
          begin
            try
              exco(DipDir,dip,Azimuth,plunge,Sense,Theta,bearingP,plungeP,bearingT,plungeT);
            except
              on EZeroDivide do
              begin
                Screen.Cursor := CrDefault;
                MessageDlg('No valid solution for dataset '+IntToStr(lhz)+'!'+#10#13+
                        ' Processing stopped.',mtError,[mbOk], 0);
                exit;
              end;
            end;
            polcar(bearingP,plungeP,p1,p2,p3);
            polcar(bearingT,plungeT,t1,t2,t3);
            stt11:=stt11+(p1*p1-t1*t1);
            stt12:=stt12+(p1*p2-t1*t2);
            stt13:=stt13+(p1*p3-t1*t3);
            stt21:=stt21+(p2*p1-t2*t1);
            stt22:=stt22+(p2*p2-t2*t2);
            stt23:=stt23+(p2*p3-t2*t3);
            stt33:=stt33+(p3*p3-t3*t3);
          end //end of block for valid sense only
          else inc(nbivalent);
        end else if not NoComment then dec(lhz);
      end; {end of while-loop}
    end else lhfailed:=true;
    CloseFile(Fn);
  except   {can not open output file}
    On EInOutError do
    begin
      GlobalFailed:=True;
      Screen.Cursor:=crDefault;
      MessageDlg('Can not open '+LHFilename+' !'#10#13+
        'Processing stopped. File might be in use by another application.',
        mtError,[mbOk], 0);
      Close;
      exit;
    end;
  end;
  If lhz-nbivalent<3 then //at least 4 valid datasets are needed.
  begin
    GlobalFailed:=True;
    Screen.Cursor:=crDefault;
    MessageDlg('At least 4 valid datasets are needed for this operation!'#10#13+
               'Processing stopped.', mtError,[mbOk], 0);
    close;
    exit;
  end;
  if not lhfailed then
  begin //eigenvalues
    ndatasets:=lhz+1;
    E:=stt11*stt33+stt22*stt33+stt11*stt22-sqr(stt12)-Sqr(stt13)-Sqr(stt23);
    f:=stt11*Sqr(stt23)+stt22*Sqr(stt13)+stt33*Sqr(stt12)-2*stt12*stt13*stt23-stt11*stt22*stt33;
    alpha:=ArcCos(-SQRt(27)/2*f/SQRt(-E*E*E))/3;
    magnitudePS[1]:= 2*SQRt(-E/3)*COS(alpha);
    magnitudePS[2]:=-2*SQRt(-E/3)*COS(alpha-PI/3);
    magnitudePS[3]:=-2*SQRt(-E/3)*COS(alpha+PI/3);
    FOR I:=1 TO 3 do
    begin
      om[I,1]:= stt11-magnitudePS[I];
      om[I,2]:= stt22-magnitudePS[I];
      om[I,3]:= stt33-magnitudePS[I];
      ev[I,3]:=-1;
      ev[I,2]:= (stt12*stt13-om[I,1]*stt23)/(Sqr(stt12)-om[I,1]*om[I,2]);
      ev[I,1]:= (stt13-stt12*ev[I,2])/om[I,1];
    end;
    carpol(ev[1,1],ev[1,2],ev[1,3],TensAzimuth[1],TensPlunge[1]);
    carpol(ev[2,1],ev[2,2],ev[2,3],TensAzimuth[2],TensPlunge[2]);
    carpol(ev[3,1],ev[3,2],ev[3,3],TensAzimuth[3],TensPlunge[3]);
    lhfailed:=true; //bugfix 990525: check result
    dummy:=DihedralAngle(TensAzimuth[1],TensPlunge[1], TensAzimuth[2],TensPlunge[2], true);
    if (dummy<1) or (dummy>89) then
    begin
      dummy:=DihedralAngle(TensAzimuth[1],TensPlunge[1], TensAzimuth[3],TensPlunge[3], true);
      if (dummy<1) or (dummy>89) then
      begin
        dummy:=DihedralAngle(TensAzimuth[2],TensPlunge[2], TensAzimuth[3],TensPlunge[3], true);
        lhfailed:=(dummy>=1) and (dummy<=89);
      end;
    end;
    If lhfailed then  //bugfix 990525
    begin
      GlobalFailed:=True;
      Screen.Cursor:=crDefault;
      MessageDlg('Operation failed.'#10#13+
        'Choose another paleostress method to obtain result.',
        mtError,[mbOk], 0);
      Close;
      Exit;
    end;
    FOR z1:= 1 TO 2 do
    begin
      FOR z2:=1 TO (3-z1) do
      begin
        IF magnitudePS[z1] < magnitudePS[z1+z2] THEN
        begin
          dummy:=magnitudePS[z1];
          magnitudePS[z1]:=magnitudePS[z1+z2];
          magnitudePS[z1+z2]:=dummy;
          dumy:=TensAzimuth[z1];
          TensAzimuth[z1]:=TensAzimuth[z1+z2];
          TensAzimuth[z1+z2]:=dumy;
          dumy:=TensPlunge[z1];
          TensPlunge[z1]:=TensPlunge[z1+z2];
          TensPlunge[z1+z2]:=dumy;
        end;
      end;
    end;
    stressratio:= (magnitudePS[2]-magnitudePS[3])/(magnitudePS[1]-magnitudePS[3]);
    NDATheta:=Theta;
    calcfluct(stt11,stt22,stt33, stt12,stt13,stt23, LHFileName, LHExtension, LHFilename,TensAzimuth,TensPlunge, rstr,false,skipped, negative);
    inherited;
    Screen.Cursor := CrDefault;
  end
  else
  begin
    Screen.Cursor := CrDefault;
    MessageDlg('Error reading '+ExtractFilename(LHFilename)+', dataset '+IntToStr(lhz+1)+'!'+#10#13+' Processing stopped.',
                      mtError,[mbOk], 0);
    Close;
  end;
end;


procedure TNDAPlot.SaveAs1Click(Sender: TObject);
var written, exitflag, saveflag: boolean;
    rstr: string;
begin
  SaveDialog1:=TSaveDialog.Create(Self);
  With SaveDialog1 do
  begin
    Filter:='NDA-files (*.n??)|*.n??|All files (*.*)|*.*';
    Options:=[ofHideReadOnly];
    Title:='Save NDA-file as';
    Filename:=ChangeFileExt(LHFileName, '.n' + IntToStr(Theta));
  end;
  repeat
    Saveflag:= SaveDialog1.Execute;
    if saveflag then
    begin
      Case SaveDialog1.FilterIndex of
        1: SaveDialog1.FileName := ChangeFileExt(SaveDialog1.FileName, '.n' + IntToStr(Theta));
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
    Str(stressratio:2:4, rstr);
    written:= calcfluct(stt11,stt22,stt33, stt12,stt13,stt23, LHFileName, LHExtension, SaveDialog1.Filename,TensAzimuth,TensPlunge, rstr,true,skipped, negative);
  end;
  SaveDialog1.free;
end;




end.
