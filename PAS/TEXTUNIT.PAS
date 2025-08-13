unit textunit;

interface

uses
   initsc,
   gcurunit,
   symbols,
   graph,
   Pageunit;

Procedure TexDelChar(linenum : integer; var actpos: integer);
Procedure TexInsChar(linenum, actpos: integer);
Procedure TexEdTextLine(linenum: integer; var actpos : integer; c : char);
Procedure TexDrawLine(linenum, startx: integer);
Procedure TexTxtPosX(var x, actpost : integer; linenum: integer;
                      cursormove: boolean);
Procedure TexActPosX(var x, actpost : integer; linenum: integer;
                     cursormove: boolean);
Procedure TexEndVKlammer(linenum, actpos, x: integer);
Procedure TexEndHKlammer(linenum: integer; actpos: integer);
Function TexTabWidth(x, linenum, ordc: integer;
                     cursormove: boolean; var xnote,totw: integer) : integer;
Procedure TexDelToEOL(linenum, actpos: integer);
Procedure TexClearLine(linenum, startx: integer);
Procedure TexWordLeft(Var Linenum,Actpos : Integer);
Procedure TexWordRight(Var Linenum,Actpos : Integer);
Function  TexGetText(Linenum : Integer) : String;
Procedure TexSetText(Linenum : Integer;S : String);
implementation

uses getunit,
     printunit,
     titleunit;
const yshift = -3.0;

{******************************************************}
Procedure TexDelToEOL(linenum, actpos: integer);
var x : integer;
begin
  Delete(page[linenum], actpos + 1, length(page[linenum]));
  page[linenum, actpos]:= ' ';
  TexActPosX(x, actpos, linenum, false);
end;

Procedure TexEndHKlammer(linenum: integer; actpos: integer);
{Ende einer waagrechten Klammer}
Var XE,XS,XM : integer;
    Y        : integer;
    PS       : integer;
    found    : boolean;
    c        : integer;
begin
  IniCharAdd(Page[linenum],#232,actpos);
  c:=getcolor;
  y:=IniYnow(linenum)-2;
  TexActPosX(xe, actpos, linenum, false);
  { suche Beginn der Klammer }
  Found:=False;
  For PS:=ActPos-1 Downto LineMarker do begin
    if page[linenum, PS] = #231 then begin
      Found:=True;
      Break;
    end;
  end;
  { fÅlle Zeichen fÅr Klammer ein }
  if printeron and found Then begin
    TexActPosX(XS, PS, linenum, false);
    PriHorizontalKlammer(XS-4,XE+4, y+4);
  end else begin
    SymHKlammerEnd(xe, y);
    if found then begin
      TexActPosX(XS, PS, linenum, false);
      SetLineStyle(solidln, 0, 1);
      Line(XS+4,y+4,XE-4,y+4);
      xm:=(XS+XE) shr 1;
      if (XE-XS)<8 Then Begin   { Klammern zu nahe beieinander }
        SymHKlammerSmallMid(xm,y);
      End Else Begin
        SymHKlammerNormMid(xm, y)
      End;
    End;
  end;
end;
{******************************************************}
Procedure TexEndVKlammer(linenum, actpos, x: integer);
{Ende einer senkrechten Klammer}
var sline, midline, i : byte;
    foundflag : boolean;
begin
  SetLineStyle(solidln,0,1);
  IniCharAdd(Page[linenum], chr(230), actpos);
  sline:= linenum;
  foundflag:= false;
{suche Beginn der Klammer}
  repeat
    if ((page[sline, 1] = 'T') and
        (length(page[sline]) >= actpos) and
        (page[sline, actpos] = chr(229))) then begin
      foundflag:= true;
    end else begin
      dec(sline);
    end;
  until ((foundflag) or (sline < topmargin));
{fÅlle Zeichen fÅr Klammer ein}
  if foundflag then begin
    TexActPosX(x, actpos, linenum, false);
    midline:= (sline + linenum) SHR 1;
    for i:= (sline + 1) to midline - 1 do
      if abs(sline-linenum)>2 then begin
        SymVKlammerCont(x-8, IniYnow(i));
      end;
      if ((2 * midline) = (sline + linenum)) then begin
        SymVKlammerEvenMid(x-1, IniYnow(midline));
        if abs(sline-linenum)>2 then
          SymVKlammerCont(x-8, IniYnow(midline + 1));
      end else begin
        if abs(sline-linenum)>2 then
          SymVKlammerCont(x-8, IniYnow(midline));
          SymVKlammerOddMid(x-1, IniYnow(midline)+4);
      end;
      if abs(sline-linenum)>2 then
        for i:= midline + 2 to linenum - 1 do begin
          SymVKlammerCont(x-8, IniYnow(i));
        end;
      if printeron then begin
        PriVerticalKlammer(x, IniYnow(linenum - 1) + linethick div 2,
                           IniYnow(sline + 1) - linethick div 2);
      end;
  end else begin
    inc(x,4);
  end;
  if abs(sline-linenum)>2 then
    SymVKlammerEnd(x-1, IniYnow(linenum))
  else begin
    PutPixel(x+3,IniYnow(linenum)-4,getcolor);
    PutPixel(x+4,IniYnow(linenum)-4,getcolor);
    PutPixel(x+4,IniYnow(linenum)-3,getcolor);
    PutPixel(x+5,IniYnow(linenum)-3,getcolor);
  end;
end;

{***************************************************************}
Procedure TexHorizontalLine(linenum, x: integer);
var oldcolor: byte;
begin
  if printeron then begin
    MainLine(IniLeftMargin, IniYnow(linenum) + 1,
             GetMaxX - GcuRightMargin + drightmargin, hlwidth);
  end else begin
    oldcolor:= GetColor;
    SetColor(12);
    MainLine(IniLeftMargin, IniYnow(linenum) + 1,
             GetMaxX - GcuRightMargin + drightmargin, hlwidth);
    SetColor(5);
    MainLine(IniLeftMargin, IniYnow(linenum) + 2,
             GetMaxX - GcuRightMargin + drightmargin, hlwidth);
    if dispspec=1 then begin
      SetColor(speccolor);
      line(x+2, IniYnow(linenum), x + 6, IniYNow(linenum));
    end;
    SetColor(oldcolor);
  end;
end;

{***************************************************************}
Procedure TexVerticalLine(linenum, x: integer; hfinclude: boolean;threeD : Boolean);
var y0, y1, i: integer;
    oldcolor: byte;
begin
  if hfinclude then begin
    y0:= 1;
    y1:= IniYBottomMargin;
  end else begin
    i:= linenum;
    while ((i >= 0) and (pos(chr(233), page[i]) = 0)) do
      dec(i);
    if i<= 0 then begin
      y0:= 1;
    end else begin
      if printeron then
        y0:= IniYnow(i)+1
      else
        y0:= IniYnow(i)+3;
    end;
    i:= linenum;
    while ((pos(chr(233), page[i]) = 0) and (i <= pagelength)) do
      inc(i);
    y1:= IniYnow(i) + 2;
    if y1>IniYBottomMargin Then
      y1:=IniYBottomMargin;
  end;

  if printeron then begin
    if threeD then
      PriSetLineWidth(vlwidth)
    else
      PriSetLineWidth(pswidth);
    if y0<=1 then
      y0:=0;
    if y1>=IniYBottomMargin-1 then
      y1:=IniYBottomMargin+1;
    PriDrawLine(x + 1, y0, x + 1, y1 - 1);
  end else begin
    oldcolor:=GetColor;
    if threeD then begin
      SetColor(12);
      SetLineStyle(Solidln,1,0);
      line(x + 1, y0-1, x + 1, y1);
      SetColor(5);
      SetLineStyle(Solidln,1,0);
      line(x + 2, y0, x + 2, y1-1);
    end else begin
      SetColor(lcolor);
      SetLineStyle( 4, $AAAA, 1);
      Line(x + 1, y0-1,x + 1, y1);
    end;
    SetColor(oldcolor);               {fÅr vertikale 3D-Linie}

    if dispspec = 1 then begin
      oldcolor:= GetColor;
      SetColor(speccolor);
      line(x, IniYnow(linenum), x, IniYNow(linenum) - 4);
      SetColor(oldcolor);
    end;
  end;
end;

{****************************************************************}
Procedure TexTxtPosX(var x, actpost : integer; linenum: integer;
                      cursormove: boolean);
Var inblock        : stringline;
    xa, lxa, xnote : integer;
    totw           : integer;
begin
   while length(page[linenum]) < (linemarker + 1) do begin
      page[linenum]:= page[linenum] + ' ';
   end;
   inblock:= page[linenum];
   delete(inblock, 1, linemarker);
   xa:= textmargin;
   if x < xa then x:= xa + 1;
   if x > GetMaxX - Gcurightmargin then begin
      x:= GetMaxX - Gcurightmargin;
   end;
   if ((linestyles in actedit) and (x>(IniLeftMargin+labellength*6))) then begin
     x:=IniLeftMargin + labellength * 6;
   end;
   repeat
     lxa:= xa;
     if length(inblock) = 0 then begin
       inblock:=' ';
       page[linenum]:= page[linenum] + ' ';
     end;
     if not IniTabChar(inblock[1]) then begin
       xa:= xa + 6;
     end else begin
       xa:= xa + TexTabWidth(xa, linenum, ord(inblock[1]), false, xnote,totw);
     end;
     if (xa>GetMaxX-GcuRightMargin) then
       xa:=GetMaxX-GcuRightMargin;
     delete(inblock, 1, 1);
   until xa>=x;
   xa:=(xa+lxa) div 2;
   actpost:=length(page[linenum])-length(inblock);
   if cursormove then
     GcuMoveCursor( xa, IniYnow(linenum) + CharHeight + 2);
   x:=xa;
end;

{****************************************************************}
Procedure TexActPosX(var x, actpost : integer; linenum: integer;
                     cursormove: boolean);
{Berechnet x in Funktion von ActPost}
Var inblock            : stringline;
    temppos, dx, xnote : integer;
    totw               : integer;
begin
   temppos:= linemarker + 1;
   if actpost < temppos then actpost:= temppos;
   if ((linestyles in actedit) and
       (actpost > labellength + linemarker)) then begin
      actpost:= labellength + linemarker;
   end;
   while length(page[linenum]) < actpost do
      page[linenum]:=page[linenum]+' ';
   inblock:= page[linenum];
   delete(inblock, 1, linemarker);
   x:= textmargin-8;
   dx:= 6;
   while (temppos < actpost) and (x<=GetMaxX-GcuRightMargin) do begin
     if length(inblock) = 0 then
       inblock:=' ';
     if Not IniTabChar(inblock[1]) then begin
       dx:= 6;
     end else begin
       dx:= TexTabWidth(x+8, linenum, ord(inblock[1]), false, xnote,totw);
     end;
     if inblock[1]=#235 then
       Inc(x,2*dx);
     x:= x + dx;
     Inc(temppos);
     delete(inblock, 1, 1);
   end;
   actpost:=temppos;
   if (x > GetMaxX -GcuRightMargin) then
     x := GetMaxX - GcuRightMargin;
   x:= x + 12;
   if cursormove then begin
     GcuMoveCursor(x, IniYnow(linenum) + CharHeight + 2);
   end;
end;

{****************************************************************}
Procedure TexClearLine(linenum, startx: integer);
var y, endx : integer;
begin
  if startx<=0 then
    startx:=1;
  IniTrailBlank(page[linenum]);
  endx:=  GetMaxX - GcuRightMargin;
  if (endx > startx) then begin
    y:= IniYnow(linenum);
    if startx < Textmargin then
      startx:= Textmargin;
    startx:=startx+4;
    if startx<endx then begin
      IniSetViewPort(startx, y -6,  {weil Tabs links zuviel wegfrassen! ???}
                     endx, y+4);
      ClearViewPort;
      SetViewPort(0, 0, GetMaxX, GetMaxY, true);
    end;
  end;
end;

{****************************************************************}
Function TexTabWidth(x, linenum, ordc: integer;
                     cursormove: boolean; var xnote,totw: integer) : integer;
{x          = ab welcher spalte suchen?
 linenum    = ab welcher Zeile suchen?
 ordc       = tabulatorzeichen (240 oder 9)
 cursormove = cursor update?
 xnote      = position der Note
 totw       = insgesamt breite des Tabulators
 return: tabwidth

 Berechnet die Position des naechsten Notenzeichens in der
 zu liennum naechstoberen Notenzeile, beginnend mit x. Ist cursormove
 true, so wird der cursor in x-Richtung auf diese Position verschoben.
 Die y-koordinate bleibt unverÑndert.
 Der Funktionswert wird gleich der Schrittweite des Tabulators}
var i: byte;
    notec, result: integer;
begin
  {Suche Notenzeile}
  if ordc < 200 then begin      { normaler Tabulator    }
    i:=linenum-1;
    while ((i>=topmargin) and (page[i,1]<>'N')) do
      dec(i);
  end else begin                { geshifteter Tabulator }
    i:=linenum+1;
    while ((i<=pagelength) and (page[i,1]<>'N')) do
      i:=i+1;
  end;
  if ((i<topmargin) or (i>pagelength)) then begin
  {Keine Notenzeile gefunden}
    result:=6; { standard charwidth }
  end else begin
    xnote:=x+4;
    GetNotePosX(xnote, notec, i, false, false);
    if xnote<x then begin
    {Keine Noten rechts der gegenwaertigen Position}
      result:=6;
      totw:=6;
    end else begin
      totw:=xnote-x-3;
      result:= totw mod 6;
    end;
    if result = 0 then
      result:= 6;
  end;
  TexTabWidth:= result-1;
  if cursormove then begin
    GcuMoveCursor(xnote - 12, gcycoord);
  end;
end;

{******************************************************************}
Function TexWordEnd(var inblock: stringline; ipos: byte): boolean;
{true wenn ipos das zweite Zeichen von einem Doppelblank bzw. tab ist}
begin
  TexWordEnd:= (((inblock[ipos] = ' ') and
                 (inblock[ipos - 1 ] <= ' ')) or
                 (not IniPrintChar (inblock[ipos])) or
                 (ipos > length(inblock)));
end;

{****************************************************************}
Procedure TexOctVal(ordc: byte; var strbuf: string4;var i: byte);
begin
  i:= 4;
  case ordc of
    040     : strbuf:= '\050'; {'('}
    041     : strbuf:= '\051'; {')'}
    092     : strbuf:= '\134'; {'\'}
    123     : strbuf:= '\173'; (*'{'*)
    125     : strbuf:= '\175'; (*'}'*)

    132     : strbuf:= '\204'; {'Ñ'}
    142     : strbuf:= '\216'; {'é'}
    133     : strbuf:= '\205'; {'Ö'}
    160     : strbuf:= '\240'; {'†'}
    131     : strbuf:= '\203'; {'É'}
    134     : strbuf:= '\206'; {'Ü'}
    143     : strbuf:= '\217'; {'è'}
(*
    204     : strbuf:= ') show Aogonek (';
    205     : strbuf:= ') show Eogonek (';
    255     : strbuf:= '\377'; {'ogonek}
*)
    130     : strbuf:= '\202'; {'Ç'}
    144     : strbuf:= '\220'; {'ê'}
    138     : strbuf:= '\212'; {'ä'}
    136     : strbuf:= '\210'; {'à'}
    137     : strbuf:= '\211'; {'â'}

    139     : strbuf:= '\213'; {'ã'}
    161     : strbuf:= '\241'; {'°'}
    141     : strbuf:= '\215'; {'ç'}
    140     : strbuf:= '\214'; {'å'}
    152     : strbuf:= '\230'; {'ò'}

    148     : strbuf:= '\224'; {'î'}
    153     : strbuf:= '\231'; {'ô'}
    162     : strbuf:= '\242'; {'¢'}
    149     : strbuf:= '\225'; {'ï'}
    147     : strbuf:= '\223'; {'ì'}

    129     : strbuf:= '\201'; {'Å'}
    154     : strbuf:= '\232'; {'ö'}
    163     : strbuf:= '\243'; {'£'}
    151     : strbuf:= '\227'; {'ó'}
    150     : strbuf:= '\226'; {'ñ'}

    126     : strbuf:= '\176'; {'~'}
    164     : strbuf:= '\244'; {'§'}
    165     : strbuf:= '\245'; {'•'}

    168     : strbuf:= '\250'; {'®'}
    173     : strbuf:= '\255'; {'≠'}
    174     : strbuf:= '\256'; {'Æ'}
    175     : strbuf:= '\257'; {'Ø'}

    135     : strbuf:= '\207'; {'á'}
    128     : strbuf:= '\200'; {'Ä'}

    225     : strbuf:= '\341'; {'·'}

    179     : strbuf:= '\263'; {'≥'}
    196     : strbuf:= '\304'; {'ƒ'}
    221     : strbuf:= '\335'; {'›'}
{   124     : strbuf:= '\174';}{'|'}

    248     : strbuf:= '\370'; {'¯'}
     21     : strbuf:= '\025'; {''}

    200..255: strbuf:= ' ';
    else begin
      strbuf:= chr(ordc);
      i:= 1;
    end;
  end;
end;

{****************************************************************}
Procedure TexGetString(linenum, istart, x, xnote: integer;
                       var inote, iprint: integer; var inblock: stringline);
{ linenum= line in page[]
  istart = ab hier suchen
  x      = pixpos von page[linenum,istart]
  xnote  = pixpos des zu zentrierenden Zeichens
  inote  = Index in inblock von Zeichen an pixpos xnote
  iprint = wird um length(inblock) INKREMENTIERT (<>length(inblock)!!!)
  inblock= nÑchstes wort nach page[linenum,istart]
}
var i,xp,xn,tw: integer;
{************************}
Function GoOn: Boolean;
begin
  GoOn:=length(page[linenum])>=(istart+i);
end;
{************************}
Procedure AddChar(incinote: boolean);
var idiff  : byte;
    strbuf : string4;
begin
  TexOctval(Byte(page[linenum, istart + i]), strbuf, idiff);
  inblock:=inblock+strbuf;
  if incinote then
    inote:= inote + idiff;
  inc(i);
  inc(iprint);
end;
{******************************}
begin
  inc(istart);
  inblock:= '';
  i:=0;
  inote:=1;{leading blanks zaehlen}
  xp:=x+5;
  while (GoOn and (page[linenum,istart+i]=' ') and (xnote>=xp)) do begin
    inc(i);
    inc(iprint);
    xp:=xp+6;
  end;
{Zeichen bis und mit der Position xnote in inblock lesen}
  while ((GoOn) and (xnote>=xp)) do begin
    if (page[linenum,istart+i]=#9) or (page[linenum,istart+i]=#240) Then
      Inc(xp,TexTabWidth(xp,linenum,byte(page[linenum,istart+i]), false,xn,tw))
    else
      inc(xp,6);
    AddChar(true);
  end;
{Bis zum naechsten Blank in inblock lesen}
  while (Not TexWordEnd(page[linenum], istart+i)) do begin
    AddChar(false);
  end;
  if inblock='' then
    inote:=0;
end;

{****************************************************************}
Procedure TexDrawLine(linenum, startx: integer);

var i, iprint, x, y, stringlength, xnote, inote : integer;
    ordc, ib                                    : byte;
    inblock, strbuf                             : stringline;
    done, printit                               : boolean;
    col                                         : word;
    ih,totw,j                                   : integer;
{*****************************************}
Procedure PrintChar;
{schreibt ein Zeichen}
var strbuf: string4;
    ordc: byte;
begin
  if printit then begin
    inblock:= '';
    while (not TexWordEnd(page[linenum],iprint+linemarker)) do begin
      ordc:= ord(page[linenum, iprint + linemarker]);
      TexOctval(ordc, strbuf, ib);
      inblock:= inblock + strbuf;
      inc(iprint);
    end;{while (not TexWordEnd(page[linenum],iprint+linemarker))}
    if inblock<>'' then begin
      PriPlaceString(PriXScale(x), PriYScale(y) + yshift,
                     inblock);
    end;{if inblock<>''}
  end;{if printit}
end;{subproc PrintChar}
{*******************************}
begin
  x:=textmargin;
  y:=IniYnow(linenum);
  if ((linestyles in actedit) and (linenum > topmargin) and
      (page[linenum - 1, 1] = 'N')) then
    IniExpand(page[linenum], linemarker + labellength);
  stringlength:= length(page[linenum]) - linemarker;
  i:= 1;
  iprint:= 1;
  while i<=stringlength do begin
    if iprint<i then
      iprint:=i;
    printit:=(printeron and (iprint = i));
    IF (x<=GetMaxX-Gcurightmargin) then begin
      ordc:=byte(page[linenum,i+LineMarker]);
      done:=true;
      repeat
        case ordc of
          32: ;{ignore}
          smallblankup,
          smallblankdown: begin
            ih:= TexTabWidth(x, linenum, ordc, false, xnote,totw);
            x:=x+ih;
            if x>startx-8 then begin
              if ordc=smallblankup then
                SymTabSymbol(x, y)
              else
                SymTabSymbolDown(x, y);
              if printit then begin{Ausdrucken?}
                inc(iprint);
                TexGetString(linenum, i + linemarker,
                             x, xnote, inote, iprint,
                             inblock);
                if inote>0 then begin
                  strbuf:= Copy(inblock, 1, inote);
                  PriLeftString(strbuf, PriRXscale(xnote),
                                PriRYScale(y) + yshift);
                  if inote<length(inblock) then begin
                    strbuf:= Copy(inblock, inote + 1,
                                  length(inblock));
                    PriComplString(strbuf);
                  end;{if inote<length(inblock)}
                end else {if inote>0} begin
                  PriPlaceString(PriXScale(xnote),
                                 PriYScale(y) + yshift,
                                 inblock);
                end; {if inote>0 else }
              end; {if printit}
            end;{if x>startx}
          end;{case of smallblankup/down}
(*          129, 132, 148, 139: {Å,Ñ,î,ã} begin
            if x>startx then begin
              PrintChar;
              if ordc = 129 then ordc:= byte('u');
              if ordc = 132 then ordc:= byte('a');
              if ordc = 148 then ordc:= byte('o');
              if ordc = 139 then ordc:= byte('i');
              done:= false;
              if ((not (linestyles in actedit)) or
                  (linenum < linestyletop)) then
                col:= lcolor
              else
                col:= ilcolor;
              SetColor(col);
              Line(x + 1, y - 4, x + 2, y - 4);
              Line(x + 4, y - 4, x + 5, y - 4);
              SetColor(lcolor);
            end;{if x>startx}
          end;{case of ue,ae,oe}*)
          229: {start senkrechte Klammer} begin
            SymVKlammerStart(x, y);
          end;
          230: {beende senkrechte Klammer}begin
            TexEndVKlammer(linenum, i + linemarker, x);
          end;
          231: {start waagrechte Klammer}begin
            SymHKlammerStart(x, y);
          end;
          232: {beende waagrechte Klammer}begin
            TexEndHKlammer(linenum, i + linemarker);
          end;
          233: {Horizontale Linie}begin
            TexHorizontalLine(linenum, x);
          end;
          234: {Verticale Linie}begin
            TexVerticalLine(linenum, x + char2width - 1, true,false);
          end;
          235: {Seitennummer}begin
            if setuppage in actedit then
              inblock:= '...'
            else
              Str(pagecount:3, inblock);
            if printit then begin
              j:=0;
              while inblock[1]='' do begin
                delete(inblock,1,1);
                Inc(j,6);
              end;
              PriPlaceString(PriXScale(x+j),
                             PriYScale(y) + yshift,
                             inblock);
              iprint:= iprint + 1;
            end {if printit}else begin
              txtfnt.write(x + 1, y, inblock,getcolor,sz6x12,stnormal);
              if dispspec=1 then begin
                j:=1;
                while (j<=3) and (inblock[j]=' ') do begin
                  txtfnt.write(x+1,y,'0',speccolor,sz6x12,stnormal);
                  inc(x,6);
                  inc(j);
                end;{while (j<=3) and (inblock[j]=' ')}
              end;{if dispspec=1}
            end;{if printit else}
          end;
          236: {Verticale Linie ohne bis zu einer Horizontalen}begin
            TexVerticalLine(linenum, x + char2width - 1, false,false);
          end;
          237: {Verticale Linie ohne bis zu einer Horizontalen: 3D resp. voll}
          begin
            TexVerticalLine(linenum, x + char2width - 1, false,true);
          end;
          else{case}begin
            if x>startx then begin
              if ((not (linestyles in actedit)) or
                  (linenum < linestyletop)) then begin
                txtfnt.write(x + 1, y, chr(ordc),getcolor,sz6x12,stnormal);
                if done then
                  PrintChar;
              end{if ((not (linestyles in actedit))} else begin
                if page[linenum - 1, 1] = 'N' then
                  IniInversWrite(x, y + 1, page[linenum, i + LineMarker],frHigh);
              end;{if ((not (linestyles in actedit)) else}
              done:= true;
            end;{if x>startx}
          end;{case else}
        end;{case}
      until done;
      if Not IniTabChar(page[linenum, i + LineMarker]) then
        x:= x + 6;
      if x > GetMaxX - Gcurightmargin then
        x:= GetMaxX - Gcurightmargin;
    end; { if x < GetMaxX - Gcurightmargin then }
    inc(i);
  end; { while i <= stringlength do }
end;{proc texdrawline}

{****************************************************************}
Procedure TexEdTextLine(linenum: integer; var actpos : integer; c : char);
var x, ordc, i, j, blanks, maxchr,totw : integer;
begin
   if (linestyles in actedit) then begin
      maxchr:= labellength + linemarker;
   end else begin
      maxchr:= Stlength;
   end;
   ordc:= ord(c);
   if ordc = 8 then begin
      if actpos > 1 then begin
         if actpos<=11 Then
           Exit;
         actpos:= actpos - 1;
         x:= gcxcoord - charwidth;
         TexClearLine(linenum, x - 13);
         if (actpos <= length(page[linenum])) then begin
            IniCharAdd(Page[linenum], chr(32), actpos);
         end;
         GetRedraw(linenum, grminX, grmaxX);
         TexActPosX(x, actpos, linenum, true);
      end;
   end else begin
      if ((length(Page[linenum]) <= maxchr) and
          (actpos <= maxchr)) then begin
         x:= gcxcoord {- 6} - 3;
         if ((Not IniTabChar(page[linenum, actpos])) and
             (Not IniTabChar(c))) then begin
            IniClrCharField(x, IniYnow(linenum));
         end else begin
            TexClearLine(linenum, x - char2width);
         end;
         IniCharAdd(Page[linenum], c, actpos);
         GetRedraw(linenum,x-9,x+9); {x+7?}
         actpos:= actpos + 1;
         if IniTabChar(c) then begin
            i:= TexTabWidth(x, linenum, ord(c), true, j,totw);
            {Anzahl Blanks berechnen}
            blanks:= (totw div 6);
            actpos:=actpos+blanks;
            blanks:=blanks-(length(page[linenum])-actpos);
            if (length(page[linenum]) + blanks) > maxchr then begin
              blanks:=maxchr-length(page[linenum]);
              actpos:=maxchr;
            end;
            for i:= 1 to blanks do begin
              page[linenum]:=page[linenum]+' ';
            end;
         end;
         TexActPosX(x, actpos, linenum, true);
      end; {if length(Page[linenum]) < StLength }
   end; {else if ordc = 8}
end;

{****************************************************************}
Procedure TexInsChar(linenum, actpos: integer);

var StringLength, i : integer;
    x : integer;
    inblock: stringline;

begin
   if ((not (linestyles in actedit)) or
       (length(page[linenum]) < (labellength + linemarker))) then
   begin
      x:= gcxcoord - 2 * CharWidth;
      if Pos(chr(smallblankup), page[linenum]) > 0 then x:= grminx;
      if Pos(chr(smallblankdown), page[linenum]) > 0 then x:= grminx;
      TexClearLine(linenum, x);
      StringLength:= Length(page[Linenum]) - LineMarker;
      if StringLength < StLength then
      begin
         page[Linenum]:= page[Linenum] + ' ';
         StringLength:= StringLength + 1;
      end;
      for i:= StringLength + LineMarker downto actpos + 1 do
      begin
         page[Linenum, i]:= page[Linenum, i-1];
      end;
      page[linenum, actpos]:= ' ';
      GetRedraw(linenum, x - 12{2*charwidth},grmaxX{x+2*charwidth});
   end;
end;

{****************************************************************}
Procedure TexDelChar(linenum : integer; var actpos: integer);

var StringLength, i : integer;
    x: integer;
    inblock:  stringline;

begin
   StringLength:= Length(page[linenum]) - LineMarker;
   if actpos <= (StringLength + LineMarker) then
   begin
      if StringLength > 0 then
      begin
         StringLength:= StringLength - 1;
      end;
      for i:= actpos to StringLength + LineMarker do
      begin
         page[linenum, i ]:= page[linenum, i+1 ];
      end;
      x:= gcxcoord - 2*CharWidth;
      if Pos(chr(smallblankup), page[linenum]) > 0 then x:= grminx;
      if Pos(chr(smallblankdown), page[linenum]) > 0 then x:= grminx;
      TexClearLine(linenum, x );
      delete(page[linenum], StringLength + 1 + LineMarker, 1);
      GetRedraw(linenum,x-2*charwidth,grmaxX);
   end;
end;
{****************************************************************}
Function SkipChar(C : Char) : Boolean;
Begin
  SkipChar:=(C=' ') Or
            (C=#9) Or  {TAB}
            (C='') Or {ATAB}
            (C='Â') Or {A-F1}
            (C='Ê') Or {A-F2}
            (C='Á') Or {A-F3}
            (C='Ë') Or {A-F4}
            (C='Í') Or {A-F5}
            (C='Ï') Or {A-F6}
            (C='È') Or {A-F7}
            (C='Ì') Or {A-F8}
            (C='Î');   {AF10}
End;
{****************************************************************}
Procedure TexWordLeft(Var Linenum,Actpos : Integer);
Var x,sl : Integer;
    s : String;
    f : Boolean;
Begin
  F:=False;
  sl:=LineNum;
  x:=actpos;
  Dec(x,11);
  Repeat
    IF x=0 Then Begin
      Repeat
        if (sl=linenum) Then
          IF f Then
            Exit
          Else
            F:=True;
        sl:=(((sl-2)+pagelength) mod pagelength)+1;
        s:=TexGetText(sl);
        x:=Length(S)+1;
      Until (Page[sl,1]='T') And (s<>'');
    End;
    s:=TexGetText(sl);
    if x>length(S) Then Begin
      x:=length(s);
      if (x<>0) And (Not SkipChar(s[x])) Then Begin
        linenum:=sl;
        actpos:=x;
        PagCursorRight(linenum,sl,actpos);
        Exit;
      End;
    End;
    While (x>0) And (Not SkipChar(S[x])) Do
      Dec(x);
    While (x>0) And SkipChar(S[x]) Do
      Dec(x);
  Until x>0;
  Inc(x,11);
  actpos:=x;
  linenum:=sl;
  TexActPosX(x,actpos,linenum,true);
End;
{****************************************************************}
Procedure TexWordRight(Var Linenum,Actpos : Integer);
Var x,sl : Integer;
    s : String;
    f,f2 : Boolean;
Begin
  f:=false;
  F2:=false;
  sl:=LineNum;
  x:=actpos;
  Dec(x,10);
  Repeat
    IF F Then Begin
      Repeat
        sl:=(sl+pagelength) mod pagelength+1;
        s:=TexGetText(sl);
        if (sl=linenum) Then
          if f2 Then
            Exit
          Else
            F2:=True;
      Until (Page[sl,1]='T') And (s<>'');
      x:=1;
    End;
    if Not (F And (not SkipChar(S[x]))) Then Begin
      F:=True;
      s:=TexGetText(sl);
      While (x<=Length(S)) And (Not SkipChar(S[x])) Do
        Inc(x);
      While (x<=Length(S)) And SkipChar(S[x]) Do
        Inc(x);
    End;
  Until x<=Length(S);
  Inc(x,10);
  actpos:=x;
  linenum:=sl;
  TexActPosX(x,actpos,linenum,true);
End;
{****************************************************************}
Function  TexGetText(Linenum : Integer) : String;
Var s : String;
Begin
  s:=Copy(Page[linenum],11,length(page[linenum])-linemarker);
  IniTrailBlank(S);
  TexGetText:=s;
End;
{****************************************************************}
Procedure TexSetText(Linenum : Integer;S : String);
Begin
  Page[Linenum]:=Copy(Page[linenum],1,11)+S;
End;
end.
