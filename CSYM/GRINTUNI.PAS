unit grintunit;

interface

Uses menutyp,
     graphmenu,
     grinout,
     imenuunit,
     initsc,
     dos,
     graph,
     crt;


Procedure GriSymbolParam(charind: integer; c: char);

implementation

{******************************************************}
Procedure GriSymbolParam(charind: integer; c: char);

var
    Bufstr : string79;
    i, j, mxmin, xmin, xmax, y, hy : integer;
    cresp: char;

begin
   ImeInitCharMenu(c);
   With UsrMenu do
   begin
      For i:= 1 to 3 do
      begin
         ChoiceVal[4 * (i - 1) + 1].Ival:= SymPar[c, 1, i];
         if SymPar[c, 2, i] = 2 then
         begin
            ChoiceVal[4 * (i - 1) + 2].Tval:= 2;
         end
         else
         begin
            ChoiceVal[4 * (i - 1) + 2].Tval:= 1;
         end;

         ChoiceVal[4 * (i - 1) + 3].Ival:= SymPar[c, 3, i];
         ChoiceVal[4 * (i - 1) + 4].Ival:= SymPar[c, 4, i];
      end;

      xmin:= leftx - symboldx div 2 + 2;
      mxmin:= xmin div charwidth + 1;
      xmax:= 2 * (GMaxX div 3) + leftx + 15 * symboldx + symboldx div 2 - 2;
      y:= grmaxy - (num_choices * spacing +
          menuattr.firstline + 4) * charheight;
      hy:= y div charheight;
      GrDisplay_Frame(xmin, y, xmax, grmaxy, barfill, true, true);
      GrDisplay_Menu(mxmin, hy, barfill, UsrMenu);
      GrGet_Menu_Values(mxmin, hy, hfmaxy, barfill, UsrMenu, cresp);
      For i:= 1 to 3 do
      begin
         SymPar[c, 1, i]:= ChoiceVal[4 * (i - 1) + 1].Ival;
         if ChoiceVal[4 * (i - 1) + 2].Tval = 2 then
         begin
            SymPar[c, 2, i]:= 2;
         end
         else
         begin
            SymPar[c, 2, i]:= 1;
         end;
         SymPar[c, 3, i]:= ChoiceVal[4 * (i - 1) + 3].Ival;
         SymPar[c, 4, i]:= ChoiceVal[4 * (i - 1) + 4].Ival;
      end;
   end;
end;

end.
