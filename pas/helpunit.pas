{$I RNS.H}

Unit helpunit;

Interface

Uses
    Graph,
    GcurUnit,
    Graphmenu,
    inout,
    menutyp,
    Crt,
    xcrt,
    imenuunit,
    InitSc,
    SysUtils;

Procedure HlpCommandTable;
Procedure HlpSymbolTable;
Procedure HlpHint(HintTextFmt: String; WaitTime: Integer; Const Args: Array Of Const);
Function HlpAreYouSure(hinttext: string; position: byte): boolean;
Function HlpAskYesEsc(hinttext, choicetext: string; position: byte): boolean;
Function HlpAsk(hinttext, choicetext: string; position: byte;
    Resp: TCharSet): char;
Function HlpAskAny(Hinttext, choicetext: string; position: byte): Char;

Function HlpGetFileName(Var instring: string; extn: string; x, y: word): Boolean;
Procedure HlpTestFileName(instring: stringline; Var ok: boolean;
    x, xmax, y: integer);
Procedure HlpText(x, xmax, y: integer; hinttext: string; escwait: boolean);
Procedure HlpBottomLine(hinttext: string);
Procedure HlpHintFrame(hintminx, hintminy, hintmaxx, hintmaxy: integer);
Function HlpTxtAreYouSure(x, xmax, y: integer;
    hinttext: string): boolean;
Procedure HlpSymbolSelect(Var c: char);

Implementation

Uses
    pageunit,
    sdunit,
    symbols,
    Dmemunit,
    mousdrv,
    grinout,
    Texts;

{******************************************************}
Procedure HlpBottomLine(hinttext: string);

Var
    x, y: integer;

Begin
    PagClearBottomLine;
    y := gmaxy DIV charheight - 2;
    x := TextMargin DIV charwidth + 1;
    IniInversText (x + 1, y - 1, hinttext, frHigh);
End;

{******************************************************}
Procedure HlpHintFrame(hintminx, hintminy, hintmaxx, hintmaxy: integer);

Begin
    SetColor (alarmcolor);
    SetFillstyle (1, alarmbkcolor);
    Bar (hintminx, hintminy, hintmaxx, hintmaxy);
    SetColor (framecolor);
    Line (hintminx, hintminy + 2, hintmaxx, hintminy + 2);
    Line (hintminx, hintminy + 1, hintminx, hintmaxy);
    SetColor (12);
    Line (hintminx, hintmaxy, hintmaxx, hintmaxy);     {unterer Abstand zu Status}
    Line (hintminx, hintmaxy + 1, hintmaxx, hintmaxy + 1);     {unterer Abstand zu Status}
    Line (hintminx, hintminy, hintmaxx, hintminy);   {oberer Abstand zur Seite}
    Line (hintminx, hintminy + 1, hintmaxx, hintminy + 1); {oberer Abstand zur Seite}

(*   SetColor(3);
   Line(hintminx+1, hintminy-1, hintmaxx, hintminy-1);  {Schatten oben}
   Line(hintminx+1, hintminy+47, hintmaxx, hintminy+47);{Schatten unten}
   Line(hintmaxx  , hintminy+3, hintmaxx, hintminy+47); {Schatten rechts}
*)
    SetColor (AlarmColor);
End;

{******************************************************}
Procedure HlpTestFileName(instring: stringline; Var ok: boolean;
    x, xmax, y: integer);
{testet instring auf einen gÅltigen textstring}

    Procedure ImpossibleFilename;
    Var
        P: Pointer;
    Begin
        ok := false;
        Mauszeigen;
        GetMem (P, ImageSize (grminx, grmaxy - 22, grmaxx, grmaxy + 32));
        GetImage (grminx, grmaxy - 22, grmaxx, grmaxy + 32, P^);
        HlpHintFrame (grminx, grmaxy - 22, grmaxx, grmaxy + 32);
        txtfnt.write (grminx + 16, grmaxy - 6,
            'Filename contains illegal characters',
            getcolor, sz8x16, stnormal);
        txtfnt.write (grminx + 16, grmaxy + 14,
            'Press [Esc] to continue ',
            getcolor, sz8x16, stnormal);
        Repeat
        Until IniMausEscape = #27;
        Mausdunkel;
        PutImage (grminx, grmaxy - 22, P^, CopyPut);
    End;

Var
    tfile: text;
    i: Integer;
Begin
    ok := true;
    If NOT IniFileExist (instring) Then
    Begin
        assign (tfile, instring);
        rewrite (tfile);
        I := IOResult;
        If I <> 0 Then
        Begin
            ImpossibleFileName;
            exit;
        End;
        close (tfile);
        I := IOResult;
        If I <> 0 Then
        Begin
            ImpossibleFileName;
            exit;
        End;
        erase (tfile);
        I := IOResult;
        If I <> 0 Then
        Begin
            ImpossibleFileName;
            exit;
        End;
    End;
    Exit;
End;

{******************************************************}
Function HlpGetFileName(Var instring: string; extn: string; x, y: word): Boolean;

Var
    resp: Response_Type;
    dir: movement;
    c: char;
    ok: boolean;
    mausx, mausy, maustaste, mausmenu: word;
    changed: Boolean;
Begin
    instring := '';
    Repeat
        resp := No_Response;
        If (x OR y) = 0 Then
        Begin
            HlpHintFrame (grminx, grmaxy - 38, grmaxx, grmaxy);
            x := grminx DIV charwidth + 22;
            y := (grmaxy - 16) DIV charheight;
        End;
        IniSpacedText (X - 20, Y - 1, '                                                 ', frLow);
        GrGet_Prompted_Spaced_String (instring, fieldlength, '>',
            x, y - 1, x, 'Filename(' + extn + ')',
            x - 19, y - 1, 18, resp, dir, c, false,
            mausx, mausy, maustaste, mausmenu, changed);
        IniMausAssign (maustaste, resp);
        Case resp Of

            escape: ok := true;

            return:
            Begin
                IniLeadBlank (instring);
                If pos ('.', instring) = 0 Then
                    instring := instring + extn;
                HlpTestFileName (instring, ok, 10, 10, 40);
            End;

        End; {case resp of}
    Until ok;
    If resp = escape Then
        HlpGetFileName := false
    Else
        HlpGetFileName := true;
End;

{******************************************************}
Procedure HlpText(x, xmax, y: integer; hinttext: string; escwait: boolean);

Var
    c: char;
    outstring: string;
    temp1, temp2: boolean;

Begin
    outstring := ' Press [Esc] to continue ';
    hinttext  := ' ' + hinttext;
    IniExpand (outstring, xmax - x);
    IniExpand (hinttext, xmax - x);

    IniInversText (x, y, hinttext, frHigh);
    If escwait Then
    Begin
        IniInversText (x, y + 1, outstring, frHigh);
        Repeat
            c := xReadKey (temp1, temp2);
        Until c = chr (27);
        IniClearLine (x, y + 2, length (outstring), bkcolor);
    End
    Else
        Delay (800);
    IniClearLine (x, y, length (outstring), bkcolor);
End;

{******************************************************}
Procedure HlpHint(HintTextFmt: String; WaitTime: Integer; Const Args: Array Of Const);

Var
    ymaxframe: integer;
    SPic: Pointer;
    SC: Byte;
    HintText: String;
Begin
    HintText := Format (HintTextFmt, Args);

    If NOT grInitialized Then
    Begin
        WriteLn (HintText);
        Exit;
    End;
    SC := GetColor;
    If WaitTime = 0 Then
        ymaxframe := 48
    Else
        ymaxframe := 32;
    If WaitTime >= 0 Then
    Begin
        GetMem (SPic, ImageSize (grminx, grmaxy - ymaxframe - 1, grMaxX, grmaxy + 1));
        If SPic <> nil Then
            GetImage (GrMinX, grmaxy - ymaxframe - 1, GrMaxX, grmaxy + 1, SPic^);
    End;
    HlpHintFrame (grminx, grmaxy - ymaxframe, Grmaxx, grmaxy);
    txtfnt.write (grminx + 16, grmaxy - ymaxframe + 2 * charheight, hinttext, getcolor, sz8x16, stnormal);
    If WaitTime = 0 Then
    Begin
        txtfnt.write (grminx + 16, grmaxy - ymaxframe + 4 * charheight,
            'Press [Esc] to continue', getcolor, sz8x16, stnormal);
        Repeat
        Until IniMausEscape = #27;
    End Else
        Delay (WaitTime);
    PutImage (GrMinX, grmaxy - ymaxframe - 1, SPic^, NormalPut);  {???}
    FreeMem (Spic, ImageSize (grminx, grmaxy - ymaxframe - 1, grmaxx, grmaxy + 1)); {???}
    SetColor (SC);
End;

{******************************************************}
Function HlpAreYouSure(hinttext: string; position: byte): boolean;

Begin
    {### Unterscheiden, damit Dir/File does not exist tiefer stehen kann}
    {  !!!!!!!   'Press [Enter] or Y to continue, [PgUp] or [Esc] to cancel');}
{             Solange 'replace ?' (replace pattern mit dem gleichen Hint
              versehen wird, ist der folgende String leider richtiger:}
    Case HlpAsk (hinttext, 'Press [Y] to continue, [Esc] to cancel', position,
            ['Y', #13, #27, #73]) Of
        'Y': HlpAreYouSure := True;
        #13: HlpAreYouSure := True;
        #27: HlpAreYouSure := False;
        #73: HlpAreYouSure := False;
    End;{Case HlpAsk of }
End;

{******************************************************}

Function HlpAskYesEsc(hinttext, choicetext: string; position: byte): boolean;
Begin
    Case HlpAsk (hinttext, choicetext, position, ['Y', #13, #27, #73]) Of
        'Y': HlpAskYesEsc := True;
        #13: HlpAskYesEsc := True;
        #27: HlpAskYesEsc := False;
        #73: HlpAskYesEsc := False;
    End;{Case HlpAsk of }
End;


Function HlpAsk(hinttext, choicetext: string; position: byte;
    Resp: TCharSet): char;
Var
    c: char;
    ymax: integer;
    SPic: Pointer;
    m: Boolean;
    mem: integer;
Begin
    XClearKbd;
    m := NOT istdunkel;
    If m Then
        Mausdunkel;
    Case position Of
        hpEdit: ymax := grmaxy;
        hpUp: ymax := grminy + 7;
        hpFileMenu: ymax := 456;
    Else ymax := grmaxy;
    End;{case}
    mem := ImageSize (grminx, ymax - 49, grmaxx, ymax + 1);
    GetMem (SPic, mem);
    GetImage (grminx, ymax - 49, grmaxx, ymax + 1, SPic^);
    HlpHintFrame (grminx, ymax - 48, grmaxx, ymax);
    txtfnt.write (grminx + 16, ymax - 34, hinttext, getcolor, sz8x16, stnormal);
    txtfnt.write (grminx + 16, ymax - 16, choicetext, getcolor, sz8x16, stnormal);
    mauszeigen;
    Repeat
        c := IniMausEscape;
    Until c IN Resp;
    HlpAsk := c;
    Mausdunkel;
    PutImage (grminx, ymax - 49, SPic^, Normalput);
    FreeMem (SPic, mem);
    If M Then
        Mauszeigen;
End;

{******************************************************}

Function HlpAskAny(Hinttext, choicetext: string; position: byte): Char;
Var
    Resp: TCharSet;
Begin
    Resp := [#0..#$FF] - [' '];
    HlpAskAny := HlpAsk (hinttext, choicetext, position, resp);
End;

{******************************************************}

Function HlpTxtAreYouSure(x, xmax, y: integer;
    hinttext: string): boolean;

Var
    c: char;
    outstring: string;
    temp1, temp2: boolean;

Begin
    outstring := '                   Press [Y] to continue - [Esc] to cancel';
    hinttext  := ' ' + hinttext;
    IniExpand (outstring, xmax - x);
    IniExpand (hinttext, xmax - x);

    IniInversText (x, y, hinttext, frHigh);
    IniInversText (x, y + 1, outstring, frHigh);
    Repeat
        c := xReadKey (temp1, temp2);
    Until ((c = chr (27)) OR (c = 'y') OR (c = 'Y'));
    IniClearLine (x, y, length (outstring), bkcolor);
    IniClearLine (x, y + 1, length (outstring), bkcolor);

    If c = chr (27) Then
        HlpTxtAreYouSure := false
    Else
        HlpTxtAreYouSure := true;
End;

{******************************************************}
Procedure HlpSymbolTable;

Var
    y, i, blnum: integer;
    acolor: byte;
    sgrmaxy: Integer;
Begin
    ImeInitSymbolMenus;
    ClearViewPort;

    SetBkColor (7{menubkcolor});

    SetColor (5);
    Line (stabxmin - 4, stabymin - 7, stabxmax + 4, stabymin - 7);
    Line (stabxmin - 4, stabymin + 19, stabxmax + 4, stabymin + 19);
    Line (stabxmin - 4, stabymin - 6, stabxmin - 4, stabymax + 3);
    Line (stabxmax DIV 2 + 1, stabymin - 6, stabxmax DIV 2 + 1, stabymax + 3);

    SetColor (12);
    Line (stabxmax DIV 2 - 1, stabymin - 7, stabxmax DIV 2 - 1, stabymax + 3);
    Line (stabxmax DIV 2, stabymin - 7, stabxmax DIV 2, stabymax + 3);
    Line (stabxmin - 4, stabymin + 17, stabxmax + 4, stabymin + 17);
    Line (stabxmin - 4, stabymin + 18, stabxmax + 4, stabymin + 18);

    MausBereich (stabxmin, stabxmax, stabymin, stabymax);
    GrDisplay_Menu (3 + sxmin, symin, SymbolMenu1, 2);
    GrDisplay_Menu (5 + sxmax DIV 2, symin, SymbolMenu2, 2);
    acolor := GetColor;
    SetColor (symsymbolscolor);
    sgrmaxy := grmaxy;
    grmaxy  := gmaxy;
    For i := 1 To 13 Do
    Begin
        y := stabymin + SymbolMenu1.menuattr.firstline * CharHeight +
            3 + i * 4 * CharHeight;
        For blnum := 1 To 3 Do
        Begin
            DmeDispChar (stabxmin + 148 + blnum * 35, y,
                SymbolMenu1.choices[i], blnum);
            DmeDispChar (stabxmax DIV 2 + 152 + blnum * 35,
                y, SymbolMenu2.choices[i], blnum);
        End;
    End;
    grmaxy := sgrmaxy;
    SetColor (acolor);
End;

{******************************************************}
Procedure HlpSymbolSelect(Var c: char);

Var
    symbolnum, choicenum: byte;
    movedir: movement;
    mausx, mausy, maustaste, mausmenu: word;
    SMBKC: Byte;
Begin
    SMBKC := MenuBkColor;
    MenuBkColor := 7;
    HlpSymbolTable;
    maustaste := 0;
    If ord (c) <= 109 Then
    Begin
        symbolnum := 1;
        choicenum := ord (c) - 96;
    End
    Else
    Begin
        symbolnum := 2;
        choicenum := ord (c) - 109;
    End;
{   GrDisplay_Menu(3 + sxmin, symin, SymbolMenu1, 2);
   GrDisplay_Menu(5 + sxmax div 2, symin, SymbolMenu2, 2);
 }
    Repeat
        If symbolnum = 1 Then
            GrGet_Menu_Response (3 + sxmin, symin, SymbolMenu1, c,
                movedir, choicenum, mausx, mausy,
                maustaste, mausmenu, true, 2)
        Else
            GrGet_Menu_Response (5 + sxmax DIV 2, symin, SymbolMenu2, c,
                movedir, choicenum, mausx, mausy,
                maustaste, mausmenu, true, 2);

        If ((movedir = left) OR (movedir = right)) Then
            symbolnum := ord (movedir);

    Until ((c = chr (27)) OR ((movedir <> left) AND (movedir <> right)));
    MenuBkColor := SMBKC;
End;

{******************************************************}
Procedure HlpCommandTable;

Const
    xmin = 1;
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
Const
    nminx = 0;         { Screen frame                 }
    nminy = 0;
    nmaxx = 639;
    nmaxy = 479;

    ominy = nminx;     { vert. Trennlinien oben        }
    omaxy = 380;

    o1x = 77;        { 1. vert. Trennlinie oben      }
    o2x = 213;       { 2. vert. Trennlinie oben      }
    o3x = 357;       { 3. vert. Trennlinie oben      }
    o4x = 499;       { 4. vert. Trennlinie oben      }

    uminy = omaxy + 3;   { vert. Trennlinien oben        }
    umaxy = nmaxy;

    u1x = 317;       { 1. vert. Trennlinie unten     }
    u2x = 445;       { 2. vert. Trennlinie unten     }

    h1y = 28;        { 1. hor.  Trennlinie           }
    h2y = uminy;     { 2. hor.  Trennlinie           }

    keyy = 14;        { shift/ctrl/alt... keys        }

    keysx = 17;       { 'Keys'                        }
    keyx  = 161;      { 'Key'                         }

    shftkeyx = 225;    { 'Shift + Key'                 }
    shftofs1 = 64;
    shftofs2 = 80;

    ctrlkeyx = 369;    { 'Ctrl + Key'                  }
    ctrlofs1 = 59;
    ctrlofs2 = 78;

    altkeyx = 511;    { 'alt + Key'                  }
    altofs1 = 64;
    altofs2 = 80;

Var
    i: byte;
    textst1, textst2, textst3, textst4, stri: string;
Begin
    SetBkColor (7{menubkcolor}); {bei einer andern Farbe mÅssten Schatten rechts und unten definiert werden!}
    {-----------}
    SetColor (5{imenutextcolor});

    Line (nminx, nminy, nmaxx, nminy); { oberer Rand                    }
    Line (nminx, nminy + 1, nminx, nmaxy); { linker Rand                    }

    Line (o1x, oMinY, o1x, omaxY);          { 1. vert. Trennlinie oben       }
    Line (o2x, oMinY, o2x, omaxY);          { 2. vert. Trennlinie oben       }
    Line (o3x, oMinY, o3x, omaxY);          { 3. vert. Trennlinie oben       }
    Line (o4x, oMinY, o4x, omaxY);          { 4. vert. Trennlinie oben       }

    Line (u1x, uminy, u1x, umaxy);          { 1. vert. Trennlinie unten      }
    Line (u2x, uminy, u2x, umaxy);          { 2. vert. Trennlinie unten      }

    Line (nminx, h1y, nmaxx, h1y);          { 1. hor.  Trennlinie            }
    Line (nminx, h2y, nmaxx, h2y);          { 2. hor.  Trennlinie            }
    {-----------}
    SetColor (12);

    Line (o1x - 2, ominy, o1x - 2, omaxy);       { 1.vert. Trennlinie o.Schatten }
    Line (o1x - 1, ominy, o1x - 1, omaxy);       { 1.vert. Trennlinie o.Schatten }

    Line (o2x - 2, ominy, o2x - 2, omaxy);       { 2.vert. Trennlinie o.Schatten }
    Line (o2x - 1, ominy, o2x - 1, omaxy);       { 2.vert. Trennlinie o.Schatten }

    Line (o3x - 2, ominy, o3x - 2, omaxy);       { 3.vert. Trennlinie o.Schatten }
    Line (o3x - 1, ominy, o3x - 1, omaxy);       { 3.vert. Trennlinie o.Schatten }

    Line (o4x - 2, ominy, o4x - 2, omaxy);       { 4.vert. Trennlinie o.Schatten }
    Line (o4x - 1, ominy, o4x - 1, omaxy);       { 4.vert. Trennlinie o.Schatten }

    Line (u1x - 2, uminy, u1x - 2, umaxy);       { 1.vert. Trennlinie u.Schatten }
    Line (u1x - 1, uminy, u1x - 1, umaxy);       { 1.vert. Trennlinie u.Schatten }

    Line (u2x - 2, uminy, u2x - 2, umaxy);       { 1.vert. Trennlinie u.Schatten }
    Line (u2x - 1, uminy, u2x - 1, umaxy);       { 1.vert. Trennlinie u.Schatten }

    Line (nminx, h1y - 2, nmaxx, h1y - 2);       { 1. hor. Trennlinie Schatten   }
    Line (nminx, h1y - 1, nmaxx, h1y - 1);       { 1. hor. Trennlinie Schatten   }

    Line (nminx, h2y - 2, nmaxx, h2y - 2);       { 2. hor. Trennlinie Schatten   }
    Line (nminx, h2y - 1, nmaxx, h2y - 1);       { 2. hor. Trennlinie Schatten   }

    SetColor (menutextcolor);
    {-------------------------------------------------------------------------}
    IniWriteXY (keysx, keyy, ' Keys');

    IniSpacedWrite (keyx, keyy, ' Key ', frHigh);

    IniSpacedWrite (shftkeyx, keyy, ' Shift ', frHigh);
    IniWriteXY (shftkeyx + shftofs1, keyy, '+');
    IniSpacedWrite (shftkeyx + shftofs2, keyy, ' Key ', frHigh);

    IniSpacedWrite (ctrlkeyx, keyy, ' Ctrl ', frHigh);
    IniWriteXY (ctrlkeyx + ctrlofs1, keyy, '+');
    IniSpacedWrite (ctrlkeyx + ctrlofs2, keyy, ' Key ', frHigh);

    IniSpacedWrite (altkeyx, keyy, '  Alt  ', frHigh);
    IniWriteXY (altkeyx + altofs1, keyy, '+');
    IniSpacedWrite (altkeyx + altofs2, keyy, ' Key ', frHigh);

    For i := 1 To 27 Do
    Begin
        If i <= 12 Then
        Begin
            If i > 9 Then
                Stri := '1' + char (i + 38)
            Else
                Stri := ' ' + Char (i + 48);
            inispacedtext (tminx - 7, tminy + (i * 2), '  F' + stri + '  ', frHigh);
        End
        Else
            Case i Of
{           11:;
            12:;
            13:}
                13: iniSpacedtext (tminx - 7, tminy + (i * 2), '  ->' + #27 + #196 + #196 + #217 + ' ', frHigh);
                14: iniSpacedtext (tminx - 7, tminy + (i * 2), '  Home ', frHigh);
                15: iniSpacedtext (tminx - 7, tminy + (i * 2), '  End  ', frHigh);
                16: iniSpacedtext (tminx - 7, tminy + (i * 2), '  PgUp ', frHigh);
                17: iniSpacedtext (tminx - 7, tminy + (i * 2), '  PgDn ', frHigh);
                18: iniSpacedtext (tminx - 7, tminy + (i * 2), '  ' + #27 + #196 + '   ', frHigh);
                19: iniSpacedtext (tminx - 7, tminy + (i * 2), '  Del  ', frHigh);
                20: iniSpacedtext (tminx - 7, tminy + (i * 2), '  Ins  ', frHigh);
                21: iniSpacedtext (tminx - 7, tminy + (i * 2), '  Tab  ', frHigh);
                {            21:;}
                {            22: iniSpacedtext(tminx - 7, tminy+(22*2),' Others ',frHigh); }
{            23:;
            24:;
            25:;
            26:;
            27:;}
            End;

        textst1 := '';
        textst2 := '';
        textst3 := '';
        textst4 := '';

        Case i Of
            1:
            Begin
                textst1 := ' this help table';
                textst2 := ' show   / hide';
                textst3 := ' print';
                textst4 := ' vertical  { begin';
            End;

            2:
            Begin
                textst1 := ' save      file';
                textst2 := ' save   / nosave ?';
                {  if not (setuppage in actedit) then }{new, herausgenommen}
                Begin
                    textst3 := ' split     file';
                End;
                textst4 := ' vertical  { end';
            End;

            3:
            Begin
                textst1 := ' noteline  insert';
                textst2 := ' noteline define';
                textst3 := ' split     line';
                textst4 := ' horizont. { begin';
            End;

            4:
            Begin
                textst1 := ' spaceline insert';
                textst2 := ' insert   page';
                textst3 := ' split     page';
                textst4 := ' horizont. { end';
            End;

            5:
            Begin
                textst1 := ' sound     play ';
                textst2 := ' sound    options';
                textst3 := ' symbol(s) sound '; {auch ins Shift-F5 Menu nehmen!}
                textst4 := ' vertical    line';
            End;

            6:
            Begin
                textst1 := ' header +/ footer';
                textst2 := ' search + replace';
                textst3 := ' search    repeat';
                textst4 := ' vert. short line';
            End;

            7:
            Begin
                textst1 := ' copy      line';
                textst2 := ' line     commands';
                textst3 := ' paste     line ';
                textst4 := ' horiz. 3D - line';
            End;

            8:
            Begin
                textst1 := ' mark/undo block';
                textst2 := ' block    commands';
                textst3 := ' paste     block';
                textst4 := ' vert.  3D - line';
            End;

            9:
            Begin
                textst1 := ' mark/undo page';
                textst2 := ' page     commands';
                textst3 := ' paste     page';
                textst4 := ' setup   new page';
            End;

            10:
            Begin
                textst1 := ' symbols   table';
                textst2 := ' keyboard swap';
                textst3 := ' change    font';
                textst4 := ' number of   page';
            End;

            11: textst1 := ' statusbar/mousemenu';

            12: textst1 := ' refresh   page';

            13:
            Begin
                textst1 := ' next  noteline';
                textst2 := ' next textline  ';
                textst3 := ' equal noteline below';
            End;

            14:
            Begin
                textst1 := ' begin of  line';
                {    textst2:=' first    noteline';   }
                textst3 := ' begin of  page';
            End;

            15:
            Begin
                textst1 := ' end   of  line';
                {     textst2:=' last     noteline';  }
                textst3 := ' end   of  page';
            End;

            16:
            Begin
                textst1 := ' previous  page';
                textst2 := ' join     next page';
                textst3 := ' first     page';
            End;{ if not (setuppage in actedit) then}{new, herausgenommen}

            17:
            Begin
                textst1 := ' next      page';
                textst2 := ' add  new page at end';
                textst3 := ' last      page';
            End;{   if not (setuppage in actedit) then}{new, herausgenommen}

            18:
            Begin
                textst1 := ' backspace';
                textst2 := ' del to   line begin';
                textst3 := ' delete    line';
            End;

            19:
            Begin
                textst1 := ' symb/char delete';
                textst2 := ' del to   line end';
                textst3 := ' delete    block/page';
                textst4 := '';
            End;

            20:
            Begin
                textst1 := ' symb/char insert';
                textst2 := ' undelete line';
                textst3 := ' undelete  block/page';
            End;

            21:
            Begin
                textst1 := ' lower     tab   ';
                textst2 := ' upper    tab   ';
                textst3 := '               ';
            End;

            23:
            Begin
                IniSpacedText (tminx - 7, tminy + (i * 2), '1', frHigh);
                IniOutTextXY (tminx - 7 + 1, tminy + (i * 2), '  to');
                IniSpacedText (tminx - 7 + 5, tminy + (i * 2), '9', frHigh);
                IniOutTextXY (tminx - 7 + 6, tminy + (i * 2), ' , ');
                IniSpacedText (tminx - 7 + 9, tminy + (i * 2), '010', frHigh);
                IniOutTextXY (tminx - 7 + 12, tminy + (i * 2), ' to');
                IniSpacedText (tminx - 7 + 15, tminy + (i * 2), '099', frHigh);
                IniOutTextXY (tminx - 7 + 18, tminy + (i * 2), '  pulse(s)* per beat');

                iniSpacedtext (tminx + SA - 4, tminy + (i * 2), 'Space', frHigh);
                IniOutTextXY (tminx + SA - 4 + 5, tminy + (i * 2), ' pause mark');

                iniSpacedtext (tminx + TA - 5, tminy + (i * 2), '-', frHigh);
                IniOutTextXY (tminx + TA - 5 + 1, tminy + (i * 2), '  +');
                iniSpacedtext (tminx + TA - 5 + 4, tminy + (i * 2), '2 symbols', frHigh);
                IniOutTextXY (tminx + TA - 5 + 13, tminy + (i * 2), '  flam(-)');

            End;

            24:
            Begin
                iniSpacedtext (tminx - 7, tminy + (i * 2), '<', frHigh);
                IniOutTextXY (tminx - 7 + 1, tminy + (i * 2), '  or');
                iniSpacedtext (tminx - 7 + 5, tminy + (i * 2), '>', frHigh);
                IniOutTextXY (tminx - 7 + 6, tminy + (i * 2), '  +');
                iniSpacedtext (tminx - 7 + 9, tminy + (i * 2), 'pulse', frHigh);
                IniOutTextXY (tminx - 7 + 14, tminy + (i * 2), ' *');
                IniOutTextXY (tminx - 7 + 18, tminy + (i * 2), '  insert subpulses to L/R');

                iniSpacedtext (tminx + SA - 4, tminy + (i * 2), ',', frHigh);
                IniOutTextXY (tminx + SA - 4 + 5, tminy + (i * 2), ' time  mark');

                iniSpacedtext (tminx + TA - 5, tminy + (i * 2), '=', frHigh);
                IniOutTextXY (tminx + TA - 5 + 1, tminy + (i * 2), '  +');
                iniSpacedtext (tminx + TA - 5 + 4, tminy + (i * 2), '2 symbols', frHigh);
                IniOutTextXY (tminx + TA - 5 + 13, tminy + (i * 2), '  unisono');

            End;


            25:
            Begin

                iniSpacedtext (tminx - 7, tminy + (i * 2), '<', frHigh);
                IniOutTextXY (tminx - 7 + 1, tminy + (i * 2), '  or');
                iniSpacedtext (tminx - 7 + 5, tminy + (i * 2), '>', frHigh);
                IniOutTextXY (tminx - 7 + 6, tminy + (i * 2), '  +');
                iniSpacedtext (tminx - 7 + 9, tminy + (i * 2), ':', frHigh);
                IniOutTextXY (tminx - 7 + 10, tminy + (i * 2), ' +');
                iniSpacedtext (tminx - 7 + 12, tminy + (i * 2), 'number', frHigh);
                IniOutTextXY (tminx - 7 + 18, tminy + (i * 2), '  devide pulse to L/R by');

                iniSpacedtext (tminx + SA - 4, tminy + (i * 2), '.', frHigh);
                IniOutTextXY (tminx + SA - 4 + 5, tminy + (i * 2), ' help  mark');

                iniSpacedtext (tminx + TA - 5, tminy + (i * 2), '+', frHigh);
                IniOutTextXY (tminx + TA - 5 + 1, tminy + (i * 2), '  +');
                iniSpacedtext (tminx + TA - 5 + 4, tminy + (i * 2), '2 symbols', frHigh);
                IniOutTextXY (tminx + TA - 5 + 13, tminy + (i * 2), '  flam(+)');

            End;

            26:
            Begin
                iniSpacedtext (tminx - 7, tminy + (i * 2), 'symbol', frHigh);
                IniOutTextXY (tminx - 7 + 6, tminy + (i * 2), '  +');
                iniSpacedtext (tminx - 7 + 9, tminy + (i * 2), '(', frHigh);
                IniOutTextXY (tminx - 7 + 10, tminy + (i * 2), ' ');
                iniSpacedtext (tminx - 7 + 11, tminy + (i * 2), ')', frHigh);
                IniOutTextXY (tminx - 7 + 12, tminy + (i * 2), ' or');
                iniSpacedtext (tminx - 7 + 15, tminy + (i * 2), '[', frHigh);
                IniOutTextXY (tminx - 7 + 16, tminy + (i * 2), ' ');
                iniSpacedtext (tminx - 7 + 17, tminy + (i * 2), ']', frHigh);
                IniOutTextXY (tminx - 7 + 18, tminy + (i * 2), '  drop/add,');

                IniOutTextXY (tminx - 7 + 26, tminy + (i * 2), ' +');
                iniSpacedtext (tminx - 7 + 28, tminy + (i * 2), '{', frHigh);
                IniOutTextXY (tminx - 7 + 29, tminy + (i * 2), ' ');
                iniSpacedtext (tminx - 7 + 30, tminy + (i * 2), '}', frHigh);
                IniOutTextXY (tminx - 7 + 31, tminy + (i * 2), '  altern.');

                iniSpacedtext (tminx + TA - 5, tminy + (i * 2), '*', frHigh);
                IniOutTextXY (tminx + TA - 5 + 1, tminy + (i * 2), '  +');
                iniSpacedtext (tminx + TA - 5 + 4, tminy + (i * 2), '1(2)symb.', frHigh);
                IniOutTextXY (tminx + TA - 5 + 13, tminy + (i * 2), '  below line');

                iniSpacedtext (tminx + SA - 4, tminy + (i * 2), #221, frHigh);
                iniSpacedtext (tminx + SA - 4 + 2, tminy + (i * 2), '\', frHigh);
                IniOutTextXY (tminx + SA - 4 + 5, tminy + (i * 2), ' jump  marks');
            End;{ if not (setuppage in actedit) then}{new, herausgenommen}

            27:
            Begin
                {   if not (setuppage in actedit) then}{new, herausgenommen}
                Begin
                    iniSpacedtext (2, tminy + (i * 2) + 1, '  Esc  ', frHigh);
                    IniOutTextXY (9, tminy + (i * 2) + 1, '  or             Quit');
                    iniSpacedtext (13, tminy + (i * 2) + 1, 'mouse R', frHigh);

                    iniSpacedtext (tminx + SA - 4, tminy + (i * 2), '/', frHigh);
                    IniOutTextXY (tminx + SA - 4 + 5, tminy + (i * 2), ' end   mark');

                End;


                iniSpacedtext (tminx + TA - 5, tminy + (i * 2), '&', frHigh);
                iniSpacedtext (tminx + TA - 5 + 2, tminy + (i * 2), '"', frHigh);
                IniOutTextXY (tminx + TA - 5 + 4, tminy + (i * 2), 'repeat marks');

            End;

        End; {case i of}

        IniOutTextXY (tminx + 2, tminy + (i * 2), textst1);
        IniOutTextXY (tminx + FA, tminy + (i * 2), textst2);
        IniOutTextXY (tminx + SA, tminy + (i * 2), textst3);
        IniOutTextXY (tminx + TA + 1, tminy + (i * 2), textst4);
    End;
End;

End.
