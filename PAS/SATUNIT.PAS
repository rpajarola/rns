unit satunit;

interface

Uses menutyp,
     graphmenu,
     grinout,
     imenuunit,
     initsc,
     dos,
     graph,
     fileunit,
     crt,
     helpunit,
     UserExit;


Procedure SatSymbolParam(c: char);
Procedure SatSaveSym;

implementation
{******************************************************}
Procedure SatSaveSym;

var c:char;
     i, j : byte;
     parfile : file of integer;
begin
   assign(parfile,'SYMBOLS.PAR');
   LastFileName:=FExpand('SYMBOLS.PAR');
   reset(parfile);
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
{   instring:= fontfile;
   Delete(instring, length(instring) - 3, 4);
   instring:= instring + '.PAR';
   FilCopyFile('symbols.par',instring);}
end;

{******************************************************}
Procedure SatSymbolParam(c: char);

var
    i, y, hy : integer;

begin
   ImeInitCharMenu(c);
   With UsrMenu do
   begin
      For i:= 1 to 3 do
      begin
         ChoiceVal[2 * (i - 1) + 1].Ival:= SymPar[c, 3, i];
         ChoiceVal[2 * (i - 1) + 2].Ival:= SymPar[c, 4, i];
      end;

      y:= stabymax - (num_choices * spacing +
          menuattr.firstline + 8) * charheight;
      hy:= y div charheight{ + 1};
      GrDisplay_Frame(stabxmin - 4, y, stabxmax + 4, stabymax - 29,
                      true, true);
      Line(stabxmin-4,stabymax-28,stabxmax+4,stabymax-28);
      GrDisplay_Menu(sxmin + 1, hy, UsrMenu, 0);
      GrGet_Menu_Values(sxmin + 1, hy, symax - 3, UsrMenu, c);
      For i:= 1 to 3 do
      begin
         SymPar[c, 3, i]:= ChoiceVal[2 * (i - 1) + 1].Ival;
         SymPar[c, 4, i]:= ChoiceVal[2 * (i - 1) + 2].Ival;
      end;
   end;
end;

end.


