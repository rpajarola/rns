{$I RNS.H}
unit noteunit;

interface

uses
   graph;


Procedure NotEdNoteLine(linenum: integer; var actpos: integer; c : char);
Procedure NotDelNote(linenum: integer; var actpos : integer);
Procedure NotInsNote(linenum : integer; var actpos: integer);
Procedure NotDelToEOL(linenum, actpos: integer);

{ NoteSystem: Linien zusammenfassen }
Procedure NotSysStart(linenum : integer);
Procedure NotSysEnd(linenum : integer);
Function  NotFindSysStart(linenum : integer) : integer;
Function  NotFindSysEnd(linenum : integer) : integer;
Function  NotIsSys(linenum : integer) : char;
Function  NotNextLine(linenum : integer) : integer;
Function  NotPrevLine(linenum : integer) : integer;
implementation

uses pageunit,
     symbols,
     initsc,
     menutyp,
     gcurunit,
     getunit,
     specunit,
     utilunit,
     helpunit,
     crt,
     Comunit,
     Texts;

{******************************************************}
Procedure NotDelToEOL(linenum, actpos: integer);

begin
  inbuffer:='';
  while (not IniNumChar(page[linenum,actpos-1])) do
    dec(actpos);
  Delete(page[linenum],actpos+1,length(page[linenum]));
  page[linenum, actpos]:= '.';
end;
{****************************************************************}
Procedure NotInsNote(linenum : integer; var actpos: integer);
var inblock : stringline;
    i: integer;
begin
  inblock:=page[linenum];
  delete(inblock,1,actpos);
  while ((length(inblock)>0)and(not IniNumchar(inblock[1]))) do
    delete(inblock,1,1);
  i:= IniNextNumber(inblock);
  if i = 0 then i:= 1;
  str(i, inblock);
  inblock:= '.' + inblock;
  UtiCharBegin(page[linenum], actpos);
  insert( inblock, page[linenum], actpos);
  PagRefClearVal(gcxcoord - 25, IniYnow(linenum - 2),
                 GetmaxX, IniYnow(linenum + 1));
end;
{****************************************************************}
Procedure NotDelNote(linenum: integer; var actpos : integer);
var stbuf: string16;
begin
   UtiDelNoteChar(page[linenum], actpos, stbuf);
   UtiDelNumChar(page[linenum], actpos);
   UtiFindCharEnd(page[linenum], actpos);
   PagRefClearVal(gcxcoord - 25, IniYnow(linenum - 2),
                  GetmaxX, IniYnow(linenum + 1));
end;

{****************************************************************}
Procedure NotEdNoteLine(linenum: integer; var actpos: integer; c : char);

var i, j, k, ordc: integer;
    inblock, strbuf: stringline;
    lineattr: lineattrtype;
    x, deltax, clearendx : integer;
    clinemin, clinemax: integer;
    left, moveright, arrow, reallymoveright: boolean;
    indexc: char;
    oldx: integer;
    ref : Byte;
const EdSnd = 50;
    {**********************}
    Procedure NotRemZero;
    begin
        while ((length(inbuffer) > 0) and (inbuffer[1] = '0')) do
        begin
           delete(inbuffer, 1, 1);
        end;
    end;
    {**********************}

const refSmall=0;
      refNormal=1;
      refNoRef=2;

begin
  reallymoveright:=false;
  ref:=refNoRef;
  if (c>='0') and (c<='9') Then
    ref:=1;
  if c='|' Then  {nur bis | eine neue Funktion hat: fak. Beatstrich}
   exit;        {jetzt werden so bedingte Sprungmarken abgefangen, die noch mit | statt › gemacht wurden}
  if c='ı' then
    c:='0';
  if (c=#9) or (c=#15) then begin
    case c of
    #9:inc(symbcount);
    #15:if symbcount>1 then
      dec(symbcount);
    End;
  end else begin
    deltax:= 25; {Default clear region}
    clinemin:= linenum - 3;
    clinemax:= linenum + 1;
    inblock:= page[linenum];
    ordc:= ord(c);
    arrow:= false; {zeigt an ob eine Pfeiltaste gedrÅckt wurde}
    if (charset = 2) then begin
      if (c>='a') and (c<='z') then
        c:=char(byte(c)+31)
      else if (c>='A') and (c<='Z') then
        c:=char(byte(c)+32)
      else if (c>=#128) and (c<=#153) then
        c:= char(byte(c) - 63);
    end; {if charset = 2 then}
    { ' ' '.' ',' rotieren }
    if (blankset>=0) and (blankset<=2) then begin
      case c of
        ' ': c:=keyswap[blankset,0];
        ',': c:=keyswap[blankset,1];
        '.': c:=keyswap[blankset,2];
      end;
    end;
{    if blankset=2 then begin
      if c=' ' then
        c:=','
      else if c=',' then
        c:=' ';
    end;}
    x:= gcxcoord;
    oldx:=x;
    k:= UtiComputeGroup(c, indexc);
    clearendx:=x+25;
    if (not(IniNumChar(c) or IniArrow(c) or IniDoppel(c))) then begin
      if ordc=8 then begin {BS}
        inbuffer:='';
        inblock:=page[linenum];
        GetNoteBlock(inblock, lineattr, linenum);
        x:=gcxcoord-1;
        GetNotePosX(x,actpos,linenum,true,true);
        UtiDelNoteChar(page[linenum],actpos,strbuf);
        UtiDelNumChar(page[linenum],actpos);
        clearendx:= GetMaxX;
        ref:=refNormal;
      end else {if ordc = 8 then} begin
        if (length(page[linenum]) + length(inbuffer)) < stlength then begin
          if (linestyles in actedit) then c:= '.';
          if (actpos<length(page[linenum])) or (x>=grmaxx) then
            ref:=refNormal
          else
            ref:=refSmall;
          { check if ()[] is valid }
          case c of
            '(','[':begin
              for i:=actpos downto 1 do begin
                if (page[linenum,i]=')')or(page[linenum,i]=']') then
                  break;
                if (page[linenum,i]='(')or(page[linenum,i]='[') then begin
                  HlpHint(HntCloseBracketFirst,HintNormalTime);
                  exit;{not allowed!!!}
                end;
                if (page[linenum,i]='%') then
                  break;
              end;
            end;{'(','['}
            ')':begin
              for i:=actpos downto 1 do begin
                if (page[linenum,i]='(') then
                  break;
                if (page[linenum,i]='(')or(page[linenum,i]='[')or
                   (page[linenum,i]=']') then begin
                  HlpHint(HntOpenBracketFirst,HintNormalTime);
                  exit;{not allowed!!!}
                end;
              end;
            end;{')'}
            ']':begin
              for i:=actpos downto 1 do begin
                if (page[linenum,i]='[') then
                  break;
                if (page[linenum,i]='(')or(page[linenum,i]='[')or
                   (page[linenum,i]=')') then begin
                  HlpHint(HntOpenBracketFirst,HintNormalTime);
                  exit;{not allowed!!!}
                end;
              end;
            end;{']'}
            '.':begin
              UtiDelNoteChar(page[linenum], actpos, strbuf);
              i:=length(strbuf);
              if (i>=2) and ((strbuf[i-1]='=')or(strbuf[i-1]='*')) then
                strbuf:=strbuf+'.'
              else
                strbuf:='.';
              inbuffer:=strbuf;
              Insert(strbuf,page[linenum],actpos);
              reallymoveright:=true;
              c:=#255;
            end;{'.'}
          end;{case c of}
          { ganzes Zeichen aus page[linenum] lîschen und in strbuf kopieren }
          UtiDelNoteChar(page[linenum], actpos, strbuf);
          {Zeichen nur Åberschreiben, wenn neues vollstÑndiges
           Zeichen Åber ein altes geschrieben wird}
           {???}
          if ((not UtiCharReady(strbuf,#255))and(strbuf<>'')) or
             ((manset=2)and(c in flamset)) then
            inbuffer:= strbuf;
          { repetitionszeichen}
          if c='"' then begin
            if pos('"',copy(page[linenum],actpos,length(page[linenum])-actpos))<>0 then
              clearendx:=getmaxx;
            moveright:=true;
            if strbuf[1]='"' then begin
            {" schon vorhanden->wegnehmen}
              if length(strbuf)>1 then
                inbuffer:=copy(strbuf,2,length(strbuf)-1)
              else
                inbuffer:='';
              if length(strbuf)>1 then
                c:=#255
              else
                c:='.';
            end else
              inbuffer:=strbuf;
          { add oder replace }
          end else if (UtiReplaceChars(c)>0) or (reallymoveright) then
            moveright:= true
          else begin
            moveright:= false;
            if not (c in flamset) then
              inbuffer:= strbuf;
          end;

          if UtiCharReady(inbuffer,c) then begin
            Insert(inbuffer,page[linenum],actpos);
            i:=actpos;
            UtiFindCharEnd(page[linenum],i);
            if i=length(page[linenum]) then begin
              UtiGetActDistance(page[linenum], actpos, strbuf);
              page[linenum]:= page[linenum] + strbuf + '.';
            end;
            if moveright then
              SpeNoteRight(linenum, actpos);
            inbuffer:='';
          end else
            Insert(inbuffer,page[linenum],actpos);
          {Spielen der Note}
          if dispsound = 1 then begin
            if (k > 0) then begin
              sound(sympar[indexc, 3, k]);
              delay(EdSnd);
              nosound;
            end;
          end;
        end else {if (length(page[linenum]...}
          HlpHint(HntTooManyChars, HintWaitEsc)
      end;{ else if ordc=8}
    end else{if (not(IniNumChar(c)...}begin
      if UtiNumReady(inbuffer, c) then begin
        if not IniArrow(inbuffer[1]) then begin
          x:= gcxcoord - 1;
          GetNotePosX(x, i, linenum, false, true);
          if x < gcxcoord then begin
            NotRemZero;
            if(length(page[linenum])+length(inbuffer))<stlength then begin
              if not ((actpos=length(page[linenum]))and
                     (ininumchar(page[linenum,actpos])))then begin
                UtiCharBegin(page[linenum], actpos);
              end;
              while IniNumChar(page[linenum,actpos - 1]) do begin
                Dec(Actpos);
              end;
              UtiDelNumChar(page[linenum], actpos);
              {Fuege neue(n) Character ein}
              if (Length(page[linenum]) <= StLength) then begin
                insert(inbuffer, page[linenum], actpos);
                i:= Length(page[linenum]);
                if IniNumChar(inblock[i]) then
                  inblock:= inblock + '$';
              end;
              SpeNoteRight(linenum, actpos);
              GetClearLines(linenum, clinemin, clinemax);
            end; {if (length(page[linenum]) + length(inbuffer)) }
          end else{if x < gcxcoord}begin
            HlpHint(HntOutOfView, HintWaitEsc);
          end;
        end else {not IniArrow(inbuffer[1])} begin
          arrow:= true;
          left:= (inbuffer[1] = '<');
          delete(inbuffer, 1, 1);
          if IniDoppel(inbuffer[1]) Then Begin
            j:=actpos;
            IF Left Then Begin
              UtiCharBegin(page[linenum], actpos);
              while IniNumChar(page[linenum,actpos - 1]) do begin
                Dec(actpos);
              end;
            End Else Begin
              UtiFindCharEnd(Page[linenum],actpos);
            End;
            Val(Copy(inbuffer,2,length(inbuffer)-1),i,k);
            Str(i*UtiGetNum(Page[linenum],actpos),inbuffer);
            if inbuffer='0' Then Begin
              Inbuffer:='';
              Exit;
            end;
            actpos:=j;
          End;
          NotRemZero;
          UtiNextNum(page[linenum], actpos, i, left);
          if i = 0 then begin
            if ((not left)and((Length(page[linenum])+length(inbuffer))
                 <StLength))then begin
              page[linenum]:= page[linenum] + inbuffer + '.';
            end;
          end else{ if i = 0 then }begin
            Val(inbuffer, j, k);
            if ((j mod i) <> 0) then begin
              Str(j, HintS1);
              Str(i, HintS2);
              HlpHint(HntDivNotPossible, HintWaitEsc);
            end else { if (j mod i) <> 0 then } begin
              k:= j div i;
              {Abstand k mal einfuegen}
              if left then begin
                while IniNumChar(page[linenum, actpos - 1]) do begin
                  actpos:= actpos - 1;
                end;
              end else { if left then }begin
                actpos:= actpos + 1;
              end; { else if left then }
              if (length(page[linenum]) + k*(length(inbuffer) + 1)
                  < stlength) then begin
                UtiDelNumChar(page[linenum], actpos);
                insert(inbuffer, page[linenum], actpos);
                for i:= 1 to k - 1 do begin
                  insert(inbuffer + '.', page[linenum], actpos);
                end;
                GetClearLines(linenum, clinemin, clinemax);
              end else begin
                hlphint(HntTooManyChars,HintWaitEsc);
              end;
            end; { else if (j mod i) <> 0 then }
          end; { else if i = 0 then }
          IF Left Then
            ComEdArrow(movement(left),linenum, actpos, actpos)
          Else if Byte(page[linenum,0])-actpos-2>=Byte(inbuffer[0]) Then
            ComEdArrow(movement(right),linenum, actpos, actpos);
          GetLine(linenum, grminx);
          ref:=refNoRef;
        end; {else not IniArrow(inbuffer[1])}
        clearendx:= gmaxx;
        inbuffer:= '';
        if not arrow then begin
          x:= x + 1;
          GetNotePosX(x , actpos, linenum, true, false);
        end;
      end{if UtiNumReady(inbuffer, c) then}else
      Clearendx:=oldx - deltax;
    end;{else if (not IniNumChar(c) and (gcxcoord > 15)) }
    if actpos=length(page[linenum]) then begin{am Ende des Strings?}
      if (gcxcoord=InilineEnd(Page[linenum])) and (x<>gcxcoord) then begin
        if (((sndwarning-1) and 1)=1) then{und am Ende der Zeile?}
          IniLineEndSound(0)
      end {if gcx...}else if (gcxcoord=grmaxx) then begin
        if (((sndwarning-1) and 2)=2) then{oder am Ende des Bildschirms?}
          IniLineEndSound(1);
      end;{if gcx... else}
    end;
    if oldx>x then oldx:=x;
    if oldx>grmaxx then oldx:=grmaxx;
    if ref=refSmall Then
      deltax:=4;
    inblock:=page[linenum];
    GetNoteAttributes(inblock,lineattr);
    i:=Inifirstbeatpos(lineattr);
    if (c='.') and (clearendx<i) then
      clearendx:=i;
    IF ref<>refNoRef Then Begin
      if (linenum<48)  then
         PagRefClearVal(oldx - deltax, IniYnow(clinemin-3),
                        clearendx, IniYnow(clinemax +3))
      else
         PagRefClearVal(oldx - deltax, IniYnow(clinemin-3),
                        clearendx, iniynow(pagelength))
    End;
  end;
end;

{****************************************************************}
Procedure NotSysStart(linenum : integer);
begin
  if page[linenum,2]='S' then
    page[linenum,2]:=' '
  else
    page[linenum,2]:='S';{*S*tart}
  PagRefClearVal(0,IniYNow(linenum-1),3,IniYNow(NotFindSysEnd(linenum)+1));
end;
{****************************************************************}
Procedure NotSysEnd(linenum : integer);
begin
  if page[linenum,2]='E' then
    page[linenum,2]:=' '
  else
    page[linenum,2]:='E';{*E*nd}
  PagRefClearVal(0,IniYNow(NotFindSysStart(linenum)-1),3,IniYNow(linenum+1));
end;

{****************************************************************}
Function NotFindSysStart(linenum : integer) : integer;
var i : integer;
Begin
  For i:=linenum-1 downto 1 do
    if page[i,1]='N' then
      if (page[i,2]='S') or (page[i,2]='E') then
        break;
  if page[i,2]<>'S' then
    i:=linenum;
  NotFindSysStart:=i;
End;

{****************************************************************}
Function NotFindSysEnd(linenum : integer) : integer;
Var i : integer;
Begin
  for i:=linenum+1 to pagelength do
    if page[i,1]='N' then
      if (page[i,2]='S') or (page[i,2]='E') then
        break;
  if page[i,2]<>'E' then
    i:=linenum;
  NotFindSysEnd:=i;
End;
{****************************************************************}
Function  NotIsSys(linenum : integer) : char;
begin
  NotIsSys:=page[linenum,2];
end;
{****************************************************************}
Function  NotNextLine(linenum : integer) : integer;
var i : integer;
begin
  for i:=linenum+1 to pagelength do
    if page[i,1]='N' then
      break;
  if (i>pagelength) or (page[i,1]<>'N') then
    i:=linenum;
  NotNextLine:=i;
end;
{****************************************************************}
Function  NotPrevLine(linenum : integer) : integer;
var i : integer;
begin
  for i:=linenum-1 downto 1 do
    if page[i,1]='N' then
      break;
  if page[i,1]<>'N' then
    i:=linenum;
  NotPrevLine:=i;
end;
end.
