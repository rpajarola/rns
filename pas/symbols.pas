{$I RNS.H}

Unit symbols;

Interface

Uses
    InitSc;

Const
    topy = 60;
    klammerrad = 3;

Type
    xfirsttyp = Array[1..3] Of integer;

Procedure SymAbsNichts(x, y: integer);
Procedure SymNichts(ix, iy: integer; x: real);
Procedure SymLeer(ix, iy: integer; x: real);
Procedure Beat(x, y, beatlength: integer; solidb: boolean);
Procedure Mainline(x0, y0, x1: integer; thickness: real);
Procedure Thinline(x0, y0, x1: integer);
Procedure SymInvisibleLine(x0, y0, x1: integer);
Procedure SymDottedLine(x0, y0, x1: integer);
Procedure SymStaffLine(x0, y0, x1: integer);
Procedure DistanceMark(x0, y0, x1: real; xfirst, GridNum: integer);
Procedure Slash(ix, iy: integer; x: real);
Procedure SymDotSlash(ix, iy: integer; x: real);
Procedure SymDotSlash2(ix, iy: integer; x: real);
Procedure SymClearChar(x, y: integer);
Procedure SymVKlammerEnd(x, y: integer);
Procedure SymVKlammerStart(x, y: integer);
Procedure SymVKlammerCont(x, y: integer);
Procedure SymVKlammerEvenMid(x, y: integer);
Procedure SymVKlammerOddMid(x, y: integer);
Procedure SymHKlammerEnd(x, y: integer);
Procedure SymHKlammerStart(x, y: integer);
Procedure SymHKlammerNormMid(x, y: integer);
Procedure SymHKlammerSmallMid(x, y: integer);
Procedure SymNorKlammerAuf(x, y, height: integer);
Procedure SymNorKlammerZu(x, y, height: integer);
Procedure SymEckKlammerAuf(x, y, height: integer);
Procedure SymEckKlammerZu(x, y, height: integer);
Procedure SymTabSymbol(x, y: integer);
Procedure SymTabSymbolDown(x, y: integer);
Procedure SymGKlammerAuf(x, y, height: integer);
Procedure SymGKlammerZu(x, y, height: integer);
Procedure SymEt(ix, iy: integer; x: real);
Procedure SymQuotMark(ix, iy: integer; x: real);
Procedure SymRepQuotMark(ix, iy: integer; x: real);

Implementation

Uses
    Helpunit,
    Dmemunit,
    Graphmenu,
    Graph,
    GcurUnit,
    RnsIni,
    Printunit;

{******************************************************************}
Procedure SymTabSymbol(x, y: integer);
{Zeichnen eines Tabulatorzeichens}
Begin
    If RnsSetup.DispSpec = 1 Then
    Begin
        putpixel (x + 1, y - 3, speccolor);
        putpixel (x + 2, y - 2, speccolor);
        putpixel (x + 1, y - 1, speccolor);
        putpixel (x + 2, y - 2, speccolor);
    End;
End;

{******************************************************************}
Procedure SymTabSymbolDown(x, y: integer);
{Zeichnen eines umbgekehrten Tabulatorzeichens}
Begin
    If (RnsSetup.DispSpec = 1) Then
    Begin
        putpixel (x + 1, y - 4, speccolor);
        putpixel (x + 2, y - 3, speccolor);
        putpixel (x + 3, y - 2, speccolor);
        putpixel (x + 1, y, speccolor);
        putpixel (x + 2, y - 1, speccolor);
        putpixel (x + 3, y - 2, speccolor);
    End;
End;

{******************************************************************}
Function SymKlammerRadius(x: integer): real;

Begin
    SymKlammerRadius := PriXScale (x + klammerrad) - PriXScale (x);
End;

                                                                              {
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
Procedure SymNorKlammerAuf(x, y, height: integer);

Begin
    If height < 0 Then
    Begin
        height := -height + charheight;
        y := y + height - (charheight DIV 2);
    End;
    If PrinterOn Then
    Begin
        PriSetLineWidth (0.5{pswidth});
        PriNewPath;
        PriArc (PriXScale (x + klammerrad), PriYScale (y - height + 2),
            SymKlammerRadius (x), 180.0, 120.0, 'n');
        PriDrawLine (x, y - height + 2, x, y + 3);
        PriArc (PriXScale (x + klammerrad), PriYScale (y + 3),
            SymKlammerRadius (x), 180.0, 240.0, ' ');
    End Else
    Begin
        PutPixel (x + 1, y - height + 1, lcolor);
        Line (x, y - height + 2, x, y + 3);
        PutPixel (x + 1, y + 4, lcolor);
    End;
End;

                                                                              {
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

Procedure SymNorKlammerZu(x, y, height: integer);

Begin
    If height < 0 Then
    Begin
        height := -height;
        y := y + height;
    End;
    If PrinterOn Then
    Begin
        PriSetLineWidth (0.5{pswidth});
        PriNewPath;
        PriArc (PriXScale (x - klammerrad), PriYScale (y - height + 2),
            SymKlammerRadius (x), 0.0, 60.0, ' ');
        PriDrawLine (x, y - height + 2, x, y + 3);
        PriArc (PriXScale (x - klammerrad), PriYScale (y + 3),
            SymKlammerRadius (x), 0.0, 300.0, 'n');
    End Else
    Begin
        PutPixel (x - 1, y - height + 1, lcolor);
        Line (x, y - height + 2, x, y + 3);
        PutPixel (x - 1, y + 4, lcolor);
    End;
End;

                                                                              {
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

Procedure SymEckKlammerAuf(x, y, height: integer);

Begin
    If height < 0 Then
    Begin
        height := -height;
        y := y + height;
    End;
    If PrinterOn Then
    Begin
        PriSetLineWidth (0.5{pswidth});
        PriNewPath;
        PriDrawLine (x, y - height, x + 1, y - height); {- oben}
        PriDrawLine (x, y - height, x, y + 5); {›}
        PriDrawLine (x, y + 5, x + 1, y + 5);  {- unten}
    End Else
    Begin
        PutPixel (x + 1, y - height + 1, lcolor);
        Line (x, y - height + 1, x, y + 4);
        PutPixel (x + 1, y + 4, lcolor);
    End;
End;

                                                                              {
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}

Procedure SymEckKlammerZu(x, y, height: integer);

Begin
    If height < 0 Then
    Begin
        height := -height;
        y := y + height;
    End;
    If PrinterOn Then
    Begin
        PriSetLineWidth (0.5{pswidth});
        PriNewPath;
        PriDrawLine (x, y - height, x - 1, y - height); {- oben}
        PriDrawLine (x, y - height, x, y + 5); {›}
        PriDrawLine (x, y + 5, x - 1, y + 5);  {- unten}
    End Else
    Begin
        PutPixel (x - 1, y - height + 1, lcolor);
        Line (x, y - height + 1, x, y + 4);
        PutPixel (x - 1, y + 4, lcolor);
    End;
End;

{******************************************************************}
Procedure SymHKlammerNormMid(x, y: integer);
Var
    ac: Byte;
Begin
    ac := GetColor;
    PutPixel (x - 2, y + 4, ac);
    PutPixel (x - 1, y + 4, ac);
    PutPixel (x - 1, y + 5, ac);
    PutPixel (x, y + 5, ac);
    PutPixel (x, y + 6, ac);
    PutPixel (x + 1, y + 5, ac);
    PutPixel (x + 1, y + 4, ac);
    PutPixel (x + 2, y + 4, ac);
    PutPixel (x, y + 4, getbkcolor);
    Line (x - 4, y + 4, x - 2, y + 4);
    Line (x + 2, y + 4, x + 4, y + 4);
End;

{******************************************************************}
Procedure SymHKlammerSmallMid(x, y: integer);
Var
    ac: byte;
Begin
    ac := getcolor;
    PutPixel (x + 2, y + 4, ac);
    PutPixel (x + 1, y + 4, ac);
    PutPixel (x + 1, y + 5, ac);
    PutPixel (x, y + 5, ac);
    PutPixel (x, y + 6, ac);{ 87921            }
    PutPixel (x - 1, y + 5, ac);{  643             }
    PutPixel (x - 1, y + 4, ac);{   5              }
    PutPixel (x - 2, y + 4, ac);
    PutPixel (x, y + 4, GetBkColor);
End;


Procedure SymHKlammerStart(x, y: integer);

Var
    ac: byte;
Begin
    ac := getcolor;
    PutPixel (x + 1, y + 2, ac);
    PutPixel (x, y + 1, ac);
    PutPixel (x + 2, y + 2, ac);
    PutPixel (x + 1, y + 1, ac);
    PutPixel (x, y, ac);

    PutPixel (x + 2, y + 2, ac);
    PutPixel (x + 3, y + 2, ac);
    PutPixel (x + 4, y + 2, ac);
    PutPixel (x + 5, y + 2, ac);
    PutPixel (x + 6, y + 2, ac);
    PutPixel (x + 7, y + 2, ac);
End;

{******************************************************************}
Procedure SymHKlammerEnd(x, y: integer);

Var
    ac: byte;

Begin
    ac := getcolor;
    PutPixel (x + 3, y + 4, ac);
    PutPixel (x + 4, y + 3, ac);
    PutPixel (x + 2, y + 4, ac);
    PutPixel (x + 3, y + 3, ac);
    PutPixel (x + 4, y + 2, ac);

    PutPixel (x - 3, y + 4, ac);
    PutPixel (x - 2, y + 4, ac);
    PutPixel (x - 1, y + 4, ac);
    PutPixel (x, y + 4, ac);
    PutPixel (x + 1, y + 4, ac);
    PutPixel (x + 2, y + 4, ac);
End;

{******************************************************************}
Procedure SymVKlammerEvenMid(x, y: integer);

Var
    ac: byte;
Begin
    {   Inc(x,7);}
    ac := getcolor;
    PutPixel (x + 1, y - 2, ac);
    PutPixel (x + 1, y - 1, ac);
    PutPixel (x, y - 1, ac);
    PutPixel (x, y, ac);
    PutPixel (x - 1, y, ac);
    PutPixel (x, y + 1, ac);
    PutPixel (x + 1, y + 1, ac);
    PutPixel (x + 1, y + 2, ac);
    Line (x + 1, y - 7, x + 1, y - 2);
    Line (x + 1, y + 2, x + 1, y + 7);
End;

{******************************************************************}
Procedure SymVKlammerOddMid(x, y: integer);

Var
    ac: byte;
Begin
    ac := GetColor;
    PutPixel (x + 1, y - 2, ac);
    PutPixel (x + 1, y - 1, ac);
    PutPixel (x, y - 1, ac);
    PutPixel (x, y, ac);
    PutPixel (x - 1, y, ac);
    PutPixel (x, y + 1, ac);
    PutPixel (x + 1, y + 1, ac);
    PutPixel (x + 1, y + 2, ac);
    PutPixel (x + 2, y - 1, GetBkColor);
    Line (x + 1, y - 1, x + 1, y - 7);
    Line (x + 1, y + 1, x + 1, y + 7);
End;

{******************************************************************}
Procedure SymVKlammerCont(x, y: integer);

Begin
    Inc (x, 7);
    Line (x + 1, y - line2thick, x + 1, y + line2thick - 1);
End;

{******************************************************************}
Procedure SymVKlammerStart(x, y: integer);

Var
    ac: byte;

Begin
    ac := getcolor;
    Inc (x, 3);
    PutPixel (x + 1, y + line2thick, ac);
    PutPixel (x + 1, y + line2thick + 1, ac);
    PutPixel (x + 1, y + line2thick + 2, ac);
    PutPixel (x + 1, y + line2thick + 3, ac);
    PutPixel (x + 1, y + line2thick + 4, ac);
    PutPixel (x + 1, y + line2thick + 5, ac);
    PutPixel (x + 1, y + line2thick + 6, ac);

    PutPixel (x + 1, y + line2thick, ac);
    PutPixel (x + 2, y + line2thick, ac);
    PutPixel (x + 2, y + line2thick - 1, ac);
    PutPixel (x + 3, y + line2thick - 1, ac);
End;

{******************************************************************}
Procedure SymVKlammerEnd(x, y: integer);

Var
    ac: byte;
Begin
    ac := getcolor;
    PutPixel (x + 1, y - 10, ac);
    PutPixel (x + 1, y - 9, ac);
    PutPixel (x + 1, y - 8, ac);
    PutPixel (x + 1, y - 7, ac);
    PutPixel (x + 1, y - 6, ac);
    PutPixel (x + 1, y - 5, ac);

    PutPixel (x + 1, y - 4, ac);
    PutPixel (x + 2, y - 4, ac);
    PutPixel (x + 2, y - 3, ac);
    PutPixel (x + 3, y - 3, ac);
End;

{******************************************************************}
Procedure ClearLine(x0, y0, x1: integer);

Begin
    SetColor (BkColor);
    Line (x0, y0 + 1, x1, y0 + 1);
    SetColor (LColor);
End;

{******************************************************************}
Procedure SymClearChar(x, y: integer);

Var
    i: integer;

Begin
    For i := 1 To 16 Do
        ClearLine (x - 7, y - 9 + i, x + 8);
End;


{******************************************************************}
Procedure Mainline(x0, y0, x1: integer; thickness: real);

Begin
    If PrinterOn Then
    Begin
        PriSetLineWidth (thickness);
        x0 := x0 - 1;
        If x0 < 0 Then
            x0 := 0;
        PriDrawLine (x0, y0, x1, y0);
    End
    Else
    Begin
        SetLineStyle (SolidLn, 0, 1);
        Line (x0, y0, x1, y0);
    End;
End;

{******************************************************************}
Procedure DistanceMark(x0, y0, x1: real; xfirst, GridNum: integer);

Var
    xloc, lxloc: integer;
    iy0: integer;
    rx, rdx: real;
    i: integer;
Begin
    If (GridNum < 1) OR (RnsSetup.DispGrid = 1) Then
        Exit;
    iy0 := round (y0);
    y0  := y0 - 1;
    dec (iy0);
    xloc := round (x0);
    rdx := (x1 - x0) / GridNum;
    rx := x0;
    If PrinterOn Then
    Begin
        While (rx < x1) AND (rx < xfirst) Do
            rx := rx + rdx;
        While rx < x1 Do
        Begin
            PriSetLineWidth (grwidth);
            PriNewPath;
            PriMove (PriRXscale (rx), PriRYscale (y0 + 1.0));        { Gridhîhe }
            PriLine (PriRXscale (rx), PriRYscale (y0 - 0.3{0.5}));   { Gridhîhe }
            PriStroke;
            rx := rx + rdx;
        End;
    End Else
    Begin
        If rdx < 2 Then
            rdx := 2;
        i := 1;
        While (xloc < x1) AND (xloc < xfirst) Do
        Begin
            inc (i);
            rx := rx + rdx;
            If Gridnum > 0 Then
                xloc := trunc (rx);
        End;
        lxloc := xloc;
        While (xloc < x1) AND (i <= gridnum) Do
        Begin
            If ((GetPixel (xloc - 1, iy0) <> GetColor) AND
                (GetPixel (xloc + 1, iy0) <> GetColor)) Then
            Begin
                inc (i);
                PutPixel (xloc, iy0, lcolor);
                inc (lxloc, 2);
            End Else
                inc (lxloc);
            While xloc < lxloc Do
            Begin
                rx := rx + rdx;
                If Gridnum > 0 Then
                    xloc := trunc (rx);
                lxloc := xloc;
            End;
        End;
    End;
End;

{******************************************************************}
Procedure Thinline(x0, y0, x1: integer);
Begin
    If PrinterOn Then
    Begin
        PriSetLineWidth (tnwidth);
        PriDrawLine (x0 - 1, y0, x1, y0);
    End Else
    Begin
        SetLineStyle (4, $AAAA, 1);
        Line (x0, y0, x1, y0);
        SetLineStyle (SolidLn, 0, 1);
    End;
End;

{******************************************************************}
Procedure SymDottedLine(x0, y0, x1: integer);

Begin
    If PrinterOn Then
    Begin
        PriSetLineWidth (dtwidth);
        PriSetDash (dtwidth, 2.0);
        PriDrawLine (x0 - 1, y0, x1, y0);
        PriReSetDash;
    End Else
    Begin
        SetLineStyle (4, $4444, 1);
        Line (x0, y0, x1, y0);
        SetLineStyle (SolidLn, 0, 1);
    End;
End;

{******************************************************************}

Procedure SymStaffLine(x0, y0, x1: integer);

Var
    i: Byte;
Begin
    If PrinterOn Then
    Begin
        PriSetLineWidth (piwidth);
        For i := 0 To 4 Do
        Begin
            PriNewPath;
            PriMove (PriRXscale (x0 - 1), PriRYscale (y0 - i * 5));
            PriLine (PriRXscale (x1), PriRYscale (y0 - i * 5));
            PriStroke;
            {      PriDrawLine(x0, y0-i*5, x1, y0-i*5);}
        End;
    End Else
    Begin
        SetLineStyle (4, $AAAA, 1);
        For i := 0 To 4 Do
            Line (x0, y0 - i * 5, x1, y0 - i * 5);
        SetLineStyle (SolidLn, 0, 1);
    End;
End;

{******************************************************************}
Procedure SymInvisibleLine(x0, y0, x1: integer);

Var
    oldcolor: byte;

Begin
    If RnsSetup.DispHidLines = 2 Then
        Exit;
    If NOT printeron Then
    Begin
        oldcolor := GetColor;
        SetColor (helplinecolor);
        SetLineStyle (4, $AAAA, 1);
        Line (x0, y0, x1, y0);
        SetLineStyle (SolidLn, 0, 1);
        SetColor (oldcolor);
    End;
End;

{******************************************************************}
Procedure SymNichts(ix, iy: integer; x: real);
Begin
    If PrinterOn Then
    Begin
        PriSetLineWidth (niwidth);
        PrirDrawLine (x, iy, x, iy - 2);  {-3}
    End Else
    Begin
        ClearLine (ix, iy, ix);
        Line (ix, iy, ix, iy - 2);       {-3}
    End;
End;

{******************************************************************}

Procedure SymAbsNichts(x, y: integer);
Begin
    If X > 638 Then
        Exit;
    ClearLine (x, y, x);
    If RnsSetup.DispSpec = 1 Then
        PutPixel (x, y - 4, speccolor);
End;

{******************************************************************}
Procedure SymLeer(ix, iy: integer; x: real);
Begin
    If PrinterOn Then
    Begin
        PriSetLineWidth (lswidth);
        PrirDrawLine (x, iy + 3, x, iy - 3);
    End Else
        Line (ix, iy + 3, ix, iy - 3);
End;

{******************************************************************}

Procedure Beat(x, y, beatlength: integer; solidb: boolean);

Var
    dy: integer;
Begin
    dy := 6;
    If PrinterOn Then
    Begin
        PriSetLineWidth (bewidth);
        PriDrawLine (x, y + dy, x, y - beatlength);
    End
    Else
    Begin
        If solidb Then
            SetLineStyle (SolidLn, 0, 1)
        Else
            SetLineStyle (4, $AAAA, 1);
        Line (x, y + dy, x, y - beatlength);
        SetLineStyle (SolidLn, 0, 1);
    End;
End;

{******************************************************************}
Procedure Slash(ix, iy: integer; x: real);
Begin
    If PrinterOn Then
    Begin
        PriSetLineWidth (0.5);
        PrirDrawLine (x - 7, iy + 7, x + 7, iy - 7);
    End
    Else
    Begin
        SetLineStyle (SolidLn, 0, 1);
        Line (ix - 7, iy + 7, ix + 7, iy - 7);
        SetLineStyle (SolidLn, 0, 1);
    End;
End;

{******************************************************************}
Procedure SymDotSlash(ix, iy: integer; x: real); {neu als: SymDotBkSlash}
Begin
    If RnsSetup.DispSlash = 2 Then
        exit;
    If PrinterOn Then
    Begin
        PriSetLineWidth (0.5);
        PrirDrawLine (x - 3, iy - 8, x + 3, iy + 8);
    End Else
    Begin
        SetLineStyle (SolidLn, 0, 1);

        Line (ix - 4, iy - 8, ix - 4, iy - 8);
        Line (ix - 3, iy - 6, ix - 3, iy - 6);
        Line (ix - 2, iy - 4, ix - 2, iy - 4);
        Line (ix - 1, iy - 2, ix - 1, iy - 2);

        Line (ix + 1, iy + 2, ix + 1, iy + 2);
        Line (ix + 2, iy + 4, ix + 2, iy + 4);
        Line (ix + 3, iy + 6, ix + 3, iy + 6);
        Line (ix + 4, iy + 8, ix + 4, iy + 8);

        SetLineStyle (SolidLn, 0, 1);
    End;
End;

{******************************************************************}
Procedure SymDotSlash2(ix, iy: integer; x: real);
Begin
    If RnsSetup.DispSlash = 2 Then
        exit;
    If PrinterOn Then
    Begin
        PriSetLineWidth (0.5);
        PriSetDash (3.0, 1.0);
        PrirDrawLine (x - 8, iy + 8, x + 8, iy - 8);
        PriReSetDash;
    End Else
    Begin
        SetLineStyle (4, $BBBB, 1);
        Line (ix - 8, iy + 8, ix + 8, iy - 8);
        SetLineStyle (SolidLn, 0, 1);
    End;
End;

{******************************************************************}

Procedure SymGKlammerAuf(x, y, height: integer);

Begin
    If PrinterOn Then
    Begin
        PriSetLineWidth (0.5{pswidth});
        PriNewPath;
        PriArc (PriXScale (x + klammerrad), PriYScale (y - height + 2),
            SymKlammerRadius (x), 180.0, 120.0, 'n');
        PriDrawLine (x, y - height + 2, x, y - 1); {›}
        PriDrawLine (x, y - 1, x - 1, y); {/}
        PriDrawLine (x - 1, y, x, y + 1); {\}
        PriDrawLine (x, y + 1, x, y + 3); {›}
        PriArc (PriXScale (x + klammerrad), PriYScale (y + 3),
            SymKlammerRadius (x), 180.0, 240.0, ' ');
    End Else
    Begin
        PutPixel (x + 1, y - height + 1, lcolor);
        Line (x, y - height + 2, x, y - 1);
        PutPixel (x - 1, y, lcolor);
        Line (x, y + 1, x, y + 3);
        PutPixel (x + 1, y + 4, lcolor);
    End;
End;

{******************************************************************}

Procedure SymGKlammerZu(x, y, height: integer);

Begin
    If PrinterOn Then
    Begin
        PriSetLineWidth (0.5{pswidth});
        PriNewPath;
        PriArc (PriXScale (x - klammerrad), PriYScale (y - height + 2),
            SymKlammerRadius (x), 0.0, 60.0, ' ');
        PriDrawLine (x, y - height + 2, x, y - 1);
        PriDrawLine (x, y - 1, x + 1, y); {/}
        PriDrawLine (x + 1, y, x, y + 1); {\}
        PriDrawLine (x, y + 1, x, y + 3);
        PriArc (PriXScale (x - klammerrad), PriYScale (y + 3),
            SymKlammerRadius (x), 0.0, 300.0, 'n');
    End Else
    Begin
        PutPixel (x - 1, y - height + 1, lcolor);
        Line (x, y - height + 2, x, y - 1);
        PutPixel (x + 1, y, lcolor);
        Line (x, y + 1, x, y + 3);
        PutPixel (x - 1, y + 4, lcolor);
    End;
End;

{******************************************************************}

Procedure SymEt(ix, iy: integer; x: real);
Const
    yofs = 6;
    blen = 1;
Begin
    If PrinterOn Then
    Begin
        PriSetLineWidth (3);
        PrirDrawLine (x - 1.5, iy - 6, x + 1.5, iy - 6);
    End Else
    Begin
        line (ix - 1, iy - 7, ix + 1, iy - 7);
        line (ix - 1, iy - 6, ix + 1, iy - 6);
        line (ix - 1, iy - 5, ix + 1, iy - 5);
    End;
End;

{******************************************************************}

Procedure SymQuotMark(ix, iy: integer; x: real);
Const
    yofs = 6;
    blen = 1;
Begin
    If PrinterOn Then
    Begin
        PriSetLineWidth (1);
        PrirDrawLine (x - 1.2, iy - 7, x - 1.2, iy - 3); {stimmt ev. noch nicht ganz!}
        PrirDrawLine (x + 1.4, iy - 7, x + 1.4, iy - 3);
    End Else
    Begin
        line (ix - 2, iy - 7, ix - 2, iy - 3);
        line (ix - 1, iy - 7, ix - 1, iy - 3);
        line (ix + 1, iy - 7, ix + 1, iy - 3);
        line (ix + 2, iy - 7, ix + 2, iy - 3);       {dick, oberhalb der Linie}
    End;
End;

{******************************************************************}

Procedure SymRepQuotMark(ix, iy: integer; x: real);
Begin
    If PrinterOn Then
    Begin
        PriSetLineWidth (1);
        PrirDrawLine (x, iy - 3, x, iy - 5);
    End Else
        line (ix, iy - 3, ix, iy - 5){dÅnn, auf der Linie};
End;

End.
