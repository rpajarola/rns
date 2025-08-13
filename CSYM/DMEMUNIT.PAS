unit dmemunit;

interface

uses dos,
     graph,
     initsc;

Procedure DmePlaceMoxels(x,y : integer; w : word);
Procedure DmePlaceWord(x,y : integer; w : word);
Procedure DmeDrawSquare(xmin, ymin, xmax, ymax : integer);
Procedure DmeDrawArrow(x, y, dirarrow : integer);
procedure DmePutemptyMoxel( x, y : integer);
procedure DmePutFilledMoxel( x,y : integer);
Procedure DmeDispChar(x, y: integer; c : char; blnum: integer);

implementation

{******************************************************************}
Procedure DmeDispChar(x, y: integer; c : char; blnum: integer);

var i, j : integer;
    muster : word;

begin
   for i:= 1 to 15 do
   begin
      muster:= symarr[c, i, blnum];
      DmePlaceWord(x - 7, y - 8 + i , muster);
   end;
end;

{******************************************************************}
Procedure DmePlaceWord(x,y : integer; w : word);

begin
   if (w and 32768) > 0 then putpixel(x, y, menutextcolor);
   if (w and 16384) > 0 then putpixel(x+1, y, menutextcolor);
   if (w and 8192) > 0 then putpixel(x+2, y, menutextcolor);
   if (w and 4096) > 0 then putpixel(x+3, y, menutextcolor);
   if (w and 2048) > 0 then putpixel(x+4, y, menutextcolor);
   if (w and 1024) > 0 then putpixel(x+5, y, menutextcolor);
   if (w and 512) > 0 then putpixel(x+6, y, menutextcolor);
   if (w and 256) > 0 then putpixel(x+7, y, menutextcolor);
   if (w and 128) > 0 then putpixel(x+8, y, menutextcolor);
   if (w and 64) > 0 then putpixel(x+9, y, menutextcolor);
   if (w and 32) > 0 then putpixel(x+10, y, menutextcolor);
   if (w and 16) > 0 then putpixel(x+11, y, menutextcolor);
   if (w and 8) > 0 then putpixel(x+12, y, menutextcolor);
   if (w and 4) > 0 then putpixel(x+13, y, menutextcolor);
   if (w and 2) > 0 then putpixel(x+14, y, menutextcolor);
   if (w and 1) > 0 then putpixel(x+15, y, menutextcolor);
end;

{**********************************}
procedure ClearLine( x0, y0, x1, y1: integer);

var i: integer;

begin
   SetColor(menubkcolor);
   for i:= y0 to y1 do
   begin
      Line(x0, i, x1, i);
   end;
   SetColor(menutextcolor);
end;

{************************************************************}
procedure DmePutEmptyMoxel( x, y : integer);
begin
   ClearLine(x - 5, y - 5, x + 5, y + 5);
   SetLineStyle( SolidLn, 0, 1);
   Line(X-5, y+5, X+5, y+5);
   Line(X-5, y-5, X+5, y-5);
   Line(X-5, y+5, X-5, y-5);
   Line(X+5, y+5, X+5, y-5);
{  Circle( x, y, 4);   }
end;

{**************************************************************}
procedure DmePutFilledMoxel( x,y : integer);

var i: integer;

begin
   ClearLine(x - 5, y - 5, x + 5, y + 5);
   SetLineStyle( SolidLn, 0, 1);
   for i:= y - 5 to y + 5 do
   begin
      Line(X-5, i, X+5, i);
   end;
end;


{******************************************************************}
Procedure DmePlaceMoxels(x,y : integer; w : word);


   {**********************************}
   procedure ClearLine( x0, y0, x1 : integer);

   begin
      SetColor(menubkcolor);
      Line(x0, y0 + 1, x1, y0 + 1);
      SetColor(menutextcolor);
   end;

begin

   if (w and 32768) > 0 then DmePutfilledMoxel(x, y)
                        else DmePutemptyMoxel(x, y);
   if (w and 16384) > 0 then DmePutfilledMoxel(x+symboldx, y)
                        else DmePutemptyMoxel(x+symboldx, y);
   if (w and 8192) > 0 then DmePutfilledMoxel(x+2*symboldx, y)
                       else DmePutemptyMoxel(x+2*symboldx,y);
   if (w and 4096) > 0 then DmePutfilledMoxel(x+3*symboldx, y)
                        else DmePutemptyMoxel(x+3*symboldx, y);
   if (w and 2048) > 0 then DmePutfilledMoxel(x+4*symboldx, y)
                       else DmePutemptyMoxel(x+4*symboldx, y);
   if (w and 1024) > 0 then DmePutfilledMoxel(x+5*symboldx, y)
                       else DmePutemptyMoxel(x+5*symboldx, y);
   if (w and 512) > 0 then DmePutfilledMoxel(x+6*symboldx, y)
                      else DmePutemptyMoxel(x+6*symboldx, y);
   if (w and 256) > 0 then DmePutfilledMoxel(x+7*symboldx, y)
                      else DmePutemptyMoxel(x+7*symboldx, y);
   if (w and 128) > 0 then DmePutfilledMoxel(x+8*symboldx, y)
                      else DmePutemptyMoxel(x+8*symboldx, y);
   if (w and 64) > 0 then DmePutfilledMoxel(x+9*symboldx, y)
                     else DmePutemptyMoxel(x+9*symboldx, y);
   if (w and 32) > 0 then DmePutfilledMoxel(x+10*symboldx, y)
                     else DmePutemptyMoxel(x+10*symboldx, y);
   if (w and 16) > 0 then DmePutfilledMoxel(x+11*symboldx, y)
                     else DmePutemptyMoxel(x+11*symboldx, y);
   if (w and 8) > 0 then DmePutfilledMoxel(x+12*symboldx, y)
                    else DmePutemptyMoxel(x+12*symboldx, y);
   if (w and 4) > 0 then DmePutfilledMoxel(x+13*symboldx, y)
                    else DmePutemptyMoxel(x+13*symboldx, y);
   if (w and 2) > 0 then DmePutfilledMoxel(x+14*symboldx, y)
                    else DmePutemptyMoxel(x+14*symboldx, y);
   if (w and 1) > 0 then DmePutfilledMoxel(x+15*symboldx, y)
                    else DmePutemptyMoxel(x+15*symboldx, y);

end;

{******************************************************************}
Procedure DmeDrawSquare(xmin, ymin, xmax, ymax : integer);

begin
   SetLineStyle(SolidLn, 0, 1);
   Line(xmin, ymin, xmax, ymin);
   Line(xmax, ymin, xmax, ymax);
   Line(xmax, ymax, xmin, ymax);
   Line(xmin, ymax, xmin, ymin);
end;

{******************************************************************}
Procedure DmeDrawArrow(x, y, dirarrow : integer);

begin
   case dirarrow of

   0: begin
         PutPixel(x, y, menutextcolor);
         Line(x - 1, y - 1, x - 1, y + 1);
         Line(x - 2, y - 2, x - 2, y + 2);
         Line(x - 3, y - 3, x - 3, y + 3);
         Line(x - 4, y - 1, x - 4, y + 1);
         Line(x - 5, y - 1, x - 5, y + 1);
         Line(x - 6, y - 1, x - 6, y + 1);
         Line(x - 7, y - 1, x - 7, y + 1);
      end;

   1: begin
         PutPixel(x, y, menutextcolor);
         Line(x + 1, y - 1, x + 1, y + 1);
         Line(x + 2, y - 2, x + 2, y + 2);
         Line(x + 3, y - 3, x + 3, y + 3);
         Line(x + 4, y - 1, x + 4, y + 1);
         Line(x + 5, y - 1, x + 5, y + 1);
         Line(x + 6, y - 1, x + 6, y + 1);
         Line(x + 7, y - 1, x + 7, y + 1);
      end;

   2: begin
         PutPixel(x, y, menutextcolor);
         Line(x - 1, y + 1, x + 1, y + 1);
         Line(x - 2, y + 2, x + 2, y + 2);
         Line(x - 3, y + 3, x + 3, y + 3);
         Line(x - 1, y + 4, x + 1, y + 4);
         Line(x - 1, y + 5, x + 1, y + 5);
         Line(x - 1, y + 6, x + 1, y + 6);
         Line(x - 1, y + 7, x + 1, y + 7);
      end;

   3: begin
         PutPixel(x, y, menutextcolor);
         Line(x - 1, y - 1, x + 1, y - 1);
         Line(x - 2, y - 2, x + 2, y - 2);
         Line(x - 3, y - 3, x + 3, y - 3);
         Line(x - 1, y - 4, x + 1, y - 4);
         Line(x - 1, y - 5, x + 1, y - 5);
         Line(x - 1, y - 6, x + 1, y - 6);
         Line(x - 1, y - 7, x + 1, y - 7);
      end;

   end; {case dirarrow}

end;

end.
