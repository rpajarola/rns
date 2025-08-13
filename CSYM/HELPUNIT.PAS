unit helpunit;

interface

uses Graph,
     GcurUnit,
     Dmemunit,
     Graphmenu,
     Dispmenu,
     inout,
     menutyp,
     Crt,
     InitSc;

Procedure HlpSymbolTable;
Procedure HlpSymbolEdit;

implementation

uses
     symbols,
     grinout;

{******************************************************}
Procedure HlpSymbolEdit;

const xmin = 20;
      xmax = 60;
      ymin = 8;
      ymax = 15;

var c: char;

begin
   IniGraphClose;
   ClrScr;
   Display_Frame(xmin, ymin - 4, xmax, ymax, true, false);
   Put_Centered_String(' Edit symbols keys ',ymin - 2, 0);
   Put_String(xmin + 2, ymin, 'Spacebar  ', 1);
   Put_String(xmin + 15, ymin, 'Toggle pixel', 0);
   Put_String(xmin + 2, ymin + 1, 'Tab       ', 1);
   Put_String(xmin + 15, ymin + 1, 'Next group', 0);
   Put_String(xmin + 2, ymin + 2, '<Shift>Tab', 1);
   Put_String(xmin + 15, ymin + 2, 'Last group', 0);
   Put_String(xmin + 2, ymin + 3, 'F2        ', 1);
   Put_String(xmin + 15, ymin + 3, 'Symbol parameter', 0);
   Put_String(xmin + 2, ymin + 4, 'F3        ', 1);
   Put_String(xmin + 15, ymin + 4, 'Play ', 0);

   repeat
      c:= ReadKey;
   until c = chr(27);
   IniGraphMode;
end;

{******************************************************}
Procedure HlpSymbolTable;

var y, i, blnum : integer;

begin
   ClearViewPort;
   GrDisplay_Frame(stabxmin, stabymin, stabxmax, stabymax,
                   emptyfill, false, false);
   GrDisplay_Menu(sxmin, symin, emptyfill, SymbolMenu1);
   GrDisplay_Menu(sxmax div 2, symin, emptyfill, SymbolMenu2);
   for i:= 1 to 13 do
   begin
      y:= stabymin + SymbolMenu1.menuattr.firstline * CharHeight +
          6 + i*2*CharHeight;
      for blnum:= 1 to 3 do
      begin
         DmeDispChar(stabxmin + 130 + blnum * 25, y,
                     SymbolMenu1.choices[i], blnum);
         DmeDispChar(stabxmax div 2 + 130 + blnum * 25,
                     y, SymbolMenu2.choices[i], blnum);
      end;
   end;
end;

end.
