{$I RNS.H}

Unit dmemunit;

Interface

Uses
    graph,
    initsc;

Procedure DmePlaceWord(x, y: integer; w: word);
Procedure DmeDispChar(x, y: integer; c: char; blnum: integer);

Implementation

Uses
    helpunit;

{******************************************************************}
Procedure DmeDispChar(x, y: integer; c: char; blnum: integer);

Var
    i: integer;
    muster: word;

Begin
    If ((x >= 0) AND (y > 1) AND (x <= gmaxx) AND (y < (gmaxy - 1))) Then
        For i := 1 To 15 Do
        Begin
            muster := symarr[c, i, blnum];
            If y - 8 + i <= grmaxy Then
                DmePlaceWord (x - 7, y - 8 + i, muster);
        End;
End;

{******************************************************************}
Procedure DmePlaceWord(x, y: integer; w: word);

Var
    acolor: byte;
    i: integer;
    bitval: word;
    pixelx: integer;

Begin
    acolor := getcolor;
    { Modern Pascal replacement for assembly bit manipulation }
    bitval := w;
    For i := 0 To 15 Do
    Begin
        If (bitval AND $8000) <> 0 Then { Test highest bit }
        Begin
            pixelx := x + i;
            If (pixelx > 1) AND (pixelx < 639) Then
                PutPixel (pixelx, y, acolor);
        End;
        bitval := bitval SHL 1; { Shift left for next bit }
    End;
End;

End.
