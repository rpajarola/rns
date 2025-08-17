unit pageunit;

interface

uses
     Graph,
     menutyp,
     butunit,
     InitSc,
     crt,
     Mousdrv;


Procedure PagDisplayPage(var tempptr, startptr, lastptr: listptr);
Procedure PagShowPage(var linenum, actposn, actpost: integer;
                      var actptr, startptr, lastptr: listptr;
                      PageNumber: integer; savenow: boolean);
Procedure PagCursorLeft(linenum : integer; var actposn, actpost : integer);
Procedure PagCursorRight(linenum : integer; var actposn, actpost : integer);
Procedure PagUnMark;
Function PagEmptyPage(var tempptr, startptr, lastptr: listptr): boolean;
Procedure PagRemovePage(var tempptr, startptr, lastptr: listptr);
Procedure PagRefClearVal(clearxmin, clearymin, clearxmax, clearymax: integer);
Procedure PagRefreshPage(clearxmin, clearymin,
                         clearxmax, clearymax: integer);
Procedure PagRefPage;
Procedure PagPageFrame;
Procedure PagPutBottomLine;
Procedure PagClearBottomLine;
Procedure PagGetSetupPage(var tempptr, startptr, lastptr: listptr);
Procedure PagGetPageFromHeap(var tempptr, startptr, lastptr: listptr;
                             var linec: integer);
Procedure PagReadPage(var tempptr, startptr, lastptr: listptr;
                      var tempbuf: stringline; var tbufpos: byte);

procedure PagShowCurPosDistances(Linenum,ActPosn,ActPost : Byte;CorrY : Byte);
                      var beats, eint, resolution : string;
Procedure PagBottomFrame;
Procedure PagPutSearchBottomLine;
function paggetfreq(c:char):Integer;


implementation

uses Symbols,
     GCurUnit,
     GetUnit,
     Textunit,
     TitleUnit,
     inout,
     fileunit,
     helpunit,
     printunit,
     markunit;

{*******************************************************************}
procedure PagShowCurPosDistances(Linenum,ActPosn,ActPost : Byte;CorrY : Byte);
var beats, eint, resolution: string;

{Zeigt Cusorposition auf Text- und Musiklinien}

  Function GetN(St : String;P,X : Byte) : Byte;
  var a : Byte;
      c : Char;

  begin

    if x=0 then begin
       for a:=P downto 1 do begin
          c:=St[a];
          Case c of
          '0'..'9': begin
                        GetN:=a;
                        Exit;
                     end;{'0'..'9'}
          '%' : begin
                   Getn:=0;
                   Exit;
                end;{'%'}
          end;{Case}
       end;{For}
    end else begin{if}
       for a:=P to Length(St) do begin
          c:=St[a];
          Case C of
          '0'..'9': begin
                        GetN:=a;
                        exit;
                     end;{'0'..'9'}
          '%' : begin
                   Getn:=0;
                   Exit;
                end;{'%'}
          end;{Case}
       end;{for}
    end;{else}
    GetN:=0;
  end;{Func}

  Function GetL(St : String;P,X : Byte) : Byte;

  var c : Char;
      b : Byte;
      Code : integer;
  begin
     c:=St[p];
     Val(c,b,Code);
     if ((p=0) or (Code<>0)) then   {RICO: P=0 gibt weiter unten einen
                                           Range Check error [P-1]}
     begin
       GetL:=0;
       Exit;
     end;{if}
     if x=0 then
       c:=St[P-1]
     else begin
       if p<$FF then
         c:=St[P+1]
       else begin
         GetL:=0;
         Exit;
       end;
     end;
     Val(c,b,Code);
     if Code<>0 then begin
       GetL:=1;
       Exit;
     end;{if}
     GetL:=2;
  end;{func}


  function getadd(linenum,actposn : Integer) : Boolean;
  begin
    if (Page[linenum,actposn] IN ['a'..'z']) then
      Getadd:=Sympar[Page[linenum,actposn],2,1]=2
    else if (Page[linenum,actposn] IN ['A'..'Z']) then
      Getadd:=Sympar[Char(Byte(Page[linenum,actposn])+32),2,2]=2
    else if (Page[linenum,actposn] IN [Chr(161)..Chr(191)]) then
      Getadd:=Sympar[Char(Byte(Page[linenum,actposn])-31),2,3]=2
    else if (Page[linenum,actposn] IN [' ','.',',']) then
      Getadd:=false
    else if (Page[linenum,actposn] IN ['-','+','=']) then
      Getadd:=false;
  end;

  function nextavail(linenum,actposn : Integer) : Boolean;
  begin
    nextavail:=paggetfreq(page[linenum,actposn+1])<>32767;
  end;

  function lastavail(linenum,actposn : Integer) : Boolean;
  begin
    lastavail:=paggetfreq(page[linenum,actposn-1])<>32767;
  end;

  function getflam(linenum,actposn : Integer) : Byte;
  begin
     Case Page[linenum,actposn] of
        '-' : getflam:=1;
        '+' : getflam:=2;
        '=' : getflam:=3
        else{case}
           getflam:=0;
     End;{case else}
  end;

Const NonChars : Set Of Char = ['(',')','[',']','-','+','='];

Var LSt,RSt : String;
    L       : Byte;
    NL,NR   : Byte;
    Col,Row : String;
    c       : char;
    chbuf   : string16;
    a       : Byte;
    i,j     : integer;
    {zeigt Position auf ML}

Type TBottomInfo = Record
       S   : String[20];
       H   : Boolean;
     End;

Const KeySwap : Array[0..2,1..2,1..2] Of TBottomInfo =
((((S:'                    ';H:False),   {0,1,1}
   (S:' KeySwap:Symbolsize ';H:True )),  {0,1,2}
  ((S:' KeySwap:Cumulating ';H:True ),   {0,2,1}
   (S:' KeySwap:Cumul/Symb ';H:True ))), {0,2,2}
 (((S:' KeySwap:  Spacebar ';H:False),   {1,1,1}
   (S:' KeySwap:  Symb/SpB ';H:True )),  {1,1,2}
  ((S:' KeySwap: Cumul/SpB ';H:True ),   {1,2,1}
   (S:' KeySwap:Cu/Sym/SpB ';H:True ))), {1,2,2}
 (((S:' KeySwap:  Spacebar ';H:False),   {2,1,1}
   (S:' KeySwap:  Symb/SpB ';H:True )),  {2,1,2}
  ((S:' KeySwap: Cumul/SpB ';H:True ),   {2,2,1}
   (S:' KeySwap:Cu/Sym/SpB ';H:True ))));{2,2,2}
begin
  if Page[linenum,1]='N' then begin
    if corry<>2 then begin
      i:=imenubkcolor;
      j:=imenutextcolor;
      if KeySwap[blankset,manset,charset].H Then begin
        imenubkcolor:=alarmbkcolor;
        imenutextcolor:=alarmcolor;
      end;
      IniSpacedText(gmaxx div (2*charwidth) - 3,
                    gmaxy div charheight - 3,
                    KeySwap[blankset,manset,charset].S,frLow);
      imenubkcolor:=i;
      imenutextcolor:=j;
    end;
    while (lastavail(linenum,actposn)) and (actposn>1) do
      dec(actposn);
    col:='';
    if (getflam(linenum,actposn-1)=0) and (getflam(linenum,actposn)=0) then begin
      if symbcount<>0 then begin
        for a:=0 to symbcount do begin
          if nextavail(linenum,actposn) then begin
            inc(actposn);
          end else begin{if nextavail}
            i:=symbcount-1;
            symbcount:=symbcount mod (a+1);
            if i<>symbcount-1 Then
              actposn:=actposn+symbcount-i;
            break;
          end;{if nextavail else}
        end;{for a}
      end;{if symbcount}
      if corry<>2{1} Then Begin
        if paggetfreq(page[linenum,actposn])<>32767 then begin{zur Sicherheit:Symbol vorhanden?}
          if getadd(linenum,actposn) then begin   {Add vom CSym aus?}
            col:=' add';
            if nextavail(linenum,actposn) and getadd(linenum,actposn+1) then begin{Mehrere?}
              col:=col+'s';
            end;{if nextavail}
          end;{if getadd}
          i:=paggetfreq(page[linenum,actposn]);
          str(i:5,row);
          if i<>0 Then
            col:=row+' Hz'+col;
        end;{if paggetfreq}
        if (symbcount<>0) or nextavail(linenum,actposn) or
            lastavail(linenum,actposn) then Begin
          col:=col+' [Tab]  '  { ' [('+#24+')Tab]  '}{zu lang in gewissen F�llen}
        end;
      end{if corry<>2} else begin
        i:=paggetfreq(page[linenum,actposn]);
        str(i:5,col);
        if (mulcent>1) Then Begin
          i:=round(abs(i*mulcent-i));
          str(i:5,row);
          if i>0  Then
            row:=' +'+row+'Hz ';
          col:=col+'Hz '+row;
        end;
        if (mulcent<1) Then Begin
          i:=round(abs(i*mulcent-i));
          str(i:5,row);
{???}     if i>0{ich meine: if i<0}  Then
            row:=' -'+row+'Hz ';
          col:=col+'Hz '+row;
        end;
        if (mulcent=0) Then Begin
          i:=round(abs(i*mulcent-i));
          str(i:5,row);
{???}     if i>0{ich meine if i=0}  Then
            row:=' �'+row+'Hz ';
          col:=col+'Hz '+row;
        End;{ if mulcent<>1}
        if (mulcent=1) then begin
          col:=col+'Hz';
        end;
      end;{if corry<>2 else }
    end else begin{if getflam}
      symbcount:=symbcount and 1;
      str(paggetfreq(page[linenum,actposn+1+(symbcount xor 1)]):5,row);
      case getflam(linenum,actposn) of
        1 : begin
          col:='[-]'+row;
        end;{1}
        2 : begin
          col:='[+]'+row;
        end;{2}
        3 : begin
          col:='[=]'+row;
        end{3}
        else begin{case getflam of}
          str(paggetfreq(page[linenum,actposn+(symbcount xor 1)]):5,row);
          case getflam(linenum,actposn-1) of
            1 : begin
              col:='[-]'+row;
            end;{1}
            2 : begin
              col:='[+]'+row;
            end;{2}
            3 : begin
              col:='[=]'+row;
            end;{3}
          end;{case getflam of}
        end;{case getflam of else}
      end;{case getflam of}
      col:=' '+col+' Hz [Tab] ';
    end;{if getflam else}
    if col[0]<#19 then       {Zentrieren}
      col:=' '+col;
    while col[0]<#19 do begin
      col:=col+' ';
      if col[0]<#19 then
        col:=' '+col;
    end;{while col}
    col[0]:=#19;
    Case Page[linenum,actposn] of
      ' ':Col:='  0 Hz pause mark  ';
      ',':Col:='  0 Hz  time mark  ';
      '/':Col:='  0 Hz   end mark  ';
      '.':Col:='  0 Hz  help mark  ';
      '\':Col:='  0 Hz  jump mark� ';{Alt Gr 1}
      Chr(167):Col:='  0 Hz  jump mark  ';{Alt Gr 7}
    End;
  end else{if page}
    col:='                   ';
  IniSpacedText(gmaxx div (2*charwidth) - 23,
                gmaxy div charheight - 3,
                col,frLow);
  a:=1;
  i:=actposn;
  While (Page[linenum,actposn] in Nonchars) Do
    Inc(actposn);
  c:= Page[linenum,actposn+1];
  if Not Odd(symbcount) Then Begin
    if Page[linenum,actposn-1] in nonChars Then Begin
      c:=Page[linenum,actposn+1];
    End Else Begin
      c:=Page[linenum,actposn];
    End;
  End Else Begin
    if Page[linenum,actposn] in nonChars Then Begin
      c:=Page[linenum,actposn+1];
    End Else Begin
      c:=Page[linenum,actposn];
    End;
  End;
  actposn:=i;
  if Page[linenum,1]='N' then begin
    if (charset = 2) then begin
      if (('a' <= c) and (c <= 'z')) then begin
        c:= Char(Byte(c) - 32);
      end else {if (('a' <= c) and (c <= 'z')) then}begin
        if (('A' <= c) and (c <= 'Z')) then begin
          c:= Char(Byte(c) + 63);
        end else begin
          if ((#128 <= c) and (c <= #153)) then begin
            c:= Char(Byte(c) - 31);
          end;
        end;
      end; {else if (('a' <= c) and (c <= 'z')) then}
    end; {if charset = 2 then}
    if blankset = 2 then begin
      if c = ',' then
        c:=' '
      else
        if c = ' ' then
          c:=',';
    end;
    chbuf:= '�  [' + c + ']  �';
    if c=' ' then
      chbuf:='� space �';
    if (c>= #128) and (c<= #153) then begin
      c:= chr(ord(c) - 31);
      chbuf:= '� Alt-' + c + ' �';
    end;

    NL:=GetN(Page[linenum],ActPosn,0);
    L:=GetL(Page[linenum],NL,0);
    if NL > 0 then begin
      LSt:=Page[linenum][NL];
      if (Lst[1]<'0') or (Lst[1]>'9') then
        Lst:= '   ';
      if L=1 then
        LSt:=' '+LSt
      else
        LSt:=Page[linenum][NL-1]+LSt;
      if (Lst[1]<'0') or (Lst[1]>'9') then
        Lst:= '  '+Lst[2];
      if (L=2) {and (Lst[1]<>'1')} then
        Lst:='0' + Lst;
      if Lst[0]<>#3 then
        Lst:= ' '+Lst;
      {  if Lst='  1' then Lst:= '  1';  }
      if Lst='   ' then
        Lst:= ' � ';
    end else begin
      LSt:=' � ';
    end;
      {Anzeige nach rechts}
    NR:=GetN(Page[linenum],ActPosn,1);
    L:=GetL(Page[linenum],NR,1);
    if NR > 0 then begin
      RSt:=Page[linenum][NR];
      if (Rst[1]<'0') or (Rst[1]>'9') then
        Rst:= '   ';
      if L=1 then
        RSt:= RSt+' '
      else
        RSt:=Rst+Page[linenum][NR+1];
      if (Rst[2]<'0') or (Rst[2]>'9') then
        Rst:= Rst[1]+'  ';
      if (L=2) {and (Rst[1]<>'1')} then
        Rst:= '0' + Rst;
      if Rst[0]<>#3 then
        Rst:= Rst+' ';
      if Rst='   ' then Rst:= '..?';
    end else begin
      RSt:= '..?';
    end;
    if linenum<>0 then begin
      beats:= copy(page[linenum], 12,3);
      eint:= copy (page[linenum], 17,3);
      resolution:= copy (page[linenum], 22,3);
      while beats[3]=' ' do
        beats:= ' ' + copy(beats, 1,2);
      while eint[3]=' ' do
        eint:= ' ' + copy(eint, 1,2);

      Str(ActPost-10,Col);
      if Byte(Col[0])=1 then
        Col:='    '
      else if Byte(Col[0])=2 then
        Col:='    ';
      Col[0]:=#4;
      Str(Linenum,Row);
      if Byte(Row[0])=1 then
        Row:=' 0'+Row + ' '
      else if Byte(Row[0])= 2 then
        Row:=' '+Row + ' ';
      Row[0]:=#4;

      IF CorrY<>2{1} Then
        IniSpacedText(gmaxx div (2*charwidth) - 3,
                      gmaxy div charheight - 5,
                      ' R  ' + resolution + '/ B' + beats + '/ G' + eint + ' ',frLow);
    End;

    IF CorrY=0 Then
      IniSpacedText(gmaxx div (3*charwidth) - 24,
                    gmaxy div charheight - 5,
                    ' '+#25+Row+'�'+'    '+#26+' ',frLow);

     {damit die y-Position der ML gleichzeitig richtig angezeigt wird:}
    Str(ActPost-10,Col);
    if Byte(Col[0])=1 then
      Col:='    '
    else if Byte(Col[0])=2 then
      Col:='    ';
    Col[0]:=#4;
    Str(Linenum,Row);
    if Byte(Row[0])=1 then
{      Row:='  '+Row + ' '  }
      Row:='  '+Row + 'X'
    else if Byte(Row[0])= 2 then
      Row:=' '+Row + 'X';
    Row[0]:=#4;

    if (corry=0) {or (addcent=0) }Then
      col:=' '+LSt+' '+chbuf+' '+RSt+' '
    Else Begin
      str(abs(Round(addcent)):4,col);
      if addcent>0 Then
        col:='+'+col
      else if addcent<0 then
        col:='-'+col
      else
        col:='�'+Col;
      str(round(paggetfreq(page[linenum,actposn])*mulcent):5,row);
      col:=' '+col+'Cent='+row+'Hz';
      IniExpand(col,19);
    End;
    IniSpacedText(gmaxx div (3*charwidth) - 10,
                  gmaxy div charheight - 5,
                  col,frLow)

    {zeigt x/y-Position}
  end{if Page[linenum,1]='N'} else begin
    if Page[linenum][1]='T' then begin
      Str(ActPost-10,Col);
      if Byte(Col[0])=1 then
        Col:=' 0'+Col+ ' '
      else if Byte(Col[0])=2 then
        Col:=' '+Col+ ' ';
      Col[0]:=#4;
      Str(Linenum,Row);
      if Byte(Row[0])=1 then
        Row:=' 0'+Row + ' '
      else if Byte(Row[0])= 2 then
        Row:=' '+Row + ' ';
      Row[0]:=#4;
      IniSpacedText(gmaxx div (3*charwidth) - 24,
                    gmaxy div charheight - 5,
                    ' '+#25+Row+'�'+Col+#26+' ',frLow);

      IniSpacedText(gmaxx div (2*charwidth) - 3,
                       gmaxy div charheight - 5,
                      '                    ',frLow);
      IniSpacedText(gmaxx div (3*charwidth) - 10,
                       gmaxy div charheight - 5,
                      '                   ',frLow);

      IniSpacedText(gmaxx div (2*charwidth) - 3,
                       gmaxy div charheight - 3,
                      '                    ',frLow);
      IniSpacedText(gmaxx div (3*charwidth) - 10,
                       gmaxy div charheight - 3,
                      '                   ',frLow);

{      IniSpacedText(gmaxx div (2*charwidth) - 3,
                       gmaxy div charheight - 1,
                      '                    ',frLow);}
      IniSpacedText(gmaxx div (3*charwidth) - 10,
                       gmaxy div charheight - 1,
                      '                   ',frLow);

    {  IniSpacedText(gmaxx div (1*charwidth) - 22,
                       gmaxy div charheight - 1,
                      '                       ',frLow);  }

 {    if Page[Linenum][1]='T' then

         SetFillStyle(1,bottomcolor);
         Bar(120,465,280,475);
         Bar(120,430,280,445);
         Bar(281,465,445,475);
         Bar(281,430,445,445);   }
    end;

    SetLineStyle(Solidln, 1, 0);

                                  {Anzeigen numeriert von O nach U
                                  1.Kolonne, 2., 3.}
  end;{ if Page[linenum][1]='N' else}
end;{proc 1}

{*******************************************************************}
Procedure PagUnMark;
{Unmark and refresh page}

var refmin, refmax: byte;
    mx: integer;

begin
   refmin:= topmargin;
   refmax:= pagelength;
   mx:= mstart.mxcoord;
   if pagecount = mstart.mpag then refmin:= mstart.mline;
   if pagecount = mend.mpag then refmax:= mend.mline;

   if ((pagecount >= mstart.mpag) and
       (pagecount <= mend.mpag)) then
   begin
      markinit;
      PagRefClearVal(0, IniYNow(refmin - 1), gmaxX, IniYNow(refmax + 1));
   end
   else
   begin
      if ((pagecount = mstart.mpag) and (mend.mpag = -1)) then
      begin
         markinit;
         PagRefClearVal(mx - 3, IniYNow(refmin - 1),
                        mx + 9, IniYNow(refmin + 1));
      end
      else
      begin
         markinit;
      end;
   end;
end;

{*******************************************************************}
Procedure PagCursorLeft(linenum : integer; var actposn, actpost : integer);

var
    xa : integer;
    inblock: stringline;
    lineattr: lineattrtype;

begin
  if Page[linenum, 1] = 'N' then begin
     inblock:= page[linenum];
     GetNoteBlock(inblock, lineattr, linenum);
     Xa:= IniFirstBeatPos(lineattr);
     GetNotePosX(Xa, actposn, linenum, true, true);
  end else begin
     actpost:= linemarker + 2;
     TexActPosX(Xa, actpost, linenum, true);
  end;
end;

{*******************************************************************}
Procedure PagCursorRight(linenum : integer; var actposn, actpost : integer);
var xa : integer;
begin
  if Page[linenum, 1] = 'N' then begin
    xa:=IniLineEnd(page[linenum]);
    GetNotePosX(Xa, actposn, linenum, true, false);
  end else begin
    xa:= gmaxX - Gcurightmargin;
    actpost:= length(page[linenum])+1;
    while (page[linenum,actpost-1]=' ') and (actpost>linemarker+1) do
      dec(actpost);
    if actpost<linemarker+2 then
      actpost:=linemarker+2;
    page[linenum,0]:=char(actpost-1);
    TexActPosX(Xa, actpost, linenum, true);
  end;
end;

{*******************************************************************}
{*******************************************************************}
{*******************************************************************}
Procedure PagEmptyBottomLine;
Begin
  SetColor(lcolor);
  SetBkColor(bkcolor);
  SetFillStyle(1, bottomcolor);
  Bar(1, grmaxy + 3, gmaxx, gmaxy);
  PagBottomFrame;
  IniSpacedText(2 ,54,'             ',frLow);
  IniSpacedText(2 ,56,'             ',frLow);
  IniSpacedText(2 ,58,'             ',frHigh);

  IniSpacedText(16,54,'                   ',frLow);
  IniSpacedText(16,56,'                   ',frLow);
  IniSpacedText(16,58,'                   ',frLow);

  IniSpacedText(36,54,'                    ',frLow);
  IniSpacedText(36,56,'                    ',frLow);
  IniSpacedText(36,58,'                    ',frLow);

  IniSpacedText(57,54,'                       ',frLow);
  IniSpacedText(57,56,'              ',frLow);
  IniSpacedText(72,56,'        ',frHigh);
  IniSpacedText(57,58,'                       ',frLow);

End;
{*******************************************************************}
Procedure PagPutSearchBottomLine;
Begin
  PagEmptyBottomLine;
End;
{*******************************************************************}
Procedure PagPutBottomLine;

const itemlength = 21;

var inblock: stringline;
    i: longint;
    x : byte;
    St: String;
    w : longint;

    {**********************************************************}
    Procedure PagPutFileHint(hinttext: string);
    {Kleines Proceduerchen um den File-Name hinzuschreiben}

    var x, y: integer;
  { var actpage: integer; }
    begin
       y:= gmaxy div charheight - 2;
       x:= TextMargin div charwidth + 1;
       IniSpacedText(x+1, y - 1, hinttext,frLow);
    end;

begin
  if not (printeron or showmenus) then begin
    PagEmptyBottomLine;
    IniSpacedText(gmaxx div (3*charwidth) - 24,
                  gmaxy div charheight - 1,
                  ' [F1] = HELP ',fr3D);

    if sndlengthspm=0 then sndlengthspm:=80;
    w:=Round(1000*sndlengthspm);
    Str((w/1000):5:3,St);
    While St[0]<#8 Do
      St:=' '+st;
    case sndlengthper of
      1 : st:=St+'  B';
      2 : st:=st+'  L';
    end;
    st:=st+'PM ';
    IniExpand(St, itemlength - 7);
    IniSpacedText(gmaxx div charwidth - 22,
                  gmaxy div charheight - 3,
                  St,frLow);
    IniSpacedText(gmaxx div charwidth - 7,
                  gmaxy div charheight - 3,
                  ' MENU ' +#16 + ' ',fr3D);

    if (not (defsetuppage in actedit)) then begin
      x:=Pos('   .',actfilename);
      St:=actfilename;
      St:=Copy(St,1,x-1)+Copy(St,x+1,Length(St)-x);
      St:=' '+St;
      IF St[0]>Char(itemlength+2) Then
        Repeat
          Dec(Byte(St[0]));
        Until (St[Byte(St[0])+1])='.';
      IniExpand(St, itemlength + 2);
      UpString(St);
      IniSpacedText(gmaxx div charwidth - 22,
                    gmaxy div charheight - 5,
                    St,frLow);
    end;

    if setuppage in actedit then begin
      if defsetuppage in actedit then begin
        PagPutFileHint(' PAGEDEFAULT ');
      end else begin
        PagPutFileHint(' SETUP  PAGE ');
      end;
    end else begin
      Str(PageCount:3,inblock);{Sorry wegen des Missbrauchs deines inblockes}
      IniSpacedText(gmaxx div 16 - 37,
                    gmaxy div charheight - 3,
                    ' PAGE :  '+inblock+' ',frLow);
    end;
    i:=framewidth;
    Framewidth:=0;
    IniSpacedText(grmaxx div charwidth - 22, gmaxy div charheight - 1,
    ' ' + fontfile,frLow);
    Framewidth:=i;
  end else {if not printeron} begin
    if printeron then begin
      Str(pagecount:3, inblock);
      inblock:= ' Printing page ' + inblock;
      HlpBottomLine(inblock);
    end else begin
      ButDraw;
    end;
  end;
end;

{*************************************************************************}

Procedure PagClearBottomLine;

begin
   SetFillStyle(1, bottomcolor);
   Bar(1, grmaxy+3, gmaxx-1, gmaxy-1); {l�scht aber den Lichtrand nicht!}
end;

{*******************************************************************}
Procedure PagPageFrame;
begin
  if printeron then begin
    PriSetLineWidth(frwidth);
    PriDrawFrame(grminx,grminy, grmaxx, grmaxy);
  end else begin
    SetColor(5);
    Line(grminx, grminy, grminx, grmaxy); { � l}
    Line(grminx, grminy, grmaxx, grminy); { � o}
    SetColor(bkcolor);
    Line(grmaxx, grminy+1, grmaxx, grmaxy-1); { � r }
  end;
end;

{*******************************************************************}
Function PagEmptyPage(var tempptr, startptr, lastptr: listptr): boolean;
{Testen, ob die n�chste Seite im Heap leer ist}
var result, endreached: boolean;
    i, tbufpos: byte;
    inblock, tempbuf: stringline;
    tempsav: listptr;
begin
  result:= true;
  i:= topmargin;
  tbufpos:= 0;
  tempbuf:= '';
  tempsav:= tempptr;

  while ((result) and (i <= pagelength)) do begin
    FilCheckLine(tempbuf, inblock, tempptr, startptr, lastptr,
                 tbufpos, endreached, true, false);
    {leere Zeile oder Fuss/Kopftext Zeile}
    if ((IniEmptyLine(inblock)) or (inblock[4] = 'F')) then begin
      i:= i + 1;
    end else begin
      result:= false;
    end;
  end;
  tempptr:= tempsav;
  PagEmptyPage:= result;
end;

{*******************************************************************}
Procedure PagRemovePage(var tempptr, startptr, lastptr: listptr);
{l�scht ersatzlos eine Seite im Buffer}
var
    i: byte;
    inblock: stringline;
begin
  i:= topmargin;
  while ((tempptr <> lastptr) and (i <= pagelength)) do begin
    FilHeapExtractString(inblock, tempptr, startptr, lastptr);
    i:= i + 1;
  end;
end;

{*******************************************************************}
Procedure PagGetPageFromHeap(var tempptr, startptr, lastptr: listptr;
                             var linec: integer);
{Kopieren einer Seite aus dem Heap in den Page-Array}
var inblock : stringline;

begin
  if tempptr <> lastptr then begin
    linec:= topmargin;
    repeat
      FilHeapExtractString(inblock, tempptr, startptr, lastptr);
      page[linec]:= inblock;
      while length(page[linec]) < linemarker do begin
         page[linec]:= page[linec] + ' ';
      end;
      if (page[linec,1]<>'N') and (page[linec,1]<>'T') then
        page[linec,1]:='T';
      inc(linec);
    until (linec > pagelength) or (tempptr = lastptr);
    While linec<=pagelength do begin
      page[linec]:='T         ';
      inc(linec);
    end;
  end;
end;

{*******************************************************************}
Procedure PagDisplayPage(var tempptr, startptr, lastptr: listptr);
{Darstellen einer Seite von der gegenw�rtigen Position an}

var linec, i : integer;
    rptr: listptr;

begin
  ClearViewPort;
  PagPageFrame;
  PagPutBottomLine;
  {Seite lesen}
  if tempptr <> lastptr then begin
    PagGetPageFromHeap(tempptr, startptr, lastptr, linec);
  end else { if tempptr <> lastptr then} begin
    PagGetSetupPage(rptr, startptr, lastptr);
  end; { else if tempptr <> lastptr then}
  linec:= pagelength;

  {Seite anzeigen}
  i:= topmargin;
  repeat
    GetLine(i, 0);
    i:= i+1;
  until ((i > pagelength) or ((IniKeyPressed) and (pagecount<>1)));
  i:= topmargin;
  repeat
    TitGetText(i, 0);
    i:= i+1;
  until ((i > pagelength) or ((IniKeyPressed) and (pagecount<>1)));
  MarkDisplay;
  IniRefInit;
end;

{*******************************************************************}
Procedure PagGetSetupPage(var tempptr, startptr, lastptr: listptr);
var tempbuf : stringline;
    i : integer;
    endreached: boolean;
    tbufpos: byte;
begin
  tbufpos:= 0;
  tempbuf:= '';
  tempptr:= startptr;
  for i:= topmargin to pagelength do begin
    FilCheckLine(tempbuf, page[i], tempptr, startptr, lastptr,
                 tbufpos, endreached, true, false);
    page[i, 3]:= ' ';
  end;
end;

{*******************************************************************}
Procedure PagReadPage(var tempptr, startptr, lastptr: listptr;
                      var tempbuf: stringline; var tbufpos: byte);
{liest eine Seite aus dem heap, ohne den Heap zu ver�ndern}
var i : integer;
    endreached: boolean;
begin
  for i:= topmargin to pagelength do
  begin
    FilCheckLine(tempbuf, page[i], tempptr, startptr, lastptr,
                 tbufpos, endreached, true, false);
  end;
end;

{*******************************************************************}
Procedure PagRefPage;
begin
  PagRefClearVal(0, 0, gmaxX, gmaxY);
end;

{*******************************************************************}
Procedure PagRefClearVal(clearxmin, clearymin, clearxmax, clearymax: integer);
begin
  if clearxmin < refxmin then refxmin:= clearxmin;
  if clearxmax > refxmax then refxmax:= clearxmax;
  if clearymin < refymin then refymin:= clearymin;
  if clearymax > refymax then refymax:= clearymax;
  if refxmin   < 0       then refxmin:= 0;
  if refymin   < 0       then refymin:= 0;
  if refxmax   > grmaxx  then refxmax:= grmaxx;
  if refymax   > grmaxy  then refymax:= grmaxy;
end;

{*******************************************************************}
Procedure PagRefreshPage(clearxmin, clearymin,
                         clearxmax, clearymax: integer);
{Darstellen einer Seite aus dem Page-Buffer}
var i : integer;
    reflinemin, reflinemax: integer;
    testinp: boolean;
begin
  SetPalette(12,0);             { Color 12=PalReg[0]                    }
  SetPalette(13,15);            { Color 13=PalReg[15]                   }
  IniSetDACReg(60,0,0,0);       { light red ->Schwarz                   }
  IniSetDACReg(5,63,63,63);     { magenta   ->Weiss  }
  IniSetDACReg(63,10,10,10);    { Weiss     ->Grau   Mausfarbe!!!       }
  SetLineStyle(SolidLn,0,1);
  if clearxmin < clearxmax then begin
    GcuPatternRestore;
    Mausdunkel;
    IniSetViewPort(clearxmin, clearymin-17, clearxmax, clearymax); {-17 wegen m(ove) pitchlines}
    ClearViewPort;
    SetViewPort(0, 0, gmaxX, gmaxY, true);
    PagPageFrame;
    reflinemin:= (clearymin div linethick) - 4;
    reflinemax:= (clearymax div linethick)+4;
    if reflinemin < topmargin then reflinemin:= topmargin;
    if reflinemax > pagelength Then
      reflinemax:= pagelength;
    if clearymax > grmaxy Then
      PagPutBottomLine;
    testinp:= ((reflinemax - reflinemin) > 15) and (pagecount<>1);
    for i:=reflinemin to reflinemax do begin
      GetLine(i, clearxmin - 20);
      if (testinp and IniKeyPressed) then
        break;
    end;
    if printeron then
      PriSwapFont;
    for i:=reflinemin to reflinemax do begin
      TitGetText(i, 0);                          {@@@@@}
      if (testinp and IniKeyPressed) then
        break;
    end;
    MarkDisplay;
    MausZeigen;
    GcuCursorRestore;
  end;{ if clearxmin < clearxmax then }
end;

{*******************************************************************}
Procedure PagShowPage(var linenum, actposn, actpost: integer;
                      var actptr, startptr, lastptr: listptr;
                      PageNumber: integer; savenow: boolean);
{Darstellen der Seite PAGENUMBER}
var Result : integer;
begin
  if savenow then
    FilSavePage(1, PageLength, actptr, startptr, lastptr);
  FilFindPage(PageNumber, Result, actptr, startptr, lastptr);
  PageCount:= Result;
  IniNewPage(linenum);
  PagDisplayPage(actptr, startptr, lastptr);
  PagCursorLeft(linenum, actposn, actpost);
end;

Procedure PagBottomFrame;
Begin
  SetColor(12);                        {Abgrenzung zur Filepage}
  Line(0,grmaxy+1,gmaxx,grmaxy+1);
  Line(0,grmaxy,gmaxx,grmaxy);
  SetColor(framecolor);                {Licht links und oben}
  Line(0,grmaxy+2,gmaxx,grmaxy+2);
  Line(0,grmaxy+3,0    ,gmaxy);
End;

function paggetfreq(c:char):Integer;
var a : Integer;
begin
  if (soundchange and saRhythm)<>0 then begin
    a:=RhythmFreq;
  end else if (c IN ['A'..'Z']) then begin
    a:=Sympar[Char(Byte(c)+32),3,2];
  end else if (c IN ['a'..'z']) then begin
    a:=Sympar[c,3,1];
  end else if (c IN [Chr(161)..Chr(191)]) then begin
    a:=Sympar[Char(Byte(c)-31),3,3];
  end else if (c IN [' ','.',',']) then begin
    a:=0;
  end else if (c IN ['+','-','=','*']) then begin
    a:=0;
  end else if (c IN ['/',Chr(167),'\']) then begin
    a:=0;
  end else if (c in ['0','1','2','3','4','5','6','7','8','9'])then begin
    a:=32767;
  end else begin
    a:=0;
  end;
  paggetfreq:=a;
end;

end.
