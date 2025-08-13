unit utilunit;

interface

uses
   initsc,
   gcurunit,
   menutyp,
   graph;

Procedure UtiDelNoteChar(var inblock: stringline; var actpos: integer;
                         var stbuf: string16);
Procedure UtiDelNumChar(var inblock: stringline; var actpos : integer);
Function UtiGetNum(inblock: stringline; actpos : integer) : Integer;
Procedure UtiCharBegin(var inblock: stringline; var actpos : integer);
Procedure UtiFindCharEnd(var inblock: stringline; var actpos : integer);
Procedure UtiComputeDxDy(inblock: stringline; var dx, dy: integer;
                         charnum: byte; flamchar: char);
Procedure UtiKlammerZuPos(c: char; var dx: integer; flamchar : char);
Procedure UtiKlammerAufPos(inblock: stringline; var dx, height: integer; flamchar : char);
Procedure UtiNextNum(var inblock: stringline; var actpos, numres : integer;
                     left : boolean);
Function UtiComputeGroup(c:char; var indexc: char) : integer;
Function UtiCharReady(var inblock: string16; c:char): boolean;
Function UtiNumReady(var inblock: string16; c:char): boolean;
Procedure UtiGetActDistance(var inblock: stringline; actpos: integer;
                            var strbuf: string16);
Function UtiReplaceChars(inblock: stringline): byte;
Function UtiCheckFlam(var inblock: stringline; actpos: integer): char;
Function UtiNextChar(inblock : stringline;c : char;p : integer) : integer;
implementation

Uses HelpUnit,
     Texts;
{**************************************************************}
Function UtiComputeGroup(c:char; var indexc: char) : integer;
{Wird 1 fuer Kleinbuchstaben
      2 fuer shift
      3 fuer alt
      4 fuer &
      0 sonst
      indexc wird die Grundform von c}
var i: integer;
begin
  i:= 0;
  indexc:= c;
  case c of
    'a'..'z' : begin
      i:= 1;
    end;
    'A'..'Z' : begin
      i:= 2;
      indexc:= char(byte(c)+32);
    end;
    #128..#153 : begin
      i:= 3;
      indexc:= char(byte(c)-31);
    end;
  end;
  UtiComputeGroup:=i;
end;

{****************************************************************}
Function UtiFlamPos(inblock: string16): byte;
{Setzt sich auf den Index des Flamchars, wenn einer in inblock ist}

var i: byte;

begin
   i:= Pos('+', inblock);
   if i = 0 then i:= Pos('=', inblock);
   if i = 0 then i:= Pos('-', inblock);
   if i = 0 then i:= Pos('*', inblock);
   UtiFlamPos:= i;
end;

{****************************************************************}
Function UtiReplaceChars(inblock: stringline): byte;
{Zaehlt die Anzahl Replace-Character in inblock}
var i, j, k: byte;
    indexc,c: char;
begin
  i:=0;
  for j:=1 to length(inblock) do begin
    c:=inblock[j];
    k:=UtiComputeGroup(c,indexc);
    if ((k>0)and(sympar[indexc,2,k]=1)and(manset=1))or
       ((k=0)and(c<>'\')and(c<>'Ý')and(c in spec))  then
      inc(i);
  end;
  UtiReplaceChars:=i;
end;

{****************************************************************}
Function UtiCharReady(var inblock: string16; c:char): boolean;
{gibt das Zeichen c in den Buffer inblock und wird true,
 wenn dadurch das gesamte Zeichen fertig ist}
var i, j, k: byte;
    indexc: char;
    a       : byte;
begin
  if ((ininumchar(inblock[1])) or
     (IniArrow(inblock[1]))) then
    inblock:= '';
{Zeichenbuffer voll, oder add-Zeichen schon vorhanden?}
  if length(inblock) = 16 then
    c:=#255;
  k:=UtiComputeGroup(c,indexc);
  if ((k>0) and (sympar[indexc,2,k]=2)and(pos(c,inblock)>0)) then
    c:=#255;
  if c<>#255 then begin
  {-------------------------------------------------------------------------}
    if inblock='' then
      inblock:=c
    else begin
    { Klammern }
      a:=length(inblock);
      case c of
        '(','[':begin
          if manset=2 then begin
          { add mode }
            inblock:=inblock+c;
          end else begin
          { replace mode }
            i:=pos('=',inblock);
            j:=pos('*',inblock);
            if i<j then
              i:=j;
            j:=pos('+',inblock);
            if i<j then
              i:=j;
            j:=pos('-',inblock);
            if i<j then
              i:=j;
            if (i=0) then begin
              inblock:=c+inblock;
            end else begin
              if i<=(a-2) then
                insert(c,inblock,i+1)
              else
                inblock:=inblock+c;
            end;
          end;
        end;
        ')':begin
          if inblock[a]='(' then
            HlpHint(HntEmptyBracket,HintNormalTime)
          else
            inblock:=inblock+c;
        end;
        ']':begin
          if inblock[a]='[' then
            HlpHint(HntEmptyBracket,HintNormalTime)
          else
            inblock:=inblock+c;
        end;
        '{':begin
          a:=pos('=',inblock);
          if (pos('{',inblock)=0) and (a<>0) then
            Insert('{',inblock,a+1);
        end;
        '}':begin
          a:=pos('=',inblock);
          if (pos('}',inblock)=0) and (a<>0) then begin
            if length(inblock)>=a then
              inc(a);
            if (pos('{',inblock)<>0) and (length(inblock)>=a) then
              inc(a);
            if UtiComputeGroup(inblock[a], indexc)<>0 then
              inc(a);
            Insert(c,inblock,a);
          end else
            inblock:=inblock+'}';
        end;
        else{case} if IniPrintNote(c) then begin
          if ((k>0)and(sympar[indexc,2,k]=1)) then
            inblock:=inblock+c
          else
            inblock:=c+inblock;
        end{IniPrintNote(c)} else if c in FlamSet then
          inblock:=inblock+c;
      end;{case}
    end;{inblock='' else }
  {-------------------------------------------------------------------------}
  end;{c<>#255}
  {pruefen ob Zeichen fertig}
  UtiCharReady:=((UtiReplaceChars(inblock)=1)and(UtiFlamPos(inblock)=0))
              or (UtiReplaceChars(inblock)=2);
end;

{****************************************************************}
Function UtiNumReady(var inblock: string16; c:char): boolean;
{gibt das Zeichen c in den Buffer inblock und wird true,
 wenn dadurch eine Abstandseingabe fertig ist}
var i, j : byte;
    strbuf: string16;
begin
   if (Not(IniNumchar(inblock[1])Or IniArrow(inblock[1])))Then
     inblock:='';
   {Zeichen eingeben}
   if (inblock<>'')and(IniArrow(c)) then
     inblock:='';
   inblock:=inblock+c;
   {pruefen ob Zeichen fertig}
   strbuf:=inblock;
   if IniArrow(inblock[1]) then begin
     Delete(strbuf, 1, 1);
     if IniDoppel(strbuf[1]) Then
       Delete(strbuf,1,1);
   end;
   if (((strbuf[1] = '0') and (length(strbuf) = 3) and (strbuf[2] > '0')) or
    {  ((strbuf[1] = '0') and (length(strbuf) = 5) and (strbuf[2] = '0')) or}
    {  fr 00100 bis 00999, Anzeige funktioniert aber falsch: pageunit.pas 329}
       ((strbuf[1] >= '1') and (strbuf[1] <= '9'))) then
     UtiNumReady:= true
   else
     UtiNumReady:= false;
end;

{****************************************************************}
Function UtiCheckFlam(var inblock: stringline; actpos: integer): char;
{wird +,-,=,* wenn der actuelle character ein Flam enth„lt}
var i: integer;
    c: char;
begin
  c:=' ';
  while (actpos>1) and (not IniNumChar(inblock[actpos-1])) do
    dec(actpos);
  while (length(inblock)>actpos) and
        (not IniNumChar(inblock[actpos])) do begin
    if (inblock[actpos] in flamset) then
      c:=inblock[actpos];
    inc(actpos);
  end;
  UtiCheckFlam:=c;
end;

{****************************************************************}
Procedure UtiComputeDxDy(inblock: stringline; var dx, dy: integer;
                         charnum: byte; flamchar: char);
{berechnet dx und dy, je nach der Gr”sse der folgenden Zeichen}
Const DXDYTab : Array[0..2,0..4] of record
        dx,dy : integer
      end =
(((dx:- 7;dy:- 7),          { - } { 'a'..'z' }
  (dx:+ 7;dy:- 7),          { + }
  (dx:  0;dy:-14),          { = }
  (dx:  0;dy:+16),          { * }
  (dx:  0;dy:  0)),         {   }

 ((dx:-10;dy:-10),          { - } { 'A'..'Z' }
  (dx:+10;dy:-10),          { + }
  (dx:  0;dy:-14),          { = }
  (dx:  0;dy:+16),          { * }
  (dx:  0;dy:  0)),         {   }

 ((dx:- 5;dy:- 5),          { - } { alt-a..alt-z }
  (dx:+ 5;dy:- 5),          { + }
  (dx:  0;dy:-14),          { = }
  (dx:  0;dy:+16),          { * }
  (dx:  0;dy:  0)));        {   }
Var Size,Flam : Byte;
    c         : char;
begin
  if charnum>length(inblock) then
    c:='a'
  else
    c:=inblock[charnum];
  if (c in klammerset) and (charnum<length(inblock)) then
    c:=inblock[charnum+1];
  if (c<='z')and(c>='a') then
    Size:=0
  else if (c<='Z')and(c>='A') then
    Size:=1
  else if (length(inblock)<charnum)or(charnum=0) or (c in flamset) or (ininumchar(c)) then
    Size:=0
  else
    Size:=2;
  case flamchar of
    '-': Flam:=0;
    '+': Flam:=1;
    '=': Flam:=2;
    '*': Flam:=3;
    else Flam:=4;
  end;
  dx:=DXDYTab[Size,Flam].dx;
  dy:=DXDYTab[Size,Flam].dy;
end;

{****************************************************************}
Procedure UtiKlammerZuPos(c: char; var dx: integer; flamchar : char);
var dy: integer;
    i: byte;
    inblock: stringline;
begin
  inblock:= c;
  UtiComputeDxDy(inblock, dx, dy, 1, '+');
   case flamchar of
    '-':;
    '+':dx:=2*dx;
    '=':;
    '*':;
  end;
end;

{****************************************************************}
Procedure UtiKlammerAufPos(inblock: stringline; var dx, height: integer;flamchar : char);
{berechnet die Position fr die Klammer}
var hy       : integer;
begin
  height:=5;
  UtiComputeDxDy(inblock, dx, hy, 2, '-');
  case flamchar of
    '-':dx:=2*dx;
    '+':;
    '=':;
    '*':;
  end;
end;

{****************************************************************}
Procedure UtiDelNoteChar(var inblock: stringline; var actpos: integer;
                         var stbuf: string16);
{L”scht einen Character bis zum n„chsten numerischen Character,
 der gel”schte Character kommt in den Buffer stbuf}
var i : integer;
begin
  stbuf:='';
  inc(actpos);
  while (inblock[actpos-1]<>'%')and(not IniNumChar(inblock[actpos-1])) do
    dec(actpos);
  i:=0;
  while (actpos+i<=length(inblock))and (not IniNumChar(inblock[actpos+i])) do
    inc(i);
  if i<>0 then begin
    stbuf:=copy(inblock,actpos,i);
    delete(inblock,actpos,i);
  end else
    stbuf:='';
{  while (not IniNumChar(inblock[actpos]))and(length(inblock)>=actpos) do begin
    stbuf:= stbuf + inblock[actpos];
    delete(inblock, actpos, 1);
  end;}
  if actpos>length(inblock) then begin
    actpos:=length(inblock)+1;
    UtiGetActDistance(inblock,actpos,stbuf);
    inblock:=inblock+stbuf+'.';
  end else if inblock[actpos] = '%' then
    inblock:=inblock+'.1.';
end;

{****************************************************************}
Procedure UtiGetActDistance(var inblock: stringline; actpos: integer;
                            var strbuf: string16);
{Berechnet von actpos aus rueckwaerts die Distanz}
begin
  strbuf:='';
  dec(actpos);
  while (inblock[actpos]<>'%')and(IniNumChar(inblock[actpos])) do begin
    strbuf:=inblock[actpos]+strbuf;
    dec(actpos);
  end;
  if strbuf='' then
    strbuf:='1';
end;
{****************************************************************}
Procedure UtiDelNumChar(var inblock: stringline; var actpos : integer);
{L”scht numerische Zeichen bis zum n„chsten nichtnumerischen Character}
var i : integer;
begin
  i:=0;
  while (actpos+i<=length(inblock))and(IniNumChar(inblock[actpos+i])) do
    inc(i);
  delete(inblock, actpos, i);
  if actpos>length(inblock) then inblock:=inblock+'.';
end;

{****************************************************************}
Function UtiGetNum(inblock: stringline; actpos : integer) : Integer;
Var St : String;
    I  : Integer;
    c : integer;
begin
   St:='';
   InBlock:=copy(inblock,actpos,10);
   While (Not IniNumChar(inblock[1])) And (inblock[0]<>#0) Do
     Delete(inblock,1,1);
   While IniNumChar(inblock[1]) and (inblock[0]<>#0 )Do Begin
     St:=St+Inblock[1];
     Delete(inblock,1,1);
   End;
   IF inblock[0]=#0 Then Begin
     UtiGetNum:=0;
     Exit;
   End;
   Val(St,i,c);
   UtiGetNum:=i;
end;

{****************************************************************}
Procedure UtiCharBegin(var inblock: stringline; var actpos : integer);
{sucht den Beginn des Notenzeichens in Inblock
 an der Stelle actpos}
begin
  while (inblock[actpos-1]<>'%')and(not IniNumchar(inblock[actpos-1])) do
    dec(actpos);
end;

{****************************************************************}
Procedure UtiFindCharEnd(var inblock: stringline; var actpos : integer);
{sucht das Ende des Notenzeichens in Inblock
 an der Stelle actpos}
begin
  while (actpos<length(inblock))and(not IniNumChar(inblock[actpos+1])) do
    inc(actpos);
end;

{****************************************************************}
Procedure UtiNextNum(var inblock: stringline; var actpos, numres : integer;
                     left : boolean);
{sucht den n„chsten numerischen String in inblock, beginnend bei
 actpos, nach rechts oder links (links: left = true).
 numres wird der Wert des Strings. Actpos wird unmittelbar vor
 das numerische Zeichen gesetzt}

var numstr: string16;
    i: byte;
    code: integer;

begin
   numres:= 0;
   numstr:= '0';
   if left then
   begin
      UtiCharBegin(inblock, actpos);
      if IniNumChar(inblock[actpos - 1]) then
      begin
         i:= actpos - 1;
         while IniNumChar(inblock[i - 1]) do
         begin
            i:= i - 1;
         end;
         numstr:= Copy(inblock, i, actpos - i);
      end;
   end
   else
   begin
      UtiFindCharEnd(inblock, actpos);
      if length(inblock) > actpos then
      begin
         i:= actpos + 1;
         while IniNumChar(inblock[i + 1]) do
         begin
            i:= i + 1;
         end;
         numstr:= Copy(inblock, actpos + 1, i - actpos);
      end;
   end;
   Val(numstr, numres, code);
end;

Function UtiNextChar(inblock : stringline;c : char;p : integer) : integer;
var i: integer;
Begin
  for i:=p+1 to length(inblock) do
    if inblock[i]=c then
      break;
  if inblock[i]=c then
    UtiNextChar:=i
  else
    UtiNextChar:=0;
End;
Function UtiPrevChar(inblock : stringline;c : char;p : integer) : integer;
var i: integer;
Begin
  for i:=p-1 downto 1 do
    if inblock[i]=c then
      break;
  if inblock[i]=c then
    UtiPrevChar:=i
  else
    UtiPrevChar:=0;
End;

end.
