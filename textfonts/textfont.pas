Program Textfont(input, output);

Uses crt, dos, graph;

Const
    farbe: integer = 14;{14=gelb, 12=schwarz im RNS}

Var
    font: Array[1..3, 1..4200] Of char;
    ch: char;
    a, x, y: integer;
    uli: string;

Procedure graphinit;
Var
    gd, gm: integer;
Begin
    gd := detect;
    initgraph (gd, gm, '');
End;

Procedure graphclose;
Begin
    closegraph;
End;

Procedure loadfont(name: string);
Var
    fnttab: Array[1..3] Of string[82];
    a, b: integer;
    datei: File Of char;
    fs: longint;
    ch: char;
Begin
    fnttab[1] := name + '8x8.fnt';
    fnttab[2] := name + '8x16.fnt';
    fnttab[3] := name + '6x12.fnt';
    For a := 1 To 3 Do
    Begin
        assign (datei, fnttab[a]);
        reset (datei);
        ch := #0;
        b  := 0;
        While (ch <> #26) Do
        Begin
            read (datei, ch);
            inc (b);
        End;
        fs := filesize (datei) - b + 1;
        For b := 1 To fs Do
        Begin
            read (datei, ch);
            font[a, b] := ch;
        End;
        close (datei);
    End;
End;

Procedure writecharslanted(x, y, size: integer; ch: char);
Var
    a, b, f, c, d: integer;
Begin
    If size = 8 Then f := 1 Else
    If size = 16 Then f := 2 Else
    If size = 12 Then f := 3;
    d := 6;
    For a := 1 To ord (font[f, 2]) Do
    Begin
        c := 128;
        If (odd (a)) Then dec (d);
        For b := 1 To ord (font[f, 1]) Do
        Begin
            If (ord (font[f, ord (ch) * ord (font[f, 2]) + 2 + a]) AND c) <> 0 Then
                putpixel (x + b + d, a + y, farbe);
            c := c DIV 2;
        End;
    End;
End;

Procedure writechar(x, y, size: integer; ch: char);
Var
    a, b, f, c: integer;
Begin
    If size = 8 Then f := 1 Else
    If size = 16 Then f := 2 Else
    If size = 12 Then f := 3;
    For a := 1 To ord (font[f, 2]) Do
    Begin
        c := 128;
        For b := 1 To ord (font[f, 1]) Do
        Begin
            If (ord (font[f, ord (ch) * ord (font[f, 2]) + 2 + a]) AND c) <> 0 Then
                putpixel (x + b, a + y, farbe);
            c := c DIV 2;
        End;
    End;
End;

Procedure writechardouble(x, y, size: integer; ch: char);
Var
    a, b, f, c: integer;
Begin
    If size = 8 Then f := 1 Else
    If size = 16 Then f := 2 Else
    If size = 12 Then f := 3;
    For a := 1 To ord (font[f, 2]) Do
    Begin
        c := 128;
        For b := 1 To ord (font[f, 1]) Do
        Begin
            If (ord (font[f, ord (ch) * ord (font[f, 2]) + 2 + a]) AND c) <> 0 Then
                putpixel (x + 2 * b, 2 * a + y, farbe);
            c := c DIV 2;
        End;
    End;
End;

Procedure writechar2bold(x, y, size: integer; ch: char);
Var
    a, b, f, c: integer;
Begin
    If size = 8 Then f := 1 Else
    If size = 16 Then f := 2 Else
    If size = 12 Then f := 3;
    For a := 1 To ord (font[f, 2]) Do
    Begin
        c := 128;
        For b := 1 To ord (font[f, 1]) Do
        Begin
            If (ord (font[f, ord (ch) * ord (font[f, 2]) + 2 + a]) AND c) <> 0 Then
            Begin
                putpixel (x + 2 * b, 2 * a + y, farbe);
                putpixel (1 + x + 2 * b, 2 * a + y, farbe);
                putpixel (x + 2 * b, 1 + 2 * a + y, farbe);
                putpixel (1 + x + 2 * b, 1 + 2 * a + y, farbe);
            End;
            c := c DIV 2;
        End;
    End;
End;

Procedure writecharbold(x, y, size: integer; ch: char);
Var
    a, b, f, c: integer;
Begin
    If size = 8 Then f := 1 Else
    If size = 16 Then f := 2 Else
    If size = 12 Then f := 3;
    For a := 1 To ord (font[f, 2]) Do
    Begin
        c := 128;
        For b := 1 To ord (font[f, 1]) Do
        Begin
            If (ord (font[f, ord (ch) * ord (font[f, 2]) + 2 + a]) AND c) <> 0 Then
            Begin
                putpixel (x + b, a + y, farbe);
                putpixel (x + b + 1, a + y, farbe);
            End;
            c := c DIV 2;
        End;
    End;
End;

Procedure writetextxy(x, y, size: integer; txt: string);
Var
    a, f: integer;
Begin
    If size = 8 Then f := 1 Else
    If size = 16 Then f := 2 Else
    If size = 12 Then f := 3;
    For a := 1 To length (txt) Do
    Begin
        writechar (x, y, size, txt[a]);
        x := x + ord (font[f, 1]);
    End;
End;

Procedure writetextxyslanted(x, y, size: integer; txt: string);
Var
    a, f: integer;
Begin
    If size = 8 Then f := 1 Else
    If size = 16 Then f := 2 Else
    If size = 12 Then f := 3;
    For a := 1 To length (txt) Do
    Begin
        writecharslanted (x, y, size, txt[a]);
        x := x + ord (font[f, 1]);
    End;
End;

Procedure writetextxybold(x, y, size: integer; txt: string);
Var
    a, f: integer;
Begin
    If size = 8 Then f := 1 Else
    If size = 16 Then f := 2 Else
    If size = 12 Then f := 3;
    For a := 1 To length (txt) Do
    Begin
        writecharbold (x + a, y, size, txt[a]);
        x := x + ord (font[f, 1]);
    End;
End;

Procedure writetextxydouble(x, y, size: integer; txt: string);
Var
    a, f: integer;
Begin
    If size = 8 Then f := 1 Else
    If size = 16 Then f := 2 Else
    If size = 12 Then f := 3;
    For a := 1 To length (txt) Do
    Begin
        writechardouble (x + (a - 1) * size, y, size, txt[a]);
        x := x + ord (font[f, 1]);
    End;
End;

Procedure writetextxydoublebold(x, y, size: integer; txt: string);
Var
    a, f: integer;
Begin
    If size = 8 Then f := 1 Else
    If size = 16 Then f := 2 Else
    If size = 12 Then f := 3;
    For a := 1 To length (txt) Do
    Begin
        writechar2bold (x + (a - 1) * size, y, size, txt[a]);
        x := x + ord (font[f, 1]);
    End;
End;


Begin
    graphinit;
    loadfont ('norm');
    clearviewport;
    writetextxy (40, 50, 12, 'FONT 6x12: normal');
    writetextxy (40, 70, 8, 'FONT 8x8: normal');
    writetextxy (40, 90, 16, 'FONT 8x16: normal');
    writetextxybold (40, 120, 12, 'FONT 6x12 bold');
    writetextxybold (40, 140, 8, 'FONT 8x8 bold');
    writetextxybold (40, 160, 16, 'FONT 8x16 bold');
    writetextxyslanted (40, 190, 12, 'FONT 6x12 slanted');
    writetextxyslanted (40, 210, 8, 'FONT 8x8 slanted');
    writetextxyslanted (40, 230, 16, 'FONT 8x16 slanted');
    writetextxydouble (40, 260, 12, 'FONT 6x12 double');
    writetextxydouble (40, 290, 8, 'FONT 8x8 double');
    writetextxydouble (40, 320, 16, 'FONT 6x16 double');
    writetextxydoublebold (40, 360, 12, 'FONT 6x12 doublebold');
    writetextxydoublebold (40, 390, 8, 'FONT 8x8 doublebold');
    writetextxydoublebold (40, 420, 16, 'FONT 8x16 doublebold');

    writetextxy (300, 150, 16, 'Taste 2 mal drÅcken fÅr mehr...');

    farbe := 1;
    uli := 'Was man damit alles machen kann...';
    ch  := #0;
    Repeat
        x := 40;
        For a := 1 To length (uli) Do
        Begin
            writechar2bold (x, 12, 16, uli[a]);
            inc (farbe);
            If (uli[a] = ' ') Then dec (farbe);
            If (farbe MOD 16 = 0) Then inc (farbe);
            inc (x, 16);
        End;
        If (keypressed) Then ch := readkey
    Until (ch <> #0);
    ch := #0;
    Repeat
        ch := readkey;
    Until (ch <> #0);
    clearviewport;
    farbe := 13;
    writetextxy (10, 2, 8, 'Hallo Peo... GrÅ·e von Uli!!');
    inc (farbe);
    x := 10;
    y := 0;
    For a := 0 To 255 Do
    Begin
        x := x + 70;
        str (a: 3, uli);
        uli := uli + ' = ' + chr (a);
        If (a MOD 9) = 0 Then
        Begin
            x := 10;
            y := y + 16;
        End;
        writetextxy (x, y, 16, uli);
    End;
    uli := chr (2) + ' 1993/94/95 by Ulrich Franzke / Bochum / Germany';
    farbe := 10;
    writetextxy (332, 468, 12, uli);
    Repeat
        ch := readkey;
    Until (ch <> #0);
    clearviewport;
    graphclose;
End.
