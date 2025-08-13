unit GraphMenu;

interface

uses MenuTyp,
     crt,
     GrInOut,
     Initsc,
     Gcurunit,
     Inout,
     Graph;


procedure GrDisplay_Frame (startx, starty, endx, endy, fillstyle: integer;
                           topline, endline: boolean);
procedure GrDisplay_Menu (startx, starty, fillstyle: integer;
                          VAR MENU: MENU_REC );
procedure GrGet_Menu_Response (startx, starty, fillstyle: integer;
                 VAR MENU: MENU_Rec;
                 var USERS_CHOICE: char; leftright: boolean;
                 var movedir : movement;
                 var choicenum : byte);
procedure GrGet_Menu_Values (startx, starty, endy, fillstyle: integer;
                             VAR MENU: MENU_Rec;
                             var USERS_CHOICE: char);

implementation

procedure GrDisplay_Frame (startx, starty, endx, endy, fillstyle: integer;
                           topline, endline: boolean);

const dx = 0;
      dy = 1;

begin
   SetFillStyle(fillstyle, imenubkcolor);
   Bar3D(startx, starty - dy, endx, endy, 0, false);
   Line(startx - 1, starty - dy, startx - 1, endy);
   Line(endx + 1, starty - dy, endx + 1, endy);

   if topline then
   begin
      Line(startx, starty + 17, endx, starty + 17);
   end;
   if endline then
   begin
      Line(startx, endy - 18, endx, endy - 18);
   end;
end;

{ -----------------------------------------------------------------}
procedure GrDispInit(startx, starty: integer; VAR MENU: MENU_REC );

begin
   TOP_LINE := starty + menu.menuattr.firstline;
   LEFT_COL := startx + 1;
   ValCol:= Left_Col + 27;
end;

{ -----------------------------------------------------------------}

procedure GrDisplay_Menu (startx, starty, fillstyle: integer;
                          VAR MENU: MENU_REC );

var
  ACTLINE : integer;
  I,J,L  : integer;

begin

  GrDispInit(startx, starty, menu);

  with MENU do
  begin

  {Schreibe den Titel}
  IniOutTextXY(Left_Col, StartY + 1, Title);

{ Schreibe die Wahlm”glichkeiten und deren Beschreibungen auf den
  Bildschirm }

     for i := 1 to NUM_CHOICES do
     begin
        ActLine:= Top_Line + i * Spacing;
        if ChoiceVal[i].TypIdent = 'o' then
        begin
           IniOutTextXY(LEFT_COL, ActLine, CHOICES[I]);
           IniOutTextXY(LEFT_COL + 2, ActLine,
                        '- ' + DESCRIPTIONS[I]);
        end
        else {if ChoiceVal[i].TypIdent = 'o' then}
        begin
           IniOutTextXY(LEFT_COL, ActLine, DESCRIPTIONS[I]);
        end;
        case ChoiceVal[i].TypIdent of
           'o' : ;
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

          end;

      end;
    end;
end;

{ ------------------------------------------------------------------}

procedure GrGet_Menu_Response (startx, starty, fillstyle : integer;
                 VAR MENU: MENU_Rec;
                 var USERS_CHOICE: char; leftright: boolean;
                 var movedir : movement;
                 var choicenum : byte);

{
BESCHREIBUNG:
    Dieses  Unterprogramm erfaát die getroffene Wahl eines  Benut-
    zers aus einem Men. Die Auswahl kann entweder dadurch erfol-
    gen,  daá  das vorgegebene Zeichen des Mens  eingegeben  wird
    oder daá Pfeiltasten mit abschlieáendem RETURN gedrckt wer-
    den, oder mit einem ESCAPE.

PARAMETER:
    MENU  (Eingabe)               - Bereits  auf  den  Bildschirm
                                    geschriebenes Men
    USERS_CHOICE (Ein-/Ausgabe)   - Getroffene Wahl des Benutzers
    leftright - true, wenn links-rechts cursortasten gltige
                Eingaben sind

BEN™TIGTE TYPENVEREINBARUNGEN:
    STRING79      - Wird fr alle Strings verwendet
    MENU_REC      - Record mit den Men-Informationen
    RESPONSE_TYPE - Typ der Eingabe (von Get_Response)
    MOVEMENT      - Richtung der eingegebenen Pfeiltasten
                    (von Get_Response)

 ---------------------------------------------------------------- }

var
  CURRENT_CHOICE,   { Getroffene und hervorgehobene Wahl }
  I        : integer;    { Z„hler fr Schleifen }
  RESP : RESPONSE_TYPE;  { Tastatur-Eingabe - siehe Get_Response }
  DIR : MOVEMENT;        { Eingegebene Richtung der Pfeiltaste }
  FOUND : boolean;       { Flag fr die Suche der Wahlm”glichkeit  }


  Procedure HighLite(VideoVal : Integer);

  var outstring: string79;
      xpos: integer;

  { Ein kleines Unterprogramm um aktuelle Wahl hervorzuheben
    bzw. die verlassene Wahl wieder in nrmaler Schrift darzustellen

    Parameter:

    ViedoVal: Schrifttyp der aktuellen Anzeige }

  begin
     GrDispInit(startx, starty, menu);

     with MENU do
     begin
        if menuattr.highliteline then
        begin
           outstring:= ' ' + choices[current_choice] + ' - ' +
                       DESCRIPTIONS[CURRENT_CHOICE];
           xpos:= -1;
        end
        else
        begin
           outstring:= ' ' + DESCRIPTIONS[CURRENT_CHOICE];
           xpos:= 4;
        end;
        IniExpand(outstring, menu_width);

        if VideoVal = 0 then
        begin
           IniClearLine (LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE*SPACING,
                         fillstyle, length(outstring), menubkcolor);
           IniOutTextXY (LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE*SPACING,
                         outstring);
        end
        else
        begin
           IniInversText ( LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE*SPACING,
                           outstring);
        end;
     end;
  end; {procedure HighLite}



begin
  with MENU do
  begin
     movedir:= none;
     CURRENT_CHOICE := choicenum;

{ Erfasse die Eingabe des Benutzers solange,  bis eine zul„ssige
   Wahl getroffen wurde }

     repeat

        { Hebe die jetzige Wahlm”glichkeit hervor }
        HighLite(1);

        { šbernimm die nach dem Prompt eingegebene Antwort }
        Get_Response (RESP, DIR, USERS_CHOICE);

        { Žndere die noch hervorgehobene Wahlm”glichkeit in normale
          Schrift um }

        HighLite(0);

        case RESP of

           { Žndere die aktuell getroffene Wahl, wenn die Pfeiltasten in der
             Richtung nach oben oder nach unten gedrckt wurden }

           ARROW: if (DIR = DOWN) and (CURRENT_CHOICE = NUM_CHOICES) then
                  CURRENT_CHOICE := 1
                  else if DIR = DOWN then
                    CURRENT_CHOICE := CURRENT_CHOICE + 1
                  else if (DIR = up) and (CURRENT_CHOICE = 1) then
                    CURRENT_CHOICE := NUM_CHOICES
                  else if DIR = UP then
                    CURRENT_CHOICE := CURRENT_CHOICE - 1
                  else if (leftright) then
                     begin
                        movedir:= DIR;
                        RESP:= RETURN;
                     end;

           { Nur wenn direkt das Schlsselzeichen fr die Wahlm”glichkeit ge-
             drckt wurde: Suche nach dem entsprechenden Element im Feld
             CHOICES }

          KEY : begin
                   USERS_CHOICE:=UpCase(USERS_CHOICE);
                   FOUND := false;
                   for i:= 1 to NUM_CHOICES do
                      if USERS_CHOICE = CHOICES[I] then
                      begin
                         FOUND := true;
                         CURRENT_CHOICE := I;
                       end;
                   if FOUND then
                      RESP := RETURN
                end;

         { šbergib die aktuelle Wahlm”glichkeit, wenn RETURN gedrckt wurde }

         RETURN: ;

         ESCAPE: ;

         end; {case}
       until ((RESP = RETURN) or (resp = escape));

       if resp = escape then users_choice:= chr(27)
       else USERS_CHOICE := CHOICES[CURRENT_CHOICE];

       choicenum := CURRENT_CHOICE;

       { Hebe erneut die getroffene Wahl hervor }
       HighLite(0);
     end; {with}
  end;


{ ------------------------------------------------------------------}

procedure GrGet_Menu_Values (startx, starty, endy, fillstyle: integer;
                             VAR MENU: MENU_Rec;
                             var USERS_CHOICE: char);
{
BESCHREIBUNG:
    Dieses  Unterprogramm erfaát die Parameter Wahl eines  Benut-
    zers aus einem Werte - Men. Die Auswahl kann entweder dadurch erfol-
    gen,  daá  Werte eingegeben werden,
    oder daá Pfeiltasten mit abschlieáendem RETURN gedrckt wer-
    den, oder mit einem ESCAPE.

PARAMETER:
    MENU  (Eingabe)               - Bereits  auf  den  Bildschirm
                                    geschriebenes Men
    USERS_CHOICE (Ein-/Ausgabe)   - Getroffene Wahl des Benutzers

 ---------------------------------------------------------------- }

var
  CURRENT_CHOICE, pry: integer;

  RESP : RESPONSE_TYPE;  { Tastatur-Eingabe - siehe Get_Response }
  DIR : MOVEMENT;        { Eingegebene Richtung der Pfeiltaste }
  FOUND : boolean;       { Flag fr die Suche der Wahlm”glichkeit  }
  KeyResponse : Char;
  ACTLINE : integer;

  Procedure HighLite(VideoVal : Integer);

  { Ein kleines Unterprogramm um aktuelle Wahl hervorzuheben
    bzw. die verlassene Wahl wieder in normaler Schrift darzustellen
    und die Eingabe-Felder vorzugeben
    ViedoVal: Schrifttyp der aktuellen Anzeige }

  var outstring: string79;

  begin
    with MENU do
    begin
       outstring:= ' ' + DESCRIPTIONS[Current_Choice];
       IniExpand(outstring, menu_width - 2*fieldlength - 2);
       If VideoVal = 1 then
       begin
          IniInversText ( LEFT_COL - 1, TOP_LINE + CURRENT_CHOICE*SPACING,
                          outstring);
       end
       else
       begin
          IniClearLine(Left_col - 1, ActLine,
                       fillstyle, menu_width + 1, menubkcolor);
          IniOutTextXY(LEFT_COL - 1, ActLine, outstring);
       end;

       case ChoiceVal[Current_Choice].TypIdent of
       'o' : ; {Sollte nie vorkommen}
       'i' : GrPut_Integer (ChoiceVal[Current_Choice].IVal,
                            VALCOL, ACTLINE, 1);
       's' : IniOutTextXY (VALCOL, ACTLINE,
                           ChoiceVal[Current_Choice].SVal);
       't' : IniOutTextXY(ValCol, ActLine,
                          ToggleString[ChoiceVal[Current_Choice].TVal +
                                       ChoiceVal[Current_Choice].TValmin - 1]);
          end; {case}
    end; {with MENU do}
    if hercgraphicsmode then SetColor(menutextcolor);

  end; {procedure HighLite}

begin
   with MENU do
   begin
      pry:= endy - 1;

      { Bestimme die aktuelle (hervorgehobene) Wahlm”glichkeit }

      CURRENT_CHOICE := 1;

     { Erfasse die Eingabe des Benutzers solange,  bis eine zul„ssige
       Wahl getroffen wurde }

     repeat
        ActLine:= Top_Line + Current_Choice * Spacing;

        { Hebe die jetzige Wahlm”glichkeit hervor }
        HighLite(1);
        { šbernimm die nach dem Prompt eingegebene Antwort }
        case ChoiceVal[Current_Choice].TypIdent of
           'o' : ;
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
                          RESP, DIR, KeyResponse, true);
       's' : GrGet_Prompted_String  (ChoiceVal[Current_Choice].SVal,
                          FieldLength, '>',
                          ValCol + (FieldLength + 1),
                          TOP_LINE + CURRENT_CHOICE*SPACING,
                          ValCol,
                          ChoiceDesc[Current_Choice],
                          LEFT_COL,
                          pry, menu_width,
                          RESP, DIR, KeyResponse, true);
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
                          RESP, DIR, KeyResponse);
       end; {case}

       { Žndere die noch hervorgehobene Wahlm”glichkeit in normale
         Schrift um }

        HighLite(0);

        case RESP of

        { Žndere die aktuell getroffene Wahl, wenn die Pfeiltasten in der
          Richtung nach oben oder nach unten gedrckt wurden }

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
     end;
  end;



{ ---------------------------------------------------------------- }

end.
