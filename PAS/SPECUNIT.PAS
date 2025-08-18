Unit Specunit;

Interface

Uses
    Graph,
    InitSc,
    menutyp,
    Imenuunit,
    crt,
    UserExit,
    Dos,
    Comunit,
    mousdrv;

Procedure SpeInsNoteLine(Var linenum, actposn: integer;
    Var tempptr, startptr, lastptr: listptr);
Procedure SpeInsTextLine(linenum: integer; Var actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    delflag: boolean);
Procedure SpeNoteRight(linenum: integer; Var actpos: integer);
Procedure SpeInsertBuffer(linenum: integer; Var actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    Var pageswap: boolean);
Procedure SpeTextRight(linenum: integer; Var actpos: integer);
Procedure SpeLineDelete(linenum: integer; fill: boolean);
Procedure SpeLineInsert(linenum: integer; inblock: stringline);
Procedure SpeLastFilled(Var lline: integer);
Procedure SpeEdLineAttr(linenum: integer; Var actposn, actpost: integer; Var startptr, lastptr: listptr);
Function SpeSpaceInPage(lines: integer): boolean;
Procedure SpeSplitPage(linenum: integer; Var actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr);
Procedure SpeJoinPage(linenum: integer; Var actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr);
Procedure SpeLineToBuf(linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr);
Procedure SpeMoveBlock(linenum: integer; Var actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr);
Procedure SpeSplitFile(Var actptr, startptr, lastptr: listptr);
Procedure SpeBlockCommands(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    inchar: char);
Function SpeDelPossible(Linenum: Integer): Boolean;
Function SpeInsPossible(Linenum: Integer; T: Integer; Var InsL, Ins: Byte;
    Num: Byte; D: Boolean; U: Boolean): Boolean;
Function SpeLineUsed(Linenum: Integer): Boolean;
Function SpeLinesFree(Linenum: Integer; Up: Boolean): Integer;
Function SpeMinSpace(Instring: Stringline): Integer;
Function SpeprevNotLine(Linenum: Integer): Integer;
Function SpeNextNotLine(Linenum: Integer): Integer;

Procedure SpeLineCommands(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr);

Implementation

Uses
    GCurUnit,
    Symbols,
    GetUnit,
    TitleUnit,
    Textunit,
    inout,
    fileunit,
    pageunit,
    printunit,
    markunit,
    graphmenu,
    grintunit,
    sp2unit,
    helpunit,
    Texts,
    NoteUnit;

Var RErr: Boolean;

{*****************************************************************}
Procedure SpeBlockCommands(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    inchar: char);

Var dir: movement;
    c: char;
    choicenum: byte;
    y, hy, i, endy: integer;
    instring: string16;
    dummyb: boolean;
    bfile: text;
    inblock: stringline;
    mausx, mausy, maustaste, mausmenu: word;

Begin
    ImeIniBlockMenu;
    choicenum := 1;
    maustaste := 0;
    Repeat
        If inchar = ' ' Then
        Begin
            PagRefClearVal (grminx - 10, grminy - 10,
                grmaxx + 10, grmaxy + 10);
            y := grmaxy - (usrmenu.num_choices * usrmenu.spacing +
                usrmenu.menuattr.firstline + 2) * charheight;
            hy := y DIV charheight;
            GrDisplay_Frame (grminx, y, grmaxx, grmaxy, true, false);
            GrDisplay_Menu (hfminx, hy, usrmenu, 0);
            GrGet_Menu_Response (hfminx, hy, usrmenu, c, dir,
                choicenum, mausx, mausy, maustaste,
                mausmenu, false, 0);
            c := UpCase (c);
        End Else c := inchar;
        Case c Of
            'S': {start block}Begin
                MarkStart (IniPos (linenum, actposn, actpost),
                    linenum, pagecount);
                MarkDisplay;
            End;
            'E': {end block}If mstart.mpag <> -1 Then
                Begin
                    i := mstart.mxcoord;
                    MarkEnd (IniPos (linenum, actposn, actpost),
                        linenum, pagecount);
                    If pagecount = mstart.mpag Then PagRefClearVal (i - 3,
                            IniYnow (mstart.mline - 1), i + 9, IniYnow (mstart.mline + 1)) Else MarkDisplay;
                End;
            'U': {Shift F3: Unmark}Begin
                FileChanged := 1;
                SpeInsertBuffer (linenum, actposn, actpost, actptr,
                    startptr, lastptr, dummyb);
                PagUnMark;
            End;
            'C':
            Begin
                filbufclear;
                MarMarkToBuffer (actptr, startptr, lastptr);
            End;
            'P':
            Begin
                SpeInsertBuffer (linenum, actposn, actpost, actptr,
                    startptr, lastptr, dummyb);
                PagUnMark;
            End;
            'M': If mend.mpag <> -1 Then
                Begin
                    FileChanged := 1;
                    MarMarkToBuffer (actptr, startptr, lastptr);
                    MarDeleteBlock (actptr, startptr, lastptr);
                    PagUnMark;
                    SpeInsertBuffer (linenum, actposn, actpost,
                        actptr, startptr, lastptr, dummyb);
{          SpeMoveBlock(linenum, actposn, actpost, actptr,
                        startptr, lastptr);}
                End Else HlpHint (HntNoMarkedArea, HintWaitEsc);

            'D': If mend.mpag <> -1 Then
                Begin
                    If mstart.mpag = mend.mpag Then
                        If mstart.mline <> mend.mline Then
                        Begin
                            i := mstart.mline;
                            If Page[i, 1] <> 'N' Then
                                i := NotNextLine (i);
                            Repeat
                                If NotIsSys (i) = 'S' Then
                                    If NotIsSys (NotNextLine (i)) = ' ' Then
                                        NotSysStart (NotNextLine (i));
                                If NotNextLine (i) = i Then
                                    break;
                                i := NotNextLine (i);
                            Until i > NotPrevLine (mend.mline + 1);
                            i := mend.mline;
                            If page[i, 1] <> 'N' Then
                                i := NotPrevLine (i);
                            Repeat
                                If NotIsSys (i) = 'E' Then
                                    If NotIsSys (NotPrevLine (i)) = ' ' Then
                                        NotSysEnd (NotPrevLine (i));
                                If NotPrevLine (i) = i Then
                                    break;
                                i := NotPrevLine (i);
                            Until i < NotNextLine (mstart.mline - 1);
                        End{*** Check & Update S/E Marks BEGIN***}{*** Check & Update S/E Marks END***};
                    MarMarkToBuffer (actptr, startptr, lastptr);
                    MarDeleteBlock (actptr, startptr, lastptr);
                    MarkInit;
                    If marpartline Then
                    Begin
                        endy := IniYnow (linenum + 1);
                        PagRefClearVal (0, 0, gmaxX, endy);
                    End Else Begin
                        PagRefPage;
                    End;
                End Else HlpHint (HntNoMarkedArea, HintWaitEsc);

            'W':
            Begin
      {$IFDEF DEMO}
                HlpHint (HntDemoBuf, 0);
      {$ELSE}
                If mend.mpag <> -1 Then
                Begin
                    MarMarkToBuffer (actptr, startptr, lastptr);
                    inblock := '';
                    IniExpand (inblock, 49);
                    IniInversText (31, (TOP_LINE + choicenum * usrmenu.SPACING),
                        inblock, frLow);
                    If HlpGetFileName (instring, '.buf', 51, (TOP_LINE +
                        choicenum * usrmenu.SPACING) + 1) Then
                    Begin
                        dummyb := true;
                        If IniFileExist (bufdir + '\' + instring) Then
                            If NOT HlpAreYouSure ('File already exists, overwrite?', hpEdit) Then
                                dummyb := false;
                        If dummyb Then
                        Begin
                            assign (bfile, bufdir + '\' + instring);
                            LastFileName := FExpand (bufdir + '\' + instring);
                            rewrite (bfile);
                            writeln (bfile, '$$$RNSBUFFER$$$');
                            If marpartline Then
                                i := 1
                            Else
                                i := 0;
                            writeln (bfile, i: 6,
                                mstart.mline: 6, mstart.mpos: 6,
                                mstart.mpag: 6,
                                mend.mline: 6, mend.mpos: 6, mend.mpag: 6);
                            FilHeapToFile (bfile, bufactptr,
                                bufstartptr, bufendptr, false,
                                true, false);
                            PagUnmark;
                        End;
                    End; {if HlpGetFileName(instring) then }
                End {if mstart.mpage }Else HlpHint (HntNoMarkedArea, HintWaitEsc);
      {$ENDIF}
            End;

            'R':
            Begin
      {$IFDEF DEMO}
                HlpHint (HntDemoBuf, 0);
      {$ELSE}
                If mstart.mpag = -1 Then
                Begin
                    Mausbereich (GrMinX + 1, GrMinX + 20 * 8, GrMinY, GrMaxY);
                    instring := FilFileSelect ('Select Bufferfile', '*.buf', bufdir);
                    If instring <> '' Then
                        If NOT IniFileExist (bufdir + '\' + instring) Then HlpHint (HntNotExist, HintWaitEsc) Else Begin
                            assign (bfile, bufdir + '\' + instring);
                            LastFileName := FExpand (bufdir + '\' + instring);
                            reset (bfile);
                            readln (bfile, inblock);
                            If (inblock = '$$$RNSBUFFER$$$') Then
                            Begin
                                readln (bfile, i, mstart.mline, mstart.mpos, mstart.mpag,
                                    mend.mline, mend.mpos, mend.mpag);
                                marpartline := (i = 1);
                                mstart.mpag := -1;
                                mend.mpag := -1;
                                FilFileToHeap (bfile, bufactptr,
                                    bufstartptr, bufendptr, dummyb);
                                SpeInsertBuffer (linenum, actposn, actpost,
                                    actptr, startptr, lastptr, dummyb);
                                Markinit;
                            End Else Begin
                                LastFileName := FExpand (TextRec (bfile).Name);
                                close (bfile);
                                HlpHint (HntNotBlockFile, HintWaitEsc);
                            End;
                        End; {if HlpGetFileName(instring) then }
                End Else {if mstart.mpag = -1 then} HlpHint (HntUnmarkBlockFirst, HintWaitEsc);
      {$ENDIF}
            End; {'R'}

            'I': {Collect Header/Footer}Begin
                FilSavePage (1, PageLength, actptr, startptr, lastptr);
                Sp2HeaderFooterToBuffer (actptr, startptr, lastptr,
                    bufactptr, bufstartptr,
                    bufendptr);
                PagShowPage (linenum, actposn, actpost,
                    actptr, startptr, lastptr,
                    pagecount, false);
            End;
        End; {case c of}
        If pos (c, usrmenu.choices) > 0 Then
            c := #27;
    Until ((c = #27) OR (inchar <> ' '));
End;

{*************************************************************************}
Procedure SpeInsEmptyLines(Var lineins: integer;
    Var actptr, startptr, lastptr: listptr);
{Fuegt lineins leere Zeilen in den Heap}

Var i: integer;

Begin
    For i := 1 To lineins Do
        FilHeapInsertString ('T    ' + chr (0), actptr,
            startptr, lastptr, actptr, false);
End;

{*************************************************************************}
Procedure SpeInsFooter(Var actptr, startptr, lastptr: listptr);
{Fuegt den Footer in den Heap ein}

Var i: integer;

Begin
    i := pagelength;
    While IniHeaderFooterLine (i) Do
        i := i - 1;
    i := i + 1;
    While i <= pagelength Do
    Begin
        FilHeapInsertString (page[i] + chr (0), actptr,
            startptr, lastptr, actptr, false);
        i := i + 1;
    End;
End;

{*************************************************************************}
Procedure SpeInsHeader(Var actptr, startptr, lastptr: listptr);
{Fuegt den Header in den Heap ein}

Var i: integer;

Begin
    i := topmargin;
    While IniHeaderFooterLine (i) Do
    Begin
        FilHeapInsertString (page[i] + chr (0),
            actptr, startptr, lastptr,
            actptr, false);
        i := i + 1;
    End;
End;

{******************************************************}
Procedure SpeSplitFile(Var actptr, startptr, lastptr: listptr);
{schreibt von der n�chsten Seite an alles in ein neues File}

Var instring: string16;
    ok: boolean;
    outfile: text;
    i:  integer;

Begin
    If ((actptr = startptr) OR (actptr = lastptr)) Then HlpHint (HntSplitFirstPage, HintWaitEsc) Else{if startptr = actptr then }Begin
        {Filenamen abfragen}
        ok := true;
        If HlpGetFileName (instring, '.RNS', 0, 0) Then
        Begin
            If IniFileExist (datadir + '/' + instring) Then
                If NOT HlpAreYouSure ('File already exists - overwrite?', hpEdit) Then ok := false;
            If ok Then
            Begin
                FilSavePage (topmargin, pagelength, actptr,
                    startptr, lastptr);
                assign (outfile, datadir + '/' + instring);
                FilHeapToFile (outfile, actptr, startptr, lastptr,
                    false, false, true);
                FilHeapToFile (infile, actptr, startptr, lastptr,
                    false, false, true);
                FilFindPage (1, i, actptr, startptr, lastptr);
                For i := 1 To pagecount Do PagRemovePage (actptr, startptr, lastptr);
                FilHeapToFile (outfile, actptr, startptr, lastptr, true, false, true);
                LastFileName := FExpand (TextRec (infile).Name);
                reset (infile);
                FilFileToHeap (infile, actptr, startptr, lastptr, ok);
                FilFindPage (pagecount + 1, i, actptr, startptr, lastptr);
                While (actptr <> lastptr) Do PagRemovePage (actptr, startptr, lastptr);
                FilHeapToFile (infile, actptr, startptr, lastptr, false, false, true);
                FilFindPage (pagecount, i, actptr, startptr, lastptr);
                PagGetPageFromHeap (actptr, startptr, lastptr, i);
            End;
        End; {if instring[1] <> chr(27) then }
    End; { else if startptr = actptr then }
End;

{******************************************************}
Procedure SpeLineToBuf(linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr);
{Versorgt eine Zeile in den Buffer}

Var apos: integer;

Begin
    MarkInit;
    apos := IniPos (linenum, actposn, actpost);
    MarkStart (apos, linenum, pagecount);
    MarkEnd (apos, linenum, pagecount);
    MarMarkToBuffer (actptr, startptr, lastptr);
    marpartline := false;
    MarkInit;
End;

{******************************************************}
Procedure SpeSplitPage(linenum: integer; Var actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr);
{Unterteilt die Seite an der Cursorposition}

Var i, lineins, linepage: integer;
    tempptr: listptr;

Begin
    tempptr := actptr;
    SpeInsHeader (tempptr, startptr, lastptr);
    lineins := 0;
    While linenum + lineins <= IniFooterEnd Do
    Begin
        FilHeapInsertString (page[IniFooterEnd] + chr (0), tempptr,
            startptr, lastptr, actptr, true);
        SpeLineInsert (linenum + lineins, 'T    ');
        lineins := lineins + 1;
    End;

    {Anzahl Zeilen ohne Header und Footer pro Seite berechnen}
    linepage := IniFooterEnd - IniHeaderEnd + 1;

    {Seite mit leeren Zeilen auffuellen}
    i := linepage - (lineins MOD linepage);
    SpeInsEmptyLines (i, actptr, startptr, lastptr);

    {Footer einfuellen}
    SpeInsFooter (actptr, startptr, lastptr);

    FilHeapSqueeze (actptr, startptr, lastptr, true);
    FilFindPage (pagecount, i, actptr, startptr, lastptr);
    PagRefClearVal (0, IniYnow (linenum - 2), GetMaxX, GetMaxY);
    PagCursorLeft (linenum, actposn, actpost);
End;

{******************************************************}
Procedure SpeJoinPage(linenum: integer; Var actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr);
{Schiebt die n�chste Seite an die gegenw�rtige}

Var i, lineins, linepage: integer;
    tempptr: listptr;
    inblock, tempbuffer: stringline;
    endreached: boolean;
    tbufpos: byte;

Begin
    lineins := topmargin;
    tempbuffer := '';
    tbufpos := 0;
    tempptr := actptr;
    linepage := 0;

    If actptr <> lastptr Then
    Begin
        SpeLastFilled (i);
        While ((i <= pagelength) AND (NOT IniHeaderFooterLine (i))) Do
        Begin
            FilCheckLine (tempbuffer, inblock,
                tempptr, startptr, lastptr,
                tbufpos, endreached, false, false);
            lineins := lineins + 1;
            If ((length (inblock) >= 4) AND (inblock[4] = 'F')) Then
                FilCheckLine (tempbuffer, inblock,
                    tempptr, startptr, lastptr,
                    tbufpos, endreached, true, false)
            Else  {if inblock[4] = 'F' then }
            Begin
                FilCheckLine (tempbuffer, inblock,
                    tempptr, startptr, lastptr,
                    tbufpos, endreached, true, true);
                page[i] := inblock;
                i := i + 1;
                linepage := linepage + 1;
            End; { else if inblock[4] = 'F' then }
        End;

        {auffuellen der naechsten Seite mit leeren Linien}
        Repeat
            FilCheckLine (tempbuffer, inblock,
                tempptr, startptr, lastptr,
                tbufpos, endreached, false, false);
            lineins := lineins + 1;
            If ((length (inblock) >= 4) AND (inblock[4] <> 'F')) Then
                FilCheckLine (tempbuffer, inblock,
                    tempptr, startptr, lastptr,
                    tbufpos, endreached, true, false);
        Until ((lineins = pagelength) OR (inblock[4] = 'F'));

        FilStringSeparate (tempbuffer, tempptr, startptr, lastptr,
            tbufpos);
        SpeInsEmptyLines (linepage, tempptr, startptr, lastptr);
        FilHeapSqueeze (tempptr, startptr, lastptr, true);

        FilFindPage (pagecount, i, actptr, startptr, lastptr);
        {Naechste Seite loeschen, falls sie leer ist}
        If PagEmptyPage (actptr, startptr, lastptr) Then
            PagRemovePage (actptr, startptr, lastptr);

        {Seite anzeigen}
        PagRefClearVal (0, IniYnow (linenum - 2), GetMaxX, GetMaxY);
        PagCursorLeft (linenum, actposn, actpost);
    End { if actptr <> lastptr then }
    Else
        HlpHint (HntOnLastPage, HintWaitEsc);
End;

{******************************************************}
Procedure SpeEdLineAttr(linenum: integer; Var actposn, actpost: integer; Var startptr, lastptr: listptr);

Var
    i: integer;

Begin
    GriBeatMenuDisp (linenum{, startptr, lastptr});

    {Beatmenu - Feld l�schen}
    PagRefClearVal (GrMinX - 10, GrMinY - 10,
        GrMaxX + 10, GrMaxY + 10);

    {Start-y f�r refresh berechnen}
    PagRefClearVal (0, IniYnow (linenum - 2), GetMaxX, IniYnow (LineNum + 2));
    i := topmargin;
    While ((i < linenum) AND (page[i, 1] <> 'N')) Do
        i := i + 1;
    If i = linenum Then PagRefPage;

    PagCursorLeft (linenum, actposn, actpost);
End;

{******************************************************}
Procedure SpeLastFilled(Var lline: integer);
{Sucht die letzte Zeile der Seite, die einen Inhalt hat}

Begin
    lline := IniFooterEnd;
    While ((lline >= topmargin) AND (IniEmptyLine (page[lline]))) Do
        lline := lline - 1;
    lline := lline + 1;
End;

{******************************************************}
Function SpeSpaceInPage(lines: integer): boolean;
    {true, wenn Platz fuer lines linien auf der Seite vorhanden ist.}

Var i: integer;
    lmax: byte;

Begin
    If lines > (IniFooterEnd - IniHeaderEnd + 1) Then
    Begin
        SpeSpaceInPage := False;
        Exit;
    End;
    i := 0;
    lmax := IniFooterEnd;
    While ((i <= lines) AND (IniEmptyLine (page[lmax - i]))) Do inc (i);
    SpeSpaceInPage := i >= lines;
End;

{******************************************************}
Procedure SpeLineInsert(linenum: integer; inblock: stringline);
{F�gt eine Zeile an der Stelle Linenum ein}

Var i: integer;

Begin
    For i := IniFooterEnd Downto (linenum + 1) Do
        page[i] := page[i - 1];
    page[linenum] := inblock;
End;

{******************************************************}
Procedure SpeLineDelete(linenum: integer; fill: boolean);
{Loescht die Zeile Linenum aus der aktuellen Page}

Var
    i, lmax: integer;

Begin
    If NOT SpeDelPossible (linenum) Then
        Exit;
    If NotIsSys (linenum) = 'S' Then
        NotSysStart (NotNextLine (linenum))
    Else If NotIsSys (linenum) = 'E' Then
        NotSysEnd (NotPrevLine (linenum));
    lmax := pagelength;
    While IniHeaderFooterLine (lmax) Do
        lmax := lmax - 1;
    For i := linenum To (lmax - 1) Do
        page[i] := page[i + 1];
    If fill Then
        page[lmax] := 'T        ';
End;

{******************************************************}
Procedure SpeNoteRight(linenum: integer; Var actpos: integer);

Var x: integer;

Begin
    While (actpos < length (page[linenum])) AND
        (NOT IniNumChar (page[linenum, actpos])) Do
        inc (actpos);
    If IniNumChar (page[linenum, actpos]) Then
    Begin
        x := gcxcoord + 1;
        GetNotePosX (x, actpos, linenum, true, false);
    End;
End;

{******************************************************}
Procedure SpeTextRight(linenum: integer; Var actpos: integer);

Var
    x: integer;

Begin
    If length (page[linenum]) <= actpos Then
        IniCharAdd (page[linenum], ' ', actpos + 1);
    If actpos < 240 Then
        Inc (actpos);
    TexActPosX (x, actpos, linenum, true);
End;

{******************************************************}
Procedure SpeInsNoteLine(Var linenum, actposn: integer;
    Var tempptr, startptr, lastptr: listptr);
Var i: integer;
    inblock: stringline;
    inserted: boolean;
    lineattr: lineattrtype;
Begin
    SpeLastFilled (i);
    If GetValidStaff (linenum) Then
    Begin
        inblock := insmusicline;
        GetNoteAttributes (inblock, lineattr);
        If lineattr.linestyle = 2 Then
        Begin
            If ((SpeSpaceInPage (1)) AND (linenum <= pagelength)) Then
            Begin
                actposn := length (insmusicline);
                inserted := true;
                SpeLineInsert (linenum, insmusicline);
            End Else Begin
                HlpHint (HntNotEnoughSpace, HintWaitEsc);
                inserted := false;
            End;
        End Else Begin
            If ((SpeSpaceInPage (linecount)) AND ((linenum + linecount - 1) <= pagelength)) Then
            Begin
                {Notenlinie ins Page-Array schreiben}
                actposn := length (insmusicline);
                inserted := true;
                For i := 1 To linecount Do SpeLineInsert (linenum + i - 1, insmusicline);
            End Else Begin
                HlpHint (HntNotEnoughSpace, HintWaitEsc);
                inserted := false;
            End;
        End;
    End Else HlpHint (HntDistanceToSmall, HintWaitEsc);
    {Seite wiederherstellen}
    If inserted Then
    Begin
        PagRefClearVal (0, IniYnow (linenum - 4), GetMaxX, grmaxy - 1);
        PagCursorLeft (linenum, actposn, i);
    End;
End;

{******************************************************}
Procedure SpeInsTextLine(linenum: integer; Var actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    delflag: boolean);

Var i, y: integer;
    inblock: stringline;

Begin
    If SpeSpaceInPage (1) Then
    Begin
        {Textlinie ins Page-Array schreiben}
        If ((delflag) AND (delln <> '')) Then
        Begin
            inblock := delln;
            FillChar (inblock[2], linemarker - 1, ' ');
        End
        Else
        Begin
            inblock := 'T        ';
        End;
        SpeLineInsert (linenum, inblock);
        y := IniYnow (linenum - 6);
        PagRefClearVal (0, y, GetMaxX, grmaxy - 1);
        PagCursorLeft (linenum, actpost, i);
    End
    Else
        HlpHint (HntNotEnoughSpace, HintWaitEsc);
End;

{******************************************************}
Procedure SpeMoveBlock(linenum: integer; Var actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr);

Var linenow, markstart, markend, nowpos: integer;
    delfirst: byte; {0 = invalid, 1 = delete first, 2 = insert first}
    pageswap: boolean;
    blocklength: integer;
Begin
    If (mstart.mpag <> -1) AND (mend.mpag <> -1) Then
    Begin
        filbufclear;
        MarMarkToBuffer (actptr, startptr, lastptr);
    End;
    blocklength := mend.mline - mstart.mline + 1 + (mend.mpag - mstart.mpag) * pagelength;
    If (blocklength < pagelength) AND (linenum + blocklength > pagelength) Then
    Begin
        HlpHint (HntNotEnoughSpace, HintWaitEsc);
        Exit;
    End;
    linenow := pagecount * pagelength + linenum + blocklength;
    markstart := mstart.mpag * pagelength + mstart.mline;
    markend := mend.mpag * pagelength + mend.mline;
    delfirst := 0;

    If marpartline Then
    Begin
        nowpos := IniPos (linenum + blocklength, actposn, actpost);
        If ((linenow <> markstart) OR (nowpos < mstart.mpos)) Then delfirst := 1 Else Begin
            If (nowpos > mend.mpos) Then
                delfirst := 2;
        End;
    End Else If (linenow - blocklength) < markstart Then delfirst := 1 Else If (linenow - blocklength) > markend Then
        delfirst := 2; { if marpartline then }

    Case delfirst Of
        0: HlpHint (HntBufItself, HintWaitEsc);
        1:
        Begin
            MarDeleteBlock (actptr, startptr, lastptr);
            SpeInsertBuffer (linenum, actposn, actpost,
                actptr, startptr, lastptr, pageswap);
            PagUnMark;
        End;
        2:
        Begin
            SpeInsertBuffer (linenum + blocklength, actposn, actpost,
                actptr, startptr, lastptr, pageswap);
            MarDeleteBlock (actptr, startptr, lastptr);
            MarkInit;
            If pageswap Then SpeJoinPage (linenum + blocklength, actposn, actpost,
                    actptr, startptr, lastptr);
            If NOT marpartline Then
                PagRefPage;
            PagCursorLeft (linenum, actposn, actpost);
        End;
    End; {case delfirst of}
End;

{*************************************************************************}
Procedure SpeInsertBuffer(linenum: integer; Var actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    Var pageswap: boolean);
{pageswap wird true gesetzt, wenn eine neue Seite angebrochen wurde}

Var
    apos, numpages, lineins, linepage, i, j: integer;
    tempbuffer, inblock: stringline;
    tempptr: listptr;
    endreached: boolean;
    tbufpos: byte;

Begin
    If (mstart.mpag <> -1) AND (mend.mpag <> -1) Then MarMarkToBuffer (actptr, startptr, lastptr);
    If bufstartptr <> bufendptr Then
    Begin
        bufactptr := bufstartptr;
        pageswap := false;
        tempbuffer := '';
        tbufpos := 0;

        If marpartline Then
        Begin
            {Nur Teil einer Zeile im Buffer}
            FilCheckLine (tempbuffer, inblock, bufactptr, bufstartptr, bufendptr,
                tbufpos, endreached, true, false);
            {Testen, ob nicht eine Textzeile in eine Notenzeile kopiert wird}
            If page[linenum, 1] <> inblock[1] Then
                HlpHint (HntIncorrectNote, HintWaitEsc)
            Else {  if page[linenum, 1] <> inblock[1] then }
            Begin
                delete (inblock, mend.mpos + 1, length (inblock));
                delete (inblock, 1, mstart.mpos - 1);
                apos := IniPos (linenum, actposn, actpost);

                If page[linenum, 1] = 'T' Then
                    IniTrailBlank (inblock) Else apos := ComStart (page[linenum], apos);
                insert (inblock, page[linenum], apos);
                PagRefClearVal (0, IniYnow (linenum - 2),
                    GetMaxX, IniYnow (linenum + 1));
            End; { else if page[linenum, 1] <> inblock[1] then }
        End
        Else  { if marpartline then }
        Begin
            lineins := 0;
            linepage := 0;
            endreached := false;

            {Einfuellen auf aktuelle Seite, solange Platz vorhanden}
            While ((NOT endreached) AND
                    (linenum + linepage <= IniFooterEnd) AND
                    (IniEmptyLine (page[IniFooterEnd]))) Do
            Begin
                FilCheckLine (tempbuffer, inblock,
                    bufactptr, bufstartptr, bufendptr,
                    tbufpos, endreached, true, false);
                If NOT endreached Then
                Begin
                    SpeLineInsert (linenum + linepage, inblock);
                    linepage := linepage + 1;
                End;
            End;

            {beenden, wenn auf einer setup-page editiert wird}
            If ((NOT endreached) AND (NOT (setuppage IN actedit))) Then
            Begin
                pageswap := true;
                {Aktuelle Seite durch Buffer fertig ersetzen}
                tempptr  := actptr;
                While ((NOT endreached) AND
                        (linenum + linepage <= IniFooterEnd)) Do
                Begin
                    FilCheckLine (tempbuffer, inblock,
                        bufactptr, bufstartptr, bufendptr,
                        tbufpos, endreached, true, false);
                    If NOT endreached Then
                    Begin
                        FilHeapInsertString (page[IniFooterEnd] + chr (0), tempptr,
                            startptr, lastptr, actptr, true);
                        SpeLineInsert (linenum + linepage, inblock);
                        lineins := lineins + 1;
                        linepage := linepage + 1;
                    End;
                End;

                {Uebertragen des Buffers auf den Heap}
                While NOT endreached Do
                Begin
                    FilCheckLine (tempbuffer, inblock,
                        bufactptr, bufstartptr, bufendptr,
                        tbufpos, endreached, true, false);
                    If NOT endreached Then
                    Begin
                        FilHeapInsertString (inblock + chr (0), tempptr,
                            startptr, lastptr, actptr, false);
                        lineins := lineins + 1;
                        If lineins MOD 10 = 0 Then
                            FilHeapSqueeze (tempptr, startptr, actptr, true);
                    End; {if not endreached then}
                End; {while not endreached do}

                {Anzahl Zeilen ohne Header und Footer pro Seite berechnen}
                linepage := IniFooterEnd - IniHeaderEnd + 1;

                {Seite mit leeren Zeilen auffuellen}
                i := linepage - (lineins MOD linepage);
                SpeInsEmptyLines (i, actptr, startptr, lastptr);
                lineins := lineins + i;

                {Tempptr auf den Anfang des eingefuegten Blocks setzen}
                FilFindPage (pagecount, i, tempptr, startptr, lastptr);

                {Header und Footertext einfuegen}
                numpages := lineins DIV linepage;
                For i := 1 To numpages Do
                Begin
                    SpeInsHeader (tempptr, startptr, lastptr);
                    tempbuffer := '';
                    tbufpos := 0;
                    For j := 1 To linepage Do
                        FilCheckLine (tempbuffer, inblock,
                            tempptr, startptr, lastptr,
                            tbufpos, endreached, true, false);
                    FilStringSeparate (tempbuffer, tempptr, startptr, lastptr,
                        tbufpos);
                    SpeInsFooter (tempptr, startptr, lastptr);
                    FilHeapSqueeze (tempptr, startptr, actptr, true);
                End;
            End; { if not endreached then }

            FilHeapSqueeze (actptr, startptr, lastptr, true);
            FilFindPage (pagecount, i, actptr, startptr, lastptr);
            PagRefClearVal (0, IniYnow (linenum - 2), GetMaxX, GetMaxY);
            PagCursorLeft (linenum, actposn, actpost);
        End; { else if marpartline then }
    End
    Else { if bufstartptr <> bufendptr then }
        HlpHint (HntBufEmpty, HintWaitEsc); {else  if bufstartptr <> bufendptr then}
End;

Function SpeDelPossible(Linenum: Integer): Boolean;
Var i: Integer;
    a: Integer;
Begin
    a :={4}3;
    For i := linenum - 1 Downto linenum - 4 Do
        If i > 0 Then
            If page[i, 1] <> 'N' Then
                dec (a)
            Else
                Break;
    For i := Linenum + 1 To linenum + a Do
    Begin
        If i > PageLength Then
        Begin
            SpeDelPossible := True;
            Exit;
        End;
        If (Page[i, 1] = 'N') AND (Page[i, 29] = '2') Then
        Begin
            SpeDelPossible := False;
            Exit;
        End;
    End;
    SpeDelPossible := True;
End;

Function SpeInsPossible(Linenum: Integer; T: Integer; Var InsL, Ins: Byte;
    Num: Byte; D: Boolean; U: Boolean): Boolean;
Var Up, Dn: Integer;

Begin
    If Linenum + Num > 53 Then
        SpeInsPossible := False
    Else Begin
        Ins := 0;
        InsL := Linenum;
        Up  := SpeLinesFree (Linenum, True);
        Dn  := SpeLinesFree (Linenum, False);
        If SpeLineUsed (Linenum) Then
        Begin
            Ins := SpeMinSpace (Page[Linenum]) + 1;
            If U Then
                InsL := InsL + Ins;
        End;
        If (Up >= T) AND (Dn >= SpeMinSpace (Page[Linenum + Dn])) Then
        Begin
            SpeInsPossible := True;
            Exit;
        End;
        If Up < T Then
        Begin
            InsL := Linenum + T - Up;
            Ins  := T - Up;
        End;
        If Dn < SpeMinSpace (Page[Linenum + Dn]) Then Ins := SpeMinSpace (Page[Linenum + Dn]) - Dn;
        SpeInsPossible := SpeSpaceInPage (Ins);
    End;
End;

Function SpeLinesFree(Linenum: Integer; Up: Boolean): Integer;
Var i: Integer;
Begin
    i := 1;
    If Up Then
        While NOT SpeLineUsed (Linenum - i) Do
            Inc (i) Else While NOT SpeLineUsed (Linenum + i) Do
            Inc (i);
    SpeLinesFree := i;
End;

Function SpeLineUsed(Linenum: Integer): Boolean;
    Function TextLength(S: String): Byte;
    Var
        i: Integer;
    Begin
        { Modern Pascal replacement for assembly string length without trailing spaces }
        { Original: Scanned string backwards removing trailing spaces }
        i := Length (S);
        While (i > 0) AND (S[i] = ' ') Do
            Dec (i);
        TextLength := i;
    End;
Begin
    If (Linenum < 1) OR (Linenum > PageLength) Then
    Begin
        RErr := True;
        SpeLineUsed := True;
        Exit;
    End;
    SpeLineUsed := (Page[Linenum, 1] = 'N') OR (TextLength (Page[Linenum]) > 11);
End;

Function SpeMinSpace(Instring: StringLine): Integer;
Begin
    If Instring[1] = 'T' Then
        SpeMinSpace := 1
    Else If Instring[29] = '2' Then
        SpeMinSpace :={4}3
    Else
        SpeMinSpace := 1;
End;
Function SpeprevNotLine(Linenum: Integer): Integer;
Var i: Integer;
Begin
    If Linenum > Pagelength Then
        Linenum := Pagelength - 1;
    For i := Linenum - 1 Downto 1 Do
        If Page[i, 1] = 'N' Then
            Break;
    Linenum := i;
    If Page[Linenum, 1] <> 'N' Then
        For i := Pagelength Downto i + 1 Do
            If Page[i, 1] = 'N' Then
                Break;
    Linenum := i;
    If Page[Linenum, 1] <> 'N' Then
        i := 0;
    SpeprevNotLine := i;
End;
Function SpeNextNotLine(Linenum: Integer): Integer;
Var i: integer;
Begin
    If Linenum < 1 Then
        Linenum := 1;
    For i := Linenum + 1 To Pagelength Do
        If Page[i, 1] = 'N' Then
            Break;
    Linenum := i;
    If Page[Linenum, 1] <> 'N' Then
        For i := 1 To Linenum - 1 Do
            If Page[i, 1] = 'N' Then
                Break;
    If Page[i, 1] <> 'N' Then
        i := 0;
    SpeNextNotLine := i;
End;

{*****************************************************************}
Procedure SpeLineCommands(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr);

Var dir: movement;
    c, inchar: char;
    choicenum: byte;
    y, hy: integer;
    mausx, mausy, maustaste, mausmenu: word;

Begin
    ImeInitLineMenu;
    choicenum := 1;
    maustaste := 0;
    Repeat
        PagRefClearVal (grminx - 10, grminy - 10,
            grmaxx + 10, grmaxy + 10);
        y := grmaxy - (usrmenu.num_choices * usrmenu.spacing +
            usrmenu.menuattr.firstline + 2) * charheight;
        hy := y DIV charheight;
        GrDisplay_Frame (grminx, y, grmaxx, grmaxy, true, false);
        GrDisplay_Menu (hfminx, hy, usrmenu, 0);
        GrGet_Menu_Response (hfminx, hy, usrmenu, c, dir,
            choicenum, mausx, mausy, maustaste,
            mausmenu, false, 0);
        c := UpCase (c);
        Case c Of
            'C':
            Begin
                inchar := #65;
                ComEdSpecial (linenum, actposn, actpost, actptr, startptr, lastptr,
                    inchar, false, false);
            End;{ case c of 'C'}
            'P':
            Begin
                inchar := #100;
                ComEdSpecial (linenum, actposn, actpost, actptr, startptr, lastptr,
                    inchar, false, true);
            End;{ case c of 'P'}{ siehe auch:comunit ca. 610}
            'S':
            Begin
                inchar := #96;
                ComEdSpecial (linenum, actposn, actpost, actptr, startptr, lastptr,
                    inchar, false, true);
            End;{ case c of 'S'}
            'B':
            Begin
                inchar := #8;
                ComEdKey (linenum, actposn, actpost, actptr, startptr, lastptr,
                    inchar, true, false);
            End;
            'E':
            Begin
                inchar := #83;
                ComEdSpecial (linenum, actposn, actpost, actptr, startptr, lastptr,
                    inchar, true, false);
            End;
            'D':
            Begin
                inchar := #127;
                ComEdKey (linenum, actposn, actpost, actptr, startptr, lastptr,
                    inchar, false, true);
            End;{ case c of 'D'}
            'U':
            Begin
                inchar := #82;
                ComEdSpecial (linenum, actposn, actpost, actptr, startptr, lastptr,
                    inchar, true, false);
            End;{ case c of 'D'}
        End; {case c of}
        If pos (c, usrmenu.choices) > 0 Then c := chr (27);
    Until ((c = chr (27)) OR (inchar <> ' '));
End;

{*************************************************************************}

Begin
    RErr := False;
End.
