unit butunit;

interface

uses graph,
     dos,
     initsc,
     menutyp,
     crt,
     GcuRunit;

type
   string10 = string[10];

   pbutton = ^tbutton;
   tbutton = object
   private
      x0, x1, y0, y1: integer;
      resp: response_type;
      keyresponse: char;
      mtext: string10;
   public
      constructor init(ax0, ax1, ay0, ay1: integer;
                     aresp:  response_type; akeyresponse: char;
                     amtext: string10);
      procedure draw;virtual;
      function activated(mausx, mausy: integer;
                         var vresp:  response_type; var vkeyresponse: char):
                         boolean;
      Procedure GetSize(Var aX0,aY0,aX1,aY1 : integer);
      Procedure GetSettings(Var aresp : response_type;var akeyresp : char;
                            var amtext : string10);
   end;

   pThreeDButton = ^tThreeDButton;
   tThreeDButton = object(Tbutton)
     FColor : Byte;
     TColor : Byte;
     constructor init(ax0, ax1, ay0, ay1: integer;
                      aresp:  response_type; akeyresponse: char;
                      amtext: string10;aFC,aTC : byte);
     procedure draw;virtual;
     procedure frame(c1,c2 : Byte);
   end;
   tmenubutton = array[1..10, 1..4] of TThreeDButton;

var
   vmenubutton: tmenubutton;
   vpageup, vpagedn, vswap, vexit: TThreeDButton;


procedure butdraw;
procedure butinit;
Procedure ButActivated(mausx, mausy: integer;
                       var vresp:  response_type; var vkeyresponse: char);

implementation

{*************************************************************}
constructor TButton.init(ax0, ax1, ay0, ay1: integer;
                      aresp:  response_type; akeyresponse: char;
                      amtext: string10);
begin
   x0:= ax0;
   x1:= ax1;
   y0:= ay0;
   y1:= ay1;
   resp:= aresp;
   keyresponse:= akeyresponse;
   mtext:= amtext;
end;

{*************************************************************}
procedure TButton.draw;

begin
   bar(x0, y0, x1+2, y1);
   txtfnt.write(x0+2, (y0+y1) div 2+1, mtext,getcolor,sz6x12,stnormal)
end;

{*************************************************************}
function TButton.activated(mausx, mausy: integer;
                          var vresp:  response_type; var vkeyresponse: char):
                          boolean;
var result: boolean;

begin
   result:= ((mausx > x0-2+charwidth) and (mausx < x1+2+charwidth) and
             (mausy > y0+charheight) and (mausy < y1+2+charheight));
   if result then
   begin
      vresp:= resp;
      vkeyresponse:= keyresponse;
   end;
   activated:= result;
end;

{*************************************************************}
procedure butinit;

const butsizex = 56;
      butsizey = 10;
      butdiffx =  4;
      butdiffy =  3;
      butxmarg = 2;
      butymarg = -1;
var i, j: word;
    vresp:  response_type;
    vkeyresponse: char;
    vmtext: string10;
    fc,tc: Byte;

const butmenu : array[1..10,1..4] of string10 =
(('1  Help  ',
  'S  Show  ',
  'C  Print ',
  'A  BegV{ '),
 ('2 Save   ',
  '  Save?  ',
  ' SplitFi ',
  '  EndV{  '),
 ('3 NoteLn ',
  '  NLDef  ',
  ' SplitLn ',
  '  BegH{  '),
 ('4 Space  ',
  '  InsPg  ',
  ' SplitPg ',
  '  EndH{  '),
 ('5 Play   ',
  '  Sound  ',
  ' SymbSnd ',
  '  VerLn  '),
 ('6 Header ',
  '  Search ',
  '  Repeat ',
  '  Ver'#18'Ln'),
 ('7 CopyLn ',
  '  Line   '{' Line'},
  ' PasteLn ',
  ' Hor3DLn '),
 ('8 MarkBl ',
  '  Block  ',
  ' PasteBl ',
  ' Ver3DLn '),
 ('9 MarkPg ',
  '  Page   ',
  ' PastePg ',
  ' SetupPg '),
 ('10 Table ',
  ' KeySwap ',
  '  Fonts  ',
  '  PgNum  '));

  ButVKeyResp : Array[1..4] OF Byte = (103,93,83,58);

function ButTopY(n : Byte) : integer;
Begin
  ButTopY:=gmaxy-butymarg-(n*(butsizey + butdiffy));
End;
function ButBotY(n : Byte) : integer;
Begin
  ButBotY:=ButTopY(n)+ButSizeY;
End;
function ButLeftX(n : Byte) : integer;
begin
  if n<11 then
    butleftx:=butxmarg+(n-1) * (butsizex + butdiffx)
  else
    butleftx:=butxmarg+(n-1) * (butsizex + butdiffx){+3};
end;
function ButRightX(n : Byte) : integer;
begin
  if n<11 then
    butrightx:=butleftx(n)+butsizex
  else
    butrightx:=gmaxx-butxmarg-2{3};
end;
function ButPgX : integer;
begin
  ButPgX:=(butrightx(11)-butleftx(11)-butdiffx) shr 1;
end;
begin
   fc:=framecolor+framebkcolor shl 4;
   tc:=mausmtcolor;
   for i:= 1 to 10 do
   begin
      for j:= 1 to 4 do
      begin
         vmtext:=butmenu[i,5-j];                       { Menutext }
         vresp:= specialkey;                           { Key-Typ  }
         vkeyresponse:=char(ButVKeyResp[j]+i);         { Scancode }
         vmenubutton[i,j].init(butleftx(i), butrightx(i),
                               buttopy(j),  butboty(j),
                               vresp, vkeyresponse, vmtext,
                               FC,TC);

      end;
   end;

   vpageup.init(butleftx(11),butleftx(11)+butpgx,
                buttopy(4), butboty(4),
                specialkey, chr(73), #23 + ' ',
                FC,TC);
   vpagedn.init(butleftx(11)+butpgx+butdiffx,butrightx(11),
                buttopy(4), butboty(4),
                specialkey, chr(81), ' ' + #22 {+ ' '},
                FC,TC);
   vswap.init(butleftx(11),butrightx(11),
              buttopy(3),  butboty(2),
              specialkey, chr(133),'  ' + #17 + ' ',
              FC,TC);
   vexit.init(butleftx(11),butrightx(11),
              buttopy(1),butboty(1),
              specialkey,chr(134),'RefPg',
              FC,TC);
end;

{*************************************************************}
procedure butdraw;

var i, j: word;
    tcol: byte;

begin
   tcol:= GetColor;
   SetColor(12);
   Line(0,grmaxy+1,gmaxx{-1},grmaxy+1);  {schwarze Linie oberhalb des Mausmenus}
   Line(0,grmaxy,gmaxx{-1},grmaxy);      {schwarze Linie oberhalb des Mausmenus}
   SetColor(framecolor{5});
   Line(0,grmaxy+2,gmaxx-1,grmaxy+2);  {Linie oberhalb des Mausmenus}
   Line(0,grmaxy+3,0,gmaxy);           {Linie links vom Mausmenu}
   SetColor(mausmtcolor);
   SetFillStyle(1, mausmbkcolor);
   for i:= 1 to 10 do
   begin
      for j:= 1 to 4 do
      begin
         vmenubutton[i,j].draw;
      end;
   end;
   vpageup.draw;
   vpagedn.draw;
   vswap.draw;
   vexit.draw;
   SetColor(8);
    Line(grminx,gmaxy,gmaxx,gmaxy);     {dunkelgraue Linie unterhalb vom Mausmenu}

   SetColor(tcol);
   SetBkColor(bkcolor);
end;

{*************************************************************}
Procedure ButActivated(mausx, mausy: integer;
                       var vresp:  response_type; var vkeyresponse: char);
var i, j: word;
    result: boolean;

begin
  result:= false;
  for i:=1 To 10 Do Begin
    For j:=1 To 4 Do Begin
      if vmenubutton[i,j].activated(mausx, mausy, vresp, vkeyresponse) then begin
        result:=true;
        break;
      end;
    end;
  end;
{$IFOPT B+}{$DEFINE BOOL}{$ENDIF}{$B-}
  result:=result or vpageup.activated(mausx, mausy, vresp, vkeyresponse)
                 or vpagedn.activated(mausx, mausy, vresp, vkeyresponse)
                 or vswap.activated(mausx, mausy, vresp, vkeyresponse)
                 or vexit.activated(mausx, mausy, vresp, vkeyresponse);
{$IFDEF BOOL}{$UNDEF BOOL}{$B+}{$ENDIF}
{  i:= 1;
  while i <= 10 do begin
    j:= 1;
    while j <= 4 do begin
      if vmenubutton[i,j].activated(mausx, mausy, vresp, vkeyresponse) then begin
        result:= true;
        i:= 999;
        j:= 999;
      end;
      j:= j+1;
    end;
    i:= i+1;
  end;
  if not result then begin
    result:= vpageup.activated(mausx, mausy, vresp, vkeyresponse);
  end;
  if not result then begin
    result:= vpagedn.activated(mausx, mausy, vresp, vkeyresponse);
  end;
  if not result then begin
    result:= vswap.activated(mausx, mausy, vresp, vkeyresponse);
  end;
  if not result then begin
    result:= vexit.activated(mausx, mausy, vresp, vkeyresponse);
  end;}
{  IF (VKeyResponse='U') And (VResp=SPECIALKEY) Then
    VResp:=No_Response;}
  IF (VResp=SPECIALKEY) And (VKeyResponse=#63) Then
    GcuPatternRestore;
end;

Procedure TButton.GetSize(Var aX0,aY0,aX1,aY1 : integer);
begin
  ax0:=x0;
  ay0:=y0;
  ax1:=x1;
  ay1:=y1;
end;

Procedure TButton.GetSettings(Var aresp : response_type;var akeyresp : char;
                            var amtext : string10);
begin
  aresp:=resp;
  akeyresp:=keyresponse;
  amtext:=mtext;
end;

constructor tThreeDButton.init(ax0, ax1, ay0, ay1: integer;
                      aresp:  response_type; akeyresponse: char;
                      amtext: string10;aFC,aTC : Byte);
begin
  inherited init(ax0, ax1, ay0, ay1, aresp, akeyresponse, amtext);
  fcolor:=aFC;
  tcolor:=aTC;
end;

procedure tThreeDButton.draw;
begin
  setcolor(tcolor);
  inherited draw;
  frame(fcolor and $0F,(fcolor and $f0) shr 4);
end;

procedure tThreeDButton.frame(c1,c2 : Byte);
begin
  SetColor(12);
  line(x0-1,y0,x0-1,y1+1);    {Rahmen links}
  line(x1+3,y0,x1+3,y1+1);    {Rahmen rechts}
  line(x0,y0-1,x1+2,y0-1);        {Rahmen oben}
  line(x0+1,y1+2,x1+2,y1+2);  {Rahmen unten}
  setcolor(c1);
  line(x0,y0,x0,y1 +1 );        { ³ l}
  line(x0,y0,x1+2,y0);        { Ä o}
  setcolor(8{c2});{I'm so sorry!}
  line(x1+2,y0+1,x1+2,y1+1);  { ³ r}
  line(x0 +1 ,y1+1,x1+2,y1+1);  { Ä u}
end;

end.
