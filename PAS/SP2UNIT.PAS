{$I RNS.H}

Unit sp2unit;

Interface

Uses dos,
    crt,
    initsc,
    imenuunit,
    graph,
    UserExit;

Procedure Sp2MarkFooter(linenum: integer);
Procedure Sp2MarkHeader(linenum: integer);
Procedure Sp2UnMarkHeader;
Procedure Sp2UnMarkFooter;
Procedure Sp2SetHeaderFooter(linenum: integer);
Procedure Sp2SearchAndReplace(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr);
Function Sp2SearchString(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr): Boolean;
Procedure Sp2ReplaceString(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr);
Procedure Sp2VisiMenu;
Procedure Sp2SwapKeyboard;
Procedure Sp2PageCommands(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr);
{Procedure Sp2SelectLine;}
Procedure Sp2HeaderFooterToBuffer(Var tempptr, startptr, lastptr,
    bufactptr, bufstartptr, bufendptr:
    listptr);

Implementation

Uses specunit,
    helpunit,
    fileunit,
    graphmenu,
    grinout,
    gcurunit,
    menutyp,
    getunit,
    textunit,
    musikunit,
    pageunit,
    Texts,
    mousdrv;
{*********************************************************}
Function UpString(S: String): String;
Var a: Byte;
Begin
    For a := 1 To Length (s) Do
        S[a] := UpCase (S[a]);
    UpString := S;
End;
{*********************************************************}
Procedure Sp2HeaderFooterToBuffer(Var tempptr, startptr, lastptr,
    bufactptr, bufstartptr, bufendptr:
    listptr);
{Versorgen aller Header und Footer in den Buffer}

Var i, k, pagec: integer;
    tbufpos: byte;
    tempbuf: stringline;
    strbuf:  string4;

Begin
    tbufpos := 0;
    tempbuf := '';
    tempptr := startptr;
    FilBufClear;
    FilFindPage (1, i, tempptr, startptr, lastptr);
    pagec := 0;
    {Seite lesen}
    Repeat
        PagReadPage (tempptr, startptr, lastptr, tempbuf, tbufpos);
        pagec := pagec + 1;
        For i := 1 To pagelength Do
            If IniHeaderFooterLine (i) Then
            Begin
                {Header, footer Marke wegnehmen}
                page[i, 4] := ' ';
                {Seitenzahl wandeln}
                k := pos (chr (235), page[i]);
                If k > 0 Then
                Begin
                    Str (pagec: 3, strbuf);
                    Delete (page[i], k, 1);
                    insert (strbuf, page[i], k);
                End;
                FilHeapInsertString (page[i] + chr (0), bufactptr, bufstartptr,
                    bufendptr, bufactptr, false);
            End;
    Until tempptr = lastptr;
End;

{*****************************************************************}
Function Sp2SearchString(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr): Boolean;
{Sucht den string searchstring auf den Zeilen vom Typ
 searchtyp, beginnend mit der gegenwaertigen Position
 wird true falls der String gefunden wurde}

Var x: integer;
    ipos, iline, ipage: integer;
    inblock, testline, tempbuffer: stringline;
    foundflag, endreached: boolean;
    tbufpos: byte;
    tempptr: listptr;

    {++++++++++++++++++++++++++++++++++++++++++++}
    Procedure Sp2TestOneLine;

    Begin
        If testline[1] = searchtyp Then
        Begin
            If Searchtyp = 'N' Then
                inblock := Copy (testline, ipos, 255)
            Else
                inblock := UpString (Copy (testline, ipos, 255));
            If Pos (searchstring, inblock) > 0 Then
            Begin
                foundflag := true;
                If pagecount <> ipage Then
                    PagShowPage (linenum, actposn, actpost,
                        actptr, startptr, lastptr, ipage, true);
                linenum := iline;
                pagecount := ipage;
                If searchtyp = 'N' Then
                Begin
                    actposn := ipos - 1 + Pos (searchstring, inblock);
                    GetActPosX (x, actposn, linenum, true);
                End
                Else
                Begin
                    actpost := ipos - 1 + Pos (searchstring, inblock);
                    TexActPosX (x, actpost, linenum, true);
                End;
            End; { if Pos(searchstring, inblock) > 0 then}
        End; {if testline [1] = searchtyp then}
        iline := iline + 1;
        ipos  := linemarker + 1;
    End; {Sp2TestOneLine}
    {+++++++++++++++++++++++++++++++++++++++++++++++++++}


Begin
    foundflag := false;
    endreached := false;
    If searchstring <> '' Then
    Begin
        tempbuffer := '';
        tbufpos := 0;
        iline := linenum;
        ipos  := IniPos (linenum, actposn, actpost) + 1;
        ipage := pagecount;

        {Suchen auf aktueller Seite}
        While ((NOT foundflag) AND (iline <= pagelength)) Do
        Begin
            testline := page[iline];
            Sp2TestOneLine;
        End; {while ((not foundflag) and (iline <= pagelength)) do}

        {Suchen im Heap}
        If NOT foundflag Then
        Begin
            ipage := pagecount + 1;
            iline := topmargin;
            tempptr := actptr;
            While ((NOT foundflag) AND (NOT endreached)) Do
            Begin
                FilCheckLine (tempbuffer, testline, tempptr, startptr, lastptr,
                    tbufpos, endreached, true, false);
                Sp2TestOneLine;
                If iline > pagelength Then
                Begin
                    ipage := ipage + 1;
                    iline := topmargin;
                End;
            End; {while ((not foundflag) and (not endreached)) do}
        End; { if not foundflag then}

        If NOT foundflag Then
        Begin
            HlpHint (HntNotFound, HintWaitEsc);
            PagCursorLeft (linenum, actposn, actpost);
        End;
    End {if searchstring <> ''}
    Else
        HlpHint (HntNoSearchText, HintWaitEsc);
    Sp2SearchString := foundflag;
End;


{*****************************************************************}
Procedure Sp2ReplaceString(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr);

Var b: byte;
    ipos: integer;

Begin
    GcuCursorRestore;
    If (gcycoord > (grmaxy - 30)) Then
        b := hpUp
    Else
        b := hpEdit;
    If HlpAreYouSure ('replace ?', b) Then
    Begin
        GcuPatternRestore;
        PagRefreshPage (refxmin, refymin, refxmax, refymax);
        IniRefInit;
        ipos := IniPos (linenum, actposn, actpost);
        delete (page[linenum], ipos, length (searchstring));
        insert (replacestring, page[linenum], ipos);
        PagRefClearVal (0, IniYnow (linenum - 1), gmaxX,
            IniYnow (linenum + 2));
    End Else GcuPatternRestore;
End;

{*****************************************************************}
Procedure Sp2SearchAndReplace(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr);

Var dir: movement;
    c: char;
    resp: response_type;
    choicenum: byte;
    x, y, hy: integer;
    instring, rstring: string16;
    s: string;
    b: boolean;
    mausx, mausy, maustaste, mausmenu: word;
    changed: boolean;
    {***************************************}
    Procedure SearchTextInput(dy: integer; prompt: string; Var tstring: string16);
    Begin
        tstring := '';
        s := '';
        IniExpand (S, 32);
        GrGet_Prompted_String (tstring, 16,                { InStr,StrLen        }
            ' ', x - 60, hy + 4 + dy, x - 60,{ Desc,DesX,-Y,OldDeX }
            prompt, x - 93, hy + 4 + dy, { Prompt,PRX,PRY      }
            77, resp, dir, c,            { PRLen,Resp,Dir,KeyRe}
            false,                       { OldWrite            }
            mausx, mausy, maustaste, mausmenu, changed);
        IniMausAssign (maustaste, resp);
        If resp = return Then c := #27
        Else c := ' ';
    End;

    {***************************************}
    Procedure SearchPatternInput(dy: integer; prompt: string;
        Var tstring: stringline);
    Begin
        tstring := '';
        MusGetPromptedPattern (tstring,                    { inString          }
            ' ',                        { DESC              }
            x + 220, y + 24,{+dy*8}          { DescX,DescY       }
            ' ' + prompt, x - 86, y + 38 + dy * 8,  { Prompt, PRX,PRY   }
            15, resp, c);               { prlen,resp,keyresp}
        If resp = return Then c := chr (27)
        Else c := ' ';
    End;

    {**********************************}
    Procedure CallReplace;
    Begin
        If ((c <> ' ') AND (Sp2SearchString (linenum, actposn, actpost,
            actptr, startptr, lastptr))) Then
        Begin
            PagRefreshPage (refxmin, refymin, refxmax, refymax);
            IniRefInit;
            Sp2ReplaceString (linenum, actposn, actpost, actptr, startptr, lastptr);
        End;
    End;
    {**********************************}

Begin
    ImeInitSearchMenu;
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
            choicenum, mausx, mausy, maustaste, mausmenu,
            false, 0);
        x := hfminx + usrmenu.menu_width + 16;
        C := Upcase (C);
        Case c Of
            'T':
            Begin
                searchtyp := 'T';
                replaceflag := false;
                SearchTextInput (6,
                    ' - Enter text to search                     >', instring);
                searchstring := UpString (instring);
                If searchstring <> '' Then
                    b := Sp2SearchString (linenum, actposn, actpost,
                        actptr, startptr, lastptr);
            End;

            'P':
            Begin
                searchtyp := 'N';
                replaceflag := false;
                SearchPatternInput (4, ' - Enter pattern to search                  >',
                    searchstring);
                If searchstring <> '' Then
                    b := Sp2SearchString (linenum, actposn, actpost,
                        actptr, startptr, lastptr)
                Else
                    PagCursorLeft (linenum, actposn, actpost);
            End;

            'C':
            Begin
                searchtyp := 'T';
                replaceflag := true;
                SearchTextInput (2,
                    ' - Enter text to change                     >', instring);
                searchstring := UpString (instring);
                If (searchstring <> '') AND (resp <> escape) Then
                Begin
                    replacestring := ' - Change "' + instring + '" to';
                    IniExpand (Replacestring, 44);
                    SearchTextInput (2, ReplaceString + '>', instring);
                    replacestring := rstring;
                    CallReplace;
                End;
                c := 'C';
            End;

            'R':
            Begin
                searchtyp := 'N';
                replaceflag := true;
                SearchPatternInput (0, ' - Enter pattern to replace                 >',
                    searchstring);
                If searchstring <> '' Then
                Begin
                    SearchPatternInput (0, ' - Change to                                >',
                        replacestring);
                    CallReplace;
                End;
            End;
        End; {case c of}
        If pos (c, usrmenu.choices) > 0 Then c := chr (27);
    Until (c = chr (27));

End;

{*****************************************************************}
Procedure Sp2PageCommands(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr);

Var dir: movement;
    c: char;
    resp: response_type;
    choicenum: byte;
    x, y, hy, i: integer;
    mausx, mausy, maustaste, mausmenu: word;
    changed: boolean;
Begin
    ImeIniPageMenu;
    If mstart.mpag <> -1 Then usrmenu.num_choices := {1}2;
    choicenum := 1;
    maustaste := 0;
    mausdunkel;
    Repeat
        PagRefClearVal (grminx - 10, grminy - 10,
            grmaxx + 10, grmaxy + 10);
        y := grmaxy - (usrmenu.num_choices * usrmenu.spacing +
            usrmenu.menuattr.firstline + 2) * charheight;
        hy := y DIV charheight;
        GrDisplay_Frame (grminx, y, grmaxx, grmaxy, true, false);
        GrDisplay_Menu (hfminx, hy, usrmenu, 0);
        GrGet_Menu_Response (hfminx, hy, usrmenu, c, dir,
            choicenum, mausx, mausy, maustaste, mausmenu,
            false, 0);
        x := hfminx + usrmenu.menu_width - 44;
        hy := y + 78;
        y := grmaxy DIV charheight -
            ((usrmenu.num_choices - choicenum + 1) * usrmenu.spacing);
        c := upcase (c);
        mausdunkel;
        Case c Of
            'G':
            Begin{gotopage}
                i := pagecount;
                GrGet_Prompted_Integer (i, 1, 1000, 12, '>',
                    x, y, x,
                    ' - Go to       page number ..?              >',
                    x - 33, y, 77, resp, dir, c, false,
                    mausx, mausy, maustaste, mausmenu, changed);
                IniMausAssign (maustaste, resp);
                If resp = return Then
                    c := #27
                Else
                    c := ' ';
                If i <> pagecount Then PagShowPage (linenum, actposn, actpost,
                        actptr, startptr, lastptr, i, true);
            End;
            'F': PagShowPage (linenum, actposn, actpost,
                    actptr, startptr, lastptr, 1, true);{first page}
            'L': PagShowPage (linenum, actposn, actpost,
                    actptr, startptr, lastptr, 30002, true);{last page}
            'N':
            Begin{New page at end}
                FilSavePage (1, PageLength, actptr, startptr, lastptr);
                FilFindPage (30002, pagecount, actptr, startptr, lastptr);
                IniNewPage (linenum);
                PagGetPageFromHeap (actptr, startptr, lastptr, i);
                PagCursorLeft (linenum, actposn, actpost);
                PagShowPage (linenum, actposn, actpost,
                    actptr, startptr, lastptr, pagecount + 1, true);
            End;
            'I':
            Begin{Insert page}
                i := pagecount;
                FilSavePage (1, PageLength, actptr, startptr, lastptr);
                PagGetSetupPage (actptr, startptr, lastptr);
                FilFindPage (pagecount, i, actptr, startptr, lastptr);
                PagRefPage;
            End;
            'S': SpeSplitPage (linenum, actposn, actpost,
                    actptr, startptr, lastptr);{Split page}
            'J': SpeJoinPage (linenum, actposn, actpost,
                    actptr, startptr, lastptr);{Join page}
            'B': If pagebuf = -1 Then
                    filmarkpage
                Else
                    filunmarkpage;{Blockmark page(irgendeine Kreation musste ja wohl her!}{ warum nicht '9' wie F9}
            'C': filCopyPage (actptr, startptr, lastptr);{Copy page to buf}
            'P': filPastePage (actptr, startptr, lastptr);{Paste page}
            'M':
            Begin{Move Page}
                fildelpage (actptr, startptr, lastptr);
                filundelpage (actptr, startptr, lastptr);
            End;
            'D': fildelpage (actptr, startptr, lastptr);{Delete page}{save page to buffer}
            'U': filundelpage (actptr, startptr, lastptr);{Undelete page} {case c of}
        End;
        If pos (c, usrmenu.choices) > 0 Then c := #27;
    Until (c = #27);
End;

{*****************************************************************}
Procedure Sp2SwapKeyboard;

Var y, hy: integer;
    c: char;

Begin
    ImeIniSwapMenu;
    usrmenu.choiceval[1].tval := manset;
    usrmenu.choiceval[2].tval := charset;
    usrmenu.choiceval[3].tval := blankset + 1;
    y := grmaxy - (usrmenu.num_choices * usrmenu.spacing +
        usrmenu.menuattr.firstline + 5) * charheight;
    hy := y DIV charheight;
    GrDisplay_Frame (grminx, y, grmaxx, grmaxy, true, true);
    GrDisplay_Menu (hfminx, hy, usrmenu, 0);
    GrGet_Menu_Values (hfminx, hy, hfmaxy, usrmenu, c);

    manset := usrmenu.choiceval[1].tval;
    charset := usrmenu.choiceval[2].tval;
    blankset := usrmenu.choiceval[3].tval - 1;
    PagRefClearVal (0, y - 16, gmaxX, gmaxy);
End;

{*****************************************************************}
Procedure Sp2VisiMenu;
Var y, hy: integer;
    c: char;
Begin
    ImeIniVisiMenu;
    usrmenu.choiceval[1].tval := dispspec;
    usrmenu.choiceval[2].tval := dispgrid;
    usrmenu.choiceval[3].tval := disphidlines;
    usrmenu.choiceval[4].tval := dispslash;
    usrmenu.choiceval[5].tval := dispcurs;
    y := grmaxy - (usrmenu.num_choices * usrmenu.spacing +
        usrmenu.menuattr.firstline + 5) * charheight;
    hy := y DIV charheight;
    GrDisplay_Frame (grminx, y, grmaxx, grmaxy, true, true);
    GrDisplay_Menu (hfminx, hy, usrmenu, 0);
    GrGet_Menu_Values (hfminx, hy, hfmaxy, usrmenu, c);

    dispspec := usrmenu.choiceval[1].tval;
    dispgrid := usrmenu.choiceval[2].tval;
    disphidlines := usrmenu.choiceval[3].tval;
    dispslash := usrmenu.choiceval[4].tval;
    dispcurs := usrmenu.choiceval[5].tval;
End;

{*****************************************************************}
Procedure Sp2SetHeaderFooter(linenum: integer);

Var dir: movement;
    c: char;
    choicenum: byte;
    y, hy: integer;
    mausx, mausy, maustaste, mausmenu: word;

Begin
    ImeInitHfMenu;
    choicenum := 1;
    maustaste := 0;
    Repeat
        y := grmaxy - (usrmenu.num_choices * usrmenu.spacing +
            usrmenu.menuattr.firstline + 2) * charheight;
        hy := y DIV charheight;
        GrDisplay_Frame (grminx, y, grmaxx, grmaxy, true, false);
        GrDisplay_Menu (hfminx, hy, usrmenu, 0);
        GrGet_Menu_Response (hfminx, hy, usrmenu, c, dir,
            choicenum, mausx, mausy, maustaste, mausmenu,
            false, 0);

        Case c Of
            'H', 'h':
            Begin
                Sp2MarkHeader (linenum);
                c := chr (27);
            End;

            'F', 'f':
            Begin
                Sp2MarkFooter (linenum);
                c := chr (27);
            End;

            'U', 'u':
            Begin
                Sp2UnMarkHeader;
                c := chr (27);
            End;

            'V', 'v':
            Begin
                Sp2UnMarkFooter;
                c := chr (27);
            End;
        End; {case c of}
    Until (c = chr (27));

    PagRefClearVal (grminx - 10, grminy - 10,
        grmaxx + 10, grmaxy + 10);
End;

{*****************************************************************}
Procedure Sp2UnMarkFooter;

Var i: byte;

Begin
    i := pagelength;
    While IniHeaderFooterLine (i) Do
    Begin
        page[i, 4] := ' ';
        i := i - 1;
    End;
    PagRefClearVal (IniLeftMargin, IniYnow (i),
        IniLeftMargin + 2 * CharWidth, IniYnow (pagelength));
End;

{*****************************************************************}
Procedure Sp2UnMarkHeader;

Var i: byte;

Begin
    i := topmargin;
    While IniHeaderFooterLine (i) Do
    Begin
        page[i, 4] := ' ';
        i := i + 1;
    End;
    PagRefClearVal (IniLeftMargin, IniYnow (topmargin - 1),
        IniLeftMargin + 2 * CharWidth, IniYnow (i));
End;

{*****************************************************************}
Procedure Sp2MarkHeader(linenum: integer);

Var i, imax: byte;

Begin
    imax := IniMaxHeader;
    If (linenum > imax) Then
        HlpHint (HntHeaderHalfPage, HintWaitEsc)
    Else
    Begin
        For i := linenum To imax Do
        Begin
            IniExpand (page[i], 4);
            page[i, 4] := ' ';
        End;
        For i := topmargin To linenum Do
        Begin
            IniExpand (page[i], 4);
            page[i, 4] := 'F';
        End;
        PagRefClearVal (IniLeftMargin, 0,
            IniLeftMargin + CharWidth, IniYnow (imax));
    End;
End;

{*****************************************************************}
Procedure Sp2MarkFooter(linenum: integer);

Var i, imin: byte;

Begin
    imin := IniMinFooter;
    If (linenum < imin) Then
        HlpHint (HntFooterHalfPage, HintWaitEsc)
    Else
    Begin
        For i := imin To linenum Do
        Begin
            IniExpand (page[i], 4);
            page[i, 4] := ' ';
        End;
        For i := linenum To pagelength Do
        Begin
            IniExpand (page[i], 4);
            page[i, 4] := 'F';
        End;
        PagRefClearVal (IniLeftMargin, IniYnow (imin - 1),
            IniLeftMargin + CharWidth, IniYnow (pagelength));
    End;
End;

{*****************************************************************}
(*Procedure Sp2SelectLine;

var dir: movement;
    y, hy: integer;
    c: char;
    choicenum: byte;
    mausx, mausy, maustaste, mausmenu: word;

begin
   ImeInitLineSelectMenu;
   choicenum:= 1;
   maustaste:= 0;
   y:= grmaxy - (usrmenu.num_choices * usrmenu.spacing +
       usrmenu.menuattr.firstline + 2) * charheight;
   hy:= y div charheight;
   GrDisplay_Frame(grminx, y, grmaxx, grmaxy, true, true);
   GrDisplay_Menu(hfminx, hy, usrmenu, 0);
   GrGet_Menu_Response(hfminx, hy, usrmenu, c, dir,
                       choicenum, mausx, mausy, maustaste, mausmenu,
                       false, 0);


   if c <> chr(27) then
   begin
      insmusicline:= page[choicenum];
   end;
end;*)

End.
