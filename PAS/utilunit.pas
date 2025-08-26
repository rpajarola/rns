{$I RNS.H}

Unit utilunit;

Interface

Uses
    initsc,
    gcurunit,
    menutyp,
    graph;

Procedure UtiDelNoteChar(Var inblock: stringline; Var actpos: integer;
    Var stbuf: string);
Procedure UtiDelNumChar(Var inblock: stringline; Var actpos: integer);
Function UtiGetNum(inblock: stringline; actpos: integer): Integer;
Procedure UtiCharBegin(Var inblock: stringline; Var actpos: integer);
Procedure UtiFindCharEnd(Var inblock: stringline; Var actpos: integer);
Procedure UtiComputeDxDy(inblock: stringline; Var dx, dy: integer;
    charnum: byte; flamchar: char);
Procedure UtiKlammerZuPos(c: char; Var dx: integer; flamchar: char);
Procedure UtiKlammerAufPos(inblock: stringline; Var dx, height: integer; flamchar: char);
Procedure UtiNextNum(Var inblock: stringline; Var actpos, numres: integer;
    left: boolean);
Function UtiComputeGroup(c: char; Var indexc: char): integer;
Function UtiCharReady(Var inblock: string; c: char): boolean;
Function UtiNumReady(Var inblock: string; c: char): boolean;
Procedure UtiGetActDistance(Var inblock: stringline; actpos: integer;
    Var strbuf: string);
Function UtiReplaceChars(inblock: stringline): byte;
Function UtiCheckFlam(Var inblock: stringline; actpos: integer): char;
Function UtiNextChar(inblock: stringline; c: char; p: integer): integer;
Implementation

Uses HelpUnit,
    Texts;
{**************************************************************}
Function UtiComputeGroup(c: char; Var indexc: char): integer;
{Wird 1 fuer Kleinbuchstaben
      2 fuer shift
      3 fuer alt
      4 fuer &
      0 sonst
      indexc wird die Grundform von c}
Var i: integer;
Begin
    i := 0;
    indexc := c;
    Case c Of
        'a'..'z': i := 1;
        'A'..'Z':
        Begin
            i := 2;
            indexc := char (byte (c) + 32);
        End;
        #128..#153:
        Begin
            i := 3;
            indexc := char (byte (c) - 31);
        End;
    End;
    UtiComputeGroup := i;
End;

{****************************************************************}
Function UtiFlamPos(inblock: string): byte;
    {Setzt sich auf den Index des Flamchars, wenn einer in inblock ist}

Var i: byte;

Begin
    i := Pos ('+', inblock);
    If i = 0 Then i := Pos ('=', inblock);
    If i = 0 Then i := Pos ('-', inblock);
    If i = 0 Then i := Pos ('*', inblock);
    UtiFlamPos := i;
End;

{****************************************************************}
Function UtiReplaceChars(inblock: stringline): byte;
    {Zaehlt die Anzahl Replace-Character in inblock}
Var i, j, k: byte;
    indexc, c: char;
Begin
    i := 0;
    For j := 1 To length (inblock) Do
    Begin
        c := inblock[j];
        k := UtiComputeGroup (c, indexc);
        If ((k > 0) AND (sympar[indexc, 2, k] = 1) AND (manset = 1)) OR
            ((k = 0) AND (c <> '\') AND (c <> #221) AND (c IN spec)) Then
            inc (i);
    End;
    UtiReplaceChars := i;
End;

{****************************************************************}
Function UtiCharReady(Var inblock: string; c: char): boolean;
{gibt das Zeichen c in den Buffer inblock und wird true,
 wenn dadurch das gesamte Zeichen fertig ist}
Var i, j, k: byte;
    indexc: char;
    a: byte;
Begin
    If ((ininumchar (inblock[1])) OR
        (IniArrow (inblock[1]))) Then
        inblock := '';
    {Zeichenbuffer voll, oder add-Zeichen schon vorhanden?}
    If length (inblock) = 16 Then
        c := #255;
    k := UtiComputeGroup (c, indexc);
    If ((k > 0) AND (sympar[indexc, 2, k] = 2) AND (pos (c, inblock) > 0)) Then
        c := #255;
    If c <> #255 Then
        If inblock = '' Then
            inblock := c
        Else Begin
            { Klammern }
            a := length (inblock);
            Case c Of
                '(', '[': If manset = 2 Then inblock := inblock + c{ add mode } Else Begin
                        { replace mode }
                        i := pos ('=', inblock);
                        j := pos ('*', inblock);
                        If i < j Then
                            i := j;
                        j := pos ('+', inblock);
                        If i < j Then
                            i := j;
                        j := pos ('-', inblock);
                        If i < j Then
                            i := j;
                        If (i = 0) Then inblock := c + inblock Else If i <= (a - 2) Then
                            insert (c, inblock, i + 1)
                        Else
                            inblock := inblock + c;
                    End;
                ')': If inblock[a] = '(' Then
                        HlpHint (HntEmptyBracket, HintNormalTime)
                    Else
                        inblock := inblock + c;
                ']': If inblock[a] = '[' Then
                        HlpHint (HntEmptyBracket, HintNormalTime)
                    Else
                        inblock := inblock + c;
                '{':
                Begin
                    a := pos ('=', inblock);
                    If (pos ('{', inblock) = 0) AND (a <> 0) Then
                        Insert ('{', inblock, a + 1);
                End;
                '}':
                Begin
                    a := pos ('=', inblock);
                    If (pos ('}', inblock) = 0) AND (a <> 0) Then
                    Begin
                        If length (inblock) >= a Then
                            inc (a);
                        If (pos ('{', inblock) <> 0) AND (length (inblock) >= a) Then
                            inc (a);
                        If UtiComputeGroup (inblock[a], indexc) <> 0 Then
                            inc (a);
                        Insert (c, inblock, a);
                    End Else
                        inblock := inblock + '}';
                End;
            Else{case} If IniPrintNote (c) Then
                Begin
                    If ((k > 0) AND (sympar[indexc, 2, k] = 1)) Then
                        inblock := inblock + c
                    Else
                        inblock := c + inblock;
                End{IniPrintNote(c)} Else If c IN FlamSet Then
                    inblock := inblock + c;
            End;{case}
        End{-------------------------------------------------------------------------}{inblock='' else }{-------------------------------------------------------------------------};{c<>#255}
    {pruefen ob Zeichen fertig}
    UtiCharReady := ((UtiReplaceChars (inblock) = 1) AND (UtiFlamPos (inblock) = 0))
        OR (UtiReplaceChars (inblock) = 2);
End;

{****************************************************************}
Function UtiNumReady(Var inblock: string; c: char): boolean;
{gibt das Zeichen c in den Buffer inblock und wird true,
 wenn dadurch eine Abstandseingabe fertig ist}
Var strbuf: string;
Begin
    If (NOT (IniNumchar (inblock[1]) OR IniArrow (inblock[1]))) Then
        inblock := '';
    {Zeichen eingeben}
    If (inblock <> '') AND (IniArrow (c)) Then
        inblock := '';
    inblock := inblock + c;
    {pruefen ob Zeichen fertig}
    strbuf  := inblock;
    If IniArrow (inblock[1]) Then
    Begin
        Delete (strbuf, 1, 1);
        If IniDoppel (strbuf[1]) Then
            Delete (strbuf, 1, 1);
    End;
    If (((strbuf[1] = '0') AND (length (strbuf) = 3) AND (strbuf[2] > '0')) OR
        {  ((strbuf[1] = '0') and (length(strbuf) = 5) and (strbuf[2] = '0')) or}
        {  fr 00100 bis 00999, Anzeige funktioniert aber falsch: pageunit.pas 329}
        ((strbuf[1] >= '1') AND (strbuf[1] <= '9'))) Then
        UtiNumReady := true
    Else
        UtiNumReady := false;
End;

{****************************************************************}
Function UtiCheckFlam(Var inblock: stringline; actpos: integer): char;
    {wird +,-,=,* wenn der actuelle character ein Flam enth„lt}
Var c: char;
Begin
    c := ' ';
    While (actpos > 1) AND (NOT IniNumChar (inblock[actpos - 1])) Do
        dec (actpos);
    While (length (inblock) > actpos) AND
        (NOT IniNumChar (inblock[actpos])) Do
    Begin
        If (inblock[actpos] IN flamset) Then
            c := inblock[actpos];
        inc (actpos);
    End;
    UtiCheckFlam := c;
End;

{****************************************************************}
Procedure UtiComputeDxDy(inblock: stringline; Var dx, dy: integer;
    charnum: byte; flamchar: char);
{berechnet dx und dy, je nach der Gr”sse der folgenden Zeichen}
Const DXDYTab: Array[0..2, 0..4] Of Record
            dx, dy: integer
        End =
        (((dx: -7; dy: -7),          { - } { 'a'..'z' }
        (dx: +7; dy: -7),          { + }
        (dx: 0; dy: -14),          { = }
        (dx: 0; dy: +16),          { * }
        (dx: 0; dy: 0)),

        ((dx: -10; dy: -10),          { - } { 'A'..'Z' }
        (dx: +10; dy: -10),          { + }
        (dx: 0; dy: -14),          { = }
        (dx: 0; dy: +16),          { * }
        (dx: 0; dy: 0)),

        ((dx: -5; dy: -5),          { - } { alt-a..alt-z }
        (dx: +5; dy: -5),          { + }
        (dx: 0; dy: -14),          { = }
        (dx: 0; dy: +16),          { * }
        (dx: 0; dy: 0)));
Var Size, Flam: Byte;
    c: char;
Begin
    If charnum > length (inblock) Then
        c := 'a'
    Else
        c := inblock[charnum];
    If (c IN klammerset) AND (charnum < length (inblock)) Then
        c := inblock[charnum + 1];
    If (c <= 'z') AND (c >= 'a') Then
        Size := 0
    Else If (c <= 'Z') AND (c >= 'A') Then
        Size := 1
    Else If (length (inblock) < charnum) OR (charnum = 0) OR (c IN flamset) OR (ininumchar (c)) Then
        Size := 0
    Else
        Size := 2;
    Case flamchar Of
        '-': Flam := 0;
        '+': Flam := 1;
        '=': Flam := 2;
        '*': Flam := 3;
    Else Flam := 4;
    End;
    dx := DXDYTab[Size, Flam].dx;
    dy := DXDYTab[Size, Flam].dy;
End;

{****************************************************************}
Procedure UtiKlammerZuPos(c: char; Var dx: integer; flamchar: char);
Var dy: integer;
    inblock: stringline;
Begin
    inblock := c;
    UtiComputeDxDy (inblock, dx, dy, 1, '+');
    Case flamchar Of
        '-': ;
        '+': dx := 2 * dx;
        '=': ;
        '*': ;
    End;
End;

{****************************************************************}
Procedure UtiKlammerAufPos(inblock: stringline; Var dx, height: integer; flamchar: char);
{berechnet die Position fr die Klammer}
Var hy: integer;
Begin
    height := 5;
    UtiComputeDxDy (inblock, dx, hy, 2, '-');
    Case flamchar Of
        '-': dx := 2 * dx;
        '+': ;
        '=': ;
        '*': ;
    End;
End;

{****************************************************************}
Procedure UtiDelNoteChar(Var inblock: stringline; Var actpos: integer;
    Var stbuf: string);
{L”scht einen Character bis zum n„chsten numerischen Character,
 der gel”schte Character kommt in den Buffer stbuf}
Var i: integer;
Begin
    stbuf := '';
    inc (actpos);
    While (inblock[actpos - 1] <> '%') AND (NOT IniNumChar (inblock[actpos - 1])) Do
        dec (actpos);
    i := 0;
    While (actpos + i <= length (inblock)) AND (NOT IniNumChar (inblock[actpos + i])) Do
        inc (i);
    If i <> 0 Then
    Begin
        stbuf := copy (inblock, actpos, i);
        delete (inblock, actpos, i);
    End Else
        stbuf := '';
{  while (not IniNumChar(inblock[actpos]))and(length(inblock)>=actpos) do begin
    stbuf:= stbuf + inblock[actpos];
    delete(inblock, actpos, 1);
  end;}
    If actpos > length (inblock) Then
    Begin
        actpos := length (inblock) + 1;
        UtiGetActDistance (inblock, actpos, stbuf);
        inblock := inblock + stbuf + '.';
    End Else If inblock[actpos] = '%' Then
        inblock := inblock + '.1.';
End;

{****************************************************************}
Procedure UtiGetActDistance(Var inblock: stringline; actpos: integer;
    Var strbuf: string);
{Berechnet von actpos aus rueckwaerts die Distanz}
Begin
    strbuf := '';
    dec (actpos);
    While (inblock[actpos] <> '%') AND (IniNumChar (inblock[actpos])) Do
    Begin
        strbuf := inblock[actpos] + strbuf;
        dec (actpos);
    End;
    If strbuf = '' Then
        strbuf := '1';
End;
{****************************************************************}
Procedure UtiDelNumChar(Var inblock: stringline; Var actpos: integer);
{L”scht numerische Zeichen bis zum n„chsten nichtnumerischen Character}
Var i: integer;
Begin
    i := 0;
    While (actpos + i <= length (inblock)) AND (IniNumChar (inblock[actpos + i])) Do
        inc (i);
    delete (inblock, actpos, i);
    If actpos > length (inblock) Then inblock := inblock + '.';
End;

{****************************************************************}
Function UtiGetNum(inblock: stringline; actpos: integer): Integer;
Var St: String;
    I:  Integer;
    code: integer;
Begin
    St := '';
    InBlock := copy (inblock, actpos, 10);
    While (NOT IniNumChar (inblock[1])) AND (Length (inblock) <> 0) Do
        Delete (inblock, 1, 1);
    While IniNumChar (inblock[1]) AND (Length (inblock) <> 0) Do
    Begin
        St := St + Inblock[1];
        Delete (inblock, 1, 1);
    End;
    If Length (inblock) = 0 Then
    Begin
        UtiGetNum := 0;
        Exit;
    End;
    Val (St, i, code);
    If code <> 0 Then
        i := 0;
    UtiGetNum := i;
End;

{****************************************************************}
Procedure UtiCharBegin(Var inblock: stringline; Var actpos: integer);
{sucht den Beginn des Notenzeichens in Inblock
 an der Stelle actpos}
Begin
    While (inblock[actpos - 1] <> '%') AND (NOT IniNumchar (inblock[actpos - 1])) Do
        dec (actpos);
End;

{****************************************************************}
Procedure UtiFindCharEnd(Var inblock: stringline; Var actpos: integer);
{sucht das Ende des Notenzeichens in Inblock
 an der Stelle actpos}
Begin
    While (actpos < length (inblock)) AND (NOT IniNumChar (inblock[actpos + 1])) Do
        inc (actpos);
End;

{****************************************************************}
Procedure UtiNextNum(Var inblock: stringline; Var actpos, numres: integer;
    left: boolean);
{sucht den n„chsten numerischen String in inblock, beginnend bei
 actpos, nach rechts oder links (links: left = true).
 numres wird der Wert des Strings. Actpos wird unmittelbar vor
 das numerische Zeichen gesetzt}

Var numstr: string;
    i: byte;
    code: integer;

Begin
    numres := 0;
    numstr := '0';
    If left Then
    Begin
        UtiCharBegin (inblock, actpos);
        If IniNumChar (inblock[actpos - 1]) Then
        Begin
            i := actpos - 1;
            While IniNumChar (inblock[i - 1]) Do
                i := i - 1;
            numstr := Copy (inblock, i, actpos - i);
        End;
    End
    Else
    Begin
        UtiFindCharEnd (inblock, actpos);
        If length (inblock) > actpos Then
        Begin
            i := actpos + 1;
            While IniNumChar (inblock[i + 1]) Do
                i := i + 1;
            numstr := Copy (inblock, actpos + 1, i - actpos);
        End;
    End;
    Val (numstr, numres, code);
    If code <> 0 Then
        numres := 0;
End;

Function UtiNextChar(inblock: stringline; c: char; p: integer): integer;
Var i: integer;
Begin
    For i := p + 1 To length (inblock) Do
        If inblock[i] = c Then
            break;
    If inblock[i] = c Then
        UtiNextChar := i
    Else
        UtiNextChar := 0;
End;
Function UtiPrevChar(inblock: stringline; c: char; p: integer): integer;
Var i: integer;
Begin
    For i := p - 1 Downto 1 Do
        If inblock[i] = c Then
            break;
    If inblock[i] = c Then
        UtiPrevChar := i
    Else
        UtiPrevChar := 0;
End;

End.
