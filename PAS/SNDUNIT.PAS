{$Q-}
unit sndunit;

interface

Uses initsc;

Procedure SndSoundMenu(var linenum, actposn, actpost: integer;
                       var actptr, startptr, lastptr: listptr;
                       Menu : boolean);
Procedure SndPlaySound(var linenum, actposn, actpost: integer;
                       var actptr, startptr, lastptr: listptr;
                       Menu : boolean;var Playnext : Boolean);

Procedure SndUpdateAddCent;
Procedure SndUpdateMulCent;
Function SndGetCentStr(C : Integer) : String;

implementation

Uses
   imenuunit,
   getunit,
   pageunit,
   menutyp,
   graphmenu,
   crt,
   xcrt,
   helpunit,
   utilunit,
   fileunit,
   graph,
   DOS,
   gcurunit,
   comunit,
   Texts,
   Mousdrv,
   Specunit,
   MarkUnit;

const cfllength = 30;
      itemmax = 10;

{type itemcharstyp = array[1..itemmax, 0..1] of integer;}
type itemcharstyp = array[1..itemmax] of record
       length,pitch : integer;
     end;
const  M = 1731.23404905852;

{******************************************************************}

Procedure SndUpdateAddCent;
Begin
  {$R-}
  if mulcent>0 Then
     AddCent := Round((ln(mulcent)*M));
  if addcent>{7973}6000 Then Begin
    addcent:=6000;
    mulCent:=(exp(AddCent/M));
  End;
  if addcent<-6000 Then Begin
    addcent:=-6000;
    mulCent:=(exp(AddCent/M));
  End;
  {$IFNDEF USER}
  {$R+}
  {$ENDIF}
End;
{******************************************************************}

Procedure SndUpdateMulCent;
Begin
  {$R-}
  mulCent:=(exp(AddCent/M));
  if mulcent>32.0 then begin
    mulcent:=32;
    AddCent := 6000;
  end;
  if mulcent<0.03125 then begin
    mulcent:=0.03125;
    AddCent :=-6000;
  end;
  {$IFNDEF USER}
  {$R+}
  {$ENDIF}
End;

{******************************************************************}
Procedure SndDraw(var slinexmin, slinexmax, y: longint;var wait : boolean);
var sslinexmin,sslinexmax : integer;
begin
   sslinexmax:=slinexmax;
   sslinexmin:=slinexmax;
   if slinexmax>638 Then
     slinexmax:=638;
   if wait then begin
     Line(slinexmin, y, slinexmax, y);
     Line(slinexmin, y + 1, slinexmax, y + 1);
   end;
   slinexmin:=sslinexmin;
   slinexmax:=sslinexmax;
end;

{******************************************************************}
Procedure SndPlay(var itemchars: itemcharstyp;
                  itemcount, timemax: integer;Var wait : Boolean;Playlast : boolean);
var item, totlength, i: integer;
    r: real;
    getfreq, idel, isnd: integer;
    mintime : integer;
    def     : integer;

Procedure XSound(v : integer;m : real);
begin
{$R-}
  if v<>sndbeat then
    sound(round(v*m))
  else
    sound(v);
{$IFNDEF USER}
{$R+}
{$ENDIF}
end;
const flamlength=20;
begin
  if not wait then
    exit;
  if itemcount<1 then begin
    delay(timemax);
    exit;
  end;
  playlast:=((soundattr and saLegato)<>0);
  totlength:= 0;
  if (soundattr and saStaccato)<>0 then begin
    lastsound:=0;
    playlast:=false;
    for i:=1 to itemcount do
      if itemchars[i].length>staccatolength then
        itemchars[i].length:=staccatolength;
  end;
  if (soundchange and saMuffled)<>0 then begin
    lastsound:=0;
    playlast:=false;
    for i:=1 to itemcount do
      if itemchars[i].length>muffledlength then
        itemchars[i].length:=muffledlength;
  end;
  { count total length }
  for item:=1 to itemcount-1 do begin
    if itemchars[item].length>flamlength then
      itemchars[item].length:=flamlength;
    totlength:=totlength+itemchars[item].length;
  end;
  totlength:=totlength+itemchars[itemcount].length;
  { ... & correct }
  if totlength > timemax then begin
    i:=0;
    for item:= 1 to itemcount do begin
      r:=(itemchars[item].length/totlength);
      itemchars[item].length:= round(r*timemax);
      i:= i + itemchars[item].length;
    end;
    totlength:= i;
  end;
  { set mintime }
  mintime:=flamlength*2;
  def:=0;
  if (itemcount>0)and(mintime>(totlength/itemcount)) then
    mintime:=trunc(totlength/itemcount);
  { ...& apply }
  for item:=1 to itemcount do begin
    if itemchars[item].length<mintime then begin
      def:=def+mintime-itemchars[item].length;
      itemchars[item].length:=mintime;
    end;
  end;
  if def>0 then begin
    r:=def;
    def:=round(r/itemcount);
    for item:=1 to itemcount do begin
      dec(itemchars[item].length,def);
      r:=r-def;
    end;
    itemchars[item].length:=itemchars[item].length-round(r);
  end;
  { play it }
  totlength:=0;
  for item:= 1 to itemcount - 1 do begin
    isnd:= itemchars[item].pitch;
    idel:= itemchars[item].length;
    totlength:=totlength+idel;
    if ((idel > 0) and (isnd > 0)) then begin
    {$R-}
      NoSound;
{      Sound(Round(isnd*MulCent));}
      XSound(isnd,MulCent);
      if wait then
        Delay(idel);
    end;
  end;
  if itemcount > 0 then begin
    isnd:= itemchars[itemcount].pitch;
    idel:= itemchars[itemcount].length;
    totlength:=totlength+idel;
    if ((idel > 0) and (isnd > 0)) then begin
    {$R-}
      NoSound;
{      Sound(Round(isnd*MulCent));}
      XSound(isnd,MulCent);
    {$IFNDEF USER}
    {$R+}
    {$ENDIF}
      if wait then
        Delay(idel);
      if ((soundattr and saStaccato)<>0) and (not playlast) then
        NoSound;
    end;
    IF (idel > 1) and (isnd > 1) and (not playlast) then
      NoSound
    else
      if lastsound<>0 then
{        sound(Round(lastsound*MulCent))}
        XSound(lastsound,MulCent)
      else
        nosound;
    if wait and (timemax>totlength) then
      delay(timemax - totlength);
  end else if wait then begin
    if playlast and (lastsound<>0) then
{      sound(Round(lastsound*MulCent))}
      XSound(lastsound,MulCent)

    else
      nosound;
    Delay(timemax);
  end;
End;

{******************************************************************}
Procedure SndPlayLine(inblock: stringline; var linenum: integer;
                      drawline: boolean;Var playnext : Boolean;Var C : Char;
                      Var SaveSndChar : Char);
{spielt die Zeile inblock}

const itemmax = 10;

var lineattr: lineattrtype;
    itemchars,saveitemchars: itemcharstyp;
    itemcount,saveitemcount: integer;
    imenubkcolor: integer;
    i,j, blength: integer;
    timemax: integer;
    indexc, flam: char;
    k: byte;
    found: boolean;
    dx, slinexmin, slinexmax, y: longint;
    rlinexmax, rtime, rlength: real;
    actlength: integer;
    InpC : Char;
    temp1,temp2 : Boolean;
    st : String;
    SChanged:Boolean;
    SaveInblock:String;
    saveslinexmin,Saveslinexmax,SaveY : longint;
    auftakt : Boolean;
    wait,ok : Boolean;
    orginblock: String;
    parentheses : integer;
    brackets    : integer;
    braces      : integer;
    playlast    : boolean;
    leaveout    : integer;
    restsndchar : boolean;
    repeatchar  : boolean;
    {******************************************************************}
    Procedure SndUpdateSndlength(sndlengthspm : real;
                                 var sndlength,actlength : integer;
                                 Sndlengthper : Byte);
    Var St : String;
    Begin
       sndlength:=Round(60000/sndlengthspm);
       if sndlengthper = 1 then begin
         actlength:=sndlength;
       end else
         actlength:=sndlength div lineattr.beats;
       Str(sndlengthspm:4:3,st);
       while st[0]<#8 do
         st:=' '+st;
       IniSpacedText(65,gmaxy div charheight - 3, st,frNoFrame);
    End;
    {**************************************}
    Procedure SndIncItemCount;

    begin
       if itemcount < itemmax then
       begin
          itemcount:= itemcount + 1;
       end;
    end;

    {**************************************}
    Procedure SndProcItem;
    var a,b : integer;
    begin
       k:=UtiComputeGroup(inblock[1], indexc);
       { normal sound? }
       if ((k > 0) and (sympar[indexc, 3, k] > 0)) then begin
         wait:=True;                 { ^frequenz}
       { yes }
         found:= true;
         if (((playOptions and poParentheses)=0) or (parentheses<=0)) and
            (((playOptions and poBrackets)  <>0) or (brackets   <=0)) and
            (leaveout<>1) then begin
           SndIncItemCount;
           itemchars[itemcount].pitch:= paggetfreq(inblock[1]);{sympar[indexc, 3, k];}
           if flam <> ' ' then begin
             itemchars[itemcount].length:= cfllength;
             flam:= ' ';
           end else begin
             itemchars[itemcount].length:= sympar[indexc, 4, k];
           end;
           lastsound:=itemchars[itemcount].pitch;
       { something special }
         end else if ((sndplaypulse and plPulse)<>0) and
           ((blength>0)or(sndplaybeat=PlayBeatNever)or
           ((sndplaybeat=PlayBeatEmpty)And(itemcount=1))) then begin
           SndIncItemCount;
           itemchars[itemcount].pitch:= sndpulse;
           itemchars[itemcount].length:= sndpulselength;
         end;
         if leaveout>0 then
           dec(leaveout);
       end else { if (k > 0) then } begin
         case inblock[1] of
           '/': begin
             inblock:= '';
           end;
           'Ý': Begin
             if ((playOptions and poDashSlash)=0) then begin
               if slinexmin<IniFirstBeatPos(lineattr) Then Begin
                 wait:=False;
               End Else if auftakt Then Begin
                 if ((sndchar='L') and (c<>#27)) then
                   inblock:='';
               End Else if Not ((sndchar='L') and (c<>#27)) Then begin
                 k:=length(orginblock)-length(inblock);
                 for a:=commusicStart(orginblock) to k do
                   if UtiComputeGroup(orginblock[a],indexc)<>0 then
                     inblock:='';
               End;
             End;
           end;
           '\': Begin
            {if auftakt Then Begin}
               if Not ((sndchar='L') and (c<>#27)) Then begin
                 k:=length(orginblock)-length(inblock);
                 for a:=commusicStart(orginblock) to k do
                   if UtiComputeGroup(orginblock[a],indexc)<>0 then
                     inblock:='';
               End;
            {End;}
           end;
           ',': begin
{             playlast:=false;
             lastsound:=0;}
             if leaveout>0 then
               dec(leaveout);
             if (sndplaypulse and plPulse)<>0 then begin
               found:=true;
               SndIncItemCount;
               itemchars[itemcount].pitch:= sndpulse;
               itemchars[itemcount].length:= sndpulselength;
             end else begin
               found:=true;
             end;
           end;
           ' ': begin
             playlast:=false;
             lastsound:=0;
               nosound;
             if leaveout>0 then
               dec(leaveout);
             if (sndplaypulse and plSpace)<>0 then begin
               found:=true;
               SndIncItemCount;
               itemchars[itemcount].pitch:= sndpulse;
               itemchars[itemcount].length:= sndpulselength;
               playlast:=true;
             end else begin
               found:=true;
               playlast:=false;
             end;
           end;
           '+','-': begin
             flam:= '-';
           end;
           '=': begin
             if (braces>0) or (inblock[2]='{') then begin
               if (playOptions and poBraces)<>0 then begin
                 leaveout:=2
               end else begin
                 leaveout:=1;
               end;
             end else
               flam:= '-';
           end;
           '(': begin
             inc(parentheses);
           end;
           ')': begin
             dec(parentheses);
           end;
           '[': begin
             inc(brackets);
           end;
           ']': begin
             dec(brackets);
           end;
           '{': begin
             inc(braces);
           end;
           '}': begin
             dec(braces);
           end;
           '.': Begin
             if leaveout>0 then
               dec(leaveout);
             if slinexmin<IniFirstBeatPos(lineattr) Then Begin
               k:=1;
               while (inblock[k]='.') or IniNumChar(inblock[k]) do
                 Inc(k);
               if inblock[k]='Ý' then
                 wait:=False;
             end;
           End;
           '&': Begin
             if saveitemcount>itemmax then
               saveitemcount:=itemmax;
             for b:=1 to saveitemcount do begin
               if (saveitemchars[b].pitch=sndbeat) and
                  ((saveitemchars[b].length=5)or(saveitemchars[b].length=sndbeatlength)) then
                 continue;
               itemchars[itemcount+1].pitch:=saveitemchars[b].pitch;
               itemchars[itemcount+1].length:=saveitemchars[b].length;
               SndIncItemCount;
             end;
             repeatchar:=true;
{             while(not ininumchar(inblock[1])) do
               delete(inblock,1,1);
             exit;}
           End;
         end; {case inblock[1]}
       end; {else if (k > 0) then }
       delete(inblock, 1, 1);
    end;

    {*************************************}
    Procedure SndProcBeat;
    { correct rounding errors }
    begin
    { time max=available time for next sound, blength=elapsed time, actlength=length of beat }
      timemax:= timemax + actlength - blength;
      if timemax<0 Then
        timemax:=0;
    end;
    {*************************************}
    Procedure SndAddBeat;
    { check if beat should be played and add a beat sound if approp.}
    begin
      if wait then begin
        if ((sndplaybeat<>playBeatNever)) and
           ((sndplaybeat=PlayBeatAlways) or (blength>actlength) or
             (inblock[1]=' ')or(inblock[1]=',')or(inblock[1]='.')) then begin
          if (inblock[1]='.')or(inblock[1]=',')or(blength>actlength)then
            playlast:=true;
          SndIncItemCount;
          itemchars[itemcount].pitch:= sndbeat;
          if playlast and ((soundattr and saLegato)<>0) then
            itemchars[itemcount].length:= 5
          else
            itemchars[itemcount].length:= sndbeatlength;
        end;
{      if (inblock[1]='.')or(inblock[1]=',')or(blength>actlength)then
        playlast:=true;
      if wait then begin
        if ((sndplaybeat<>playBeatNever)) and
           ((sndplaybeat=PlayBeatAlways) or (blength>actlength) or
             (inblock[1]=' ')or(inblock[1]=',')or(inblock[1]='.')) then begin
          SndIncItemCount;
          itemchars[itemcount].pitch:= sndbeat;
          if playlast and ((soundattr and saLegato)<>0) then
            itemchars[itemcount].length:= 5
          else
            itemchars[itemcount].length:= sndbeatlength;
        end;}
      end;
      { make sure the beat won't eat up the next ones time }
      rlength:= rlength-actlength;
      blength:= round(rlength);
    end;
    {**************************************}
    Procedure SndDrawPlay;
    begin
      repeatchar:=false;
      slinexmin:= slinexmax;
      rlinexmax:= rlinexmax + (dx * timemax)/(actlength);
      slinexmax:= round(rlinexmax);
      {Testen ob innerhalb der sichtbaren Seite}
      if slinexmin < (IniLineEnd(orginblock)) then begin
        playlast:=playlast or (inblock[1]='.') or (inblock[1]=',');
        SndPlay(itemchars, itemcount, timemax,wait,playlast);
        PlayLast:=false;
        if slinexmin<IniFirstBeatPos(lineattr) Then
          Auftakt:=True;
        if drawline {And (Not Paused) }then begin
          SndDraw(slinexmin, slinexmax, y,wait);
        end;
      End;
      itemcount:= 0;
    end;
    {**************************************}

begin
   repeatchar:=false;
   restsndchar:=false;
   lastsound:=0;
   parentheses:=0;
   brackets:=0;
   braces:=0;
   leaveout:=0;
   OrgInblock:=Inblock;
   auftakt:=False;
   Wait:=True;
   if ((inblock[1] = 'N') and (inblock[5] <> 'H') and (inblock[0] > #35)) then begin
      savey:=0;
      PlaySuccess:=True;
      rlength:= 0;
      flam:= ' ';

      GetNoteAttributes(inblock, lineattr);
      dx:= IniDxValue(lineattr);
      slinexmin:= IniFirstBeatPos(lineattr) - dx;
      slinexmax:= slinexmin;
      rlinexmax:= slinexmax;
      if sndlengthper = 1 then begin
         actlength:=sndlength;
      end else begin
         actlength:=sndlength div lineattr.beats;
      end;
      y:= IniYNow(linenum);
      while inblock[1] <> '%' do begin
         delete(inblock, 1, 1);
      end;
{      auftakt:=copy(inblock,1,3)<>'%.1';}
      delete(inblock, 1, 1);

      {Suche Beginn: 1. Beat oder 1. Vorschlag}
      found:= false;
      itemcount:= 0;
      playnext:=false;
{      i:=imenubkcolor;
      imenubkcolor:=alarmcolor;   funktioniert nicht!!!}
      IniSpacedText(20,gmaxy div charheight - 1,sndgetcentstr(addcent),frLow);
{      imenubkcolor:=i; }
      if (length(inblock)>0) and (not (ininumchar(inblock[1]) or
                                      (inblock[1]='.') )) then begin
        blength:=0;
        SndAddBeat;
        rlength:=0;
        blength:=0;
      end;

      while ((not found) and (length(inblock) > 0)) do begin
         playlast:=false;
         saveinblock:=inblock;
         SChanged:=False;
         While xKeyPressed Do Begin
            InpC:=XReadKey(temp1, temp2);
            Case UpCase(InpC) Of
               #27 : begin
                  if not temp2 then begin
                     c:=#27;
                     PlayNext:=False;
                     if not temp1 Then Begin
                        SndUpdateSndLength(sndlengthspm,sndlength,actlength,sndlengthper);
                        nosound;
                        Exit;
                     End else
                        if not paused Then Begin
                           i:=imenubkcolor;
                           imenubkcolor:=alarmbkcolor;
                           IniSpacedText( 2,gmaxy div charheight - 1,
                                          '  Finishing line ',frLow);
                           imenubkcolor:=i;
                        End else
                           c:=#0;
                  end;
               end;
               #13 : begin{Enter}
                  IniSpacedText( 12,gmaxy div charheight - 5,
                                'pause  ',frNoFrame);
                  c:=#27;
                  PlayNext:=True;
                  Inc(Linenum);
                  paused:=False;
                  nosound;
                  Exit;
               End;{Case InpC Of #13}

               #10 : begin {Ctrl-Enter}
                     {spiele Linie zu Ende bevor n„chste gespielt wird}
                  IniSpacedText( 12,gmaxy div charheight - 5,
                                'pause  ',frNoFrame);
                  SndUpdateSndLength(sndlengthspm,sndlength,actlength,sndlengthper);
                  PlayNext:=True;
                  Inc(Linenum);
                  paused:=False;
                  nosound;
                  sndchar:='P';
                  restsndchar:=true;
               end;


               '-' : begin
                 if temp1 And (Not Temp2) Then Begin{Shft}
                   if sndlengthspm<=12 Then
                      sndlengthspm:=2;
                   if sndlengthspm>12 Then
                      sndlengthspm:=sndlengthspm-10;
                 End Else
                   if not (Temp1 or Temp2) Then {Normal}
                     if sndlengthspm>=2 Then
                        sndlengthspm:=sndlengthspm-1;
                     if sndlengthspm<2 Then
                        sndlengthspm:=2;
                 SChanged:=True;
               end;{case inpC OF '-'}
               '+' : begin
                  if temp1 And (Not Temp2) Then begin{Shft}
                     if sndlengthspm<=(SndMaxSpm-10) Then
                        sndlengthspm:=sndlengthspm+10;
                     if (sndlengthspm+10)>SndMaxSpm Then
                        sndlengthspm:=SndMaxSpm;
                  End Else
                     if not (Temp1 or Temp2) Then {Normal}
                        if sndlengthspm<=SndMaxSpm-1 then
                           sndlengthspm:=sndlengthspm+1;
                        if sndlengthspm>(SndMaxSpm-1) Then
                           sndlengthspm:=SndMaxSpm;
                  SChanged:=True;
               end;
               #0 : Begin{Ctrl-/Alt- [+/-]}
                  Case XReadKey(Temp1,Temp2) OF
                     #28  :{Alt-Enter} Begin
                       if not(Temp1 or Temp2) and (c<>#27) then begin{Alt-Enter}
                         i:=Linenum;
                         ComSysStart(i);
                         i:=SpePrevNotLine(i);
                         IF i=0 Then Begin
                           nosound;
                           Exit;
                         End;{ if i=0}
                         ComSysStart(i);
                         linenum:=i;
                         if linenum>1 Then
                           dec(linenum);
                         PlayNext:=True;
                         paused:=false;
                         c:=#27;
                         nosound;
                         Exit;
                       End{if not temp1 or temp2}
                     End;{#28}
                     #82 :begin{Insert}
                        sndlengthspm:=Round(sndlengthspm);
                        SChanged:=True;
                     end;
                     #78  :{Alt +}
                        if (Sndlengthspm*1.33333{1.5})<=SndMaxSpm Then
                           Sndlengthspm:=(Sndlengthspm*1.33333{1.5});
                     #144 :{Ctrl +}
                        if sndlengthspm<=SndMaxSpm SHR 1 then
                           sndlengthspm:=sndlengthspm*2;
                     #74  :{Alt -}
                        if (Sndlengthspm)>=2*1.33333{1.5} Then
                           Sndlengthspm:=(Sndlengthspm/1.33333{1.5});
                     #142 :{Ctrl -}
                        if sndlengthspm>=4 Then
                           sndlengthspm:=sndlengthspm /2;
                  End;
                  SChanged:=True;
               End;
               ' ' : begin
                  Paused:=Not Paused;
                  nosound;
                  IF Paused Then Begin
                     IniSpacedText( 12,gmaxy div charheight - 5,
                                   'play   ',frNoFrame);
                     IniSpacedText( 2,gmaxy div charheight - 1,
                                   ' =Symbol '+#26+'=step ',frHigh);
                  End Else Begin
                     IniSpacedText( 12,gmaxy div charheight - 5,
                                   'pause  ',frNoFrame);
                     IniSpacedText( 2,gmaxy div charheight - 1,
                                   ' Esc = stop end ',frHigh);

                     saveslinexmin:= saveslinexmax;
                  End;
            end;
            '/': Begin
               IF Sndlengthper=1 Then
                  if sndlengthspm / lineattr.beats >= 2 {and <=SndMaxSpm} then Begin
                     sndlengthper:=2;
                     sndlengthspm:=(sndlengthspm / lineattr.beats);
                     IniSpacedText(76,gmaxy div charheight - 3,'LPM',frNoFrame);
                     SChanged:=True;
                  end else begin
                     IniSpacedText(65,gmaxy div charheight - 3,
                     ' raise  ',frNoFrame);
                  end;
               End;
               '*': Begin
                  IF Sndlengthper<>1 Then
                     if sndlengthspm * lineattr.beats <= SndMaxSpm then Begin
                        sndlengthper:=1;
                        sndlengthspm:=(sndlengthspm * lineattr.beats);
                        IniSpacedText(76,gmaxy div charheight - 3,'BPM',frNoFrame);
                        SChanged:=True;
                  {  end; }
                     end else begin
                        IniSpacedText(65,gmaxy div charheight - 3,
                        ' lower  ',frNoFrame);
                     end;
               end;
               '.': Begin  {or Del, wenn NumLock off}
                  sndlengthspm:=Round(sndlengthspm);
                  SChanged:=True;
               end;
               '0' :Begin{.    = round}
                 addcent:=100*Round(addcent / 100);
                 SndUpdateMulCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '4' :Begin{Dn   = -100 cent}
                 addcent:=addcent-100;
                 sndUpdateMulCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '7' :Begin{Home  = /2}
                 Mulcent:=Mulcent/2;
                 SndUpdateAddCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '1' :Begin{End   = -1 cent}
                 Dec(Addcent);
                 SndUpdateMulCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '8' :Begin{Up   = +200 cent}
                 Addcent:=Addcent+200;
                 SndUpdateMulCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '2' :Begin{Dn   = -200 cent}
                 addcent:=addcent-200;
                 sndUpdateMulCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '3' :Begin{PgDn   = +1 cent}
                 Inc(Addcent);
                 SndUpdateMulCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '5' :Begin{m   = reset}
                 Addcent:=0;
                 Mulcent:=1;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '6' :Begin{rg   = +100 cent}
                 Addcent:=Addcent+100;
                 SndUpdateMulCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '9' :Begin{pgup = *2}
                 MulCent:=MulCent*2;
                 SndUpDateAddCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               'B' :Begin
                 SndPlayBeat:=SndPlayBeat Mod 3+1;
                 IniDrawSoundState;
               End;
               'T' :Begin
                 if (SndPlayPulse And plPulse)=2 then
                   SndPlayPulse:=SndPlayPulse And (Not 3)
                 else
                   Inc(SndPlayPulse);
                 IniDrawSoundState;
               End;
               'P' :Begin
                 SndPlayPulse:=SndPlayPulse xor plspace;
                 IniDrawSoundState;
               End;
               'L' :Begin
                 soundattr:=(soundattr xor saLegato) and saLegato;
                 IniDrawSoundState;
               End;
               'S' :Begin
                 soundattr:=(soundattr xor saStaccato) and saStaccato;
                 IniDrawSoundState;
               end;
               'R' :begin
                 soundchange:=(soundchange xor saRhythm) {and saRhythm};
                 IniDrawSoundState;
               end;
(*             'Y' :begin
                 soundattr:=(soundattr xor saYFreq) and saYFreq;
               end;                                                   *)
(*             'P' :begin
                 soundattr:=(soundattr xor saPitch) and saPitch;
               end;                                                   *)
(*             'I' :begin
                 soundattr:=(soundattr xor saInterval) and saInterval;
               end;                                                   *)
               'M' :begin
                 soundchange:=(soundchange xor saMuffled) {and saMuffled};
                 IniDrawSoundState;
               end;
               '%' :begin
                 soundchange:=(soundchange xor saPhrased) {and saPhrased};
                 IniDrawSoundState;
               end;
               '(',')':begin
                 PlayOptions:=PlayOptions xor poParentheses;
                 IniDrawSoundState;
               end;
               '[',']':begin
                 PlayOptions:=PlayOptions xor poBrackets;
                 IniDrawSoundState;
               end;
               '{','}':begin
                 PlayOptions:=PlayOptions xor poBraces;
                 IniDrawSoundState;
               end;
               'Ý' :begin
                 PlayOptions:=PlayOptions xor poDashSlash;
                 IniDrawSoundState;
               end;
{Wenn NumLock off: ---------------------------------------------------------}
(* 1              #71 :Begin{Home=+1Hz}
                 MulCent:=MulCent*2; {Reaktion vorl„ufig:+1Oktave}
                 SndUpDateAddCent;
                 st:=sndgetcentstr(addcent);          IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End; *)
{---------------------------------------------------------------------------}

           End;{Case}
         End;{While XKeyPressed}
         IF SChanged Then Begin
            SndUpDateSndLength(sndlengthspm,sndlength,actlength,sndlengthper);
         End;
         IF IniMausEscape=#27 Then Begin
           c:=#27;
           PlayNext:=False;
           nosound;
           Exit;
         End;
         if IniNumChar(inblock[1]) then begin
           rtime:=actlength/IniNextNumber(inblock);
           timemax:=round(rtime);
           if timemax<0 Then
             timemax:=0;

(*           rtime:=0;
           ok:=false;
           repeat
             if IniNumChar(inblock[1]) then begin
               rtime:=rtime+(actlength/IniNextNumber(inblock));
             end else begin
               if (inblock[1]='.')or((inblock[1]=',')and
               ( ((SndPlayPulse and plpulse)=plPulseNever) or
                (((SndPlayPulse and plpulse)=plPulseNoLeg)And((soundattr and saLegato)<>0))))then
{               if (inblock[1]='.')or((inblock[1]=',')and((SndPlayPulse and plpulse)<>plPulseAlways)) then}
                 delete(inblock,1,1)
               else
                 ok:=true;
             end;
           until ok or (length(inblock)=0);*)

            timemax:=round(rtime);
            if timemax<0 Then
              timemax:=0;
            rlength:= rlength + rtime;
            blength:= round(rlength);
            if blength > actlength then
               SndProcBeat;
            rlinexmax:= rlinexmax + (dx * rtime)/actlength;
            slinexmax:= round(rlinexmax);
            if blength >= actlength then begin
              found:= true;
              SndAddBeat;
            end;
         end else begin
            SndProcItem;
         end;
      end; {while ((not found) and (length(inblock) > 0))}

      while length(inblock) > 0 do
      begin
         SChanged:=False;
         IF Paused and IniNumChar(inblock[1]) Then Begin
            Repeat
               InpC:=XReadKey(temp1,temp2);
               Case UpCase(InpC) OF
                  #27 : begin
                     if not temp2 then begin
                        c:=#27;
                        PlayNext:=False;
                        IF Not temp1 Then Begin
                           SndUpDateSndLength(sndlengthspm,sndlength,actlength,sndlengthper);
                           nosound;
                           Exit;
                        End else
                           if not paused Then Begin
                              i:=imenubkcolor;
                              imenubkcolor:=alarmbkcolor;
                              IniSpacedText( 2,gmaxy div charheight - 1,
                                             '  Finishing line ',frHigh);
                              imenubkcolor:=i;
                           End else
                              c:=#0;
                     end;{if not temp2}
                  end;{case inpC OF #27}
                  #13 : begin{Enter}
                     c:=#27;
                     PlayNext:=True;
                     Inc(Linenum);
                     paused:=false;
                     IniSpacedText( 12,gmaxy div charheight - 5,
                                   'pause  ',frNoFrame);
                     SndUpDateSndLength(sndlengthspm,sndlength,actlength,sndlengthper);
                     nosound;
                     Exit;
                  End;{Case InpC Of #13}

                  #10 : begin {Ctrl-Enter}
                     {spiele Linie zu Ende bevor n„chste gespielt wird}
                  IniSpacedText( 12,gmaxy div charheight - 5,
                                'pause  ',frNoFrame);
                  SndUpdateSndLength(sndlengthspm,sndlength,actlength,sndlengthper);
                  PlayNext:=True;
                  Inc(Linenum);
                  paused:=False;
                  nosound;
                  sndchar:='P';
                  restsndchar:=true;
                  end;


                  '-' : begin
                    if temp1 And (Not Temp2) Then Begin{Shft}
                      if sndlengthspm<=12 Then
                         sndlengthspm:=2;
                      if sndlengthspm>12 Then
                         sndlengthspm:=sndlengthspm-10;
                    End Else
                      if not (Temp1 or Temp2) Then {Normal}
                        if sndlengthspm>=2 Then
                           sndlengthspm:=sndlengthspm-1;
                        if sndlengthspm<2 Then
                           sndlengthspm:=2;
                    SChanged:=True;
                  end;{case inpC OF '-'}
                  '+' : begin
                    if temp1 And (Not Temp2) Then begin{Shft}
                      if sndlengthspm<=(SndMaxSpm-10) Then
                         sndlengthspm:=sndlengthspm+10;
                      if (sndlengthspm+10)>SndMaxSpm Then
                          sndlengthspm:=SndMaxSpm;
                    End Else
                      if not (Temp1 or Temp2) Then {Normal}
                        if sndlengthspm<=SndMaxSpm-1 then
                           sndlengthspm:=sndlengthspm+1;
                        if sndlengthspm>(SndMaxSpm-1) Then
                           sndlengthspm:=SndMaxSpm;
                    SChanged:=True;
                  end;{case inpC OF '+'}
                  #0 : Begin{Ctrl-/Alt- [+/-]}
                     Case XReadKey(Temp1,Temp2) OF
                       #28  :{Alt-Enter} Begin
                         if not(Temp1 or Temp2) and (c<>#27) then begin{Alt-Enter}
{                           PagRefClearVal(0,     IniYnow(linenum)-1,
                                          gmaxX, IniYnow(linenum));}
                           i:=Linenum;
                           ComSysStart(i);
                           i:=SpePrevNotLine(i);
                           IF i=0 Then Begin
                             nosound;
                             Exit;
                           End;{ if i=0}
                           ComSysStart(i);
                           linenum:=i;
                           PlayNext:=True;
                           paused:=false;
                           c:=#27;
                           if linenum>1 Then
                             dec(linenum);
                           nosound;
                           Exit;
                         End{if not temp1 or temp2}
                       End;{#28}
                       #82 :begin{Insert}
                         sndlengthspm:=Round(sndlengthspm);
                         if sndlengthper = 1 then begin
                           actlength:=sndlength;
                         end else
                           actlength:=sndlength div lineattr.beats;
                         SChanged:=True;
                       end;
                       #78  :{Alt +}
                         if (Sndlengthspm*1.33333{1.5})<=SndMaxSpm Then
                           Sndlengthspm:=(Sndlengthspm*1.33333{1.5});
                       #144 :{Ctrl +}
                         if sndlengthspm<=SndMaxSpm SHR 1 then
                           sndlengthspm:=sndlengthspm*2;
                       #74  :{Alt -}
                          if (Sndlengthspm)>=2*1.33333{1.5} Then
                            Sndlengthspm:=(Sndlengthspm/1.33333{1.5});
                       #142 :{Ctrl -}
                          if sndlengthspm>=4 Then
                            sndlengthspm:=sndlengthspm /2;
                       #98:begin{ctrl F5}
                        {$R-}
                          sound(Round(itemchars[itemcount].pitch*MulCent));
                           {$IFNDEF USER}
                           {$R+}
                           {$ENDIF}
                          Repeat
                          Until XKeyPressed;
                          NoSound;
                          InpC:=XReadKey(Temp1,Temp2);
                        End;
                       #77:Begin{right}
                          Inpc:=#9;
                        End;
                       #72:begin{up}
                          Repeat
                            Case UpCase(InpC) OF
                              '0' :Begin{.  = round}
                                addcent:=100*Round(addcent / 100);
                                SndUpdateMulCent;
                                st:=sndgetcentstr(addcent);
                                IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
                              End;
                              '4' :Begin{lf   = -100 cent}
                                addcent:=addcent-100;
                                sndUpdateMulCent;
                                st:=sndgetcentstr(addcent);
                                IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
                              End;
                              '7' :Begin{Home = /2}
                                Mulcent:=Mulcent/2;
                                SndUpdateAddCent;
                                st:=sndgetcentstr(addcent);
                                IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
                              End;
                              '1' :Begin{End   = -1 cent}
                                Dec(Addcent);
                                SndUpdateMulCent;
                                st:=sndgetcentstr(addcent);
                                IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
                              End;
                              '8' :Begin{Up   = +200 cent}
                                Addcent:=Addcent+200;
                                SndUpdateMulCent;
                                st:=sndgetcentstr(addcent);
                                IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
                              End;
                              '2' :Begin{Dn   = -200 cent}
                                addcent:=addcent-200;
                                sndUpdateMulCent;
                                st:=sndgetcentstr(addcent);
                                IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
                              End;
                              '3' :Begin{PgDn   = +1 cent}
                                Inc(Addcent);
                                SndUpdateMulCent;
                                st:=sndgetcentstr(addcent);
                                IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
                              End;
                              '5' :Begin{m   = reset}
                                Addcent:=0;
                                Mulcent:=1;
                                st:=sndgetcentstr(addcent);
                                IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
                              End;
                              '6' :Begin{rg   = +100 cent}
                                Addcent:=Addcent+100;
                                SndUpdateMulCent;
                                st:=sndgetcentstr(addcent);
                                IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
                              End;
                              '9' :Begin{pgup = *2}
                                MulCent:=MulCent*2;
                                SndUpDateAddCent;
                                st:=sndgetcentstr(addcent);
                                IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
                              End;
                              'B' :Begin
                                SndPlayBeat:=SndPlayBeat Mod 3+1;
                                IniDrawSoundState;
                              End;
                              'T' :Begin
                                if (SndPlayPulse And plPulse)=2 then
                                  SndPlayPulse:=SndPlayPulse And (Not 3)
                                else
                                  Inc(SndPlayPulse);
                                IniDrawSoundState;
                              End;
                              'P' :Begin
                                SndPlayPulse:=SndPlayPulse xor plspace;
                                IniDrawSoundState;
                              End;
                              'L' :Begin
                                soundattr:=(soundattr xor saLegato) and saLegato;
                                IniDrawSoundState;
                              End;
                              'S' :Begin
                                soundattr:=(soundattr xor saStaccato) and saStaccato;
                                IniDrawSoundState;
                              end;
                              'R' :begin
                                soundchange:=(soundchange xor saRhythm) {and saRhythm};
                                IniDrawSoundState;
                              end;
(*                            'I' :begin
                              soundattr:=(soundattr xor saIncipit) and saIncipit;
                              end;  *)
                              'M' :begin
                              soundchange:=(soundchange xor saMuffled) {and saMuffled};
                                IniDrawSoundState;
                              end;
                              '%' :begin
                                soundchange:=(soundchange xor saPhrased) {and saPhrased};
                                IniDrawSoundState;
                              end;
                              '(',')':begin
                                PlayOptions:=PlayOptions xor poParentheses;
                                IniDrawSoundState;
                              end;
                              '[',']':begin
                                PlayOptions:=PlayOptions xor poBrackets;
                                IniDrawSoundState;
                              end;
                              '{','}':begin
                                PlayOptions:=PlayOptions xor poBraces;
                                IniDrawSoundState;
                              end;
                              'Ý' :begin
                                PlayOptions:=PlayOptions xor poDashSlash;
                                IniDrawSoundState;
                              end;
(*                           '/' :begin
                               PlayOptions:=PlayOptions xor poSlash;
                             end;*)
{Wenn NumLock off: ---------------------------------------------------------}
(* 2              #71 :Begin{Home=+1Hz}
                 MulCent:=MulCent*2; {Reaktion vorl„ufig:+1Oktave}
                 SndUpDateAddCent;
                 st:=sndgetcentstr(addcent);          IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;    *)
{---------------------------------------------------------------------------}
                            End;
                            {$R-}
                            sound(Round(LastSound*MulCent));
                            {$IFNDEF USER}
                            {$R+}
                            {$ENDIF}
                            InpC:=XReadKey(temp1,temp2);
                          Until (InpC<'0') Or (InpC>'9');
                          IF InpC=#0 Then Begin
                            IF XReadKey(temp1,temp2)<>#77 Then
                               NoSound;
                          End Else
                            NoSound;
                       End;
                     End;{Case XReadKey OF}
                     SChanged:=True;
                  End;{{case inpC OF #0}
               '/': Begin
                  IF Sndlengthper=1 Then
                     if sndlengthspm / lineattr.beats >= 2 {and <=SndMaxSpm} then Begin
                        sndlengthper:=2;
                        sndlengthspm:=(sndlengthspm / lineattr.beats);
                        IniSpacedText(76,gmaxy div charheight - 3,'LPM',frNoFrame);
                        SChanged:=True;
                     end else begin
                        IniSpacedText(65,gmaxy div charheight - 3,
                        ' raise  ',frNoFrame);
                     end;
                  End;
                  '*': Begin
                     IF Sndlengthper<>1 Then
                        if sndlengthspm * lineattr.beats <= SndMaxSpm then Begin
                           sndlengthper:=1;
                           sndlengthspm:=(sndlengthspm * lineattr.beats);
                           IniSpacedText(76,gmaxy div charheight - 3,'BPM',frNoFrame);
                           SChanged:=True;
                        end else begin
                           IniSpacedText(65,gmaxy div charheight - 3,
                           ' lower  ',frNoFrame);
                        end;
                  end;
                  '.': Begin  {or Del, wenn NumLock off}
                     sndlengthspm:=Round(sndlengthspm);
                     if sndlengthper = 1 then begin
                        actlength:=sndlength;
                     end else
                        actlength:=sndlength div lineattr.beats;
                     SChanged:=True;
                  end;
                  '0' :Begin{.  = round}
                    addcent:=100*Round(addcent / 100);
                    SndUpdateMulCent;
                    st:=sndgetcentstr(addcent);
                    IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
                  End;
                  '4' :Begin{lf   = -100 cent}
                    addcent:=addcent-100;
                    sndUpdateMulCent;
                    st:=sndgetcentstr(addcent);
                    IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
                  End;
                  '7' :Begin{Home = /2}
                    Mulcent:=Mulcent/2;
                    SndUpdateAddCent;
                    st:=sndgetcentstr(addcent);
                    IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
                  End;
                  '1' :Begin{End  = -1 cent}
                    Dec(Addcent);
                    SndUpdateMulCent;
                    st:=sndgetcentstr(addcent);
                    IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
                  End;
               '8' :Begin{Up   = +200 cent}
                 Addcent:=Addcent+200;
                 SndUpdateMulCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '2' :Begin{Dn   = -200 cent}
                 addcent:=addcent-200;
                 sndUpdateMulCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
                  '3' :Begin{PgDn   = +1 cent}
                    Inc(Addcent);
                    SndUpdateMulCent;
                    st:=sndgetcentstr(addcent);
                    IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
                  End;
                  '5' :Begin{m   = reset}
                    Addcent:=0;
                    Mulcent:=1;
                    st:=sndgetcentstr(addcent);
                    IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
                  End;
                  '6' :Begin{rg   = +100 cent}
                    Addcent:=Addcent+100;
                    SndUpdateMulCent;
                    st:=sndgetcentstr(addcent);
                    IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
                  End;
                  '9' :Begin{pgup = *2}
                    MulCent:=MulCent*2;
                    SndUpDateAddCent;
                    st:=sndgetcentstr(addcent);
                    IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
                  End;
               'B' :Begin
                 SndPlayBeat:=SndPlayBeat Mod 3+1;
                 IniDrawSoundState;
               End;
               'T' :Begin
                 if (SndPlayPulse And plPulse)=2 then
                   SndPlayPulse:=SndPlayPulse And (Not 3)
                 else
                   Inc(SndPlayPulse);
                 IniDrawSoundState;
               End;
               'P' :Begin
                 SndPlayPulse:=SndPlayPulse xor plspace;
                 IniDrawSoundState;
               End;
               'L' :Begin
                 soundattr:=(soundattr xor saLegato) and saLegato;
                 IniDrawSoundState;
               End;
               'S' :Begin
                 soundattr:=(soundattr xor saStaccato) and saStaccato;
                 IniDrawSoundState;
               end;
               'R' :begin
                 soundchange:=(soundchange xor saRhythm) {and saRhythm};
                 IniDrawSoundState;
               end;
(*             'I' :begin
                 soundattr:=(soundattr xor saIncipit) and saIncipit;
               end;  *)
               'M' :begin
(*                 soundchange:=(soundchange xor saMuffled) {and saMuffled};*)
                 soundattr:=(soundattr xor saMuffled) {and saMuffled};
                 IniDrawSoundState;
               end;
               '%' :begin
                 soundchange:=(soundchange xor saPhrased) {and saPhrased};
                 IniDrawSoundState;
               end;
               '(',')':begin
                 PlayOptions:=PlayOptions xor poParentheses;
                 IniDrawSoundState;
               end;
               '[',']':begin
                 PlayOptions:=PlayOptions xor poBrackets;
                 IniDrawSoundState;
               end;
               '{','}':begin
                 PlayOptions:=PlayOptions xor poBraces;
                 IniDrawSoundState;
               end;
               'Ý' :begin
                 PlayOptions:=PlayOptions xor poDashSlash;
                 IniDrawSoundState;
               end;
(*             '/' :begin
                 PlayOptions:=PlayOptions xor poSlash;
               end;*)
{Wenn NumLock off: ---------------------------------------------------------}
(* 3              #71 :Begin{Home=+1Hz}
                 MulCent:=MulCent*2; {Reaktion vorl„ufig:+1Oktave}
                 SndUpDateAddCent;
                 st:=sndgetcentstr(addcent);          IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End; *)
{---------------------------------------------------------------------------}
               End;
               IF SChanged Then Begin
               Str(sndlengthspm:4:3,st);
                  while st[0]<#8 do
                     st:=' '+st;
                  IniSpacedText(65,gmaxy div charheight - 3, st,frNoFrame);
               End;
            Until InpC IN [#9,#15,' '{,#63}];
            Case InpC OF
               #9: Begin
                  saveslinexmin:=slinexmin;
                  Saveslinexmax:=slinexmax;
                  SaveY:=y;
               End;
               #15:;
               ' ':Begin
                  Paused:=False;
                  nosound;
                  if savey<>0 Then
                     SndDraw(saveslinexmin, Saveslinexmax, Savey,wait);
                  IniSpacedText( 12,gmaxy div charheight - 5,
                                 'pause  ',frNoFrame);
                     IniSpacedText( 2,gmaxy div charheight - 1,
                                   ' Esc = stop end ',frHigh);
               End;{case inpC OF ' '}
          (*     #63: Begin
                  Paused:=False;
                  nosound;
                  if savey<>0 Then
                     SndDraw(saveslinexmin, Saveslinexmax, Savey,wait);
                  IniSpacedText( 12,gmaxy div charheight - 5,
                                 'pause  ',frNoFrame);
                     IniSpacedText( 2,gmaxy div charheight - 1,
                                   ' Esc = stop end ',frHigh);
               End;{case inpC OF #63}  *)
            End;
         End;
         While xKeyPressed Do Begin
            InpC:=XReadKey(temp1, temp2);
            Case UpCase(InpC) Of
               #27 : begin
                  if not temp2 then begin
                     c:=#27;
                     PlayNext:=False;
                     if not temp1 Then Begin
                        SndUpDateSndLength(sndlengthspm,sndlength,actlength,sndlengthper);
                        nosound;
                        Exit;
                     End else
                        if not paused Then Begin
                           i:=imenubkcolor;
                           j:=imenutextcolor;
                           imenubkcolor:=alarmbkcolor;
                           imenutextcolor:=alarmcolor;
                           IniSpacedText( 2,gmaxy div charheight - 1,
                                          '  Finishing line ',frLow);
                           imenubkcolor:=i;
                           imenutextcolor:=j;
                        End else
                           c:=#0;
                  end;
               end;
               #13 : begin{Enter}
                  IniSpacedText( 12,gmaxy div charheight - 5,
                                'pause  ',frNoFrame);
                  c:=#27;
                  PlayNext:=True;
                  paused:=false;
                  Inc(Linenum);
                  nosound;
                  Exit;
               End;{Case InpC Of #13}

               #10 : begin {Ctrl-Enter}
                     {spiele Linie zu Ende bevor n„chste gespielt wird}
                  IniSpacedText( 12,gmaxy div charheight - 5,
                                'pause  ',frNoFrame);
                  SndUpdateSndLength(sndlengthspm,sndlength,actlength,sndlengthper);
                  PlayNext:=True;
                  Inc(Linenum);
                  paused:=False;
                  nosound;
                  sndchar:='P';
                  restsndchar:=true;
               end;


                  '-' : begin
                    if temp1 And (Not Temp2) Then Begin{Shft}
                      if sndlengthspm<=12 Then
                         sndlengthspm:=2;
                      if sndlengthspm>12 Then
                         sndlengthspm:=sndlengthspm-10;
                    End Else
                      if not (Temp1 or Temp2) Then {Normal}
                        if sndlengthspm>=2 Then
                           sndlengthspm:=sndlengthspm-1;
                        if sndlengthspm<2 Then
                           sndlengthspm:=2;
                    SChanged:=True;
                  end;{case inpC OF '-'}
               '+' : begin
                  if temp1 And (Not Temp2) Then begin{Shft}
                        if sndlengthspm<=(SndMaxSpm-10) Then
                           sndlengthspm:=sndlengthspm+10;
                        if (sndlengthspm+10)>SndMaxSpm Then
                           sndlengthspm:=SndMaxSpm;
                  End Else
                     if not (Temp1 or Temp2) Then {Normal}
                        if sndlengthspm<=SndMaxSpm-1 then
                           sndlengthspm:=sndlengthspm+1;
                        if sndlengthspm>(SndMaxSpm-1) Then
                           sndlengthspm:=SndMaxSpm;
                  SChanged:=True;
               end;
               #0 : Begin{Ctrl-/Alt- [+/-]}
                  Inpc:=XReadKey(Temp1,Temp2);
                  Case  InpC OF
                     #82 :begin{Insert}
                        sndlengthspm:=Round(sndlengthspm);
                        if sndlengthper = 1 then begin
                           actlength:=sndlength;
                        end else
                           actlength:=sndlength div lineattr.beats;
                        SChanged:=True;
                     end;
                     #78  :{Alt +}
                        if (Sndlengthspm*1.33333{1.5})<=SndMaxSpm Then
                            Sndlengthspm:=(Sndlengthspm*1.33333{1.5});
                     #144 :{Ctrl +}
                        if sndlengthspm<=SndMaxSpm SHR 1 then
                           sndlengthspm:=sndlengthspm*2;
                     #74  :{Alt -}
                        if (Sndlengthspm)>=2*1.33333{1.5} Then
                           Sndlengthspm:=(Sndlengthspm/1.33333{1.5});
                     #142 :{Ctrl -}
                        if sndlengthspm>=4 Then
                           sndlengthspm:=sndlengthspm /2;
                     #28  :{Alt-Enter} Begin
                       if not(Temp1 or Temp2) and (c<>#27) then begin{Alt-Enter}
{                         PagRefClearVal(0,     IniYnow(linenum)-1,
                                        gmaxX, IniYnow(linenum));}
                         i:=Linenum;
                         ComSysStart(i);
                         i:=SpePrevNotLine(i);
                         IF i=0 Then Begin
                           nosound;
                           Exit;
                         End;{ if i=0}
                         ComSysStart(i);
                         linenum:=i;
                         PlayNext:=True;
                         paused:=false;
                         c:=#27;
                         if linenum>1 Then
                           dec(linenum);
                         nosound;
                         Exit;
                       End{if not temp1 or temp2}
                     End;{#28}
                  End;{Case }
                  SChanged:=True;
               End;{#0}
               '0' :Begin{.  = round}
                 addcent:=100*Round(addcent / 100);
                 SndUpdateMulCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '4' :Begin{lf  = -100 cent}
                 addcent:=addcent-100;
                 sndUpdateMulCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '7' :Begin{Home = /2}
                 Mulcent:=Mulcent/2;
                 SndUpdateAddCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '1' :Begin{End  = -1 cent}
                 Dec(Addcent);
                 SndUpdateMulCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '8' :Begin{Up   = +200 cent}
                 Addcent:=Addcent+200;
                 SndUpdateMulCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '2' :Begin{Dn   = -200 cent}
                 addcent:=addcent-200;
                 sndUpdateMulCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '3' :Begin{PgDn   = +1 cent}
                 Inc(Addcent);
                 SndUpdateMulCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '5' :Begin{m   = reset}
                 Addcent:=0;
                 Mulcent:=1;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '6' :Begin{rg   = +100 cent}
                 Addcent:=Addcent+100;
                 SndUpdateMulCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
               '9' :Begin{pgup = *2}
                 MulCent:=MulCent*2;
                 SndUpDateAddCent;
                 st:=sndgetcentstr(addcent);
                 IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End;
{Wenn NumLock off: ---------------------------------------------------------}
(* 4              #71 :Begin{Home=+1Hz}
                 MulCent:=MulCent*2; {Reaktion vorl„ufig:+1Oktave}
                 SndUpDateAddCent;
                 st:=sndgetcentstr(addcent);          IniSpacedText(20,gmaxy div charheight - 1,st,frLow);
               End; *)
{---------------------------------------------------------------------------}
               ' ' : begin
                  paused:=Not Paused;
                  nosound;
                  IF Paused Then Begin
                     IniSpacedText( 12,gmaxy div charheight - 5,
                                   'play   ',frNoFrame);
                     IniSpacedText( 2,gmaxy div charheight - 1,
                                   ' =Symbol '+#26+'=step ',frHigh);
                  End Else Begin
                     IniSpacedText( 12,gmaxy div charheight - 5,
                                   'pause  ',frNoFrame);
                     IniSpacedText( 2,gmaxy div charheight - 1,
                                   ' Esc = stop end ',frHigh);
                     if savey<>0 Then
                        SndDraw(saveslinexmin, Saveslinexmax, Savey,wait);
                  End;
               end;
               '/': Begin
                  IF Sndlengthper=1 Then begin
                    if sndlengthspm / lineattr.beats >= 2 {<=SndMaxSpm} then Begin
                      sndlengthper:=2;
                      sndlengthspm:=(sndlengthspm / lineattr.beats);
                      IniSpacedText(76,gmaxy div charheight - 3,'LPM',frNoFrame);
                      SChanged:=True;
                    end else begin
                      IniSpacedText(65,gmaxy div charheight - 3,
                      ' raise  ',frNoFrame);
                    end;
                 end;
               End;
               '*': Begin
                  IF Sndlengthper<>1 Then
                     if sndlengthspm * lineattr.beats <= SndMaxSpm then Begin
                        sndlengthper:=1;
                        sndlengthspm:=(sndlengthspm * lineattr.beats);
                        IniSpacedText(76,gmaxy div charheight - 3,'BPM',frNoFrame);
                        SChanged:=True;
                     end else begin
                        IniSpacedText(65,gmaxy div charheight - 3,
                        ' lower  ',frNoFrame);
                     end;
               end;
               '.': Begin  {or Del, wenn Numlock off}
                  sndlengthspm:=Round(sndlengthspm);
                  SChanged:=True;
               end;
               'B' :Begin
                 SndPlayBeat:=SndPlayBeat Mod 3+1;
                 IniDrawSoundState;
               End;
               'T' :Begin
                 if (SndPlayPulse And plPulse)=2 then
                   SndPlayPulse:=SndPlayPulse And (Not 3)
                 else
                   Inc(SndPlayPulse);
                 IniDrawSoundState;
               End;
               'P' :Begin
                 SndPlayPulse:=SndPlayPulse xor plspace;
                 IniDrawSoundState;
               End;
               'L' :Begin
                 soundattr:=(soundattr xor saLegato) and saLegato;
                 IniDrawSoundState;
               End;
               'S' :Begin
                 soundattr:=(soundattr xor saStaccato) and saStaccato;
                 IniDrawSoundState;
               end;
               'R' :begin
                 soundchange:=(soundchange xor saRhythm) {and saRhythm};
                 IniDrawSoundState;
               end;  {*schliesst so die andern nicht aus}
(*             'I' :begin
                 soundattr:=(soundattr xor saIncipit) and saIncipit;
               end;      *)
               'M' :begin
                 soundchange:=(soundchange xor saMuffled) {and saMuffled};
                 IniDrawSoundState;
               end;
               '%' :begin
                 soundchange:=(soundchange xor saPhrased) {and saPhrased};
                 IniDrawSoundState;
               end;
               '(',')':begin
                 PlayOptions:=PlayOptions xor poParentheses;
                 IniDrawSoundState;
               end;
               '[',']':begin
                 PlayOptions:=PlayOptions xor poBrackets;
                 IniDrawSoundState;
               end;
               '{','}':begin
                 PlayOptions:=PlayOptions xor poBraces;
                 IniDrawSoundState;
               end;
               'Ý' :begin
                 PlayOptions:=PlayOptions xor poDashSlash;
                 IniDrawSoundState;
               end;
            End;{Case}
         End;{While XKeyPressed}
         if (savey<>0) And Paused Then Begin
            IF SaveSlinexmin>slinexmin Then Begin
              saveslinexmin:=slinexmin;
              saveslinexmax:=slinexmax;
            End;
            IF SaveSlinexmax<slinexmin Then
              SaveSlinexmax:=slinexmin;
         End;
         IF SChanged Then Begin
            SndUpdateSndLength(sndlengthspm,sndlength,actlength,sndlengthper);
         End;
         IF IniMausEscape=#27 Then Begin
            c:=#27;
            PlayNext:=False;
            SndUpdateSndLength(sndlengthspm,sndlength,actlength,sndlengthper);
            nosound;
            Exit;
         End;
         if IniNumChar(inblock[1]) then begin
         { save current sound for legato }
           if(itemcount<>0)and(not repeatchar) then begin
             if((itemcount>1)or(itemchars[1].pitch<>sndbeat)or
                ((itemchars[1].length<>5)and(itemchars[1].length<>sndbeatlength))) then begin
               saveitemcount:=itemcount;
               saveitemchars:=itemchars;
             end;
           end;
           { actlength=total length of beat->rtime=length of this sound}
           leaveout:=0;
           rtime:=actlength/IniNextNumber(inblock);
           timemax:=round(rtime);
           if timemax<0 Then
             timemax:=0;
(*           rtime:=0;
           ok:=false;
           repeat
             if IniNumChar(inblock[1]) then begin
               rtime:=rtime+(actlength/IniNextNumber(inblock));
             end else begin
               if (inblock[1]='.')or((inblock[1]=',')and
               ( ((SndPlayPulse and plpulse)=plPulseNever) or
                (((SndPlayPulse and plpulse)=plPulseNoLeg)And((soundattr and saLegato)<>0))))then
                 delete(inblock,1,1)
               else
                 ok:=true;
             end;
           until ok or (length(inblock)=0);*)
           timemax:=round(rtime);
           if timemax<0 Then
             timemax:=0;
           { rlength/blength=elapsed time in this beat }
           rlength:= rlength + rtime;
           blength:= round(rlength);
           { beat finished? -> add beat sound }
           { kick out any rounding errors->exact beat... :) }
           if blength >= actlength then
             SndProcBeat;
           SndDrawPlay;
           if blength >= actlength then begin
           { add beat sounds }
             SndAddBeat;
             if blength > 0 then begin
               timemax:= blength;
               SndDrawPlay;
             end;
           end;
         end else begin{if IniNumChar(inblock[1])}
           SndProcItem;
         end;
      end; {while length(inblock) > 0 do}
   end else begin {if inblock[1] = 'N' then}
         playnext:=false;
         IF Sndchar='L' Then begin
            c:=#27;
{            HlpHint(HntLineEmpty, HintNormalTime);}
            playnext:=true;
         end;
      end;
  NoSound;
  if restsndchar then sndchar:=savesndchar;
End;

{******************************************************************}
Procedure SndSetOptions;

var
    c: char;
    resp: response_type;
    y, hy: integer;
    ok: boolean;

begin
   ImeInitSndOptionsMenu;
   if sndlengthspm=0 then sndlengthspm:=60000/sndlength;{New}
   UsrMenu.ChoiceVal[1].rval:= sndlengthspm;{New}
   UsrMenu.ChoiceVal[2].Tval:= sndlengthper;
   UsrMenu.ChoiceVal[3].Tval:= sndplaybeat;
   UsrMenu.ChoiceVal[4].Tval:= sndplaypulse+1;
   UsrMenu.ChoiceVal[5].ival:= sndbeat;
   UsrMenu.ChoiceVal[6].ival:= sndbeatlength;
   UsrMenu.ChoiceVal[7].ival:= sndpulse;
   UsrMenu.ChoiceVal[8].ival:= sndpulselength;
   UsrMenu.ChoiceVal[9].tval:= dispsound;
   UsrMenu.ChoiceVal[10].tval:=sndwarning;
   y:= grmaxy - (usrmenu.num_choices * usrmenu.spacing +
       usrmenu.menuattr.firstline + 6) * charheight;
   MausDunkel;
   PagRefClearVal(0, y - 16, gmaxX, gmaxy);
   hy:= y div charheight;
   GrDisplay_Frame(grminx, y, grmaxx, grmaxy, true, true);
   GrDisplay_Menu(hfminx, hy, usrmenu, 0);
   MausZeigen;
   GrGet_Menu_Values(hfminx, hy, hfmaxy, UsrMenu, c);
   sndlength:= Round(60000/UsrMenu.ChoiceVal[1].rval);{New}
   sndlengthspm:=UsrMenu.ChoiceVal[1].rval;{New}
   sndlengthper:= UsrMenu.ChoiceVal[2].tval;
   sndplaybeat:= UsrMenu.ChoiceVal[3].tval;
   sndplaypulse:= UsrMenu.ChoiceVal[4].tval-1;
   sndbeat:= UsrMenu.ChoiceVal[5].ival;
   sndbeatlength:= UsrMenu.ChoiceVal[6].ival;
   sndpulse:= UsrMenu.ChoiceVal[7].ival;
   sndpulselength:= UsrMenu.ChoiceVal[8].ival;
   dispsound:=UsrMenu.ChoiceVal[9].tval;
   sndwarning:=UsrMenu.ChoiceVal[10].tval;
end;

{******************************************************************}
Procedure SndSoundMenu(var linenum, actposn, actpost: integer;
                       var actptr, startptr, lastptr: listptr;
                       Menu : boolean);

var dir: movement;
    c: char;
    resp: response_type;
    choicenum: byte;
    x, y, hy, i: integer;
    mausx, mausy, maustaste, mausmenu: word;
    Playnext : Boolean;
    shiftp,ctrlp : Boolean;
    st : string;
begin
   paused:=false;
   maustaste:= 0;
   repeat
      ImeInitSoundMenu;
      choicenum:= 1;
      Mausdunkel;
      y:= grmaxy - (usrmenu.num_choices * usrmenu.spacing +
          usrmenu.menuattr.firstline + 2) * charheight;
      PagRefClearVal(0, y - 16, gmaxX, gmaxy);
      hy:= y div charheight;
      GrDisplay_Frame(grminx, y, grmaxx, grmaxy, true, false);
      GrDisplay_Menu(hfminx, hy, usrmenu, 0);
      Mauszeigen;
      GrGet_Menu_Response(hfminx, hy, usrmenu, c, dir, choicenum,
                          mausx, mausy, maustaste, mausmenu,
                          false, 0);
      x:= hfminx + usrmenu.menu_width + 16;
      c:= UpCase(c);
      PagRefPage;

      if c = 'O' then
      begin
         SndSetOptions;
      end
      else
      begin
         if c >= 'A' then
         begin
            sndchar:= c;
            c:= chr(27);
            PagRefreshPage(refxmin, refymin, refxmax, refymax);
            IniRefInit;
            st:='';
      {     st:=' [Esc]=stop  [Space]=pause  [Enter]=nextline  ('+#24+')[+/-]=speed ';}
             HlpBottomLine(st);                                          {[+/-]=speed}


IniSpacedText( 2,gmaxy div charheight - 5,'  Space = pause  ',frHigh);
IniSpacedText( 2,gmaxy div charheight - 3,'  Esc   = stop   ',frHigh);
IniSpacedText( 2,gmaxy div charheight - 1,' '+#24+'Esc = stop end ',frHigh);

IniSpacedText(20,gmaxy div charheight - 5,' (A/C)Enter = '+#24+#25+'Line ',frHigh);
IniSpacedText(20,gmaxy div charheight - 3,' 0=roundCent 5=reset ',frHigh);
IniSpacedText(20,gmaxy div charheight - 1,'                     ',frLow);

IniSpacedText(42,gmaxy div charheight - 5,' on/off: BPTSLMR ([{Ý ',frHigh);
IniSpacedText(42,gmaxy div charheight - 3,' ('+#24+'/Ctrl/Alt)ñ: speed ',frHigh);
IniSpacedText(42,gmaxy div charheight - 1,'                      ',frHigh);

IniSpacedText(65,gmaxy div charheight - 5,' / * = LPMBPM ',frHigh);
IniSpacedText(65,gmaxy div charheight - 1,' . = round -PM ',frHigh);


            Str(sndlengthspm:4:3,st);
            while st[0]<#8 do
               st:=' '+st;
            IF SndLengthPer=1 Then
               st:=st+'   BPM '
            Else
               st:=st+'   LPM ';
            IniSpacedText(65,gmaxy div charheight - 3, st,frLow);
            Repeat
               While xkeypressed do xreadkey (shiftp, ctrlp);
               SndPlaySound(linenum, actposn, actpost,
                            actptr, startptr, lastptr, true,playnext);
               If PlayNext Then Begin
                  ComEdReturn(linenum, actposn, actpost, false, false);
                  PagRefreshPage(refxmin, refymin, refxmax, refymax);
                  IniRefInit;
               end;
            until PlayNext=False;
        {    pagputbottomline }   {###}
        {    PagRefreshPage(refxmin, refymin, refxmax, refymax); } {###}
        {    iniRefInit; }  {###}
            c:=#27;
         end;
      end;
   until (c = chr(27));
end;


{******************************************************************}
Procedure SndPlaySound(var linenum, actposn, actpost: integer;
                       var actptr, startptr, lastptr: listptr;
                       Menu : boolean;var Playnext : Boolean);

var actcolor: byte;
    i,j: integer;
    c: char;
    InpC : Char;
    tempbuffer, inblock : stringline;
    St : string;
    endreached, drawline: boolean;
    tbufpos: byte;
    temp1, temp2: boolean;
    savesndchar : Char;
    savelinenum : integer;
    linetype    : Char; {Helpline?}

    {************************}
    Procedure SwapColor;

    begin
       if actcolor <> soundcolor then
       begin
          actcolor:=soundcolor;
       end
       else
       begin
          actcolor:=lcolor;
       end;
       SetColor(actcolor);
    end;


begin
   PlaySuccess:=False;
   savesndchar:=sndchar;
   savelinenum:=linenum;
   IF Not Menu Then
     sndchar:='L';
   if sndchar<>'F' then begin
     linenum:=0;
     while (page[linenum,1]<>'N') and (linenum<>pagelength+1) do begin
       inc(linenum);
     end;
     if linenum>=pagelength then begin
       if (mstart.mpag<>-1) and (mend.mpag<>-1) then begin
         sndchar:='B';
         filbufclear;
         MarMarkToBuffer(actptr, startptr, lastptr);
       end else begin
         HlpHint(HntPageEmpty, HintNormalTime);
         c:=#27;
         playnext:=False;
         linenum:=savelinenum;
         sndchar:=savesndchar;
         nosound;
         Exit;
       end;
     end;
     linenum:=savelinenum;
   end;{if sndchar<>'F'}
   actcolor:= lcolor;
   if Menu then begin
     if page[linenum]<>'N' then begin
       if sndchar<>'F' then begin
         while (page[linenum,1]<>'N') and (linenum<>pagelength+1) do
           inc(linenum);
         if page[linenum]<>'N' then begin
           while (page[linenum,1]<>'N') and (linenum<>1) do
             dec(linenum);
           if linenum=1 then begin
             nosound;
             exit;
           end;{if linenum=1}
         end;{if page[linenum]<>'N'}
       end;{if sndchar<>'F'}
     end;{if page[linenum]<>'N'}
   end;{if Menu}
   if (not Menu) and (sndchar<>'F') then begin
     sndchar:='L';
     if (Page[Linenum,1] <> 'N') then begin
       sndchar:='P';
     end;
     if (mstart.mpag<>-1) and (mend.mpag<>-1) then begin
       sndchar:='B';
       filbufclear;
       MarMarkToBuffer(actptr, startptr, lastptr);
     end;
   end;{if (not Menu) and (sndchar<>'F')}
   case sndchar of
     'L' : begin
       while c <> #27 do Begin
         PlayNext:=False;
         SwapColor;
         For i:=Linenum To Pagelength Do Begin
           If Page[i,1]='N' Then Begin
             PlayNext:=True;
             Linenum:=i;
             Break;
           End;{If Page}
         End;{For i}
         IF Not PlayNext Then Begin
           For i:=1 To Linenum-1 Do Begin
             If Page[i,1]='N' Then Begin
               PlayNext:=True;
               Linenum:=i;
               Break;
             End;{If Page}
           End;{For i}
         End;{IF Not PlayNext}
         i:=linenum;
         linetype:=page[i,5];
         If ((page[linenum,5]='H') and (savelinenum=linenum)) then
           page[linenum,5]:=' ';
         If PlayNext Then
           SndPlayLine(page[linenum], linenum, true,playnext,C,savesndchar);
         Page[i,5]:=linetype;
         PagRefClearVal(0,     IniYnow(i),
                        gmaxX, IniYnow(i)+1);
         if (i<>linenum) and not (playsuccess) then Begin
           pagrefreshpage(refxmin,refymin,refxmax,refymax);
           gcupatternrestore;
         End;
       End;{While c <> #27}
       Savelinenum:=Linenum;
     End;{Case SndChar Of 'L'}

     'B' : begin
       PlayNext:=False;
       j:=0;
       If not Menu then
         PagRefPage;
       if bufstartptr = bufendptr then begin
          HlpHint(HntBufEmpty, HintNormalTime);
       end else {if bufstartptr = bufendptr then} begin
         if marpartline then begin
           HlpHint(HntCantPlayPart, HintWaitEsc);
         end else {if marpartline then}begin
           endreached:= true;
           if ((mstart.mpag = pagecount) and
               (mend.mpag = pagecount)) then begin
             drawline:= true;
           end else begin
             drawline:= false;
           end;
           while c <> chr(27) do begin
             if endreached then begin
               bufactptr:= bufstartptr;
               tempbuffer:= '';
               tbufpos:= 0;
               SwapColor;
               i:= mstart.mline;
             end;
             FilCheckLine(tempbuffer, inblock,
                          bufactptr, bufstartptr, bufendptr,
                          tbufpos, endreached, true, false);
             if inblock[1]='N' then
               j:=1;
             if endreached and (j=0) then begin
               c:=#27;
               HlpHint(HntBufEmpty, HintNormalTime);
             end;
             SndPlayLine(inblock, i, drawline,playnext,c,savesndchar);
             i:= i + 1;
             if playnext then begin
               playnext:=False;
               {savesndchar:='L';}
             end;
           end; {while c <> chr(27) do}
         end; {else if marpartline then}
       end; {else if bufstartptr = bufendptr then}
     end;

     'P': begin
       PlayNext:=false;
       while c <> #27 do begin
         i:= 1;
         SwapColor;
         while ((i <= pagelength) and (c <> chr(27))) do begin
           if (i=pagelength) and Not (PlaySuccess) Then Begin
             PlayNext:=False;
             c:=#27;
             HlpHint(HntPageEmpty, HintNormalTime);
           End;
           setcolor(actcolor);
           { if (page[i,5]<>'H') and(page[i,1]='N') then  }
           SndPlayLine(page[i], i, true,playnext,c,savesndchar);
           i:= i + 1;
           if playnext then begin
             savelinenum:=i;
             savesndchar:='L';
           end;
         end;
       end;
       If (not Menu) And (PlaySuccess) then
         PagRefClearVal(0, 0, gmaxX, (pagelength)*linethick+linethick shr 1);
     end;

     'F': begin
       PlayNext:=False;
       FilSavePage(topmargin, pagelength,
                   actptr, startptr, lastptr);
       endreached:= true;
       while c <> chr(27) do begin
         if endreached then begin
           actptr:= startptr;
           tempbuffer:= '';
           tbufpos:= 0;
           FilFindPage(1, i, actptr, startptr, lastptr);
           linenum:=0;
         end;
         inc(linenum);
         if linenum = pagelength+1 then
           linenum:=1;
         if linenum <= pagelength then begin
           FilCheckLine(tempbuffer, inblock,
                        actptr, startptr, lastptr,
                        tbufpos, endreached, true, false);
           SndPlayLine(inblock, linenum, false,playnext,c,savesndchar);
         end;
         linenum:=savelinenum;
         if playnext then begin
           playnext:=false;
           c:=#0;
         end;
       end;
       FilFindPage(pagecount, i, actptr, startptr, lastptr);
       PagGetPageFromHeap(actptr, startptr, lastptr,i);
       savesndchar:='L'
     end;
   end; {case c of}
   while xKeyPressed do
      xReadKey(temp1, temp2);
   PagUnmark;
   sndchar:=savesndchar;
   linenum:=savelinenum;
   IF Not PlaySuccess Then
      playNext:=False;
end;

Function SndGetCentStr(C : Integer) : String;
Var O,HT,Cn: Integer;
    S1,S2  : String;
    corrY  : Byte;
Const IV : Array[0..11] of string[3] =
('Ä ³'{+#25},'2b³','2 ³','3b³','3 ³','4 ³','4#³','5 ³','6b³','6 ³','7b³','7 ³');

Procedure OHTCn;Assembler;
Asm
  POP BP                { Del Stackframe                }
  XOR AX,AX             { Clear Vars                    }
  MOV O,AX
  MOV HT,AX
  MOV CN,AX
  MOV AX,C              { Get Cents                     }
  TEST AX,8000h         { +                             }
  JZ   @@1
  NEG AX
@@1:
  MOV DX,AX
  CMP AX,1200
  JB  @@2
  XOR DX,DX
  MOV CX,1200d
  IDIV CX               { Div->O+ht                     }
  MOV O,AX
@@2:
  MOV AX,DX
  CMP AX,100
  JB  @@3
  XOR DX,DX
  MOV CX,100d
  IDIV CX               { Div->ht+cn                    }
  MOV HT,AX
@@3:
  MOV Cn,DX
  CMP Cn,50d
  JLE @@4
  SUB Cn,100d
  INC HT
  CMP HT,12d
  JB  @@4
  MOV HT,0
  INC O
@@4:
  CMP O,5
  JLE @@5
  MOV O,5
@@5:
  RET
End;

Function Oct : String;
Begin
  IF O=0 Then Begin
    Oct:='  0ù8 ³'+S1;
  End Else
    Oct:='  '+S1+''+Char(O+Byte('0'))+'ù8 ³ ';
End;
Function Hts : String;
Begin
  Hts:=IV[HT];
End;
Function Cent : String;
Begin
  Str(Abs(Cn):2,S2);
  IF Cn=0 Then
    S2:='+'+S2          {wenn    0 Cent}
  Else IF c>0 Then Begin
    IF cn>0 Then
      S2:='+'+S2        {wenn + .. Cent}
    Else IF cn<0 Then
      s2:='-'+S2        {wenn - .. Cent}
    Else
      s2:=' '+S2;       {wenn ???}
  End Else Begin
    IF cn>0 Then
      S2:='-'+S2
    Else IF cn<0 Then
      s2:='+'+S2
    Else
      s2:=' '+S2;       {wird nicht gebraucht}
  End;
  Cent:=+S2+'Cent ';
End;
Begin
  IF c>50 Then
    S1:='+'  {'+('}
  Else IF c<-50 Then
    S1:='-'  {'-('}
  Else
    S1:=' '; {' ('}
(*IF c>1199 Then
    S1:='+'  {'+('}
  Else IF c<-1199 Then
    S1:='-'  {'-('}
  Else
    S1:=' '; {' ('}     *)

  OHTCn;
  S1:=Oct+HTs+Cent;
  IF S1='  0ù8 ³ Ä ³+ 0Cent ' Then Begin
  if ctrlF5 then
    S1:='  NumBlock = Cent ñ ' { ñ = 241 }      {frs Ctrl-F5}
  else
    S1:=' NumberBlock = Centñ ' { ñ = 241 }     {frs F5}
  End;
  IniCenter(S1,21);
  SndGetCentStr:=S1;
End;
end.