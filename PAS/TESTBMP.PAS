Program TestBMP;

Uses LoadBMP;

Var B: PBMP16;
    I, J: Word;
Begin
    Asm
        mov  ax,0012h
        int  10h
    End;
    B := New (PBMP16, Load ('TITLE.BMP'));
    B^.Display (0, 0);
    ReadLn;
    B^.Done;
    Asm
        mov  ax,0003h
        int  10h
    End;
End.
