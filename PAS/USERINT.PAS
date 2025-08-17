unit userint;

interface

Uses menutyp,
     inout,
     graphmenu,
     grinout,
     imenuunit,
     initsc,
     getunit,
     dos,
     graph,
     editunit,
     symbols,
     helpunit,
     printunit,
     gcurunit,
     sdunit,
     titleunit,
     crt,
     UserExit,
     Strings,
     Texts;

var demoversion: boolean;

Procedure UseTopMenu;

implementation

uses grintunit,
     mousdrv,
     fileunit;

Type PTextBuf = ^TTextBuf;
     TTextBuf = Array[0..127] of Char;
     TTextRec = Record
       Handle    : Word;
       Mode      : Word;
       BufSize   : Word;
       Private   : Word;
       BufPos    : Word;
       BufEnd    : Word;
       BufPtr    : PTextBuf;
       OpenFunc  : Pointer;
       InOutFunc : Pointer;
       FlushFunc : Pointer;
       CloseFunc : Pointer;
       UserData  : Array[1..16] of Byte;
       Name      : Array[0..79] of Char;
       Buffer    : TTextBuf;
     End;

const topstartx = 2;
      topstarty = 1;
      topendx = 21;
      topendy = 29;
      substartx = 23;
      substarty = 1;
      subendx = 80;
      subendy = 30;
      sdxmin = 25;
      sdymin = 5;
      sdxmax = 78;
      sdymax = 22;
      sdcol = 3;

Var CLS,CLE: byte;

{******************************************************}

Procedure KillCursor;
begin
   { TODO: Implement cursor hiding functionality }
   { Original: INT 10h function 3 (get cursor) then function 1 (set cursor invisible) }
   CLS := 0; { Save current cursor start line }
   CLE := 0; { Save current cursor end line }
   { Stub: Cursor visibility control not implemented }
end;
{********************************************************}

Procedure RestoreCursor;
begin
   { TODO: Implement cursor restoration functionality }
   { Original: INT 10h function 1 (set cursor) with saved CLS/CLE values }
   { Stub: Cursor visibility control not implemented }
end;
{******************************************************}
Procedure UseGetConfig;
{Liest die Configuration aus dem File CONFIG.rns}

Procedure SearchADir(Var S : String);
Var F : SearchRec;
Begin
  S:='*.*';
  FindFirst(S,Directory,F);
  While (((F.Attr And Directory)=0) Or (F.Name='.') Or
         (F.Name='..') Or (F.Name='')) And (DosError=0) Do
    FindNext(F);
  S:=F.Name;
End;
var
   infile: text;
   b: byte;
   actdir : string;
begin
  GetDir(0,actdir);
  Assign(infile, 'config.rns');
  LastFileName:=FExpand('CONFIG.RNS');
  reset(infile);
  readln(infile, datadir);
  {$I-}
  ChDir(DataDir);
  {$I+}
  IF IOResult<>0 Then Begin
    SearchADir(Datadir);
  End Else
    ChDir(ActDir);
  readln(infile, colorfile);
  readln(infile, psdir);
  readln(infile, bufdir);
  close(infile);
  b:=pos('.',datadir);
  if (b=length(datadir)) and (b<>0) then
    datadir:=copy (datadir,1,b-1) + copy(datadir,b+1, length(datadir)-b-1);
  if Not IniDirExist(datadir) then begin
  {$I-}
    MkDir(datadir);
    IF IOResult<>0 Then RunError(IOResult);
  {$I+}
  end;
  if psdir='' then
    psdir:='PSFILES';
  if bufdir='' then
    bufdir:='BUFFERS';
  {$I-}
  if not IniDirExist(psdir) then
    MkDir(psdir);
  IF IOResult<>0 Then RunError(IOResult);
  if not IniDirExist(bufdir) then
    MkDir(bufdir);
  IF IOResult<>0 Then RunError(IOResult);
  {$I+}
  ChDir(ActDir);
end;

{******************************************************}
Procedure UseSaveConfig;
{Speichert die Configuration in das File CONFIG.rns}

var
   outfile: text;

begin
   Assign(outfile, 'config.rns');
   LastFileName:=FExpand('CONFIG.RNS');
   rewrite(outfile);
   writeln(outfile, datadir);
   writeln(outfile, colorfile);
   writeln(outfile, psdir);
   writeln(outfile, bufdir);
   close(outfile);
end;

{******************************************************}
procedure UseGetSetup;
{Liest das setup-file}

var infile: text;
    inblock: stringline;
    tempattr: lineattrtype;

begin
   FilAssignRnsFile(infile,'setup', true);
   {Aktuelle Attribute lesen}
   readln(infile, inblock);
   GetNoteBlock(inblock, tempattr, 1);
   readln(infile, insmusicline);
   actattr:= tempattr;
   readln(infile, linecount);
   readln(infile, dispspec, dispgrid, disphidlines, dispcurs,
          manset, charset, blankset);
   readln(infile, prformat, prdest);
   readln(infile, prfname);
   IniLeadBlank(prfname);
   readln(infile, prfile);
   readln(infile, prdevice);
   IniLeadBlank(prdevice);
   readln(infile, sndlength, sndlengthper, sndplaybeat, sndplaypulse, dispsound);
   readln(infile, sndchar);
   readln(infile, sndbeat, sndbeatlength);
   readln(infile, sndpulse, sndpulselength);
   readln(infile, fontfile);
   readln(infile, sndlengthspm);{New}
   readln(infile, ctrlenterofs);
   readln(infile, sndwarning);
   readln(infile, dispslash);
   if sndwarning<1 then
     sndwarning:=1;
   if ctrlenterofs=0 Then
     ctrlEnterOfs:=2;
   if dispslash<1 then
     dispslash:=1;
   close(infile);
end;

{******************************************************}
procedure UseSaveSetup;
{speichert das Setup-File}

var infile: text;

begin
   FilAssignRnsFile(infile,'setup', false);
   {Aktuelle Attribute schreibenlesen}
   LastFileName:=FExpand(TextRec(infile).Name);
   writeln(infile, '          ',
           actattr.beats:5, actattr.eint:5, actattr.resolution:5,
           actattr.linestyle:5);
   writeln(infile, insmusicline);
   writeln(infile, '          ',
           linecount:5);
   writeln(infile, '          ',
           dispspec:3, dispgrid:3, disphidlines:3, dispcurs:3,
           manset:3, charset:3, blankset:3);
   writeln(infile, prformat: 3, prdest: 3);
   writeln(infile, prfname);
   writeln(infile, prfile: 3);
   writeln(infile, prdevice:3);
   writeln(infile, sndlength:5, sndlengthper:3,sndplaybeat:3,
           sndplaypulse:3, dispsound: 3);
   writeln(infile, sndchar);
   writeln(infile, sndbeat :6, sndbeatlength:6);
   writeln(infile, sndpulse:6, sndpulselength:6);
   writeln(infile, fontfile);
   writeln(infile, sndlengthspm:12);{New}
   writeln(infile, ctrlenterofs:3);
   writeln(infile, sndwarning:3);
   writeln(infile, dispslash:3);
   close(infile);

end;

{************************************************************}
Procedure UseFileName(var instring: string79; var c: char;
                      var mausx, mausy, maustaste, mausmenu: word);

Var
    resp : response_type;
    dir : movement;
    KeyResp : Char;
    ok : boolean;
    oldstring: string79;
    demloc: boolean;
    changed : boolean;
begin
   MausBereichAdd(8*substartx, 8*subendx,
                  8*substarty, 8*(substarty+4), 1);
{   MausBereichAdd((sdxmin-1)*8, sdxmax*8,
                  (sdymin-2)*16, (sdymax+sdymin+2)*16, 3);}
   MausBereichAdd(8*substartx, 8*subendx,
                  8*(substarty+4)+1,(sdymax+sdymin+2)*16, 3);
   IniSpacedText(substartx,substarty+1,{Rahmen zeichnen}
   ' Active File [max 8 (.rns)]:                             ',frLow);
   IF Not IniFileExist(datadir+'\'+instring) Then
     instring:='';
   oldstring:= instring;
   c:= chr(0);
   maustaste:= 0;
   IniSpacedText(substartx, (subendy-1)*2,
              ' [Enter] (last name) - new name, cursor+[Enter] or [Esc] '
              ,frLow);
   SduSodir(True, ok, false, instring,'*.RNS *.BUF', datadir+'\',false,
            sdxmin*8-4,sdymin*16-8,sdymax,sdcol,
            mausx,mausy,maustaste,mausmenu,0,0,true);
   demloc:= demoversion;
   Mauszeigen;
   Repeat
      maustaste:= 0;
      instring:= oldstring;
      GrGet_Prompted_Spaced_String(instring, fieldlength, '>',
                            substartx + 30 + fieldlength, substarty +1,
                            substartx+ 29,
                            '',
                            substartx + 29, substarty + 1,
                            subendx - substartx - 2*fieldlength - 32,
                            resp, dir, Keyresp, true,
                            mausx, mausy, maustaste, mausmenu,changed);
      Instring:=UpString(InString);
      ok:= false;
      IniMausAssign(maustaste, resp);
      if ((maustaste > 0) and (resp <> escape)) then
      case mausmenu of
        1: begin {Filetitel}
          resp:= return;
        end;
        2: begin {???}
          resp:= no_response;
        end;
        3: begin {Files}
          resp:= arrow;
          dir:= down;
        end;
      end;
{      begin
         if mausmenu = 2 then
         begin
            resp:=return;
         end
         else
         begin
            if mausmenu = 3 then
            begin
               resp:= arrow;
               dir:= down;
            end
            else
            begin
               if mausmenu = 1 then
               begin
                 resp:=no_response;
               end;
            end;
         end;
      end; }

      case resp of

      escape: ok:= true;

      return: begin
                 ok:=true;
                 if (instring = '') Or (instring = '   .   ') then
                   if oldstring='' Then
                     ok:=false
                   Else
                     instring:= oldstring;
                 IniLeadBlank(instring);
                 if pos('.', instring) = 0 then
                 begin
                    instring:= instring + '.RNS';
                 end;
                 if ok then     { G�ltiger Filename? }
                    HlpTestFileName(datadir + '\' + instring, ok,
                                 substartx, subendx, substarty + 6);
                 if ok then
                 begin
                   if not IniFileExist(datadir + '\' +instring) then begin
                     if demloc then begin
                       instring:='TESTFILE.RNS';
{                       ok:= false;
                       HlpDemoText(substartx, subendx, substarty + 6);}
                     end else begin
                       ok:=HlpAreYouSure('File ' + datadir + '\' + instring + ' does not exist',hpFileMenu);
                     end;
                   end; {if not IniFileExist(datadir + '\' +instring) then}
                 end; {if ok then}
{                 if not ok then
                   SduSodir(True, ok, false, instring,'*.RNS', datadir+'\',false,
                    sdxmin*8-4,sdymin*16-8,sdymax,sdcol,
                    mausx,mausy,maustaste,3,0,0,true);}
             End;
      arrow: begin
                if dir = down Then
                   SduSodir(false, ok, true, instring,'*.RNS *.BUF',datadir+'\',
                            false,sdxmin*8-4,sdymin*16-8,sdymax,sdcol,
                            mausx,mausy,maustaste,3,0,0,true);
             end;
      specialkey: begin
                     if KeyResp = #81 Then Begin
                       SduSodir(false, ok, true, instring,'*.RNS *.BUF',datadir+'\',
                                false,sdxmin*8-4,sdymin*16-8,sdymax,sdcol,
                                mausx,mausy,maustaste,3,0,0,true);
                     end;
                  end;
      end; {case resp of}
   until ok;
   if resp = ESCAPE then c:= #27;
end;

{************************************************************}
Procedure UseDirName(var mausx, mausy, maustaste, mausmenu: word);

Var
    resp : response_type;
    dir : movement;
    KeyResp : Char;
    ok, demloc : boolean;
    instring: string79;
    actdir : string79;
    b: byte;
    st: string;
    changed : boolean;
begin
  IniSpacedText(substartx,substarty+1,
  ' Active Directory [8(.+3)]:                              ',frLow);
  maustaste:= 0;
  IniSpacedText(substartx, (subendy-1)*2,
             ' [Enter] (last name) - new name, cursor+[Enter] or [Esc] ',
             frLow);
  MausBereichAdd(8*substartx, 8*subendx,
                 8*substarty, 8*(substarty+1), 2);
  MausBereichAdd(8*substartx, 8*subendx,
                 8*(substarty+4)+1,(sdymax+sdymin+2)*16, 3);
{  MausBereichAdd((sdxmin-1)*8, sdxmax*8,
                 (sdymin-1)*16, (sdymax+sdymin-1)*16+8, 3);}
  SduSodir(True, ok, false, instring,'*.*','',true,
           sdxmin*8-4,sdymin*16-8,sdymax,sdcol,
           mausx, mausy, maustaste, 3, 0, 0,True);
  demloc:= demoversion;
  datadir:=upstring(datadir);
  Repeat
     instring:= datadir + '\';
     GrGet_Prompted_Spaced_String(instring, fieldlength, '>',
                           substartx + 30 + fieldlength, substarty + 1,
                           substartx + 28,
                           ''{Active Directory [max 8]: '},
                           substartx + 28, substarty + 1,
                           subendx - substartx - 2*fieldlength - 2-27{30},
                           resp, dir, Keyresp, true,
                           mausx, mausy, maustaste, mausmenu,changed);
     Instring:=UpString(Instring);
     if pos('\', instring)=length(instring) then
        instring:= copy(instring,1,length(instring)-1);
     ok:= false;
     IniMausAssign(maustaste, resp);

     if demloc then begin
       ok:= true;
     end else begin
       case resp of
         escape: ok:= true;
         return: begin
           IniLeadBlank(instring);
           if ((mausmenu = 2) or (maustaste = 0)) then begin
             if instring='' then begin
               instring:=datadir;
               ok:=true;
             end else if instring = '..' then begin
               getdir(0,actdir);
               if Length(actdir)<=3 then
                 instring:= datadir+'..\';
                 ok:=true;
             end else if instring = '.' then begin
               instring:=datadir;
               ok:=true;
             end else if instring = '\' then begin
               instring:='\';
               ok:=true;
             end else begin
               if pos(':',instring)=2 then begin
                 instring:='';
                 ok:=false;
                 HlpText(substartx, subendx, substarty+6, 'Illegal name for data directory',true);
                 SduSodir(true,ok,false,instring,'*.*','',true,
                          sdxmin*8-4,sdymin*16-8,sdymax,
                          sdcol,mausx,mausy,maustaste,3,0,0,true);
               end else begin
                 if (pos(':',instring)<>0) or
                    (pos('\',instring)<>0) or
                    (pos(#9,instring)<>0) or
                    ((pos('.',instring)=pos('\',instring)+1)) or
                    ((pos('.',instring)=pos('\',instring)-1)) or
                    (pos('..',instring)<>0) or
                    (pos('*',instring)<>0) or
                    (pos('?',instring)<>0) then
                   instring:=datadir;
                 if (instring<>'') and IniDirExist(instring) then begin
                   datadir:= instring;
                   ok:= true;
                 end else begin
                   {$I-}MkDir(instring);{$I+}
                   if IOResult = 0 then begin
                     if HlpAreYouSure('Directory "' +instring +'\" does not exist',hpFileMenu) then begin
                       datadir:= instring;
                       ok:= true;
                     end else begin
                       RmDir(instring);
                       SduSodir(true,ok,false,instring,'*.*','',true,
                                sdxmin*8-4,sdymin*16-8,sdymax,sdcol,
                                mausx,mausy,maustaste,3,0,0,true);
                     end;
                   end else begin
{                      SduClearWin(sdxmin, sdymin, sdxmax, sdymax);}
                     HlpText(substartx, subendx, substarty + 6,
                             'Illegal name for data directory', true);
                     SduSodir(true, ok, false, instring, '*.*','',true,
                              sdxmin*8-4, sdymin*16-8, sdymax, sdcol,
                              mausx, mausy, maustaste, 3, 0, 0,True);
                   end;
                 end;{if inidirexist else}
               end;{if pos(':'...=2 else}
             end;{if instring = '\' else}
           end {if mausmenu = 2}else begin
             if mausmenu = 3 then begin
               SduSodir(false, ok, true, instring, '*.*','',true,
                        sdxmin*8-4, sdymin*16-8, sdymax, sdcol,
                        mausx, mausy, maustaste, 3, 0, 0,True);
               if ok then datadir:= instring;
             end else begin
               ok:= true;
               resp:= escape;
             end;
           end;
         end;{case of return}
         arrow: begin
           if dir = down then begin
             SduSodir(false, ok, true,instring, '*.*','',true,
                      sdxmin*8-4, sdymin*16-8, sdymax, sdcol,
                      mausx, mausy, maustaste, 3, 0, 0,True);
             if ok then datadir:= instring;
           end;
         end;{case of arrow}
       end; {case resp of}
     end; {else if demoversion}

  until ok;
  if resp = ESCAPE then
  begin
    mausx:=0;
    mausy:=0;
    maustaste:=0;
    mausmenu:=0;
  end
  else
  begin    {new}
     if (mausx=0) and (mausy=0) and (maustaste=0) and (mausmenu=0) then
       mausx:=1;
     b:= pos('.',datadir);
     if (b=length(datadir)) and (b<>0) then
        datadir:= copy(datadir,1,b-1) + copy (datadir,b+1, length(datadir) -b-1);
     instring:= datadir;
     st:= ' Loading Directory ' + datadir + '\                                             ';
     st[0]:=#57;
     IniSpacedText(substartx, topendy*2, st,frHigh);
     UseGetConfig;
     datadir:= instring;
  end;
end;

{************************************************************}
Procedure UseFontSelect(var mausx, mausy, maustaste, mausmenu: word);

const hy = 25;

Var
    ok : boolean;
    instring: string79;

begin
   maustaste:= 0;

   Instring:=' Active Font: ' + fontfile;
   IniExpand(instring,57);
   IniSpacedText(substartx, substarty*2,instring,frLow);

   IniSpacedText(substartx, (subendy-1)*2,
              ' Use cursor+[Enter] or [Esc]                             ',
              frLow);
   MausBereichAdd(8*substartx, 8*subendx,
                  8*substarty, 8*(substarty+1), 2);
   MausBereichAdd(8*substartx, 8*subendx,
                  8*(substarty+4)+1,(sdymax+sdymin+2)*16, 3);
{   MausBereichAdd((sdxmin-1)*8, sdxmax*8,
                  (sdymin-1)*16, (sdymax+sdymin-1)*16+8, 3);}
   maustaste:=0;
   ok:=false;
   SduSodir(True, ok, false, instring, '*.FNT','',false,
            sdxmin*8-4, sdymin*16-8, sdymax, sdcol,
            mausx, mausy, maustaste, 3,0,0,True);
   SduSodir(False, ok, true, instring,'*.FNT','',false,
            sdxmin*8-4, sdymin*16-8, sdymax, sdcol,
            mausx, mausy, maustaste, 3,0,0, False);
   if ok then
   begin
      fontfile:= instring;
      IniIniSymbols;
      Window(substartx + 1, substarty + 3, subendx -1, subendy - 3);
      Window(1,1,80,25);
      if ok then begin   {PEO}
         UseSaveSetup;   {PEO}
      end;
   end;
end;

{************************************************************}
Procedure UseColorSelect(var mausx, mausy, maustaste, mausmenu: word);

const hy = 25;

Var
    ok : boolean;
    instring: string79;
begin
   maustaste:= 0;

   Instring:=' Active Color Setting: ' + colorfile;
   IniExpand(instring,57);
   IniSpacedText(substartx, substarty*2,instring,frLow);

   IniOutTextXY(subendx - 8, substarty + 1, '        ');
   IniSpacedText(substartx, (subendy-1)*2,
              ' Use cursor+[Enter] or [Esc]                             ',frLow);
   MausBereichAdd(8*substartx, 8*subendx,
                  8*substarty, 8*(substarty+1), 2);
   MausBereichAdd(8*substartx, 8*subendx,
                  8*(substarty+4)+1,(sdymax+sdymin+2)*16, 3);
{   MausBereichAdd((sdxmin-1)*8, sdxmax*8,
                  (sdymin-1)*16, (sdymax+sdymin-1)*16+8, 3);}
   OK:=False;
   SduSodir(True, ok, false, instring,'*.COL','',false,
            sdxmin*8-4, 72, sdymax, 3,
            mausx, mausy, maustaste, 3,0,0,True);
   SduSodir(False, ok, true, instring, '*.COL','',false,
            sdxmin*8-4, 72, sdymax, 3,
            mausx, mausy, maustaste, 3,0,0,False);
   if ok then
   begin
      colorfile:= instring;
      FilCopyFile(instring, 'colors.rns');
   end;
end;

Procedure DrawTopMenuLines(C : Char);
Begin
  SetBkColor(7); {Hintergrund grau}
  SetColor(5);

  Line((topstartx-1 )*CharWidth-8, (topstarty-1  ),
       (topstartx-1 )*Charwidth-8, (topstarty+478)); {Linke Kante, hell 1}
  Line((topstartx-1 )*CharWidth-7, (topstarty-1  ),
        subendx      *Charwidth-1, (topstarty-1  )); {Obere Kante, hell 1}
  Line((topstartx-1 )*CharWidth-7, (topstarty+40 ),
        subendx      *Charwidth-1, (topstarty+40 )); {Titelabschluss, hell}
  Line((topstartx-1 )*CharWidth-7, (topstarty+457),
        subendx      *Charwidth-1, (topstarty+457)); {unterer Abschluss hell}
  Line((topstartx+20)*CharWidth-5, (topstarty-1),
       (topstartx+20)*Charwidth-5, (topstarty+480)); {Trennungslinie hell 1}
  SetColor(12);
  Line((topstartx-1)*CharWidth-8, (topstarty+38),
        subendx     *Charwidth-1, (topstarty+38)); {Titelabschluss, dunkel}
  Line((topstartx-1)*CharWidth-8, (topstarty+39),
        subendx     *Charwidth-1, (topstarty+39)); {Titelabschluss, dunkel}
  Line((topstartx-1)*CharWidth-8, (topstarty+455),
        subendx     *Charwidth-1, (topstarty+455)); {unterer Abschluss dunkel}
  Line((topstartx-1)*CharWidth-8, (topstarty+456),
        subendx     *Charwidth-1, (topstarty+456)); {unterer Abschluss dunkel}
  SetColor(12);
  Line((topstartx+20)*CharWidth-6, (topstarty-1),
       (topstartx+20)*Charwidth-6, (topstarty+478)); {Trennungslinie dunkel 1}
  Line((topstartx+20)*CharWidth-7, (topstarty-1),
       (topstartx+20)*Charwidth-7, (topstarty+478)); {Trennungslinie dunkel 2}
     {Rahmen f�r Text}
  IF C<>'F' then begin
    SetColor(12);
    Line((substartX+0)*Charwidth-1, (substarty+2)*2*Charheight+6,
         (subendx  -1)*charwidth-4, (substarty+2)*2*Charheight+6);
    Line((substartX+0)*Charwidth-1, (substarty+18)*2*Charheight-8,
         (subendX  -1)*charwidth-4, (substarty+18)*2*Charheight-8);
    Line((substartX+0)*Charwidth-1, (substarty+2)*2*Charheight+6,
         (substartx+0)*charwidth-1, (substartY+6)*2*Charheight+2);
    SetColor(5);
    Line((substartX+0)*Charwidth  , (substartY+6)*2*Charheight+2,
         (subendX  -1)*charwidth-4, (substarty+6)*2*Charheight+2);
    Line((subendX  -1)*Charwidth-4, (substarty+2)*2*Charheight+7,
         (subendX  -1)*charwidth-4, (substarty+6)*2*Charheight+2);
    SetColor(12);
    Line((substartX+0)*Charwidth-1, (substarty+18)*2*Charheight-7,
         (substartX+0)*charwidth-1, (subendy  -2)*2*Charheight-4);
    SetColor(5);
    Line((substartX+0)*Charwidth  , (subendy  -2)*2*Charheight-4,
         (subendX  -1)*charwidth-4, (subendy  -2)*2*Charheight-4);
    Line((subendX  -1)*Charwidth-4, (substarty+18)*2*Charheight-7,
         (subendX  -1)*charwidth-4, (subendy  -2)*2*Charheight-4);
    SetFillStyle(11,13); {11=gepunktet, 13=lila}
    Bar(184, 55,627,113);
    Bar(184,297,627,443);
{???????????????????????????????????????????????????????}
{    SetFillStyle(solidfill, bkcolor);} {in jedem Fall absurde Cursorfarben-Wechsel
     je nach zuerst gew. Colors}
  end;
End;
{******************************************************}
Procedure UseGetPickFil(var Instring : Stringline);
Var infile : text;
Begin
  FilAssignRnsFile(infile, 'pickfil', true);
  LastFileName:=FExpand(TextRec(Infile).Name);
  readln(infile, instring);
  close(infile);
End;
{******************************************************}
Procedure UseSetPickFil(Instring : Stringline);
Var infile : text;
Begin
  FilAssignRnsFile(infile, 'pickfil', false);
  LastFileName:=FExpand(TextRec(infile).Name);
  writeln(infile, instring);
  close(infile);
End;
{******************************************************}
Procedure UseTopMenu;

Var
    resp : response_type;
    dir : movement;
    KeyResp : Char;
    i : integer;
    b : byte;
    c : char;
    instring, inbuf : string79;
    choicenum : byte;
    infile,bakfile: text;
    st: string;
    bakname : String79;
    mausx, mausy, maustaste, mausmenu: word;
    mx,my,mt,mm : Word;
    changed : boolean;
begin
  UseGetConfig;
  UseGetSetup;
  IniIniColors;
  IniIniSymbols;
  UseSaveSetup;
  IniGraphInit;
  MausInstall;
  IniSwapMenuColors;
  c:= ' ';
  mausmenu:= 0;
  choicenum:= 1;
  demoversion:=not(IniFileExist('imie.rns') and TitVerify);
  ImeInitTopmenu;
  repeat
    SetFillStyle(SolidFill,MenuBkColor);
    SetColor(MenuFrameColor);
    UseGetPickFil(instring);
    Mausdunkel;
    if c<>' ' then begin{ nur beim ersten mal nicht l�schen }
      bar(172, 1,639,479);{l�scht nur rechten Teil, nicht Hauptmenu}
{      bar( 10,61,159,110);}{l�scht nur 1.Button des Hauptmenus: wegen Dir\}
      { ClearDevice;} {alternativ zur den bars}
      ImeInitTopmenu; {damit richtiger Pfad 1.button Hauptmenu gezeigt wird}
    end else begin
      IniPalBlank(0,0,0);
    end;
    DrawTopMenuLines(c);
    SetColor(12);
    GrDisplay_Menu(topstartx, topstarty, usrmenu, 1);
    if c<>'F' then begin
      logo^.display(192,150); {192,175}
      SetColor(12);
      if demoversion then begin
        inbuf:= '                          ';
        IniExpand(inbuf, subendx - substartx-2);
        IniOutTextXY(substartx, (substarty+3)*2, inbuf);
        inbuf:= '                         D E M O - V E R S I O N ';
        IniExpand(inbuf, subendx - substartx-2);
        IniOutTextXY(substartx, (substarty+4)*2, inbuf);
        assign(infile, 'copyd.rns');
        If not IniDirExist('demodir') then
          mkdir('demodir');
        datadir:= 'demodir';
        chdir(datadir);
        If not IniFileExist('testfile.rns') then
          FilCopyFile('..\testfile.rns', 'testfile.rns');
        ChDir('..');
      end else begin
        inbuf:= '                          ';
        IniExpand(inbuf, subendx - substartx-2);
        IniOutTextXY(substartx, (substarty+3)*2, inbuf);
        inbuf:= '  L I C E N S E D  V E R S I O N  '+usrfirstname+' '+usrname;
        IniCenter(inbuf, 74);
        IniOutTextXY(substartx, (substarty+4)*2, inbuf);
        assign(infile, 'copyr.rns');
      end;
      LastFileName:=FExpand(TextRec(Infile).Name);
      reset(infile);
      i:= 6;
      while not eof(infile) do begin
        readln(infile, inbuf);
        IniExpand(inbuf, subendx - substartx - 2);
        IniOutTextXY(substartx, (substarty+i+2)*2, ' '+inbuf);
        i:= i+1;
      end;
      close(infile);
      SetColor(12);
      MausGrafik(1);
      MausBereich(1,(substartX-3)*Charwidth-3,42,GrmaxY+14);
      MausSetXY(102,90);
      if mausmenu <> 1 then begin
        maustaste:= 0;
        mausmenu:= 0;
      end;
    {    IniFadeIn;}
      IniSetAllDACRegs(ThePalette);
{    if c <> 'F' then begin}
      repeat
        if maustaste = 7 then
          maustaste:= 0;
        GrGet_Menu_Response(topstartx, topstarty, usrmenu, c,
                            dir, choicenum,
                            mausx, mausy, maustaste, mausmenu, false, 1);
        c:= UpCase(c);
        if c=#27 then begin
{          IniSetDACReg(1,$3F,$3F,$3F);
          Delay(300);
          IniSetAllDACRegs(ThePalette);
          choicenum:=usrmenu.num_choices;}
        end;
      until (c='F') or (c='D') or (c='S') or (c='P') or (c='C') or (c='Q');
    end;
    While KeyPressed Do ReadKey;
    Mausbereich(172,628,1,438);
    case c of
      'F' : begin
        choicenum:=1;
        mausdunkel;
        MausSetXY(509,23);
        SetFillStyle(Solidfill,7);
        Bar((substartx-1)*charwidth,(substarty+2)*2*Charwidth,
            (subendx)*charwidth,(subendy-2)*2*charwidth);
        UseFileName(instring, c, mausx, mausy,
                    maustaste, mausmenu);
        Instring:=UpString(Instring);
        if c <> #27 then begin
           UseSetPickFil(instring);
           UseGetSetup;
           IF IniFileExist(datadir+'\'+instring) Then Begin
              IF Pos('.',instring)=0 Then Begin
                 FilCopyFile(datadir+'\'+instring,datadir+'\'+instring+'.BAK');
                 Assign(Bakfile,datadir+'\'+instring+'.BAK');
              End Else Begin
                 FilCopyFile(datadir+'\'+instring,datadir+'\'+
                   Copy(instring,1,Pos('.',instring))+'BAK');
                 Assign(Bakfile,datadir+'\'+Copy(instring,1,
                   Pos('.',instring))+'BAK');
              End;
             BakName:=datadir+'\'+Copy(instring,1,Pos('.',instring))+'BAK'; { Modern file name access }
           End Else
             BakName:='';
           IniSwapMenuColors;
           EdiRythmEdit(datadir + '\' + instring,bakname,
                        false, demoversion);
           Mauszeigen;
           IniSwapMenuColors;
           st:=copy(fontfile,1,byte(fontfile[0])-3)+'PAR';
           IniHideCursor;
           IF NOT FilCompareFiles(st,'SYMBOLS.PAR') Then Begin
             HlpHintFrame(grminx, grmaxy - 48, Grmaxx, grmaxy);
             txtfnt.write(grminx + 24, grmaxy - 48 + 2*charheight,
             'Fontfile '+St+
             ' has been changed!',getcolor,sz8x16,stnormal);
             txtfnt.write(grminx + 24, grmaxy - 48 + 4*charheight,
             'Press [Y] to save, [Esc] to cancel',getcolor,sz8x16,stnormal);
             repeat
               c:=IniMausEscape;
             until (c=#27) Or (c=#13) Or (c='Y');
           End Else
             c:=#27;
           Case C Of
             #27 :;
             #13,'Y' : Begin
               IF IniFileExist(St) Then Begin
                 HlpHintFrame(grminx, grmaxy - 48, Grmaxx, grmaxy);
                 txtfnt.write(grminx + 20, grmaxy - 42 + 2*charheight,
                 {'File '+}st+' already exists, enter new name:',getcolor,sz8x16,stnormal);
                 {suche ein Zahl im string und schreibe eine as Ende
                  des Strings}
                 While IniFileexist(st) Do Begin
                   c:=St[0];
                   IF (St[Byte(c)-4]<'0') Or (St[Byte(c)-4]>'9') Then Begin
                     b:=Pos('-',St);
                     IF b<>0 Then
                       St:=Copy(St,1,b-1)+Copy(St,b+1,Byte(st[0])-b);
                     b:=Pos('.',St);
                     IF St[0]>#12 Then
                       St[8]:='2'
                     Else
                       St:=Copy(St,1,b-1)+'2'+Copy(St,b,Byte(St[0])-b+1);
                   End{IF St[...<'1'} Else Begin
                     IF (St[Byte(c)-4]<>'9') Then Begin
                       Inc(St[Byte(c)-4]);
                     End{IF St[...<>'9'} Else Begin
                       IF (St[Byte(c)-5]<'0') Or (St[Byte(c)-5]>'9') Then Begin
                         st[Byte(c)-5]:='1';
                         st[Byte(c)-4]:='0';
                       End{IF St[...<'1'} Else Begin
                         IF St[Byte(c)-5]<>'9' Then Begin
                           Inc(Byte(St[Byte(c)-5]));
                           St[Byte(c)-4]:='0';
                         End Else
                           st:='';
                       End;{IF St[...<'1' else}
                     End;{IF ST[... <>'9' else}
                   End;{IF ST[... <'1' else}
                 End;{While}
                 Repeat
                   IniInversWrite(456,402,'              ',frLow);
  {String}         GrGetUpcase_String (st,
  {X,Y}            456, 402,
  {Length}         12,
  {Resp,dir}       Resp,Dir,
  {keyresp}        Keyresp,
  {oldwrite}       True,
  {mausx,-y}       mx,my,
  {msetaste,-menu} mt,mm,
                   changed);
                   IF Resp<>Escape Then Begin
                     IF Pos('.PAR',St)=0 Then Begin
                       if Pos('.',St)<>0 Then Begin
                         Resp:=Key;
                         IF Pos('.',St)>9 Then Begin
                            St:=Copy(St,1,8);
                            St:=St+'.PAR';
                         End{Pos('.',St)>9} Else
                           St:=Copy(St,1,Pos('.',st))+'PAR';
                       End{IF Pos('.',St)<>0}Else Begin
                         Resp:=Key;
                         IF St[0]>#8 Then
                           st:=Copy(St,1,8)+'.PAR'
                         Else
                           St:=St+'.PAR';
                       End;{IF Pos('.',St)<>0 Else}
                     End;{Pos('.PAR',St)<>0}
                   End;{IF Resp<>Escape}
                 Until ((Resp=Return) And ((Not IniFileExist(St)) Or IniUserFontFile(st))) Or (Resp=ESCAPE);
                 IF Resp=Return Then Begin
                   FilCopyFile('SYMBOLS.PAR',ST);
                   St:=Copy(St,1,Pos('.',St)-1);
                   FilCopyFile('SYMBOLS.SYM',ST+'.SYM');
                   FilCopyFile('SYMBOLS.PRN',ST+'.FNT');
                 End;
               End;
             End;
           End;
           LastFileName:=BakName;
        {$I-}
           IF BakName<>'' Then
             Erase(BakFile);
        {$I+}
{.........................................................................}
           {Zur�cksetzungen vor Save beim verlassen des Files}
{          soundchange:=(soundchange xor saMuffled) and not saMuffled;}
           {muffled M soll w�hrend ganzer Session f�r alle Files gelten!}
           soundchange:=(soundchange xor saRhythm) and not saRhythm;
           {nur rhythmische Stuktur R wird beim Filesave gel�scht}
           PageCount:=1;
{.........................................................................}
           UseSaveSetup;
           c:='F';
           mausdunkel;
           ClearDevice;
           ImeInitTopmenu;
        end;
        choicenum:=2;
      End;

      'P' : begin
        actedit:= actedit + [setuppage, defsetuppage];
        IniSwapColors;
        IniSwapMenuColors;
        EdiRythmEdit('pageset','', true, false);
        IniSwapMenuColors;
        IniSwapColors;
        actedit:= actedit - [setuppage, defsetuppage];
        SetFillStyle(Solidfill,7);{!!!}
        c:=#1;
        choicenum:=1;
        ClearDevice;
        ImeInitTopmenu;
      end;

      'D' : begin
        Mausdunkel;
        MausSetXY(509,23);
        SetFillStyle(Solidfill,7);{!!!}
        Bar((substartx-1)*charwidth,(substarty+2)*2*Charwidth,
            (subendx)*charwidth,(subendy-2)*2*charwidth);
        UseSaveSetup;
        UseDirName(mausx, mausy, maustaste, mausmenu);
        if (mausx<>0) or (mausy<>0) or (maustaste<>0) or (mausmenu<>0) Then begin
           IniSwapMenuColors;
           UseSaveConfig;
           UseGetSetup;
           IniIniSymbols;
           IniIniColors;
           c:= 'F';
           IniSwapMenuColors;
        end else begin
          choicenum:=1;
          c:=#1;
        end;
      end;

      'S' : begin  {new}
        Mausdunkel;
        MausSetXY(300,90);
        SetFillStyle(Solidfill,7);{!!!}
        Bar((substartx-1)*charwidth,(substarty+2)*2*Charwidth,
            (subendx)*charwidth,(subendy-2)*2*charwidth);
        UseFontSelect(mausx, mausy, maustaste, mausmenu);
        c:=#1;
        choicenum:=1;
      end;

      'C' : begin
        Mausdunkel;
        MausSetXY(300,90);
        IniSwapMenuColors;
        IniIniColors;
        SetFillStyle(Solidfill,7);{!!!}
        Bar((substartx-1)*charwidth,(substarty+2)*2*Charwidth,
            (subendx)*charwidth,(subendy-2)*2*charwidth);
        IniSwapMenuColors;
        UseColorSelect(mausx, mausy, maustaste, mausmenu);
        IniSwapMenuColors;
        UseSaveConfig;
        IniIniColors;
        IniSwapMenuColors;
        GcuIniCursor;
        c:=#1;
        choicenum:=1;
      end;
    end;
    MausZeigen;
  until c = 'Q';
end;

begin
  demoversion:= true;
end.
