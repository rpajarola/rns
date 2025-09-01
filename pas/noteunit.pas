{$I RNS.H}
Unit noteunit;

Interface

Uses
    graph;


Procedure NotEdNoteLine(linenum: integer; Var actpos: integer; c: char);
Procedure NotDelNote(linenum: integer; Var actpos: integer);
Procedure NotInsNote(linenum: integer; Var actpos: integer);
Procedure NotDelToEOL(linenum, actpos: integer);

{ NoteSystem: Linien zusammenfassen }
Procedure NotSysStart(linenum: integer);
Procedure NotSysEnd(linenum: integer);
Function NotFindSysStart(linenum: integer): integer;
Function NotFindSysEnd(linenum: integer): integer;
Function NotIsSys(linenum: integer): char;
Function NotNextLine(linenum: integer): integer;
Function NotPrevLine(linenum: integer): integer;

Implementation

Uses
    pageunit,
    symbols,
    initsc,
    menutyp,
    gcurunit,
    getunit,
    specunit,
    utilunit,
    helpunit,
    crt,
    RnsIni,
    Comunit,
    Texts;

{******************************************************}
Procedure NotDelToEOL(linenum, actpos: integer);

Begin
    inbuffer := '';
    While (NOT IniNumChar (page[linenum, actpos - 1])) Do
        dec (actpos);
    Delete (page[linenum], actpos + 1, length (page[linenum]));
    page[linenum, actpos] := '.';
End;

{****************************************************************}

Procedure NotInsNote(linenum: integer; Var actpos: integer);
Var
    inblock: stringline;
    i: integer;
Begin
    inblock := page[linenum];
    delete (inblock, 1, actpos);
    While ((length (inblock) > 0) AND (NOT IniNumchar (inblock[1]))) Do
        delete (inblock, 1, 1);
    i := IniNextNumber (inblock);
    If i = 0 Then
        i := 1;
    str (i, inblock);
    inblock := '.' + inblock;
    UtiCharBegin (page[linenum], actpos);
    insert (inblock, page[linenum], actpos);
    PagRefClearVal (gcxcoord - 25, IniYnow (linenum - 2),
        GetmaxX, IniYnow (linenum + 1));
End;

{****************************************************************}

Procedure NotDelNote(linenum: integer; Var actpos: integer);
Var
    stbuf: string;
Begin
    UtiDelNoteChar (page[linenum], actpos, stbuf);
    UtiDelNumChar (page[linenum], actpos);
    UtiFindCharEnd (page[linenum], actpos);
    PagRefClearVal (gcxcoord - 25, IniYnow (linenum - 2),
        GetmaxX, IniYnow (linenum + 1));
End;

{****************************************************************}
Procedure NotEdNoteLine(linenum: integer; Var actpos: integer; c: char);

Var
    i, j, k, ordc: integer;
    inblock, strbuf: stringline;
    lineattr: lineattrtype;
    x, deltax, clearendx: integer;
    clinemin, clinemax: integer;
    left, moveright, arrow, reallymoveright: boolean;
    indexc: char;
    oldx: integer;
    ref:  Byte;
Const
    EdSnd = 50;

    {**********************}

    Procedure NotRemZero;
    Begin
        While ((length (inbuffer) > 0) AND (inbuffer[1] = '0')) Do
            delete (inbuffer, 1, 1);
    End;

    {**********************}

Const
    refSmall = 0;
    refNormal = 1;
    refNoRef = 2;

Begin
    reallymoveright := false;
    ref := refNoRef;
    If (c >= '0') AND (c <= '9') Then
        ref := 1;
    If c = '|' Then  {nur bis | eine neue Funktion hat: fak. Beatstrich}
        exit;        {jetzt werden so bedingte Sprungmarken abgefangen, die noch mit | statt › gemacht wurden}
    If c = #245 Then
        c := '0';
    If (c = #9) OR (c = #15) Then
    Begin
        Case c Of
            #9: inc (symbcount);
            #15: If symbcount > 1 Then
                    dec (symbcount);
        End;
    End Else
    Begin
        deltax := 25; {Default clear region}
        clinemin := linenum - 3;
        clinemax := linenum + 1;
        inblock := page[linenum];
        ordc := ord (c);
        arrow := false; {zeigt an ob eine Pfeiltaste gedrÅckt wurde}
        If (RnsSetup.CharSet = 2) Then
            If (c >= 'a') AND (c <= 'z') Then
                c := char (byte (c) + 31)
            Else If (c >= 'A') AND (c <= 'Z') Then
                c := char (byte (c) + 32)
            Else If (c >= #128) AND (c <= #153) Then
                c := char (byte (c) - 63); {if RnsSetup.CharSet = 2 then}
        { ' ' '.' ',' rotieren }
        If (RnsSetup.BlankSet >= 0) AND (RnsSetup.BlankSet <= 2) Then
            Case c Of
                ' ': c := keyswap[RnsSetup.BlankSet, 0];
                ',': c := keyswap[RnsSetup.BlankSet, 1];
                '.': c := keyswap[RnsSetup.BlankSet, 2];
            End;
{    if RnsSetup.BlankSet=2 then begin
      if c=' ' then
        c:=','
      else if c=',' then
        c:=' ';
    end;}
        x := gcxcoord;
        oldx := x;
        k := UtiComputeGroup (c, indexc);
        clearendx := x + 25;
        If (NOT (IniNumChar (c) OR IniArrow (c) OR (c = ':'))) Then
        Begin
            If ordc = 8 Then
            Begin {BS}
                inbuffer := '';
                inblock  := page[linenum];
                GetNoteBlock (inblock, lineattr, linenum);
                x := gcxcoord - 1;
                GetNotePosX (x, actpos, linenum, true, true);
                UtiDelNoteChar (page[linenum], actpos, strbuf);
                UtiDelNumChar (page[linenum], actpos);
                clearendx := GetMaxX;
                ref := refNormal;
            End Else {if ordc = 8 then}
            Begin
                If (length (page[linenum]) + length (inbuffer)) < stlength Then
                Begin
                    If (linestyles IN actedit) Then
                        c := '.';
                    If (actpos < length (page[linenum])) OR (x >= grmaxx) Then
                        ref := refNormal
                    Else
                        ref := refSmall;
                    { check if ()[] is valid }
                    Case c Of
                        '(', '[': For i := actpos Downto 1 Do
                            Begin
                                If (page[linenum, i] = ')') OR (page[linenum, i] = ']') Then
                                    break;
                                If (page[linenum, i] = '(') OR (page[linenum, i] = '[') Then
                                Begin
                                    HlpHint (HntCloseBracketFirst, HintNormalTime, []);
                                    exit;{not allowed!!!}
                                End;
                                If (page[linenum, i] = '%') Then
                                    break;
                            End;{'(','['}
                        ')': For i := actpos Downto 1 Do
                            Begin
                                If (page[linenum, i] = '(') Then
                                    break;
                                If (page[linenum, i] = '(') OR (page[linenum, i] = '[') OR
                                    (page[linenum, i] = ']') Then
                                Begin
                                    HlpHint (HntOpenBracketFirst, HintNormalTime, []);
                                    exit;{not allowed!!!}
                                End;
                            End;{')'}
                        ']': For i := actpos Downto 1 Do
                            Begin
                                If (page[linenum, i] = '[') Then
                                    break;
                                If (page[linenum, i] = '(') OR (page[linenum, i] = '[') OR
                                    (page[linenum, i] = ')') Then
                                Begin
                                    HlpHint (HntOpenBracketFirst, HintNormalTime, []);
                                    exit;{not allowed!!!}
                                End;
                            End;{']'}
                        '.':
                        Begin
                            UtiDelNoteChar (page[linenum], actpos, strbuf);
                            i := length (strbuf);
                            If (i >= 2) AND ((strbuf[i - 1] = '=') OR (strbuf[i - 1] = '*')) Then
                                strbuf := strbuf + '.'
                            Else
                                strbuf := '.';
                            inbuffer := strbuf;
                            Insert (strbuf, page[linenum], actpos);
                            reallymoveright := true;
                            c := #255;
                        End;{'.'}
                    End;{case c of}
                    { ganzes Zeichen aus page[linenum] lîschen und in strbuf kopieren }
                    UtiDelNoteChar (page[linenum], actpos, strbuf);
          {Zeichen nur Åberschreiben, wenn neues vollstÑndiges
           Zeichen Åber ein altes geschrieben wird}
                    {???}
                    If ((NOT UtiCharReady (strbuf, #255)) AND (strbuf <> '')) OR
                        ((RnsSetup.ManSet = 2) AND (c IN flamset)) Then
                        inbuffer := strbuf;
                    { repetitionszeichen}
                    If c = '"' Then
                    Begin
                        If pos ('"', copy (page[linenum], actpos, length (page[linenum]) - actpos)) <> 0 Then
                            clearendx := getmaxx;
                        moveright := true;
                        If strbuf[1] = '"' Then
                        Begin
                            {" schon vorhanden->wegnehmen}
                            If length (strbuf) > 1 Then
                                inbuffer := copy (strbuf, 2, length (strbuf) - 1)
                            Else
                                inbuffer := '';
                            If length (strbuf) > 1 Then
                                c := #255
                            Else
                                c := '.';
                        End Else
                            inbuffer := strbuf;
                        { add oder replace }
                    End Else If (UtiReplaceChars (c) > 0) OR (reallymoveright) Then
                        moveright := true
                    Else
                    Begin
                        moveright := false;
                        If NOT (c IN flamset) Then
                            inbuffer := strbuf;
                    End;

                    If UtiCharReady (inbuffer, c) Then
                    Begin
                        Insert (inbuffer, page[linenum], actpos);
                        i := actpos;
                        UtiFindCharEnd (page[linenum], i);
                        If i = length (page[linenum]) Then
                        Begin
                            UtiGetActDistance (page[linenum], actpos, strbuf);
                            page[linenum] := page[linenum] + strbuf + '.';
                        End;
                        If moveright Then
                            SpeNoteRight (linenum, actpos);
                        inbuffer := '';
                    End Else
                        Insert (inbuffer, page[linenum], actpos);
                    {Spielen der Note}
                    If RnsSetup.KbdSound = 1 Then
                        If (k > 0) Then
                        Begin
                            sound (sympar[indexc, 3, k]);
                            delay (EdSnd);
                            nosound;
                        End;
                End Else {if (length(page[linenum]...}
                    HlpHint (HntTooManyChars, HintWaitEsc, []);
            End;{ else if ordc=8}
        End Else{if (not(IniNumChar(c)...}If UtiNumReady (inbuffer, c) Then
        Begin
            If NOT IniArrow (inbuffer[1]) Then
            Begin
                x := gcxcoord - 1;
                GetNotePosX (x, i, linenum, false, true);
                If x < gcxcoord Then
                Begin
                    NotRemZero;
                    If (length (page[linenum]) + length (inbuffer)) < stlength Then
                    Begin
                        If NOT ((actpos = length (page[linenum])) AND
                            (ininumchar (page[linenum, actpos]))) Then
                            UtiCharBegin (page[linenum], actpos);
                        While IniNumChar (page[linenum, actpos - 1]) Do
                            Dec (Actpos);
                        UtiDelNumChar (page[linenum], actpos);
                        {Fuege neue(n) Character ein}
                        If (Length (page[linenum]) <= StLength) Then
                        Begin
                            insert (inbuffer, page[linenum], actpos);
                            i := Length (page[linenum]);
                            If IniNumChar (inblock[i]) Then
                                inblock := inblock + '$';
                        End;
                        SpeNoteRight (linenum, actpos);
                        GetClearLines (linenum, clinemin, clinemax);
                    End; {if (length(page[linenum]) + length(inbuffer)) }
                End Else {if x < gcxcoord}
                Begin
                    HlpHint (HntOutOfView, HintWaitEsc, []);
                End;
            End Else {not IniArrow(inbuffer[1])}
            Begin
                arrow := true;
                left  := (inbuffer[1] = '<');
                delete (inbuffer, 1, 1);
                If inbuffer[1] = 'c' Then
                Begin
                    j := actpos;
                    If Left Then
                    Begin
                        UtiCharBegin (page[linenum], actpos);
                        While IniNumChar (page[linenum, actpos - 1]) Do
                            Dec (actpos);
                    End Else
                        UtiFindCharEnd (Page[linenum], actpos);
                    Val (Copy (inbuffer, 2, length (inbuffer) - 1), i, k);
                    Str (i * UtiGetNum (Page[linenum], actpos), inbuffer);
                    If inbuffer = '0' Then
                    Begin
                        Inbuffer := '';
                        Exit;
                    End;
                    actpos := j;
                End;
                NotRemZero;
                UtiNextNum (page[linenum], actpos, i, left);
                If i = 0 Then
                Begin
                    If ((NOT left) AND ((Length (page[linenum]) + length (inbuffer))
                        < StLength)) Then
                        page[linenum] := page[linenum] + inbuffer + '.';
                End Else{ if i = 0 then }
                Begin
                    Val (inbuffer, j, k);
                    If ((j MOD i) <> 0) Then
                        HlpHint (HntDivNotPossible, HintWaitEsc, [j, i])
                    Else { if (j mod i) <> 0 then }
                    Begin
                        k := j DIV i;
                        {Abstand k mal einfuegen}
                        If left Then
                            While IniNumChar (page[linenum, actpos - 1]) Do
                                actpos := actpos - 1
                        Else
                            { if left then }actpos := actpos + 1; { else if left then }
                        If (length (page[linenum]) + k * (length (inbuffer) + 1)
                            < stlength) Then
                        Begin
                            UtiDelNumChar (page[linenum], actpos);
                            insert (inbuffer, page[linenum], actpos);
                            For i := 1 To k - 1 Do
                                insert (inbuffer + '.', page[linenum], actpos);
                            GetClearLines (linenum, clinemin, clinemax);
                        End Else
                            hlphint (HntTooManyChars, HintWaitEsc, []);
                    End; { else if (j mod i) <> 0 then }
                End; { else if i = 0 then }
                If Left Then
                    ComEdArrow (movement (left), linenum, actpos, actpos)
                Else If Length (page[linenum]) - actpos - 2 >= Length (inbuffer) Then
                    ComEdArrow (movement (right), linenum, actpos, actpos);
                GetLine (linenum, grminx);
                ref := refNoRef;
            End; {else not IniArrow(inbuffer[1])}
            clearendx := gmaxx;
            inbuffer  := '';
            If NOT arrow Then
            Begin
                x := x + 1;
                GetNotePosX (x, actpos, linenum, true, false);
            End;
        End{if UtiNumReady(inbuffer, c) then}Else
            Clearendx := oldx - deltax;{else if (not IniNumChar(c) and (gcxcoord > 15)) }
        If actpos = length (page[linenum]) Then
            If (gcxcoord = InilineEnd (Page[linenum])) AND (x <> gcxcoord) Then
            Begin
                If (((RnsSetup.SndWarning - 1) AND 1) = 1) Then{und am Ende der Zeile?}
                    IniLineEndSound (0);
            End {if gcx...}Else If (gcxcoord = grmaxx) Then
                If (((RnsSetup.SndWarning - 1) AND 2) = 2) Then{oder am Ende des Bildschirms?}
                    IniLineEndSound (1){am Ende des Strings?}{if gcx... else};
        If oldx > x Then
            oldx := x;
        If oldx > grmaxx Then
            oldx := grmaxx;
        If ref = refSmall Then
            deltax := 4;
        inblock := page[linenum];
        GetNoteAttributes (inblock, lineattr);
        i := Inifirstbeatpos (lineattr);
        If (c = '.') AND (clearendx < i) Then
            clearendx := i;
        If ref <> refNoRef Then
            If (linenum < 48) Then
                PagRefClearVal (oldx - deltax, IniYnow (clinemin - 3),
                    clearendx, IniYnow (clinemax + 3))
            Else
                PagRefClearVal (oldx - deltax, IniYnow (clinemin - 3),
                    clearendx, iniynow (pagelength));
    End;
End;

{****************************************************************}
Procedure NotSysStart(linenum: integer);
Begin
    If page[linenum, 2] = 'S' Then
        page[linenum, 2] := ' '
    Else
        page[linenum, 2] := 'S';{*S*tart}
    PagRefClearVal (0, IniYNow (linenum - 1), 3, IniYNow (NotFindSysEnd (linenum) + 1));
End;

{****************************************************************}

Procedure NotSysEnd(linenum: integer);
Begin
    If page[linenum, 2] = 'E' Then
        page[linenum, 2] := ' '
    Else
        page[linenum, 2] := 'E';{*E*nd}
    PagRefClearVal (0, IniYNow (NotFindSysStart (linenum) - 1), 3, IniYNow (linenum + 1));
End;

{****************************************************************}
Function NotFindSysStart(linenum: integer): integer;
Var
    i: integer;
Begin
    For i := linenum - 1 Downto 1 Do
        If page[i, 1] = 'N' Then
            If (page[i, 2] = 'S') OR (page[i, 2] = 'E') Then
                break;
    If page[i, 2] <> 'S' Then
        i := linenum;
    NotFindSysStart := i;
End;

{****************************************************************}
Function NotFindSysEnd(linenum: integer): integer;
Var
    i: integer;
Begin
    For i := linenum + 1 To pagelength Do
        If page[i, 1] = 'N' Then
            If (page[i, 2] = 'S') OR (page[i, 2] = 'E') Then
                break;
    If page[i, 2] <> 'E' Then
        i := linenum;
    NotFindSysEnd := i;
End;

{****************************************************************}

Function NotIsSys(linenum: integer): char;
Begin
    NotIsSys := page[linenum, 2];
End;

{****************************************************************}

Function NotNextLine(linenum: integer): integer;
Var
    i: integer;
Begin
    For i := linenum + 1 To pagelength Do
        If page[i, 1] = 'N' Then
            break;
    If (i > pagelength) OR (page[i, 1] <> 'N') Then
        i := linenum;
    NotNextLine := i;
End;

{****************************************************************}

Function NotPrevLine(linenum: integer): integer;
Var
    i: integer;
Begin
    For i := linenum - 1 Downto 1 Do
        If page[i, 1] = 'N' Then
            break;
    If page[i, 1] <> 'N' Then
        i := linenum;
    NotPrevLine := i;
End;

End.
