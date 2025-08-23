{$I-}

Unit Textfont;

Interface

Const sz8x8 = 0;    { Sizes }
    sz8x16 = 1;
    sz6x12 = 2;
    stNormal = $00;
    stBold = $01;
    stDouble = $02;
    stItalic = $04;
    stUndeline = $08;
    stHigh = $10;
    stLow = $20;

Type TTextFont = Array[0..2, 1..4200] Of char;
    PTextFontViewer = ^TTextFont;
    TTextFontViewer = Object
        Font: TTextFont;
        Constructor Init(Name: String);
        Destructor Done; Virtual;
        Procedure WriteChar(X, Y: Word; Ch: Char; Color: Byte; Size: Integer;
            Style: Byte); Virtual;
        Procedure Write(X, Y: Word; St: String; Color: Byte; Size: Integer;
            Style: Byte);
    End;

Implementation

Uses Graph;

Constructor TTextFontViewer.Init(Name: String);
Var
    fnttab: Array[0..2] Of string[82];
    a, b: integer;
    datei: File Of char;
    fs: longint;
    ch: char;
Begin
    fnttab[0] := name + '8X8.TFT'; {RNS8X8.TFT}
    fnttab[1] := name + '8X16.TFT'; {RNS8X16.TFT}
    fnttab[2] := name + '6X12.TFT'; {RNS8X12.TFT}
    For a := 0 To 2 Do
    Begin
        assign (datei, fnttab[a]);
        reset (datei);
        If IOResult <> 0 Then
        Begin
            WriteLn ('Error: Cannot open font file: ', fnttab[a]);
            WriteLn ('Make sure the font file exists in the current directory.');
            Halt (2); { Exit with file not found error code }
        End;
        ch := #0;
        b  := 0;
        While (ch <> #26) Do
        Begin
            read (datei, ch);
            If IOResult <> 0 Then
            Begin
                WriteLn ('Error: Cannot read from font file: ', fnttab[a]);
                close (datei);
                Halt (100); { Exit with disk read error }
            End;
            inc (b);
        End;
        fs := filesize (datei) - b;
        For b := 1 To fs Do
        Begin
            read (datei, ch);
            If IOResult <> 0 Then
            Begin
                WriteLn ('Error: Cannot read font data from: ', fnttab[a]);
                close (datei);
                Halt (100); { Exit with disk read error }
            End;
            font[a, b] := ch;
        End;
        close (datei);
    End;
End;

Destructor TTextFontViewer.Done;
Begin
End;

Procedure TTextFontViewer.WriteChar(X, Y: Word; Ch: Char; Color: Byte; Size: Integer; Style: Byte);
{ stNormal stBold stDouble stItalic stUndeline stHigh stLow }
Var
    a, b, f, c, charstart, xmin, xmax, ymin, ymax: integer;

Begin
    {  if (Style and stItalic)<>0 then x:=x+6;}
    If size = sz8x8 Then dec (Y, 9) Else If size = sz8x16 Then dec (Y, 9) Else If size = sz6x12 Then dec (Y, 7);
    charstart := Byte (ch) * Byte (font[size, 2]) + 3;
    xmin := x + 1;
    xmax := x + Byte (font[size, 1]);
    ymin := y + 1;
    ymax := y + Byte (font[size, 2]);
    For a := ymin To ymax Do
    Begin
        {    if ((Style and stItalic)<>0) and ((a and 1)<>0) then dec(x);}
        c := 128;
        f := Byte (font[size, charstart]);
        For b := xmin To xmax Do
        Begin
            If (f AND c) <> 0 Then
                If (Style AND stDouble) = 0 Then
                Begin
                    PutPixel (b, a, Color);
                    If (Style AND stBold) <> 0 Then
                    Begin
                        PutPixel (b + 1, a, Color);
                        If (Style AND stDouble) <> 0 Then
                        Begin
                            PutPixel (b, a + 1, Color);
                            PutPixel (b + 1, a + 1, Color);
                        End;
                    End;
                End Else Begin
                    PutPixel (2 * b, 2 * a, Color);
                    If (Style AND stBold) <> 0 Then
                    Begin
                        PutPixel (2 * b + 1, 2 * a, Color);
                        If (Style AND stDouble) <> 0 Then
                        Begin
                            PutPixel (2 * b, 2 * a + 1, Color);
                            PutPixel (2 * b + 1, 2 * a + 1, Color);
                        End;
                    End;
                End;
            c := c SHR 1;
        End;
        inc (charstart);
    End;
End;

Procedure TTextFontViewer.Write(X, Y: Word; St: String; Color: Byte; Size: Integer; Style: Byte);
Var
    a, dx: integer;
Begin
    dx := Byte (font[size, 1]);
    If size = sz8x16 Then
        inc (dx);
    If (style AND stdouble) <> 0 Then
        dx := dx + Byte (font[size, 1]) - 1;
    For a := 1 To length (St) Do
    Begin
        writechar (x, y, St[a], color, size, style);
        x := x + dx;
    End;
End;


End.
${I+}