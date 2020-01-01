unit Invers;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics,Types, math, Sigma, Dialogs;

type
  TStressTensorPlot = class(TSigmaForm)
  public
    negative: Integer;
    SaveDialog1: TSaveDialog;
    stt11,stt12,stt13,stt21,stt22,stt23,stt33: single;
    StressTenPlotInfo: String;
    function calcfluct (st11,st22,st33,st12,st13,st23: single; const FileName1: string;
                     const Extension1: TExtension; const filename2: string; bearingps,
                     plungeps : T1Sing1by3; rstr: Tstring15; WriteToFile: boolean;
                     var nosense, nev: Integer): Boolean;
  end;

  TInversPlot = class(TStressTensorPlot)
    procedure FormCreate(Sender: TObject; const AFilename: String; const AExtension: TExtension); override;
    procedure calcfluct2 (var reverse: integer; var fluctuation: single);
  public
    procedure SaveAs1Click(Sender: TObject); override;
  protected
    rstr: string;
  end;



implementation

uses nda, fileops, tecmain;


function TStresstensorPlot.Calcfluct(st11,st22,st33,st12,st13,st23: single; const FileName1: string;
                     const Extension1: TExtension; const filename2: string; bearingps,
                     plungeps : T1Sing1by3; rstr: Tstring15; WriteToFile: boolean;
                     var nosense, nev: Integer): Boolean;
  var    //reverse, fluctuation: write only
    F,g: TextFile;
    z,Sense,SenseSpecial, Quality, reverse, intdummy, x : Integer;
    f1,f2,f3,s1,s2,s3, o1,o2,o3, sv1, sv2, sv3: double;
    divergence, percentnev,shear, pitch,fluctuation, DipDir, Dip,
    Azimuth, Plunge, MyAzimuth: single;
    failed, NoComment, SenseMissing, hit : boolean;
    fstr: Tstring15;
    dummy, sinuserror, azdummy, dipdummy: single;
    Comment, Stringdummy: String;
  begin
    Screen.Cursor:=crHourGlass;
    failed:=false;
    result:=false;
    fluctuation:=0;
    nev:=0;
    nosense:=0;
    LHZ := 0;
    try
      AssignFile(F,FileName1);
      Reset(F);
    except   //can not open input file
      On EInOutError do
      begin
        GlobalFailed:=True;
        Screen.Cursor:=crDefault;
        MessageDlg('Can not open '+Filename1+' !'#10#13+
        'Processing stopped. File might be in use by another application.',
        mtError,[mbOk], 0);
        exit;
      end;
    end;
    try  //can output file been opened?
      If WriteToFile then
      begin
        AssignFile(g, FileName2);
        Rewrite(g);
        if Extension1=ERR then
        begin
          MessageDlg('Invalid file extension!',mtError,[mbOk], 0);
          failed:=true;
          CloseFile(f);
          CloseFile(g);
          Screen.Cursor:=crDefault;
          exit;
        end;
      end
      else
      begin  //allocate memory
        getmem(SFFluMohrFPLData,sizeof(SFFluMohrFPLData^[0])*(ndatasets));
      end;
      if not eof(f) then
      begin
        If WriteToFile then writeln(g, FileCommentSeparator,'Sense,DipDir,Dip,Azimuth,Plunge,striae-error, delta')
        else StressTenPlotInfo:='No. fault   lin.  se er delta';
        while not SeekEof(F) and not failed do
        begin
          if Extension1 = PTF then
            ReadPTFDataset(f,Sense,Quality,DipDir,Dip,Azimuth,Plunge,
                  dummy,dummy,dummy,dummy,dummy,dummy,dummy, intdummy, failed,NoComment)
          else
            ReadFPLDataset(f, Sense, Quality, DipDir, Dip, Azimuth, Plunge, failed, NoComment, Extension1, Comment);
          MyAzimuth:=Azimuth;
          if not failed and NoComment then
          begin
            //if not SeekEof(f) then Inc(LHZ);
            lhz:=lhz+1;
            IF dip=90 THEN dip:=89.99;
            IF plunge=0 THEN plunge:=0.01;
            IF (MyAzimuth-DipDir=270) or (MyAzimuth-DipDir=-90)  THEN MyAzimuth:=MyAzimuth+0.01
            else IF (MyAzimuth-DipDir=-270) or (MyAzimuth-DipDir=90) THEN MyAzimuth:=MyAzimuth-0.01;
            Pitch:= ArcTan((TAN(DegToRad(MyAzimuth)-DegToRad(DipDir)-PI/2))/COS(DegToRad(plunge)));
            //SenseSpecial:=Sense;
            SenseMissing:=False;
            SenseSpecial:=ConvertSense(Sense, pitch);
            IF SenseSpecial=2 THEN SenseSpecial:=-1
            else
              IF (SenseSpecial=5) or (SenseSpecial=0) THEN
              begin
                SenseSpecial:=1;
                SenseMissing:=True;
              end;
            if not sensemissing or not (self is tndaplot) then
            begin
              polcar(DipDir,(dip-90),f1,f2,f3);    //f1 to f3  fault plane
              polcar(MyAzimuth, plunge,s1,s2,s3);  //s1 to s3 fault lineation
              s1:= -SenseSpecial * s1;
              s2:= -SenseSpecial * s2;
              s3:= -SenseSpecial * s3;
              o1:=f2*s3-f3*s2; //b axis
              o2:=f3*s1-f1*s3;
              o3:=f1*s2-f2*s1;
              sv1:=f1*st11+f2*st12+f3*st13;  //st=stress tensor
              sv2:=f1*st12+f2*st22+f3*st23;  //sv=stress vector
              sv3:=f1*st13+f2*st23+f3*st33;
              carpol(sv1,sv2,sv3, azdummy, dipdummy);
              divergence:=ArcCos((o1*sv1+o2*sv2+o3*sv3)/SQRt(Sqr(sv1)+Sqr(sv2)+Sqr(sv3))); // divergence: angle betw. max. shear stress and  fault lineation
              IF divergence < PI/2 THEN divergence:= PI/2 - divergence
              ELSE divergence:= divergence - PI/2;
              shear:= ArcCos((s1*sv1+s2*sv2+s3*sv3)/SQRt(Sqr(sv1)+Sqr(sv2)+Sqr(sv3)));  //delta in sperner's thesis
              fluctuation:= fluctuation + RadToDeg(divergence);                         //shear: angle between stress vector and fault lineation
            end
            else
            begin
              divergence:=0;
              shear:=0;
            end;
            If WriteToFile then
              write(g, Sense,FileListSeparator,
                  FloatToString(Dipdir,3,2),FileListSeparator,FloatToString(Dip,2,2),FileListSeparator,
                    FloatToString(Azimuth,3,2),FileListSeparator,FloatToString(Plunge,2,2),FileListSeparator,
                    FloatToString(RadToDeg(divergence),2,0),FileListSeparator)
            else
            begin
              StressTenPlotInfo:=StressTenPlotInfo+#$D#$A+FloatToString(LHz,3,0)+' '+
                    FloatToString(Dipdir,3,0)+'/'+FloatToString(Dip,2,0)+' '+
                    FloatToString(Azimuth,3,0)+'/'+FloatToString(Plunge,2,0)+' '+GetSenseAsString(Sense)+' '+
                    FloatToString(RadToDeg(divergence),2,0)+' ';
              With SFFluMohrFPLData^[LHZ-1] do
              begin
                FMDipDir:=DipDir;
                FMDip:=Dip;
                FMSense:=Sense;
                FMFluctuation:=Round(RadToDeg(Divergence));
              end;
            end; //if not writetofile
            IF shear>PI/2 THEN
            begin
              If WriteToFile then write(g, FloatToString(180-RadToDeg(shear),2,0))
              else StressTenPlotInfo:=StressTenPlotInfo+FloatToString(180-RadToDeg(shear),2,0);
              if sensemissing and (self is tndaplot) then
              begin
                If WriteToFile then write(g, FileListSeparator,' skipped')
                else StressTenPlotInfo:=StressTenPlotInfo+' '+'skipped';
                inc(nosense);
              END
              else if sensemissing then
              begin
                If WriteToFile then write(g, FileListSeparator,' *')
                else StressTenPlotInfo:=StressTenPlotInfo+' '+'*';
                inc(nosense);
              END
            END
            else
            begin  //negative expected value
              If WriteToFile then write(g, FloatToString(RadToDeg(shear),2,0))
              else StressTenPlotInfo:=StressTenPlotInfo+FloatToString(RadToDeg(shear),2,0);
              IF SenseMissing and (self is tndaplot) THEN
              begin
                If WriteToFile then write(g, FileListSeparator,' skipped')
                else StressTenPlotInfo:=StressTenPlotInfo+' skipped';
                Inc(nosense);
              END
              ELSE
              begin
                if sensemissing then
                begin
                  If WriteToFile then write(g, FileListSeparator,' * ')
                  else StressTenPlotInfo:=StressTenPlotInfo+FileListSeparator+' * ';
                  Inc(nosense);
                END;
                If WriteToFile then write(g, FileListSeparator,' nev')
                else StressTenPlotInfo:=StressTenPlotInfo+' '+'nev';
                Inc(nev);
              end;
            end;
            If WriteToFile then writeln(g);
          end else if not NoComment then dec(LHZ);
        end; //end of while-loop
      end else failed:=true;
    If not failed then
    begin
      //inc(LHZ);
      If WriteToFile then
      begin
        Case ExtractExtension(Filename2) of
          INV: Stringdummy:='Sigma';
          else Stringdummy:='Lambda';
        end;
        For z:=1 to 3 do
            writeln(g, Stringdummy,IntToStr(z),'= ',FloatToString(bearingps[z],3,2),FileListSeparator,FloatToString(plungeps[z],2,2));
        Case ExtractExtension(Filename2) of
          INV: Writeln(g, 'Stress ratio= ',rstr);
          else Writeln(g, 'Strain ratio= ',rstr);
        end;
      end;
      fluctuation:= fluctuation/(LHZ-nosense);
      IF (LHZ-nosense)>0 THEN percentnev:= nev*100/(LHZ-nosense)
      ELSE percentnev:=0;
      IF percentnev>50 THEN reverse:= 1 ELSE reverse:= -1;
      Str(fluctuation:2:1, fstr);
      If WriteToFile then
      begin
        writeln(g,'Fluctuation= ',fstr,' degree');
        writeln(g,'Negative expected values= ',nev,' (',Round(nev*100/(LHZ-nosense)),'% of ',(LHZ-nosense),')');
        If self is tndaplot then writeln(g,'Datasets skipped= ', Nosense)
        else writeln(g,'Sense substituted=', Nosense);
        write(g, 'Datasets total= ', LHZ);
        Result:=true;
        closeFile(g);
      end;
      //else skipped:=nosense;
      closeFile(F);
      Screen.Cursor:=crDefault;
      If WriteToFile then TecMainWin.WriteToStatusbar(nil ,'Written to file '+FileName2);
    end
    else
    begin
      Screen.Cursor:=crDefault;
      closeFile(F);
      If WriteToFile then closeFile(g);
    end;
    except   {can not write to file}
    On EInOutError do
    begin
      GlobalFailed:=True;
      Screen.Cursor:=crDefault;
      MessageDlg('Can not write to '+Filename2+' !'#10#13+
                 'Processing stopped. File might be in use by another application.',
                 mtError,[mbOk], 0);
      exit;
    end;
  end;
  END;

procedure TInversPlot.FormCreate(Sender: TObject; const AFilename: String; const AExtension: TExtension);
var A,B,c,d,e,f,g,h,i,j,k,l,m,n,f1,f2,f3,s1,s2,s3,o1,o2,o3,
    y1,y2,y3,y4,y5,p1,p2,p3,p4,p5,p6,p7,p8,p9,q1,q2,q3,q4,q5,
    us,vs,ws,p,q,alpha,pitch, dumy: double;
    DipDir, Dip, Azimuth, Plunge, dummy: Single;
    fn: Textfile;
    Sense, Quality,s,reverse,y,z1,z2,intdumy, nosense: Integer;
    Psi,u,v,w: array[1..2] of double;
    fluctuation: array[1..2] of single;
    magnitudePS: array[1..3] of double;
    ev,om : array[1..3,1..3] of double;
    comment: String;

begin
  LHExtension:=AExtension;
  LHFilename:=AFilename;
  SaveAs1.Visible:=true;
  SaveAs1.enabled:=true;
  SaveAs1.OnClick:=SaveAs1Click;
  TecMainWin.SaveBtn.Enabled:=true;
  skipped:=0;
  A:=0;
  B:=0;
  c:=0;
  d:=0;
  E:=0;
  f:=0;
  g:=0;
  h:=0;
  I:=0;
  J:=0;
  k:=0;
  l:=0;
  m:=0;
  n:=0;
  LHfailed:=false;
  try
    AssignFile(fn, LHFilename);
    Reset(fn);
    if not LHfailed then lhz := 0;
    Screen.Cursor := CrHourGlass;
    if not eof(fn) then
    begin
      nosense:=0;
      while not Eof(fn) do
      begin
        if LHExtension = PTF then
           ReadPTFDataset(fn,Sense,Quality,DipDir,Dip,Azimuth,Plunge,
                  dummy,dummy,dummy,dummy,dummy,dummy,dummy, intdumy,LHfailed, LHNoComment)
          else
           ReadFPLDataset(fn, Sense, Quality, DipDir, Dip, Azimuth, Plunge, LHfailed, LHNoComment, LHExtension, Comment);
        if not LHfailed and LHNoComment then
        begin
          If not eof(fn) then Inc(lhz);
          IF dip=90 THEN dip:=89.99;
          IF plunge=0 THEN plunge:=0.01;
          IF (Azimuth-DipDir=270) or (Azimuth-DipDir=-90)  THEN Azimuth:=Azimuth+0.01
          else IF (Azimuth-DipDir=-270) or (Azimuth-DipDir=90) THEN Azimuth:=Azimuth-0.01;
          Pitch := ArcTan2((TAN(DegToRad(Azimuth)-DegToRad(DipDir)-PI/2)),COS(DegToRad(plunge)));
          Sense:= ConvertSense(Sense, Pitch);
          If Sense=2 then Sense:= -1
          else If (sense=0) or (sense=5) then
          begin
            inc(nosense);
            sense:=1;
          end;
          //If (Sense<>0) and (Sense<>5) then     //bugfix 981203: take all datasets
          //begin
            polcar (DipDir,(dip-90),f1,f2,f3);
            polcar (Azimuth, plunge,s1,s2,s3);
            s1 := -sense * s1;
            s2 := -sense * s2;
            s3 := -sense * s3;
            o1:=f2*s3-f3*s2;
            o2:=f3*s1-f1*s3;
            o3:=f1*s2-f2*s1;
            y1:=o1*f2+o2*f1;
            y2:=o1*f3+o3*f1;
            y3:=o2*f3+o3*f2;
            y4:=SQRt(3)*(o3*f3-o2*f2);
            y5:=2*o1*f1-o2*f2-o3*f3;
            A:=A+2*Sqr(y1);
            B:=B+2*Sqr(y2);
            c:=c+2*Sqr(y3);
            d:=d+2*y1*y2;
            E:=E+2*y1*y3;
            f:=f+2*y2*y3;
            g:=g+y1*y5;
            h:=h+y2*y5;
            I:=I+y3*y5;
            J:=J+y1*y4;
            k:=k+y2*y4;
            l:=l+y3*y4;
            m:=m+0.5*y4*y5;
            n:=n+0.5*(Sqr(y4)-Sqr(y5));
          //end else inc(nosense);
        end else if not LHNoComment then Dec(LHz);
      end;
    end else LHfailed:=true;
    closefile(fn);
  except   //can not open file
    On EInOutError do
    begin
      GlobalFailed:=True;
      Screen.Cursor:=crDefault;
      MessageDlg('Can not open '+LHFilename+' !'#10#13+
                 'Processing stopped. File might be in use by another application.',
                 mtError,[mbOk], 0);
      Close;
      Exit;
    end;
  end;
  If LHz<3 then //at least 4 datasets are needed.
  begin
    GlobalFailed:=True;
    Screen.Cursor:=crDefault;
    MessageDlg('At least 4 datasets are needed for this operation!'#10#13+
               'Processing stopped.', mtError,[mbOk], 0);
    Close;
    Exit;
  end;
  If not LHfailed then
  begin
    ndatasets:=lhz+1;
    p1:=d*E-A*f;
    p2:=A*B-d*d;
    p3:=E*E-A*c ;
    p4:=d*g-A*h; //*
    p5:=d*J-A*k; //*
    p6:=E*g-A*I; //*
    p7:=E*J-A*l;
    p8:=A*n-J*J+g*g;
    p9:=A*m-g*J;
    q1:=0.5*(p2*p8+p4*p4-p5*p5);
    q2:=p2*p9-p4*p5;
    q3:=p1*p4+p2*p6;  //*
    q4:=p1*p5+p2*p7;  //*
    q5:=p1*p1+p2*p3;
    Dummy:=q1*q5-0.5*q3*q3+0.5*q4*q4;
    If  Dummy=0 then
    begin
      GlobalFailed:=True;
      Screen.Cursor:=crDefault;
      MessageDlg('At least 4 differing datasets are needed for this operation!'#10#13+
               'Processing stopped.', mtError,[mbOk], 0);
      Close;
      Exit;
    end;
    Psi[1]:=0.5*ArcTan((-q2*q5-q3*q4)/(q1*q5-0.5*q3*q3+0.5*q4*q4));
    Psi[2]:=Psi[1]+PI/2;
    FOR s:=1 TO 2 do
    begin
      w[s] := (-q3*COS(Psi[s])-q4*SIN(Psi[s]))/q5;
      v[s] := (p1*W[s]+p4*COS(Psi[s])+p5*SIN(Psi[s]))/p2;
      u[s] := (-d*V[s]-E*W[s]-g*COS(Psi[s])-J*SIN(Psi[s]))/A;
      ws := COS(Psi[s]);
      vs :=COS(Psi[s]+2*PI/3);
      us :=COS(Psi[s]+4*PI/3);
      stt11:=ws;
      stt22:=vs;
      stt33:=us;
      stt12:=u[s];
      stt13:=v[s];
      stt23:=w[s];
      calcfluct2(reverse,fluctuation[s]);
    end;
    IF fluctuation[1] < fluctuation[2] THEN s:=1 ELSE s:=2;
    stt11:=COS(Psi[s]);
    stt22:=COS(Psi[s]+2*PI/3);
    stt33:=COS(Psi[s]+4*PI/3);
    stt12:=u[s];
    stt13:=V[s];
    stt23:=W[s];
    calcfluct2(reverse,fluctuation[1]);
    IF reverse = 1 THEN
    begin
      stt11:=-stt11;
      stt22:=-stt22;
      stt33:=-stt33;
      stt12:=-stt12;
      stt13:=-stt13;
      stt23:=-stt23;
    END;
    p:=-(0.75+Sqr(stt12)+Sqr(stt13)+Sqr(stt23));
    q:=stt11*Sqr(stt23)+stt22*Sqr(stt13)+stt33*Sqr(stt12)-2*stt12*stt13*stt23-stt11*stt22*stt33;
    alpha:=ArcCos(-SQRt(27)/2*q/SQRt(-p*p*p))/3;
    magnitudePS[1]:= 2*SQRt(-p/3)*COS(alpha);
    magnitudePS[2]:=-2*SQRt(-p/3)*COS(alpha-PI/3);
    magnitudePS[3]:=-2*SQRt(-p/3)*COS(alpha+PI/3);
    FOR y:=1 TO 3 do
    begin
      om[y,1]:=stt11-magnitudePS[y];
      om[y,2]:=stt22-magnitudePS[y];
      om[y,3]:=stt33-magnitudePS[y];
      ev[y,3]:=-1 ;
      ev[y,2]:=(stt12*stt13-om[y,1]*stt23)/(Sqr(stt12)-om[y,1]*om[y,2]);
      ev[y,1]:=(stt13-stt12*ev[y,2])/om[y,1];
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
    FOR z1 := 1 TO 2 do
    begin
      FOR z2 := 1 TO (3-z1) do
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
        END;
      end;
    end;
    stressratio := (magnitudePS[2]-magnitudePS[3])/(magnitudePS[1]-magnitudePS[3]);
    calcfluct(stt11,stt22,stt33,stt12,stt13,stt23,LHFilename, LHExtension, LHFilename,TensAzimuth,TensPlunge,rstr,false, Skipped, negative);
    inherited;
    Screen.Cursor := CrDefault;
  end
  else
  begin
    Screen.Cursor := CrDefault;
    MessageDlg('Error reading '+ExtractFilename(LHFilename)+' in Line '+IntToStr(LHZ+1)+'!'+#10#13+' Processing stopped.',
               mtError,[mbOk], 0);
  end;
end;

procedure TInversPlot.calcfluct2 (var reverse: integer;var fluctuation: single);
var Sensestr : TString4;
    F: TextFile;
    Sense, Quality,nosense,n, nev, intdumy : Integer;
    f1,f2,f3,s1,s2,s3, o1,o2,o3, sv1, sv2, sv3: double;
    divergence, percentnev,shear, pitch, DipDir, Dip, Azimuth, Plunge, dumy: single;
    failed, NoComment : boolean;
    comment: String;

begin
  failed:=false;
  fluctuation:=0;
  nev:=0;
  nosense:=0;
  N := 0;
  AssignFile(F, LHFileName);
  try
    Reset(F);
    if not eof(f) then
    begin
      while not Eof(F) and not failed do
      begin
        if LHExtension = PTF then
           ReadPTFDataset(f,Sense,Quality,DipDir,Dip,Azimuth,Plunge,
                  dumy,dumy,dumy,dumy,dumy,dumy,dumy, intdumy,failed,NoComment)
          else
           ReadFPLDataset(f, Sense, Quality, DipDir, Dip, Azimuth, Plunge, failed, NoComment, LHExtension, comment);
        if not failed and NoComment then
        begin
          If not eof(f) then Inc(n);
          IF dip=90 THEN dip:=89;
          IF plunge=0 THEN plunge:=1;
          IF (Azimuth-DipDir=270) or (Azimuth-DipDir=-90)  THEN Azimuth:=Azimuth+0.1
          else IF (Azimuth-DipDir=-270) or (Azimuth-DipDir=90) THEN Azimuth:=Azimuth-0.1;
          Pitch:= ArcTan((Tan(DegToRad(Azimuth)-DegToRad(DipDir)-PI/2))/COS(DegToRad(plunge)));
          If (sense=0) or (sense=5) then
          begin
            inc(nosense);
            Sense:=1 //set sense to 1 for bivalent datasets
          end
          else Sense:= ConvertSense(Sense, Pitch);
          Case Sense of
            1: sensestr:='+';
            2: begin
              sense := -1;
              sensestr:='-';
            end;
          end;
          //If (sense <> s_hugounknown) and (sense <> s_unknown) then
          //begin
            polcar(DipDir,(dip-90),f1,f2,f3);
            polcar(Azimuth, plunge,s1,s2,s3);
            s1:= -Sense * s1;
            s2:= -Sense * s2;
            s3:= -Sense * s3;
            o1:=f2*s3-f3*s2;
            o2:=f3*s1-f1*s3;
            o3:=f1*s2-f2*s1;
            sv1:=f1*stt11+f2*stt12+f3*stt13;
            sv2:=f1*stt12+f2*stt22+f3*stt23;
            sv3:=f1*stt13+f2*stt23+f3*stt33;
            divergence:=ArcCos((o1*sv1+o2*sv2+o3*sv3)/SQRt(Sqr(sv1)+Sqr(sv2)+Sqr(sv3)));
            IF divergence < PI/2 THEN divergence:= PI/2 - divergence
            ELSE divergence:= divergence - PI/2;
            shear:= ArcCos((s1*sv1+s2*sv2+s3*sv3)/SQRt(Sqr(sv1)+Sqr(sv2)+Sqr(sv3)));
            IF shear<PI/2 THEN Inc(nev)
            ELSE
              fluctuation:= fluctuation + RadToDeg(divergence);
          //end else inc(nosense);
        end else if not NoComment then dec(n);
      end; {end of while-loop}
      If not failed then
      begin
        inc(n);
        fluctuation:= fluctuation/(n-nosense);
        IF (n-nosense)>0 THEN percentnev:= nev*100/(n-nosense)
        ELSE percentnev:=0;
        IF percentnev>50 THEN reverse:= 1 ELSE reverse:= -1;
      end;
    end;
    closeFile(F);
  except   {can not open file}
    On EInOutError do
    begin
      GlobalFailed:=True;
      Screen.Cursor:=crDefault;
      MessageDlg('Can not open '+LHFilename+' !'#10#13+
                 'Processing stopped. File might be in use by another application.',
                 mtError,[mbOk], 0);
      exit;
    end;
  end;
END;

procedure TInversPlot.SaveAs1Click(Sender: TObject);
var written, saveflag, exitflag: boolean;
begin
  SaveDialog1:=TSaveDialog.Create(Self);
  With SaveDialog1 do
  begin
    Filter:='Invers files (*.inv)|*.inv|All files (*.*)|*.*';
    Options:=[ofHideReadOnly];
    Title:='Save invers file as';
    Filename:=ChangeFileExt(LHFileName, '.inv');
  end;
  repeat
    Saveflag:= SaveDialog1.Execute;
    if saveflag then
    begin
      Case SaveDialog1.FilterIndex of
        1: SaveDialog1.FileName := ChangeFileExt(SaveDialog1.FileName,'.inv');
      end;
      If FileExists(SaveDialog1.Filename) then
      Case MessageDlg('File '+SaveDialog1.Filename+' already exists! Overwrite?', mtWarning,[mbOk,mbCancel, mbRetry], 0) of
        mrRetry: Exitflag:=false;
        mrCancel: exit;
        mrOK: Exitflag:=true;
      end else exitflag:=true;
    end else exitflag:=true;
  until exitflag;
  Str(stressratio:2:4, rstr);
  If saveflag then
    written:=calcfluct(stt11,stt22,stt33,stt12,stt13,stt23,LHFilename, LHExtension, SaveDialog1.Filename,TensAzimuth,TensPlunge,rstr,true, skipped, negative);
  SaveDialog1.free;
end;

end.
