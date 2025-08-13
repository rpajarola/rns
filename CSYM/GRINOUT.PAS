Unit grinout;

interface

uses menutyp,
     crt,
     inout,
     dispmenu,
     gcurunit,
     initsc,
     graph;


procedure GrPut_Integer (NUMBER, X, Y, NUM_LENGTH: integer);

procedure GrPut_Prompt (OUT_STRING: string79; X, Y: integer);

procedure GrGet_String (var IN_STRING: STRING16;
               X, Y, OLDX, STR_LENGTH: integer;
                            var  RESP: RESPONSE_TYPE;
                        var DIRECTION: MOVEMENT;
                     var KEYRESPONSE : char;
                             oldwrite: boolean);

procedure GrGet_Integer (var NUMBER: integer;
                   IValMin, IValMax: integer;
             X, Y, OLDX, NUM_LENGTH: integer;
                          var  RESP: RESPONSE_TYPE;
                      var DIRECTION: MOVEMENT;
                    var KeyResponse: char;
                           oldwrite: boolean);

procedure GrGet_Prompted_String (var IN_STRING: STRING16;
                                    STR_LENGTH: integer;
                                       STRDESC: char;
                                  DESCX, DESCY: integer;
                                       OLDESCX: integer;
                                        PROMPT: STRING79;
                                      PRX, PRY: integer;
                                      prlength: integer;
                                     var  RESP: RESPONSE_TYPE;
                                 var DIRECTION: MOVEMENT;
                              var KeyResponse: char;
                                     oldwrite: boolean);

procedure GrGet_Prompted_Integer (var INNUMBER: integer;
                            IValMin, IValMax: integer;
                                  NUM_LENGTH: integer;
                                     STRDESC: Char;
                                DESCX, DESCY: integer;
                                     OLDESCX: integer;
                                      PROMPT: STRING79;
                                    PRX, PRY: integer;
                                    prlength: integer;
                                   var  RESP: RESPONSE_TYPE;
                               var DIRECTION: MOVEMENT;
                             var KeyResponse: char;
                                    oldwrite: boolean);

procedure GrGet_Prompted_Toggle (var tval: integer;
                                 tValMin, tValMax: integer;
                                 var tstrings: toggletyp;
                                 NUM_LENGTH: integer;
                                 STRDESC: Char;
                                 DESCX, DESCY: integer;
                                 OLDESCX: integer;
                                 PROMPT: STRING79;
                                 PRX, PRY: integer;
                                 prlength: integer;
                                 var  RESP: RESPONSE_TYPE;
                                 var DIRECTION: MOVEMENT;
                                 var KeyResponse: char);

implementation

{------------------------------------------------------------------}

procedure GrPut_Integer (NUMBER, X, Y, NUM_LENGTH: integer);
{
BESCHREIBUNG:
    Dieses Unterprogramm gibt eine Integer-Zahl an einer bestimmten
    Stelle auf dem Bildschirm aus.

PARAMETER:
    NUMBER_IN  (Eingabe) - Auszugebende Zahl
    X, Y                 - Position
    NUM_LENGTH (Eingabe) - Gesamtanzahl der zu benutzenden Stellen
                           (rechtsbÅndig) [2-80]

BENôTIGTE TYPEN:
    STRING79 - Wird fÅr alle Strings verwendet

---------------------------------------------------------------------}
var
  TEMP_STR: STRING79;

begin

{ Wandle die Zahl in einen String um und gib den String aus }

  Str (NUMBER:NUM_LENGTH, TEMP_STR);
  IniOutTextXY (X, Y, TEMP_STR);
end;

{------------------------------------------------------------------}

procedure GrPut_Prompt (OUT_STRING: string79; X, Y: integer);
{
BESCHREIBUNG:
    Dieses Unterprogramm gibt einen String in einer bestimmten
    Zeile auf dem Bildschirm aus und lîscht vorher den Inhalt der
    Zeile

PARAMETER:
    OUT_STRING  (Eingabe) - Auszugebender String
    X, Y                  - Position

BENôTIGTE TYPEN:
    STRING79 - Wird fÅr alle Strings verwendet

---------------------------------------------------------------------}
begin

{ Lîsche die gesamte Zeile und gib den String aus }

   IniOutTextXY(X, Y, ClearString);
   IniOutTextXY(X, Y, OUT_STRING);
end;

{-------------------------------------------------------------------}

procedure GrGet_String (var IN_STRING: STRING16;
               X, Y, OLDX, STR_LENGTH: integer;
                            var  RESP: RESPONSE_TYPE;
                        var DIRECTION: MOVEMENT;
                     var KEYRESPONSE : char;
                             oldwrite: boolean);
{
BESCHREIBUNG:
    Dieses Unterprogramm liest einen String von einer bestimmten
    Stelle des Bildschirms ein und berÅcksichtigt bestehende Bild-
    schirmattribute.

PARAMETER:
    IN_STRING (Ein-/Ausgabe) - Einzulesender String
    X, Y, OLDX               - Position
    STR_LENGTH (Eingabe)     - Gesamtanzahl der zu benutzenden Stellen
                               [ 1-80 ]
    RESP (Ausgabe)           - Gibt an, ob der BenÅtzer die Eingabe mit
                               Return, den Pfeiltasten oder mit
                               ESCAPE beendet hat.
    DIRECTION (Ausgabe)      - Richtung der Pfeiltaste
    KeyResponse (Ausgabe)   - Zuletzt gedrÅcktes Zeichen

 BENôTIGTE TYPEN:
    STRING79 - Wird fÅr alle Strings verwendet


ANMERKUNGEN:
    Dieses Unterprogramm liest nur jeweils ein Zeichen ein, so da·
    das Echo kontrolliert werden kann.
    Der Pfeil nach rechts wird verwendet, um es dem Benutzer zu er-
    mîglichen, ein Zeichen des bestehenden Strings zu Åbernehmen.
    Eine Eingabe au·erhalb der vorgegebenen LÑnge ist nicht erlaubt.

-------------------------------------------------------------------}

const
  BELL            = 7;        { ASCII Signalton }
  BACK_SPACE      = 8;        { ASCII RÅckschritt }
  CARRIAGE_RETURN = 13;       { ASCII WagenrÅcklauf }
  ESC             = 27;       { ASCII Escape Zeichen }
  RIGHT_ARROW     = 77;       { IBM Escape Sequenz fÅr Pfeiltaste
                                 nach rechts }

var
  OLDSTR : STRING79;          { Originaler String }
  IN_CHAR: char;              { Zeicheneingabe von Tastatur }
  I  : integer;              { ZÑhler fÅr String-LÑnge }
  clstring: string79;

begin

   { Gib den String mit den entsprechenden Attributen auf dem
     Bildschirm aus }

   clstring:= '';
   IniExpand(clstring, str_length);

   if oldwrite then
   begin
      IniInversText (OLDX, Y, ClString);
      IniInversText (OLDX, Y, IN_STRING);
   end;
   IniInversText (X, Y, ClString);
   OLDSTR := IN_STRING;

{ Lies das erste Zeichen ein. Verwende bei RETURN den alten String }

   IniGotoXY(X, Y);
   Get_Response(Resp, Direction, KeyResponse);
   in_string:= '';
{ Verarbeite jeweils nur ein Zeichen }

    while (Resp=Key) do
    begin

   { Wenn RÅckschritt gedrÅckt wurde, entferne das eingegebene Zeichen }

      if Ord (KeyResponse) = BACK_SPACE then  { RÅckschritt }
      begin
         if length (IN_STRING) > 0 then
         begin
            IN_STRING[0] := Chr(Length (IN_STRING) - 1);
            x:= x - 1;
            IniInversText(X, Y, ' ');
         end;
      end {if Ord}

      { PrÅfe ob Pfeiltasten - bestehend aus 2 Zeichen mit ESCAPE als
        erstem Zeichen - gedrÅckt wurden }

      else {if Ord}
      begin

         { FÅge ein "normales" Zeichen" in den String ein }

         if Length(IN_STRING) < STR_LENGTH then
         begin
            IN_STRING[0] := Chr(Length (IN_STRING) + 1);
            IN_STRING[Ord(IN_STRING[0])] := KeyResponse;
            IniInversText(X, Y, KeyResponse);
            x:= x + 1;
         end;
      end; {if Ord}
      IniGotoXY(X, Y);
      Get_Response(Resp, Direction, KeyResponse);
   end; {while}
   if Resp <> Return then
   begin
      in_string:= oldstr;
   end;
end;

{-------------------------------------------------------------------}

procedure GrGet_Integer (var NUMBER: integer;
                   IValMin, IValMax: integer;
             X, Y, OLDX, NUM_LENGTH: integer;
                          var  RESP: RESPONSE_TYPE;
                      var DIRECTION: MOVEMENT;
                    var KeyResponse: char;
                           oldwrite: boolean);
{
BESCHREIBUNG:
    Dieses Unterprogramm liest eine Integer-Zahl von einer bestimmten
    Stelle des Bildschirms ein.

PARAMETER:
    NUMBER (Ein-/Ausgabe)    - Einzulesende Zahl
    IValMin (Eingabe)        - Minimaler erlaubter Wert
    IValMax (Eingabe)        - Maximaler erlaubter Wert
    X,Y,OLDX                 - Position
    NUM_LENGTH (Eingabe)     - Gesamtanzahl der zu benutzenden Stellen
                               [ 1-80 ]
    RESP (Ausgabe)           - Gibt an, ob der BenÅtzer die Eingabe mit
                               Return, den Pfeiltasten oder mit
                               ESCAPE beendet hat.
    DIRECTION (Ausgabe)      - Richtung der Pfeiltaste
    KeyResponse (Ausgabe)   - Zuletzt gedrÅcktes Zeichen

 BENôTIGTE TYPEN:
    STRING79 - Wird fÅr alle Strings verwendet

-------------------------------------------------------------------}

const
  BELL = 7;                  { ASCII Signalton }

var
  VALCODE        : integer;  { Code fÅr die String-Umwandlung }
  ORIGINAL_STR,              { Originaler String }
  TEMP_STR       : string16; { Von Tastatur eingegebener String }
  TEMP_INT       : integer;  { Versuchte Umwandlung des Strings }

begin
   Str (NUMBER, ORIGINAL_STR);

{ Probiere weiterhin, bis nur noch Ziffern eingegeben werden }

   repeat
      TEMP_STR := Original_Str;

      { Lies die Eingabe als String ein }

      GrGet_String (TEMP_STR, X, Y, OLDX, NUM_LENGTH,
                    RESP, DIRECTION, KeyResponse, oldwrite);

      {Teste ob Eingabe nicht mit Pfeilen oder Escape Abgeschlossen wurde}

      if (RESP <> Arrow) and (RESP <> Escape) then
      begin

         { Entferne Leerzeichen }

         while TEMP_STR[1] = ' ' do
            TEMP_STR := copy (TEMP_STR, 2, Length (TEMP_STR));

            { Versuche den String in eine Integer-Zahl umzuwandeln }

            Val (TEMP_STR, TEMP_INT, VALCODE);

            IF VALCODE = 0 then
            begin
               {Teste ob der Wert im erlaubten Bereich ist}

               if (TEMP_INT >= IValMin) and (TEMP_INT <= IValMax) then
               begin

                  { Wandle den Integer in einen String mit entsprechendem
                    Format zurÅck und gib ihn erneut auf dem Bildschirm aus }

                  NUMBER := TEMP_INT;
                  if oldwrite then
                  begin
                     Str (NUMBER:NUM_LENGTH, TEMP_STR);
                     IniOutTextXY(OLDX, Y, TEMP_STR);
                  end;
               end
               else {if (TEMP_INT >= IValMin) and (TEMP_INT <= IValMax)}
               begin
                  if oldwrite then
                  begin
                     VALCODE:=1;
                     IniOutTextXY(OLDX, Y, ORIGINAL_STR);
                  end;
               end  {else if (TEMP_INT >=}
            end {if VALCODE = 0}
            else
            begin
               if oldwrite then
               begin
                  IniOutTextXY(OLDX, Y, ORIGINAL_STR);
               end;
            end;
      end
      else {if (RESP <> Arrow) and (RESP <> Escape)}
         VALCODE := 0;

   until VALCODE = 0;

end;

{-------------------------------------------------------------------}
procedure GrGet_Toggle (var tval: integer;
                        tValMin, tValMax: integer;
                        var tstrings: toggletyp;
                        DESCX, DESCY: integer;
                        OLDESCX: integer;
                        NUM_LENGTH: integer;
                        var  RESP: RESPONSE_TYPE;
                        var DIRECTION: MOVEMENT;
                        var KeyResponse: char);


begin
   repeat
      Get_Response(resp, direction, keyresponse);

      {Testen ob die Eingabe nicht mit Pfeilen oder ESC abgeschlossen wurde}
      if ((resp <> arrow) and (resp <> escape)) then
      begin
         if KeyResponse = ' ' then
         begin
            {gib neuen Wert am Bildschirm aus}
            if tval + tvalmin <= tvalmax then tval:= tval + 1
            else tval:= 1;
            IniExpand(tstrings[tval + tvalmin - 1], fieldlength);
            IniInversText(oldescx, descy, tstrings[tval + tvalmin - 1]);
         end;
      end;
   until ((resp = arrow) or (resp = escape));
end;

{-------------------------------------------------------------------}
procedure GrGet_Prompted_String (var IN_STRING: STRING16;
                                    STR_LENGTH: integer;
                                       STRDESC: char;
                                  DESCX, DESCY: integer;
                                       OLDESCX: integer;
                                        PROMPT: STRING79;
                                      PRX, PRY: integer;
                                      prlength: integer;
                                     var  RESP: RESPONSE_TYPE;
                                 var DIRECTION: MOVEMENT;
                              var KeyResponse: char;
                                     oldwrite: boolean);
{
BESCHREIBUNG:
    Dieses Unterprogramm liest einen String an einer bestimmten
    Stelle des Bildschirm ein und schreibt eine Benutzeraufforderung
    (=Prompt) auf den Bildschirm.

PARAMETER:
    IN_STRING (Ein-/Ausgabe) - Einzulesender String
    STR_LENGTH (Eingabe)     - LÑnge des einzugebenden Strings [1-79]
    STRDESC                  - Beschreibung des Strings (erscheint
                               in erhîhter Helligkeit)
    DESCX, DESCY, OLDESCX    - Position
    PROMPT (Eingabe)         - Benutzeraufforderung zur Eingabe
    PRX, PRY                 - Position, in der die Benutzerauf-
                               forderung stehen soll
    RESP (Ausgabe)           - Gibt an, ob der BenÅtzer die Eingabe mit
                               Return, den Pfeiltasten oder mit
                               ESCAPE beendet hat.
    DIRECTION (Ausgabe)      - Richtung der Pfeiltaste
    KeyResponse (Ausgabe)    - Zuletzt gedrÅcktes Zeichen

 BENôTIGTE TYPEN:
    STRING79 - Wird fÅr alle Strings verwendet

-------------------------------------------------------------------}
VAR i : integer;

begin

{ Gib die Beschreibung der vorzunehmenden Eingabe in erhîhter
   Helligkeit aus und zeige die Benutzeraufforderung an }

  IniInversText (DESCX - 1, DESCY, ' ' + STRDESC + ' ');
  IniExpand(prompt, prlength);
  IniInversText (PRX - 1, PRY, ' ' + PROMPT);

{ Nimm die Eingabe vor }

  GrGet_String (IN_STRING, DESCX + 2, DESCY, OLDESCX,
                STR_LENGTH, RESP, DIRECTION, KEYRESPONSE, oldwrite);
end;

{-------------------------------------------------------------}
procedure GrGet_Prompted_Integer (var INNUMBER: integer;
                            IValMin, IValMax: integer;
                                  NUM_LENGTH: integer;
                                     STRDESC: Char;
                                DESCX, DESCY: integer;
                                     OLDESCX: integer;
                                      PROMPT: STRING79;
                                    PRX, PRY: integer;
                                    prlength: integer;
                                   var  RESP: RESPONSE_TYPE;
                               var DIRECTION: MOVEMENT;
                             var KeyResponse: char;
                                    oldwrite: boolean);

{
BESCHREIBUNG:
    Dieses Unterprogramm liest eine Integer-Zahl an einer bestimmten
    Stelle des Bildschirms ein. Rest siehe bei GrGet_Prompted_String.
-------------------------------------------------------------------}

VAR i : integer;

begin

{ Gib die Beschreibung der vorzunehmenden Eingabe in erhîhter
   Helligkeit aus und zeige die Benutzeraufforderung an }

  IniInversText (DESCX - 1, DESCY, ' ' + STRDESC + ' ');
  IniExpand(prompt, prlength);
  IniInversText (PRX - 1, PRY, ' ' + PROMPT);

{ Nimm die Eingabe vor }

  GrGet_Integer (INNUMBER, IValMin, IValMax,
                 DESCX + 2, DESCY, OLDESCX,
                 NUM_LENGTH, RESP, DIRECTION, KEYRESPONSE, oldwrite);

end;

{-------------------------------------------------------------------}
procedure GrGet_Prompted_Toggle (var tval: integer;
                                 tValMin, tValMax: integer;
                                 var tstrings: toggletyp;
                                 NUM_LENGTH: integer;
                                 STRDESC: Char;
                                 DESCX, DESCY: integer;
                                 OLDESCX: integer;
                                 PROMPT: STRING79;
                                 PRX, PRY: integer;
                                 prlength: integer;
                                 var  RESP: RESPONSE_TYPE;
                                 var DIRECTION: MOVEMENT;
                                 var KeyResponse: char);

VAR i : integer;
    outstring: string79;

begin

{ Gib die Beschreibung der vorzunehmenden Eingabe in erhîhter
   Helligkeit aus und zeige die Benutzeraufforderung an }

   IniExpand(tstrings[tval + tvalmin - 1], fieldlength);
   IniInversText(oldescx, descy, tstrings[tval + tvalmin - 1]);
   outstring:= 'toggle';
   IniExpand(outstring, fieldlength);
   IniInversText (DESCX - 1, DESCY, ' ' + STRDESC + ' ' + outstring);
   IniExpand(prompt, prlength);
   IniInversText (PRX - 1, PRY, ' ' + PROMPT);

   { Nimm die Eingabe vor }

   GrGet_Toggle (tval, tvalmin, tvalmax, tstrings,
                 DESCX + 2, DESCY, OLDESCX, num_length,
                 RESP, DIRECTION, KEYRESPONSE);

end;

end.
