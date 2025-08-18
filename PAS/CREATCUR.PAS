Program CreateCur;

Const CurFile = 'CURSOR.SHP';

Const CursorXSize = 9;
    CursorYSize = 13;

Type TCurImg = Array[0..CursorYSize] Of Word;
Type TImg = Record
        XSize, YSize: Word;
        Data: TCurImg;
    End;

Var Pic: TImg;
    F: File;
    i, j, k: Integer;
    Pfeil: Integer;

Procedure SetCurPix(X, Y: Integer; S: Boolean; Var P: TCurImg);
Begin
    If s Then
        P[Y] := P[y] OR (1 SHL X)
    Else
        P[Y] := P[y] AND NOT (1 SHL X);
End;

Begin
    Pic.XSize := CursorXSize + 1;
    Pic.YSize := CursorYSize + 1;
    FillChar (Pic.Data, SizeOf (Pic.Data), 0);

    pfeil := CursorXSize DIV 2 + 2;
    For j := 0 To CursorYSize - pfeil Do
        For i := CursorXSize DIV 2 - 2 To CursorXSize DIV 2 + 2 Do
            SetCurPix (i, j, True, Pic.Data);
    For j := CursorYSize - pfeil + 1 To CursorYSize - 1 Do
    Begin
        k := j - CursorYSize + pfeil - 1;
        For i := k To CursorXSize - 1 - k Do
            SetCurPix (i, j, True, Pic.Data);
    End;
    Assign (F, CurFile);
    ReWrite (F, 1);
    BlockWrite (F, Pic, SizeOf (Pic));
End.
