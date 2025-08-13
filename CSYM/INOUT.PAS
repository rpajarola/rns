Unit inout;

interface

uses menutyp, crt;


procedure Set_Video (ATTRIBUTE: integer);
procedure Get_Response (var RESPONSE     : RESPONSE_TYPE;
                        var DIRECTION   : MOVEMENT;
                        var KeyResponse   : char);
procedure Put_String (COL, LINE : integer; OUT_STRING: STRING79;
                      ATTRIB: integer);

procedure Put_Centered_String (OUT_STRING: STRING79;
                             LINE, ATTRIB: integer);


implementation

uses initsc;

{***********************************************************}
procedure Set_Video (ATTRIBUTE: integer);

begin
   if attribute = 0 then
   begin
      TextBackground(menubkcolor);
      TextColor(menutextcolor);
   end
   else
   begin
      TextBackground(imenubkcolor);
      TextColor(imenutextcolor);
   end;
end;

{***********************************************************}
procedure Get_Response (var RESPONSE     : RESPONSE_TYPE;
                        var DIRECTION   : MOVEMENT;
                        var KeyResponse   : char);
{
 BESCHREIBUNG:
    Dieses Unterprogramm liest ein Zeichen von der Tastatur ein und
    kategorisiert es entweder als Pfeiltaste, WagenrÅcklauf, ESCAPE oder als
    anderes Zeichen. Pfeile werden nach Richtung unterschieden.

PARAMETER:
    RESPONSE (Ausgabe)  - Art der Antwort ( vgl den Typ RESPONSE_TYPE)
    DIRECTION (Ausgabe) - Richtung der gedrÅckten Pfeiltaste, wenn
                          Åberhaupt
    KeyResponse (Ausgabe) - Eingegebene Taste, wenn Åberhaupt

  BENôTIGTE TYPEN:
    RESPONSE_TYPE = (NO_RESPONSE, ARROW, KEY, RETURN, ESCAPE SPECIALKEY) -
       Wird zur Unterscheidungder gegebenen Antwort verwendet
       (NO_RESPONSE sollte niemals Åbergeben werden)
    MOVEMENT = (NONE, LEFT, RIGHT, UP, DOWN) -
       Wird zur Unterscheidung der Pfeilrichtung verwendet

BEISPIELHAFTER AUFRUF:
    Get_Response (RTYPE, ARROW_DIR, KEY_ENTERED);

-------------------------------------------------------------------}

const
  BELL            = 7;  { ASCII Signalton }
  CARRIAGE_RETURN = 13; { ASCII WagenrÅcklauf }
  ESC             = 27; { ASCII Escape Zeichen }
  RIGHT_ARROW     = 77; { IBM Escape Sequenz fÅr den
                             Pfeil nach rechts }
  LEFT_ARROW      = 75; { IBM Escape Sequenz fÅr den
                             Pfeil nach links }
  DOWN_ARROW      = 80; { IBM Escape Sequenz fÅr den
                             Pfeil nach unten }
  UP_ARROW        = 72; { IBM Escape Sequenz fÅr den
                             Pfeil nach oben }

var
  IN_CHAR: char;    { TemporÑre Variable fÅr die Eingabe }

begin
  RESPONSE := NO_RESPONSE;
  DIRECTION := NONE;
  KeyResponse := ' ';

{ Bilde so lange eine Schleife, bis eine gÅltige Taste gedrÅckt
   wurde }

  repeat
    IN_CHAR:=ReadKey;

 { PrÅfe, ob es sich um Pfeiltasten handelt - d.h. eine Eingabe mit
   zwei Zeichen, wobei ESCAPE das erste Zeichen ist }

    if Ord(IN_CHAR) = 0 then
      begin
        RESPONSE := ARROW;

{ Pfeile sind Antworten die aus zwei Zeichen bestehen }

        IN_CHAR:=ReadKey;
        KeyResponse := IN_CHAR;

        if Ord(IN_CHAR) = LEFT_ARROW then
         DIRECTION := LEFT
        else if Ord(IN_CHAR) = RIGHT_ARROW then
         DIRECTION := RIGHT
        else if Ord(IN_CHAR) = DOWN_ARROW then
         DIRECTION := DOWN
        else if Ord(IN_CHAR) = UP_ARROW then
         DIRECTION := UP

{ Sonst ein Spezialzeichen }

        else
          begin
            RESPONSE := SpecialKey;
            KeyResponse := IN_CHAR;
          end;
        end

{ PrÅfe, ob ein WagenrÅcklauf (Return) erfolgte }

      else if Ord(IN_CHAR) = CARRIAGE_RETURN then
      begin
        RESPONSE := RETURN;
        KeyResponse := IN_CHAR;
      end

{ PrÅfe, ob ein ESCAPE erfolgte }

      else if Ord(IN_CHAR) = ESC then
      begin
        KeyResponse := IN_CHAR;
        RESPONSE := ESCAPE;
     end

{ PrÅfe, ob irgendein anderes Zeichen eingegeben wurde}

      else
         begin
          RESPONSE := KEY;
          KeyResponse := IN_CHAR;
        end;
      until RESPONSE <> NO_RESPONSE;
  end;

{------------------------------------------------------------------}
{------------------------------------------------------------------}

procedure Put_String (COL, LINE : integer; OUT_STRING: STRING79;
                      ATTRIB: integer);
{
BESCHREIBUNG:
    Dieses Unterprogramm gibt einen String an einer bestimmten
    Stelleauf dem Bildschirm aus und setzt ganz bestimmte Bild-
    schirmattribute.

PARAMETER:
    OUT_STRING (Eingabe) - Auszugebender String
    LINE (Eingabe)       - Bildschirmzeile [1-24]
    COL  (Eingabe)       - Bildschirmspalte [1-80]
    ATTRIBUTE (Eingabe)  - Bildschirmattribute [0-7]

BENôTIGTE TYPEN:
    STRING79 - Wird fÅr alle Strings verwendet

BENUTZTE BIBLIOTHEKSPROGRAMME:
    Set_Video - Setzt Bildschirmattribute

---------------------------------------------------------------------}
begin

{ Setze die Bildschirmattribute und die Cursor-Stellung }

  Set_Video(ATTRIB);
  GotoXY(COL,LINE);
  write (OUT_STRING);

{ Stelle die normalen Bildschirmattribute wieder her }

  Set_Video(0);
end;

{-------------------------------------------------------------------}

procedure Put_Centered_String (OUT_STRING: STRING79;
                             LINE, ATTRIB: integer);
{
BESCHREIBUNG:
    Dieses Unterprogramm gibt einen String in der Mitte einer anzu-
    gebenden Zeile auf dem Bildschirm aus und setzt ganz bestimmte
    Bildschirmattribute.

PARAMETER:
    OUT_STRING (Eingabe) - Auszugebender String
    LINE (Eingabe)       - Bildschirmzeile [1-24]
    ATTRIBUTE (Eingabe)  - Bildschirmattribute [0-7]

 BENôTIGTE TYPEN:
    STRING79 - Wird fÅr alle Strings verwendet

BENUTZTE BIBLIOTHEKSPROGRAMME:
    Put_String - Gibt einen String an einer bestimmten Bildschirm-
                 stelle aus
    Set_Video  - Setzt Bildschirmattribute

BEISPIELHAFTER AUFRUF:
    Put_Centered_String ('Dies ist ein Beispiel fÅr einen Titel', 5, 3);

 ANMERKUNGEN:
    Vgl. das Unterprogramm Set_Video fÅr den Code der Bildschirm-
    attribute.
    Die Zentrierung wird dadurch erreicht, da· die Anfangsspalte auf
    40 - LÑnge/2 gesetzt wird.
---------------------------------------------------------------------}
begin

{ Berechne die Spaltennummer und gebe den String aus }

  Put_String (40 - Length (OUT_STRING) div 2, LINE, OUT_STRING, ATTRIB);
end;

{-------------------------------------------------------------------}

end.
