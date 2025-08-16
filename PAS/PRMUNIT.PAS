unit prmunit;

interface

Uses
   initsc;

Procedure PrmPrintMenu(var linenum, actposn, actpost: integer;
                       var actptr, startptr, lastptr: listptr);


implementation

Uses
   imenuunit,
   printunit,
   pageunit,
   menutyp,
   graphmenu,
   crt,
   helpunit,
   DOS,
   mousdrv,
   grinout,
   fileunit;
{******************************************************************}
Procedure PrmSetOptions;
var c     : char;
    y, hy : integer;
    ok    : boolean;
    m     : boolean;
begin
  m:=not istdunkel;
  if m then
    mausdunkel;
  ImeInitPrOptionsMenu;
  UsrMenu.ChoiceVal[1].Tval:= prformat;
  UsrMenu.ChoiceVal[2].Tval:= prdest;
  UsrMenu.ChoiceVal[3].Sval:= prfname;
  y:=grmaxy-(usrmenu.num_choices*usrmenu.spacing+usrmenu.menuattr.firstline+6)*charheight;
  hy:= y div charheight;
  GrDisplay_Frame(grminx, y, grmaxx, grmaxy, true, true);
  GrDisplay_Menu(hfminx, hy, usrmenu, 0);
  GrGet_Menu_Values(hfminx, hy, hfmaxy, UsrMenu, c);
  prformat:= UsrMenu.ChoiceVal[1].tval;
  prdest:= UsrMenu.ChoiceVal[2].tval;
  if (pos(':',Togglestring[prdest+UsrMenu.ChoiceVal[2].tvalmin-1])= 0) then begin
    prfile:= 1;
  end else begin
     prfile:= 0;
  end;
  if prfile = 1 then begin
    IniLeadBlank(UsrMenu.ChoiceVal[3].sval);
    if pos('.', UsrMenu.ChoiceVal[3].sval) = 0 then begin
       UsrMenu.ChoiceVal[3].sval:= UsrMenu.ChoiceVal[3].sval + '.eps';
    end;
    HlpTestFileName(psdir + '\' + UsrMenu.ChoiceVal[3].sval,
                    ok, grminx, grmaxx, y);
    if ok then begin
      prfname:= UsrMenu.ChoiceVal[3].sval;
    end;
  end else begin
    prdevice:= Copy(Togglestring[prdest+UsrMenu.ChoiceVal[2].tvalmin-1],1, 4);
  end;
  if m then
    mauszeigen;
end;
{******************************************************************}
{******************************************************************}

Type TPageList = Array[0..255] of integer;

{******************************************************************}

Procedure String2List(S : String;var List : TPageList);
Var i,j,k : integer;
    r : boolean;
Begin
  r:=false;
  i:=0;
  list[0]:=1;
  while (s<>'') and (i<=255) do Begin
    if iniNumChar(s[1]) then begin      { Zahl?                         }
      k:=ininextnumber(s);              { zahl->k                       }
      if r then begin                   { range?                        }
        if k>list[i-1] then             { up/down?                      }
          j:=1
        else
          j:=-1;
        while list[i-1]<>k do begin     { bis das Ziel erreicht ist     }
          list[i]:=list[i-1]+j;         { se                            }
          inc(i);
        end;
        r:=false;
      end else begin
        List[i]:=k;
        inc(i);
      end;
    end else begin
      if s[1]='-' then begin            { -> range                      }
        delete(s,1,1);
         r:=true;
        if i=0 then
          inc(i);
      end else if (s[1]='.') and (s[2]='.') then begin { -> range           }
        delete(s,1,2);
        r:=true;
        if i=0 then
          inc(i);
      end else begin                    { separator                     }
        r:=false;
        delete(s,1,1);
      end;
    end;
  end;
  if r then begin
    while (i<=255) do begin
      list[i]:=list[i-1]+1;
      inc(i);
    end;
  end else
    list[i]:=-1;
End;

{******************************************************************}

Procedure Printpages(var linenum,actposn,actpost : integer;
                     var actptr, startptr, lastptr: listptr;
                     list : TPageList);

var spagecount : integer;
    i          : integer;
    inblock    : stringline;
    n          : integer;
Begin
  if (not (prfile=1)) or (not IniFileExist(psdir+'\'+prfname)) or
     (HlpAreYouSure('File: "'+psdir+'\'+prfname+
  '" already exists, overwrite?',hpEdit)) then begin
    n:=filnumpages(actptr,startptr,lastptr);
    PriPostscriptinit;
    spagecount:=pagecount;
    i:=0;
    while (i<256) and (List[i]>=0) Do Begin
      pagecount:=List[i];
      inc(i);
      printeron:=false;
      if pagecount=0 then begin
        { auf n„chste seite gehen }
        if ((prpage mod prformat)<>0) then begin{ Seite nicht sowieso fertig? }
          inblock:= 'showpage';                 { Seite anzeigen              }
          PriString(inblock);
          PriSetTopMargins;                     { n„xtes Mal: obere H„lfte    }
          repeat
            inc(prpage);
          until (prpage mod prformat)=0;
        end;
      end else
        { seite "laden" ... }
      if pagecount<=n then begin
        PagShowPage(linenum,actposn,actpost,actptr,startptr,lastptr,pagecount,true);
        printeron:=true;
        PriPostscript;
      end;
    End;
    PriPostscriptComplete;
    PagClearBottomLine;
    pagecount:=spagecount;
    printeron:=false;
    PagShowPage(linenum,actposn,actpost,actptr,startptr,lastptr,pagecount,true);
  End;
End;

{******************************************************************}
Procedure PrmPrintMenu(var linenum, actposn, actpost: integer;
                       var actptr, startptr, lastptr: listptr);
var dir                               : movement;
    c                                 : char;
    resp                              : response_type;
    choicenum                         : byte;
    x, y, hy, i, dy          : integer;
    mausx, mausy, maustaste, mausmenu : word;
    s                                 : string;
    changed                           : boolean;
    list                              : TPageList;
begin
  repeat
    ImeInitPrintMenu;
    maustaste:= 0;
    choicenum:= 1;
    PagRefClearVal(grminx - 10, grminy - 10,
                   grmaxx + 10, grmaxy + 10);
    y:=grmaxy - (usrmenu.num_choices * usrmenu.spacing +
       usrmenu.menuattr.firstline + 2) * charheight;
    hy:=y div charheight;
    GrDisplay_Frame(grminx, y, grmaxx, grmaxy, true, false);
    GrDisplay_Menu(hfminx, hy, usrmenu, 0);
    GrGet_Menu_Response(hfminx, hy, usrmenu, c, dir,
                        choicenum, mausx, mausy, maustaste,
                        mausmenu, false, 0);
    x:=hfminx + usrmenu.menu_width + 16;
    c:=UpCase(c);
    case c of
      'L' : begin
        dy:=10+hy+4;
        IniInversText (x-94,dy,'L - List  pages:                                                              ',
                       frlow);
        GrGet_String (s,x-81,dy,x-81,79,resp,dir,c,false,
                      mausx, mausy, maustaste, mausmenu,changed);
        if (resp=return) and (s<>'') then begin
          String2List(s,list);
          Printpages(linenum,actposn,actpost,actptr,startptr,lastptr,list);
        end;
      end;
      'P' : begin
        if (not (prfile=1)) or (not IniFileExist(psdir+'\'+prfname)) or
           (HlpAreYouSure('File: "'+psdir+'\'+prfname+
        '" already exists, overwrite?',hpEdit)) then begin
          PriPostscriptinit;
          PriPostscript;
          PriPostscriptComplete;
          PagClearBottomLine;
        end;
      end;
      'F' : begin       { print file    }
        for i:=0 to 255 do
          list[i]:=i+1;
        printpages(linenum,actposn,actpost,actptr,startptr,lastptr,list);
      end;
      'E' : begin
        for i:=0 to 255 do
          list[i]:=pagecount+i;
        printpages(linenum,actposn,actpost,actptr,startptr,lastptr,list);
      end;
      'C' : begin
        for i:=0 to pagecount-1 do
          list[i]:=i+1;
        list[pagecount]:=-1;
        printpages(linenum,actposn,actpost,actptr,startptr,lastptr,list);
      end;
      'O': begin
        PrmSetOptions;
      end;
    end; {case c of}
  until (c=#27);
end;

end.

