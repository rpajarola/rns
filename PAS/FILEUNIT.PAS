{$I RNS.H}
unit fileunit;

interface

uses initsc,
     UserExit,
     MenuTyp,
     MousDrv,
     PageUnit,
     Titleunit,
     Getunit,
     XCrt,
     CRCUnit,
     SysUtils;

Procedure FilFindPtr(pagenum, linenum: integer; var foundptr,
                     startptr, lastptr: listptr;
                     lastinclude: boolean);
Procedure FilSkipPage(var tempptr, startptr, lastptr: listptr);
Procedure FilSavePage(FirstLine, LastLine : integer; var tempptr,
                      startptr, lastptr: listptr);
Procedure FilFindPage(Pagenumber : integer; var Actpage : integer;
                      var tempptr, startptr, lastptr: listptr);
Procedure FilFileToHeap(var infile : text; var actptr, startptr,
                        lastptr: listptr; var ok: boolean);
Procedure FilHeapToFile(var outfile : text; var actptr, startptr,
                        lastptr: listptr; dispmem : boolean;
                        fileopen: boolean;WriteHeader : boolean);
Procedure FilHeapInsertString(inblock: stringline; var nowptr, firstptr,
                              endptr, actptr: listptr; newactptr : boolean);
Procedure FilHeapExtractString(var inblock: stringline; var actptr, startptr,
                               endptr: listptr);
Procedure FilStringSeparate(var tempbuffer: stringline;
                            var tempptr, startptr, lastptr: listptr;
                            var tbufpos: byte);
Procedure FilBufStart;
Procedure FilBufClear;
Procedure FilHeapSqueeze(var actptr, startptr, endptr: listptr;
                         trailblank: boolean);
Procedure FilCheckLine(var tempbuffer, inblock: stringline;
                       var tempptr, startptr, lastptr: listptr;
                       var tbufpos: byte; var endreached: boolean;
                       skip: boolean; delline: boolean);
Procedure FilCopyFile(instring, outstring: stringline);
Procedure FilAssignRnsFile(var tfile: text; instring: stringline;
          readf: boolean);
Procedure FilFindeErstBestenFont(VAR instring : stringline);
Function FilCompareFiles(FName1,FName2 : String) : Boolean;
Procedure FilFontSelect;
Procedure FilDelPage(var actptr, startptr, lastptr : listptr);
Procedure FilUnDelPage(var actptr, startptr, lastptr : listptr);
Procedure FilCopyPage(var actptr, startptr, lastptr : listptr);
Procedure FilPastePage(var actptr, startptr, lastptr : listptr);
Procedure FilMarkPage;
Procedure FilUnMarkPage;
Procedure FilCutBlockFile(Name : String);
Function FilNumPages(actptr, startptr, lastptr : listptr) : integer;
Function FilFileSelect(prompt,wildcard,dir : string) : string;
implementation

uses helpunit,
     dos,
     Graph,
     crt,
     Texts,
     SdUnit,
     Markunit;
{****************************************************}
Function FilNew(var lptr: listptr): boolean;
begin
   new(lptr);
   if lptr = nil then
   begin
      HlpHint(HntOutOfMemory, HintNormalTime);
      FilNew:= false;
   end
   else
   begin
      FilNew:= true;
   end;
end;

{****************************************************}
Procedure FilFindeErstBestenFont(VAR instring : stringline);

var sr : SearchRec;
begin
   FindFirst('.\*.fnt',$3F,SR);
   if IOResult<>0 then begin
      WriteLn;
      WriteLn;
      WriteLn(^g^g^g,'No *.FNT found');
      Halt(24);
   end
   else
   begin
      instring:= sr.name;
   end;
end;

{****************************************************}
Procedure FilCopyFile(instring, outstring: stringline);

var infile, outfile: file;
    inblock : pointer;
    inblocksize : word;
    inread, inwrite: word;

begin
  assign(infile, FExpand(instring));
  assign(outfile, FExpand(outstring));
  LastFileName:=FExpand(instring);
  FileMode:=0;
{$I-}
  reset(infile, 1);
  IF IOResult<>0 Then;
  FileMode:=2;
  LastFileName:=FExpand(OutString);
  rewrite(outfile, 1);
  IF IOResult<>0 Then;
{$I+}
  inblocksize:=65536-16; { Modern replacement for memavail - use fixed buffer size }
  if inblocksize>filesize(infile) then
    inblocksize:=filesize(infile);
  getmem(inblock,inblocksize);
  if inblock=nil then
    runerror(217);
  repeat
    LastFileName:=FExpand(instring);
    blockread(infile, inblock^, inblocksize, inread);
    LastFileName:=FExpand(Outstring);
    blockwrite(outfile, inblock^, inread, inwrite);
  until (inread = 0) or (inread <> inwrite);
  freemem(inblock,inblocksize);
  LastFileName:=FExpand(Instring);
  close(infile);
  LastFileName:=FExpand(Outstring);
  close(outfile);
end;

{****************************************************}
Function FilWrongVersion(instring: stringline): Boolean;

var infile: text;
    bufstr: stringline;
begin
   Assign(infile, instring);
   LastFileName:=FExpand(instring);
   Reset(infile);
   ReadLn(infile,bufstr);
   close(infile);
   FilWrongVersion:= (pos(versionstring, bufstr) = 0);
end;

{****************************************************}
Procedure FilAssignRnsFile(var tfile: text; instring: stringline;
          readf: boolean);

var instr2: stringline;
begin
   instr2:= datadir + '\' + instring + exts;
   if ((not IniFileExist(instr2)) or
       (FilWrongVersion(instr2))) then
   begin
      FilCopyFile(instring + exts, instr2);
   end;
   Assign(tfile, instr2);
   LastFileName:=FExpand(instr2);
   if readf then
   begin
      reset(tfile);
      readln(tfile);
   end
   else
   begin
      rewrite(tfile);
      writeln(tfile,'version ',versionstring);
   end;
end;


{*********************************************************}
Procedure FilCheckLine(var tempbuffer, inblock: stringline;
                       var tempptr, startptr, lastptr: listptr;
                       var tbufpos: byte; var endreached: boolean;
                       skip: boolean; delline: boolean);
{Inblock wird = n�chste Zeile. Tempbuffer ist der aktuelle String im Heap,
 in der der n�chste Terminator gesucht wird. Die �bersprungene Zeile
 ist in inblock. Tempptr zeigt auf den Nachfolger
 von tempbuffer, tbufpos gibt die Position des 0-terminators in Tempbuffer an.
 Ist skip true, wird die Zeile �bersprungen, sonst nur angezeigt in inblock
 Ist DELLINE true, wird die Zeile gel�scht.}

var tbsav: byte;

begin
   endreached:= false;
   tbsav:= tbufpos;
   {Lies n�chsten String aus dem Heap, wenn der Buffer leer ist}

   if Length(tempbuffer) <= tbufpos then
   begin
      tbufpos:= 0;
      tbsav:= 0;
      if tempptr <> lastptr then
      begin
         tempbuffer:= tempptr^.datblock;
         tempptr:= tempptr^.next;
      end
      else
      begin
         endreached:= true;
         tempbuffer:= 'T' + chr(0);
      end;
   end;
   inblock:= '';
   repeat
      tbufpos:= tbufpos + 1;
      inblock:= inblock + tempbuffer[tbufpos];
   until tempbuffer[tbufpos] = chr(0);
   delete(inblock, length(inblock), 1);
   if delline then
   begin
      delete(tempbuffer, tbsav + 1, tbufpos - tbsav);
      if tempbuffer <> '' then
      begin
         tempptr^.last^.datblock:= tempbuffer;
      end
      else
      begin
         tempptr:= tempptr^.last;
         FilHeapExtractString(inblock, tempptr, startptr, lastptr);
      end;
      tbufpos:= tbsav;
   end;
   if not skip then tbufpos:= tbsav;
   if length(inblock) < linemarker then inblock:= inblock + '         ';
end;

{*********************************************************}
Procedure FilStringSeparate(var tempbuffer: stringline;
                            var tempptr, startptr, lastptr: listptr;
                            var tbufpos: byte);
{An der Stelle tbufpos in tempbuffer wird der String aufgebrochen}

var prevptr, nextptr: listptr;

begin
   if ((length(tempbuffer) > tbufpos) and (tbufpos > 0)) then
   begin
      if FilNew(nextptr) then
      begin
         prevptr:= tempptr^.last;
         prevptr^.datblock:= Copy(tempbuffer, 1, tbufpos);
         nextptr^.datblock:= Copy(tempbuffer, tbufpos + 1,
                                  length(tempbuffer));
         nextptr^.next:= tempptr;
         nextptr^.last:= prevptr;
         prevptr^.next:= nextptr;
         tempptr^.last:= nextptr;
         tempptr:= nextptr;
      end;
   end
   else
   begin
      if ((tbufpos = 0) and (length(tempbuffer) > 0)) then
      begin
         prevptr:= tempptr^.last;
         prevptr^.datblock:= tempbuffer;
         prevptr^.next:= tempptr;
         tempptr^.last:= prevptr;
         tempptr:= prevptr;
      end;
   end;
end;

{*********************************************************}
Procedure FilBufStart;
{Initialisieren des Buffers}

begin
   if FilNew(bufendptr) then
   begin
      if bufendptr <> nil then
      begin
         bufendptr^.datblock:= '$$$End$$$';
         bufendptr^.last:= nil;
         bufstartptr:= bufendptr;
      end;
   end;
end;

{*********************************************************}
Procedure FilBufClear;
{Leeren eines Buffer}

var bufptr: listptr;

begin
   bufptr:= bufstartptr;
   while bufptr <> bufendptr do
   begin
      bufstartptr:= bufstartptr^.next;
      dispose(bufptr);
      bufptr:= bufstartptr;
   end;
   bufstartptr:= bufendptr;
   bufactptr:= nil;
{   marpartline:= false;}
end;

{*********************************************************}
Procedure FilFindPtr(pagenum, linenum: integer; var foundptr,
                     startptr, lastptr: listptr;
                     lastinclude: boolean);
{suchen des Pointers auf die Zeile linenum auf der Seite pagenum
 lastinclude = true heisst, dass die letzte Zeile noch �bersprungen
               wird}

var inblock, dummyblock: stringline;
    actline, linepos: byte;
    i: integer;
    endreached: boolean;

begin
   {Seite suchen}
   FilFindPage(pagenum, i, foundptr, startptr, lastptr);

   {Zeile suchen}
   actline:= topmargin;
   inblock:= '';
   linepos:= 0;
   while actline < linenum do
   begin
      FilCheckLine(inblock, dummyblock, foundptr, startptr,
                   lastptr, linepos, endreached, true, false);
      actline:= actline + 1;
   end;
   if lastinclude then FilCheckLine(inblock, dummyblock, foundptr,
                                    startptr, lastptr,
                                    linepos, endreached, true, false);

   {String aufbrechen}
   FilStringSeparate(inblock, foundptr, startptr, lastptr, linepos);
end;

{*********************************************************}
Procedure FilFileToHeap(var infile : text; var actptr, startptr,
                        lastptr: listptr; var ok: boolean);
{Kopiert das File infile auf den Heap und initialisiert die Pointer}

var tempptr                      : listptr;
    workdat                      : linerec;
    inblock,tempbuffer: stringline;
    version,code                 : Integer;
begin
  if FilNew(lastptr) then begin
    if lastptr<>nil then begin
    {Daten lesen}
      workdat.datblock:='$$$END$$$';
      workdat.next:=nil;
      workdat.last:=nil;
      lastptr^:=workdat;
      startptr:=lastptr;
      actptr:=startptr;
      tempptr:=startptr;
      tempbuffer:='';

      ok:=true;
      ReSet(infile);
      ReadLn(infile,inblock);
      if inblock='$$$RNSBUFFER$$$' then begin
        readln(infile);
        version:=0;
      end else begin
        if copy(inblock,1,7)='VERSION' then begin
          Val(Copy(inblock,9,3),version,code);
          if code <> 0 then
              version := 0;
          readln(infile,inblock);
        end else if (inblock[1]='N') or (inblock[1]='T') then begin
          version:=1;
        end else begin
          ReadLn(infile,inblock);
          if (inblock[1]='N') or (inblock[1]='T') then begin
            ReSet(infile);
            ReadLn(infile,inblock);
            Version:=2;
          end else begin
            ReSet(infile);
            ReadLn(infile,inblock);
            version:=3;
          end;
        end;
        case version of
          0: begin              { buf file, header bereits ausgewertet  }
          end;
          1: begin
            ReSet(Infile);      { kein header!                          }
          end;
          2: begin
            fontfile:=inblock;  { nur font                              }
            IniIniSymbols;
          end;
          3: begin
            fontfile:=inblock;  { font+snd...                           }
            readln(infile, sndlength, sndlengthper, sndplaybeat, sndplaypulse, dispsound);
            readln(infile, sndlengthspm);
            IniIniSymbols;
          end;{case version of 3}
          4: begin
            fontfile:=inblock;  { font+snd...                           }
            readln(infile, sndlength, sndlengthper, sndplaybeat, sndplaypulse, dispsound, soundattr);
            readln(infile, sndlengthspm);
            IniIniSymbols;
          end;
        end;{case version}
      end;
      while ((not eof(infile)) and (ok)) do begin
        LastFileName:=FExpand(TextRec(Infile).Name);
        readln(infile, inblock);
        if inblock='' then begin
          inblock:='T';
        end{if inblock=''}else if(inblock[1]<>'T') and (inblock[1]<>'N') then begin
          while (inblock[0]>#0) And (inblock[1]=' ')  Do
            delete(inblock,1,1);
          if inblock='' Then
            inblock:='T';
          if (inblock[1]<>'T') and (inblock[1]<>'N') then begin
            if HlpAskYesEsc('File contains illegal data!',
                'Press [Y] to continue, [ESC] to cancel',hpFileMenu) then begin
              inblock:='T        '+inblock;
            end{if hlpaskyesesc}else begin
              ok:=false;
            end;
          end;{if inblock[1]<>'T'...}
        end;{if(inblock[1]<>'T') and (inblock[1]<>'N')}
        if ok and ((inblock[1]='T') or (inblock[1]='N')) then begin
          if (length(tempbuffer) + length(inblock) >= 255) then begin
            {Buffer voll, auf den Heap schreiben}
            FilHeapInsertString(tempbuffer, tempptr, startptr, lastptr,
                                actptr, false);
            tempbuffer:=inblock+#0;
          end else begin
            {Noch Platz im Buffer, Buffer weiter f�llen}
            tempbuffer:=tempbuffer+inblock+#0
          end;
        end;{if(inblock[1]='T')or(inblock[1]='N')}
      end;{while ((not eof(infile)) and (ok))}
      if ok then begin
        FilHeapInsertString(tempbuffer, tempptr, startptr, lastptr,
                            actptr, false);
      end;{if ok}
      LastFileName:=FExpand(TextRec(infile).Name);
      close(infile);
    end;{if lastptr<>nil}
  end{if filnew}else begin
    ok:= false;
  end;
end;

{*********************************************************}
Procedure FilHeapToFile(var outfile : text; var actptr, startptr,
                        lastptr: listptr; dispmem : boolean;
                        fileopen: boolean;WriteHeader : boolean);
{Kopiert den Heap auf das File infile und gibt den Speicher frei falls
 dispmem = true ist}

var temptr: listptr;
    inblock, tempblock: stringline;
    lineend: byte;
    attr: word;
    fn : String;
begin
  fn:=UpString(actfilename);
  temptr:= startptr;
  GetFAttr(outfile, attr);
  if ((attr and readonly) <> 0) then begin
    HlpHintFrame(grminx, grmaxy - 48, grmaxx, grmaxy);
    txtfnt.write(grminx + 20, grmaxy - 32,
       'Read only file, not saved!',
       getcolor,sz8x16,stnormal);
    txtfnt.write(grminx + 20, grmaxy - 16,
       'Press any key to continue',
       getcolor,sz8x16,stnormal);
    XClearKbd;
    Repeat Until KeyPressed;
    XClearKbd;
  end else begin
    HlpHintFrame(grminx, grmaxy - {32}48, grmaxx, grmaxY);
    txtfnt.write(grminx + 20, grmaxY - 24{13}, HintTexts[HntSavingFile],getcolor,sz8x16,stnormal);
    Delay(250);
    LastFileName:=FExpand(fn);
    if not fileopen then begin
      rewrite(outfile);
    end;
    if writeheader then begin
      WriteLn(Outfile,'VERSION '+VersionString);
      WriteLn(Outfile,fontfile);
      writeln(Outfile, sndlength:5, sndlengthper:3,sndplaybeat:3,
              sndplaypulse:3,dispsound: 3,soundattr: 3);
      WriteLn(Outfile,sndlengthspm);
    end;
    while temptr <> lastptr do begin
      inblock:= temptr^.datblock;
      lineend:= pos(chr(0), inblock);
      while lineend > 0 do begin
        tempblock:= Copy(inblock, 1, lineend - 1);
        writeln(outfile, tempblock);
        delete(inblock, 1, lineend);
        lineend:= pos(chr(0), inblock);
      end;
      temptr:= temptr^.next;
      if dispmem then begin
        dispose(temptr^.last);
      end;
    end;
  end;
  close(outfile);
  {$IFDEF DEMO}
    CRC:=GetCRC(fn);
    SetCRCFileEntry(fn,crc);
  {$ENDIF}
end;

{*********************************************************}
Procedure FilHeapInsertString(inblock: stringline; var nowptr, firstptr,
                              endptr, actptr: listptr; newactptr : boolean);
{Einfuegen des Strings inblock an die Stelle nowptr,
 nowptr wird auf den neuen String gesetzt, falls newactptr = true ist,
 sonst bleibt es unver�ndert
 ist nowptr = actptr, so wird auf jeden Fall ein neuer Pointer kreiert}

var workdat: linerec;
    tempptr, prevptr: listptr;

begin
   if ((newactptr) and
       (nowptr <> endptr) and
       (nowptr <> actptr) and
       (firstptr <> endptr) and
       ((length(inblock) + length(nowptr^.datblock)) < 255)) then
   begin
      nowptr^.datblock:= inblock + nowptr^.datblock;
   end
   else { if ((newactptr) and }
   begin
      if ((not newactptr) and
          (nowptr <> firstptr) and
          (firstptr <> endptr) and
          ((length(inblock) + length(nowptr^.last^.datblock)) < 255)) then
      begin
         nowptr^.last^.datblock:= nowptr^.last^.datblock + inblock;
      end
      else {if ((not newactptr) and}
      begin
         if FilNew(tempptr) then
         begin
            workdat.datblock:= inblock;
            workdat.next:= nil;
            workdat.last:= nil;
            tempptr^:= workdat;

            if firstptr = endptr then
            begin
               firstptr:= tempptr;
               nowptr:= endptr;
               tempptr^.next:= endptr;
               endptr^.last:= tempptr;
            end
            else { if firstptr = nil then }
            begin
               prevptr:= nowptr^.last;
               tempptr^.next:= nowptr;
               tempptr^.last:= prevptr;
               nowptr^.last:= tempptr;
               if prevptr <> nil then prevptr^.next:= tempptr;
               if tempptr^.next = firstptr then firstptr:= tempptr;
            end; { else if firstptr = nil then }
            if newactptr then nowptr:= tempptr;
         end {if filnew};
      end; { else if ((not newactptr) and}
   end; { else if ((newactptr) and }
end;

{*********************************************************}
Procedure FilHeapExtractString(var inblock: stringline; var actptr,
                               startptr, endptr: listptr);
{Lesen des Strings inblock an der Stelle actptr,
 actptr zeigt neu auf den Nachfolger von inblock.
 Inblock wird geloescht.}

var prevptr, nextptr: listptr;
    lineend: byte;
    tempbuffer: stringline;

begin
   if ((actptr <> nil) and (actptr <> endptr)) then
   begin
      tempbuffer:= actptr^.datblock;
      lineend:= pos(chr(0), tempbuffer);
      inblock:= copy(tempbuffer, 1, lineend - 1);
      delete(tempbuffer, 1, lineend);
      if (length(tempbuffer) > 0) then
      begin
         actptr^.datblock:= tempbuffer;
      end
      else
      begin
         prevptr:= actptr^.last;
         nextptr:= actptr^.next;
         if startptr = actptr then
         begin
            startptr:= nextptr;
         end;
         prevptr^.next:= nextptr;
         nextptr^.last:= prevptr;
         dispose(actptr);
         actptr:= nextptr;
      end;
   end;
end;

{*********************************************************}
Procedure FilHeapSqueeze(var actptr, startptr, endptr: listptr;
                         trailblank: boolean);
{Heap auf maximale Stringl�nge verdichten}

var inblock: stringline;
    lineend: byte;
    t1ptr, t2ptr: listptr;

begin
   if startptr <> endptr then
   begin
      t1ptr:= startptr;
      t2ptr:= t1ptr^.next;
      while t2ptr <> endptr do
      begin
         if t2ptr <> actptr then
         begin
            lineend:= pos(chr(0), t2ptr^.datblock);
            if (length(t1ptr^.datblock) + lineend < 255) then
            begin
               FilHeapExtractString(inblock, t2ptr, startptr, endptr);
               if (trailblank and (inblock[1] = 'T')) then
               begin
                  IniTrailBlank(inblock);
               end;
               t1ptr^.datblock:= t1ptr^.datblock + inblock + chr(0);
            end
            else
            begin
               t1ptr:= t2ptr;
               t2ptr:= t2ptr^.next;
            end;
         end
         else
         begin
            t1ptr:= t2ptr;
            t2ptr:= t2ptr^.next;
         end;
      end; {while t2ptr <> endptr do}
   end; {if startptr <> endptr then}
end;

{*********************************************************}
Procedure FilSavePage(FirstLine, LastLine : integer; var tempptr,
                      startptr, lastptr: listptr);
{Versorgen der Seite von firstline bis lastline
 tempptr zeigt auf das Ende der Seite}

Var i : integer;

begin
   for i:= firstline to lastline do
   begin
      if page[i,1] = 'T' then IniTrailBlank(page[i]);
      FilHeapInsertString(page[i] + chr(0), tempptr, startptr, lastptr,
                          tempptr, false);
   end;
   FilHeapSqueeze(tempptr, startptr, lastptr, true);
end;

{**************************************************************}
Procedure FilFindPage(Pagenumber : integer; var Actpage : integer;
                      var tempptr, startptr, lastptr: listptr);

Var actline, i : integer;
    inblock, dummyblock : stringline;
    linepos: byte;
    endreached: boolean;

{Sucht die Seite Pagenumber im Heap. Ist sie gefunden,
wird ActPage= Pagenumber}

begin
   actpage:=0;
   actline:=TopMargin;
   tempptr:= startptr;
   inblock:= '';
   linepos:= 0;
   endreached:= false;

   while (not endreached) and (actpage < pagenumber) do
   begin
      FilCheckLine(inblock, dummyblock, tempptr, startptr, lastptr,
                   linepos, endreached, true, false);
      actline:= actline + 1;
      if actline > pagelength then
      begin
         actpage:= actpage + 1;
         actline:= TopMargin;
      end;
   end;
   if endreached then
   begin
      i:= actpage - 1;
      FilFindPage(i, Actpage, tempptr, startptr, lastptr);
   end;
   FilStringSeparate(inblock, tempptr, startptr, lastptr, linepos);
end;

{**************************************************************}
Procedure FilSkipPage(var tempptr, startptr, lastptr: listptr);

{Springt auf die n�chste Seite im Heap, und holt die aktuelle
 aus dem Heap}

var actline : integer;

begin
   actline:= topmargin;
   if tempptr <> nil then
   begin
      while (tempptr <> lastptr) and (actline <= PageLength) do
      begin
         FilHeapExtractString(page[actline], tempptr, startptr, lastptr);
         actline:= actline + 1;
      end;
   end;
end;

Function FilCompareFiles(FName1,FName2 : String) : Boolean;
Var P1,P2    : Pointer;
    F1,F2 : File;
    L     : LongInt;
    A     : Word;
    OK    : Boolean;
    SFMode: Byte;
Begin
  SFMode:=FileMode;
  FileMode:=0;
  OK:=True;
  Assign(F1,FName1);
  LastfileName:=FExpand(FName1);
  ReSet(F1,1);
  Assign(F2,FName2);
  LastfileName:=FExpand(FName2);
  ReSet(F2,1);
  L:=FileSize(F1);
  IF L<>FileSize(F2) Then Begin
    FilCompareFiles:=False;
    LastfileName:=FExpand(FName1);
    Close(F1);
    LastfileName:=FExpand(FName2);
    Close(F2);
    Exit;
  End;
  While L>0 Do Begin
    IF L>$FFFF Then
      a:=$FFFF
    Else
      a:=L;
    GetMem(P1,a);
    GetMem(P2,a);
    BlockRead(F1,P1^,a);
    BlockRead(F2,P2^,a);
    // Compare memory blocks
    OK := CompareMem(P1, P2, a);
    FreeMem(P1,a);
    FreeMem(P2,a);
    IF L>$FFFF THEN
      L:=L-$FFFF
    Else
      L:=0;
  End;
  FileMode:=SFMode;
  FilCompareFiles:=OK;
  Close(F1);
  Close(F2);
End;

Procedure FilFontSelect;

(*Var instring        : string79;
    ok              : boolean;
    infile, outfile : text;
    MausX,MausY     : Word;
    Maustaste       : Word;
    MausMenu        : Word;
begin
  Mausdunkel;
  MausSetXY(300,90);

  SetFillStyle(Solidfill,7);   {Auswahl-Menu!}
  Bar(GrMinX+1,GrMinY+1,GrMinX+20*8,GrMaxY-1);

  SetColor(12);  {Abtrennungslinien!}
  Line(GrMinx,25,grminx+20*8-1,25);
  Line(grminx+20*8,grminy,grminx+20*8,grmaxy-1);
  Line(grminx+20*8+1,grminy,grminx+20*8+1,grmaxy-1);

  Setcolor(5);
  Line(grminx+20*8+2,grminy,grminx+20*8+2,grmaxy-1);
  Line(GrMinx,26,grminx+20*8-1,26);
  IniExpand(instring,57);
  SetColor(12);
  IniOutTextXY(5,1,'Select Symbolfont');
  MausBereichAdd(GrMinX+2,GrMinX+20*8,GrMinY+2,GrMaxY-1,3);
  maustaste:=0;
  ok:=false;
  SduSodir(True,ok, False, instring,'*.FNT','',false,
           22,45,22,1, mausx, mausy, maustaste, mausmenu, 0, 0,false);
  SduSodir(False,ok, True, instring,'*.FNT','',false,
           22,45,22,1, mausx, mausy, maustaste, 3, 0, 0,false);
  IF Ok Then Begin
    fontfile:= instring;
    IniIniSymbols;
  End;
  PagRefPage;
end;*)
var s : string;
begin
  s:=FilFileSelect('Select Symbolfont','*.FNT','');
  if s<>'' then begin
    fontfile:=s;
    IniIniSymbols
  end;
end;

Function FilFileSelect(prompt,wildcard,dir : string) : string;
Var instring        : string79;
    ok              : boolean;
    MausX,MausY     : Word;
    Maustaste       : Word;
    MausMenu        : Word;
Begin
  Mausdunkel;
  MausMenu := 0;
  MausSetXY(300,90);

  SetFillStyle(Solidfill,7);   {Auswahl-Menu}
  Bar(GrMinX+1,GrMinY+1,GrMinX+20*8,GrMaxY-1);

  SetColor(12);  {Abtrennungslinien}
  Line(GrMinx,25,grminx+20*8-1,25);
  Line(grminx+20*8,grminy,grminx+20*8,grmaxy-1);
  Line(grminx+20*8+1,grminy,grminx+20*8+1,grmaxy-1);

  Setcolor(5);
  Line(grminx+20*8+2,grminy,grminx+20*8+2,grmaxy-1);
  Line(GrMinx,26,grminx+20*8-1,26);
  IniExpand(instring,57);
  SetColor(12);
  IniOutTextXY(5,1,prompt);
  MausBereichAdd(GrMinX+2,GrMinX+20*8,GrMinY+2,GrMaxY-1,3);
  maustaste:=0;
  ok:=false;
  if dir<>'' then
    dir:=dir+'\';
  SduSodir(True,ok, False, instring,wildcard,dir,false,
           22,45,22,1, mausx, mausy, maustaste, mausmenu, 0, 0,false);
  SduSodir(False,ok, True, instring,wildcard,dir,false,
           22,45,22,1, mausx, mausy, maustaste, 3, 0, 0,false);
  IF Ok Then
    FilFileSelect:=instring
  Else
    FilFileSelect:='';
  PagRefPage;
End;

Procedure FilDelPage(var actptr, startptr, lastptr : listptr);
Var delfil  : Text;
    i,result: integer;
    oldpage : integer;
Begin
  lastbuf:=2;
  delpage:= true;
  assign(delfil,'delpage');
  LastFileName:=FExpand('DELPAGE');
  rewrite(delfil);
  if (pagebuf=-1) or (pagebuf=pagecount) then begin
    for i:= 1 to pagelength do
      writeln(delfil,page[i]);
  end else begin
    oldpage:=pagecount;
    { Aktuelle Seite sichern }
    FilSavePage(1, pagelength,actptr, startptr, lastptr);
    { Zu l�schende Seite suchen und vom Heap holen }
    FilFindPage(pagebuf, Result, actptr, startptr, lastptr);
    PagGetPageFromHeap(actptr, startptr, lastptr, i);
    for i:= 1 to pagelength do
      writeln(delfil,page[i]);
    pagecount:=oldpage;
    FilFindPage(pagecount, Result, actptr, startptr, lastptr);
  end;
  close(delfil);
  {goto previous page if this is last page}
  if actptr = lastptr then
    dec(pagecount);
  if pagecount > 0 then begin{show new page, dont save this page}
     FilFindPage(pagecount, Result, actptr, startptr, lastptr);
     PageCount:= Result;
     IniNewPage(i{dummy});{parameter sollte linenum sein, wird aber nicht ber�cksichtigt}
     PagGetPageFromHeap(actptr, startptr, lastptr, i);
  end else begin
    PagGetSetupPage(actptr, startptr, lastptr);
    pagecount:= 1;
  end;
  PagRefPage;
  FilUnMarkPage;
end;
Procedure FilUnDelPage(var actptr, startptr, lastptr : listptr);
var delfil  : text;
    i       : integer;
Begin
  if delpage then begin
    { Aktuelle Seite sichern }
    FilSavePage(1, PageLength, actptr, startptr, lastptr);
    { Und gleich wieder suchen }
    FilFindPage(pagecount, i, actptr, startptr, lastptr);
    pagecount:=i;
    { SetupPage ins page array holen }
    PagGetSetupPage(actptr, startptr, lastptr);
    { und delpage hineinschreiben }
    assign(delfil,'delpage');
    LastFileName:=FExpand('DELPAGE');
    ReSet(delfil);
    for i:= 1 to pagelength do
      ReadLn(delfil,page[i]);
    close(delfil);
    { Pointer auf diese Seite setzen }
    FilFindPage(PageCount, i, actptr, startptr, lastptr);
    PagRefPage;
    FilUnMarkPage;
  end;
end;
Procedure FilPastePage(var actptr, startptr, lastptr : listptr);
var copyfile : Text;
    i : integer;
Begin
  if pagebuf<>-1 then
    filcopypage(actptr, startptr, lastptr);
  if copypage then begin
    i:= pagecount;
    FilSavePage(1, PageLength, actptr, startptr, lastptr);
    PagGetSetupPage(actptr, startptr, lastptr);
    FilFindPage(pagecount, i, actptr, startptr, lastptr);
    assign(copyfile,'COPYPAGE');
    LastFileName:=FExpand('COPYPAGE');
    ReSet(copyfile);
    for i:= 1 to pagelength do
      ReadLn(copyfile,page[i]);
    close(copyfile);
    PagRefPage;
    filUnMarkPage;
  end;
end;

Procedure FilMarkPage;
begin
  pagebuf:=pagecount;
  MarkInverse(1,Pagelength,grminx,grmaxx);
end;

{������������������������ FilUnMarkPage ��������������������������������������}

Procedure FilUnMarkPage;

{var linenum,startx,endx,x,y: integer;}

begin
  if pagebuf<>-1 then begin
    pagebuf:=-1;
    { linenum:=2; }
    pagrefpage; {einklammern wenn Alternative PagRefClearVal geht!}
{    PagUnmark;}  {ev. bringt das etwas}
{    PagRefClearVal(grminx,iniYnow(linenum),grmaxx,iniYnow(linenum));
    PagRefClearVal(grminx,iniYnow(linenum+50),grmaxx,iniYnow(linenum+50));}
    {Funktioniert einzeln, zusammen macht es praktisch PageRefresh ???}

    {Weitere Strategie: 1. und 52. Zeile saven, l�schen, dann neu schreiben:}
{    x:=1;
    y:=1;
    SetViewPort (x,y+3,x+638,y+9,true);
    SetBkColor(bkcolor);
    ClearViewPort;
    SetViewPort (x,y+411,x+638,y+417,true);
    ClearViewPort;
    SetViewPort (0,0,GetMaxX,GetMaxY,true); }
  end;
end;

{������������������������ FilCopyPage ����������������������������������������}

Procedure FilCopyPage(var actptr, startptr, lastptr : listptr);
Var Copyfile : Text;
    i,result : integer;
    oldpage  : integer;
Begin
  copypage:=true;
  LastFileName:=FExpand('COPYPAGE');
  assign(copyfile,'COPYPAGE');
  rewrite(Copyfile);
  if pagebuf=-1 Then begin
    for i:= 1 to pagelength do
      writeln(Copyfile,page[i]);
  end else begin
    oldpage:=pagecount;
    FilSavePage(1, pagelength,actptr, startptr, lastptr);
    FilFindPage(pagebuf, Result, actptr, startptr, lastptr);
    PagGetPageFromHeap(actptr, startptr, lastptr, i);
    for i:= 1 to pagelength do
      writeln(copyfile,page[i]);
    FilSavePage(1, pagelength,actptr, startptr, lastptr);
    FilFindPage(oldpage, Result, actptr, startptr, lastptr);
    PagGetPageFromHeap(actptr, startptr, lastptr, i);
  end;
  close(copyfile);
end;

Procedure FilCutBlockFile(Name : String);
Var F1,F2   : Text;
    i,j     : Integer;
    inblock : String;
begin
  Assign(F1,Name);
  ReSet(F1);
  Assign(F2,'TEMP.RNS');
  i:=0;j:=0;
  While Not EoF(F1) Do Begin
    ReadLn(F1,InBlock);
    if inblock[1]='T' then begin
      while inblock[length(inblock)]=' ' do
        dec(byte(inblock[0]));
      if inblock<>'T' then
        j:=i;
    end else
      j:=i;
    inc(i);
  End;
  ReSet(F1);
  ReWrite(F2);
  ReadLn(F1,inblock);
  ReadLn(F1);
  WriteLn(F2,Inblock);
  WriteLn(F2,0:5,1:5,1:5,1:5,(j mod 52)+1:5,1:5,(j div 52)+1:5);
  if j>53 then j:=j-52;
  For i:=2 To j do begin
    ReadLn(F1,InBlock);
    WriteLn(F2,InBlock);
  end;
  Close(F1);
  Erase(F1);
  Close(F2);
  Rename(F2,Name);
End;

Function FilNumPages(actptr, startptr, lastptr : listptr) : integer;
{ Anzahl Seiten }
Var i : integer;
    actpage : integer;
    tempptr : listptr;
Begin
  i:=0;
  repeat
    inc(i);
    FilFindPage(i,actpage,tempptr,startptr,lastptr);
  until i<>actpage;
  FilNumPages:=i-1;
end;
begin
   FilBufStart;
end.
