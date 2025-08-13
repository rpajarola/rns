Unit ScrSave;

Interface

Uses Graph;

Procedure SaveScreen;

Implementation
{$Q-,R-}
Function LineY(X : Integer;A,B : Real) : Integer;
Begin
  LineY:=Round((X*A)+B);
End;
Function KeyPressed : Boolean;
InLine($31/$C0/         { XOR  AX,AX    }
       $8E/$C0/         { MOV  ES,AX    }
       $26/             { ES:           }
       $A1/$041A/       { MOV  AX,[41A] }
       $26/             { ES:           }
       $33/$06/$041C);  { XOR  AX,[41C] }
Procedure SaveScreen;
Type TImageLine = Record
       XR,YR    : Word;
       Line     : Array[0..3,0..79] Of Byte;
    End;
Var I     : TImageLine;
    a     : Word;
    c     : LongInt;
    L     : LongInt;
    T     : Array[0..3] OF Byte Absolute L;

Begin
  SetColor(15);
  Randomize;
  I.XR:=639;
  I.YR:=0;
  a:=Random(15);
  if a=0 then
    inc(a);
  FillChar(i.line[0],sizeof(i.line[0]),$FF*byte((a and 1)=1));
  FillChar(i.line[1],sizeof(i.line[1]),$FF*byte((a and 2)=2));
  FillChar(i.line[2],sizeof(i.line[2]),$FF*byte((a and 4)=4));
  FillChar(i.line[3],sizeof(i.line[3]),$FF*byte((a and 8)=8));
  a:=0;
  While Not KeyPressed Do Begin
    For c:=0 To $FFFF do;
    PutImage(0,a,I,XorPut);
    Inc(a);
    if a>GetMaxY then begin
      a:=Random(15);
      if a=0 then
        inc(a);
      FillChar(i.line[0],sizeof(i.line[0]),$FF*byte((a and 1)=1));
      FillChar(i.line[1],sizeof(i.line[1]),$FF*byte((a and 2)=2));
      FillChar(i.line[2],sizeof(i.line[2]),$FF*byte((a and 4)=4));
      FillChar(i.line[3],sizeof(i.line[3]),$FF*byte((a and 8)=8));
      a:=0;
    end;
  End;
  Asm
    XOR AX,AX
    INT 16h
  End;
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