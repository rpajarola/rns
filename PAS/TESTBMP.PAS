Program TestBMP;

Uses LoadBMP;

Var B : PBMP16;
    I,J : Word;
Begin
  Asm
    MOV  AX,0012h
    INT  10h
  End;
  B:=New(PBMP16,Load('TITLE.BMP'));
  B^.Display(0,0);
  ReadLn;
  B^.Done;
  Asm
    MOV  AX,0003h
    INT  10h
  End;
End.