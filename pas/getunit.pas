{$I RNS.H}

Unit GetUnit;

Interface

Uses
    InitSc,
    graph;

Procedure GetLine(linenum, startx: integer);
Procedure GetDrawBlock(inblock: stringline; linenum: integer;
    lineattr: lineattrtype; startx, endx: integer;
    Var xfirst: integer);
Procedure GetNoteAttributes(Var inblock: stringline;
    Var lineattr: lineattrtype);
Procedure GetNoteBlock(Var inblock: stringline; Var lineattr: lineattrtype;
    linenum: integer);
Procedure GetNotePosX(Var x, notec: integer; linenum: integer;
    cursormove, left: boolean);
Procedure GetDrawBeats(lineattr: lineattrtype; linenum: integer);
Procedure GetDrawDistances(lineattr: lineattrtype; linenum, startx: integer);
Procedure GetActPosX(Var x, notec: integer; linenum: integer;
    cursormove: boolean);
Procedure GetClearLines(linenum: integer; Var lineup, linedown: integer);

Function GetDrawSymbol(linenum, actposn: integer; UpdateCursor: Boolean): Boolean;
Function GetValidStaff(Var linenum: integer): Boolean;
Procedure GetReDraw(linenum, startx, endx: integer);
Procedure GetDrawSystems(lineattr: lineattrtype; linenum: integer);

Implementation

Uses
    symbols,
    TitleUnit,
    GCurUnit,
    UtilUnit,
    PrintUnit,
    DmemUnit,
    ComUnit,
    NoteUnit,
    PageUnit;

{****************************************************************}
Procedure GetClearLines(linenum: integer; Var lineup, linedown: integer);
{sucht bis zur n�chsten Notenzeile rauf un runter nach Textzeilen
 mit Tabulatoren und setzt lineup auf die obere Zeile, linedown auf
 die unter}

Var
    i: integer;

Begin
    lineup := linenum - 2;
    i := lineup;
    While ((i >= topmargin) AND (page[i, 1] = 'T')) Do
    Begin
        If pos (chr (240), page[i]) > 0 Then
            lineup := i - 1{shift tab gefunden};
        i := i - 1;
    End;

    linedown := linenum + 1;
    i := linedown;
    While ((i <= pagelength) AND (page[i, 1] = 'T')) Do
    Begin
        If pos (chr (9), page[i]) > 0 Then
            linedown := i{shift tab gefunden};
        i := i + 1;
    End;
End;

{****************************************************************}
Procedure GetComputeX(Var inblock: stringline; Var xa, dx: integer;
    Var rxa: real);

Var
    rx: real;

Begin
    ActNumber := IniNextNumber (inblock);
    rx := dx / ActNumber;
    rxa := rxa + rx;
    xa := trunc (rxa * 1000 + 0.5) DIV 1000;
    If (xa > GetMaxX - GcuRightMargin) Then
        xa := getmaxX - gcurightmargin + 1;
End;


Procedure GetComputeXNoCorr(Var inblock: stringline; Var xa, dx: integer;
    Var rxa: real);

Var
    rx: real;

Begin
    ActNumber := IniNextNumber (inblock);
    rx := dx / ActNumber;
    rxa := rxa + rx;
    xa := trunc (rxa * 1000 + 0.5) DIV 1000;
End;

{****************************************************************}

Procedure GetNotePosX(Var x, notec: integer; linenum: integer;
    cursormove, left: boolean);
{Berechnen von xa und NoteCount f�r die Position x und plaziere Cursor
 Ist left true, so wird xa <= x, sonst wird es >= x}

Var
    rxa, rx: real;
    xa, dx, xmin: integer;
    inblock: stringline;
    lineattr: lineattrtype;

Begin
    inblock := page[linenum];
    GetNoteBlock (inblock, lineattr, linenum);
    dx := IniDxValue (lineattr);
    xa := IniFirstBeatPos (lineattr) - dx;
    rxa := xa;
    xmin := xa;
    If x < xa Then
    Begin
        x := xa;
        left := true;
    End;

    {inblock solange l�schen, bis xa > x wird}
    While ((length (inblock) > 0) AND (xa < x)) Do
        If IniNumChar (inblock[1]) Then
        Begin
            {Abstand berechnen}
            GetComputeXNoCorr (inblock, xa, dx, rxa);
            If xmin < IniLeftMargin Then
                xmin := xa;
            If x < xmin Then
                x := xmin;
        End Else
            delete (inblock, 1, 1);
    {Berechnen von Notec}
    Notec := length (Page[linenum]) - length (inblock);
    If ((left) AND (Xa > x)) Then
    Begin
        rx := dx / ActNumber;
        rxa := rxa - rx;
        xa := trunc (rxa);
        str (ActNumber, inblock);
        Notec := Notec - Length (inblock);
    End Else If length (inblock) > 0 Then
        notec := notec + 1;
    {Cursor plazieren, wenn verlangt}
    If cursormove Then
        GcuMoveCursor (Xa, IniYnow (linenum) + CharHeight);
    {x wird auf die aktuelle Position gesetzt}
    x := xa;
End;

{****************************************************************}
Procedure GetActPosX(Var x, notec: integer; linenum: integer;
    cursormove: boolean);
{Berechne von x in Abhaengigkeit von NoteCount x und plaziere Cursor}

Var
    rxa: real;
    xa, dx, xmin: integer;
    inblock: stringline;
    lineattr: lineattrtype;

Begin
    inblock := page[linenum];
    GetNoteBlock (inblock, lineattr, linenum);
    dx := IniDxValue (lineattr);
    xa := IniFirstBeatPos (lineattr) - dx;
    rxa := xa;
    xmin := xa;

    While ((length (Page[linenum]) - length (inblock)) < notec) AND (inblock <> '') Do
        If IniNumChar (inblock[1]) Then
        Begin
            {Abstand berechnen}
            GetComputeX (inblock, xa, dx, rxa);
            If xmin < IniLeftMargin Then
                xmin := xa;
        End Else
            delete (inblock, 1, 1);
    {Berechnen von Notec}
    Notec := length (Page[linenum]) - length (inblock);
    {Cursor plazieren, wenn verlangt}
    If cursormove Then
        GcuMoveCursor (Xa, IniYnow (linenum) + CharHeight);
    x := xa;
End;

{**************************************************************}
Procedure GetNoteAttributes(Var inblock: stringline;
    Var lineattr: lineattrtype);

Begin
    delete (inblock, 1, LineMarker);
    lineattr.beats := IniNextnumber (inblock);
    lineattr.eint  := IniNextNumber (inblock);
    lineattr.resolution := IniNextNumber (inblock);
    lineattr.linestyle := IniNextNumber (inblock);
    If lineattr.beats = 0 Then
        lineattr.beats := 1;
    If lineattr.linestyle = 0 Then
        lineattr.linestyle := 1;
End;

{**************************************************************}
Procedure GetNoteBlock(Var inblock: stringline; Var lineattr: lineattrtype;
    linenum: integer);

Var
    linblock, strbuf: stringline;

Begin
    linblock := copy (inblock, 1, linemarker);
    GetNoteAttributes (inblock, lineattr);

    {Notenlinie ins Page-Array schreiben}
    Str (lineattr.beats: 5, strbuf);
    linblock := linblock + strbuf;
    Str (lineattr.Eint: 5, strbuf);
    linblock := linblock + strbuf;
    Str (lineattr.resolution: 5, strbuf);
    linblock := linblock + strbuf;
    Str (lineattr.linestyle: 5, strbuf);
    linblock := linblock + strbuf;
    If linenum > 0 Then
    Begin
        page[linenum] := linblock + inblock;
        If lineattr.linestyle = 5 Then
            page[linenum, 5] := 'H'
        Else
            page[linenum, 5] := ' ';
    End;

    While ((length (inblock) > 0) AND (inblock[1] <> '%')) Do
        delete (inblock, 1, 1);
    delete (inblock, 1, 1);
End;

{**************************************************************}
Procedure GetLine(linenum, startx: integer);

Var
    xfirst: integer;
    inblock: stringline;
    lineattr: lineattrtype;

Begin
    SetColor (LColor);
    If (linenum >= 0) AND (linenum <= pagelim) AND (page[linenum, 1] = 'N') Then
    Begin
        inblock := page[linenum];
        GetNoteBlock (inblock, lineattr, linenum);
        { Draw Symbols }
        GetDrawBlock (inblock, linenum, lineattr, startx, grmaxx, xfirst);
        { Draw Distance Marks (Pulses) }
        GetDrawDistances (lineattr, linenum, xfirst);
        { Draw Beats/Lines }
        GetDrawBeats (lineattr, linenum);
        { Draw Notesystems }
        GetDrawSystems (lineattr, linenum);
    End;
End;

{**************************************************************}
Procedure GetDrawBlock(inblock: stringline; linenum: integer;
    lineattr: lineattrtype; startx, endx: integer;
    Var xfirst: integer);

Var
    rxa: real;
    xa, xl, dx, y, difx, dify: integer;
    sympary, sterny: integer;
    dummy: integer;
    vogelx: integer absolute y;
    i, height: integer;
    indexc, lastc, flamc, c: char;
    eklammerflam, rklammerflam, gflam: boolean;
    vogel: byte;
    QuotMark, Sternflam: boolean;
    tempstr: string;
    KlY, KlX: integer;
Begin
    quotmark := false;
    sternflam := false;
    vogel := 0; { kein � oder � }
    dx := IniDxValue (lineattr);
    xfirst := IniFirstBeatPos (lineattr);
    xa := IniFirstBeatPos (lineattr) - dx;
    xl := IniLeftMargin;
    rxa := xa;
    dify := 0;
    difx := 0;
    sympary := 0;
    sterny := 0;
    c  := ' ';
    lastc := ' ';
    height := 5;
    flamc := ' ';
    rklammerflam := false;
    eklammerflam := false;
    gflam := false;
    If inblock[1] = '"' Then
    Begin
        For i := 1 To length (inblock) Do
            If Ininumchar (inblock[i]) Then
                break;
        dec (i);
        If i > 1 Then
            delete (inblock, 1, i - 1);
        If quotmark Then
            inblock[1] := #154
        Else
            inblock[1] := '"';
        quotmark := true;
    End;
    While length (inblock) > 0 Do
        If IniNumChar (inblock[1]) Then
        Begin
            {Abstand berechnen}
            GetComputeX (inblock, xa, dx, rxa);
            difx := 0;
            dify := 0;
            sympary := 0;
            sterny := 0;
            sternflam := false;
            flamc := ' ';
            rklammerflam := false;
            eklammerflam := false;
            gflam := false;
            For i := 1 To length (inblock) Do
                If Ininumchar (inblock[i]) Then
                    break;
            dec (i);
            tempstr := copy (inblock, 1, i);
            If pos ('"', tempstr) <> 0 Then
            Begin
                If i > 1 Then
                    delete (inblock, 1, i - 1);
                If quotmark Then
                    inblock[1] := #154
                Else
                    inblock[1] := '"';
                quotmark := true;
            End Else
            If (pos ('.', tempstr) = 0) AND (pos (',', tempstr) = 0)
                {TESTING}
                AND (pos (' ', tempstr) = 0) AND (pos ('&', tempstr) = 0) Then
                {          quotmark:=false};
        End Else { if numchar(inblock[1]) }
        Begin
            { * * * * * * * * * * }
            vogelX := IniLineEnd (Page[linenum]);
            If xa > vogelX Then
                dummy := vogelX + 1
            Else If xa = vogelX Then
                dummy := vogelX
            Else
                dummy := xa;
            If dummy = vogelX Then
                vogel := 1
            Else If dummy = vogelX + 1 Then
                If vogel <> 2 Then
                Begin
                    If vogel = 0 Then
                        c := Chr (174)  // ¬ character
                    Else If vogel = 1 Then
                        c := Chr (175); // ¯ character
                    If vogelX = gmaxx Then
                        inc (vogelX);
                    TxtFnt.WriteChar (vogelX - 9, IniYnow (Linenum) - 13,
                        c, curcolor, sz8x16, stnormal);
                End;
            If xa > endx Then
                exit;
            { * * * * * * * * * * }
            If (xa > xl) AND (xa > startx) AND (xa < getmaxX - gcurightmargin) Then
            Begin
                c := inblock[1];
                y := IniYnow (linenum);
                Case c Of
                    ',': If length (inblock) > 1 Then
                            SymNichts (xa, y, rxa);
                    '.': SymAbsNichts (xa, y);
                    '/': Slash (xa, y, rxa);
                    '\': SymDotSlash (xa, y, rxa);
                    Chr (167): SymDotSlash2 (xa, y, rxa);
                    ' ': SymLeer (xa, y, rxa);
                    '&': SymEt (xa + difx, y, rxa);
                    '"': SymQuotMark (xa + difx, y, rxa);
                    #154: SymRepQuotMark (xa, y, rxa);
                    '{': SymGKlammerAuf (xa + difx - charwidth, y + dify, 5);
                    '}': SymGKlammerZu (xa + difx + charwidth, y + dify, 5);
                    '(': If flamc = ' ' Then
                        Begin
                            { Kleine Klammer unten }
                            UtiKlammerAufPos (inblock, difx, height, flamc);
                            SymNorKlammerAuf (xa + difx, y + sterny, height);
                        End Else
                        Begin
                            rklammerflam := true;
                            If inblock[3] = ')' Then
                            Begin
                                { kleine Klammer oben }
                                SymNorKlammerAuf (xa + difx - charwidth, y + sterny + dify, 5);
                                gflam := false;
                            End Else
                            Begin
                                { grosse Klammer }
                                gflam := true;
                                KlY := IniYNow (linenum) + 5 - (y + sterny + dify);
                                KlX := difx;
                                If difx > 0 Then
                                    SymNorKlammerAuf (xa - charwidth, IniYNow (linenum), KlY)
                                Else
                                    SymNorKlammerAuf (xa + difx - charwidth, IniYNow (linenum), KlY);
                            End;
                        End;
                    ')': If NOT rklammerflam Then
                        Begin
                            { kleine Klammer unten }
                            UtiKlammerZuPos (lastc, dummy, flamc);
                            SymNorKlammerZu (xa + difx + dummy, y + sterny + dify, height);
                        End Else
                        Begin
                            rklammerflam := false;
                            If gflam Then
                            Begin
                                { grosse Klammer }
                                gflam := false;
                                If KlY = 0 Then
                                    KlY := IniYNow (linenum) + 5 - (y + sterny + dify);
                                If KlX > 0 Then
                                    SymNorKlammerZu (xa + KlX + charwidth, IniYNow (linenum), KlY)
                                Else
                                    SymNorKlammerZu (xa + charwidth, IniYNow (linenum), KlY);
                                KlY := 0;
                            End Else
                                SymNorKlammerZu (xa + difx + charwidth, y + sterny + dify, 5){ kleine Klammer oben };
                        End;
                    '[': If flamc = ' ' Then
                        Begin
                            UtiKlammerAufPos (inblock, difx, height, flamc);
                            SymEckKlammerAuf (xa + difx, y, height);
                        End Else
                        Begin
                            eklammerflam := true;
                            SymEckKlammerAuf (xa + difx - charwidth, y, 5);
                        End;
                    ']': If NOT eklammerflam Then
                        Begin
                            UtiKlammerZuPos (lastc, difx, flamc);
                            SymEckKlammerZu (xa + difx, y, height);
                        End Else
                        Begin
                            eklammerflam := false;
                            SymEckKlammerZu (xa + difx + charwidth, y, 5);
                        End;
                    'a'..'z', 'A'..'Z', #128..#153:
                    Begin
                        If flamc = ' ' Then
                        Begin
                            difx := 0;
                            dify := 0;
                        End;
                        i := UtiComputeGroup (c, indexc);
                        If UtiReplaceChars (c) > 0 Then
                            lastc := c;
                        If i > 0 Then
                            sympary := -Sympar[indexc, 1, i];
                        If printeron Then
                            PriWriteSym (inblock[1], rxa + 1.0 * difx, 1.0 * (y + sympary + sterny + dify))
                        Else
                            DmeDispChar (xa + difx, y + sympary + sterny + dify, indexc, i);
                        If sternflam Then
                            UtiComputeDxdy (inblock[1], difx, sterny, 1, '*');
                        flamc := ' ';
                    End;
                    '+', '=', '-', '*':
                    Begin
                        If ((c = '*') AND (inblock[2] IN flamset)) Then
                        Begin
                            sternflam := true;
                            delete (inblock, 1, 1);
                            c := inblock[1];
                        End Else If ((c IN flamset) AND (inblock[2] = '*')) Then
                        Begin
                            sternflam := true;
                            delete (inblock, 2, 1);
                        End Else
                        Begin
                            sternflam := false;
                            sterny := 0;
                        End;
                        UtiComputeDxdy (inblock, difx, dify, 3, c);
                        flamc := c;
                        If sternflam Then
                        Begin
                            dify := -dify;
                            UtiComputeDxdy (inblock, dummy, sterny, 3, '*');
                        End;
                    End;
                End; { case inblock[1] of }
            End; {if xa > 15 ....}
            If ((xfirst > xa) AND (inblock[1] <> '.')) Then
            Begin
                xfirst := xa;
                If xfirst < grminx Then
                    xfirst := grminx;
            End;
            delete (inblock, 1, 1);
        End{ if numchar(inblock[1]) else}; { while length(inblock) > 0 do }
End;

{**************************************************************}
Function GetMainLine(lineattr: lineattrtype; linenum: integer): Boolean;

Var
    i: integer;

Begin
    i := linenum;
    If lineattr.linestyle > 1 Then
    Begin
        While ((i < pagelength) AND (page[i + 1, 1] = 'N')) Do
            Inc (i);
        While ((i > 1) AND (page[i, 5] = 'H')) Do
            Dec (i);
    End;
    GetMainLine := ((linenum = i) AND (page[i, 5] <> 'H'));
End;


{***************************************************************}
Procedure GetDrawBeats(lineattr: lineattrtype; linenum: integer);

Var
    dx, beatlength: integer;
    i, x0, x, y: integer;

Begin
    dx := IniDxValue (lineattr);
    { Zeichne Line und Beatmarken }
    x0 := IniLeftMargin + 1;
    y  := IniYnow (linenum);
    Case lineattr.linestyle Of
        1: MainLine (x0, y, GetMaxX - GcuRightMargin + drightmargin, tkwidth);
        2: SymStaffLine (x0, y, GetMaxX - GcuRightMargin + drightmargin);
        3: ThinLine (x0, y, GetMaxX - GcuRightMargin + drightmargin);
        4: SymDottedLine (x0, y, GetMaxX - GcuRightMargin + drightmargin);
        5: SymInvisibleLine (x0, y, GetMaxX - GcuRightMargin + drightmargin);
    End;
    If (lineattr.linestyle <> 5) Then { not a helpline }
    Begin
        x0 := IniFirstBeatPos (lineattr) - dx;
        Case lineattr.linestyle Of
            1: Beatlength := 12;
            2: Beatlength := 26;
            3, 4: If GetMainline (lineattr, linenum) Then
                    Beatlength := 12
                Else
                    Beatlength := 6;
        End;
        x := x0;
        i := pos ('%', page[linenum]);
        If page[linenum, i + 1] <> '.' Then
        Begin
            Beat (x, IniYnow (linenum), beatlength, false);
            If (dispgrid <> 3) OR (GetMainline (lineattr, linenum)) Then
                DistanceMark (x, IniYnow (linenum), x + dx, 0, lineattr.eint);
        End;
        For i := 1 To lineattr.beats Do
        Begin
            x := x + dx;
            Beat (x, IniYnow (linenum), beatlength, false);
            If (dispgrid <> 3) OR (GetMainline (lineattr, linenum)) Then
                DistanceMark (x, IniYnow (linenum), x + dx, 0, lineattr.eint);
        End;
{    GetNotePosX(x,notec,linenum,false,true);
    if ((length(page[linenum]) >= notec) and
        (page[linenum, notec] <> '.')) then
      Beat( x, IniYnow(linenum), beatlength, false);}
        If IniLineEnd (page[linenum]) < GMaxX Then
            Beat (IniLineEnd (page[linenum]), IniYnow (linenum), beatlength, true);

        { Grids im 0. beat zeichnen falls noetig }
        i := 1;
        Repeat
            inc (i);
        Until (i = length (page[linenum])) OR (page[linenum, i] = '%');
        inc (i);
        While (i <= length (page[linenum])) AND
            ((page[linenum, i] = '.') OR
                ((page[linenum, i] >= '0') AND (page[linenum, i] <= '9'))) Do
            inc (i);
        GetActPosX (x, i, linenum, false);
        If (x < x0 + dx) AND (i < length (page[linenum])) Then
            DistanceMark (x0, IniYnow (linenum), x0 + dx, x, lineattr.eint);

{   x:=x0-1;
    repeat
      i:=x;
      inc(x);
      GetNotePosX(x,notec,linenum,false,false);
    until (i=x) or (page[linenum,notec]<>'.') or (x>=x0+dx) or (notec=length(page[linenum]))
    or (((page[linenum,notec+1]<'0') or (page[linenum,notec+1]>'9')) and (page[linenum,notec+1]<>'.'));

    if (x<x0+dx) And ((dispgrid<>3) or (GetMainline(lineattr,linenum)))Then Begin
      DistanceMark(x0,IniYnow(linenum),x0+dx,x,lineattr.eint);
    End;
}
    End; {if lineattr.linestyle}
End;

{**************************************************************}
Procedure GetDrawDistances(lineattr: lineattrtype; linenum, startx: integer);

Begin
(*   if ((linenum <= pagelength) and
       (GetMainLine(lineattr, linenum) or (dispgrid = 2)) and
       (lineattr.eint > 1) and
       (lineattr.linestyle < 5) and
       (dispgrid > 1)) then
   begin
      rdx:= IniRDxValue(lineattr);

      { Zeichne Distanzmarken }
      rx0:= IniFirstBeatPos(lineattr) - rdx;
      y:=  IniYnow(linenum);

      for i:= 0 to lineattr.beats do
      begin

        DistanceMark(rx0,IniYnow(linenum),rx0+rdx,startx,lineattr.eint);
        rx0:=rx0+rdx;
      end;
   end;*)
End;

{***********************************************}

Function GetDrawSymbol(linenum, actposn: integer; UpdateCursor: Boolean): Boolean;
{Zeichne das Symbol in Page[linenum,actposn] an der (hoffentlich)richtigen
 Stelle, wenn UpdateCursor True ist, wird GCXCoord nachgef�hrt. Falls das
 Symbol ausserhalb des Bildschirmes liegt, liefert GetDrawSymbol False zur�ck}

Var
    rxa: real;
    xa, dx, xmin: integer;
    i: integer;
    c, c1: char;
    inblock: stringline;
    lineattr: lineattrtype;
    difx, dify: Integer;
Begin
    inblock := page[linenum];
    GetNoteBlock (inblock, lineattr, linenum);
    dx := IniDxValue (lineattr);
    xa := IniFirstBeatPos (lineattr) - dx;
    rxa := xa;
    xmin := xa;
    While ((length (Page[linenum]) - length (inblock)) < actposn) Do
        If (IniNumChar (inblock[1])) Then
        Begin
            {Abstand berechnen}
            GetComputeX (inblock, xa, dx, rxa);
            If xmin < IniLeftMargin Then
                xmin := xa;
        End Else
        Begin
            delete (inblock, 1, 1);
            If inblock = '' Then
            Begin
                GetDrawSymbol := True;
                Exit;
            End;
        End;
    {Berechnen von Notec}
    inblock := page[linenum];
    GetNoteBlock (inblock, lineattr, linenum);
    c := Page[Linenum, actposn];
    If Xa < GetMaxX Then
    Begin
        GetDrawSymbol := True;
        If updatecursor Then
            gcxcoord := Xa;
    End Else
    Begin
        GetDrawSymbol := False;
        Exit;
    End;
    i := actposn;
    While (NOT (IniNumChar (page[linenum, i - 1]) OR
            (IniPrintNote (page[linenum, i - 1]))))
        AND (i >= commusicstart (page[linenum])) Do
        dec (i);
    Repeat
        c1 := page[linenum, i];
        inc (i);
    Until (c1 = '+') OR (c1 = '-') OR (c1 = '=') OR (c1 = '*') OR (i >= actposn);
    If (c1 = '+') OR (c1 = '-') OR (c1 = '=') OR (c1 = '*') Then
        UtiComputeDxdy (page[linenum], difx, dify, actposn, c1)
    Else
    Begin
        difx := 0;
        dify := 0;
    End;
    i := UtiComputeGroup (c, c);
    Case C Of
        ',': SymNichts (xa + difx, IniYnow (linenum) + dify, rxa);
        ' ': SymLeer (xa + difx, IniYnow (linenum) + dify, rxa);
        '/': Slash (xa + difx, IniYnow (linenum) + dify, rxa);
        '\': SymDotSlash (xa + difx, IniYnow (linenum) + dify, rxa);
        Chr (167): SymDotSlash2 (xa + difx, IniYnow (linenum) + dify, rxa);
        '.': ;
        '&': SymEt (xa + difx, IniYnow (linenum) + dify, rxa);
        '"': SymQuotMark (xa + difx, IniYnow (linenum) + dify, rxa); {bei & abgeschr., Peo}
    Else
        DmeDispChar (Xa + difx, IniYnow (linenum) - Sympar[c, 1, i] + dify, c, i);
    End;{Case}
End;

{***********************************************}

Function GetValidStaff(Var linenum: integer): Boolean;
Var
    i, ii, j: integer;
    s: Stringline;
    lineattr: lineattrtype;

Begin
    If page[linenum, 1] = 'N' Then
    Begin
        s := page[linenum];
        getnoteattributes (s, lineattr);
    End Else
        lineattr := actattr{IF page[linenum,1]='N'};{IF page[linenum,1]='N' Else}
    If lineattr.linestyle <> 2 Then
    Begin
        GetValidstaff := True;
        Exit;
    End;{IF lineattr.linestyle<>2}
    If linenum < CtrlEnterOfs - 1 Then
    Begin
        GetvalidStaff := False;
        Exit;
    End;{IF linenum<CtrlEnterOfs-1}
    If (linenum > pagelength) OR (linenum < 4) Then
    Begin
        getvalidstaff := true;
        exit;
    End;
    For i := linenum Downto linenum - 4 Do
        If Page[i, 1] = 'N' Then
        Begin
            j := i + 1;
            For ii := j To j + 8 Do
                If (ii <= pagelength) AND (Page[ii, 1] = 'N') Then
                Begin
                    If ii >= j + 4 Then
                    Begin
                        s := page[ii];
                        GetNoteAttributes (s, lineattr);
                        If lineattr.linestyle <> 2 Then
                        Begin
                            linenum := ii;
                            GetValidStaff := True;
                            Exit;
                        End Else
                        Begin{if lineattr.linestyle<>2}
                            GetvalidStaff := False;
                            Exit;
                        End;{if lineattr.linestyle<>2 Else}
                    End Else
                    Begin{if ii>=j+5}
                        GetvalidStaff := False;
                        Exit;
                    End;{if ii>=j+5 else }
                End {if page[ii,1]='N'}Else If i > pagelength Then
                Begin
                    GetValidstaff := false;
                    exit;
                End;{For ii:=j to j+10}
            linenum := j + 5;
            GetValidStaff := True;
            Exit;
        End{IF Page[i,1]='N'};{For i:=linenum downto linenum-5}
    If linenum > pagelength Then
        linenum := pagelength;
End;


Procedure GetReDraw(linenum, startx, endx: integer);
Var
    i, xfirst: integer;
    inblock: stringline;
    lineattr: lineattrtype;
Begin
    For i := linenum - 2 To linenum + 5 Do
        If (i >= 0) AND (i <= pagelim) Then
            If page[i, 1] = 'N' Then
            Begin
                inblock := page[i];
                GetNoteBlock (inblock, lineattr, i);
                GetDrawBlock (inblock, i, lineattr, startx, endx, xfirst);
                If lineattr.linestyle = 2 Then
                    GetDrawBeats (lineattr, i);
            End Else
                TitGetText (i, startx);
End;

{***********************************************}
Procedure GetDrawSystems(lineattr: lineattrtype; linenum: integer);
Var
    offs: integer;
Begin
    If lineattr.linestyle = 2 Then
        offs := -20
    Else
        offs := 0;
    If printeron Then
    Begin
        If page[linenum, 2] = 'S' Then
        Begin
            PriSetLineWidth (2);
            If NotFindSysEnd (linenum) = linenum Then
                PriDrawLine (1, IniYNow (linenum) + offs, 1, IniYNow (linenum) + 5)
            Else
            Begin
                PriDrawLine (1, IniYNow (linenum) + offs, 1, IniYNow (NotFindSysEnd (linenum)));
            End;
        End Else If page[linenum, 2] = 'E' Then
        Begin
            PriSetLineWidth (2);
            PriDrawLine (1, IniYNow (linenum) - 5, 1, IniYNow (linenum));
        End;
    End Else If page[linenum, 2] = 'S' Then
    Begin
        If NotFindSysEnd (linenum) = linenum Then
        Begin
            Line (2, IniYNow (linenum) + offs, 2, IniYNow (linenum) + 5);
            Line (3, IniYNow (linenum) + offs, 3, IniYNow (linenum) + 5);
        End Else
        Begin
            Line (2, IniYNow (linenum) + offs, 2, IniYNow (NotFindSysEnd (linenum)));
            Line (3, IniYNow (linenum) + offs, 3, IniYNow (NotFindSysEnd (linenum)));
        End;
    End Else If page[linenum, 2] = 'E' Then
    Begin
        Line (2, IniYNow (linenum) - 5, 2, IniYNow (linenum));
        Line (3, IniYNow (linenum) - 5, 3, IniYNow (linenum));
    End;
End;

Begin
End.
