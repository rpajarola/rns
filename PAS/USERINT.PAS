{$I RNS.H}

Unit userint;

Interface

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

Var demoversion: boolean;

Procedure UseTopMenu;

Implementation

Uses grintunit,
    mousdrv,
    fileunit;

Type PTextBuf = ^TTextBuf;
    TTextBuf  = Array[0..127] Of Char;
    TTextRec  = Record
        Handle: Word;
        Mode: Word;
        BufSize: Word;
        BufPos: Word;
        BufEnd: Word;
        BufPtr: PTextBuf;
        OpenFunc: Pointer;
        InOutFunc: Pointer;
        FlushFunc: Pointer;
        CloseFunc: Pointer;
        UserData: Array[1..16] Of Byte;
        Name: Array[0..79] Of Char;
        Buffer: TTextBuf;
    End;

Const topstartx = 2;
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

Var CLS, CLE: byte;

{******************************************************}

Procedure KillCursor;
Begin
    { TODO: Implement cursor hiding functionality }
    { Original: INT 10h function 3 (get cursor) then function 1 (set cursor invisible) }
    CLS := 0; { Save current cursor start line }
    CLE := 0; { Save current cursor end line }
    { Stub: Cursor visibility control not implemented }
End;
{********************************************************}

Procedure RestoreCursor;
Begin
    { TODO: Implement cursor restoration functionality }
    { Original: INT 10h function 1 (set cursor) with saved CLS/CLE values }
    { Stub: Cursor visibility control not implemented }
End;
{******************************************************}
Procedure UseGetConfig;
{Liest die Configuration aus dem File CONFIG.rns}

    Procedure SearchADir(Var S: String);
    Var F: SearchRec;
    Begin
        S := '*.*';
        FindFirst (S, Directory, F);
        While (((F.Attr AND Directory) = 0) OR (F.Name = '.') OR
                (F.Name = '..') OR (F.Name = '')) AND (DosError = 0) Do
            FindNext (F);
        S := F.Name;
    End;
Var
    infile: text;
    b: byte;
    actdir: string;
Begin
    GetDir (0, actdir);
    Assign (infile, 'config.rns');
    reset (infile);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot open config file: CONFIG.RNS');
        WriteLn ('Make sure the config file exists in the current directory.');
        Halt (2);
    End;
    readln (infile, datadir);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot read data directory from CONFIG.RNS');
        close (infile);
        Halt (100);
    End;
    ChDir (DataDir);
    If IOResult <> 0 Then SearchADir (Datadir) Else
        ChDir (ActDir);
    readln (infile, colorfile);
    readln (infile, psdir);
    readln (infile, bufdir);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot read configuration data from CONFIG.RNS');
        close (infile);
        Halt (100);
    End;
    close (infile);
    b := pos ('.', datadir);
    If (b = length (datadir)) AND (b <> 0) Then
        datadir := copy (datadir, 1, b - 1) + copy (datadir, b + 1, length (datadir) - b - 1);
    If NOT IniDirExist (datadir) Then
    Begin
        MkDir (datadir);
        If IOResult <> 0 Then RunError (IOResult);
    End;
    If psdir = '' Then
        psdir := 'PSFILES';
    If bufdir = '' Then
        bufdir := 'BUFFERS';
    If NOT IniDirExist (psdir) Then
        MkDir (psdir);
    If IOResult <> 0 Then RunError (IOResult);
    If NOT IniDirExist (bufdir) Then
        MkDir (bufdir);
    If IOResult <> 0 Then RunError (IOResult);
    ChDir (ActDir);
End;

{******************************************************}
Procedure UseSaveConfig;
{Speichert die Configuration in das File CONFIG.rns}

Var
    outfile: text;

Begin
    Assign (outfile, 'config.rns');
    rewrite (outfile);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot create config file: CONFIG.RNS');
        WriteLn ('Check write permissions in current directory.');
        Halt (5);
    End;
    writeln (outfile, datadir);
    writeln (outfile, colorfile);
    writeln (outfile, psdir);
    writeln (outfile, bufdir);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot write configuration data to CONFIG.RNS');
        close (outfile);
        Halt (101);
    End;
    close (outfile);
End;

{******************************************************}
Procedure UseGetSetup;
{Liest das setup-file}

Var infile: text;
    inblock: stringline;
    tempattr: lineattrtype;

Begin
    FilAssignRnsFile (infile, 'setup', true);
    {Check if file was opened successfully}
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot open setup file');
        WriteLn ('Make sure the setup file exists in the data directory.');
        Halt (2);
    End;
    {Aktuelle Attribute lesen}
    readln (infile, inblock);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot read setup data from setup file');
        close (infile);
        Halt (100);
    End;
    GetNoteBlock (inblock, tempattr, 1);
    readln (infile, insmusicline);
    actattr := tempattr;
    readln (infile, linecount);
    readln (infile, dispspec, dispgrid, disphidlines, dispcurs,
        manset, charset, blankset);
    readln (infile, prformat, prdest);
    readln (infile, prfname);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot read setup parameters from setup file');
        close (infile);
        Halt (100);
    End;
    IniLeadBlank (prfname);
    readln (infile, prfile);
    readln (infile, prdevice);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot read printer settings from setup file');
        close (infile);
        Halt (100);
    End;
    IniLeadBlank (prdevice);
    readln (infile, sndlength, sndlengthper, sndplaybeat, sndplaypulse, dispsound);
    readln (infile, sndchar);
    readln (infile, sndbeat, sndbeatlength);
    readln (infile, sndpulse, sndpulselength);
    readln (infile, fontfile);
    readln (infile, sndlengthspm);{New}
    readln (infile, ctrlenterofs);
    readln (infile, sndwarning);
    readln (infile, dispslash);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot read sound and display settings from setup file');
        close (infile);
        Halt (100);
    End;
    If sndwarning < 1 Then
        sndwarning := 1;
    If ctrlenterofs = 0 Then
        ctrlEnterOfs := 2;
    If dispslash < 1 Then
        dispslash := 1;
    close (infile);
End;

{******************************************************}
Procedure UseSaveSetup;
{speichert das Setup-File}

Var infile: text;

Begin
    FilAssignRnsFile (infile, 'setup', false);
    {Check if file was opened successfully}
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot create setup file');
        WriteLn ('Check write permissions in data directory.');
        Halt (5);
    End;
    {Aktuelle Attribute schreibenlesen}
    writeln (infile, '          ',
        actattr.beats: 5, actattr.eint: 5, actattr.resolution: 5,
        actattr.linestyle: 5);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot write setup attributes to setup file');
        close (infile);
        Halt (101);
    End;
    writeln (infile, insmusicline);
    writeln (infile, '          ',
        linecount: 5);
    writeln (infile, '          ',
        dispspec: 3, dispgrid: 3, disphidlines: 3, dispcurs: 3,
        manset: 3, charset: 3, blankset: 3);
    writeln (infile, prformat: 3, prdest: 3);
    writeln (infile, prfname);
    writeln (infile, prfile: 3);
    writeln (infile, prdevice: 3);
    writeln (infile, sndlength: 5, sndlengthper: 3, sndplaybeat: 3,
        sndplaypulse: 3, dispsound: 3);
    writeln (infile, sndchar);
    writeln (infile, sndbeat: 6, sndbeatlength: 6);
    writeln (infile, sndpulse: 6, sndpulselength: 6);
    writeln (infile, fontfile);
    writeln (infile, sndlengthspm: 12);{New}
    writeln (infile, ctrlenterofs: 3);
    writeln (infile, sndwarning: 3);
    writeln (infile, dispslash: 3);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot write setup data to setup file');
        close (infile);
        Halt (101);
    End;
    close (infile);

End;

{************************************************************}
Procedure UseFileName(Var instring: string79; Var c: char;
    Var mausx, mausy, maustaste, mausmenu: word);

Var
    resp: response_type;
    dir: movement;
    KeyResp: Char;
    ok: boolean;
    oldstring: string79;
    demloc: boolean;
    changed: boolean;
Begin
    MausBereichAdd (8 * substartx, 8 * subendx,
        8 * substarty, 8 * (substarty + 4), 1);
{   MausBereichAdd((sdxmin-1)*8, sdxmax*8,
                  (sdymin-2)*16, (sdymax+sdymin+2)*16, 3);}
    MausBereichAdd (8 * substartx, 8 * subendx,
        8 * (substarty + 4) + 1, (sdymax + sdymin + 2) * 16, 3);
    IniSpacedText (substartx, substarty + 1,{Rahmen zeichnen}
        ' Active File [max 8 (.rns)]:                             ', frLow);
    If NOT IniFileExist (datadir + '\' + instring) Then
        instring := '';
    oldstring := instring;
    c := chr (0);
    maustaste := 0;
    IniSpacedText (substartx, (subendy - 1) * 2,
        ' [Enter] (last name) - new name, cursor+[Enter] or [Esc] '
        , frLow);
    SduSodir (True, ok, false, instring, '*.RNS *.BUF', datadir + '\', false,
        sdxmin * 8 - 4, sdymin * 16 - 8, sdymax, sdcol,
        mausx, mausy, maustaste, mausmenu, 0, 0, true);
    demloc := demoversion;
    Mauszeigen;
    Repeat
        maustaste := 0;
        instring  := oldstring;
        GrGet_Prompted_Spaced_String (instring, fieldlength, '>',
            substartx + 30 + fieldlength, substarty + 1,
            substartx + 29,
            '',
            substartx + 29, substarty + 1,
            subendx - substartx - 2 * fieldlength - 32,
            resp, dir, Keyresp, true,
            mausx, mausy, maustaste, mausmenu, changed);
        Instring := UpString (InString);
        ok := false;
        IniMausAssign (maustaste, resp);
        If ((maustaste > 0) AND (resp <> escape)) Then
            Case mausmenu Of
                1: resp := return;{Filetitel}
                2: resp := no_response;{???}
                3:
                Begin {Files}
                    resp := arrow;
                    dir  := down;
                End;
            End;
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

        Case resp Of

            escape: ok := true;

            return:
            Begin
                ok := true;
                If (instring = '') OR (instring = '   .   ') Then
                    If oldstring = '' Then
                        ok := false
                    Else
                        instring := oldstring;
                IniLeadBlank (instring);
                If pos ('.', instring) = 0 Then
                    instring := instring + '.RNS';
                If ok Then     { G�ltiger Filename? }
                    HlpTestFileName (datadir + '\' + instring, ok,
                        substartx, subendx, substarty + 6);
                If ok Then
                    If NOT IniFileExist (datadir + '\' + instring) Then
                        If demloc Then instring := 'TESTFILE.RNS'{                       ok:= false;
                       HlpDemoText(substartx, subendx, substarty + 6);} Else ok := HlpAreYouSure ('File ' + datadir + '\' + instring + ' does not exist', hpFileMenu){if not IniFileExist(datadir + '\' +instring) then}; {if ok then}
{                 if not ok then
                   SduSodir(True, ok, false, instring,'*.RNS', datadir+'\',false,
                    sdxmin*8-4,sdymin*16-8,sdymax,sdcol,
                    mausx,mausy,maustaste,3,0,0,true);}
            End;
            arrow: If dir = down Then
                    SduSodir (false, ok, true, instring, '*.RNS *.BUF', datadir + '\',
                        false, sdxmin * 8 - 4, sdymin * 16 - 8, sdymax, sdcol,
                        mausx, mausy, maustaste, 3, 0, 0, true);
            specialkey: If KeyResp = #81 Then SduSodir (false, ok, true, instring, '*.RNS *.BUF', datadir + '\',
                        false, sdxmin * 8 - 4, sdymin * 16 - 8, sdymax, sdcol,
                        mausx, mausy, maustaste, 3, 0, 0, true);
        End; {case resp of}
    Until ok;
    If resp = ESCAPE Then c := #27;
End;

{************************************************************}
Procedure UseDirName(Var mausx, mausy, maustaste, mausmenu: word);

Var
    resp: response_type;
    dir: movement;
    KeyResp: Char;
    ok, demloc: boolean;
    instring: string79;
    actdir: string79;
    b: byte;
    st: string;
    changed: boolean;
Begin
    IniSpacedText (substartx, substarty + 1,
        ' Active Directory [8(.+3)]:                              ', frLow);
    maustaste := 0;
    IniSpacedText (substartx, (subendy - 1) * 2,
        ' [Enter] (last name) - new name, cursor+[Enter] or [Esc] ',
        frLow);
    MausBereichAdd (8 * substartx, 8 * subendx,
        8 * substarty, 8 * (substarty + 1), 2);
    MausBereichAdd (8 * substartx, 8 * subendx,
        8 * (substarty + 4) + 1, (sdymax + sdymin + 2) * 16, 3);
{  MausBereichAdd((sdxmin-1)*8, sdxmax*8,
                 (sdymin-1)*16, (sdymax+sdymin-1)*16+8, 3);}
    SduSodir (True, ok, false, instring, '*.*', '', true,
        sdxmin * 8 - 4, sdymin * 16 - 8, sdymax, sdcol,
        mausx, mausy, maustaste, 3, 0, 0, True);
    demloc := demoversion;
    datadir := upstring (datadir);
    Repeat
        instring := datadir + '\';
        GrGet_Prompted_Spaced_String (instring, fieldlength, '>',
            substartx + 30 + fieldlength, substarty + 1,
            substartx + 28,
            ''{Active Directory [max 8]: '},
            substartx + 28, substarty + 1,
            subendx - substartx - 2 * fieldlength - 2 - 27{30},
            resp, dir, Keyresp, true,
            mausx, mausy, maustaste, mausmenu, changed);
        Instring := UpString (Instring);
        If pos ('\', instring) = length (instring) Then
            instring := copy (instring, 1, length (instring) - 1);
        ok := false;
        IniMausAssign (maustaste, resp);

        If demloc Then ok := true Else Case resp Of
                escape: ok := true;
                return:
                Begin
                    IniLeadBlank (instring);
                    If ((mausmenu = 2) OR (maustaste = 0)) Then
                    Begin
                        If instring = '' Then
                        Begin
                            instring := datadir;
                            ok := true;
                        End Else If instring = '..' Then
                        Begin
                            getdir (0, actdir);
                            If Length (actdir) <= 3 Then
                                instring := datadir + '..\';
                            ok := true;
                        End Else If instring = '.' Then
                        Begin
                            instring := datadir;
                            ok := true;
                        End Else If instring = '\' Then
                        Begin
                            instring := '\';
                            ok := true;
                        End Else If pos (':', instring) = 2 Then
                        Begin
                            instring := '';
                            ok := false;
                            HlpText (substartx, subendx, substarty + 6, 'Illegal name for data directory', true);
                            SduSodir (true, ok, false, instring, '*.*', '', true,
                                sdxmin * 8 - 4, sdymin * 16 - 8, sdymax,
                                sdcol, mausx, mausy, maustaste, 3, 0, 0, true);
                        End Else Begin
                            If (pos (':', instring) <> 0) OR
                                (pos ('\', instring) <> 0) OR
                                (pos (#9, instring) <> 0) OR
                                ((pos ('.', instring) = pos ('\', instring) + 1)) OR
                                ((pos ('.', instring) = pos ('\', instring) - 1)) OR
                                (pos ('..', instring) <> 0) OR
                                (pos ('*', instring) <> 0) OR
                                (pos ('?', instring) <> 0) Then
                                instring := datadir;
                            If (instring <> '') AND IniDirExist (instring) Then
                            Begin
                                datadir := instring;
                                ok := true;
                            End Else Begin
                   MkDir (instring);
                                If IOResult = 0 Then
                                Begin
                                    If HlpAreYouSure ('Directory "' + instring + '\" does not exist', hpFileMenu) Then
                                    Begin
                                        datadir := instring;
                                        ok := true;
                                    End Else Begin
                                        RmDir (instring);
                                        SduSodir (true, ok, false, instring, '*.*', '', true,
                                            sdxmin * 8 - 4, sdymin * 16 - 8, sdymax, sdcol,
                                            mausx, mausy, maustaste, 3, 0, 0, true);
                                    End;
                                End Else Begin
                                    {                      SduClearWin(sdxmin, sdymin, sdxmax, sdymax);}
                                    HlpText (substartx, subendx, substarty + 6,
                                        'Illegal name for data directory', true);
                                    SduSodir (true, ok, false, instring, '*.*', '', true,
                                        sdxmin * 8 - 4, sdymin * 16 - 8, sdymax, sdcol,
                                        mausx, mausy, maustaste, 3, 0, 0, True);
                                End;
                            End;{if inidirexist else}
                        End{if pos(':'...=2 else};{if instring = '\' else}
                    End {if mausmenu = 2}Else If mausmenu = 3 Then
                    Begin
                        SduSodir (false, ok, true, instring, '*.*', '', true,
                            sdxmin * 8 - 4, sdymin * 16 - 8, sdymax, sdcol,
                            mausx, mausy, maustaste, 3, 0, 0, True);
                        If ok Then datadir := instring;
                    End Else Begin
                        ok := true;
                        resp := escape;
                    End;
                End;{case of return}
                arrow: If dir = down Then
                    Begin
                        SduSodir (false, ok, true, instring, '*.*', '', true,
                            sdxmin * 8 - 4, sdymin * 16 - 8, sdymax, sdcol,
                            mausx, mausy, maustaste, 3, 0, 0, True);
                        If ok Then datadir := instring;
                    End;{case of arrow}
            End{case resp of}; {else if demoversion}

    Until ok;
    If resp = ESCAPE Then
    Begin
        mausx := 0;
        mausy := 0;
        maustaste := 0;
        mausmenu := 0;
    End
    Else
    Begin    {new}
        If (mausx = 0) AND (mausy = 0) AND (maustaste = 0) AND (mausmenu = 0) Then
            mausx := 1;
        b := pos ('.', datadir);
        If (b = length (datadir)) AND (b <> 0) Then
            datadir := copy (datadir, 1, b - 1) + copy (datadir, b + 1, length (datadir) - b - 1);
        instring := datadir;
        st := ' Loading Directory ' + datadir + '\                                             ';
        st[0] := #57;
        IniSpacedText (substartx, topendy * 2, st, frHigh);
        UseGetConfig;
        datadir := instring;
    End;
End;

{************************************************************}
Procedure UseFontSelect(Var mausx, mausy, maustaste, mausmenu: word);

Const hy = 25;

Var
    ok: boolean;
    instring: string79;

Begin
    maustaste := 0;

    Instring := ' Active Font: ' + fontfile;
    IniExpand (instring, 57);
    IniSpacedText (substartx, substarty * 2, instring, frLow);

    IniSpacedText (substartx, (subendy - 1) * 2,
        ' Use cursor+[Enter] or [Esc]                             ',
        frLow);
    MausBereichAdd (8 * substartx, 8 * subendx,
        8 * substarty, 8 * (substarty + 1), 2);
    MausBereichAdd (8 * substartx, 8 * subendx,
        8 * (substarty + 4) + 1, (sdymax + sdymin + 2) * 16, 3);
{   MausBereichAdd((sdxmin-1)*8, sdxmax*8,
                  (sdymin-1)*16, (sdymax+sdymin-1)*16+8, 3);}
    maustaste := 0;
    ok := false;
    SduSodir (True, ok, false, instring, '*.FNT', '', false,
        sdxmin * 8 - 4, sdymin * 16 - 8, sdymax, sdcol,
        mausx, mausy, maustaste, 3, 0, 0, True);
    SduSodir (False, ok, true, instring, '*.FNT', '', false,
        sdxmin * 8 - 4, sdymin * 16 - 8, sdymax, sdcol,
        mausx, mausy, maustaste, 3, 0, 0, False);
    If ok Then
    Begin
        fontfile := instring;
        IniIniSymbols;
        Window (substartx + 1, substarty + 3, subendx - 1, subendy - 3);
        Window (1, 1, 80, 25);
        If ok Then UseSaveSetup{PEO}{PEO};
    End;
End;

{************************************************************}
Procedure UseColorSelect(Var mausx, mausy, maustaste, mausmenu: word);

Const hy = 25;

Var
    ok: boolean;
    instring: string79;
Begin
    maustaste := 0;

    Instring := ' Active Color Setting: ' + colorfile;
    IniExpand (instring, 57);
    IniSpacedText (substartx, substarty * 2, instring, frLow);

    IniOutTextXY (subendx - 8, substarty + 1, '        ');
    IniSpacedText (substartx, (subendy - 1) * 2,
        ' Use cursor+[Enter] or [Esc]                             ', frLow);
    MausBereichAdd (8 * substartx, 8 * subendx,
        8 * substarty, 8 * (substarty + 1), 2);
    MausBereichAdd (8 * substartx, 8 * subendx,
        8 * (substarty + 4) + 1, (sdymax + sdymin + 2) * 16, 3);
{   MausBereichAdd((sdxmin-1)*8, sdxmax*8,
                  (sdymin-1)*16, (sdymax+sdymin-1)*16+8, 3);}
    OK := False;
    SduSodir (True, ok, false, instring, '*.COL', '', false,
        sdxmin * 8 - 4, 72, sdymax, 3,
        mausx, mausy, maustaste, 3, 0, 0, True);
    SduSodir (False, ok, true, instring, '*.COL', '', false,
        sdxmin * 8 - 4, 72, sdymax, 3,
        mausx, mausy, maustaste, 3, 0, 0, False);
    If ok Then
    Begin
        colorfile := instring;
        FilCopyFile (instring, 'colors.rns');
    End;
End;

Procedure DrawTopMenuLines(C: Char);
Begin
    SetBkColor (7); {Hintergrund grau}
    SetColor (5);

    Line ((topstartx - 1) * CharWidth - 8, (topstarty - 1),
        (topstartx - 1) * Charwidth - 8, (topstarty + 478)); {Linke Kante, hell 1}
    Line ((topstartx - 1) * CharWidth - 7, (topstarty - 1),
        subendx * Charwidth - 1, (topstarty - 1)); {Obere Kante, hell 1}
    Line ((topstartx - 1) * CharWidth - 7, (topstarty + 40),
        subendx * Charwidth - 1, (topstarty + 40)); {Titelabschluss, hell}
    Line ((topstartx - 1) * CharWidth - 7, (topstarty + 457),
        subendx * Charwidth - 1, (topstarty + 457)); {unterer Abschluss hell}
    Line ((topstartx + 20) * CharWidth - 5, (topstarty - 1),
        (topstartx + 20) * Charwidth - 5, (topstarty + 480)); {Trennungslinie hell 1}
    SetColor (12);
    Line ((topstartx - 1) * CharWidth - 8, (topstarty + 38),
        subendx * Charwidth - 1, (topstarty + 38)); {Titelabschluss, dunkel}
    Line ((topstartx - 1) * CharWidth - 8, (topstarty + 39),
        subendx * Charwidth - 1, (topstarty + 39)); {Titelabschluss, dunkel}
    Line ((topstartx - 1) * CharWidth - 8, (topstarty + 455),
        subendx * Charwidth - 1, (topstarty + 455)); {unterer Abschluss dunkel}
    Line ((topstartx - 1) * CharWidth - 8, (topstarty + 456),
        subendx * Charwidth - 1, (topstarty + 456)); {unterer Abschluss dunkel}
    SetColor (12);
    Line ((topstartx + 20) * CharWidth - 6, (topstarty - 1),
        (topstartx + 20) * Charwidth - 6, (topstarty + 478)); {Trennungslinie dunkel 1}
    Line ((topstartx + 20) * CharWidth - 7, (topstarty - 1),
        (topstartx + 20) * Charwidth - 7, (topstarty + 478)); {Trennungslinie dunkel 2}
    {Rahmen f�r Text}
    If C <> 'F' Then
    Begin
        SetColor (12);
        Line ((substartX + 0) * Charwidth - 1, (substarty + 2) * 2 * Charheight + 6,
            (subendx - 1) * charwidth - 4, (substarty + 2) * 2 * Charheight + 6);
        Line ((substartX + 0) * Charwidth - 1, (substarty + 18) * 2 * Charheight - 8,
            (subendX - 1) * charwidth - 4, (substarty + 18) * 2 * Charheight - 8);
        Line ((substartX + 0) * Charwidth - 1, (substarty + 2) * 2 * Charheight + 6,
            (substartx + 0) * charwidth - 1, (substartY + 6) * 2 * Charheight + 2);
        SetColor (5);
        Line ((substartX + 0) * Charwidth, (substartY + 6) * 2 * Charheight + 2,
            (subendX - 1) * charwidth - 4, (substarty + 6) * 2 * Charheight + 2);
        Line ((subendX - 1) * Charwidth - 4, (substarty + 2) * 2 * Charheight + 7,
            (subendX - 1) * charwidth - 4, (substarty + 6) * 2 * Charheight + 2);
        SetColor (12);
        Line ((substartX + 0) * Charwidth - 1, (substarty + 18) * 2 * Charheight - 7,
            (substartX + 0) * charwidth - 1, (subendy - 2) * 2 * Charheight - 4);
        SetColor (5);
        Line ((substartX + 0) * Charwidth, (subendy - 2) * 2 * Charheight - 4,
            (subendX - 1) * charwidth - 4, (subendy - 2) * 2 * Charheight - 4);
        Line ((subendX - 1) * Charwidth - 4, (substarty + 18) * 2 * Charheight - 7,
            (subendX - 1) * charwidth - 4, (subendy - 2) * 2 * Charheight - 4);
        SetFillStyle (11, 13); {11=gepunktet, 13=lila}
        Bar (184, 55, 627, 113);
        Bar (184, 297, 627, 443);
        {???????????????????????????????????????????????????????}
        {    SetFillStyle(solidfill, bkcolor);} {in jedem Fall absurde Cursorfarben-Wechsel
     je nach zuerst gew. Colors}
    End;
End;
{******************************************************}
Procedure UseGetPickFil(Var Instring: Stringline);
Var infile: text;
Begin
    FilAssignRnsFile (infile, 'pickfil', true);
    {Check if file was opened successfully}
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot open pickfil file');
        WriteLn ('Make sure the pickfil file exists in the data directory.');
        Halt (2);
    End;
    readln (infile, instring);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot read from pickfil file');
        close (infile);
        Halt (100);
    End;
    close (infile);
End;
{******************************************************}
Procedure UseSetPickFil(Instring: Stringline);
Var infile: text;
Begin
    FilAssignRnsFile (infile, 'pickfil', false);
    {Check if file was opened successfully}
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot create pickfil file');
        WriteLn ('Check write permissions in data directory.');
        Halt (5);
    End;
    writeln (infile, instring);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot write to pickfil file');
        close (infile);
        Halt (101);
    End;
    close (infile);
End;
{******************************************************}
Procedure UseTopMenu;

Var
    resp: response_type;
    dir: movement;
    KeyResp: Char;
    i: integer;
    b: byte;
    c: char;
    instring, inbuf: string79;
    choicenum: byte;
    infile, bakfile: text;
    st: string;
    bakname: String79;
    mausx, mausy, maustaste, mausmenu: word;
    mx, my, mt, mm: Word;
    changed: boolean;
Begin
    UseGetConfig;
    UseGetSetup;
    IniIniColors;
    IniIniSymbols;
    UseSaveSetup;
    IniGraphInit;
    MausInstall;
    IniSwapMenuColors;
    c := ' ';
    mausmenu := 0;
    choicenum := 1;
    demoversion := NOT (IniFileExist ('imie.rns') AND TitVerify);
    ImeInitTopmenu;
    Repeat
        SetFillStyle (SolidFill, MenuBkColor);
        SetColor (MenuFrameColor);
        UseGetPickFil (instring);
        Mausdunkel;
        If c <> ' ' Then
        Begin{ nur beim ersten mal nicht l�schen }
            bar (172, 1, 639, 479);{l�scht nur rechten Teil, nicht Hauptmenu}
            {      bar( 10,61,159,110);}{l�scht nur 1.Button des Hauptmenus: wegen Dir\}
            { ClearDevice;}{alternativ zur den bars}
            ImeInitTopmenu; {damit richtiger Pfad 1.button Hauptmenu gezeigt wird}
        End Else IniPalBlank (0, 0, 0);
        DrawTopMenuLines (c);
        SetColor (12);
        GrDisplay_Menu (topstartx, topstarty, usrmenu, 1);
        If c <> 'F' Then
        Begin
            logo^.display (192, 150); {192,175}
            SetColor (12);
            If demoversion Then
            Begin
                inbuf := '                          ';
                IniExpand (inbuf, subendx - substartx - 2);
                IniOutTextXY (substartx, (substarty + 3) * 2, inbuf);
                inbuf := '                         D E M O - V E R S I O N ';
                IniExpand (inbuf, subendx - substartx - 2);
                IniOutTextXY (substartx, (substarty + 4) * 2, inbuf);
                assign (infile, 'copyd.rns');
                If NOT IniDirExist ('demodir') Then
                    mkdir ('demodir');
                datadir := 'demodir';
                chdir (datadir);
                If NOT IniFileExist ('testfile.rns') Then
                    FilCopyFile ('..\testfile.rns', 'testfile.rns');
                ChDir ('..');
            End Else Begin
                inbuf := '                          ';
                IniExpand (inbuf, subendx - substartx - 2);
                IniOutTextXY (substartx, (substarty + 3) * 2, inbuf);
                inbuf := '  L I C E N S E D  V E R S I O N  ' + usrfirstname + ' ' + usrname;
                IniCenter (inbuf, 74);
                IniOutTextXY (substartx, (substarty + 4) * 2, inbuf);
                assign (infile, 'copyr.rns');
            End;
            reset (infile);
            If IOResult <> 0 Then
            Begin
                WriteLn ('Error: Cannot open copyright file: ', String (TextRec (infile).Name));
                WriteLn ('Make sure the copyright file exists.');
                Halt (2);
            End;
            i := 6;
            While NOT eof (infile) Do
            Begin
                readln (infile, inbuf);
                If IOResult <> 0 Then
                Begin
                    WriteLn ('Error: Cannot read from copyright file');
                    close (infile);
                    Halt (100);
                End;
                IniExpand (inbuf, subendx - substartx - 2);
                IniOutTextXY (substartx, (substarty + i + 2) * 2, ' ' + inbuf);
                i := i + 1;
            End;
            close (infile);
            SetColor (12);
            MausGrafik (1);
            MausBereich (1, (substartX - 3) * Charwidth - 3, 42, GrmaxY + 14);
            MausSetXY (102, 90);
            If mausmenu <> 1 Then
            Begin
                maustaste := 0;
                mausmenu  := 0;
            End;
            {    IniFadeIn;}
            IniSetAllDACRegs (ThePalette);
            {    if c <> 'F' then begin}
            Repeat
                If maustaste = 7 Then
                    maustaste := 0;
                GrGet_Menu_Response (topstartx, topstarty, usrmenu, c,
                    dir, choicenum,
                    mausx, mausy, maustaste, mausmenu, false, 1);
                c := UpCase (c);
                If c = #27 Then {          IniSetDACReg(1,$3F,$3F,$3F);
          Delay(300);
          IniSetAllDACRegs(ThePalette);
          choicenum:=usrmenu.num_choices;};
            Until (c = 'F') OR (c = 'D') OR (c = 'S') OR (c = 'P') OR (c = 'C') OR (c = 'Q');
        End;
        While KeyPressed Do ReadKey;
        Mausbereich (172, 628, 1, 438);
        Case c Of
            'F':
            Begin
                choicenum := 1;
                mausdunkel;
                MausSetXY (509, 23);
                SetFillStyle (Solidfill, 7);
                Bar ((substartx - 1) * charwidth, (substarty + 2) * 2 * Charwidth,
                    (subendx) * charwidth, (subendy - 2) * 2 * charwidth);
                UseFileName (instring, c, mausx, mausy,
                    maustaste, mausmenu);
                Instring := UpString (Instring);
                If c <> #27 Then
                Begin
                    UseSetPickFil (instring);
                    UseGetSetup;
                    If IniFileExist (datadir + '\' + instring) Then
                    Begin
                        If Pos ('.', instring) = 0 Then
                        Begin
                            FilCopyFile (datadir + '\' + instring, datadir + '\' + instring + '.BAK');
                            Assign (Bakfile, datadir + '\' + instring + '.BAK');
                        End Else Begin
                            FilCopyFile (datadir + '\' + instring, datadir + '\' +
                                Copy (instring, 1, Pos ('.', instring)) + 'BAK');
                            Assign (Bakfile, datadir + '\' + Copy (instring, 1,
                                Pos ('.', instring)) + 'BAK');
                        End;
                        BakName := datadir + '\' + Copy (instring, 1, Pos ('.', instring)) + 'BAK'; { Modern file name access }
                    End Else
                        BakName := '';
                    IniSwapMenuColors;
                    EdiRythmEdit (datadir + '\' + instring, bakname,
                        false, demoversion);
                    Mauszeigen;
                    IniSwapMenuColors;
                    st := copy (fontfile, 1, byte (fontfile[0]) - 3) + 'PAR';
                    IniHideCursor;
                    If NOT FilCompareFiles (st, 'SYMBOLS.PAR') Then
                    Begin
                        HlpHintFrame (grminx, grmaxy - 48, Grmaxx, grmaxy);
                        txtfnt.write (grminx + 24, grmaxy - 48 + 2 * charheight,
                            'Fontfile ' + St +
                            ' has been changed!', getcolor, sz8x16, stnormal);
                        txtfnt.write (grminx + 24, grmaxy - 48 + 4 * charheight,
                            'Press [Y] to save, [Esc] to cancel', getcolor, sz8x16, stnormal);
                        Repeat
                            c := IniMausEscape;
                        Until (c = #27) OR (c = #13) OR (c = 'Y');
                    End Else
                        c := #27;
                    Case C Of
                        #27: ;
                        #13, 'Y': If IniFileExist (St) Then
                            Begin
                                HlpHintFrame (grminx, grmaxy - 48, Grmaxx, grmaxy);
                                txtfnt.write (grminx + 20, grmaxy - 42 + 2 * charheight,
                                    {'File '+}st + ' already exists, enter new name:', getcolor, sz8x16, stnormal);
                 {suche ein Zahl im string und schreibe eine as Ende
                  des Strings}
                                While IniFileexist (st) Do
                                Begin
                                    c := St[0];
                                    If (St[Byte (c) - 4] < '0') OR (St[Byte (c) - 4] > '9') Then
                                    Begin
                                        b := Pos ('-', St);
                                        If b <> 0 Then
                                            St := Copy (St, 1, b - 1) + Copy (St, b + 1, Byte (st[0]) - b);
                                        b := Pos ('.', St);
                                        If St[0] > #12 Then
                                            St[8] := '2'
                                        Else
                                            St := Copy (St, 1, b - 1) + '2' + Copy (St, b, Byte (St[0]) - b + 1);
                                    End{IF St[...<'1'} Else If (St[Byte (c) - 4] <> '9') Then Inc (St[Byte (c) - 4]){IF St[...<>'9'} Else If (St[Byte (c) - 5] < '0') OR (St[Byte (c) - 5] > '9') Then
                                    Begin
                                        st[Byte (c) - 5] := '1';
                                        st[Byte (c) - 4] := '0';
                                    End{IF St[...<'1'} Else If St[Byte (c) - 5] <> '9' Then
                                    Begin
                                        Inc (Byte (St[Byte (c) - 5]));
                                        St[Byte (c) - 4] := '0';
                                    End Else
                                        st := ''{IF St[...<'1' else}{IF ST[... <>'9' else};{IF ST[... <'1' else}
                                End;{While}
                                Repeat
                                    IniInversWrite (456, 402, '              ', frLow);
                                    {String}         GrGetUpcase_String (st,
                                        {X,Y}            456, 402,
                                        {Length}         12,
                                        {Resp,dir}       Resp, Dir,
                                        {keyresp}        Keyresp,
                                        {oldwrite}       True,
                                        {mausx,-y}       mx, my,
                                        {msetaste,-menu} mt, mm,
                                        changed);
                                    If Resp <> Escape Then
                                        If Pos ('.PAR', St) = 0 Then
                                            If Pos ('.', St) <> 0 Then
                                            Begin
                                                Resp := Key;
                                                If Pos ('.', St) > 9 Then
                                                Begin
                                                    St := Copy (St, 1, 8);
                                                    St := St + '.PAR';
                                                End{Pos('.',St)>9} Else
                                                    St := Copy (St, 1, Pos ('.', st)) + 'PAR';
                                            End{IF Pos('.',St)<>0}Else Begin
                                                Resp := Key;
                                                If St[0] > #8 Then
                                                    st := Copy (St, 1, 8) + '.PAR'
                                                Else
                                                    St := St + '.PAR';
                                            End{IF Pos('.',St)<>0 Else}{Pos('.PAR',St)<>0};{IF Resp<>Escape}
                                Until ((Resp = Return) AND ((NOT IniFileExist (St)) OR IniUserFontFile (st))) OR (Resp = ESCAPE);
                                If Resp = Return Then
                                Begin
                                    FilCopyFile ('SYMBOLS.PAR', ST);
                                    St := Copy (St, 1, Pos ('.', St) - 1);
                                    FilCopyFile ('SYMBOLS.SYM', ST + '.SYM');
                                    FilCopyFile ('SYMBOLS.PRN', ST + '.FNT');
                                End;
                            End;
                    End;
                    If BakName <> '' Then
                        Erase (BakFile);
                    {.........................................................................}
                    {Zur�cksetzungen vor Save beim verlassen des Files}
                    {          soundchange:=(soundchange xor saMuffled) and not saMuffled;}
                    {muffled M soll w�hrend ganzer Session f�r alle Files gelten!}
                    soundchange := (soundchange XOR saRhythm) AND NOT saRhythm;
                    {nur rhythmische Stuktur R wird beim Filesave gel�scht}
                    PageCount := 1;
                    {.........................................................................}
                    UseSaveSetup;
                    c := 'F';
                    mausdunkel;
                    ClearDevice;
                    ImeInitTopmenu;
                End;
                choicenum := 2;
            End;

            'P':
            Begin
                actedit := actedit + [setuppage, defsetuppage];
                IniSwapColors;
                IniSwapMenuColors;
                EdiRythmEdit ('pageset', '', true, false);
                IniSwapMenuColors;
                IniSwapColors;
                actedit := actedit - [setuppage, defsetuppage];
                SetFillStyle (Solidfill, 7);{!!!}
                c := #1;
                choicenum := 1;
                ClearDevice;
                ImeInitTopmenu;
            End;

            'D':
            Begin
                Mausdunkel;
                MausSetXY (509, 23);
                SetFillStyle (Solidfill, 7);{!!!}
                Bar ((substartx - 1) * charwidth, (substarty + 2) * 2 * Charwidth,
                    (subendx) * charwidth, (subendy - 2) * 2 * charwidth);
                UseSaveSetup;
                UseDirName (mausx, mausy, maustaste, mausmenu);
                If (mausx <> 0) OR (mausy <> 0) OR (maustaste <> 0) OR (mausmenu <> 0) Then
                Begin
                    IniSwapMenuColors;
                    UseSaveConfig;
                    UseGetSetup;
                    IniIniSymbols;
                    IniIniColors;
                    c := 'F';
                    IniSwapMenuColors;
                End Else Begin
                    choicenum := 1;
                    c := #1;
                End;
            End;

            'S':
            Begin  {new}
                Mausdunkel;
                MausSetXY (300, 90);
                SetFillStyle (Solidfill, 7);{!!!}
                Bar ((substartx - 1) * charwidth, (substarty + 2) * 2 * Charwidth,
                    (subendx) * charwidth, (subendy - 2) * 2 * charwidth);
                UseFontSelect (mausx, mausy, maustaste, mausmenu);
                c := #1;
                choicenum := 1;
            End;

            'C':
            Begin
                Mausdunkel;
                MausSetXY (300, 90);
                IniSwapMenuColors;
                IniIniColors;
                SetFillStyle (Solidfill, 7);{!!!}
                Bar ((substartx - 1) * charwidth, (substarty + 2) * 2 * Charwidth,
                    (subendx) * charwidth, (subendy - 2) * 2 * charwidth);
                IniSwapMenuColors;
                UseColorSelect (mausx, mausy, maustaste, mausmenu);
                IniSwapMenuColors;
                UseSaveConfig;
                IniIniColors;
                IniSwapMenuColors;
                GcuIniCursor;
                c := #1;
                choicenum := 1;
            End;
        End;
        MausZeigen;
    Until c = 'Q';
End;

Begin
    demoversion := true;
End.
