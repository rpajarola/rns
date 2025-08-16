unit GraphMenu;

interface

uses MenuTyp,
     crt,
     GrInOut,
     Initsc,
     Gcurunit,
     Inout,
     Graph;


procedure GrDisplay_Frame (startx, starty, endx, endy: integer;
                           topline, endline: boolean);
procedure GrDisplay_Menu (startx, starty: integer;
                          VAR MENU: MENU_REC; keyright: byte);
procedure GrGet_Menu_Response (startx, starty : integer;
                 VAR MENU: MENU_Rec;
                 var USERS_CHOICE: char;
                 var movedir : movement;
                 var choicenum : byte;
                 var mausx, mausy, maustaste, mausmenu: word;
                 leftright: boolean; keyright: byte);
procedure GrGet_Menu_Values (startx, starty, endy: integer;
                             VAR MENU: MENU_Rec;
                             var USERS_CHOICE: char);

implementation

uses mousdrv;

procedure GrDisplay_Frame (startx, starty, endx, endy: integer;
                           topline, endline: boolean);

const dx = 0;
      dy = 1;

var actcolor: byte;
    m       : boolean;
begin
   m:=not istdunkel;
   if m then
     mausdunkel;
   actcolor:= Getcolor;
   SetColor(menubkcolor{!!!}{menuframecolor});
   SetFillStyle($FFFF,menubkcolor);
   Bar3D(startx, starty - dy, endx, endy, 0, false);
   Line(startx - 1, starty - dy, startx - 1, endy);
   Line(endx + 1, starty - dy, endx + 1, endy);
   SetColor(12);
   Line(startx,starty-1,endx,starty-1);  {Trennungslinie zum Background}
   Line(startx,starty-2,endx,starty-2);  {Trennungslinie zum Background}
   Line(startx,endy,endx,endy);
   SetColor(framecolor);
   Line(startx,starty,endx,starty);      {Lichtlinie oberhalb der Menus}
   Line(startx,starty+1,startx,endy-1);  {Lichtlinie links der Menus}
{   SetColor(menuframecolor);}
   if topline then
   begin
      Line(startx+1, starty + 23, endx, starty + 23);{Abgrenzungslinie hell}
      SetColor(12);
      Line(startx{+1}, starty + 22, endx, starty + 22);{Abgrenzungslimie dunkel}
      SetColor(framecolor);
   end;
   if endline then
   begin
      Line(startx+1, endy - 21, endx, endy - 21);    {" hell}
      SetColor(12);
      Line(startx{+1}, endy - 22, endx, endy - 22);    {" dunkel}
   end;
   if m then
     mauszeigen;
   SetColor(actcolor);
   MausInstall;
   MausGrafik(2);
   MausBereich(startx+10, endx-10, starty+38, endy-10);
end;

{ -----------------------------------------------------------------}
procedure GrDispInit(startx, starty: integer; VAR MENU: MENU_REC );

begin
   TOP_LINE := starty + menu.menuattr.firstline;
   LEFT_COL := startx + 1;
   ValCol:= Left_Col + 27;
end;

{ -----------------------------------------------------------------}

procedure GrDisplay_Menu (startx, starty: integer;
                          VAR MENU: MENU_REC; keyright: byte);

var
  ACTLINE : integer;
  I,J,L  : integer;
  outstring : stringline;
  m         : boolean;
begin

  m:=not istdunkel;
  if m then
    mausdunkel;
  GrDispInit(startx, starty, menu);
   with MENU do begin
     {Schreibe den Titel}
     i:=left_col-1;
     j:=starty+1;
     IniGraphXY(i,j);
     txtfnt.Write(i,j,Title,getcolor,sz6x12,stnormal);
     { Schreibe die Wahlm�glichkeiten und deren Beschreibungen auf den
       Bildschirm }
     for i := 1 to NUM_CHOICES do begin
       ActLine:= Top_Line + i * Spacing;
       if ChoiceVal[i].TypIdent = 'o' then begin
         case keyright of
           1: begin
             IniSwapMenuColors;
             j:=imenubkcolor;
             l:=imenutextcolor;
             imenubkcolor:=7;
             imenutextcolor:=12;
             IniInversText(LEFT_COL-1, ActLine, ' '+DESCRIPTIONS[I],frL3D+frSmallBar);
             imenubkcolor:=j;
             imenutextcolor:=l;
             IniSwapMenuColors;

           end;{ case keyright of 1 }
           0: begin
             outstring:=choices[i] + ' - ' + descriptions[i];
             IniOutTextXY(LEFT_COL-1, ActLine, outstring)
           end;{ case keyright of 0 }
           2: begin
             outstring:=' '+choices[i] + ' - ' + descriptions[i]+' ';
             IniSpacedText(LEFT_COL-1,ActLine, outstring,fr3D);
           end;{ case keyright of 2 }
         end;{case keyright}
       end else begin{if ChoiceVal[i].TypIdent = 'o' }
         IniOutTextXY(LEFT_COL-1, ActLine, DESCRIPTIONS[I]);
       end;
       case ChoiceVal[i].TypIdent of
         'o' : ;
         'r' : GrPut_Real(ChoiceVal[i].RVal,
                          VALCOL, ACTLINE, 1);{New}
         'i' : GrPut_Integer (ChoiceVal[i].IVal, ValCol,
                              ActLine, 1);
         's' : begin
                 IniOutTextXY(ValCol, ActLine, ChoiceVal[i].SVal);
               end;
         't' : begin
                 IniOutTextXY(ValCol, ActLine,
                              ToggleString[ChoiceVal[i].TVal +
                                           ChoiceVal[i].TValmin - 1]);
               end;
       end;{ case}
     end;{ for i }
   end;{ with menu }
  if m then
    mauszeigen;
end;{ proc GrDisplay_Menu }

{ ------------------------------------------------------------------}

procedure GrGet_Menu_Response (startx, starty : integer;
                 VAR MENU: MENU_Rec;
                 var USERS_CHOICE: char;
                 var movedir : movement;
                 var choicenum : byte;
                 var mausx, mausy, maustaste, mausmenu: word;
                 leftright: boolean; keyright : byte);

{
BESCHREIBUNG:
    Dieses  Unterprogramm erfa�t die getroffene Wahl eines  Benut-
    zers aus einem Men�. Die Auswahl kann entweder dadurch erfol-
    gen,  da�  das vorgegebene Zeichen des Men�s  eingegeben  wird
    oder da� Pfeiltasten mit abschlie�endem RETURN gedr�ckt wer-
    den, oder mit einem ESCAPE.

PARAMETER:
    MENU  (Eingabe)               - Bereits  auf  den  Bildschirm
                                    geschriebenes Men�
    USERS_CHOICE (Ein-/Ausgabe)   - Getroffene Wahl des Benutzers
    leftright - true, wenn links-rechts cursortasten g�ltige
                Eingaben sind
    keyright - true, falls der Shortcut-key rechts von der
               Auswahl stehen soll

BEN�TIGTE TYPENVEREINBARUNGEN:
    STRING79      - Wird f�r alle Strings verwendet
    MENU_REC      - Record mit den Men�-Informationen
    RESPONSE_TYPE - Typ der Eingabe (von Get_Respsonse)
    MOVEMENT      - Richtung der eingegebenen Pfeiltasten
                    (von Get_Response)

 ---------------------------------------------------------------- }

var
  CURRENT_CHOICE,   { Getroffene und hervorgehobene Wahl }
  I,j,L, s, y : integer;
  RESP : RESPONSE_TYPE;  { Tastatur-Eingabe - siehe Get_Response }
  DIR : MOVEMENT;        { Eingegebene Richtung der Pfeiltaste }
  FOUND : boolean;       { Flag f�r die Suche der Wahlm�glichkeit  }
  shiftp, ctrlp: boolean;
  mp : Word;

  Procedure HighLite(VideoVal : Integer);

  var outstring: string79;
      xpos: integer;
  { Ein kleines Unterprogramm um aktuelle Wahl hervorzuheben
    bzw. die verlassene Wahl wieder in normaler Schrift darzustellen

    Parameter:

    VideoVal: Schrifttyp der aktuellen Anzeige }

  begin
    mausdunkel;
    GrDispInit(startx, starty, menu);
    with MENU do begin
      case keyright of
        1: begin
          if videoval=1 then begin
            IniInversText(LEFT_COL-1, TOP_LINE + CURRENT_CHOICE*SPACING, ' '+DESCRIPTIONS[CURRENT_CHOICE],frL3D+frSmallBar);
          end else begin{ if videoval=1 }
            IniSwapMenuColors;
            j:=imenubkcolor;
            l:=imenutextcolor;
            imenubkcolor:=7;
            imenutextcolor:=12;
            IniInversText(LEFT_COL-1, TOP_LINE + CURRENT_CHOICE*SPACING, ' '+DESCRIPTIONS[CURRENT_CHOICE],frL3D+frSmallBar);
            imenubkcolor:=j;
            imenutextcolor:=l;
            IniSwapMenuColors;
          end;{ if videoval=1 else }
        end;{ case keyright of 1 }
        0: begin
          if menuattr.highliteline then begin
            outstring:=choices[current_choice]+' - '+descriptions[current_choice];
            xpos:=-1;
          end else begin{ if menuattr.highliteline }
            outstring:=' ' + DESCRIPTIONS[CURRENT_CHOICE];
            xpos:= 4;
            IniClearLine (LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE*SPACING,
                          length(outstring), menubkcolor);
            IniOutTextXY (LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE*SPACING,
                          outstring);
          end;{ if menuattr.highliteline else }
          IniExpand(outstring, menu_width);
          if VideoVal = 0 then begin
            IniClearLine (LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE*SPACING,
                          length(outstring), menubkcolor);
            IniOutTextXY (LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE*SPACING,
                          outstring);
          end else begin{ if videoval =0 }
            IniInversText (LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE*SPACING,
                           outstring,frHigh);
          end;{ if videoval =0 else}
        end;{ case keyright of 0}
        2: begin
          if menuattr.highliteline then begin
            outstring:=' '+choices[current_choice]+' - '+descriptions[current_choice]+' ';
            xpos:=-1;
          end else begin{ if menuattr.highliteline }
            outstring:=' ' + DESCRIPTIONS[CURRENT_CHOICE];
            xpos:= 4;
            IniClearLine (LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE*SPACING,
                          length(outstring), menubkcolor);
            IniSpacedText(LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE*SPACING,
                          outstring,frNoFrame);
          end;{ if menuattr.highliteline else }
          IniExpand(outstring, menu_width);
          if VideoVal = 0 then begin
            IniSpacedText(LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE*SPACING,
                          outstring,fr3D);
          end else begin{ if videoval =0 }
            IniSwapMenuColors;
            IniSpacedText (LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE*SPACING,
                           outstring,fr3D);
            IniSwapMenuColors;
          end;{ if videoval =0 else}
        end;{ case keyright of 0}
      end;{ case keyright of }
    end;{ with menu}
    mauszeigen;
  end; {procedure HighLite}



begin
  with MENU do begin
    for i:=1 to NUM_CHOICES do
      changed[i]:=false;

    MausZeigen;
    movedir:= none;
    CURRENT_CHOICE := choicenum;
    s:=choicenum;
    Highlite(1);
{ Erfasse die Eingabe des Benutzers solange, bis eine zul�ssige
   Wahl getroffen wurde }
    repeat
{ Hebe die jetzige Wahlm�glichkeit hervor }
{ �bernimm die nach dem Prompt eingegebene Antwort }
      if maustaste = 0 then begin
        if s<>current_choice Then Begin
          i:=current_choice;
          current_choice:=s;
          HighLite(0);
          current_choice:=i;
          HighLite(1);
        End;
        Repeat
          Get_Response (RESP, DIR, USERS_CHOICE, shiftp, ctrlp,
                        mausx, mausy, maustaste, mp, mausmenu);

        Until (RESP<>NO_Response) Or (Maustaste>0) Or (Mp=1);
        s:=current_choice;
      end else begin
        MausPressedPosition(mausx, mausy);
      end;
      maustaste:=maustaste or mp;
      if (maustaste = 1) then begin
        IniMausAssign(maustaste, resp);
        y:= mausy;
        if menu.spacing>4 then
          CURRENT_CHOICE:=(((y div 8)-starty-menu.menuattr.firstline+4) div spacing)
        else
        if menu.spacing=4 then
          CURRENT_CHOICE:=(((y div 8)-starty-menu.menuattr.firstline+4) div spacing)-1
        else
          CURRENT_CHOICE:=(((y div 8)-starty-menu.menuattr.firstline+4) div spacing)-2;

        if CURRENT_CHOICE < 1 then
          CURRENT_CHOICE:= 1;
        if CURRENT_CHOICE > NUM_CHOICES then
          CURRENT_CHOICE:= NUM_CHOICES;
{ leftright = true: es sind 2 Menus angezeigt. Teste
  ob Maus in der richtigen H�lfte des Schirmes.
  Achtung: Koordinaten sind = gxcoord div 8}
        if ((not leftright) or (((startx < (gmaxx div 16)) and
           (mausx < (gmaxx div 2))) or ((startx > (gmaxx div 16)) and
           (mausx > (gmaxx div 2))))) then begin
          mausmenu:= 0;
          maustaste:= 0;
        end else if mausx > (gmaxx div 2) then
          movedir:= right
        else
          movedir:= left;
      end else if maustaste<>0 Then Begin
        if keyright=1 then
          resp:=no_Response;
        maustaste:= 0;
      end;
      case RESP of
{ �ndere die aktuell getroffene Wahl, wenn die Pfeiltasten in der
  Richtung nach oben oder nach unten gedr�ckt wurden }
        ARROW: begin
          if (DIR = DOWN) and (CURRENT_CHOICE = NUM_CHOICES) then
            CURRENT_CHOICE := 1
          else if DIR = DOWN then
            CURRENT_CHOICE := CURRENT_CHOICE + 1
          else if (DIR = up) and (CURRENT_CHOICE = 1) then
            CURRENT_CHOICE := NUM_CHOICES
          else if DIR = UP then
            CURRENT_CHOICE := CURRENT_CHOICE - 1
          else if (leftright) then begin
            movedir:= DIR;
            RESP:= RETURN;
          end;
        end;{arrow}
{ Nur wenn direkt das Schl�sselzeichen f�r die Wahlm�glichkeit ge-
  dr�ckt wurde: Suche nach dem entsprechenden Element im Feld
  CHOICES }
        KEY : begin
          USERS_CHOICE:=UpCase(USERS_CHOICE);
          FOUND := false;
          for i:= 1 to NUM_CHOICES do
            if USERS_CHOICE = CHOICES[I] then begin
              FOUND := true;
              Highlite(0);
              CURRENT_CHOICE := I;
              Break;
            end;
          if FOUND then
            RESP := RETURN
        end;{key}
{ �bergib die aktuelle Wahlm�glichkeit, wenn RETURN gedr�ckt wurde }
        RETURN: changed[Current_Choice]:=True;
        ESCAPE:;
      end; {case}
      if mp=1 Then
        resp:=no_Response;
      maustaste:=0;
    until ((RESP = RETURN) or (resp = escape));

    if resp = escape then
      users_choice:= chr(27)
    else
      USERS_CHOICE := CHOICES[CURRENT_CHOICE];
    choicenum := CURRENT_CHOICE;
    HighLite(1);
  end; {with}
  Mausdunkel;
  Highlite(0);
end;
{ ------------------------------------------------------------------}
procedure GrGet_Menu_Values (startx, starty, endy: integer;
                             VAR MENU: MENU_Rec;
                             var USERS_CHOICE: char);
{
BESCHREIBUNG:
    Dieses  Unterprogramm erfa�t die Parameter Wahl eines  Benut-
    zers aus einem Werte - Men�. Die Auswahl kann entweder dadurch erfol-
    gen,  da�  Werte eingegeben werden,
    oder da� Pfeiltasten mit abschlie�endem RETURN gedr�ckt wer-
    den, oder mit einem ESCAPE.

PARAMETER:
    MENU  (Eingabe)               - Bereits  auf  den  Bildschirm
                                    geschriebenes Men�
    USERS_CHOICE (Ein-/Ausgabe)   - Getroffene Wahl des Benutzers

 ---------------------------------------------------------------- }

var
  CURRENT_CHOICE, pry: integer;

  RESP : RESPONSE_TYPE;  { Tastatur-Eingabe - siehe Get_Response }
  DIR : MOVEMENT;        { Eingegebene Richtung der Pfeiltaste }
  KeyResponse : Char;
  ACTLINE, y : integer;
  mausx, mausy, maustaste, mausmenu: word;

  Procedure HighLite(VideoVal : Integer);

  { Ein kleines Unterprogramm um aktuelle Wahl hervorzuheben
    bzw. die verlassene Wahl wieder in normaler Schrift darzustellen
    und die Eingabe-Felder vorzugeben
    ViedoVal: Schrifttyp der aktuellen Anzeige }

  var outstring: string79;

  begin
    Mausdunkel;
    with MENU do begin
      outstring:= ' ' + DESCRIPTIONS[Current_Choice];
      IniExpand(outstring, menu_width +1);
      If VideoVal = 1 then begin
        IniInversText ( LEFT_COL - 1, TOP_LINE + CURRENT_CHOICE*SPACING,
                        outstring,frHigh);
      end else begin
        IniClearLine(Left_col - 1, ActLine,
                     menu_width + 1, menubkcolor);
        IniOutTextXY(LEFT_COL - 1, ActLine, outstring);
      end;

      case ChoiceVal[Current_Choice].TypIdent of
        'o' : ; {Sollte nie vorkommen}
        'r' : GrPut_Real(ChoiceVal[Current_Choice].RVal,
                         VALCOL, ACTLINE, 1);{New}
        'i' : GrPut_Integer (ChoiceVal[Current_Choice].IVal,
                             VALCOL, ACTLINE, 1);
        's' : IniOutTextXY (VALCOL, ACTLINE,
                            ChoiceVal[Current_Choice].SVal);
        't' : IniOutTextXY(ValCol, ActLine,
                           ToggleString[ChoiceVal[Current_Choice].TVal +
                                        ChoiceVal[Current_Choice].TValmin - 1]);
      end; {case}
    end; {with MENU do}
    Mauszeigen;
  end; {procedure HighLite}

begin
   with MENU do begin
{     for pry:=1 to num_choices do
       changed[pry]:=false;}
       pry:= endy - 2;

      { Bestimme die aktuelle (hervorgehobene) Wahlm�glichkeit }

      CURRENT_CHOICE := 1;

     { Erfasse die Eingabe des Benutzers solange,  bis eine zul�ssige
       Wahl getroffen wurde }

     repeat
        ActLine:= Top_Line + Current_Choice * Spacing;

        { Hebe die jetzige Wahlm�glichkeit hervor }
        HighLite(1);
        { �bernimm die nach dem Prompt eingegebene Antwort }
        case ChoiceVal[Current_Choice].TypIdent of
           'o' :;
{New}      'r' : GrGet_Prompted_Real (
                          ChoiceVal[Current_Choice].RVal,
                          ChoiceVal[Current_Choice].RValMin,
                          ChoiceVal[Current_Choice].RValMax,
                          FieldLength, '>',
                          ValCol + (FieldLength + 1),
                          TOP_LINE + CURRENT_CHOICE*SPACING,
                          ValCol,
                          ChoiceDesc[Current_Choice],
                          LEFT_COL,
                          pry, menu_width,
                          RESP, DIR, KeyResponse, true,
                          mausx, mausy, maustaste, mausmenu,changed[current_choice]);
           'i' : GrGet_Prompted_Integer (
                          ChoiceVal[Current_Choice].IVal,
                          ChoiceVal[Current_Choice].IValMin,
                          ChoiceVal[Current_Choice].IValMax,
                          FieldLength, '>',
                          ValCol + (FieldLength + 1),
                          TOP_LINE + CURRENT_CHOICE*SPACING,
                          ValCol,
                          ChoiceDesc[Current_Choice],
                          LEFT_COL,
                          pry, menu_width,
                          RESP, DIR, KeyResponse, true,
                          mausx, mausy, maustaste, mausmenu,changed[current_choice]);
       's' : GrGet_Prompted_String  (ChoiceVal[Current_Choice].SVal,
                          FieldLength, '>',
                          ValCol + (FieldLength + 1),
                          TOP_LINE + CURRENT_CHOICE*SPACING,
                          ValCol,
                          ChoiceDesc[Current_Choice],
                          LEFT_COL,
                          pry, menu_width,
                          RESP, DIR, KeyResponse, true,
                          mausx, mausy, maustaste, mausmenu,changed[current_choice]);
       't' : GrGet_Prompted_Toggle  (
                          ChoiceVal[Current_Choice].TVal,
                          ChoiceVal[Current_Choice].TValMin,
                          ChoiceVal[Current_Choice].TValMax,
                          Togglestring,
                          FieldLength, '<',
                          ValCol + (FieldLength + 1),
                          TOP_LINE + CURRENT_CHOICE*SPACING,
                          ValCol,
                          ChoiceDesc[Current_Choice],
                          LEFT_COL,
                          pry, menu_width,
                          RESP, DIR, KeyResponse,
                          mausx, mausy, maustaste, mausmenu,changed[current_choice]);
       end; {case}
        { �ndere die noch hervorgehobene Wahlm�glichkeit in normale
         Schrift um }
       HighLite(0);

       IniMausAssign(maustaste, resp);
       if (maustaste = 1) then
       begin
          y:= mausy;
          CURRENT_CHOICE:= ((y div 8) - starty -
                             menu.menuattr.firstline + 1) div spacing;
          if CURRENT_CHOICE < 1 then CURRENT_CHOICE:= 1;
          if CURRENT_CHOICE > NUM_CHOICES then
             CURRENT_CHOICE:= NUM_CHOICES;
       end;

       case RESP of

       { �ndere die aktuell getroffene Wahl, wenn die Pfeiltasten in der
         Richtung nach oben oder nach unten gedr�ckt wurden }

          ARROW : if (DIR = DOWN) and (CURRENT_CHOICE = NUM_CHOICES) then
                     CURRENT_CHOICE := 1
                  else if DIR = DOWN then
                     CURRENT_CHOICE := CURRENT_CHOICE + 1
                  else if (DIR = up) and (CURRENT_CHOICE = 1) then
                     CURRENT_CHOICE := NUM_CHOICES
                  else if DIR = UP then
                     CURRENT_CHOICE := CURRENT_CHOICE - 1;

           KEY : ;

        RETURN : ;
        end;
      until RESP = ESCAPE;
      IniHideCursor;
    end;
 end;



{ ---------------------------------------------------------------- }

end.
