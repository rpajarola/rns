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
    ExitSave : pointer;

{*******************************************************}
{$IFDEF USER}
procedure GraphExit;
begin
   CloseGraph;
   IniShowCursor;
   ExitProc:= ExitSave;
end;
{$ENDIF}
{*******************************************************}
{*******************************************************}
Function HeapFunc(Size: word): integer;
begin
   HeapFunc:= 1;
end;

Procedure InstallUserDrivers;
begin
   TextBackGround(Black);
   ClrScr;
   TextColor(White);
   TextBackGround(Red);
   GotoXY(1,12);
   IF RegisterBGIDriver(@EGAVGADriverProc)<0 then begin
      WriteLn('Error loading VGA graphics driver, program halted');
      Writeln;
      WriteLn('Reinstall RHYTHMICS from your original diskette');
      Halt($FE);
   end;
end;

{**************************RNS Main**************************}
begin
   IF Ioresult=0 Then;
   InstallUserDrivers;
   // TODO: Modern heap error handling
   // Original: Heaperror:= @HeapFunc;
   Assign(Buffile,'Buffer');
   Assign(debfile,'Debfile');
   LastFileName:=FExpand('DEBFILE');
   {$I-}
   Rewrite(debfile);
   {$I+}
      if ioresult <> 0 then begin filemode:=0;
      reset(debfile);
      filemode:=2;
   end;

   IniIniColors;

   UseTopMenu;
   TextBackground(black);
   TextColor(white);
   ClrScr;
   LastFileName:=FExpand(TextRec(Debfile).Name);
   Close(debfile);
   {$I-}
end.
