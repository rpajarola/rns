{$I RNS.H}

Unit sndunit;

Interface

Uses initsc;

Procedure SndSoundMenu(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    Menu: boolean);
Procedure SndPlaySound(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    Menu: boolean; Var Playnext: Boolean);

Procedure SndUpdateAddCent;
Procedure SndUpdateMulCent;
Function SndGetCentStr(C: Integer): String;

Implementation

Uses
    imenuunit,
    getunit,
    pageunit,
    menutyp,
    graphmenu,
    crt,
    xcrt,
    helpunit,
    utilunit,
    fileunit,
    graph,
    DOS,
    gcurunit,
    comunit,
    Texts,
    Mousdrv,
    Specunit,
    MarkUnit;

Const cfllength = 30;
    itemmax = 10;

Type itemcharstyp = Array[1..itemmax] Of Record
        length, pitch: integer;
    End;
Const  M = 1731.23404905852;

{******************************************************************}

Procedure SndUpdateAddCent;
Begin
  {$R-}
    If mulcent > 0 Then
        AddCent := Round ((ln (mulcent) * M));
    If addcent >{7973}6000 Then
    Begin
        addcent := 6000;
        mulCent := (exp (AddCent / M));
    End;
    If addcent < -6000 Then
    Begin
        addcent := -6000;
        mulCent := (exp (AddCent / M));
    End;
  {$IFNDEF USER}
  {$R+}
  {$ENDIF}
End;
{******************************************************************}

Procedure SndUpdateMulCent;
Begin
  {$R-}
    mulCent := (exp (AddCent / M));
    If mulcent > 32.0 Then
    Begin
        mulcent := 32;
        AddCent := 6000;
    End;
    If mulcent < 0.03125 Then
    Begin
        mulcent := 0.03125;
        AddCent := -6000;
    End;
  {$IFNDEF USER}
  {$R+}
  {$ENDIF}
End;

{******************************************************************}
Procedure SndDraw(Var slinexmin, slinexmax, y: longint; Var wait: boolean);
Var sslinexmin, sslinexmax: integer;
Begin
    sslinexmax := slinexmax;
    sslinexmin := slinexmax;
    If slinexmax > 638 Then
        slinexmax := 638;
    If wait Then
    Begin
        Line (slinexmin, y, slinexmax, y);
        Line (slinexmin, y + 1, slinexmax, y + 1);
    End;
    slinexmin := sslinexmin;
    slinexmax := sslinexmax;
End;

{******************************************************************}
Procedure SndPlay(Var itemchars: itemcharstyp;
    itemcount, timemax: integer; Var wait: Boolean; Playlast: boolean);
Var item, totlength, i: integer;
    r: real;
    idel, isnd: integer;
    mintime: integer;
    def: integer;

    Procedure XSound(v: integer; m: real);
    Begin
{$R-}
        If v <> sndbeat Then
            sound (round (v * m))
        Else
            sound (v);
{$IFNDEF USER}
{$R+}
{$ENDIF}
    End;
Const flamlength = 20;
Begin
    If NOT wait Then
        exit;
    If itemcount < 1 Then
    Begin
        delay (timemax);
        exit;
    End;
    playlast := ((soundattr AND saLegato) <> 0);
    totlength := 0;
    If (soundattr AND saStaccato) <> 0 Then
    Begin
        lastsound := 0;
        playlast  := false;
        For i := 1 To itemcount Do
            If itemchars[i].length > staccatolength Then
                itemchars[i].length := staccatolength;
    End;
    If (soundchange AND saMuffled) <> 0 Then
    Begin
        lastsound := 0;
        playlast  := false;
        For i := 1 To itemcount Do
            If itemchars[i].length > muffledlength Then
                itemchars[i].length := muffledlength;
    End;
    { count total length }
    For item := 1 To itemcount - 1 Do
    Begin
        If itemchars[item].length > flamlength Then
            itemchars[item].length := flamlength;
        totlength := totlength + itemchars[item].length;
    End;
    totlength := totlength + itemchars[itemcount].length;
    { ... & correct }
    If totlength > timemax Then
    Begin
        i := 0;
        For item := 1 To itemcount Do
        Begin
            r := (itemchars[item].length / totlength);
            itemchars[item].length := round (r * timemax);
            i := i + itemchars[item].length;
        End;
        totlength := i;
    End;
    { set mintime }
    mintime := flamlength * 2;
    def := 0;
    If (itemcount > 0) AND (mintime > (totlength / itemcount)) Then
        mintime := trunc (totlength / itemcount);
    { ...& apply }
    For item := 1 To itemcount Do
        If itemchars[item].length < mintime Then
        Begin
            def := def + mintime - itemchars[item].length;
            itemchars[item].length := mintime;
        End;
    If def > 0 Then
    Begin
        r := def;
        def := round (r / itemcount);
        For item := 1 To itemcount Do
        Begin
            dec (itemchars[item].length, def);
            r := r - def;
        End;
        itemchars[item].length := itemchars[item].length - round (r);
    End;
    { play it }
    totlength := 0;
    For item := 1 To itemcount - 1 Do
    Begin
        isnd := itemchars[item].pitch;
        idel := itemchars[item].length;
        totlength := totlength + idel;
        If ((idel > 0) AND (isnd > 0)) Then
        Begin
    {$R-}
            NoSound;
            XSound (isnd, MulCent);
            If wait Then
                Delay (idel);
        End;
    End;
    If itemcount > 0 Then
    Begin
        isnd := itemchars[itemcount].pitch;
        idel := itemchars[itemcount].length;
        totlength := totlength + idel;
        If ((idel > 0) AND (isnd > 0)) Then
        Begin
    {$R-}
            NoSound;
            XSound (isnd, MulCent);
    {$IFNDEF USER}
    {$R+}
    {$ENDIF}
            If wait Then
                Delay (idel);
            If ((soundattr AND saStaccato) <> 0) AND (NOT playlast) Then
                NoSound;
        End;
        If (idel > 1) AND (isnd > 1) AND (NOT playlast) Then
            NoSound
        Else
        If lastsound <> 0 Then
            XSound (lastsound, MulCent)
        Else
            nosound;
        If wait AND (timemax > totlength) Then
            delay (timemax - totlength);
    End Else If wait Then
    Begin
        If playlast AND (lastsound <> 0) Then
            XSound (lastsound, MulCent)

        Else
            nosound;
        Delay (timemax);
    End;
End;

{******************************************************************}
Procedure SndPlayLine(inblock: stringline; Var linenum: integer;
    drawline: boolean; Var playnext: Boolean; Var C: Char;
    Var SaveSndChar: Char);
{spielt die Zeile inblock}

Const itemmax = 10;

Var lineattr: lineattrtype;
    itemchars, saveitemchars: itemcharstyp;
    itemcount, saveitemcount: integer;
    imenubkcolor: integer;
    i, j, blength: integer;
    timemax: integer;
    indexc, flam: char;
    k: byte;
    found: boolean;
    dx, slinexmin, slinexmax, y: longint;
    rlinexmax, rtime, rlength: real;
    actlength: integer;
    InpC: Char;
    temp1, temp2: Boolean;
    st: String;
    SChanged: Boolean;
    saveslinexmin, Saveslinexmax, SaveY: longint;
    auftakt: Boolean;
    wait: Boolean;
    orginblock: String;
    parentheses: integer;
    brackets: integer;
    braces: integer;
    playlast: boolean;
    leaveout: integer;
    restsndchar: boolean;
    repeatchar: boolean;
    {******************************************************************}
    Procedure SndUpdateSndlength(sndlengthspm: real;
        Var sndlength, actlength: integer;
        Sndlengthper: Byte);
    Var St: String;
    Begin
        sndlength := Round (60000 / sndlengthspm);
        If sndlengthper = 1 Then actlength := sndlength Else
            actlength := sndlength DIV lineattr.beats;
        Str (sndlengthspm: 4: 3, st);
        While Length (st) < 8 Do
            st := ' ' + st;
        IniSpacedText (65, gmaxy DIV charheight - 3, st, frNoFrame);
    End;
    {**************************************}
    Procedure SndIncItemCount;

    Begin
        If itemcount < itemmax Then
            itemcount := itemcount + 1;
    End;

    {**************************************}
    Procedure SndProcItem;
    Var a, b: integer;
    Begin
        k := UtiComputeGroup (inblock[1], indexc);
        { normal sound? }
        If ((k > 0) AND (sympar[indexc, 3, k] > 0)) Then
        Begin
            wait := True;                 { ^frequenz}
            { yes }
            found := true;
            If (((playOptions AND poParentheses) = 0) OR (parentheses <= 0)) AND
                (((playOptions AND poBrackets) <> 0) OR (brackets <= 0)) AND
                (leaveout <> 1) Then
            Begin
                SndIncItemCount;
                itemchars[itemcount].pitch := paggetfreq (inblock[1]);{sympar[indexc, 3, k];}
                If flam <> ' ' Then
                Begin
                    itemchars[itemcount].length := cfllength;
                    flam := ' ';
                End Else Begin
                    itemchars[itemcount].length := sympar[indexc, 4, k];
                End;
                lastsound := itemchars[itemcount].pitch;
                { something special }
            End Else If ((sndplaypulse AND plPulse) <> 0) AND
                ((blength > 0) OR (sndplaybeat = PlayBeatNever) OR
                ((sndplaybeat = PlayBeatEmpty) AND (itemcount = 1))) Then
            Begin
                SndIncItemCount;
                itemchars[itemcount].pitch := sndpulse;
                itemchars[itemcount].length := sndpulselength;
            End;
            If leaveout > 0 Then
                dec (leaveout);
        End Else { if (k > 0) then } Case inblock[1] Of
                '/': inblock := '';
                #189: If ((playOptions AND poDashSlash) = 0) Then
                        If slinexmin < IniFirstBeatPos (lineattr) Then wait := False Else If auftakt Then
                        Begin
                            If ((sndchar = 'L') AND (c <> #27)) Then
                                inblock := '';
                        End Else If NOT ((sndchar = 'L') AND (c <> #27)) Then
                        Begin
                            k := length (orginblock) - length (inblock);
                            For a := commusicStart (orginblock) To k Do
                                If UtiComputeGroup (orginblock[a], indexc) <> 0 Then
                                    inblock := '';
                        End;
                '\': If NOT ((sndchar = 'L') AND (c <> #27)) Then
                    Begin
                        k := length (orginblock) - length (inblock);
                        For a := commusicStart (orginblock) To k Do
                            If UtiComputeGroup (orginblock[a], indexc) <> 0 Then
                                inblock := '';
                    End;{if auftakt Then Begin}{End;}
                ',':
                Begin
                    If leaveout > 0 Then
                        dec (leaveout);
                    If (sndplaypulse AND plPulse) <> 0 Then
                    Begin
                        found := true;
                        SndIncItemCount;
                        itemchars[itemcount].pitch := sndpulse;
                        itemchars[itemcount].length := sndpulselength;
                    End Else found := true;
                End;
                ' ':
                Begin
                    playlast := false;
                    lastsound := 0;
                    nosound;
                    If leaveout > 0 Then
                        dec (leaveout);
                    If (sndplaypulse AND plSpace) <> 0 Then
                    Begin
                        found := true;
                        SndIncItemCount;
                        itemchars[itemcount].pitch := sndpulse;
                        itemchars[itemcount].length := sndpulselength;
                        playlast := true;
                    End Else Begin
                        found := true;
                        playlast := false;
                    End;
                End;
                '+', '-': flam := '-';
                '=': If (braces > 0) OR (inblock[2] = '{') Then
                    Begin
                        If (playOptions AND poBraces) <> 0 Then leaveout := 2 Else Begin
                            leaveout := 1;
                        End;
                    End Else
                        flam := '-';
                '(': inc (parentheses);
                ')': dec (parentheses);
                '[': inc (brackets);
                ']': dec (brackets);
                '{': inc (braces);
                '}': dec (braces);
                '.':
                Begin
                    If leaveout > 0 Then
                        dec (leaveout);
                    If slinexmin < IniFirstBeatPos (lineattr) Then
                    Begin
                        k := 1;
                        While (inblock[k] = '.') OR IniNumChar (inblock[k]) Do
                            Inc (k);
                        If inblock[k] = '�' Then
                            wait := False;
                    End;
                End;
                '&':
                Begin
                    If saveitemcount > itemmax Then
                        saveitemcount := itemmax;
                    For b := 1 To saveitemcount Do
                    Begin
                        If (saveitemchars[b].pitch = sndbeat) AND
                            ((saveitemchars[b].length = 5) OR (saveitemchars[b].length = sndbeatlength)) Then
                            continue;
                        itemchars[itemcount + 1].pitch := saveitemchars[b].pitch;
                        itemchars[itemcount + 1].length := saveitemchars[b].length;
                        SndIncItemCount;
                    End;
                    repeatchar := true;
                End;
            End{case inblock[1]};
        delete (inblock, 1, 1);
    End;

    {*************************************}
    Procedure SndProcBeat;
    { correct rounding errors }
    Begin
        { time max=available time for next sound, blength=elapsed time, actlength=length of beat }
        timemax := timemax + actlength - blength;
        If timemax < 0 Then
            timemax := 0;
    End;
    {*************************************}
    Procedure SndAddBeat;
    { check if beat should be played and add a beat sound if approp.}
    Begin
        If wait Then
            If ((sndplaybeat <> playBeatNever)) AND
                ((sndplaybeat = PlayBeatAlways) OR (blength > actlength) OR
                (inblock[1] = ' ') OR (inblock[1] = ',') OR (inblock[1] = '.')) Then
            Begin
                If (inblock[1] = '.') OR (inblock[1] = ',') OR (blength > actlength) Then
                    playlast := true;
                SndIncItemCount;
                itemchars[itemcount].pitch := sndbeat;
                If playlast AND ((soundattr AND saLegato) <> 0) Then
                    itemchars[itemcount].length := 5
                Else
                    itemchars[itemcount].length := sndbeatlength;
            End;
        { make sure the beat won't eat up the next ones time }
        rlength := rlength - actlength;
        blength := round (rlength);
    End;
    {**************************************}
    Procedure SndDrawPlay;
    Begin
        repeatchar := false;
        slinexmin  := slinexmax;
        rlinexmax  := rlinexmax + (dx * timemax) / (actlength);
        slinexmax  := round (rlinexmax);
        {Testen ob innerhalb der sichtbaren Seite}
        If slinexmin < (IniLineEnd (orginblock)) Then
        Begin
            playlast := playlast OR (inblock[1] = '.') OR (inblock[1] = ',');
            SndPlay (itemchars, itemcount, timemax, wait, playlast);
            PlayLast := false;
            If slinexmin < IniFirstBeatPos (lineattr) Then
                Auftakt := True;
            If drawline {And (Not Paused) } Then SndDraw (slinexmin, slinexmax, y, wait);
        End;
        itemcount := 0;
    End;
    {**************************************}

Begin
    Saveslinexmax := 0;
    repeatchar := false;
    restsndchar := false;
    lastsound := 0;
    parentheses := 0;
    brackets := 0;
    braces := 0;
    leaveout := 0;
    OrgInblock := Inblock;
    auftakt := False;
    Wait := True;
    If ((inblock[1] = 'N') AND (inblock[5] <> 'H') AND (Length (inblock) > 35)) Then
    Begin
        savey := 0;
        PlaySuccess := True;
        rlength := 0;
        flam  := ' ';

        GetNoteAttributes (inblock, lineattr);
        dx := IniDxValue (lineattr);
        slinexmin := IniFirstBeatPos (lineattr) - dx;
        slinexmax := slinexmin;
        rlinexmax := slinexmax;
        If sndlengthper = 1 Then actlength := sndlength Else Begin
            actlength := sndlength DIV lineattr.beats;
        End;
        y := IniYNow (linenum);
        While inblock[1] <> '%' Do delete (inblock, 1, 1);
        delete (inblock, 1, 1);

        {Suche Beginn: 1. Beat oder 1. Vorschlag}
        found := false;
        itemcount := 0;
        playnext := false;
        imenubkcolor := alarmcolor;   {funktioniert nicht!!!}
        IniSpacedText (20, gmaxy DIV charheight - 1, sndgetcentstr (addcent), frLow);
        If (length (inblock) > 0) AND (NOT (ininumchar (inblock[1]) OR
            (inblock[1] = '.'))) Then
        Begin
            blength := 0;
            SndAddBeat;
            rlength := 0;
            blength := 0;
        End;

        While ((NOT found) AND (length (inblock) > 0)) Do
        Begin
            playlast := false;
            SChanged := False;
            While xKeyPressed Do
            Begin
                InpC := XReadKey (temp1, temp2);
                Case UpCase (InpC) Of
                    #27: If NOT temp2 Then
                        Begin
                            c := #27;
                            PlayNext := False;
                            If NOT temp1 Then
                            Begin
                                SndUpdateSndLength (sndlengthspm, sndlength, actlength, sndlengthper);
                                nosound;
                                Exit;
                            End Else
                            If NOT paused Then
                            Begin
                                i := imenubkcolor;
                                imenubkcolor := alarmbkcolor;
                                IniSpacedText (2, gmaxy DIV charheight - 1,
                                    '  Finishing line ', frLow);
                                imenubkcolor := i;
                            End Else
                                c := #0;
                        End;
                    #13:
                    Begin{Enter}
                        IniSpacedText (12, gmaxy DIV charheight - 5,
                            'pause  ', frNoFrame);
                        c := #27;
                        PlayNext := True;
                        Inc (Linenum);
                        paused := False;
                        nosound;
                        Exit;
                    End;{Case InpC Of #13}

                    #10:
                    Begin {Ctrl-Enter}
                        {spiele Linie zu Ende bevor n�chste gespielt wird}
                        IniSpacedText (12, gmaxy DIV charheight - 5,
                            'pause  ', frNoFrame);
                        SndUpdateSndLength (sndlengthspm, sndlength, actlength, sndlengthper);
                        PlayNext := True;
                        Inc (Linenum);
                        paused := False;
                        nosound;
                        sndchar := 'P';
                        restsndchar := true;
                    End;


                    '-':
                    Begin
                        If temp1 AND (NOT Temp2) Then
                        Begin{Shft}
                            If sndlengthspm <= 12 Then
                                sndlengthspm := 2;
                            If sndlengthspm > 12 Then
                                sndlengthspm := sndlengthspm - 10;
                        End Else
                        If NOT (Temp1 OR Temp2) Then {Normal}
                            If sndlengthspm >= 2 Then
                                sndlengthspm := sndlengthspm - 1;
                        If sndlengthspm < 2 Then
                            sndlengthspm := 2;
                        SChanged := True;
                    End;{case inpC OF '-'}
                    '+':
                    Begin
                        If temp1 AND (NOT Temp2) Then
                        Begin{Shft}
                            If sndlengthspm <= (SndMaxSpm - 10) Then
                                sndlengthspm := sndlengthspm + 10;
                            If (sndlengthspm + 10) > SndMaxSpm Then
                                sndlengthspm := SndMaxSpm;
                        End Else
                        If NOT (Temp1 OR Temp2) Then {Normal}
                            If sndlengthspm <= SndMaxSpm - 1 Then
                                sndlengthspm := sndlengthspm + 1;
                        If sndlengthspm > (SndMaxSpm - 1) Then
                            sndlengthspm := SndMaxSpm;
                        SChanged := True;
                    End;
                    #0:
                    Begin{Ctrl-/Alt- [+/-]}
                        Case XReadKey (Temp1, Temp2) Of
                            #28:{Alt-Enter} If NOT (Temp1 OR Temp2) AND (c <> #27) Then
                                Begin{Alt-Enter}
                                    i := Linenum;
                                    ComSysStart (i);
                                    i := SpePrevNotLine (i);
                                    If i = 0 Then
                                    Begin
                                        nosound;
                                        Exit;
                                    End;{ if i=0}
                                    ComSysStart (i);
                                    linenum := i;
                                    If linenum > 1 Then
                                        dec (linenum);
                                    PlayNext := True;
                                    paused := false;
                                    c := #27;
                                    nosound;
                                    Exit;
                                End;{if not temp1 or temp2}{#28}
                            #82:
                            Begin{Insert}
                                sndlengthspm := Round (sndlengthspm);
                                SChanged := True;
                            End;
                            #78:{Alt +}
                                If (Sndlengthspm * 1.33333{1.5}) <= SndMaxSpm Then
                                    Sndlengthspm := (Sndlengthspm * 1.33333{1.5});
                            #144:{Ctrl +}
                                If sndlengthspm <= SndMaxSpm SHR 1 Then
                                    sndlengthspm := sndlengthspm * 2;
                            #74:{Alt -}
                                If (Sndlengthspm) >= 2 * 1.33333{1.5} Then
                                    Sndlengthspm := (Sndlengthspm / 1.33333{1.5});
                            #142:{Ctrl -}
                                If sndlengthspm >= 4 Then
                                    sndlengthspm := sndlengthspm / 2;
                        End;
                        SChanged := True;
                    End;
                    ' ':
                    Begin
                        Paused := NOT Paused;
                        nosound;
                        If Paused Then
                        Begin
                            IniSpacedText (12, gmaxy DIV charheight - 5,
                                'play   ', frNoFrame);
                            IniSpacedText (2, gmaxy DIV charheight - 1,
                                ' =Symbol ' + #26 + '=step ', frHigh);
                        End Else Begin
                            IniSpacedText (12, gmaxy DIV charheight - 5,
                                'pause  ', frNoFrame);
                            IniSpacedText (2, gmaxy DIV charheight - 1,
                                ' Esc = stop end ', frHigh);

                            saveslinexmin := saveslinexmax;
                        End;
                    End;
                    '/': If Sndlengthper = 1 Then
                            If sndlengthspm / lineattr.beats >= 2 {and <=SndMaxSpm} Then
                            Begin
                                sndlengthper := 2;
                                sndlengthspm := (sndlengthspm / lineattr.beats);
                                IniSpacedText (76, gmaxy DIV charheight - 3, 'LPM', frNoFrame);
                                SChanged := True;
                            End Else IniSpacedText (65, gmaxy DIV charheight - 3,
                                    ' raise  ', frNoFrame);
                    '*': If Sndlengthper <> 1 Then
                            If sndlengthspm * lineattr.beats <= SndMaxSpm Then
                            Begin
                                sndlengthper := 1;
                                sndlengthspm := (sndlengthspm * lineattr.beats);
                                IniSpacedText (76, gmaxy DIV charheight - 3, 'BPM', frNoFrame);
                                SChanged := True;
                                {  end; }
                            End Else IniSpacedText (65, gmaxy DIV charheight - 3,
                                    ' lower  ', frNoFrame);
                    '.':
                    Begin  {or Del, wenn NumLock off}
                        sndlengthspm := Round (sndlengthspm);
                        SChanged := True;
                    End;
                    '0':
                    Begin{.    = round}
                        addcent := 100 * Round (addcent / 100);
                        SndUpdateMulCent;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    '4':
                    Begin{Dn   = -100 cent}
                        addcent := addcent - 100;
                        sndUpdateMulCent;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    '7':
                    Begin{Home  = /2}
                        Mulcent := Mulcent / 2;
                        SndUpdateAddCent;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    '1':
                    Begin{End   = -1 cent}
                        Dec (Addcent);
                        SndUpdateMulCent;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    '8':
                    Begin{Up   = +200 cent}
                        Addcent := Addcent + 200;
                        SndUpdateMulCent;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    '2':
                    Begin{Dn   = -200 cent}
                        addcent := addcent - 200;
                        sndUpdateMulCent;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    '3':
                    Begin{PgDn   = +1 cent}
                        Inc (Addcent);
                        SndUpdateMulCent;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    '5':
                    Begin{m   = reset}
                        Addcent := 0;
                        Mulcent := 1;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    '6':
                    Begin{rg   = +100 cent}
                        Addcent := Addcent + 100;
                        SndUpdateMulCent;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    '9':
                    Begin{pgup = *2}
                        MulCent := MulCent * 2;
                        SndUpDateAddCent;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    'B':
                    Begin
                        SndPlayBeat := SndPlayBeat MOD 3 + 1;
                        IniDrawSoundState;
                    End;
                    'T':
                    Begin
                        If (SndPlayPulse AND plPulse) = 2 Then
                            SndPlayPulse := SndPlayPulse AND (NOT 3)
                        Else
                            Inc (SndPlayPulse);
                        IniDrawSoundState;
                    End;
                    'P':
                    Begin
                        SndPlayPulse := SndPlayPulse XOR plspace;
                        IniDrawSoundState;
                    End;
                    'L':
                    Begin
                        soundattr := (soundattr XOR saLegato) AND saLegato;
                        IniDrawSoundState;
                    End;
                    'S':
                    Begin
                        soundattr := (soundattr XOR saStaccato) AND saStaccato;
                        IniDrawSoundState;
                    End;
                    'R':
                    Begin
                        soundchange := (soundchange XOR saRhythm) {and saRhythm};
                        IniDrawSoundState;
                    End;
                    'M':
                    Begin
                        soundchange := (soundchange XOR saMuffled) {and saMuffled};
                        IniDrawSoundState;
                    End;
                    '%':
                    Begin
                        soundchange := (soundchange XOR saPhrased) {and saPhrased};
                        IniDrawSoundState;
                    End;
                    '(', ')':
                    Begin
                        PlayOptions := PlayOptions XOR poParentheses;
                        IniDrawSoundState;
                    End;
                    '[', ']':
                    Begin
                        PlayOptions := PlayOptions XOR poBrackets;
                        IniDrawSoundState;
                    End;
                    '{', '}':
                    Begin
                        PlayOptions := PlayOptions XOR poBraces;
                        IniDrawSoundState;
                    End;
                    #189:
                    Begin
                        PlayOptions := PlayOptions XOR poDashSlash;
                        IniDrawSoundState;
                    End;
                    {Wenn NumLock off: ---------------------------------------------------------}
                    {---------------------------------------------------------------------------}

                End;{Case}
            End;{While XKeyPressed}
            If SChanged Then SndUpDateSndLength (sndlengthspm, sndlength, actlength, sndlengthper);
            If IniMausEscape = #27 Then
            Begin
                c := #27;
                PlayNext := False;
                nosound;
                Exit;
            End;
            If IniNumChar (inblock[1]) Then
            Begin
                rtime := actlength / IniNextNumber (inblock);
                timemax := round (rtime);
                If timemax < 0 Then
                    timemax := 0;

                timemax := round (rtime);
                If timemax < 0 Then
                    timemax := 0;
                rlength := rlength + rtime;
                blength := round (rlength);
                If blength > actlength Then
                    SndProcBeat;
                rlinexmax := rlinexmax + (dx * rtime) / actlength;
                slinexmax := round (rlinexmax);
                If blength >= actlength Then
                Begin
                    found := true;
                    SndAddBeat;
                End;
            End Else SndProcItem;
        End; {while ((not found) and (length(inblock) > 0))}

        While length (inblock) > 0 Do
        Begin
            SChanged := False;
            If Paused AND IniNumChar (inblock[1]) Then
            Begin
                Repeat
                    InpC := XReadKey (temp1, temp2);
                    Case UpCase (InpC) Of
                        #27: If NOT temp2 Then
                            Begin
                                c := #27;
                                PlayNext := False;
                                If NOT temp1 Then
                                Begin
                                    SndUpDateSndLength (sndlengthspm, sndlength, actlength, sndlengthper);
                                    nosound;
                                    Exit;
                                End Else
                                If NOT paused Then
                                Begin
                                    i := imenubkcolor;
                                    imenubkcolor := alarmbkcolor;
                                    IniSpacedText (2, gmaxy DIV charheight - 1,
                                        '  Finishing line ', frHigh);
                                    imenubkcolor := i;
                                End Else
                                    c := #0;
                            End;{if not temp2}{case inpC OF #27}
                        #13:
                        Begin{Enter}
                            c := #27;
                            PlayNext := True;
                            Inc (Linenum);
                            paused := false;
                            IniSpacedText (12, gmaxy DIV charheight - 5,
                                'pause  ', frNoFrame);
                            SndUpDateSndLength (sndlengthspm, sndlength, actlength, sndlengthper);
                            nosound;
                            Exit;
                        End;{Case InpC Of #13}

                        #10:
                        Begin {Ctrl-Enter}
                            {spiele Linie zu Ende bevor n�chste gespielt wird}
                            IniSpacedText (12, gmaxy DIV charheight - 5,
                                'pause  ', frNoFrame);
                            SndUpdateSndLength (sndlengthspm, sndlength, actlength, sndlengthper);
                            PlayNext := True;
                            Inc (Linenum);
                            paused := False;
                            nosound;
                            sndchar := 'P';
                            restsndchar := true;
                        End;


                        '-':
                        Begin
                            If temp1 AND (NOT Temp2) Then
                            Begin{Shft}
                                If sndlengthspm <= 12 Then
                                    sndlengthspm := 2;
                                If sndlengthspm > 12 Then
                                    sndlengthspm := sndlengthspm - 10;
                            End Else
                            If NOT (Temp1 OR Temp2) Then {Normal}
                                If sndlengthspm >= 2 Then
                                    sndlengthspm := sndlengthspm - 1;
                            If sndlengthspm < 2 Then
                                sndlengthspm := 2;
                            SChanged := True;
                        End;{case inpC OF '-'}
                        '+':
                        Begin
                            If temp1 AND (NOT Temp2) Then
                            Begin{Shft}
                                If sndlengthspm <= (SndMaxSpm - 10) Then
                                    sndlengthspm := sndlengthspm + 10;
                                If (sndlengthspm + 10) > SndMaxSpm Then
                                    sndlengthspm := SndMaxSpm;
                            End Else
                            If NOT (Temp1 OR Temp2) Then {Normal}
                                If sndlengthspm <= SndMaxSpm - 1 Then
                                    sndlengthspm := sndlengthspm + 1;
                            If sndlengthspm > (SndMaxSpm - 1) Then
                                sndlengthspm := SndMaxSpm;
                            SChanged := True;
                        End;{case inpC OF '+'}
                        #0:
                        Begin{Ctrl-/Alt- [+/-]}
                            Case XReadKey (Temp1, Temp2) Of
                                #28:{Alt-Enter} If NOT (Temp1 OR Temp2) AND (c <> #27) Then
                                    Begin{Alt-Enter}
                                        i := Linenum;
                                        ComSysStart (i);
                                        i := SpePrevNotLine (i);
                                        If i = 0 Then
                                        Begin
                                            nosound;
                                            Exit;
                                        End;{ if i=0}
                                        ComSysStart (i);
                                        linenum := i;
                                        PlayNext := True;
                                        paused := false;
                                        c := #27;
                                        If linenum > 1 Then
                                            dec (linenum);
                                        nosound;
                                        Exit;
                                    End;{if not temp1 or temp2}{#28}
                                #82:
                                Begin{Insert}
                                    sndlengthspm := Round (sndlengthspm);
                                    If sndlengthper = 1 Then actlength := sndlength Else
                                        actlength := sndlength DIV lineattr.beats;
                                    SChanged := True;
                                End;
                                #78:{Alt +}
                                    If (Sndlengthspm * 1.33333{1.5}) <= SndMaxSpm Then
                                        Sndlengthspm := (Sndlengthspm * 1.33333{1.5});
                                #144:{Ctrl +}
                                    If sndlengthspm <= SndMaxSpm SHR 1 Then
                                        sndlengthspm := sndlengthspm * 2;
                                #74:{Alt -}
                                    If (Sndlengthspm) >= 2 * 1.33333{1.5} Then
                                        Sndlengthspm := (Sndlengthspm / 1.33333{1.5});
                                #142:{Ctrl -}
                                    If sndlengthspm >= 4 Then
                                        sndlengthspm := sndlengthspm / 2;
                                #98:
                                Begin{ctrl F5}
                        {$R-}
                                    sound (Round (itemchars[itemcount].pitch * MulCent));
                           {$IFNDEF USER}
                           {$R+}
                           {$ENDIF}
                                    Repeat
                                    Until XKeyPressed;
                                    NoSound;
                                    InpC := XReadKey (Temp1, Temp2);
                                End;
                                #77: Inpc := #9;{right}
                                #72:
                                Begin{up}
                                    Repeat
                                        Case UpCase (InpC) Of
                                            '0':
                                            Begin{.  = round}
                                                addcent := 100 * Round (addcent / 100);
                                                SndUpdateMulCent;
                                                st := sndgetcentstr (addcent);
                                                IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                                            End;
                                            '4':
                                            Begin{lf   = -100 cent}
                                                addcent := addcent - 100;
                                                sndUpdateMulCent;
                                                st := sndgetcentstr (addcent);
                                                IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                                            End;
                                            '7':
                                            Begin{Home = /2}
                                                Mulcent := Mulcent / 2;
                                                SndUpdateAddCent;
                                                st := sndgetcentstr (addcent);
                                                IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                                            End;
                                            '1':
                                            Begin{End   = -1 cent}
                                                Dec (Addcent);
                                                SndUpdateMulCent;
                                                st := sndgetcentstr (addcent);
                                                IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                                            End;
                                            '8':
                                            Begin{Up   = +200 cent}
                                                Addcent := Addcent + 200;
                                                SndUpdateMulCent;
                                                st := sndgetcentstr (addcent);
                                                IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                                            End;
                                            '2':
                                            Begin{Dn   = -200 cent}
                                                addcent := addcent - 200;
                                                sndUpdateMulCent;
                                                st := sndgetcentstr (addcent);
                                                IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                                            End;
                                            '3':
                                            Begin{PgDn   = +1 cent}
                                                Inc (Addcent);
                                                SndUpdateMulCent;
                                                st := sndgetcentstr (addcent);
                                                IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                                            End;
                                            '5':
                                            Begin{m   = reset}
                                                Addcent := 0;
                                                Mulcent := 1;
                                                st := sndgetcentstr (addcent);
                                                IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                                            End;
                                            '6':
                                            Begin{rg   = +100 cent}
                                                Addcent := Addcent + 100;
                                                SndUpdateMulCent;
                                                st := sndgetcentstr (addcent);
                                                IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                                            End;
                                            '9':
                                            Begin{pgup = *2}
                                                MulCent := MulCent * 2;
                                                SndUpDateAddCent;
                                                st := sndgetcentstr (addcent);
                                                IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                                            End;
                                            'B':
                                            Begin
                                                SndPlayBeat := SndPlayBeat MOD 3 + 1;
                                                IniDrawSoundState;
                                            End;
                                            'T':
                                            Begin
                                                If (SndPlayPulse AND plPulse) = 2 Then
                                                    SndPlayPulse := SndPlayPulse AND (NOT 3)
                                                Else
                                                    Inc (SndPlayPulse);
                                                IniDrawSoundState;
                                            End;
                                            'P':
                                            Begin
                                                SndPlayPulse := SndPlayPulse XOR plspace;
                                                IniDrawSoundState;
                                            End;
                                            'L':
                                            Begin
                                                soundattr := (soundattr XOR saLegato) AND saLegato;
                                                IniDrawSoundState;
                                            End;
                                            'S':
                                            Begin
                                                soundattr := (soundattr XOR saStaccato) AND saStaccato;
                                                IniDrawSoundState;
                                            End;
                                            'R':
                                            Begin
                                                soundchange := (soundchange XOR saRhythm) {and saRhythm};
                                                IniDrawSoundState;
                                            End;
                                            'M':
                                            Begin
                                                soundchange := (soundchange XOR saMuffled) {and saMuffled};
                                                IniDrawSoundState;
                                            End;
                                            '%':
                                            Begin
                                                soundchange := (soundchange XOR saPhrased) {and saPhrased};
                                                IniDrawSoundState;
                                            End;
                                            '(', ')':
                                            Begin
                                                PlayOptions := PlayOptions XOR poParentheses;
                                                IniDrawSoundState;
                                            End;
                                            '[', ']':
                                            Begin
                                                PlayOptions := PlayOptions XOR poBrackets;
                                                IniDrawSoundState;
                                            End;
                                            '{', '}':
                                            Begin
                                                PlayOptions := PlayOptions XOR poBraces;
                                                IniDrawSoundState;
                                            End;
                                            #189:
                                            Begin
                                                PlayOptions := PlayOptions XOR poDashSlash;
                                                IniDrawSoundState;
                                            End;
                                        End;
                            {$R-}
                                        sound (Round (LastSound * MulCent));
                            {$IFNDEF USER}
                            {$R+}
                            {$ENDIF}
                                        InpC := XReadKey (temp1, temp2);
                                    Until (InpC < '0') OR (InpC > '9');
                                    If InpC = #0 Then
                                    Begin
                                        If XReadKey (temp1, temp2) <> #77 Then
                                            NoSound;
                                    End Else
                                        NoSound;
                                End;
                            End;{Case XReadKey OF}
                            SChanged := True;
                        End;{case inpC OF #0}
                        '/': If Sndlengthper = 1 Then
                                If sndlengthspm / lineattr.beats >= 2 {and <=SndMaxSpm} Then
                                Begin
                                    sndlengthper := 2;
                                    sndlengthspm := (sndlengthspm / lineattr.beats);
                                    IniSpacedText (76, gmaxy DIV charheight - 3, 'LPM', frNoFrame);
                                    SChanged := True;
                                End Else IniSpacedText (65, gmaxy DIV charheight - 3,
                                        ' raise  ', frNoFrame);
                        '*': If Sndlengthper <> 1 Then
                                If sndlengthspm * lineattr.beats <= SndMaxSpm Then
                                Begin
                                    sndlengthper := 1;
                                    sndlengthspm := (sndlengthspm * lineattr.beats);
                                    IniSpacedText (76, gmaxy DIV charheight - 3, 'BPM', frNoFrame);
                                    SChanged := True;
                                End Else IniSpacedText (65, gmaxy DIV charheight - 3,
                                        ' lower  ', frNoFrame);
                        '.':
                        Begin  {or Del, wenn NumLock off}
                            sndlengthspm := Round (sndlengthspm);
                            If sndlengthper = 1 Then actlength := sndlength Else
                                actlength := sndlength DIV lineattr.beats;
                            SChanged := True;
                        End;
                        '0':
                        Begin{.  = round}
                            addcent := 100 * Round (addcent / 100);
                            SndUpdateMulCent;
                            st := sndgetcentstr (addcent);
                            IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                        End;
                        '4':
                        Begin{lf   = -100 cent}
                            addcent := addcent - 100;
                            sndUpdateMulCent;
                            st := sndgetcentstr (addcent);
                            IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                        End;
                        '7':
                        Begin{Home = /2}
                            Mulcent := Mulcent / 2;
                            SndUpdateAddCent;
                            st := sndgetcentstr (addcent);
                            IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                        End;
                        '1':
                        Begin{End  = -1 cent}
                            Dec (Addcent);
                            SndUpdateMulCent;
                            st := sndgetcentstr (addcent);
                            IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                        End;
                        '8':
                        Begin{Up   = +200 cent}
                            Addcent := Addcent + 200;
                            SndUpdateMulCent;
                            st := sndgetcentstr (addcent);
                            IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                        End;
                        '2':
                        Begin{Dn   = -200 cent}
                            addcent := addcent - 200;
                            sndUpdateMulCent;
                            st := sndgetcentstr (addcent);
                            IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                        End;
                        '3':
                        Begin{PgDn   = +1 cent}
                            Inc (Addcent);
                            SndUpdateMulCent;
                            st := sndgetcentstr (addcent);
                            IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                        End;
                        '5':
                        Begin{m   = reset}
                            Addcent := 0;
                            Mulcent := 1;
                            st := sndgetcentstr (addcent);
                            IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                        End;
                        '6':
                        Begin{rg   = +100 cent}
                            Addcent := Addcent + 100;
                            SndUpdateMulCent;
                            st := sndgetcentstr (addcent);
                            IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                        End;
                        '9':
                        Begin{pgup = *2}
                            MulCent := MulCent * 2;
                            SndUpDateAddCent;
                            st := sndgetcentstr (addcent);
                            IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                        End;
                        'B':
                        Begin
                            SndPlayBeat := SndPlayBeat MOD 3 + 1;
                            IniDrawSoundState;
                        End;
                        'T':
                        Begin
                            If (SndPlayPulse AND plPulse) = 2 Then
                                SndPlayPulse := SndPlayPulse AND (NOT 3)
                            Else
                                Inc (SndPlayPulse);
                            IniDrawSoundState;
                        End;
                        'P':
                        Begin
                            SndPlayPulse := SndPlayPulse XOR plspace;
                            IniDrawSoundState;
                        End;
                        'L':
                        Begin
                            soundattr := (soundattr XOR saLegato) AND saLegato;
                            IniDrawSoundState;
                        End;
                        'S':
                        Begin
                            soundattr := (soundattr XOR saStaccato) AND saStaccato;
                            IniDrawSoundState;
                        End;
                        'R':
                        Begin
                            soundchange := (soundchange XOR saRhythm) {and saRhythm};
                            IniDrawSoundState;
                        End;
                        'M':
                        Begin
                            soundattr := (soundattr XOR saMuffled) {and saMuffled};
                            IniDrawSoundState;
                        End;
                        '%':
                        Begin
                            soundchange := (soundchange XOR saPhrased) {and saPhrased};
                            IniDrawSoundState;
                        End;
                        '(', ')':
                        Begin
                            PlayOptions := PlayOptions XOR poParentheses;
                            IniDrawSoundState;
                        End;
                        '[', ']':
                        Begin
                            PlayOptions := PlayOptions XOR poBrackets;
                            IniDrawSoundState;
                        End;
                        '{', '}':
                        Begin
                            PlayOptions := PlayOptions XOR poBraces;
                            IniDrawSoundState;
                        End;
                        #189:
                        Begin
                            PlayOptions := PlayOptions XOR poDashSlash;
                            IniDrawSoundState;
                        End;
                    End;
                    If SChanged Then
                    Begin
                        Str (sndlengthspm: 4: 3, st);
                        While Length (st) < 8 Do
                            st := ' ' + st;
                        IniSpacedText (65, gmaxy DIV charheight - 3, st, frNoFrame);
                    End;
                Until InpC IN [#9, #15, ' '{,#63}];
                Case InpC Of
                    #9:
                    Begin
                        saveslinexmin := slinexmin;
                        Saveslinexmax := slinexmax;
                        SaveY := y;
                    End;
                    #15: ;
                    ' ':
                    Begin
                        Paused := False;
                        nosound;
                        If savey <> 0 Then
                            SndDraw (saveslinexmin, Saveslinexmax, Savey, wait);
                        IniSpacedText (12, gmaxy DIV charheight - 5,
                            'pause  ', frNoFrame);
                        IniSpacedText (2, gmaxy DIV charheight - 1,
                            ' Esc = stop end ', frHigh);
                    End;{case inpC OF ' '}
                End;
            End;
            While xKeyPressed Do
            Begin
                InpC := XReadKey (temp1, temp2);
                Case UpCase (InpC) Of
                    #27: If NOT temp2 Then
                        Begin
                            c := #27;
                            PlayNext := False;
                            If NOT temp1 Then
                            Begin
                                SndUpDateSndLength (sndlengthspm, sndlength, actlength, sndlengthper);
                                nosound;
                                Exit;
                            End Else
                            If NOT paused Then
                            Begin
                                i := imenubkcolor;
                                j := imenutextcolor;
                                imenubkcolor := alarmbkcolor;
                                imenutextcolor := alarmcolor;
                                IniSpacedText (2, gmaxy DIV charheight - 1,
                                    '  Finishing line ', frLow);
                                imenubkcolor := i;
                                imenutextcolor := j;
                            End Else
                                c := #0;
                        End;
                    #13:
                    Begin{Enter}
                        IniSpacedText (12, gmaxy DIV charheight - 5,
                            'pause  ', frNoFrame);
                        c := #27;
                        PlayNext := True;
                        paused := false;
                        Inc (Linenum);
                        nosound;
                        Exit;
                    End;{Case InpC Of #13}

                    #10:
                    Begin {Ctrl-Enter}
                        {spiele Linie zu Ende bevor n�chste gespielt wird}
                        IniSpacedText (12, gmaxy DIV charheight - 5,
                            'pause  ', frNoFrame);
                        SndUpdateSndLength (sndlengthspm, sndlength, actlength, sndlengthper);
                        PlayNext := True;
                        Inc (Linenum);
                        paused := False;
                        nosound;
                        sndchar := 'P';
                        restsndchar := true;
                    End;


                    '-':
                    Begin
                        If temp1 AND (NOT Temp2) Then
                        Begin{Shft}
                            If sndlengthspm <= 12 Then
                                sndlengthspm := 2;
                            If sndlengthspm > 12 Then
                                sndlengthspm := sndlengthspm - 10;
                        End Else
                        If NOT (Temp1 OR Temp2) Then {Normal}
                            If sndlengthspm >= 2 Then
                                sndlengthspm := sndlengthspm - 1;
                        If sndlengthspm < 2 Then
                            sndlengthspm := 2;
                        SChanged := True;
                    End;{case inpC OF '-'}
                    '+':
                    Begin
                        If temp1 AND (NOT Temp2) Then
                        Begin{Shft}
                            If sndlengthspm <= (SndMaxSpm - 10) Then
                                sndlengthspm := sndlengthspm + 10;
                            If (sndlengthspm + 10) > SndMaxSpm Then
                                sndlengthspm := SndMaxSpm;
                        End Else
                        If NOT (Temp1 OR Temp2) Then {Normal}
                            If sndlengthspm <= SndMaxSpm - 1 Then
                                sndlengthspm := sndlengthspm + 1;
                        If sndlengthspm > (SndMaxSpm - 1) Then
                            sndlengthspm := SndMaxSpm;
                        SChanged := True;
                    End;
                    #0:
                    Begin{Ctrl-/Alt- [+/-]}
                        Inpc := XReadKey (Temp1, Temp2);
                        Case InpC Of
                            #82:
                            Begin{Insert}
                                sndlengthspm := Round (sndlengthspm);
                                If sndlengthper = 1 Then actlength := sndlength Else
                                    actlength := sndlength DIV lineattr.beats;
                                SChanged := True;
                            End;
                            #78:{Alt +}
                                If (Sndlengthspm * 1.33333{1.5}) <= SndMaxSpm Then
                                    Sndlengthspm := (Sndlengthspm * 1.33333{1.5});
                            #144:{Ctrl +}
                                If sndlengthspm <= SndMaxSpm SHR 1 Then
                                    sndlengthspm := sndlengthspm * 2;
                            #74:{Alt -}
                                If (Sndlengthspm) >= 2 * 1.33333{1.5} Then
                                    Sndlengthspm := (Sndlengthspm / 1.33333{1.5});
                            #142:{Ctrl -}
                                If sndlengthspm >= 4 Then
                                    sndlengthspm := sndlengthspm / 2;
                            #28:{Alt-Enter} If NOT (Temp1 OR Temp2) AND (c <> #27) Then
                                Begin{Alt-Enter}
{                         PagRefClearVal(0,     IniYnow(linenum)-1,
                                        gmaxX, IniYnow(linenum));}
                                    i := Linenum;
                                    ComSysStart (i);
                                    i := SpePrevNotLine (i);
                                    If i = 0 Then
                                    Begin
                                        nosound;
                                        Exit;
                                    End;{ if i=0}
                                    ComSysStart (i);
                                    linenum := i;
                                    PlayNext := True;
                                    paused := false;
                                    c := #27;
                                    If linenum > 1 Then
                                        dec (linenum);
                                    nosound;
                                    Exit;
                                End;{if not temp1 or temp2}{#28}
                        End;{Case }
                        SChanged := True;
                    End;{#0}
                    '0':
                    Begin{.  = round}
                        addcent := 100 * Round (addcent / 100);
                        SndUpdateMulCent;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    '4':
                    Begin{lf  = -100 cent}
                        addcent := addcent - 100;
                        sndUpdateMulCent;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    '7':
                    Begin{Home = /2}
                        Mulcent := Mulcent / 2;
                        SndUpdateAddCent;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    '1':
                    Begin{End  = -1 cent}
                        Dec (Addcent);
                        SndUpdateMulCent;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    '8':
                    Begin{Up   = +200 cent}
                        Addcent := Addcent + 200;
                        SndUpdateMulCent;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    '2':
                    Begin{Dn   = -200 cent}
                        addcent := addcent - 200;
                        sndUpdateMulCent;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    '3':
                    Begin{PgDn   = +1 cent}
                        Inc (Addcent);
                        SndUpdateMulCent;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    '5':
                    Begin{m   = reset}
                        Addcent := 0;
                        Mulcent := 1;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    '6':
                    Begin{rg   = +100 cent}
                        Addcent := Addcent + 100;
                        SndUpdateMulCent;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    '9':
                    Begin{pgup = *2}
                        MulCent := MulCent * 2;
                        SndUpDateAddCent;
                        st := sndgetcentstr (addcent);
                        IniSpacedText (20, gmaxy DIV charheight - 1, st, frLow);
                    End;
                    {Wenn NumLock off: ---------------------------------------------------------}
(* 4              #71 :Begin{Home=+1Hz}
                 MulCent:=MulCent*2; {Reaktion vorl�ufig:+1Oktave}
                 SndUpDateAddCent;
                 st:=sndgetcentstr(addcent);          IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End; *)
                    {---------------------------------------------------------------------------}
                    ' ':
                    Begin
                        paused := NOT Paused;
                        nosound;
                        If Paused Then
                        Begin
                            IniSpacedText (12, gmaxy DIV charheight - 5,
                                'play   ', frNoFrame);
                            IniSpacedText (2, gmaxy DIV charheight - 1,
                                ' =Symbol ' + #26 + '=step ', frHigh);
                        End Else Begin
                            IniSpacedText (12, gmaxy DIV charheight - 5,
                                'pause  ', frNoFrame);
                            IniSpacedText (2, gmaxy DIV charheight - 1,
                                ' Esc = stop end ', frHigh);
                            If savey <> 0 Then
                                SndDraw (saveslinexmin, Saveslinexmax, Savey, wait);
                        End;
                    End;
                    '/': If Sndlengthper = 1 Then
                            If sndlengthspm / lineattr.beats >= 2 {<=SndMaxSpm} Then
                            Begin
                                sndlengthper := 2;
                                sndlengthspm := (sndlengthspm / lineattr.beats);
                                IniSpacedText (76, gmaxy DIV charheight - 3, 'LPM', frNoFrame);
                                SChanged := True;
                            End Else IniSpacedText (65, gmaxy DIV charheight - 3,
                                    ' raise  ', frNoFrame);
                    '*': If Sndlengthper <> 1 Then
                            If sndlengthspm * lineattr.beats <= SndMaxSpm Then
                            Begin
                                sndlengthper := 1;
                                sndlengthspm := (sndlengthspm * lineattr.beats);
                                IniSpacedText (76, gmaxy DIV charheight - 3, 'BPM', frNoFrame);
                                SChanged := True;
                            End Else IniSpacedText (65, gmaxy DIV charheight - 3,
                                    ' lower  ', frNoFrame);
                    '.':
                    Begin  {or Del, wenn Numlock off}
                        sndlengthspm := Round (sndlengthspm);
                        SChanged := True;
                    End;
                    'B':
                    Begin
                        SndPlayBeat := SndPlayBeat MOD 3 + 1;
                        IniDrawSoundState;
                    End;
                    'T':
                    Begin
                        If (SndPlayPulse AND plPulse) = 2 Then
                            SndPlayPulse := SndPlayPulse AND (NOT 3)
                        Else
                            Inc (SndPlayPulse);
                        IniDrawSoundState;
                    End;
                    'P':
                    Begin
                        SndPlayPulse := SndPlayPulse XOR plspace;
                        IniDrawSoundState;
                    End;
                    'L':
                    Begin
                        soundattr := (soundattr XOR saLegato) AND saLegato;
                        IniDrawSoundState;
                    End;
                    'S':
                    Begin
                        soundattr := (soundattr XOR saStaccato) AND saStaccato;
                        IniDrawSoundState;
                    End;
                    'R':
                    Begin
                        soundchange := (soundchange XOR saRhythm) {and saRhythm};
                        IniDrawSoundState;
                    End;  {*schliesst so die andern nicht aus}
(*             'I' :begin
                 soundattr:=(soundattr xor saIncipit) and saIncipit;
               end;      *)
                    'M':
                    Begin
                        soundchange := (soundchange XOR saMuffled) {and saMuffled};
                        IniDrawSoundState;
                    End;
                    '%':
                    Begin
                        soundchange := (soundchange XOR saPhrased) {and saPhrased};
                        IniDrawSoundState;
                    End;
                    '(', ')':
                    Begin
                        PlayOptions := PlayOptions XOR poParentheses;
                        IniDrawSoundState;
                    End;
                    '[', ']':
                    Begin
                        PlayOptions := PlayOptions XOR poBrackets;
                        IniDrawSoundState;
                    End;
                    '{', '}':
                    Begin
                        PlayOptions := PlayOptions XOR poBraces;
                        IniDrawSoundState;
                    End;
                    #189:
                    Begin
                        PlayOptions := PlayOptions XOR poDashSlash;
                        IniDrawSoundState;
                    End;
                End;{Case}
            End;{While XKeyPressed}
            If (savey <> 0) AND Paused Then
            Begin
                If SaveSlinexmin > slinexmin Then
                Begin
                    saveslinexmin := slinexmin;
                    saveslinexmax := slinexmax;
                End;
                If SaveSlinexmax < slinexmin Then
                    SaveSlinexmax := slinexmin;
            End;
            If SChanged Then SndUpdateSndLength (sndlengthspm, sndlength, actlength, sndlengthper);
            If IniMausEscape = #27 Then
            Begin
                c := #27;
                PlayNext := False;
                SndUpdateSndLength (sndlengthspm, sndlength, actlength, sndlengthper);
                nosound;
                Exit;
            End;
            If IniNumChar (inblock[1]) Then
            Begin
                { save current sound for legato }
                If (itemcount <> 0) AND (NOT repeatchar) Then
                    If ((itemcount > 1) OR (itemchars[1].pitch <> sndbeat) OR
                        ((itemchars[1].length <> 5) AND (itemchars[1].length <> sndbeatlength))) Then
                    Begin
                        saveitemcount := itemcount;
                        saveitemchars := itemchars;
                    End;
                { actlength=total length of beat->rtime=length of this sound}
                leaveout := 0;
                rtime := actlength / IniNextNumber (inblock);
                timemax := round (rtime);
                If timemax < 0 Then
                    timemax := 0;
(*           rtime:=0;
           ok:=false;
           repeat
             if IniNumChar(inblock[1]) then begin
               rtime:=rtime+(actlength/IniNextNumber(inblock));
             end else begin
               if (inblock[1]='.')or((inblock[1]=',')and
               ( ((SndPlayPulse and plpulse)=plPulseNever) or
                (((SndPlayPulse and plpulse)=plPulseNoLeg)And((soundattr and saLegato)<>0))))then
                 delete(inblock,1,1)
               else
                 ok:=true;
             end;
           until ok or (length(inblock)=0);*)
                timemax := round (rtime);
                If timemax < 0 Then
                    timemax := 0;
                { rlength/blength=elapsed time in this beat }
                rlength := rlength + rtime;
                blength := round (rlength);
                { beat finished? -> add beat sound }
                { kick out any rounding errors->exact beat... :) }
                If blength >= actlength Then
                    SndProcBeat;
                SndDrawPlay;
                If blength >= actlength Then
                Begin
                    { add beat sounds }
                    SndAddBeat;
                    If blength > 0 Then
                    Begin
                        timemax := blength;
                        SndDrawPlay;
                    End;
                End;
            End Else SndProcItem{if IniNumChar(inblock[1])};
        End; {while length(inblock) > 0 do}
    End Else Begin {if inblock[1] = 'N' then}
        playnext := false;
        If Sndchar = 'L' Then
        Begin
            c := #27;
            playnext := true;
        End;
    End;
    NoSound;
    If restsndchar Then sndchar := savesndchar;
End;

{******************************************************************}
Procedure SndSetOptions;

Var
    c: char;
    y, hy: integer;

Begin
    ImeInitSndOptionsMenu;
    If sndlengthspm = 0 Then sndlengthspm := 60000 / sndlength;{New}
    UsrMenu.ChoiceVal[1].rval := sndlengthspm;{New}
    UsrMenu.ChoiceVal[2].Tval := sndlengthper;
    UsrMenu.ChoiceVal[3].Tval := sndplaybeat;
    UsrMenu.ChoiceVal[4].Tval := sndplaypulse + 1;
    UsrMenu.ChoiceVal[5].ival := sndbeat;
    UsrMenu.ChoiceVal[6].ival := sndbeatlength;
    UsrMenu.ChoiceVal[7].ival := sndpulse;
    UsrMenu.ChoiceVal[8].ival := sndpulselength;
    UsrMenu.ChoiceVal[9].tval := dispsound;
    UsrMenu.ChoiceVal[10].tval := sndwarning;
    y := grmaxy - (usrmenu.num_choices * usrmenu.spacing +
        usrmenu.menuattr.firstline + 6) * charheight;
    MausDunkel;
    PagRefClearVal (0, y - 16, gmaxX, gmaxy);
    hy := y DIV charheight;
    GrDisplay_Frame (grminx, y, grmaxx, grmaxy, true, true);
    GrDisplay_Menu (hfminx, hy, usrmenu, 0);
    MausZeigen;
    GrGet_Menu_Values (hfminx, hy, hfmaxy, UsrMenu, c);
    sndlength := Round (60000 / UsrMenu.ChoiceVal[1].rval);{New}
    sndlengthspm := UsrMenu.ChoiceVal[1].rval;{New}
    sndlengthper := UsrMenu.ChoiceVal[2].tval;
    sndplaybeat := UsrMenu.ChoiceVal[3].tval;
    sndplaypulse := UsrMenu.ChoiceVal[4].tval - 1;
    sndbeat := UsrMenu.ChoiceVal[5].ival;
    sndbeatlength := UsrMenu.ChoiceVal[6].ival;
    sndpulse := UsrMenu.ChoiceVal[7].ival;
    sndpulselength := UsrMenu.ChoiceVal[8].ival;
    dispsound := UsrMenu.ChoiceVal[9].tval;
    sndwarning := UsrMenu.ChoiceVal[10].tval;
End;

{******************************************************************}
Procedure SndSoundMenu(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    Menu: boolean);

Var dir: movement;
    c: char;
    choicenum: byte;
    y, hy: integer;
    mausx, mausy, maustaste, mausmenu: word;
    Playnext: Boolean;
    shiftp, ctrlp: Boolean;
    st: string;
Begin
    paused := false;
    maustaste := 0;
    Repeat
        ImeInitSoundMenu;
        choicenum := 1;
        Mausdunkel;
        y := grmaxy - (usrmenu.num_choices * usrmenu.spacing +
            usrmenu.menuattr.firstline + 2) * charheight;
        PagRefClearVal (0, y - 16, gmaxX, gmaxy);
        hy := y DIV charheight;
        GrDisplay_Frame (grminx, y, grmaxx, grmaxy, true, false);
        GrDisplay_Menu (hfminx, hy, usrmenu, 0);
        Mauszeigen;
        GrGet_Menu_Response (hfminx, hy, usrmenu, c, dir, choicenum,
            mausx, mausy, maustaste, mausmenu,
            false, 0);
        c := UpCase (c);
        PagRefPage;

        If c = 'O' Then
            SndSetOptions
        Else
        If c >= 'A' Then
        Begin
            sndchar := c;
            c := chr (27);
            PagRefreshPage (refxmin, refymin, refxmax, refymax);
            IniRefInit;
            st := '';
            {     st:=' [Esc]=stop  [Space]=pause  [Enter]=nextline  ('+#24+')[+/-]=speed ';}
            HlpBottomLine (st);                                          {[+/-]=speed}


            IniSpacedText (2, gmaxy DIV charheight - 5, '  Space = pause  ', frHigh);
            IniSpacedText (2, gmaxy DIV charheight - 3, '  Esc   = stop   ', frHigh);
            IniSpacedText (2, gmaxy DIV charheight - 1, ' ' + #24 + 'Esc = stop end ', frHigh);

            IniSpacedText (20, gmaxy DIV charheight - 5, ' (A/C)Enter = ' + #24 + #25 + 'Line ', frHigh);
            IniSpacedText (20, gmaxy DIV charheight - 3, ' 0=roundCent 5=reset ', frHigh);
            IniSpacedText (20, gmaxy DIV charheight - 1, '                     ', frLow);

            IniSpacedText (42, gmaxy DIV charheight - 5, ' on/off: BPTSLMR ([{� ', frHigh);
            IniSpacedText (42, gmaxy DIV charheight - 3, ' (' + #24 + '/Ctrl/Alt)�: speed ', frHigh);
            IniSpacedText (42, gmaxy DIV charheight - 1, '                      ', frHigh);

            IniSpacedText (65, gmaxy DIV charheight - 5, ' / * = LPMBPM ', frHigh);
            IniSpacedText (65, gmaxy DIV charheight - 1, ' . = round -PM ', frHigh);


            Str (sndlengthspm: 4: 3, st);
            While Length (st) < 8 Do
                st := ' ' + st;
            If SndLengthPer = 1 Then
                st := st + '   BPM '
            Else
                st := st + '   LPM ';
            IniSpacedText (65, gmaxy DIV charheight - 3, st, frLow);
            Repeat
                While xkeypressed Do xreadkey (shiftp, ctrlp);
                SndPlaySound (linenum, actposn, actpost,
                    actptr, startptr, lastptr, true, playnext);
                If PlayNext Then
                Begin
                    ComEdReturn (linenum, actposn, actpost, false, false);
                    PagRefreshPage (refxmin, refymin, refxmax, refymax);
                    IniRefInit;
                End;
            Until PlayNext = False;
            {    pagputbottomline }{###}
            {    PagRefreshPage(refxmin, refymin, refxmax, refymax); }{###}
            {    iniRefInit; }{###}
            c := #27;
        End;
    Until (c = chr (27));
End;


{******************************************************************}
Procedure SndPlaySound(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    Menu: boolean; Var Playnext: Boolean);

Var actcolor: byte;
    i, j: integer;
    c: char;
    tempbuffer, inblock: stringline;
    endreached, drawline: boolean;
    tbufpos: byte;
    temp1, temp2: boolean;
    savesndchar: Char;
    savelinenum: integer;
    linetype: Char; {Helpline?}

    {************************}
    Procedure SwapColor;

    Begin
        If actcolor <> soundcolor Then
            actcolor := soundcolor
        Else
            actcolor := lcolor;
        SetColor (actcolor);
    End;


Begin
    PlaySuccess := False;
    savesndchar := sndchar;
    savelinenum := linenum;
    If NOT Menu Then
        sndchar := 'L';
    If sndchar <> 'F' Then
    Begin
        linenum := 0;
        While (page[linenum, 1] <> 'N') AND (linenum <> pagelength + 1) Do inc (linenum);
        If linenum >= pagelength Then
            If (mstart.mpag <> -1) AND (mend.mpag <> -1) Then
            Begin
                sndchar := 'B';
                filbufclear;
                MarMarkToBuffer (actptr, startptr, lastptr);
            End Else Begin
                HlpHint (HntPageEmpty, HintNormalTime, []);
                c := #27;
                playnext := False;
                linenum := savelinenum;
                sndchar := savesndchar;
                nosound;
                Exit;
            End;
        linenum := savelinenum;
    End;{if sndchar<>'F'}
    actcolor := lcolor;
    If Menu Then
        If page[linenum] <> 'N' Then
            If sndchar <> 'F' Then
            Begin
                While (page[linenum, 1] <> 'N') AND (linenum <> pagelength + 1) Do
                    inc (linenum);
                If page[linenum] <> 'N' Then
                Begin
                    While (page[linenum, 1] <> 'N') AND (linenum <> 1) Do
                        dec (linenum);
                    If linenum = 1 Then
                    Begin
                        nosound;
                        exit;
                    End;{if linenum=1}
                End;{if page[linenum]<>'N'}
            End{if sndchar<>'F'}{if page[linenum]<>'N'};{if Menu}
    If (NOT Menu) AND (sndchar <> 'F') Then
    Begin
        sndchar := 'L';
        If (Page[Linenum, 1] <> 'N') Then sndchar := 'P';
        If (mstart.mpag <> -1) AND (mend.mpag <> -1) Then
        Begin
            sndchar := 'B';
            filbufclear;
            MarMarkToBuffer (actptr, startptr, lastptr);
        End;
    End;{if (not Menu) and (sndchar<>'F')}
    Case sndchar Of
        'L':
        Begin
            While c <> #27 Do
            Begin
                PlayNext := False;
                SwapColor;
                For i := Linenum To Pagelength Do
                    If Page[i, 1] = 'N' Then
                    Begin
                        PlayNext := True;
                        Linenum  := i;
                        Break;
                    End{If Page};{For i}
                If NOT PlayNext Then
                    For i := 1 To Linenum - 1 Do
                        If Page[i, 1] = 'N' Then
                        Begin
                            PlayNext := True;
                            Linenum  := i;
                            Break;
                        End{If Page}{For i};{IF Not PlayNext}
                i := linenum;
                linetype := page[i, 5];
                If ((page[linenum, 5] = 'H') AND (savelinenum = linenum)) Then
                    page[linenum, 5] := ' ';
                If PlayNext Then
                    SndPlayLine (page[linenum], linenum, true, playnext, C, savesndchar);
                Page[i, 5] := linetype;
                PagRefClearVal (0, IniYnow (i),
                    gmaxX, IniYnow (i) + 1);
                If (i <> linenum) AND NOT (playsuccess) Then
                Begin
                    pagrefreshpage (refxmin, refymin, refxmax, refymax);
                    gcupatternrestore;
                End;
            End;{While c <> #27}
            Savelinenum := Linenum;
        End;{Case SndChar Of 'L'}

        'B':
        Begin
            PlayNext := False;
            j := 0;
            If NOT Menu Then
                PagRefPage;
            If bufstartptr = bufendptr Then
	    HlpHint (HntBufEmpty, HintNormalTime, [])
	    Else {if bufstartptr = bufendptr then} If
	    marpartline Then
	    HlpHint (HntCantPlayPart, HintWaitEsc, [])
	    Else {if marpartline then}Begin
                endreached := true;
                If ((mstart.mpag = pagecount) AND
                    (mend.mpag = pagecount)) Then drawline := true Else drawline := false;
                While c <> chr (27) Do
                Begin
                    If endreached Then
                    Begin
                        bufactptr := bufstartptr;
                        tempbuffer := '';
                        tbufpos := 0;
                        SwapColor;
                        i := mstart.mline;
                    End;
                    FilCheckLine (tempbuffer, inblock,
                        bufactptr, bufstartptr, bufendptr,
                        tbufpos, endreached, true, false);
                    If inblock[1] = 'N' Then
                        j := 1;
                    If endreached AND (j = 0) Then
                    Begin
                        c := #27;
                        HlpHint (HntBufEmpty, HintNormalTime, []);
                    End;
                    SndPlayLine (inblock, i, drawline, playnext, c, savesndchar);
                    i := i + 1;
                    If playnext Then playnext := False{savesndchar:='L';};
                End; {while c <> chr(27) do}
            End{else if marpartline then}; {else if bufstartptr = bufendptr then}
        End;

        'P':
        Begin
            PlayNext := false;
            While c <> #27 Do
            Begin
                i := 1;
                SwapColor;
                While ((i <= pagelength) AND (c <> chr (27))) Do
                Begin
                    If (i = pagelength) AND NOT (PlaySuccess) Then
                    Begin
                        PlayNext := False;
                        c := #27;
                        HlpHint (HntPageEmpty, HintNormalTime, []);
                    End;
                    setcolor (actcolor);
                    { if (page[i,5]<>'H') and(page[i,1]='N') then  }
                    SndPlayLine (page[i], i, true, playnext, c, savesndchar);
                    i := i + 1;
                    If playnext Then
                    Begin
                        savelinenum := i;
                        savesndchar := 'L';
                    End;
                End;
            End;
            If (NOT Menu) AND (PlaySuccess) Then
                PagRefClearVal (0, 0, gmaxX, (pagelength) * linethick + linethick SHR 1);
        End;

        'F':
        Begin
            PlayNext := False;
            FilSavePage (topmargin, pagelength,
                actptr, startptr, lastptr);
            endreached := true;
            While c <> chr (27) Do
            Begin
                If endreached Then
                Begin
                    actptr := startptr;
                    tempbuffer := '';
                    tbufpos := 0;
                    FilFindPage (1, i, actptr, startptr, lastptr);
                    linenum := 0;
                End;
                inc (linenum);
                If linenum = pagelength + 1 Then
                    linenum := 1;
                If linenum <= pagelength Then
                Begin
                    FilCheckLine (tempbuffer, inblock,
                        actptr, startptr, lastptr,
                        tbufpos, endreached, true, false);
                    SndPlayLine (inblock, linenum, false, playnext, c, savesndchar);
                End;
                linenum := savelinenum;
                If playnext Then
                Begin
                    playnext := false;
                    c := #0;
                End;
            End;
            FilFindPage (pagecount, i, actptr, startptr, lastptr);
            PagGetPageFromHeap (actptr, startptr, lastptr, i);
            savesndchar := 'L';
        End;
    End; {case c of}
    While xKeyPressed Do
        xReadKey (temp1, temp2);
    PagUnmark;
    sndchar := savesndchar;
    linenum := savelinenum;
    If NOT PlaySuccess Then
        playNext := False;
End;

Function SndGetCentStr(C: Integer): String;
Var O, HT, Cn: Integer;
    S1, S2: String;
Const IV: Array[0..11] Of String = (#196 + ' ' + #179, '2b' + #179, '2 ' + #179, '3b' + #179, '3 ' + #179, '4 ' + #179, '4#' + #179, '5 ' + #179, '6b' + #179, '6 ' + #179, '7b' + #179, '7 ' + #179);

    Procedure OHTCn;
    Var
        AX, DX: Integer;
    Begin
        // Clear variables
        O := 0;
        HT := 0;
        CN := 0;

        // Get absolute value of cents
        AX := Abs (C);
        DX := AX;

        // Calculate octaves (divide by 1200)
        If AX >= 1200 Then
        Begin
            O := AX DIV 1200;
            DX := AX MOD 1200;
        End;

        // Calculate halftones (divide remainder by 100)
        AX := DX;
        If AX >= 100 Then
        Begin
            HT := AX DIV 100;
            DX := AX MOD 100;
        End;

        // Set cents
        CN := DX;

        // Round halftones if cents > 50
        If CN > 50 Then
        Begin
            CN := CN - 100;
            Inc (HT);
            If HT >= 12 Then
            Begin
                HT := 0;
                Inc (O);
            End;
        End;

        // Limit octaves to 5
        If O > 5 Then
            O := 5;
    End;

    Function Oct: String;
    Begin
        If O = 0 Then Oct := '  0' + #249 + '8 ' + #179 + S1 Else
            Oct := '  ' + S1 + '' + Char (O + Byte ('0')) + #249 + '8 ' + #179 + ' ';
    End;
    Function HTs: String;
    Begin
        HTs := IV[HT];
    End;
    Function Cent: String;
    Begin
        Str (Abs (Cn): 2, S2);
        If Cn = 0 Then
            S2 := '+' + S2          {wenn    0 Cent}
        Else If c > 0 Then
        Begin
            If cn > 0 Then
                S2 := '+' + S2        {wenn + .. Cent}
            Else If cn < 0 Then
                s2 := '-' + S2        {wenn - .. Cent}
            Else
                s2 := ' ' + S2;       {wenn ???}
        End Else If cn > 0 Then
            S2 := '-' + S2
        Else If cn < 0 Then
            s2 := '+' + S2
        Else
            s2 := ' ' + S2{wird nicht gebraucht};
        Cent := S2 + 'Cent ';
    End;
Begin
    If c > 50 Then
        S1 := '+'  // +
    Else If c < -50 Then
        S1 := '-'  // -
    Else
        S1 := ' '; // space
(*IF c>1199 Then
    S1:='+'  // +
  Else IF c<-1199 Then
    S1:='-'  // -
  Else
    S1:=' '; // space     *)

    OHTCn;
    S1 := Oct + HTs + Cent;
    { TODO: fix this }
    If S1 = '  0' + #195 + #185 + '8 ' + #194 + #179 + ' ' + #195 + #132 + ' ' + #194 + #179 + '0Cent ' Then
        If ctrlF5 Then
            S1 := '  NumBlock = Cent ' + #241 + ' ' // f�rs Ctrl-F5
        Else
            S1 := ' NumberBlock = Cent' + #241 + ' '// f�rs F5
    ;
    IniCenter (S1, 21);
    SndGetCentStr := S1;
End;
End.
