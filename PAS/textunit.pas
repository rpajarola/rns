{$I RNS.H}

Unit textunit;

Interface

Uses
    initsc,
    gcurunit,
    symbols,
    graph,
    Pageunit;

Procedure TexDelChar(linenum: integer; Var actpos: integer);
Procedure TexInsChar(linenum, actpos: integer);
Procedure TexEdTextLine(linenum: integer; Var actpos: integer; c: char);
Procedure TexDrawLine(linenum, startx: integer);
Procedure TexTxtPosX(Var x, actpost: integer; linenum: integer;
    cursormove: boolean);
Procedure TexActPosX(Var x, actpost: integer; linenum: integer;
    cursormove: boolean);
Procedure TexEndVKlammer(linenum, actpos, x: integer);
Procedure TexEndHKlammer(linenum: integer; actpos: integer);
Function TexTabWidth(x, linenum, ordc: integer;
    cursormove: boolean; Var xnote, totw: integer): integer;
Procedure TexDelToEOL(linenum, actpos: integer);
Procedure TexClearLine(linenum, startx: integer);
Procedure TexWordLeft(Var Linenum, Actpos: Integer);
Procedure TexWordRight(Var Linenum, Actpos: Integer);
Function TexGetText(Linenum: Integer): String;
Procedure TexSetText(Linenum: Integer; S: String);
Implementation

Uses getunit,
    printunit,
    titleunit;
Const yshift = -3.0;

{******************************************************}
Procedure TexDelToEOL(linenum, actpos: integer);
Var x: integer;
Begin
    Delete (page[linenum], actpos + 1, length (page[linenum]));
    page[linenum, actpos] := ' ';
    TexActPosX (x, actpos, linenum, false);
End;

Procedure TexEndHKlammer(linenum: integer; actpos: integer);
{Ende einer waagrechten Klammer}
Var XE, XS, XM: integer;
    Y: integer;
    PS: integer;
    found: boolean;
Begin
    IniCharAdd (Page[linenum], #232, actpos);
    y := IniYnow (linenum) - 2;
    TexActPosX (xe, actpos, linenum, false);
    { suche Beginn der Klammer }
    Found := False;
    For PS := ActPos - 1 Downto LineMarker Do
        If page[linenum, PS] = #231 Then
        Begin
            Found := True;
            Break;
        End;
    { fÅlle Zeichen fÅr Klammer ein }
    If printeron AND found Then
    Begin
        TexActPosX (XS, PS, linenum, false);
        PriHorizontalKlammer (XS - 4, XE + 4, y + 4);
    End Else Begin
        SymHKlammerEnd (xe, y);
        If found Then
        Begin
            TexActPosX (XS, PS, linenum, false);
            SetLineStyle (solidln, 0, 1);
            Line (XS + 4, y + 4, XE - 4, y + 4);
            xm := (XS + XE) SHR 1;
            If (XE - XS) < 8 Then SymHKlammerSmallMid (xm, y){ Klammern zu nahe beieinander } Else SymHKlammerNormMid (xm, y);
        End;
    End;
End;
{******************************************************}
Procedure TexEndVKlammer(linenum, actpos, x: integer);
{Ende einer senkrechten Klammer}
Var sline, midline, i: byte;
    foundflag: boolean;
Begin
    SetLineStyle (solidln, 0, 1);
    IniCharAdd (Page[linenum], chr (230), actpos);
    sline := linenum;
    foundflag := false;
    {suche Beginn der Klammer}
    Repeat
        If ((page[sline, 1] = 'T') AND
            (length (page[sline]) >= actpos) AND
            (page[sline, actpos] = chr (229))) Then foundflag := true Else dec (sline);
    Until ((foundflag) OR (sline < topmargin));
    {fÅlle Zeichen fÅr Klammer ein}
    If foundflag Then
    Begin
        TexActPosX (x, actpos, linenum, false);
        midline := (sline + linenum) SHR 1;
        For i := (sline + 1) To midline - 1 Do
            If abs (sline - linenum) > 2 Then SymVKlammerCont (x - 8, IniYnow (i));
        If ((2 * midline) = (sline + linenum)) Then
        Begin
            SymVKlammerEvenMid (x - 1, IniYnow (midline));
            If abs (sline - linenum) > 2 Then
                SymVKlammerCont (x - 8, IniYnow (midline + 1));
        End Else Begin
            If abs (sline - linenum) > 2 Then
                SymVKlammerCont (x - 8, IniYnow (midline));
            SymVKlammerOddMid (x - 1, IniYnow (midline) + 4);
        End;
        If abs (sline - linenum) > 2 Then
            For i := midline + 2 To linenum - 1 Do SymVKlammerCont (x - 8, IniYnow (i));
        If printeron Then PriVerticalKlammer (x, IniYnow (linenum - 1) + linethick DIV 2,
                IniYnow (sline + 1) - linethick DIV 2);
    End Else inc (x, 4);
    If abs (sline - linenum) > 2 Then
        SymVKlammerEnd (x - 1, IniYnow (linenum))
    Else Begin
        PutPixel (x + 3, IniYnow (linenum) - 4, getcolor);
        PutPixel (x + 4, IniYnow (linenum) - 4, getcolor);
        PutPixel (x + 4, IniYnow (linenum) - 3, getcolor);
        PutPixel (x + 5, IniYnow (linenum) - 3, getcolor);
    End;
End;

{***************************************************************}
Procedure TexHorizontalLine(linenum, x: integer);
Var oldcolor: byte;
Begin
    If printeron Then MainLine (IniLeftMargin, IniYnow (linenum) + 1,
            GetMaxX - GcuRightMargin + drightmargin, hlwidth) Else Begin
        oldcolor := GetColor;
        SetColor (12);
        MainLine (IniLeftMargin, IniYnow (linenum) + 1,
            GetMaxX - GcuRightMargin + drightmargin, hlwidth);
        SetColor (5);
        MainLine (IniLeftMargin, IniYnow (linenum) + 2,
            GetMaxX - GcuRightMargin + drightmargin, hlwidth);
        If dispspec = 1 Then
        Begin
            SetColor (speccolor);
            line (x + 2, IniYnow (linenum), x + 6, IniYNow (linenum));
        End;
        SetColor (oldcolor);
    End;
End;

{***************************************************************}
Procedure TexVerticalLine(linenum, x: integer; hfinclude: boolean; threeD: Boolean);
Var y0, y1, i: integer;
    oldcolor:  byte;
Begin
    If hfinclude Then
    Begin
        y0 := 1;
        y1 := IniYBottomMargin;
    End Else Begin
        i := linenum;
        While ((i >= 0) AND (pos (chr (233), page[i]) = 0)) Do
            dec (i);
        If i <= 0 Then y0 := 1 Else If printeron Then
            y0 := IniYnow (i) + 1
        Else
            y0 := IniYnow (i) + 3;
        i := linenum;
        While ((pos (chr (233), page[i]) = 0) AND (i <= pagelength)) Do
            inc (i);
        y1 := IniYnow (i) + 2;
        If y1 > IniYBottomMargin Then
            y1 := IniYBottomMargin;
    End;

    If printeron Then
    Begin
        If threeD Then
            PriSetLineWidth (vlwidth)
        Else
            PriSetLineWidth (pswidth);
        If y0 <= 1 Then
            y0 := 0;
        If y1 >= IniYBottomMargin - 1 Then
            y1 := IniYBottomMargin + 1;
        PriDrawLine (x + 1, y0, x + 1, y1 - 1);
    End Else Begin
        oldcolor := GetColor;
        If threeD Then
        Begin
            SetColor (12);
            SetLineStyle (Solidln, 1, 0);
            line (x + 1, y0 - 1, x + 1, y1);
            SetColor (5);
            SetLineStyle (Solidln, 1, 0);
            line (x + 2, y0, x + 2, y1 - 1);
        End Else Begin
            SetColor (lcolor);
            SetLineStyle (4, $AAAA, 1);
            Line (x + 1, y0 - 1, x + 1, y1);
        End;
        SetColor (oldcolor);               {fÅr vertikale 3D-Linie}

        If dispspec = 1 Then
        Begin
            oldcolor := GetColor;
            SetColor (speccolor);
            line (x, IniYnow (linenum), x, IniYNow (linenum) - 4);
            SetColor (oldcolor);
        End;
    End;
End;

{****************************************************************}
Procedure TexTxtPosX(Var x, actpost: integer; linenum: integer;
    cursormove: boolean);
Var inblock: stringline;
    xa, lxa, xnote: integer;
    totw: integer;
Begin
    While length (page[linenum]) < (linemarker + 1) Do page[linenum] := page[linenum] + ' ';
    inblock := page[linenum];
    delete (inblock, 1, linemarker);
    xa := textmargin;
    If x < xa Then x := xa + 1;
    If x > GetMaxX - Gcurightmargin Then x := GetMaxX - Gcurightmargin;
    If ((linestyles IN actedit) AND (x > (IniLeftMargin + labellength * 6))) Then x := IniLeftMargin + labellength * 6;
    Repeat
        lxa := xa;
        If length (inblock) = 0 Then
        Begin
            inblock := ' ';
            page[linenum] := page[linenum] + ' ';
        End;
        If NOT IniTabChar (inblock[1]) Then xa := xa + 6 Else xa := xa + TexTabWidth (xa, linenum, ord (inblock[1]), false, xnote, totw);
        If (xa > GetMaxX - GcuRightMargin) Then
            xa := GetMaxX - GcuRightMargin;
        delete (inblock, 1, 1);
    Until xa >= x;
    xa := (xa + lxa) DIV 2;
    actpost := length (page[linenum]) - length (inblock);
    If cursormove Then
        GcuMoveCursor (xa, IniYnow (linenum) + CharHeight + 2);
    x := xa;
End;

{****************************************************************}
Procedure TexActPosX(Var x, actpost: integer; linenum: integer;
    cursormove: boolean);
{Berechnet x in Funktion von ActPost}
Var inblock: stringline;
    temppos, dx, xnote: integer;
    totw: integer;
Begin
    temppos := linemarker + 1;
    If actpost < temppos Then actpost := temppos;
    If ((linestyles IN actedit) AND
        (actpost > labellength + linemarker)) Then actpost := labellength + linemarker;
    While length (page[linenum]) < actpost Do
        page[linenum] := page[linenum] + ' ';
    inblock := page[linenum];
    delete (inblock, 1, linemarker);
    x := textmargin - 8;
    dx := 6;
    While (temppos < actpost) AND (x <= GetMaxX - GcuRightMargin) Do
    Begin
        If length (inblock) = 0 Then
            inblock := ' ';
        If NOT IniTabChar (inblock[1]) Then dx := 6 Else dx := TexTabWidth (x + 8, linenum, ord (inblock[1]), false, xnote, totw);
        If inblock[1] = #235 Then
            Inc (x, 2 * dx);
        x := x + dx;
        Inc (temppos);
        delete (inblock, 1, 1);
    End;
    actpost := temppos;
    If (x > GetMaxX - GcuRightMargin) Then
        x := GetMaxX - GcuRightMargin;
    x := x + 12;
    If cursormove Then GcuMoveCursor (x, IniYnow (linenum) + CharHeight + 2);
End;

{****************************************************************}
Procedure TexClearLine(linenum, startx: integer);
Var y, endx: integer;
Begin
    If startx <= 0 Then
        startx := 1;
    IniTrailBlank (page[linenum]);
    endx := GetMaxX - GcuRightMargin;
    If (endx > startx) Then
    Begin
        y := IniYnow (linenum);
        If startx < Textmargin Then
            startx := Textmargin;
        startx := startx + 4;
        If startx < endx Then
        Begin
            IniSetViewPort (startx, y - 6,  {weil Tabs links zuviel wegfrassen! ???}
                endx, y + 4);
            ClearViewPort;
            SetViewPort (0, 0, GetMaxX, GetMaxY, true);
        End;
    End;
End;

{****************************************************************}
Function TexTabWidth(x, linenum, ordc: integer;
    cursormove: boolean; Var xnote, totw: integer): integer;
{x          = ab welcher spalte suchen?
 linenum    = ab welcher Zeile suchen?
 ordc       = tabulatorzeichen (240 oder 9)
 cursormove = cursor update?
 xnote      = position der Note
 totw       = insgesamt breite des Tabulators
 return: tabwidth

 Berechnet die Position des naechsten Notenzeichens in der
 zu liennum naechstoberen Notenzeile, beginnend mit x. Ist cursormove
 true, so wird der cursor in x-Richtung auf diese Position verschoben.
 Die y-koordinate bleibt unverÑndert.
 Der Funktionswert wird gleich der Schrittweite des Tabulators}
Var i: byte;
    notec, result: integer;
Begin
    {Suche Notenzeile}
    If ordc < 200 Then
    Begin      { normaler Tabulator    }
        i := linenum - 1;
        While ((i >= topmargin) AND (page[i, 1] <> 'N')) Do
            dec (i);
    End Else Begin                { geshifteter Tabulator }
        i := linenum + 1;
        While ((i <= pagelength) AND (page[i, 1] <> 'N')) Do
            i := i + 1;
    End;
    If ((i < topmargin) OR (i > pagelength)) Then result := 6{Keine Notenzeile gefunden}{ standard charwidth } Else Begin
        xnote := x + 4;
        GetNotePosX (xnote, notec, i, false, false);
        If xnote < x Then
        Begin
            {Keine Noten rechts der gegenwaertigen Position}
            result := 6;
            totw := 6;
        End Else Begin
            totw := xnote - x - 3;
            result := totw MOD 6;
        End;
        If result = 0 Then
            result := 6;
    End;
    TexTabWidth := result - 1;
    If cursormove Then GcuMoveCursor (xnote - 12, gcycoord);
End;

{******************************************************************}
Function TexWordEnd(Var inblock: stringline; ipos: byte): boolean;
    {true wenn ipos das zweite Zeichen von einem Doppelblank bzw. tab ist}
Begin
    TexWordEnd := (((inblock[ipos] = ' ') AND
        (inblock[ipos - 1] <= ' ')) OR
        (NOT IniPrintChar (inblock[ipos])) OR
        (ipos > length (inblock)));
End;

{****************************************************************}
Procedure TexOctVal(ordc: byte; Var strbuf: string4; Var i: byte);
Begin
    i := 4;
    strbuf := ' ';
    Case ordc Of
        040: strbuf := '\050'; {'('}
        041: strbuf := '\051'; {')'}
        092: strbuf := '\134'; {'\'}
        123: strbuf := '\173'; (*'{'*)
        125: strbuf := '\175'; (*'}'*)

        132: strbuf := '\204'; {'Ñ'}
        142: strbuf := '\216'; {'é'}
        133: strbuf := '\205'; {'Ö'}
        160: strbuf := '\240'; {'†'}
        131: strbuf := '\203'; {'É'}
        134: strbuf := '\206'; {'Ü'}
        143: strbuf := '\217'; {'è'}
        130: strbuf := '\202'; {'Ç'}
        144: strbuf := '\220'; {'ê'}
        138: strbuf := '\212'; {'ä'}
        136: strbuf := '\210'; {'à'}
        137: strbuf := '\211'; {'â'}

        139: strbuf := '\213'; {'ã'}
        161: strbuf := '\241'; {'°'}
        141: strbuf := '\215'; {'ç'}
        140: strbuf := '\214'; {'å'}
        152: strbuf := '\230'; {'ò'}

        148: strbuf := '\224'; {'î'}
        153: strbuf := '\231'; {'ô'}
        162: strbuf := '\242'; {'¢'}
        149: strbuf := '\225'; {'ï'}
        147: strbuf := '\223'; {'ì'}

        129: strbuf := '\201'; {'Å'}
        154: strbuf := '\232'; {'ö'}
        163: strbuf := '\243'; {'£'}
        151: strbuf := '\227'; {'ó'}
        150: strbuf := '\226'; {'ñ'}

        126: strbuf := '\176'; {'~'}
        164: strbuf := '\244'; {'§'}
        165: strbuf := '\245'; {'•'}

        168: strbuf := '\250'; {'®'}
        173: strbuf := '\255'; {'≠'}
        174: strbuf := '\256'; {'Æ'}
        175: strbuf := '\257'; {'Ø'}

        135: strbuf := '\207'; {'á'}
        128: strbuf := '\200'; {'Ä'}

        225: strbuf := '\341'; {'·'}

        179: strbuf := '\263'; {'≥'}
        196: strbuf := '\304'; {'ƒ'}
        221: strbuf := '\335'; {'›'}

        248: strbuf := '\370'; {'¯'}
        21: strbuf  := '\025'; {''}

    Else
    Begin
        If ordc < 200 Then strbuf := chr (ordc);
        i := 1;
    End;
    End;
End;

{****************************************************************}
Procedure TexGetString(linenum, istart, x, xnote: integer;
    Var inote, iprint: integer; Var inblock: stringline);
{ linenum= line in page[]
  istart = ab hier suchen
  x      = pixpos von page[linenum,istart]
  xnote  = pixpos des zu zentrierenden Zeichens
  inote  = Index in inblock von Zeichen an pixpos xnote
  iprint = wird um length(inblock) INKREMENTIERT (<>length(inblock)!!!)
  inblock= nÑchstes wort nach page[linenum,istart]
}
Var i, xp, xn, tw: integer;
    {************************}
    Function GoOn: Boolean;
    Begin
        GoOn := length (page[linenum]) >= (istart + i);
    End;
    {************************}
    Procedure AddChar(incinote: boolean);
    Var idiff: byte;
        strbuf: string4;
    Begin
        TexOctval (Byte (page[linenum, istart + i]), strbuf, idiff);
        inblock := inblock + strbuf;
        If incinote Then
            inote := inote + idiff;
        inc (i);
        inc (iprint);
    End;
    {******************************}
Begin
    inc (istart);
    inblock := '';
    i := 0;
    inote := 1;{leading blanks zaehlen}
    xp := x + 5;
    While (GoOn AND (page[linenum, istart + i] = ' ') AND (xnote >= xp)) Do
    Begin
        inc (i);
        inc (iprint);
        xp := xp + 6;
    End;
    {Zeichen bis und mit der Position xnote in inblock lesen}
    While ((GoOn) AND (xnote >= xp)) Do
    Begin
        If (page[linenum, istart + i] = #9) OR (page[linenum, istart + i] = #240) Then
            Inc (xp, TexTabWidth (xp, linenum, byte (page[linenum, istart + i]), false, xn, tw))
        Else
            inc (xp, 6);
        AddChar (true);
    End;
    {Bis zum naechsten Blank in inblock lesen}
    While (NOT TexWordEnd (page[linenum], istart + i)) Do AddChar (false);
    If inblock = '' Then
        inote := 0;
End;

{****************************************************************}
Procedure TexDrawLine(linenum, startx: integer);

Var i, iprint, x, y, stringlength, xnote, inote: integer;
    ordc, ib: byte;
    inblock, strbuf: stringline;
    done, printit: boolean;
    ih, totw, j: integer;
    {*****************************************}
    Procedure PrintChar;
    {schreibt ein Zeichen}
    Var strbuf: string4;
        ordc: byte;
    Begin
        If printit Then
        Begin
            inblock := '';
            While (NOT TexWordEnd (page[linenum], iprint + linemarker)) Do
            Begin
                ordc := ord (page[linenum, iprint + linemarker]);
                TexOctval (ordc, strbuf, ib);
                inblock := inblock + strbuf;
                inc (iprint);
            End;{while (not TexWordEnd(page[linenum],iprint+linemarker))}
            If inblock <> '' Then PriPlaceString (PriXScale (x), PriYScale (y) + yshift,
                    inblock);{if inblock<>''}
        End;{if printit}
    End;{subproc PrintChar}
    {*******************************}
Begin
    x := textmargin;
    y := IniYnow (linenum);
    If ((linestyles IN actedit) AND (linenum > topmargin) AND
        (page[linenum - 1, 1] = 'N')) Then
        IniExpand (page[linenum], linemarker + labellength);
    stringlength := length (page[linenum]) - linemarker;
    i := 1;
    iprint := 1;
    While i <= stringlength Do
    Begin
        If iprint < i Then
            iprint := i;
        printit := (printeron AND (iprint = i));
        If (x <= GetMaxX - Gcurightmargin) Then
        Begin
            ordc := byte (page[linenum, i + LineMarker]);
            done := true;
            Repeat
                Case ordc Of
                    32: ;{ignore}
                    smallblankup,
                    smallblankdown:
                    Begin
                        ih := TexTabWidth (x, linenum, ordc, false, xnote, totw);
                        x  := x + ih;
                        If x > startx - 8 Then
                        Begin
                            If ordc = smallblankup Then
                                SymTabSymbol (x, y)
                            Else
                                SymTabSymbolDown (x, y);
                            If printit Then
                            Begin{Ausdrucken?}
                                inc (iprint);
                                TexGetString (linenum, i + linemarker,
                                    x, xnote, inote, iprint,
                                    inblock);
                                If inote > 0 Then
                                Begin
                                    strbuf := Copy (inblock, 1, inote);
                                    PriLeftString (strbuf, PriRXscale (xnote),
                                        PriRYScale (y) + yshift);
                                    If inote < length (inblock) Then
                                    Begin
                                        strbuf := Copy (inblock, inote + 1,
                                            length (inblock));
                                        PriComplString (strbuf);
                                    End;{if inote<length(inblock)}
                                End Else {if inote>0} PriPlaceString (PriXScale (xnote),
                                        PriYScale (y) + yshift,
                                        inblock); {if inote>0 else }
                            End; {if printit}
                        End;{if x>startx}
                    End;{case of smallblankup/down}
(*          129, 132, 148, 139: {Å,Ñ,î,ã} begin
            if x>startx then begin
              PrintChar;
              if ordc = 129 then ordc:= byte('u');
              if ordc = 132 then ordc:= byte('a');
              if ordc = 148 then ordc:= byte('o');
              if ordc = 139 then ordc:= byte('i');
              done:= false;
              if ((not (linestyles in actedit)) or
                  (linenum < linestyletop)) then
                col:= lcolor
              else
                col:= ilcolor;
              SetColor(col);
              Line(x + 1, y - 4, x + 2, y - 4);
              Line(x + 4, y - 4, x + 5, y - 4);
              SetColor(lcolor);
            end;{if x>startx}
          end;{case of ue,ae,oe}*)
                    229: {start senkrechte Klammer} SymVKlammerStart (x, y);
                    230: {beende senkrechte Klammer}TexEndVKlammer (linenum, i + linemarker, x);
                    231: {start waagrechte Klammer}SymHKlammerStart (x, y);
                    232: {beende waagrechte Klammer}TexEndHKlammer (linenum, i + linemarker);
                    233: {Horizontale Linie}TexHorizontalLine (linenum, x);
                    234: {Verticale Linie}TexVerticalLine (linenum, x + char2width - 1, true, false);
                    235: {Seitennummer}Begin
                        If setuppage IN actedit Then
                            inblock := '...'
                        Else
                            Str (pagecount: 3, inblock);
                        If printit Then
                        Begin
                            j := 0;
                            While inblock[1] = '' Do
                            Begin
                                delete (inblock, 1, 1);
                                Inc (j, 6);
                            End;
                            PriPlaceString (PriXScale (x + j),
                                PriYScale (y) + yshift,
                                inblock);
                            iprint := iprint + 1;
                        End {if printit}Else Begin
                            txtfnt.write (x + 1, y, inblock, getcolor, sz6x12, stnormal);
                            If dispspec = 1 Then
                            Begin
                                j := 1;
                                While (j <= 3) AND (inblock[j] = ' ') Do
                                Begin
                                    txtfnt.write (x + 1, y, '0', speccolor, sz6x12, stnormal);
                                    inc (x, 6);
                                    inc (j);
                                End;{while (j<=3) and (inblock[j]=' ')}
                            End;{if dispspec=1}
                        End;{if printit else}
                    End;
                    236: {Verticale Linie ohne bis zu einer Horizontalen}TexVerticalLine (linenum, x + char2width - 1, false, false);
                    237: {Verticale Linie ohne bis zu einer Horizontalen: 3D resp. voll}
                        TexVerticalLine (linenum, x + char2width - 1, false, true);
                Else{case}If x > startx Then
                    Begin
                        If ((NOT (linestyles IN actedit)) OR
                            (linenum < linestyletop)) Then
                        Begin
                            txtfnt.write (x + 1, y, chr (ordc), getcolor, sz6x12, stnormal);
                            If done Then
                                PrintChar;
                        End{if ((not (linestyles in actedit))} Else If page[linenum - 1, 1] = 'N' Then
                            IniInversWrite (x, y + 1, page[linenum, i + LineMarker], frHigh);{if ((not (linestyles in actedit)) else}
                        done := true;
                    End;{case else}
                    {if x>startx}End;{case}
            Until done;
            If NOT IniTabChar (page[linenum, i + LineMarker]) Then
                x := x + 6;
            If x > GetMaxX - Gcurightmargin Then
                x := GetMaxX - Gcurightmargin;
        End; { if x < GetMaxX - Gcurightmargin then }
        inc (i);
    End; { while i <= stringlength do }
End;{proc texdrawline}

{****************************************************************}
Procedure TexEdTextLine(linenum: integer; Var actpos: integer; c: char);
Var x, ordc, i, j, blanks, maxchr, totw: integer;
Begin
    If (linestyles IN actedit) Then maxchr := labellength + linemarker Else maxchr := Stlength;
    ordc := ord (c);
    If ordc = 8 Then
    Begin
        If actpos > 1 Then
        Begin
            If actpos <= 11 Then
                Exit;
            actpos := actpos - 1;
            x := gcxcoord - charwidth;
            TexClearLine (linenum, x - 13);
            If (actpos <= length (page[linenum])) Then IniCharAdd (Page[linenum], chr (32), actpos);
            GetRedraw (linenum, grminX, grmaxX);
            TexActPosX (x, actpos, linenum, true);
        End;
    End Else If ((length (Page[linenum]) <= maxchr) AND
        (actpos <= maxchr)) Then
    Begin
        x := gcxcoord {- 6} - 3;
        If ((NOT IniTabChar (page[linenum, actpos])) AND
            (NOT IniTabChar (c))) Then IniClrCharField (x, IniYnow (linenum)) Else TexClearLine (linenum, x - char2width);
        IniCharAdd (Page[linenum], c, actpos);
        GetRedraw (linenum, x - 9, x + 9); {x+7?}
        actpos := actpos + 1;
        If IniTabChar (c) Then
        Begin
            i := TexTabWidth (x, linenum, ord (c), true, j, totw);
            {Anzahl Blanks berechnen}
            blanks := (totw DIV 6);
            actpos := actpos + blanks;
            blanks := blanks - (length (page[linenum]) - actpos);
            If (length (page[linenum]) + blanks) > maxchr Then
            Begin
                blanks := maxchr - length (page[linenum]);
                actpos := maxchr;
            End;
            For i := 1 To blanks Do page[linenum] := page[linenum] + ' ';
        End;
        TexActPosX (x, actpos, linenum, true);
    End{if length(Page[linenum]) < StLength }; {else if ordc = 8}
End;

{****************************************************************}
Procedure TexInsChar(linenum, actpos: integer);

Var StringLength, i: integer;
    x: integer;

Begin
    If ((NOT (linestyles IN actedit)) OR
        (length (page[linenum]) < (labellength + linemarker))) Then
    Begin
        x := gcxcoord - 2 * CharWidth;
        If Pos (chr (smallblankup), page[linenum]) > 0 Then x := grminx;
        If Pos (chr (smallblankdown), page[linenum]) > 0 Then x := grminx;
        TexClearLine (linenum, x);
        StringLength := Length (page[Linenum]) - LineMarker;
        If StringLength < StLength Then
        Begin
            page[Linenum] := page[Linenum] + ' ';
            StringLength  := StringLength + 1;
        End;
        For i := StringLength + LineMarker Downto actpos + 1 Do
            page[Linenum, i] := page[Linenum, i - 1];
        page[linenum, actpos] := ' ';
        GetRedraw (linenum, x - 12{2*charwidth}, grmaxX{x+2*charwidth});
    End;
End;

{****************************************************************}
Procedure TexDelChar(linenum: integer; Var actpos: integer);

Var StringLength, i: integer;
    x: integer;

Begin
    StringLength := Length (page[linenum]) - LineMarker;
    If actpos <= (StringLength + LineMarker) Then
    Begin
        If StringLength > 0 Then
            StringLength := StringLength - 1;
        For i := actpos To StringLength + LineMarker Do
            page[linenum, i] := page[linenum, i + 1];
        x := gcxcoord - 2 * CharWidth;
        If Pos (chr (smallblankup), page[linenum]) > 0 Then x := grminx;
        If Pos (chr (smallblankdown), page[linenum]) > 0 Then x := grminx;
        TexClearLine (linenum, x);
        delete (page[linenum], StringLength + 1 + LineMarker, 1);
        GetRedraw (linenum, x - 2 * charwidth, grmaxX);
    End;
End;
{****************************************************************}
Function SkipChar(C: Char): Boolean;
Begin
    SkipChar := (C = ' ') OR
        (C = #9) OR  {TAB}
        (C = #240) OR {ATAB}
        (C = #229) OR {A-F1}
        (C = #230) OR {A-F2}
        (C = #231) OR {A-F3}
        (C = #232) OR {A-F4}
        (C = #233) OR {A-F5}
        (C = #234) OR {A-F6}
        (C = #235) OR {A-F7}
        (C = #236) OR {A-F8}
        (C = #237);   {AF10}
End;
{****************************************************************}
Procedure TexWordLeft(Var Linenum, Actpos: Integer);
Var x, sl: Integer;
    s: String;
    f: Boolean;
Begin
    F := False;
    sl := LineNum;
    x := actpos;
    Dec (x, 11);
    Repeat
        If x = 0 Then
            Repeat
                If (sl = linenum) Then
                    If f Then
                        Exit
                    Else
                        F := True;
                sl := (((sl - 2) + pagelength) MOD pagelength) + 1;
                s  := TexGetText (sl);
                x  := Length (S) + 1;
            Until (Page[sl, 1] = 'T') AND (s <> '');
        s := TexGetText (sl);
        If x > length (S) Then
        Begin
            x := length (s);
            If (x <> 0) AND (NOT SkipChar (s[x])) Then
            Begin
                linenum := sl;
                actpos  := x;
                PagCursorRight (linenum, sl, actpos);
                Exit;
            End;
        End;
        While (x > 0) AND (NOT SkipChar (S[x])) Do
            Dec (x);
        While (x > 0) AND SkipChar (S[x]) Do
            Dec (x);
    Until x > 0;
    Inc (x, 11);
    actpos := x;
    linenum := sl;
    TexActPosX (x, actpos, linenum, true);
End;
{****************************************************************}
Procedure TexWordRight(Var Linenum, Actpos: Integer);
Var x, sl: Integer;
    s: String;
    f, f2: Boolean;
Begin
    f := false;
    F2 := false;
    sl := LineNum;
    x := actpos;
    Dec (x, 10);
    Repeat
        If F Then
        Begin
            Repeat
                sl := (sl + pagelength) MOD pagelength + 1;
                s  := TexGetText (sl);
                If (sl = linenum) Then
                    If f2 Then
                        Exit
                    Else
                        F2 := True;
            Until (Page[sl, 1] = 'T') AND (s <> '');
            x := 1;
        End;
        If NOT (F AND (NOT SkipChar (S[x]))) Then
        Begin
            F := True;
            s := TexGetText (sl);
            While (x <= Length (S)) AND (NOT SkipChar (S[x])) Do
                Inc (x);
            While (x <= Length (S)) AND SkipChar (S[x]) Do
                Inc (x);
        End;
    Until x <= Length (S);
    Inc (x, 10);
    actpos := x;
    linenum := sl;
    TexActPosX (x, actpos, linenum, true);
End;
{****************************************************************}
Function TexGetText(Linenum: Integer): String;
Var s: String;
Begin
    s := Copy (Page[linenum], 11, length (page[linenum]) - linemarker);
    IniTrailBlank (S);
    TexGetText := s;
End;
{****************************************************************}
Procedure TexSetText(Linenum: Integer; S: String);
Begin
    Page[Linenum] := Copy (Page[linenum], 1, 11) + S;
End;
End.
