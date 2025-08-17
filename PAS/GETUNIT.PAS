unit GetUnit;

interface

uses
     InitSc,
     graph;

Procedure GetLine(linenum, startx : integer);
Procedure GetDrawBlock(inblock: stringline; linenum : integer;
		       lineattr: lineattrtype; startx,endx : integer;
		       var xfirst: integer);
Procedure GetNoteAttributes(var inblock: stringline;
                            var lineattr: lineattrtype);
Procedure GetNoteBlock(var inblock : stringline; var lineattr: lineattrtype;
		       linenum: integer);
Procedure GetNotePosX(var x, notec : integer; linenum : integer;
		      cursormove, left : boolean);
Procedure GetDrawBeats(lineattr: lineattrtype; linenum: integer);
Procedure GetDrawDistances(lineattr: lineattrtype; linenum, startx: integer);
Procedure GetActPosX(var x, notec : integer; linenum : integer;
		     cursormove : boolean);
Procedure GetClearLines(linenum: integer; var lineup, linedown : integer);

Function GetDrawSymbol(linenum,actposn : integer;UpdateCursor : Boolean) : Boolean;
Function GetValidStaff(var linenum : integer) : Boolean;
Procedure GetReDraw(linenum, startx,endx : integer);
Procedure GetDrawSystems(lineattr: lineattrtype; linenum : integer);

implementation

uses symbols,
     TitleUnit,
     GCurUnit,
     UtilUnit,
     PrintUnit,
     DmemUnit,
     ComUnit,
     NoteUnit,
     PageUnit;

{****************************************************************}
Procedure GetClearLines(linenum: integer; var lineup, linedown : integer);
{sucht bis zur nÑchsten Notenzeile rauf un runter nach Textzeilen
 mit Tabulatoren und setzt lineup auf die obere Zeile, linedown auf
 die unter}

var i: integer;

begin
   lineup:= linenum - 2;
   i:= lineup;
   while ((i >= topmargin) and (page[i, 1] = 'T')) do
   begin
      if pos(chr(240), page[i]) > 0 then
      begin
         {shift tab gefunden}
         lineup:= i - 1;
      end;
      i:= i - 1;
   end;

   linedown:= linenum + 1;
   i:= linedown;
   while ((i <= pagelength) and (page[i, 1] = 'T')) do
   begin
      if pos(chr(9), page[i]) > 0 then
      begin
         {shift tab gefunden}
         linedown:= i;
      end;
      i:= i + 1;
   end;
end;

{****************************************************************}
Procedure GetComputeX(var inblock: stringline; var xa, dx : integer;
		      var rxa: real);

var
   rx : real;
   xmin : integer;
   lineattr : lineattrtype;

begin
   ActNumber:= IniNextNumber(inblock);
   rx:= dx / ActNumber;
   rxa:= rxa + rx;
   xa:= trunc(rxa * 1000 + 0.5) div 1000;
   if (xa > GetMaxX - GcuRightMargin) then
     xa:= getmaxX-gcurightmargin+1;
end;
Procedure GetComputeXNoCorr(var inblock: stringline; var xa, dx : integer;
		      var rxa: real);

var
   rx : real;
   xmin : integer;
   lineattr : lineattrtype;

begin
   ActNumber:= IniNextNumber(inblock);
   rx:= dx / ActNumber;
   rxa:= rxa + rx;
   xa:= trunc(rxa * 1000 + 0.5) div 1000;
end;
{****************************************************************}
Procedure GetNotePosX(var x, notec : integer; linenum : integer;
		      cursormove, left : boolean);
{Berechnen von xa und NoteCount fÅr die Position x und plaziere Cursor
 Ist left true, so wird xa <= x, sonst wird es >= x}

var
    rxa, rx : real;
    xa, dx, xmin : integer;
    i,j,k : integer;
    c : char;
    inblock : stringline;
    lineattr : lineattrtype;

begin
  inblock:= page[linenum];
  GetNoteBlock(inblock, lineattr, linenum);
  dx:= IniDxValue(lineattr);
  xa:= IniFirstBeatPos(lineattr) - dx;
  rxa:= xa;
  xmin:= xa;
  if x < xa then begin
    x:= xa;
    left:= true;
  end;

  {inblock solange lîschen, bis xa > x wird}
  while ((length(inblock) > 0) and (xa < x)) do begin
    if IniNumChar(inblock[1]) then begin
    {Abstand berechnen}
      GetComputeXNoCorr(inblock, xa, dx, rxa);
      if xmin < IniLeftMargin then
        xmin:= xa;
      if x < xmin then
        x:= xmin;
    end else begin
	 delete(inblock, 1, 1);
    end;
  end;
  {Berechnen von Notec}
  Notec:= length(Page[linenum]) - length(inblock);
  if ((left) and (Xa > x)) then begin
    rx:= dx / ActNumber;
    rxa:= rxa - rx;
    xa:= trunc(rxa);
    str( ActNumber, inblock);
    Notec:= Notec - Length(inblock);
  end else begin
    if length(inblock) > 0 then
      notec:= notec + 1;
  end;
  {Cursor plazieren, wenn verlangt}
  if cursormove then begin
    GcuMoveCursor( Xa, IniYnow(linenum) + CharHeight);
  end;
  {x wird auf die aktuelle Position gesetzt}
  x:= xa;
end;

{****************************************************************}
Procedure GetActPosX(var x, notec : integer; linenum : integer;
		     cursormove : boolean);
{Berechne von x in Abhaengigkeit von NoteCount x und plaziere Cursor}

var
    rxa, rx : real;
    xa, dx, xmin : integer;
    i,j,k : integer;
    c : char;
    inblock : stringline;
    lineattr : lineattrtype;

begin
  inblock:= page[linenum];
  GetNoteBlock(inblock, lineattr, linenum);
  dx:= IniDxValue(lineattr);
  xa:= IniFirstBeatPos(lineattr) - dx;
  rxa:= xa;
  xmin:= xa;

  while ((length(Page[linenum]) - length(inblock)) < notec) and (inblock<>'')do begin
    if IniNumChar(inblock[1]) then begin
      {Abstand berechnen}
      GetComputeX(inblock, xa, dx, rxa);
      if xmin < IniLeftMargin then
        xmin:= xa;
    end else begin
      delete(inblock, 1, 1);
    end;
  end;
  {Berechnen von Notec}
  Notec:= length(Page[linenum]) - length(inblock);
  {Cursor plazieren, wenn verlangt}
  if cursormove then begin
    GcuMoveCursor( Xa, IniYnow(linenum) + CharHeight);
  end;
  x:=xa;
end;

{**************************************************************}
Procedure GetNoteAttributes(var inblock: stringline;
                            var lineattr: lineattrtype);

begin
  delete(inblock, 1, LineMarker);
  lineattr.beats:= IniNextnumber(inblock);
  lineattr.eint:= IniNextNumber(inblock);
  lineattr.resolution:= IniNextNumber(inblock);
  lineattr.linestyle:= IniNextNumber(inblock);
  if lineattr.beats=0 then
    lineattr.beats:=1;
  if lineattr.linestyle=0 then
    lineattr.linestyle:=1;
end;

{**************************************************************}
Procedure GetNoteBlock(var inblock : stringline; var lineattr: lineattrtype;
		       linenum: integer);

var i, y : integer;
    linblock, strbuf: stringline;

begin
   linblock:= copy(inblock, 1, linemarker);
   GetNoteAttributes(inblock, lineattr);

   {Notenlinie ins Page-Array schreiben}
   Str( lineattr.beats:  5, strbuf);
   linblock:= linblock + strbuf;
   Str( lineattr.Eint: 5, strbuf);
   linblock:= linblock + strbuf;
   Str( lineattr.resolution: 5, strbuf);
   linblock:= linblock + strbuf;
   Str( lineattr.linestyle: 5, strbuf);
   linblock:= linblock + strbuf;
   if linenum > 0 then begin
      page[linenum]:= linblock + inblock;
      if lineattr.linestyle = 5 then begin
         page[linenum, 5]:= 'H';
      end else begin
         page[linenum, 5]:= ' ';
      end;
   end;

   while ((length(inblock) > 0) and (inblock[1] <> '%')) do
      delete(inblock, 1, 1);
   delete (inblock, 1, 1);
end;

{**************************************************************}
Procedure GetLine(linenum, startx : integer);

var i, xfirst : integer;
    inblock : stringline;
    lineattr : lineattrtype;

begin
   SetColor(LColor);
   if (linenum>=0) and (linenum<=pagelim) and (page[linenum,1] = 'N') then begin
     inblock:= page[linenum];
     GetNoteBlock(inblock, lineattr, linenum);
     { Draw Symbols }
     GetDrawBlock(inblock, linenum, lineattr, startx, grmaxx, xfirst);
     { Draw Distance Marks (Pulses) }
     GetDrawDistances(lineattr, linenum, xfirst);
     { Draw Beats/Lines }
     GetDrawBeats(lineattr, linenum);
     { Draw Notesystems }
     GetDrawSystems(lineattr, linenum);
   end;
end;

{**************************************************************}
Procedure GetDrawBlock(inblock: stringline; linenum : integer;
		       lineattr: lineattrtype; startx,endx : integer;
		       var xfirst: integer);

var
    rxa, rx                          : real;
    x, xa, xl, dx, y, difx, dify     : integer;
    sympary,sterny                   : integer;
    dummy                            : integer;
    vogelx                           : integer absolute y;
    i,j,k, height                    : integer;
    c, indexc, lastc, altc,flamc     : char;
    eklammerflam, rklammerflam,gflam : boolean;
    vogel                            : byte;
    QuotMark,Sternflam               : boolean;
    tempstr                          : string;
    KlY,KlX                          : integer;
begin
  quotmark:=false;
  sternflam:=false;
  vogel:=0; { kein Ø oder Æ }
  dx:=IniDxValue(lineattr);
  xfirst:=IniFirstBeatPos(lineattr);
  xa:=IniFirstBeatPos(lineattr) - dx;
  xl:=IniLeftMargin;
  rxa:=xa;
  dify:=0;
  difx:=0;
  sympary:=0;
  sterny:=0;
  c:= ' ';
  lastc:= ' ';
  height:= 5;
  flamc:=' ';
  rklammerflam:= false;
  eklammerflam:= false;
  gflam:=false;
  if inblock[1]='"' then begin
    for i:=1 to length(inblock) do
      if Ininumchar(inblock[i]) then
        break;
    dec(i);
    if i>1 then
      delete(inblock,1,i-1);
    if quotmark then
      inblock[1]:=#154
    else
      inblock[1]:='"';
    quotmark:=true;
  end;
  while length(inblock) > 0 do begin
    if IniNumChar(inblock[1]) then begin
    {Abstand berechnen}
      GetComputeX(inblock, xa, dx, rxa);
      difx:=0;
      dify:=0;
      sympary:=0;
      sterny:=0;
      sternflam:=false;
      flamc:=' ';
      rklammerflam:=false;
      eklammerflam:=false;
      gflam:=false;
      for i:=1 to length(inblock) do
        if Ininumchar(inblock[i]) then
          break;
      dec(i);
      tempstr:=copy(inblock,1,i);
      if pos('"',tempstr)<>0 then begin
        if i>1 then
          delete(inblock,1,i-1);
        if quotmark then
          inblock[1]:=#154
        else
          inblock[1]:='"';
        quotmark:=true;
      end else
        if (pos('.',tempstr)=0)and(pos(',',tempstr)=0)
        {TESTING}
        and(pos(' ',tempstr)=0)and(pos('&',tempstr)=0) then
{          quotmark:=false};
    end else { if numchar(inblock[1]) }begin
      { * * * * * * * * * * }
      vogelX:=IniLineEnd(Page[linenum]);
      if xa>vogelX then
        dummy:=vogelX+1
      else if xa=vogelX then
        dummy:=vogelX
      else
        dummy:=xa;
      if dummy=vogelX then
        vogel:=1
      else if dummy=vogelX+1 then begin
        if vogel<>2 then begin
          if vogel=0 then
            c:='Æ'
          else if vogel=1 then
            c:='Ø';
          if vogelX=gmaxx then
            inc(vogelX);
          TxtFnt.WriteChar(vogelX-9,IniYnow(Linenum)-13,
                           c,curcolor,sz8x16,stnormal);
        end;
      end;
      if xa>endx then
        exit;
      { * * * * * * * * * * }
      if (xa>xl)and(xa>startx)and(xa<getmaxX-gcurightmargin) then begin
        c:=inblock[1];
	y:=IniYnow(linenum);
	case c of
          ',' : if length(inblock)>1 then SymNichts(xa,y,rxa);
	  '.' : SymAbsNichts(xa,y);
	  '/' : Slash(xa,y,rxa);
	  '\' : SymDotSlash(xa,y,rxa);
          '›' : SymDotSlash2(xa,y,rxa);
	  ' ' : SymLeer(xa,y,rxa);
          '&' : SymEt(xa+difx,y,rxa);
          '"' : SymQuotMark(xa+difx,y,rxa);
          #154: SymRepQuotMark(xa,y,rxa);
	  '{' : SymGKlammerAuf(xa+difx-charwidth,y+dify,5);
	  '}' : SymGKlammerZu(xa+difx+charwidth,y+dify,5);
	  '(' : begin
            if flamc=' ' then begin
              { Kleine Klammer unten }
              UtiKlammerAufPos(inblock, difx, height,flamc);
              SymNorKlammerAuf(xa + difx, y+sterny, height);
            end else begin
              rklammerflam:= true;
              if inblock[3]=')' then begin
                { kleine Klammer oben }
                SymNorKlammerAuf(xa+difx-charwidth,y+sterny+dify,5);
                gflam:=false;
              end else begin
                { grosse Klammer }
                gflam:=true;
                KlY:=IniYNow(linenum)+5-(y+sterny+dify);
                KlX:=difx;
                if difx>0 then
                  SymNorKlammerAuf(xa-charwidth,IniYNow(linenum),KlY)
                else
                  SymNorKlammerAuf(xa+difx-charwidth,IniYNow(linenum),KlY);
              end;
            end;
          end;
	  ')' : begin
	    if not rklammerflam then begin
              { kleine Klammer unten }
              UtiKlammerZuPos(lastc, dummy, flamc);
              SymNorKlammerZu(xa + difx+dummy, y+sterny+dify, height);
            end else begin
              rklammerflam:=false;
              if gflam then begin
                { grosse Klammer }
                gflam:=false;
                if KlY=0 then
                  KlY:=IniYNow(linenum)+5-(y+sterny+dify);
                if KlX>0 then
                  SymNorKlammerZu(xa+KlX+charwidth,IniYNow(linenum),KlY)
                else
                  SymNorKlammerZu(xa+charwidth,IniYNow(linenum),KlY);
                KlY:=0;
              end else begin
                { kleine Klammer oben }
                SymNorKlammerZu(xa+difx+charwidth,y+sterny+dify,5);
              end;
            end;
	  end;
	  '[' : begin
            if flamc=' ' then begin
              UtiKlammerAufPos(inblock, difx, height, flamc);
  	      SymEckKlammerAuf(xa + difx, y, height);
            end else begin
              eklammerflam:= true;
    	      SymEckKlammerAuf(xa + difx - charwidth, y, 5);
            end;
	  end;
	  ']' : begin
	    if not eklammerflam then begin
              UtiKlammerZuPos(lastc, difx, flamc);
    	      SymEckKlammerZu(xa + difx, y, height);
            end else begin
              eklammerflam:= false;
    	      SymEckKlammerZu(xa + difx + charwidth, y, 5);
            end;
	  end;
	  'a'..'z', 'A'..'Z', #128..#153 : begin
            if flamc=' ' then begin
              difx:= 0;
              dify:= 0;
            end;
            i:=UtiComputeGroup(c,indexc);
            if UtiReplaceChars(c)>0 then
              lastc:=c;
            if i>0 then
              sympary:=-Sympar[indexc,1,i];
	    if printeron then
              PriWriteSym(inblock[1], rxa + 1.0*difx,1.0*(y+sympary+sterny+dify))
            else
              DmeDispChar(xa+difx, y+sympary+sterny+dify, indexc, i);
            if sternflam then
              UtiComputeDxdy(inblock[1],difx,sterny,1,'*');
            flamc:=' ';
	  end;
          '+', '=','-', '*' : begin
            if ((c='*') and (inblock[2] in flamset)) then begin
              sternflam:=true;
              delete(inblock,1,1);
              c:=inblock[1];
            end else if ((c in flamset) and (inblock[2]='*')) then begin
              sternflam:=true;
              delete(inblock,2,1);
            end else begin
              sternflam:=false;
              sterny:=0;
            end;
	    UtiComputeDxdy(inblock, difx, dify, 3, c);
            flamc:=c;
            if sternflam then begin
              dify:=-dify;
              UtiComputeDxdy(inblock, dummy, sterny, 3, '*');
            end;
	  end;
	end; { case inblock[1] of }
      end; {if xa > 15 ....}
      if ((xfirst > xa) and (inblock[1] <> '.')) then begin
           xfirst:= xa;
        if xfirst < grminx then xfirst:= grminx;
      end;
      delete(inblock, 1, 1);
    end; { if numchar(inblock[1]) else}
  end; { while length(inblock) > 0 do }
end;

{**************************************************************}
Function GetMainLine(lineattr: lineattrtype; linenum: integer) : Boolean;

var
    i: integer;

begin
   i:= linenum;
   if lineattr.linestyle > 1 then
   begin
      while ((i < pagelength) and (page[i + 1, 1] = 'N')) do
      begin
        Inc(i);
      end;
      while ((i > 1) and (page[i, 5] = 'H')) do
      begin
        Dec(i);
      end;
   end;
   GetMainLine:= ((linenum = i) and (page[i, 5] <> 'H'));
end;


{***************************************************************}
Procedure GetDrawBeats(lineattr: lineattrtype; linenum: integer);

var
    dx,beatlength : integer;
    i, x0, x, y : integer;
    c : char;
    notec: integer;
    solidb: boolean;

begin
  dx:= IniDxValue(lineattr);
  { Zeichne Line und Beatmarken }
  x0:= IniLeftMargin+1;
  y:=	IniYnow(linenum);
  Case lineattr.linestyle of
    1: MainLine(x0, y, GetMaxX - GcuRightMargin + drightmargin, tkwidth);
    2: SymStaffLine(x0, y, GetMaxX - GcuRightMargin + drightmargin);
    3: ThinLine(x0, y, GetMaxX - GcuRightMargin + drightmargin);
    4: SymDottedLine(x0, y, GetMaxX - GcuRightMargin + drightmargin);
    5: SymInvisibleLine(x0, y,GetMaxX - GcuRightMargin + drightmargin);
  End;
  if (lineattr.linestyle <> 5) then { not a helpline } begin
    x0:= IniFirstBeatPos(lineattr) - dx;
    Case lineattr.linestyle of
      1: Beatlength:=12;
      2: Beatlength:=26;
    3,4: IF GetMainline(lineattr,linenum) Then
           Beatlength:=12
         Else
           Beatlength:=6;
    End;
    x:=x0;
    i:=pos('%',page[linenum]);
    if page[linenum,i+1]<>'.' then begin
      Beat(x, IniYnow(linenum), beatlength, false);
      if (dispgrid<>3) or (GetMainline(lineattr,linenum)) Then
        DistanceMark(x,IniYnow(linenum),x+dx,0,lineattr.eint);
    end;
    for i:=1 to lineattr.beats do begin
      x:=x+dx;
      Beat(x, IniYnow(linenum), beatlength, false);
      if (dispgrid<>3) or (GetMainline(lineattr,linenum)) Then
        DistanceMark(x,IniYnow(linenum),x+dx,0,lineattr.eint);
    end;
{    GetNotePosX(x,notec,linenum,false,true);
    if ((length(page[linenum]) >= notec) and
        (page[linenum, notec] <> '.')) then
      Beat( x, IniYnow(linenum), beatlength, false);}
    If IniLineEnd(page[linenum])<GMaxX then
      Beat(IniLineEnd(page[linenum]), IniYnow(linenum), beatlength,true);

    { Grids im 0. beat zeichnen falls noetig }
    i:=1;
    repeat
      inc(i);
    until (i=length(page[linenum])) or (page[linenum,i]='%');
    inc(i);
    while (i<=length(page[linenum])) and
          ((page[linenum,i]='.') or
          ((page[linenum,i]>='0') and (page[linenum,i]<='9'))) do
      inc(i);
    GetActPosX(x,i,linenum,false);
    if (x<x0+dx) and (i<length(page[linenum])) then
      DistanceMark(x0,IniYnow(linenum),x0+dx,x,lineattr.eint);

{   x:=x0-1;
    repeat
      i:=x;
      inc(x);
      GetNotePosX(x,notec,linenum,false,false);
    until (i=x) or (page[linenum,notec]<>'.') or (x>=x0+dx) or (notec=length(page[linenum]))
    or (((page[linenum,notec+1]<'0') or (page[linenum,notec+1]>'9')) and (page[linenum,notec+1]<>'.'));

    if (x<x0+dx) And ((dispgrid<>3) or (GetMainline(lineattr,linenum)))Then Begin
      DistanceMark(x0,IniYnow(linenum),x0+dx,x,lineattr.eint);
    End;
}
  end; {if lineattr.linestyle}
end;

{**************************************************************}
Procedure GetDrawDistances(lineattr: lineattrtype; linenum, startx: integer);

var
    y : integer;
    rdx,rx0 : real;
    i : integer;
    c : char;

begin
(*   if ((linenum <= pagelength) and
       (GetMainLine(lineattr, linenum) or (dispgrid = 2)) and
       (lineattr.eint > 1) and
       (lineattr.linestyle < 5) and
       (dispgrid > 1)) then
   begin
      rdx:= IniRDxValue(lineattr);

      { Zeichne Distanzmarken }
      rx0:= IniFirstBeatPos(lineattr) - rdx;
      y:=  IniYnow(linenum);

      for i:= 0 to lineattr.beats do
      begin

	DistanceMark(rx0,IniYnow(linenum),rx0+rdx,startx,lineattr.eint);
        rx0:=rx0+rdx;
      end;
   end;*)
end;
{***********************************************}
Function GetDrawSymbol(linenum,actposn : integer;UpdateCursor : Boolean) : Boolean;
{Zeichne das Symbol in Page[linenum,actposn] an der (hoffentlich)richtigen
 Stelle, wenn UpdateCursor True ist, wird GCXCoord nachgefÅhrt. Falls das
 Symbol ausserhalb des Bildschirmes liegt, liefert GetDrawSymbol False zurÅck}

var
    rxa, rx      : real;
    xa, dx, xmin : integer;
    i,j,k        : integer;
    c,c1         : char;
    inblock      : stringline;
    lineattr     : lineattrtype;
    x            : integer;
    difx,dify    : Integer;
begin
  inblock:= page[linenum];
  GetNoteBlock(inblock, lineattr, linenum);
  dx:= IniDxValue(lineattr);
  xa:= IniFirstBeatPos(lineattr) - dx;
  rxa:= xa;
  xmin:= xa;
  while ((length(Page[linenum]) - length(inblock)) < actposn) do begin
    if (IniNumChar(inblock[1])) then begin
    {Abstand berechnen}
      GetComputeX(inblock, xa, dx, rxa);
      if xmin < IniLeftMargin then
        xmin:= xa;
    end else begin
      delete(inblock, 1, 1);
      if inblock='' Then Begin
        GetDrawSymbol:=True;
        Exit;
      End;
    end;
  end;
  {Berechnen von Notec}
  x:= length(Page[linenum]) - length(inblock);
  inblock:= page[linenum];
  GetNoteBlock(inblock, lineattr, linenum);
  c:=Page[Linenum,actposn];
  IF Xa<GetMaxX Then Begin
    GetDrawSymbol:=True;
    if updatecursor then
      gcxcoord:=Xa
  End Else Begin
    GetDrawSymbol:=False;
    Exit;
  End;
  i:=actposn;
  while (not (IniNumChar(page[linenum,i-1]) or
             (IniPrintNote(page[linenum,i-1]))))
    and (i>=commusicstart(page[linenum])) do
    dec(i);
  repeat
    c1:=page[linenum,i];
    inc(i);
  until (c1='+') Or (c1='-') Or (c1='=') Or (c1='*') or (i>=actposn);
  if (c1='+') Or (c1='-') Or (c1='=') Or (c1='*') Then Begin
    UtiComputeDxdy(page[linenum], difx, dify, actposn, c1);
  End Else Begin
    difx:=0;
    dify:=0;
  End;
  i:= UtiComputeGroup(c, c);
  Case C Of
    ',' : SymNichts(xa+difx, IniYnow(linenum)+dify,rxa);
    ' ' : SymLeer(xa+difx, IniYnow(linenum)+dify,rxa);
    '/' : Slash(xa+difx, IniYnow(linenum)+dify,rxa);
    '\' : SymDotSlash(xa+difx, IniYnow(linenum)+dify,rxa);
    '›' : SymDotSlash2(xa+difx, IniYnow(linenum)+dify,rxa);
    '.' :;
    '&' : SymEt(xa+difx, IniYnow(linenum)+dify,rxa);
    '"' : SymQuotMark(xa+difx, IniYnow(linenum)+dify,rxa); {bei & abgeschr., Peo}
  Else
    DmeDispChar( Xa+difx,IniYnow(linenum) - Sympar[c, 1, i]+dify,c,i);
  End;{Case}
end;

{***********************************************}

Function GetValidStaff(Var linenum : integer) : Boolean;
Var i,ii,j      : integer;
    s        : Stringline;
    lineattr : lineattrtype;

Begin
  IF page[linenum,1]='N' Then Begin
    s:=page[linenum];
    getnoteattributes(s,lineattr);
  End Else Begin{IF page[linenum,1]='N'}
    lineattr:=actattr;
  End;{IF page[linenum,1]='N' Else}
  IF lineattr.linestyle<>2 Then Begin
    GetValidstaff:=True;
    Exit;
  End;{IF lineattr.linestyle<>2}
  IF linenum<CtrlEnterOfs-1 Then Begin
     GetvalidStaff:=False;
     Exit;
  End;{IF linenum<CtrlEnterOfs-1}
  if (linenum>pagelength) or (linenum<4) Then begin
    getvalidstaff:=true;
    exit;
  end;
  For i:=linenum downto linenum-4 Do Begin
    IF Page[i,1]='N' Then Begin
      j:=i+1;
      For ii:=j to j+8 Do Begin
        IF (ii<=pagelength) and (Page[ii,1]='N') Then Begin
          if ii>=j+4 Then Begin
            s:=page[ii];
            GetNoteAttributes(s,lineattr);
            if lineattr.linestyle<>2 Then Begin
              linenum:=ii;
              GetValidStaff:=True;
              Exit;
            End Else Begin{if lineattr.linestyle<>2}
              GetvalidStaff:=False;
              Exit;
            End;{if lineattr.linestyle<>2 Else}
          End Else Begin{if ii>=j+5}
            GetvalidStaff:=False;
            Exit;
          End;{if ii>=j+5 else }
        End {if page[ii,1]='N'}else begin
          if i>pagelength then begin
            GetValidstaff:=false;
            exit;
          end;
        end;
      End;{For ii:=j to j+10}
      linenum:=j+5;
      GetValidStaff:=True;
      Exit;
    End;{IF Page[i,1]='N'}
  End;{For i:=linenum downto linenum-5}
  if linenum>pagelength then
    linenum:=pagelength;
End;

Procedure GetReDraw(linenum, startx,endx : integer);
Var i, xfirst : integer;
    inblock : stringline;
    lineattr : lineattrtype;
Begin
  for i:=linenum-2 to linenum+5 do begin
    if (i>=0) and (i<=pagelim) then begin
      if page[i,1] = 'N' then begin
        inblock:= page[i];
        GetNoteBlock(inblock, lineattr, i);
        GetDrawBlock(inblock, i, lineattr, startx, endx, xfirst);
        if lineattr.linestyle=2 then
          GetDrawBeats(lineattr, i);
      end else
        titgettext(i,startx);
    end;
  end;
End;

{***********************************************}
Procedure GetDrawSystems(lineattr : lineattrtype; linenum : integer);
var offs : integer;
Begin
  if lineattr.linestyle=2 then
    offs:=-20
  else
    offs:=0;
  if printeron then begin
    if page[linenum,2]='S' then begin
      PriSetLineWidth(2);
      if NotFindSysEnd(linenum)=linenum then begin
        PriDrawLine(1,IniYNow(linenum)+offs,1,IniYNow(linenum)+5);
      end else begin
        PriDrawLine(1,IniYNow(linenum)+offs,1,IniYNow(NotFindSysEnd(linenum)));
      end;
    end else if page[linenum,2]='E' then begin
      PriSetLineWidth(2);
      PriDrawLine(1,IniYNow(linenum)-5,1,IniYNow(linenum));
    end;
  end else begin
    if page[linenum,2]='S' then begin
      if NotFindSysEnd(linenum)=linenum then begin
        Line(2,IniYNow(linenum)+offs,2,IniYNow(linenum)+5);
        Line(3,IniYNow(linenum)+offs,3,IniYNow(linenum)+5);
      end else begin
        Line(2,IniYNow(linenum)+offs,2,IniYNow(NotFindSysEnd(linenum)));
        Line(3,IniYNow(linenum)+offs,3,IniYNow(NotFindSysEnd(linenum)));
      end;
    end else if page[linenum,2]='E' then begin
      Line(2,IniYNow(linenum)-5,2,IniYNow(linenum));
      Line(3,IniYNow(linenum)-5,3,IniYNow(linenum));
    end;
  end;
End;
Begin
End.

