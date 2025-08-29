{$I RNS.H}

Unit editunit;

Interface

Uses
    Graph,
    GCurUnit,
    Symbols,
    GetUnit,
    TitleUnit,
    InitSc,
    menutyp,
    inout,
    fileunit,
    pageunit,
    comunit,
    noteunit,
    markunit,
    helpunit,
    strings,
    butunit,
    timer,
    dos,
    crt,
    xcrt,
    UserExit,
    Texts;

Procedure EdiRythmEdit(instring, bakname: string; defpagesetup, demloc: boolean);
Function EdiSavePossible(fn: String): Boolean;
Implementation

Uses mousdrv,
    CRCUnit;

Const crcOK = 0;
    crcNIL  = 1;
    crcNOK  = 2;


Function EdiCheckCRC(instring: String): Byte;
Var crc: Word;
Begin
    If GetCRCFileEntry (instring, crc) Then
    Begin
        If GetCRC (instring) = crc Then
            EdiCheckCRC := crcOK
        Else
            EdiCheckCRC := crcNOK;
    End Else
        EdiCheckCRC := crcNIL;
End;
Procedure EdiCopyFile(N1, N2: String);
Var P: Pointer;
    S: LongInt;
    C, C1, M: Word;
    F1, F2: File;
Begin
    Assign (F1, N1);
    Assign (F2, N2);
    FileMode := 0;
    ReSet (F1, 1);
    If IOResult <> 0 Then Exit;
    FileMode := 1;
    ReWrite (F2, 1);
    If IOResult <> 0 Then
    Begin
        Close (F1);
        Exit;
    End;
    FileMode := 2;
    S := FileSize (F1);
    If S > 65528 Then
        M := 65528
    Else
        M := S;
    GetMem (P, M);
    C := 1;
    While (S > 0) AND (C <> 0) Do
    Begin
        If S > M Then BlockRead (F1, P^, M, C) Else BlockRead (F1, P^, S, C);
        If IOResult <> 0 Then Break;
        Dec (S, C);
        BlockWrite (F2, P^, C, C1);
        If IOResult <> 0 Then Break;
        If C1 <> C Then
            C := 0;
    End;
    FreeMem (P, M);
    Close (F1);
    Close (F2);
End;

Function EdiCheckDemoFileName(instring: String; Var f: Text): Boolean;
    { Check if file is in list and CRC ok }
Begin
    instring := UpString (instring);
    Case EdiCheckCRC (instring) Of
        crcOK: EdiCheckDemoFileName := True;{      if pos('TESTFILE.RNS',instring)=0 Then
        SetFAttr(infile, ReadOnly);}
        crcNIL:
        Begin
            HlpHint (HntDemoNIL, 0, []);
            EdiCheckDemoFileName := False;
        End;
        crcNOK: If pos ('TESTFILE.RNS', instring) = 0 Then
            Begin
                HlpHint (HntDemoCRC, 0, []);
                EdiCheckDemoFileName := False;
            End Else Begin
                HlpAsk ('Demoversion: TESTFILE.RNS has been changed, restoring previous one',
                    'Press [Enter] to continue', hpEdit, [#13]);
                {        HlpHint(HntDemoCRCTestfile,0, []);}
                If isCRCOK ('DEMODIR\DEMOTEST.PRE') Then
                Begin
                    EdiCopyFile ('DEMODIR\DEMOTEST.PRE', 'DEMODIR\TESTFILE.RNS');
                    SetCRCFileEntry ('DEMODIR\TESTFILE.RNS', GetCRC ('DEMODIR\TESTFILE.RNS'));
                    EdiCheckDemoFileName := True;
                End Else If isCRCOK ('TESTFILE.RNS') Then
                Begin
                    EdiCopyFile ('TESTFILE.RNS', 'DEMODIR\TESTFILE.RNS');
                    SetCRCFileEntry ('DEMODIR\TESTFILE.RNS', GetCRC ('DEMODIR\TESTFILE.RNS'));
                    EdiCheckDemoFileName := True;
                End Else EdiCheckDemoFileName := False;
            End;
    End;
End;

Function SlashSeparated(prev, next: String): String;
Begin
    If next = '' Then SlashSeparated := prev
    Else If prev = '' Then SlashSeparated := next
    Else SlashSeparated := prev + ' / ' + next;
End;

{******************************************************}
Procedure EdiRythmEdit(instring, bakname: string; defpagesetup, demloc: boolean);

Var
    j: integer;
    Response: Response_Type;
    Direction: Movement;
    KeyResponse: Char;
    Result: integer;
    actpost, actposn: integer;
    actptr, startptr, lastptr: listptr;
    linenum: integer;
    firstpage: byte;
    inblock: stringline;
    ifile: text;
    ok, shiftp, ctrlp: boolean;
    mausx, mausy, maustaste, mp, mausmenu: word;
    attr: word;
    Savepat: boolean;
    Hide: string;

Begin
    soundattr := 0;
    Mausdunkel;
    symcount := 0;
    Response := No_Response;
    firstpage := 1;
    actposn  := 1;
    actpost  := 1;
    vtimer.init;
    If defsetuppage IN actedit Then firstpage := 0;
  {$IFNDEF DEMO }If demLOC Then {$ENDIF}
        If NOT EdiCheckDemoFileName (instring, infile) Then Exit;
    If defpagesetup Then
    Begin
        FilAssignCfgFile (infile, instring, true);
        Reset (infile);
        If IOResult <> 0 Then
        Begin
            HlpHint (HntCannotOpenFile, HintWaitEsc, [instring]);
            Exit;
        End;
        instring := instring + '.cfg';
        readln (infile, inblock);
        If IOResult <> 0 Then
        Begin
            close (infile);
            HlpHint (HntCannotReadFile, HintWaitEsc, [instring]);
            Exit;
        End;
        If inblock = '$$$RNSBUFFER$$$' Then
            bufffile := true
        Else
            bufffile := false;
        ReSet (infile);
        If IOResult <> 0 Then
        Begin
            HlpHint (HntCannotOpenFile, HintWaitEsc, [instring]);
            Exit;
        End;
    End Else assign (infile, instring){    if ((demloc) and (Pos('TESTFILE.RNS',instring) = 0)) then begin
      SetFAttr(infile, ReadOnly);
    end else};

    If ((NOT IniFileExist (instring)) AND
        (NOT (defsetuppage IN actedit))) Then
    Begin
        firstpage := 0;
        pagesav := 1;
        actedit := actedit + [setuppage];
        IniSwapColors;
        FilAssignCfgFile (ifile, 'pageset', true);
        Rewrite (infile);
        If IOResult <> 0 Then
        Begin
            HlpHint (HntCannotCreateFile, HintWaitEsc, ['pageset']);
            Exit;
        End;
        ReSet (ifile);
        If IOResult <> 0 Then
        Begin
            close (infile);
            HlpHint (HntCannotOpenFile, HintWaitEsc, ['pageset']);
            Exit;
        End;
        For linenum := topmargin To pagelength Do
        Begin
            Readln (ifile, inblock);
            If IOResult <> 0 Then
            Begin
                close (ifile);
                close (infile);
                HlpHint (HntCannotReadFile, HintWaitEsc, ['pageset']);
                Exit;
            End;
            Writeln (infile, inblock);
            If IOResult <> 0 Then
            Begin
                close (ifile);
                close (infile);
                HlpHint (HntCannotWriteFile, HintWaitEsc, ['pageset']);
                Exit;
            End;
        End;
        Close (infile);
        Close (ifile);
    {leeren von Pagefil.rns Dieses File wird nach Abschluss
     des Pagelayout in Sp2Unit zur�ckgeladen}
        Assign (ifile, 'PAGEFIL.RNS');
        rewrite (ifile);
        If IOResult <> 0 Then
        Begin
            HlpHint (HntCannotCreateFile, HintWaitEsc, ['pageset']);
            Exit;
        End;
        close (ifile);
    End;
    If NOT defpagesetup Then
    Begin
        reset (infile);
        If IOResult <> 0 Then
        Begin
            HlpHint (HntCannotOpenFile, HintWaitEsc, ['pageset']);
            Exit;
        End;
        readln (infile, inblock);
        If IOResult <> 0 Then
        Begin
            close (infile);
            HlpHint (HntCannotReadFile, HintWaitEsc, ['pageset']);
            Exit;
        End;
        If inblock = '$$$RNSBUFFER$$$' Then
            bufffile := true
        Else
            bufffile := false;
        ReSet (infile);
        If IOResult <> 0 Then
        Begin
            HlpHint (HntCannotOpenFile, HintWaitEsc, ['pageset']);
            Exit;
        End;
    End;
    actfilename := instring;
    FilFileToHeap (infile, actptr, startptr, lastptr, ok);
    GetFAttr (infile, attr);
    If ((attr AND readonly) <> 0) Then
    Begin
        Mauszeigen;
        HlpHintFrame (grminx, grmaxy - 22, grmaxx, grmaxy + 32);
        txtfnt.write (grminx + 16, grmaxy - 5,
            'Read only file, changes will not be saved!',
            getcolor, sz8x16, stnormal);
        txtfnt.write (grminx + 16, grmaxy + 15,
            'Press [Esc] to quit or any other key to continue ',
            getcolor, sz8x16, stnormal);
        ok := False;
        While NOT OK Do
            ok := (ReadKey <> #27);
        While KeyPressed Do ReadKey;
        Mausdunkel;
    End;
    If ok Then
    Begin
        IniSetAllDACRegs (ThePalette);
        MarkInit;
        IniRefInit;
        ButInit;
        nextresponse := NO_RESPONSE;
        FilFindPage (firstpage, result, actptr, startptr, lastptr);
        GcuCursorClear;
        GcuPatternRestore;
        PagDisplayPage (actptr, startptr, lastptr);
        j := 1000;
        Hide := '';
        If DispSpec = 2 Then
        Begin
            Hide := SlashSeparated (Hide, 'Nonprintings');
            j := 0;
        End;
        If DispGrid = 1 Then
            Hide := SlashSeparated (Hide, 'Grids');
        If DispHidLines = 2 Then
            Hide := SlashSeparated (Hide, 'Helplines');
        If DispCurs = 3 Then
        Begin
            Hide := SlashSeparated (Hide, 'Cursor');
            j := 0;
        End;
        If Hide <> '' Then
            HlpHint (HntDisp, j, [Hide]);
        If (linestyles IN actedit) Then linenum := linestyletop Else linenum := TopMargin + 1;
        PagCursorLeft (linenum, actposn, actpost);
        GcuCursorRestore;
        MausInstall;
        MausGrafik (1);
        MausBereich (0 + 9, GetMaxX + 5, 0 + 9, GetMaxY);
        MausZeigen;

        Keyresponse := #0;
        While (Response <> ESCAPE) AND NOT
            ((Response = SPECIALKEY) AND (Keyresponse = #85)) Do
        Begin
            If NOT showmenus Then PagShowCurPosDistances (Linenum, ActPosn, ActPost, 0);
            If nextresponse = no_response Then Get_Response (Response, Direction, KeyResponse, shiftp, ctrlp,
                    mausx, mausy, maustaste, mp, mausmenu) Else Begin
                response := nextresponse;
                keyresponse := nextkey;
                nextresponse := NO_RESPONSE;
                shiftp := nextshift;
                ctrlp  := nextctrl;
            End;
            MausDunkel;
            IniRefInit;
            If Response = NO_RESPONSE Then
            Begin
                SavePat := ComEdMaus (mausx, mausy - line2thick,
                    maustaste,
                    linenum, actposn, actpost);
                ComMouseAssign (mausx, mausy, maustaste,
                    Response, KeyResponse, shiftp, ctrlp);
            End Else Begin
                GcuPatternRestore;
                SavePat := True;
            End;
            Case Response Of
                ESCAPE: ComEdEscape (linenum, actposn, actpost, actptr,
                        startptr, lastptr, Response);
                ARROW: ComEdArrow (Direction, linenum, actposn, actpost);
                RETURN: ComEdReturn (linenum, actposn, actpost,
                        shiftp, ctrlp);
                KEY: ComEdKey (linenum, actposn, actpost, actptr,
                        startptr, lastptr, KeyResponse, shiftp, ctrlp);
                SPECIALKEY: ComEdSpecial (linenum, actposn, actpost, actptr,
                        startptr, lastptr,
                        KeyResponse, shiftp, ctrlp);
            End; { case Response of }
            PagRefreshPage (refxmin, refymin, refxmax, refymax + 3); {+3 ###, wegen Refresh nach F5 - Esc}
            If SavePat Then
                GcuCursorRestore;
            SavePat := True;
            If mausform <> 1 Then
            Begin
                MausGrafik (1);
                MausBereich (0 + 9, GetMaxX + 5, 0 + 9, GetMaxY);
            End;
            MausZeigen;
        End; { while Response <> ESCAPE do }
        If Response = ESCAPE Then
            FileChanged := 2;
        FilSavePage (1, PageLength, actptr, startptr, lastptr);
        Mausdunkel;
        soundattr := soundattr AND NOT saRhythm;
        If defpagesetup Then
        Begin
            rewrite (infile);
            If IOResult <> 0 Then
            Begin
                HlpHint (HntCannotCreateFile, HintWaitEsc, [instring]);
                Exit;
            End;
            FilHeapToFile (infile, actptr, startptr, lastptr, true, true, true);
        End Else If EdiSavePossible (actfilename) Then
        Begin
            If FileChanged = 2 Then
            Begin
                FileChanged := 0;
                FileMode := 2;
                ReWrite (InFile);
                If IOResult = 0 Then
                Begin
                    If bufffile Then
                    Begin
                        WriteLn (infile, '$$$RNSBUFFER$$$');
                        If IOResult <> 0 Then
                        Begin
                            close (infile);
                            HlpHint (HntCannotWriteFile, HintWaitEsc, [instring]);
                            Exit;
                        End;
                        WriteLn (infile, '    -1    -1    -1    -1    -1    -1    -1');
                        If IOResult <> 0 Then
                        Begin
                            close (infile);
                            HlpHint (HntCannotWriteFile, HintWaitEsc, [instring]);
                            Exit;
                        End;

                        FilHeapToFile (infile, actptr, startptr, lastptr, true, true, false);
                        FilCutBlockFile (FExpand (TextRec (infile).Name));
                    End Else Begin
                        FilHeapToFile (infile, actptr, startptr, lastptr, true, true, true);
                    End;
                End Else Begin
                    GetFAttr (infile, attr);
                    If attr AND ReadOnly <> 0 Then
                        HlpHint (HntReadOnly, HintWaitEsc, [instring])
                    Else
                        HlpHint (HntFileAccesDenied, HintWaitEsc, [instring]);
                End;
            End;
        End Else Begin
            HlpHintFrame (grminx, grmaxy - 48, grmaxx, grmaxy);
            txtfnt.write (grminx + 20, grmaxy - 32,
                'Demoversion: not saved',
                getcolor, sz8x16, stnormal);
            txtfnt.write (grminx + 20, grmaxy - 16,
                'Press any key to continue',
                getcolor, sz8x16, stnormal);
            XClearKbd;
            Repeat Until KeyPressed;
            XClearKbd;
        End;
        FilBufClear;
        MarkInit;
    End;
  {$IFDEF DEMO}
    EdiCopyFile ('DEMODIR\TESTFILE.RNS', 'DEMODIR\DEMOTEST.PRE');
    SetCRCFileEntry ('DEMODIR\DEMOTEST.PRE', GetCRC ('DEMODIR\DEMOTEST.PRE'))
  {$ENDIF};
    Mausdunkel;
End;
Function EdiSavePossible(fn: String): Boolean;
Begin
    EdiSavePossible :={$IFNDEF DEMO}((IniFileExist ('imie.rns')) AND TitVerify) OR{$ENDIF}(pos ('TESTFILE.RNS', fn) <> 0);
End;
End.
