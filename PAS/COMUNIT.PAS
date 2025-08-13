{$I RNS.H}
unit Comunit;

interface

uses
     Graph,
     GCurUnit,
     InitSc,
     menutyp,
     xcrt,
     crt,
     getunit,
     dos,
     UserExit,
     SndUnit,
     MousDrv,
     ScrSave;

Procedure ComEdArrow(Direction : Movement;
                     var linenum, actposn, actpost: integer);
Procedure ComEdReturn(var linenum, actposn, actpost: integer;
                      shiftp, ctrlp : Boolean);
Function ComEdKey(var linenum, actposn, actpost: integer;
                   var actptr, startptr, lastptr: listptr;
                   KeyResponse : char;shiftp, ctrlp : Boolean) : Boolean;
Procedure ComEdSpecial(var linenum, actposn, actpost: integer;
                       var actptr, startptr, lastptr: listptr;
                       var KeyResponse : char; shiftp, ctrlp: boolean);
Procedure ComEdEscape(var linenum, actposn, actpost: integer;
                      var actptr, startptr, lastptr: listptr;
                      var resp: Response_Type);
Function ComEdMaus(mausx, mausy, maustaste: word;
                    var linenum, actposn, actpost: integer) : Boolean;
Procedure ComMouseAssign(mausx, mausy, maustaste: word;
                         Var Response: Response_type;
                         Var Keyresponse: Char;
                         Var shiftp, ctrlp: boolean);

Procedure ComSysEnd(Var Linenum : Integer);
Procedure ComSysStart(Var Linenum : Integer);
Function ComSysHeight(Linenum : integer) : Integer;
Function ComMusicStart(inblock : Stringline) : Byte;
Function ComStart(inblock : Stringline;actposn : Byte) : Byte;
Function ComEnd(inblock : StringLine;Actposn : Byte) : Byte;
Function ComLen(inblock : StringLine;ActPosn : Byte) : Byte;
Function comnext(inblock : stringline;actposn : Byte) : Byte;
Function comprev(inblock : stringline;actposn : Byte) : byte;
Function comskiplinesDown(linenum : integer) : integer;
Function comskiplinesUp(linenum : integer) : integer;
Function ComNL(linenum : integer) : Boolean;
Function ComTL(linenum : integer) : Boolean;
Function ComUsedTL(linenum : integer) : Boolean;
Function ComUsedL(linenum : integer) : Boolean;
Function ComSpaceUpNeed(linenum : integer) : Byte;
Function ComSpaceDownNeed(linenum : integer) : Byte;
Function ComSpaceBetweenNeed(l1,l2 : integer) : Byte;
Function ComSpaceBetween(l1,l2 : integer) : byte;
Function ComLinesUpBelong2(linenum : integer) : Byte;
Function ComLinesDownBelong2(linenum : integer) : Byte;
Function ComLineBelong2(linenum : integer) : Byte;
Function ComNextLine(linenum : integer) : integer;
Function ComPrevLine(linenum : integer) : integer;
Function ComInsPossible(num : integer) : Boolean;
Function Searchlastchiffre(linenum : Integer) : String;
Function CopyLine(Src,Des : Integer) : Boolean;
Function LineUsed(Linenum : Byte) : Boolean;
Function ComHorLine(linenum : integer) : Boolean;
implementation

uses
     Symbols,
     TitleUnit,
     inout,
     fileunit,
     grintunit,
     pageunit,
     prmunit,
     specunit,
     sp2unit,
     noteunit,
     textunit,
     graphmenu,
     markunit,
     butunit,
     satunit,
     helpunit,
     utilunit,
     dmemunit,
     Texts,
     userint,
     EditUnit;

VAR CursorKilled : Boolean;
    Cursorlinestart,cursorlineend : Byte;

{******************************************************}
Function ComKeyGrant(var c: char; linenum: integer): boolean;
{testet, ob ein Normales Zeichen c zur Zeit erlaubt ist}

var ordc   : byte absolute c;
begin
  ComKeyGrant:=True;
  if mstart.mpag<>-1 then begin
    ComKeyGrant:= false;
    HlpHint(HntUnmarkBlockFirst, HintWaitEsc);
    Exit;
  end;

  if ((IniHeaderFooterLine(linenum)) and (ordc = 127)) then begin
    ComKeyGrant:= false;
    HlpHint(HntNotAvailableHeader, HintWaitEsc);
    Exit;
  end;
  if ordc = 26 then begin
     ComKeyGrant:= false;
  end;
end;
{******************************************************}
function ComTestBlock(c : Char;var linenum, actposn, actpost: integer;
                      var actptr, startptr, lastptr: listptr) : Boolean;
var dummyb : Boolean;
begin
  ComTestBlock:=False;
  if (mstart.mpag<>-1) and (mend.mpag<>-1) then begin
    case UpCase(c) of
      'M': begin
        ComTestBlock:=True;
        FileChanged:=1;
        MarMarkToBuffer(actptr, startptr, lastptr);
        MarDeleteBlock(actptr, startptr, lastptr);
        PagUnMark;
        SpeInsertBuffer(linenum, actposn, actpost,
                        actptr, startptr, lastptr, dummyb);
      end;{'M'}
      'C': begin
        ComTestBlock:=True;
        filbufclear;
        MarMarkToBuffer(actptr, startptr, lastptr);
      end;{case c of 'C'}
    end;{Case}
  end else if pagebuf<>-1 then begin
    Case UpCase(c) of
      'M': begin
        ComTestBlock:=True;
        fildelpage(actptr, startptr, lastptr);
        filundelpage(actptr, startptr, lastptr);
      end;{'M'}
      'C': begin
        ComTestBlock:=True;
        filCopyPage(actptr, startptr, lastptr);
      end;{case c of 'C'}
    End;{case}
  end;
end;

{******************************************************}
Function ComSpecGrant(c: char; linenum: integer): boolean;
{testet, ob ein Spezialzeichen c zur Zeit erlaubt ist}

const marknocommands:          { wÑhrend Markierung nicht erlaubt }
      set of byte = [61{F3},62{F4},64{F6},67{F9},
                     82{INS}, 83{DEL},
                     87{shft f4},90{shft F7},92{shft F9},
                     94{Ctrl F1}, 95{Ctrl F2},96{Ctrl F3},97{ctrl f4},100{ctrl f7},102{ctrl F9},
{Alt F1..F8,F10}    104, 105, 106, 107, 108, 109, 110, 111, 113];

      pagemarknocommands:
      set of byte = [66{F8},
                     87{shft f4},91{shft F8},
                     94{Ctrl F1},95{Ctrl F2},97{ctrl f4}];

      pagenocommands:          { wÑhrend Page layout nicht erlaubt }
      set of byte = [60{F2}, 73{PU},81{PD},
                     92{Shft F9},
                     132{Ctrl PU},118{Ctrl PD},
                     95{Ctrl F2} (*,102*){Ctrl F9},112{alt f9}];

      markset:                { im Header nicht erlaubt}
      set of byte = [61, 62, 65, 66,
                     91,
                     146{ctrl ins}];

Var Ordc : Byte absolute c;
begin
  ComSpecGrant:=true;

  if (pagebuf<>-1) and (ordc in pagemarknocommands) then begin
    ComSpecGrant:= false;
    HlpHint(HntUnmarkPageFirst, HintWaitEsc);
    Exit;
  end;

  if (mstart.mpag<>-1) and (ordc in marknocommands) then begin
    ComSpecGrant:= false;
    HlpHint(HntUnmarkBlockFirst, HintWaitEsc);
    Exit;
  end;

  if (setuppage in actedit) and (ordc in pagenocommands) then begin
    ComSpecGrant:= false;
    HlpHint(HntNotAvailableLayout, HintWaitEsc);
    Exit;
  end;

  if (IniHeaderFooterLine(linenum)) and (ordc in markset) then begin
    ComSpecGrant:= false;
    HlpHint(HntNotAvailableHeader, HintWaitEsc);
    Exit;
  end;
end;

{******************************************************}
Procedure ComEdEscape(var linenum, actposn, actpost: integer;
                      var actptr, startptr, lastptr: listptr;
                      var resp: Response_Type);
begin
   inbuffer:='';
   {Wenn Markierung offen: UNMARK}
   if mstart.mpag = -1 then
   begin
      if ((setuppage in actedit) and
          (not (defsetuppage in actedit))) then
      begin
         {Zuletzt wurden die Pagesettings geaendert, escape
          springt ins file zurÅck}
          actedit:= actedit - [setuppage];
          IniSwapColors;
          PagShowPage(linenum, actposn, actpost,
                      actptr, startptr, lastptr, pagesav, true);
          MarkInit;
          resp:= no_response;
      end;
   end
   else
   begin
      PagUnMark;
      PagRefPage;
      resp:= no_response;
   end;
end;

{******************************************************}
Procedure ComEdReturn(var linenum, actposn, actpost: integer;
                      shiftp, ctrlp : Boolean);

var inblock: stringline;
    beats, eint : integer;
    x: integer;
    i : integer;
begin
  inbuffer:='';
  if shiftp and (not ctrlp) then{Shft Enter}begin
    if linenum<Pagelength-1 then
      inc(linenum,2)
    else
      linenum:=2;
    While (Page[linenum,1]='N') Do Begin
      IF linenum=52 Then
        linenum:=1;
      Inc(linenum);
    End;
    IF not (linenum in [1..pagelength]) Then
      linenum:=1;
  end else if not (shiftp or ctrlp) then{Nur Enter}begin
    if linenum>=pagelength then
      i:=pagelength - 1;
    for i:=linenum to pagelength do begin
      IF i<Pagelength Then
        if page[i+1,1]='N' then
          break;
    end;
    if (i=pagelength) {and (page[i+1,1]<>'N') }then begin
      for i:=0 to linenum-1 do begin
        if page[i+1,1]='N' then
          break;
      end;
    end;
    While Page[i+1,1]='N' Do
      Inc(i);
    linenum:=i;
  end;

  PagCursorleft(linenum, actposn, actpost);
  LastEntry:= other;
  arrowentry:= noarr;
end;

{******************************************************}
Function ComEdMaus(mausx, mausy, maustaste: word;
                    var linenum, actposn, actpost: integer) : Boolean;

var x: integer;
    gx,gy : integer;
begin
   ComEdMaus:=False;
   if ((mausy >= grminy) and (mausy <= grmaxy)) then
   begin
      gx:=gcxcoord;
      gy:=gcycoord;
      linenum:= IniLNow(mausy)+1;
      if (linenum < topmargin) then
      begin
         linenum:= topmargin;
      end;
      if (linenum > pagelength) then
      begin
         linenum:= pagelength;
      end;
      if page[ linenum, 1] = 'N' then
      begin
         x:= mausx+3;
         GetNotePosX(x, actposn, linenum, true, true);
      end
      else
      begin
         x:=mausx;
         TexTxtPosX(x, actpost, linenum, true);
         IF actpost<11 then
           actpost:=11;
      end;
      IF (gx<>gcxcoord) or (gy<>gcycoord) Then Begin
         inc(gcxcoord);
         WSwap(gx,gcxcoord);
         WSwap(gy,gcycoord);
         GcuPatternRestore;
         WSwap(gx,gcxcoord);
         WSwap(gy,gcycoord);
         ComEdMaus:=True;
      End;
   end;
   Lastentry:= other;
   arrowentry:= noarr;
   inbuffer:= '';
end;

{******************************************************}
Procedure ComMouseAssign(mausx, mausy, maustaste: word;
                         Var Response: Response_type;
                         Var Keyresponse: Char;
                         Var shiftp, ctrlp: boolean);
{Umwandeln von Tastendruck in Zeichen}

begin
   case maustaste of

      1: begin    { Links: Ret }
            if mausy > grmaxy then begin
               if showmenus then begin
                  ButActivated(mausx+8, mausy+8, response, keyresponse);
               end else begin
                  Response:= SPECIALKEY;
                  if mausx>118 Then
                    KeyResponse:= #133
                  else
                    KeyResponse:= #59;
               end;
            end;
         end;

      2: begin { Rechts: Esc}
            Response:= ESCAPE
         end;

      4: begin { Mitte: F8=Mark/UnMark }
            Response:= SPECIALKEY;
            KeyResponse:= #66;
         end;

      3: begin { L+R: Ctrl-F10=Swap Menu }
           Response:= SPECIALKEY;
           KeyResponse:= #103;
         end;
      5: begin { L+M: Ctrl-F8=Paste block}
           Response:= SPECIALKEY;
           KeyResponse:= #101;
         end;
      6: begin { M+R: F10=Symbol Table }
           Response:= SPECIALKEY;
           KeyResponse:= #68;
         end;
      7: begin { L+M+R: F1=Help }
           Response:= SPECIALKEY;
           KeyResponse:= #59;
         end;

   end;
   shiftp:= false;
   ctrlp:= false;
end;


{******************************************************}
Procedure ComEdArrow(Direction : Movement;
                     var linenum, actposn, actpost : integer);

var i,j,k: integer;
    inblock: stringline;
    beats, eint : integer;
    x: integer;

begin
   inbuffer:='';
   symbcount:=0;
   case Direction of
     UP   : begin
              if ((linenum > linestyletop) or
                 ((not (linestyles in actedit)) and
                  (linenum >= topmargin + 1))) And (Linenum>1)
              then begin
                Dec(linenum);
                if page[linenum, 1] = 'T' then Begin
                  IniTrailBlank(page[linenum]);
                  IF actpost<11 Then Begin
                    actpost:=11;
                  End;
                End;
                if page[ linenum, 1] = 'N' then begin
                  x:= gcxcoord+6;
                  GetNotePosX(x, actposn, linenum, true, true);
                end else begin
                  if lastentry <> curupdown then begin
                    x:= gcxcoord;
                    TexTxtPosX(x, actpost, linenum, true);
                    if actpost<11 then Begin
                      actpost:=11;
                    End;
                    TexActPosX(x, actpost, linenum, true);
                  end else begin
                    TexActPosX(x, actpost, linenum, true);
                  end;
                end;
              end;
              lastentry:= curupdown;
            end; {UP}

      DOWN : begin
                if linenum < PageLength then
                begin
                   Inc(linenum);
                   if page[linenum, 1] = 'T' then Begin
                      IniTrailBlank(page[linenum]);
                      IF actpost<11 Then Begin
                         actpost:=11;
                      End;
                   End;
                   case page[ linenum, 1] of

                   'N':
                      begin
                         x:= gcxcoord+6;
                         GetNotePosX(x, actposn, linenum, true, true);
                      end;

                    'T':
                       begin
                          if lastentry <> curupdown then
                          begin
                             x:= gcxcoord;
                             TexTxtPosX(x, actpost, linenum, true);
                             if actpost<11 then Begin
                                actpost:=11;
                             End;
                             TexActPosX(x, actpost, linenum, true);
                          end
                          else
                          begin
                             TexActPosX(x, actpost, linenum, true);
                          end;
                       end;
                   end; {case page[ linenum, 1] of}

                end; {if Linenum < Pagelength}
                lastentry:= curupdown;
             end; {DOWN}

      LEFT : begin
                case page[ linenum, 1] of

                'N':
                   begin
                      x:= gcxcoord - 1;
                      GetNotePosX(x, actposn, linenum, true, true);
                      Dec(X);
                      GetNotePosX(x, actposn, linenum, true, false);
                   end;

                'T':
                   begin
                      IF ActPost>11 Then
                        actpost:= actpost - 1;
                      TexActPosX(x, actpost, linenum, true);
                   end;
                end; {case page[ linenum, 1] of}
                Lastentry:= other;
             end; {LEFT}

      RIGHT: begin
                case page[ linenum, 1] of

                'N':
                   begin
                      x:= gcxcoord + 1;
                      GetNotePosX(x, actposn, linenum, true, false);
                   end;

                'T':
                   begin
                      SpeTextRight(linenum, actpost);
                   end;
                end; {case page[ linenum, 1] of}
                Lastentry:= other;
             end; {RIGHT}
   end; { case Direction of }
   arrowentry:= noarr;
   inbuffer:= '';
end;  { ARROW }

{******************************************************}
Procedure ComLineRep(linenum: integer);

begin
   setcolor(lcolor);
   if ((linenum > topmargin) and (page[linenum - 1, 1] = 'N')) then
   begin
      GetLine(linenum - 1, gcxcoord - 20);
   end;
   if ((linenum > topmargin) and (page[linenum + 1, 1] = 'N')) then
   begin
      GetLine(linenum + 1, gcxcoord - 20);
   end;
   if ((linenum > topmargin) and (page[linenum + 2, 1] = 'N')) then
   begin
      GetLine(linenum + 2, gcxcoord - 20);
   end;
end;
{***********************************************}
Procedure ComDelToSoLn(var linenum,actposn,actpost : Integer);
Var inblock : stringline;
    i,l     : integer;
Begin
  inbuffer:='';
  inblock:=page[linenum];
  if inblock[1] = 'N' then begin
    i:=commusicstart(inblock);
    if (copy(inblock,i,2)='.1')and((inblock[i+2]<'0')or(inblock[i+2]>'9')) then
      inc(i,2)
    else begin
      i:=comnext(inblock,i);
       if inblock[comstart(inblock,comnext(inblock,i))]='.' then begin
        while (inblock[comstart(inblock,comnext(inblock,i))]='.') and (i<>length(inblock)) do
          i:=comnext(inblock,i);
        i:=comnext(inblock,i);
      end;
    end;
    delete(inblock,i,Comstart(inblock,actposn)-i);
    PagRefClearVal(grminx,iniynow(linenum-5),grmaxx,iniynow(linenum+3));
    page[linenum]:=inblock;
    actposn:=i;
    GetActPosX(l, actposn,linenum,true);
  end {if inblock} else begin
    PagRefClearVal(grminx,iniynow(linenum-5),grmaxx,iniynow(linenum+3));
    i:=linemarker;
    while inblock[i]=' ' do
      inc(i);
    if i>=actpost then
      i:=linemarker+2;
    delete(inblock,i,actpost-i);
{    PagRefClearVal(grminx,iniynow(linenum)-6,grmaxx,iniynow(linenum)+4);}
    page[linenum]:=inblock;
    actpost:=i;
    TexActPosX(l, actpost,linenum,true);
  end;{if inblock else}
End;
{***********************************************}
Function ComEdKey(var linenum, actposn, actpost: integer;
                   var actptr, startptr, lastptr: listptr;
                   KeyResponse : char;shiftp, ctrlp : Boolean) : Boolean;

var ordc, endy : integer;
    Insl,Ins   : integer;
    Pitch      : Integer;
    dummyb     : boolean;
    inserted   : boolean;
    inblock    : stringline;
    v          : string[3];
    i,k,l,m,y  : Integer;
    a,b        : integer;
begin
  ComEdKey:=False;
  if ComTestBlock(KeyResponse, linenum, actposn, actpost,actptr,
                   startptr, lastptr) Then
    Exit;
  if ComKeyGrant(KeyResponse, linenum) then begin
    ordc:=  Byte(KeyResponse);
    case ordc of
      10 :{ctrl Enter} begin
        if Mstart.MPag<>-1 then begin
          HlpHint(HntUnMarkBlockFirst, HintWaitEsc);
          Exit;
        end;{If Mstart.MPag...}
        if page[linenum,1]='T' then
          Exit;                         { Mit TLs gebe ich mich nicht ab!  }
        l:=linenum;
        ComSysstart(l);                 { Erste Zeile des Systems          }
        ComSysend(Linenum);             { Letzte Zeile des Systems         }

        { unterste Linie, die noch zur linenum gehîrt)                     }
        k:=linenum+comskiplinesdown(linenum);

        { i=naechstuntere, nichtleere Linie, ueberspringe Trommelsprache.. }
        i:=ComNextLine(k);

        { insl=Zeilennummer wo die neue Linie eingefÅgt wird               }
        insl:=ComSpaceBetweenNeed(k,l)+k+comsysheight(linenum);

        { ins=Anzahl benîtigter Leerzeilen                                 }
        ins:=ComSpaceBetweenNeed(k,l)+ComSpaceBetweenNeed(linenum,i)+comsysheight(linenum);

        { ->ins=Anzahl einzuschiebender Leerzeilen                         }
        ins:=ins-comspacebetween(i,k);
        if ins<0 Then
          ins:=0;
        if ComInsPossible(Ins) Then Begin
          For l:=1 To Ins Do Begin
            SpeInsTextLine(i, actpost, actptr, startptr,
                           lastptr, false);
          End;
          For l:=0 To (ComSysHeight(Linenum)-1) Do Begin
            m:=pos('%',page[linenum-l]);
            inblock:=copy(page[linenum-l],1,m);
            page[linenum-l,2]:=' ';
            while not (page[linenum,m] in Numbers) do
              inc(m);
            inblock:=inblock+'.';
            v:='';
            while page[linenum,m] in Numbers Do Begin
              v:=v+page[linenum,m];
              inc(m);
            End;
            val(v,m,y);
            if y<>0 then begin
              m:=1;
              v:='1';
            end;
            for y:=1 to m do
              inblock:=inblock+v+'.';
            If Searchlastchiffre(linenum-l)<>'0' Then{ Beat Åbernehmen }
              inblock:=inblock+Searchlastchiffre(linenum-l);{NL einfÅgen}
            Page[insl-l]:=inblock;
          End;
          Linenum:=Insl;
          PagRefClearVal(0,       IniYnow(linenum-comsysheight(linenum)-2),
                         GetMaxX, GrMaxY-9);
          PagCursorLeft(linenum, actposn, actpost);
        End Else Begin
          HlpHint(HntNotEnoughSpace, HintWaitEsc);
        End;
      End;

      127 : begin  {Ctrl BS: -}
        if mstart.mpag=-1 then begin
          delpage:= false;
          delln:= page[linenum];
          SpeLineDelete(linenum, true);
          PagRefClearVal(0, IniYnow(linenum - 5),
                         gmaxx, grmaxy-1);
          PagCursorLeft(linenum, actposn, actpost);
          lastentry:= other;
          arrowentry:= noarr;
          inbuffer:='';
        end;
      end;
      else begin{Case}
        if shiftp and (ordc=8) then{Shift BS} begin
          ComDelToSoLn(linenum,actposn,actpost);
        end else begin
          comedkey:=True;
          FileChanged:=1;
          if (page[linenum, 1] = 'N') then begin
            NotEdNoteLine(linenum, actposn, KeyResponse);
          end else begin
            TexEdTextLine(linenum, actpost, KeyResponse);
            getredraw(linenum,gcxcoord-18,gcxcoord);
            ComLineRep(linenum); {neu fÅr TAB PEO}
            lastentry:= other;
          end;
        end;
      end; {case else}
    end;{case}
  end; {if ComKeyGrant}
  comedkey:=true;
end;

{******************************************************}
procedure KillCursor;assembler;{New}

asm
  CMP cursorkilled, false
  JNZ @001
  MOV AH,3
  MOV BH,0
  INT $10
  MOV cursorlinestart,ch
  MOV cursorlineend,cl
  MOV AH,1
  MOV CH,$20
  INT $10
  MOV cursorkilled,true
@001:
end;

{******************************************************}

procedure RestoreCursor;assembler;{New}
asm
  CMP cursorkilled, true
  JNZ @001
  MOV AH,1
  MOV CH,cursorlinestart
  MOV CL,cursorlineend;
  INT $10
  MOV cursorkilled,FALSE
@001:
END;

{******************************************************}
Procedure ComEdSpecial(var linenum, actposn, actpost: integer;
                       var actptr, startptr, lastptr: listptr;
                       Var KeyResponse : char; shiftp, ctrlp: boolean);

var c,ch,dummyc                   : char;
    SLColor                       : Byte;
    lasts                         : Byte;
    oldcolor                      : byte;
    i,j,k,result                  : integer;
    Insl,ins,sta                  : integer;
    ActLineSav                    : integer;
    OldLine                       : integer;
    ordc,beats,eint               : integer;
    x,y                           : integer;
    col,row,getfreq               : Integer;
    l                             : integer;
    attr                          : word;
    playnext                      : Boolean;
    inserted                      : boolean;
    LimitFound,dummyb,temp1,temp2 : Boolean;
    repline                       : boolean;
    SPic                          : Pointer;
    st                            : String;
    inblock                       : stringline;
    delfil                        : text;
    lineattr                      : lineattrtype;
    lastsnd                       : integer;

Function SearchFirst(Var st : String;Var linenum,actposn : Integer) : Boolean;
Var c : char;
    lnum : integer;
Function ValidLine : Boolean;
Begin
  actposn:=comMusicStart(st);
{ IF Pos('/',St)<>0 Then
    Byte(St[0]):=Pos('/',St);}
  while ((actposn<=length(st)) and (UtiComputeGroup(st[actposn],c)=0)) do
    inc(actposn);
  ValidLine:=(actposn<=length(st)) and (GetDrawSymbol(lnum,actposn,false));
End;
Begin
  lnum:=linenum;
  dec(linenum);
  st:=Page[lnum];
  while (not ValidLine) and (lnum<>linenum) do begin
    ComEdReturn(lnum, actposn, actpost,
                false,false);
    st:=page[lnum];
  end;
  if lnum=linenum then begin
    inc(linenum);
    hlpHint(HntlineEmpty,HintNormalTime);
    SearchFirst:=False;
    Exit;
  end;
  linenum:=lnum;
End;

Procedure SwapColor;
begin
   if LColor <> soundcolor then
   begin
      LColor:=soundcolor;
   end
   else
   begin
      LColor:=Slcolor;
   end;
   SetColor(LColor);
end;


begin
  repline:=true;
  if ComSpecGrant(KeyResponse, linenum) then begin
    ordc:= Byte(KeyResponse);
    case ordc of
      162 : {alt ins} begin
        if delpage then begin
          {insert page von delfile}
          i:= pagecount;
          FilSavePage(1, PageLength, actptr, startptr, lastptr);
          assign(delfil,'delpage');
          LastFileName:=FExpand('DELPAGE');
          reset(delfil);
          for j:= 1 to pagelength do
            readln(delfil, page[j]);
          PagRefPage;
          close(delfil);
          FilFindPage(pagecount, i, actptr, startptr, lastptr);
          PagRefPage;
        end;
      end;
      163:{alt del}begin{save page to buffer}
        delpage:= true;
        assign(delfil,'delpage');
        LastFileName:=FExpand('DELPAGE');
        rewrite(delfil);
        for i:= 1 to pagelength do
          writeln(delfil,page[i]);
        close(delfil);
        {goto previous page if this is last page}
        if actptr = lastptr then
          pagecount:= pagecount - 1;
        if pagecount > 0 then begin
          {show new page, dont save this page}
          PagShowPage(linenum, actposn, actpost, actptr,
                      startptr, lastptr, pagecount, false);
        end else begin
          PagGetSetupPage(actptr, startptr, lastptr);
          pagecount:= 1;
          PagRefPage;
        end;
      end;
      15 : {shift tab}begin
        FileChanged:=1;
        if page[linenum,1] = 'T' then begin
          TexEdTextLine(linenum, actpost, chr(240));
        end else begin
          if page[linenum,1] = 'N' then
            if symbcount>0 then
              dec(symbcount);
        end;
      end;

      59 : {F1: this help table}begin
        SetViewPort(0,0,GetMaxX,GetMaxY,true);
        ClearViewPort;
        HlpCommandTable;
        repeat
          SetPalette(12,0);             { Color 12=PalReg[0]                    }
          SetPalette(13,15);            { Color 13=PalReg[15]                   }
          IniSetDACReg(60,0,0,0);       { light red ->Schwarz                   }
          IniSetDACReg(5,63,63,63);     { magenta   ->Weiss  }
          IniSetDACReg(63,10,10,10);    { Weiss     ->Grau   Mausfarbe!!!       }
          c:= IniMausEscape;
        until c = chr(27);
        PagRefPage;
        repline:=false;
      end;

      60:  {F2: save file}begin
        XClearKbd;
        GetMem(SPic,ImageSize(grminx, grmaxy - 49,
                              grMaxX, grmaxy));
        GetImage(GrMinX, grmaxy - 49,
                 GrMaxX, grmaxy, SPic^);
        HlpHintFrame(grminx, grmaxy - 48, grmaxx, grmaxy);
        if EdiSavePossible(actfilename) Then Begin
          GetFAttr(infile, attr);
          if (attr And readonly)<>0 Then Begin
            txtfnt.Write(grminx + 20, grmaxy - 32,
               'Read only file, changes will not be saved!',
               getcolor,sz8x16,stnormal);
            txtfnt.Write(grminx + 20, grmaxy - 16,
               'Press any key to continue',
               getcolor,sz8x16,stnormal);
            xClearKbd;
            Repeat Until KeyPressed;
            xClearKbd;
            PutImage(GrMinX, grmaxy - 49,SPic^,NormalPut);
            FreeMem(Spic,ImageSize(grminx, grmaxy - 49,grmaxx, grmaxy));
            Exit;
          End;
          fileChanged:=0;
          FilSavePage(1, pagelength, actptr, startptr, lastptr);
          LastFileName:=FExpand(TextRec(infile).Name);
          rewrite(infile);
          if bufffile then begin
            WriteLn(infile,'$$$RNSBUFFER$$$');
            WriteLn(infile,'    -1    -1    -1    -1    -1    -1    -1');
            FilHeapToFile(infile, actptr, startptr, lastptr,
                          false, false, false);
          end else
            FilHeapToFile(infile, actptr, startptr, lastptr,
                        false, false, true);
          FilFindPage(pagecount, result, actptr, startptr, lastptr);
          PagRemovePage(actptr, startptr, lastptr);
        End Else Begin
          txtfnt.write(grminx + 20, grmaxy - 32,
             'Demoversion: not saved',
             getcolor,sz8x16,stnormal);
          txtfnt.write(grminx + 20, grmaxy - 16,
             'Press any key to continue',
             getcolor,sz8x16,stnormal);
          XClearKbd;
          Repeat Until KeyPressed;
          XClearKbd;
        End;
        PutImage(GrMinX, grmaxy - 49,SPic^,NormalPut);
        FreeMem(Spic,ImageSize(grminx, grmaxy - 49,grmaxx, grmaxy));
      end;

      61 : {F3: noteline insert} begin
        FileChanged:=1;
        SpeInsNoteLine(linenum, actposn, actptr, startptr, lastptr);
        PagCursorLeft(linenum, actposn, actpost);
        repline:=false;
      end;

      62 : {F4: emptyline insert}begin
        FileChanged:=1;
        SpeInsTextLine(linenum, actpost, actptr, startptr,
                       lastptr, false);
        PagCursorLeft(linenum, actposn, actpost);
        repline:=false; {sonst gibts Doppellinien wegen ComLineRep PEO}
      end;

      63 : {F5: sound play}begin
        for i:=linenum to pagelength do
          if page[i,1]='N' then
            break;
        if page[i,1]<>'N' then
          for i:=1 to linenum do
            if page[i,1]='N' then
              break;
        if page[i,1]='N' then begin
          inblock:=page[i];
          getnoteattributes(inblock,lineattr);
        end;
        CtrlF5:=False;
        GcuPatternRestore;
        paused:=false;
        playnext:=True;
        st:='';
        HlpBottomLine(st);                                  {[+/-]=speed}
        PagBottomFrame;
        IniSpacedText( 2,54,'  Space = pause  ',frHigh);
        IniSpacedText( 2,56,'  Esc   = stop   ',frHigh);
        IniSpacedText( 2,58,' '+#24+'Esc = stop end ',frHigh);

        IniSpacedText(20,54,' (A/C)Enter = '+#24+#25+'Line ',frHigh);
        IniSpacedText(20,56,' 0=roundCent 5=reset ',frHigh);
        IniSpacedText(20,58,'                     ',frLow);


        IniSpacedText(42,54,' on/off: BPTSLMR ([{› ',frHigh);
        IniSpacedText(42,56,' ('+#24+'/Ctrl/Alt)Ò: speed ',frHigh);
        IniSpacedText(42,58,'                      ',frHigh);
   {      IniSpacedText(42,54,' Ò, '+#24+'Ò = speedÒ1, Ò10 ',frHigh);
        IniSpacedText(42,56,' CtrlÒ = speed˘,:2    ',frHigh);
        IniSpacedText(42,58,'  AltÒ = speed˘,:1.33 ',frHigh);  }
        IniDrawSoundState;

        IniSpacedText(65,54,' / * = LPMBPM ',frHigh);
                   Str(sndlengthspm:4:3,st);
                   while st[0]<#8 do
                      st:=' '+st;
                   IF SndLengthPer=1 Then
                      st:=st+'   BPM '
                   Else
                      st:=st+'   LPM ';
        IniSpacedText(65,56, st,frLow);
        IniSpacedText(65,58,' . = round -PM ',frHigh);
        GcuPatternRestore;
        if page[linenum,5]='H' then begin
          sndchar:='L';
          SndPlaySound(linenum,actposn,actpost,actptr,startptr,
                    lastptr,true,playnext);
          gcupatternrestore;
        end;
        if playnext then
          Repeat
            While xkeypressed do xreadkey(temp1, temp2);
            SndPlaySound(linenum, actposn, actpost,
                         actptr, startptr, lastptr, false,playnext);
            If PlayNext Then Begin
              ComEdReturn(linenum, actposn, actpost, shiftp, ctrlp);
              IF PlaySuccess Then Begin
                PagRefreshPage(refxmin, refymin, refxmax, refymax);
                if playnext then
                  gcupatternrestore;
              end;
              IniRefInit;
            end;
          until PlayNext=False;
        PagPutBottomLine;
        GcuPatternRestore;
        PagCursorleft(linenum, actposn, actpost);
        repline:=false;
      end;

      64 : {F6: header + footer}begin
        FileChanged:=1;
        Sp2SetHeaderFooter(linenum);
        repline:=false;
      end;

      65 : {F7: copy line (to Ctrl-F7-Buffer)}begin
        saveln:=page[linenum];
        HlpHint(HntSavingLine, HintNormalTime);
        repline:=false;
      end;

      66 : {F8: mark/undo block}begin
        if mstart.mpag = -1 then begin
          MarkStart(IniPos(linenum, actposn, actpost),
                    linenum, pagecount);
          MarkDisplay;
        end else begin {end block}
          if mend.mpag = -1 then begin
            MarkEnd(IniPos(linenum, actposn, actpost),
                    linenum, pagecount);
            MarkDisplay;
          end else begin
            PagUnmark;
          {  PagRefPage; }
            PagRefClearVal(grminx,iniYnow(linenum),grmaxx,iniYnow(linenum));
          end;
        end;
        repline:=false;
      end;

      67 : {F9: mark/undo page}begin
        if pagebuf=-1 then begin
          filmarkpage;
        end else begin
          filunmarkpage;
        end;
        repline:=false;
      end;

      68 : {F10: symbols table}begin
        c:= 'a';
        temp1:= false;
        while (c <> chr(27)) do begin
          Mausdunkel;
          HlpSymbolSelect(c);
          if ((c >= 'a') and (c <= 'z')) then begin
            SatSymbolParam(c);
            temp1:= true;
          end;
        end;
        if temp1 then begin
          SatSaveSym;
        end;
        PagRefPage;
        repline:=false;
      end;

      133 : {F11: StatusBar/MouseMenu}begin
        showmenus:= not showmenus;
        setlinestyle(solidln,0,1);
        if showmenus then begin
          ButDraw;
        end else begin
          PagPutBottomLine;
        end;
        repline:=false;
      end;

      134 : {F12: Refresh Page}begin
        PagRefPage;
        repline:=false;
      end;

      71 : {home: begin of line}begin
        PagCursorLeft(linenum, actposn, actpost);
        repline:=false;
      end;

      73 : {PgUp: previous page} begin
        if shiftp then begin
          SpeJoinPage(linenum, actposn, actpost,
                      actptr, startptr, lastptr);
        end else if PageCount > 1 then begin
          PagShowPage(linenum, actposn, actpost, actptr,
                      startptr, lastptr,
                      pagecount - 1, true);
        end;
        repline:=false;
      end;

      79 : {End: end of line}begin
        PagCursorRight(linenum, actposn, actpost);
        repline:=false;
      end;

      81 : {PgDn: next page} begin
        if shiftp then begin{ shift PdDn}
          FilSavePage(1, PageLength, actptr, startptr, lastptr);
          FilFindPage(30002, pagecount, actptr, startptr, lastptr);
          IniNewPage(linenum);
          PagGetPageFromHeap(actptr, startptr, lastptr, i);
          PagCursorLeft(linenum, actposn, actpost);
          PagShowPage(linenum, actposn, actpost,
            actptr, startptr, lastptr, pagecount + 1, true);
        end else begin
           ActFilename:=UpString(actfilename);
           if demoversion and (pagecount>=4) and
              (actfilename='DEMODIR\TESTFILE.RNS') then
             hlphint(hntdemonewpage,hintwaitesc)
           else begin
             if ((actptr <> lastptr) or
                 (HlpAreYouSure('New page?'{ + ': [Enter] to continue, [PgUp] to cancel - or:'}, hpEdit))) then begin
                PagShowPage(linenum, actposn, actpost, actptr,
                            startptr, lastptr,
                            pagecount + 1, true);
             end else
               pagrefpage;
           end;
        end;
        repline:=false;
      end;

      82 : {Insert: symb/char insert}begin
        FileChanged:=1;
        if not shiftp then begin
          if page[linenum,1] = 'T' then begin
            TexInsChar(linenum, actpost);
          end else { if page[linenum,1]='T'} begin
            NotInsNote(linenum, actposn);
            PagRefClearVal(gcxcoord-25, IniYnow(linenum-5), gmaxX, IniYnow(linenum+3));
          end;
        end else {if not shiftp}begin
          SpeInsTextLine(linenum, actpost,
                         actptr, startptr, lastptr, true);
          PagCursorLeft(linenum, actposn, actpost);
          PagRefPage;
        end; {else if not shiftp}
        repline:=false;
      end;

      83 : {Delete: sym/char delete}begin
        FileChanged:=1;
        inbuffer:='';
        if not shiftp then begin
          if page[linenum,1] = 'T' then begin
            TexDelChar(linenum, actpost);
          end else { if page[linenum,1] = 'T' then } begin
            NotDelNote(linenum, actposn);
            if gcxcoord<=gmaxx then
              PagRefClearVal(gcxcoord-25, IniYnow(linenum-5), gmaxX, IniYnow(linenum+3))
            else
              PagRefClearVal(gmaxx-25, IniYnow(linenum-5), gmaxX, IniYnow(linenum+3))
          end;
        end else{shift del: Delete to end of line}begin
          if page[linenum,1] = 'T' then begin
            TexDelToEOL(linenum, actpost);
          end else { if page[linenum,1] = 'T' then } begin
            if gcxcoord>IniLineEnd(page[linenum]) then
              PagCursorRight(linenum, actposn, actpost);
            NotDelToEOL(linenum, actposn);
            PagCursorRight(linenum, actposn, actpost);
          end;
          if (linenum+3) > 52 then
            i:=52
          else
            i:=linenum+3;
          IF Page[linenum,1]='N' Then begin
            if gcxcoord<=gmaxx then
              PagRefClearVal(gcxcoord-25, IniYnow(linenum-5), gmaxX-1, IniYnow(i))
            else
              PagRefClearVal(gmaxx-25, IniYnow(linenum-5), gmaxX-1, IniYnow(i));
          end Else begin
            TexClearLine(linenum, gcxcoord-6);
            getredraw(linenum,gcxcoord-12,grmaxx);
          end;
        end;
      end;

      84 : {Shift F1: show / hide}begin
        Sp2VisiMenu;
        PagRefPage;
        repline:=false;
      end;

      85 : {Shift F2: (save as or quit) Save Y/N}begin
        IF FileChanged=1 Then Begin
          GetMem(SPic,ImageSize(grminx, grmaxy - 49,
                                grMaxX, grmaxy));
          GetImage(GrMinX, grmaxy - 49,
                   GrMaxX, grmaxy, SPic^);
          HlpHintFrame(grminx, grmaxy - 48, grmaxx, grmaxY);
          txtfnt.Write(grminx + 20, grmaxY - 32,
          'File '+ActFileName+' has been changed!',
          getcolor,sz8x16,stnormal);
          txtfnt.Write(grminx + 20, grmaxY - 16,
          'Save changes? [Y]/[N]. [Esc] to cancel',
          getcolor,sz8x16,stnormal);
          Repeat
            c:=IniMausEscape;
            IF c=#13 then
              c:='Y'
            Else IF C=#0 Then Begin
              c:=XReadKey(temp1,temp2);
              IF C=#73 Then c:=#27;
              IF C=#81 Then c:='Y';
            End Else
              c:=UpCase(C);
          Until (C='Y') Or (C='N') Or (C=#27);
          IF C='Y' Then
            FileChanged:=2
          Else if c='N' then
            FileChanged:=0
          Else
            keyresponse:=#0;
          PutImage(GrMinX, grmaxy - 49,SPic^,NormalPut);
        End;
        repline:=false;
      end;

      86 : {Shift F3: noteline define}begin
        SpeEdLineAttr(linenum, actposn, actpost, startptr, lastptr);
        repline:=false;
      end;

      87 : {Shift F4: insert page}begin
        i:= pagecount;
        FilSavePage(1, PageLength, actptr, startptr, lastptr);
        PagGetSetupPage(actptr, startptr, lastptr);
        FilFindPage(pagecount, i, actptr, startptr, lastptr);
        PagRefPage;
        repline:=false;
      end;

      88 : {Shift F5: sound options}begin
        CtrlF5:=False;
        SndSoundMenu(linenum, actposn, actpost,
                     actptr, startptr, lastptr, true);
        PagRefPage;
        repline:=false;
      end;

      89 : {Shift F6: search + replace}begin
        FileChanged:=1;
        Sp2SearchAndReplace(linenum, actposn, actpost, actptr,
                             startptr, lastptr);
        repline:=false;
      end;

      90 : {Shift F7: line commands}begin
        SpeLineCommands(linenum, actposn, actpost, actptr,
                          startptr, lastptr);
        repline:=false;
       end;

      91 : {Shift F8: block commands}begin
        FileChanged:=1;
        SpeBlockCommands(linenum, actposn, actpost, actptr,
                         startptr, lastptr, ' ');
        repline:=false;
      end;

      92 : {Shift F9: page commands}begin
        FileChanged:=1;
        Sp2PageCommands(linenum, actposn, actpost, actptr,
                        startptr, lastptr);
        repline:=false;
      end;

      93 : {Shift F10: swap keyboard}begin
        Sp2SwapKeyboard;
        PagRefPage;
        repline:=false;
      end;

      94 : {Ctrl F1: print menu}begin
        PrmPrintMenu(linenum, actposn, actpost,
                    actptr, startptr, lastptr);
        PagRefPage;
        repline:=false;
      end;

      95 : {Ctrl F2: split file}begin
        if{$IFDEF DEMO}false or{$ENDIF}(not demoversion) then begin
          FileChanged:=1;
          pagesav:= pagecount;
          SpeSplitFile(actptr, startptr, lastptr);
          pagecount:= pagesav -1;
          PagRefPage;
        End;
      end;

      96 : {Ctrl F3: split line}begin
        inblock:=page[linenum];
        st:=inblock;
        if inblock[1]<>'N' Then
          exit;
        if gcxcoord>IniLineEnd(page[linenum]) then
          PagCursorRight(linenum, actposn, actpost);
        i:=comstart(inblock,actposn);
        page[linenum,0]:=char(i-1);
        page[linenum]:=page[linenum]+'.';
        pagrefclearval(grminx,iniynow(linenum-5),grmaxx,iniynow(linenum+3));
        inblock:=copy(inblock,i,length(inblock)-i+2);
        if not ComEdKey(linenum, actposn, actpost,
                    actptr, startptr, lastptr, #10,shiftp,ctrlp) then begin
          page[linenum]:=st;
          exit;
        end;
        page[linenum,0]:=char(commusicstart(page[linenum])+1);
        page[linenum]:=page[linenum]+inblock;
      end;
      97 : {ctrl F4 split page}begin
        SpeSplitPage(linenum, actposn, actpost,
                     actptr, startptr, lastptr);
        repline:=false;
      end;
      98 : {Ctrl F5: Play Symbol}begin
        CtrlF5:=True;
        Paused:=False;
        lastS:=0;
        IF Page[Linenum,1]<>'N' Then
          ComEdReturn(linenum, actposn, actpost,false, false);
        GCUCursorClear;
        Dec(ActPosn);
        SLColor:=LColor;
        dummyb:=showmenus;
        showmenus:=False;
        While XKeyPressed Do
          XReadKey(Temp1,Temp2);
          C:=#1;
          PagPutBottomLine;   {### brauchts leider noch wenn Mausmenu, dann Ctrl-F5}
          {IniSpacedText( 2,gmaxy div charheight - 5,' Space=pause ',frHigh);}
          IniSpacedText( 2,gmaxy div charheight - 3,' Esc  = stop ',frHigh);
          IniSpacedText( 2,gmaxy div charheight - 1,' '+#27+' '+#26+'  = step ',frHigh+frdel3d);
          IniSpacedText(36,gmaxy div charheight - 5,'                    ',frLow);
          IniSpacedText(36,gmaxy div charheight - 3,'                    ',frLow);
          IniSpacedText(36,gmaxy div charheight - 1,'                    ',frLow);
          IniSpacedText(72,gmaxy div charheight - 3,'        ',frLow+frdel3d);
          IniSpacedText(16,gmaxy div charheight - 1,
          Copy(sndgetcentstr(addcent),2,19),frLow);
          actposn:=linenum;
          if (page[linenum,1]<>'N') then
            ComEdReturn(i, actposn, actpost,false,false);
          if page[linenum,1]<>'N' then begin
            hlpHint(HntpageEmpty,HintNormalTime);
            Exit;
          end;
          if not SearchFirst(st,linenum,actposn) then
            exit;
          Repeat
            i:=UtiComputeGroup(St[actposn],ch);
            SwapColor;
            IF Not GetDrawSymbol(linenum,actposn,true) Then
              Actposn:=commusicStart(st);
            IF Not Paused Then Begin
              IF (Ch<='z') and (Ch>='a') Then begin
                lastsnd:=sympar[ch,3,i];
                sound(Round(sympar[ch,3,i]*mulcent));
              end else if (ch='&') then
                sound(Round(lastsnd*mulcent));
            End Else
              nosound;
            SwapColor;
            PagShowCurPosDistances(Linenum,ActPosn,ActPost,2);
            IF Paused Then
              IniSpacedText( 2,gmaxy div charheight - 5,' Space= play ',frHigh)
            Else
              IniSpacedText( 2,gmaxy div charheight - 5,' Space=pause ',frHigh);
            case xreadkey(temp1,temp2) OF
              #0 : Begin
                Case xreadkey(temp1,temp2) OF
                  #165 : Begin{Alt-Tab}
                  End;
                  #28 : Begin{Alt-Enter}
                    GetDrawSymbol(linenum,actposn,true);
                    dummyc:=#28;
                    ComEdSpecial(linenum, actposn, actpost,
                                 actptr, startptr, lastptr,
                                 dummyc,temp1, temp2);
                    SearchFirst(st,linenum,actposn);
                  End;{#28}
                  #77 : Begin{Rechts}
   {                  SetColor(SLColor);}
                    GetDrawSymbol(linenum,actposn+lasts,true);
                    Repeat
                      inc(actposn);
                      if (actposn>length(st)) then
                        actposn:=commusicstart(st);
                    Until (((UtiComputeGroup(St[actposn],c)<>0) or (c='&')) and
                          (GetDrawSymbol(linenum,actposn,false)));
                  End;
                  #75 : Begin{Links}
   {                  SetColor(SLColor);}
                    GetDrawSymbol(linenum,actposn+lasts,true);
                    Repeat
                      dec(actposn);
                      if (actposn<commusicstart(st)) then
                        actposn:=length(st);
                    Until (((UtiComputeGroup(St[actposn],c)<>0) or (c='&')) and
                          (GetDrawSymbol(linenum,actposn,false)));
                  End;{#75}
   {Wenn NumLock off: ----------------------------------------------------------}
                  #82 :Begin{Insert=+1Hz}
                    Inc(addcent);
                    SndUpdateMulCent;
                    IniSpacedText(16,gmaxy div charheight - 1,
                          Copy(sndgetcentstr(addcent),2,19),frLow);
                  End;
                  #83 :Begin{Delete=-1Hz}
                    Dec(Addcent);
                    SndUpdateMulCent;
                    IniSpacedText(16,gmaxy div charheight - 1,
                          Copy(sndgetcentstr(addcent),2,19),frLow);
                  End;
                  #71 :Begin{Home=+10Hz}
                    addcent:=addcent+100;
                    SndUpdateMulCent;
                    IniSpacedText(16,gmaxy div charheight - 1,
                          Copy(sndgetcentstr(addcent),2,19),frLow);
                  End;
                  #79 :Begin{End=-10Hz}
                    addcent:=addcent-100;
                    SndUpdateMulCent;
                    IniSpacedText(16,gmaxy div charheight - 1,
                          Copy(sndgetcentstr(addcent),2,19),frLow);
                  End;
                  #73 :Begin{PageUp=+100Hz}
                    MulCent:=MulCent*2; {Reaktion vorlÑufig:1Oktave hîher}
                    SndUpDateAddCent;
                    IniSpacedText(16,gmaxy div charheight - 1,
                          Copy(sndgetcentstr(addcent),2,19),frLow);
                  End;
                  #81 :Begin{PageDn=-100Hz}
                    Mulcent:=Mulcent/2;
                    SndUpdateAddCent;
                    IniSpacedText(16,gmaxy div charheight - 1,
                          Copy(sndgetcentstr(addcent),2,19),frLow);
                  End;
                  #72 :Begin{CursorUp=}
                  End;
                  #80 :Begin{CusorDn=}
                  End;
   {----------------------------------------------------------------------------}
                  Else
                    c:=#1;
                End;{Case}
              End;{#0}
   (*            #9 : Begin{Tab}
                Inc(symbcount);
              End;*)
              '0' :Begin{.  = round}
                addcent:=100*Round(addcent / 100);
                SndUpdateMulCent;
                IniSpacedText(16,gmaxy div charheight - 1,
                              Copy(sndgetcentstr(addcent),2,19),frLow);
              End;
              '4' :Begin{lf   = -100 cent}
                addcent:=addcent-100;
                SndUpdateMulCent;
                IniSpacedText(16,gmaxy div charheight - 1,
                              Copy(sndgetcentstr(addcent),2,19),frLow);
              End;
              '7' :Begin{hm = /2}
                Mulcent:=Mulcent/2;
                SndUpdateAddCent;
                IniSpacedText(16,gmaxy div charheight - 1,
                              Copy(sndgetcentstr(addcent),2,19),frLow);
              End;
              '1' :Begin{End  = -1 cent}
                Dec(Addcent);
                SndUpdateMulCent;
                IniSpacedText(16,gmaxy div charheight - 1,
                              Copy(sndgetcentstr(addcent),2,19),frLow);
              End;
              '8' :Begin{Up   = +200 cent}
                Addcent:=Addcent+200;
                SndUpdateMulCent;
                st:=sndgetcentstr(addcent);
                IniSpacedText(16,gmaxy div charheight - 1,
                              Copy(sndgetcentstr(addcent),2,19),frLow);
              End;
              '2' :Begin{Dn   = -200 cent}
                addcent:=addcent-200;
                sndUpdateMulCent;
                st:=sndgetcentstr(addcent);
                IniSpacedText(16,gmaxy div charheight - 1,
                              Copy(sndgetcentstr(addcent),2,19),frLow);
              End;
              '3' :Begin{rg   = +1 cent}
                Inc(Addcent);
                SndUpdateMulCent;
                IniSpacedText(16,gmaxy div charheight - 1,
                              Copy(sndgetcentstr(addcent),2,19),frLow);
              End;
              '5' :Begin{m   = reset}
                Addcent:=0;
                Mulcent:=1;
                IniSpacedText(16,gmaxy div charheight - 1,
                              Copy(sndgetcentstr(addcent),2,19),frLow);
              End;
              '6' :Begin{rg   = +100 cent}
                Addcent:=Addcent+100;
                SndUpdateMulCent;
                IniSpacedText(16,gmaxy div charheight - 1,
                              Copy(sndgetcentstr(addcent),2,19),frLow);
              End;
              '9' :Begin{pgup = *2}
                MulCent:=MulCent*2;
                SndUpDateAddCent;
                IniSpacedText(16,gmaxy div charheight - 1,
                              Copy(sndgetcentstr(addcent),2,19),frLow);
              End;
              ' ' : Begin
                IF Paused Then
                  NoSound
                Else IF (Ch<>' ') And (Ch<>'.') and (Ch<>',') Then
                  Sound(Round(sympar[ch,3,i]*mulcent));
                Paused:=Not Paused;
              End;
              #27 : c:=#0;
              #13 : Begin
                NoSound;
                GetDrawSymbol(linenum,actposn+lasts,true);
                ComEdReturn(linenum, actposn, actpost,
                                   false,false);
                SearchFirst(st,linenum,actposn);
              End;
              Else Begin
                c:=#1;
              End;
            End;{Case}
          Until c=#0;
          nosound;
   {        St:=Page[linenum];}
          i:=UtiComputeGroup(St[actposn+lasts],ch);
          GetDrawSymbol(linenum,actposn+lasts,true);
          showmenus:=dummyb;
          PagPutBottomLine;
        repline:=false;
      end;
      99 : {Ctrl F6: search repeat}begin
        dummyb:= Sp2SearchString(linenum, actposn, actpost,
                                 actptr, startptr, lastptr);
        if ((dummyb) and (replaceflag)) then
        begin
           FileChanged:=1;
           Sp2ReplaceString(linenum, actposn, actpost,
                            actptr, startptr, lastptr);
        end;
        repline:=false;
     end;

     100 : {Ctrl-F7: paste line}
           begin
             if SpeSpaceInPage(1) then begin
               SpeLineInsert(linenum, saveln);
               y:= IniYnow(linenum - 6);
               PagRefClearVal(0, y, GetMaxX, grmaxy-1);
               PagCursorLeft(linenum, actposn, actpost);
             end else begin
               HlpHint(HntNotEnoughSpace, HintWaitEsc);
             end;
             repline:=false;
           end;{ctrl f7}

     101 : {Ctrl F8: paste block}
           begin
              FileChanged:=1;
              SpeInsertBuffer(linenum, actposn, actpost, actptr,
                              startptr, lastptr, dummyb);
              PagUnMark;
              repline:=false;
           end;

     102 : {Ctrl F9: Paste Page}
           begin
             filPastePage(actptr, startptr, lastptr);
           end;

     103 : {ctrl F10: Choose Font}
           begin
             FilFontSelect;
             repline:=false;
           end;

    16..50 : {Alt-Character, wandeln in Bereich 128..153}
            begin
              IF KeyResponse=#28 Then Begin
                IF not(shiftp or ctrlp) then begin{Alt-Enter}
                  IF Linenum=1 Then
                    Linenum:=2;
                  For i:=Linenum-1 DownTo 1 Do
                    IF Page[i,1]='T' Then{erste TL oberhalb suchen}
                      break;
                  IF (i=1) And (Page[i,1]<>'T') Then{Unterste TL suchen}
                    For i:=Pagelength DownTo Linenum Do
                      IF Page[i,1]='T' Then
                        Break;
                  IF i<linenum Then Begin{erste NL oberhalb suchen}
                    While (Page[i,1]<>'N') and (i>1) Do
                      Dec(i);
                    if i<=1 Then{keine NL oberhalbƒ>von unten beginnen}
                      i:=pagelength;
                  End;{if i<linenum}
                  IF i>linenum Then Begin{unterste NL suchen}
                    While (Page[i,1]<>'N') And (i>=linenum) Do
                      dec(i);
                  End;{if i>linenum}
                  linenum:=i;
                End Else begin{if not(shiftp or ctrlp)}
                  IF shiftp and (not ctrlp) Then begin{shft-Alt-Enter}
                    if linenum>2 then
                      Dec(linenum,2)
                    else
                      linenum:=pagelength;
                  End Else Begin{if shiftp and not ctrlp}
                    IF ctrlp and (not shiftp) Then Begin{Ctrl-Alt-Enter}
                      if Mstart.MPag<>-1 then begin
                        HlpHint(HntUnMarkBlockFirst, HintWaitEsc);
                        Exit;
                      end;{If Mstart.MPag...}
                      if page[linenum,1]='T' then
                        Exit; { Mit TLs gebe ich mich nicht ab!}
                      l:=linenum;
                      ComSysEnd(l);        { Letzte Zeile des Systems       }
                      ComSysStart(Linenum);{ Erste Zeile des Systems        }

                      { oberste Linie, die noch zu l gehîrt                 }
                      k:=linenum-comskiplinesup(linenum);

                      { i=naechstobere, nichtleere Linie                    }
                      i:=ComPrevLine(k);

                      { ins=Anzahl benîtigter Leerzeilen                    }
                      ins:=ComSpaceBetweenNeed(i,linenum)+ComSpaceBetweenNeed(l,k)+comsysheight(linenum);

                      { ->ins=Anzahl einzuschiebender Leerzeilen            }
                      { insl=Zeilennummer wo die neue Linie eingefÅgt wird  }
                      ins:=ins-comspacebetween(k,i);
                      if ins<0 Then begin
                        ins:=0;
                        insl:=linenum-ComSpaceBetweenNeed(l,linenum)-comsysheight(linenum);
                      end else begin
                        insl:=i+ComSpaceBetweenNeed(i,linenum)+1;
                      end;


                      if ComInsPossible(Ins) Then Begin
                        For x:=1 To Ins Do Begin
                          SpeInsTextLine(k-1, actpost, actptr, startptr,
                                         lastptr, false);
                        End;
                        linenum:=linenum+ins;
                        For x:=0 To (ComSysHeight(Linenum))-1 Do Begin
                          inblock:=copy(page[linenum+x],1,pos('%',page[linenum+x]))+'.1.';
                          page[linenum+x,2]:=' ';
                          If Searchlastchiffre(linenum+x)<>'0' Then{ Beat Åbernehmen }
                            inblock:=inblock+Searchlastchiffre(linenum+x)+'.';{NL einfÅgen}
                          Page[insl+x]:=inblock;
                        End;
                        Linenum:=Insl;
                        ComSysEnd(Linenum);
                        PagRefClearVal(0,       IniYnow(linenum-2),
                                       GetMaxX, GrMaxY-9);
                        PagCursorLeft(linenum, actposn, actpost);
                      End Else Begin
                        HlpHint(HntNotEnoughSpace, HintWaitEsc);
                      End;

                    End;{IF ctrlp and (not shiftp)}
                  End;{IF if shiftp and not ctrlp else}
                End;{if not(shiftp or ctrlp)}
                PagCursorleft(linenum, actposn, actpost);
                LastEntry:= other;
                arrowentry:= noarr;
              End Else Begin{IF KeyResponse=#28}
                FileChanged:=1;
                c:= IniAltChar(KeyResponse);
                ComEdKey(linenum, actposn, actpost,
                         actptr, startptr, lastptr, c, shiftp, ctrlp)
              End;{IF KeyResponse=#28 else}
              IF (linenum<1) or (linenum>pagelength) Then
                linenum:=1;
            end;{case 16..50}
      104 : {Alt F1: Start senkrechte Klammer}
            begin
              if page[linenum,1] = 'T' then begin
                 setcolor(lcolor);
                 FileChanged:=1;
                 TexEdTextLine(linenum, actpost, chr(229));
                 dec(actpost);
                 TexActPosX(x, actpost, linenum, true);
                 inc(Linenum,3);
                 inc(gcycoord,24);
                 while Page[Linenum,1]='N' do begin
                    inc(Linenum);
                    inc(gcycoord,8);
                 end;
              end else if page[linenum,1]='N' then begin
                NotSysStart(linenum);
              end;
              repline:=false;
            end;

      105 : {Alt F2: End senkrechte Klammer}
            begin
              if page[linenum,1] = 'T' then
              begin
                 FileChanged:=1;
                 TexEndVKlammer(linenum, actpost, gcxcoord - char2width);
              end else if page[linenum,1]='N' then begin
                NotSysEnd(linenum);
              end;
              repline:=false;
            end;

      106 : {Alt F3: Start waagrechte Klammer}
            begin
              if page[linenum,1] = 'T' then
              begin
                 FileChanged:=1;
                 TexEdTextLine(linenum, actpost, chr(231));
              end;
        repline:=false;
            end;

      107 : {Alt F4: End waagrechte Klammer}
            begin
              if page[linenum,1] = 'T' then
              begin
                 FileChanged:=1;
                 TexEndHKlammer(linenum, actpost);
              end;
        repline:=false;
            end;

      108 : {Alt F5: vertical line}
            begin
              if page[linenum,1] = 'T' then begin
                FileChanged:=1;
                TexEdTextLine(linenum, actpost, chr(234));
              end;
        repline:=false;
            end;

      109 : {Alt F6: vert. short line}
            begin
              if page[linenum,1] = 'T' then begin
                FileChanged:=1;
                TexEdTextLine(linenum, actpost, chr(236));
              end;
        repline:=false;
            end;

      110 : {Alt F7: horizontal line - full (resp. 3D-Line}
            begin
              if page[linenum,1] = 'T' then
              begin
                FileChanged:=1;
                TexEdTextLine(linenum, actpost, chr(233));
              end;
        repline:=false;
            end;

      111 :{Alt F8: vertical line full (resp. 3D-Line)}
            begin
              if page[linenum,1] = 'T' then
              begin
                FileChanged:=1;
                TexEdTextLine(linenum, actpost, chr(237));
              end;
        repline:=false;
            end;
      112 : {Alt F9: setup page}
            begin
              FileChanged:=1;
              actedit:= actedit + [setuppage];
              IniSwapColors;
              Pagesav:= pagecount;
              PagShowPage(linenum, actposn, actpost,
                          actptr, startptr, lastptr, 0, true);
        repline:=false;
            end;
      113 : {Alt F10: number of page}
            begin
              if page[linenum,1] = 'T' then
              begin
                 FileChanged:=1;
                 TexEdTextLine(linenum, actpost, chr(235));
              end;
            end;
      140 : {Alt F12: ScreenSave} Begin
        SaveScreen;
        PagRefPage;
        repline:=false;
      End;
      117 : {Ctrl End: end of page} begin
        linenum:= pagelength;
        PagCursorLeft(linenum, actposn, actpost);
        repline:=false;
      end;

      115: {Ctrl Left} begin
        if page[linenum,1]='T' Then
          TexWordLeft(Linenum,Actpost);
      end;
      116 : {Ctrl Right} begin
        if page[linenum,1]='T' Then
          TexWordRight(Linenum,Actpost);
      end;
      141 : {Ctrl Up} begin
      end;
      145 : {Ctrl Down} begin
      end;
      118 : {Ctrl PgDn: last page}
            begin
               PagShowPage(linenum, actposn, actpost,
                           actptr, startptr, lastptr, 30002, true);
        repline:=false;
            end;

      119 : {Ctrl Home: begin of page}
            begin
               linenum:= 1;
               PagCursorLeft(linenum, actposn, actpost);
        repline:=false;
            end;

      132 : {Ctrl PgUp: first page}
            begin
               PagShowPage(linenum, actposn, actpost,
                           actptr, startptr, lastptr, 1, true);
        repline:=false;
            end;

      146 : {Ctrl Insert}
            begin
              inbuffer:='';
              if lastbuf=2 then begin
                if delpage then begin
                  FileChanged:=1;
                  filundelpage(actptr, startptr, lastptr);
                end;
              end else if lastbuf=1 then begin
                if mend.mpag<>-1 then begin
                  filbufclear;
                  MarMarkToBuffer(actptr, startptr, lastptr);
                end;
                SpeInsertBuffer(linenum, actposn, actpost, actptr,
                                 startptr, lastptr, dummyb);
                PagUnMark;
                PagRefPage;
                FileChanged:=1;
              end;
              repline:=false;
            end;

      147: {Ctrl Delete}
           begin
             inbuffer:='';
             FileChanged:=1;
             if pagebuf<>-1 then begin
               fildelpage(actptr, startptr, lastptr);
             end else if mstart.mpag<>-1 then begin
               SpeBlockCommands(linenum, actposn, actpost, actptr,
                                startptr, lastptr, 'D');
               PagRefPage;
             end else begin
             end;
             repline:=false;
           end;
    end; {case ord(KeyResponse) of }
    if repline then
      ComLineRep(linenum);
    arrowentry:= noarr;
    if ((ord(KeyResponse) < 16) or (ord(KeyResponse) > 50)) then begin
      LastEntry:= other;
    end;
  end; { if ComSpecGrant }
  nosound;
end; { SPECIALKEY }

Procedure ComSysEnd(Var Linenum : Integer);
Begin
  IF Page[Linenum,1]<>'N' Then
    Exit;
  While (Page[Linenum+1,1]='N') And (Linenum<=Pagelength) Do
    Inc(Linenum);
End;
Procedure ComSysStart(Var Linenum : Integer);
Begin
  IF Page[Linenum,1]<>'N' Then
    Exit;
  While (Page[Linenum-1,1]='N') And (Linenum>0) Do
    Dec(Linenum);
End;

Function ComSysHeight(Linenum : integer) : Integer;
Var i : Integer;
Begin
  i:=1;
  While (Page[Linenum-1,1]='N') And (Linenum>0) Do
    Dec(linenum);
  While (Page[Linenum+i,1]='N') And (Linenum+i<=Pagelength) Do
    Inc(i);
  ComSysHeight:=i;
End;

Function ComSpaceUpNeed(linenum : integer) : Byte;
{ Anzahl der freien linien, die beim einfÅgen einer NL mittel ctrl-enter
  oder ctrl-f3 nach oben benîtigt werden}
Var inblock : stringline;
    lineattr: lineattrtype;
Begin
  IF ComTL(linenum) Then Begin
    ComSpaceUpNeed:=1;
  End Else Begin
    inblock:=page[linenum];
    GetNoteAttributes(inblock,lineattr);
    Case lineattr.linestyle of
      1:{thick}      ComSpaceUpNeed:=2;
      2:{staff}      ComSpaceUpNeed:=4;
      3:{thin}       ComSpaceUpNeed:=2;
      4:{dotted}     ComSpaceUpNeed:=2;
      5:{helpline}   ComSpaceUpNeed:=2;
    End;
  End;
End;
Function ComSpaceDownNeed(linenum : integer) : Byte;
{ Anzahl der freien linien, die beim einfÅgen einer NL mittels ctrl-enter
  oder ctrl-f3 nach unten benîtigt werden}
Var inblock : stringline;
    lineattr: lineattrtype;
Begin
  IF ComTL(linenum) Then Begin
    ComSpaceDownNeed:=1;
  End Else Begin
    inblock:=page[linenum];
    GetNoteAttributes(inblock,lineattr);
    Case lineattr.linestyle of
      1:{thick}      ComSpaceDownNeed:=2;
      2:{staff}      ComSpaceDownNeed:=2;
      3:{thin}       ComSpaceDownNeed:=2;
      4:{dotted}     ComSpaceDownNeed:=2;
      5:{helpline}   ComSpaceDownNeed:=2;
    End;
  End;
End;

Function ComSpaceBetweenNeed(l1,l2 : integer) : Byte;
var s1,s2 : integer;
Begin
  s1:=ComSpaceDownNeed(l1);
  s2:=ComSpaceUpNeed(l2);
  if s1<s2 then
    s1:=s2;
  if comTL(l1) or comTL(l2) then
    dec(s1);
  ComSpaceBetweenNeed:=s1;
End;
Function ComSpaceBetween(l1,l2 : integer) : byte;
Begin
  l1:=abs(l1-l2);
  if l1>1 Then
    ComSpaceBetween:=l1-1
  else
    ComSpaceBetween:=0;
End;
Function ComLinesUpBelong2(linenum : integer) : Byte;
{ Anzahl Linien oberhalb, die zu dieser Linie gehîren (oder umgekehrt...) }
{ NL: 0, TL: 2 }
Var inblock : stringline;
    lineattr: lineattrtype;
Begin
  IF ComTL(linenum) and not comHorLine(linenum) Then    {!!!}
    ComLinesUpBelong2:=2
  Else
    ComlinesUpBelong2:=0;
End;
Function ComLinesDownBelong2(linenum : integer) : Byte;
{ Anzahl der Linien unterhalb, die unabhÑngig von deren Art zu dieser Linie
  gehîren kînnen
  leere TL: 1, benutzte TL: 2, NL: Falls nÑchste Linie auch NL, dann 1,
  sonst je nach Linientyp }
Var inblock : stringline;
    lineattr: lineattrtype;
Begin
  if ComTL(linenum) then Begin
    if ComUsedTL(linenum) Then
      ComLinesDownBelong2:=2
    else
      ComLinesDownBelong2:=1;
  End Else Begin
    if ComNL(linenum+1) Then Begin
      ComLinesDownBelong2:=1;
    End Else Begin
      inblock:=page[linenum];
      GetNoteAttributes(inblock,lineattr);
      Case lineattr.linestyle of
        1:{thick}      ComlinesDownBelong2:=2;
        2:{staff}      ComlinesDownBelong2:=3;
        3:{thin}       ComlinesDownBelong2:=2;
        4:{dotted}     ComlinesDownBelong2:=2;
        5:{helpline}   ComlinesDownBelong2:=2;
      End;
    End;
  End;
End;

Function ComLineBelong2(linenum : integer) : Byte;
{ 0 wenn linenum nicht zur nÑchstoberen Linie gehîrt,
  sonst Anzahl der Linien unterhalb, die zu dieser gehîren kînnen,
  Notenlinie: immer 0,
  tl: 0, falls zuviele Linien oberhalb leer, 1, falls Linie leer, sonst 2}
var i : integer;
Begin
  if comNL(linenum) then begin
    ComLineBelong2:=0;
    exit;
  end;
  For i:=1 to ComLinesUpBelong2(linenum) Do Begin
    if ComUsedL(linenum-i) Then Begin
      ComLineBelong2:=ComLinesDownBelong2(linenum);
      Exit;
    End;
  End;
  ComLineBelong2:=0;
end;
Function comskiplinesDown(linenum : integer) : integer;
{ Anzahl der zu ueberspringenden linien, falls unterhalb eine NL eingefÅgt
  werden soll
  linenum=nummer der NL
  i=zÑhler,b=temp
}
Var i,a,b: integer;
Begin
  i:=1;
  a:=ComLinesDownBelong2(linenum);
  while i<=a do begin
    b:=ComLineBelong2(linenum+i);
    if b=0 Then
      break;
    a:=i+b;
    inc(i);
  end;
  if comNL(linenum+i) then
    dec(i);
  while not comUsedL(linenum+i-1) do
    dec(i);
  comskiplinesdown:=i-1;
End;
Function comskiplinesUp(linenum : integer) : integer;
{ Anzahl der zu ueberspringenden linien
  linenum=nummer der NL
  tx=anzahl der zu beruecksichtigenden linien}
Begin
  if comUsedTL(linenum-1) then
    comskiplinesUp:=1
  else
    comskiplinesUp:=0;
End;
Function ComNL(linenum : integer) : Boolean;
{NL?}
Begin
  ComNL:=page[linenum,1]='N';
End;
Function ComTL(linenum : integer) : Boolean;
{TL?}
Begin
  ComTL:=page[linenum,1]='T';
End;
Function ComUsedTL(linenum : integer) : Boolean;
{ TL & nicht leer}
Begin
  If Page[linenum,1]<>'T' Then Begin
    ComUsedTL:=False;
    Exit;
  End;
  while page[linenum,byte(page[linenum,0])]=' ' do
    dec(byte(page[linenum,0]));
  If Length(Page[linenum])<linemarker then
    ComUsedTL:=False
  Else
    ComUsedTL:=True;
End;
Function ComUsedL(linenum : integer) : Boolean;
Begin
  ComUsedL:=ComNL(linenum) or ComUsedTL(linenum);
End;
Function ComNextLine(linenum : integer) : integer;
Begin
  Repeat
    Inc(linenum);
  Until (Linenum>PageLength) or ComUsedL(linenum);
  ComNextLine:=Linenum;
End;
Function ComPrevLine(linenum : integer) : integer;
Begin
  Repeat
    Dec(linenum);
  Until (linenum=0) Or ComNL(linenum) Or ComUsedTL(linenum);
  ComPrevLine:=Linenum;
End;
Function ComInsPossible(num : integer) : Boolean;
Begin
  if num>pagelength then Begin
    ComInsPossible:=False;
    Exit;
  End;
  dec(num);
  While Num>=0 Do Begin
    if LineUsed(pagelength-Num) Then Begin
      ComInsPossible:=False;
      Exit;
    End;
    dec(num);
  End;
  ComInsPossible:=True;
End;
Function ComMusicStart(inblock : Stringline) : Byte;
{ Data Start }
Begin
  if inblock[1]<>'N' then
    ComMusicStart:=0
  else
    ComMusicStart:=pos('%',inblock)+1;
End;
Function ComStart(inblock : Stringline;actposn : Byte) : Byte;
{ Anfangsposition der Note, auf die actposn zeigt }
Begin
  if actposn>length(inblock) then
    actposn:=length(inblock);
  if inblock[1]<>'N' then
    ComStart:=0
  else Begin
    while (actposn<length(inblock)) and not (inblock[actposn] in notes) do
      inc(actposn);
    while (actposn>0) and (inblock[actposn-1] IN Notes) do
      dec(actposn);
    if actposn>=commusicstart(inblock) Then
      ComStart:=actposn
    else
      comstart:=commusicstart(inblock);
  End;
End;
function ComEnd(inblock : StringLine;Actposn : Byte) : Byte;
{ Ende der Note, auf die actposn zeigt }
Begin
  if inblock[1]<>'N' then
    ComEnd:=0
  else Begin
    while (actposn<length(inblock)) and not (inblock[actposn] in notes) do
      inc(actposn);
    while (actposn<length(inblock)) and (inblock[actposn+1] IN Notes) do
      Inc(actposn);
    if inblock[actposn] in notes then
      ComEnd:=actposn
    else
      comend:=0;
  End;
End;
function ComLen(inblock : StringLine;ActPosn : Byte) : Byte;
Begin
  ComLen:=ComEnd(inblock,actposn)-ComStart(inblock,actposn);
End;

function comnext(inblock : stringline;actposn : Byte) : Byte;
Begin
  actposn:=comend(inblock,actposn)+1;
  if actposn=1 Then
    actposn:=commusicstart(inblock);
  actposn:=comstart(inblock,actposn);
  comnext:=actposn;
End;
function comprev(inblock : stringline;actposn : Byte) : byte;
begin
  actposn:=comstart(inblock,actposn);
  if actposn<commusicstart(inblock)+2 Then
    actposn:=length(inblock)
  else
    dec(actposn,2);
  actposn:=comstart(inblock,actposn);
  comprev:=actposn;
end;
function Searchlastchiffre(linenum : Integer) : String;
var st : String;
    a  : Byte;
const chiffres : Set of Char = ['1','2','3','4','5','6','7','8','9','0'];
begin
   a:=Byte(Page[linenum,0]);
   st:='';
   while (NOT (Page[linenum,a] in chiffres)) and (a<>0) do
      dec(a);
   if a<34 Then Begin
      Searchlastchiffre:='0';
      Exit;
   End;
   while (Page[linenum,a-1] in chiffres) and (a<>0)  do
      dec(a);
   while Page[linenum,a] in chiffres do begin
      st:=st+Page[linenum,a];
      inc(a);
   end;{while}
   Searchlastchiffre:=St;
end;
Function CopyLine(Src,Des : Integer) : Boolean;
Var inblock:stringline;
Begin
  IF (Des>PageLength) Or (Des<1) or (Src>PageLength) Or (Src<1) Then Begin
    HlpHint(HntOutOfRange, HintWaitEsc);
    CopyLine:=False;
    Exit;
  End;
  if page[src]='N' Then begin
    inblock:=copy(page[Src],1,33)+'.';
    If Searchlastchiffre(src)<>'0' Then
      inblock:=inblock+Searchlastchiffre(Src);{NL einfÅgen}
    IF Page[Des,4]<>' ' Then Begin
      HlpHint(HntCopyLineToHeader, HintWaitEsc);
      CopyLine:=False;
      Exit;
    End;
  end{ if page[src]='N'} else begin
    inblock:=page[src];
  end;
  Inblock[4]:=' ';
  CopyLine:=TRUE;
  IF LineUsed(Des) Then begin
    IF SpeSpaceInPage(1) Then begin
      SpeLineInsert(Des, inblock)
    end Else begin
      HlpHint(HntNotEnoughSpace, HintWaitEsc)
    end;
  end Else
    Page[Des]:=inblock;
End;{Func CopyLine}
Function LineUsed(Linenum : Byte) : Boolean;
Begin
   While (Page[Linenum,0]<>#9) And (Page[Linenum,Byte(Page[Linenum,0])]=' ') Do
      Dec(Byte(Page[Linenum,0]));
   IF Page[Linenum,0]>#9 Then
      LineUsed:=True
   Else
      LineUsed:=False;
End;

Function ComHorLine(linenum : integer) : Boolean;
Begin
  ComHorLine:=pos(#233,page[linenum])<>0;
End;
end.