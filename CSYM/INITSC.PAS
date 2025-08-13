unit InitSc;

interface

uses
     graph,
     menutyp,
     inout,
     dos,
     crt;

const LineMarker = 9;
      StLength = 245;
      ClearAreaX = 10;
      PageLim = 56;


      barfill = 11; {fill style fuer menus}

      promptline = 21;
      smallblank = 9;

      resolparam = 3;

      ttyp = 1; {horizontal TextJustify}

      drightmargin = 0;

      labellength = 20;
      leftx = 20; {linker Rand in den Symbol - Menus}
      numofpar = 8; {Max Anzahl parameter pro symbol}

type stringline = string[255];
     KeyEntry = (invalid, one, numeric, character, curupdown, plus,
                 postplus, other);
     ArrowTyp = (noarr, leftarr, rightarr);
     Editvariants = (setuppage, defsetuppage, linestyles);

                      {Buchstabe, Zeile, Normal/Ctrl/Alt/}
     SymArrTyp = array['a'..'z',1..15,1..3] of word;
     SymParamTyp = array['a'..'z', 1..numofpar, 1..3] of integer;

     listptr = ^linerec;

     linerec = record
        datblock : stringline;
        next : listptr;
        last : listptr;
     end;

     lineattrtype = record
        beats : integer;
        eint : integer;
        resolution : integer;
        linestyle: byte; {1= solid, 2= solid/dotted, 3= dotted}
     end;

     markdescrtyp = record
        mline : integer;
        mpos : integer;
        mpage : integer;
        mxcoord : integer;
        mpoint : listptr;
     end;

var
    infile : text;
    GraphDriver : integer;
    GraphMode : integer;
    ErrCode : integer;
    HercGraphicsMode : Boolean;
    HercGraphicsPage : Byte absolute $0000:$0199;

    PageLength : integer;
    LineThick : integer;
    TopMargin : integer;
    PageCount : integer;
    CharWidth, CharHeight : integer;
    Char2Width, Char2Height : integer;  {Halbe Zeichenbreite, Hoehe}
    Chr4Width : integer;
    Chr8Width : integer;
    Page : Array[0..PageLim] of stringline;
    actfilename: stringline;
    insmusicline: stringline;
    TextMargin : integer;
    SymCount : integer;
    ActNumber : integer;
    LastEntry : KeyEntry;
    Lastchar: char;
    ArrowEntry : ArrowTyp;
    SymArr : SymArrTyp;
    SymPar : SymParamTyp;
    fbeatlinepos: integer;
    actattr: lineattrtype;

    dispspec: byte; {2 = off, 1 = on}
    dispgrid: byte;
    disphidlines: byte;
    dispref: byte;
    charset: byte; {1 = normaler set, 2 = <alt> , normal, shift}
    blankset: byte; {1 = blank ist Leertaste, 2 = blank ist Komma}

    linecount: integer;
    yzeropos: integer;

    outfile, buffile : text;

    gmaxx, gmaxy: integer;

    GrMinX, GrMaxX, GrMinY, GrMaxY: integer;
    UsrMenu, Symbolmenu1, Symbolmenu2 : Menu_Rec;
    togglestring: toggletyp;
    hfminx, hfminy, hfmaxx, hfmaxy: integer;
    TOP_Line, Left_Col, Valcol : integer;
    stabxmin, stabxmax, stabymin, stabymax: integer;
    sxmin, sxmax, symin, symax: integer;
    printtyp, printport, datadir: string16;

    searchstring: stringline;
    searchtyp: char;
    replaceflag: boolean;
    replacestring: stringline;

    symboldx, symboldy : integer;
    mstart, mend : markdescrtyp;
    marpartline: boolean;

    actedit: set of editvariants;

    bufstartptr, bufactptr, bufendptr : listptr;
    refxmin, refxmax, refymin, refymax: integer;
    hintminx, hintminy, hintmaxx, hintmaxy : integer;
    menutextcolor, menubkcolor, imenutextcolor, imenubkcolor: byte;
    cursorcolor: byte;

    printeron: boolean; {true, wenn postscriptfile geschrieben wird}

Procedure IniOutTextXY(X, Y : integer; Texts: String79);
Function IniAltChar(c : char) : char;
Procedure IniGetSymbols;
procedure InitScreen;
Function  IniYnow(linenum : integer) : integer;
Procedure IniNewPage(var linenum: integer);
Procedure IniClrCharField( x, y : integer);
Procedure IniCharAdd(var TargetString : Stringline; C : Char;
                     PosInString : integer);
Function IniNextnumber(var strbuf: stringline) : integer;
Function IniDxValue(lineattr: lineattrtype) : integer;
Function IniPrintNote(c: char) : Boolean;
Function IniNumChar(c: char) : Boolean;
Procedure IniGotoXY(var X, Y : integer);
Procedure IniGraphXY(var X, Y : integer);
Procedure IniInversText(X, Y : integer; Texts: String79);
Procedure IniInversWrite(X, Y : integer; Texts: String79);
Procedure IniClearLine(X, Y, fillstyle : integer; cllength: integer;
                       BColor : byte);
Function IniLnow(ynow : integer) : integer;
Procedure IniSetViewPort(x1, y1, x2, y2 : integer);
Function IniEmptyLine( inblock : stringline): boolean;
Function IniLeftMargin : integer;
Procedure IniTrailBlank(var inblock: stringline);
Procedure IniLeadBlank(var inblock: stringline);
Function IniFileExist(instring: string79) : boolean;
Function IniBytes(x,y:integer):integer;
Procedure IniGraphMode;
Procedure IniRefInit;
Procedure IniGraphinit;
Procedure IniGraphClose;
Function IniFirstBeatPos(lineattr: lineattrtype) : integer;
Function IniYBottomMargin : integer;
Function IniPos(linenum, actposn, actpost: integer): integer;
Function IniMaxHeader : integer;
Function IniHeaderFooterLine(linenum: integer) : boolean;
Function IniMinFooter : integer;
Function IniHeaderEnd : integer;
Function IniFooterEnd : integer;
Procedure IniExpand(var instring: string79; newlength: byte);

implementation

uses gcurunit;

{******************************************************}
Procedure IniExpand(var instring: string79; newlength: byte);

begin
   while length(instring) < newlength do
   begin
      instring:= instring + ' ';
   end;
end;

{******************************************************}
Function IniPos(linenum, actposn, actpost: integer): integer;

begin
   if page[linenum,1] = 'T' then
   begin
      IniPos:= actpost;
   end
   else
   begin
      IniPos:= actposn;
   end;
end;

{******************************************************}
Function IniAltChar(c : char) : char;
{Umwandeln eines Alt-Characters in den Bereich 128..153,
 wobei alphabetisch geordnet wird}

var str : string79;

begin
   str:= 'qwertyuiop    asdfghjkl     zxcvbnm';
   IniAltChar:= chr(ord(str[ord(c) - 15]) + 31);
end;

{******************************************************}
Procedure IniGraphClose;

begin
   CloseGraph;
   HercGraphicsMode := false;
end;

{******************************************************}
Procedure IniGraphMode;

begin
   DetectGraph(GraphDriver, GraphMode);
   InitGraph(GraphDriver, GraphMode, 'C:\TPEX');
   ErrCode:= GraphResult;
   If ErrCode <> grOk then
   begin
      writeln('Graphic error ',GraphErrorMsg(ErrCode));
      writeln('Program aborted');
      halt(1);
   end;
   HercGraphicsMode := true;
   SetTextJustify(LeftText, Ttyp);
   SetTextStyle(DefaultFont, HorizDir, 1);
end;

{******************************************************}
Procedure IniGraphinit;

begin
   IniGraphMode;
   InitScreen;
   GcuIniCursor;
end;

{******************************************************}
Function IniBytes(x,y:integer):integer;
begin
    Inibytes := $2000 * (y mod 4) + 90 * (y shr 2) + (x shr 3)
end;

{******************************************************}
Function IniFileExist(instring: string79) : boolean;

{ testet, ob unter dem Namen instring schon ein File auf dem Directory
  existiert }

Var FileInfo : SearchRec;

begin
   FindFirst(instring, AnyFile, FileInfo);
   IniFileExist:= (DosError=0);
end;

{**************************************************************}
Procedure IniTrailBlank(var inblock: stringline);

var l : integer;

begin
   l:= length(inblock);
   while ((l > 0) and (inblock[l] = ' ')) do
   begin
      delete(inblock, l, 1);
      l:= l - 1;
   end;
end;

{**************************************************************}
Procedure IniLeadBlank(var inblock: stringline);

var l : integer;

begin
   while ((length(inblock) > 0) and (inblock[1] = ' ')) do
   begin
      delete(inblock, 1, 1);
   end;
end;

{**************************************************************}
Function IniLeftMargin : integer;

var margin : integer;

begin
   margin:= GetMaxX - 649 - Gcurightmargin;
   if margin < 0 then margin:= 0;
   IniLeftMargin:= margin;
end;
{**************************************************************}
Procedure IniOutTextXY(X, Y : integer; Texts: String79);

begin
   if hercgraphicsmode then
   begin
      IniGraphXY(x, y);
      OutTextXY(x, y, texts);
   end
   else
   begin
      GotoXY(x, y);
      write(texts);
   end;
end;

{**************************************************************}
Procedure IniGraphXY(var X, Y : integer);

begin
   x:= x*charwidth - 6;
   y:= y*charheight + 6;
end;

{**************************************************************}
Procedure IniGotoXY(var X, Y : integer);

begin
   if not hercgraphicsmode then
   begin
      GotoXY(x, y);
   end;
end;
{**************************************************************}
Procedure IniInversWrite(X, Y : integer; Texts: String79);
                         

begin
   {Zeichne Linienbalken}
   SetFillStyle(1, iMenuBkColor);
   Bar(x - 1, y - char2height - 1, X + Length(Texts) * CharWidth,
       Y + Char2Height);

   {Schreibe Text in der Hintergrundfarbe}
   SetColor(imenutextcolor);
   OutTextXY(X, Y, Texts);
   SetColor(menutextcolor);
end;

{**************************************************************}
Procedure IniInversText(X, Y : integer; Texts: String79);

var i: integer;

begin
   if hercgraphicsmode then
   begin
      IniGraphXY(x, y);
      IniInversWrite(x, y, texts);
   end
   else
   begin
      Set_Video(1);
      GotoXY(x, y);
      write(texts);
      Set_Video(0);
   end;
end;

{**************************************************************}
Procedure IniClearLine(X, Y, fillstyle : integer; cllength: integer;
                       BColor : byte);
var i, xmax: integer;
    clears: string79;

begin
   if hercgraphicsmode then
   begin
      IniGraphXY(x, y);
      xmax:=  X + cllength*CharWidth;
      if xmax > GetMaxX then xmax:= GetMaxX;
      SetFillStyle(fillstyle, BColor);
      Bar(x - 1, y - char2height - 1, Xmax,
          Y + Char2Height);
   end
   else
   begin
      clears:= '';
      for i:= 1 to cllength do
      begin
         clears:= clears + ' ';
      end;
      Set_Video(bcolor);
      GotoXY(x, y);
      write(clears);
      Set_Video(0);
   end;
end;

{**************************************************************}
Function IniYBottomMargin : integer;

begin
   IniYBottomMargin:= (Pagelength + 1)*linethick;
end;

{**************************************************************}
Function IniFirstBeatPos(lineattr: lineattrtype) : integer;

begin
   IniFirstBeatPos:= GMaxX - GcuRightMargin - lineattr.resolution;
end;

{**************************************************************}
Function IniDxValue(lineattr: lineattrtype) : integer;

begin
   IniDxValue:= (GetMaxX + 1 - GcuRightMargin - IniFirstBeatPos(lineattr))
                div (lineattr.beats);
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Function IniNumChar(c: char) : Boolean;
{True wenn c zwischen 0 und 9 liegt}

begin
   IniNumChar:= ((c >= '0') and (c <= '9'));
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Function IniPrintNote(c: char) : Boolean;
{True wenn c ein als Note druckbares Zeichen, ausser 0...9 ist}

const spec: set of char = [' ','/','.',',','≥'];

begin
   IniPrintNote:= ((c in spec)
                   or ((c >= 'A') and (c <= 'Z'))
                   or ((c >= 'a') and (c <= 'z'))
                   or (( c >= #128) and (c <= #153)));
end;

{**************************************************************}
Function IniNextnumber(var strbuf: stringline) : integer;
{Liest einen integer aus dem Buffer und gibt ihn als Funktionswert zurÅck.
 Der String selbst wird im Buffer gelîscht.}

var numstring : string[20];
    i, codei : integer;

begin
   {Lîsche leading blanks}
   numstring:='';
   while (length(strbuf) > 0 ) and (strbuf[1] = ' ') do
      delete(strbuf,1,1);

   {Lese bis zum ersten nichtnumerischen Zeichen}
   while (length(strbuf) > 0 ) and IniNumChar(strbuf[1]) do
   begin
      numstring:= numstring + strbuf[1];
      delete(strbuf,1,1);
   end;

   {Wandle den String in einen Integer um}
   if numstring <> '' then
   begin
      Val( numstring, i, codei );
      IniNextNumber:= i;
   end
   else
   begin
      IniNextNumber:= 0;
   end;
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure IniNewPage(var linenum: integer);
{Neue Seite initialisieren}

var Response : Response_Type;
    Direction : Movement;
    KeyResponse : Char;
    i,j : integer;

begin
   ClearViewPort;
   For i:= 1 to PageLim do page[i]:='T';
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Function IniYnow(linenum : integer) : integer;

begin
   if linenum < pagelim then
   begin
      IniYnow:= linenum*linethick;
   end
   else
   begin
      {linenum = pagelim bedeutet, dass eine Zeile in der Mitte
       der Seite editiert wird}
      IniYNow:= (pagelength div 2) * linethick;
   end;
   if linenum = 0 then IniYnow:= yzeropos;
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Function IniMaxHeader : integer;

begin
   IniMaxHeader:= pagelength div 2 - 1;
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Function IniHeaderFooterLine(linenum: integer) : boolean;

begin
   if ((linenum >= topmargin) and (length(page[linenum]) >= 4) and
       (page[linenum, 4] = 'F')) then
   begin
      IniHeaderFooterLine:= true;
   end
   else
   begin
      IniHeaderFooterLine:= false;
   end;
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Function IniHeaderEnd : integer;

var i: byte;

begin
   i:= topmargin;
   while (IniHeaderFooterLine(i)) do
   begin
      i:= i + 1;
   end;
   IniHeaderEnd:= i;
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Function IniMinFooter : integer;

begin
   IniMinFooter:= pagelength div 2 + 1;
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Function IniFooterEnd : integer;

var i: byte;

begin
   i:= pagelength;
   while (IniHeaderFooterLine(i)) do
   begin
      i:= i - 1;
   end;
   IniFooterEnd:= i;
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Function IniLnow(ynow : integer) : integer;

begin
   IniLnow:= ynow div linethick;
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure InitScreen;

Var i: integer;

begin
   gmaxx:= GetMaxX;
   gmaxy:= GetMaxY;
   TopMargin:= 1;
   LineThick := 6;
   PageLength := (gmaxy div linethick) - 5;
   PageCount:= 1;
   CharWidth:= TextWidth('W');
   CharHeight:= TextHeight('$_');
   Char2Width:= CharWidth div 2;
   Char2Height:= CharHeight div 2;
   Chr4Width:= CharWidth div 4;
   Chr8Width:= CharWidth div 8;
   For i:= 1 to pagelength do page[i]:='';
   TextMargin:= IniLeftMargin;
   GrMinx:= IniLeftMargin - 1;
   GrMaxx:= gmaxx - gcurightmargin + drightmargin;
   GrMaxY:= IniYBottomMargin;
   GrMinY:= 0;
   hfminx:= GrMinx div charwidth + 2;
   hfmaxx:= GrMaxX div charheight;
   hfminy:= 0;
   hfmaxy:= GrMaxY div charheight;
   lastentry:= invalid;
   arrowentry:= noarr;
   actedit:= [];
   symboldx:= 12;
   symboldy:= 12;
   stabxmin:= 24;
   stabymin:= 8;
   stabxmax:= 620;
   stabymax:= GmaxY - 25;
   sxmin:= stabxmin div charwidth + 1;
   sxmax:= stabxmax div charwidth;
   symin:= stabymin div charheight;
   symax:= stabymax div charheight;

   searchstring:= '';
   actfilename:= '';

   printeron:= false;
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure IniRefInit;
{Initialisierung der refreshparameter}

begin
   refxmin:= GMaxX;
   refxmax:= 0;
   refymin:= GMaxY;
   refymax:= 0;
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure IniGetSymbols;

var i, j: integer;
    c : char;
    infile: file of word;
    parfile: file of integer;

begin
   assign(infile,'symbols.sym');
   reset(infile);
   for c:='a' to 'z' do
      for i:=1 to 15 do
         for j:= 1 to 3 do
            read(infile,symarr[c,i,j]);
   close(infile);

   begin
      assign(parfile,'symbols.par');
      reset(parfile);
      for c:='a' to 'z' do
      begin
         for i:=1 to numofpar do
         begin
            for j:= 1 to 3 do
            begin
               read(parfile,sympar[c,i,j]);
            end;
         end;
      end;

      close(parfile);
   end;
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Function IniEmptyLine( inblock : stringline): boolean;

begin
   IniTrailBlank(inblock);
   IniEmptyLine:= ((inblock = '') or
                   ((inblock[1] <> 'N')
                    and (length(inblock) <= linemarker)));
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure IniClrCharField( x, y : integer);

var i,j,k : integer;

begin
   {Lîsche ein Feld von Charactergroesse}
   if x < textmargin then x:= textmargin;
   if x > (GMaxX - GcuRightMargin) then x:= GMaxX - GcuRightMargin;

   for j:= 1 to charheight do
      for i:= 0 to charwidth do
         PutPixel(x + i, y + ttyp * 4 - j, 0);
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure IniSetViewPort(x1, y1, x2, y2 : integer);

begin
   if x1 < 0 then x1:= 0;
   if y1 < 0 then y1:= 0;
   if x2 > GMaxX then x2:= GMaxX;
   if y2 > GMaxX then y2:= GMaxY;
   SetViewPort(x1, y1, x2, y2, true);
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure IniCharAdd( var TargetString : stringline; C : Char;
                   PosInString : integer);

{FÅgt den Character C in TargetString auf Position PosInString ein,
 wobei wenn nîtig Blanks hinzugefÅgt werden}

var i,j,k : integer;
    ActLength : integer;

begin
   if PosInString <= StLength then
   begin
      ActLength:= Length(TargetString);
      if ActLength < PosInString then
      begin
         for i:= ActLength + 1 to PosInString do
            TargetString:= TargetString + ' ';
      end;
      TargetString[PosInString]:= C;
   end;
end;

{*************************************************************************}
end.

