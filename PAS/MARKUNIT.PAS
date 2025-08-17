unit markunit;

interface

uses
    graph,
    crt,
    dos,
    gcurunit,
    initsc;

Procedure MarkInit;
Procedure MarkStart(actpos, linenum, nowpage: integer);
Procedure MarkEnd(actpos, linenum, nowpage: integer);
Procedure MarkDisplay;
Procedure MarMarkToBuffer(actptr, startptr, lastptr: listptr);
Procedure MarDeleteBlock(var actptr, startptr, lastptr : listptr);
Procedure MarkInverse(lstart, lend, mstartx, mendx : integer);

implementation

uses textunit,
     fileunit,
     utilunit,
     specunit,
     pageunit,
     getunit;
                                                                              {
лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл}

Procedure MarRemoveFromHeap(var heapsptr, heapeptr,
                            actptr, startptr, lastptr : listptr);
{Entfernt von heapsptr bis und ohne heapeptr vom Heap}

var tempptr, prevptr: listptr;

begin
   repeat
      tempptr:= heapsptr;
      prevptr:= heapsptr^.last;
      heapsptr:= heapsptr^.next;
      heapsptr^.last:= prevptr;
      prevptr^.next:=heapsptr;
      if startptr = tempptr then startptr:= heapsptr;
      if actptr = tempptr then actptr:= heapsptr;
      dispose(tempptr);
      tempptr:= heapsptr;
   until tempptr = heapeptr;
end;
                                                                              {
лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл}

Procedure MarDeleteBlock(var actptr, startptr, lastptr : listptr);
{lscht den Markierten Block}

var heapfptr: listptr;
    eline, j : byte;
    lpage, emptyline: integer;
    endreached: boolean;
    tempbuf, inblock: stringline;
    tbufpos: byte;
    i: integer;
                                                                              {
    нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн}

    Procedure MarEmptyLines(var heapptr: listptr; var emptyl: integer);

    var i: integer;

    begin
       if emptyl > 0 then
       begin
          FilStringSeparate(tempbuf, heapptr, startptr, lastptr, tbufpos);
          tempbuf:= '';
          tbufpos:= 0;
          for i:= 1 to emptyl do
          begin
             FilHeapInsertString('T' + chr(0),  heapptr, startptr, lastptr,
                                 heapptr, false);
          end;
          emptyl:= 0;
       end;
    end;
                                                                              {
    нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн}

    Procedure MarClearLine(var heapptr: listptr; var emptyl: integer;
                           linenum: integer; delflag : boolean);
    begin
       FilCheckLine(tempbuf, inblock, heapptr, startptr, lastptr,
                    tbufpos, endreached, false, false);
       {lasse Header/Footer unverndert}
       if ((length(inblock) > 4) and (inblock[4] <> 'F')) then
       begin
          FilCheckLine(tempbuf, inblock, heapptr, startptr, lastptr,
                       tbufpos, endreached, true, delflag);
          if delflag then emptyl:= emptyl + 1;
       end else
       begin
          MarEmptyLines(heapptr, emptyl);
          FilCheckLine(tempbuf, inblock, heapptr, startptr, lastptr,
                       tbufpos, endreached, true, false);
       end;
       if linenum = pagelength then
       begin
          MarEmptyLines(heapptr, emptyl);
          FilStringSeparate(tempbuf, heapptr, startptr, lastptr, tbufpos);
      end;
    end;
                                                                              {
    нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн}

begin
   if not marpartline then
   begin
      {initialisieren des buffers}
      tempbuf:= '';
      tbufpos:= 0;
      emptyline:= 0;

      {aktuelle Seite speichern}
      FilSavePage(topmargin, pagelength, actptr, startptr, lastptr);

      {Pointer auf Beginn und Ende des markierten Bereichs suchen}
      FilFindPtr(mstart.mpag, mstart.mline, heapfptr,
                 startptr, lastptr, false);

      {Anzahl ganze Seiten zum Loeschen berechnen}
      lpage:= mend.mpag - mstart.mpag - 1;
      if lpage < 0 then lpage:= 0;

      {letzte Zeile auf erster Seite bestimmen}
      if mstart.mpag = mend.mpag then
      begin
         eline:= mend.mline;
      end else
      begin
         eline:= pagelength;
      end;

      {Zeilen loeschen}
      for i:= mstart.mline to eline do
      begin
         MarClearLine(heapfptr, emptyline, i, true);
      end;

      {Seitenende der ersten Seite suchen}
      for i:= eline + 1 to pagelength do
      begin
         MarClearLine(heapfptr, emptyline, i, false);
      end;

      {ganze Seiten loeschen}
      for j:= 1 to lpage do
      begin
         for i:= topmargin to pagelength do
         begin
            FilHeapExtractString(inblock, heapfptr, startptr, lastptr);
         end;
      end;

      {letzte Seite}
      if mstart.mpag < mend.mpag then
      begin
         {initialisieren des buffers}
         tempbuf:= '';
         tbufpos:= 0;
         emptyline:= 0;
         eline:= mend.mline;

         {Zeilen loeschen}
         for i:= topmargin to eline do
         begin
            MarClearLine(heapfptr, emptyline, i, true);
         end;

         {Seitenende der letzten Seite suchen}
         for i:= eline + 1 to pagelength do
         begin
            MarClearLine(heapfptr, emptyline, i, false);
         end;
      end;

      {Suchen der aktuellen Seite}
      FilFindPage(pagecount, lpage, actptr, startptr, lastptr);
      while ((actptr = lastptr) and (pagecount > 0)) do
      begin
         pagecount:= pagecount - 1;
         FilFindPage(pagecount, lpage, actptr, startptr, lastptr);
      end;
      PagGetPageFromHeap(actptr, startptr, lastptr, i);
   end else  {if not marpartline}
   begin
      {Teil einer Zeile lschen}
      if mstart.mpag = pagecount then
      begin
         delete(page[mstart.mline], mstart.mpos,
                mend.mpos - mstart.mpos + 1);
      end else {if mstart.mpage = pagecount then}
      begin
         if pagecount < mstart.mpag then
         begin
            i:= mstart.mpag - 1
         end else
         begin
            i:= mstart.mpag;
         end;
         FilFindPtr(i, mstart.mline, heapfptr,
                    startptr, lastptr, false);
         FilHeapExtractString(inblock, heapfptr, startptr, lastptr);
         delete(inblock, mstart.mpos, mend.mpos - mstart.mpos + 1);
         FilHeapInsertString(inblock + chr(0), heapfptr, startptr, lastptr,
                             heapfptr, false);
      end; {else if mstart.mpag = pagecount then}
   end; {else if marpartline }
end;
                                                                              {
лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл}

Procedure MarMarkToBuffer(actptr, startptr, lastptr: listptr);
{Kopiert den markierten Teil in den Buffer}

var inblock: stringline;
    bufsptr, bufeptr: listptr;
    sline, eline, i: byte;
                                                                              {
    нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн}

    Procedure MarPtrToBuf;
    {Kopiert von bufsptr bis bufeptr in den buffer}

    var tempptr: listptr;
        count, tbufpos: byte;
        endreached, ok1, ok2: boolean;
        tempbuf: stringline;


    begin
       count:= 1;
       tempptr:= bufsptr;
       tbufpos:= 0;
       tempbuf:= '';
       ok1:= false;
       ok2:= false;
       repeat
          FilCheckLine(tempbuf, inblock, tempptr, startptr, lastptr,
                       tbufpos, endreached, true, false);
          if ok1 then
          begin
             ok2:=((bufeptr <> tempptr) or (endreached));
          end else
          begin
             ok1:= (bufeptr = tempptr);
          end;
          if not (ok1 and ok2) then
          begin
             while length(inblock) < linemarker do
             begin
                inblock:= inblock + ' ';
             end;
             if ((length(inblock) < 4) or (inblock[4] <> 'F')) then
             begin
                FilHeapInsertString(inblock + chr(0), bufactptr, bufstartptr,
                                    bufendptr, bufactptr, false);
             end;
             count:= count + 1;
             if count = pagelength then
             begin
                FilHeapSqueeze(bufactptr, bufstartptr, bufendptr, false);
                count:= 1;
             end;
          end;
       until (ok1 and ok2);
       FilHeapSqueeze(bufactptr, bufstartptr, bufendptr, false);
    end;
                                                                               {
    нннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннннн}

begin
  if (mstart.mpag=-1) or (mend.mpag=-1) then
    exit;
  filbufclear;
  lastbuf:=1;
  {Bereich vor der aktuellen Seite}
  if pagecount > mstart.mpag then begin
  {suche Startpointer}
    FilFindPtr(mstart.mpag, mstart.mline, bufsptr, startptr, lastptr,
               false);
  {Suche endpointer}
    if pagecount > mend.mpag then begin
      FilFindPtr(mend.mpag, mend.mline, bufeptr, startptr, lastptr,
                 true);
    end else
    begin
      bufeptr:= actptr;
    end;
    {Kopiere in Buffer}
    MarPtrToBuf;
  end;
  {Aktuelle Seite kopieren}
  if ((pagecount >= mstart.mpag) and (pagecount <= mend.mpag)) then begin
  {erste Zeile}
    if pagecount > mstart.mpag then begin
      sline:= topmargin;
    end else
    begin
      sline:= mstart.mline;
    end;
    {letzte Zeile}
    if pagecount < mend.mpag then begin
      eline:= pagelength;
    end else
    begin
      eline:= mend.mline;
    end;
    {Kopieren in den Buffer}
    for i:= sline to eline do begin
      if not IniHeaderFooterLine(i) then begin
        FilHeapInsertString(page[i] + chr(0), bufactptr, bufstartptr, bufendptr,
                            bufactptr, false);
      end;
    end;
    FilHeapSqueeze(bufactptr, bufstartptr, bufendptr, false);
  end; { if ((pagecount >= mstart.mpag) and (pagecount <= mend.mpag)) }

  {Bereich nach der aktuellen Seite}
  if pagecount < mend.mpag then begin
    if pagecount >= mstart.mpag then begin
      bufsptr:= actptr;
    end else
    begin
      FilFindPtr(mstart.mpag - 1, mstart.mline, bufsptr,
                 startptr, lastptr, false);
    end;
    FilFindPtr(mend.mpag - 1, mend.mline, bufeptr, startptr, lastptr,
               true);
    {Kopiere in Buffer}
    MarPtrToBuf;
  end;
end;
                                                                              {
лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл}

Procedure MarSwitchStyle(var switch: boolean);

begin
  if switch then
  begin
     SetColor(speccolor);
     SetLineStyle(4, $AAAA, 1);
     switch:= false;
  end else
  begin
     SetColor(speccolor);
     SetLineStyle(4, $5555, 1);
     switch:= true;
  end;
end;
                                                                              {
лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл}

Procedure MarkDrawLine(i1, i2, j1: integer; firstswitch: boolean);
{zeichnet einen Balken am linken Rand/rechten Rand}

var j2, i: integer;
    switch: boolean;

begin
   j2:= j1 + 5;
   switch:= firstswitch;
   for i:= i1 to i2 do
   begin
      MarSwitchStyle(switch);
      Line(j1+1, i, j2, i);
   end;
end;

{лллллллллллллллллллллллл Markierungen ллллллллллллллллллллллллллллллллллллллл}

Procedure MarkInverse(lstart, lend, mstartx, mendx : integer);

var i, i1, i2, j1, j2: integer;
    switch : boolean;

begin
{ўўўўўўўўўўўўўўўўўўўўўўўўErste Zeile ўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўў}
  i1:= IniYnow(lstart) - 4;
  if page[lstart, 1] = 'N' then
    i1:= i1 + 1;
  i2:= i1 + 6{markheight};

  j1:= mstartx+1;
  j2:= gmaxX - GcuRightMargin + drightmargin {- 1};
  if lend = lstart then
    j2:= mendx;

  switch:= true;
  if j2=j1+7               then switch:= false;
  if marpartline           then switch:= false;
  if page[lstart, 1] = 'T' then switch:= false;

  MarSwitchStyle(switch);
  for i:= i1 to i2 do
  begin
    Line(j1, i, j2, i);
    MarSwitchStyle(switch);
  end;

(*  if lend > lstart{ + 1} then
  begin
{ўўўўўўўўўўўўўўўўўўўўўўўў Zwischenzeile links ўўўўўўўўўўўўўўўўўўўўўўўўўўўў}
    i1:= i2 + 1; *)
{    i2:= IniYnow(lend) -4; }

{    switch:= false;
    if (page[lstart,1] = 'N') xor
       (page[lend  ,1] = 'N') then
    begin
      if (page[lstart,1] = 'N') and
         (page[lend  ,1] = 'T') and
         (lend>lstart+1)       then
        switch:= false;
      if (page[lstart,1] = 'T') and
         (page[lend  ,1] = 'N') and
         (lend>lstart+1)       then
        switch:= false;
      if (page[lstart,1] = 'N') and
         (page[lend  ,1] = 'N') then
        switch:= true;
      MarkDrawLine(i1, i2, IniLeftMargin, false);
    end;
    if (page[lstart,1] = 'T') or
       (page[lend  ,1] = 'T') then
    begin
      if (page[lstart,1] = 'T') and
         (page[lend  ,1] = 'N') then
        switch:= true;
      MarkDrawLine(i1, i2-1, IniLeftMargin, true);
    end;  }
{ўўўўўўўўўўўўўўўўўўўўўўўў Zwischenzeile rechts ўўўўўўўўўўўўўўўўўўўўўўўўўўў}
{    j1:= gmaxX - GcuRightMargin + drightmargin-6;

    if page[lend, 1] = 'T' then
      MarkDrawLine(i1, i2-1, j1, false)
    else
      MarkDrawLine(i1, i2  , j1, true);
  end;     }

  if lend > lstart then
  begin
{ўўўўўўўўўўўўўўўўўўўўўўўў letzte Zeile ўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўўў}

    i1:= IniYnow(lend) -3; {i2 + 1;}
    if  page[lend  ,1] = 'T'  then
      i1:=i1-1;
    if (page[lend  ,1] = 'T') and
       (lend=lstart+1)        then
      i1:=i1-1;
    if (page[lstart,1] = 'N') and
       (page[lend  ,1] = 'T') and
       (lend=lstart+1)        then
      i1:=i1+1;
    if (page[lstart,1] = 'T') and
       (page[lend  ,1] = 'N') and
       (lend=lstart+1)        then
      i1:=i1-2;
    if (page[lstart,1] = 'N') and
       (page[lend  ,1] = 'N') and
       (lend=lstart+1)        then
      i1:=i1-1;

    i2:= i1 + 6{markheight};
    if (page[lstart,1] = 'N') and
       (page[lend  ,1] = 'N') and
       (lend=lstart+1)        then
      i2:=i2;
    if (page[lstart,1] = 'N') and
       (page[lend  ,1] = 'T') and
       (lend=lstart+1)        then
      i2:=i2;
    if (page[lend  ,1] = 'T') and
       (lend=lstart+1)        then
      i2:=i2+1;
    if (page[lstart,1] = 'N') and
       (page[lend  ,1] = 'T') and
       (lend=lstart+1)        then
      i2:=i2-1;
    if (page[lstart,1] = 'T') and
       (page[lend  ,1] = 'N') and
       (lend=lstart+1)        then
      i2:=i2+2;
    if (page[lstart,1] = 'N') and
       (page[lend  ,1] = 'N') and
       (lend=lstart+1)        then
      i2:=i2+1;

    j1:= IniLeftMargin+1;
    j2:= gmaxX - GcuRightMargin + drightmargin {- 1};

    switch:= false;
    if (page[lstart,1] = 'N') and
       (page[lend  ,1] = 'N') and
       (lend=lstart+1)        then
      switch:= true;
    if  page[lend  ,1] = 'T'  then
      switch:= true;
    if (page[lend  ,1] = 'T') and
       (lend=lstart+1)        then
      switch:= false;
    if (page[lstart,1] = 'N') and
       (page[lend  ,1] = 'T') and
       (lend=lstart+1)        then
      switch:= true;
    if (page[lstart,1] = 'T') and
       (page[lend  ,1] = 'N') then
      switch:= false;

    for i:= i1 to i2 do
    begin
      Line(j1, i, j2, i);
      MarSwitchStyle(switch);
    end;
  end; { if lend > lstart then }
end;
                                                                              {
лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл}

Procedure MarkStart(actpos, linenum, nowpage: integer);
      {Starte Block}

var i: integer;

begin
   mstart.mline:= linenum;
   mstart.mpag:= nowpage;
   i:= actpos;
   if page[linenum, 1] = 'N' then
   begin
      UtiCharBegin(page[linenum], i);
   end;
   mstart.mpos:= i;
   mstart.mxcoord:= gcxcoord - (actpos - i + 1)*char2width;
end;
                                                                              {
лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл}

Procedure MarkEnd(actpos, linenum, nowpage: integer);
   {Beende Block}

var i, x : integer;
    mpos,mline,mpag : integer;
begin
  if ((mstart.mpag < nowpage) or
      ((mstart.mpag = nowpage) and (mstart.mline < linenum)) or
      ((mstart.mpag = nowpage) and (mstart.mline = linenum) and
       (mstart.mpos <= actpos))) then begin
{    FilBufClear;}
    if ((mstart.mpag <> nowpage) or (mstart.mline <> linenum)) then begin
    {block markierung,  mehr als eine Zeile}
      mend.mline:= linenum;
      mend.mpos:= length(page[mend.mline]);
      mend.mpag:= nowpage;
      mend.mxcoord:= gmaxX - Gcurightmargin + drightmargin - 1;
      mstart.mxcoord:= IniLeftMargin;
      marpartline:= false;
    end else
    begin
      mend.mline:= linenum;
      mend.mpag:= nowpage;
      mend.mpos:= actpos;
      if page[linenum, 1] = 'N' then begin
        while IniNumChar(page[linenum, mend.mpos + 1]) do begin
          mend.mpos:= mend.mpos + 1;
        end;
      end;
      mend.mxcoord:= gcxcoord + char2width - 1;
      marpartline:= true;
    end;
  end else
  begin
    mpos:=mstart.mpos;
    mpag:=mstart.mpag;
    mline:=mstart.mline;
    x:=mstart.mxcoord;
    MarkStart(actpos, linenum, nowpage);
    i:=gcxcoord;
    gcxcoord:=x;
    MarkEnd(mpos,mline,mpag);
    gcxcoord:=i;
  end;
end;
                                                                              {
лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл}

Procedure MarkDisplay;

var leftx, rightx, topl, botl : integer;
    oldcolor: byte;

begin
   if (pagebuf=pagecount) then begin
     MarkInverse(1,Pagelength,grminx,grmaxx);
     exit;
   end;
   if ((mstart.mpag <= pagecount) and (pagecount <= mend.mpag)) then
   begin
      leftx:= IniLeftMargin;
      rightx:= gmaxX - GcuRightMargin;
      topl:= topmargin;
      botl:= pagelength;
      if mstart.mpag = pagecount then
      begin
         leftx:= mstart.mxcoord;
         topl:= mstart.mline;
      end;
      if mend.mpag = pagecount then
      begin
         rightx:= mend.mxcoord;
         botl:= mend.mline;
      end;
      MarkInverse(topl, botl, leftx, rightx);
   end else
   begin
      if ((mstart.mpag = pagecount) and (mend.mpag = -1)) then
      begin
         MarkInverse(mstart.mline, mstart.mline, mstart.mxcoord,
                     mstart.mxcoord + 7{6});
      end;
   end;

   {header und footer marken anzeigen}
   if ((setuppage in actedit) or (dispspec = 1)) then
   begin
      oldcolor:= GetColor;
      SetColor(speccolor);
      topl:= topmargin;
      while (IniHeaderFooterLine(topl)) do
      begin
         topl:= topl + 1;
      end;
      if (IniHeaderFooterLine(topl - 1)) then
      begin
         MarkDrawLine(1, IniYNow(topl - 1) + 2, IniLeftMargin{+1}, false);
      end;

      botl:= pagelength;
      while (IniHeaderFooterLine(botl)) do
      begin
         botl:= botl - 1;
      end;
      if ((botl <= pagelength) and
          (IniHeaderFooterLine(pagelength))) then
      begin
         MarkDrawLine(IniYNow(botl) + 6{markheight} - 4,
                      IniYBottomMargin - 1,
                      IniLeftMargin{+1}, false);
      end;
      SetColor(oldcolor);
   end; { if ((dispspec > 0) or (setuppage in actedit)) then }
   SetLineStyle(0, 1, 1);
end;
                                                                              {
лллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллллл}

Procedure MarkInit;

begin
   mstart.mpag:= -1;
   mend.mpag:= -1;
end;

end.




