Unit grinout;

interface

uses menutyp,
     crt,
     inout,
     gcurunit,
     initsc,
     graph,
     MousDrv;


procedure GrPut_Integer (NUMBER, X, Y, NUM_LENGTH: integer);

procedure GrPut_Real (NUMBER : Real; X, Y, NUM_LENGTH: integer);{New}

procedure GrPut_Prompt (OUT_STRING: string79; X, Y: integer);

procedure GrGet_String (var IN_STRING: STRING16;
               X, Y, OLDX, STR_LENGTH: integer;
                            var  RESP: RESPONSE_TYPE;
                        var DIRECTION: MOVEMENT;
                     var KEYRESPONSE : char;
                             oldwrite: boolean;
                     var mausx, mausy: word;
              var maustaste, mausmenu: word;
                         var changed : boolean);
procedure GrGet_Spaced_String (var IN_STRING: STRING16;
               X, Y, OLDX, STR_LENGTH: integer;
                            var  RESP: RESPONSE_TYPE;
                        var DIRECTION: MOVEMENT;
                     var KEYRESPONSE : char;
                             oldwrite: boolean;
                     var mausx, mausy: word;
              var maustaste, mausmenu: word;
                         var changed : boolean);
procedure GrGetUpcase_String (var IN_STRING: STRING16;
               X, Y, STR_LENGTH: integer;
                            var  RESP: RESPONSE_TYPE;
                        var DIRECTION: MOVEMENT;
                     var KEYRESPONSE : char;
                             oldwrite: boolean;
                     var mausx, mausy: word;
              var maustaste, mausmenu: word;
                         var changed : boolean);
procedure GrGet_Integer (var NUMBER: integer;
                   IValMin, IValMax: integer;
             X, Y, OLDX, NUM_LENGTH: integer;
                          var  RESP: RESPONSE_TYPE;
                      var DIRECTION: MOVEMENT;
                    var KeyResponse: char;
                           oldwrite: boolean;
                   var mausx, mausy: word;
            var maustaste, mausmenu: word;
                         var changed : boolean);

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
                                      oldwrite: boolean;
                              var mausx, mausy: word;
                       var maustaste, mausmenu: word;
                                  var changed : boolean);

procedure GrGet_Prompted_Spaced_String (var IN_STRING: STRING16;
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
                                      oldwrite: boolean;
                              var mausx, mausy: word;
                       var maustaste, mausmenu: word;
                                  var changed : boolean);
procedure GrGet_Prompted_Real (var RNNUMBER: Real;     {New}
                            RValMin, RValMax: Real;
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
                                    oldwrite: boolean;
                            var mausx, mausy: word;
                     var maustaste, mausmenu: word;
                                var changed : boolean);

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
                                    oldwrite: boolean;
                            var mausx, mausy: word;
                     var maustaste, mausmenu: word;
                                var changed : boolean);

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
                                 var KeyResponse: char;
                                 var mausx, mausy: word;
                                 var maustaste, mausmenu: word;
                                 var changed : boolean);


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

procedure GrPut_Real (NUMBER : Real; X, Y, NUM_LENGTH: integer);
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
var
  TEMP_STR : STRING79;
  w        : LongInt;
begin

{ Wandle die Zahl in einen String um und gib den String aus }

  w:=Round(NUMBER*1000);
  Str (w, TEMP_STR);
  TEMP_STR:=Copy(TEMP_STR,1,Length(TEMP_STR)-3)+'.'+
            Copy(TEMP_STR,Length(TEMP_STR)-2,3);
  IF Copy(TEMP_STR,Length(TEMP_STR)-2,3)='000' then
    TEMP_STR:=Copy(TEMP_STR,1,Length(TEMP_STR)-4);
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

procedure GrGet_Spaced_String (var IN_STRING: STRING16;
               X, Y, OLDX, STR_LENGTH: integer;
                            var  RESP: RESPONSE_TYPE;
                        var DIRECTION: MOVEMENT;
                     var KEYRESPONSE : char;
                             oldwrite: boolean;
                     var mausx, mausy: word;
              var maustaste, mausmenu: word;
                         var changed : boolean);
const
  BELL            = 7;        { ASCII Signalton }
  BACK_SPACE      = 8;        { ASCII RÅckschritt }
  CARRIAGE_RETURN = 13;       { ASCII WagenrÅcklauf }
  ESC             = 27;       { ASCII Escape Zeichen }
  RIGHT_ARROW     = 77;       { IBM Escape Sequenz fÅr Pfeiltaste
                                 nach rechts }

var
  OLDSTR : STRING79;          { Originaler String }
  clstring: string79;
  shiftp, ctrlp: boolean;
  mp : word;
begin
{ Gib den String mit den entsprechenden Attributen auf dem
  Bildschirm aus }
  clstring:= '';
  IniExpand(clstring, str_length);
  if oldwrite then begin
    IniSpacedText (OLDX, Y, ClString,frNoFrame);
    IniSpacedText (OLDX, Y, IN_STRING,frNoFrame);
  end;
  IniSpacedText (X, Y, ClString,frNoFrame);
  OLDSTR := IN_STRING;
{ Lies das erste Zeichen ein. Verwende bei RETURN den alten String }
  IniSpacedText(X,Y,'_',frNoFrame);
  IniShowCursor;
  Repeat
    Get_Response(Resp, Direction, KeyResponse, shiftp, ctrlp,
                 mausx, mausy, maustaste, mp, mausmenu);
  Until (Resp<>No_Response) Or (maustaste<>0);
  IniMausAssign(maustaste, resp);
  in_string:= '';
{ Verarbeite jeweils nur ein Zeichen }
  while (Resp=Key) or (resp=no_response) do begin
   { Wenn RÅckschritt gedrÅckt wurde, entferne das eingegebene Zeichen }
    if resp=key then begin
      if Ord (KeyResponse) = BACK_SPACE then  { RÅckschritt } begin
        if length (IN_STRING) > 0 then begin
          Dec(Byte(In_string[0]));
          Dec(X);
          IF Length(In_string)<(Str_Length-1) Then
            IniSpacedText(X, Y, '_ ',frNoFrame)
          Else
            IniSpacedText(X, Y, '_',frNoFrame);
        end;
      end {if Ord}else begin
{ PrÅfe ob Pfeiltasten - bestehend aus 2 Zeichen mit ESCAPE als
  erstem Zeichen - gedrÅckt wurden }
{ FÅge ein "normales" Zeichen" in den String ein }
        if Length(IN_STRING) < STR_LENGTH then begin
          IN_STRING:=IN_STRING+KeyResponse;
          IF Length(In_string)<Str_Length Then
            IniSpacedText(X, Y, KeyResponse+'_',frNoFrame)
          Else
            IniSpacedText(X, Y, KeyResponse,frNoFrame);
          Inc(X);
        end;{if Length(IN_STRING) < STR_LENGTH}
      end; {if Ord else}
    End;
    Get_Response(Resp, Direction, KeyResponse, shiftp, ctrlp,
                 mausx, mausy, maustaste, mp, mausmenu);
    IniMausAssign(maustaste, resp);
  end; {while}
  if Resp <> Return then
    in_string:= oldstr
  else
    changed:=true;
  IniHideCursor;
end;
{-------------------------------------------------------------------}
procedure GrGet_String (var IN_STRING: STRING16;
               X, Y, OLDX, STR_LENGTH: integer;
                            var  RESP: RESPONSE_TYPE;
                        var DIRECTION: MOVEMENT;
                     var KEYRESPONSE : char;
                             oldwrite: boolean;
                     var mausx, mausy: word;
              var maustaste, mausmenu: word;
                         var changed : boolean);
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
  clstring: string79;
  shiftp, ctrlp: boolean;
  mp : word;
begin
  x:=x*8-6;
  y:=y*8+6;
  oldx:=oldx*8-6;
{ Gib den String mit den entsprechenden Attributen auf dem
  Bildschirm aus }
  clstring:= '';
  IniExpand(clstring, str_length);
  if oldwrite then begin
    IniInversWrite(OldX,Y,clString,frSmallBar);
    IniInversWrite(OldX,Y,In_String,frSmallBar);
  end;
{### unterscheiden ob Dir-Eingabe oder z.B. Shift-F3, sonst Menu falsch}
  IniInversWrite(X,Y,ClString,frSmallBar);
  OLDSTR := IN_STRING;
{ Lies das erste Zeichen ein. Verwende bei RETURN den alten String }
  IniInversWrite(X,Y,'_',frSmallBar);
  IniShowCursor;
  Repeat
    Get_Response(Resp, Direction, KeyResponse, shiftp, ctrlp,
                 mausx, mausy, maustaste, mp, mausmenu);
  Until (Resp<>No_Response) Or (maustaste<>0);
  IniMausAssign(maustaste, resp);
  in_string:= '';
{ Verarbeite jeweils nur ein Zeichen }
  while (Resp=Key) or (resp=no_response) do begin
{ Wenn RÅckschritt gedrÅckt wurde, entferne das eingegebene Zeichen }
    if resp=key then begin
      if Ord (KeyResponse) = BACK_SPACE then  { RÅckschritt } begin
        if length (IN_STRING) > 0 then begin
          Dec(Byte(In_string[0]));
          Dec(X,6);
          IF Length(In_string)<(Str_Length-1) Then
            IniInversWrite(X,Y,'_ ',frSmallBar)
          Else
            IniInversWrite(X,Y,'_',frSmallBar);
        end;
      end {if Ord}else begin
{ PrÅfe ob Pfeiltasten - bestehend aus 2 Zeichen mit ESCAPE als
  erstem Zeichen - gedrÅckt wurden }
{ FÅge ein "normales" Zeichen" in den String ein }
        if Length(IN_STRING) < STR_LENGTH then begin
          IN_STRING:=IN_STRING+KeyResponse;
          IF Length(In_string)<Str_Length Then
            IniInversWrite(X,Y,KeyResponse+'_',frSmallBar)
          Else
            IniInversWrite(X,Y, KeyResponse,frSmallBar);
            Inc(X,6);
        end;
      end; {if Ord}
    End;
    Get_Response(Resp, Direction, KeyResponse, shiftp, ctrlp,
                 mausx, mausy, maustaste, mp, mausmenu);
    IniMausAssign(maustaste, resp);
  end; {while}
  if Resp <> Return then
    in_string:= oldstr
  else
    changed:=true;
 IniHideCursor;
end;
{-------------------------------------------------------------------}
procedure GrGetUpcase_String (var IN_STRING: STRING16;
               X, Y, STR_LENGTH: integer;
                            var  RESP: RESPONSE_TYPE;
                        var DIRECTION: MOVEMENT;
                     var KEYRESPONSE : char;
                             oldwrite: boolean;
                     var mausx, mausy: word;
              var maustaste, mausmenu: word;
                         var changed : boolean);
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

const
  BELL            = 7;        { ASCII Signalton }
  BACK_SPACE      = 8;        { ASCII RÅckschritt }
  CARRIAGE_RETURN = 13;       { ASCII WagenrÅcklauf }
  ESC             = 27;       { ASCII Escape Zeichen }
  RIGHT_ARROW     = 77;       { IBM Escape Sequenz fÅr Pfeiltaste
                                 nach rechts }

var
  OLDSTR : STRING79;          { Originaler String }
  clstring: string79;
  shiftp, ctrlp: boolean;
  mp : word;
begin
  { Gib den String mit den entsprechenden Attributen auf dem
    Bildschirm aus }
  clstring:= '';
  IniExpand(clstring, str_length);
  if not oldwrite then
    IniSpacedWrite(X, Y, ClString,frNoFrame)
  else begin
    IniSpacedWrite(X, Y, IN_STRING,frNoFrame);
  end;
  OLDSTR := IN_STRING;
{ Lies das erste Zeichen ein. Verwende bei RETURN den alten String }
  IniInversWrite(X,Y,In_String+'_',frNoFrame);
  IniShowCursor;
  Get_Response(Resp, Direction, KeyResponse, shiftp, ctrlp,
               mausx, mausy, maustaste, mp, mausmenu);
  IniMausAssign(maustaste, resp);
{   in_string:= '';}
{ Verarbeite jeweils nur ein Zeichen }

  while (Resp=Key) do begin
{ Wenn RÅckschritt gedrÅckt wurde, entferne das eingegebene Zeichen }
    if Byte(KeyResponse) = BACK_SPACE then  { RÅckschritt } begin
      if length (IN_STRING) > 0 then begin
        Dec(Byte(In_string[0]));
        IF Length(In_string)<Str_Length-1 Then
          IniInversWrite(X, Y,In_String+'_ ',frSmallBar)
        Else
          IniInversWrite(X, Y,In_String+'_',frSmallBar);
      end;
    end {if Byte}else begin
{ PrÅfe ob Pfeiltasten - bestehend aus 2 Zeichen mit 0 als
  erstem Zeichen - gedrÅckt wurden
  FÅge ein "normales" Zeichen" in den String ein }
      if Byte(IN_STRING[0]) < STR_LENGTH then begin
        IN_STRING:=IN_STRING+UpCase(KeyResponse);
        IF Length(In_string)<Str_Length Then
          IniInversWrite(X, Y, In_String+'_',frSmallBar)
        Else
          IniInversWrite(X, Y, In_String,frSmallBar);
      end;
    end; {if Byte Else}
    Get_Response(Resp, Direction, KeyResponse, shiftp, ctrlp,
                 mausx, mausy, maustaste, mp, mausmenu);
    IniMausAssign(maustaste, resp);
  end; {while}
  if Resp <>return then
    in_string:= oldstr
  else
    changed:=true;
  IniHideCursor;
end;
{-------------------------------------------------------------------}
procedure GrGet_Real (var NUMBER: real;
                   RValMin, RValMax: real;
             X, Y, OLDX, NUM_LENGTH: integer;
                          var  RESP: RESPONSE_TYPE;
                      var DIRECTION: MOVEMENT;
                    var KeyResponse: char;
                           oldwrite: boolean;
                   var mausx, mausy: word;
            var maustaste, mausmenu: word;
                       var changed : boolean);
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

const
  BELL = 7;                  { ASCII Signalton }
var
  VALCODE        : integer;  { Code fÅr die String-Umwandlung }
  ORIGINAL_STR,              { Originaler String }
  TEMP_STR       : string16; { Von Tastatur eingegebener String }
  TEMP_Real      : real;     { Versuchte Umwandlung des Strings }
  w              : LongInt;
begin
   IniShowCursor;
   Str (NUMBER, ORIGINAL_STR);

   w:=Round(NUMBER*1000);
   Str (w, ORIGINAL_STR);
   Original_Str:=Copy(Original_Str,1,Length(Original_Str)-3)+'.'+
                 Copy(Original_Str,Length(Original_Str)-2,4);
   IF Copy(ORIGINAL_STR,Length(ORIGINAL_STR)-2,3)='000' then
      Original_STR:=Copy(ORIGINAL_STR,1,Length(ORIGINAL_STR)-4);
{ Probiere weiterhin, bis nur noch Ziffern eingegeben werden }
   repeat
      TEMP_STR := Original_Str;
      { Lies die Eingabe als String ein }
      GrGet_String (TEMP_STR, X, Y, OLDX, NUM_LENGTH,
                    RESP, DIRECTION, KeyResponse, oldwrite,
                    mausx, mausy, maustaste, mausmenu,changed);
      IniMausAssign(maustaste, resp);
      {Teste ob Eingabe nicht mit Pfeilen oder Escape Abgeschlossen wurde}
      if (RESP <> Arrow) and (RESP <> Escape) then
      begin
         { Entferne Leerzeichen }
         while (TEMP_STR[1] = ' ') and (Length(TEMP_STR)<>0) do
            TEMP_STR := copy (TEMP_STR, 2, Length (TEMP_STR));
            { Versuche den String in eine Real-Zahl umzuwandeln }
            Val (TEMP_STR, TEMP_Real, VALCODE);
            IF VALCODE = 0 then
            begin
               {Teste ob der Wert im erlaubten Bereich ist}
               if (TEMP_Real >= RValMin) and (TEMP_Real <= RValMax) then
               begin
                  { Wandle den Real in einen String mit entsprechendem
                    Format zurÅck und gib ihn erneut auf dem Bildschirm aus }
                  NUMBER := TEMP_Real;
                  if oldwrite then
                  begin
                     w:=Round(NUMBER*1000);
                     Str(w, ORIGINAL_STR);
                     Original_Str:=Copy(Original_Str,1,Length(Original_Str)-3)+'.'+
                     Copy(Original_Str,Length(Original_Str)-2,4);
                     IF Copy(ORIGINAL_STR,Length(ORIGINAL_STR)-2,3)='000' then
                       Original_STR:=Copy(ORIGINAL_STR,1,Length(ORIGINAL_STR)-4);
                     IniOutTextXY(OLDX, Y, TEMP_STR);
                  end;
               end
               else {if (TEMP_Real >= RValMin) and (TEMP_Real <= RValMax)}
               begin
                  if oldwrite then
                  begin
                     VALCODE:=1;
                     IniOutTextXY(OLDX, Y, ORIGINAL_STR);
                  end;
               end  {else if (TEMP_Real >=}
            end {if VALCODE = 0}
            else
            begin
               if maustaste = 1 then
               begin
                  valcode:= 0;
               end
               else
               begin
                  if oldwrite then
                  begin
                     IniOutTextXY(OLDX, Y, ORIGINAL_STR);
                  end;
               end;
            end;
      end
      else {if (RESP <> Arrow) and (RESP <> Escape)} begin
         VALCODE := 0;
      end;
   until VALCODE = 0;
   IniHideCursor;
end;
{-------------------------------------------------------------------}
procedure GrGet_Integer (var NUMBER: integer;
                   IValMin, IValMax: integer;
             X, Y, OLDX, NUM_LENGTH: integer;
                          var  RESP: RESPONSE_TYPE;
                      var DIRECTION: MOVEMENT;
                    var KeyResponse: char;
                           oldwrite: boolean;
                   var mausx, mausy: word;
            var maustaste, mausmenu: word;
                       var changed : boolean);
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
   IniShowCursor;
   Str (NUMBER, ORIGINAL_STR);
{ Probiere weiterhin, bis nur noch Ziffern eingegeben werden }
   repeat
      TEMP_STR := Original_Str;
      { Lies die Eingabe als String ein }
      GrGet_String (TEMP_STR, X, Y, OLDX, NUM_LENGTH,
                    RESP, DIRECTION, KeyResponse, oldwrite,
                    mausx, mausy, maustaste, mausmenu,changed);
      IniMausAssign(maustaste, resp);
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
               if maustaste = 1 then
               begin
                  valcode:= 0;
               end
               else
               begin
                  if oldwrite then
                  begin
                     IniOutTextXY(OLDX, Y, ORIGINAL_STR);
                  end;
               end;
            end;
      end
      else {if (RESP <> Arrow) and (RESP <> Escape)}begin
        VALCODE := 0;
     end;
  until VALCODE = 0;
  IniHideCursor;
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
                        var KeyResponse: char;
                        var mausx, mausy: word;
                        var maustaste, mausmenu: word;
                        var changed : boolean);

var shiftp, ctrlp: boolean;
    mp : word;
begin
   repeat
      Get_Response(resp, direction, keyresponse, shiftp, ctrlp,
                   mausx, mausy, maustaste, mp, mausmenu);
      IniMausAssign(maustaste, resp);
      {Testen ob die Eingabe nicht mit Pfeilen oder ESC abgeschlossen wurde}
      if ((resp <> arrow) and (resp <> escape)) And Not
      ((resp = no_response) And (maustaste=0)) then
      begin
         if (KeyResponse = ' ') Or (maustaste=4) Or ((Maustaste=1)And
          ((Mausy DIV 8)>=descy-1) And ((Mausy DIV 8)<=descy+1))then
         begin
            {gib neuen Wert am Bildschirm aus}
            if tval + tvalmin <= tvalmax then tval:= tval + 1
            else tval:= 1;
            IniExpand(tstrings[tval + tvalmin - 1], fieldlength);
            Mausdunkel;
            IniInversText(oldescx, descy, tstrings[tval + tvalmin - 1],frNoFrame);
            MausZeigen;
            changed:=true;
         end;
      end;
   until ((resp = arrow) or (resp = escape) or (maustaste = 1));
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
                                      oldwrite: boolean;
                              var mausx, mausy: word;
                       var maustaste, mausmenu: word;
                                  var changed : boolean);
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

begin

{ Gib die Beschreibung der vorzunehmenden Eingabe in erhîhter
   Helligkeit aus und zeige die Benutzeraufforderung an }

  IniSpacedText (DESCX - 1, DESCY, ' ' + STRDESC + ' ',frNoFrame);
  IniExpand(prompt, prlength);
  IniInversText (PRX - 1, PRY, ' ' + PROMPT,frLow); {hinterlÑsst RÑnder in Dir-Eingabe ###}

{ Nimm die Eingabe vor }

  GrGet_String (IN_STRING, DESCX + 2, DESCY, OLDESCX,
                STR_LENGTH, RESP, DIRECTION, KEYRESPONSE, oldwrite,
                mausx, mausy, maustaste, mausmenu,changed);
end;
{-------------------------------------------------------------------}
procedure GrGet_Prompted_Spaced_String (var IN_STRING: STRING16;
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
                                      oldwrite: boolean;
                              var mausx, mausy: word;
                       var maustaste, mausmenu: word;
                                  var changed : boolean);

begin
{ Gib die Beschreibung der vorzunehmenden Eingabe in erhîhter
   Helligkeit aus und zeige die Benutzeraufforderung an }
  IniSpacedText (DESCX - 1, DESCY, ' ' + STRDESC + ' ',frNoFrame);
  IniExpand(prompt, prlength);
  IniSpacedText (PRX - 1, PRY, ' ' + PROMPT,frNoFrame);

{ Nimm die Eingabe vor }

  GrGet_Spaced_String (IN_STRING, DESCX + 2, DESCY, OLDESCX,
                STR_LENGTH, RESP, DIRECTION, KEYRESPONSE, oldwrite,
                mausx, mausy, maustaste, mausmenu,changed);
end;

{-------------------------------------------------------------}
procedure GrGet_Prompted_Real (var RNNUMBER: Real;
                            RValMin, RValMax: Real;
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
                                    oldwrite: boolean;
                            var mausx, mausy: word;
                     var maustaste, mausmenu: word;
                                  var changed : boolean);

{
BESCHREIBUNG:
    Dieses Unterprogramm liest eine Real-Zahl an einer bestimmten
    Stelle des Bildschirms ein. Rest siehe bei GrGet_Prompted_String.
-------------------------------------------------------------------}

begin

{ Gib die Beschreibung der vorzunehmenden Eingabe in erhîhter
   Helligkeit aus und zeige die Benutzeraufforderung an }

  IniInversText (DESCX - 1, DESCY, ' ' + STRDESC + ' ',frNoFrame);
  IniExpand(prompt, prlength);
  IniInversText (PRX - 1, PRY, ' ' + PROMPT,frLow);

{ Nimm die Eingabe vor }

  GrGet_Real (RNNUMBER, RValMin, RValMax,
                 DESCX + 2, DESCY, OLDESCX,
                 NUM_LENGTH, RESP, DIRECTION, KEYRESPONSE, oldwrite,
                 mausx, mausy, maustaste, mausmenu,changed);

end;

{-------------------------------------------------------------------}

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
                                    oldwrite: boolean;
                            var mausx, mausy: word;
                     var maustaste, mausmenu: word;
                                var changed : boolean);

{
BESCHREIBUNG:
    Dieses Unterprogramm liest eine Integer-Zahl an einer bestimmten
    Stelle des Bildschirms ein. Rest siehe bei GrGet_Prompted_String.
-------------------------------------------------------------------}

begin

{ Gib die Beschreibung der vorzunehmenden Eingabe in erhîhter
   Helligkeit aus und zeige die Benutzeraufforderung an }

  IniInversText (DESCX - 1, DESCY, ' ' + STRDESC + ' ',frNoFrame);
  IniExpand(prompt, prlength);
  IniInversText (PRX - 1, PRY, ' ' + PROMPT,frLow);

{ Nimm die Eingabe vor }

  GrGet_Integer (INNUMBER, IValMin, IValMax,
                 DESCX + 2, DESCY, OLDESCX,
                 NUM_LENGTH, RESP, DIRECTION, KEYRESPONSE, oldwrite,
                 mausx, mausy, maustaste, mausmenu,changed);

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
                                 var KeyResponse: char;
                                 var mausx, mausy: word;
                                 var maustaste, mausmenu: word;
                                 var changed : boolean);
VAR outstring: string79;

begin

{ Gib die Beschreibung der vorzunehmenden Eingabe in erhîhter
   Helligkeit aus und zeige die Benutzeraufforderung an }

   IniExpand(tstrings[tval + tvalmin - 1], fieldlength);
   IniInversText(oldescx, descy, tstrings[tval + tvalmin - 1],frNoFrame);
   outstring:= '[Spacebar]';
   IniExpand(outstring, fieldlength);
   IniInversText (DESCX - 1, DESCY, ' ' + STRDESC + ' ' + outstring,frNoFrame);
   IniExpand(prompt, prlength);
   IniInversText (PRX - 1, PRY, ' ' + PROMPT,frLow);

   { Nimm die Eingabe vor }

   GrGet_Toggle (tval, tvalmin, tvalmax, tstrings,
                 DESCX + 2, DESCY, OLDESCX, num_length,
                 RESP, DIRECTION, KEYRESPONSE,
                 mausx, mausy, maustaste, mausmenu,changed);

end;

end.
