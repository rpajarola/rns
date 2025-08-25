{$I RNS.H}

Unit grintunit;

Interface

Uses menutyp,
    graphmenu,
    grinout,
    imenuunit,
    initsc,
    getunit,
    dos,
    graph,
    crt,
    pageunit,
    HelpUnit,
    fileunit;

Procedure GriBeatMenuDisp(linenum: integer);

Implementation

{******************************************************}
(*Procedure GriBeatMenuDisp(linenum: integer;var startptr, lastptr : listptr);

var c : char;
    Bufstr : string79;
    i, j, y, hy : integer;
    inblock, bufline : stringline;
    lineattr,tempattr: lineattrtype;
    a : byte;
    b,g,r : Integer;
    bc,ec,rc,lc : Boolean;
    s1,s2,s3,s4,s5,s6 : String[10];
    ok : boolean;
    lines,linee,pages,pagee : integer;
    bufactptr,bufstartptr,bufendptr : listptr;
    tempbuffer : stringline;
    tbufpos : byte;
    endreached : boolean;
begin
  ImeInitBeatMenu;
  With UsrMenu do begin
    if page[linenum, 1] = 'N' then begin
      inblock:= page[linenum];
      GetNoteBlock(inblock, lineattr, linenum);
    end else begin
{      insmusicline:= 'N           1 0 480 3 %.1.';}
      inblock:=insmusicline;
      GetNoteBlock(inblock, lineattr, 0);
    end;

    ChoiceVal[1].Ival:= lineattr.beats;
    ChoiceVal[2].Ival:= lineattr.eint;
    ChoiceVal[3].ival:= lineattr.resolution;
    ChoiceVal[4].Ival:= linecount;
    ChoiceVal[5].tval:= lineattr.linestyle;

    b:=lineattr.Beats;
    g:=lineattr.Eint;
    r:=lineattr.resolution;

    y:= grmaxy - (num_choices * spacing +
        menuattr.firstline + 5) * charheight;
    hy:= y div charheight;
    GrDisplay_Frame(grminx, y, grmaxx, grmaxy, true, true);
    GrDisplay_Menu(hfminX, hy, UsrMenu, 0);

    Repeat
      ok:=true;
      SetColor(menutextcolor);
      SetFillstyle(1, menubkcolor);

      GrGet_Menu_Values(hfminx, hy, hfmaxy, UsrMenu, c);

      Tempattr.beats:= ChoiceVal[1].Ival;
      Tempattr.eint:= ChoiceVal[2].Ival;
      Tempattr.resolution:= ChoiceVal[3].Ival;
      linecount:= ChoiceVal[4].Ival;
      Tempattr.linestyle:= ChoiceVal[5].tval;
      bc:=changed[1];
      ec:=changed[2];
      rc:=changed[3];
      lc:=changed[5];
      str(Tempattr.beats,s1);
      str(Tempattr.eint,s2);
      str(Tempattr.resolution,s3);
      s4:=ToggleString[TempAttr.linestyle];
      IniTrailBlank(S4);
      if ((pagebuf<>-1) or (mstart.mpag<>-1)) and
        (mstart.mline<>mend.mline) then begin
        if bc then begin
          case HlpAsk(' Number of beats has been changed to '+s1+'!',
                    ' Change ALL lines? [Y]/[N]. [ESC] to review menu',hpEdit,['Y','N',#13,#27]) of
            'N' : begin
              bc:=false;
              TempAttr.Beats:=LineAttr.Beats;
            end;
            #27 : begin
              continue;
            end;
            #13, 'Y': begin
            end;
          end;{case}
        end;
        if ec then begin
          case HlpAsk(' Number of grids has been changed to '+s2+'!',
                    ' Change ALL lines? [Y]/[N]. [ESC] to review menu',hpEdit,['Y','N',#13,#27]) of
            'N' : begin
              ec:=false;
              TempAttr.eint:=LineAttr.eint;
            end;
            #27 : begin
              continue;
            end;
            #13, 'Y': begin
            end;
          end;{case}
        end;
        if rc then begin
          case HlpAsk(' Resolution has been changed to '+s3+'!',
                    ' Change ALL lines? [Y]/[N]. [ESC] to review menu',hpEdit,['Y','N',#13,#27]) of
            'N' : begin
              rc:=false;
              TempAttr.resolution:=LineAttr.resolution;
            end;
            #27 : begin
              continue;
            end;
            #13, 'Y': begin
            end;
          end;{case}
        end;
        if lc then begin
          case HlpAsk(' Linestyle has been changed to '+s4+'!',
                    ' Change ALL lines? [Y]/[N]. [ESC] to review menu',hpEdit,['Y','N',#13,#27]) of
            'N' : begin
              lc:=false;
              TempAttr.linestyle:=LineAttr.linestyle;
            end;
            #27 : begin
              continue;
            end;
            #13, 'Y': begin
            end;
          end;{case}
        end;

      end;
      if ((TempAttr.resolution mod TempAttr.Beats)<>0) And ((rc) or (bc)) then begin
      { Beats/Resolution don't match and were changed }
        str(Tempattr.resolution,s1);
        str(Tempattr.beats,s2);
        str(Tempattr.resolution div Tempattr.beats,s3);
        str(Tempattr.resolution mod Tempattr.beats,s4);
        case hlpAsk('Division with rest (Resolution:Beats)  '+s1+':'+s2+'='+
                        s3+', REST '+s4,
                    'Press [Y] to accept, [N] to abandon changes, [Esc] to review menu',hpEdit,
                    ['Y','N',#27]) of
          'Y' : begin
            lineattr.beats:=tempattr.beats;
            lineattr.Resolution:=tempattr.resolution;
            ok:=True;
          end;
          'N' : ok:=True;
          #27 : ok:=False;
        end;{case}
      end else begin
        lineattr.beats:=tempattr.beats;
        lineattr.resolution:=tempattr.resolution;
      end;
      if (tempattr.eint>((tempattr.resolution div tempattr.beats) div 2)) and
        ((ec) or (rc) or (bc)) then begin
        str(lineattr.eint,s5);
        str((lineattr.resolution div lineattr.beats) div 2,s6);
        case HlpAsk('Not enough space to display '+s5+
                        ' grids: choose between 0 and '+s6+'.',
                    'Press [Y] to accept, [N] to abandon changes, [Esc] to review menu',hpEdit,
                    ['Y','N',#27]) of
          'Y' : begin
            lineattr.beats:=tempattr.beats;
            lineattr.Resolution:=tempattr.resolution;
            lineattr.eint:=tempattr.eint;
            ok:=True;
          end;
          'N' : ok:=True;
          #27 : ok:=False;
        end;{case}
      end else begin
        lineattr.eint:=tempattr.eint;
      end;
      lineattr.linestyle:=tempattr.linestyle;
    Until ok;

    actattr:= lineattr;

    lines:=MStart.MLine;
    linee:=Mend.MLine;
    pages:=MStart.MPag;
    pagee:=MEnd.MPag;
    a:=linenum;
    if pagebuf<>-1 then begin
      lines:=1;
      linee:=pagelength;
      pages:=pagebuf;
      pagee:=pagebuf;
    end;
    FilFindPtr(pages,lines, bufstartptr, startptr, lastptr,false);
    FilFindPtr(pagee,linee, bufendptr, startptr, lastptr,true);
    bufactptr:=bufstartptr;
    tempbuffer:='';
    tbufpos:=0;
    endreached:=false;
    Repeat
      FilCheckLine(tempbuffer, inblock, bufactptr, startptr, lastptr,
                   tbufpos, endreached, true, true);
      if inblock[1]<> 'N' then
        inblock:= insmusicline;

      bufline:= copy(inblock, 1, linemarker);
      delete(inblock, 1, LineMarker);

      i:=IniNextnumber(inblock);
      if bc then
        str(lineattr.beats:5, BufStr)
      else
        str(i:5,BufStr);
      bufline:= bufline + BufStr;

      i:=IniNextnumber(inblock);
      if ec then
        str(lineattr.eint:5, BufStr)
      else
        str(i:5, BufStr);
      bufline:= bufline + BufStr;

      i:=IniNextnumber(inblock);
      if rc then
        str(lineattr.resolution:5, BufStr)
      else
        str(i:5,BufStr);
      bufline:= bufline + BufStr;

      i:=IniNextnumber(inblock);
      if lc then
        str(lineattr.linestyle:5, BufStr)
      else
        str(i:5,BufStr);
      bufline:= bufline + BufStr;

      bufline:= bufline + inblock;

      if inblock[1]='N' then
        inblock:=bufline
      else
        insmusicline:=bufline;
      FilHeapInsertString(inblock,bufstartptr, bufstartptr,
                  startptr, lastptr, true);
    Until bufstartptr=bufendptr;
    FilHeapSqueeze(bufactptr, startptr, lastptr, true);
    linenum:=a;
  end; {With BeatMenu do}
end;
*)

{******************************************************}
Procedure GriBeatMenuDisp(linenum: integer);

Var c: char;
    Bufstr: string79;
    i, y, hy: integer;
    inblock, bufline: stringline;
    lineattr, tempattr: lineattrtype;
    EndMlineSav,
    StartMlineSav: byte;
    a: byte;
    bc, ec, rc, lc: Boolean;
    s1, s2, s3, s4, s5, s6: String[10];
    ok: boolean;
Begin
    ImeInitBeatMenu;
    With UsrMenu Do
    Begin
        If page[linenum, 1] = 'N' Then
        Begin
            inblock := page[linenum];
            GetNoteBlock (inblock, lineattr, linenum);
        End Else Begin
            {      insmusicline:= 'N           1 0 480 3 %.1.';}
            inblock := insmusicline;
            GetNoteBlock (inblock, lineattr, 0);
        End;

        ChoiceVal[1].Ival := lineattr.beats;
        ChoiceVal[2].Ival := lineattr.eint;
        ChoiceVal[3].ival := lineattr.resolution;
        ChoiceVal[4].Ival := linecount;
        ChoiceVal[5].tval := lineattr.linestyle;

        For y := 1 To num_choices Do
            changed[y] := false;
        y := grmaxy - (num_choices * spacing +
            menuattr.firstline + 5) * charheight;
        hy := y DIV charheight;
        Repeat
            ok := true;
            SetColor (menutextcolor);
            SetFillstyle (1, menubkcolor);
            GrDisplay_Frame (grminx, y, grmaxx, grmaxy, true, true);
            GrDisplay_Menu (hfminX, hy, UsrMenu, 0);

            GrGet_Menu_Values (hfminx, hy, hfmaxy, UsrMenu, c);

            Tempattr.beats := ChoiceVal[1].Ival;
            Tempattr.eint := ChoiceVal[2].Ival;
            Tempattr.resolution := ChoiceVal[3].Ival;
            linecount := ChoiceVal[4].Ival;
            Tempattr.linestyle := ChoiceVal[5].tval;
            bc := changed[1];
            ec := changed[2];
            rc := changed[3];
            lc := changed[5];
            str (Tempattr.beats, s1);
            str (Tempattr.eint, s2);
            str (Tempattr.resolution, s3);
            s4 := ToggleString[TempAttr.linestyle];
            IniTrailBlank (S4);
            If ((pagebuf <> -1) OR (mstart.mpag <> -1)) AND
                (mstart.mline <> mend.mline) Then
            Begin
                If bc Then
                    Case HlpAsk (' Number of beats has been changed to ' + s1 + '!',
                            ' Change ALL lines? [Y]/[N]. [ESC] to review menu', hpEdit, ['Y', 'N', #13, #27]) Of
                        'N':
                        Begin
                            bc := false;
                            TempAttr.Beats := LineAttr.Beats;
                        End;
                        #27:
                        Begin
                            ok := False;
                            TempAttr.Beats := LineAttr.Beats;
                            ChoiceVal[1].Ival := TempAttr.Beats;
                            changed[1] := false;
                        End;
                        #13, 'Y': ;
                    End{case};
                If ec Then
                    Case HlpAsk (' Number of grids has been changed to ' + s2 + '!',
                            ' Change ALL lines? [Y]/[N]. [ESC] to review menu', hpEdit, ['Y', 'N', #13, #27]) Of
                        'N':
                        Begin
                            ec := false;
                            TempAttr.eint := LineAttr.eint;
                        End;
                        #27:
                        Begin
                            ok := False;
                            TempAttr.eint := LineAttr.eint;
                            ChoiceVal[2].Ival := TempAttr.eint;
                            changed[2] := false;
                        End;
                        #13, 'Y': ;
                    End{case};
                If rc Then
                    Case HlpAsk (' Resolution has been changed to ' + s3 + '!',
                            ' Change ALL lines? [Y]/[N]. [ESC] to review menu', hpEdit, ['Y', 'N', #13, #27]) Of
                        'N':
                        Begin
                            rc := false;
                            TempAttr.resolution := LineAttr.resolution;
                        End;
                        #27:
                        Begin
                            ok := False;
                            TempAttr.resolution := LineAttr.resolution;
                            ChoiceVal[3].Ival := TempAttr.resolution;
                            changed[3] := false;
                        End;
                        #13, 'Y': ;
                    End{case};
                If lc Then
                    Case HlpAsk (' Linestyle has been changed to ' + s4 + '!',
                            ' Change ALL lines? [Y]/[N]. [ESC] to review menu', hpEdit, ['Y', 'N', #13, #27]) Of
                        'N':
                        Begin
                            lc := false;
                            TempAttr.linestyle := LineAttr.linestyle;
                        End;
                        #27:
                        Begin
                            ok := False;
                            TempAttr.linestyle := LineAttr.linestyle;
                            ChoiceVal[5].tval := TempAttr.linestyle;
                            changed[5] := false;
                        End;
                        #13, 'Y': ;
                    End{case};

            End;
            If ((TempAttr.resolution MOD TempAttr.Beats) <> 0) AND ((rc) OR (bc)) Then
            Begin
                { Beats/Resolution don't match and were changed }
                str (Tempattr.resolution, s1);
                str (Tempattr.beats, s2);
                str (Tempattr.resolution DIV Tempattr.beats, s3);
                str (Tempattr.resolution MOD Tempattr.beats, s4);
                Case hlpAsk ('Division with rest (Resolution:Beats)  ' + s1 + ':' + s2 + '=' +
                        s3 + ', REST ' + s4,
                        'Press [Y] to accept, [N] to abandon changes, [Esc] to review menu', hpEdit,
                        ['Y', 'N', #27]) Of
                    'Y':
                    Begin
                        lineattr.beats := tempattr.beats;
                        lineattr.Resolution := tempattr.resolution;
                        ok := True;
                    End;
                    'N': ok := True;
                    #27:
                    Begin
                        ok := False;
                        lineattr.beats := tempattr.beats;
                        lineattr.Resolution := tempattr.resolution;
                        ChoiceVal[1].Ival := lineattr.beats;
                        ChoiceVal[3].Ival := lineattr.Resolution;
                        changed[1] := false;
                        changed[3] := false;
                    End;
                End;{case}
            End Else Begin
                lineattr.beats := tempattr.beats;
                lineattr.resolution := tempattr.resolution;
            End;
            If (tempattr.eint > ((tempattr.resolution DIV tempattr.beats) DIV 2)) AND
                ((ec) OR (rc) OR (bc)) Then
            Begin
                str (tempattr.eint, s5);
                str ((tempattr.resolution DIV tempattr.beats) DIV 2, s6);
                Case HlpAsk ('Not enough space to display ' + s5 +
                        ' grids: choose between 0 and ' + s6 + '.',
                        'Press [Y] to accept, [N] to abandon changes, [Esc] to review menu', hpEdit,
                        ['Y', 'N', #27]) Of
                    'Y':
                    Begin
                        lineattr.beats := tempattr.beats;
                        lineattr.Resolution := tempattr.resolution;
                        lineattr.eint := tempattr.eint;
                        ok := True;
                    End;
                    'N': ok := True;
                    #27:
                    Begin
                        ok := False;
                        lineattr.beats := tempattr.beats;
                        lineattr.Resolution := tempattr.resolution;
                        lineattr.eint := tempattr.eint;
                        ChoiceVal[1].Ival := lineattr.beats;
                        ChoiceVal[3].Ival := lineattr.Resolution;
                        ChoiceVal[2].Ival := lineattr.eint;
                        bc := changed[1];
                        ec := changed[2];
                        rc := changed[3];
                    End;
                End;{case}
            End Else lineattr.eint := tempattr.eint;
            lineattr.linestyle := tempattr.linestyle;
        Until ok;

        actattr := lineattr;

        StartMlineSav := MStart.MLine;
        EndMlineSav := Mend.MLine;
        a := linenum;
        If (mstart.mpag <> pagecount) OR (mend.mpag <> pagecount) Then
        Begin
            StartMlineSav := linenum;
            EndMlineSav := linenum;
        End;
        If pagebuf <> -1 Then
        Begin
            StartMlineSav := 1;
            EndMLineSav := pagelength;
        End;
        For linenum := StartMlineSav To EndMlineSav Do
        Begin
            If page[linenum, 1] = 'N' Then inblock := Page[linenum] Else inblock := insmusicline;

            bufline := copy (inblock, 1, linemarker);
            delete (inblock, 1, LineMarker);

            i := IniNextnumber (inblock);
            If bc Then
                str (lineattr.beats: 5, BufStr)
            Else
                str (i: 5, BufStr);
            bufline := bufline + BufStr;

            i := IniNextnumber (inblock);
            If ec Then
                str (lineattr.eint: 5, BufStr)
            Else
                str (i: 5, BufStr);
            bufline := bufline + BufStr;

            i := IniNextnumber (inblock);
            If rc Then
                str (lineattr.resolution: 5, BufStr)
            Else
                str (i: 5, BufStr);
            bufline := bufline + BufStr;

            i := IniNextnumber (inblock);
            If lc Then
                str (lineattr.linestyle: 5, BufStr)
            Else
                str (i: 5, BufStr);
            bufline := bufline + BufStr;

            bufline := bufline + inblock;

            If page[linenum, 1] = 'N' Then
                Page[linenum] := bufline
            Else
                insmusicline  := bufline;
        End;{For MEnd.MLine Downto MStart.MLine Do}
        linenum := a;
        If startmlinesav <> endmlinesav Then pagunmark;
    End; {With BeatMenu do}
End;
End.
