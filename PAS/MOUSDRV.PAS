Unit Mousdrv;

Interface

Var Mausexist: boolean;
    Mausform:  byte;

Const MseOK = 1;
    MseBlock = 2;
    MseEsc  = 4;

Procedure MausInstall;
Procedure MausZeigen;
Function IstDunkel: Boolean;
Procedure MausPosition(Var cursorx, cursory, trel, tpress, mausmenu: word);
Procedure MausGrafik(mausbild: byte);
Procedure MausBereich(xmin, xmax, ymin, ymax: integer);
Procedure MausBereichAdd(xmin, xmax, ymin, ymax, mausnum: integer);
Procedure MausDunkel;
Procedure MausPressedPosition(Var cursorx, cursory: word);
Procedure MausSetXY(x, y: Word);
Procedure MausPos(Var cursorx, cursory, taste, mausmenu: Word);

Implementation

Var Dunkel: Boolean;
    mausposx, mausposy: word;

{******************************************************}
Procedure MausInstall;
Begin
    Dunkel := True;
    Mausexist := True;  // Assume mouse exists on modern systems
    Mausform := 0;
    mausposx := 0;
    mausposy := 0;
End;

{******************************************************}
Procedure MausZeigen;
Begin
    If Mausexist AND Dunkel Then
        Dunkel := False// TODO: Show mouse cursor with modern API
    ;
End;

{******************************************************}
Procedure MausDunkel;
Begin
    If Mausexist AND NOT Dunkel Then
        Dunkel := True// TODO: Hide mouse cursor with modern API
    ;
End;

{******************************************************}
Function IstDunkel: Boolean;
Begin
    IstDunkel := Dunkel;
End;

{******************************************************}
Procedure MausPosition(Var cursorx, cursory, trel, tpress, mausmenu: word);
Begin
    If Mausexist Then
    Begin
        // TODO: Get mouse position with modern API
        cursorx := mausposx;
        cursory := mausposy;
        trel := 0;
        tpress := 0;
        mausmenu := 0;
    End
    Else
    Begin
        cursorx := 0;
        cursory := 0;
        trel := 0;
        tpress := 0;
        mausmenu := 0;
    End;
End;

{******************************************************}
Procedure MausGrafik(mausbild: byte);
Begin
    // TODO: Set mouse cursor shape with modern API
    Mausform := mausbild;
End;

{******************************************************}
Procedure MausBereich(xmin, xmax, ymin, ymax: integer);
Begin
    // TODO: Set mouse movement bounds with modern API
End;

{******************************************************}
Procedure MausBereichAdd(xmin, xmax, ymin, ymax, mausnum: integer);
Begin
    // TODO: Add mouse region with modern API
End;

{******************************************************}
Procedure MausPressedPosition(Var cursorx, cursory: word);
Begin
    // TODO: Get mouse press position with modern API
    cursorx := mausposx;
    cursory := mausposy;
End;

{******************************************************}
Procedure MausSetXY(x, y: Word);
Begin
    // TODO: Set mouse position with modern API
    mausposx := x;
    mausposy := y;
End;

{******************************************************}
Procedure MausPos(Var cursorx, cursory, taste, mausmenu: Word);
Begin
    // TODO: Get complete mouse state with modern API
    cursorx := mausposx;
    cursory := mausposy;
    taste := 0;
    mausmenu := 0;
End;

End.
