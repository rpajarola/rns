Unit PrtScr;

Interface

Implementation
Uses Dos;
Var OldInt5: Procedure;
    OrgExitProc: Pointer;

Procedure NewExitProc; Far;
Begin
    SetIntVec (5, @OldInt5);
End;

Procedure NewInt5; Interrupt;
Begin
    SetColor (lcolor);
    SetBkColor (bkcolor);
    SetFillStyle (1, bottomcolor);
    Bar (1, grmaxy + 3, gmaxx, gmaxy);
    SetColor (5);
    Line (grminx, grminy, grminx, grmaxy); { ³ l}
    Line (grminx, grminy, grmaxx, grminy); { Ä o}
    Line (grmaxx, grminy + 1, grmaxx, grmaxy - 1); { ³ r }
    Inline($9C);
    OldInt5;
End;

Begin
    GetIntVec (5, @OldInt5);
    SetIntVec (5, @NewInt5);
    OrgExitProc := ExitProc;
    ExitProc := @NewExitProc;
End.
