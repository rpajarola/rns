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


Var
    ExitSave: pointer;

{*******************************************************}
{$IFDEF USER}
Procedure GraphExit;
Begin
    CloseGraph;
    IniShowCursor;
    ExitProc := ExitSave;
End;
{$ENDIF}
{*******************************************************}
{*******************************************************}
Function HeapFunc(Size: word): integer;
Begin
    HeapFunc := 1;
End;

Procedure InstallUserDrivers;
Begin
    TextBackGround (Black);
    ClrScr;
    TextColor (White);
    TextBackGround (Red);
    GotoXY (1, 12);
    If RegisterBGIDriver (@EGAVGADriverProc) < 0 Then
    Begin
        WriteLn ('Error loading VGA graphics driver, program halted');
        Writeln;
        WriteLn ('Reinstall RHYTHMICS from your original diskette');
        Halt ($FE);
    End;
End;

{**************************RNS Main**************************}
Begin
    If Ioresult = 0 Then;
    InstallUserDrivers;
    // TODO: Modern heap error handling
    // Original: Heaperror:= @HeapFunc;
    Assign (Buffile, 'Buffer');
    Assign (debfile, 'Debfile');
    LastFileName := FExpand ('DEBFILE');
   {$I-}
    Rewrite (debfile);
   {$I+}
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
    LastFileName := FExpand (TextRec (Debfile).Name);
    Close (debfile);
   {$I-}
End.
