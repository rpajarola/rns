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

Type TImg = Record
        XSize, YSize: Word;
        Planes: Array[0..3] Of Pointer;
    End;

Type TCurImg = Array[0..CursorYSize] Of Word;
Type TCursor = Object
        X, Y: Word;
        V: Boolean;
        MinX, MaxX, MinY, MaxY: Word;
        CursorShape, BackGround, XGrids, YGrids: TImg;
        OrgCurShape, EmptyCurShape: Pointer;
        PatSave: Boolean;
        Constructor Init;        { Create cursor shape, clear patterns... }
        Destructor Done;         { Hide cursor, dispose of patterns...    }
        Procedure ReSet; Virtual; { Reset backgrounds, reload shape...     }
        Procedure Show; Virtual;  { draw cursor on screen, save patterns...}
        Procedure Hide; Virtual;  { hide cursor, (restore patterns)        }
        Function Visible: Boolean;{ no comment                           }
        Procedure Move(aX, aY: Word);{ move to pos X,Y, draw if visible   }
        Procedure LoadCursor;    { Load Cursor shape from CURSOR.SHP      }
        Procedure SavePat(X0, Y0, XS, YS: Word; Var I: TImg);{ Save Pattern }
        Procedure DrawPat(X0, Y0: Word; I: TImg);{ Draw Pattern           }
    End;

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

Function MemNeed(X, Y: Word): Word;
Begin
    If (X AND 7) = 0 Then
        MemNeed := (X DIV 8) * Y
    Else
        MemNeed := ((X DIV 8) + 1) * Y;
End;

Procedure DisposeImg(p: TImg);
Var a: Byte;
Begin
    For a := 0 To 3 Do FreeMem (p.Planes[a], MemNeed (p.xsize, p.ysize));
End;

Constructor TCursor.Init;        { Create cursor shape, clear patterns... }
Var a: Byte;
Begin
    LoadCursor;
    BackGround.XSize := CursorShape.XSize;
    BackGround.YSize := CursorShape.YSize;
    XGrids.XSize := 1;
    XGrids.YSize := 480;
    YGrids.XSize := 640;
    YGrids.YSize := 1;
    For a := 0 To 3 Do
    Begin
        GetMem (BackGround.Planes[a], MemNeed (BackGround.XSize, BackGround.YSize));
        FillChar (BackGround.Planes[a]^, MemNeed (BackGround.XSize, BackGround.YSize), 0);
        GetMem (XGrids.Planes[a], MemNeed (XGrids.XSize, XGrids.YSize));
        FillChar (XGrids.Planes[a], MemNeed (XGrids.XSize, XGrids.YSize), 0);
        GetMem (YGrids.Planes[a], MemNeed (YGrids.XSize, YGrids.YSize));
        FillChar (YGrids.Planes[a], MemNeed (YGrids.XSize, YGrids.YSize), 0);
    End;
End;
Destructor TCursor.Done;         { Hide cursor, dispose of patterns...    }
Begin
    Hide;
    DisposeImg (CursorShape);
    DisposeImg (BackGround);
    DisposeImg (XGrids);
    DisposeImg (YGrids);
End;
Procedure TCursor.ReSet;        { Reset backgrounds, reload shape...     }
Var a: Byte;
Begin
    Hide;
    DisposeImg (CursorShape);
    LoadCursor;
    For a := 0 To 3 Do
    Begin
        FillChar (BackGround.Planes[a]^, MemNeed (BackGround.XSize, BackGround.YSize), 0);
        FillChar (XGrids.Planes[a], MemNeed (XGrids.XSize, XGrids.YSize), 0);
        FillChar (YGrids.Planes[a], MemNeed (YGrids.XSize, YGrids.YSize), 0);
    End;
    Show;
End;
Procedure TCursor.Show;          { draw cursor on screen, save patterns...}
Begin
    If NOT V Then
    Begin
        V := True;
        If PatSave Then
            SavePat (X, Y, BackGround.XSize, BackGround.YSize, BackGround);
        DrawPat (X, Y, CursorShape);
    End;
End;
Procedure TCursor.Hide;          { hide cursor, (restore patterns)        }
Begin
    If V Then
    Begin
        V := False;
        DrawPat (X, Y, BackGround);
    End;
End;
Function TCursor.Visible: Boolean;{ no comment                           }
Begin
    Visible := V;
End;
Procedure TCursor.Move(aX, aY: Word);{ move to pos X,Y, draw if visible     }
Begin
    If V Then
    Begin
        Hide;
        X := aX;
        Y := aY;
        Show;
    End Else Begin
        X := aX;
        Y := aY;
    End;
End;
Procedure TCursor.LoadCursor;    { Load Cursor shape from CURSOR.SHP      }
Var F: File;
    a: Byte;
Begin
    Assign (F, 'CURSOR.SHP');
    System.ReSet (F, 1);
    BlockRead (F, CursorShape, 4);
    GetMem (OrgCurShape, MemNeed (CursorShape.XSize, CursorShape.YSize));
    GetMem (EmptyCurShape, MemNeed (CursorShape.XSize, CursorShape.YSize));
    BlockRead (F, OrgCurShape^, MemNeed (CursorShape.XSize, CursorShape.YSize));
    FillChar (EmptyCurShape^, MemNeed (CursorShape.XSize, CursorShape.YSize), 0);
    For a := 0 To 3 Do
        If CurColor AND (1 SHL a) <> 0 Then
            CursorShape.Planes[a] := OrgCurShape
        Else
            CursorShape.Planes[a] := EmptyCurShape;
End;
Procedure TCursor.SavePat(X0, Y0, XS, YS: Word; Var I: TImg); Assembler;{ Save Pattern }
{TImg = Record
  XSize,YSize : Word;
  Planes      : Array[0..3] Of Pointer;
End;}
Asm
(*  MOV  DX,03CEh
  MOV  AL,08   { Pixel mask     }
  MOV AH,Mask*)
End;
Procedure TCursor.DrawPat(X0, Y0: Word; I: TImg); Assembler;{ Draw Pattern }
Asm
End;

Begin
    dispcurs := 1;
    CursorIsOn := False;
End.
