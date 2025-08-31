{$I RNS.H}

Unit inout;

Interface

Uses
    menutyp,
    xcrt,
    crt;

Procedure Set_Video(ATTRIBUTE: integer);
Procedure Get_Response(Var RESPONSE: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KeyResponse: char;
    Var shiftp, ctrlp: boolean;
    Var mausx, mausy: word;
    Var maustaste, mp, mausmenu: word);
Procedure Put_String(COL, LINE: integer; OUT_STRING: STRING;
    ATTRIB: integer);

Procedure Put_Centered_String(OUT_STRING: STRING;
    LINE, ATTRIB: integer);


Implementation

Uses
    initsc,
    mousdrv;

{***********************************************************}
Procedure Set_Video(ATTRIBUTE: integer);

Begin
    If attribute = 0 Then
    Begin
        TextBackground (tmbk);
        TextColor (tmtext);
    End
    Else
    Begin
        TextBackground (itmbk);
        TextColor (itmtext);
    End;

End;

{***********************************************************}
Procedure Get_Response(Var RESPONSE: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KeyResponse: char;
    Var shiftp, ctrlp: boolean;
    Var mausx, mausy: word;
    Var maustaste, mp, mausmenu: word);
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

Const
    BELL = 7;  { ASCII Signalton }
    CARRIAGE_RETURN = 13; { ASCII WagenrÅcklauf }
    ESC  = 27; { ASCII Escape Zeichen }
    RIGHT_ARROW = 77; { IBM Escape Sequenz fÅr den
                             Pfeil nach rechts }
    LEFT_ARROW = 75; { IBM Escape Sequenz fÅr den
                             Pfeil nach links }
    DOWN_ARROW = 80; { IBM Escape Sequenz fÅr den
                             Pfeil nach unten }
    UP_ARROW = 72; { IBM Escape Sequenz fÅr den
                             Pfeil nach oben }

Var
    IN_CHAR: char;    { TemporÑre Variable fÅr die Eingabe }
    tempshift, tempctrl: boolean;
Begin
    RESPONSE := NO_RESPONSE;
    DIRECTION := NONE;
    KeyResponse := ' ';
    MausZeigen;

    Repeat
        If XKeyPressed Then
        Begin
            IN_CHAR := xReadKey (shiftp, ctrlp);

         { PrÅfe, ob es sich um Pfeiltasten handelt - d.h. eine Eingabe mit
           zwei Zeichen, wobei 0 das erste Zeichen ist }
            If Ord (IN_CHAR) = 0 Then
            Begin
                RESPONSE := ARROW;
                IN_CHAR  := xReadKey (tempshift, tempctrl);
                KeyResponse := IN_CHAR;

                If Ord (IN_CHAR) = LEFT_ARROW Then
                    DIRECTION := LEFT
                Else
                Begin
                    If Ord (IN_CHAR) = RIGHT_ARROW Then
                        DIRECTION := RIGHT
                    Else
                    If Ord (IN_CHAR) = DOWN_ARROW Then
                        DIRECTION := DOWN
                    Else
                    If Ord (IN_CHAR) = UP_ARROW Then
                        DIRECTION := UP
                    { Sonst ein Spezialzeichen }
                    Else
                    Begin
                        RESPONSE := SpecialKey;
                        KeyResponse := IN_CHAR;
                    End;
                End;
            End
            Else
            Begin
                If Ord (IN_CHAR) = CARRIAGE_RETURN Then
                Begin
                    RESPONSE := RETURN;
                    KeyResponse := IN_CHAR;
                End
                Else
                If Ord (IN_CHAR) = ESC Then
                Begin
                    KeyResponse := IN_CHAR;
                    RESPONSE := ESCAPE;
                End
                Else
                Begin
                    RESPONSE := KEY;
                    KeyResponse := IN_CHAR;
                End;
            End;
        End
        Else {if XKeyPressed then}
        Begin
            {Maustaste gedrÅckt?}
            MausPosition (mausx, mausy, maustaste, mp, mausmenu);
            If ((maustaste = 1) AND (mausform <> 1)) Then
            Begin
                RESPONSE := RETURN;
                keyresponse := #13;
            End;
            If maustaste = 2 Then
            Begin
                RESPONSE := ESCAPE;
                keyresponse := #27;
            End;

        End;
    Until ((RESPONSE <> NO_RESPONSE) OR (maustaste > 0) OR (mp > 0));
End;

{------------------------------------------------------------------}
{------------------------------------------------------------------}

Procedure Put_String(COL, LINE: integer; OUT_STRING: STRING;
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
    STRING - Wird fÅr alle Strings verwendet

BENUTZTE BIBLIOTHEKSPROGRAMME:
    Set_Video - Setzt Bildschirmattribute

---------------------------------------------------------------------}
Begin

    { Setze die Bildschirmattribute und die Cursor-Stellung }

    Set_Video (ATTRIB);
    GotoXY (COL, LINE);
    write (OUT_STRING);

    { Stelle die normalen Bildschirmattribute wieder her }

    Set_Video (0);
End;

{-------------------------------------------------------------------}

Procedure Put_Centered_String(OUT_STRING: STRING;
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
    STRING - Wird fÅr alle Strings verwendet

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
Begin

    { Berechne die Spaltennummer und gebe den String aus }

    Put_String (40 - Length (OUT_STRING) DIV 2, LINE, OUT_STRING, ATTRIB);
End;

{-------------------------------------------------------------------}

End.
