  {$F-}               { Force Far Calls    }
  {$R+}               { Range Check        }
  {$Q+}               { Overflow Check     }
  {$S+}               { Stack Check        }
  {$I+}               { IO-Check           }
  {$A-}               { Word align Data    }
  {$G+}               { 286 Code           }
  {$V-}               { Strict VAR Strings }
  {$B-}               { Boolean Eval       }
  {$T-}               { Typed @            }
  {$P-}               { Open Params        }
  {$X+}               { Extended Syntax    }
  {$N-}               { Coprocessor        }
  {$E-}               { Emulation          }
  {$D-}               { Debug information  }
  {$L-}               { Local Symbols      }
  {$Y-}               { Symbol information }
  {$O-}               { Overlay Code       }

unit inout;

interface

uses menutyp,
     xcrt,
     crt;

procedure Set_Video (ATTRIBUTE: integer);
procedure Get_Response (var RESPONSE     : RESPONSE_TYPE;
                        var DIRECTION   : MOVEMENT;
                        var KeyResponse   : char;
                        var shiftp, ctrlp: boolean;
                        var mausx, mausy: word;
                        var maustaste, mp, mausmenu: word);
procedure Put_String (COL, LINE : integer; OUT_STRING: STRING79;
                      ATTRIB: integer);

procedure Put_Centered_String (OUT_STRING: STRING79;
                             LINE, ATTRIB: integer);


implementation

uses initsc,
     mousdrv;

{***********************************************************}
procedure Set_Video (ATTRIBUTE: integer);

begin
   if attribute = 0 then
   begin
      TextBackground(tmbk);
      TextColor(tmtext);
   end
   else
   begin
      TextBackground(itmbk);
      TextColor(itmtext);
   end;

end;

{***********************************************************}
procedure Get_Response (var RESPONSE     : RESPONSE_TYPE;
                        var DIRECTION   : MOVEMENT;
                        var KeyResponse   : char;
                        var shiftp, ctrlp: boolean;
                        var mausx, mausy: word;
                        var maustaste, mp, mausmenu: word);
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
  tempshift, tempctrl: boolean;
begin
   RESPONSE := NO_RESPONSE;
   DIRECTION := NONE;
   KeyResponse := ' ';
   MausZeigen;

   repeat
      if XKeyPressed then
      begin
         IN_CHAR:=xReadKey(shiftp, ctrlp);

         { PrÅfe, ob es sich um Pfeiltasten handelt - d.h. eine Eingabe mit
           zwei Zeichen, wobei 0 das erste Zeichen ist }
         if Ord(IN_CHAR) = 0 then
         begin
            RESPONSE := ARROW;
            IN_CHAR:=xReadKey(tempshift, tempctrl);
            KeyResponse := IN_CHAR;

            if Ord(IN_CHAR) = LEFT_ARROW then
            begin
               DIRECTION := LEFT;
            end
            else
            begin
               if Ord(IN_CHAR) = RIGHT_ARROW then
               begin
                  DIRECTION := RIGHT;
               end
               else
               begin
                  if Ord(IN_CHAR) = DOWN_ARROW then
                  begin
                     DIRECTION := DOWN;
                  end
                  else
                  begin
                     if Ord(IN_CHAR) = UP_ARROW then
                     begin
                        DIRECTION := UP;
                     end
                     { Sonst ein Spezialzeichen }
                     else
                     begin
                        RESPONSE := SpecialKey;
                        KeyResponse := IN_CHAR;
                     end;
                  end;
               end;
            end;
         end
         else
         begin
            if Ord(IN_CHAR) = CARRIAGE_RETURN then
            begin
               RESPONSE := RETURN;
               KeyResponse := IN_CHAR;
            end
            else
            begin
               if Ord(IN_CHAR) = ESC then
               begin
                  KeyResponse := IN_CHAR;
                  RESPONSE := ESCAPE;
               end
               else
               begin
                  RESPONSE := KEY;
                  KeyResponse := IN_CHAR;
               end;
            end;
         end;
      end
      else {if XKeyPressed then}
      begin
         {Maustaste gedrÅckt?}
         MausPosition(mausx, mausy, maustaste, mp, mausmenu);
         if ((maustaste = 1) and (mausform <> 1)) then
         begin
            RESPONSE:= RETURN;
            keyresponse:= #13;
         end;
         if maustaste = 2 then
         begin
            RESPONSE:= ESCAPE;
            keyresponse:= #27;
         end;

      end;
   until ((RESPONSE <> NO_RESPONSE) or (maustaste > 0) or (mp>0));
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
