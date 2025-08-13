{$I RNS.H}
Program Rns(Input, Output);

Uses Test86,
     Graph,
     crt,
     Dos,
     initsc,
     UserInt,
     EditUnit,
     menutyp,
     helpunit,
     userexit,
     BGIDriv,
     Undebug;


Var
    ExitSave : pointer;

{*******************************************************}
{$IFDEF USER}
procedure GraphExit;Far;
begin
   CloseGraph;
   HercGraphicsMode := false;
   IniShowCursor;
   ExitProc:= ExitSave;
end;
{$ENDIF}
{*******************************************************}
Function VGAAvail : Boolean;Assembler;
Asm
  MOV  AX,01A00h
  INT  10h       { IF VGAavail then AL=1A, otherwise it's left zero        }
End;             { Turbo Pascal treats every value different to 0 as true! }
{*******************************************************}
Function HeapFunc(Size: word): integer; Far;
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
   if not VGAAvail then begin
     WriteLn('Sorry, you need a VGA graphics adapter to run this program!');
     Halt($FF);
   end;
   IF RegisterBGIDriver(@EGAVGADriverProc)<0 then begin
      WriteLn('Error loading VGA graphics driver, program halted');
      Writeln;
      WriteLn('Reinstall RHYTHMICS from your original diskette');
      Halt($FE);
   end;
end;

{**************************RNS Main**************************}
begin
   Int3;
   LockKbd;
   IF Ioresult=0 Then;
   InstallUserDrivers;
   LockKbd;
{$IFDEF USER}
   ExitSave:= ExitProc;
   ExitProc:= @GraphExit;
{$ENDIF}
   HercGraphicsMode := false;
   Int3;
   Heaperror:= @HeapFunc;
   Assign(Buffile,'Buffer');
   Assign(debfile,'Debfile');
   LockKbd;
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
