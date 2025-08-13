unit userint;

interface

Uses menutyp,
     inout,
     dispmenu,
     graphmenu,
     grinout,
     imenuunit,
     initsc,
     dos,
     graph,
     symbols,
     helpunit,
     printunit,
     gcurunit,
     crt;

Procedure UseSaveSym;
Procedure UseEditSym;

implementation

uses grintunit;

const topstartx = 2;
      topstarty = 1;
      topendx = 22;
      topendy = 24;
      substartx = 24;
      substarty = 1;
      subendx = 79;
      subendy = 24;

{******************************************************}
Procedure UseSymbolMenu(c : char);

var rc : char;
    ordrc: byte;
    charind: integer;

begin
   rc:= chr(0);
   SymDispCharMenu(charind, c);
   GcuCursorRestore;
   while rc <> chr(27) do
   begin
      rc:= readkey;
      GcuPatternRestore;
      ordrc:= ord(rc);
      case ordrc of
         0 : begin
                rc:= readkey;
                ordrc:= ord(rc);

                case ordrc of
                   15: SymCursorBackTab(charind);
                   59: begin
                          HlpSymbolEdit;
                          SymDispCharMenu(charind, c);
                       end;
                   60: begin
                          GriSymbolParam(charind, c);
                          SymDispCharMenu(charind, c);
                       end;
                   61: begin
                          while rc <> chr(27) do
                          begin
                             sound(sympar[c, 3, charind]);
                             delay(sympar[c, 4, charind]);
                             nosound;
                             delay(200);
                             if keypressed then
                             begin
                                rc:= readkey;
                             end;
                          end;
                          rc:=' ';
                       end;
                   72: SymCursorMoveUp;
                   75: SymCursorMoveLeft(charind);
                   77: SymCursorMoveRight(charind);
                   80: SymCursorMoveDown;
                   94: begin
                          HardCopy24(0, false);
                       end;
                end;
             end;

         9 : SymCursorTab(charind);

        32 : SymToggleBit(charind, c);
      end; {case}
      GcuCursorRestore;
   end; { while rc <> chr(27) do }
end;


{******************************************************}
Procedure UseSymbolSelect(var c: char);

var symbolnum, choicenum : byte;
    movedir : movement;


begin
   HlpSymbolTable;

   if ord(c) <= 109 then
   begin
      symbolnum:= 1;
      choicenum:= ord(c) - 96;
   end
   else
   begin
      symbolnum:= 2;
      choicenum:= ord(c) - 109;
   end;

   repeat
      if symbolnum = 1 then
      begin
         GrDisplay_Menu(sxmin, symin, emptyfill, SymbolMenu1);
         GrGet_Menu_Response(sxmin, symin, emptyfill, SymbolMenu1, c, true,
                             movedir, choicenum);
      end
      else
      begin
         GrDisplay_Menu(sxmax div 2, symin, emptyfill, SymbolMenu2);
         GrGet_Menu_Response(sxmax div 2, symin, emptyfill,
                             SymbolMenu2, c, true,
                             movedir, choicenum);
      end;

      if ((movedir = left) or (movedir = right)) then
      begin
         symbolnum:= ord(movedir);
      end;

   until ((c = chr(27)) or ((movedir <> left) and (movedir <> right)));
end;

{******************************************************}
Procedure UseSaveSym;

var c:char;
     i, j : byte;
     outfile : file of word;
     parfile : file of integer;

begin
   assign(outfile,'Symbols.sym');
   rewrite(outfile);
   for c:= 'a' to 'z' do
   begin
      for i:= 1 to 15 do
      begin
         for j:= 1 to 3 do
         begin
            write(outfile,symarr[c,i,j]);
         end;
      end;
   end;
   close(outfile);

   assign(parfile,'Symbols.par');
   rewrite(parfile);
   for c:= 'a' to 'z' do
   begin
      for i:= 1 to numofpar do
      begin
         for j:= 1 to 3 do
         begin
            write(parfile,sympar[c, i, j]);
         end;
      end;
   end;
   close(parfile);
end;

{******************************************************}
Procedure UseEditSym;

var c: char;

begin
   c:='a';
   ClrScr;
   IniGraphInit;
   InitScreen;
   IniGetSymbols;
   setcolor(menutextcolor);
   while (c <> chr(27)) do
   begin
      UseSymbolSelect(c);
      if ((c >= 'a') and (c <= 'z')) then
      begin
         UseSymbolMenu(c);
      end;
   end;
   IniGraphClose;
end;

end.
