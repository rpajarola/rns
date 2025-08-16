{$I RNS.H}
unit InitSc;
interface

uses
     graph,
     menutyp,
     inout,
     dos,
     xcrt,
     crt,
     UserExit,
     TextFont,
     loadbmp;

const
      versionstring = '004';
      exts = '.cfg';

      LineMarker = 9;
      {1: N=Notenlinie T=Textlinie

       3: P= Setup Page
       4: F= Header/Footer
       5: H=Hidden Line}

      StLength = 245;
      ClearAreaX = 10;
      PageLim = 56;

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

      spec: set of char = [' ','/','.',',','\','�','&','"'];
      flamset: set of char = ['+', '=', '-', '*'];
      klammerset : set of char = ['(',')','[',']','{','}'];
      sndmaxspm = 600;

      HintNormalTime = 750;
      HintWaitEsc    = 0;
      HintNoRestore  = -1;

      hpEdit         = 0;       { Hint position }
      hpUp           = 1;
      hpFileMenu     = 2;

      notes : Set of char =
['a'..'z', 'A'..'Z', #128..#153,'/','�','\','.',' ',',','+','=','-','*'];{"?}
      numbers : set of char = ['0'..'9'];
      sz8x8  =  0;    { Sizes }
      sz8x16 =  1;
      sz6x12 =  2;
      stNormal     = $00;
      stBold       = $01;
      stDouble     = $02;
      stItalic     = $04;
      stUndeline   = $08;
      stHigh       = $10;
      stLow        = $20;
      stSpaced     = $40;

      frNoFrame    = $00;       { kein Rahmen                   }
      frHigh       = $01;       { herausstehend                 }
      frLow        = $02;       { versenkt                      }
      fr3D         = $03;       { 3D Rahmen (Hallo Windows)     }
      frL3D        = $04;       { 3D Rahmen (Platten-Effekt)    }
      frDel3D      = $80;       { l�scht den 3D Rahmen          }
      frNoBar      = $40;       { zeichnet keinen Balken        }
      frSmallBar   = $20;       { zeichnet einen kleineren Balk.}

      plPulse      = $03;       { Spielt ','                     }
      plSpace      = $04;       { Spielt ' '                     }
      plEt         = $08;       { Spielt '&'                     }

      plPulseNever = $00;       { Spielt ',' nie                 }
      plPulseNoLeg = $01;       { Spielt ',' falls kein Legato   }
      plPulseAlways= $02;       { Spielt ',' immer               }

      poParentheses = $01;      { spielt () nicht                }
      poBrackets    = $02;      { spielt []                      }
      poBraces      = $04;      (*spielt {} variante 2          *)
      poDashSlash   = $08;      { ignoriert �                    }

      saLegato      = $01;      { spielt die T�ne legato         }
      saStaccato    = $02;      { spielt die T�ne staccato       }
(*    saInterval    = $??;      { spielt alle Intervalle, z�hlt  } *)
(*    saPitches     = $??;      { spielt die vorhandenen T�ne    }
                                { aufsteigend ohne Wiederholungen) *)
      saRhythm      = $08;      { spielt rhythmisches Skelett    }
(*    saYFreq       = $??;      { spielt Melodie ohne Rhythmus   } *)
                                {hexadez: 01,02,04,08,10,20,40,80,100}
      saMuffled     = $04;      { spielt ged�mpft/sehr kurz      }
      saPhrased     = $10;      { spielt phrasiert ab}


      PlayBeatNever = 1;
      PlayBeatAlways= 2;
      PlayBeatEmpty = 3;

      staccatolength= 50;
      legatolength  = 30000;    { damit richtig legato gespielt wird }
      RhythmFreq    = 392;      { spielt Rhythmus mit 392 Hz         }
      muffledlength = 5;        { spielt T�ne leise/sehr kurz        }
      phrasedmul1   = 2;        { Abstandsmultiplikator: phrasiert   }

      logoname = 'TITLE.BMP';

      keyswap : array[0..2,0..2] of char = { ' ' ',' '.' }
      (('.',' ',','),
       (' ',',','.'),
       (',',' ','.'));

type stringline = string[255];
     string4 = string[80];
     KeyEntry = (invalid, one, numeric, character, curupdown, plus,
                 postplus, other);
     ArrowTyp = (noarr, leftarr, rightarr);
     Editvariants = (setuppage, defsetuppage, linestyles);

     {bitmap: Buchstabe, Zeile (1 word pro zeile), Normal/Ctrl/Alt/}
     SymArrTyp = array['a'..'z',1..15,1..3] of word;
     { Symparameter: Buchstabe,?,nor,ctrl,alt}
     SymParamTyp = array['a'..'z', 1..numofpar, 1..3] of integer;
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

     linerec = record
        datblock : stringline;
        next : listptr;
        last : listptr;
     end;

     lineattrtype = record
        beats : integer;
        eint : integer;
        resolution : integer;
        linestyle: byte; {1=thick,2=pitch,3=thin,4=dotted,5=helpline}
     end;

     markdescrtyp = record
        mline : integer;
        mpos : integer;
        mpag : integer;
        mxcoord : integer;
     end;

     TRGB = Record
       R,G,B : Byte;
     End;
     TDACTable = Array[0..$FF] Of TRGB;
     TRealRGB = Record
       R,G,B : Real;
     end;
     TRealDAC = Array[0..$FF] of TRealRGB;
     TCharSet = Set Of Char;
var ThePalette : TDACTable;
    PalSteps   : TRealDAC;
    symbcount : byte;   {das wievielte Zeichen wird angezeigt(f�r pagshowcurposistances}
    infile, debfile : text;
    GraphDriver : integer;
    GraphMode : integer;
    ErrCode : integer;
    HercGraphicsMode : Boolean;
    HercGraphicsPage : Byte absolute $0000:$0199;
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
    symtabbkcolor:byte;
    symsymbolscolor: byte;
    mausmtcolor, mausmbkcolor: byte;
    FrameColor,FrameBkColor : Byte;
    PageLength : integer;
    LineThick, line2thick : integer;
    TopMargin : integer;
    PageCount : integer;
    Pagesav: integer;   {Letzte Seitennummer vor Eintritt in Setup page}
    CharWidth, CharHeight : integer;
    Char2Width, Char2Height : integer;  {Halbe Zeichenbreite, Hoehe}
    Chr4Width : integer;
    Chr8Width : integer;
    Page : Array[0..PageLim] of stringline;
    actfilename: stringline;
    insmusicline: stringline;
    TextMargin : integer;
    SymCount : integer;
    ActNumber : integer;
    LastEntry : KeyEntry;
    Lastchar: char;
    ArrowEntry : ArrowTyp;
    SymArr : SymArrTyp;
    SymPar : SymParamTyp;
    actattr: lineattrtype;

    dispspec: byte; {2 = off, 1 = on}
    dispgrid: byte;
    dispsound: byte; {2 = off, 1 = play while editing}
    disphidlines: byte;
    dispslash : byte;
    charset: byte; {1 = normaler set, 2 = <alt> , normal, shift}
    blankset: byte; {1 = blank ist Leertaste, 2 = blank ist Komma}
    manset: byte; {1 = normal, 2 = alle Zeichen addieren}
    delln,saveln: stringline;
    delpage: boolean; {true, falls zuletzt eine Seite geloescht wurde}
    copypage: boolean;{" " " Seite kopiert}
    linecount: integer;
    yzeropos: integer;

    buffile : text;

    gmaxx, gmaxy: integer;

    GrMinX, GrMaxX, GrMinY, GrMaxY: integer;
    UsrMenu, Symbolmenu1, Symbolmenu2 : Menu_Rec;
    togglestring: toggletyp;
    hfminx, hfminy, hfmaxx, hfmaxy: integer;
    TOP_Line, Left_Col, Valcol : integer;
    stabxmin, stabxmax, stabymin, stabymax: integer;
    sxmin, sxmax, symin, symax: integer;
    datadir, fontfile, colorfile: string16;

    searchstring: stringline;
    searchtyp: char;
    replaceflag: boolean;
    replacestring: stringline;

    nextresponse : Response_Type; {Key im Keyboard-Buffer}
    nextkey : Char;
    nextshift, nextctrl: boolean;

    symboldx, symboldy : integer;
    mstart, mend : markdescrtyp;
    marpartline: boolean;

    actedit: set of editvariants;
    inbuffer: string16; {Buffer fuer eingegebene Zeichen}
    bufstartptr, bufactptr, bufendptr : listptr;
    refxmin, refxmax, refymin, refymax: integer;
    hintminx, hintminy, hintmaxx, hintmaxy : integer;

    printeron: boolean; {true, wenn postscriptfile geschrieben wird}

    prformat: byte; {1 = 1 page per sheet, 2 = 2 pages per sheet}
    prpage, prdest: integer;
    prfname: string16;
    prfile: integer; {1 wenn auf file geschrieben wird}
    prdevice: string16;

    paused:boolean;    {pause?}
    sndlength: integer; {l�nge pro beat}
    sndlengthspm : real;{new}{dasselbe f�r strokes/min}
    sndlengthper: byte; {Laenge pro beat oder Line}
    sndplaybeat: byte; {Beat spielen oder nicht}
    sndplaypulse: byte; {Puls spielen oder nicht}{ bit 0: ','; bit 1:' '}
    {Beath�he, L�nge, Pulsh�he, L�nge}
    sndbeat, sndbeatlength, sndpulse, sndpulselength: integer;
    sndchar: char;
    sndwarning:byte;
    PlaySuccess : Boolean;

    usrname, usrfirstname: stringline;

    showmenus: boolean;

    addcent       : integer;
    mulcent       : real;
    LastSound     : integer;
    HintS1,HintS2 : String[8];
    FrameWidth    : Byte;
    FileChanged   : Byte;
    CtrlEnterOfs  : Byte;
    TxtFnt        : TTextFontViewer;
    pagebuf       : integer;
    lastbuf       : integer;
    ctrlF5        : boolean;
    bufffile      : boolean;
    playoptions   : byte;(* () [] {} � / *)
    soundattr     : byte;
    soundchange   : byte;
    Logo          : pbmp16;
    SymFontSize   : Byte;
    psfile        : text;
    psdir,bufdir  : string79;
    ShowSlashes   : byte;
    nff           : boolean;

Procedure IniOutTextXY(X, Y : integer; Texts: String79);
Procedure IniWriteXY(X,Y : integer; Texts: String79);
Function IniAltChar(c : char) : char;
Procedure IniGetSymbols;
procedure InitScreen;
Function  IniYnow(linenum : integer) : integer;
Procedure IniNewPage(var linenum: integer);
Procedure IniClrCharField( x, y : integer);
Procedure IniCharAdd(var TargetString : Stringline; C : Char;
                     PosInString : integer);
Function IniNextnumber(var strbuf: stringline) : integer;
Function IniRDxValue(lineattr: lineattrtype) : real;
Function IniDxValue(lineattr: lineattrtype) : integer;
Function IniPrintChar(c: char) : Boolean;
Function IniPrintNote(c: char) : Boolean;
Function IniNumChar(c: char) : Boolean;
Function IniArrow(c: char) : Boolean;
Function IniDoppel(c: char) : Boolean;
Procedure IniGraphXY(var X, Y : integer);
Procedure IniInversWrite(X, Y : integer; Texts: String79;T : Byte);
Procedure IniSpacedWrite(X, Y : integer; Texts: String79;T : Byte);
Procedure IniInversText(X, Y : integer; Texts: String79;T : Byte);
Procedure IniSpacedText(X, Y : integer; Texts: String79;T : Byte);
Procedure IniClearLine(X, Y: integer; cllength: integer;
                       BColor : byte);
Procedure IniClearSpacedLine(X, Y: integer; cllength: integer;
                       BColor : byte);
Function IniLnow(ynow : integer) : integer;
Procedure IniSetViewPort(x1, y1, x2, y2 : integer);
Function IniEmptyLine( inblock : stringline): boolean;
Function IniLeftMargin : integer;
Procedure IniTrailBlank(var inblock: stringline);
Procedure IniLeadBlank(var inblock: stringline);
Function IniUserFontFile(instring: string79) : boolean;
Function IniFileExist(instring: string79) : boolean;
Function IniDirExist(instring: string79) : boolean;
Function IniBytes(x,y:integer):integer;
Procedure IniGraphMode;
Procedure IniRefInit;
Procedure IniGraphinit;
Procedure IniGraphClose;
Function IniFirstBeatPos(lineattr: lineattrtype) : integer;
Function IniYBottomMargin : integer;
Function IniPos(linenum, actposn, actpost: integer): integer;
Function IniMaxHeader : integer;
Function IniHeaderFooterLine(linenum: integer) : boolean;
Function IniMinFooter : integer;
Function IniHeaderEnd : integer;
Function IniFooterEnd : integer;
Procedure IniExpand(var instring: string79; newlength: byte);
Procedure IniCenter(Var instring : String;newlength: byte);
Function IniTabChar(c: char): boolean;
Procedure IniShowCursor;
Procedure IniHideCursor;
Procedure IniSwapColors;
Procedure IniIniColors;
Procedure IniHideColors;
Procedure IniIniSymbols;
Function IniKeyPressed: boolean;
Function IniMausEscape : char;
Procedure IniMausAssign(maustaste: word; var resp: response_type);
Procedure IniSwapFrame;
Procedure IniSwapMenuColors;
Procedure WSwap(Var a,b);
Function UpString(VAR Zeile : STRING) : String;
Procedure Ini3DFrame(X0,Y0,X1,Y1 : Word;F,B : Byte;t : byte);
Function IniLineEnd(inblock : String) : Integer;
Procedure IniLineEndSound(Level : Byte);
Procedure IniInitPalette;
Procedure IniFadeOut;
Procedure IniFadeIn;
Procedure IniSetDACReg(n,r,g,b : byte);
Procedure IniSetAllDACRegs(aPalette : TDACTable);
Procedure IniPalBlank(r,g,b : byte);
Procedure IniDrawSoundState;
implementation

uses gcurunit,
     mousdrv,
     fileunit,
     getunit,

{******************************************************}
Function UpString(VAR Zeile : STRING) : String;
(* Umwandlung eines Strings in Gro�buchstaben *)
VAR i : INTEGER;
BEGIN
  FOR i := 1 TO Length(Zeile) DO  Zeile[i] := UpCase(Zeile[i]);
  UpString:=Zeile;
END;
{******************************************************}
Function IniKeyPressed: boolean;
{wird true, wenn ein key gedr�ckt wurde, der den Bildaufbau
 abbricht}
const skipset:
      set of byte = [59, 60, 62, 67, 73, 81, 89, 118, 132];
var c: char;
    result: boolean;
    mausx, mausy, maustaste, mp, mausmenu: word;
begin
  if nextresponse = no_response then begin
    result:= false;
  end else begin
    result:= true;
  end;
  if ((nextresponse = no_response) and (xKeyPressed)) then begin
    c:= xreadkey(nextshift, nextctrl);
    if c = #27 then begin
      result:= true;
      nextresponse:= escape;
    end else begin
      if c = #0 then begin
        c:= xreadkey(nextshift, nextctrl);
        if byte(c) in skipset then begin
          result:= true;
          nextresponse:= specialkey;
          nextkey:= c;
        end;
      end;
    end;
  end;
  if nextresponse = no_response then begin
    MausPosition(mausx, mausy, maustaste, mp, mausmenu);
    if maustaste = 7 then begin
      result:= true;
      nextresponse:= escape;
    end;
  end;
  IniKeyPressed:= result;
end;
{****************************************************}
Procedure IniSwapColors;Assembler;
{Tauscht die Farben von Setuppage und standard aus}
Asm
  MOV AL,LColor
  XCHG AL,ILColor
  MOV LColor,AL
  MOV AL,BkColor
  XCHG AL,IBKColor
  MOV BkColor,AL
  CALL GcuIniCursor;
end;
{****************************************************}
Procedure IniCursor (Anfangszeile,Endzeile:byte);Assembler;
Asm
  MOV  CH,Anfangszeile
  MOV  CL,Endzeile
  MOV  AH,1
  INT  10h
End;
{****************************************************}
Procedure IniHideCursor;
begin
  IniCursor($ff, 0);
end;
{****************************************************}
Procedure IniShowCursor;
begin
end;
{******************************************************}
Procedure IniExpand(var instring: string79; newlength: byte);Assembler;
Asm
  CLD
  PUSH DS
  LDS SI,InString
  LES DI,InString
  LODSB
  MOV CL,NewLength
  CMP AL,CL
  JAE @001
  XOR CH,CH
  PUSH CX
  XCHG CL,AL
  PUSH CX
  STOSB
  REP MOVSB
  POP AX
  POP CX
  SUB CL,AL
  MOV AL,' '
  REP STOSB
@001:
  POP DS
end;
{******************************************************}
Procedure IniCenter(Var instring : String;newlength: byte);
Var a : Byte;
   st : String;
Begin
  IF newlength<byte(instring[0]) Then Begin
    instring[0]:=char(newlength);
    Exit;
  End;
  FillChar(St[1],Newlength,' ');
  Move(instring[1],st[(newlength-Byte(instring[0])) shr 1+1],Byte(instring[0]));
  st[0]:=char(newlength);
  instring:=st;
end;
{******************************************************}
Function IniTabChar(c: char): boolean;
begin
   IniTabChar:= ((c = chr(smallblankup)) or (c = chr(smallblankdown)));
end;
{******************************************************}
Function IniPos(linenum, actposn, actpost: integer): integer;
begin
  if page[linenum,1] = 'T' then begin
    IniPos:= actpost;
  end else begin
    IniPos:= actposn;
  end;
end;
{******************************************************}
Function IniMausEscape : char;
var c: char;
    mausx, mausy, maustaste, mp, mausmenu: word;
    temp1, temp2: boolean;
begin
  c:= ' ';
  maustaste:= 0;
  if XKeyPressed then begin
    c:= xReadKey(temp1, temp2);
    c:= UpCase(c);
  end else begin
    MausPosition(mausx, mausy, maustaste, mp, mausmenu);
    Case Maustaste Of
      2 : c:=#27;
      1 : c:=#13;
      else case mp of
        2 : c:=#27;
        1 : c:=#13;
      end;
    End;
  end;
  IniMausEscape:= c;
end;
{******************************************************}
Procedure IniMausAssign(maustaste: word; var resp: response_type);
{resp wird return bzw. escape, falls taste 1 bzw. 7 gedr�ckt wurde}
begin
  if maustaste = 1 then begin
    resp:= return;
  end else begin
    if maustaste = 2 then begin
      resp:= escape;
    end;
  end;
end;
{******************************************************}
Function IniAltChar(c : char) : char;
{Umwandeln eines Alt-Characters in den Bereich 128..153,
 wobei alphabetisch geordnet wird}
var str : string79;
begin
  str:= 'qwertyuiop    asdfghjkl     zxcvbnm';
  IniAltChar:= char(Byte(str[Byte(c) - 15]) + 31);
end;
{******************************************************}
Procedure IniGraphClose;
begin
  CloseGraph;
  HercGraphicsMode := false;
end;
{******************************************************}
Procedure IniGraphMode;
begin
  IF Not HercGraphicsMode Then Begin
    GraphDriver:=VGA;
    GraphMode:=VGAHi;
    InitGraph(GraphDriver, GraphMode, '');
    ErrCode:=GraphResult;
    If ErrCode <> grOk then begin
      writeln('Graphics error ',GraphErrorMsg(ErrCode));
      writeln('Program aborted');
      halt(1);
    end;
    HercGraphicsMode := true;
  End;
  SetTextJustify(LeftText, Ttyp);
  SetTextStyle(DefaultFont, HorizDir, 1);
end;
{******************************************************}
Procedure IniGraphinit;
begin
  asm
    mov  dx,3d4h
    xor  al,al
    out  dx,al
  end;
  IniGraphMode;
  InitScreen;
  GcuIniCursor;
  IniInitPalette;
  IniPalBlank(0,0,0);
  asm
    mov  dx,3d4h
    mov  al,20h
    out  dx,al
  end;
end;
{******************************************************}
Function IniBytes(x,y:integer):integer;
begin
  Inibytes := $2000 * (y mod 4) + 90 * (y shr 2) + (x shr 3)
end;
{******************************************************}
Function IniUserFontFile(instring: string79) : boolean;
{ testet, ob das File mit dem Namen instring ein User-File ist }
Var F : Text;
    SFM : Integer;
    St : String79;
begin
  Instring:=UpString(instring);
  IF Pos('.',Instring)<>0 Then
    Instring:=Copy(Instring,1,Pos('.',Instring)-1);
  Assign(F,'FONTS.RNS');
  LastFileName:='FONTS.RNS';
  SFM:=FileMode;
{$I-}
  ReSet(F);
{$I+}
  FileMode:=SFM;
  IF IOResult<>0 Then Begin
    IniUserFontFile:=True;
    Close(f);
    Exit;
  End;
  St:='';
  While Not (EoF(F) Or (St=Instring)) Do Begin
    ReadLn(F,St);
    St:=UpString(st);
    IF St=instring Then Begin
      IniUserFontFile:=False;
      Close(f);
      Exit;
    End;
  End;
  Close(f);
end;
{******************************************************}
Function IniFileExist(instring: string79) : boolean;
{ testet, ob unter dem Namen instring schon ein File auf dem Directory existiert }
Var FileInfo : SearchRec;
begin
  FindFirst(instring, AnyFile, FileInfo);
  IniFileExist:= (DosError=0);
end;

{******************************************************}
Function IniDirExist(instring: string79) : boolean;
{ testet, ob unter dem Namen instring schon ein Directory existiert }
var actdir : string;
begin
  GetDir(0,actdir);
  {$I-}
  ChDir(instring);
  {$I+}
  if IOResult = 0 then begin
    ChDir('..');
    IniDirExist:= true;
  end else begin
    IniDirExist:= false;
  end;
  ChDir(ActDir);
end;

{**************************************************************}
Procedure IniTrailBlank(var inblock: stringline);
var l : integer;
begin
  l:= length(inblock);
  while ((l > 0) and (inblock[l] = ' ')) do begin
    dec(byte(inblock[0]));
    dec(l);
  end;
end;
{**************************************************************}
Procedure IniLeadBlank(var inblock: stringline);
var l : integer;
begin
  while ((length(inblock) > 0) and (inblock[1] = ' ')) do begin
    delete(inblock, 1, 1);
  end;
end;
{**************************************************************}
Function IniLeftMargin : integer;
var margin : integer;
begin
  margin:= GetMaxX - 640;
  if margin < 0 then
    margin:= 0;
  IniLeftMargin:= margin;
end;
{**************************************************************}
Procedure IniOutTextXY(X, Y : integer; Texts: String79);
Var T : Boolean;
begin
  t:=IstDunkel;
  IF Not T Then Mausdunkel;
  if x<0 Then x:=0;
  if y<0 Then y:=0;
  IniGraphXY(x, y);
  TxtFnt.Write(X,Y,texts,getcolor,sz6x12,stnormal);
  IF Not T Then MausZeigen;
end;
{**************************************************************}
Procedure IniWriteXY(X,Y : integer; Texts: String79);
Var T : Boolean;
begin
  t:=IstDunkel;
  IF Not T Then Mausdunkel;
  if x<0 Then x:=0;
  if y<0 Then y:=0;
  TxtFnt.Write(X,Y,texts,getcolor,sz6x12,stnormal);
  IF Not T Then MausZeigen;
end;
{**************************************************************}
Procedure IniGraphXY(var X, Y : integer);
begin
  x:= x*charwidth - 6;
  y:= y*charheight + 6;
end;
{**************************************************************}
Procedure IniInversWrite(X, Y : integer; Texts: String79;t : byte);
var fcolor, bkcolor: byte;
    fills:  fillsettingstype;
    X1,X2,Y1,Y2 : Integer;
    i : Byte;
    D : Boolean;
begin
   D:=IstDunkel;
   IF Not D Then Mausdunkel;
   if (t and frSmallBar)=frSmallBar then begin
     t:=t and not frSmallBar;
     x1:= X;
     X2:= X+Length(Texts)*6;
     Y1:= Y-6;
     Y2:= Y+5;
   end else begin
     X1:= X-2;
     X2:= X+Length(Texts)*8;
     Y1:= Y-6;{-1 w�re besser, clear funktioniert dann aber noch nicht richtig}
     Y2:= Y+5;
   end;
   fcolor:= GetColor;
   bkcolor:= GetBkColor;
   GetFillSettings(fills);
   {Zeichne Linienbalken}
   SetColor(imenubkcolor);
   SetFillStyle(1,imenubkcolor);
   if t and frNoBar=0 then begin
     t:=t and not frNoBar;
     Bar(X1,Y1,X2,Y2);  {Beschriftungsbalken der (aktiven) Hauptmenu-Buttons}
   end;
   if (t and (not frdel3d)=frhigh) then
     Ini3DFrame(X1,Y1,X2,Y2,12,5,t)
   Else
     Ini3DFrame(X1,Y1,X2,Y2,framebkcolor,framecolor,t);
   TxtFnt.Write(X, Y, Texts,imenutextcolor,sz6x12,stnormal);
   SetColor(fcolor);
   SetBkColor(bkcolor);
   SetFillStyle(1, fills.color);
   IF Not D Then MausZeigen;
end;
{**************************************************************}
Procedure IniSpacedWrite(X, Y : integer; Texts: String79;t : byte);
var fcolor, bkcolor: byte;
    fills:  fillsettingstype;
    X1,X2,Y1,Y2 : Integer;
    i : Byte;
    d : Boolean;
begin
  d:=IstDunkel;
  IF Not d Then Mausdunkel;
  X1:= X-2;
  X2:= X+Length(Texts)*CharWidth;
  Y1:= Y-(Char2Height+1)-1;{+2 w�re besser, clear funktioniert dann aber noch nicht richtig}
  Y2:= Y+Char2Height+1;
  if t=frNoFrame then begin
    inc(x1,2);
    inc(Y1);
    dec(y2);
  end;
  fcolor:= GetColor;
  bkcolor:= GetBkColor;
  GetFillSettings(fills);
  {Zeichne Linienbalken}
  SetColor(imenubkcolor);
  SetFillStyle(1, imenubkcolor);
  Bar(X1, Y1, X2, Y2);
  if (t and (not frdel3d)=frhigh) then
    Ini3DFrame(X1,Y1,X2,Y2,12,5,t)
  Else
    Ini3DFrame(X1,Y1,X2,Y2,framebkcolor,framecolor,t);
  TxtFnt.Write(X, Y, Texts,imenutextcolor,sz8x8,stnormal);
  SetColor(fcolor);
  SetBkColor(bkcolor);
  SetFillStyle(1, fills.color);
  IF Not d Then MausZeigen;
End;
{**************************************************************}
Procedure IniInversText(X, Y : integer; Texts: String79;t : Byte);
begin
  IniGraphXY(x, y);
  IniInversWrite(x, y, texts,t);
end;
{**************************************************************}
Procedure IniSpacedText(X, Y : integer; Texts: String79;t : byte);
begin
  IniGraphXY(x, y);
  IniSpacedWrite(x, y, texts,t);
End;
{**************************************************************}
Procedure IniClearLine(X, Y: integer; cllength: integer;BColor : byte);
var i, xmax: integer;
    clears: string79;

begin
  SetFillStyle(solidfill, bcolor);
  x:= x*charwidth - 9;
  y:= y*charheight + 3;
  xmax:=X+cllength*charwidth+5;
  if xmax > GetMaxX then xmax:= GetMaxX;
  Bar(x, y - char2height, xmax,Y + Char2Height+5);
end;
{**************************************************************}
Procedure IniClearSpacedLine(X, Y: integer; cllength: integer;BColor : byte);
var xmax : integer;
begin
  SetFillStyle(solidfill, bcolor);
  x:= x*charwidth - 9;
  y:= y*charheight + 3;
  xmax:=X+cllength*charwidth+5;
  if xmax > GetMaxX then xmax:= GetMaxX;
  Bar(x, y - char2height, xmax,Y + Char2Height+2);
end;
{**************************************************************}
Function IniYBottomMargin : integer;
begin
  IniYBottomMargin:= (Pagelength + 1)*linethick;
End;
{**************************************************************}
Function IniFirstBeatPos(lineattr: lineattrtype) : integer;
begin
  IniFirstBeatPos:= GMaxX - GcuRightMargin - lineattr.resolution;
end;
{**************************************************************}
Function IniRDxValue(lineattr: lineattrtype) : real;
Begin
  if lineattr.beats=0 Then
    inirdxvalue:=0
  else
    InirDxValue:=(GetMaxX-GcuRightMargin-IniFirstBeatPos(lineattr))/(lineattr.beats);
End;
Function IniDxValue(lineattr: lineattrtype) : integer;
begin
  if lineattr.beats=0 Then
    inidxvalue:=0
  else
    IniDxValue:= (GetMaxX {+ 1} - GcuRightMargin - IniFirstBeatPos(lineattr))
                  div (lineattr.beats);
end;
{**************************************************************}
Function IniNumChar(c: char) : Boolean;
{True wenn c zwischen 0 und 9 liegt}
begin
  IniNumChar:= ((c >= '0') and (c <= '9'));
end;
{**************************************************************}
Function IniArrow(c: char) : Boolean;
{True wenn c = < oder > ist}
begin
  IniArrow:= ((c = '>') or (c = '<'));
end;
{**************************************************************}
Function IniDoppel(c: char) : Boolean;
{True wenn c = : ist}
begin
  IniDoppel:= (c = ':');
end;
{**************************************************************}
Function IniPrintChar(c: char) : Boolean;
Var V : Byte  Absolute C;
{True wenn c zwischen blank und z liegt oder ein Umlaut ist}
begin
  IniPrintChar:= (((c >= ' ') and (c <= 'z')) or
                  (v = 040) or
                  (v = 041) or
                  (v = 092) or
                  (v = 123) or
                  (v = 125) or

                  (v = 132) or
                  (v = 142) or
                  (v = 133) or
                  (v = 160) or
                  (v = 131) or
                  (v = 134) or
                  (v = 143) or
(*
                  (v = 204) or
                  (v = 205) or
                  (v = 255) or
*)
                  (v = 130) or
                  (v = 144) or
                  (v = 138) or
                  (v = 136) or
                  (v = 137) or
                  (v = 139) or
                  (v = 161) or
                  (v = 141) or
                  (v = 140) or
                  (v = 152) or

                  (v = 148) or
                  (v = 153) or
                  (v = 162) or
                  (v = 149) or
                  (v = 147) or

                  (v = 129) or
                  (v = 154) or
                  (v = 163) or
                  (v = 151) or
                  (v = 150) or

                  (v = 126) or
                  (v = 164) or
                  (v = 165) or

                  (v = 168) or
                  (v = 173) or
                  (v = 174) or
                  (v = 175) or

                  (v = 135) or
                  (v = 128) or

                  (v = 225) or

                  (v = 179) or
                  (v = 196) or
                  (v = 221) or
                 {(v = XXX) or }

                  (v = 248) or
                  (v = 21));

end;
{**************************************************************}
Function IniPrintNote(c: char) : Boolean;
{True wenn c ein als Note druckbares Zeichen, ausser 0...9 ist}
begin
  IniPrintNote:= ((c in spec)
                  or ((c >= 'A') and (c <= 'Z'))
                  or ((c >= 'a') and (c <= 'z'))
                  or (( c >= #128) and (c <= #153)));
End;
{**************************************************************}
Function IniNextnumber(var strbuf: stringline) : integer;
{Liest einen integer aus dem Buffer und gibt ihn als Funktionswert zur�ck.
 Der String selbst wird im Buffer gel�scht.}
var numstring : string[20];
    i, codei : integer;
begin
{L�sche leading blanks}
  numstring:='';
  while (length(strbuf) > 0 ) and (strbuf[1] = ' ') do
    delete(strbuf,1,1);
{Lese bis zum ersten nichtnumerischen Zeichen}
  while (length(strbuf) > 0 ) and IniNumChar(strbuf[1]) do begin
    numstring:= numstring + strbuf[1];
    delete(strbuf,1,1);
  end;
{Wandle den String in einen Integer um}
  if numstring <> '' then begin
    Val( numstring, i, codei );
    IniNextNumber:= i;
  end else begin
    IniNextNumber:= 0;
  end;
end;
{**************************************************************}
Procedure IniNewPage(var linenum: integer);
{Neue Seite initialisieren}
var Response : Response_Type;
    Direction : Movement;
    KeyResponse : Char;
    i,j : integer;
begin
  ClearViewPort;
  For i:= 1 to PageLim do page[i]:='T';
end;
{**************************************************************}
Function IniYnow(linenum : integer) : integer;
begin
  if linenum < pagelim then begin
    IniYnow:= linenum*linethick;
  end else begin
  {linenum = pagelim bedeutet, dass eine Zeile in der Mitte der Seite editiert wird}
    IniYNow:= (pagelength div 2) * linethick;
  end;
  if linenum = 0 then
    IniYnow:= yzeropos;
end;
{**************************************************************}
Function IniMaxHeader : integer;
begin
  IniMaxHeader:= pagelength div 2 - 1;
end;
{**************************************************************}
Function IniHeaderFooterLine(linenum: integer) : boolean;
begin
  if ((linenum >= topmargin) and
      (linenum <= pagelength) and
      (length(page[linenum]) >= 4) and
      (page[linenum, 4] = 'F')) then begin
    IniHeaderFooterLine:= true;
  end else begin
    IniHeaderFooterLine:= false;
  end;
end;
{**************************************************************}
Function IniHeaderEnd : integer;
var i: byte;
begin
  i:= topmargin;
  while (IniHeaderFooterLine(i)) do
    i:= i + 1;
  IniHeaderEnd:= i;
end;
{**************************************************************}
Function IniMinFooter : integer;
begin
  IniMinFooter:= pagelength div 2 + 1;
End;
{**************************************************************}
Function IniFooterEnd : integer;
var i: byte;
begin
  i:= pagelength;
  while (IniHeaderFooterLine(i)) do
    dec(i);
  IniFooterEnd:= i;
end;
{**************************************************************}
Function IniLnow(ynow : integer) : integer;
begin
  IniLnow:= ynow div linethick;
end;
{**************************************************************}
Procedure InitScreen;
Var i: integer;
begin
  gmaxx:= GetMaxX;
  gmaxy:= GetMaxY;
  TopMargin:= 1;
  PageLength := 52;
  LineThick := gmaxy div (pagelength + 5);
  line2thick:= linethick div 2;
  PageCount:= 1;
  CharWidth:= TextWidth('W');
  CharHeight:= TextHeight('$_');
  Char2Width:= CharWidth div 2;
  Char2Height:= CharHeight div 2;
  Chr4Width:= CharWidth div 4;
  Chr8Width:= CharWidth div 8;
  For i:= 1 to pagelength do page[i]:='';
  TextMargin:= IniLeftMargin;
  GrMinx:= IniLeftMargin;
  GrMaxx:= gmaxx - gcurightmargin + drightmargin;
  GrMaxY:= IniYBottomMargin;
  GrMinY:= 0;
  hfminx:= GrMinx div charwidth + 2;
  hfmaxx:= GrMaxX div charheight;
  hfminy:= 0;
  hfmaxy:= GrMaxY div charheight;
  lastentry:= invalid;
  arrowentry:= noarr;
{   actedit:= [];}
  symboldx:= 12;
  symboldy:= 12;
  stabxmin:= 4;
  stabymin:= 7;
  stabxmax:= 635;
  stabymax:= GmaxY - 3;
  sxmin:= stabxmin div charwidth + 1;
  sxmax:= stabxmax div charwidth;
  symin:= stabymin div charheight;
  symax:= stabymax div charheight;
  searchstring:= '';
{   actfilename:= '';}
  inbuffer:= '';
  printeron:= false;
  delpage:= false;
  delln:= 'T          ';
  showmenus:= false;
end;
{**************************************************************}
Procedure IniRefInit;
{Initialisierung der refreshparameter}
begin
  refxmin:= GMaxX;
  refxmax:= 0;
  refymin:= GMaxY;
  refymax:= 0;
end;
{**************************************************************}
Procedure IniGetSymbols;
var i, j: integer;
    c : char;
    infile: file of word;
    parfile: file of integer;
begin
  assign(infile,'symbols.sym');
  LastFileName:=FExpand('SYMBOLS.SYM');
  reset(infile);
  for c:='a' to 'z' do
    for i:=1 to 15 do
      for j:= 1 to 3 do
        read(infile,symarr[c,i,j]);
  close(infile);
  assign(parfile,'symbols.par');
  LastFileName:=FExpand('SYMBOLS.PAR');
  reset(parfile);
  for c:='a' to 'z' do
    for i:=1 to numofpar do
      for j:= 1 to 3 do
        read(parfile,sympar[c,i,j]);
  close(parfile);
end;
{**************************************************************}
Function IniEmptyLine( inblock : stringline): boolean;
begin
  IniTrailBlank(inblock);
  IniEmptyLine:= ((inblock = '') or
                  ((inblock[1] <> 'N')
                   and (length(inblock) <= linemarker)));
end;
{**************************************************************}
Procedure IniClrCharField( x, y : integer);
var i,j,k : integer;
begin
{L�sche ein Feld von Charactergroesse}
  if x < textmargin+2 then x:= textmargin+2;
  if x > 640 then
    exit;
  if x > 638-charwidth Then
    X:=638-charwidth;
  setviewport(x,y-6,x+8,y+4,true);
  setbkcolor(bkcolor);
  clearviewport;
  setviewport(0,0,GetMaxX,GetMaxY,true);
end;
{**************************************************************}
Procedure IniSetViewPort(x1, y1, x2, y2 : integer);
begin
  if x1 < 0 then x1:= 0;
  if y1 < 0 then y1:= 0;
  if x2 > GMaxX then x2:= GMaxX;
  if y2 > GMaxY then y2:= GMaxY;
  SetViewPort(x1, y1, x2, y2, true);
end;
{**************************************************************}
Procedure IniCharAdd(var TargetString : stringline; C : Char;
                      PosInString : integer);
{F�gt den Character C in TargetString auf Position PosInString ein,
 wobei wenn n�tig Blanks hinzugef�gt werden}
var i,j,k : integer;
    ActLength : integer;
begin
  if PosInString <= StLength then begin
    ActLength:= Length(TargetString);
    if ActLength < PosInString then begin
      for i:= ActLength + 1 to PosInString do
        TargetString:= TargetString + ' ';
    end;
    TargetString[PosInString]:= C;
  end;
end;
{**************************************************************}
Procedure IniIniColors;
var infile: text;
begin
  Assign(infile, 'colors.rns');
  LastFileName:=FExpand('COLORS.RNS');
{$I-}
  reset(infile);
{$I+}
  IF IOResult<>0 then Begin
    RunError(217);
  End;
  readln(infile, bkcolor);
  readln(infile, lcolor);
  readln(infile, ibkcolor);
  readln(infile, ilcolor);
  readln(infile, curcolor);
  readln(infile, gridcolor);
  readln(infile, menutextcolor);
  readln(infile, menubkcolor);
  readln(infile, imenutextcolor);
  readln(infile, imenubkcolor);
  readln(infile, bottomcolor);
  readln(infile, speccolor);
  readln(infile, helplinecolor);
  readln(infile, tmtext);
  readln(infile, tmbk);
  readln(infile, itmtext);
  readln(infile, itmbk);
  readln(infile, alarmcolor);
  readln(infile, alarmbkcolor);
  readln(infile, soundcolor);
  readln(infile, symtabcolor);
  readln(infile, symtabbkcolor);
  readln(infile, symsymbolscolor);
  readln(infile, menuframecolor);
  readln(infile, mausmtcolor);
  readln(infile, mausmbkcolor);
  readln(infile, FrameColor);
  readln(infile, FrameBkColor);
  close(infile);
end;
{**************************************************************}
Procedure IniIniSymbols;
var instring: stringline;
begin
  if not IniFileExist(fontfile) then
    FilFindeErstBestenFont(fontfile);
  instring:= fontfile;
  FilCopyFile(instring, 'symbols.prn');
  Delete(instring, length(instring) - 3, 4);
  instring:= instring + '.SYM';
  FilCopyFile(instring, 'symbols.sym');
  Delete(instring, length(instring) - 3, 4);
  instring:= instring + '.PAR';
  FilCopyFile(instring, 'symbols.par');
  IniGetSymbols;
end;
{**************************************************************}
Procedure IniHideColors;
var infile: text;
begin
  lcolor:= bkcolor;
  ibkcolor:= bkcolor;
  ilcolor:= bkcolor;
  curcolor:= bkcolor;
  gridcolor:= bkcolor;
  speccolor:= bkcolor;
  helplinecolor:= bkcolor;
  SetBkColor(bkcolor);
  SetColor(bkcolor);
end;
{*************************************************************************}
Procedure IniSwapFrame;Assembler;
Asm
  MOV AL,FrameColor
  XCHG AL,FrameBkColor
  MOV FrameColor,AL
End;
{*************************************************************************}
Const OldMenuBkColor    : Byte = 7;
      OldFrameColor     : Byte = 5;
      OldIMenuTextColor : Byte = 5;
      OldIMenuBkColor   : Byte = 1;
      OldMenuTextColor  : Byte = 12;
Procedure IniSwapMenuColors;Assembler;
Asm
  MOV AL,MenuBkColor
  XCHG AL,OldMenuBkColor
  MOV MenuBkColor,AL

  MOV AL,MenuTextColor
  XCHG AL,OldMenuTextColor
  MOV MenuTextColor,AL

  MOV AL,FrameColor
  XCHG AL,OldFrameColor
  MOV FrameColor,AL

  MOV AL,IMenuTextColor
  XCHG AL,OldIMenuTextColor
  MOV IMenuTextColor,AL

  MOV AL,IMenuBkColor
  XCHG AL,OldIMenuBkColor
  MOV IMenuBkColor,AL
End;
{*************************************************************************}
Procedure WSwap(Var a,b);Assembler;
Asm
  LES DI,a
  MOV AX,ES:[DI]
  LES DI,b
  MOV BX,ES:[DI]
  XCHG AX,BX
  MOV ES:[DI],BX
  LES DI,a
  MOV ES:[DI],AX
End;
{*************************************************************************}
Procedure Ini3DFrame(X0,Y0,X1,Y1 : Word;F,B : Byte;t : byte);
{ Rahmen: X0,Y0/X1,Y1, F,B : Colors, t: frxxxx }
Var SC : Byte;
    i  : byte;
Begin
  sc:=getcolor;
  if (t and frdel3D)=frdel3d then begin
    t:=t and not frdel3d;
    setcolor(7);
    Line(X0-2,Y0-2,X1+2,Y0-2);
    Line(X0-2,Y0-1,X0-2,Y1+2);
    Line(X0-1,Y1+2,X1+2,Y1+2);
    Line(X1+2,Y0-1,X1+2,Y1+1);
  end;
  Case t of
    frNoFrame:;
    frHigh,frLow: Begin
      if t=frHigh then
        WSwap(F,B);
      For i:=1 To FrameWidth{-1} Do Begin
        SetColor(F);
        Line(x0-i  , Y0-i  , X1+i  ,Y0-i  );{OL-OR}
        Line(x0-i  , Y0-i+1, X0-i  ,Y1+i  );{OL-UL}
        Setcolor(B);
        Line(x0-i+1, Y1+i  , X1+i  ,Y1+i  );{UL-UR}
        Line(x1+i  , Y0-i+1, X1+i  ,Y1+i-1);{OR-UR}
      end;
    End;{case t of 0 }
    fr3D : Begin
      SetColor(12);{black}
      Line(X0-1,Y0-2,X1+1,Y0-2);{S:OL-OR}
      Line(x0-2,Y0-1,X0-2,Y1+1);{S:OL-UL}
      Line(x0-1,Y1+2,X1+1,Y1+2);{S:UL-UR}
      Line(x1+2,Y0-1,X1+2,Y1+1);{S:OR-UR}

      SetColor(8);{gray}
      Line(X0-1  ,Y1+1,X1+1,Y1+1);{G:UL-UR}
      Line(X1+1,Y0  ,X1+1,Y1  );{G:OR-UR}

      SetColor(5);{white}
      Line(X0-1,Y0-1,X1+1,Y0-1);{W:OL-OR}
      Line(X0-1,Y0  ,X0-1,Y1{+1});{W:OL-UL}
    end;
    frL3D : Begin
      SetColor(12);{black}
      Line(X0-1,Y0-21,X1{+1},Y0-21);{S:OL-OR}
      Line(x0-2,Y0-20,X0-2,Y1+20);{S:OL-UL}
      Line(x0-1,Y1+21,X1{+1},Y1+21);{S:UL-UR}
      Line(x1{+2}+1,Y0-20,X1{+2}+1,Y1+20);{S:OR-UR}

      SetColor(8);{gray}
      Line(X0-1  ,Y1+20,X1{+1},Y1+20);{G:UL-UR}
      Line(X1{+1},Y0-19,X1{+1},Y1+20);{G:OR-UR}

      SetColor(5);{white}
      Line(X0-1,Y0-20,X1{+1}-1,Y0-20);{W:OL-OR}
      Line(X0-1,Y0-20,X0-1,Y1+19);{W:OL-UL}
    end;
  End;{ case t}
  SetColor(SC);
End;
{*************************************************************************}
Function IniLineEnd(inblock : String) : Integer;
var lineattr: lineattrtype;
Begin
  if Inblock[1]<>'N' then begin
    IniLineEnd:=0;
    exit;
  end;
  GetNoteAttributes(stringline(inblock),lineattr);
  with lineattr do
    IniLineEnd:=grmaxx-(resolution mod beats);
End;
{*************************************************************************}
Procedure IniLineEndSound(Level : Byte);
var a : Byte;
begin
  delay(50);
  case level of
    0: begin
      for a:=0 to 2 do begin
        sound(880);
        delay(100);
        nosound;
        delay(100);
      end;
    end;{case level of 0}
    1: begin
      for a:=0 to 4 do begin
        sound(880);
        delay(50);
        nosound;
        delay(50);
      end;
    end;{case level of 1}
    else begin
    end;{case level else}
  end;{case level}
end;
{*************************************************************************}
Procedure IniInitPalette;
Var a : Byte;
Begin
  SetPalette(12,0);             { Color 12=PalReg[0]                    }
  SetPalette(13,15);            { Color 13=PalReg[15]                   }
  IniSetDACReg(60,0,0,0);       { light red ->Schwarz                   }
  IniSetDACReg(5,63,63,63);     { magenta   ->Weiss  }
  IniSetDACReg(63,10,10,10);    { Weiss     ->Grau   Mausfarbe!!!       }
{  SetRGBPalette}
  Asm
    CLD                         { Clear dir flag                        }
    LEA  DI,ThePalette          { ES:DI=@Palette                        }
    MOV  AX,DS
    MOV  ES,AX
    MOV  CX,3*100h              { 3*100h bytes                          }
    MOV  DX,3C8h                { DAC                                   }
    MOV  AL,1                   { Index 0                               }
    OUT  DX,AL
    INC  DX                     { Data:                                 }
  @@1:
    DB   0E4h,060h              { waste some time                       }
    IN   AL,DX                  { Get Byte, Idx will be incremented auto}
    STOSB                       { store                                 }
    DEC  CX                     { =loop                                 }
    JNZ  @@1
  End;
  For a:=0 TO $FF Do Begin
    PalSteps[a].R:=ThePalette[a].R/128;
    PalSteps[a].G:=ThePalette[a].G/128;
    PalSteps[a].B:=ThePalette[a].B/128;
  End;
End;
Procedure IniSetDACReg(n,r,g,b : byte);
begin
  // TODO: Set single palette register with modern graphics API
  // Original: Set VGA DAC register n to RGB values r,g,b
end;
Procedure IniSetAllDACRegs(aPalette : TDACTable);
begin
  // TODO: Set complete palette with modern graphics API
  // Original: Set all 256 VGA DAC registers from aPalette array
end;

Procedure IniFadeOut;
Var a,b : byte;
    ActPalette : TDACTable;
Begin
  ActPalette:=ThePalette;
  for b:=0 To $3F do begin
    for a:=0 To $FF Do Begin
      With ActPalette[a] Do Begin
        if r>0 then dec(r);
        if g>0 then dec(g);
        if b>0 then dec(b);
        IniSetDACReg(a,R,G,B);
      End;
    End;
  End;
End;
Procedure IniPalBlank(r,g,b : byte);
Var ActPalette : TDACTable;
    a          : byte;
Begin
  For a:=0 To $FF Do Begin
    ActPalette[a].r:=r;
    ActPalette[a].g:=g;
    ActPalette[a].b:=b;
  End;
  IniSetAllDACRegs(actpalette);
End;
Procedure IniFadeIn;
Var a,b : byte;
    ActPalette : TDACTable;
    RealPalette : TRealDAC;
Begin
  FillChar(actpalette,sizeof(actpalette),0);
  For a:=0 To $FF do begin
    realpalette[a].r:=0;
    realpalette[a].b:=0;
    realpalette[a].g:=0;
  end;
  for b:=0 to $7E do begin
    for a:=0 To $FF Do Begin
      With ActPalette[a] Do Begin
        realpalette[a].r:=realpalette[a].r+palsteps[a].r;
        realpalette[a].g:=realpalette[a].r+palsteps[a].g;
        realpalette[a].b:=realpalette[a].r+palsteps[a].b;
        r:=round(realpalette[a].r);
        g:=round(realpalette[a].g);
        b:=round(realpalette[a].b);
        IniSetDACReg(a,R,G,B);
      End;
    End;
  End;
  IniSetAllDACRegs(ThePalette);
end;

Procedure IniDrawSoundState;
Procedure DrawTriStateChar(n : integer;c : char;b : byte);
begin
  case b of
    1:TxtFnt.WriteChar(394+n*8,438,c,ImenuTextColor,sz8x8,stnormal);
    2:TxtFnt.WriteChar(394+n*8,438,c,AlarmColor,sz8x8,stnormal);
    3:TxtFnt.WriteChar(394+n*8,438,c,AlarmBkColor,sz8x8,stnormal);
  end;
end;

Procedure DrawStateChar(n : integer;c : char;b : boolean);
begin
  if b then
    TxtFnt.WriteChar(394+n*8,438,c,ImenuTextColor,sz8x8,stnormal)
  else
    TxtFnt.WriteChar(394+n*8,438,c,AlarmColor,sz8x8,stnormal);
end;

Begin
(* 'BPTSLMR ([{�' *)
  DrawTriStateChar(01,'B',SndPlayBeat);
  DrawStateChar(02,'P',(SndPlayPulse and plspace)=0);
  DrawTriStatechar(03,'T',(SndPlayPulse And plPulse)+1);
{  DrawStateChar(03,'T',(SndPlayPulse And plpulse)=0);}
  DrawStateChar(04,'S',(soundattr And saStaccato)=0);
  DrawStateChar(05,'L',(soundattr And saLegato)=0);
  DrawStateChar(06,'M',(soundchange And saMuffled)=0);
  DrawStateChar(07,'R',(soundchange And saRhythm)=0);
  DrawStateChar(09,'(',(PlayOptions And poParentheses)=0);
  DrawStateChar(10,'[',(PlayOptions And poBrackets)=0);
  DrawStateChar(11,'{',(PlayOptions And poBraces)=0);
  DrawStateChar(12,'�',(PlayOptions And poDashSlash)=0);

{  IF SndPlayBeat=1 Then
    TxtFnt.WriteChar(402,438,'B',ImenuTextColor,sz8x8,stnormal)
  Else
    TxtFnt.WriteChar(402,438,'B',AlarmColor,sz8x8,stnormal);
  IF (SndPlayPulse And plspace)=0 Then
    TxtFnt.WriteChar(410,438,'P',ImenuTextColor,sz8x8,stnormal)
  Else
    TxtFnt.WriteChar(410,438,'P',AlarmColor,sz8x8,stnormal);
  IF (SndPlayPulse And plpulse)=0 Then
    TxtFnt.WriteChar(418,438,'T',ImenuTextColor,sz8x8,stnormal)
  Else
    TxtFnt.WriteChar(418,438,'T',AlarmColor,sz8x8,stnormal);
  IF (soundattr And saStaccato)=0 Then
    TxtFnt.WriteChar(426,438,'S',ImenuTextColor,sz8x8,stnormal)
  Else
    TxtFnt.WriteChar(426,438,'S',AlarmColor,sz8x8,stnormal);
  IF (soundattr And saLegato)=0 Then
    TxtFnt.WriteChar(434,438,'L',ImenuTextColor,sz8x8,stnormal)
  Else
    TxtFnt.WriteChar(434,438,'L',AlarmColor,sz8x8,stnormal);
  IF (soundchange And saMuffled)=0 Then
    TxtFnt.WriteChar(442,438,'M',ImenuTextColor,sz8x8,stnormal)
  Else
    TxtFnt.WriteChar(442,438,'M',AlarmColor,sz8x8,stnormal);
  IF (soundchange And saRhythm)=0 Then
    TxtFnt.WriteChar(450,438,'R',ImenuTextColor,sz8x8,stnormal)
  Else
    TxtFnt.WriteChar(450,438,'R',AlarmColor,sz8x8,stnormal);
  IF (PlayOptions And poParentheses)=0 Then
    TxtFnt.WriteChar(466,438,'(',ImenuTextColor,sz8x8,stnormal)
  Else
    TxtFnt.WriteChar(466,438,'(',AlarmColor,sz8x8,stnormal);
  IF (PlayOptions And poBrackets)=0 Then
    TxtFnt.WriteChar(474,438,'[',ImenuTextColor,sz8x8,stnormal)
  Else
    TxtFnt.WriteChar(474,438,'[',AlarmColor,sz8x8,stnormal);
  IF (PlayOptions And poBraces)=0 Then
    TxtFnt.WriteChar(482,438,'{',ImenuTextColor,sz8x8,stnormal)
  Else
    TxtFnt.WriteChar(482,438,'{',AlarmColor,sz8x8,stnormal);
  IF (PlayOptions And poDashSlash)=0 Then
    TxtFnt.WriteChar(490,438,'�',ImenuTextColor,sz8x8,stnormal)
  Else
    TxtFnt.WriteChar(490,438,'�',AlarmColor,sz8x8,stnormal);}
End;

begin
  IniHideCursor;
  symbcount:=0;
  addcent:=0;
  mulcent:=1;
  LastSound:=0;
  FrameWidth:=1;
  FileChanged:=0;
  TTextFontViewer(TxtFnt).Init('RNS'); {'RNS'}
  sndwarning:=1;
  pagebuf:=-1;
  lastbuf:=-1;
  playOptions:=0;
  logo:=new(pbmp16,load(logoname));
end.
