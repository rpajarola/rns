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
    // TODO: Modern heap error handling
    // Original: Heaperror:= @HeapFunc;
    Assign (Buffile, 'Buffer');
    Assign (debfile, 'Debfile');
    Rewrite (debfile);
    If ioresult <> 0 Then
    Begin filemode := 0;
        reset (debfile);
        filemode := 2;
    End;

    IniIniColors;

    UseTopMenu;
    TextBackground (black);
    TextColor (white);
    ClrScr;
    Close (debfile);
End.
