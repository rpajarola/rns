unit symbols;

interface

uses Graph,
     GcurUnit,
     InitSc;

const
    topy = 60;
    klammerrad = 3;

type xfirsttyp = array[1..3] of integer;

procedure SymAbsNichts( x,y : integer);
procedure SymNichts(ix,iy : integer;x : real);
procedure SymLeer(ix,iy : integer;x : real);
procedure Beat( x, y, beatlength : integer; solidb: boolean);
procedure Mainline( x0, y0, x1 : integer; thickness: real);
procedure Thinline( x0, y0, x1 : integer);
Procedure SymInvisibleLine( x0, y0, x1 : integer);
Procedure SymDottedLine( x0, y0, x1 : integer);
Procedure SymStaffLine( x0, y0, x1 : integer);
procedure DistanceMark(x0,y0,x1 : real;xfirst, GridNum : integer);
procedure Slash(ix,iy : integer;x : real);
procedure SymDotSlash(ix,iy : integer;x : real);
procedure SymDotSlash2(ix,iy : integer;x : real);
Procedure SymClearChar(x, y: integer);
procedure SymVKlammerEnd(x, y : integer);
procedure SymVKlammerStart(x, y : integer);
procedure SymVKlammerCont(x, y : integer);
procedure SymVKlammerEvenMid(x, y : integer);
procedure SymVKlammerOddMid(x, y : integer);
procedure SymHKlammerEnd(x, y : integer);
procedure SymHKlammerStart(x, y : integer);
procedure SymHKlammerNormMid(x, y : integer);
procedure SymHKlammerSmallMid(x, y : integer);
procedure SymNorKlammerAuf(x, y, height : integer);
procedure SymNorKlammerZu(x, y, height : integer);
procedure SymEckKlammerAuf(x, y, height : integer);
procedure SymEckKlammerZu(x, y, height : integer);
Procedure SymTabSymbol(x, y : integer);
Procedure SymTabSymbolDown(x, y : integer);
procedure SymGKlammerAuf(x, y, height : integer);
procedure SymGKlammerZu(x, y, height : integer);
procedure SymEt(ix,iy : integer;x : real);
procedure SymQuotMark(ix,iy : integer;x : real);
procedure SymRepQuotMark(ix,iy : integer;x : real);
implementation

uses Helpunit,
     Dmemunit,
     Graphmenu,
     Printunit;

{******************************************************************}
Procedure SymTabSymbol(x, y : integer);
{Zeichnen eines Tabulatorzeichens}
begin
  if dispspec = 1 then begin
    putpixel(x+1,y-3,speccolor);
    putpixel(x+2,y-2,speccolor);
    putpixel(x+1,y-1,speccolor);
    putpixel(x+2,y-2,speccolor);
  end;
end;

{******************************************************************}
Procedure SymTabSymbolDown(x, y : integer);
{Zeichnen eines umbgekehrten Tabulatorzeichens}
begin
  if (dispspec = 1) then begin
    putpixel(x+1,y-4,speccolor);
    putpixel(x+2,y-3,speccolor);
    putpixel(x+3,y-2,speccolor);
    putpixel(x+1,y  ,speccolor);
    putpixel(x+2,y-1,speccolor);
    putpixel(x+3,y-2,speccolor);
  end;
end;

{******************************************************************}
Function SymKlammerRadius(x : integer): real;

begin
   SymKlammerRadius:= PriXScale(x + klammerrad) - PriXScale(x);
end;

                                                                              {
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
procedure SymNorKlammerAuf(x, y, height : integer);

begin
  if height<0 then begin
    height:=-height+charheight;
    y:=y+height-(charheight div 2);
  end;
  if PrinterOn then
  begin
    PriSetLineWidth(0.5{pswidth});
    PriNewPath;
    PriArc(PriXScale(x + klammerrad), PriYScale(y - height + 2),
           SymKlammerRadius(x), 180.0, 120.0, 'n');
    PriDrawLine(x, y - height + 2, x, y + 3);
    PriArc(PriXScale(x + klammerrad), PriYScale(y + 3),
           SymKlammerRadius(x), 180.0, 240.0, ' ');
  end else
  begin
    PutPixel(x + 1, y - height + 1, lcolor);
    Line(x, y - height + 2, x, y + 3);
    PutPixel(x + 1, y + 4, lcolor);
  end;
end;
                                                                              {
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
procedure SymNorKlammerZu(x, y, height : integer);

begin
  if height<0 then begin
    height:=-height;
    y:=y+height;
  end;
  if PrinterOn then
  begin
    PriSetLineWidth(0.5{pswidth});
    PriNewPath;
    PriArc(PriXScale(x - klammerrad), PriYScale(y - height + 2),
           SymKlammerRadius(x), 0.0,  60.0,' ');
    PriDrawLine(x, y - height + 2, x, y + 3);
    PriArc(PriXScale(x - klammerrad), PriYScale(y + 3),
           SymKlammerRadius(x), 0.0, 300.0,'n');
  end else
  begin
    PutPixel(x - 1, y - height + 1, lcolor);
    Line(x, y - height + 2, x, y + 3);
    PutPixel(x - 1, y + 4, lcolor);
  end;
end;
                                                                              {
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
procedure SymEckKlammerAuf(x, y, height : integer);

begin
  if height<0 then begin
    height:=-height;
    y:=y+height;
  end;
  if PrinterOn then
  begin
    PriSetLineWidth(0.5{pswidth});
    PriNewPath;
    PriDrawLine(x, y - height, x + 1, y - height); {- oben}
    PriDrawLine(x, y - height, x    , y + 5     ); {›}
    PriDrawLine(x, y + 5     , x + 1, y + 5     ); {- unten}
  end else
  begin
    PutPixel(x + 1, y - height + 1, lcolor);
    Line(x, y - height + 1, x, y + 4);
    PutPixel(x + 1, y + 4, lcolor);
  end;
end;
                                                                              {
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ}
procedure SymEckKlammerZu(x, y, height : integer);

begin
  if height<0 then begin
    height:=-height;
    y:=y+height;
  end;
  if PrinterOn then
  begin
    PriSetLineWidth(0.5{pswidth});
    PriNewPath;
    PriDrawLine(x, y - height, x - 1, y - height); {- oben}
    PriDrawLine(x, y - height, x    , y + 5     ); {›}
    PriDrawLine(x, y + 5     , x - 1, y + 5     ); {- unten}
  end else
  begin
    PutPixel(x - 1, y - height + 1, lcolor);
    Line(x, y - height + 1, x, y + 4);
    PutPixel(x - 1, y + 4, lcolor);
  end;
end;

{******************************************************************}
procedure SymHKlammerNormMid(x, y : integer);
var ac : Byte;
begin
  ac:=GetColor;
  PutPixel(x-2,y+4,ac);
  PutPixel(x-1,y+4,ac);
  PutPixel(x-1,y+5,ac);
  PutPixel(x  ,y+5,ac);
  PutPixel(x  ,y+6,ac);
  PutPixel(x+1,y+5,ac);
  PutPixel(x+1,y+4,ac);
  PutPixel(x+2,y+4,ac);
  PutPixel(x  ,y+4,getbkcolor);
  Line(x-4,y+4,x-2,y+4);
  Line(x+2,y+4,x+4,y+4);
end;

{******************************************************************}
procedure SymHKlammerSmallMid(x, y : integer);
var ac : byte;
begin
  ac:=getcolor;
  PutPixel(x+2,y+4,ac);{                  }
  PutPixel(x+1,y+4,ac);{                  }
  PutPixel(x+1,y+5,ac);{                  }
  PutPixel(x  ,y+5,ac);{                  }
  PutPixel(x  ,y+6,ac);{ 87921            }
  PutPixel(x-1,y+5,ac);{  643             }
  PutPixel(x-1,y+4,ac);{   5              }
  PutPixel(x-2,y+4,ac);{                  }
  PutPixel(x,y+4,GetBkColor);
end;

procedure SymHKlammerStart(x, y : integer);

var i: byte;
    ac : byte;
begin
   ac:=getcolor;
   PutPixel(x+1,y+2,ac);
   PutPixel(x,y+1,ac);
   PutPixel(x+2,y+2,ac);
   PutPixel(x+1,y+1,ac);
   PutPixel(x,y,ac);

   PutPixel(x+2,y+2,ac);
   PutPixel(x+3,y+2,ac);
   PutPixel(x+4,y+2,ac);
   PutPixel(x+5,y+2,ac);
   PutPixel(x+6,y+2,ac);
   PutPixel(x+7,y+2,ac);
end;

{******************************************************************}
procedure SymHKlammerEnd(x, y : integer);

var i: byte;
    ac : byte;

begin
   ac:=getcolor;
   PutPixel(x+3,y+4,ac);
   PutPixel(x+4,y+3,ac);
   PutPixel(x+2,y+4,ac);
   PutPixel(x+3,y+3,ac);
   PutPixel(x+4,y+2,ac);

   PutPixel(x-3,y+4,ac);
   PutPixel(x-2,y+4,ac);
   PutPixel(x-1,y+4,ac);
   PutPixel(x  ,y+4,ac);
   PutPixel(x+1,y+4,ac);
   PutPixel(x+2,y+4,ac);
end;

{******************************************************************}
procedure SymVKlammerEvenMid(x, y : integer);

var i: byte;
    ac : byte;
begin
{   Inc(x,7);}
   ac:=getcolor;
   PutPixel(x+1,y-2,ac);
   PutPixel(x+1,y-1,ac);
   PutPixel(x  ,y-1,ac);
   PutPixel(x  ,y,ac);
   PutPixel(x-1,y,ac);
   PutPixel(x  ,y+1,ac);
   PutPixel(x+1,y+1,ac);
   PutPixel(x+1,y+2,ac);
   Line(x+1,y-7,x+1,y-2);
   Line(x+1,y+2,x+1,y+7);
end;

{******************************************************************}
procedure SymVKlammerOddMid(x, y : integer);

var i: byte;
    ac : byte;
begin
   ac:=GetColor;
   PutPixel(x+1,y-2,ac);
   PutPixel(x+1,y-1,ac);
   PutPixel(x  ,y-1,ac);
   PutPixel(x  ,y,ac);
   PutPixel(x-1,y,ac);
   PutPixel(x  ,y+1,ac);
   PutPixel(x+1,y+1,ac);
   PutPixel(x+1,y+2,ac);
   PutPixel(x+2,y-1,GetBkColor);
   Line(x+1 , y -1, x+1, y -7);
   Line(x+1 , y +1, x+1, y +7);
end;

{******************************************************************}
procedure SymVKlammerCont(x, y : integer);

begin
   Inc(x,7);
   Line(x+1 , y - line2thick, x+1, y + line2thick - 1);
end;

{******************************************************************}
procedure SymVKlammerStart(x, y : integer);

var i: byte;
    ac : byte;

begin
   ac:=getcolor;
   Inc(x,3);
   PutPixel(x+1,y+line2thick,ac);
   PutPixel(x+1,y+line2thick+1,ac);
   PutPixel(x+1,y+line2thick+2,ac);
   PutPixel(x+1,y+line2thick+3,ac);
   PutPixel(x+1,y+line2thick+4,ac);
   PutPixel(x+1,y+line2thick+5,ac);
   PutPixel(x+1,y+line2thick+6,ac);

   PutPixel(x+1,y+line2thick,ac);
   PutPixel(x+2,y+line2thick,ac);
   PutPixel(x+2,y+line2thick-1,ac);
   PutPixel(x+3,y+line2thick-1,ac);
end;

{******************************************************************}
procedure SymVKlammerEnd(x, y : integer);

var i: byte;
    ac : byte;
begin
   ac:=getcolor;
   PutPixel(x+1,y-10,ac);
   PutPixel(x+1,y-9,ac);
   PutPixel(x+1,y-8,ac);
   PutPixel(x+1,y-7,ac);
   PutPixel(x+1,y-6,ac);
   PutPixel(x+1,y-5,ac);

   PutPixel(x+1,y-4,ac);
   PutPixel(x+2,y-4,ac);
   PutPixel(x+2,y-3,ac);
   PutPixel(x+3,y-3,ac);
end;

{******************************************************************}
procedure ClearLine( x0, y0, x1 : integer);

begin
   SetColor(BkColor);
   Line(x0, y0 + 1, x1, y0 + 1);
   SetColor(LColor);
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
procedure Mainline( x0, y0, x1 : integer; thickness: real);

begin
   if PrinterOn then
   begin
      PriSetLineWidth(thickness);
      x0:=x0-1;
      if x0<0 then
        x0:=0;
      PriDrawLine(x0, y0, x1, y0);
   end
   else
   begin
      SetLineStyle( SolidLn, 0, 1);
      Line( x0, y0, x1, y0);
   end;
end;

{******************************************************************}
procedure DistanceMark(x0,y0,x1 : real;xfirst, GridNum : integer);

var xloc,lxloc : integer;
    iy0        : integer;
    rx,rdx     : real;
    i          : integer;
begin
  if (GridNum<1) Or (Dispgrid=1) Then
    Exit;
  iy0:=round(y0);
  y0:=y0-1;
  dec(iy0);
  xloc:=round(x0);
  rdx:=(x1-x0) / GridNum;
  rx:=x0;
  if PrinterOn then begin
    while (rx<x1) and (rx<xfirst) do
      rx:=rx+rdx;
    while rx < x1 do begin
      PriSetLineWidth(grwidth);
      PriNewPath;
      PriMove(PriRXscale(rx), PriRYscale(y0+1.0));        { Gridhîhe }
      PriLine(PriRXscale(rx), PriRYscale(y0-0.3{0.5}));   { Gridhîhe }
      PriStroke;
      rx:= rx + rdx;
    end;
  end else begin
    if rdx<2 then
      rdx:=2;
    i:=1;
    while (xloc<x1) and (xloc<xfirst) do begin
      inc(i);
      rx:= rx + rdx;
      if Gridnum>0 then
        xloc:= trunc(rx);
    end;
    lxloc:=xloc;
    while (xloc < x1) and (i<=gridnum) do begin
      if ((GetPixel(xloc - 1, iy0) <> GetColor) and
          (GetPixel(xloc + 1, iy0) <> GetColor)) then begin
        inc(i);
        PutPixel(xloc, iy0, lcolor);
        inc(lxloc,2);
      end else
        inc(lxloc);
      while xloc<lxloc do begin
        rx:= rx + rdx;
        if Gridnum>0 then
          xloc:= trunc(rx);
        lxloc:=xloc;
      end;
    end;
  end;
end;

{******************************************************************}
procedure Thinline( x0, y0, x1 : integer);
begin
   if PrinterOn then begin
      PriSetLineWidth(tnwidth);
      PriDrawLine(x0-1, y0, x1, y0);
   end else begin
      SetLineStyle( 4, $AAAA, 1);
      Line( x0, y0, x1, y0);
      SetLineStyle( SolidLn, 0, 1);
   end;
end;

{******************************************************************}
Procedure SymDottedLine( x0, y0, x1 : integer);

begin
   if PrinterOn then begin
      PriSetLineWidth(dtwidth);
      PriSetDash(dtwidth, 2.0);
      PriDrawLine(x0-1, y0, x1, y0);
      PriReSetDash;
   end else begin
      SetLineStyle( 4, $4444, 1);
      Line( x0, y0, x1, y0);
      SetLineStyle( SolidLn, 0, 1);
   end;
end;

{******************************************************************}

Procedure SymStaffLine( x0, y0, x1 : integer);

Var i : Byte;
begin
  if PrinterOn then begin
    PriSetLineWidth(piwidth);
    For i:=0 To 4 Do begin
      PriNewPath;
      PriMove(PriRXscale(x0-1), PriRYscale(y0-i*5));
      PriLine(PriRXscale(x1), PriRYscale(y0-i*5));
      PriStroke;
{      PriDrawLine(x0, y0-i*5, x1, y0-i*5);}
    end;
  end else begin
    SetLineStyle(4, $AAAA, 1);
    For i:=0 To 4 Do
      Line( x0, y0-i*5, x1, y0-i*5);
    SetLineStyle( SolidLn, 0, 1);
  end;
end;

{******************************************************************}
Procedure SymInvisibleLine( x0, y0, x1 : integer);

var oldcolor: byte;

begin
   if disphidlines=2 Then
     Exit;
   if not printeron then
   begin
      oldcolor:= GetColor;
      SetColor(helplinecolor);
      SetLineStyle( 4, $AAAA, 1);
      Line( x0, y0, x1, y0);
      SetLineStyle( SolidLn, 0, 1);
      SetColor(oldcolor);
   end;
end;

{******************************************************************}
procedure SymNichts(ix,iy : integer;x : real);
begin
  if PrinterOn then begin
    PriSetLineWidth(niwidth);
    PrirDrawLine(x, iy, x, iy - 2);  {-3}
  end else begin
    ClearLine(ix, iy, ix);
    Line( ix, iy, ix, iy - 2);       {-3}
  end;
end;
{******************************************************************}
procedure SymAbsNichts( x,y : integer);
begin
  IF X>638 Then
    Exit;
  ClearLine(x, y, x);
  if dispspec = 1 then begin
    PutPixel(x, y - 4, speccolor);
  end;
end;

{******************************************************************}
procedure SymLeer(ix,iy : integer;x : real);
begin
  if PrinterOn then begin
    PriSetLineWidth(lswidth);
    PrirDrawLine(x, iy + 3, x, iy - 3);
  end else begin
    Line( ix, iy + 3, ix, iy - 3);
  end;
end;
{******************************************************************}
procedure Beat( x, y, beatlength : integer; solidb: boolean);

var dy: integer;
begin
   dy:= 6;
   if PrinterOn then
   begin
      PriSetLineWidth(bewidth);
      PriDrawLine(x, y+dy, x, y-beatlength);
   end
   else
   begin
      if solidb then
      begin
         SetLineStyle( SolidLn, 0, 1);
      end
      else
      begin
         SetLineStyle( 4, $AAAA, 1);
      end;
      Line( x, y+dy, x, y-beatlength);
      SetLineStyle( SolidLn, 0, 1);
   end;
end;

{******************************************************************}
procedure Slash(ix,iy : integer;x : real);
begin
   if PrinterOn then
   begin
      PriSetLineWidth(0.5);
      PrirDrawLine(x - 7, iy + 7, x + 7, iy - 7);
   end
   else
   begin
      SetLineStyle( SolidLn, 0, 1);
       Line( ix-7, iy+7, ix+7, iy-7);
      SetLineStyle( SolidLn, 0, 1);
   end;
end;

{******************************************************************}
procedure SymDotSlash(ix,iy : integer;x : real); {neu als: SymDotBkSlash}
begin
  if dispslash=2 then
    exit;
  if PrinterOn then begin
    PriSetLineWidth(0.5);
    PrirDrawLine(x - 3, iy - 8, x + 3, iy + 8);
  end else begin
    SetLineStyle( SolidLn, 0, 1);

    Line( ix-4, iy-8, ix-4, iy-8);
    Line( ix-3, iy-6, ix-3, iy-6);
    Line( ix-2, iy-4, ix-2, iy-4);
    Line( ix-1, iy-2, ix-1, iy-2);

    Line( ix+1, iy+2, ix+1, iy+2);
    Line( ix+2, iy+4, ix+2, iy+4);
    Line( ix+3, iy+6, ix+3, iy+6);
    Line( ix+4, iy+8, ix+4, iy+8);

     SetLineStyle( SolidLn, 0, 1);
  end;
end;

{******************************************************************}
procedure SymDotSlash2(ix,iy : integer;x : real);
begin
  if dispslash=2 then
    exit;
  if PrinterOn then begin
    PriSetLineWidth(0.5);
    PriSetDash(3.0, 1.0);
    PrirDrawLine(x - 8, iy + 8, x + 8, iy - 8);
    PriReSetDash;
  end else begin
    SetLineStyle( 4, $BBBB, 1);
    Line( ix-8, iy+8, ix+8, iy-8);
    SetLineStyle( SolidLn, 0, 1);
  end;
end;
{******************************************************************}
procedure SymGKlammerAuf(x, y, height : integer);

begin
  if PrinterOn then begin
    PriSetLineWidth(0.5{pswidth});
    PriNewPath;
    PriArc(PriXScale(x + klammerrad), PriYScale(y - height + 2),
           SymKlammerRadius(x), 180.0, 120.0, 'n');
    PriDrawLine(x, y - height + 2, x, y - 1); {›}
    PriDrawLine(x, y          - 1, x-1, y    ); {/}
    PriDrawLine(x-1, y             , x, y + 1); {\}
    PriDrawLine(x, y          + 1, x, y + 3); {›}
    PriArc(PriXScale(x + klammerrad), PriYScale(y + 3),
           SymKlammerRadius(x), 180.0, 240.0, ' ');
  end else begin
    PutPixel(x + 1, y - height + 1, lcolor);
    Line(x, y - height + 2, x, y - 1);
    PutPixel(x - 1, y, lcolor);
    Line(x, y          + 1, x, y + 3);
    PutPixel(x + 1, y + 4, lcolor);
  end;
end;
{******************************************************************}
procedure SymGKlammerZu(x, y, height : integer);

begin
  if PrinterOn then begin
    PriSetLineWidth(0.5{pswidth});
    PriNewPath;
    PriArc(PriXScale(x - klammerrad), PriYScale(y - height + 2),
           SymKlammerRadius(x), 0.0,  60.0,' ');
    PriDrawLine(x, y - height + 2, x, y - 1);
    PriDrawLine(x, y          - 1, x+1, y    ); {/}
    PriDrawLine(x+1, y             , x, y + 1); {\}
    PriDrawLine(x, y          + 1, x, y + 3);
    PriArc(PriXScale(x - klammerrad), PriYScale(y + 3),
           SymKlammerRadius(x), 0.0, 300.0,'n');
  end else begin
    PutPixel(x - 1, y - height + 1, lcolor);
    Line(x, y - height + 2, x, y - 1);
    PutPixel(x + 1, y, lcolor);
    Line(x, y          + 1, x, y + 3);
    PutPixel(x - 1, y + 4, lcolor);
  end;
end;
{******************************************************************}
procedure SymEt(ix,iy : integer;x : real);
const yofs = 6;
      blen = 1;
begin
  if PrinterOn then begin
    PriSetLineWidth(3);
    PrirDrawLine(x-1.5,iy-6,x+1.5,iy-6);
  end else begin
    line(ix-1,iy-7,ix+1,iy-7);
    line(ix-1,iy-6,ix+1,iy-6);
    line(ix-1,iy-5,ix+1,iy-5);
  end;
end;
{******************************************************************}
procedure SymQuotMark(ix,iy : integer;x : real);
const yofs = 6;
      blen = 1;
begin
  if PrinterOn then begin
    PriSetLineWidth(1);
    PrirDrawLine(x-1.2,iy-7,x-1.2,iy-3); {stimmt ev. noch nicht ganz!}
    PrirDrawLine(x+1.4,iy-7,x+1.4,iy-3);
  end else begin
    line(ix-2,iy-7,ix-2,iy-3);
    line(ix-1,iy-7,ix-1,iy-3);
    line(ix+1,iy-7,ix+1,iy-3);
    line(ix+2,iy-7,ix+2,iy-3);       {dick, oberhalb der Linie}
  end;
end;
{******************************************************************}
procedure SymRepQuotMark(ix,iy : integer;x : real);
begin
  if PrinterOn then begin
    PriSetLineWidth(1);
    PrirDrawLine(x,iy-3,x,iy-5);
  end else begin
    line(ix  ,iy-3,ix  ,iy-5);             {dÅnn, auf der Linie}
  end;
end;

end.
