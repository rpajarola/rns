unit printunit;

interface

Uses
  initsc,
  crt,
  DOS,
  UserExit,
  HelpUnit,
  Texts;
                      {Hier werden RÑnder von 2 File-Seiten auf A4 definiert:}
                      {  0.0 Punkte = unterer Blattrand des amerik.Formats!?}
                      {2.8 Punkte entsprechen etwa 1mm}
                      {unter 63 stellt Epson den untern Rand nicht mehr dar!}
                      {RandabstÑnde zu A5 mÅssen sich leider danach richten!}
                      {446.5 Punkte = ca. Hîhen-Mitte des A4-Blattes}
                      {657.5 Punkte = ca. Hîhen-Mitte der 1.File-Seite}
                      {235.5 Punkte = ca. Hîhen-Mitte der 2.File-Seite}
const cxmin= 46.0;    {links-rechts Verschiebung}{linker  Rand}
      cxmax=558.0;                               {rechter Rand}

      cymaxtop=829.0; {1.File-Seite Rand oben : Abstand vom untern Blattrand}
      cymintop=486.0; {1.File-Seite Rand unten: Abstand vom untern Blattrand}
      {Diff1:  343.0} {Diff1 und Diff 2 mÅssen gleich gross sein *}

      cymaxbot=407.0; {2.File-Seite Rand oben : Abstand vom untern Blattrand}
      cyminbot= 64.0; {2.File-Seite Rand unten: Abstand vom untern Blattrand}
      {Diff2:  343.0  {* je grîsser die Differenz desto hîher die File-Seite}

var psactwidth: real;
    psxmin, psxmax, psymin, psymax: real;

procedure PriPostscriptinit;
procedure PriPostscriptComplete;
procedure PriPostscript;
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
Procedure PriRDrawLine(x0, y0, x1, y1: real);
procedure PriSetLineWidth(thick: real);
procedure PriWriteChar(c: char; x, y: real);
procedure PriWriteSym(c: char; x,y: real);
procedure PriClosepath;
procedure PriPlaceString(x, y: real; inblock: stringline);
procedure PriSwapFont;
procedure PriLeftString(instring: stringline; x, y: real);
procedure PriComplString(inblock: stringline);
procedure PriArc(rx, ry, rad, startw, endw: real; c: char);
procedure PriHorizontalKlammer(ixmin, ixmax, iy: integer);
procedure PriVerticalKlammer(ix, iymin, iymax: integer);
procedure PriReSetDash;
procedure PriSetDash(llength, distlength: real);
procedure PriMakeUmlaute(var psfile : text);
procedure PriSetTopMargins;
procedure PriSetBottomMargins;
procedure PriDrawFrame(x0,y0,x1,y1 : integer);

implementation

uses pageunit;


{*************************************************************}
Procedure PriGetFontHeight;
var instring : stringline;
    a,b      : integer;
    F        : Text;
Begin
  Assign(F,'SYMBOLS.PRN');
  ReSet(F);
  while not eof(f) do begin
    ReadLn(f,instring);
    instring:=upstring(instring);
    if (pos('SCALEFONT',instring)<>0) And
       (pos('/SYMBOLFONT',instring)<>0) Then Begin
      a:=pos('SCALEFONT',instring)-2;
      b:=0;
      while (instring[a-b]<>' ') do
        inc(b);
      a:=a-b+1;
      val(copy(instring,a,b),a,b);
      if b<>0 then
        Symfontsize:=15
      else
        Symfontsize:=a;
      Close(F);
      Exit;
    End;
  End;
  Symfontsize:=15;
  Close(F);
End;

{*************************************************************}
Procedure PriSetTopMargins;
begin
  psymin:= cymintop;
  psymax:= cymaxtop;
end;

{*************************************************************}
Procedure PriSetBottomMargins;
begin
  psymin:= cyminbot;
  psymax:= cymaxbot;
end;

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
Procedure PriRDrawLine(x0, y0, x1, y1: real);
{Schreibt eine Line mit Displaycoordinaten in das Postscriptfile}
begin
  PriNewPath;
  PriMove(PriRXscale(x0), PriRYscale(y0));
  PriLine(PriRXscale(x1), PriRYscale(y1));
  PriStroke;
end;
{******************************************************************}
Function PriRXScale(x: real): real;
{Wandelt einen x-real coordinatenwert am Bildschirm in einen
 x-Wert fÅr das Postscriptfile um}

begin{46+x*512/639}
   PriRXScale:=x;{ psxmin + (x - grminx) * (psxmax - psxmin) / (grmaxx - grminx);}
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


begin{829-y*343/424}
   PriRYScale:= grmaxy-y;{psymax - (y - grminy) * (psymax - psymin) / (grmaxy - grminy);}
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
 LastFileName:=FExpand(TextRec(psfile).Name);
 writeln(psfile, inblock);
 inblock:= '';
end;

{***************************}
procedure PriPlaceString(x, y: real; inblock: stringline);
begin
   PriMove(x, y);
   LastFileName:=FExpand(TextRec(Psfile).Name);
   writeln(psfile,'(', inblock, ') show');
end;

{***************************}
procedure PriAddreal(var inblock: stringline; r: real);

var rstring: string[16];

begin
 Str(r:6:3, rstring);
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
procedure PriSetDash(llength, distlength: real);

var inblock: stringline;

begin
 inblock:= '[';
 PriAddreal(inblock, llength);
 PriAddreal(inblock, distlength);
 inblock:= inblock + '] 0.0 setdash';
 PriString(inblock);
end;

{***************************}
procedure PriReSetDash;

var inblock: stringline;

begin
 inblock:= '[] 0.0 setdash';
 PriString(inblock);
end;
{***************************}
procedure PriArc(rx, ry, rad, startw, endw: real; c: char);

var inblock: stringline;

begin
   PriNewPath;
   inblock:= '';
   PriAddreal(inblock, rx);
   PriAddreal(inblock, ry);
   PriAddreal(inblock, rad);
   PriAddreal(inblock, startw);
   PriAddreal(inblock, endw);
   inblock:= inblock + 'arc' + c;
   PriString(inblock);
   PriStroke;
end;
{
˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛
                       primove
˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛˛
}
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
{****************************************************************************}

procedure PriSwapFont;

var inblock: stringline;

begin  {in Print-Options zur Auswahl geben}
{ Font. Bitte dunnot cheinsch. Denn hier (und _nur_ hier) sind ae oe und ue
  bereits als Ñ î und Å eingebaut.
  Fontwechsel bitte woanders erledigen.
}
  inblock:= '%%IncludeFont: New-Font';
  PriString(inblock);
  inblock:= '%%BeginFont: New-Font';
  PriString(inblock);
  inblock:= '/New-Font findfont 11.25 scalefont setfont'; {vorher 10, Peo}
  PriString(inblock);
  inblock:= '%%EndFont';
  PriString(inblock);
   {Times-Bold 10Pt*** proportional ***************************************}
{   inblock:= '%%IncludeFont: Times-Bold';
   PriString(inblock);
   inblock:= '%%BeginFont: Times-Bold';
   PriString(inblock);
   inblock:= '/Times-Bold findfont 10 scalefont setfont';
   PriString(inblock);
   inblock:= '%%EndFont';
   PriString(inblock);
}
   {Times-Italic 10Pt*** proportional ***************************************}
{   inblock:= '%%IncludeFont: Times-Italic';
   PriString(inblock);
   inblock:= '%%BeginFont: Times-Italic';
   PriString(inblock);
   inblock:= '/Times-Italic findfont 10 scalefont setfont';
   PriString(inblock);
   inblock:= '%%EndFont';
   PriString(inblock);
}
   {Times-BoldItalic 10Pt*** proportional ***************************************}
{   inblock:= '%%IncludeFont: Times-BoldItalic';
   PriString(inblock);
   inblock:= '%%BeginFont: Times-BoldItalic';
   PriString(inblock);
   inblock:= '/Times-BoldItalic findfont 10 scalefont setfont';
   PriString(inblock);
   inblock:= '%%EndFont';
   PriString(inblock);
}
   {Helvetica 8Pt*** proportional *******************************************}
   {8Pt Helvetica entsprÑche in der Hîhe dem Screen-Font, ist sehr schmal,
    was fÅr Trommelsprache und Liedsilben gut ist}
   {scheint auch als STANDARD-Font in Frage zu kommen / siehe auch 9Pt}
{   inblock:= '%%IncludeFont: Helvetica';
   PriString(inblock);
   inblock:= '%%BeginFont: Helvetica';
   PriString(inblock);
   inblock:= '/Helvetica findfont 8 scalefont setfont';
   PriString(inblock);
   inblock:= '%%EndFont';
   PriString(inblock);
}
   {Helvetica-Bold 8Pt*** proportional **************************************}
   {Entspricht in der Hîhe dem Bildschirm-Font, gut leserlich}
{   inblock:= '%%IncludeFont: Helvetica-Bold';
   PriString(inblock);
   inblock:= '%%BeginFont: Helvetica-Bold';
   PriString(inblock);
   inblock:= '/Helvetica-Bold findfont 8 scalefont setfont';
   PriString(inblock);
   inblock:= '%%EndFont';
   PriString(inblock);
}
   {Helvetica-Oblique 8Pt*** proportional ***********************************}
   {Entspricht in der Hîhe dem Bildschirm-Font, gut leserlich}
{   inblock:= '%%IncludeFont: Helvetica-Oblique';
   PriString(inblock);
   inblock:= '%%BeginFont: Helvetica-Oblique';
   PriString(inblock);
   inblock:= '/Helvetica-Oblique findfont 8 scalefont setfont';
   PriString(inblock);
   inblock:= '%%EndFont';
   PriString(inblock);
}
   {Helvetica-BoldOblique 8Pt*** proportional *******************************}
   {Entspricht in der Hîhe dem Bildschirm-Font, gut leserlich}
{   inblock:= '%%IncludeFont: Helvetica-BoldOblique';
   PriString(inblock);
   inblock:= '%%BeginFont: Helvetica-BoldOblique';
   PriString(inblock);
   inblock:= '/Helvetica-BoldOblique findfont 8 scalefont setfont';
   PriString(inblock);
   inblock:= '%%EndFont';
   PriString(inblock);
}
(*   {Helvetica 9Pt*** proportional *******************************************}
   {Als STANDARD-Font wahrscheinlich am besten geeignet}
   inblock:= '%%IncludeFont: Helvetica';
   PriString(inblock);
   inblock:= '%%BeginFont: Helvetica';
   PriString(inblock);
   inblock:= '/Helvetica findfont 11.25 scalefont setfont';
{   inblock:= '/Helvetica findfont 9 scalefont setfont';}
   PriString(inblock);
   inblock:= '%%EndFont';
   PriString(inblock);
  *)
   {Helvetica-Bold 9Pt*** proportional **************************************}
   {Gut fÅr Titel, Index-Seiten, Projektions-Folien etc.}
{   inblock:= '%%IncludeFont: Helvetica-Bold';
   PriString(inblock);
   inblock:= '%%BeginFont: Helvetica-Bold';
   PriString(inblock);
   inblock:= '/Helvetica-Bold findfont 9 scalefont setfont';
   PriString(inblock);
   inblock:= '%%EndFont';
   PriString(inblock);
}
   {Helvetica 10Pt*** proportional ******************************************}
   {FÅllt nach rechts am besten aus. Nicht geeignet fÅr CAPITAL words}
{   inblock:= '%%IncludeFont: Helvetica';
   PriString(inblock);
   inblock:= '%%BeginFont: Helvetica';
   PriString(inblock);
   inblock:= '/Helvetica findfont 10 scalefont setfont';
   PriString(inblock);
   inblock:= '%%EndFont';
   PriString(inblock);
}
   {Courier 8Pt*** nicht proportional ***************************************}
   {Dieser Font ist etwas fein. Kann aber sehr gut sein fÅr Technik und -
    Trommelsprache oder Liedersilben. FÅr Lesetext besser Courier-Bold*}
   {8Pt entspricht genau der Breite des Bildschirm-Fonts}
{   inblock:= '%%IncludeFont: Courier';
   PriString(inblock);
   inblock:= '%%BeginFont: Courier';
   PriString(inblock);
   inblock:= '/Courier findfont 8 scalefont setfont';
   PriString(inblock);
   inblock:= '%%EndFont';
   PriString(inblock);
}
   {Courier-Bold 8P*** nicht proportional *******************************************************}
   {Courier 8Pt entspricht genau dem Screen-Font-Breite, ist aber kleiner
    9 oder gar 10Pt entsprÑchen eher der Hîhe, brauchen aber mehr Breite}
{   inblock:= '%%IncludeFont: Courier-Bold';
   PriString(inblock);
   inblock:= '%%BeginFont: Courier-Bold';
   PriString(inblock);
   inblock:= '/Courier-Bold findfont 8 scalefont setfont';
   PriString(inblock);
   inblock:= '%%EndFont';
   PriString(inblock);
}
end;
{****************************************************************************}

procedure PriSetLineWidth(thick: real);
var inblock: stringline;
begin
  if ((psactwidth < (thick - 0.01)) or (psactwidth > (thick + 0.01))) then begin
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
  PriMove(PriRXScale(x) - ({Symfontsize/2}7.5), PriRYScale(y) - ({Symfontsize/2}7.5));
  inblock:= inblock + '(' + c + ') show';
  PriString(inblock);
end;

{***************************}
procedure PriWriteSym(c: char; x,y: real);
var inblock: stringline;
    ch : string[2];
begin
  if nff then begin
    inblock:='';
{    PriMove(PriRXScale(x) -7.5,PriRYScale(y) - 7.5);}
    PriMove(PriRXScale(x),PriRYScale(y));
    case c of
      'A'..'Z', 'a'..'z': ch:=c;
      #128..#153: ch:='a'+char(byte(c)-128+byte('a'));
      ' ': ch:='Blank';
    end; {case}
    inblock:='Sym'+ch;
    PriString(inblock);
  end else begin
    PriWriteChar(c,x,y);
  end;
end;
{***************************}
procedure PriLeftString(instring: stringline; x, y: real);
{linken Teil eines Strings schreiben}
var inblock: stringline;
begin
  inblock:=' ('+ instring + ') stringwidth pop ';
  PriString(inblock);
  inblock:=' ('+ instring[length(instring)] +
           ') stringwidth pop 2.0 div sub ';
  PriString(inblock);
  PriAddReal(inblock, x);
  inblock:= inblock + 'exch sub ';
  PriAddReal(inblock, y);
  inblock:= inblock + 'moveto';
  PriString(inblock);
  inblock:= '(' + instring + ') show';
  PriString(inblock);
end;

{***************************}
procedure PriComplString(inblock: stringline);
begin
  LastFileName:=FExpand(TextRec(psfile).Name);
  writeln(psfile,'(', inblock, ') show');
end;

{******************************************************************}
procedure PriHorizontalKlammer(ixmin, ixmax, iy: integer);
{Drucken einer geschweiften Klammer}
const delta=1.5;{4.0}
var xmin, xmax, x, y: real;
begin
  xmin:= PriXScale(ixmin);
  xmax:= PriXScale(ixmax);
  x:= (xmax + xmin)/2.0;
  y:= PriYScale(iy);
  PriSetLineWidth(0.5);
  PriMove(xmin, y + delta);
  PriArc(xmin + delta, y + delta, delta, 180.0, 270.0, ' ');
  PriMove(xmin + delta, y);
  PriLine(x - delta, y);
  PriStroke;
  PriMove(x - delta, y);
  PriArc(x - delta, y - delta, delta, 90.0, 0.0, 'n');
  PriArc(x + delta, y - delta, delta, 180.0, 90.0, 'n');
  PriMove(x + delta, y);
  PriLine(xmax - delta, y);
  PriStroke;
  PriMove(xmax - delta, y);
  PriArc(xmax - delta, y + delta, delta, 270.0, 0.0, ' ');
end;

{******************************************************************}
procedure PriVerticalKlammer(ix, iymin, iymax: integer);
{Drucken einer geschweiften Klammer}
const delta=1.5;{4.0}
var ymin, ymax, x, y: real;
begin
  ymin:= PriYScale(iymin);
  ymax:= PriYScale(iymax);
  y:= (ymax + ymin)/2.0;
  x:= PriXScale(ix);
  PriSetLineWidth(0.5);
  PriMove(x + delta, ymax);
  PriArc(x + delta, ymax - delta, delta, 90.0, 180.0, ' ');
  PriMove(x, ymax - delta);
  PriLine(x, y + delta);
  PriStroke;
  PriMove(x, y + delta);
  PriArc(x - delta, y + delta, delta, 0.0, 270.0, 'n');
  PriArc(x - delta, y - delta, delta, 90.0, 0.0, 'n');
  PriMove(x, y - delta);
  PriLine(x, ymin + delta);
  PriStroke;
  PriMove(x, ymin + delta);
  PriArc(x + delta, ymin + delta, delta, 180.0, 270.0, ' ');
end;

{******************************************************************}
procedure PriPostscript;
{Drucken auf ein Postscript File.}
var inblock: stringline;
    infile: text;
begin
  if not nff then begin
    inblock:= '%%IncludeFont: SymbolFont';       { Symbolfont anmelden       }
    PriString(inblock);
    inblock:= '%%BeginFont: SymbolFont';
    PriString(inblock);
    inblock:= '/SymbolFont findfont ';
    PriAddReal(inblock,symfontsize);
    inblock:=inblock+' scalefont setfont';
    PriString(inblock);
    inblock:= '%%EndFont';
    PriString(inblock);
  end;

  inblock:='gsave';
  PriString(inblock);
  inblock:='';                                 { Position                  }
  PriAddReal(inblock, psxmin*1.25);
  PriAddReal(inblock, psymin*1.25);
  inblock:=inblock+'translate';
  PriString(inblock);

  LastFileName:=FExpand(TextRec(psfile).Name);
  writeln(psfile,'gsave');
  writeln(psfile,'%%IncludeFont: New-Font');
  writeln(psfile,'%%BeginFont: New-Font');
  writeln(psfile,'/New-Font findfont 5 scalefont setfont');
  writeln(psfile,'%%EndFont');
  writeln(psfile,'-4 0 moveto');
  writeln(psfile,'90.0 rotate');
  writeln(psfile,'.0 setgray');
  writeln(psfile,'(R H Y T H M I C S   N O T A T I O N   S Y S T E M     r h y t h m i c s @ a c c e s s . c h) show');
{  writeln(psfile,'(C O P Y R I G H T    B Y    R H Y T H M I C S    C H  -  8 0 0 4   Z U E R I C H'+
                 '    + 4 1   1   7 3 0  3 7  3 7                                                       R H Y T H M I C S'+
                 '    N O T A T I O N    S Y S T E M) show');  }
  writeln(psfile,'grestore');

  {$IFDEF DEMO}      { Geschenk an nicht registrierte User...   ;-)))))))  }
  LastFileName:=FExpand(TextRec(psfile).Name);
  writeln(psfile,'gsave');
  writeln(psfile,'%%IncludeFont: New-Font');
  writeln(psfile,'%%BeginFont: New-Font');
  writeln(psfile,'/New-Font findfont 125 scalefont setfont');
  writeln(psfile,'%%EndFont');
  writeln(psfile,'45 20 moveto');
  writeln(psfile,'27.5 rotate');
  writeln(psfile,'.3 setgray');
  writeln(psfile,'(SPECIMEN) show');
  writeln(psfile,'grestore');
  {$ENDIF}
  writeln(psfile);
  if nff then
    writeln(psfile,'/Helvetica-Bold findfont 12 scalefont setfont');
  PagRefreshPage(0, 0, gmaxx, gmaxy);          { und los geht die Pixlerei }

  if ((prpage mod prformat) = 0) then begin    { Seite fertig?             }
    inblock:= 'showpage';                      { Seite anzeigen            }
    PriString(inblock);
    PriSetTopMargins;                          { nÑxtes Mal: obere HÑlfte  }
  end else begin
    PriSetBottomMargins;                       { nÑxtes Mal: untere HÑlfte }
  end;
  Inc(prpage);                                 { nÑchste Seite             }
  inblock:='grestore';
  PriString(inblock);
end;

{******************************************************************}
procedure PriPostscriptinit;
{Drucken auf ein Postscript File:
 Initialisierung}
var inblock, strbuf: stringline;
    infile: text;
begin
  if prfile = 1 then begin                      { PS-File îffnen            }
    Assign(psfile, psdir + '\' + prfname);
    LastFileName:=FExpand(psdir + '\' + prfname);
  end else begin
    Assign(psfile, 'psfile');
    LastFileName:=FExpand('PSFILE');
  end;
  rewrite(psfile);
  Writeln(psfile, '%!PS-Adobe-2.0 EPSF-2.0');   { Header schreiben          }
  inblock:= '%%BoundingBox:';                   { Boundingbox schreiben     }
  Str(cxmin:8:2, strbuf);
  inblock:= inblock + strbuf;
  if prformat = 1 then begin
    Str(cymintop:8:2, strbuf);
    inblock:= inblock + strbuf;
  end else begin
    Str(cyminbot:8:2, strbuf);
    inblock:= inblock + strbuf;
  end;
  Str(cxmax:8:2, strbuf);
  inblock:= inblock + strbuf;
  Str(cymaxtop:8:2, strbuf);
  inblock:= inblock + strbuf;
  writeln(psfile, inblock);
  writeln(psfile, '%%Creator: RNS');
  writeln(psfile, '%%EndComments');
  Assign(infile,'symbols.prn');                 { Zeichensatz kopieren      }
  LastFileName:=FExpand('SYMBOLS.PRN');

  reset(infile);
  readln(infile,inblock);
  if inblock='nff' then
    nff:=true
  else begin
{    readln(infile,inblock);readln(infile,inblock);readln(infile,inblock);}
  end;
  if not nff then
    PriGetFontHeight;
  inblock:= '';
  while Pos('******', inblock) = 0 do begin
    Readln(infile, inblock);
    LastFileName:=FExpand(psdir + '\' + prfname);
    Writeln(psfile, inblock);
    LastFileName:=FExpand('SYMBOLS.PRN');
  end;
  close(infile);
  priMakeUmlaute(psfile);
  printeron:= true;
  IniHideColors;
  prpage:= 1;
  psxmin:= cxmin;
  psxmax:= cxmax;
  PriSetTopMargins;

  inblock:='';                                 { Skalierung                }
  PriAddReal(inblock,0.8);
  PriAddReal(inblock,0.8);
  inblock:=inblock+' scale';
  PriString(inblock);
end;
{******************************************************************}
procedure PriPostscriptComplete;
var inblock: stringline;
    infile, lst: text;
begin
  if ((prformat = 2 ) and ((prpage mod prformat) = 0)) then begin
    PriSetTopMargins;
    inblock:= 'showpage';
    PriString(inblock);
  end;
  LastFileName:=FExpand(TextRec(PSFile).Name);
  close(psfile);
  IniIniColors;
  printeron:= false;
  if prfile = 0 then begin
    assign(lst, prdevice);
    assign(infile, 'psfile');
    LastFileName:=FExpand('PSFILE');
    reset(infile);
    LastFileName:=FExpand(TextRec(Lst).Name);
    rewrite(lst);
    while not eof(infile) do begin
      LastFileName:=FExpand('PSFILE');
      readln(infile, inblock);
      LastFileName:=FExpand(TextRec(Lst).Name);
      {$I-}
      writeln(lst, inblock);
      if IOResult<>0 then begin
        HlpHint(HntPrinterError,HintWaitEsc);
        Exit;
      end;
      {$I+}
    end;
    LastFileName:=FExpand(TextRec(Lst).Name);
    Close(Lst);
    LastFileName:=FExpand('PSFILE');
    Close(infile);
    HlpHint(HntPrintFinished,HintWaitEsc);
  end Else
    HlpHint(HntPrintToFileFinished,HintWaitEsc);
end;

procedure PriMakeUmlaute(var psfile : text);
begin
(*
  writeln(psfile,'/Aogonek % Aogonek');
  writeln(psfile,'{ currentpoint exch 3.5 add exch (A) show currentpoint 3 index 3 index moveto pop pop (\377) show moveto');
  writeln(psfile,'} def');
  writeln(psfile,'/Eogonek % Eogonek');
  writeln(psfile,'{ currentpoint exch 3.5 add exch (E) show currentpoint 3 index 3 index moveto pop pop (\377) show moveto');
  writeln(psfile,'} def');
*)
  { Umlaute in Schrift einsetzen                        }
  writeln(psfile,'/Helvetica findfont dup maxlength dict');
  { Kopieren aller Elemente bis auf FID:                }
  writeln(psfile,'/newdict exch def % Ziel-Dict');
  writeln(psfile,'{1 index /FID ne');
  writeln(psfile,'	{newdict 3 1 roll put');
  writeln(psfile,'	}');
  writeln(psfile,'	{pop pop % wenn FID: beides entfernen');
  writeln(psfile,'      } ifelse');
  writeln(psfile,'} forall');
  { /Encoding ist read-only                             }
  { Attribut wird mit copy nicht Åbertragen:            }
  writeln(psfile,'newdict /Encoding get dup length array copy');
  writeln(psfile,'newdict /Encoding 3 -1 roll put');
  { Direkt im dict ersetzen                             }
  writeln(psfile,'newdict begin');

  writeln(psfile,'Encoding 132 /adieresis put % Ñ ');
  writeln(psfile,'Encoding 142 /Adieresis put % é ');
  writeln(psfile,'Encoding 160 /aacute put % † ');
  writeln(psfile,'Encoding 133 /agrave put % Ö ');
  writeln(psfile,'Encoding 131 /acircumflex put % É ');
  writeln(psfile,'Encoding 134 /aring put % Ü ');
  writeln(psfile,'Encoding 143 /Aring put % è ');
  writeln(psfile,'Encoding 255 /ogonek put % ogonek ');

  writeln(psfile,'Encoding 130 /eacute put % Ç ');
  writeln(psfile,'Encoding 144 /Eacute put % ê ');
  writeln(psfile,'Encoding 138 /egrave put % ä ');
  writeln(psfile,'Encoding 136 /ecircumflex put % à ');
  writeln(psfile,'Encoding 137 /edieresis put % â ');

  writeln(psfile,'Encoding 139 /idieresis put % ã ');
  writeln(psfile,'Encoding 161 /iacute put % ° ');
  writeln(psfile,'Encoding 141 /igrave put % ç ');
  writeln(psfile,'Encoding 140 /icircumflex put % å ');
  writeln(psfile,'Encoding 152 /ydieresis put % ò ');

  writeln(psfile,'Encoding 148 /odieresis put % î ');
  writeln(psfile,'Encoding 153 /Odieresis put % ô ');
  writeln(psfile,'Encoding 162 /oacute put % ¢ ');
  writeln(psfile,'Encoding 149 /ograve put % ï ');
  writeln(psfile,'Encoding 147 /ocircumflex put % ì ');

  writeln(psfile,'Encoding 129 /udieresis put % Å ');
  writeln(psfile,'Encoding 154 /Udieresis put % ö ');
  writeln(psfile,'Encoding 163 /uacute put % £ ');
  writeln(psfile,'Encoding 151 /ugrave put % ó ');
  writeln(psfile,'Encoding 150 /ucircumflex put % ñ ');

  writeln(psfile,'Encoding 126 /tilde put % ~ ');
  writeln(psfile,'Encoding 164 /ntilde put % § ');
  writeln(psfile,'Encoding 165 /Ntilde put % • ');

  writeln(psfile,'Encoding 168 /questiondown put % ® ');
  writeln(psfile,'Encoding 173 /exclamdown put % ≠ ');
  writeln(psfile,'Encoding 174 /guillemotleft put % Æ ');
  writeln(psfile,'Encoding 175 /guillemotright put % Ø ');

  writeln(psfile,'Encoding 135 /ccedilla put % á ');
  writeln(psfile,'Encoding 128 /Ccedilla put % Ä ');

  writeln(psfile,'Encoding 225 /germandbls put % Doppel-s '); {stand.-encoding 251(373 okt.}

  writeln(psfile,'Encoding 179 /bar put % ≥ ');
  writeln(psfile,'Encoding 196 /emdash put % ƒ ');
{  writeln(psfile,'Encoding 221 /... put % › '); fÅr kl. 1 verw., @ fÅr kl. 2}

  writeln(psfile,'Encoding 248 /ring put % ¯ ');
  writeln(psfile,'Encoding 21 /section put %  ');

  writeln(psfile,'Encoding 123 /braceleft put % { ');
  writeln(psfile,'Encoding 125 /braceright put % } ');

  {ZusÑtzlich: nicht kodierte Zeichen wie Iacute, Egrave etc. PS Seite 844}

  writeln(psfile,'end');
  { Newdict definieren                                  }
  writeln(psfile,'newdict /FontName (New-Font) put');
  writeln(psfile,'/New-Font newdict definefont pop');
End;

{******************************************************************}

procedure PriDrawFrame(x0,y0,x1,y1 : integer);
Begin
  writeln(psfile,'2 setlinecap');
  PriNewPath;
  PriMove(PriXscale(x0), PriYscale(y0));
  PriLine(PriXscale(x1), PriYscale(y0));
  PriLine(PriXscale(x1), PriYscale(y1));
  PriLine(PriXscale(x0), PriYscale(y1));
  PriLine(PriXscale(x0), PriYscale(y0));
  PriStroke;
  writeln(psfile,'0 setlinecap');
End;
end.