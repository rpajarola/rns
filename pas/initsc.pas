{$I RNS.H}
Unit InitSc;
Interface

Uses
    graph,
    menutyp,
    inout,
    dos,
    xcrt,
    crt,
    TextFont,
    loadbmp,
    SysUtils;

Const
    versionstring = '004';

    LineMarker = 9;
      {1: N=Notenlinie T=Textlinie

       3: P= Setup Page
       4: F= Header/Footer
       5: H=Hidden Line}

    StLength = 245;
    ClearAreaX = 10;
    PageLim  = 56;

    barfill = 11; {fill style fuer menus}

    promptline = 21;
    smallblankup = 9;
    smallblankdown = 240;

    resolparam = 3;

    ttyp = 1; {horizontal TextJustify}

    drightmargin = 0;
    linestyletop = 11; {max. H�he beim Editieren der Linestyles}
    dygraph = 6; {Schriftverschiebung in y-Richtung}
    labellength = 20;
    leftx = 20; {linker Rand in den Symbol - Menus}
    numofpar = 8; {Max Anzahl parameter pro symbol}

(*      pswidth = 0.2; {Standard- Breite}                 {vorher 0.1!}
      smwidth = 0.1; {Breite von Hilfslinien}
      dtwidth = 0.3; {gepunktete Linien}
      thwidth = 0.5; {Breite von dicken Linien}
      lswidth = 0.5; {0.5 Breite von Nichts und Leeren}
      grwidth = 0.6; {Breite von Grids}                 {vorher 0.4!}*)
    {0.1 - 0.3 ist auf Epson 800 identisch, 0.4 - 0.5, ev. 0.6 ebenfalls}

    frwidth = 0.8; { frame }

    hlwidth = 0.8; { horizontal line }
    vlwidth = 0.8; { vertical 3d line }
    pswidth = 0.2; { vertical normal line }
    bewidth = 0.4; { beat-breite }
    lswidth = 0.6; { symleer }
    niwidth = 0.6; { symnichts }
    grwidth = 0.6; { Grids }

    { notelines }
    tkwidth = 0.5; { thick }
    dtwidth = 0.5; { doted }
    piwidth = 0.2; { pitch }
    tnwidth = 0.2; { thin }

    spec: Set Of char = [' ', '/', '.', ',', '\', '&', '"'];
    flamset: Set Of char = ['+', '=', '-', '*'];
    klammerset: Set Of char = ['(', ')', '[', ']', '{', '}'];
    sndmaxspm = 600;

    HintNormalTime = 750;
    HintWaitEsc = 0;
    HintNoRestore = -1;

    hpEdit = 0;       { Hint position }
    hpUp = 1;
    hpFileMenu = 2;

    notes: Set Of char =
        ['a'..'z', 'A'..'Z', #128..#153, '/', '\', '.', ' ', ',', '+', '=', '-', '*'];
    numbers: Set Of char = ['0'..'9'];
    sz8x8 = 0;    { Sizes }
    sz8x16 = 1;
    sz6x12 = 2;
    stNormal = $00;
    stBold = $01;
    stDouble = $02;
    stItalic = $04;
    stUndeline = $08;
    stHigh = $10;
    stLow = $20;
    stSpaced = $40;

    frNoFrame = $00;       { kein Rahmen                   }
    frHigh = $01;       { herausstehend                 }
    frLow = $02;       { versenkt                      }
    fr3D = $03;       { 3D Rahmen (Hallo Windows)     }
    frL3D = $04;       { 3D Rahmen (Platten-Effekt)    }
    frDel3D = $80;       { l�scht den 3D Rahmen          }
    frNoBar = $40;       { zeichnet keinen Balken        }
    frSmallBar = $20;       { zeichnet einen kleineren Balk.}

    plPulse = $03;       { Spielt ','                     }
    plSpace = $04;       { Spielt ' '                     }
    plEt = $08;       { Spielt '&'                     }

    plPulseNever = $00;       { Spielt ',' nie                 }
    plPulseNoLeg = $01;       { Spielt ',' falls kein Legato   }
    plPulseAlways = $02;       { Spielt ',' immer               }

    poParentheses = $01;      { spielt () nicht                }
    poBrackets = $02;      { spielt []                      }
    poBraces = $04;      (*spielt {} variante 2          *)
    poDashSlash = $08;      { ignoriert �                    }

    saLegato = $01;      { spielt die T�ne legato         }
    saStaccato = $02;      { spielt die T�ne staccato       }
    (*    saInterval    = $??;      { spielt alle Intervalle, z�hlt  } *)
(*    saPitches     = $??;      { spielt die vorhandenen T�ne    }
                                { aufsteigend ohne Wiederholungen) *)
    saRhythm = $08;      { spielt rhythmisches Skelett    }
    (*    saYFreq       = $??;      { spielt Melodie ohne Rhythmus   } *)
    {hexadez: 01,02,04,08,10,20,40,80,100}
    saMuffled = $04;      { spielt ged�mpft/sehr kurz      }
    saPhrased = $10;      { spielt phrasiert ab}


    PlayBeatNever = 1;
    PlayBeatAlways = 2;
    PlayBeatEmpty = 3;

    staccatolength = 50;
    legatolength = 30000;    { damit richtig legato gespielt wird }
    RhythmFreq = 392;      { spielt Rhythmus mit 392 Hz         }
    muffledlength = 5;        { spielt T�ne leise/sehr kurz        }
    phrasedmul1 = 2;        { Abstandsmultiplikator: phrasiert   }

    logoname = 'TITLE.BMP';

    keyswap: Array[0..2, 0..2] Of char = { ' ' ',' '.' }
        (('.', ' ', ','),
        (' ', ',', '.'),
        (',', ' ', '.'));

Type stringline = string;
    KeyEntry = (invalid, one, numeric, character, curupdown, plus,
        postplus, other);
    ArrowTyp = (noarr, leftarr, rightarr);
    Editvariants = (setuppage, defsetuppage, linestyles);

    {bitmap: Buchstabe, Zeile (1 word pro zeile), Normal/Ctrl/Alt/}
    SymArrTyp = Array['a'..'z', 1..15, 1..3] Of uint16;
    { Symparameter: Buchstabe,?,nor,ctrl,alt}
    SymParamTyp = Array['a'..'z', 1..numofpar, 1..3] Of int16;
        {parameter 1: y-shift
                   2: replace/add  1 = replace, 2 = add
                   3: sound frequency
                   4: sound length
                   5: unused
                   6: unused
                   7: unused
                   8: unused
                   }
    listptr = ^linerec;

    linerec = Record
        datblock: stringline;
        next: listptr;
        last: listptr;
    End;

    lineattrtype = Record
        beats: integer;
        eint:  integer;
        resolution: integer;
        linestyle: byte; {1=thick,2=pitch,3=thin,4=dotted,5=helpline}
    End;

    markdescrtyp = Record
        mline: integer;
        mpos:  integer;
        mpag:  integer;
        mxcoord: integer;
    End;

    TRGB = Record
        R, G, B: Byte;
    End;
    TDACTable = Array[0..$FF] Of TRGB;
    TRealRGB  = Record
        R, G, B: Real;
    End;
    TRealDAC = Array[0..$FF] Of TRealRGB;
    TCharSet = Set Of Char;
Var ThePalette: TDACTable;
    PalSteps: TRealDAC;
    symbcount: byte;   {das wievielte Zeichen wird angezeigt(f�r pagshowcurposistances}
    infile: text;
    GraphDriver: integer;
    GraphMode: integer;
    ErrCode: integer;
    heapmark: pointer;

    curcolor, gridcolor: byte;
    bkcolor, lcolor, ibkcolor, ilcolor: byte;
    {Backcolor, Foreground, Inverse Background, Inverse Foreground}
    menutextcolor, menubkcolor, imenutextcolor, imenubkcolor: byte;
    menuframecolor: byte;
    bottomcolor, speccolor, helplinecolor, alarmcolor, alarmbkcolor: byte;
    tmtext, tmbk, itmtext, itmbk: byte;
    soundcolor: byte;
    symtabcolor: byte;
    symtabbkcolor: byte;
    symsymbolscolor: byte;
    mausmtcolor, mausmbkcolor: byte;
    FrameColor, FrameBkColor: Byte;
    PageLength: integer;
    LineThick, line2thick: integer;
    TopMargin: integer;
    PageCount: integer;
    Pagesav: integer;   {Letzte Seitennummer vor Eintritt in Setup page}
    CharWidth, CharHeight: integer;
    Char2Width, Char2Height: integer;  {Halbe Zeichenbreite, Hoehe}
    Chr4Width: integer;
    Chr8Width: integer;
    Page: Array[0..PageLim] Of stringline;
    actfilename: stringline;
    insmusicline: stringline;
    TextMargin: integer;
    SymCount: integer;
    ActNumber: integer;
    LastEntry: KeyEntry;
    Lastchar: char;
    ArrowEntry: ArrowTyp;
    SymArr: SymArrTyp;
    SymPar: SymParamTyp;
    actattr: lineattrtype;

    dispspec: byte; {2 = off, 1 = on}
    dispgrid: byte;
    dispsound: byte; {2 = off, 1 = play while editing}
    disphidlines: byte;
    dispslash: byte;
    charset: byte; {1 = normaler set, 2 = <alt> , normal, shift}
    blankset: byte; {1 = blank ist Leertaste, 2 = blank ist Komma}
    manset: byte;  {1 = normal, 2 = alle Zeichen addieren}
    delln, saveln: stringline;
    delpage: boolean; {true, falls zuletzt eine Seite geloescht wurde}
    copypage: boolean;{" " " Seite kopiert}
    linecount: integer;
    yzeropos: integer;

    gmaxx, gmaxy: integer;

    GrInitialized: boolean = false;
    GrMinX, GrMaxX, GrMinY, GrMaxY: integer;
    UsrMenu, Symbolmenu1, Symbolmenu2: Menu_Rec;
    togglestring:  toggletyp;
    hfminx, hfminy, hfmaxx, hfmaxy: integer;
    TOP_Line, Left_Col, Valcol: integer;
    stabxmin, stabxmax, stabymin, stabymax: integer;
    sxmin, sxmax, symin, symax: integer;
    fontfile, colorfile: string;

    searchstring: stringline;
    searchtyp: char;
    replaceflag: boolean;
    replacestring: stringline;

    nextresponse: Response_Type; {Key im Keyboard-Buffer}
    nextkey: Char;
    nextshift, nextctrl: boolean;

    symboldx, symboldy: integer;
    mstart, mend: markdescrtyp;
    marpartline:  boolean;

    actedit: Set Of editvariants;
    inbuffer: string; {Buffer fuer eingegebene Zeichen}
    bufstartptr, bufactptr, bufendptr: listptr;
    refxmin, refxmax, refymin, refymax: integer;
    hintminx, hintminy, hintmaxx, hintmaxy: integer;

    printeron: boolean; {true, wenn postscriptfile geschrieben wird}

    prformat: byte; {1 = 1 page per sheet, 2 = 2 pages per sheet}
    prpage, prdest: integer;
    prfname: string;
    prfile: integer; {1 wenn auf file geschrieben wird}
    prdevice: string;

    paused: boolean;    {pause?}
    sndlength: integer; {l�nge pro beat}
    sndlengthspm: real;{new}{dasselbe f�r strokes/min}
    sndlengthper: byte; {Laenge pro beat oder Line}
    sndplaybeat: byte; {Beat spielen oder nicht}
    sndplaypulse: byte; {Puls spielen oder nicht}{ bit 0: ','; bit 1:' '}
    {Beath�he, L�nge, Pulsh�he, L�nge}
    sndbeat, sndbeatlength, sndpulse, sndpulselength: integer;
    sndchar: char;
    sndwarning: byte;
    PlaySuccess: Boolean;

    usrname, usrfirstname: stringline;

    showmenus: boolean;

    addcent: integer;
    mulcent: real;
    LastSound: integer;
    FrameWidth: Byte;
    FileChanged: Byte;
    CtrlEnterOfs: Byte;
    TxtFnt: TTextFontViewer;
    pagebuf: integer;
    lastbuf: integer;
    ctrlF5: boolean;
    bufffile: boolean;
    playoptions: byte;(* () [] {} � / *)
    soundattr: byte;
    soundchange: byte;
    Logo: pbmp16;
    SymFontSize: Byte;
    psfile: text;
    psdir, bufdir: string;
    ShowSlashes: byte;
    nff:  boolean;

Procedure IniOutTextXY(X, Y: integer; Texts: String);
Procedure IniWriteXY(X, Y: integer; Texts: String);
Function IniAltChar(c: char): char;
Procedure IniGetSymbols;
Procedure InitScreen;
Function IniYnow(linenum: integer): integer;
Procedure IniNewPage(Var linenum: integer);
Procedure IniClrCharField(x, y: integer);
Procedure IniCharAdd(Var TargetString: Stringline; C: Char;
    PosInString: integer);
Function IniNextnumber(Var strbuf: stringline): integer;
Function IniRDxValue(lineattr: lineattrtype): real;
Function IniDxValue(lineattr: lineattrtype): integer;
Function IniPrintChar(c: char): Boolean;
Function IniPrintNote(c: char): Boolean;
Function IniNumChar(c: char): Boolean;
Function IniArrow(c: char): Boolean;
Function IniDoppel(c: char): Boolean;
Procedure IniGraphXY(Var X, Y: integer);
Procedure IniInversWrite(X, Y: integer; Texts: String; T: Byte);
Procedure IniSpacedWrite(X, Y: integer; Texts: String; T: Byte);
Procedure IniInversText(X, Y: integer; Texts: String; T: Byte);
Procedure IniSpacedText(X, Y: integer; Texts: String; T: Byte);
Procedure IniClearLine(X, Y: integer; cllength: integer;
    BColor: byte);
Procedure IniClearSpacedLine(X, Y: integer; cllength: integer;
    BColor: byte);
Function IniLnow(ynow: integer): integer;
Procedure IniSetViewPort(x1, y1, x2, y2: integer);
Function IniEmptyLine(inblock: stringline): boolean;
Function IniLeftMargin: integer;
Procedure IniTrailBlank(Var inblock: stringline);
Procedure IniLeadBlank(Var inblock: stringline);
Function IniUserFontFile(instring: string): boolean;
Function IniFileExist(instring: string): boolean;
Function IniDirExist(instring: string): boolean;
Function IniBytes(x, y: integer): integer;
Procedure IniGraphMode;
Procedure IniRefInit;
Procedure IniGraphinit;
Procedure IniGraphClose;
Function IniFirstBeatPos(lineattr: lineattrtype): integer;
Function IniYBottomMargin: integer;
Function IniPos(linenum, actposn, actpost: integer): integer;
Function IniMaxHeader: integer;
Function IniHeaderFooterLine(linenum: integer): boolean;
Function IniMinFooter: integer;
Function IniHeaderEnd: integer;
Function IniFooterEnd: integer;
Procedure IniExpand(Var instring: string; newlength: byte);
Function IniTabChar(c: char): boolean;
Procedure IniShowCursor;
Procedure IniHideCursor;
Procedure IniSwapColors;
Procedure IniIniColors;
Procedure IniHideColors;
Procedure IniIniSymbols;
Function IniKeyPressed: boolean;
Function IniMausEscape: char;
Procedure IniMausAssign(maustaste: word; Var resp: response_type);
Procedure IniSwapFrame;
Procedure IniSwapMenuColors;
Procedure ISwap(Var a, b: INTEGER);
Procedure WSwap(Var a, b: WORD);
Procedure BSwap(Var a, b: BYTE);
Function UpString(Var Zeile: STRING): String;
Procedure Ini3DFrame(X0, Y0, X1, Y1: Word; F, B: Byte; t: byte);
Function IniLineEnd(inblock: String): Integer;
Procedure IniLineEndSound(Level: Byte);
Procedure IniInitPalette;
Procedure IniFadeOut;
Procedure IniFadeIn;
Procedure IniSetDACReg(n, r, g, b: byte);
Procedure IniSetAllDACRegs(aPalette: TDACTable);
Procedure IniPalBlank(r, g, b: byte);
Procedure IniDrawSoundState;
Implementation

Uses gcurunit,
    mousdrv,
    fileunit,
    getunit;

{******************************************************}
Function UpString(Var Zeile: STRING): String;
    (* Umwandlung eines Strings in Gro�buchstaben *)
Var i: INTEGER;
Begin
    For i := 1 To Length (Zeile) Do Zeile[i] := UpCase (Zeile[i]);
    UpString := Zeile;
End;
{******************************************************}
Function IniKeyPressed: boolean;
{wird true, wenn ein key gedr�ckt wurde, der den Bildaufbau
 abbricht}
Const skipset:
        Set Of byte = [59, 60, 62, 67, 73, 81, 89, 118, 132];
Var c: char;
    res: boolean;
    mausx, mausy, maustaste, mp, mausmenu: word;
Begin
    If nextresponse = no_response Then res := false Else res := true;
    If ((nextresponse = no_response) AND (xKeyPressed)) Then
    Begin
        c := xreadkey (nextshift, nextctrl);
        If c = #27 Then
        Begin
            res := true;
            nextresponse := escape;
        End Else If c = #0 Then
        Begin
            c := xreadkey (nextshift, nextctrl);
            If byte (c) IN skipset Then
            Begin
                res := true;
                nextresponse := specialkey;
                nextkey := c;
            End;
        End;
    End;
    If nextresponse = no_response Then
    Begin
        MausPosition (mausx, mausy, maustaste, mp, mausmenu);
        If maustaste = 7 Then
        Begin
            res := true;
            nextresponse := escape;
        End;
    End;
    IniKeyPressed := res;
End;
{****************************************************}
Procedure IniSwapColors;
{Tauscht die Farben von Setuppage und standard aus}
Var
    temp: Byte;
Begin
    // Swap LColor with ILColor
    temp := LColor;
    LColor := ILColor;
    ILColor := temp;

    // Swap BkColor with IBKColor
    temp := BkColor;
    BkColor := IBKColor;
    IBKColor := temp;

    GcuIniCursor;
End;
{****************************************************}
Procedure IniCursor(Anfangszeile, Endzeile: byte);
Begin
    // TODO: Modern cursor shape control
    // Original: Sets cursor shape using BIOS INT 10h
    // Parameters: Anfangszeile (start line), Endzeile (end line)
End;
{****************************************************}
Procedure IniHideCursor;
Begin
    IniCursor ($ff, 0);
End;
{****************************************************}
Procedure IniShowCursor;
Begin
End;
{******************************************************}
Procedure IniExpand(Var instring: string; newlength: byte);
Begin
    // Expand string to newlength by padding with spaces if needed
    While Length (instring) < newlength Do
        instring := instring + ' ';
End;
{******************************************************}
Function IniTabChar(c: char): boolean;
Begin
    IniTabChar := ((c = chr (smallblankup)) OR (c = chr (smallblankdown)));
End;
{******************************************************}
Function IniPos(linenum, actposn, actpost: integer): integer;
Begin
    If page[linenum, 1] = 'T' Then IniPos := actpost Else IniPos := actposn;
End;
{******************************************************}
Function IniMausEscape: char;
Var c: char;
    mausx, mausy, maustaste, mp, mausmenu: word;
    temp1, temp2: boolean;
Begin
    c := ' ';
    maustaste := 0;
    If XKeyPressed Then
    Begin
        c := xReadKey (temp1, temp2);
        c := UpCase (c);
    End Else Begin
        MausPosition (mausx, mausy, maustaste, mp, mausmenu);
        Case Maustaste Of
            2: c := #27;
            1: c := #13;
        Else Case mp Of
                2: c := #27;
                1: c := #13;
            End;
        End;
    End;
    IniMausEscape := c;
End;
{******************************************************}
Procedure IniMausAssign(maustaste: word; Var resp: response_type);
{resp wird return bzw. escape, falls taste 1 bzw. 7 gedr�ckt wurde}
Begin
    If maustaste = 1 Then resp := return Else If maustaste = 2 Then resp := escape;
End;
{******************************************************}
Function IniAltChar(c: char): char;
{Umwandeln eines Alt-Characters in den Bereich 128..153,
 wobei alphabetisch geordnet wird}
Var str: string;
Begin
    str := 'qwertyuiop    asdfghjkl     zxcvbnm';
    IniAltChar := char (Byte (str[Byte (c) - 15]) + 31);
End;
{******************************************************}
Procedure IniGraphClose;
Begin
    CloseGraph;
End;
{******************************************************}
Procedure IniGraphMode;
Begin
    GraphDriver := VGA;
    GraphMode := VGAHi;
    InitGraph (GraphDriver, GraphMode, '');
    ErrCode := GraphResult;
    If ErrCode <> grOk Then
    Begin
        writeln ('Graphics error ', GraphErrorMsg (ErrCode));
        writeln ('Program aborted');
        halt (1);
    End;
    SetTextJustify (LeftText, Ttyp);
    SetTextStyle (DefaultFont, HorizDir, 1);
End;
{******************************************************}
Procedure IniGraphinit;
Begin
    // TODO: Modern graphics initialization
    // Original: VGA CRTC register setup
    IniGraphMode;
    InitScreen;
    GcuIniCursor;
    IniInitPalette;
    IniPalBlank (0, 0, 0);
    // TODO: Modern graphics mode setup
    // Original: VGA mode register setup
End;
{******************************************************}
Function IniBytes(x, y: integer): integer;
Begin
    Inibytes := $2000 * (y MOD 4) + 90 * (y SHR 2) + (x SHR 3);
End;
{******************************************************}
Function IniUserFontFile(instring: string): boolean;
    { testet, ob das File mit dem Namen instring ein User-File ist }
Var F: Text;
    SFM: Integer;
    St: String;
Begin
    Instring := UpString (instring);
    If Pos ('.', Instring) <> 0 Then
        Instring := Copy (Instring, 1, Pos ('.', Instring) - 1);
    Assign (F, 'FONTS.RNS');
    SFM := FileMode;
    ReSet (F);
    FileMode := SFM;
    If IOResult <> 0 Then
    Begin
        IniUserFontFile := True;
        Close (f);
        Exit;
    End;
    St := '';
    While NOT (EoF (F) OR (St = Instring)) Do
    Begin
        ReadLn (F, St);
        St := UpString (st);
        If St = instring Then
        Begin
            IniUserFontFile := False;
            Close (f);
            Exit;
        End;
    End;
    Close (f);
End;
{******************************************************}
Function IniFileExist(instring: string): boolean;
    { testet, ob unter dem Namen instring schon ein File auf dem Directory existiert }
Var FileInfo: TRawbyteSearchRec;
Begin
    FindFirst (instring, AnyFile, FileInfo);
    IniFileExist := (DosError = 0);
End;

{******************************************************}
Function IniDirExist(instring: string): boolean;
    { testet, ob unter dem Namen instring schon ein Directory existiert }
Var actdir: string;
Begin
    GetDir (0, actdir);
    ChDir (instring);
    If IOResult = 0 Then
    Begin
        ChDir ('..');
        IniDirExist := true;
    End Else IniDirExist := false;
    ChDir (ActDir);
End;

{**************************************************************}
Procedure IniTrailBlank(Var inblock: stringline);
Var l: integer;
Begin
    l := length (inblock);
    While ((l > 0) AND (inblock[l] = ' ')) Do
    Begin
        SetLength (inblock, Length (inblock) - 1);
        dec (l);
    End;
End;
{**************************************************************}
Procedure IniLeadBlank(Var inblock: stringline);
Begin
    While ((length (inblock) > 0) AND (inblock[1] = ' ')) Do delete (inblock, 1, 1);
End;
{**************************************************************}
Function IniLeftMargin: integer;
Var margin: integer;
Begin
    margin := GetMaxX - 640;
    If margin < 0 Then
        margin := 0;
    IniLeftMargin := margin;
End;
{**************************************************************}
Procedure IniOutTextXY(X, Y: integer; Texts: String);
Var T: Boolean;
Begin
    t := IstDunkel;
    If NOT T Then Mausdunkel;
    If x < 0 Then x := 0;
    If y < 0 Then y := 0;
    IniGraphXY (x, y);
    TxtFnt.Write (X, Y, texts, getcolor, sz6x12, stnormal);
    If NOT T Then MausZeigen;
End;
{**************************************************************}
Procedure IniWriteXY(X, Y: integer; Texts: String);
Var T: Boolean;
Begin
    t := IstDunkel;
    If NOT T Then Mausdunkel;
    If x < 0 Then x := 0;
    If y < 0 Then y := 0;
    TxtFnt.Write (X, Y, texts, getcolor, sz6x12, stnormal);
    If NOT T Then MausZeigen;
End;
{**************************************************************}
Procedure IniGraphXY(Var X, Y: integer);
Begin
    x := x * charwidth - 6;
    y := y * charheight + 6;
End;
{**************************************************************}
Procedure IniInversWrite(X, Y: integer; Texts: String; t: byte);
Var fcolor, bkcolor: byte;
    fills: fillsettingstype;
    X1, X2, Y1, Y2: Integer;
    D: Boolean;
Begin
    D := IstDunkel;
    If NOT D Then Mausdunkel;
    If (t AND frSmallBar) = frSmallBar Then
    Begin
        t := t AND NOT frSmallBar;
        x1 := X;
        X2 := X + Length (Texts) * 6;
        Y1 := Y - 6;
        Y2 := Y + 5;
    End Else Begin
        X1 := X - 2;
        X2 := X + Length (Texts) * 8;
        Y1 := Y - 6;{-1 w�re besser, clear funktioniert dann aber noch nicht richtig}
        Y2 := Y + 5;
    End;
    fcolor := GetColor;
    bkcolor := GetBkColor;
    GetFillSettings (fills);
    {Zeichne Linienbalken}
    SetColor (imenubkcolor);
    SetFillStyle (1, imenubkcolor);
    If t AND frNoBar = 0 Then
    Begin
        t := t AND NOT frNoBar;
        Bar (X1, Y1, X2, Y2);  {Beschriftungsbalken der (aktiven) Hauptmenu-Buttons}
    End;
    If (t AND (NOT frdel3d) = frhigh) Then
        Ini3DFrame (X1, Y1, X2, Y2, 12, 5, t)
    Else
        Ini3DFrame (X1, Y1, X2, Y2, framebkcolor, framecolor, t);
    TxtFnt.Write (X, Y, Texts, imenutextcolor, sz6x12, stnormal);
    SetColor (fcolor);
    SetBkColor (bkcolor);
    SetFillStyle (1, fills.color);
    If NOT D Then MausZeigen;
End;
{**************************************************************}
Procedure IniSpacedWrite(X, Y: integer; Texts: String; t: byte);
Var fcolor, bkcolor: byte;
    fills: fillsettingstype;
    X1, X2, Y1, Y2: Integer;
    d: Boolean;
Begin
    d := IstDunkel;
    If NOT d Then Mausdunkel;
    X1 := X - 2;
    X2 := X + Length (Texts) * CharWidth;
    Y1 := Y - (Char2Height + 1) - 1;{+2 w�re besser, clear funktioniert dann aber noch nicht richtig}
    Y2 := Y + Char2Height + 1;
    If t = frNoFrame Then
    Begin
        inc (x1, 2);
        inc (Y1);
        dec (y2);
    End;
    fcolor := GetColor;
    bkcolor := GetBkColor;
    GetFillSettings (fills);
    {Zeichne Linienbalken}
    SetColor (imenubkcolor);
    SetFillStyle (1, imenubkcolor);
    Bar (X1, Y1, X2, Y2);
    If (t AND (NOT frdel3d) = frhigh) Then
        Ini3DFrame (X1, Y1, X2, Y2, 12, 5, t)
    Else
        Ini3DFrame (X1, Y1, X2, Y2, framebkcolor, framecolor, t);
    TxtFnt.Write (X, Y, Texts, imenutextcolor, sz8x8, stnormal);
    SetColor (fcolor);
    SetBkColor (bkcolor);
    SetFillStyle (1, fills.color);
    If NOT d Then MausZeigen;
End;
{**************************************************************}
Procedure IniInversText(X, Y: integer; Texts: String; t: Byte);
Begin
    IniGraphXY (x, y);
    IniInversWrite (x, y, texts, t);
End;
{**************************************************************}
Procedure IniSpacedText(X, Y: integer; Texts: String; t: byte);
Begin
    IniGraphXY (x, y);
    IniSpacedWrite (x, y, texts, t);
End;
{**************************************************************}
Procedure IniClearLine(X, Y: integer; cllength: integer; BColor: byte);
Var xmax: integer;

Begin
    SetFillStyle (solidfill, bcolor);
    x := x * charwidth - 9;
    y := y * charheight + 3;
    xmax := X + cllength * charwidth + 5;
    If xmax > GetMaxX Then xmax := GetMaxX;
    Bar (x, y - char2height, xmax, Y + Char2Height + 5);
End;
{**************************************************************}
Procedure IniClearSpacedLine(X, Y: integer; cllength: integer; BColor: byte);
Var xmax: integer;
Begin
    SetFillStyle (solidfill, bcolor);
    x := x * charwidth - 9;
    y := y * charheight + 3;
    xmax := X + cllength * charwidth + 5;
    If xmax > GetMaxX Then xmax := GetMaxX;
    Bar (x, y - char2height, xmax, Y + Char2Height + 2);
End;
{**************************************************************}
Function IniYBottomMargin: integer;
Begin
    IniYBottomMargin := (Pagelength + 1) * linethick;
End;
{**************************************************************}
Function IniFirstBeatPos(lineattr: lineattrtype): integer;
Begin
    IniFirstBeatPos := GMaxX - GcuRightMargin - lineattr.resolution;
End;
{**************************************************************}
Function IniRDxValue(lineattr: lineattrtype): real;
Begin
    If lineattr.beats = 0 Then
        inirdxvalue := 0
    Else
        InirDxValue := (GetMaxX - GcuRightMargin - IniFirstBeatPos (lineattr)) / (lineattr.beats);
End;
Function IniDxValue(lineattr: lineattrtype): integer;
Begin
    If lineattr.beats = 0 Then
        inidxvalue := 0
    Else
        IniDxValue := (GetMaxX {+ 1} - GcuRightMargin - IniFirstBeatPos (lineattr))
            DIV (lineattr.beats);
End;
{**************************************************************}
Function IniNumChar(c: char): Boolean;
    {True wenn c zwischen 0 und 9 liegt}
Begin
    IniNumChar := ((c >= '0') AND (c <= '9'));
End;
{**************************************************************}
Function IniArrow(c: char): Boolean;
    {True wenn c = < oder > ist}
Begin
    IniArrow := ((c = '>') OR (c = '<'));
End;
{**************************************************************}
Function IniDoppel(c: char): Boolean;
    {True wenn c = : ist}
Begin
    IniDoppel := (c = ':');
End;
{**************************************************************}
Function IniPrintChar(c: char): Boolean;
Var V: Byte Absolute C;
    {True wenn c zwischen blank und z liegt oder ein Umlaut ist}
Begin
    IniPrintChar := (((c >= ' ') AND (c <= 'z')) OR
        (v = 040) OR
        (v = 041) OR
        (v = 092) OR
        (v = 123) OR
        (v = 125) OR

        (v = 132) OR
        (v = 142) OR
        (v = 133) OR
        (v = 160) OR
        (v = 131) OR
        (v = 134) OR
        (v = 143) OR
(*
                  (v = 204) or
                  (v = 205) or
                  (v = 255) or
*)
        (v = 130) OR
        (v = 144) OR
        (v = 138) OR
        (v = 136) OR
        (v = 137) OR
        (v = 139) OR
        (v = 161) OR
        (v = 141) OR
        (v = 140) OR
        (v = 152) OR

        (v = 148) OR
        (v = 153) OR
        (v = 162) OR
        (v = 149) OR
        (v = 147) OR

        (v = 129) OR
        (v = 154) OR
        (v = 163) OR
        (v = 151) OR
        (v = 150) OR

        (v = 126) OR
        (v = 164) OR
        (v = 165) OR

        (v = 168) OR
        (v = 173) OR
        (v = 174) OR
        (v = 175) OR

        (v = 135) OR
        (v = 128) OR

        (v = 225) OR

        (v = 179) OR
        (v = 196) OR
        (v = 221) OR
        {(v = XXX) or }

        (v = 248) OR
        (v = 21));

End;
{**************************************************************}
Function IniPrintNote(c: char): Boolean;
    {True wenn c ein als Note druckbares Zeichen, ausser 0...9 ist}
Begin
    IniPrintNote := ((c IN spec)
        OR ((c >= 'A') AND (c <= 'Z'))
        OR ((c >= 'a') AND (c <= 'z'))
        OR ((c >= #128) AND (c <= #153)));
End;
{**************************************************************}
Function IniNextnumber(Var strbuf: stringline): integer;
{Liest einen integer aus dem Buffer und gibt ihn als Funktionswert zur�ck.
 Der String selbst wird im Buffer gel�scht.}
Var numstring: string[20];
    i, codei:  integer;
Begin
    {L�sche leading blanks}
    numstring := '';
    While (length (strbuf) > 0) AND (strbuf[1] = ' ') Do
        delete (strbuf, 1, 1);
    {Lese bis zum ersten nichtnumerischen Zeichen}
    While (length (strbuf) > 0) AND IniNumChar (strbuf[1]) Do
    Begin
        numstring := numstring + strbuf[1];
        delete (strbuf, 1, 1);
    End;
    {Wandle den String in einen Integer um}
    If numstring <> '' Then
    Begin
        Val (numstring, i, codei);
        If codei <> 0 Then
            i := 0;
        IniNextNumber := i;
    End Else IniNextNumber := 0;
End;
{**************************************************************}
Procedure IniNewPage(Var linenum: integer);
{Neue Seite initialisieren}
Var i: integer;
Begin
    ClearViewPort;
    For i := 1 To PageLim Do page[i] := 'T';
End;
{**************************************************************}
Function IniYnow(linenum: integer): integer;
Begin
    If linenum < pagelim Then IniYnow := linenum * linethick Else IniYNow := (pagelength DIV 2) * linethick{linenum = pagelim bedeutet, dass eine Zeile in der Mitte der Seite editiert wird};
    If linenum = 0 Then
        IniYnow := yzeropos;
End;
{**************************************************************}
Function IniMaxHeader: integer;
Begin
    IniMaxHeader := pagelength DIV 2 - 1;
End;
{**************************************************************}
Function IniHeaderFooterLine(linenum: integer): boolean;
Begin
    If ((linenum >= topmargin) AND
        (linenum <= pagelength) AND
        (length (page[linenum]) >= 4) AND
        (page[linenum, 4] = 'F')) Then IniHeaderFooterLine := true Else IniHeaderFooterLine := false;
End;
{**************************************************************}
Function IniHeaderEnd: integer;
Var i: byte;
Begin
    i := topmargin;
    While (IniHeaderFooterLine (i)) Do
        i := i + 1;
    IniHeaderEnd := i;
End;
{**************************************************************}
Function IniMinFooter: integer;
Begin
    IniMinFooter := pagelength DIV 2 + 1;
End;
{**************************************************************}
Function IniFooterEnd: integer;
Var i: byte;
Begin
    i := pagelength;
    While (IniHeaderFooterLine (i)) Do
        dec (i);
    IniFooterEnd := i;
End;
{**************************************************************}
Function IniLnow(ynow: integer): integer;
Begin
    IniLnow := ynow DIV linethick;
End;
{**************************************************************}
Procedure InitScreen;
Var i: integer;
Begin
    gmaxx := GetMaxX;
    gmaxy := GetMaxY;
    TopMargin := 1;
    PageLength := 52;
    LineThick := gmaxy DIV (pagelength + 5);
    line2thick := linethick DIV 2;
    PageCount := 1;
    CharWidth := TextWidth ('W');
    CharHeight := TextHeight ('$_');
    Char2Width := CharWidth DIV 2;
    Char2Height := CharHeight DIV 2;
    Chr4Width := CharWidth DIV 4;
    Chr8Width := CharWidth DIV 8;
    For i := 1 To pagelength Do page[i] := '';
    TextMargin := IniLeftMargin;
    GrMinx := IniLeftMargin;
    GrMaxx := gmaxx - gcurightmargin + drightmargin;
    GrMaxY := IniYBottomMargin;
    GrMinY := 0;
    hfminx := GrMinx DIV charwidth + 2;
    hfmaxx := GrMaxX DIV charheight;
    hfminy := 0;
    hfmaxy := GrMaxY DIV charheight;
    lastentry := invalid;
    arrowentry := noarr;
    {   actedit:= [];}
    symboldx := 12;
    symboldy := 12;
    stabxmin := 4;
    stabymin := 7;
    stabxmax := 635;
    stabymax := GmaxY - 3;
    sxmin  := stabxmin DIV charwidth + 1;
    sxmax  := stabxmax DIV charwidth;
    symin  := stabymin DIV charheight;
    symax  := stabymax DIV charheight;
    searchstring := '';
    {   actfilename:= '';}
    inbuffer := '';
    printeron := false;
    delpage := false;
    delln  := 'T          ';
    showmenus := false;
End;
{**************************************************************}
Procedure IniRefInit;
{Initialisierung der refreshparameter}
Begin
    refxmin := GMaxX;
    refxmax := 0;
    refymin := GMaxY;
    refymax := 0;
End;
{**************************************************************}
Procedure IniGetSymbols;
Var res: SmallInt;
    symfile: File;
    parfile: File;
Begin
    assign (symfile, 'symbols.sym');
    reset (symfile, 2);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot open symbols.sym file');
        WriteLn ('Make sure the file exists in the current directory.');
        RunError (127);
    End;
    BlockRead (symfile, SymArr, 26 * 15 * 3, res);
    close (symfile);

    assign (parfile, 'symbols.par');
    reset (parfile, 2);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot open symbols.par file');
        WriteLn ('Make sure the file exists in the current directory.');
        RunError (127);
    End;
    BlockRead (parfile, SymPar, 26 * numofpar * 3, res);
    close (parfile);
End;

{**************************************************************}
Function IniEmptyLine(inblock: stringline): boolean;
Begin
    IniTrailBlank (inblock);
    IniEmptyLine := ((inblock = '') OR
        ((inblock[1] <> 'N')
        AND (length (inblock) <= linemarker)));
End;
{**************************************************************}
Procedure IniClrCharField(x, y: integer);
Begin
    {L�sche ein Feld von Charactergroesse}
    If x < textmargin + 2 Then x := textmargin + 2;
    If x > 640 Then
        exit;
    If x > 638 - charwidth Then
        X := 638 - charwidth;
    setviewport (x, y - 6, x + 8, y + 4, true);
    setbkcolor (bkcolor);
    clearviewport;
    setviewport (0, 0, GetMaxX, GetMaxY, true);
End;
{**************************************************************}
Procedure IniSetViewPort(x1, y1, x2, y2: integer);
Begin
    If x1 < 0 Then x1 := 0;
    If y1 < 0 Then y1 := 0;
    If x2 > GMaxX Then x2 := GMaxX;
    If y2 > GMaxY Then y2 := GMaxY;
    SetViewPort (x1, y1, x2, y2, true);
End;
{**************************************************************}
Procedure IniCharAdd(Var TargetString: stringline; C: Char;
    PosInString: integer);
{F�gt den Character C in TargetString auf Position PosInString ein,
 wobei wenn n�tig Blanks hinzugef�gt werden}
Var i: integer;
    ActLength: integer;
Begin
    If PosInString <= StLength Then
    Begin
        ActLength := Length (TargetString);
        If ActLength < PosInString Then
            For i := ActLength + 1 To PosInString Do
                TargetString := TargetString + ' ';
        TargetString[PosInString] := C;
    End;
End;
{**************************************************************}
Procedure IniIniColors;
Var infile: text;
Begin
    Assign (infile, 'colors.rns');
    reset (infile);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot open colors.rns file');
        WriteLn ('Make sure the file exists in the current directory.');
        RunError (127);
    End;
    readln (infile, bkcolor);
    readln (infile, lcolor);
    readln (infile, ibkcolor);
    readln (infile, ilcolor);
    readln (infile, curcolor);
    readln (infile, gridcolor);
    readln (infile, menutextcolor);
    readln (infile, menubkcolor);
    readln (infile, imenutextcolor);
    readln (infile, imenubkcolor);
    readln (infile, bottomcolor);
    readln (infile, speccolor);
    readln (infile, helplinecolor);
    readln (infile, tmtext);
    readln (infile, tmbk);
    readln (infile, itmtext);
    readln (infile, itmbk);
    readln (infile, alarmcolor);
    readln (infile, alarmbkcolor);
    readln (infile, soundcolor);
    readln (infile, symtabcolor);
    readln (infile, symtabbkcolor);
    readln (infile, symsymbolscolor);
    readln (infile, menuframecolor);
    readln (infile, mausmtcolor);
    readln (infile, mausmbkcolor);
    readln (infile, FrameColor);
    readln (infile, FrameBkColor);
    If IOResult <> 0 Then
    Begin
        close (infile);
        WriteLn ('Error: Cannot read color data from colors.rns file');
        WriteLn ('File may be corrupted or incomplete.');
        RunError (127);
    End;
    close (infile);
End;
{**************************************************************}
Procedure IniIniSymbols;
Begin
    If NOT IniFileExist (fontfile) Then
        FilFindeErstBestenFont (fontfile);
    FilCopyFile (fontfile, 'symbols.prn');
    FilCopyFile (ChangeFileExt (fontfile, '.sym'), 'symbols.sym');
    FilCopyFile (ChangeFileExt (fontfile, '.par'), 'symbols.par');
    IniGetSymbols;
End;
{**************************************************************}
Procedure IniHideColors;
Begin
    lcolor := bkcolor;
    ibkcolor := bkcolor;
    ilcolor := bkcolor;
    curcolor := bkcolor;
    gridcolor := bkcolor;
    speccolor := bkcolor;
    helplinecolor := bkcolor;
    SetBkColor (bkcolor);
    SetColor (bkcolor);
End;
{*************************************************************************}
Procedure IniSwapFrame;
Var
    temp: Byte;
Begin
    temp := FrameColor;
    FrameColor := FrameBkColor;
    FrameBkColor := temp;
End;
{*************************************************************************}
Const OldMenuBkColor: Byte = 7;
    OldFrameColor: Byte = 5;
    OldIMenuTextColor: Byte = 5;
    OldIMenuBkColor: Byte = 1;
    OldMenuTextColor: Byte = 12;
Procedure IniSwapMenuColors;
Var
    temp: Byte;
Begin
    // Swap MenuBkColor with OldMenuBkColor
    temp := MenuBkColor;
    MenuBkColor := OldMenuBkColor;
    OldMenuBkColor := temp;

    // Swap MenuTextColor with OldMenuTextColor
    temp := MenuTextColor;
    MenuTextColor := OldMenuTextColor;
    OldMenuTextColor := temp;

    // Swap FrameColor with OldFrameColor
    temp := FrameColor;
    FrameColor := OldFrameColor;
    OldFrameColor := temp;

    // Swap IMenuTextColor with OldIMenuTextColor
    temp := IMenuTextColor;
    IMenuTextColor := OldIMenuTextColor;
    OldIMenuTextColor := temp;

    // Swap IMenuBkColor with OldIMenuBkColor
    temp := IMenuBkColor;
    IMenuBkColor := OldIMenuBkColor;
    OldIMenuBkColor := temp;
End;
{*************************************************************************}
Procedure ISwap(Var a, b: INTEGER);
Var
    temp: INTEGER;
Begin
    temp := a;
    a := b;
    b := temp;
End;
{*************************************************************************}
Procedure WSwap(Var a, b: WORD);
Var
    temp: Word;
Begin
    temp := a;
    a := b;
    b := temp;
End;
{*************************************************************************}
Procedure BSwap(Var a, b: BYTE);
Var
    temp: Byte;
Begin
    temp := a;
    a := b;
    b := temp;
End;
{*************************************************************************}
Procedure Ini3DFrame(X0, Y0, X1, Y1: Word; F, B: Byte; t: byte);
{ Rahmen: X0,Y0/X1,Y1, F,B : Colors, t: frxxxx }
Var SC: Byte;
    i:  byte;
Begin
    sc := getcolor;
    If (t AND frdel3D) = frdel3d Then
    Begin
        t := t AND NOT frdel3d;
        setcolor (7);
        Line (X0 - 2, Y0 - 2, X1 + 2, Y0 - 2);
        Line (X0 - 2, Y0 - 1, X0 - 2, Y1 + 2);
        Line (X0 - 1, Y1 + 2, X1 + 2, Y1 + 2);
        Line (X1 + 2, Y0 - 1, X1 + 2, Y1 + 1);
    End;
    Case t Of
        frNoFrame: ;
        frHigh, frLow:
        Begin
            If t = frHigh Then
                BSwap (F, B);
            For i := 1 To FrameWidth{-1} Do
            Begin
                SetColor (F);
                Line (x0 - i, Y0 - i, X1 + i, Y0 - i);{OL-OR}
                Line (x0 - i, Y0 - i + 1, X0 - i, Y1 + i);{OL-UL}
                Setcolor (B);
                Line (x0 - i + 1, Y1 + i, X1 + i, Y1 + i);{UL-UR}
                Line (x1 + i, Y0 - i + 1, X1 + i, Y1 + i - 1);{OR-UR}
            End;
        End;{case t of 0 }
        fr3D:
        Begin
            SetColor (12);{black}
            Line (X0 - 1, Y0 - 2, X1 + 1, Y0 - 2);{S:OL-OR}
            Line (x0 - 2, Y0 - 1, X0 - 2, Y1 + 1);{S:OL-UL}
            Line (x0 - 1, Y1 + 2, X1 + 1, Y1 + 2);{S:UL-UR}
            Line (x1 + 2, Y0 - 1, X1 + 2, Y1 + 1);{S:OR-UR}

            SetColor (8);{gray}
            Line (X0 - 1, Y1 + 1, X1 + 1, Y1 + 1);{G:UL-UR}
            Line (X1 + 1, Y0, X1 + 1, Y1);{G:OR-UR}

            SetColor (5);{white}
            Line (X0 - 1, Y0 - 1, X1 + 1, Y0 - 1);{W:OL-OR}
            Line (X0 - 1, Y0, X0 - 1, Y1);{W:OL-UL}
        End;
        frL3D:
        Begin
            SetColor (12);{black}
            Line (X0 - 1, Y0 - 21, X1, Y0 - 21);{S:OL-OR}
            Line (x0 - 2, Y0 - 20, X0 - 2, Y1 + 20);{S:OL-UL}
            Line (x0 - 1, Y1 + 21, X1, Y1 + 21);{S:UL-UR}
            Line (x1 + 1, Y0 - 20, X1 + 1, Y1 + 20);{S:OR-UR}

            SetColor (8);{gray}
            Line (X0 - 1, Y1 + 20, X1, Y1 + 20);{G:UL-UR}
            Line (X1, Y0 - 19, X1, Y1 + 20);{G:OR-UR}

            SetColor (5);{white}
            Line (X0 - 1, Y0 - 20, X1 - 1, Y0 - 20);{W:OL-OR}
            Line (X0 - 1, Y0 - 20, X0 - 1, Y1 + 19);{W:OL-UL}
        End;
    End;{ case t}
    SetColor (SC);
End;
{*************************************************************************}
Function IniLineEnd(inblock: String): Integer;
Var lineattr: lineattrtype;
Begin
    If Inblock[1] <> 'N' Then
    Begin
        IniLineEnd := 0;
        exit;
    End;
    GetNoteAttributes (stringline (inblock), lineattr);
    With lineattr Do
        IniLineEnd := grmaxx - (resolution MOD beats);
End;
{*************************************************************************}
Procedure IniLineEndSound(Level: Byte);
Var a: Byte;
Begin
    delay (50);
    Case level Of
        0: For a := 0 To 2 Do
            Begin
                sound (880);
                delay (100);
                nosound;
                delay (100);
            End;{case level of 0}
        1: For a := 0 To 4 Do
            Begin
                sound (880);
                delay (50);
                nosound;
                delay (50);
            End;{case level of 1}
    Else;{case level else}
    End;{case level}
End;
{*************************************************************************}
Procedure IniInitPalette;
Var a: Byte;
Begin
    SetPalette (12, 0);             { Color 12=PalReg[0]                    }
    SetPalette (13, 15);            { Color 13=PalReg[15]                   }
    IniSetDACReg (60, 0, 0, 0);       { light red ->Schwarz                   }
    IniSetDACReg (5, 63, 63, 63);     { magenta   ->Weiss  }
    IniSetDACReg (63, 10, 10, 10);    { Weiss     ->Grau   Mausfarbe!!!       }
    {  SetRGBPalette}
    // TODO: Modern palette initialization
    // Original: Read VGA DAC palette into ThePalette array
    // Initialize ThePalette with default values for now
    For a := 0 To $FF Do
    Begin
        PalSteps[a].R := ThePalette[a].R / 128;
        PalSteps[a].G := ThePalette[a].G / 128;
        PalSteps[a].B := ThePalette[a].B / 128;
    End;
End;
Procedure IniSetDACReg(n, r, g, b: byte);
Begin
    // TODO: Set single palette register with modern graphics API
    // Original: Set VGA DAC register n to RGB values r,g,b
End;
Procedure IniSetAllDACRegs(aPalette: TDACTable);
Begin
    // TODO: Set complete palette with modern graphics API
    // Original: Set all 256 VGA DAC registers from aPalette array
End;

Procedure IniFadeOut;
Var a, b: byte;
    ActPalette: TDACTable;
Begin
    ActPalette := ThePalette;
    For b := 0 To $3F Do
        For a := 0 To $FF Do
            With ActPalette[a] Do
            Begin
                If r > 0 Then dec (r);
                If g > 0 Then dec (g);
                If b > 0 Then dec (b);
                IniSetDACReg (a, R, G, B);
            End;
End;
Procedure IniPalBlank(r, g, b: byte);
Var ActPalette: TDACTable;
    a: byte;
Begin
    For a := 0 To $FF Do
    Begin
        ActPalette[a].r := r;
        ActPalette[a].g := g;
        ActPalette[a].b := b;
    End;
    IniSetAllDACRegs (actpalette);
End;
Procedure IniFadeIn;
Var a, b: byte;
    ActPalette: TDACTable;
    RealPalette: TRealDAC;
Begin
    FillChar (actpalette, sizeof (actpalette), 0);
    For a := 0 To $FF Do
    Begin
        realpalette[a].r := 0;
        realpalette[a].b := 0;
        realpalette[a].g := 0;
    End;
    For b := 0 To $7E Do
        For a := 0 To $FF Do
            With ActPalette[a] Do
            Begin
                realpalette[a].r := realpalette[a].r + palsteps[a].r;
                realpalette[a].g := realpalette[a].r + palsteps[a].g;
                realpalette[a].b := realpalette[a].r + palsteps[a].b;
                r := round (realpalette[a].r);
                g := round (realpalette[a].g);
                b := round (realpalette[a].b);
                IniSetDACReg (a, R, G, B);
            End;
    IniSetAllDACRegs (ThePalette);
End;

Procedure IniDrawSoundState;
    Procedure DrawTriStateChar(n: integer; c: char; b: byte);
    Begin
        Case b Of
            1: TxtFnt.WriteChar (394 + n * 8, 438, c, ImenuTextColor, sz8x8, stnormal);
            2: TxtFnt.WriteChar (394 + n * 8, 438, c, AlarmColor, sz8x8, stnormal);
            3: TxtFnt.WriteChar (394 + n * 8, 438, c, AlarmBkColor, sz8x8, stnormal);
        End;
    End;

    Procedure DrawStateChar(n: integer; c: char; b: boolean);
    Begin
        If b Then
            TxtFnt.WriteChar (394 + n * 8, 438, c, ImenuTextColor, sz8x8, stnormal)
        Else
            TxtFnt.WriteChar (394 + n * 8, 438, c, AlarmColor, sz8x8, stnormal);
    End;

Begin
    (* 'BPTSLMR ([{�' *)
    DrawTriStateChar (01, 'B', SndPlayBeat);
    DrawStateChar (02, 'P', (SndPlayPulse AND plspace) = 0);
    DrawTriStatechar (03, 'T', (SndPlayPulse AND plPulse) + 1);
    DrawStateChar (04, 'S', (soundattr AND saStaccato) = 0);
    DrawStateChar (05, 'L', (soundattr AND saLegato) = 0);
    DrawStateChar (06, 'M', (soundchange AND saMuffled) = 0);
    DrawStateChar (07, 'R', (soundchange AND saRhythm) = 0);
    DrawStateChar (09, '(', (PlayOptions AND poParentheses) = 0);
    DrawStateChar (10, '[', (PlayOptions AND poBrackets) = 0);
    DrawStateChar (11, '{', (PlayOptions AND poBraces) = 0);
    DrawStateChar (12, Chr (167), (PlayOptions AND poDashSlash) = 0);
End;

Begin
    IniHideCursor;
    symbcount := 0;
    addcent := 0;
    mulcent := 1;
    LastSound := 0;
    FrameWidth := 1;
    FileChanged := 0;
    TTextFontViewer (TxtFnt).Init ('rns');
    sndwarning := 1;
    pagebuf := -1;
    lastbuf := -1;
    playOptions := 0;
    logo := new (pbmp16, load (logoname));
End.
