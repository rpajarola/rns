{$I RNS.H}

Unit fileunit;

Interface

Uses initsc,
    UserExit,
    MenuTyp,
    MousDrv,
    PageUnit,
    Titleunit,
    Getunit,
    XCrt,
    CRCUnit,
    SysUtils;

Procedure FilFindPtr(pagenum, linenum: integer; Var foundptr,
    startptr, lastptr: listptr;
    lastinclude: boolean);
Procedure FilSkipPage(Var tempptr, startptr, lastptr: listptr);
Procedure FilSavePage(FirstLine, LastLine: integer; Var tempptr,
    startptr, lastptr: listptr);
Procedure FilFindPage(Pagenumber: integer; Var Actpage: integer;
    Var tempptr, startptr, lastptr: listptr);
Procedure FilFileToHeap(Var infile: text; Var actptr, startptr,
    lastptr: listptr; Var ok: boolean);
Procedure FilHeapToFile(Var outfile: text; Var actptr, startptr,
    lastptr: listptr; dispmem: boolean;
    fileopen: boolean; WriteHeader: boolean);
Procedure FilHeapInsertString(inblock: stringline; Var nowptr, firstptr,
    endptr, actptr: listptr; newactptr: boolean);
Procedure FilHeapExtractString(Var inblock: stringline; Var actptr, startptr,
    endptr: listptr);
Procedure FilStringSeparate(Var tempbuffer: stringline;
    Var tempptr, startptr, lastptr: listptr;
    Var tbufpos: byte);
Procedure FilBufStart;
Procedure FilBufClear;
Procedure FilHeapSqueeze(Var actptr, startptr, endptr: listptr;
    trailblank: boolean);
Procedure FilCheckLine(Var tempbuffer, inblock: stringline;
    Var tempptr, startptr, lastptr: listptr;
    Var tbufpos: byte; Var endreached: boolean;
    skip: boolean; delline: boolean);
Procedure FilCopyFile(instring, outstring: stringline);
Procedure FilAssignRnsFile(Var tfile: text; instring: stringline;
    readf: boolean);
Procedure FilFindeErstBestenFont(Var instring: stringline);
Function FilCompareFiles(FName1, FName2: String): Boolean;
Procedure FilFontSelect;
Procedure FilDelPage(Var actptr, startptr, lastptr: listptr);
Procedure FilUnDelPage(Var actptr, startptr, lastptr: listptr);
Procedure FilCopyPage(Var actptr, startptr, lastptr: listptr);
Procedure FilPastePage(Var actptr, startptr, lastptr: listptr);
Procedure FilMarkPage;
Procedure FilUnMarkPage;
Procedure FilCutBlockFile(Name: String);
Function FilNumPages(actptr, startptr, lastptr: listptr): integer;
Function FilFileSelect(prompt, wildcard, dir: string): string;
Implementation

Uses helpunit,
    dos,
    Graph,
    crt,
    Texts,
    SdUnit,
    Markunit;
{****************************************************}
Function FilNew(Var lptr: listptr): boolean;
Begin
    new (lptr);
    If lptr = nil Then
    Begin
        HlpHint (HntOutOfMemory, HintNormalTime);
        FilNew := false;
    End
    Else
        FilNew := true;
End;

{****************************************************}
Procedure FilFindeErstBestenFont(Var instring: stringline);

Var sr: SearchRec;
Begin
    FindFirst ('.\*.fnt', $3F, SR);
    If IOResult <> 0 Then
    Begin
        WriteLn;
        WriteLn;
        WriteLn (^g^g^g, 'No *.FNT found');
        Halt (24);
    End
    Else
        instring := sr.name;
End;

{****************************************************}
Procedure FilCopyFile(instring, outstring: stringline);

Var infile, outfile: File;
    inblock: pointer;
    inblocksize: word;
    inread, inwrite: word;

Begin
    assign (infile, FExpand (instring));
    assign (outfile, FExpand (outstring));
    FileMode := 0;
    reset (infile, 1);
    If IOResult <> 0 Then
    Begin
        HlpHint (HntCannotOpenFile, HintWaitEsc);
        Exit;
    End;
    FileMode := 2;
    rewrite (outfile, 1);
    If IOResult <> 0 Then
    Begin
        close (infile);
        HlpHint (HntCannotCreateFile, HintWaitEsc);
        Exit;
    End;
    inblocksize := 65536 - 16;
    If inblocksize > filesize (infile) Then
        inblocksize := filesize (infile);
    getmem (inblock, inblocksize);
    If inblock = nil Then
        runerror (217);
    Repeat
        blockread (infile, inblock^, inblocksize, inread);
        If IOResult <> 0 Then Break;
        blockwrite (outfile, inblock^, inread, inwrite);
        If IOResult <> 0 Then Break;
    Until (inread = 0) OR (inread <> inwrite);
    freemem (inblock, inblocksize);
    close (infile);
    close (outfile);
End;

{****************************************************}
Function FilWrongVersion(instring: stringline): Boolean;

Var infile: text;
    bufstr: stringline;
Begin
    Assign (infile, instring);
    Reset (infile);
    ReadLn (infile, bufstr);
    close (infile);
    FilWrongVersion := (pos (versionstring, bufstr) = 0);
End;

{****************************************************}
Procedure FilAssignRnsFile(Var tfile: text; instring: stringline;
    readf: boolean);

Var instr2: stringline;
Begin
    instr2 := datadir + '\' + instring + exts;
    If ((NOT IniFileExist (instr2)) OR
        (FilWrongVersion (instr2))) Then
        FilCopyFile (instring + exts, instr2);
    Assign (tfile, instr2);
    If readf Then
    Begin
        reset (tfile);
        If IOResult <> 0 Then
        Begin
            HlpHint (HntCannotOpenFile, HintWaitEsc);
            Exit;
        End;
        readln (tfile);
        If IOResult <> 0 Then
        Begin
            close (tfile);
            HlpHint (HntCannotReadFile, HintWaitEsc);
            Exit;
        End;
    End
    Else
    Begin
        rewrite (tfile);
        If IOResult <> 0 Then
        Begin
            HlpHint (HntCannotCreateFile, HintWaitEsc);
            Exit;
        End;
        writeln (tfile, 'version ', versionstring);
        If IOResult <> 0 Then
        Begin
            close (tfile);
            HlpHint (HntCannotWriteFile, HintWaitEsc);
            Exit;
        End;
    End;
End;


{*********************************************************}
Procedure FilCheckLine(Var tempbuffer, inblock: stringline;
    Var tempptr, startptr, lastptr: listptr;
    Var tbufpos: byte; Var endreached: boolean;
    skip: boolean; delline: boolean);
{Inblock wird = n�chste Zeile. Tempbuffer ist der aktuelle String im Heap,
 in der der n�chste Terminator gesucht wird. Die �bersprungene Zeile
 ist in inblock. Tempptr zeigt auf den Nachfolger
 von tempbuffer, tbufpos gibt die Position des 0-terminators in Tempbuffer an.
 Ist skip true, wird die Zeile �bersprungen, sonst nur angezeigt in inblock
 Ist DELLINE true, wird die Zeile gel�scht.}

Var tbsav: byte;

Begin
    endreached := false;
    tbsav := tbufpos;
    {Lies n�chsten String aus dem Heap, wenn der Buffer leer ist}

    If Length (tempbuffer) <= tbufpos Then
    Begin
        tbufpos := 0;
        tbsav := 0;
        If tempptr <> lastptr Then
        Begin
            tempbuffer := tempptr^.datblock;
            tempptr := tempptr^.next;
        End
        Else
        Begin
            endreached := true;
            tempbuffer := 'T' + chr (0);
        End;
    End;
    inblock := '';
    Repeat
        tbufpos := tbufpos + 1;
        inblock := inblock + tempbuffer[tbufpos];
    Until tempbuffer[tbufpos] = chr (0);
    delete (inblock, length (inblock), 1);
    If delline Then
    Begin
        delete (tempbuffer, tbsav + 1, tbufpos - tbsav);
        If tempbuffer <> '' Then
            tempptr^.last^.datblock := tempbuffer
        Else
        Begin
            tempptr := tempptr^.last;
            FilHeapExtractString (inblock, tempptr, startptr, lastptr);
        End;
        tbufpos := tbsav;
    End;
    If NOT skip Then tbufpos := tbsav;
    If length (inblock) < linemarker Then inblock := inblock + '         ';
End;

{*********************************************************}
Procedure FilStringSeparate(Var tempbuffer: stringline;
    Var tempptr, startptr, lastptr: listptr;
    Var tbufpos: byte);
{An der Stelle tbufpos in tempbuffer wird der String aufgebrochen}

Var prevptr, nextptr: listptr;

Begin
    If ((length (tempbuffer) > tbufpos) AND (tbufpos > 0)) Then
    Begin
        If FilNew (nextptr) Then
        Begin
            prevptr := tempptr^.last;
            prevptr^.datblock := Copy (tempbuffer, 1, tbufpos);
            nextptr^.datblock := Copy (tempbuffer, tbufpos + 1,
                length (tempbuffer));
            nextptr^.next := tempptr;
            nextptr^.last := prevptr;
            prevptr^.next := nextptr;
            tempptr^.last := nextptr;
            tempptr := nextptr;
        End;
    End
    Else
    If ((tbufpos = 0) AND (length (tempbuffer) > 0)) Then
    Begin
        prevptr := tempptr^.last;
        prevptr^.datblock := tempbuffer;
        prevptr^.next := tempptr;
        tempptr^.last := prevptr;
        tempptr := prevptr;
    End;
End;

{*********************************************************}
Procedure FilBufStart;
{Initialisieren des Buffers}

Begin
    If FilNew (bufendptr) Then
        If bufendptr <> nil Then
        Begin
            bufendptr^.datblock := '$$$End$$$';
            bufendptr^.last := nil;
            bufstartptr := bufendptr;
        End;
End;

{*********************************************************}
Procedure FilBufClear;
{Leeren eines Buffer}

Var bufptr: listptr;

Begin
    bufptr := bufstartptr;
    While bufptr <> bufendptr Do
    Begin
        bufstartptr := bufstartptr^.next;
        dispose (bufptr);
        bufptr := bufstartptr;
    End;
    bufstartptr := bufendptr;
    bufactptr := nil;
    {   marpartline:= false;}
End;

{*********************************************************}
Procedure FilFindPtr(pagenum, linenum: integer; Var foundptr,
    startptr, lastptr: listptr;
    lastinclude: boolean);
{suchen des Pointers auf die Zeile linenum auf der Seite pagenum
 lastinclude = true heisst, dass die letzte Zeile noch �bersprungen
               wird}

Var inblock, dummyblock: stringline;
    actline, linepos: byte;
    i: integer;
    endreached: boolean;

Begin
    {Seite suchen}
    FilFindPage (pagenum, i, foundptr, startptr, lastptr);

    {Zeile suchen}
    actline := topmargin;
    inblock := '';
    linepos := 0;
    While actline < linenum Do
    Begin
        FilCheckLine (inblock, dummyblock, foundptr, startptr,
            lastptr, linepos, endreached, true, false);
        actline := actline + 1;
    End;
    If lastinclude Then FilCheckLine (inblock, dummyblock, foundptr,
            startptr, lastptr,
            linepos, endreached, true, false);

    {String aufbrechen}
    FilStringSeparate (inblock, foundptr, startptr, lastptr, linepos);
End;

{*********************************************************}
Procedure FilFileToHeap(Var infile: text; Var actptr, startptr,
    lastptr: listptr; Var ok: boolean);
{Kopiert das File infile auf den Heap und initialisiert die Pointer}

Var tempptr: listptr;
    workdat: linerec;
    inblock, tempbuffer: stringline;
    version, code: Integer;
Begin
    If FilNew (lastptr) Then
    Begin
        If lastptr <> nil Then
        Begin
            {Daten lesen}
            workdat.datblock := '$$$END$$$';
            workdat.next := nil;
            workdat.last := nil;
            lastptr^ := workdat;
            startptr := lastptr;
            actptr := startptr;
            tempptr := startptr;
            tempbuffer := '';

            ok := true;
            ReSet (infile);
            ReadLn (infile, inblock);
            If inblock = '$$$RNSBUFFER$$$' Then
            Begin
                readln (infile);
                If IOResult <> 0 Then
                Begin
                    close (infile);
                    HlpHint (HntCannotReadFile, HintWaitEsc);
                    Exit;
                End;
                version := 0;
            End Else Begin
                If copy (inblock, 1, 7) = 'VERSION' Then
                Begin
                    Val (Copy (inblock, 9, 3), version, code);
                    If code <> 0 Then
                        version := 0;
                    readln (infile, inblock);
                    If IOResult <> 0 Then
                    Begin
                        close (infile);
                        HlpHint (HntCannotReadFile, HintWaitEsc);
                        Exit;
                    End;
                End Else If (inblock[1] = 'N') OR (inblock[1] = 'T') Then version := 1 Else Begin
                    ReadLn (infile, inblock);
                    If (inblock[1] = 'N') OR (inblock[1] = 'T') Then
                    Begin
                        ReSet (infile);
                        ReadLn (infile, inblock);
                        Version := 2;
                    End Else Begin
                        ReSet (infile);
                        ReadLn (infile, inblock);
                        version := 3;
                    End;
                End;
                Case version Of
                    0: ;{ buf file, header bereits ausgewertet  }
                    1: ReSet (Infile);{ kein header!                          }
                    2:
                    Begin
                        fontfile := inblock;  { nur font                              }
                        IniIniSymbols;
                    End;
                    3:
                    Begin
                        fontfile := inblock;  { font+snd...                           }
                        readln (infile, sndlength, sndlengthper, sndplaybeat, sndplaypulse, dispsound);
                        If IOResult <> 0 Then
                        Begin
                            close (infile);
                            HlpHint (HntCannotReadFile, HintWaitEsc);
                            Exit;
                        End;
                        readln (infile, sndlengthspm);
                        If IOResult <> 0 Then
                        Begin
                            close (infile);
                            HlpHint (HntCannotReadFile, HintWaitEsc);
                            Exit;
                        End;
                        IniIniSymbols;
                    End;{case version of 3}
                    4:
                    Begin
                        fontfile := inblock;  { font+snd...                           }
                        readln (infile, sndlength, sndlengthper, sndplaybeat, sndplaypulse, dispsound, soundattr);
                        If IOResult <> 0 Then
                        Begin
                            close (infile);
                            HlpHint (HntCannotReadFile, HintWaitEsc);
                            Exit;
                        End;
                        readln (infile, sndlengthspm);
                        If IOResult <> 0 Then
                        Begin
                            close (infile);
                            HlpHint (HntCannotReadFile, HintWaitEsc);
                            Exit;
                        End;
                        IniIniSymbols;
                    End;
                End;{case version}
            End;
            While ((NOT eof (infile)) AND (ok)) Do
            Begin
                readln (infile, inblock);
                If inblock = '' Then inblock := 'T'{if inblock=''}Else If (inblock[1] <> 'T') AND (inblock[1] <> 'N') Then
                Begin
                    While (Length (inblock) > 0) AND (inblock[1] = ' ') Do
                        delete (inblock, 1, 1);
                    If inblock = '' Then
                        inblock := 'T';
                    If (inblock[1] <> 'T') AND (inblock[1] <> 'N') Then
                        If HlpAskYesEsc ('File contains illegal data!',
                            'Press [Y] to continue, [ESC] to cancel', hpFileMenu) Then inblock := 'T        ' + inblock{if hlpaskyesesc}Else ok := false;{if inblock[1]<>'T'...}
                End;{if(inblock[1]<>'T') and (inblock[1]<>'N')}
                If ok AND ((inblock[1] = 'T') OR (inblock[1] = 'N')) Then
                    If (length (tempbuffer) + length (inblock) >= 255) Then
                    Begin
                        {Buffer voll, auf den Heap schreiben}
                        FilHeapInsertString (tempbuffer, tempptr, startptr, lastptr,
                            actptr, false);
                        tempbuffer := inblock + #0;
                    End Else tempbuffer := tempbuffer + inblock + #0{Noch Platz im Buffer, Buffer weiter f�llen};{if(inblock[1]='T')or(inblock[1]='N')}
            End;{while ((not eof(infile)) and (ok))}
            If ok Then FilHeapInsertString (tempbuffer, tempptr, startptr, lastptr,
                    actptr, false);{if ok}
            close (infile);
        End;{if lastptr<>nil}
    End{if filnew}Else ok := false;
End;

{*********************************************************}
Procedure FilHeapToFile(Var outfile: text; Var actptr, startptr,
    lastptr: listptr; dispmem: boolean;
    fileopen: boolean; WriteHeader: boolean);
{Kopiert den Heap auf das File infile und gibt den Speicher frei falls
 dispmem = true ist}

Var temptr: listptr;
    inblock, tempblock: stringline;
    lineend: byte;
    attr: word;
    fn: String;
Begin
    fn := UpString (actfilename);
    temptr := startptr;
    GetFAttr (outfile, attr);
    If ((attr AND readonly) <> 0) Then
    Begin
        HlpHintFrame (grminx, grmaxy - 48, grmaxx, grmaxy);
        txtfnt.write (grminx + 20, grmaxy - 32,
            'Read only file, not saved!',
            getcolor, sz8x16, stnormal);
        txtfnt.write (grminx + 20, grmaxy - 16,
            'Press any key to continue',
            getcolor, sz8x16, stnormal);
        XClearKbd;
        Repeat Until KeyPressed;
        XClearKbd;
    End Else Begin
        HlpHintFrame (grminx, grmaxy - {32}48, grmaxx, grmaxY);
        txtfnt.write (grminx + 20, grmaxY - 24{13}, HintTexts[HntSavingFile], getcolor, sz8x16, stnormal);
        Delay (250);
        If NOT fileopen Then
        Begin
            rewrite (outfile);
            If IOResult <> 0 Then
            Begin
                HlpHint (HntCannotCreateFile, HintWaitEsc);
                Exit;
            End;
        End;
        If writeheader Then
        Begin
            WriteLn (Outfile, 'VERSION ' + VersionString);
            If IOResult <> 0 Then
            Begin
                close (outfile);
                HlpHint (HntCannotWriteFile, HintWaitEsc);
                Exit;
            End;
            WriteLn (Outfile, fontfile);
            If IOResult <> 0 Then
            Begin
                close (outfile);
                HlpHint (HntCannotWriteFile, HintWaitEsc);
                Exit;
            End;
            writeln (Outfile, sndlength: 5, sndlengthper: 3, sndplaybeat: 3,
                sndplaypulse: 3, dispsound: 3, soundattr: 3);
            If IOResult <> 0 Then
            Begin
                close (outfile);
                HlpHint (HntCannotWriteFile, HintWaitEsc);
                Exit;
            End;
            WriteLn (Outfile, sndlengthspm);
            If IOResult <> 0 Then
            Begin
                close (outfile);
                HlpHint (HntCannotWriteFile, HintWaitEsc);
                Exit;
            End;
        End;
        While temptr <> lastptr Do
        Begin
            inblock := temptr^.datblock;
            lineend := pos (chr (0), inblock);
            While lineend > 0 Do
            Begin
                tempblock := Copy (inblock, 1, lineend - 1);
                writeln (outfile, tempblock);
                If IOResult <> 0 Then
                Begin
                    close (outfile);
                    HlpHint (HntCannotWriteFile, HintWaitEsc);
                    Exit;
                End;
                delete (inblock, 1, lineend);
                lineend := pos (chr (0), inblock);
            End;
            temptr := temptr^.next;
            If dispmem Then dispose (temptr^.last);
        End;
    End;
    close (outfile);
  {$IFDEF DEMO}
    CRC := GetCRC (fn);
    SetCRCFileEntry (fn, crc);
  {$ENDIF}
End;

{*********************************************************}
Procedure FilHeapInsertString(inblock: stringline; Var nowptr, firstptr,
    endptr, actptr: listptr; newactptr: boolean);
{Einfuegen des Strings inblock an die Stelle nowptr,
 nowptr wird auf den neuen String gesetzt, falls newactptr = true ist,
 sonst bleibt es unver�ndert
 ist nowptr = actptr, so wird auf jeden Fall ein neuer Pointer kreiert}

Var workdat: linerec;
    tempptr, prevptr: listptr;

Begin
    If ((newactptr) AND
        (nowptr <> endptr) AND
        (nowptr <> actptr) AND
        (firstptr <> endptr) AND
        ((length (inblock) + length (nowptr^.datblock)) < 255)) Then
        nowptr^.datblock := inblock + nowptr^.datblock
    Else { if ((newactptr) and }
    If ((NOT newactptr) AND
        (nowptr <> firstptr) AND
        (firstptr <> endptr) AND
        ((length (inblock) + length (nowptr^.last^.datblock)) < 255)) Then
        nowptr^.last^.datblock := nowptr^.last^.datblock + inblock
    Else {if ((not newactptr) and}
    If FilNew (tempptr) Then
    Begin
        workdat.datblock := inblock;
        workdat.next := nil;
        workdat.last := nil;
        tempptr^ := workdat;

        If firstptr = endptr Then
        Begin
            firstptr := tempptr;
            nowptr := endptr;
            tempptr^.next := endptr;
            endptr^.last := tempptr;
        End
        Else { if firstptr = nil then }
        Begin
            prevptr := nowptr^.last;
            tempptr^.next := nowptr;
            tempptr^.last := prevptr;
            nowptr^.last := tempptr;
            If prevptr <> nil Then prevptr^.next := tempptr;
            If tempptr^.next = firstptr Then firstptr := tempptr;
        End; { else if firstptr = nil then }
        If newactptr Then nowptr := tempptr;
    End{if filnew}{ else if ((not newactptr) and}; { else if ((newactptr) and }
End;

{*********************************************************}
Procedure FilHeapExtractString(Var inblock: stringline; Var actptr,
    startptr, endptr: listptr);
{Lesen des Strings inblock an der Stelle actptr,
 actptr zeigt neu auf den Nachfolger von inblock.
 Inblock wird geloescht.}

Var prevptr, nextptr: listptr;
    lineend: byte;
    tempbuffer: stringline;

Begin
    If ((actptr <> nil) AND (actptr <> endptr)) Then
    Begin
        tempbuffer := actptr^.datblock;
        lineend := pos (chr (0), tempbuffer);
        inblock := copy (tempbuffer, 1, lineend - 1);
        delete (tempbuffer, 1, lineend);
        If (length (tempbuffer) > 0) Then
            actptr^.datblock := tempbuffer
        Else
        Begin
            prevptr := actptr^.last;
            nextptr := actptr^.next;
            If startptr = actptr Then
                startptr := nextptr;
            prevptr^.next := nextptr;
            nextptr^.last := prevptr;
            dispose (actptr);
            actptr := nextptr;
        End;
    End;
End;

{*********************************************************}
Procedure FilHeapSqueeze(Var actptr, startptr, endptr: listptr;
    trailblank: boolean);
{Heap auf maximale Stringl�nge verdichten}

Var inblock: stringline;
    lineend: byte;
    t1ptr, t2ptr: listptr;

Begin
    If startptr <> endptr Then
    Begin
        t1ptr := startptr;
        t2ptr := t1ptr^.next;
        While t2ptr <> endptr Do
            If t2ptr <> actptr Then
            Begin
                lineend := pos (chr (0), t2ptr^.datblock);
                If (length (t1ptr^.datblock) + lineend < 255) Then
                Begin
                    FilHeapExtractString (inblock, t2ptr, startptr, endptr);
                    If (trailblank AND (inblock[1] = 'T')) Then
                        IniTrailBlank (inblock);
                    t1ptr^.datblock := t1ptr^.datblock + inblock + chr (0);
                End
                Else
                Begin
                    t1ptr := t2ptr;
                    t2ptr := t2ptr^.next;
                End;
            End
            Else
            Begin
                t1ptr := t2ptr;
                t2ptr := t2ptr^.next;
            End; {while t2ptr <> endptr do}
    End; {if startptr <> endptr then}
End;

{*********************************************************}
Procedure FilSavePage(FirstLine, LastLine: integer; Var tempptr,
    startptr, lastptr: listptr);
{Versorgen der Seite von firstline bis lastline
 tempptr zeigt auf das Ende der Seite}

Var i: integer;

Begin
    For i := firstline To lastline Do
    Begin
        If page[i, 1] = 'T' Then IniTrailBlank (page[i]);
        FilHeapInsertString (page[i] + chr (0), tempptr, startptr, lastptr,
            tempptr, false);
    End;
    FilHeapSqueeze (tempptr, startptr, lastptr, true);
End;

{**************************************************************}
Procedure FilFindPage(Pagenumber: integer; Var Actpage: integer;
    Var tempptr, startptr, lastptr: listptr);

Var actline, i: integer;
    inblock, dummyblock: stringline;
    linepos: byte;
    endreached: boolean;

{Sucht die Seite Pagenumber im Heap. Ist sie gefunden,
wird ActPage= Pagenumber}

Begin
    actpage := 0;
    actline := TopMargin;
    tempptr := startptr;
    inblock := '';
    linepos := 0;
    endreached := false;

    While (NOT endreached) AND (actpage < pagenumber) Do
    Begin
        FilCheckLine (inblock, dummyblock, tempptr, startptr, lastptr,
            linepos, endreached, true, false);
        actline := actline + 1;
        If actline > pagelength Then
        Begin
            actpage := actpage + 1;
            actline := TopMargin;
        End;
    End;
    If endreached Then
    Begin
        i := actpage - 1;
        FilFindPage (i, Actpage, tempptr, startptr, lastptr);
    End;
    FilStringSeparate (inblock, tempptr, startptr, lastptr, linepos);
End;

{**************************************************************}
Procedure FilSkipPage(Var tempptr, startptr, lastptr: listptr);

{Springt auf die n�chste Seite im Heap, und holt die aktuelle
 aus dem Heap}

Var actline: integer;

Begin
    actline := topmargin;
    If tempptr <> nil Then
        While (tempptr <> lastptr) AND (actline <= PageLength) Do
        Begin
            FilHeapExtractString (page[actline], tempptr, startptr, lastptr);
            actline := actline + 1;
        End;
End;

Function FilCompareFiles(FName1, FName2: String): Boolean;
Var P1, P2: Pointer;
    F1, F2: File;
    L: LongInt;
    A: Word;
    OK: Boolean;
    SFMode: Byte;
Begin
    SFMode := FileMode;
    FileMode := 0;
    OK := True;
    Assign (F1, FName1);
    ReSet (F1, 1);
    Assign (F2, FName2);
    ReSet (F2, 1);
    L := FileSize (F1);
    If L <> FileSize (F2) Then
    Begin
        FilCompareFiles := False;
        Close (F1);
        Close (F2);
        Exit;
    End;
    While L > 0 Do
    Begin
        If L > $FFFF Then
            a := $FFFF
        Else
            a := L;
        GetMem (P1, a);
        GetMem (P2, a);
        BlockRead (F1, P1^, a);
        BlockRead (F2, P2^, a);
        // Compare memory blocks
        OK := CompareMem (P1, P2, a);
        FreeMem (P1, a);
        FreeMem (P2, a);
        If L > $FFFF Then
            L := L - $FFFF
        Else
            L := 0;
    End;
    FileMode := SFMode;
    FilCompareFiles := OK;
    Close (F1);
    Close (F2);
End;

Procedure FilFontSelect;

(*Var instring        : String;
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
Var s: string;
Begin
    s := FilFileSelect ('Select Symbolfont', '*.FNT', '');
    If s <> '' Then
    Begin
        fontfile := s;
        IniIniSymbols;
    End;
End;

Function FilFileSelect(prompt, wildcard, dir: string): string;
Var instring: String;
    ok: boolean;
    MausX, MausY: Word;
    Maustaste: Word;
    MausMenu: Word;
Begin
    Mausdunkel;
    MausMenu := 0;
    MausSetXY (300, 90);

    SetFillStyle (Solidfill, 7);   {Auswahl-Menu}
    Bar (GrMinX + 1, GrMinY + 1, GrMinX + 20 * 8, GrMaxY - 1);

    SetColor (12);  {Abtrennungslinien}
    Line (GrMinx, 25, grminx + 20 * 8 - 1, 25);
    Line (grminx + 20 * 8, grminy, grminx + 20 * 8, grmaxy - 1);
    Line (grminx + 20 * 8 + 1, grminy, grminx + 20 * 8 + 1, grmaxy - 1);

    Setcolor (5);
    Line (grminx + 20 * 8 + 2, grminy, grminx + 20 * 8 + 2, grmaxy - 1);
    Line (GrMinx, 26, grminx + 20 * 8 - 1, 26);
    IniExpand (instring, 57);
    SetColor (12);
    IniOutTextXY (5, 1, prompt);
    MausBereichAdd (GrMinX + 2, GrMinX + 20 * 8, GrMinY + 2, GrMaxY - 1, 3);
    maustaste := 0;
    ok := false;
    If dir <> '' Then
        dir := dir + '\';
    SduSodir (True, ok, False, instring, wildcard, dir, false,
        22, 45, 22, 1, mausx, mausy, maustaste, mausmenu, 0, 0, false);
    SduSodir (False, ok, True, instring, wildcard, dir, false,
        22, 45, 22, 1, mausx, mausy, maustaste, 3, 0, 0, false);
    If Ok Then
        FilFileSelect := instring
    Else
        FilFileSelect := '';
    PagRefPage;
End;

Procedure FilDelPage(Var actptr, startptr, lastptr: listptr);
Var delfil: Text;
    i, result: integer;
    oldpage: integer;
Begin
    lastbuf := 2;
    delpage := true;
    assign (delfil, 'delpage');
    rewrite (delfil);
    If IOResult <> 0 Then
    Begin
        HlpHint (HntCannotCreateFile, HintWaitEsc);
        Exit;
    End;
    If (pagebuf = -1) OR (pagebuf = pagecount) Then
        For i := 1 To pagelength Do
        Begin
            writeln (delfil, page[i]);
            If IOResult <> 0 Then
            Begin
                close (delfil);
                HlpHint (HntCannotWriteFile, HintWaitEsc);
                Exit;
            End;
        End Else Begin
        oldpage := pagecount;
        { Aktuelle Seite sichern }
        FilSavePage (1, pagelength, actptr, startptr, lastptr);
        { Zu l�schende Seite suchen und vom Heap holen }
        FilFindPage (pagebuf, Result, actptr, startptr, lastptr);
        PagGetPageFromHeap (actptr, startptr, lastptr, i);
        For i := 1 To pagelength Do
        Begin
            writeln (delfil, page[i]);
            If IOResult <> 0 Then
            Begin
                close (delfil);
                HlpHint (HntCannotWriteFile, HintWaitEsc);
                Exit;
            End;
        End;
        pagecount := oldpage;
        FilFindPage (pagecount, Result, actptr, startptr, lastptr);
    End;
    close (delfil);
    {goto previous page if this is last page}
    If actptr = lastptr Then
        dec (pagecount);
    If pagecount > 0 Then
    Begin{show new page, dont save this page}
        FilFindPage (pagecount, Result, actptr, startptr, lastptr);
        PageCount := Result;
        IniNewPage (i{dummy});{parameter sollte linenum sein, wird aber nicht ber�cksichtigt}
        PagGetPageFromHeap (actptr, startptr, lastptr, i);
    End Else Begin
        PagGetSetupPage (actptr, startptr, lastptr);
        pagecount := 1;
    End;
    PagRefPage;
    FilUnMarkPage;
End;
Procedure FilUnDelPage(Var actptr, startptr, lastptr: listptr);
Var delfil: text;
    i: integer;
Begin
    If delpage Then
    Begin
        { Aktuelle Seite sichern }
        FilSavePage (1, PageLength, actptr, startptr, lastptr);
        { Und gleich wieder suchen }
        FilFindPage (pagecount, i, actptr, startptr, lastptr);
        pagecount := i;
        { SetupPage ins page array holen }
        PagGetSetupPage (actptr, startptr, lastptr);
        { und delpage hineinschreiben }
        assign (delfil, 'delpage');
        ReSet (delfil);
        For i := 1 To pagelength Do
            ReadLn (delfil, page[i]);
        close (delfil);
        { Pointer auf diese Seite setzen }
        FilFindPage (PageCount, i, actptr, startptr, lastptr);
        PagRefPage;
        FilUnMarkPage;
    End;
End;
Procedure FilPastePage(Var actptr, startptr, lastptr: listptr);
Var copyfile: Text;
    i: integer;
Begin
    If pagebuf <> -1 Then
        filcopypage (actptr, startptr, lastptr);
    If copypage Then
    Begin
        i := pagecount;
        FilSavePage (1, PageLength, actptr, startptr, lastptr);
        PagGetSetupPage (actptr, startptr, lastptr);
        FilFindPage (pagecount, i, actptr, startptr, lastptr);
        assign (copyfile, 'COPYPAGE');
        ReSet (copyfile);
        For i := 1 To pagelength Do
            ReadLn (copyfile, page[i]);
        close (copyfile);
        PagRefPage;
        filUnMarkPage;
    End;
End;

Procedure FilMarkPage;
Begin
    pagebuf := pagecount;
    MarkInverse (1, Pagelength, grminx, grmaxx);
End;

{������������������������ FilUnMarkPage ��������������������������������������}

Procedure FilUnMarkPage;

{var linenum,startx,endx,x,y: integer;}

Begin
    If pagebuf <> -1 Then
    Begin
        pagebuf := -1;
        { linenum:=2; }
        pagrefpage; {einklammern wenn Alternative PagRefClearVal geht!}
        {    PagUnmark;}{ev. bringt das etwas}
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
    End;
End;

{������������������������ FilCopyPage ����������������������������������������}

Procedure FilCopyPage(Var actptr, startptr, lastptr: listptr);
Var Copyfile: Text;
    i, result: integer;
    oldpage:  integer;
Begin
    copypage := true;
    assign (copyfile, 'COPYPAGE');
    rewrite (Copyfile);
    If IOResult <> 0 Then
    Begin
        HlpHint (HntCannotCreateFile, HintWaitEsc);
        Exit;
    End;
    If pagebuf = -1 Then
        For i := 1 To pagelength Do
        Begin
            writeln (Copyfile, page[i]);
            If IOResult <> 0 Then
            Begin
                close (copyfile);
                HlpHint (HntCannotWriteFile, HintWaitEsc);
                Exit;
            End;
        End Else Begin
        oldpage := pagecount;
        FilSavePage (1, pagelength, actptr, startptr, lastptr);
        FilFindPage (pagebuf, Result, actptr, startptr, lastptr);
        PagGetPageFromHeap (actptr, startptr, lastptr, i);
        For i := 1 To pagelength Do
        Begin
            writeln (copyfile, page[i]);
            If IOResult <> 0 Then
            Begin
                close (copyfile);
                HlpHint (HntCannotWriteFile, HintWaitEsc);
                Exit;
            End;
        End;
        FilSavePage (1, pagelength, actptr, startptr, lastptr);
        FilFindPage (oldpage, Result, actptr, startptr, lastptr);
        PagGetPageFromHeap (actptr, startptr, lastptr, i);
    End;
    close (copyfile);
End;

Procedure FilCutBlockFile(Name: String);
Var F1, F2: Text;
    i, j: Integer;
    inblock: String;
Begin
    Assign (F1, Name);
    ReSet (F1);
    Assign (F2, 'TEMP.RNS');
    i := 0;j := 0;
    While NOT EoF (F1) Do
    Begin
        ReadLn (F1, InBlock);
        If inblock[1] = 'T' Then
        Begin
            While inblock[length (inblock)] = ' ' Do
                SetLength (inblock, Length (inblock) - 1);
            If inblock <> 'T' Then
                j := i;
        End Else
            j := i;
        inc (i);
    End;
    ReSet (F1);
    ReWrite (F2);
    ReadLn (F1, inblock);
    ReadLn (F1);
    WriteLn (F2, Inblock);
    WriteLn (F2, 0: 5, 1: 5, 1: 5, 1: 5, (j MOD 52) + 1: 5, 1: 5, (j DIV 52) + 1: 5);
    If j > 53 Then j := j - 52;
    For i := 2 To j Do
    Begin
        ReadLn (F1, InBlock);
        WriteLn (F2, InBlock);
    End;
    Close (F1);
    Erase (F1);
    Close (F2);
    Rename (F2, Name);
End;

Function FilNumPages(actptr, startptr, lastptr: listptr): integer;
    { Anzahl Seiten }
Var i: integer;
    actpage: integer;
    tempptr: listptr;
Begin
    i := 0;
    Repeat
        inc (i);
        FilFindPage (i, actpage, tempptr, startptr, lastptr);
    Until i <> actpage;
    FilNumPages := i - 1;
End;
Begin
    FilBufStart;
End.
