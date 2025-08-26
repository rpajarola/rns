{$I RNS.H}

Unit pageunit;

Interface

Uses
    Graph,
    menutyp,
    butunit,
    InitSc,
    crt,
    Mousdrv;


Procedure PagDisplayPage(Var tempptr, startptr, lastptr: listptr);
Procedure PagShowPage(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    PageNumber: integer; savenow: boolean);
Procedure PagCursorLeft(linenum: integer; Var actposn, actpost: integer);
Procedure PagCursorRight(linenum: integer; Var actposn, actpost: integer);
Procedure PagUnMark;
Function PagEmptyPage(Var tempptr, startptr, lastptr: listptr): boolean;
Procedure PagRemovePage(Var tempptr, startptr, lastptr: listptr);
Procedure PagRefClearVal(clearxmin, clearymin, clearxmax, clearymax: integer);
Procedure PagRefreshPage(clearxmin, clearymin,
    clearxmax, clearymax: integer);
Procedure PagRefPage;
Procedure PagPageFrame;
Procedure PagPutBottomLine;
Procedure PagClearBottomLine;
Procedure PagGetSetupPage(Var tempptr, startptr, lastptr: listptr);
Procedure PagGetPageFromHeap(Var tempptr, startptr, lastptr: listptr;
    Var linec: integer);
Procedure PagReadPage(Var tempptr, startptr, lastptr: listptr;
    Var tempbuf: stringline; Var tbufpos: byte);

Procedure PagShowCurPosDistances(Linenum, ActPosn, ActPost: Byte; CorrY: Byte);
Var beats, eint, resolution: string;
Procedure PagBottomFrame;
Procedure PagPutSearchBottomLine;
Function paggetfreq(c: char): Integer;


Implementation

Uses Symbols,
    GCurUnit,
    GetUnit,
    Textunit,
    TitleUnit,
    inout,
    fileunit,
    helpunit,
    printunit,
    markunit;

{*******************************************************************}
Procedure PagShowCurPosDistances(Linenum, ActPosn, ActPost: Byte; CorrY: Byte);
Var beats, eint, resolution: string;

    {Zeigt Cusorposition auf Text- und Musiklinien}

    Function GetN(St: String; P, X: Byte): Byte;
    Var a: Byte;
        c: Char;

    Begin

        If x = 0 Then
            For a := P Downto 1 Do
            Begin
                c := St[a];
                Case c Of
                    '0'..'9':
                    Begin
                        GetN := a;
                        Exit;
                    End;{'0'..'9'}
                    '%':
                    Begin
                        Getn := 0;
                        Exit;
                    End;{'%'}
                End;{Case}
            End{For} Else For a := P To Length (St) Do
            Begin
                c := St[a];
                Case C Of
                    '0'..'9':
                    Begin
                        GetN := a;
                        exit;
                    End;{'0'..'9'}
                    '%':
                    Begin
                        Getn := 0;
                        Exit;
                    End;{'%'}
                End;{Case}
            End{if}{for};{else}
        GetN := 0;
    End;{Func}

    Function GetL(St: String; P, X: Byte): Byte;

    Var c: Char;
        b: Byte;
        Code: integer;
    Begin
        c := St[p];
        Val (c, b, Code);
        If ((p = 0) OR (Code <> 0)) Then   {RICO: P=0 gibt weiter unten einen
                                           Range Check error [P-1]}
        Begin
            GetL := 0;
            Exit;
        End;{if}
        If x = 0 Then
            c := St[P - 1]
        Else If p < $FF Then
            c := St[P + 1]
        Else Begin
            GetL := 0;
            Exit;
        End;
        Val (c, b, Code);
        If Code <> 0 Then
        Begin
            GetL := 1;
            Exit;
        End;{if}
        GetL := 2;
    End;{func}


    Function getadd(linenum, actposn: Integer): Boolean;
    Begin
        If (Page[linenum, actposn] IN ['a'..'z']) Then
            Getadd := Sympar[Page[linenum, actposn], 2, 1] = 2
        Else If (Page[linenum, actposn] IN ['A'..'Z']) Then
            Getadd := Sympar[Char (Byte (Page[linenum, actposn]) + 32), 2, 2] = 2
        Else If (Page[linenum, actposn] IN [Chr (161)..Chr (191)]) Then
            Getadd := Sympar[Char (Byte (Page[linenum, actposn]) - 31), 2, 3] = 2
        Else If (Page[linenum, actposn] IN [' ', '.', ',']) Then
            Getadd := false
        Else If (Page[linenum, actposn] IN ['-', '+', '=']) Then
            Getadd := false;
    End;

    Function nextavail(linenum, actposn: Integer): Boolean;
    Begin
        nextavail := paggetfreq (page[linenum, actposn + 1]) <> 32767;
    End;

    Function lastavail(linenum, actposn: Integer): Boolean;
    Begin
        lastavail := paggetfreq (page[linenum, actposn - 1]) <> 32767;
    End;

    Function getflam(linenum, actposn: Integer): Byte;
    Begin
        Case Page[linenum, actposn] Of
            '-': getflam := 1;
            '+': getflam := 2;
            '=': getflam := 3
        Else{case}
            getflam := 0;
        End;{case else}
    End;

Const NonChars: Set Of Char = ['(', ')', '[', ']', '-', '+', '='];

Var LSt, RSt: String;
    L: Byte;
    NL, NR: Byte;
    Col, Row: String;
    c: char;
    chbuf: string16;
    a: Byte;
    i, j: integer;
    {zeigt Position auf ML}

Type TBottomInfo = Record
        S: String[20];
        H: Boolean;
    End;

Const KeySwap: Array[0..2, 1..2, 1..2] Of TBottomInfo =
        ((((S: '                    '; H: False),   {0,1,1}
        (S: ' KeySwap:Symbolsize '; H: True)),  {0,1,2}
        ((S: ' KeySwap:Cumulating '; H: True),   {0,2,1}
        (S: ' KeySwap:Cumul/Symb '; H: True))), {0,2,2}
        (((S: ' KeySwap:  Spacebar '; H: False),   {1,1,1}
        (S: ' KeySwap:  Symb/SpB '; H: True)),  {1,1,2}
        ((S: ' KeySwap: Cumul/SpB '; H: True),   {1,2,1}
        (S: ' KeySwap:Cu/Sym/SpB '; H: True))), {1,2,2}
        (((S: ' KeySwap:  Spacebar '; H: False),   {2,1,1}
        (S: ' KeySwap:  Symb/SpB '; H: True)),  {2,1,2}
        ((S: ' KeySwap: Cumul/SpB '; H: True),   {2,2,1}
        (S: ' KeySwap:Cu/Sym/SpB '; H: True))));{2,2,2}
Begin
    If Page[linenum, 1] = 'N' Then
    Begin
        If corry <> 2 Then
        Begin
            i := imenubkcolor;
            j := imenutextcolor;
            If KeySwap[blankset, manset, charset].H Then
            Begin
                imenubkcolor := alarmbkcolor;
                imenutextcolor := alarmcolor;
            End;
            IniSpacedText (gmaxx DIV (2 * charwidth) - 3,
                gmaxy DIV charheight - 3,
                KeySwap[blankset, manset, charset].S, frLow);
            imenubkcolor := i;
            imenutextcolor := j;
        End;
        While (lastavail (linenum, actposn)) AND (actposn > 1) Do
            dec (actposn);
        col := '';
        If (getflam (linenum, actposn - 1) = 0) AND (getflam (linenum, actposn) = 0) Then
        Begin
            If symbcount <> 0 Then
                For a := 0 To symbcount Do
                    If nextavail (linenum, actposn) Then inc (actposn) Else Begin{if nextavail}
                        i := symbcount - 1;
                        symbcount := symbcount MOD (a + 1);
                        If i <> symbcount - 1 Then
                            actposn := actposn + symbcount - i;
                        break;
                    End{if nextavail else}{for a};{if symbcount}
            If corry <> 2{1} Then
            Begin
                If paggetfreq (page[linenum, actposn]) <> 32767 Then
                Begin{zur Sicherheit:Symbol vorhanden?}
                    If getadd (linenum, actposn) Then
                    Begin   {Add vom CSym aus?}
                        col := ' add';
                        If nextavail (linenum, actposn) AND getadd (linenum, actposn + 1) Then col := col + 's'{Mehrere?};{if nextavail}
                    End;{if getadd}
                    i := paggetfreq (page[linenum, actposn]);
                    str (i: 5, row);
                    If i <> 0 Then
                        col := row + ' Hz' + col;
                End;{if paggetfreq}
                If (symbcount <> 0) OR nextavail (linenum, actposn) OR
                    lastavail (linenum, actposn) Then col := col + ' [Tab]  '{ ' [('+#24+')Tab]  '}{zu lang in gewissen F�llen};
            End{if corry<>2} Else Begin
                i := paggetfreq (page[linenum, actposn]);
                str (i: 5, col);
                If (mulcent > 1) Then
                Begin
                    i := round (abs (i * mulcent - i));
                    str (i: 5, row);
                    If i > 0 Then
                        row := ' +' + row + 'Hz ';
                    col := col + 'Hz ' + row;
                End;
                If (mulcent < 1) Then
                Begin
                    i := round (abs (i * mulcent - i));
                    str (i: 5, row);
                    {???}     If i > 0{ich meine: if i<0} Then
                        row := ' -' + row + 'Hz ';
                    col := col + 'Hz ' + row;
                End;
                If (mulcent = 0) Then
                Begin
                    i := round (abs (i * mulcent - i));
                    str (i: 5, row);
                    {???}     If i > 0{ich meine if i=0} Then
                        row := ' �' + row + 'Hz ';
                    col := col + 'Hz ' + row;
                End;{ if mulcent<>1}
                If (mulcent = 1) Then col := col + 'Hz';
            End;{if corry<>2 else }
        End Else Begin{if getflam}
            symbcount := symbcount AND 1;
            str (paggetfreq (page[linenum, actposn + 1 + (symbcount XOR 1)]): 5, row);
            Case getflam (linenum, actposn) Of
                1: col := '[-]' + row;{1}
                2: col := '[+]' + row;{2}
                3: col := '[=]' + row {3}
            Else
            Begin{case getflam of}
                str (paggetfreq (page[linenum, actposn + (symbcount XOR 1)]): 5, row);
                Case getflam (linenum, actposn - 1) Of
                    1: col := '[-]' + row;{1}
                    2: col := '[+]' + row;{2}
                    3: col := '[=]' + row;{3}
                End;{case getflam of}
            End;{case getflam of else}
            End;{case getflam of}
            col := ' ' + col + ' Hz [Tab] ';
        End;{if getflam else}
        If col[0] < #19 Then       {Zentrieren}
            col := ' ' + col;
        While col[0] < #19 Do
        Begin
            col := col + ' ';
            If col[0] < #19 Then
                col := ' ' + col;
        End;{while col}
        col[0] := #19;
        Case Page[linenum, actposn] Of
            ' ': Col := '  0 Hz pause mark  ';
            ',': Col := '  0 Hz  time mark  ';
            '/': Col := '  0 Hz   end mark  ';
            '.': Col := '  0 Hz  help mark  ';
            '\': Col := '  0 Hz  jump mark� ';{Alt Gr 1}
            Chr (167): Col := '  0 Hz  jump mark  ';{Alt Gr 7}
        End;
    End Else{if page}
        col := '                   ';
    IniSpacedText (gmaxx DIV (2 * charwidth) - 23,
        gmaxy DIV charheight - 3,
        col, frLow);
    a := 1;
    i := actposn;
    While (Page[linenum, actposn] IN Nonchars) Do
        Inc (actposn);
    c := Page[linenum, actposn + 1];
    If NOT Odd (symbcount) Then
    Begin
        If Page[linenum, actposn - 1] IN nonChars Then c := Page[linenum, actposn + 1] Else Begin
            c := Page[linenum, actposn];
        End;
    End Else If Page[linenum, actposn] IN nonChars Then c := Page[linenum, actposn + 1] Else c := Page[linenum, actposn];
    actposn := i;
    If Page[linenum, 1] = 'N' Then
    Begin
        If (charset = 2) Then
            If (('a' <= c) AND (c <= 'z')) Then c := Char (Byte (c) - 32) Else {if (('a' <= c) and (c <= 'z')) then}If (('A' <= c) AND (c <= 'Z')) Then c := Char (Byte (c) + 63) Else If ((#128 <= c) AND (c <= #153)) Then c := Char (Byte (c) - 31){else if (('a' <= c) and (c <= 'z')) then}; {if charset = 2 then}
        If blankset = 2 Then
            If c = ',' Then
                c := ' '
            Else
            If c = ' ' Then
                c := ',';
        chbuf := '�  [' + c + ']  �';
        If c = ' ' Then
            chbuf := '� space �';
        If (c >= #128) AND (c <= #153) Then
        Begin
            c := chr (ord (c) - 31);
            chbuf := '� Alt-' + c + ' �';
        End;

        NL := GetN (Page[linenum], ActPosn, 0);
        L  := GetL (Page[linenum], NL, 0);
        If NL > 0 Then
        Begin
            LSt := Page[linenum][NL];
            If (Lst[1] < '0') OR (Lst[1] > '9') Then
                Lst := '   ';
            If L = 1 Then
                LSt := ' ' + LSt
            Else
                LSt := Page[linenum][NL - 1] + LSt;
            If (Lst[1] < '0') OR (Lst[1] > '9') Then
                Lst := '  ' + Lst[2];
            If (L = 2) {and (Lst[1]<>'1')} Then
                Lst := '0' + Lst;
            If Lst[0] <> #3 Then
                Lst := ' ' + Lst;
            {  if Lst='  1' then Lst:= '  1';  }
            If Lst = '   ' Then
                Lst := ' � ';
        End Else Begin
            LSt := ' � ';
        End;
        {Anzeige nach rechts}
        NR := GetN (Page[linenum], ActPosn, 1);
        L  := GetL (Page[linenum], NR, 1);
        If NR > 0 Then
        Begin
            RSt := Page[linenum][NR];
            If (Rst[1] < '0') OR (Rst[1] > '9') Then
                Rst := '   ';
            If L = 1 Then
                RSt := RSt + ' '
            Else
                RSt := Rst + Page[linenum][NR + 1];
            If (Rst[2] < '0') OR (Rst[2] > '9') Then
                Rst := Rst[1] + '  ';
            If (L = 2) {and (Rst[1]<>'1')} Then
                Rst := '0' + Rst;
            If Rst[0] <> #3 Then
                Rst := Rst + ' ';
            If Rst = '   ' Then Rst := '..?';
        End Else Begin
            RSt := '..?';
        End;
        If linenum <> 0 Then
        Begin
            beats := copy (page[linenum], 12, 3);
            eint  := copy (page[linenum], 17, 3);
            resolution := copy (page[linenum], 22, 3);
            While beats[3] = ' ' Do
                beats := ' ' + copy (beats, 1, 2);
            While eint[3] = ' ' Do
                eint := ' ' + copy (eint, 1, 2);

            Str (ActPost - 10, Col);
            If Byte (Col[0]) = 1 Then
                Col := '    '
            Else If Byte (Col[0]) = 2 Then
                Col := '    ';
            Col[0]  := #4;
            Str (Linenum, Row);
            If Byte (Row[0]) = 1 Then
                Row := ' 0' + Row + ' '
            Else If Byte (Row[0]) = 2 Then
                Row := ' ' + Row + ' ';
            Row[0]  := #4;

            If CorrY <> 2{1} Then
                IniSpacedText (gmaxx DIV (2 * charwidth) - 3,
                    gmaxy DIV charheight - 5,
                    ' R  ' + resolution + '/ B' + beats + '/ G' + eint + ' ', frLow);
        End;

        If CorrY = 0 Then
            IniSpacedText (gmaxx DIV (3 * charwidth) - 24,
                gmaxy DIV charheight - 5,
                ' ' + #25 + Row + '�' + '    ' + #26 + ' ', frLow);

        {damit die y-Position der ML gleichzeitig richtig angezeigt wird:}
        Str (ActPost - 10, Col);
        If Byte (Col[0]) = 1 Then
            Col := '    '
        Else If Byte (Col[0]) = 2 Then
            Col := '    ';
        Col[0]  := #4;
        Str (Linenum, Row);
        If Byte (Row[0]) = 1 Then
            {      Row:='  '+Row + ' '  }
            Row := '  ' + Row + 'X'
        Else If Byte (Row[0]) = 2 Then
            Row := ' ' + Row + 'X';
        Row[0]  := #4;

        If (corry = 0) {or (addcent=0) } Then
            col := ' ' + LSt + ' ' + chbuf + ' ' + RSt + ' '
        Else Begin
            str (abs (Round (addcent)): 4, col);
            If addcent > 0 Then
                col := '+' + col
            Else If addcent < 0 Then
                col := '-' + col
            Else
                col := '�' + Col;
            str (round (paggetfreq (page[linenum, actposn]) * mulcent): 5, row);
            col := ' ' + col + 'Cent=' + row + 'Hz';
            IniExpand (col, 19);
        End;
        IniSpacedText (gmaxx DIV (3 * charwidth) - 10,
            gmaxy DIV charheight - 5,
            col, frLow);

        {zeigt x/y-Position}
    End{if Page[linenum,1]='N'} Else Begin
        If Page[linenum][1] = 'T' Then
        Begin
            Str (ActPost - 10, Col);
            If Byte (Col[0]) = 1 Then
                Col := ' 0' + Col + ' '
            Else If Byte (Col[0]) = 2 Then
                Col := ' ' + Col + ' ';
            Col[0]  := #4;
            Str (Linenum, Row);
            If Byte (Row[0]) = 1 Then
                Row := ' 0' + Row + ' '
            Else If Byte (Row[0]) = 2 Then
                Row := ' ' + Row + ' ';
            Row[0]  := #4;
            IniSpacedText (gmaxx DIV (3 * charwidth) - 24,
                gmaxy DIV charheight - 5,
                ' ' + #25 + Row + '�' + Col + #26 + ' ', frLow);

            IniSpacedText (gmaxx DIV (2 * charwidth) - 3,
                gmaxy DIV charheight - 5,
                '                    ', frLow);
            IniSpacedText (gmaxx DIV (3 * charwidth) - 10,
                gmaxy DIV charheight - 5,
                '                   ', frLow);

            IniSpacedText (gmaxx DIV (2 * charwidth) - 3,
                gmaxy DIV charheight - 3,
                '                    ', frLow);
            IniSpacedText (gmaxx DIV (3 * charwidth) - 10,
                gmaxy DIV charheight - 3,
                '                   ', frLow);

{      IniSpacedText(gmaxx div (2*charwidth) - 3,
                       gmaxy div charheight - 1,
                      '                    ',frLow);}
            IniSpacedText (gmaxx DIV (3 * charwidth) - 10,
                gmaxy DIV charheight - 1,
                '                   ', frLow);

    {  IniSpacedText(gmaxx div (1*charwidth) - 22,
                       gmaxy div charheight - 1,
                      '                       ',frLow);  }

 {    if Page[Linenum][1]='T' then

         SetFillStyle(1,bottomcolor);
         Bar(120,465,280,475);
         Bar(120,430,280,445);
         Bar(281,465,445,475);
         Bar(281,430,445,445);   }
        End;

        SetLineStyle (Solidln, 1, 0);

                                  {Anzeigen numeriert von O nach U
                                  1.Kolonne, 2., 3.}
    End;{ if Page[linenum][1]='N' else}
End;{proc 1}

{*******************************************************************}
Procedure PagUnMark;
{Unmark and refresh page}

Var refmin, refmax: byte;
    mx: integer;

Begin
    refmin := topmargin;
    refmax := pagelength;
    mx := mstart.mxcoord;
    If pagecount = mstart.mpag Then refmin := mstart.mline;
    If pagecount = mend.mpag Then refmax := mend.mline;

    If ((pagecount >= mstart.mpag) AND
        (pagecount <= mend.mpag)) Then
    Begin
        markinit;
        PagRefClearVal (0, IniYNow (refmin - 1), gmaxX, IniYNow (refmax + 1));
    End
    Else
    If ((pagecount = mstart.mpag) AND (mend.mpag = -1)) Then
    Begin
        markinit;
        PagRefClearVal (mx - 3, IniYNow (refmin - 1),
            mx + 9, IniYNow (refmin + 1));
    End
    Else
        markinit;
End;

{*******************************************************************}
Procedure PagCursorLeft(linenum: integer; Var actposn, actpost: integer);

Var
    xa: integer;
    inblock: stringline;
    lineattr: lineattrtype;

Begin
    If Page[linenum, 1] = 'N' Then
    Begin
        inblock := page[linenum];
        GetNoteBlock (inblock, lineattr, linenum);
        Xa := IniFirstBeatPos (lineattr);
        GetNotePosX (Xa, actposn, linenum, true, true);
    End Else Begin
        actpost := linemarker + 2;
        TexActPosX (Xa, actpost, linenum, true);
    End;
End;

{*******************************************************************}
Procedure PagCursorRight(linenum: integer; Var actposn, actpost: integer);
Var xa: integer;
Begin
    If Page[linenum, 1] = 'N' Then
    Begin
        xa := IniLineEnd (page[linenum]);
        GetNotePosX (Xa, actposn, linenum, true, false);
    End Else Begin
        xa := gmaxX - Gcurightmargin;
        actpost := length (page[linenum]) + 1;
        While (page[linenum, actpost - 1] = ' ') AND (actpost > linemarker + 1) Do
            dec (actpost);
        If actpost < linemarker + 2 Then
            actpost := linemarker + 2;
        page[linenum, 0] := char (actpost - 1);
        TexActPosX (Xa, actpost, linenum, true);
    End;
End;

{*******************************************************************}
{*******************************************************************}
{*******************************************************************}
Procedure PagEmptyBottomLine;
Begin
    SetColor (lcolor);
    SetBkColor (bkcolor);
    SetFillStyle (1, bottomcolor);
    Bar (1, grmaxy + 3, gmaxx, gmaxy);
    PagBottomFrame;
    IniSpacedText (2, 54, '             ', frLow);
    IniSpacedText (2, 56, '             ', frLow);
    IniSpacedText (2, 58, '             ', frHigh);

    IniSpacedText (16, 54, '                   ', frLow);
    IniSpacedText (16, 56, '                   ', frLow);
    IniSpacedText (16, 58, '                   ', frLow);

    IniSpacedText (36, 54, '                    ', frLow);
    IniSpacedText (36, 56, '                    ', frLow);
    IniSpacedText (36, 58, '                    ', frLow);

    IniSpacedText (57, 54, '                       ', frLow);
    IniSpacedText (57, 56, '              ', frLow);
    IniSpacedText (72, 56, '        ', frHigh);
    IniSpacedText (57, 58, '                       ', frLow);

End;
{*******************************************************************}
Procedure PagPutSearchBottomLine;
Begin
    PagEmptyBottomLine;
End;
{*******************************************************************}
Procedure PagPutBottomLine;

Const itemlength = 21;

Var inblock: stringline;
    i: longint;
    x: byte;
    St: String;
    w: longint;

    {**********************************************************}
    Procedure PagPutFileHint(hinttext: string);
    {Kleines Proceduerchen um den File-Name hinzuschreiben}

    Var x, y: integer;
        { var actpage: integer; }
    Begin
        y := gmaxy DIV charheight - 2;
        x := TextMargin DIV charwidth + 1;
        IniSpacedText (x + 1, y - 1, hinttext, frLow);
    End;

Begin
    If NOT (printeron OR showmenus) Then
    Begin
        PagEmptyBottomLine;
        IniSpacedText (gmaxx DIV (3 * charwidth) - 24,
            gmaxy DIV charheight - 1,
            ' [F1] = HELP ', fr3D);

        If sndlengthspm = 0 Then sndlengthspm := 80;
        w := Round (1000 * sndlengthspm);
        Str ((w / 1000): 5: 3, St);
        While St[0] < #8 Do
            St := ' ' + st;
        Case sndlengthper Of
            1: st := St + '  B';
            2: st := st + '  L';
        End;
        st := st + 'PM ';
        IniExpand (St, itemlength - 7);
        IniSpacedText (gmaxx DIV charwidth - 22,
            gmaxy DIV charheight - 3,
            St, frLow);
        IniSpacedText (gmaxx DIV charwidth - 7,
            gmaxy DIV charheight - 3,
            ' MENU ' + #16 + ' ', fr3D);

        If (NOT (defsetuppage IN actedit)) Then
        Begin
            x := Pos ('   .', actfilename);
            St := actfilename;
            St := Copy (St, 1, x - 1) + Copy (St, x + 1, Length (St) - x);
            St := ' ' + St;
            If St[0] > Char (itemlength + 2) Then
                Repeat
                    Dec (Byte (St[0]));
                Until (St[Byte (St[0]) + 1]) = '.';
            IniExpand (St, itemlength + 2);
            UpString (St);
            IniSpacedText (gmaxx DIV charwidth - 22,
                gmaxy DIV charheight - 5,
                St, frLow);
        End;

        If setuppage IN actedit Then
        Begin
            If defsetuppage IN actedit Then PagPutFileHint (' PAGEDEFAULT ') Else Begin
                PagPutFileHint (' SETUP  PAGE ');
            End;
        End Else Begin
            Str (PageCount: 3, inblock);{Sorry wegen des Missbrauchs deines inblockes}
            IniSpacedText (gmaxx DIV 16 - 37,
                gmaxy DIV charheight - 3,
                ' PAGE :  ' + inblock + ' ', frLow);
        End;
        i := framewidth;
        Framewidth := 0;
        IniSpacedText (grmaxx DIV charwidth - 22, gmaxy DIV charheight - 1,
            ' ' + fontfile, frLow);
        Framewidth := i;
    End Else {if not printeron} If printeron Then
    Begin
        Str (pagecount: 3, inblock);
        inblock := ' Printing page ' + inblock;
        HlpBottomLine (inblock);
    End Else ButDraw;
End;

{*************************************************************************}

Procedure PagClearBottomLine;

Begin
    SetFillStyle (1, bottomcolor);
    Bar (1, grmaxy + 3, gmaxx - 1, gmaxy - 1); {l�scht aber den Lichtrand nicht!}
End;

{*******************************************************************}
Procedure PagPageFrame;
Begin
    If printeron Then
    Begin
        PriSetLineWidth (frwidth);
        PriDrawFrame (grminx, grminy, grmaxx, grmaxy);
    End Else Begin
        SetColor (5);
        Line (grminx, grminy, grminx, grmaxy); { � l}
        Line (grminx, grminy, grmaxx, grminy); { � o}
        SetColor (bkcolor);
        Line (grmaxx, grminy + 1, grmaxx, grmaxy - 1); { � r }
    End;
End;

{*******************************************************************}
Function PagEmptyPage(Var tempptr, startptr, lastptr: listptr): boolean;
    {Testen, ob die n�chste Seite im Heap leer ist}
Var result, endreached: boolean;
    i, tbufpos: byte;
    inblock, tempbuf: stringline;
    tempsav: listptr;
Begin
    result := true;
    i := topmargin;
    tbufpos := 0;
    tempbuf := '';
    tempsav := tempptr;

    While ((result) AND (i <= pagelength)) Do
    Begin
        FilCheckLine (tempbuf, inblock, tempptr, startptr, lastptr,
            tbufpos, endreached, true, false);
        {leere Zeile oder Fuss/Kopftext Zeile}
        If ((IniEmptyLine (inblock)) OR (inblock[4] = 'F')) Then i := i + 1 Else result := false;
    End;
    tempptr := tempsav;
    PagEmptyPage := result;
End;

{*******************************************************************}
Procedure PagRemovePage(Var tempptr, startptr, lastptr: listptr);
{l�scht ersatzlos eine Seite im Buffer}
Var
    i: byte;
    inblock: stringline;
Begin
    i := topmargin;
    While ((tempptr <> lastptr) AND (i <= pagelength)) Do
    Begin
        FilHeapExtractString (inblock, tempptr, startptr, lastptr);
        i := i + 1;
    End;
End;

{*******************************************************************}
Procedure PagGetPageFromHeap(Var tempptr, startptr, lastptr: listptr;
    Var linec: integer);
{Kopieren einer Seite aus dem Heap in den Page-Array}
Var inblock: stringline;

Begin
    If tempptr <> lastptr Then
    Begin
        linec := topmargin;
        Repeat
            FilHeapExtractString (inblock, tempptr, startptr, lastptr);
            page[linec] := inblock;
            While length (page[linec]) < linemarker Do page[linec] := page[linec] + ' ';
            If (page[linec, 1] <> 'N') AND (page[linec, 1] <> 'T') Then
                page[linec, 1] := 'T';
            inc (linec);
        Until (linec > pagelength) OR (tempptr = lastptr);
        While linec <= pagelength Do
        Begin
            page[linec] := 'T         ';
            inc (linec);
        End;
    End;
End;

{*******************************************************************}
Procedure PagDisplayPage(Var tempptr, startptr, lastptr: listptr);
{Darstellen einer Seite von der gegenw�rtigen Position an}

Var linec, i: integer;
    rptr: listptr;

Begin
    ClearViewPort;
    PagPageFrame;
    PagPutBottomLine;
    {Seite lesen}
    If tempptr <> lastptr Then PagGetPageFromHeap (tempptr, startptr, lastptr, linec) Else { if tempptr <> lastptr then} PagGetSetupPage (rptr, startptr, lastptr); { else if tempptr <> lastptr then}
    linec := pagelength;

    {Seite anzeigen}
    i := topmargin;
    Repeat
        GetLine (i, 0);
        i := i + 1;
    Until ((i > pagelength) OR ((IniKeyPressed) AND (pagecount <> 1)));
    i := topmargin;
    Repeat
        TitGetText (i, 0);
        i := i + 1;
    Until ((i > pagelength) OR ((IniKeyPressed) AND (pagecount <> 1)));
    MarkDisplay;
    IniRefInit;
End;

{*******************************************************************}
Procedure PagGetSetupPage(Var tempptr, startptr, lastptr: listptr);
Var tempbuf: stringline;
    i: integer;
    endreached: boolean;
    tbufpos: byte;
Begin
    tbufpos := 0;
    tempbuf := '';
    tempptr := startptr;
    For i := topmargin To pagelength Do
    Begin
        FilCheckLine (tempbuf, page[i], tempptr, startptr, lastptr,
            tbufpos, endreached, true, false);
        page[i, 3] := ' ';
    End;
End;

{*******************************************************************}
Procedure PagReadPage(Var tempptr, startptr, lastptr: listptr;
    Var tempbuf: stringline; Var tbufpos: byte);
{liest eine Seite aus dem heap, ohne den Heap zu ver�ndern}
Var i: integer;
    endreached: boolean;
Begin
    For i := topmargin To pagelength Do
        FilCheckLine (tempbuf, page[i], tempptr, startptr, lastptr,
            tbufpos, endreached, true, false);
End;

{*******************************************************************}
Procedure PagRefPage;
Begin
    PagRefClearVal (0, 0, gmaxX, gmaxY);
End;

{*******************************************************************}
Procedure PagRefClearVal(clearxmin, clearymin, clearxmax, clearymax: integer);
Begin
    If clearxmin < refxmin Then refxmin := clearxmin;
    If clearxmax > refxmax Then refxmax := clearxmax;
    If clearymin < refymin Then refymin := clearymin;
    If clearymax > refymax Then refymax := clearymax;
    If refxmin < 0 Then refxmin := 0;
    If refymin < 0 Then refymin := 0;
    If refxmax > grmaxx Then refxmax := grmaxx;
    If refymax > grmaxy Then refymax := grmaxy;
End;

{*******************************************************************}
Procedure PagRefreshPage(clearxmin, clearymin,
    clearxmax, clearymax: integer);
{Darstellen einer Seite aus dem Page-Buffer}
Var i: integer;
    reflinemin, reflinemax: integer;
    testinp: boolean;
Begin
    SetPalette (12, 0);             { Color 12=PalReg[0]                    }
    SetPalette (13, 15);            { Color 13=PalReg[15]                   }
    IniSetDACReg (60, 0, 0, 0);       { light red ->Schwarz                   }
    IniSetDACReg (5, 63, 63, 63);     { magenta   ->Weiss  }
    IniSetDACReg (63, 10, 10, 10);    { Weiss     ->Grau   Mausfarbe!!!       }
    SetLineStyle (SolidLn, 0, 1);
    If clearxmin < clearxmax Then
    Begin
        GcuPatternRestore;
        Mausdunkel;
        IniSetViewPort (clearxmin, clearymin - 17, clearxmax, clearymax); {-17 wegen m(ove) pitchlines}
        ClearViewPort;
        SetViewPort (0, 0, gmaxX, gmaxY, true);
        PagPageFrame;
        reflinemin := (clearymin DIV linethick) - 4;
        reflinemax := (clearymax DIV linethick) + 4;
        If reflinemin < topmargin Then reflinemin := topmargin;
        If reflinemax > pagelength Then
            reflinemax := pagelength;
        If clearymax > grmaxy Then
            PagPutBottomLine;
        testinp := ((reflinemax - reflinemin) > 15) AND (pagecount <> 1);
        For i := reflinemin To reflinemax Do
        Begin
            GetLine (i, clearxmin - 20);
            If (testinp AND IniKeyPressed) Then
                break;
        End;
        If printeron Then
            PriSwapFont;
        For i := reflinemin To reflinemax Do
        Begin
            TitGetText (i, 0);                          {@@@@@}
            If (testinp AND IniKeyPressed) Then
                break;
        End;
        MarkDisplay;
        MausZeigen;
        GcuCursorRestore;
    End;{ if clearxmin < clearxmax then }
End;

{*******************************************************************}
Procedure PagShowPage(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    PageNumber: integer; savenow: boolean);
{Darstellen der Seite PAGENUMBER}
Var Result: integer;
Begin
    If savenow Then
        FilSavePage (1, PageLength, actptr, startptr, lastptr);
    FilFindPage (PageNumber, Result, actptr, startptr, lastptr);
    PageCount := Result;
    IniNewPage (linenum);
    PagDisplayPage (actptr, startptr, lastptr);
    PagCursorLeft (linenum, actposn, actpost);
End;

Procedure PagBottomFrame;
Begin
    SetColor (12);                        {Abgrenzung zur Filepage}
    Line (0, grmaxy + 1, gmaxx, grmaxy + 1);
    Line (0, grmaxy, gmaxx, grmaxy);
    SetColor (framecolor);                {Licht links und oben}
    Line (0, grmaxy + 2, gmaxx, grmaxy + 2);
    Line (0, grmaxy + 3, 0, gmaxy);
End;

Function paggetfreq(c: char): Integer;
Var a: Integer;
Begin
    If (soundchange AND saRhythm) <> 0 Then a := RhythmFreq Else If (c IN ['A'..'Z']) Then a := Sympar[Char (Byte (c) + 32), 3, 2] Else If (c IN ['a'..'z']) Then a := Sympar[c, 3, 1] Else If (c IN [Chr (161)..Chr (191)]) Then a := Sympar[Char (Byte (c) - 31), 3, 3] Else If (c IN [' ', '.', ',']) Then a := 0 Else If (c IN ['+', '-', '=', '*']) Then a := 0 Else If (c IN ['/', Chr (167), '\']) Then a := 0 Else If (c IN ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']) Then a := 32767 Else a := 0;
    paggetfreq := a;
End;

End.
