Unit ScrSave;

Interface

Uses CRT, Graph;

Procedure SaveScreen;

Implementation
{$Q-,R-}
Function LineY(X: Integer; A, B: Real): Integer;
Begin
    LineY := Round ((X * A) + B);
End;
Function KeyPressed: Boolean;
Begin
    { Modern replacement for assembly keyboard buffer check }
    { Original checked BIOS keyboard buffer at 0040:001A vs 0040:001C }
    KeyPressed := CRT.KeyPressed; { Use CRT unit's KeyPressed function }
End;
Procedure SaveScreen;
Type TImageLine = Record
        XR, YR: Word;
        Line: Array[0..3, 0..79] Of Byte;
    End;
Var I: TImageLine;
    a: Word;
    c: LongInt;
    L: LongInt;
    T: Array[0..3] Of Byte Absolute L;

Begin
    SetColor (15);
    Randomize;
    I.XR := 639;
    I.YR := 0;
    a := Random (15);
    If a = 0 Then
        inc (a);
    FillChar (i.line[0], sizeof (i.line[0]), $FF * byte ((a AND 1) = 1));
    FillChar (i.line[1], sizeof (i.line[1]), $FF * byte ((a AND 2) = 2));
    FillChar (i.line[2], sizeof (i.line[2]), $FF * byte ((a AND 4) = 4));
    FillChar (i.line[3], sizeof (i.line[3]), $FF * byte ((a AND 8) = 8));
    a := 0;
    While NOT KeyPressed Do
    Begin
        For c := 0 To $FFFF Do ;
        PutImage (0, a, I, XorPut);
        Inc (a);
        If a > GetMaxY Then
        Begin
            a := Random (15);
            If a = 0 Then
                inc (a);
            FillChar (i.line[0], sizeof (i.line[0]), $FF * byte ((a AND 1) = 1));
            FillChar (i.line[1], sizeof (i.line[1]), $FF * byte ((a AND 2) = 2));
            FillChar (i.line[2], sizeof (i.line[2]), $FF * byte ((a AND 4) = 4));
            FillChar (i.line[3], sizeof (i.line[3]), $FF * byte ((a AND 8) = 8));
            a := 0;
        End;
    End;
    { Modern replacement for assembly keyboard wait }
    { Original: INT 16h with AX=0 (wait for keypress) }
    CRT.ReadKey; { Wait for a key press }
End;
{Procedure SaveScreen;
Type TImage = Record
       XR,YR    : Word;
       Reserved : Word;
       Pixel    : Word;
     End;

Var X     : Integer;
    a,b   : Real;
    i,j   : Integer;
    Image : TImage;
Begin
  Image.XR:=0;
  Image.YR:=0;
  Image.Pixel:=$FFFF;

  Randomize;
  While Not KeyPressed Do Begin
    Repeat
      a:=Random(5);
      a:=a/10;
    Until a<>0;
    b:=Random(GetMaxY);
    For x:=0 To GetMaxX do begin
      j:=LineY(X,a,b);
      if j>GetMaxX then
        j:=GetMaxX;
      For i:=0 To j do
        PutImage(x,i,image,xorput)
    End;
  End;
End;
}
End.
