unit helpunit;

interface

uses Graph,
     GcurUnit,
     Graphmenu,
{     Dispmenu,}
     inout,
     menutyp,
     dos,
     Crt,
     xcrt,
     imenuunit,
     InitSc,
     UserExit;

Procedure HlpCommandTable;
Procedure HlpSymbolTable;
Procedure HlpHint(hintnum: integer; WaitTime: Integer);
Function HlpAreYouSure(hinttext: string79; position : byte): boolean;
Function HlpAskYesEsc(hinttext,choicetext: string79; position : byte) : boolean;
Function HlpAsk(hinttext,choicetext: string79; position : byte;
                Resp : TCharSet) : char;
Function HlpAskAny(Hinttext,choicetext: string79; position : byte) : Char;

Function HlpGetFileName(var instring: string16; extn: string16;x,y : word): Boolean;
Procedure HlpTestFileName(instring: stringline; var ok: boolean;
			  x, xmax, y: integer);
Procedure HlpText(x, xmax, y: integer; hinttext: string79; escwait: boolean);
Procedure HlpBottomLine(hinttext: string79);
Procedure HlpHintFrame(hintminx, hintminy, hintmaxx, hintmaxy: integer);
Function HlpTxtAreYouSure(x, xmax, y: integer;
			  hinttext: string79): boolean;
Procedure HlpSymbolSelect(var c: char);
Procedure HlpDemoText(x, xmax, y: integer);

implementation

uses pageunit,
     sdunit,
     symbols,
     Dmemunit,
     mousdrv,
     grinout,
     Texts;

{******************************************************}
Procedure HlpBottomLine(hinttext: string79);

var x, y: integer;

begin
   PagClearBottomLine;
   y:= gmaxy div charheight - 2;
   x:= TextMargin div charwidth + 1;
   IniInversText(x+1, y - 1, hinttext,frHigh);
end;

{******************************************************}
Procedure HlpHintFrame(hintminx, hintminy, hintmaxx, hintmaxy: integer);

var c : char;
begin
   SetColor(alarmcolor);
   SetFillstyle(1, alarmbkcolor);
   Bar(hintminx, hintminy, hintmaxx, hintmaxy);
   SetColor(framecolor);
   Line(hintminx, hintminy+2, hintmaxx, hintminy+2);
   Line(hintminx, hintminy+1, hintminx, hintmaxy);
   SetColor(12);
   Line(hintminx, hintmaxy, hintmaxx, hintmaxy);     {unterer Abstand zu Status}
   Line(hintminx, hintmaxy+1, hintmaxx, hintmaxy+1);     {unterer Abstand zu Status}
   Line(hintminx, hintminy  , hintmaxx, hintminy);   {oberer Abstand zur Seite}
   Line(hintminx, hintminy+1, hintmaxx, hintminy+1); {oberer Abstand zur Seite}

(*   SetColor(3);
   Line(hintminx+1, hintminy-1, hintmaxx, hintminy-1);  {Schatten oben}
   Line(hintminx+1, hintminy+47, hintmaxx, hintminy+47);{Schatten unten}
   Line(hintmaxx  , hintminy+3, hintmaxx, hintminy+47); {Schatten rechts}
*)
   SetColor(AlarmColor);
end;

{******************************************************}
Procedure HlpTestFileName(instring: stringline; var ok: boolean;
			  x, xmax, y: integer);
{testet instring auf einen gÅltigen textstring}
Procedure ImpossibleFilename;
var P : Pointer;
Begin
  ok:=false;
  Mauszeigen;
  GetMem(P,ImageSize(grminx,grmaxy-22,grmaxx,grmaxy+32));
  GetImage(grminx,grmaxy-22,grmaxx,grmaxy+32,P^);
  HlpHintFrame(grminx, grmaxy - 22, grmaxx, grmaxy+32);
  txtfnt.write(grminx +16, grmaxy -6,
     'Filename contains illegal characters',
     getcolor,sz8x16,stnormal);
  txtfnt.write(grminx+16, grmaxy + 14,
      'Press [Esc] to continue ',
      getcolor,sz8x16,stnormal);
  Repeat Until IniMausEscape = #27;
  Mausdunkel;
  PutImage(grminx,grmaxy-22,P^,CopyPut);
End;
var tfile: text;
    i    : Integer;
begin
  ok:= true;
  if not IniFileExist(instring) then begin
{$I-}
    assign(tfile, instring);
    LastFileName:=FExpand(instring);
    rewrite(tfile);
    I:=IOResult;
    IF I<>0 Then begin
      ImpossibleFileName;
      exit;
    end;
    close(tfile);
    I:=IOResult;
    IF I<>0 Then begin
      ImpossibleFileName;
      exit;
    end;
    erase(tfile);
    I:=IOResult;
    IF I<>0 Then begin
      ImpossibleFileName;
      exit;
    end;
{$I+}
  end;
  Exit;
end;

{******************************************************}
Function HlpGetFileName(var instring: string16; extn: string16;x,y : word): Boolean;

var resp: Response_Type;
    dir: movement;
    c: char;
    ok: boolean;
    mausx, mausy, maustaste, mausmenu: word;
    changed : Boolean;
begin
   instring:= '';
   repeat
      resp:= No_Response;
      if (x or y)=0 then begin
        HlpHintFrame(grminx, grmaxy - 38, grmaxx, grmaxy);
        x:= grminx div charwidth + 22;
        y:= (grmaxy - 16) div charheight;
      end;
      IniSpacedText(X-20,Y-1,'                                                 ',frLow);
      GrGet_Prompted_Spaced_String(instring, fieldlength, '>',
			    x, y - 1, x, 'Filename('+extn+')',
			    x - 19, y - 1, 18, resp, dir, c, false,
                            mausx, mausy, maustaste, mausmenu, changed);
      IniMausAssign(maustaste, resp);
      case resp of

      escape: ok:= true;

      return: begin
                 IniLeadBlank(instring);
                 if pos('.', instring) = 0 then
                 begin
                    instring:= instring + extn;
                 end;
	         HlpTestFileName(instring, ok, 10, 10, 40);
              end;

      end; {case resp of}
   until ok;
   if resp = escape then HlpGetFileName:= false
   else HlpGetFileName:= true;
end;

{******************************************************}
Procedure HlpText(x, xmax, y: integer; hinttext: string79; escwait: boolean);

var c: char;
    outstring: string79;
    temp1, temp2: boolean;

begin
   outstring:= ' Press [Esc] to continue ';
   hinttext:= ' ' + hinttext;
   IniExpand(outstring, xmax - x);
   IniExpand(hinttext, xmax - x);

   IniInversText(x, y, hinttext,frHigh);
   if escwait then
   begin
      IniInversText(x, y + 1, outstring,frHigh);
      repeat
	 c:= xReadKey(temp1, temp2);
      until c = chr(27);
      IniClearLine(x, y + 2, length(outstring), bkcolor);
   end
   else
   begin
      Delay(800);
   end;
   IniClearLine(x, y, length(outstring), bkcolor);
end;

{******************************************************}
Procedure HlpDemoText(x, xmax, y: integer);

var hinttext, outstring: string79;

begin
   Mausdunkel;
   HlpHintFrame(grminx+171, grmaxy - 22, grmaxx, grmaxy+32);
   txtfnt.write(grminx +208, grmaxy -5,
      'Not possible to open NEW files in Demo-Version',
      getcolor,sz8x16,stnormal);
   txtfnt.write(grminx + 208, grmaxy + 15,
       'Press [Esc] to continue and open TESTFILE.RNS',
       getcolor,sz8x16,stnormal);
end;

{******************************************************}
Procedure HlpHint(hintnum: integer; WaitTime: Integer);

var ymaxframe: integer;
    temp1, temp2: boolean;
    SPic : Pointer;
    SC : Byte;
    HintText : String;
begin
  SC:=GetColor;
  if WaitTime=0 then
    ymaxframe:= 48
  else
    ymaxframe:= 32;
  IF WaitTime>=0 Then Begin
    GetMem(SPic,ImageSize(grminx, grmaxy - ymaxframe-1, grMaxX, grmaxy+1));
    if SPic<>nil then
      GetImage(GrMinX, grmaxy - ymaxframe-1, GrMaxX, grmaxy+1,SPic^);
  End;
  HlpHintFrame(grminx, grmaxy - ymaxframe, Grmaxx, grmaxy);
  Case HintNum Of
    HntDivNotPossible: Begin
      HintText:='Division '+HintS1+':'+HintS2+' not possible';
    End;{HntDivNotPossible}
    HntPrintToFileFinished: Begin
      HintText:=HintTexts[HintNum]+' '+prfname+' in '+FExpand(psdir);
    End;
    Else
      HintText:=HintTexts[HintNum];
  End;{Case}
  txtfnt.write(grminx + 16, grmaxy - ymaxframe + 2*charheight, hinttext,getcolor,sz8x16,stnormal);
  if WaitTime=0 then begin
    txtfnt.write(grminx + 16, grmaxy - ymaxframe + 4*charheight,
              'Press [Esc] to continue',getcolor,sz8x16,stnormal);
    repeat until IniMausEscape = #27;
  end else begin
    Delay(WaitTime);
  end;
  PutImage(GrMinX, grmaxy - ymaxframe-1,SPic^,NormalPut);  {???}
  FreeMem(Spic,ImageSize(grminx, grmaxy - ymaxframe-1, grmaxx, grmaxy+1)); {???}
  SetColor(SC);
end;

{******************************************************}
Function HlpAreYouSure(hinttext: string79; position : byte): boolean;

begin
   {### Unterscheiden, damit Dir/File does not exist tiefer stehen kann}
{  !!!!!!!   'Press [Enter] or Y to continue, [PgUp] or [Esc] to cancel');}
{             Solange 'replace ?' (replace pattern mit dem gleichen Hint
              versehen wird, ist der folgende String leider richtiger:}
  case HlpAsk(hinttext,'Press [Y] to continue, [Esc] to cancel',position,
              ['Y',#13,#27,#73]) of
    'Y' : HlpAreYouSure:= True;
    #13 : HlpAreYouSure:= True;
    #27 : HlpAreYouSure:= False;
    #73 : HlpAreYouSure:= False;
  End;{Case HlpAsk of }
end;
{******************************************************}
Function HlpAskYesEsc(hinttext,choicetext: string79; position : byte) : boolean;
begin
  case HlpAsk(hinttext,choicetext,position,['Y',#13,#27,#73]) of
    'Y' : HlpAskYesEsc:= True;
    #13 : HlpAskYesEsc:= True;
    #27 : HlpAskYesEsc:= False;
    #73 : HlpAskYesEsc:= False;
  End;{Case HlpAsk of }
End;
Function HlpAsk(hinttext,choicetext: string79; position : byte;
                Resp : TCharSet) : char;
var c : char;
    ymax: integer;
    temp1, temp2: boolean;
    SPic : Pointer;
    m : Boolean;
    mem : integer;
begin
  XClearKbd;
  m:=not istdunkel;
  if m then Mausdunkel;
  case position of
    hpEdit : begin
      ymax:= grmaxy;
    end;
    hpUp : begin
      ymax:= grminy + 7
    end;
    hpFileMenu : begin
      ymax:=456;
    end;
    else begin
      ymax:=grmaxy;
    end;
  end;{case}
  mem:=ImageSize(grminx, ymax - 49, grmaxx, ymax+1);
  GetMem(SPic,mem);
  GetImage(grminx, ymax - 49, grmaxx, ymax+1,SPic^);
  HlpHintFrame(grminx, ymax - 48, grmaxx, ymax);
  txtfnt.write(grminx + 16, ymax - 34, hinttext,getcolor,sz8x16,stnormal);
  txtfnt.write(grminx + 16, ymax - 16,choicetext,getcolor,sz8x16,stnormal);
  mauszeigen;
  Repeat
    c:=IniMausEscape;
  Until c in Resp;
  HlpAsk:=c;
  Mausdunkel;
  PutImage(grminx, ymax - 49, SPic^,Normalput);
  FreeMem(SPic,mem);
  IF M Then Mauszeigen;
End;

{******************************************************}

Function HlpAskAny(Hinttext,choicetext: string79; position : byte) : Char;
Var Resp : TCharSet;
Begin
  Resp:=[#0..#$FF]-[' '];
  HlpAskAny:=HlpAsk(hinttext,choicetext,position,resp);
End;
{******************************************************}
Function HlpTxtAreYouSure(x, xmax, y: integer;
			  hinttext: string79): boolean;

var c : char;
    outstring: string79;
    temp1, temp2: boolean;

begin
   outstring:= '                   Press [Y] to continue - [Esc] to cancel';
   hinttext:= ' ' + hinttext;
   IniExpand(outstring, xmax - x);
   IniExpand(hinttext, xmax - x);

   IniInversText(x, y, hinttext,frHigh);
   IniInversText(x, y + 1, outstring,frHigh);
   repeat
      c:= xReadKey(temp1, temp2);
   until ((c = chr(27)) or (c = 'y') or (c = 'Y'));
   IniClearLine(x, y, length(outstring), bkcolor);
   IniClearLine(x, y + 1, length(outstring), bkcolor);

   if c = chr(27) then HlpTxtAreYouSure:= false
   else  HlpTxtAreYouSure:= true;
end;

{******************************************************}
Procedure HlpSymbolTable;

var y, i, blnum : integer;
    acolor: byte;
    sgrmaxy : Integer;
begin
   ImeInitSymbolMenus;
   ClearViewPort;

   SetBkColor(7{menubkcolor});

   SetColor(5);
   Line(stabxmin-4, stabymin-7 , stabxmax+4, stabymin-7 );
   Line(stabxmin-4, stabymin+19, stabxmax+4, stabymin+19);
   Line(stabxmin-4, stabymin-6 , stabxmin-4, stabymax+3 );
   Line(stabxmax div 2 +1, stabymin-6 , stabxmax div 2 +1, stabymax+3 );

   SetColor(12);
   Line(stabxmax div 2 -1, stabymin-7, stabxmax div 2 -1, stabymax+3);
   Line(stabxmax div 2   , stabymin-7, stabxmax div 2   , stabymax+3);
   Line(stabxmin-4, stabymin+17, stabxmax+4, stabymin+17);
   Line(stabxmin-4, stabymin+18, stabxmax+4, stabymin+18);

   MausBereich(stabxmin, stabxmax, stabymin, stabymax);
   GrDisplay_Menu(3 + sxmin, symin, SymbolMenu1, 2);
   GrDisplay_Menu(5 + sxmax div 2, symin, SymbolMenu2, 2);
   acolor:= GetColor;
   SetColor(symsymbolscolor);
   sgrmaxy:=grmaxy;
   grmaxy:=gmaxy;
   for i:= 1 to 13 do
   begin
      y:= stabymin + SymbolMenu1.menuattr.firstline * CharHeight +
	  3 + i*4*CharHeight;
      for blnum:= 1 to 3 do
      begin
	 DmeDispChar(stabxmin + 148 + blnum * 35, y,
		     SymbolMenu1.choices[i], blnum);
	 DmeDispChar(stabxmax div 2 + 152 + blnum * 35,
		     y, SymbolMenu2.choices[i], blnum);
      end;
   end;
   grmaxy:=sgrmaxy;
   SetColor(acolor);
end;

{******************************************************}
Procedure HlpSymbolSelect(var c: char);

var symbolnum, choicenum : byte;
    movedir : movement;
    mausx, mausy, maustaste, mausmenu: word;
    SMBKC : Byte;
begin
   SMBKC:=MenuBkColor;
   MenuBkColor:=7;
   HlpSymbolTable;
   maustaste:= 0;
   if ord(c) <= 109 then
   begin
      symbolnum:= 1;
      choicenum:= ord(c) - 96;
   end
   else
   begin
      symbolnum:= 2;
      choicenum:= ord(c) - 109;
   end;
{   GrDisplay_Menu(3 + sxmin, symin, SymbolMenu1, 2);
   GrDisplay_Menu(5 + sxmax div 2, symin, SymbolMenu2, 2);
 }
   repeat
      if symbolnum = 1 then
      begin
         GrGet_Menu_Response(3 + sxmin, symin, SymbolMenu1, c,
                             movedir, choicenum, mausx, mausy,
                             maustaste, mausmenu, true, 2);
      end
      else
      begin
         GrGet_Menu_Response(5 + sxmax div 2, symin, SymbolMenu2, c,
                             movedir, choicenum, mausx, mausy,
                             maustaste, mausmenu, true, 2);
      end;

      if ((movedir = left) or (movedir = right)) then
      begin
         symbolnum:= ord(movedir);
      end;

   until ((c = chr(27)) or ((movedir <> left) and (movedir <> right)));
   MenuBkColor:=SMBKC;
end;

{******************************************************}
Procedure HlpCommandTable;

const xmin = 1;
      xmax = 80;
      ymin = 1;
      ymax = 30;
      tminx = 9;
      tminy = 3;
      fA = 19;
      SA = 37;
      Ta = 54;
      MaxY = 480;
      MinX = 0;
      MinY = 0;
{ * * * * * * * * }
Const nminx = 0;         { Screen frame                 }
      nminy = 0;
      nmaxx = 639;
      nmaxy = 479;

      ominy= nminx;     { vert. Trennlinien oben        }
      omaxy= 380;

      o1x  = 77;        { 1. vert. Trennlinie oben      }
      o2x  = 213;       { 2. vert. Trennlinie oben      }
      o3x  = 357;       { 3. vert. Trennlinie oben      }
      o4x  = 499;       { 4. vert. Trennlinie oben      }

      uminy= omaxy+3;   { vert. Trennlinien oben        }
      umaxy= nmaxy;

      u1x  = 317;       { 1. vert. Trennlinie unten     }
      u2x  = 445;       { 2. vert. Trennlinie unten     }

      h1y  = 28;        { 1. hor.  Trennlinie           }
      h2y  = uminy;     { 2. hor.  Trennlinie           }

      keyy = 14;        { shift/ctrl/alt... keys        }

      keysx = 17;       { 'Keys'                        }
      keyx  = 161;      { 'Key'                         }

      shftkeyx= 225;    { 'Shift + Key'                 }
      shftofs1= 64;
      shftofs2= 80;

      ctrlkeyx= 369;    { 'Ctrl + Key'                  }
      ctrlofs1= 59;
      ctrlofs2= 78;

      altkeyx = 511;    { 'alt + Key'                  }
      altofs1 = 64;
      altofs2 = 80;

var c : char;
    i : byte;
    textst1, textst2, textst3, textst4, stri : string79;
begin
   SetBkColor(7{menubkcolor}); {bei einer andern Farbe mÅssten Schatten rechts und unten definiert werden!}
   {-----------}
   SetColor(5{imenutextcolor});

   Line(nminx, nminy,   nmaxx, nminy); { oberer Rand                    }
   Line(nminx, nminy+1, nminx, nmaxy); { linker Rand                    }

   Line(o1x,oMinY,o1x,omaxY);          { 1. vert. Trennlinie oben       }
   Line(o2x,oMinY,o2x,omaxY);          { 2. vert. Trennlinie oben       }
   Line(o3x,oMinY,o3x,omaxY);          { 3. vert. Trennlinie oben       }
   Line(o4x,oMinY,o4x,omaxY);          { 4. vert. Trennlinie oben       }

   Line(u1x,uminy,u1x,umaxy);          { 1. vert. Trennlinie unten      }
   Line(u2x,uminy,u2x,umaxy);          { 2. vert. Trennlinie unten      }

   Line(nminx,h1y,nmaxx,h1y);          { 1. hor.  Trennlinie            }
   Line(nminx,h2y,nmaxx,h2y);          { 2. hor.  Trennlinie            }
   {-----------}
   SetColor(12);

   Line(o1x-2,ominy,o1x-2,omaxy);       { 1.vert. Trennlinie o.Schatten }
   Line(o1x-1,ominy,o1x-1,omaxy);       { 1.vert. Trennlinie o.Schatten }

   Line(o2x-2,ominy,o2x-2,omaxy);       { 2.vert. Trennlinie o.Schatten }
   Line(o2x-1,ominy,o2x-1,omaxy);       { 2.vert. Trennlinie o.Schatten }

   Line(o3x-2,ominy,o3x-2,omaxy);       { 3.vert. Trennlinie o.Schatten }
   Line(o3x-1,ominy,o3x-1,omaxy);       { 3.vert. Trennlinie o.Schatten }

   Line(o4x-2,ominy,o4x-2,omaxy);       { 4.vert. Trennlinie o.Schatten }
   Line(o4x-1,ominy,o4x-1,omaxy);       { 4.vert. Trennlinie o.Schatten }

   Line(u1x-2,uminy,u1x-2,umaxy);       { 1.vert. Trennlinie u.Schatten }
   Line(u1x-1,uminy,u1x-1,umaxy);       { 1.vert. Trennlinie u.Schatten }

   Line(u2x-2,uminy,u2x-2,umaxy);       { 1.vert. Trennlinie u.Schatten }
   Line(u2x-1,uminy,u2x-1,umaxy);       { 1.vert. Trennlinie u.Schatten }

   Line(nminx,h1y-2,nmaxx,h1y-2);       { 1. hor. Trennlinie Schatten   }
   Line(nminx,h1y-1,nmaxx,h1y-1);       { 1. hor. Trennlinie Schatten   }

   Line(nminx,h2y-2,nmaxx,h2y-2);       { 2. hor. Trennlinie Schatten   }
   Line(nminx,h2y-1,nmaxx,h2y-1);       { 2. hor. Trennlinie Schatten   }

   SetColor(menutextcolor);
   {-------------------------------------------------------------------------}
   IniWriteXY    (keysx,keyy,' Keys');

   IniSpacedWrite(keyx,keyy,' Key ',frHigh);

   IniSpacedWrite(shftkeyx,keyy,' Shift ',frHigh);
   IniWriteXY    (shftkeyx+shftofs1,keyy,'+');
   IniSpacedWrite(shftkeyx+shftofs2,keyy,' Key ',frHigh);

   IniSpacedWrite(ctrlkeyx,keyy,' Ctrl ',frHigh);
   IniWriteXY    (ctrlkeyx+ctrlofs1,keyy,'+');
   IniSpacedWrite(ctrlkeyx+ctrlofs2,keyy,' Key ',frHigh);

   IniSpacedWrite(altkeyx,keyy,'  Alt  ',frHigh);
   IniWriteXY    (altkeyx+altofs1,keyy,'+');
   IniSpacedWrite(altkeyx+altofs2,keyy,' Key ',frHigh);

   for i:= 1 to 27 do
   begin
      if i <= 12 then
      begin
         IF i>9 Then
           Stri:='1'+char(i+38)
         Else
           Stri:=' '+Char(i+48);
	 inispacedtext(tminx - 7, tminy+(i*2),'  F' + stri + '  ',frHigh);
      end
      else
      begin
	 case i of
{           11:;
            12:;
            13:}
	    13: iniSpacedtext(tminx - 7, tminy+(i*2),'  '+#27+'ƒƒŸ ',frHigh);
	    14: iniSpacedtext(tminx - 7, tminy+(i*2),'  Home ',frHigh);
            15: iniSpacedtext(tminx - 7, tminy+(i*2),'  End  ',frHigh);
	    16: iniSpacedtext(tminx - 7, tminy+(i*2),'  PgUp ',frHigh);
	    17: iniSpacedtext(tminx - 7, tminy+(i*2),'  PgDn ',frHigh);
	    18: iniSpacedtext(tminx - 7, tminy+(i*2),'  '+#27+'ƒ   ',frHigh);
	    19: iniSpacedtext(tminx - 7, tminy+(i*2),'  Del  ',frHigh);
	    20: iniSpacedtext(tminx - 7, tminy+(i*2),'  Ins  ',frHigh);
            21: iniSpacedtext(tminx - 7, tminy+(i*2),'  Tab  ',frHigh);
{            21:;}
{            22: iniSpacedtext(tminx - 7, tminy+(22*2),' Others ',frHigh); }
{            23:;
            24:;
            25:;
            26:;
            27:;}
	 end;
      end;

      textst1:='';
      textst2:='';
      textst3:='';
      textst4:='';

      case i of
      1 : begin
	     textst1:=' this help table';
	     textst2:=' show   / hide';
	     textst3:=' print';
	     textst4:=' vertical  { begin';
	  end;

      2 : begin
	     textst1:=' save      file';
             textst2:=' save   / nosave ?';
             {  if not (setuppage in actedit) then } {new, herausgenommen}
	     begin
		textst3:=' split     file';
	     end;
	     textst4:=' vertical  { end';
	  end;

      3 : begin
	     textst1:=' noteline  insert';
	     textst2:=' noteline define';
	     textst3:=' split     line';
	     textst4:=' horizont. { begin';
	  end;

      4 : begin
	     textst1:=' spaceline insert';
	     textst2:=' insert   page';
	     textst3:=' split     page';
	     textst4:=' horizont. { end';
	  end;

      5 : begin
	     textst1:=' sound     play ';
	     textst2:=' sound    options';
	     textst3:=' symbol(s) sound '; {auch ins Shift-F5 Menu nehmen!}
	     textst4:=' vertical    line';
	  end;

      6 : begin
	     textst1:=' header +/ footer';
	     textst2:=' search + replace';
             textst3:=' search    repeat';
	     textst4:=' vert. short line';
	  end;

      7 : begin
	     textst1:=' copy      line';
	     textst2:=' line     commands';
	     textst3:=' paste     line ';
	     textst4:=' horiz. 3D - line';
	  end;

      8 : begin
	     textst1:=' mark/undo block';
	     textst2:=' block    commands';
	     textst3:=' paste     block';
             textst4:=' vert.  3D - line';
	  end;

      9 : begin
	     textst1:=' mark/undo page';
	     textst2:=' page     commands';
             textst3:=' paste     page';
             textst4:=' setup   new page';
	  end;

     10 : begin
             textst1:=' symbols   table';
	     textst2:=' keyboard swap';
             textst3:=' change    font';
	     textst4:=' number of   page';
	  end;

     11 : begin
             textst1:=' statusbar/mousemenu';
          end;

     12 : begin
             textst1:=' refresh   page';
          end;

     13 : begin
             textst1:=' next  noteline';
             textst2:=' next textline  ';
             textst3:=' equal noteline below';
          end;

     14 : begin
	     textst1:=' begin of  line';
	 {    textst2:=' first    noteline';   }
	     textst3:=' begin of  page';
	  end;

     15 : begin
	     textst1:=' end   of  line';
	{     textst2:=' last     noteline';  }
	     textst3:=' end   of  page';
	  end;

     16 : begin
	   { if not (setuppage in actedit) then} {new, herausgenommen}
	     begin
		textst1:=' previous  page';
                textst2:=' join     next page';
		textst3:=' first     page';
 	     end;
	  end;

     17 : begin
	 {   if not (setuppage in actedit) then} {new, herausgenommen}
	     begin
		textst1:=' next      page';
                textst2:=' add  new page at end';
		textst3:=' last      page';
	     end;
	  end;

     18 : begin
	     textst1:=' backspace';
	     textst2:=' del to   line begin';
             textst3:=' delete    line';
	  end;

     19 : begin
	     textst1:=' symb/char delete';
             textst2:=' del to   line end';
             textst3:=' delete    block/page';
             textst4:='';
          end;

     20 : begin
	     textst1:=' symb/char insert';
	     textst2:=' undelete line';
             textst3:=' undelete  block/page';
	  end;

     21 : begin
	     textst1:=' lower     tab   ';
             textst2:=' upper    tab   ';
             textst3:='               ';
          end;

     23 : begin
             IniSpacedText(tminx-7    , tminy+(i*2),'1',frHigh);
             IniOutTextXY (tminx-7+1  , tminy+(i*2),'  to');
             IniSpacedText(tminx-7+5  , tminy+(i*2),'9',frHigh);
             IniOutTextXY (tminx-7+6  , tminy+(i*2),' , ');
             IniSpacedText(tminx-7+9  , tminy+(i*2),'010',frHigh);
             IniOutTextXY (tminx-7+12 , tminy+(i*2),' to');
             IniSpacedText(tminx-7+15 , tminy+(i*2),'099',frHigh);
             IniOutTextXY (tminx-7+18 , tminy+(i*2),'  pulse(s)* per beat');

             iniSpacedtext(tminx + SA-4  , tminy+(i*2),'Space',frHigh);
             IniOutTextXY (tminx + SA-4+5, tminy+(i*2),' pause mark');

             iniSpacedtext(tminx + TA-5  , tminy+(i*2),'-',frHigh);
             IniOutTextXY (tminx + TA-5+1, tminy+(i*2),'  +');
             iniSpacedtext(tminx + TA-5+4, tminy+(i*2),'2 symbols',frHigh);
             IniOutTextXY (tminx + TA-5+13,tminy+(i*2),'  flam(-)');

          end;

     24 : begin
             iniSpacedtext(tminx-7    , tminy+(i*2),'<',frHigh);
             IniOutTextXY (tminx-7+ 1 , tminy+(i*2),'  or');
             iniSpacedtext(tminx-7+ 5 , tminy+(i*2),'>',frHigh);
             IniOutTextXY (tminx-7+ 6 , tminy+(i*2),'  +');
             iniSpacedtext(tminx-7+ 9 , tminy+(i*2),'pulse',frHigh);
             IniOutTextXY (tminx-7+ 14, tminy+(i*2),' *');
             IniOutTextXY (tminx-7+18 , tminy+(i*2),'  insert subpulses to L/R');

             iniSpacedtext(tminx + SA-4  , tminy+(i*2),',',frHigh);
             IniOutTextXY (tminx + SA-4+5, tminy+(i*2),' time  mark');

             iniSpacedtext(tminx + TA-5   , tminy+(i*2),'=',frHigh);
             IniOutTextXY (tminx + TA-5+1 , tminy+(i*2),'  +');
             iniSpacedtext(tminx + TA-5+4 , tminy+(i*2),'2 symbols',frHigh);
             IniOutTextXY (tminx + TA-5+13,tminy+(i*2),'  unisono');

	  end;


     25 : begin

             iniSpacedtext(tminx-7    , tminy+(i*2),'<',frHigh);
             IniOutTextXY (tminx-7+ 1 , tminy+(i*2),'  or');
             iniSpacedtext(tminx-7+ 5 , tminy+(i*2),'>',frHigh);
             IniOutTextXY (tminx-7+ 6 , tminy+(i*2),'  +');
             iniSpacedtext(tminx-7+ 9 , tminy+(i*2),':',frHigh);
             IniOutTextXY (tminx-7+10 , tminy+(i*2),' +');
             iniSpacedtext(tminx-7+12 , tminy+(i*2),'number',frHigh);
             IniOutTextXY (tminx-7+18 , tminy+(i*2),'  devide pulse to L/R by');

             iniSpacedtext(tminx + SA-4  , tminy+(i*2),'.',frHigh);
             IniOutTextXY (tminx + SA-4+5, tminy+(i*2),' help  mark');

             iniSpacedtext(tminx + TA-5   , tminy+(i*2),'+',frHigh);
             IniOutTextXY (tminx + TA-5+1 , tminy+(i*2),'  +');
             iniSpacedtext(tminx + TA-5+4 , tminy+(i*2),'2 symbols',frHigh);
             IniOutTextXY (tminx + TA-5+13,tminy+(i*2),'  flam(+)');

	  end;

     26 : begin
	   { if not (setuppage in actedit) then} {new, herausgenommen}
	     begin
                iniSpacedtext(tminx-7    , tminy+(i*2),'symbol',frHigh);
                IniOutTextXY (tminx-7 +6 , tminy+(i*2),'  +');
                iniSpacedtext(tminx-7 +9 , tminy+(i*2),'(',frHigh);
                IniOutTextXY (tminx-7 +10, tminy+(i*2),' ');
                iniSpacedtext(tminx-7 +11, tminy+(i*2),')',frHigh);
                IniOutTextXY (tminx-7 +12, tminy+(i*2),' or');
                iniSpacedtext(tminx-7 +15, tminy+(i*2),'[',frHigh);
                IniOutTextXY (tminx-7 +16, tminy+(i*2),' ');
                iniSpacedtext(tminx-7 +17, tminy+(i*2),']',frHigh);
                IniOutTextXY (tminx-7 +18, tminy+(i*2),'  drop/add,');

                IniOutTextXY (tminx-7 +26, tminy+(i*2),' +');
                iniSpacedtext(tminx-7 +28, tminy+(i*2),'{',frHigh);
                IniOutTextXY (tminx-7 +29, tminy+(i*2),' ');
                iniSpacedtext(tminx-7 +30, tminy+(i*2),'}',frHigh);
                IniOutTextXY (tminx-7 +31, tminy+(i*2),'  altern.');

             iniSpacedtext(tminx + TA-5,    tminy+(i*2),'*',frHigh);
             IniOutTextXY (tminx + TA-5+1,  tminy+(i*2),'  +');
             iniSpacedtext(tminx + TA-5+4,  tminy+(i*2),'1(2)symb.',frHigh);
             IniOutTextXY (tminx + TA-5+13, tminy+(i*2),'  below line');

             iniSpacedtext(tminx + SA-4  , tminy+(i*2),'›',frHigh);
             iniSpacedtext(tminx + SA-4+2, tminy+(i*2),'\',frHigh);
             IniOutTextXY (tminx + SA-4+5, tminy+(i*2),' jump  marks');
 	     end;
	  end;

     27 : begin
	 {   if not (setuppage in actedit) then} {new, herausgenommen}
	     begin
             iniSpacedtext(2 , tminy+(i*2)+1,'  Esc  ',frHigh);
             IniOutTextXY (9 , tminy+(i*2)+1,'  or             Quit');
             iniSpacedtext(13, tminy+(i*2)+1,'mouse R',frHigh);

             iniSpacedtext(tminx + SA-4  , tminy+(i*2),'/',frHigh);
             IniOutTextXY (tminx + SA-4+5, tminy+(i*2),' end   mark');

	     end;


             iniSpacedtext(tminx + TA-5  , tminy+(i*2),'&',frHigh);
             iniSpacedtext(tminx + TA-5+2, tminy+(i*2),'"',frHigh);
             IniOutTextXY (tminx + TA-5+4, tminy+(i*2),'repeat marks');

	  end;


      end; {case i of}

      IniOutTextXY(tminx + 2 ,   tminy+(i*2),textst1);
      IniOutTextXY(tminx + FA,   tminy+(i*2),textst2);
      IniOutTextXY(tminx + SA,   tminy+(i*2),textst3);
      IniOutTextXY(tminx + TA+1, tminy+(i*2),textst4);
   end;
end;
end.
