unit Specunit;

interface

uses
     Graph,
     InitSc,
     menutyp,
     Imenuunit,
     crt,
     UserExit,
     Dos,
     Comunit,
     mousdrv;

Procedure SpeInsNoteLine(var linenum, actposn: integer;
                         var tempptr, startptr, lastptr: listptr);
Procedure SpeInsTextLine(linenum: integer; var actpost: integer;
                         var actptr, startptr, lastptr: listptr;
                         delflag: boolean);
Procedure SpeNoteRight(linenum: integer; var actpos: integer);
Procedure SpeInsertBuffer(linenum: integer; var actposn, actpost: integer;
                          var actptr, startptr, lastptr: listptr;
                          var pageswap: boolean);
Procedure SpeTextRight(linenum: integer; var actpos: integer);
Procedure SpeLineDelete(linenum: integer; fill : boolean);
Procedure SpeLineInsert(linenum: integer; inblock : stringline);
Procedure SpeLastFilled(var lline: integer);
Procedure SpeEdLineAttr(linenum: integer; var actposn, actpost: integer;var startptr, lastptr : listptr);
Function SpeSpaceInPage(lines: integer): boolean;
Procedure SpeSplitPage(linenum: integer; var actposn, actpost: integer;
                       var actptr, startptr, lastptr: listptr);
Procedure SpeJoinPage(linenum: integer; var actposn, actpost: integer;
                      var actptr, startptr, lastptr: listptr);
Procedure SpeLineToBuf(linenum, actposn, actpost: integer;
                       var actptr, startptr, lastptr: listptr);
Procedure SpeMoveBlock(linenum: integer; var actposn, actpost: integer;
                       var actptr, startptr, lastptr: listptr);
Procedure SpeSplitFile(var actptr, startptr, lastptr: listptr);
Procedure SpeBlockCommands(var linenum, actposn, actpost: integer;
                           var actptr, startptr, lastptr: listptr;
                           inchar: char);
Function SpeDelPossible(Linenum : Integer) : Boolean;
Function SpeInsPossible(Linenum : Integer;T : Integer;Var InsL,Ins : Byte;
                        Num : Byte;D : Boolean;U : Boolean) : Boolean;
Function SpeLineUsed(Linenum : Integer) : Boolean;
Function SpeLinesFree(Linenum : Integer;Up : Boolean) : Integer;
Function SpeMinSpace(Instring : Stringline) : Integer;
Function SpeprevNotLine(Linenum : Integer) : Integer;
Function SpeNextNotLine(Linenum : Integer) : Integer;

Procedure SpeLineCommands(var linenum, actposn, actpost: integer;
                          var actptr, startptr, lastptr: listptr);

implementation

uses
     GCurUnit,
     Symbols,
     GetUnit,
     TitleUnit,
     Textunit,
     inout,
     fileunit,
     pageunit,
     printunit,
     markunit,
     graphmenu,
     grintunit,
     sp2unit,
     helpunit,
     Texts,
     NoteUnit;

Var RErr : Boolean;

{*****************************************************************}
Procedure SpeBlockCommands(var linenum, actposn, actpost: integer;
                           var actptr, startptr, lastptr: listptr;
                           inchar: char);

var dir: movement;
    c: char;
    choicenum: byte;
    y, hy, i, endy: integer;
    instring: string16;
    dummyb: boolean;
    bfile: text;
    inblock: stringline;
    mausx, mausy, maustaste, mausmenu: word;

begin
  ImeIniBlockMenu;
  choicenum:= 1;
  maustaste:= 0;
  repeat
    if inchar = ' ' then begin
      PagRefClearVal(grminx - 10, grminy - 10,
                     grmaxx + 10, grmaxy + 10);
      y:= grmaxy - (usrmenu.num_choices * usrmenu.spacing +
          usrmenu.menuattr.firstline + 2) * charheight;
      hy:= y div charheight;
      GrDisplay_Frame(grminx, y, grmaxx, grmaxy, true, false);
      GrDisplay_Menu(hfminx, hy, usrmenu, 0);
      GrGet_Menu_Response(hfminx, hy, usrmenu, c, dir,
                          choicenum, mausx, mausy, maustaste,
                          mausmenu, false, 0);
      c:= UpCase(c);
    end else begin
      c:= inchar;
    end;
    case c of
      'S': {start block}begin
        MarkStart(IniPos(linenum, actposn, actpost),
                  linenum, pagecount);
        MarkDisplay;
      end;
      'E': {end block}begin
        if mstart.mpag <>-1 then begin
          i:= mstart.mxcoord;
          MarkEnd(IniPos(linenum, actposn, actpost),
                  linenum, pagecount);
          if pagecount = mstart.mpag then begin
            PagRefClearVal(i - 3,
            IniYnow(mstart.mline - 1),i + 9,IniYnow(mstart.mline + 1));
          end else begin
            MarkDisplay;
          end;
        end;
      end;
      'U': {Shift F3: Unmark}begin
        FileChanged:=1;
        SpeInsertBuffer(linenum, actposn, actpost, actptr,
                        startptr, lastptr, dummyb);
        PagUnMark;
      end;
      'C': begin
        filbufclear;
        MarMarkToBuffer(actptr, startptr, lastptr);
      end;
      'P': begin
        SpeInsertBuffer(linenum, actposn, actpost, actptr,
                        startptr, lastptr, dummyb);
        PagUnMark;
      end;
      'M': begin
        if mend.mpag <> -1 then begin
          FileChanged:=1;
          MarMarkToBuffer(actptr, startptr, lastptr);
          MarDeleteBlock(actptr, startptr, lastptr);
          PagUnMark;
          SpeInsertBuffer(linenum, actposn, actpost,
                          actptr, startptr, lastptr, dummyb);
{          SpeMoveBlock(linenum, actposn, actpost, actptr,
                        startptr, lastptr);}
        end else begin
          HlpHint(HntNoMarkedArea, HintWaitEsc);
        end;
      end;

      'D': begin
        if mend.mpag<>-1 then begin
          if mstart.mpag=mend.mpag then begin
          {*** Check & Update S/E Marks BEGIN***}
            if mstart.mline<>mend.mline then begin
              i:=mstart.mline;
              if Page[i,1]<>'N' Then
                i:=NotNextLine(i);
              repeat
                if NotIsSys(i)='S' then
                  if NotIsSys(NotNextLine(i))=' ' then
                    NotSysStart(NotNextLine(i));
                if NotNextLine(i)=i then
                  break;
                i:=NotNextLine(i);
              until i>NotPrevLine(mend.mline+1);
              i:=mend.mline;
              if page[i,1]<>'N' Then
                i:=NotPrevLine(i);
              repeat
                if NotIsSys(i)='E' then
                  if NotIsSys(NotPrevLine(i))=' ' then
                    NotSysEnd(NotPrevLine(i));
                if NotPrevLine(i)=i then
                  break;
                i:=NotPrevLine(i);
              until i<NotNextLine(mstart.mline-1);
            end;
          {*** Check & Update S/E Marks END***}
          end;
          MarMarkToBuffer(actptr, startptr, lastptr);
          MarDeleteBlock(actptr, startptr, lastptr);
          MarkInit;
          if marpartline then begin
            endy:= IniYnow(linenum + 1);
            PagRefClearVal(0, 0, gmaxX, endy);
          end else begin
            PagRefPage;
          end;
        end else begin
           HlpHint(HntNoMarkedArea, HintWaitEsc);
        end;
      end;

      'W': begin
      {$IFDEF DEMO}
        HlpHint(HntDemoBuf,0);
      {$ELSE}
        if mend.mpag <> -1 then begin
          MarMarkToBuffer(actptr, startptr, lastptr);
          inblock:='';
          IniExpand(inblock,49);
          IniInversText(31,(TOP_LINE+choicenum*usrmenu.SPACING),
          inblock,frLow);
          if HlpGetFileName(instring,'.buf',51,(TOP_LINE+
                            choicenum*usrmenu.SPACING)+1) then begin
            dummyb:= true;
            if IniFileExist(bufdir + '\' + instring) then begin
              if not HlpAreYouSure('File already exists, overwrite?',hpEdit) then
                dummyb:= false;
            end;
            if dummyb then begin
              assign(bfile, bufdir + '\' + instring);
              LastFileName:=FExpand(bufdir + '\' + instring);
              rewrite(bfile);
              writeln(bfile,'$$$RNSBUFFER$$$');
              if marpartline then
                i:= 1
              else
                i:= 0;
              writeln(bfile, i:6,
                mstart.mline:6, mstart.mpos:6,
                mstart.mpag:6,
                mend.mline:6, mend.mpos:6, mend.mpag:6);
              FilHeapToFile(bfile, bufactptr,
                bufstartptr, bufendptr, false,
                true,false);
              PagUnmark;
            end;
          end; {if HlpGetFileName(instring) then }
        end {if mstart.mpage }else begin
          HlpHint(HntNoMarkedArea, HintWaitEsc);
        end;
      {$ENDIF}
      end;

      'R': begin
      {$IFDEF DEMO}
        HlpHint(HntDemoBuf,0);
      {$ELSE}
        if mstart.mpag = -1 then begin
          Mausbereich(GrMinX+1,GrMinX+20*8,GrMinY,GrMaxY);
          instring:=FilFileSelect('Select Bufferfile','*.buf',bufdir);
          if instring<>'' then begin
            if not IniFileExist(bufdir + '\' + instring) then begin
              HlpHint(HntNotExist, HintWaitEsc);
            end else begin
              assign(bfile, bufdir + '\' + instring);
              LastFileName:=FExpand(bufdir + '\' + instring);
              reset(bfile);
              readln(bfile, inblock);
              if(inblock = '$$$RNSBUFFER$$$') then begin
                readln(bfile, i,mstart.mline, mstart.mpos, mstart.mpag,
                       mend.mline, mend.mpos, mend.mpag);
                marpartline:= (i = 1);
                mstart.mpag:=-1;
                mend.mpag:=-1;
                FilFileToHeap(bfile, bufactptr,
                   bufstartptr, bufendptr, dummyb);
                SpeInsertBuffer(linenum, actposn, actpost,
                   actptr, startptr, lastptr, dummyb);
                Markinit;
              end else begin
                LastFileName:=FExpand(TextRec(bfile).Name);
                close(bfile);
                HlpHint(HntNotBlockFile, HintWaitEsc);
              end;
            end;
          end; {if HlpGetFileName(instring) then }
        end else {if mstart.mpag = -1 then} begin
          HlpHint(HntUnmarkBlockFirst, HintWaitEsc);
        end;
      {$ENDIF}
      end; {'R'}

      'I': {Collect Header/Footer}begin
        FilSavePage(1, PageLength, actptr, startptr, lastptr);
        Sp2HeaderFooterToBuffer(actptr, startptr, lastptr,
                                bufactptr, bufstartptr,
                                bufendptr);
        PagShowPage(linenum, actposn, actpost,
                    actptr, startptr, lastptr,
                    pagecount, false);
      end;
    end; {case c of}
    if pos(c,usrmenu.choices)>0 then
      c:=#27;
  until ((c=#27) or (inchar<>' '));
end;

{*************************************************************************}
Procedure SpeInsEmptyLines(var lineins: integer;
                           var actptr, startptr, lastptr: listptr);
{Fuegt lineins leere Zeilen in den Heap}

var i: integer;

begin
   for i:= 1 to lineins do
   begin
      FilHeapInsertString('T    ' + chr(0), actptr,
                          startptr, lastptr, actptr, false);
   end;
end;

{*************************************************************************}
Procedure SpeInsFooter( var actptr, startptr, lastptr: listptr);
{Fuegt den Footer in den Heap ein}

var i: integer;

begin
   i:= pagelength;
   while IniHeaderFooterLine(i) do
   begin
      i:= i - 1;
   end;
   i:= i + 1;
   while i <= pagelength do
   begin
      FilHeapInsertString(page[i] + chr(0), actptr,
                          startptr, lastptr, actptr, false);
      i:= i + 1;
   end;
end;

{*************************************************************************}
Procedure SpeInsHeader(var actptr, startptr, lastptr: listptr);
{Fuegt den Header in den Heap ein}

var i: integer;

begin
   i:= topmargin;
   while IniHeaderFooterLine(i) do
   begin
      FilHeapInsertString(page[i] + chr(0),
                          actptr, startptr, lastptr,
                          actptr, false);
      i:= i + 1;
   end;
end;

{******************************************************}
Procedure SpeSplitFile(var actptr, startptr, lastptr: listptr);
{schreibt von der n�chsten Seite an alles in ein neues File}

var instring: string16;
    ok : boolean;
    outfile: text;
    i: integer;

begin
  if ((actptr = startptr) or (actptr = lastptr)) then begin
     HlpHint(HntSplitFirstPage, HintWaitEsc);
  end else{if startptr = actptr then }begin
{Filenamen abfragen}
    ok:= true;
    if HlpGetFileName(instring,'.RNS',0,0) then begin
      if IniFileExist(datadir + '/' + instring) then begin
        if not HlpAreYouSure('File already exists - overwrite?',hpEdit) then begin
          ok:= false;
        end;
      end;
      if ok then begin
        FilSavePage(topmargin, pagelength, actptr,
                    startptr, lastptr);
        assign(outfile, datadir + '/' + instring);
        FilHeapToFile(outfile, actptr, startptr, lastptr,
                      false, false, true);
        FilHeapToFile(infile, actptr, startptr, lastptr,
                      false, false, true);
        FilFindPage(1, i, actptr, startptr, lastptr);
        for i:= 1 to pagecount do begin
          PagRemovePage(actptr, startptr, lastptr);
        end;
        FilHeapToFile(outfile, actptr, startptr, lastptr, true, false, true);
        LastFileName:=FExpand(TextRec(infile).Name);
        reset(infile);
        FilFileToHeap(infile, actptr, startptr, lastptr, ok);
        FilFindPage(pagecount + 1, i, actptr, startptr, lastptr);
        while(actptr <> lastptr) do begin
          PagRemovePage(actptr, startptr, lastptr);
        end;
        FilHeapToFile(infile, actptr, startptr, lastptr, false, false, true);
        FilFindPage(pagecount, i, actptr, startptr, lastptr);
        PagGetPageFromHeap(actptr, startptr, lastptr, i);
      end;
    end; {if instring[1] <> chr(27) then }
  end; { else if startptr = actptr then }
end;

{******************************************************}
Procedure SpeLineToBuf(linenum, actposn, actpost: integer;
                       var actptr, startptr, lastptr: listptr);
{Versorgt eine Zeile in den Buffer}

var apos: integer;

begin
   MarkInit;
   apos:= IniPos(linenum, actposn, actpost);
   MarkStart(apos, linenum, pagecount);
   MarkEnd(apos, linenum, pagecount);
   MarMarkToBuffer(actptr, startptr, lastptr);
   marpartline:= false;
   MarkInit;
end;

{******************************************************}
Procedure SpeSplitPage(linenum: integer; var actposn, actpost: integer;
                       var actptr, startptr, lastptr: listptr);
{Unterteilt die Seite an der Cursorposition}

var i, lineins, linepage: integer;
    tempptr: listptr;

begin
   tempptr:= actptr;
   SpeInsHeader(tempptr, startptr, lastptr);
   lineins:= 0;
   while linenum + lineins <= IniFooterEnd do
   begin
      FilHeapInsertString(page[IniFooterEnd] + chr(0), tempptr,
                          startptr, lastptr, actptr, true);
      SpeLineInsert(linenum + lineins, 'T    ');
      lineins:= lineins + 1;
   end;

   {Anzahl Zeilen ohne Header und Footer pro Seite berechnen}
   linepage:= IniFooterEnd - IniHeaderEnd + 1;

   {Seite mit leeren Zeilen auffuellen}
   i:= linepage - (lineins mod linepage);
   SpeInsEmptyLines(i, actptr, startptr, lastptr);

   {Footer einfuellen}
   SpeInsFooter(actptr, startptr, lastptr);

   FilHeapSqueeze(actptr, startptr, lastptr, true);
   FilFindPage(pagecount, i, actptr, startptr, lastptr);
   PagRefClearVal(0, IniYnow(linenum - 2), GetMaxX, GetMaxY);
   PagCursorLeft(linenum, actposn, actpost);
end;

{******************************************************}
Procedure SpeJoinPage(linenum: integer; var actposn, actpost: integer;
                      var actptr, startptr, lastptr: listptr);
{Schiebt die n�chste Seite an die gegenw�rtige}

var i, lineins, linepage: integer;
    tempptr: listptr;
    inblock, tempbuffer: stringline;
    endreached: boolean;
    tbufpos: byte;

begin
   lineins:= topmargin;
   tempbuffer:= '';
   tbufpos:= 0;
   tempptr:= actptr;
   linepage:= 0;

   if actptr <> lastptr then
   begin
      SpeLastFilled(i);
      while ((i <= pagelength) and (not IniHeaderFooterLine(i))) do
      begin
         FilCheckLine(tempbuffer, inblock,
                      tempptr, startptr, lastptr,
                      tbufpos, endreached, false, false);
         lineins:= lineins + 1;
         if ((length(inblock) >= 4) and (inblock[4] = 'F')) then
         begin
            FilCheckLine(tempbuffer, inblock,
                         tempptr, startptr, lastptr,
                         tbufpos, endreached, true, false);
         end
         else  {if inblock[4] = 'F' then }
         begin
            FilCheckLine(tempbuffer, inblock,
                         tempptr, startptr, lastptr,
                         tbufpos, endreached, true, true);
            page[i]:= inblock;
            i:= i + 1;
            linepage:= linepage + 1;
         end; { else if inblock[4] = 'F' then }
      end;

      {auffuellen der naechsten Seite mit leeren Linien}
      repeat
         FilCheckLine(tempbuffer, inblock,
                      tempptr, startptr, lastptr,
                      tbufpos, endreached, false, false);
         lineins:= lineins + 1;
         if ((length(inblock) >= 4) and (inblock[4] <> 'F')) then
         begin
            FilCheckLine(tempbuffer, inblock,
                   tempptr, startptr, lastptr,
                   tbufpos, endreached, true, false);
         end;
      until ((lineins = pagelength) or (inblock[4] = 'F'));

      FilStringSeparate(tempbuffer, tempptr, startptr, lastptr,
                        tbufpos);
      SpeInsEmptyLines(linepage, tempptr, startptr, lastptr);
      FilHeapSqueeze(tempptr, startptr, lastptr, true);

      FilFindPage(pagecount, i, actptr, startptr, lastptr);
      {Naechste Seite loeschen, falls sie leer ist}
      if PagEmptyPage(actptr, startptr, lastptr) then
      begin
         PagRemovePage(actptr, startptr, lastptr);
      end;

      {Seite anzeigen}
      PagRefClearVal(0, IniYnow(linenum - 2), GetMaxX, GetMaxY);
      PagCursorLeft(linenum, actposn, actpost);
   end { if actptr <> lastptr then }
   else
   begin
      HlpHint(HntOnLastPage, HintWaitEsc);
   end;
end;

{******************************************************}
Procedure SpeEdLineAttr(linenum: integer; var actposn, actpost: integer;var startptr, lastptr : listptr);

var
   i: integer;

begin
   GriBeatMenuDisp(linenum{, startptr, lastptr});

   {Beatmenu - Feld l�schen}
   PagRefClearVal(GrMinX - 10, GrMinY - 10,
                  GrMaxX + 10, GrMaxY + 10);

   {Start-y f�r refresh berechnen}
   PagRefClearVal(0, IniYnow(linenum - 2), GetMaxX, IniYnow(LineNum + 2));
   i:= topmargin;
   while ((i < linenum) and (page[i,1] <> 'N')) do
   begin
      i:= i + 1;
   end;
   if i = linenum then PagRefPage;

   PagCursorLeft(linenum, actposn, actpost);
end;

{******************************************************}
Procedure SpeLastFilled(var lline: integer);
{Sucht die letzte Zeile der Seite, die einen Inhalt hat}

begin
   lline:= IniFooterEnd;
   while ((lline >= topmargin) and (IniEmptyLine(page[lline]))) do
   begin
      lline:= lline - 1;
   end;
   lline:= lline + 1;
end;

{******************************************************}
Function SpeSpaceInPage(lines: integer): boolean;
{true, wenn Platz fuer lines linien auf der Seite vorhanden ist.}

var i : integer;
    lmax: byte;

begin
  if lines>(IniFooterEnd-IniHeaderEnd+1) Then Begin
    SpeSpaceInPage:=False;
    Exit;
  End;
  i:= 0;
  lmax:= IniFooterEnd;
  while ((i <= lines) and (IniEmptyLine(page[lmax - i]))) do begin
    inc(i);
  end;
  SpeSpaceInPage:= i >= lines;
end;

{******************************************************}
Procedure SpeLineInsert(linenum: integer; inblock : stringline);
{F�gt eine Zeile an der Stelle Linenum ein}

var i: integer;

begin
   for i:= IniFooterEnd downto (linenum + 1) do
   begin
      page[i]:= page[i - 1];
   end;
   page[linenum]:= inblock;
end;

{******************************************************}
Procedure SpeLineDelete(linenum: integer; fill : boolean);
{Loescht die Zeile Linenum aus der aktuellen Page}

var
   i, lmax : integer;

begin
  IF Not SpeDelPossible(linenum) Then
    Exit;
  if NotIsSys(linenum)='S' then
    NotSysStart(NotNextLine(linenum))
  else if NotIsSys(linenum)='E' then
    NotSysEnd(NotPrevLine(linenum));
  lmax:= pagelength;
  while IniHeaderFooterLine(lmax) do
    lmax:= lmax - 1;
  for i:= linenum to (lmax - 1) do
    page[i]:= page[i + 1];
  if fill then
    page[lmax]:= 'T        ';
end;

{******************************************************}
Procedure SpeNoteRight(linenum: integer; var actpos: integer);

var x : integer;

begin
   while (actpos < length(page[linenum])) and
          (not IniNumChar(page[linenum, actpos])) do
      inc(actpos);
   if IniNumChar(page[linenum, actpos]) then
   begin
      x:= gcxcoord + 1;
      GetNotePosX(x, actpos, linenum, true, false);
   end;
end;

{******************************************************}
Procedure SpeTextRight(linenum: integer; var actpos: integer);

var
    x : integer;

begin
   if length(page[linenum]) <= actpos then
   begin
      IniCharAdd(page[linenum],' ',actpos + 1);
   end;
   if actpos<240 then
     Inc(actpos);
   TexActPosX(x, actpos, linenum, true);
end;

{******************************************************}
Procedure SpeInsNoteLine(var linenum, actposn: integer;
                         var tempptr, startptr, lastptr: listptr);
var i : integer;
    inblock: stringline;
    inserted: boolean;
    lineattr: lineattrtype;
begin
  SpeLastFilled(i);
  IF GetValidStaff(linenum) Then Begin
    inblock:=insmusicline;
    GetNoteAttributes(inblock,lineattr);
    if lineattr.linestyle=2 then begin
      if((SpeSpaceInPage(1))and(linenum<=pagelength))then begin
        actposn:=length(insmusicline);
        inserted:=true;
        SpeLineInsert(linenum,insmusicline);
      end else begin
        HlpHint(HntNotEnoughSpace, HintWaitEsc);
        inserted:= false;
      end;
    end else begin
      if((SpeSpaceInPage(linecount))and((linenum+linecount-1)<=pagelength))then begin
      {Notenlinie ins Page-Array schreiben}
        actposn:= length(insmusicline);
        inserted:= true;
        for i:= 1 to linecount do begin
          SpeLineInsert(linenum + i - 1, insmusicline);
        end;
      end else begin
        HlpHint(HntNotEnoughSpace, HintWaitEsc);
        inserted:= false;
      end;
    end;
  End Else Begin
    HlpHint(HntDistanceToSmall,HintWaitEsc);
  End;
  {Seite wiederherstellen}
  if inserted then begin
    PagRefClearVal(0, IniYnow(linenum - 4), GetMaxX, grmaxy-1);
    PagCursorLeft(linenum, actposn, i);
  end;
end;

{******************************************************}
Procedure SpeInsTextLine(linenum: integer; var actpost: integer;
                         var actptr, startptr, lastptr: listptr;
                         delflag: boolean);

var i, y : integer;
    inblock: stringline;

begin
   if SpeSpaceInPage(1) then
   begin
      {Textlinie ins Page-Array schreiben}
      if ((delflag) and (delln <> '')) then
      begin
         inblock:= delln;
         FillChar(inblock[2],linemarker-1,' ');
      end
      else
      begin
         inblock:= 'T        ';
      end;
      SpeLineInsert(linenum, inblock);
      y:= IniYnow(linenum - 6);
      PagRefClearVal(0, y, GetMaxX, grmaxy-1);
      PagCursorLeft(linenum, actpost, i);
   end
   else
   begin
      HlpHint(HntNotEnoughSpace, HintWaitEsc);
   end;
end;

{******************************************************}
Procedure SpeMoveBlock(linenum: integer; var actposn, actpost: integer;
                       var actptr, startptr, lastptr: listptr);

var linenow, markstart, markend, nowpos: integer;
    delfirst: byte; {0 = invalid, 1 = delete first, 2 = insert first}
    pageswap: boolean;
    blocklength : integer;
begin
  if (mstart.mpag<>-1) and (mend.mpag<>-1) then begin
    filbufclear;
    MarMarkToBuffer(actptr, startptr, lastptr);
  end;
  blocklength:=mend.mline-mstart.mline+1+(mend.mpag-mstart.mpag)*pagelength;
  if (blocklength<pagelength) and (linenum+blocklength>pagelength) then begin
    HlpHint(HntNotEnoughSpace, HintWaitEsc);
    Exit;
  end;
  linenow:= pagecount*pagelength + linenum+blocklength;
  markstart:= mstart.mpag*pagelength + mstart.mline;
  markend:= mend.mpag*pagelength + mend.mline;
  delfirst:= 0;

  if marpartline then begin
    nowpos:= IniPos(linenum+blocklength, actposn, actpost);
    if ((linenow <> markstart) or (nowpos < mstart.mpos)) then begin
      delfirst:= 1;
    end else begin
      if (nowpos > mend.mpos) then
        delfirst:= 2;
    end;
  end else begin
    if (linenow-blocklength) < markstart then begin
      delfirst:= 1;
    end else begin
      if (linenow-blocklength) > markend then
        delfirst:= 2;
    end;
  end; { if marpartline then }

  case delfirst of
    0: begin
      HlpHint(HntBufItself, HintWaitEsc);
    end;
    1: begin
      MarDeleteBlock(actptr, startptr, lastptr);
      SpeInsertBuffer(linenum, actposn, actpost,
                      actptr, startptr, lastptr, pageswap);
      PagUnMark;
    end;
    2: begin
      SpeInsertBuffer(linenum+blocklength, actposn, actpost,
                      actptr, startptr, lastptr, pageswap);
      MarDeleteBlock(actptr, startptr, lastptr);
      MarkInit;
      if pageswap then begin
        SpeJoinPage(linenum+blocklength, actposn, actpost,
                    actptr, startptr, lastptr);
      end;
      if not marpartline then
        PagRefPage;
      PagCursorLeft(linenum, actposn, actpost);
    end;
  end; {case delfirst of}
end;

{*************************************************************************}
Procedure SpeInsertBuffer(linenum: integer; var actposn, actpost: integer;
                          var actptr, startptr, lastptr: listptr;
                          var pageswap: boolean);
{pageswap wird true gesetzt, wenn eine neue Seite angebrochen wurde}

var
    apos, numpages, lineins, linepage, i, j: integer;
    tempbuffer, inblock : stringline;
    tempptr: listptr;
    endreached: boolean;
    tbufpos: byte;

begin
   if (mstart.mpag<>-1) and (mend.mpag<>-1) then begin
     MarMarkToBuffer(actptr, startptr, lastptr);
   end;
   if bufstartptr <> bufendptr then
   begin
      bufactptr:= bufstartptr;
      pageswap:= false;
      tempbuffer:= '';
      tbufpos:= 0;

      if marpartline then
      begin
         {Nur Teil einer Zeile im Buffer}
         FilCheckLine(tempbuffer, inblock, bufactptr, bufstartptr, bufendptr,
                      tbufpos, endreached, true, false);
         {Testen, ob nicht eine Textzeile in eine Notenzeile kopiert wird}
         if page[linenum, 1] <> inblock[1] then
         begin
            HlpHint(HntIncorrectNote, HintWaitEsc);
         end
         else {  if page[linenum, 1] <> inblock[1] then }
         begin
            delete(inblock, mend.mpos + 1, length(inblock));
            delete(inblock, 1, mstart.mpos - 1);
            apos:= IniPos(linenum, actposn, actpost);

            if page[linenum, 1] = 'T' then
            begin
               IniTrailBlank(inblock);
            end else begin
              apos:=ComStart(page[linenum],apos)
            end;
            insert(inblock, page[linenum], apos);
            PagRefClearVal(0, IniYnow(linenum - 2),
                           GetMaxX, IniYnow(linenum + 1));
         end; { else if page[linenum, 1] <> inblock[1] then }
      end
      else  { if marpartline then }
      begin
         lineins:= 0;
         linepage:= 0;
         endreached:= false;

         {Einfuellen auf aktuelle Seite, solange Platz vorhanden}
         while ((not endreached) and
                (linenum + linepage <= IniFooterEnd) and
                (IniEmptyLine(page[IniFooterEnd]))) do
         begin
           FilCheckLine(tempbuffer, inblock,
                         bufactptr, bufstartptr, bufendptr,
                         tbufpos, endreached, true, false);
            if not endreached then
            begin
               SpeLineInsert(linenum + linepage, inblock);
               linepage:= linepage + 1;
            end;
         end;

         {beenden, wenn auf einer setup-page editiert wird}
         if ((not endreached) and (not (setuppage in actedit))) then
         begin
            pageswap:= true;
            {Aktuelle Seite durch Buffer fertig ersetzen}
            tempptr:= actptr;
            while ((not endreached) and
                   (linenum + linepage <= IniFooterEnd)) do
            begin
               FilCheckLine(tempbuffer, inblock,
                            bufactptr, bufstartptr, bufendptr,
                            tbufpos, endreached, true, false);
               if not endreached then
               begin
                  FilHeapInsertString(page[IniFooterEnd] + chr(0), tempptr,
                                      startptr, lastptr, actptr, true);
                  SpeLineInsert(linenum + linepage, inblock);
                  lineins:= lineins + 1;
                  linepage:= linepage + 1;
               end;
            end;

            {Uebertragen des Buffers auf den Heap}
            while not endreached do
            begin
               FilCheckLine(tempbuffer, inblock,
                            bufactptr, bufstartptr, bufendptr,
                            tbufpos, endreached, true, false);
               if not endreached then
               begin
                  FilHeapInsertString(inblock + chr(0), tempptr,
                                      startptr, lastptr, actptr, false);
                  lineins:= lineins + 1;
                  if lineins mod 10 = 0 then
                  begin
                     FilHeapSqueeze(tempptr, startptr, actptr, true);
                  end;
               end; {if not endreached then}
            end; {while not endreached do}

            {Anzahl Zeilen ohne Header und Footer pro Seite berechnen}
            linepage:= IniFooterEnd - IniHeaderEnd + 1;

            {Seite mit leeren Zeilen auffuellen}
            i:= linepage - (lineins mod linepage);
            SpeInsEmptyLines(i, actptr, startptr, lastptr);
            lineins:= lineins + i;

            {Tempptr auf den Anfang des eingefuegten Blocks setzen}
            FilFindPage(pagecount, i, tempptr, startptr, lastptr);

            {Header und Footertext einfuegen}
            numpages:= lineins div linepage;
            for i:= 1 to numpages do
            begin
               SpeInsHeader(tempptr, startptr, lastptr);
               tempbuffer:= '';
               tbufpos:= 0;
               for j:= 1 to linepage do
               begin
                  FilCheckLine(tempbuffer, inblock,
                               tempptr, startptr, lastptr,
                               tbufpos, endreached, true, false);
               end;
               FilStringSeparate(tempbuffer, tempptr, startptr, lastptr,
                                 tbufpos);
               SpeInsFooter(tempptr, startptr, lastptr);
               FilHeapSqueeze(tempptr, startptr, actptr, true);
            end;
         end; { if not endreached then }

         FilHeapSqueeze(actptr, startptr, lastptr, true);
         FilFindPage(pagecount, i, actptr, startptr, lastptr);
         PagRefClearVal(0, IniYnow(linenum - 2), GetMaxX, GetMaxY);
         PagCursorLeft(linenum, actposn, actpost);
      end; { else if marpartline then }
   end
   else { if bufstartptr <> bufendptr then }
   begin
      HlpHint(HntBufEmpty, HintWaitEsc);
   end; {else  if bufstartptr <> bufendptr then}
end;

Function SpeDelPossible(Linenum : Integer) : Boolean;
Var i : Integer;
    a : Integer;
Begin
  a:={4}3;
  for i:=linenum-1 downto linenum-4 Do Begin
    if i>0 Then
      if page[i,1]<>'N' Then
        dec(a)
      Else
        Break;
  End;
  For i:=Linenum+1 To linenum+a Do Begin
    IF i>PageLength Then Begin
      SpeDelPossible:=True;
      Exit;
    End;
    IF (Page[i,1]='N') And (Page[i,29]='2') Then Begin
      SpeDelPossible:=False;
      Exit;
    End;
  End;
  SpeDelPossible:=True;
End;

Function SpeInsPossible(Linenum : Integer;T : Integer;Var InsL,Ins : Byte;
                        Num : Byte;D : Boolean;U : Boolean) : Boolean;
Var Up,Dn : Integer;

Begin
  if Linenum+Num>53 then
    SpeInsPossible:=False
  Else Begin
    Ins:=0;
    InsL:=Linenum;
    Up:=SpeLinesFree(Linenum,True);
    Dn:=SpeLinesFree(Linenum,False);
    IF SpeLineUsed(Linenum) Then Begin
      Ins:=SpeMinSpace(Page[Linenum])+1;
      IF U Then
        InsL:=InsL+Ins;
    End;
    IF (Up>=T) And (Dn>=SpeMinSpace(Page[Linenum+Dn])) Then Begin
      SpeInsPossible:=True;
      Exit;
    End;
    IF Up<T Then Begin
      InsL:=Linenum+T-Up;
      Ins:=T-Up;
    End;
    IF Dn<SpeMinSpace(Page[Linenum+Dn]) Then Begin
      Ins:=SpeMinSpace(Page[Linenum+Dn])-Dn;
    End;
    SpeInsPossible:=SpeSpaceInPage(Ins);
  End;
End;

Function SpeLinesFree(Linenum : Integer;Up : Boolean) : Integer;
Var i : Integer;
Begin
  i:=1;
  IF Up Then Begin
    While Not SpeLineUsed(Linenum-i) Do
      Inc(i);
  End Else Begin
    While Not SpeLineUsed(Linenum+i) Do
      Inc(i);
  End;
  SpeLinesFree:=i;
End;

Function SpeLineUsed(Linenum : Integer) : Boolean;
Function TextLength(S : String) : Byte;
var
  i: Integer;
begin
  { Modern Pascal replacement for assembly string length without trailing spaces }
  { Original: Scanned string backwards removing trailing spaces }
  i := Length(S);
  while (i > 0) and (S[i] = ' ') do
    Dec(i);
  TextLength := i;
end;
Begin
  IF (Linenum<1) Or (Linenum>PageLength) Then Begin
    RErr:=True;
    SpeLineUsed:=True;
    Exit;
  End;
  SpeLineUsed:=(Page[Linenum,1]='N') Or (TextLength(Page[Linenum])>11);
End;

Function SpeMinSpace(Instring : StringLine) : Integer;
Begin
  IF Instring[1]='T' Then
    SpeMinSpace:=1
  Else IF Instring[29]='2' Then
    SpeMinSpace:={4}3
  Else
    SpeMinSpace:=1;
End;
Function SpeprevNotLine(Linenum : Integer) : Integer;
Var i : Integer;
Begin
  IF Linenum>Pagelength Then
    Linenum:=Pagelength-1;
  For i:=Linenum-1 DownTo 1 Do
    IF Page[i,1]='N' Then
      Break;
  Linenum:=i;
  IF Page[Linenum,1]<>'N' Then Begin
    For i:=Pagelength Downto i+1 Do
      IF Page[i,1]='N' Then
        Break;
  End;
  Linenum:=i;
  IF Page[Linenum,1]<>'N' Then
    i:=0;
  SpeprevNotLine:=i;
End;
Function SpeNextNotLine(Linenum : Integer) : Integer;
var i:integer;
Begin
  IF Linenum<1 Then
    Linenum:=1;
  For i:=Linenum+1 To Pagelength Do
    IF Page[i,1]='N' Then
      Break;
  Linenum:=i;
  IF Page[Linenum,1]<>'N' Then Begin
    For i:=1 to Linenum-1 Do
      IF Page[i,1]='N' Then
        Break;
  End;
  IF Page[i,1]<>'N' Then
    i:=0;
  SpeNextNotLine:=i;
End;

{*****************************************************************}
Procedure SpeLineCommands(var linenum, actposn, actpost: integer;
                           var actptr, startptr, lastptr: listptr);

var dir: movement;
    c, inchar: char;
    choicenum: byte;
    y, hy: integer;
    mausx, mausy, maustaste, mausmenu: word;

begin
  ImeInitLineMenu;
  choicenum:= 1;
  maustaste:= 0;
  repeat
    PagRefClearVal(grminx - 10, grminy - 10,
                   grmaxx + 10, grmaxy + 10);
    y:= grmaxy - (usrmenu.num_choices * usrmenu.spacing +
        usrmenu.menuattr.firstline + 2) * charheight;
    hy:= y div charheight;
    GrDisplay_Frame(grminx, y, grmaxx, grmaxy, true, false);
    GrDisplay_Menu(hfminx, hy, usrmenu, 0);
    GrGet_Menu_Response(hfminx, hy, usrmenu, c, dir,
                        choicenum, mausx, mausy, maustaste,
                        mausmenu, false, 0);
    c:= UpCase(c);
    case c of
      'C': begin
        inchar:=#65;
        ComEdSpecial(linenum, actposn, actpost, actptr, startptr, lastptr,
                     inchar,false,false);
      end;{ case c of 'C'}
      'P': begin
        inchar:=#100;
        ComEdSpecial(linenum, actposn, actpost, actptr, startptr, lastptr,
                     inchar,false,true);
      end;{ case c of 'P'}{ siehe auch:comunit ca. 610}
      'S': begin
        inchar:=#96;
        ComEdSpecial(linenum, actposn, actpost, actptr, startptr, lastptr,
                     inchar,false,true);
      end;{ case c of 'S'}
      'B': begin
        inchar:=#8;
        ComEdKey(linenum, actposn, actpost,actptr, startptr, lastptr,
                 inchar,true,false);
      end;
      'E': begin
        inchar:=#83;
        ComEdSpecial(linenum, actposn, actpost, actptr, startptr, lastptr,
                     inchar,true,false);
      end;
      'D': begin
        inchar:=#127;
        ComEdKey(linenum, actposn, actpost, actptr, startptr, lastptr,
                     inchar,false,true);
      end;{ case c of 'D'}
      'U': begin
        inchar:=#82;
        ComEdSpecial(linenum, actposn, actpost, actptr, startptr, lastptr,
                     inchar,true,false);
      end;{ case c of 'D'}
    end; {case c of}
    if pos(c, usrmenu.choices) > 0 then c:= chr(27);
  until ((c = chr(27)) or (inchar <> ' '));
end;

{*************************************************************************}

Begin
  RErr:=False;
End.
