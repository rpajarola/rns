{$I RNS.H}

Unit printunit;

Interface

Uses
    initsc,
    crt,
    DOS,
    HelpUnit,
    Texts,
    SysUtils;
{Hier werden Raender von 2 File-Seiten auf A4 definiert:}
{  0.0 Punkte = unterer Blattrand des amerik.Formats!?}
{2.8 Punkte entsprechen etwa 1mm}
{unter 63 stellt Epson den untern Rand nicht mehr dar!}
{Randabstaende zu A5 muessen sich leider danach richten!}
{446.5 Punkte = ca. Hoehen-Mitte des A4-Blattes}
{657.5 Punkte = ca. Hoehen-Mitte der 1.File-Seite}
{235.5 Punkte = ca. Hoehen-Mitte der 2.File-Seite}
Const cxmin = 46.0;    {links-rechts Verschiebung}{linker  Rand}
    cxmax = 558.0;                               {rechter Rand}

    cymaxtop = 829.0; {1.File-Seite Rand oben : Abstand vom untern Blattrand}
    cymintop = 486.0; {1.File-Seite Rand unten: Abstand vom untern Blattrand}
    {Diff1:  343.0}{Diff1 und Diff 2 muessen gleich gross sein *}

    cymaxbot = 407.0; {2.File-Seite Rand oben : Abstand vom untern Blattrand}
    cyminbot = 64.0; {2.File-Seite Rand unten: Abstand vom untern Blattrand}
{Diff2:  343.0}{je groesser die Differenz desto hoeher die File-Seite}

Var psactwidth: real;
    psxmin, psxmax, psymin, psymax: real;

Function PriPostscriptinit: Boolean;
Function PriPostscriptComplete: Boolean;
Procedure PriPostscript;
Function PriXScale(x: integer): real;
Function PriYScale(y: integer): real;
Function PriRXScale(x: real): real;
Function PriRYScale(y: real): real;
Procedure PriString(Var inblock: stringline);
Procedure PriAddreal(Var inblock: stringline; r: real);
Procedure PriLine(rx, ry: real);
Procedure PriMove(rx, ry: real);
Procedure PriStroke;
Procedure PriNewpath;
Procedure PriDrawLine(x0, y0, x1, y1: integer);
Procedure PriRDrawLine(x0, y0, x1, y1: real);
Procedure PriSetLineWidth(thick: real);
Procedure PriWriteChar(c: char; x, y: real);
Procedure PriWriteSym(c: char; x, y: real);
Procedure PriClosepath;
Procedure PriPlaceString(x, y: real; inblock: stringline);
Procedure PriSwapFont;
Procedure PriLeftString(instring: stringline; x, y: real);
Procedure PriComplString(inblock: stringline);
Procedure PriArc(rx, ry, rad, startw, endw: real; c: char);
Procedure PriHorizontalKlammer(ixmin, ixmax, iy: integer);
Procedure PriVerticalKlammer(ix, iymin, iymax: integer);
Procedure PriReSetDash;
Procedure PriSetDash(llength, distlength: real);
Procedure PriMakeUmlaute(Var psfile: text);
Procedure PriSetTopMargins;
Procedure PriSetBottomMargins;
Procedure PriDrawFrame(x0, y0, x1, y1: integer);

Implementation

Uses pageunit;


{*************************************************************}
Procedure PriGetFontHeight;
Var instring: stringline;
    a, b: integer;
    F: Text;
Begin
    { if anything goes wrong, use default font size }
    Symfontsize := 15;
    Assign (F, 'SYMBOLS.PRN');
    ReSet (F);
    If IOResult <> 0 Then
        Exit;
    While NOT eof (f) Do
    Begin
        ReadLn (f, instring);
        If IOResult <> 0 Then
        Begin
            Close (F);
            exit;
        End;
        instring := upstring (instring);
        If (pos ('SCALEFONT', instring) <> 0) AND
            (pos ('/SYMBOLFONT', instring) <> 0) Then
        Begin
            a := pos ('SCALEFONT', instring) - 2;
            b := 0;
            While (instring[a - b] <> ' ') Do
                inc (b);
            a := a - b + 1;
            val (copy (instring, a, b), a, b);
            If b <> 0 Then
                Symfontsize := 15
            Else
                Symfontsize := a;
            Close (F);
            exit;
        End;
    End;
    Close (F);
End;

{*************************************************************}
Procedure PriSetTopMargins;
Begin
    psymin := cymintop;
    psymax := cymaxtop;
End;

{*************************************************************}
Procedure PriSetBottomMargins;
Begin
    psymin := cyminbot;
    psymax := cymaxbot;
End;

{******************************************************************}
Procedure PriDrawLine(x0, y0, x1, y1: integer);
{Schreibt eine Line mit Displaycoordinaten in das Postscriptfile}
Begin
    PriNewPath;
    PriMove (PriXscale (x0), PriYscale (y0));
    PriLine (PriXscale (x1), PriYscale (y1));
    PriStroke;
End;
{******************************************************************}
Procedure PriRDrawLine(x0, y0, x1, y1: real);
{Schreibt eine Line mit Displaycoordinaten in das Postscriptfile}
Begin
    PriNewPath;
    PriMove (PriRXscale (x0), PriRYscale (y0));
    PriLine (PriRXscale (x1), PriRYscale (y1));
    PriStroke;
End;

{******************************************************************}
Function PriRXScale(x: real): real;
{Wandelt einen x-real coordinatenwert am Bildschirm in einen
 x-Wert fuer das Postscriptfile um}

Begin{46+x*512/639}
    PriRXScale := x;{ psxmin + (x - grminx) * (psxmax - psxmin) / (grmaxx - grminx);}
End;

{******************************************************************}
Function PriXScale(x: integer): real;
{Wandelt einen x-coordinatenwert am Bildschirm in einen
 x-Wert fuer das Postscriptfile um}

Begin
    PriXScale := PriRXScale (1.0 * x);
End;

{******************************************************************}
Function PriRYScale(y: real): real;
{Wandelt einen y-real coordinatenwert am Bildschirm in einen
 y-Wert fuer das Postscriptfile um}


Begin{829-y*343/424}
    PriRYScale := grmaxy - y;{psymax - (y - grminy) * (psymax - psymin) / (grmaxy - grminy);}
End;

{******************************************************************}
Function PriYScale(y: integer): real;
{Wandelt einen y-coordinatenwert am Bildschirm in einen
 y-Wert fuer das Postscriptfile um}

Begin
    PriYScale := PriRYScale (1.0 * y);
End;

{***************************}
Procedure PriString(Var inblock: stringline);
Begin
    writeln (psfile, inblock);
    inblock := '';
End;

{***************************}
Procedure PriPlaceString(x, y: real; inblock: stringline);
Begin
    PriMove (x, y);
    writeln (psfile, '(', inblock, ') show');
End;

{***************************}
Procedure PriAddreal(Var inblock: stringline; r: real);

Var rstring: string[16];

Begin
    Str (r: 6: 3, rstring);
    inblock := inblock + rstring + ' ';
End;

{***************************}
Procedure PriLine(rx, ry: real);

Var inblock: stringline;

Begin
    inblock := '';
    PriAddreal (inblock, rx);
    PriAddreal (inblock, ry);
    inblock := inblock + 'lineto';
    PriString (inblock);
End;

{***************************}
Procedure PriSetDash(llength, distlength: real);

Var inblock: stringline;

Begin
    inblock := '[';
    PriAddreal (inblock, llength);
    PriAddreal (inblock, distlength);
    inblock := inblock + '] 0.0 setdash';
    PriString (inblock);
End;

{***************************}
Procedure PriReSetDash;

Var inblock: stringline;

Begin
    inblock := '[] 0.0 setdash';
    PriString (inblock);
End;
{***************************}
Procedure PriArc(rx, ry, rad, startw, endw: real; c: char);

Var inblock: stringline;

Begin
    PriNewPath;
    inblock := '';
    PriAddreal (inblock, rx);
    PriAddreal (inblock, ry);
    PriAddreal (inblock, rad);
    PriAddreal (inblock, startw);
    PriAddreal (inblock, endw);
    inblock := inblock + 'arc' + c;
    PriString (inblock);
    PriStroke;
End;
{***************************}
Procedure PriMove(rx, ry: real);

Var inblock: stringline;

Begin
    inblock := '';
    PriAddreal (inblock, rx);
    PriAddreal (inblock, ry);
    inblock := inblock + 'moveto';
    PriString (inblock);
End;

{***************************}
Procedure PriClosepath;

Var inblock: stringline;

Begin
    inblock := ' closepath ';
    PriString (inblock);
End;

{***************************}
Procedure PriStroke;

Var inblock: stringline;

Begin
    inblock := ' stroke ';
    PriString (inblock);
End;

{***************************}
Procedure PriNewpath;

Var inblock: stringline;

Begin
    inblock := ' newpath ';
    PriString (inblock);
End;
{****************************************************************************}

Procedure PriSwapFont;

Var inblock: stringline;

Begin  {in Print-Options zur Auswahl geben}
{ Font. Pleae do not change. Denn hier (und _nur_ hier) sind ae oe und ue
  bereits eingebaut.
  Fontwechsel bitte woanders erledigen.
}
    inblock := '%%IncludeFont: New-Font';
    PriString (inblock);
    inblock := '%%BeginFont: New-Font';
    PriString (inblock);
    inblock := '/New-Font findfont 11.25 scalefont setfont'; {vorher 10, Peo}
    PriString (inblock);
    inblock := '%%EndFont';
    PriString (inblock);
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
   {8Pt Helvetica entspraeche in der Hoehe dem Screen-Font, ist sehr schmal,
    was fuer Trommelsprache und Liedsilben gut ist}
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
    {Entspricht in der Hoehe dem Bildschirm-Font, gut leserlich}
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
    {Entspricht in der Hoehe dem Bildschirm-Font, gut leserlich}
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
    {Entspricht in der Hoehe dem Bildschirm-Font, gut leserlich}
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
    {Gut fuer Titel, Index-Seiten, Projektions-Folien etc.}
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
    {Fuellt nach rechts am besten aus. Nicht geeignet fuer CAPITAL words}
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
   {Dieser Font ist etwas fein. Kann aber sehr gut sein fuer Technik und -
    Trommelsprache oder Liedersilben. Fuer Lesetext besser Courier-Bold*}
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
    9 oder gar 10Pt entspraechen eher der Hoehe, brauchen aber mehr Breite}
{   inblock:= '%%IncludeFont: Courier-Bold';
   PriString(inblock);
   inblock:= '%%BeginFont: Courier-Bold';
   PriString(inblock);
   inblock:= '/Courier-Bold findfont 8 scalefont setfont';
   PriString(inblock);
   inblock:= '%%EndFont';
   PriString(inblock);
}
End;
{****************************************************************************}

Procedure PriSetLineWidth(thick: real);
Var inblock: stringline;
Begin
    If ((psactwidth < (thick - 0.01)) OR (psactwidth > (thick + 0.01))) Then
    Begin
        inblock := '';
        PriAddReal (inblock, thick);
        inblock := inblock + ' setlinewidth';
        PriString (inblock);
        psactwidth := thick;
    End;
End;

{***************************}
Procedure PriWriteChar(c: char; x, y: real);
Var inblock: stringline;
Begin
    inblock := '';
    PriMove (PriRXScale (x) - ({Symfontsize/2}7.5), PriRYScale (y) - ({Symfontsize/2}7.5));
    inblock := inblock + '(' + c + ') show';
    PriString (inblock);
End;

{***************************}
Procedure PriWriteSym(c: char; x, y: real);
Var inblock: stringline;
    ch: string;
Begin
    If nff Then
    Begin
        inblock := '';
        {    PriMove(PriRXScale(x) -7.5,PriRYScale(y) - 7.5);}
        PriMove (PriRXScale (x), PriRYScale (y));
        Case c Of
            'A'..'Z', 'a'..'z': ch := c;
            #128..#153: ch := 'a' + char (byte (c) - 128 + byte ('a'));
            ' ': ch := 'Blank';
        End; {case}
        inblock := 'Sym' + ch;
        PriString (inblock);
    End Else PriWriteChar (c, x, y);
End;
{***************************}
Procedure PriLeftString(instring: stringline; x, y: real);
{linken Teil eines Strings schreiben}
Var inblock: stringline;
Begin
    inblock := ' (' + instring + ') stringwidth pop ';
    PriString (inblock);
    inblock := ' (' + instring[length (instring)] +
        ') stringwidth pop 2.0 div sub ';
    PriString (inblock);
    PriAddReal (inblock, x);
    inblock := inblock + 'exch sub ';
    PriAddReal (inblock, y);
    inblock := inblock + 'moveto';
    PriString (inblock);
    inblock := '(' + instring + ') show';
    PriString (inblock);
End;

{***************************}
Procedure PriComplString(inblock: stringline);
Begin
    writeln (psfile, '(', inblock, ') show');
End;

{******************************************************************}
Procedure PriHorizontalKlammer(ixmin, ixmax, iy: integer);
{Drucken einer geschweiften Klammer}
Const delta = 1.5;{4.0}
Var xmin, xmax, x, y: real;
Begin
    xmin := PriXScale (ixmin);
    xmax := PriXScale (ixmax);
    x := (xmax + xmin) / 2.0;
    y := PriYScale (iy);
    PriSetLineWidth (0.5);
    PriMove (xmin, y + delta);
    PriArc (xmin + delta, y + delta, delta, 180.0, 270.0, ' ');
    PriMove (xmin + delta, y);
    PriLine (x - delta, y);
    PriStroke;
    PriMove (x - delta, y);
    PriArc (x - delta, y - delta, delta, 90.0, 0.0, 'n');
    PriArc (x + delta, y - delta, delta, 180.0, 90.0, 'n');
    PriMove (x + delta, y);
    PriLine (xmax - delta, y);
    PriStroke;
    PriMove (xmax - delta, y);
    PriArc (xmax - delta, y + delta, delta, 270.0, 0.0, ' ');
End;

{******************************************************************}
Procedure PriVerticalKlammer(ix, iymin, iymax: integer);
{Drucken einer geschweiften Klammer}
Const delta = 1.5;{4.0}
Var ymin, ymax, x, y: real;
Begin
    ymin := PriYScale (iymin);
    ymax := PriYScale (iymax);
    y := (ymax + ymin) / 2.0;
    x := PriXScale (ix);
    PriSetLineWidth (0.5);
    PriMove (x + delta, ymax);
    PriArc (x + delta, ymax - delta, delta, 90.0, 180.0, ' ');
    PriMove (x, ymax - delta);
    PriLine (x, y + delta);
    PriStroke;
    PriMove (x, y + delta);
    PriArc (x - delta, y + delta, delta, 0.0, 270.0, 'n');
    PriArc (x - delta, y - delta, delta, 90.0, 0.0, 'n');
    PriMove (x, y - delta);
    PriLine (x, ymin + delta);
    PriStroke;
    PriMove (x, ymin + delta);
    PriArc (x + delta, ymin + delta, delta, 180.0, 270.0, ' ');
End;

{******************************************************************}
Procedure PriPostscript;
{Drucken auf ein Postscript File.}
Var inblock: stringline;
Begin
    If NOT nff Then
    Begin
        inblock := '%%IncludeFont: SymbolFont';       { Symbolfont anmelden       }
        PriString (inblock);
        inblock := '%%BeginFont: SymbolFont';
        PriString (inblock);
        inblock := '/SymbolFont findfont ';
        PriAddReal (inblock, symfontsize);
        inblock := inblock + ' scalefont setfont';
        PriString (inblock);
        inblock := '%%EndFont';
        PriString (inblock);
    End;

    inblock := 'gsave';
    PriString (inblock);
    inblock := '';                                 { Position                  }
    PriAddReal (inblock, psxmin * 1.25);
    PriAddReal (inblock, psymin * 1.25);
    inblock := inblock + 'translate';
    PriString (inblock);

    writeln (psfile, 'gsave');
    writeln (psfile, '%%IncludeFont: New-Font');
    writeln (psfile, '%%BeginFont: New-Font');
    writeln (psfile, '/New-Font findfont 5 scalefont setfont');
    writeln (psfile, '%%EndFont');
    writeln (psfile, '-4 0 moveto');
    writeln (psfile, '90.0 rotate');
    writeln (psfile, '.0 setgray');
    writeln (psfile, '(R H Y T H M I C S   N O T A T I O N   S Y S T E M     r h y t h m i c s @ a c c e s s . c h) show');
{  writeln(psfile,'(C O P Y R I G H T    B Y    R H Y T H M I C S    C H  -  8 0 0 4   Z U E R I C H'+
                 '    + 4 1   1   7 3 0  3 7  3 7                                                       R H Y T H M I C S'+
                 '    N O T A T I O N    S Y S T E M) show');  }
    writeln (psfile, 'grestore');

    writeln (psfile);
    If nff Then
        writeln (psfile, '/Helvetica-Bold findfont 12 scalefont setfont');
    PagRefreshPage (0, 0, gmaxx, gmaxy);          { und los geht die Pixlerei }

    If ((prpage MOD prformat) = 0) Then
    Begin    { Seite fertig?             }
        inblock := 'showpage';                      { Seite anzeigen            }
        PriString (inblock);
        PriSetTopMargins;                          { naextes Mal: obere Haelfte  }
    End Else PriSetBottomMargins{ naextes Mal: untere Haelfte };
    Inc (prpage);                                 { naechste Seite             }
    inblock := 'grestore';
    PriString (inblock);
End;

{******************************************************************}
Function PriPostscriptinit: Boolean;
{Drucken auf ein Postscript File:
 Initialisierung}
Var inblock, strbuf: stringline;
    infile: text;
    filename: string;
Begin
    PriPostscriptinit := False; { Default to failure }
    If prfile = 1 Then
    Begin                      { PS-File oeffnen            }
        Assign (psfile, ConcatPaths ([psdir, prfname]));
        filename := FExpand (ConcatPaths ([psdir, prfname]));
    End Else Begin
        Assign (psfile, 'psfile');
        filename := FExpand ('psfile');
    End;
    rewrite (psfile);
    If IOResult <> 0 Then
    Begin
        HlpHint (HntCannotCreateFile, HintWaitEsc, ['psfile']);
        exit;
    End;
    Writeln (psfile, '%!PS-Adobe-2.0 EPSF-2.0');   { Header schreiben          }
    inblock := '%%BoundingBox:';                   { Boundingbox schreiben     }
    Str (cxmin: 8: 2, strbuf);
    inblock := inblock + strbuf;
    If prformat = 1 Then
    Begin
        Str (cymintop: 8: 2, strbuf);
        inblock := inblock + strbuf;
    End Else Begin
        Str (cyminbot: 8: 2, strbuf);
        inblock := inblock + strbuf;
    End;
    Str (cxmax: 8: 2, strbuf);
    inblock := inblock + strbuf;
    Str (cymaxtop: 8: 2, strbuf);
    inblock := inblock + strbuf;
    writeln (psfile, inblock);
    writeln (psfile, '%%Creator: RNS');
    writeln (psfile, '%%EndComments');
    Assign (infile, 'symbols.prn');                 { Zeichensatz kopieren      }
    reset (infile);
    If IOResult <> 0 Then
    Begin
        close (psfile);
        HlpHint (HntFontFileNotFound, HintWaitEsc, ['symbols.prn']);
        exit;
    End;
    readln (infile, inblock);
    If IOResult <> 0 Then
    Begin
        close (infile);
        close (psfile);
        HlpHint (HntCannotReadFile, HintWaitEsc, ['symbols.prn']);
        exit;
    End;
    If inblock = 'nff' Then
        nff := true
    Else {    readln(infile,inblock);readln(infile,inblock);readln(infile,inblock);};
    If NOT nff Then
        PriGetFontHeight;
    inblock := '';
    While Pos ('******', inblock) = 0 Do
    Begin
        Readln (infile, inblock);
        If IOResult <> 0 Then
        Begin
            close (infile);
            close (psfile);
            HlpHint (HntCannotReadFile, HintWaitEsc, ['symbols.prn']);
            exit;
        End;
        Writeln (psfile, inblock);
        If IOResult <> 0 Then
        Begin
            close (infile);
            close (psfile);
            HlpHint (HntCannotWriteFile, HintWaitEsc, ['symbols.prn']);
            exit;
        End;
    End;
    close (infile);
    priMakeUmlaute (psfile);
    printeron := true;
    IniHideColors;
    prpage := 1;
    psxmin := cxmin;
    psxmax := cxmax;
    PriSetTopMargins;

    inblock := '';                                 { Skalierung                }
    PriAddReal (inblock, 0.8);
    PriAddReal (inblock, 0.8);
    inblock := inblock + ' scale';
    PriString (inblock);
    PriPostscriptinit := True; { Success }
End;
{******************************************************************}
Function PriPostscriptComplete: Boolean;
Var inblock: stringline;
    infile, lst: text;
Begin
    PriPostscriptComplete := False; { Default to failure }
    If ((prformat = 2) AND ((prpage MOD prformat) = 0)) Then
    Begin
        PriSetTopMargins;
        inblock := 'showpage';
        PriString (inblock);
    End;
    close (psfile);
    IniIniColors;
    printeron := false;
    If prfile = 0 Then
    Begin
        assign (lst, prdevice);
        assign (infile, 'psfile');
        reset (infile);
        If IOResult <> 0 Then
        Begin
            HlpHint (HntCannotOpenTempFile, HintWaitEsc, []);
            exit;
        End;
        rewrite (lst);
        If IOResult <> 0 Then
        Begin
            close (infile);
            HlpHint (HntPrinterError, HintWaitEsc, [prdevice]);
            exit;
        End;
        While NOT eof (infile) Do
        Begin
            readln (infile, inblock);
            If IOResult <> 0 Then
            Begin
                close (infile);
                close (lst);
                HlpHint (HntCannotReadFile, HintWaitEsc, ['psfile']);
                exit;
            End;
            writeln (lst, inblock);
            If IOResult <> 0 Then
            Begin
                close (infile);
                close (lst);
                HlpHint (HntPrinterError, HintWaitEsc, [prdevice]);
                exit;
            End;
        End;
        Close (Lst);
        Close (infile);
        HlpHint (HntPrintFinished, HintWaitEsc, [prdevice]);
    End Else
        HlpHint (HntPrintToFileFinished, HintWaitEsc, ['psfile']);
    PriPostscriptComplete := True; { Success }
End;

Procedure PriMakeUmlaute(Var psfile: text);
Begin
    { Umlaute in Schrift einsetzen                        }
    writeln (psfile, '/Helvetica findfont dup maxlength dict');
    { Kopieren aller Elemente bis auf FID:                }
    writeln (psfile, '/newdict exch def % Ziel-Dict');
    writeln (psfile, '{1 index /FID ne');
    writeln (psfile, '	{newdict 3 1 roll put');
    writeln (psfile, '	}');
    writeln (psfile, '	{pop pop % wenn FID: beides entfernen');
    writeln (psfile, '      } ifelse');
    writeln (psfile, '} forall');
    { /Encoding ist read-only                             }
    { Attribut wird mit copy nicht uebertragen:            }
    writeln (psfile, 'newdict /Encoding get dup length array copy');
    writeln (psfile, 'newdict /Encoding 3 -1 roll put');
    { Direkt im dict ersetzen                             }
    writeln (psfile, 'newdict begin');

    writeln (psfile, 'Encoding 132 /adieresis put % ' + #132);
    writeln (psfile, 'Encoding 142 /Adieresis put % ' + #142);
    writeln (psfile, 'Encoding 160 /aacute put % ' + #160);
    writeln (psfile, 'Encoding 133 /agrave put % ' + #133);
    writeln (psfile, 'Encoding 131 /acircumflex put %' + #131);
    writeln (psfile, 'Encoding 134 /aring put % ' + #134);
    writeln (psfile, 'Encoding 143 /Aring put % ' + #143);
    writeln (psfile, 'Encoding 255 /ogonek put % ogonek ');

    writeln (psfile, 'Encoding 130 /eacute put % ' + #130);
    writeln (psfile, 'Encoding 144 /Eacute put % ' + #144);
    writeln (psfile, 'Encoding 138 /egrave put % ' + #138);
    writeln (psfile, 'Encoding 136 /ecircumflex put % ' + #136);
    writeln (psfile, 'Encoding 137 /edieresis put % ' + #137);

    writeln (psfile, 'Encoding 139 /idieresis put % ' + #139);
    writeln (psfile, 'Encoding 161 /iacute put % ' + #161);
    writeln (psfile, 'Encoding 141 /igrave put % ' + #141);
    writeln (psfile, 'Encoding 140 /icircumflex put % ' + #140);
    writeln (psfile, 'Encoding 152 /ydieresis put % ' + #152);

    writeln (psfile, 'Encoding 148 /odieresis put % ' + #148);
    writeln (psfile, 'Encoding 153 /Odieresis put % ' + #153);
    writeln (psfile, 'Encoding 162 /oacute put % ' + #162);
    writeln (psfile, 'Encoding 149 /ograve put % ' + #149);
    writeln (psfile, 'Encoding 147 /ocircumflex put ' + #147);

    writeln (psfile, 'Encoding 129 /udieresis put % ' + #129);
    writeln (psfile, 'Encoding 154 /Udieresis put % ' + #154);
    writeln (psfile, 'Encoding 163 /uacute put % ' + #163);
    writeln (psfile, 'Encoding 151 /ugrave put % ' + #151);
    writeln (psfile, 'Encoding 150 /ucircumflex put % ' + #150);

    writeln (psfile, 'Encoding 126 /tilde put % ' + #126);
    writeln (psfile, 'Encoding 164 /ntilde put % ' + #164);
    writeln (psfile, 'Encoding 165 /Ntilde put % ' + #165);

    writeln (psfile, 'Encoding 168 /questiondown put % ' + #168);
    writeln (psfile, 'Encoding 173 /exclamdown put % ' + #173);
    writeln (psfile, 'Encoding 174 /guillemotleft put % ' + #174);
    writeln (psfile, 'Encoding 175 /guillemotright put % ' + #175);

    writeln (psfile, 'Encoding 135 /ccedilla put % ' + #135);
    writeln (psfile, 'Encoding 128 /Ccedilla put % ' + #128);

    writeln (psfile, 'Encoding 225 /germandbls put % Doppel-s '); {stand.-encoding 251(373 okt.}

    writeln (psfile, 'Encoding 179 /bar put % ' + #179);
    writeln (psfile, 'Encoding 196 /emdash put % ' + #196);

    writeln (psfile, 'Encoding 248 /ring put % ' + #248);
    writeln (psfile, 'Encoding 21 /section put % ' + #21);

    writeln (psfile, 'Encoding 123 /braceleft put % { ');
    writeln (psfile, 'Encoding 125 /braceright put % } ');

    {Zusaetzlich: nicht kodierte Zeichen wie Iacute, Egrave etc. PS Seite 844}

    writeln (psfile, 'end');
    { Newdict definieren                                  }
    writeln (psfile, 'newdict /FontName (New-Font) put');
    writeln (psfile, '/New-Font newdict definefont pop');
End;

{******************************************************************}

Procedure PriDrawFrame(x0, y0, x1, y1: integer);
Begin
    writeln (psfile, '2 setlinecap');
    PriNewPath;
    PriMove (PriXscale (x0), PriYscale (y0));
    PriLine (PriXscale (x1), PriYscale (y0));
    PriLine (PriXscale (x1), PriYscale (y1));
    PriLine (PriXscale (x0), PriYscale (y1));
    PriLine (PriXscale (x0), PriYscale (y0));
    PriStroke;
    writeln (psfile, '0 setlinecap');
End;
End.
