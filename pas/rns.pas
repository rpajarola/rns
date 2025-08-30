{$I RNS.H}
Program Rns(Input, Output);

Uses Graph,
    crt,
    Dos,
    initsc,
    UserInt,
    EditUnit,
    menutyp,
    helpunit,
    userexit;

{*******************************************************}
{*******************************************************}
Function HeapFunc(Size: word): integer;
Begin
    HeapFunc := 1;
End;

Procedure InstallUserDrivers;
Begin
    If RegisterBGIDriver (@EGAVGADriverProc) < 0 Then
    Begin
        WriteLn ('Error loading graphics driver');
        Halt ($FE);
    End;
End;

{**************************RNS Main**************************}
Begin
    InstallUserDrivers;
    IniIniColors;
    UseTopMenu;
    TextBackground (black);
    TextColor (white);
    ClrScr;
End.
