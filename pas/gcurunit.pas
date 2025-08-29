{$I RNS.H}

Unit gcurunit;

Interface

Uses graph,
    xcrt,
    crt,
    Mousdrv;

Const CursorXSize = 9;
    CursorYSize = 13;
    CurGridXStep = 6;
    CurGridYStep = 8;
    CurGridXS = 640 DIV CurGridXStep;
    CurGridYS = 424 DIV CurGridYStep;

Type CursorArr = Array[0..CursorXSize, 0..CursorYSize] Of word;

Var PatternSave, GraphCursor: CursorArr;
    gcxcoord, gcycoord: integer;
    dispcurs: byte; {1= display cursor, 2 = display cursor and grid
                     3= dont display cursor}
    CurGridX: Array[1..CurGridXS] Of Word;
    CurGridY: Array[1..CurGridYS] Of word;

Procedure GcuCursorClear;{Clear saved patterns}
Procedure GcuIniCursor;{Clear saved patterns+create cursor shape}
Procedure GcuMoveCursor(x, y: integer);{move cursor w/o draw}
Procedure GcuPatternRestore;{hide cursor}
Procedure GcuCursorRestore;{draw cursor}
Function GcuRightMargin: integer;{zero}
Procedure GcuPatternStore;{save pattern}

Implementation

Uses initsc;

Var CursorIsOn: Boolean;
{**************************************************************}
Function GcuRightMargin: integer;
Begin
    GcuRightMargin := 0;
End;
{**************************************************************}
Procedure MinMax(Var imin, imax, jmin, jmax: integer);
Begin
    imax := gcxcoord + (CursorXSize DIV 2);
    imin := gcxcoord - (CursorXSize DIV 2);
    jmax := gcycoord + (CursorYSize DIV 2) - 1;
    jmin := gcycoord - (CursorYSize DIV 2) - 1;
    If imin > grmaxx Then
    Begin
        imin := grmaxx - (cursorxsize DIV 2);
        imax := imin + cursorXSize;
    End;
    If jmin > grmaxy Then
    Begin
        jmin := grmaxy - (cursorysize DIV 2);
        jmax := +cursorySize;
    End;
End;

{**************************************************************}
Function GcuGridPosX(i: integer): integer;
Var a: integer;
Begin
    a := grminx - 2 + i * curgridxstep;
    If (a > grmaxx) OR (a < 1) Then
        a := 4;
    GcuGridPosX := a;
End;
{**************************************************************}
Function GcuGridPosY(i: integer): integer;
Var a: Integer;
Begin
    a := grminy - 5 + i * curgridystep;
    If (A > grmaxY) OR (a < 2) Then
        a := 3;
    GcuGridPosY := a;
End;

{**************************************************************}
Procedure GcuPatternStore;
Var i, j, imin, imax, jmin, jmax: integer;
    b: Boolean;
Begin
    b := NOT istdunkel;
    If b Then mausdunkel;
    MinMax (imin, imax, jmin, jmax);

    For j := jmin To jmax Do
        For i := imin To imax Do
            PatternSave[i - imin, j - jmin] := GetPixel (i, j);

    If dispcurs = 2 Then
    Begin
        For i := 1 To curgridxs Do
            If Page[gcycoord DIV linethick - 1, 1] <> 'N' Then
                curgridx[i] := GetPixel (GcuGridPosX (i), jmin - 1);
        For i := 1 To curgridys Do
            curgridy[i] := GetPixel (gcxcoord, GcuGridPosY (i));
    End;
    If b Then mauszeigen;
End;

{**************************************************************}
Procedure GcuCursorClear;
Var i, j, imin, imax, jmin, jmax: integer;
Begin
    MinMax (imin, imax, jmin, jmax);
    For j := jmin To jmax Do
        For i := imin To imax Do
            PatternSave[i - imin, j - jmin] := bkcolor;
    If dispcurs = 2 Then
    Begin
        For i := 1 To curgridxs Do
            curgridx[i] := bkcolor;
        For i := 1 To curgridys Do
            curgridy[i] := bkcolor;
    End;
End;

{**************************************************************}
Procedure GcuPatternRestore;
Var i, j, imin, imax, jmin, jmax: integer;
    b: Boolean;
Begin
    If NOT CursorIsOn Then
        Exit;
    CursorIsOn := False;
    b := NOT istdunkel;
    If b Then mausdunkel;
    MinMax (imin, imax, jmin, jmax);
    For j := jmin To jmax Do
        For i := imin To imax Do
            PutPixel (i, j, PatternSave[i - imin, j - jmin]);
    If dispcurs = 2 Then
    Begin
        For i := 1 To curgridxs Do
            If Page[gcycoord DIV linethick - 1, 1] <> 'N' Then
                PutPixel (GcuGridPosX (i), jmin - 1, curgridx[i]);
        For i := 1 To curgridys Do
            PutPixel (gcxcoord, GcuGridPosY (i), curgridy[i]);
    End;
    If b Then mauszeigen;
End;

{**************************************************************}
Procedure GcuDrawCursor;

Var i, j, imin, imax, jmin, jmax, icorr, jcorr: integer;
    b: Boolean;
Begin
    b := NOT istdunkel;
    If b Then mausdunkel;
    If NOT CursorisOn Then
        GcuPatternStore;
    CursorIsOn := True;
    If ((NOT xKeyPressed) AND (dispcurs < 3)) Then
    Begin
        MinMax (imin, imax, jmin, jmax);
        For j := jmin To jmax Do
            For i := imin To imax Do
                If (i > 1) AND (j > 1) AND (i < GetmaxX) AND (j < GetmaxY - 56) Then
                    PutPixel (i, j, GraphCursor[i - imin, jmax - j]);
        If dispcurs = 2 Then
        Begin
            For i := 1 To curgridxs Do
                If Page[gcycoord DIV linethick - 1, 1] <> 'N' Then
                    PutPixel (GcuGridPosX (i), jmin - 1, gridcolor);
            For i := 1 To curgridys Do
                PutPixel (gcxcoord, GcuGridPosY (i), gridcolor);
        End;
    End Else If (dispcurs < 3) Then
    Begin
        MinMax (imin, imax, jmin, jmax);
        For i := imin + 2 To imax - 2 Do
            If (i > 1) AND (jmin > 1) AND (i < GetmaxX)
                AND (jmin < GetmaxY - 56) Then
                PutPixel (i, jmin, GraphCursor[CursorXSize SHR 1, CursorYSize SHR 1]);
    End;
    If b Then mauszeigen;
End;

{**************************************************************}
Procedure GcuMoveCursor(x, y: integer);
Begin
    gcxcoord := x;
    gcycoord := y;
End;

{**************************************************************}
Procedure GcuCursorRestore;
Begin
    GcuMoveCursor (gcxcoord, gcycoord);
    GcuDrawCursor;
End;

{**************************************************************}
Procedure GcuIniCursor;
Var i, j, k, pfeil: integer;
Begin
    {initialisiere Cursor-Bild}
    For i := 0 To CursorYSize Do
        For j := 0 To CursorXSize Do
            GraphCursor[j, i] := bkcolor;
    For i := 1 To curgridxs Do
        curgridx[i] := bkcolor;
    For i := 1 To curgridys Do
        curgridy[i] := bkcolor;
    { Pfeil malen }
    pfeil := CursorXSize DIV 2 + 2;
    For j := 0 To CursorYSize - pfeil Do
        For i := CursorXSize DIV 2 - 2 To CursorXSize DIV 2 + 2 Do
            GraphCursor[i, j] := curcolor;
    For j := CursorYSize - pfeil + 1 To CursorYSize - 1 Do
    Begin
        k := j - CursorYSize + pfeil - 1;
        For i := k To CursorXSize - 1 - k Do
            GraphCursor[i, j] := curcolor;
    End;
End;

Begin
    dispcurs := 1;
    CursorIsOn := False;
End.
