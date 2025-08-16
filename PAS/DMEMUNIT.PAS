unit dmemunit;

interface

uses dos,
     graph,
     initsc;

Procedure DmePlaceWord(x,y : integer; w : word);
Procedure DmeDispChar(x, y: integer; c : char; blnum: integer);

implementation

uses helpunit;

{******************************************************************}
Procedure DmeDispChar(x, y: integer; c : char; blnum: integer);

var i, j : integer;
    muster : word;

begin
  if ((x>=0) and (y>1) and (x<=gmaxx) and (y < (gmaxy - 1))) then begin
    for i:= 1 to 15 do begin
      muster:= symarr[c, i, blnum];
      if y-8+i<=grmaxy Then
        DmePlaceWord(x - 7, y - 8 + i , muster);
    end;
  end;
end;

{******************************************************************}
Procedure DmePlaceWord(x,y : integer; w : word);

var acolor: byte;
    i: integer;
    bitval: word;
    pixelx: integer;

begin
   acolor:= getcolor;
   { Modern Pascal replacement for assembly bit manipulation }
   bitval := w;
   for i := 0 to 15 do
   begin
     if (bitval and $8000) <> 0 then { Test highest bit }
     begin
       pixelx := x + i;
       if (pixelx > 1) and (pixelx < 639) then
         PutPixel(pixelx, y, acolor);
     end;
     bitval := bitval shl 1; { Shift left for next bit }
   end;
end;

end.
