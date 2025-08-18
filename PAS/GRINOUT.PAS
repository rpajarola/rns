Unit grinout;

Interface

Uses menutyp,
    crt,
    inout,
    gcurunit,
    initsc,
    graph,
    MousDrv;


Procedure GrPut_Integer(NUMBER, X, Y, NUM_LENGTH: integer);

Procedure GrPut_Real(NUMBER: Real; X, Y, NUM_LENGTH: integer);{New}

Procedure GrPut_Prompt(OUT_STRING: string79; X, Y: integer);

Procedure GrGet_String(Var IN_STRING: STRING16;
    X, Y, OLDX, STR_LENGTH: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KEYRESPONSE: char;
    oldwrite: boolean;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);
Procedure GrGet_Spaced_String(Var IN_STRING: STRING16;
    X, Y, OLDX, STR_LENGTH: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KEYRESPONSE: char;
    oldwrite: boolean;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);
Procedure GrGetUpcase_String(Var IN_STRING: STRING16;
    X, Y, STR_LENGTH: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KEYRESPONSE: char;
    oldwrite: boolean;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);
Procedure GrGet_Integer(Var NUMBER: integer;
    IValMin, IValMax: integer;
    X, Y, OLDX, NUM_LENGTH: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KeyResponse: char;
    oldwrite: boolean;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);

Procedure GrGet_Prompted_String(Var IN_STRING: STRING16;
    STR_LENGTH: integer;
    STRDESC: char;
    DESCX, DESCY: integer;
    OLDESCX: integer;
    PROMPT: STRING79;
    PRX, PRY: integer;
    prlength: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KeyResponse: char;
    oldwrite: boolean;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);

Procedure GrGet_Prompted_Spaced_String(Var IN_STRING: STRING16;
    STR_LENGTH: integer;
    STRDESC: char;
    DESCX, DESCY: integer;
    OLDESCX: integer;
    PROMPT: STRING79;
    PRX, PRY: integer;
    prlength: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KeyResponse: char;
    oldwrite: boolean;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);
Procedure GrGet_Prompted_Real(Var RNNUMBER: Real;     {New}
    RValMin, RValMax: Real;
    NUM_LENGTH: integer;
    STRDESC: Char;
    DESCX, DESCY: integer;
    OLDESCX: integer;
    PROMPT: STRING79;
    PRX, PRY: integer;
    prlength: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KeyResponse: char;
    oldwrite: boolean;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);

Procedure GrGet_Prompted_Integer(Var INNUMBER: integer;
    IValMin, IValMax: integer;
    NUM_LENGTH: integer;
    STRDESC: Char;
    DESCX, DESCY: integer;
    OLDESCX: integer;
    PROMPT: STRING79;
    PRX, PRY: integer;
    prlength: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KeyResponse: char;
    oldwrite: boolean;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);

Procedure GrGet_Prompted_Toggle(Var tval: integer;
    tValMin, tValMax: integer;
    Var tstrings: toggletyp;
    NUM_LENGTH: integer;
    STRDESC: Char;
    DESCX, DESCY: integer;
    OLDESCX: integer;
    PROMPT: STRING79;
    PRX, PRY: integer;
    prlength: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KeyResponse: char;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);


Implementation

{------------------------------------------------------------------}

Procedure GrPut_Integer(NUMBER, X, Y, NUM_LENGTH: integer);
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
Var
    TEMP_STR: STRING79;

Begin

    { Wandle die Zahl in einen String um und gib den String aus }

    Str (NUMBER: NUM_LENGTH, TEMP_STR);
    IniOutTextXY (X, Y, TEMP_STR);
End;

{------------------------------------------------------------------}

Procedure GrPut_Real(NUMBER: Real; X, Y, NUM_LENGTH: integer);
{
BESCHREIBUNG:
    Dieses Unterprogramm gibt eine Real-Zahl an einer bestimmten
    Stelle auf dem Bildschirm aus.

PARAMETER:
    NUMBER_IN  (Eingabe) - Auszugebende Zahl
    X, Y                 - Position
    NUM_LENGTH (Eingabe) - Gesamtanzahl der zu benutzenden Stellen
                           (rechtsbÅndig) [2-80]

BENôTIGTE TYPEN:
    STRING79 - Wird fÅr alle Strings verwendet

---------------------------------------------------------------------}
Var
    TEMP_STR: STRING79;
    w: LongInt;
Begin

    { Wandle die Zahl in einen String um und gib den String aus }

    w := Round (NUMBER * 1000);
    Str (w, TEMP_STR);
    TEMP_STR := Copy (TEMP_STR, 1, Length (TEMP_STR) - 3) + '.' +
        Copy (TEMP_STR, Length (TEMP_STR) - 2, 3);
    If Copy (TEMP_STR, Length (TEMP_STR) - 2, 3) = '000' Then
        TEMP_STR := Copy (TEMP_STR, 1, Length (TEMP_STR) - 4);
    IniOutTextXY (X, Y, TEMP_STR);
End;

{------------------------------------------------------------------}

Procedure GrPut_Prompt(OUT_STRING: string79; X, Y: integer);
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
Begin

    { Lîsche die gesamte Zeile und gib den String aus }

    IniOutTextXY (X, Y, ClearString);
    IniOutTextXY (X, Y, OUT_STRING);
End;

{-------------------------------------------------------------------}

Procedure GrGet_Spaced_String(Var IN_STRING: STRING16;
    X, Y, OLDX, STR_LENGTH: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KEYRESPONSE: char;
    oldwrite: boolean;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);
Const
    BELL = 7;        { ASCII Signalton }
    BACK_SPACE = 8;        { ASCII RÅckschritt }
    CARRIAGE_RETURN = 13;       { ASCII WagenrÅcklauf }
    ESC  = 27;       { ASCII Escape Zeichen }
    RIGHT_ARROW = 77;       { IBM Escape Sequenz fÅr Pfeiltaste
                                 nach rechts }

Var
    OLDSTR: STRING79;          { Originaler String }
    clstring: string79;
    shiftp, ctrlp: boolean;
    mp: word;
Begin
{ Gib den String mit den entsprechenden Attributen auf dem
  Bildschirm aus }
    clstring := '';
    IniExpand (clstring, str_length);
    If oldwrite Then
    Begin
        IniSpacedText (OLDX, Y, ClString, frNoFrame);
        IniSpacedText (OLDX, Y, IN_STRING, frNoFrame);
    End;
    IniSpacedText (X, Y, ClString, frNoFrame);
    OLDSTR := IN_STRING;
    { Lies das erste Zeichen ein. Verwende bei RETURN den alten String }
    IniSpacedText (X, Y, '_', frNoFrame);
    IniShowCursor;
    Repeat
        Get_Response (Resp, Direction, KeyResponse, shiftp, ctrlp,
            mausx, mausy, maustaste, mp, mausmenu);
    Until (Resp <> No_Response) OR (maustaste <> 0);
    IniMausAssign (maustaste, resp);
    in_string := '';
    { Verarbeite jeweils nur ein Zeichen }
    While (Resp = Key) OR (resp = no_response) Do
    Begin
        { Wenn RÅckschritt gedrÅckt wurde, entferne das eingegebene Zeichen }
        If resp = key Then
            If Ord (KeyResponse) = BACK_SPACE Then  { RÅckschritt } Begin
                If length (IN_STRING) > 0 Then
                Begin
                    Dec (Byte (In_string[0]));
                    Dec (X);
                    If Length (In_string) < (Str_Length - 1) Then
                        IniSpacedText (X, Y, '_ ', frNoFrame)
                    Else
                        IniSpacedText (X, Y, '_', frNoFrame);
                End;
            End {if Ord}Else If Length (IN_STRING) < STR_LENGTH Then
            Begin
                IN_STRING := IN_STRING + KeyResponse;
                If Length (In_string) < Str_Length Then
                    IniSpacedText (X, Y, KeyResponse + '_', frNoFrame)
                Else
                    IniSpacedText (X, Y, KeyResponse, frNoFrame);
                Inc (X);
            End{ PrÅfe ob Pfeiltasten - bestehend aus 2 Zeichen mit ESCAPE als
  erstem Zeichen - gedrÅckt wurden }{ FÅge ein "normales" Zeichen" in den String ein }{if Length(IN_STRING) < STR_LENGTH}{if Ord else};
        Get_Response (Resp, Direction, KeyResponse, shiftp, ctrlp,
            mausx, mausy, maustaste, mp, mausmenu);
        IniMausAssign (maustaste, resp);
    End; {while}
    If Resp <> Return Then
        in_string := oldstr
    Else
        changed := true;
    IniHideCursor;
End;
{-------------------------------------------------------------------}
Procedure GrGet_String(Var IN_STRING: STRING16;
    X, Y, OLDX, STR_LENGTH: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KEYRESPONSE: char;
    oldwrite: boolean;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);
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

Const
    BELL = 7;        { ASCII Signalton }
    BACK_SPACE = 8;        { ASCII RÅckschritt }
    CARRIAGE_RETURN = 13;       { ASCII WagenrÅcklauf }
    ESC  = 27;       { ASCII Escape Zeichen }
    RIGHT_ARROW = 77;       { IBM Escape Sequenz fÅr Pfeiltaste
                                 nach rechts }

Var
    OLDSTR: STRING79;          { Originaler String }
    clstring: string79;
    shiftp, ctrlp: boolean;
    mp: word;
Begin
    x := x * 8 - 6;
    y := y * 8 + 6;
    oldx := oldx * 8 - 6;
{ Gib den String mit den entsprechenden Attributen auf dem
  Bildschirm aus }
    clstring := '';
    IniExpand (clstring, str_length);
    If oldwrite Then
    Begin
        IniInversWrite (OldX, Y, clString, frSmallBar);
        IniInversWrite (OldX, Y, In_String, frSmallBar);
    End;
    {### unterscheiden ob Dir-Eingabe oder z.B. Shift-F3, sonst Menu falsch}
    IniInversWrite (X, Y, ClString, frSmallBar);
    OLDSTR := IN_STRING;
    { Lies das erste Zeichen ein. Verwende bei RETURN den alten String }
    IniInversWrite (X, Y, '_', frSmallBar);
    IniShowCursor;
    Repeat
        Get_Response (Resp, Direction, KeyResponse, shiftp, ctrlp,
            mausx, mausy, maustaste, mp, mausmenu);
    Until (Resp <> No_Response) OR (maustaste <> 0);
    IniMausAssign (maustaste, resp);
    in_string := '';
    { Verarbeite jeweils nur ein Zeichen }
    While (Resp = Key) OR (resp = no_response) Do
    Begin
        { Wenn RÅckschritt gedrÅckt wurde, entferne das eingegebene Zeichen }
        If resp = key Then
            If Ord (KeyResponse) = BACK_SPACE Then  { RÅckschritt } Begin
                If length (IN_STRING) > 0 Then
                Begin
                    Dec (Byte (In_string[0]));
                    Dec (X, 6);
                    If Length (In_string) < (Str_Length - 1) Then
                        IniInversWrite (X, Y, '_ ', frSmallBar)
                    Else
                        IniInversWrite (X, Y, '_', frSmallBar);
                End;
            End {if Ord}Else If Length (IN_STRING) < STR_LENGTH Then
            Begin
                IN_STRING := IN_STRING + KeyResponse;
                If Length (In_string) < Str_Length Then
                    IniInversWrite (X, Y, KeyResponse + '_', frSmallBar)
                Else
                    IniInversWrite (X, Y, KeyResponse, frSmallBar);
                Inc (X, 6);
            End{ PrÅfe ob Pfeiltasten - bestehend aus 2 Zeichen mit ESCAPE als
  erstem Zeichen - gedrÅckt wurden }{ FÅge ein "normales" Zeichen" in den String ein }{if Ord};
        Get_Response (Resp, Direction, KeyResponse, shiftp, ctrlp,
            mausx, mausy, maustaste, mp, mausmenu);
        IniMausAssign (maustaste, resp);
    End; {while}
    If Resp <> Return Then
        in_string := oldstr
    Else
        changed := true;
    IniHideCursor;
End;
{-------------------------------------------------------------------}
Procedure GrGetUpcase_String(Var IN_STRING: STRING16;
    X, Y, STR_LENGTH: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KEYRESPONSE: char;
    oldwrite: boolean;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);
{
BESCHREIBUNG:
    Dieses Unterprogramm liest einen String von einer bestimmten
    Stelle des Bildschirms ein und berÅcksichtigt bestehende Bild-
    schirmattribute.

PARAMETER:
    IN_STRING (Ein-/Ausgabe) - Einzulesender String
    X, Y                     - Position
    Pos                      - Position im String
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

Const
    BELL = 7;        { ASCII Signalton }
    BACK_SPACE = 8;        { ASCII RÅckschritt }
    CARRIAGE_RETURN = 13;       { ASCII WagenrÅcklauf }
    ESC  = 27;       { ASCII Escape Zeichen }
    RIGHT_ARROW = 77;       { IBM Escape Sequenz fÅr Pfeiltaste
                                 nach rechts }

Var
    OLDSTR: STRING79;          { Originaler String }
    clstring: string79;
    shiftp, ctrlp: boolean;
    mp: word;
Begin
  { Gib den String mit den entsprechenden Attributen auf dem
    Bildschirm aus }
    clstring := '';
    IniExpand (clstring, str_length);
    If NOT oldwrite Then
        IniSpacedWrite (X, Y, ClString, frNoFrame)
    Else IniSpacedWrite (X, Y, IN_STRING, frNoFrame);
    OLDSTR := IN_STRING;
    { Lies das erste Zeichen ein. Verwende bei RETURN den alten String }
    IniInversWrite (X, Y, In_String + '_', frNoFrame);
    IniShowCursor;
    Get_Response (Resp, Direction, KeyResponse, shiftp, ctrlp,
        mausx, mausy, maustaste, mp, mausmenu);
    IniMausAssign (maustaste, resp);
    {   in_string:= '';}
    { Verarbeite jeweils nur ein Zeichen }

    While (Resp = Key) Do
    Begin
        { Wenn RÅckschritt gedrÅckt wurde, entferne das eingegebene Zeichen }
        If Byte (KeyResponse) = BACK_SPACE Then  { RÅckschritt } Begin
            If length (IN_STRING) > 0 Then
            Begin
                Dec (Byte (In_string[0]));
                If Length (In_string) < Str_Length - 1 Then
                    IniInversWrite (X, Y, In_String + '_ ', frSmallBar)
                Else
                    IniInversWrite (X, Y, In_String + '_', frSmallBar);
            End;
        End {if Byte}Else If Byte (IN_STRING[0]) < STR_LENGTH Then
        Begin
            IN_STRING := IN_STRING + UpCase (KeyResponse);
            If Length (In_string) < Str_Length Then
                IniInversWrite (X, Y, In_String + '_', frSmallBar)
            Else
                IniInversWrite (X, Y, In_String, frSmallBar);
        End{ PrÅfe ob Pfeiltasten - bestehend aus 2 Zeichen mit 0 als
  erstem Zeichen - gedrÅckt wurden
  FÅge ein "normales" Zeichen" in den String ein }; {if Byte Else}
        Get_Response (Resp, Direction, KeyResponse, shiftp, ctrlp,
            mausx, mausy, maustaste, mp, mausmenu);
        IniMausAssign (maustaste, resp);
    End; {while}
    If Resp <> return Then
        in_string := oldstr
    Else
        changed := true;
    IniHideCursor;
End;
{-------------------------------------------------------------------}
Procedure GrGet_Real(Var NUMBER: real;
    RValMin, RValMax: real;
    X, Y, OLDX, NUM_LENGTH: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KeyResponse: char;
    oldwrite: boolean;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);
{
BESCHREIBUNG:
    Dieses Unterprogramm liest eine Integer-Zahl von einer bestimmten
    Stelle des Bildschirms ein.

PARAMETER:
    NUMBER (Ein-/Ausgabe)    - Einzulesende Zahl
    RValMin (Eingabe)        - Minimaler erlaubter Wert
    RValMax (Eingabe)        - Maximaler erlaubter Wert
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

Const
    BELL = 7;                  { ASCII Signalton }
Var
    VALCODE: integer;  { Code fÅr die String-Umwandlung }
    ORIGINAL_STR,              { Originaler String }
    TEMP_STR: string16; { Von Tastatur eingegebener String }
    TEMP_Real: real;     { Versuchte Umwandlung des Strings }
    w: LongInt;
Begin
    IniShowCursor;
    Str (NUMBER, ORIGINAL_STR);

    w := Round (NUMBER * 1000);
    Str (w, ORIGINAL_STR);
    Original_Str := Copy (Original_Str, 1, Length (Original_Str) - 3) + '.' +
        Copy (Original_Str, Length (Original_Str) - 2, 4);
    If Copy (ORIGINAL_STR, Length (ORIGINAL_STR) - 2, 3) = '000' Then
        Original_STR := Copy (ORIGINAL_STR, 1, Length (ORIGINAL_STR) - 4);
    { Probiere weiterhin, bis nur noch Ziffern eingegeben werden }
    Repeat
        TEMP_STR := Original_Str;
        { Lies die Eingabe als String ein }
        GrGet_String (TEMP_STR, X, Y, OLDX, NUM_LENGTH,
            RESP, DIRECTION, KeyResponse, oldwrite,
            mausx, mausy, maustaste, mausmenu, changed);
        IniMausAssign (maustaste, resp);
        {Teste ob Eingabe nicht mit Pfeilen oder Escape Abgeschlossen wurde}
        If (RESP <> Arrow) AND (RESP <> Escape) Then
        Begin
            { Entferne Leerzeichen }
            While (TEMP_STR[1] = ' ') AND (Length (TEMP_STR) <> 0) Do
                TEMP_STR := copy (TEMP_STR, 2, Length (TEMP_STR));
            { Versuche den String in eine Real-Zahl umzuwandeln }
            Val (TEMP_STR, TEMP_Real, VALCODE);
            If VALCODE = 0 Then
            Begin
                {Teste ob der Wert im erlaubten Bereich ist}
                If (TEMP_Real >= RValMin) AND (TEMP_Real <= RValMax) Then
                Begin
                  { Wandle den Real in einen String mit entsprechendem
                    Format zurÅck und gib ihn erneut auf dem Bildschirm aus }
                    NUMBER := TEMP_Real;
                    If oldwrite Then
                    Begin
                        w := Round (NUMBER * 1000);
                        Str (w, ORIGINAL_STR);
                        Original_Str := Copy (Original_Str, 1, Length (Original_Str) - 3) + '.' +
                            Copy (Original_Str, Length (Original_Str) - 2, 4);
                        If Copy (ORIGINAL_STR, Length (ORIGINAL_STR) - 2, 3) = '000' Then
                            Original_STR := Copy (ORIGINAL_STR, 1, Length (ORIGINAL_STR) - 4);
                        IniOutTextXY (OLDX, Y, TEMP_STR);
                    End;
                End
                Else {if (TEMP_Real >= RValMin) and (TEMP_Real <= RValMax)}
                Begin
                    If oldwrite Then
                    Begin
                        VALCODE := 1;
                        IniOutTextXY (OLDX, Y, ORIGINAL_STR);
                    End;
                End;  {else if (TEMP_Real >=}
            End {if VALCODE = 0}
            Else
            Begin
                If maustaste = 1 Then
                    valcode := 0
                Else
                If oldwrite Then
                    IniOutTextXY (OLDX, Y, ORIGINAL_STR);
            End;
        End
        Else {if (RESP <> Arrow) and (RESP <> Escape)} VALCODE := 0;
    Until VALCODE = 0;
    IniHideCursor;
End;
{-------------------------------------------------------------------}
Procedure GrGet_Integer(Var NUMBER: integer;
    IValMin, IValMax: integer;
    X, Y, OLDX, NUM_LENGTH: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KeyResponse: char;
    oldwrite: boolean;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);
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
Const
    BELL = 7;                  { ASCII Signalton }
Var
    VALCODE: integer;  { Code fÅr die String-Umwandlung }
    ORIGINAL_STR,              { Originaler String }
    TEMP_STR: string16; { Von Tastatur eingegebener String }
    TEMP_INT: integer;  { Versuchte Umwandlung des Strings }
Begin
    IniShowCursor;
    Str (NUMBER, ORIGINAL_STR);
    { Probiere weiterhin, bis nur noch Ziffern eingegeben werden }
    Repeat
        TEMP_STR := Original_Str;
        { Lies die Eingabe als String ein }
        GrGet_String (TEMP_STR, X, Y, OLDX, NUM_LENGTH,
            RESP, DIRECTION, KeyResponse, oldwrite,
            mausx, mausy, maustaste, mausmenu, changed);
        IniMausAssign (maustaste, resp);
        {Teste ob Eingabe nicht mit Pfeilen oder Escape Abgeschlossen wurde}
        If (RESP <> Arrow) AND (RESP <> Escape) Then
        Begin
            { Entferne Leerzeichen }
            While TEMP_STR[1] = ' ' Do
                TEMP_STR := copy (TEMP_STR, 2, Length (TEMP_STR));
            { Versuche den String in eine Integer-Zahl umzuwandeln }
            Val (TEMP_STR, TEMP_INT, VALCODE);
            If VALCODE = 0 Then
            Begin
                {Teste ob der Wert im erlaubten Bereich ist}
                If (TEMP_INT >= IValMin) AND (TEMP_INT <= IValMax) Then
                Begin
                  { Wandle den Integer in einen String mit entsprechendem
                    Format zurÅck und gib ihn erneut auf dem Bildschirm aus }
                    NUMBER := TEMP_INT;
                    If oldwrite Then
                    Begin
                        Str (NUMBER: NUM_LENGTH, TEMP_STR);
                        IniOutTextXY (OLDX, Y, TEMP_STR);
                    End;
                End
                Else {if (TEMP_INT >= IValMin) and (TEMP_INT <= IValMax)}
                Begin
                    If oldwrite Then
                    Begin
                        VALCODE := 1;
                        IniOutTextXY (OLDX, Y, ORIGINAL_STR);
                    End;
                End;  {else if (TEMP_INT >=}
            End {if VALCODE = 0}
            Else
            Begin
                If maustaste = 1 Then
                    valcode := 0
                Else
                If oldwrite Then
                    IniOutTextXY (OLDX, Y, ORIGINAL_STR);
            End;
        End
        Else {if (RESP <> Arrow) and (RESP <> Escape)}VALCODE := 0;
    Until VALCODE = 0;
    IniHideCursor;
End;

{-------------------------------------------------------------------}
Procedure GrGet_Toggle(Var tval: integer;
    tValMin, tValMax: integer;
    Var tstrings: toggletyp;
    DESCX, DESCY: integer;
    OLDESCX: integer;
    NUM_LENGTH: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KeyResponse: char;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);

Var shiftp, ctrlp: boolean;
    mp: word;
Begin
    Repeat
        Get_Response (resp, direction, keyresponse, shiftp, ctrlp,
            mausx, mausy, maustaste, mp, mausmenu);
        IniMausAssign (maustaste, resp);
        {Testen ob die Eingabe nicht mit Pfeilen oder ESC abgeschlossen wurde}
        If ((resp <> arrow) AND (resp <> escape)) AND NOT
            ((resp = no_response) AND (maustaste = 0)) Then
            If (KeyResponse = ' ') OR (maustaste = 4) OR ((Maustaste = 1) AND
                ((Mausy DIV 8) >= descy - 1) AND ((Mausy DIV 8) <= descy + 1)) Then
            Begin
                {gib neuen Wert am Bildschirm aus}
                If tval + tvalmin <= tvalmax Then tval := tval + 1
                Else tval := 1;
                IniExpand (tstrings[tval + tvalmin - 1], fieldlength);
                Mausdunkel;
                IniInversText (oldescx, descy, tstrings[tval + tvalmin - 1], frNoFrame);
                MausZeigen;
                changed := true;
            End;
    Until ((resp = arrow) OR (resp = escape) OR (maustaste = 1));
End;

{-------------------------------------------------------------------}
Procedure GrGet_Prompted_String(Var IN_STRING: STRING16;
    STR_LENGTH: integer;
    STRDESC: char;
    DESCX, DESCY: integer;
    OLDESCX: integer;
    PROMPT: STRING79;
    PRX, PRY: integer;
    prlength: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KeyResponse: char;
    oldwrite: boolean;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);
{
BESCHREIBUNG:
    Dieses Unterprogramm liest einen String an einer bestimmten
    Stelle des Bildschirm ein und schreibt eine Benutzeraufforderung
    (=Prompt) auf den Bildschirm.
    changed wird true, wenn der Wert geÑndert wurde oder mit [Enter] bestÑtigt
    wurde.
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

Begin

{ Gib die Beschreibung der vorzunehmenden Eingabe in erhîhter
   Helligkeit aus und zeige die Benutzeraufforderung an }

    IniSpacedText (DESCX - 1, DESCY, ' ' + STRDESC + ' ', frNoFrame);
    IniExpand (prompt, prlength);
    IniInversText (PRX - 1, PRY, ' ' + PROMPT, frLow); {hinterlÑsst RÑnder in Dir-Eingabe ###}

    { Nimm die Eingabe vor }

    GrGet_String (IN_STRING, DESCX + 2, DESCY, OLDESCX,
        STR_LENGTH, RESP, DIRECTION, KEYRESPONSE, oldwrite,
        mausx, mausy, maustaste, mausmenu, changed);
End;
{-------------------------------------------------------------------}
Procedure GrGet_Prompted_Spaced_String(Var IN_STRING: STRING16;
    STR_LENGTH: integer;
    STRDESC: char;
    DESCX, DESCY: integer;
    OLDESCX: integer;
    PROMPT: STRING79;
    PRX, PRY: integer;
    prlength: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KeyResponse: char;
    oldwrite: boolean;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);

Begin
{ Gib die Beschreibung der vorzunehmenden Eingabe in erhîhter
   Helligkeit aus und zeige die Benutzeraufforderung an }
    IniSpacedText (DESCX - 1, DESCY, ' ' + STRDESC + ' ', frNoFrame);
    IniExpand (prompt, prlength);
    IniSpacedText (PRX - 1, PRY, ' ' + PROMPT, frNoFrame);

    { Nimm die Eingabe vor }

    GrGet_Spaced_String (IN_STRING, DESCX + 2, DESCY, OLDESCX,
        STR_LENGTH, RESP, DIRECTION, KEYRESPONSE, oldwrite,
        mausx, mausy, maustaste, mausmenu, changed);
End;

{-------------------------------------------------------------}
Procedure GrGet_Prompted_Real(Var RNNUMBER: Real;
    RValMin, RValMax: Real;
    NUM_LENGTH: integer;
    STRDESC: Char;
    DESCX, DESCY: integer;
    OLDESCX: integer;
    PROMPT: STRING79;
    PRX, PRY: integer;
    prlength: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KeyResponse: char;
    oldwrite: boolean;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);

{
BESCHREIBUNG:
    Dieses Unterprogramm liest eine Real-Zahl an einer bestimmten
    Stelle des Bildschirms ein. Rest siehe bei GrGet_Prompted_String.
-------------------------------------------------------------------}

Begin

{ Gib die Beschreibung der vorzunehmenden Eingabe in erhîhter
   Helligkeit aus und zeige die Benutzeraufforderung an }

    IniInversText (DESCX - 1, DESCY, ' ' + STRDESC + ' ', frNoFrame);
    IniExpand (prompt, prlength);
    IniInversText (PRX - 1, PRY, ' ' + PROMPT, frLow);

    { Nimm die Eingabe vor }

    GrGet_Real (RNNUMBER, RValMin, RValMax,
        DESCX + 2, DESCY, OLDESCX,
        NUM_LENGTH, RESP, DIRECTION, KEYRESPONSE, oldwrite,
        mausx, mausy, maustaste, mausmenu, changed);

End;

{-------------------------------------------------------------------}

{-------------------------------------------------------------}
Procedure GrGet_Prompted_Integer(Var INNUMBER: integer;
    IValMin, IValMax: integer;
    NUM_LENGTH: integer;
    STRDESC: Char;
    DESCX, DESCY: integer;
    OLDESCX: integer;
    PROMPT: STRING79;
    PRX, PRY: integer;
    prlength: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KeyResponse: char;
    oldwrite: boolean;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);

{
BESCHREIBUNG:
    Dieses Unterprogramm liest eine Integer-Zahl an einer bestimmten
    Stelle des Bildschirms ein. Rest siehe bei GrGet_Prompted_String.
-------------------------------------------------------------------}

Begin

{ Gib die Beschreibung der vorzunehmenden Eingabe in erhîhter
   Helligkeit aus und zeige die Benutzeraufforderung an }

    IniInversText (DESCX - 1, DESCY, ' ' + STRDESC + ' ', frNoFrame);
    IniExpand (prompt, prlength);
    IniInversText (PRX - 1, PRY, ' ' + PROMPT, frLow);

    { Nimm die Eingabe vor }

    GrGet_Integer (INNUMBER, IValMin, IValMax,
        DESCX + 2, DESCY, OLDESCX,
        NUM_LENGTH, RESP, DIRECTION, KEYRESPONSE, oldwrite,
        mausx, mausy, maustaste, mausmenu, changed);

End;

{-------------------------------------------------------------------}
Procedure GrGet_Prompted_Toggle(Var tval: integer;
    tValMin, tValMax: integer;
    Var tstrings: toggletyp;
    NUM_LENGTH: integer;
    STRDESC: Char;
    DESCX, DESCY: integer;
    OLDESCX: integer;
    PROMPT: STRING79;
    PRX, PRY: integer;
    prlength: integer;
    Var RESP: RESPONSE_TYPE;
    Var DIRECTION: MOVEMENT;
    Var KeyResponse: char;
    Var mausx, mausy: word;
    Var maustaste, mausmenu: word;
    Var changed: boolean);
Var outstring: string79;

Begin

{ Gib die Beschreibung der vorzunehmenden Eingabe in erhîhter
   Helligkeit aus und zeige die Benutzeraufforderung an }

    IniExpand (tstrings[tval + tvalmin - 1], fieldlength);
    IniInversText (oldescx, descy, tstrings[tval + tvalmin - 1], frNoFrame);
    outstring := '[Spacebar]';
    IniExpand (outstring, fieldlength);
    IniInversText (DESCX - 1, DESCY, ' ' + STRDESC + ' ' + outstring, frNoFrame);
    IniExpand (prompt, prlength);
    IniInversText (PRX - 1, PRY, ' ' + PROMPT, frLow);

    { Nimm die Eingabe vor }

    GrGet_Toggle (tval, tvalmin, tvalmax, tstrings,
        DESCX + 2, DESCY, OLDESCX, num_length,
        RESP, DIRECTION, KEYRESPONSE,
        mausx, mausy, maustaste, mausmenu, changed);

End;

End.
