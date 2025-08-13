program csym(input, output);

uses Graph,
     UserInt,
     menutyp,
     initsc,
     imenuunit,
     helpunit,
     crt;

Var
    ExitSave : pointer;

{*******************************************************}
{$F+}procedure GraphExit; {$F-}
begin
   CloseGraph;
   HercGraphicsMode := false;
   {$I-}
   Close(Outfile);
   {$I+}
   ExitProc:= ExitSave;
end;

{*******************************************************}

begin
   ExitSave:= ExitProc;
   ExitProc:= @GraphExit;
   HercGraphicsMode := false;
   ImeInitMenus;
   UseEditSym;
   UseSaveSym;
   ClrScr;
end.
