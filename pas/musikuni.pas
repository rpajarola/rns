{$I RNS.H}

Unit musikunit;

Interface

Uses
    MenuTyp,
    InitSc;

Procedure MusGetPattern(Var IN_STRING: STRINGLINE;
    X, Y: integer;
    Var RESP: RESPONSE_TYPE;
    Var KEYRESPONSE: char);

Procedure MusGetPromptedPattern(Var IN_STRING: STRINGLINE;
    STRDESC: char;
    DESCX, DESCY: integer;
    PROMPT: STRING;
    PRX, PRY: integer;
    prlength: integer;
    Var RESP: RESPONSE_TYPE;
    Var KeyResponse: char);


Implementation

Uses
    getunit,
    symbols,
    noteunit,
    pageunit,
    inout,
    RnsIni,
    graphmenu,
    crt,
    gcurunit,
    graph;

{****************************************************************}
Procedure MusGetPromptedPattern(Var IN_STRING: STRINGLINE;
    STRDESC: char;
    DESCX, DESCY: integer;
    PROMPT: STRING;
    PRX, PRY: integer;
    prlength: integer;
    Var RESP: RESPONSE_TYPE;
    Var KeyResponse: char);

{Eingabe eines Musikpatterns}

Begin
    {schreibe den Prompt}
    IniExpand (prompt, prlength);
    Prompt := Prompt + '   ';
    IniInversWrite (PRX, PRY, PROMPT, frLow + frSmallBar);
    {Nimmt die Eingabe vor}
    MusGetPattern (IN_STRING, DESCX, DESCY, RESP, KEYRESPONSE);
End;

{****************************************************************}
Procedure MusGetPattern(Var IN_STRING: STRINGLINE;
    X, Y: integer;
    Var RESP: RESPONSE_TYPE;
    Var KEYRESPONSE: char);

Var
    c: char;                    { Zeicheneingabe von Tastatur }
    I: integer;               { ZÑhler fÅr String-LÑnge }
    inblock: stringline;
    lineattr: lineattrtype;
    direction: movement;
    idummy, xfirst, linenum, actposn, actpost: integer;
    shiftp, ctrlp: boolean;
    mausx, mausy, maustaste, mp, mausmenu: word;
    OldDispCurs: integer;
Begin
    ActPost := 0;
    OldDispCurs := RnsSetup.DispCurs;
    RnsSetup.DispCurs := 1;
    {Bereite das Feld vor}
    yzeropos := y + 40;
    page[0] := 'N            1   0   120 1 %.';
    actnumber := 4;
    resp := key;
    While ((Resp <> Return) AND (Resp <> Escape)) Do
    Begin
        If resp <> arrow Then
        Begin
            inblock := page[0];
            GetNoteBlock (inblock, lineattr, 0);
            SetColor (12);
            {       SetBkColor(7);}
            SetFillStyle (Solidfill, 7);
            Bar (X, Y, grmaxX, y + 71);
            Ini3DFrame (X, Y, grmaxX, y + 71, 12, 5, fr3D);
            GetDrawBlock (inblock, 0, lineattr, grminx, grmaxx, idummy);
            SetColor (12);
            ThinLine (x, yzeropos, GrMaxX);
            xfirst := IniFirstBeatPos (lineattr) - IniDxValue (lineattr);
            Beat (xfirst, yzeropos, 12, false);
        End;
        linenum := 0;
        If inblock = '.' Then
            PagCursorLeft (linenum, actposn, actpost);
        GcuCursorRestore;
        PagShowCurPosDistances (Linenum, ActPosn, ActPost, 0);

        { Himmiherrgottzackzefixmilecktsamoaschscheissglumsverreckts }
        IniSpacedText (gmaxx DIV (2 * charwidth) - 3,{ Der letzte!}
            gmaxy DIV charheight - 5,
            '                    ', frLow);

        Get_Response (Resp, Direction, KeyResponse, shiftp, ctrlp,
            mausx, mausy, maustaste, mp, mausmenu);
        GcuPatternRestore;
        Case resp Of
            key:
                NotEdNoteLine (linenum, actposn, KeyResponse);
            specialkey:
            Begin
                i := ord (keyresponse);
                Case i Of
                    71:
                    Begin{home: begin of line}
                        actposn := 29;
                        GcuMoveCursor (xfirst, GcyCoord);
                    End;
                    79: PagCursorRight (linenum, actposn, actpost);{End: end of line}
                    82: NotInsNote (linenum, actposn);{insert}
                    83: If shiftp Then
                            NotDelToEOL (linenum, actposn)
                        Else
                            NotDelNote (linenum, actposn);{delete}
                    16..50:
                    Begin{Alt-Character, wandeln in Bereich 128..153}
                        c := IniAltChar (KeyResponse);
                        NotEdNoteLine (linenum, actposn, c);
                    End;
                End; {case i of}
            End; { specialkey }
            arrow: Case direction Of
                    LEFT:
                    Begin
                        i := gcxcoord - 1;
                        GetNotePosX (i, actposn, linenum,
                            true, true);
                    End; {LEFT}
                    RIGHT:
                    Begin
                        i := gcxcoord + 1;
                        GetNotePosX (i, actposn, linenum,
                            true, false);
                    End; {RIGHT}
                End;{ case Direction of } { arrow }
        End; {case resp of}
    End; {while}
    in_string := page[0];
    GetNoteBlock (in_string, lineattr, 0);
    actposn := length (in_string);
    If in_string[actposn] = '.' Then
        Repeat
            delete (in_string, actposn, 1);
            actposn := actposn - 1;
        Until NOT IniNumChar (in_string[actposn]);
    If in_string = '.' Then
        in_string := '';
    RnsSetup.DispCurs := OldDispCurs;
End;

End.
