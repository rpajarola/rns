unit gcurunit;

interface

uses graph,
     crt;

Const CursorXSize=9;
      CursorYSize=13;

type CursorArr = Array[0..CursorXSize,0..CursorYSize] of word;

var PatternSave, GraphCursor : CursorArr;
    gcxcoord, gcycoord: integer;
    dispcurs: byte; {1= display cursor, 2 = dont display cursor}

procedure GcuCursorClear;
Procedure GcuIniCursor;
procedure GcuMoveCursor(x,y : integer);
procedure GcuPatternRestore;
Procedure GcuCursorRestore;
Function GcuRightMargin : integer;

implementation

uses initsc;

{**************************************************************}
Function GcuRightMargin : integer;

begin
   if GetMaxX > 650 then GcuRightMargin:= 16
   else GcuRightMargin:= 0;
end;

{**************************************************************}
procedure MinMax(var imin,imax,jmin,jmax : integer);

begin
   imax:= gcxcoord + (CursorXSize div 2);
   imin:= gcxcoord - (CursorXSize div 2);
   jmax:= gcycoord + (CursorYSize div 2) - 1;
   jmin:= gcycoord - (CursorYSize div 2) - 1;

   if imin < 0 then imin:= 0;
   if jmin < 0 then jmin:= 0;
   if imax > GetmaxX then imax:= GetMaxX;
   if jmax > GetmaxY then jmax:= GetMaxY;
end;

{**************************************************************}
procedure GcuPatternStore;

var i,j,imin,imax,jmin,jmax : integer;

begin

   MinMax(imin,imax,jmin,jmax);

   for j:= jmin to jmax do
      for i:= imin to imax do
         PatternSave[i-imin,j-jmin]:= GetPixel(i,j);

end;

{**************************************************************}
procedure GcuCursorClear;

var i,j,imin,imax,jmin,jmax : integer;

begin
   MinMax(imin,imax,jmin,jmax);

   for j:= jmin to jmax do
      for i:= imin to imax do
	 PatternSave[i-imin,j-jmin]:= menubkcolor;
end;

{**************************************************************}
procedure GcuPatternRestore;

var i,j,imin,imax,jmin,jmax : integer;

begin
    MinMax(imin,imax,jmin,jmax);
    for j:= jmin to jmax do
       for i:= imin to imax do
          PutPixel(i,j,PatternSave[i-imin,j-jmin]);
end;

{**************************************************************}
procedure GcuDrawCursor;

var i, j, imin, imax, jmin, jmax, istart, jstart : integer;

begin
   GcuPatternStore;
   if ((not KeyPressed) and (dispcurs = 1)) then
   begin
      MinMax(imin,imax,jmin,jmax);
      istart:= gcxcoord - (CursorXSize div 2);

      for j:= jmin to jmax do
         for i:= imin to imax do
	    PutPixel(i,j,GraphCursor[i-istart,jmax-j]);
   end;
end;

{**************************************************************}
Procedure GcuMoveCursor(x,y : integer);

begin
   if x > (GetMaxX - GcuRightMargin) then x:= GetMaxX - GcuRightMargin;
   MoveTo(x,y);
   gcxcoord:= x;
   gcycoord:= y;
end;

{**************************************************************}
Procedure GcuCursorRestore;

begin
   GcuMoveCursor(gcxcoord, gcycoord);
   GcuDrawCursor;
end;

{**************************************************************}
Procedure GcuIniCursor;

var i,j,k,pfeil : integer;

begin
   {initialisiere Cursor-Bild}
   for i:= 0 to CursorYSize do
      for j:= 0 to CursorXSize do
	 GraphCursor[j,i]:= menubkcolor;

   pfeil:= CursorXSize div 2 + 2;

   for j:= 0 to CursorYSize - pfeil do
      for i:= CursorXSize div 2 - 2  to CursorXSize div 2 + 2 do
      begin
	 GraphCursor[i,j]:= CursorColor;
      end;

   for j:= CursorYSize - pfeil + 1 to CursorYSize - 1 do
   begin
      k:= j - CursorYSize + pfeil - 1;
      for i:= k to CursorXSize - 1 - k do
      begin
	 GraphCursor[i,j]:= CursorColor;
      end;
   end;
   dispcurs:= 1;
end;

end.
