Unit markunit;

Interface

Uses
    graph,
    crt,
    dos,
    gcurunit,
    initsc;

Procedure MarkInit;
Procedure MarkStart(actpos, linenum, nowpage: integer);
Procedure MarkEnd(actpos, linenum, nowpage: integer);
Procedure MarkDisplay;
Procedure MarMarkToBuffer(actptr, startptr, lastptr: listptr);
Procedure MarDeleteBlock(Var actptr, startptr, lastptr: listptr);
Procedure MarkInverse(lstart, lend, mstartx, mendx: integer);

Implementation

Uses textunit,
    fileunit,
    utilunit,
    specunit,
    pageunit,
    getunit;
                                                                              {
лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл}

Procedure MarRemoveFromHeap(Var heapsptr, heapeptr,
    actptr, startptr, lastptr: listptr);
{Entfernt von heapsptr bis und ohne heapeptr vom Heap}

Var tempptr, prevptr: listptr;

Begin
    Repeat
        tempptr := heapsptr;
        prevptr := heapsptr^.last;
        heapsptr := heapsptr^.next;
        heapsptr^.last := prevptr;
        prevptr^.next := heapsptr;
        If startptr = tempptr Then startptr := heapsptr;
        If actptr = tempptr Then actptr := heapsptr;
        dispose (tempptr);
        tempptr := heapsptr;
    Until tempptr = heapeptr;
End;
                                                                              {
лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл}

Procedure MarDeleteBlock(Var actptr, startptr, lastptr: listptr);
{lscht den Markierten Block}

Var heapfptr: listptr;
    eline, j: byte;
    lpage, emptyline: integer;
    endreached: boolean;
    tempbuf, inblock: stringline;
    tbufpos: byte;
    i: integer;
                                                                              {
    нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн}

    Procedure MarEmptyLines(Var heapptr: listptr; Var emptyl: integer);

    Var i: integer;

    Begin
        If emptyl > 0 Then
        Begin
            FilStringSeparate (tempbuf, heapptr, startptr, lastptr, tbufpos);
            tempbuf := '';
            tbufpos := 0;
            For i := 1 To emptyl Do
                FilHeapInsertString ('T' + chr (0), heapptr, startptr, lastptr,
                    heapptr, false);
            emptyl := 0;
        End;
    End;
                                                                              {
    нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн}

    Procedure MarClearLine(Var heapptr: listptr; Var emptyl: integer;
        linenum: integer; delflag: boolean);
    Begin
        FilCheckLine (tempbuf, inblock, heapptr, startptr, lastptr,
            tbufpos, endreached, false, false);
        {lasse Header/Footer unverndert}
        If ((length (inblock) > 4) AND (inblock[4] <> 'F')) Then
        Begin
            FilCheckLine (tempbuf, inblock, heapptr, startptr, lastptr,
                tbufpos, endreached, true, delflag);
            If delflag Then emptyl := emptyl + 1;
        End Else
        Begin
            MarEmptyLines (heapptr, emptyl);
            FilCheckLine (tempbuf, inblock, heapptr, startptr, lastptr,
                tbufpos, endreached, true, false);
        End;
        If linenum = pagelength Then
        Begin
            MarEmptyLines (heapptr, emptyl);
            FilStringSeparate (tempbuf, heapptr, startptr, lastptr, tbufpos);
        End;
    End;
                                                                              {
    нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн}

Begin
    If NOT marpartline Then
    Begin
        {initialisieren des buffers}
        tempbuf := '';
        tbufpos := 0;
        emptyline := 0;

        {aktuelle Seite speichern}
        FilSavePage (topmargin, pagelength, actptr, startptr, lastptr);

        {Pointer auf Beginn und Ende des markierten Bereichs suchen}
        FilFindPtr (mstart.mpag, mstart.mline, heapfptr,
            startptr, lastptr, false);

        {Anzahl ganze Seiten zum Loeschen berechnen}
        lpage := mend.mpag - mstart.mpag - 1;
        If lpage < 0 Then lpage := 0;

        {letzte Zeile auf erster Seite bestimmen}
        If mstart.mpag = mend.mpag Then
            eline := mend.mline Else
        Begin
            eline := pagelength;
        End;

        {Zeilen loeschen}
        For i := mstart.mline To eline Do
            MarClearLine (heapfptr, emptyline, i, true);

        {Seitenende der ersten Seite suchen}
        For i := eline + 1 To pagelength Do
            MarClearLine (heapfptr, emptyline, i, false);

        {ganze Seiten loeschen}
        For j := 1 To lpage Do
            For i := topmargin To pagelength Do
                FilHeapExtractString (inblock, heapfptr, startptr, lastptr);

        {letzte Seite}
        If mstart.mpag < mend.mpag Then
        Begin
            {initialisieren des buffers}
            tempbuf := '';
            tbufpos := 0;
            emptyline := 0;
            eline := mend.mline;

            {Zeilen loeschen}
            For i := topmargin To eline Do
                MarClearLine (heapfptr, emptyline, i, true);

            {Seitenende der letzten Seite suchen}
            For i := eline + 1 To pagelength Do
                MarClearLine (heapfptr, emptyline, i, false);
        End;

        {Suchen der aktuellen Seite}
        FilFindPage (pagecount, lpage, actptr, startptr, lastptr);
        While ((actptr = lastptr) AND (pagecount > 0)) Do
        Begin
            pagecount := pagecount - 1;
            FilFindPage (pagecount, lpage, actptr, startptr, lastptr);
        End;
        PagGetPageFromHeap (actptr, startptr, lastptr, i);
    End Else  {if not marpartline}
    If mstart.mpag = pagecount Then
        delete (page[mstart.mline], mstart.mpos,
            mend.mpos - mstart.mpos + 1) Else {if mstart.mpage = pagecount then}
    Begin
        If pagecount < mstart.mpag Then
            i := mstart.mpag - 1 Else
            i := mstart.mpag;
        FilFindPtr (i, mstart.mline, heapfptr,
            startptr, lastptr, false);
        FilHeapExtractString (inblock, heapfptr, startptr, lastptr);
        delete (inblock, mstart.mpos, mend.mpos - mstart.mpos + 1);
        FilHeapInsertString (inblock + chr (0), heapfptr, startptr, lastptr,
            heapfptr, false);
    End{Teil einer Zeile lschen}{else if mstart.mpag = pagecount then}; {else if marpartline }
End;
                                                                              {
лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл}

Procedure MarMarkToBuffer(actptr, startptr, lastptr: listptr);
{Kopiert den markierten Teil in den Buffer}

Var inblock: stringline;
    bufsptr, bufeptr: listptr;
    sline, eline, i: byte;
                                                                              {
    нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн}

    Procedure MarPtrToBuf;
    {Kopiert von bufsptr bis bufeptr in den buffer}

    Var tempptr: listptr;
        count, tbufpos: byte;
        endreached, ok1, ok2: boolean;
        tempbuf: stringline;


    Begin
        count := 1;
        tempptr := bufsptr;
        tbufpos := 0;
        tempbuf := '';
        ok1 := false;
        ok2 := false;
        Repeat
            FilCheckLine (tempbuf, inblock, tempptr, startptr, lastptr,
                tbufpos, endreached, true, false);
            If ok1 Then
                ok2 := ((bufeptr <> tempptr) OR (endreached)) Else
                ok1 := (bufeptr = tempptr);
            If NOT (ok1 AND ok2) Then
            Begin
                While length (inblock) < linemarker Do
                    inblock := inblock + ' ';
                If ((length (inblock) < 4) OR (inblock[4] <> 'F')) Then
                    FilHeapInsertString (inblock + chr (0), bufactptr, bufstartptr,
                        bufendptr, bufactptr, false);
                count := count + 1;
                If count = pagelength Then
                Begin
                    FilHeapSqueeze (bufactptr, bufstartptr, bufendptr, false);
                    count := 1;
                End;
            End;
        Until (ok1 AND ok2);
        FilHeapSqueeze (bufactptr, bufstartptr, bufendptr, false);
    End;
                                                                               {
    нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн}

Begin
    If (mstart.mpag = -1) OR (mend.mpag = -1) Then
        exit;
    filbufclear;
    lastbuf := 1;
    {Bereich vor der aktuellen Seite}
    If pagecount > mstart.mpag Then
    Begin
        {suche Startpointer}
        FilFindPtr (mstart.mpag, mstart.mline, bufsptr, startptr, lastptr,
            false);
        {Suche endpointer}
        If pagecount > mend.mpag Then FilFindPtr (mend.mpag, mend.mline, bufeptr, startptr, lastptr,
                true) Else
            bufeptr := actptr;
        {Kopiere in Buffer}
        MarPtrToBuf;
    End;
    {Aktuelle Seite kopieren}
    If ((pagecount >= mstart.mpag) AND (pagecount <= mend.mpag)) Then
    Begin
        {erste Zeile}
        If pagecount > mstart.mpag Then sline := topmargin Else
            sline := mstart.mline;
        {letzte Zeile}
        If pagecount < mend.mpag Then eline := pagelength Else
            eline := mend.mline;
        {Kopieren in den Buffer}
        For i := sline To eline Do
            If NOT IniHeaderFooterLine (i) Then FilHeapInsertString (page[i] + chr (0), bufactptr, bufstartptr, bufendptr,
                    bufactptr, false);
        FilHeapSqueeze (bufactptr, bufstartptr, bufendptr, false);
    End; { if ((pagecount >= mstart.mpag) and (pagecount <= mend.mpag)) }

    {Bereich nach der aktuellen Seite}
    If pagecount < mend.mpag Then
    Begin
        If pagecount >= mstart.mpag Then bufsptr := actptr Else
            FilFindPtr (mstart.mpag - 1, mstart.mline, bufsptr,
                startptr, lastptr, false);
        FilFindPtr (mend.mpag - 1, mend.mline, bufeptr, startptr, lastptr,
            true);
        {Kopiere in Buffer}
        MarPtrToBuf;
    End;
End;
                                                                              {
лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл}

Procedure MarSwitchStyle(Var switch: boolean);

Begin
    If switch Then
    Begin
        SetColor (speccolor);
        SetLineStyle (4, $AAAA, 1);
        switch := false;
    End Else
    Begin
        SetColor (speccolor);
        SetLineStyle (4, $5555, 1);
        switch := true;
    End;
End;
                                                                              {
лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл}

Procedure MarkDrawLine(i1, i2, j1: integer; firstswitch: boolean);
{zeichnet einen Balken am linken Rand/rechten Rand}

Var j2, i: integer;
    switch: boolean;

Begin
    j2 := j1 + 5;
    switch := firstswitch;
    For i := i1 To i2 Do
    Begin
        MarSwitchStyle (switch);
        Line (j1 + 1, i, j2, i);
    End;
End;

{лллллллллллллллллллллллл Markierungen ллллллллллллллллллллллллллллллллллллллл}

Procedure MarkInverse(lstart, lend, mstartx, mendx: integer);

Var i, i1, i2, j1, j2: integer;
    switch: boolean;

Begin
    {ўўўўўўўўўўўўўўўўўўўўўўўўErste Zeile ўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўў}
    i1 := IniYnow (lstart) - 4;
    If page[lstart, 1] = 'N' Then
        i1 := i1 + 1;
    i2 := i1 + 6{markheight};

    j1 := mstartx + 1;
    j2 := gmaxX - GcuRightMargin + drightmargin {- 1};
    If lend = lstart Then
        j2 := mendx;

    switch := true;
    If j2 = j1 + 7 Then switch := false;
    If marpartline Then switch := false;
    If page[lstart, 1] = 'T' Then switch := false;

    MarSwitchStyle (switch);
    For i := i1 To i2 Do
    Begin
        Line (j1, i, j2, i);
        MarSwitchStyle (switch);
    End;

(*  if lend > lstart{ + 1} then
  begin
{ўўўўўўўўўўўўўўўўўўўўўўўў Zwischenzeile links ўўўўўўўўўўўўўўўўўўўўўўўўўўўў}
    i1:= i2 + 1; *)
    {    i2:= IniYnow(lend) -4; }

{    switch:= false;
    if (page[lstart,1] = 'N') xor
       (page[lend  ,1] = 'N') then
    begin
      if (page[lstart,1] = 'N') and
         (page[lend  ,1] = 'T') and
         (lend>lstart+1)       then
        switch:= false;
      if (page[lstart,1] = 'T') and
         (page[lend  ,1] = 'N') and
         (lend>lstart+1)       then
        switch:= false;
      if (page[lstart,1] = 'N') and
         (page[lend  ,1] = 'N') then
        switch:= true;
      MarkDrawLine(i1, i2, IniLeftMargin, false);
    end;
    if (page[lstart,1] = 'T') or
       (page[lend  ,1] = 'T') then
    begin
      if (page[lstart,1] = 'T') and
         (page[lend  ,1] = 'N') then
        switch:= true;
      MarkDrawLine(i1, i2-1, IniLeftMargin, true);
    end;  }
    {ўўўўўўўўўўўўўўўўўўўўўўўў Zwischenzeile rechts ўўўўўўўўўўўўўўўўўўўўўўўўўўў}
{    j1:= gmaxX - GcuRightMargin + drightmargin-6;

    if page[lend, 1] = 'T' then
      MarkDrawLine(i1, i2-1, j1, false)
    else
      MarkDrawLine(i1, i2  , j1, true);
  end;     }

    If lend > lstart Then
    Begin
        {ўўўўўўўўўўўўўўўўўўўўўўўў letzte Zeile ўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўў}

        i1 := IniYnow (lend) - 3; {i2 + 1;}
        If page[lend, 1] = 'T' Then
            i1 := i1 - 1;
        If (page[lend, 1] = 'T') AND
            (lend = lstart + 1) Then
            i1 := i1 - 1;
        If (page[lstart, 1] = 'N') AND
            (page[lend, 1] = 'T') AND
            (lend = lstart + 1) Then
            i1 := i1 + 1;
        If (page[lstart, 1] = 'T') AND
            (page[lend, 1] = 'N') AND
            (lend = lstart + 1) Then
            i1 := i1 - 2;
        If (page[lstart, 1] = 'N') AND
            (page[lend, 1] = 'N') AND
            (lend = lstart + 1) Then
            i1 := i1 - 1;

        i2 := i1 + 6{markheight};
        If (page[lstart, 1] = 'N') AND
            (page[lend, 1] = 'N') AND
            (lend = lstart + 1) Then
            i2 := i2;
        If (page[lstart, 1] = 'N') AND
            (page[lend, 1] = 'T') AND
            (lend = lstart + 1) Then
            i2 := i2;
        If (page[lend, 1] = 'T') AND
            (lend = lstart + 1) Then
            i2 := i2 + 1;
        If (page[lstart, 1] = 'N') AND
            (page[lend, 1] = 'T') AND
            (lend = lstart + 1) Then
            i2 := i2 - 1;
        If (page[lstart, 1] = 'T') AND
            (page[lend, 1] = 'N') AND
            (lend = lstart + 1) Then
            i2 := i2 + 2;
        If (page[lstart, 1] = 'N') AND
            (page[lend, 1] = 'N') AND
            (lend = lstart + 1) Then
            i2 := i2 + 1;

        j1 := IniLeftMargin + 1;
        j2 := gmaxX - GcuRightMargin + drightmargin {- 1};

        switch := false;
        If (page[lstart, 1] = 'N') AND
            (page[lend, 1] = 'N') AND
            (lend = lstart + 1) Then
            switch := true;
        If page[lend, 1] = 'T' Then
            switch := true;
        If (page[lend, 1] = 'T') AND
            (lend = lstart + 1) Then
            switch := false;
        If (page[lstart, 1] = 'N') AND
            (page[lend, 1] = 'T') AND
            (lend = lstart + 1) Then
            switch := true;
        If (page[lstart, 1] = 'T') AND
            (page[lend, 1] = 'N') Then
            switch := false;

        For i := i1 To i2 Do
        Begin
            Line (j1, i, j2, i);
            MarSwitchStyle (switch);
        End;
    End; { if lend > lstart then }
End;
                                                                              {
лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл}

Procedure MarkStart(actpos, linenum, nowpage: integer);
{Starte Block}

Var i: integer;

Begin
    mstart.mline := linenum;
    mstart.mpag := nowpage;
    i := actpos;
    If page[linenum, 1] = 'N' Then
        UtiCharBegin (page[linenum], i);
    mstart.mpos := i;
    mstart.mxcoord := gcxcoord - (actpos - i + 1) * char2width;
End;
                                                                              {
лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл}

Procedure MarkEnd(actpos, linenum, nowpage: integer);
{Beende Block}

Var i, x: integer;
    mpos, mline, mpag: integer;
Begin
    If ((mstart.mpag < nowpage) OR
        ((mstart.mpag = nowpage) AND (mstart.mline < linenum)) OR
        ((mstart.mpag = nowpage) AND (mstart.mline = linenum) AND
        (mstart.mpos <= actpos))) Then
    Begin
        {    FilBufClear;}
        If ((mstart.mpag <> nowpage) OR (mstart.mline <> linenum)) Then
        Begin
            {block markierung,  mehr als eine Zeile}
            mend.mline := linenum;
            mend.mpos  := length (page[mend.mline]);
            mend.mpag  := nowpage;
            mend.mxcoord := gmaxX - Gcurightmargin + drightmargin - 1;
            mstart.mxcoord := IniLeftMargin;
            marpartline := false;
        End Else
        Begin
            mend.mline := linenum;
            mend.mpag  := nowpage;
            mend.mpos  := actpos;
            If page[linenum, 1] = 'N' Then
                While IniNumChar (page[linenum, mend.mpos + 1]) Do mend.mpos := mend.mpos + 1;
            mend.mxcoord := gcxcoord + char2width - 1;
            marpartline  := true;
        End;
    End Else
    Begin
        mpos := mstart.mpos;
        mpag := mstart.mpag;
        mline := mstart.mline;
        x := mstart.mxcoord;
        MarkStart (actpos, linenum, nowpage);
        i := gcxcoord;
        gcxcoord := x;
        MarkEnd (mpos, mline, mpag);
        gcxcoord := i;
    End;
End;
                                                                              {
лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл}

Procedure MarkDisplay;

Var leftx, rightx, topl, botl: integer;
    oldcolor: byte;

Begin
    If (pagebuf = pagecount) Then
    Begin
        MarkInverse (1, Pagelength, grminx, grmaxx);
        exit;
    End;
    If ((mstart.mpag <= pagecount) AND (pagecount <= mend.mpag)) Then
    Begin
        leftx := IniLeftMargin;
        rightx := gmaxX - GcuRightMargin;
        topl  := topmargin;
        botl  := pagelength;
        If mstart.mpag = pagecount Then
        Begin
            leftx := mstart.mxcoord;
            topl  := mstart.mline;
        End;
        If mend.mpag = pagecount Then
        Begin
            rightx := mend.mxcoord;
            botl := mend.mline;
        End;
        MarkInverse (topl, botl, leftx, rightx);
    End Else
    If ((mstart.mpag = pagecount) AND (mend.mpag = -1)) Then
        MarkInverse (mstart.mline, mstart.mline, mstart.mxcoord,
            mstart.mxcoord + 7{6});

    {header und footer marken anzeigen}
    If ((setuppage IN actedit) OR (dispspec = 1)) Then
    Begin
        oldcolor := GetColor;
        SetColor (speccolor);
        topl := topmargin;
        While (IniHeaderFooterLine (topl)) Do
            topl := topl + 1;
        If (IniHeaderFooterLine (topl - 1)) Then
            MarkDrawLine (1, IniYNow (topl - 1) + 2, IniLeftMargin{+1}, false);

        botl := pagelength;
        While (IniHeaderFooterLine (botl)) Do
            botl := botl - 1;
        If ((botl <= pagelength) AND
            (IniHeaderFooterLine (pagelength))) Then
            MarkDrawLine (IniYNow (botl) + 6{markheight} - 4,
                IniYBottomMargin - 1,
                IniLeftMargin{+1}, false);
        SetColor (oldcolor);
    End; { if ((dispspec > 0) or (setuppage in actedit)) then }
    SetLineStyle (0, 1, 1);
End;
                                                                              {
лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл}

Procedure MarkInit;

Begin
    mstart.mpag := -1;
    mend.mpag := -1;
End;

End.
