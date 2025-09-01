{$I RNS.H}

Unit Comunit;

Interface

Uses
    MenuTyp,
    InitSc;

Procedure ComEdArrow(Direction: Movement;
    Var linenum, actposn, actpost: integer);
Procedure ComEdReturn(Var linenum, actposn, actpost: integer;
    shiftp, ctrlp: Boolean);
Function ComEdKey(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    KeyResponse: char; shiftp, ctrlp: Boolean): Boolean;
Procedure ComEdSpecial(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    Var KeyResponse: char; shiftp, ctrlp: boolean);
Procedure ComEdEscape(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    Var resp: Response_Type);
Function ComEdMaus(mausx, mausy, maustaste: word;
    Var linenum, actposn, actpost: integer): Boolean;
Procedure ComMouseAssign(mausx, mausy, maustaste: word;
    Var Response: Response_type;
    Var Keyresponse: Char;
    Var shiftp, ctrlp: boolean);

Procedure ComSysEnd(Var Linenum: Integer);
Procedure ComSysStart(Var Linenum: Integer);
Function ComSysHeight(Linenum: integer): Integer;
Function ComMusicStart(inblock: Stringline): Byte;
Function ComStart(inblock: Stringline; actposn: Byte): Byte;
Function ComEnd(inblock: StringLine; Actposn: Byte): Byte;
Function ComLen(inblock: StringLine; ActPosn: Byte): Byte;
Function comnext(inblock: stringline; actposn: Byte): Byte;
Function comprev(inblock: stringline; actposn: Byte): byte;
Function comskiplinesDown(linenum: integer): integer;
Function comskiplinesUp(linenum: integer): integer;
Function ComNL(linenum: integer): Boolean;
Function ComTL(linenum: integer): Boolean;
Function ComUsedTL(linenum: integer): Boolean;
Function ComUsedL(linenum: integer): Boolean;
Function ComSpaceUpNeed(linenum: integer): Byte;
Function ComSpaceDownNeed(linenum: integer): Byte;
Function ComSpaceBetweenNeed(l1, l2: integer): Byte;
Function ComSpaceBetween(l1, l2: integer): byte;
Function ComLinesUpBelong2(linenum: integer): Byte;
Function ComLinesDownBelong2(linenum: integer): Byte;
Function ComLineBelong2(linenum: integer): Byte;
Function ComNextLine(linenum: integer): integer;
Function ComPrevLine(linenum: integer): integer;
Function ComInsPossible(num: integer): Boolean;
Function Searchlastchiffre(linenum: Integer): String;
Function CopyLine(Src, Des: Integer): Boolean;
Function LineUsed(Linenum: Byte): Boolean;
Function ComHorLine(linenum: integer): Boolean;

Implementation

Uses
    Symbols,
 inout,   TitleUnit,
    fileunit,
    grintunit,
    pageunit,
    prmunit,
    specunit,
    sp2unit,
    noteunit,
    textunit,
    graphmenu,
    markunit,
    butunit,
    satunit,
    helpunit,
    utilunit,
    dmemunit,
    Texts,
    userint,
    SysUtils,
    Graph,
    GCurUnit,
    xcrt,
    crt,
    getunit,
    dos,
    SndUnit,
    MousDrv,
    ScrSave,
    RnsIni,
    EditUnit;

Var
    CursorKilled: Boolean;
    Cursorlinestart, cursorlineend: Byte;

{******************************************************}
Function ComKeyGrant(Var c: char; linenum: integer): boolean;
    {testet, ob ein Normales Zeichen c zur Zeit erlaubt ist}

Var
    ordc: byte absolute c;
Begin
    ComKeyGrant := True;
    If mstart.mpag <> -1 Then
    Begin
        ComKeyGrant := false;
        HlpHint (HntUnmarkBlockFirst, HintWaitEsc, []);
        Exit;
    End;

    If ((IniHeaderFooterLine (linenum)) AND (ordc = 127)) Then
    Begin
        ComKeyGrant := false;
        HlpHint (HntNotAvailableHeader, HintWaitEsc, []);
        Exit;
    End;
    If ordc = 26 Then
        ComKeyGrant := false;
End;

{******************************************************}

Function ComTestBlock(c: Char; Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr): Boolean;
Var
    dummyb: Boolean;
Begin
    ComTestBlock := False;
    If (mstart.mpag <> -1) AND (mend.mpag <> -1) Then
        Case UpCase (c) Of
            'M':
            Begin
                ComTestBlock := True;
                FileChanged  := 1;
                MarMarkToBuffer (actptr, startptr, lastptr);
                MarDeleteBlock (actptr, startptr, lastptr);
                PagUnMark;
                SpeInsertBuffer (linenum, actposn, actpost,
                    actptr, startptr, lastptr, dummyb);
            End;{'M'}
            'C':
            Begin
                ComTestBlock := True;
                filbufclear;
                MarMarkToBuffer (actptr, startptr, lastptr);
            End;{case c of 'C'}
        End{Case} Else If pagebuf <> -1 Then
        Case UpCase (c) Of
            'M':
            Begin
                ComTestBlock := True;
                fildelpage (actptr, startptr, lastptr);
                filundelpage (actptr, startptr, lastptr);
            End;{'M'}
            'C':
            Begin
                ComTestBlock := True;
                filCopyPage (actptr, startptr, lastptr);
            End;{case c of 'C'}
        End{case};
End;

{******************************************************}
Function ComSpecGrant(c: char; linenum: integer): boolean;
    {testet, ob ein Spezialzeichen c zur Zeit erlaubt ist}

Const
    marknocommands:          { w�hrend Markierung nicht erlaubt }
        Set Of byte = [61{F3}, 62{F4}, 64{F6}, 67{F9},
        82{INS}, 83{DEL},
        87{shft f4}, 90{shft F7}, 92{shft F9},
        94{Ctrl F1}, 95{Ctrl F2}, 96{Ctrl F3}, 97{ctrl f4}, 100{ctrl f7}, 102{ctrl F9},
        {Alt F1..F8,F10}    104, 105, 106, 107, 108, 109, 110, 111, 113];

    pagemarknocommands:
        Set Of byte = [66{F8},
        87{shft f4}, 91{shft F8},
        94{Ctrl F1}, 95{Ctrl F2}, 97{ctrl f4}];

    pagenocommands:          { w�hrend Page layout nicht erlaubt }
        Set Of byte = [60{F2}, 73{PU}, 81{PD},
        92{Shft F9},
        132{Ctrl PU}, 118{Ctrl PD},
        95{Ctrl F2} (*,102*){Ctrl F9}, 112{alt f9}];

    markset:                { im Header nicht erlaubt}
        Set Of byte = [61, 62, 65, 66,
        91,
        146{ctrl ins}];

Var
    Ordc: Byte absolute c;
Begin
    ComSpecGrant := true;

    If (pagebuf <> -1) AND (ordc IN pagemarknocommands) Then
    Begin
        ComSpecGrant := false;
        HlpHint (HntUnmarkPageFirst, HintWaitEsc, []);
        Exit;
    End;

    If (mstart.mpag <> -1) AND (ordc IN marknocommands) Then
    Begin
        ComSpecGrant := false;
        HlpHint (HntUnmarkBlockFirst, HintWaitEsc, []);
        Exit;
    End;

    If (setuppage IN actedit) AND (ordc IN pagenocommands) Then
    Begin
        ComSpecGrant := false;
        HlpHint (HntNotAvailableLayout, HintWaitEsc, []);
        Exit;
    End;

    If (IniHeaderFooterLine (linenum)) AND (ordc IN markset) Then
    Begin
        ComSpecGrant := false;
        HlpHint (HntNotAvailableHeader, HintWaitEsc, []);
        Exit;
    End;
End;

{******************************************************}
Procedure ComEdEscape(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    Var resp: Response_Type);
Begin
    inbuffer := '';
    {Wenn Markierung offen: UNMARK}
    If mstart.mpag = -1 Then
    Begin
        If ((setuppage IN actedit) AND
            (NOT (defsetuppage IN actedit))) Then
        Begin
         {Zuletzt wurden die Pagesettings geaendert, escape
          springt ins file zur�ck}
            actedit := actedit - [setuppage];
            IniSwapColors;
            PagShowPage (linenum, actposn, actpost,
                actptr, startptr, lastptr, pagesav, true);
            MarkInit;
            resp := no_response;
        End;
    End
    Else
    Begin
        PagUnMark;
        PagRefPage;
        resp := no_response;
    End;
End;

{******************************************************}
Procedure ComEdReturn(Var linenum, actposn, actpost: integer;
    shiftp, ctrlp: Boolean);

Var
    i: integer;
Begin
    inbuffer := '';
    If shiftp AND (NOT ctrlp) Then{Shft Enter}
    Begin
        If linenum < Pagelength - 1 Then
            inc (linenum, 2)
        Else
            linenum := 2;
        While (Page[linenum, 1] = 'N') Do
        Begin
            If linenum = 52 Then
                linenum := 1;
            Inc (linenum);
        End;
        If NOT (linenum IN [1..pagelength]) Then
            linenum := 1;
    End Else If NOT (shiftp OR ctrlp) Then{Nur Enter}
    Begin
        If linenum >= pagelength Then
            i := pagelength - 1;
        For i := linenum To pagelength Do
            If i < Pagelength Then
                If page[i + 1, 1] = 'N' Then
                    break;
        If (i = pagelength) {and (page[i+1,1]<>'N') } Then
            For i := 0 To linenum - 1 Do
                If page[i + 1, 1] = 'N' Then
                    break;
        While Page[i + 1, 1] = 'N' Do
            Inc (i);
        linenum := i;
    End;

    PagCursorleft (linenum, actposn, actpost);
    LastEntry := other;
    arrowentry := noarr;
End;

{******************************************************}
Function ComEdMaus(mausx, mausy, maustaste: word;
    Var linenum, actposn, actpost: integer): Boolean;

Var
    x: integer;
    gx, gy: integer;
Begin
    ComEdMaus := False;
    If ((mausy >= grminy) AND (mausy <= grmaxy)) Then
    Begin
        gx := gcxcoord;
        gy := gcycoord;
        linenum := IniLNow (mausy) + 1;
        If (linenum < topmargin) Then
            linenum := topmargin;
        If (linenum > pagelength) Then
            linenum := pagelength;
        If page[linenum, 1] = 'N' Then
        Begin
            x := mausx + 3;
            GetNotePosX (x, actposn, linenum, true, true);
        End
        Else
        Begin
            x := mausx;
            TexTxtPosX (x, actpost, linenum, true);
            If actpost < 11 Then
                actpost := 11;
        End;
        If (gx <> gcxcoord) OR (gy <> gcycoord) Then
        Begin
            inc (gcxcoord);
            ISwap (gx, gcxcoord);
            ISwap (gy, gcycoord);
            GcuPatternRestore;
            ISwap (gx, gcxcoord);
            ISwap (gy, gcycoord);
            ComEdMaus := True;
        End;
    End;
    Lastentry := other;
    arrowentry := noarr;
    inbuffer  := '';
End;

{******************************************************}
Procedure ComMouseAssign(mausx, mausy, maustaste: word;
    Var Response: Response_type;
    Var Keyresponse: Char;
    Var shiftp, ctrlp: boolean);
{Umwandeln von Tastendruck in Zeichen}

Begin
    Case maustaste Of

        1: If mausy > grmaxy Then
                If showmenus Then
                    ButActivated (mausx + 8, mausy + 8, response, keyresponse)
                Else
                Begin
                    Response := SPECIALKEY;
                    If mausx > 118 Then
                        KeyResponse := #133
                    Else
                        KeyResponse := #59;
                End;{ Links: Ret }

        2: Response := ESCAPE;{ Rechts: Esc}

        4:
        Begin { Mitte: F8=Mark/UnMark }
            Response := SPECIALKEY;
            KeyResponse := #66;
        End;

        3:
        Begin { L+R: Ctrl-F10=Swap Menu }
            Response := SPECIALKEY;
            KeyResponse := #103;
        End;
        5:
        Begin { L+M: Ctrl-F8=Paste block}
            Response := SPECIALKEY;
            KeyResponse := #101;
        End;
        6:
        Begin { M+R: F10=Symbol Table }
            Response := SPECIALKEY;
            KeyResponse := #68;
        End;
        7:
        Begin { L+M+R: F1=Help }
            Response := SPECIALKEY;
            KeyResponse := #59;
        End;

    End;
    shiftp := false;
    ctrlp  := false;
End;


{******************************************************}
Procedure ComEdArrow(Direction: Movement;
    Var linenum, actposn, actpost: integer);
Var
    x: integer;
Begin
    inbuffer := '';
    symbcount := 0;
    Case Direction Of
        UP:
        Begin
            If ((linenum > linestyletop) OR
                ((NOT (linestyles IN actedit)) AND
                (linenum >= topmargin + 1))) AND (Linenum > 1)
            Then
            Begin
                Dec (linenum);
                If page[linenum, 1] = 'T' Then
                Begin
                    page[linenum] := TrimRight (page[linenum]);
                    If actpost < 11 Then
                        actpost := 11;
                End;
                If page[linenum, 1] = 'N' Then
                Begin
                    x := gcxcoord + 6;
                    GetNotePosX (x, actposn, linenum, true, true);
                End Else If lastentry <> curupdown Then
                Begin
                    x := gcxcoord;
                    TexTxtPosX (x, actpost, linenum, true);
                    If actpost < 11 Then
                        actpost := 11;
                    TexActPosX (x, actpost, linenum, true);
                End Else
                    TexActPosX (x, actpost, linenum, true);
            End;
            lastentry := curupdown;
        End; {UP}

        DOWN:
        Begin
            If linenum < PageLength Then
            Begin
                Inc (linenum);
                If page[linenum, 1] = 'T' Then
                Begin
                    page[linenum] := TrimRight (page[linenum]);
                    If actpost < 11 Then
                        actpost := 11;
                End;
                Case page[linenum, 1] Of

                    'N':
                    Begin
                        x := gcxcoord + 6;
                        GetNotePosX (x, actposn, linenum, true, true);
                    End;

                    'T':
                        If lastentry <> curupdown Then
                        Begin
                            x := gcxcoord;
                            TexTxtPosX (x, actpost, linenum, true);
                            If actpost < 11 Then
                                actpost := 11;
                            TexActPosX (x, actpost, linenum, true);
                        End
                        Else
                            TexActPosX (x, actpost, linenum, true);
                End; {case page[ linenum, 1] of}

            End; {if Linenum < Pagelength}
            lastentry := curupdown;
        End; {DOWN}

        LEFT:
        Begin
            Case page[linenum, 1] Of

                'N':
                Begin
                    x := gcxcoord - 1;
                    GetNotePosX (x, actposn, linenum, true, true);
                    Dec (X);
                    GetNotePosX (x, actposn, linenum, true, false);
                End;

                'T':
                Begin
                    If ActPost > 11 Then
                        actpost := actpost - 1;
                    TexActPosX (x, actpost, linenum, true);
                End;
            End; {case page[ linenum, 1] of}
            Lastentry := other;
        End; {LEFT}

        RIGHT:
        Begin
            Case page[linenum, 1] Of

                'N':
                Begin
                    x := gcxcoord + 1;
                    GetNotePosX (x, actposn, linenum, true, false);
                End;

                'T':
                    SpeTextRight (linenum, actpost);
            End; {case page[ linenum, 1] of}
            Lastentry := other;
        End; {RIGHT}
    End; { case Direction of }
    arrowentry := noarr;
    inbuffer := '';
End;  { ARROW }

{******************************************************}
Procedure ComLineRep(linenum: integer);

Begin
    setcolor (lcolor);
    If ((linenum > topmargin) AND (page[linenum - 1, 1] = 'N')) Then
        GetLine (linenum - 1, gcxcoord - 20);
    If ((linenum > topmargin) AND (page[linenum + 1, 1] = 'N')) Then
        GetLine (linenum + 1, gcxcoord - 20);
    If ((linenum > topmargin) AND (page[linenum + 2, 1] = 'N')) Then
        GetLine (linenum + 2, gcxcoord - 20);
End;

{***********************************************}

Procedure ComDelToSoLn(Var linenum, actposn, actpost: Integer);
Var
    inblock: stringline;
    i, l: integer;
Begin
    inbuffer := '';
    inblock  := page[linenum];
    If inblock[1] = 'N' Then
    Begin
        i := commusicstart (inblock);
        If (copy (inblock, i, 2) = '.1') AND ((inblock[i + 2] < '0') OR (inblock[i + 2] > '9')) Then
            inc (i, 2)
        Else
        Begin
            i := comnext (inblock, i);
            If inblock[comstart (inblock, comnext (inblock, i))] = '.' Then
            Begin
                While (inblock[comstart (inblock, comnext (inblock, i))] = '.') AND (i <> length (inblock)) Do
                    i := comnext (inblock, i);
                i := comnext (inblock, i);
            End;
        End;
        delete (inblock, i, Comstart (inblock, actposn) - i);
        PagRefClearVal (grminx, iniynow (linenum - 5), grmaxx, iniynow (linenum + 3));
        page[linenum] := inblock;
        actposn := i;
        GetActPosX (l, actposn, linenum, true);
    End {if inblock} Else
    Begin
        PagRefClearVal (grminx, iniynow (linenum - 5), grmaxx, iniynow (linenum + 3));
        i := linemarker;
        While inblock[i] = ' ' Do
            inc (i);
        If i >= actpost Then
            i := linemarker + 2;
        delete (inblock, i, actpost - i);
        {    PagRefClearVal(grminx,iniynow(linenum)-6,grmaxx,iniynow(linenum)+4);}
        page[linenum] := inblock;
        actpost := i;
        TexActPosX (l, actpost, linenum, true);
    End;{if inblock else}
End;

{***********************************************}

Function ComEdKey(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    KeyResponse: char; shiftp, ctrlp: Boolean): Boolean;

Var
    ordc: integer;
    Insl, Ins: integer;
    inblock: stringline;
    v: string[3];
    i, k, l, m, y: Integer;
Begin
    ComEdKey := False;
    If ComTestBlock (KeyResponse, linenum, actposn, actpost, actptr,
        startptr, lastptr) Then
        Exit;
    If ComKeyGrant (KeyResponse, linenum) Then
    Begin
        ordc := Byte (KeyResponse);
        Case ordc Of
            10:{ctrl Enter}
            Begin
                If Mstart.MPag <> -1 Then
                Begin
                    HlpHint (HntUnMarkBlockFirst, HintWaitEsc, []);
                    Exit;
                End;{If Mstart.MPag...}
                If page[linenum, 1] = 'T' Then
                    Exit;                         { Mit TLs gebe ich mich nicht ab!  }
                l := linenum;
                ComSysstart (l);                 { Erste Zeile des Systems          }
                ComSysend (Linenum);             { Letzte Zeile des Systems         }

                { unterste Linie, die noch zur linenum geh�rt)                     }
                k := linenum + comskiplinesdown (linenum);

                { i=naechstuntere, nichtleere Linie, ueberspringe Trommelsprache.. }
                i := ComNextLine (k);

                { insl=Zeilennummer wo die neue Linie eingef�gt wird               }
                insl := ComSpaceBetweenNeed (k, l) + k + comsysheight (linenum);

                { ins=Anzahl ben�tigter Leerzeilen                                 }
                ins := ComSpaceBetweenNeed (k, l) + ComSpaceBetweenNeed (linenum, i) + comsysheight (linenum);

                { ->ins=Anzahl einzuschiebender Leerzeilen                         }
                ins := ins - comspacebetween (i, k);
                If ins < 0 Then
                    ins := 0;
                If ComInsPossible (Ins) Then
                Begin
                    For l := 1 To Ins Do
                        SpeInsTextLine (i, actpost, actptr, startptr,
                            lastptr, false);
                    For l := 0 To (ComSysHeight (Linenum) - 1) Do
                    Begin
                        m := pos ('%', page[linenum - l]);
                        inblock := copy (page[linenum - l], 1, m);
                        page[linenum - l, 2] := ' ';
                        While NOT (page[linenum, m] IN Numbers) Do
                            inc (m);
                        inblock := inblock + '.';
                        v := '';
                        While page[linenum, m] IN Numbers Do
                        Begin
                            v := v + page[linenum, m];
                            inc (m);
                        End;
                        val (v, m, y);
                        If y <> 0 Then
                        Begin
                            m := 1;
                            v := '1';
                        End;
                        For y := 1 To m Do
                            inblock := inblock + v + '.';
                        If Searchlastchiffre (linenum - l) <> '0' Then{ Beat �bernehmen }
                            inblock := inblock + Searchlastchiffre (linenum - l);{NL einf�gen}
                        Page[insl - l] := inblock;
                    End;
                    Linenum := Insl;
                    PagRefClearVal (0, IniYnow (linenum - comsysheight (linenum) - 2),
                        GetMaxX, GrMaxY - 9);
                    PagCursorLeft (linenum, actposn, actpost);
                End Else
                    HlpHint (HntNotEnoughSpace, HintWaitEsc, []);
            End;

            127: If mstart.mpag = -1 Then
                Begin
                    delpage := false;
                    delln := page[linenum];
                    SpeLineDelete (linenum, true);
                    PagRefClearVal (0, IniYnow (linenum - 5),
                        gmaxx, grmaxy - 1);
                    PagCursorLeft (linenum, actposn, actpost);
                    lastentry := other;
                    arrowentry := noarr;
                    inbuffer  := '';
                End;{Ctrl BS: -}
        Else If shiftp AND (ordc = 8) Then
                {Shift BS} ComDelToSoLn (linenum, actposn, actpost)
            Else
            Begin
                comedkey := True;
                FileChanged := 1;
                If (page[linenum, 1] = 'N') Then
                    NotEdNoteLine (linenum, actposn, KeyResponse)
                Else
                Begin
                    TexEdTextLine (linenum, actpost, KeyResponse);
                    getredraw (linenum, gcxcoord - 18, gcxcoord);
                    ComLineRep (linenum); {neu f�r TAB PEO}
                    lastentry := other;
                End;
            End; {case else}
            {Case}End;{case}
    End; {if ComKeyGrant}
    comedkey := true;
End;

{******************************************************}
Procedure KillCursor;{New}

Begin
    { TODO: Implement cursor hiding functionality }
    { Original: INT 10h cursor manipulation }
    If NOT CursorKilled Then
    Begin
        Cursorlinestart := 0; { Save cursor info }
        Cursorlineend := 0;
        CursorKilled  := true;
        { Stub: Actual cursor hiding not implemented }
    End;
End;

{******************************************************}

Procedure RestoreCursor;{New}
Begin
    { TODO: Implement cursor restoration functionality }
    { Original: INT 10h cursor manipulation }
    If CursorKilled Then
        CursorKilled := false{ Restore cursor using saved values }{ Stub: Actual cursor restoration not implemented };
End;

{******************************************************}
Procedure ComEdSpecial(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    Var KeyResponse: char; shiftp, ctrlp: boolean);

Var
    c, ch, dummyc: char;
    SLColor: Byte;
    lasts: Byte;
    i, j, k, result: integer;
    Insl, ins: integer;
    ordc: integer;
    x, y: integer;
    l: integer;
    attr: word;
    playnext: Boolean;
    dummyb, temp1, temp2: Boolean;
    repline: boolean;
    SPic: Pointer;
    st: String;
    inblock: stringline;
    delfil: text;
    lineattr: lineattrtype;
    lastsnd: integer;


    Function SearchFirst(Var st: String; Var linenum, actposn: Integer): Boolean;
    Var
        c: char;
        lnum: integer;


        Function ValidLine: Boolean;
        Begin
            actposn := comMusicStart (st);
{ IF Pos('/',St)<>0 Then
    Length(St):=Pos('/',St);}
            While ((actposn <= length (st)) AND (UtiComputeGroup (st[actposn], c) = 0)) Do
                inc (actposn);
            ValidLine := (actposn <= length (st)) AND (GetDrawSymbol (lnum, actposn, false));
        End;

    Begin
        lnum := linenum;
        dec (linenum);
        st := Page[lnum];
        While (NOT ValidLine) AND (lnum <> linenum) Do
        Begin
            ComEdReturn (lnum, actposn, actpost,
                false, false);
            st := page[lnum];
        End;
        If lnum = linenum Then
        Begin
            inc (linenum);
            hlpHint (HntlineEmpty, HintNormalTime, []);
            SearchFirst := False;
            Exit;
        End;
        linenum := lnum;
    End;


    Procedure SwapColor;
    Begin
        If LColor <> soundcolor Then
            LColor := soundcolor
        Else
            LColor := Slcolor;
        SetColor (LColor);
    End;


Begin
    repline := true;
    If ComSpecGrant (KeyResponse, linenum) Then
    Begin
        ordc := Byte (KeyResponse);
        Case ordc Of
            162: {alt ins} If delpage Then
                Begin
                    {insert page von delfile}
                    i := pagecount;
                    FilSavePage (1, PageLength, actptr, startptr, lastptr);
                    assign (delfil, 'delpage');
                    reset (delfil);
                    If IOResult <> 0 Then
                    Begin
                        HlpHint (HntCannotOpenFile, HintWaitEsc, []);
                        Exit;
                    End;
                    For j := 1 To pagelength Do
                    Begin
                        readln (delfil, page[j]);
                        If IOResult <> 0 Then
                        Begin
                            close (delfil);
                            HlpHint (HntCannotReadFile, HintWaitEsc, []);
                            Exit;
                        End;
                    End;
                    PagRefPage;
                    close (delfil);
                    FilFindPage (pagecount, i, actptr, startptr, lastptr);
                    PagRefPage;
                End;
            163:{alt del}
            Begin{save page to buffer}
                delpage := true;
                assign (delfil, 'delpage');
                rewrite (delfil);
                If IOResult <> 0 Then
                Begin
                    HlpHint (HntCannotCreateFile, HintWaitEsc, []);
                    Exit;
                End;
                For i := 1 To pagelength Do
                Begin
                    writeln (delfil, page[i]);
                    If IOResult <> 0 Then
                    Begin
                        close (delfil);
                        HlpHint (HntCannotWriteFile, HintWaitEsc, []);
                        Exit;
                    End;
                End;
                close (delfil);
                {goto previous page if this is last page}
                If actptr = lastptr Then
                    pagecount := pagecount - 1;
                If pagecount > 0 Then
                    PagShowPage (linenum, actposn, actpost, actptr,
                        startptr, lastptr, pagecount, false){show new page, dont save this page}
                Else
                Begin
                    PagGetSetupPage (actptr, startptr, lastptr);
                    pagecount := 1;
                    PagRefPage;
                End;
            End;
            15: {shift tab}
            Begin
                FileChanged := 1;
                If page[linenum, 1] = 'T' Then
                    TexEdTextLine (linenum, actpost, chr (240))
                Else If page[linenum, 1] = 'N' Then
                    If symbcount > 0 Then
                        dec (symbcount);
            End;

            59: {F1: this help table}
            Begin
                SetViewPort (0, 0, GetMaxX, GetMaxY, true);
                ClearViewPort;
                HlpCommandTable;
                Repeat
                    SetPalette (12, 0);             { Color 12=PalReg[0]                    }
                    SetPalette (13, 15);            { Color 13=PalReg[15]                   }
                    IniSetDACReg (60, 0, 0, 0);       { light red ->Schwarz                   }
                    IniSetDACReg (5, 63, 63, 63);     { magenta   ->Weiss  }
                    IniSetDACReg (63, 10, 10, 10);    { Weiss     ->Grau   Mausfarbe!!!       }
                    c := IniMausEscape;
                Until c = chr (27);
                PagRefPage;
                repline := false;
            End;

            60:  {F2: save file}
            Begin
                XClearKbd;
                GetMem (SPic, ImageSize (grminx, grmaxy - 49,
                    grMaxX, grmaxy));
                GetImage (GrMinX, grmaxy - 49,
                    GrMaxX, grmaxy, SPic^);
                HlpHintFrame (grminx, grmaxy - 48, grmaxx, grmaxy);
                GetFAttr (infile, attr);
                If (attr AND readonly) <> 0 Then
                Begin
                    txtfnt.Write (grminx + 20, grmaxy - 32,
                        'Read only file, changes will not be saved!',
                        getcolor, sz8x16, stnormal);
                    txtfnt.Write (grminx + 20, grmaxy - 16,
                        'Press any key to continue',
                        getcolor, sz8x16, stnormal);
                    xClearKbd;
                    Repeat
                    Until KeyPressed;
                    xClearKbd;
                    PutImage (GrMinX, grmaxy - 49, SPic^, NormalPut);
                    FreeMem (Spic, ImageSize (grminx, grmaxy - 49, grmaxx, grmaxy));
                    Exit;
                End;
                fileChanged := 0;
                FilSavePage (1, pagelength, actptr, startptr, lastptr);
                rewrite (infile);
                If IOResult <> 0 Then
                Begin
                    HlpHint (HntCannotCreateFile, HintWaitEsc, [actfilename]);
                    Exit;
                End;
                If bufffile Then
                Begin
                    WriteLn (infile, '$$$RNSBUFFER$$$');
                    If IOResult <> 0 Then
                    Begin
                        close (infile);
                        HlpHint (HntCannotWriteFile, HintWaitEsc, [actfilename]);
                        Exit;
                    End;
                    WriteLn (infile, '    -1    -1    -1    -1    -1    -1    -1');
                    If IOResult <> 0 Then
                    Begin
                        close (infile);
                        HlpHint (HntCannotWriteFile, HintWaitEsc, [actfilename]);
                        Exit;
                    End;
                    FilHeapToFile (infile, actptr, startptr, lastptr,
                        false, false, false);
                End Else
                    FilHeapToFile (infile, actptr, startptr, lastptr,
                        false, false, true);
                FilFindPage (pagecount, result, actptr, startptr, lastptr);
                PagRemovePage (actptr, startptr, lastptr);
                PutImage (GrMinX, grmaxy - 49, SPic^, NormalPut);
                FreeMem (Spic, ImageSize (grminx, grmaxy - 49, grmaxx, grmaxy));
            End;

            61: {F3: noteline insert}
            Begin
                FileChanged := 1;
                SpeInsNoteLine (linenum, actposn, actptr, startptr, lastptr);
                PagCursorLeft (linenum, actposn, actpost);
                repline := false;
            End;

            62: {F4: emptyline insert}
            Begin
                FileChanged := 1;
                SpeInsTextLine (linenum, actpost, actptr, startptr,
                    lastptr, false);
                PagCursorLeft (linenum, actposn, actpost);
                repline := false; {sonst gibts Doppellinien wegen ComLineRep PEO}
            End;

            63: {F5: sound play}
            Begin
                For i := linenum To pagelength Do
                    If page[i, 1] = 'N' Then
                        break;
                If page[i, 1] <> 'N' Then
                    For i := 1 To linenum Do
                        If page[i, 1] = 'N' Then
                            break;
                If page[i, 1] = 'N' Then
                Begin
                    inblock := page[i];
                    getnoteattributes (inblock, lineattr);
                End;
                CtrlF5 := False;
                GcuPatternRestore;
                paused := false;
                playnext := True;
                st := '';
                HlpBottomLine (st);                                  {[+/-]=speed}
                PagBottomFrame;
                IniSpacedText (2, 54, '  Space = pause  ', frHigh);
                IniSpacedText (2, 56, '  Esc   = stop   ', frHigh);
                IniSpacedText (2, 58, ' ' + #24 + 'Esc = stop end ', frHigh);

                IniSpacedText (20, 54, ' (A/C)Enter = ' + #24 + #25 + 'Line ', frHigh);
                IniSpacedText (20, 56, ' 0=roundCent 5=reset ', frHigh);
                IniSpacedText (20, 58, '                     ', frLow);


                IniSpacedText (42, 54, ' on/off: BPTSLMR ([{� ', frHigh);
                IniSpacedText (42, 56, ' (' + #24 + '/Ctrl/Alt)�: speed ', frHigh);
                IniSpacedText (42, 58, '                      ', frHigh);
   {      IniSpacedText(42,54,' �, '+#24+'� = speed�1, �10 ',frHigh);
        IniSpacedText(42,56,' Ctrl� = speed�,:2    ',frHigh);
        IniSpacedText(42,58,'  Alt� = speed�,:1.33 ',frHigh);  }
                IniDrawSoundState;

                IniSpacedText (65, 54, ' / * = LPMBPM ', frHigh);
                Str (RnsSetup.SndLengthSpm: 4: 3, st);
                While Length (st) < 8 Do
                    st := ' ' + st;
                If RnsSetup.SndLengthPer = 1 Then
                    st := st + '   BPM '
                Else
                    st := st + '   LPM ';
                IniSpacedText (65, 56, st, frLow);
                IniSpacedText (65, 58, ' . = round -PM ', frHigh);
                GcuPatternRestore;
                If page[linenum, 5] = 'H' Then
                Begin
                    RnsSetup.SndChar := 'L';
                    SndPlaySound (linenum, actposn, actpost, actptr, startptr,
                        lastptr, true, playnext);
                    gcupatternrestore;
                End;
                If playnext Then
                    Repeat
                        While xkeypressed Do
                            xreadkey (temp1, temp2);
                        SndPlaySound (linenum, actposn, actpost,
                            actptr, startptr, lastptr, false, playnext);
                        If PlayNext Then
                        Begin
                            ComEdReturn (linenum, actposn, actpost, shiftp, ctrlp);
                            If PlaySuccess Then
                            Begin
                                PagRefreshPage (refxmin, refymin, refxmax, refymax);
                                If playnext Then
                                    gcupatternrestore;
                            End;
                            IniRefInit;
                        End;
                    Until PlayNext = False;
                PagPutBottomLine;
                GcuPatternRestore;
                PagCursorleft (linenum, actposn, actpost);
                repline := false;
            End;

            64: {F6: header + footer}
            Begin
                FileChanged := 1;
                Sp2SetHeaderFooter (linenum);
                repline := false;
            End;

            65: {F7: copy line (to Ctrl-F7-Buffer)}
            Begin
                saveln := page[linenum];
                HlpHint (HntSavingLine, HintNormalTime, []);
                repline := false;
            End;

            66: {F8: mark/undo block}
            Begin
                If mstart.mpag = -1 Then
                Begin
                    MarkStart (IniPos (linenum, actposn, actpost),
                        linenum, pagecount);
                    MarkDisplay;
                End Else If mend.mpag = -1 Then
                Begin
                    MarkEnd (IniPos (linenum, actposn, actpost),
                        linenum, pagecount);
                    MarkDisplay;
                End Else
                Begin
                    PagUnmark;
                    {  PagRefPage; }
                    PagRefClearVal (grminx, iniYnow (linenum), grmaxx, iniYnow (linenum));
                End{end block};
                repline := false;
            End;

            67: {F9: mark/undo page}
            Begin
                If pagebuf = -1 Then
                    filmarkpage
                Else
                    filunmarkpage;
                repline := false;
            End;

            68: {F10: symbols table}
            Begin
                c := 'a';
                temp1 := false;
                While (c <> chr (27)) Do
                Begin
                    Mausdunkel;
                    HlpSymbolSelect (c);
                    If ((c >= 'a') AND (c <= 'z')) Then
                    Begin
                        SatSymbolParam (c);
                        temp1 := true;
                    End;
                End;
                If temp1 Then
                    SatSaveSym;
                PagRefPage;
                repline := false;
            End;

            133: {F11: StatusBar/MouseMenu}
            Begin
                showmenus := NOT showmenus;
                setlinestyle (solidln, 0, 1);
                If showmenus Then
                    ButDraw
                Else
                    PagPutBottomLine;
                repline := false;
            End;

            134: {F12: Refresh Page}
            Begin
                PagRefPage;
                repline := false;
            End;

            71: {home: begin of line}
            Begin
                PagCursorLeft (linenum, actposn, actpost);
                repline := false;
            End;

            73: {PgUp: previous page}
            Begin
                If shiftp Then
                    SpeJoinPage (linenum, actposn, actpost,
                        actptr, startptr, lastptr)
                Else If PageCount > 1 Then
                    PagShowPage (linenum, actposn, actpost, actptr,
                        startptr, lastptr,
                        pagecount - 1, true);
                repline := false;
            End;

            79: {End: end of line}
            Begin
                PagCursorRight (linenum, actposn, actpost);
                repline := false;
            End;

            81: {PgDn: next page}
            Begin
                If shiftp Then
                Begin{ shift PdDn}
                    FilSavePage (1, PageLength, actptr, startptr, lastptr);
                    FilFindPage (30002, pagecount, actptr, startptr, lastptr);
                    IniNewPage (linenum);
                    PagGetPageFromHeap (actptr, startptr, lastptr, i);
                    PagCursorLeft (linenum, actposn, actpost);
                    PagShowPage (linenum, actposn, actpost,
                        actptr, startptr, lastptr, pagecount + 1, true);
                End Else
                Begin
                    ActFilename := UpString (actfilename);
                    If ((actptr <> lastptr) OR
                        (HlpAreYouSure ('New page?'{ + ': [Enter] to continue, [PgUp] to cancel - or:'}, hpEdit))) Then
                        PagShowPage (linenum, actposn, actpost, actptr,
                            startptr, lastptr,
                            pagecount + 1, true)
                    Else
                        pagrefpage;
                End;
                repline := false;
            End;

            82: {Insert: symb/char insert}
            Begin
                FileChanged := 1;
                If NOT shiftp Then
                Begin
                    If page[linenum, 1] = 'T' Then
                        TexInsChar (linenum, actpost)
                    Else { if page[linenum,1]='T'}
                    Begin
                        NotInsNote (linenum, actposn);
                        PagRefClearVal (gcxcoord - 25, IniYnow (linenum - 5), gmaxX, IniYnow (linenum + 3));
                    End;
                End Else {if not shiftp}
                Begin
                    SpeInsTextLine (linenum, actpost,
                        actptr, startptr, lastptr, true);
                    PagCursorLeft (linenum, actposn, actpost);
                    PagRefPage;
                End; {else if not shiftp}
                repline := false;
            End;

            83: {Delete: sym/char delete}
            Begin
                FileChanged := 1;
                inbuffer := '';
                If NOT shiftp Then
                Begin
                    If page[linenum, 1] = 'T' Then
                        TexDelChar (linenum, actpost)
                    Else { if page[linenum,1] = 'T' then }
                    Begin
                        NotDelNote (linenum, actposn);
                        If gcxcoord <= gmaxx Then
                            PagRefClearVal (gcxcoord - 25, IniYnow (linenum - 5), gmaxX, IniYnow (linenum + 3))
                        Else
                            PagRefClearVal (gmaxx - 25, IniYnow (linenum - 5), gmaxX, IniYnow (linenum + 3));
                    End;
                End Else{shift del: Delete to end of line}
                Begin
                    If page[linenum, 1] = 'T' Then
                        TexDelToEOL (linenum, actpost)
                    Else { if page[linenum,1] = 'T' then }
                    Begin
                        If gcxcoord > IniLineEnd (page[linenum]) Then
                            PagCursorRight (linenum, actposn, actpost);
                        NotDelToEOL (linenum, actposn);
                        PagCursorRight (linenum, actposn, actpost);
                    End;
                    If (linenum + 3) > 52 Then
                        i := 52
                    Else
                        i := linenum + 3;
                    If Page[linenum, 1] = 'N' Then
                    Begin
                        If gcxcoord <= gmaxx Then
                            PagRefClearVal (gcxcoord - 25, IniYnow (linenum - 5), gmaxX - 1, IniYnow (i))
                        Else
                            PagRefClearVal (gmaxx - 25, IniYnow (linenum - 5), gmaxX - 1, IniYnow (i));
                    End Else
                    Begin
                        TexClearLine (linenum, gcxcoord - 6);
                        getredraw (linenum, gcxcoord - 12, grmaxx);
                    End;
                End;
            End;

            84: {Shift F1: show / hide}
            Begin
                Sp2VisiMenu;
                PagRefPage;
                repline := false;
            End;

            85: {Shift F2: (save as or quit) Save Y/N}
            Begin
                If FileChanged = 1 Then
                Begin
                    GetMem (SPic, ImageSize (grminx, grmaxy - 49,
                        grMaxX, grmaxy));
                    GetImage (GrMinX, grmaxy - 49,
                        GrMaxX, grmaxy, SPic^);
                    HlpHintFrame (grminx, grmaxy - 48, grmaxx, grmaxY);
                    txtfnt.Write (grminx + 20, grmaxY - 32,
                        'File ' + ActFileName + ' has been changed!',
                        getcolor, sz8x16, stnormal);
                    txtfnt.Write (grminx + 20, grmaxY - 16,
                        'Save changes? [Y]/[N]. [Esc] to cancel',
                        getcolor, sz8x16, stnormal);
                    Repeat
                        c := IniMausEscape;
                        If c = #13 Then
                            c := 'Y'
                        Else If C = #0 Then
                        Begin
                            c := XReadKey (temp1, temp2);
                            If C = #73 Then
                                c := #27;
                            If C = #81 Then
                                c := 'Y';
                        End Else
                            c := UpCase (C);
                    Until (C = 'Y') OR (C = 'N') OR (C = #27);
                    If C = 'Y' Then
                        FileChanged := 2
                    Else If c = 'N' Then
                        FileChanged := 0
                    Else
                        keyresponse := #0;
                    PutImage (GrMinX, grmaxy - 49, SPic^, NormalPut);
                End;
                repline := false;
            End;

            86: {Shift F3: noteline define}
            Begin
                SpeEdLineAttr (linenum, actposn, actpost, startptr, lastptr);
                repline := false;
            End;

            87: {Shift F4: insert page}
            Begin
                i := pagecount;
                FilSavePage (1, PageLength, actptr, startptr, lastptr);
                PagGetSetupPage (actptr, startptr, lastptr);
                FilFindPage (pagecount, i, actptr, startptr, lastptr);
                PagRefPage;
                repline := false;
            End;

            88: {Shift F5: sound options}
            Begin
                CtrlF5 := False;
                SndSoundMenu (linenum, actposn, actpost,
                    actptr, startptr, lastptr, true);
                PagRefPage;
                repline := false;
            End;

            89: {Shift F6: search + replace}
            Begin
                FileChanged := 1;
                Sp2SearchAndReplace (linenum, actposn, actpost, actptr,
                    startptr, lastptr);
                repline := false;
            End;

            90: {Shift F7: line commands}
            Begin
                SpeLineCommands (linenum, actposn, actpost, actptr,
                    startptr, lastptr);
                repline := false;
            End;

            91: {Shift F8: block commands}
            Begin
                FileChanged := 1;
                SpeBlockCommands (linenum, actposn, actpost, actptr,
                    startptr, lastptr, ' ');
                repline := false;
            End;

            92: {Shift F9: page commands}
            Begin
                FileChanged := 1;
                Sp2PageCommands (linenum, actposn, actpost, actptr,
                    startptr, lastptr);
                repline := false;
            End;

            93: {Shift F10: swap keyboard}
            Begin
                Sp2SwapKeyboard;
                PagRefPage;
                repline := false;
            End;

            94: {Ctrl F1: print menu}
            Begin
                PrmPrintMenu (linenum, actposn, actpost,
                    actptr, startptr, lastptr);
                PagRefPage;
                repline := false;
            End;

            95: {Ctrl F2: split file}
            Begin
                FileChanged := 1;
                pagesav := pagecount;
                SpeSplitFile (actptr, startptr, lastptr);
                pagecount := pagesav - 1;
                PagRefPage;
            End;

            96: {Ctrl F3: split line}
            Begin
                inblock := page[linenum];
                st := inblock;
                If inblock[1] <> 'N' Then
                    exit;
                If gcxcoord > IniLineEnd (page[linenum]) Then
                    PagCursorRight (linenum, actposn, actpost);
                i := comstart (inblock, actposn);
                SetLength (page[linenum], i - 1);
                page[linenum] := page[linenum] + '.';
                pagrefclearval (grminx, iniynow (linenum - 5), grmaxx, iniynow (linenum + 3));
                inblock := copy (inblock, i, length (inblock) - i + 2);
                If NOT ComEdKey (linenum, actposn, actpost,
                    actptr, startptr, lastptr, #10, shiftp, ctrlp) Then
                Begin
                    page[linenum] := st;
                    exit;
                End;
                SetLength (page[linenum], commusicstart (page[linenum]) + 1);
                page[linenum] := page[linenum] + inblock;
            End;
            97: {ctrl F4 split page}
            Begin
                SpeSplitPage (linenum, actposn, actpost,
                    actptr, startptr, lastptr);
                repline := false;
            End;
            98: {Ctrl F5: Play Symbol}
            Begin
                CtrlF5 := True;
                Paused := False;
                lastS  := 0;
                If Page[Linenum, 1] <> 'N' Then
                    ComEdReturn (linenum, actposn, actpost, false, false);
                GCUCursorClear;
                Dec (ActPosn);
                SLColor := LColor;
                dummyb  := showmenus;
                showmenus := False;
                While XKeyPressed Do
                    XReadKey (Temp1, Temp2);
                C := #1;
                PagPutBottomLine;   {### brauchts leider noch wenn Mausmenu, dann Ctrl-F5}
                {IniSpacedText( 2,gmaxy div charheight - 5,' Space=pause ',frHigh);}
                IniSpacedText (2, gmaxy DIV charheight - 3, ' Esc  = stop ', frHigh);
                IniSpacedText (2, gmaxy DIV charheight - 1, ' ' + #27 + ' ' + #26 + '  = step ', frHigh + frdel3d);
                IniSpacedText (36, gmaxy DIV charheight - 5, '                    ', frLow);
                IniSpacedText (36, gmaxy DIV charheight - 3, '                    ', frLow);
                IniSpacedText (36, gmaxy DIV charheight - 1, '                    ', frLow);
                IniSpacedText (72, gmaxy DIV charheight - 3, '        ', frLow + frdel3d);
                IniSpacedText (16, gmaxy DIV charheight - 1,
                    Copy (sndgetcentstr (addcent), 2, 19), frLow);
                actposn := linenum;
                If (page[linenum, 1] <> 'N') Then
                    ComEdReturn (i, actposn, actpost, false, false);
                If page[linenum, 1] <> 'N' Then
                Begin
                    hlpHint (HntpageEmpty, HintNormalTime, []);
                    Exit;
                End;
                If NOT SearchFirst (st, linenum, actposn) Then
                    exit;
                Repeat
                    i := UtiComputeGroup (St[actposn], ch);
                    SwapColor;
                    If NOT GetDrawSymbol (linenum, actposn, true) Then
                        Actposn := commusicStart (st);
                    If NOT Paused Then
                    Begin
                        If (Ch <= 'z') AND (Ch >= 'a') Then
                        Begin
                            lastsnd := sympar[ch, 3, i];
                            sound (Round (sympar[ch, 3, i] * mulcent));
                        End Else If (ch = '&') Then
                            sound (Round (lastsnd * mulcent));
                    End Else
                        nosound;
                    SwapColor;
                    PagShowCurPosDistances (Linenum, ActPosn, ActPost, 2);
                    If Paused Then
                        IniSpacedText (2, gmaxy DIV charheight - 5, ' Space= play ', frHigh)
                    Else
                        IniSpacedText (2, gmaxy DIV charheight - 5, ' Space=pause ', frHigh);
                    Case xreadkey (temp1, temp2) Of
                        #0: Case xreadkey (temp1, temp2) Of
                                #165: ;{Alt-Tab}
                                #28:
                                Begin{Alt-Enter}
                                    GetDrawSymbol (linenum, actposn, true);
                                    dummyc := #28;
                                    ComEdSpecial (linenum, actposn, actpost,
                                        actptr, startptr, lastptr,
                                        dummyc, temp1, temp2);
                                    SearchFirst (st, linenum, actposn);
                                End;{#28}
                                #77:
                                Begin{Rechts}
                                     {                  SetColor(SLColor);}
                                    GetDrawSymbol (linenum, actposn + lasts, true);
                                    Repeat
                                        inc (actposn);
                                        If (actposn > length (st)) Then
                                            actposn := commusicstart (st);
                                    Until (((UtiComputeGroup (St[actposn], c) <> 0) OR (c = '&')) AND
                                            (GetDrawSymbol (linenum, actposn, false)));
                                End;
                                #75:
                                Begin{Links}
                                     {                  SetColor(SLColor);}
                                    GetDrawSymbol (linenum, actposn + lasts, true);
                                    Repeat
                                        dec (actposn);
                                        If (actposn < commusicstart (st)) Then
                                            actposn := length (st);
                                    Until (((UtiComputeGroup (St[actposn], c) <> 0) OR (c = '&')) AND
                                            (GetDrawSymbol (linenum, actposn, false)));
                                End;{#75}
                                {Wenn NumLock off: ----------------------------------------------------------}
                                #82:
                                Begin{Insert=+1Hz}
                                    Inc (addcent);
                                    SndUpdateMulCent;
                                    IniSpacedText (16, gmaxy DIV charheight - 1,
                                        Copy (sndgetcentstr (addcent), 2, 19), frLow);
                                End;
                                #83:
                                Begin{Delete=-1Hz}
                                    Dec (Addcent);
                                    SndUpdateMulCent;
                                    IniSpacedText (16, gmaxy DIV charheight - 1,
                                        Copy (sndgetcentstr (addcent), 2, 19), frLow);
                                End;
                                #71:
                                Begin{Home=+10Hz}
                                    addcent := addcent + 100;
                                    SndUpdateMulCent;
                                    IniSpacedText (16, gmaxy DIV charheight - 1,
                                        Copy (sndgetcentstr (addcent), 2, 19), frLow);
                                End;
                                #79:
                                Begin{End=-10Hz}
                                    addcent := addcent - 100;
                                    SndUpdateMulCent;
                                    IniSpacedText (16, gmaxy DIV charheight - 1,
                                        Copy (sndgetcentstr (addcent), 2, 19), frLow);
                                End;
                                #73:
                                Begin{PageUp=+100Hz}
                                    MulCent := MulCent * 2; {Reaktion vorl�ufig:1Oktave h�her}
                                    SndUpDateAddCent;
                                    IniSpacedText (16, gmaxy DIV charheight - 1,
                                        Copy (sndgetcentstr (addcent), 2, 19), frLow);
                                End;
                                #81:
                                Begin{PageDn=-100Hz}
                                    Mulcent := Mulcent / 2;
                                    SndUpdateAddCent;
                                    IniSpacedText (16, gmaxy DIV charheight - 1,
                                        Copy (sndgetcentstr (addcent), 2, 19), frLow);
                                End;
                                #72: ;{CursorUp=}
                                #80: ;{CusorDn=}
                                {----------------------------------------------------------------------------}
                            Else
                                c := #1;
                            End;{Case}{#0}
   (*            #9 : Begin{Tab}
                Inc(symbcount);
              End;*)
                        '0':
                        Begin{.  = round}
                            addcent := 100 * Round (addcent / 100);
                            SndUpdateMulCent;
                            IniSpacedText (16, gmaxy DIV charheight - 1,
                                Copy (sndgetcentstr (addcent), 2, 19), frLow);
                        End;
                        '4':
                        Begin{lf   = -100 cent}
                            addcent := addcent - 100;
                            SndUpdateMulCent;
                            IniSpacedText (16, gmaxy DIV charheight - 1,
                                Copy (sndgetcentstr (addcent), 2, 19), frLow);
                        End;
                        '7':
                        Begin{hm = /2}
                            Mulcent := Mulcent / 2;
                            SndUpdateAddCent;
                            IniSpacedText (16, gmaxy DIV charheight - 1,
                                Copy (sndgetcentstr (addcent), 2, 19), frLow);
                        End;
                        '1':
                        Begin{End  = -1 cent}
                            Dec (Addcent);
                            SndUpdateMulCent;
                            IniSpacedText (16, gmaxy DIV charheight - 1,
                                Copy (sndgetcentstr (addcent), 2, 19), frLow);
                        End;
                        '8':
                        Begin{Up   = +200 cent}
                            Addcent := Addcent + 200;
                            SndUpdateMulCent;
                            st := sndgetcentstr (addcent);
                            IniSpacedText (16, gmaxy DIV charheight - 1,
                                Copy (sndgetcentstr (addcent), 2, 19), frLow);
                        End;
                        '2':
                        Begin{Dn   = -200 cent}
                            addcent := addcent - 200;
                            sndUpdateMulCent;
                            st := sndgetcentstr (addcent);
                            IniSpacedText (16, gmaxy DIV charheight - 1,
                                Copy (sndgetcentstr (addcent), 2, 19), frLow);
                        End;
                        '3':
                        Begin{rg   = +1 cent}
                            Inc (Addcent);
                            SndUpdateMulCent;
                            IniSpacedText (16, gmaxy DIV charheight - 1,
                                Copy (sndgetcentstr (addcent), 2, 19), frLow);
                        End;
                        '5':
                        Begin{m   = reset}
                            Addcent := 0;
                            Mulcent := 1;
                            IniSpacedText (16, gmaxy DIV charheight - 1,
                                Copy (sndgetcentstr (addcent), 2, 19), frLow);
                        End;
                        '6':
                        Begin{rg   = +100 cent}
                            Addcent := Addcent + 100;
                            SndUpdateMulCent;
                            IniSpacedText (16, gmaxy DIV charheight - 1,
                                Copy (sndgetcentstr (addcent), 2, 19), frLow);
                        End;
                        '9':
                        Begin{pgup = *2}
                            MulCent := MulCent * 2;
                            SndUpDateAddCent;
                            IniSpacedText (16, gmaxy DIV charheight - 1,
                                Copy (sndgetcentstr (addcent), 2, 19), frLow);
                        End;
                        ' ':
                        Begin
                            If Paused Then
                                NoSound
                            Else If (Ch <> ' ') AND (Ch <> '.') AND (Ch <> ',') Then
                                Sound (Round (sympar[ch, 3, i] * mulcent));
                            Paused := NOT Paused;
                        End;
                        #27: c := #0;
                        #13:
                        Begin
                            NoSound;
                            GetDrawSymbol (linenum, actposn + lasts, true);
                            ComEdReturn (linenum, actposn, actpost,
                                false, false);
                            SearchFirst (st, linenum, actposn);
                        End;
                    Else c := #1;
                    End;{Case}
                Until c = #0;
                nosound;
                {        St:=Page[linenum];}
                i := UtiComputeGroup (St[actposn + lasts], ch);
                GetDrawSymbol (linenum, actposn + lasts, true);
                showmenus := dummyb;
                PagPutBottomLine;
                repline := false;
            End;
            99: {Ctrl F6: search repeat}
            Begin
                dummyb := Sp2SearchString (linenum, actposn, actpost,
                    actptr, startptr, lastptr);
                If ((dummyb) AND (replaceflag)) Then
                Begin
                    FileChanged := 1;
                    Sp2ReplaceString (linenum, actposn, actpost,
                        actptr, startptr, lastptr);
                End;
                repline := false;
            End;

            100: {Ctrl-F7: paste line}
            Begin
                If SpeSpaceInPage (1) Then
                Begin
                    SpeLineInsert (linenum, saveln);
                    y := IniYnow (linenum - 6);
                    PagRefClearVal (0, y, GetMaxX, grmaxy - 1);
                    PagCursorLeft (linenum, actposn, actpost);
                End Else
                    HlpHint (HntNotEnoughSpace, HintWaitEsc, []);
                repline := false;
            End;{ctrl f7}

            101: {Ctrl F8: paste block}
            Begin
                FileChanged := 1;
                SpeInsertBuffer (linenum, actposn, actpost, actptr,
                    startptr, lastptr, dummyb);
                PagUnMark;
                repline := false;
            End;

            102: {Ctrl F9: Paste Page}
                filPastePage (actptr, startptr, lastptr);

            103: {ctrl F10: Choose Font}
            Begin
                FilFontSelect;
                repline := false;
            End;

            16..50: {Alt-Character, wandeln in Bereich 128..153}
            Begin
                If KeyResponse = #28 Then
                Begin
                    If NOT (shiftp OR ctrlp) Then
                    Begin{Alt-Enter}
                        If Linenum = 1 Then
                            Linenum := 2;
                        For i := Linenum - 1 Downto 1 Do
                            If Page[i, 1] = 'T' Then{erste TL oberhalb suchen}
                                break;
                        If (i = 1) AND (Page[i, 1] <> 'T') Then{Unterste TL suchen}
                            For i := Pagelength Downto Linenum Do
                                If Page[i, 1] = 'T' Then
                                    Break;
                        If i < linenum Then
                        Begin{erste NL oberhalb suchen}
                            While (Page[i, 1] <> 'N') AND (i > 1) Do
                                Dec (i);
                            If i <= 1 Then{keine NL oberhalb�>von unten beginnen}
                                i := pagelength;
                        End;{if i<linenum}
                        If i > linenum Then
                            While (Page[i, 1] <> 'N') AND (i >= linenum) Do
                                dec (i){unterste NL suchen};{if i>linenum}
                        linenum := i;
                    End Else
                    Begin{if not(shiftp or ctrlp)}
                        If shiftp AND (NOT ctrlp) Then
                        Begin{shft-Alt-Enter}
                            If linenum > 2 Then
                                Dec (linenum, 2)
                            Else
                                linenum := pagelength;
                        End Else If ctrlp AND (NOT shiftp) Then
                        Begin{Ctrl-Alt-Enter}
                            If Mstart.MPag <> -1 Then
                            Begin
                                HlpHint (HntUnMarkBlockFirst, HintWaitEsc, []);
                                Exit;
                            End;{If Mstart.MPag...}
                            If page[linenum, 1] = 'T' Then
                                Exit; { Mit TLs gebe ich mich nicht ab!}
                            l := linenum;
                            ComSysEnd (l);        { Letzte Zeile des Systems       }
                            ComSysStart (Linenum);{ Erste Zeile des Systems        }

                            { oberste Linie, die noch zu l geh�rt                 }
                            k := linenum - comskiplinesup (linenum);

                            { i=naechstobere, nichtleere Linie                    }
                            i := ComPrevLine (k);

                            { ins=Anzahl ben�tigter Leerzeilen                    }
                            ins := ComSpaceBetweenNeed (i, linenum) + ComSpaceBetweenNeed (l, k) + comsysheight (linenum);

                            { ->ins=Anzahl einzuschiebender Leerzeilen            }
                            { insl=Zeilennummer wo die neue Linie eingef�gt wird  }
                            ins := ins - comspacebetween (k, i);
                            If ins < 0 Then
                            Begin
                                ins := 0;
                                insl := linenum - ComSpaceBetweenNeed (l, linenum) - comsysheight (linenum);
                            End Else
                                insl := i + ComSpaceBetweenNeed (i, linenum) + 1;


                            If ComInsPossible (Ins) Then
                            Begin
                                For x := 1 To Ins Do
                                    SpeInsTextLine (k - 1, actpost, actptr, startptr,
                                        lastptr, false);
                                linenum := linenum + ins;
                                For x := 0 To (ComSysHeight (Linenum)) - 1 Do
                                Begin
                                    inblock := copy (page[linenum + x], 1, pos ('%', page[linenum + x])) + '.1.';
                                    page[linenum + x, 2] := ' ';
                                    If Searchlastchiffre (linenum + x) <> '0' Then{ Beat �bernehmen }
                                        inblock := inblock + Searchlastchiffre (linenum + x) + '.';{NL einf�gen}
                                    Page[insl + x] := inblock;
                                End;
                                Linenum := Insl;
                                ComSysEnd (Linenum);
                                PagRefClearVal (0, IniYnow (linenum - 2),
                                    GetMaxX, GrMaxY - 9);
                                PagCursorLeft (linenum, actposn, actpost);
                            End Else
                                HlpHint (HntNotEnoughSpace, HintWaitEsc, []);

                        End{if shiftp and not ctrlp}{IF ctrlp and (not shiftp)};{IF if shiftp and not ctrlp else}
                    End;{if not(shiftp or ctrlp)}
                    PagCursorleft (linenum, actposn, actpost);
                    LastEntry := other;
                    arrowentry := noarr;
                End Else
                Begin{IF KeyResponse=#28}
                    FileChanged := 1;
                    c := IniAltChar (KeyResponse);
                    ComEdKey (linenum, actposn, actpost,
                        actptr, startptr, lastptr, c, shiftp, ctrlp);
                End;{IF KeyResponse=#28 else}
                If (linenum < 1) OR (linenum > pagelength) Then
                    linenum := 1;
            End;{case 16..50}
            104: {Alt F1: Start senkrechte Klammer}
            Begin
                If page[linenum, 1] = 'T' Then
                Begin
                    setcolor (lcolor);
                    FileChanged := 1;
                    TexEdTextLine (linenum, actpost, chr (229));
                    dec (actpost);
                    TexActPosX (x, actpost, linenum, true);
                    inc (Linenum, 3);
                    inc (gcycoord, 24);
                    While Page[Linenum, 1] = 'N' Do
                    Begin
                        inc (Linenum);
                        inc (gcycoord, 8);
                    End;
                End Else If page[linenum, 1] = 'N' Then
                    NotSysStart (linenum);
                repline := false;
            End;

            105: {Alt F2: End senkrechte Klammer}
            Begin
                If page[linenum, 1] = 'T' Then
                Begin
                    FileChanged := 1;
                    TexEndVKlammer (linenum, actpost, gcxcoord - char2width);
                End Else If page[linenum, 1] = 'N' Then
                    NotSysEnd (linenum);
                repline := false;
            End;

            106: {Alt F3: Start waagrechte Klammer}
            Begin
                If page[linenum, 1] = 'T' Then
                Begin
                    FileChanged := 1;
                    TexEdTextLine (linenum, actpost, chr (231));
                End;
                repline := false;
            End;

            107: {Alt F4: End waagrechte Klammer}
            Begin
                If page[linenum, 1] = 'T' Then
                Begin
                    FileChanged := 1;
                    TexEndHKlammer (linenum, actpost);
                End;
                repline := false;
            End;

            108: {Alt F5: vertical line}
            Begin
                If page[linenum, 1] = 'T' Then
                Begin
                    FileChanged := 1;
                    TexEdTextLine (linenum, actpost, chr (234));
                End;
                repline := false;
            End;

            109: {Alt F6: vert. short line}
            Begin
                If page[linenum, 1] = 'T' Then
                Begin
                    FileChanged := 1;
                    TexEdTextLine (linenum, actpost, chr (236));
                End;
                repline := false;
            End;

            110: {Alt F7: horizontal line - full (resp. 3D-Line}
            Begin
                If page[linenum, 1] = 'T' Then
                Begin
                    FileChanged := 1;
                    TexEdTextLine (linenum, actpost, chr (233));
                End;
                repline := false;
            End;

            111:{Alt F8: vertical line full (resp. 3D-Line)}
            Begin
                If page[linenum, 1] = 'T' Then
                Begin
                    FileChanged := 1;
                    TexEdTextLine (linenum, actpost, chr (237));
                End;
                repline := false;
            End;
            112: {Alt F9: setup page}
            Begin
                FileChanged := 1;
                actedit := actedit + [setuppage];
                IniSwapColors;
                Pagesav := pagecount;
                PagShowPage (linenum, actposn, actpost,
                    actptr, startptr, lastptr, 0, true);
                repline := false;
            End;
            113: {Alt F10: number of page}
                If page[linenum, 1] = 'T' Then
                Begin
                    FileChanged := 1;
                    TexEdTextLine (linenum, actpost, chr (235));
                End;
            140: {Alt F12: ScreenSave}
            Begin
                SaveScreen;
                PagRefPage;
                repline := false;
            End;
            117: {Ctrl End: end of page}
            Begin
                linenum := pagelength;
                PagCursorLeft (linenum, actposn, actpost);
                repline := false;
            End;

            115: {Ctrl Left} If page[linenum, 1] = 'T' Then
                    TexWordLeft (Linenum, Actpost);
            116: {Ctrl Right} If page[linenum, 1] = 'T' Then
                    TexWordRight (Linenum, Actpost);
            141: {Ctrl Up};
            145: {Ctrl Down};
            118: {Ctrl PgDn: last page}
            Begin
                PagShowPage (linenum, actposn, actpost,
                    actptr, startptr, lastptr, 30002, true);
                repline := false;
            End;

            119: {Ctrl Home: begin of page}
            Begin
                linenum := 1;
                PagCursorLeft (linenum, actposn, actpost);
                repline := false;
            End;

            132: {Ctrl PgUp: first page}
            Begin
                PagShowPage (linenum, actposn, actpost,
                    actptr, startptr, lastptr, 1, true);
                repline := false;
            End;

            146: {Ctrl Insert}
            Begin
                inbuffer := '';
                If lastbuf = 2 Then
                Begin
                    If delpage Then
                    Begin
                        FileChanged := 1;
                        filundelpage (actptr, startptr, lastptr);
                    End;
                End Else If lastbuf = 1 Then
                Begin
                    If mend.mpag <> -1 Then
                    Begin
                        filbufclear;
                        MarMarkToBuffer (actptr, startptr, lastptr);
                    End;
                    SpeInsertBuffer (linenum, actposn, actpost, actptr,
                        startptr, lastptr, dummyb);
                    PagUnMark;
                    PagRefPage;
                    FileChanged := 1;
                End;
                repline := false;
            End;

            147: {Ctrl Delete}
            Begin
                inbuffer := '';
                FileChanged := 1;
                If pagebuf <> -1 Then
                    fildelpage (actptr, startptr, lastptr)
                Else If mstart.mpag <> -1 Then
                Begin
                    SpeBlockCommands (linenum, actposn, actpost, actptr,
                        startptr, lastptr, 'D');
                    PagRefPage;
                End Else;
                repline := false;
            End;
        End; {case ord(KeyResponse) of }
        If repline Then
            ComLineRep (linenum);
        arrowentry := noarr;
        If ((ord (KeyResponse) < 16) OR (ord (KeyResponse) > 50)) Then
            LastEntry := other;
    End; { if ComSpecGrant }
    nosound;
End; { SPECIALKEY }


Procedure ComSysEnd(Var Linenum: Integer);
Begin
    If Page[Linenum, 1] <> 'N' Then
        Exit;
    While (Page[Linenum + 1, 1] = 'N') AND (Linenum <= Pagelength) Do
        Inc (Linenum);
End;


Procedure ComSysStart(Var Linenum: Integer);
Begin
    If Page[Linenum, 1] <> 'N' Then
        Exit;
    While (Page[Linenum - 1, 1] = 'N') AND (Linenum > 0) Do
        Dec (Linenum);
End;


Function ComSysHeight(Linenum: integer): Integer;
Var
    i: Integer;
Begin
    i := 1;
    While (Page[Linenum - 1, 1] = 'N') AND (Linenum > 0) Do
        Dec (linenum);
    While (Page[Linenum + i, 1] = 'N') AND (Linenum + i <= Pagelength) Do
        Inc (i);
    ComSysHeight := i;
End;


Function ComSpaceUpNeed(linenum: integer): Byte;
{ Anzahl der freien linien, die beim einf�gen einer NL mittel ctrl-enter
  oder ctrl-f3 nach oben ben�tigt werden}
Var
    inblock: stringline;
    lineattr: lineattrtype;
Begin
    If ComTL (linenum) Then
        ComSpaceUpNeed := 1
    Else
    Begin
        inblock := page[linenum];
        GetNoteAttributes (inblock, lineattr);
        Case lineattr.linestyle Of
            1:{thick}      ComSpaceUpNeed := 2;
            2:{staff}      ComSpaceUpNeed := 4;
            3:{thin}       ComSpaceUpNeed := 2;
            4:{dotted}     ComSpaceUpNeed := 2;
            5:{helpline}   ComSpaceUpNeed := 2;
        End;
    End;
End;


Function ComSpaceDownNeed(linenum: integer): Byte;
{ Anzahl der freien linien, die beim einf�gen einer NL mittels ctrl-enter
  oder ctrl-f3 nach unten ben�tigt werden}
Var
    inblock: stringline;
    lineattr: lineattrtype;
Begin
    If ComTL (linenum) Then
        ComSpaceDownNeed := 1
    Else
    Begin
        inblock := page[linenum];
        GetNoteAttributes (inblock, lineattr);
        Case lineattr.linestyle Of
            1:{thick}      ComSpaceDownNeed := 2;
            2:{staff}      ComSpaceDownNeed := 2;
            3:{thin}       ComSpaceDownNeed := 2;
            4:{dotted}     ComSpaceDownNeed := 2;
            5:{helpline}   ComSpaceDownNeed := 2;
        End;
    End;
End;


Function ComSpaceBetweenNeed(l1, l2: integer): Byte;
Var
    s1, s2: integer;
Begin
    s1 := ComSpaceDownNeed (l1);
    s2 := ComSpaceUpNeed (l2);
    If s1 < s2 Then
        s1 := s2;
    If comTL (l1) OR comTL (l2) Then
        dec (s1);
    ComSpaceBetweenNeed := s1;
End;


Function ComSpaceBetween(l1, l2: integer): byte;
Begin
    l1 := abs (l1 - l2);
    If l1 > 1 Then
        ComSpaceBetween := l1 - 1
    Else
        ComSpaceBetween := 0;
End;


Function ComLinesUpBelong2(linenum: integer): Byte;
    { Anzahl Linien oberhalb, die zu dieser Linie geh�ren (oder umgekehrt...) }
    { NL: 0, TL: 2 }
Begin
    If ComTL (linenum) AND NOT comHorLine (linenum) Then    {!!!}
        ComLinesUpBelong2 := 2
    Else
        ComlinesUpBelong2 := 0;
End;


Function ComLinesDownBelong2(linenum: integer): Byte;
{ Anzahl der Linien unterhalb, die unabh�ngig von deren Art zu dieser Linie
  geh�ren k�nnen
  leere TL: 1, benutzte TL: 2, NL: Falls n�chste Linie auch NL, dann 1,
  sonst je nach Linientyp }
Var
    inblock: stringline;
    lineattr: lineattrtype;
Begin
    If ComTL (linenum) Then
    Begin
        If ComUsedTL (linenum) Then
            ComLinesDownBelong2 := 2
        Else
            ComLinesDownBelong2 := 1;
    End Else If ComNL (linenum + 1) Then
        ComLinesDownBelong2 := 1
    Else
    Begin
        inblock := page[linenum];
        GetNoteAttributes (inblock, lineattr);
        Case lineattr.linestyle Of
            1:{thick}      ComlinesDownBelong2 := 2;
            2:{staff}      ComlinesDownBelong2 := 3;
            3:{thin}       ComlinesDownBelong2 := 2;
            4:{dotted}     ComlinesDownBelong2 := 2;
            5:{helpline}   ComlinesDownBelong2 := 2;
        End;
    End;
End;


Function ComLineBelong2(linenum: integer): Byte;
{ 0 wenn linenum nicht zur n�chstoberen Linie geh�rt,
  sonst Anzahl der Linien unterhalb, die zu dieser geh�ren k�nnen,
  Notenlinie: immer 0,
  tl: 0, falls zuviele Linien oberhalb leer, 1, falls Linie leer, sonst 2}
Var
    i: integer;
Begin
    If comNL (linenum) Then
    Begin
        ComLineBelong2 := 0;
        exit;
    End;
    For i := 1 To ComLinesUpBelong2 (linenum) Do
        If ComUsedL (linenum - i) Then
        Begin
            ComLineBelong2 := ComLinesDownBelong2 (linenum);
            Exit;
        End;
    ComLineBelong2 := 0;
End;


Function comskiplinesDown(linenum: integer): integer;
{ Anzahl der zu ueberspringenden linien, falls unterhalb eine NL eingef�gt
  werden soll
  linenum=nummer der NL
  i=z�hler,b=temp
}
Var
    i, a, b: integer;
Begin
    i := 1;
    a := ComLinesDownBelong2 (linenum);
    While i <= a Do
    Begin
        b := ComLineBelong2 (linenum + i);
        If b = 0 Then
            break;
        a := i + b;
        inc (i);
    End;
    If comNL (linenum + i) Then
        dec (i);
    While NOT comUsedL (linenum + i - 1) Do
        dec (i);
    comskiplinesdown := i - 1;
End;


Function comskiplinesUp(linenum: integer): integer;
{ Anzahl der zu ueberspringenden linien
  linenum=nummer der NL
  tx=anzahl der zu beruecksichtigenden linien}
Begin
    If comUsedTL (linenum - 1) Then
        comskiplinesUp := 1
    Else
        comskiplinesUp := 0;
End;


Function ComNL(linenum: integer): Boolean;
    {NL?}
Begin
    ComNL := page[linenum, 1] = 'N';
End;


Function ComTL(linenum: integer): Boolean;
    {TL?}
Begin
    ComTL := page[linenum, 1] = 'T';
End;


Function ComUsedTL(linenum: integer): Boolean;
    { TL & nicht leer}
Begin
    If Page[linenum, 1] <> 'T' Then
    Begin
        ComUsedTL := False;
        Exit;
    End;
    While page[linenum, Length (page[linenum])] = ' ' Do
        SetLength (page[linenum], Length (page[linenum]) - 1);
    If Length (Page[linenum]) < linemarker Then
        ComUsedTL := False
    Else
        ComUsedTL := True;
End;


Function ComUsedL(linenum: integer): Boolean;
Begin
    ComUsedL := ComNL (linenum) OR ComUsedTL (linenum);
End;


Function ComNextLine(linenum: integer): integer;
Begin
    Repeat
        Inc (linenum);
    Until (Linenum > PageLength) OR ComUsedL (linenum);
    ComNextLine := Linenum;
End;


Function ComPrevLine(linenum: integer): integer;
Begin
    Repeat
        Dec (linenum);
    Until (linenum = 0) OR ComNL (linenum) OR ComUsedTL (linenum);
    ComPrevLine := Linenum;
End;


Function ComInsPossible(num: integer): Boolean;
Begin
    If num > pagelength Then
    Begin
        ComInsPossible := False;
        Exit;
    End;
    dec (num);
    While Num >= 0 Do
    Begin
        If LineUsed (pagelength - Num) Then
        Begin
            ComInsPossible := False;
            Exit;
        End;
        dec (num);
    End;
    ComInsPossible := True;
End;


Function ComMusicStart(inblock: Stringline): Byte;
    { Data Start }
Begin
    If inblock[1] <> 'N' Then
        ComMusicStart := 0
    Else
        ComMusicStart := pos ('%', inblock) + 1;
End;


Function ComStart(inblock: Stringline; actposn: Byte): Byte;
    { Anfangsposition der Note, auf die actposn zeigt }
Begin
    If actposn > length (inblock) Then
        actposn := length (inblock);
    If inblock[1] <> 'N' Then
        ComStart := 0
    Else
    Begin
        While (actposn < length (inblock)) AND NOT (inblock[actposn] IN notes) Do
            inc (actposn);
        While (actposn > 0) AND (inblock[actposn - 1] IN Notes) Do
            dec (actposn);
        If actposn >= commusicstart (inblock) Then
            ComStart := actposn
        Else
            comstart := commusicstart (inblock);
    End;
End;


Function ComEnd(inblock: StringLine; Actposn: Byte): Byte;
    { Ende der Note, auf die actposn zeigt }
Begin
    If inblock[1] <> 'N' Then
        ComEnd := 0
    Else
    Begin
        While (actposn < length (inblock)) AND NOT (inblock[actposn] IN notes) Do
            inc (actposn);
        While (actposn < length (inblock)) AND (inblock[actposn + 1] IN Notes) Do
            Inc (actposn);
        If inblock[actposn] IN notes Then
            ComEnd := actposn
        Else
            comend := 0;
    End;
End;


Function ComLen(inblock: StringLine; ActPosn: Byte): Byte;
Begin
    ComLen := ComEnd (inblock, actposn) - ComStart (inblock, actposn);
End;


Function comnext(inblock: stringline; actposn: Byte): Byte;
Begin
    actposn := comend (inblock, actposn) + 1;
    If actposn = 1 Then
        actposn := commusicstart (inblock);
    actposn := comstart (inblock, actposn);
    comnext := actposn;
End;


Function comprev(inblock: stringline; actposn: Byte): byte;
Begin
    actposn := comstart (inblock, actposn);
    If actposn < commusicstart (inblock) + 2 Then
        actposn := length (inblock)
    Else
        dec (actposn, 2);
    actposn := comstart (inblock, actposn);
    comprev := actposn;
End;


Function Searchlastchiffre(linenum: Integer): String;
Var
    st: String;
    a:  Byte;
Const
    chiffres: Set Of Char = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
Begin
    a := Length (Page[linenum]);
    st := '';
    While (NOT (Page[linenum, a] IN chiffres)) AND (a <> 0) Do
        dec (a);
    If a < 34 Then
    Begin
        Searchlastchiffre := '0';
        Exit;
    End;
    While (Page[linenum, a - 1] IN chiffres) AND (a <> 0) Do
        dec (a);
    While Page[linenum, a] IN chiffres Do
    Begin
        st := st + Page[linenum, a];
        inc (a);
    End;{while}
    Searchlastchiffre := St;
End;


Function CopyLine(Src, Des: Integer): Boolean;
Var
    inblock: stringline;
Begin
    If (Des > PageLength) OR (Des < 1) OR (Src > PageLength) OR (Src < 1) Then
    Begin
        HlpHint (HntOutOfRange, HintWaitEsc, []);
        CopyLine := False;
        Exit;
    End;
    If page[src] = 'N' Then
    Begin
        inblock := copy (page[Src], 1, 33) + '.';
        If Searchlastchiffre (src) <> '0' Then
            inblock := inblock + Searchlastchiffre (Src);{NL einf�gen}
        If Page[Des, 4] <> ' ' Then
        Begin
            HlpHint (HntCopyLineToHeader, HintWaitEsc, []);
            CopyLine := False;
            Exit;
        End;
    End{ if page[src]='N'} Else
        inblock := page[src];
    Inblock[4] := ' ';
    CopyLine := TRUE;
    If LineUsed (Des) Then
    Begin
        If SpeSpaceInPage (1) Then
            SpeLineInsert (Des, inblock)
        Else
        Begin
            HlpHint (HntNotEnoughSpace, HintWaitEsc, []);
        End;
    End Else
        Page[Des] := inblock;
End;{Func CopyLine}


Function LineUsed(Linenum: Byte): Boolean;
Begin
    While (Length (Page[Linenum]) <> 9) AND (Page[Linenum, Length (Page[Linenum])] = ' ') Do
        SetLength (Page[linenum], Length (Page[linenum]) - 1);
    If Length (Page[Linenum]) > 9 Then
        LineUsed := True
    Else
        LineUsed := False;
End;


Function ComHorLine(linenum: integer): Boolean;
Begin
    ComHorLine := pos (#233, page[linenum]) <> 0;
End;

End.
