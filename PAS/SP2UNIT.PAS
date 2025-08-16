unit sp2unit;

interface

uses dos,
     crt,
     initsc,
     imenuunit,
     graph,
     UserExit;

Procedure Sp2MarkFooter(linenum: integer);
Procedure Sp2MarkHeader(linenum: integer);
Procedure Sp2UnMarkHeader;
Procedure Sp2UnMarkFooter;
Procedure Sp2SetHeaderFooter(linenum: integer);
Procedure Sp2SearchAndReplace(var linenum, actposn, actpost: integer;
                              var actptr, startptr, lastptr: listptr);
Function Sp2SearchString(var linenum, actposn, actpost: integer;
                         var actptr, startptr, lastptr: listptr) : Boolean;
Procedure Sp2ReplaceString(var linenum, actposn, actpost: integer;
                           var actptr, startptr, lastptr: listptr);
Procedure Sp2VisiMenu;
Procedure Sp2SwapKeyboard;
Procedure Sp2PageCommands(var linenum, actposn, actpost: integer;
                          var actptr, startptr, lastptr: listptr);
{Procedure Sp2SelectLine;}
Procedure Sp2HeaderFooterToBuffer(var tempptr, startptr, lastptr,
                                  bufactptr, bufstartptr, bufendptr:
                                  listptr);

implementation

uses specunit,
     helpunit,
     fileunit,
     graphmenu,
     grinout,
     gcurunit,
     menutyp,
     getunit,
     textunit,
     musikunit,
     pageunit,
     Texts,
     mousdrv;
{*********************************************************}
Function UpString(S : String) : String;
Var a : Byte;
Begin
  For a:=1 To Length(s) do
    S[a]:=UpCase(S[a]);
  UpString:=S;
End;
{*********************************************************}
Procedure Sp2HeaderFooterToBuffer(var tempptr, startptr, lastptr,
                                  bufactptr, bufstartptr, bufendptr:
                                  listptr);
{Versorgen aller Header und Footer in den Buffer}

Var i, k, pagec : integer;
    tbufpos: byte;
    tempbuf: stringline;
    strbuf: string4;

begin
   tbufpos:= 0;
   tempbuf:= '';
   tempptr:= startptr;
   FilBufClear;
   FilFindPage(1, i, tempptr, startptr, lastptr);
   pagec:= 0;
   {Seite lesen}
   repeat
      PagReadPage(tempptr, startptr, lastptr, tempbuf, tbufpos);
      pagec:= pagec + 1;
      for i:= 1 to pagelength do
      begin
         if IniHeaderFooterLine(i) then
         begin
            {Header, footer Marke wegnehmen}
            page[i, 4]:= ' ';
            {Seitenzahl wandeln}
            k:= pos(chr(235), page[i]);
            if k > 0 then
            begin
               Str(pagec:3, strbuf);
               Delete(page[i], k, 1);
               insert(strbuf, page[i], k);
            end;
            FilHeapInsertString(page[i] + chr(0), bufactptr, bufstartptr,
                                bufendptr, bufactptr, false);
         end;
      end;
   until tempptr = lastptr;
end;

{*****************************************************************}
Function Sp2SearchString(var linenum, actposn, actpost: integer;
                         var actptr, startptr, lastptr: listptr) : Boolean;
{Sucht den string searchstring auf den Zeilen vom Typ
 searchtyp, beginnend mit der gegenwaertigen Position
 wird true falls der String gefunden wurde}

var x: integer;
    ipos, iline, ipage: integer;
    inblock, testline, tempbuffer: stringline;
    foundflag, endreached: boolean;
    tbufpos: byte;
    tempptr: listptr;

    {++++++++++++++++++++++++++++++++++++++++++++}
    Procedure Sp2TestOneLine;

    begin
      if testline[1] = searchtyp then
      begin
         IF Searchtyp = 'N' Then
           inblock:=Copy(testline, ipos, 255)
         Else
           inblock:=UpString(Copy(testline, ipos, 255));
         if Pos(searchstring, inblock) > 0 then
         begin
            foundflag:= true;
            if pagecount <> ipage then
            begin
               PagShowPage(linenum, actposn, actpost,
                           actptr, startptr, lastptr, ipage, true);

            end;
            linenum:= iline;
            pagecount:= ipage;
            if searchtyp = 'N' then
            begin
               actposn:= ipos - 1 + Pos(searchstring, inblock);
               GetActPosX(x, actposn, linenum, true);
            end
            else
            begin
               actpost:= ipos - 1 + Pos(searchstring, inblock);
               TexActPosX(x, actpost, linenum, true);
            end;
         end; { if Pos(searchstring, inblock) > 0 then}
      end; {if testline [1] = searchtyp then}
      iline:= iline + 1;
      ipos:= linemarker + 1;
    end; {Sp2TestOneLine}
    {+++++++++++++++++++++++++++++++++++++++++++++++++++}


begin
   foundflag:= false;
   endreached:= false;
   if searchstring <> '' then
   begin
      tempbuffer:= '';
      tbufpos:= 0;
      iline:= linenum;
      ipos:= IniPos(linenum, actposn, actpost) + 1;
      ipage:= pagecount;

      {Suchen auf aktueller Seite}
      while ((not foundflag) and (iline <= pagelength)) do
      begin
         testline:= page[iline];
         Sp2TestOneLine;
      end; {while ((not foundflag) and (iline <= pagelength)) do}

      {Suchen im Heap}
      if not foundflag then
      begin
         ipage:= pagecount + 1;
         iline:= topmargin;
         tempptr:= actptr;
         while ((not foundflag) and (not endreached)) do
         begin
            FilCheckLine(tempbuffer, testline, tempptr, startptr, lastptr,
                         tbufpos, endreached, true, false);
            Sp2TestOneLine;
            if iline > pagelength then
            begin
               ipage:= ipage + 1;
               iline:= topmargin;
            end;
         end; {while ((not foundflag) and (not endreached)) do}
      end; { if not foundflag then}

      if not foundflag then
      begin
         HlpHint(HntNotFound, HintWaitEsc);
         PagCursorLeft(linenum, actposn, actpost);
      end;
   end {if searchstring <> ''}
   else
   begin
      HlpHint(HntNoSearchText, HintWaitEsc);
   end;
   Sp2SearchString:= foundflag;
end;


{*****************************************************************}
Procedure Sp2ReplaceString(var linenum, actposn, actpost: integer;
                           var actptr, startptr, lastptr: listptr);

var b: byte;
    ipos: integer;

begin
   GcuCursorRestore;
   if (gcycoord > (grmaxy - 30)) then
     b:=hpUp
   else
     b:=hpEdit;
   if HlpAreYouSure('replace ?', b) then
   begin
      GcuPatternRestore;
      PagRefreshPage(refxmin, refymin, refxmax, refymax);
      IniRefInit;
      ipos:= IniPos(linenum, actposn, actpost);
      delete(page[linenum], ipos, length(searchstring));
      insert(replacestring, page[linenum], ipos);
      PagRefClearVal(0, IniYnow(linenum - 1), gmaxX,
                     IniYnow(linenum + 2));
   end else begin
     GcuPatternRestore;
   end;
end;

{*****************************************************************}
Procedure Sp2SearchAndReplace(var linenum, actposn, actpost: integer;
                              var actptr, startptr, lastptr: listptr);

var dir: movement;
    c: char;
    resp: response_type;
    choicenum: byte;
    x, y, hy: integer;
    instring, rstring: string16;
    s : string;
    b: boolean;
    mausx, mausy, maustaste, mausmenu: word;
    changed : boolean;
  {***************************************}
  Procedure SearchTextInput(dy: integer; prompt: string;var tstring: string16);
  begin
    tstring:='';
    s:='';
    IniExpand(S,32);
    GrGet_Prompted_String(tstring, 16,                { InStr,StrLen        }
                          ' ',x-60, hy + 4 + dy, x-60,{ Desc,DesX,-Y,OldDeX }
                          prompt,x - 93, hy + 4 + dy, { Prompt,PRX,PRY      }
                          77,resp, dir, c,            { PRLen,Resp,Dir,KeyRe}
                          false,                      { OldWrite            }
                          mausx, mausy, maustaste, mausmenu,changed);
    IniMausAssign(maustaste, resp);
    if resp = return then c:= #27
                     else c:= ' ';
  end;

  {***************************************}
  Procedure SearchPatternInput(dy: integer; prompt: string;
                               var tstring: stringline);
  begin
    tstring:= '';
    MusGetPromptedPattern(tstring,                    { inString          }
                          ' ',                        { DESC              }
                          x+220,y+24,{+dy*8}          { DescX,DescY       }
                          ' '+prompt,x-86,y+38+dy*8,  { Prompt, PRX,PRY   }
                          15, resp, c);               { prlen,resp,keyresp}
    if resp = return then c:= chr(27)
                     else c:= ' ';
  end;

  {**********************************}
  Procedure CallReplace;
  begin
    if ((c <> ' ') and (Sp2SearchString(linenum, actposn,actpost,
                                  actptr, startptr,lastptr))) then begin
      PagRefreshPage(refxmin, refymin, refxmax, refymax);
      IniRefInit;
      Sp2ReplaceString(linenum, actposn, actpost, actptr, startptr, lastptr);
    end;
  end;
  {**********************************}

begin
  ImeInitSearchMenu;
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
                        choicenum, mausx, mausy, maustaste, mausmenu,
                        false, 0);
    x:= hfminx + usrmenu.menu_width + 16;
    C:=Upcase(C);
    case c of
      'T': begin
        searchtyp:= 'T';
        replaceflag:= false;
        SearchTextInput(6,
        ' - Enter text to search                     >',instring);
        searchstring:= UpString(instring);
        if searchstring <> '' then
          b:= Sp2SearchString(linenum, actposn, actpost,
                              actptr, startptr, lastptr);
      end;

      'P': begin
        searchtyp:= 'N';
        replaceflag:= false;
        SearchPatternInput(4, ' - Enter pattern to search                  >',
                           searchstring);
        if searchstring <> '' then
          b:= Sp2SearchString(linenum, actposn, actpost,
                              actptr, startptr, lastptr)
        else
          PagCursorLeft(linenum, actposn, actpost);
      end;

      'C': begin
        searchtyp:= 'T';
        replaceflag:= true;
        SearchTextInput(2,
        ' - Enter text to change                     >',instring);
        searchstring:= UpString(instring);
        if (searchstring <> '') and (resp<>escape) then begin
          replacestring:=' - Change "'+instring+'" to';
          IniExpand(Replacestring,44);
          SearchTextInput(2, ReplaceString+'>',instring);
          replacestring:= rstring;
          CallReplace;
        end;
        c:='C';
      end;

      'R': begin
        searchtyp:= 'N';
        replaceflag:= true;
        SearchPatternInput(0,    ' - Enter pattern to replace                 >',
                  searchstring);
        if searchstring <> '' then begin
          SearchPatternInput(0, ' - Change to                                >',
                  replacestring);
          CallReplace;
        end;
      end;
    end; {case c of}
    if pos(c, usrmenu.choices) > 0 then c:= chr(27);
  until (c = chr(27));

end;

{*****************************************************************}
Procedure Sp2PageCommands(var linenum, actposn, actpost: integer;
                          var actptr, startptr, lastptr: listptr);

var dir: movement;
    c: char;
    resp: response_type;
    choicenum: byte;
    x, y, hy, i: integer;
    mausx, mausy, maustaste, mausmenu: word;
    changed : boolean;
begin
  ImeIniPageMenu;
  if mstart.mpag <> -1 then begin
    usrmenu.num_choices:= {1}2;
  end;
  choicenum:= 1;
  maustaste:= 0;
  mausdunkel;
  repeat
    PagRefClearVal(grminx - 10, grminy - 10,
                   grmaxx + 10, grmaxy + 10);
    y:= grmaxy - (usrmenu.num_choices * usrmenu.spacing +
        usrmenu.menuattr.firstline + 2) * charheight;
    hy:= y div charheight;
    GrDisplay_Frame(grminx, y, grmaxx, grmaxy, true, false);
    GrDisplay_Menu(hfminx, hy, usrmenu, 0);
    GrGet_Menu_Response(hfminx, hy, usrmenu, c, dir,
                        choicenum, mausx, mausy, maustaste, mausmenu,
                        false, 0);
    x:= hfminx + usrmenu.menu_width - 44;
    hy:= y + 78;
    y:= grmaxy div charheight -
        ((usrmenu.num_choices - choicenum + 1) * usrmenu.spacing);
    c:=upcase(c);
    mausdunkel;
    case c of
      'G': begin{gotopage}
        i:= pagecount;
        GrGet_Prompted_Integer(i, 1, 1000, 12, '>',
                               x, y, x,
                               ' - Go to       page number ..?              >',
                               x - 33, y, 77, resp, dir, c, false,
                               mausx, mausy, maustaste, mausmenu,changed);
        IniMausAssign(maustaste, resp);
        if resp = return then
          c:= #27
        else
          c:= ' ';
        if i <> pagecount then begin
          PagShowPage(linenum, actposn, actpost,
                      actptr, startptr, lastptr, i, true);
        end;
      end;
      'F': begin{first page}
        PagShowPage(linenum, actposn, actpost,
                    actptr, startptr, lastptr, 1, true);
      end;
      'L': begin{last page}
        PagShowPage(linenum, actposn, actpost,
                    actptr, startptr, lastptr, 30002, true);
      end;
      'N': begin{New page at end}
        FilSavePage(1, PageLength, actptr, startptr, lastptr);
        FilFindPage(30002, pagecount, actptr, startptr, lastptr);
        IniNewPage(linenum);
        PagGetPageFromHeap(actptr, startptr, lastptr, i);
        PagCursorLeft(linenum, actposn, actpost);
        PagShowPage(linenum, actposn, actpost,
                    actptr, startptr, lastptr, pagecount + 1, true);
      end;
      'I': begin{Insert page}
        i:= pagecount;
        FilSavePage(1, PageLength, actptr, startptr, lastptr);
        PagGetSetupPage(actptr, startptr, lastptr);
        FilFindPage(pagecount, i, actptr, startptr, lastptr);
        PagRefPage;
      end;
      'S': begin{Split page}
        SpeSplitPage(linenum, actposn, actpost,
                     actptr, startptr, lastptr);
      end;
      'J': begin{Join page}
        SpeJoinPage(linenum, actposn, actpost,
                    actptr, startptr, lastptr);
      end;
      'B': begin{Blockmark page(irgendeine Kreation musste ja wohl her!}
           { warum nicht '9' wie F9}
        if pagebuf=-1 then
          filmarkpage
        else
          filunmarkpage;
      end;
      'C': begin{Copy page to buf}
        filCopyPage(actptr, startptr, lastptr);
      end;
      'P': begin{Paste page}
        filPastePage(actptr, startptr, lastptr);
      end;
      'M': begin{Move Page}
        fildelpage(actptr, startptr, lastptr);
        filundelpage(actptr, startptr, lastptr);
      end;
      'D': begin{Delete page}
                {save page to buffer}
        fildelpage(actptr, startptr, lastptr);
      end;
      'U': begin{Undelete page}
        filundelpage(actptr, startptr, lastptr);
      end; {case c of}
    end;
    if pos(c, usrmenu.choices) > 0 then c:= #27;
  until (c = #27);
end;

{*****************************************************************}
Procedure Sp2SwapKeyboard;

var y, hy: integer;
    c: char;
    choicenum: byte;

begin
   ImeIniSwapMenu;
   choicenum:= 1;
   usrmenu.choiceval[1].tval:=  manset;
   usrmenu.choiceval[2].tval:=  charset;
   usrmenu.choiceval[3].tval:=  blankset+1;
   y:= grmaxy - (usrmenu.num_choices * usrmenu.spacing +
       usrmenu.menuattr.firstline + 5) * charheight;
   hy:= y div charheight;
   GrDisplay_Frame(grminx, y, grmaxx, grmaxy, true, true);
   GrDisplay_Menu(hfminx, hy, usrmenu, 0);
   GrGet_Menu_Values(hfminx, hy, hfmaxy, usrmenu, c);

   manset:= usrmenu.choiceval[1].tval;
   charset:= usrmenu.choiceval[2].tval;
   blankset:= usrmenu.choiceval[3].tval-1;
   PagRefClearVal(0, y - 16, gmaxX, gmaxy);
end;

{*****************************************************************}
Procedure Sp2VisiMenu;
var y, hy: integer;
    c: char;
    choicenum: byte;
begin
   ImeIniVisiMenu;
   choicenum:=1;
   usrmenu.choiceval[1].tval:=dispspec;
   usrmenu.choiceval[2].tval:=dispgrid;
   usrmenu.choiceval[3].tval:=disphidlines;
   usrmenu.choiceval[4].tval:=dispslash;
   usrmenu.choiceval[5].tval:=dispcurs;
   y:=grmaxy - (usrmenu.num_choices * usrmenu.spacing +
       usrmenu.menuattr.firstline + 5) * charheight;
   hy:=y div charheight;
   GrDisplay_Frame(grminx, y, grmaxx, grmaxy, true, true);
   GrDisplay_Menu(hfminx, hy, usrmenu, 0);
   GrGet_Menu_Values(hfminx, hy, hfmaxy, usrmenu, c);

   dispspec:= usrmenu.choiceval[1].tval;
   dispgrid:= usrmenu.choiceval[2].tval;
   disphidlines:= usrmenu.choiceval[3].tval;
   dispslash:=usrmenu.choiceval[4].tval;
   dispcurs:= usrmenu.choiceval[5].tval;
end;

{*****************************************************************}
Procedure Sp2SetHeaderFooter(linenum: integer);

var dir: movement;
    c: char;
    choicenum: byte;
    y, hy: integer;
    mausx, mausy, maustaste, mausmenu: word;

begin
   ImeInitHfMenu;
   choicenum:= 1;
   maustaste:= 0;
   repeat
      y:= grmaxy - (usrmenu.num_choices * usrmenu.spacing +
          usrmenu.menuattr.firstline + 2) * charheight;
      hy:= y div charheight;
      GrDisplay_Frame(grminx, y, grmaxx, grmaxy, true, false);
      GrDisplay_Menu(hfminx, hy, usrmenu, 0);
      GrGet_Menu_Response(hfminx, hy, usrmenu, c, dir,
                          choicenum, mausx, mausy, maustaste, mausmenu,
                          false, 0);

      case c of
         'H', 'h': begin
                      Sp2MarkHeader(linenum);
                      c:= chr(27);
                   end;

         'F', 'f': begin
                      Sp2MarkFooter(linenum);
                      c:= chr(27);
                   end;

         'U', 'u': begin
                      Sp2UnMarkHeader;
                      c:= chr(27);
                   end;

         'V', 'v': begin
                      Sp2UnMarkFooter;
                      c:= chr(27);
                   end;
      end; {case c of}
   until (c = chr(27));

   PagRefClearVal(grminx - 10, grminy - 10,
                  grmaxx + 10, grmaxy + 10);
end;

{*****************************************************************}
Procedure Sp2UnMarkFooter;

var i: byte;

begin
   i:= pagelength;
   while IniHeaderFooterLine(i) do
   begin
      page[i, 4]:= ' ';
      i:= i - 1;
   end;
   PagRefClearVal(IniLeftMargin, IniYnow(i),
                  IniLeftMargin + 2 * CharWidth, IniYnow(pagelength));
end;

{*****************************************************************}
Procedure Sp2UnMarkHeader;

var i: byte;

begin
   i:= topmargin;
   while IniHeaderFooterLine(i) do
   begin
      page[i, 4]:= ' ';
      i:= i + 1;
   end;
   PagRefClearVal(IniLeftMargin, IniYnow(topmargin - 1),
                  IniLeftMargin + 2 * CharWidth, IniYnow(i));
end;

{*****************************************************************}
Procedure Sp2MarkHeader(linenum: integer);

var i, imax: byte;

begin
   imax:= IniMaxHeader;
   if (linenum > imax) then
   begin
      HlpHint(HntHeaderHalfPage, HintWaitEsc);
   end
   else
   begin
      for i:= linenum to imax do
      begin
         IniExpand(page[i], 4);
         page[i, 4]:= ' ';
      end;
      for i:= topmargin to linenum do
      begin
         IniExpand(page[i], 4);
         page[i, 4]:= 'F';
      end;
      PagRefClearVal(IniLeftMargin, 0,
                     IniLeftMargin + CharWidth, IniYnow(imax));
   end;
end;

{*****************************************************************}
Procedure Sp2MarkFooter(linenum: integer);

var i, imin: byte;

begin
   imin:= IniMinFooter;
   if (linenum < imin) then
   begin
      HlpHint(HntFooterHalfPage, HintWaitEsc);
   end
   else
   begin
      for i:= imin to linenum do
      begin
         IniExpand(page[i], 4);
         page[i, 4]:= ' ';
      end;
      for i:= linenum to pagelength do
      begin
         IniExpand(page[i], 4);
         page[i, 4]:= 'F';
      end;
      PagRefClearVal(IniLeftMargin, IniYnow(imin - 1),
                     IniLeftMargin + CharWidth, IniYnow(pagelength));
   end;
end;

{*****************************************************************}
(*Procedure Sp2SelectLine;

var dir: movement;
    y, hy: integer;
    c: char;
    choicenum: byte;
    mausx, mausy, maustaste, mausmenu: word;

begin
   ImeInitLineSelectMenu;
   choicenum:= 1;
   maustaste:= 0;
   y:= grmaxy - (usrmenu.num_choices * usrmenu.spacing +
       usrmenu.menuattr.firstline + 2) * charheight;
   hy:= y div charheight;
   GrDisplay_Frame(grminx, y, grmaxx, grmaxy, true, true);
   GrDisplay_Menu(hfminx, hy, usrmenu, 0);
   GrGet_Menu_Response(hfminx, hy, usrmenu, c, dir,
                       choicenum, mausx, mausy, maustaste, mausmenu,
                       false, 0);


   if c <> chr(27) then
   begin
      insmusicline:= page[choicenum];
   end;
end;*)

end.
