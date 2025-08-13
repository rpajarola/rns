unit printunit;

interface

Uses
  initsc,
  crt,
  DOS;


const psxmin = 52.5;
      psxmax = 558.5;
      psymin = 202.5;
      psymax = 576.5;

      pswidth = 0.2;

var psfile: text;
    psactwidth: real;

procedure hardcopy24(page:integer; eopage:boolean);
Function PriXScale(x: integer): real;
Function PriYScale(y: integer): real;
Function PriRXScale(x: real): real;
Function PriRYScale(y: real): real;
procedure PriString(var inblock: stringline);
procedure PriAddreal(var inblock: stringline; r: real);
procedure PriLine(rx, ry: real);
procedure PriMove(rx, ry: real);
procedure PriStroke;
procedure PriNewpath;
Procedure PriDrawLine(x0, y0, x1, y1: integer);
procedure PriSetLineWidth(thick: real);
procedure PriWriteChar(c: char; x, y: real);
procedure PriClosepath;

implementation

{******************************************************************}
Procedure PriDrawLine(x0, y0, x1, y1: integer);
{Schreibt eine Line mit Displaycoordinaten in das Postscriptfile}

begin
   PriNewPath;
   PriMove(PriXscale(x0), PriYscale(y0));
   PriLine(PriXscale(x1), PriYscale(y1));
   PriStroke;
end;

{******************************************************************}
Function PriRXScale(x: real): real;
{Wandelt einen x-real coordinatenwert am Bildschirm in einen
 x-Wert fÅr das Postscriptfile um}

begin
   PriRXScale:= psxmin + (x - grminx) * (psxmax - psxmin) / (grmaxx - grminx);
end;

{******************************************************************}
Function PriXScale(x: integer): real;
{Wandelt einen x-coordinatenwert am Bildschirm in einen
 x-Wert fÅr das Postscriptfile um}

begin
   PriXScale:= PriRXScale(1.0*x);
end;

{******************************************************************}
Function PriRYScale(y: real): real;
{Wandelt einen y-real coordinatenwert am Bildschirm in einen
 y-Wert fÅr das Postscriptfile um}

begin
   PriRYScale:= psymax - (y - grminy) * (psymax - psymin) / (grmaxy - grminy);
end;

{******************************************************************}
Function PriYScale(y: integer): real;
{Wandelt einen y-coordinatenwert am Bildschirm in einen
 y-Wert fÅr das Postscriptfile um}

begin
   PriYScale:= PriRYScale(1.0*y);
end;

{***************************}
procedure PriString(var inblock: stringline);
begin
 writeln(psfile, inblock);
 inblock:= '';
end;

{***************************}
procedure PriAddreal(var inblock: stringline; r: real);

var rstring: string[16];

begin
 Str(r:6:1, rstring);
 inblock:= inblock + rstring + ' ';
end;

{***************************}
procedure PriLine(rx, ry: real);

var inblock: stringline;

begin
 inblock:= '';
 PriAddreal(inblock, rx);
 PriAddreal(inblock, ry);
 inblock:= inblock + 'lineto';
 PriString(inblock);
end;

{***************************}
procedure PriMove(rx, ry: real);

var inblock: stringline;

begin
 inblock:= '';
 PriAddreal(inblock, rx);
 PriAddreal(inblock, ry);
 inblock:= inblock + 'moveto';
 PriString(inblock);
end;

{***************************}
procedure PriClosepath;

var inblock: stringline;

begin
 inblock:= ' closepath ';
 PriString(inblock);
end;

{***************************}
procedure PriStroke;

var inblock: stringline;

begin
 inblock:= ' stroke ';
 PriString(inblock);
end;

{***************************}
procedure PriNewpath;

var inblock: stringline;

begin
 inblock:= ' newpath ';
 PriString(inblock);
end;

{***************************}
procedure PriSetLineWidth(thick: real);

var inblock: stringline;

begin
   if ((psactwidth < (thick - 0.01)) or (psactwidth > (thick + 0.01))) then
   begin
      inblock:= '';
      PriAddReal(inblock, thick);
      inblock:= inblock + ' setlinewidth';
      PriString(inblock);
      psactwidth:= thick;
   end;
end;

{***************************}
procedure PriWriteChar(c: char; x, y: real);

var inblock: stringline;

begin
   inblock:= '';
   PriMove(PriRXScale(x) - 6.5, PriRYScale(y) - 6.5);
   inblock:= inblock + '(' + c + ') show';
   PriString(inblock);
end;

{*************************************************************}
procedure hardcopy24(page:integer; eopage:boolean);
var offset, k, bitrange,
         x,
         y : integer;
 Printbyte,
         b1,
         b2,
         b3 : byte;
         lst : text;
         xbyte : array[0..7] of byte;
         c: char;

begin
   assign(lst,'LPT2');
   Rewrite(LST);

   write(lst,#27,'3',#24);
   y:=0;
   while y <= 347 do
   begin
      if y = 24 then
      begin
         IniInversText(10, 1,'Press <ESC> to stop printing');
      end;
      write(lst,#27,'*',#38,chr(lo(720*1)),chr(hi(720*1)));
      for x := 0 to 89 do
      begin
         for k:= 0 to 7 do
            xbyte[k]:= 0;

         bitrange:= 1;
         for k:= 0 to 7 do
         begin
            offset := Inibytes(x*8, y+7-k);
            if page = 0 then
               printbyte := mem[$b000:offset];
            if page = 1 then
               printbyte := mem[$b800:offset];
            if (printbyte and 128) = 128 then xbyte[0]:= xbyte[0] + bitrange;
            if (printbyte and  64) =  64 then xbyte[1]:= xbyte[1] + bitrange;
            if (printbyte and  32) =  32 then xbyte[2]:= xbyte[2] + bitrange;
            if (printbyte and  16) =  16 then xbyte[3]:= xbyte[3] + bitrange;
            if (printbyte and   8) =   8 then xbyte[4]:= xbyte[4] + bitrange;
            if (printbyte and   4) =   4 then xbyte[5]:= xbyte[5] + bitrange;
            if (printbyte and   2) =   2 then xbyte[6]:= xbyte[6] + bitrange;
            if (printbyte and   1) =   1 then xbyte[7]:= xbyte[7] + bitrange;

            bitrange:= bitrange + bitrange;
         end;

         for k:= 0 to 7 do
         begin
            printbyte:= xbyte[k];
            b1 := 0;
            b2 := 0;
            b3 := 0;
            if ((Printbyte and 128) = 128) then
               b1 := 128 + 64 + 32;
            if ((Printbyte and 64) = 64) then
               b1 := b1 or 16 + 8 + 4;
            if ((Printbyte and 32) = 32) then
            begin
               b1 := b1 or 2 + 1;
               b2 := 128;
            end;
            if ((Printbyte and 16) = 16) then
               b2 := b2 or 64 + 32 +16;
            if ((Printbyte and 8) = 8) then
               b2 := b2 or 8 + 4 + 2;
            if ((Printbyte and 4) = 4) then
            begin
               b2 := b2 or 1;
               b3 := 128 + 64;
            end;
            if ((Printbyte and 2) = 2) then
               b3 := b3 or 32 + 16 + 8;
            if ((Printbyte and 1) = 1) then
               b3 := b3 or 4 + 2 + 1;
            if b1 = 26 then b1:=30;
            if b2 = 26 then b2:=30;
            if b3 = 26 then b3:=30;

            write(lst,chr(b1),chr(b2),chr(b3));
         end;
      end;  {for x := 0 to 90 do}
      writeln(lst);
      y:= y + 8;
      while KeyPressed do
      begin
         c:= ReadKey;
         if c = chr(27) then y:= 20000;
      end;
   end; {while y <= 347 do }
   write(lst,#27,#0);
   if eopage then
   begin
      write(lst, chr(12));
   end;
   close(LST);
   IniClearLine(10, 1, 0, 39, menubkcolor);
end;

begin
   psactwidth:= 0.0;
end.
