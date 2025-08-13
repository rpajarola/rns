Program CreateCur;

Const CurFile = 'CURSOR.SHP';

Const CursorXSize  = 9;
      CursorYSize  = 13;

Type TCurImg = Array[0..CursorYSize] Of Word;
Type TImg = Record
       XSize,YSize : Word;
       Data        : TCurImg;
     End;

Var Pic   : TImg;
    F     : File;
    i,j,k : Integer;
    Pfeil : Integer;

Procedure SetCurPix(X,Y : Integer;S : Boolean;Var P : TCurImg);
Begin
  IF s Then
    P[Y]:=P[y] Or (1 Shl X)
  Else
    P[Y]:=P[y] And Not (1 Shl X);
End;

Begin
  Pic.XSize:=CursorXSize+1;
  Pic.YSize:=CursorYSize+1;
  FillChar(Pic.Data,SizeOf(Pic.Data),0);

  pfeil:= CursorXSize div 2 + 2;
  for j:= 0 to CursorYSize - pfeil do
    for i:= CursorXSize div 2 - 2  to CursorXSize div 2 + 2 do
      SetCurPix(i,j,True,Pic.Data);
  for j:= CursorYSize - pfeil + 1 to CursorYSize - 1 do begin
    k:= j - CursorYSize + pfeil - 1;
    for i:= k to CursorXSize - 1 - k do
      SetCurPix(i,j,True,Pic.Data);
  end;
  Assign(F,CurFile);
  ReWrite(F,1);
  BlockWrite(F,Pic,SizeOf(Pic));
End.