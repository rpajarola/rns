unit symbols;

interface

uses Graph,
     GcurUnit,
     Dmemunit,
     Graphmenu,
     InitSc;

const
    topy = 60;
    hordy = 3;

type xfirsttyp = array[1..3] of integer;

Procedure SymDispCharMenu(var blnum: integer; c : char);
Procedure SymCursorMoveDown;
Procedure SymCursorMoveUp;
Procedure SymCursorMoveRight(var blnum: integer);
Procedure SymCursorMoveLeft(var blnum: integer);
Procedure SymToggleBit(blnum: integer; c : char);
Procedure SymClearChar(x, y: integer);
Procedure SymCursorTab(var blnum: integer);
Procedure SymCursorBackTab(var blnum: integer);

implementation

uses Helpunit,
     Printunit;

{******************************************************************}
procedure ClearLine( x0, y0, x1 : integer);

begin
   SetColor(menubkColor);
   Line(x0, y0 + 1, x1, y0 + 1);
   SetColor(menutextcolor);
end;

{******************************************************************}
Function SymExp2(x: integer) : word;

var w: word;
    b: byte;

begin
   w:= 1;
   b:= 0;
   while b < x do
   begin
      w:= w + w;
      b:= b + 1;
   end;
   SymExp2:= w;
end;

{******************************************************************}
Function SymMoxelYPos(y : integer) : integer;

begin
   SymMoxelYPos:= y - symboldy + 2;
end;

{******************************************************************}
Procedure SymComputeXfirst(var x : xfirsttyp);

begin
   x[1]:= leftx;
   x[2]:= (GMaxX div 3) + leftx;
   x[3]:= 2 * (GMaxX div 3) + leftx;
end;

{******************************************************************}
Procedure SymDispExamples(blnum : integer; c : char);

var i, x, y, x2: integer;
    muster : word;
    xfirst: xfirsttyp;

begin
   {Schreiben der Beispielsymbole}
   SymComputeXfirst(xfirst);
   x2:= symboldx div 2;
   y:= topy + x2 + 17*symboldy + 1;
   for i:= 0 to 2 do
   begin
      x:= xfirst[blnum] + symboldx + i * 6 * symboldx;
      SymClearChar(x, y);
      DmeDispChar(x, y, c, blnum);
   end;

   Line(xfirst[blnum] - x2, y, xfirst[blnum] + 12*symboldx, y);
   x:= xfirst[blnum] + 14 * symboldx;
   Line(x, y, x + symboldx + x2, y);
   Line(xfirst[blnum] + symboldx, y + 7,
        xfirst[blnum] + symboldx, y - 14);
end;

{******************************************************************}
Procedure SymToggleBit(blnum: integer; c : char);

var i, x, y : integer;
    muster : word;
    mask : word;
    xfirst : xfirsttyp;

begin
   SymComputeXfirst( xfirst);
   x:= gcxcoord - xfirst[blnum];

   y:= (gcycoord - topy) div symboldy;
   x:= x div symboldx;

   muster:= symarr[c, y, blnum];
   mask:= SymExp2(x);
   mask:= 32768 div mask;
   if muster and mask = 0 then
   begin
      DmePutFilledMoxel(gcxcoord, SymMoxelYPos(gcycoord));
      symarr[c, y, blnum]:= muster or mask;
   end
   else
   begin
      DmePutEmptyMoxel(gcxcoord, SymMoxelYPos(gcycoord));
      mask:= not mask;
      symarr[c, y, blnum]:= muster and mask;
   end;

   {Schreiben der Beispielsymbole}
   SymDispExamples(blnum, c);
end;

{******************************************************************}
Procedure SymCursorBackTab(var blnum: integer);

var x: integer;
    xfirst: xfirsttyp;

begin
   SymComputeXfirst(xfirst);
   if blnum > 1 then
   begin
      blnum:= blnum - 1;
   end;
   x:= xfirst[blnum];
   GcuMoveCursor(x, gcycoord);
end;

{******************************************************************}
Procedure SymCursorTab(var blnum: integer);

var x: integer;
    xfirst: xfirsttyp;

begin
   SymComputeXfirst(xfirst);
   if blnum < 3 then
   begin
      blnum:= blnum + 1;
   end;
   x:= xfirst[blnum];
   GcuMoveCursor(x, gcycoord);
end;

{******************************************************************}
Procedure SymCursorMoveLeft(var blnum: integer);

var x: integer;
    xfirst: xfirsttyp;

begin
   SymComputeXfirst(xfirst);
   x:= gcxcoord - symboldx;
   if ((blnum > 1) and (gcxcoord = xfirst[blnum])) then
   begin
       x:= xfirst[blnum - 1] + 15 * symboldx;
       blnum:= blnum - 1;
   end;
   if gcxcoord = xfirst[1] then x:= xfirst[1];
   GcuMoveCursor(x, gcycoord);
end;

{******************************************************************}
Procedure SymCursorMoveRight(var blnum: integer);

var x: integer;
    xfirst: xfirsttyp;

begin
   SymComputeXfirst(xfirst);
   x:= gcxcoord + symboldx;
   if ((blnum < 3) and (gcxcoord = xfirst[blnum] + 15 * symboldx)) then
   begin
       x:= xfirst[blnum + 1];
       blnum:= blnum + 1;
   end;
   if (gcxcoord = xfirst[3] + 15 * symboldx)  then
       x:= xfirst[3] + 15 * symboldx;
   GcuMoveCursor(x, gcycoord);
end;

{******************************************************************}
Procedure SymCursorMoveUp;

var y: integer;

begin
   if (SymMoxelYPos(gcycoord) > topy + symboldy) then
      y:= gcycoord - symboldy
   else y:= gcycoord;
   GcuMoveCursor(gcxcoord, y);
end;

{******************************************************************}
Procedure SymCursorMoveDown;

var y: integer;

begin
   if (SymMoxelYPos(gcycoord) < topy + 15*symboldy) then
       y:= gcycoord + symboldy
   else y:= gcycoord;
   GcuMoveCursor(gcxcoord, y);
end;

{******************************************************************}
Procedure SymClearChar(x, y: integer);

var i, j : integer;

begin
   for i:= 1 to 16 do
   begin
      ClearLine(x - 7, y - 9 + i, x + 8);
   end;
end;


{******************************************************************}
Procedure SymDispCharMenu(var blnum: integer; c : char);
{Zeichne den Display fr ein Character-Editiermenu}

var i, j, x, y, x0: integer;
    muster : word;
    cshifted : char;
    xfirst: xfirsttyp;

begin
   ClearViewPort;

   SymComputeXfirst(xfirst);
   cshifted:= chr(ord(c) - 32);

   {schreibe den Buchstaben gross an}
   SetTextStyle(2, 0, 5);
   SetTextJustify(0, 2);
   OutTextXY(xfirst[1], 20, c);
   OutTextXY(xfirst[2], 20, cshifted);
   OutTextXY(xfirst[3], 20, '<Alt> ' + c);
   SetTextStyle(0, 0, 1);
   SetTextJustify(0, Ttyp);

   {Zeichne die Pixel}
   for i:= 1 to 15 do
   begin
      y:= topy + i*symboldy;

      for j:= 1 to 3 do
      begin
         muster:= Symarr[c,i,j];
         DmePlaceMoxels(xfirst[j], y, muster);
      end;
   end;

   {Hebe Mittelkreise durch Pfeile hervor}
   for i:= 0 to 2 do
   begin
      x0:= i * (GetMaxX div 3);

      x:= leftx - symboldx div 2 - 1 + x0;
      y:= topy + 8*symboldy;
      DmeDrawArrow(x, y, 0);

      x:= x + 16*symboldx + 2;
      DmeDrawArrow(x, y, 1);

      x:= leftx + x0 + 7*symboldx;
      y:= topy + symboldy div 2 + 15*symboldy + 1;
      DmeDrawArrow(x, y, 2);

      y:= topy + symboldy div 2 - 1;
      DmeDrawArrow(x, y, 3);
   end;

   for j:= 1 to 3 do
   begin
      SymDispExamples(j, c);
   end;

   {Plaziere den Cursor}
   y:= SymMoxelYPos(topy + symboldy);
   GcuMoveCursor(leftx, 2 * (topy + symboldy) - y);
   blnum:= 1;
end;

end.
