{$I RNS.H}

Unit GraphMenu;

Interface

Uses MenuTyp,
    crt,
    GrInOut,
    Initsc,
    Gcurunit,
    Inout,
    Graph;


Procedure GrDisplay_Frame(startx, starty, endx, endy: integer;
    topline, endline: boolean);
Procedure GrDisplay_Menu(startx, starty: integer;
    Var MENU: MENU_REC; keyright: byte);
Procedure GrGet_Menu_Response(startx, starty: integer;
    Var MENU: MENU_Rec;
    Var USERS_CHOICE: char;
    Var movedir: movement;
    Var choicenum: byte;
    Var mausx, mausy, maustaste, mausmenu: word;
    leftright: boolean; keyright: byte);
Procedure GrGet_Menu_Values(startx, starty, endy: integer;
    Var MENU: MENU_Rec;
    Var USERS_CHOICE: char);

Implementation

Uses mousdrv;

Procedure GrDisplay_Frame(startx, starty, endx, endy: integer;
    topline, endline: boolean);

Const dx = 0;
    dy = 1;

Var actcolor: byte;
    m: boolean;
Begin
    m := NOT istdunkel;
    If m Then
        mausdunkel;
    actcolor := Getcolor;
    SetColor (menubkcolor{!!!}{menuframecolor});
    SetFillStyle ($FFFF, menubkcolor);
    Bar3D (startx, starty - dy, endx, endy, 0, false);
    Line (startx - 1, starty - dy, startx - 1, endy);
    Line (endx + 1, starty - dy, endx + 1, endy);
    SetColor (12);
    Line (startx, starty - 1, endx, starty - 1);  {Trennungslinie zum Background}
    Line (startx, starty - 2, endx, starty - 2);  {Trennungslinie zum Background}
    Line (startx, endy, endx, endy);
    SetColor (framecolor);
    Line (startx, starty, endx, starty);      {Lichtlinie oberhalb der Menus}
    Line (startx, starty + 1, startx, endy - 1);  {Lichtlinie links der Menus}
    {   SetColor(menuframecolor);}
    If topline Then
    Begin
        Line (startx + 1, starty + 23, endx, starty + 23);{Abgrenzungslinie hell}
        SetColor (12);
        Line (startx{+1}, starty + 22, endx, starty + 22);{Abgrenzungslimie dunkel}
        SetColor (framecolor);
    End;
    If endline Then
    Begin
        Line (startx + 1, endy - 21, endx, endy - 21);    {" hell}
        SetColor (12);
        Line (startx{+1}, endy - 22, endx, endy - 22);    {" dunkel}
    End;
    If m Then
        mauszeigen;
    SetColor (actcolor);
    MausInstall;
    MausGrafik (2);
    MausBereich (startx + 10, endx - 10, starty + 38, endy - 10);
End;

{ -----------------------------------------------------------------}
Procedure GrDispInit(startx, starty: integer; Var MENU: MENU_REC);

Begin
    TOP_LINE := starty + menu.menuattr.firstline;
    LEFT_COL := startx + 1;
    ValCol := Left_Col + 27;
End;

{ -----------------------------------------------------------------}

Procedure GrDisplay_Menu(startx, starty: integer;
    Var MENU: MENU_REC; keyright: byte);

Var
    ACTLINE: integer;
    I, J, L: integer;
    outstring: stringline;
    m: boolean;
Begin

    m := NOT istdunkel;
    If m Then
        mausdunkel;
    GrDispInit (startx, starty, menu);
    With MENU Do
    Begin
        {Schreibe den Titel}
        i := left_col - 1;
        j := starty + 1;
        IniGraphXY (i, j);
        txtfnt.Write (i, j, Title, getcolor, sz6x12, stnormal);
     { Schreibe die Wahlm�glichkeiten und deren Beschreibungen auf den
       Bildschirm }
        For i := 1 To NUM_CHOICES Do
        Begin
            ActLine := Top_Line + i * Spacing;
            If ChoiceVal[i].TypIdent = 'o' Then
                Case keyright Of
                    1:
                    Begin
                        IniSwapMenuColors;
                        j := imenubkcolor;
                        l := imenutextcolor;
                        imenubkcolor := 7;
                        imenutextcolor := 12;
                        IniInversText (LEFT_COL - 1, ActLine, ' ' + DESCRIPTIONS[I], frL3D + frSmallBar);
                        imenubkcolor := j;
                        imenutextcolor := l;
                        IniSwapMenuColors;

                    End;{ case keyright of 1 }
                    0:
                    Begin
                        outstring := choices[i] + ' - ' + descriptions[i];
                        IniOutTextXY (LEFT_COL - 1, ActLine, outstring);
                    End;{ case keyright of 0 }
                    2:
                    Begin
                        outstring := ' ' + choices[i] + ' - ' + descriptions[i] + ' ';
                        IniSpacedText (LEFT_COL - 1, ActLine, outstring, fr3D);
                    End;{ case keyright of 2 }
                End{case keyright} Else IniOutTextXY (LEFT_COL - 1, ActLine, DESCRIPTIONS[I]){if ChoiceVal[i].TypIdent = 'o' };
            Case ChoiceVal[i].TypIdent Of
                'o': ;
                'r': GrPut_Real (ChoiceVal[i].RVal,
                        VALCOL, ACTLINE, 1);{New}
                'i': GrPut_Integer (ChoiceVal[i].IVal, ValCol,
                        ActLine, 1);
                's': IniOutTextXY (ValCol, ActLine, ChoiceVal[i].SVal);
                't': IniOutTextXY (ValCol, ActLine,
                        ToggleString[ChoiceVal[i].TVal +
                        ChoiceVal[i].TValmin - 1]);
            End;{ case}
        End;{ for i }
    End;{ with menu }
    If m Then
        mauszeigen;
End;{ proc GrDisplay_Menu }

{ ------------------------------------------------------------------}

Procedure GrGet_Menu_Response(startx, starty: integer;
    Var MENU: MENU_Rec;
    Var USERS_CHOICE: char;
    Var movedir: movement;
    Var choicenum: byte;
    Var mausx, mausy, maustaste, mausmenu: word;
    leftright: boolean; keyright: byte);

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

Var
    CURRENT_CHOICE,   { Getroffene und hervorgehobene Wahl }
    I, j, L, s, y: integer;
    RESP: RESPONSE_TYPE;  { Tastatur-Eingabe - siehe Get_Response }
    DIR: MOVEMENT;        { Eingegebene Richtung der Pfeiltaste }
    FOUND: boolean;       { Flag f�r die Suche der Wahlm�glichkeit  }
    shiftp, ctrlp: boolean;
    mp: Word;

    Procedure HighLite(VideoVal: Integer);

    Var outstring: String;
        xpos: integer;
  { Ein kleines Unterprogramm um aktuelle Wahl hervorzuheben
    bzw. die verlassene Wahl wieder in normaler Schrift darzustellen

    Parameter:

    VideoVal: Schrifttyp der aktuellen Anzeige }

    Begin
        mausdunkel;
        GrDispInit (startx, starty, menu);
        With MENU Do
            Case keyright Of
                1: If videoval = 1 Then IniInversText (LEFT_COL - 1, TOP_LINE + CURRENT_CHOICE * SPACING, ' ' + DESCRIPTIONS[CURRENT_CHOICE], frL3D + frSmallBar) Else Begin{ if videoval=1 }
                        IniSwapMenuColors;
                        j := imenubkcolor;
                        l := imenutextcolor;
                        imenubkcolor := 7;
                        imenutextcolor := 12;
                        IniInversText (LEFT_COL - 1, TOP_LINE + CURRENT_CHOICE * SPACING, ' ' + DESCRIPTIONS[CURRENT_CHOICE], frL3D + frSmallBar);
                        imenubkcolor := j;
                        imenutextcolor := l;
                        IniSwapMenuColors;
                    End;{ if videoval=1 else }{ case keyright of 1 }
                0:
                Begin
                    If menuattr.highliteline Then
                    Begin
                        outstring := choices[current_choice] + ' - ' + descriptions[current_choice];
                        xpos := -1;
                    End Else Begin{ if menuattr.highliteline }
                        outstring := ' ' + DESCRIPTIONS[CURRENT_CHOICE];
                        xpos := 4;
                        IniClearLine (LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE * SPACING,
                            length (outstring), menubkcolor);
                        IniOutTextXY (LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE * SPACING,
                            outstring);
                    End;{ if menuattr.highliteline else }
                    IniExpand (outstring, menu_width);
                    If VideoVal = 0 Then
                    Begin
                        IniClearLine (LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE * SPACING,
                            length (outstring), menubkcolor);
                        IniOutTextXY (LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE * SPACING,
                            outstring);
                    End Else IniInversText (LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE * SPACING,
                            outstring, frHigh){ if videoval =0 };{ if videoval =0 else}
                End;{ case keyright of 0}
                2:
                Begin
                    If menuattr.highliteline Then
                    Begin
                        outstring := ' ' + choices[current_choice] + ' - ' + descriptions[current_choice] + ' ';
                        xpos := -1;
                    End Else Begin{ if menuattr.highliteline }
                        outstring := ' ' + DESCRIPTIONS[CURRENT_CHOICE];
                        xpos := 4;
                        IniClearLine (LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE * SPACING,
                            length (outstring), menubkcolor);
                        IniSpacedText (LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE * SPACING,
                            outstring, frNoFrame);
                    End;{ if menuattr.highliteline else }
                    IniExpand (outstring, menu_width);
                    If VideoVal = 0 Then IniSpacedText (LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE * SPACING,
                            outstring, fr3D) Else Begin{ if videoval =0 }
                        IniSwapMenuColors;
                        IniSpacedText (LEFT_COL + xpos, TOP_LINE + CURRENT_CHOICE * SPACING,
                            outstring, fr3D);
                        IniSwapMenuColors;
                    End;{ if videoval =0 else}
                End;{ case keyright of 0}
            End{ case keyright of };{ with menu}
        mauszeigen;
    End; {procedure HighLite}


Begin
    With MENU Do
    Begin
        For i := 1 To NUM_CHOICES Do
            changed[i] := false;

        MausZeigen;
        movedir := none;
        CURRENT_CHOICE := choicenum;
        s := choicenum;
        Highlite (1);
{ Erfasse die Eingabe des Benutzers solange, bis eine zul�ssige
   Wahl getroffen wurde }
        Repeat
            { Hebe die jetzige Wahlm�glichkeit hervor }
            { �bernimm die nach dem Prompt eingegebene Antwort }
            If maustaste = 0 Then
            Begin
                If s <> current_choice Then
                Begin
                    i := current_choice;
                    current_choice := s;
                    HighLite (0);
                    current_choice := i;
                    HighLite (1);
                End;
                Repeat
                    Get_Response (RESP, DIR, USERS_CHOICE, shiftp, ctrlp,
                        mausx, mausy, maustaste, mp, mausmenu);

                Until (RESP <> NO_Response) OR (Maustaste > 0) OR (Mp = 1);
                s := current_choice;
            End Else MausPressedPosition (mausx, mausy);
            maustaste := maustaste OR mp;
            If (maustaste = 1) Then
            Begin
                IniMausAssign (maustaste, resp);
                y := mausy;
                If menu.spacing > 4 Then
                    CURRENT_CHOICE := (((y DIV 8) - starty - menu.menuattr.firstline + 4) DIV spacing)
                Else
                If menu.spacing = 4 Then
                    CURRENT_CHOICE := (((y DIV 8) - starty - menu.menuattr.firstline + 4) DIV spacing) - 1
                Else
                    CURRENT_CHOICE := (((y DIV 8) - starty - menu.menuattr.firstline + 4) DIV spacing) - 2;

                If CURRENT_CHOICE < 1 Then
                    CURRENT_CHOICE := 1;
                If CURRENT_CHOICE > NUM_CHOICES Then
                    CURRENT_CHOICE := NUM_CHOICES;
{ leftright = true: es sind 2 Menus angezeigt. Teste
  ob Maus in der richtigen H�lfte des Schirmes.
  Achtung: Koordinaten sind = gxcoord div 8}
                If ((NOT leftright) OR (((startx < (gmaxx DIV 16)) AND
                    (mausx < (gmaxx DIV 2))) OR ((startx > (gmaxx DIV 16)) AND
                    (mausx > (gmaxx DIV 2))))) Then
                Begin
                    mausmenu := 0;
                    maustaste := 0;
                End Else If mausx > (gmaxx DIV 2) Then
                    movedir := right
                Else
                    movedir := left;
            End Else If maustaste <> 0 Then
            Begin
                If keyright = 1 Then
                    resp := no_Response;
                maustaste := 0;
            End;
            Case RESP Of
{ �ndere die aktuell getroffene Wahl, wenn die Pfeiltasten in der
  Richtung nach oben oder nach unten gedr�ckt wurden }
                ARROW: If (DIR = DOWN) AND (CURRENT_CHOICE = NUM_CHOICES) Then
                        CURRENT_CHOICE := 1
                    Else If DIR = DOWN Then
                        CURRENT_CHOICE := CURRENT_CHOICE + 1
                    Else If (DIR = up) AND (CURRENT_CHOICE = 1) Then
                        CURRENT_CHOICE := NUM_CHOICES
                    Else If DIR = UP Then
                        CURRENT_CHOICE := CURRENT_CHOICE - 1
                    Else If (leftright) Then
                    Begin
                        movedir := DIR;
                        RESP := RETURN;
                    End;{arrow}
{ Nur wenn direkt das Schl�sselzeichen f�r die Wahlm�glichkeit ge-
  dr�ckt wurde: Suche nach dem entsprechenden Element im Feld
  CHOICES }
                KEY:
                Begin
                    USERS_CHOICE := UpCase (USERS_CHOICE);
                    FOUND := false;
                    For i := 1 To NUM_CHOICES Do
                        If USERS_CHOICE = CHOICES[I] Then
                        Begin
                            FOUND := true;
                            Highlite (0);
                            CURRENT_CHOICE := I;
                            Break;
                        End;
                    If FOUND Then
                        RESP := RETURN;
                End;{key}
                { �bergib die aktuelle Wahlm�glichkeit, wenn RETURN gedr�ckt wurde }
                RETURN: changed[Current_Choice] := True;
                ESCAPE: ;
            End; {case}
            If mp = 1 Then
                resp := no_Response;
            maustaste := 0;
        Until ((RESP = RETURN) OR (resp = escape));

        If resp = escape Then
            users_choice := chr (27)
        Else
            USERS_CHOICE := CHOICES[CURRENT_CHOICE];
        choicenum := CURRENT_CHOICE;
        HighLite (1);
    End; {with}
    Mausdunkel;
    Highlite (0);
End;
{ ------------------------------------------------------------------}
Procedure GrGet_Menu_Values(startx, starty, endy: integer;
    Var MENU: MENU_Rec;
    Var USERS_CHOICE: char);
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

Var
    CURRENT_CHOICE, pry: integer;
    SVal: String;
    RESP: RESPONSE_TYPE;  { Tastatur-Eingabe - siehe Get_Response }
    DIR:  MOVEMENT;        { Eingegebene Richtung der Pfeiltaste }
    KeyResponse: Char;
    ACTLINE, y: integer;
    mausx, mausy, maustaste, mausmenu: word;

    Procedure HighLite(VideoVal: Integer);

  { Ein kleines Unterprogramm um aktuelle Wahl hervorzuheben
    bzw. die verlassene Wahl wieder in normaler Schrift darzustellen
    und die Eingabe-Felder vorzugeben
    ViedoVal: Schrifttyp der aktuellen Anzeige }

    Var outstring: String;

    Begin
        Mausdunkel;
        With MENU Do
        Begin
            outstring := ' ' + DESCRIPTIONS[Current_Choice];
            IniExpand (outstring, menu_width + 1);
            If VideoVal = 1 Then IniInversText (LEFT_COL - 1, TOP_LINE + CURRENT_CHOICE * SPACING,
                    outstring, frHigh) Else Begin
                IniClearLine (Left_col - 1, ActLine,
                    menu_width + 1, menubkcolor);
                IniOutTextXY (LEFT_COL - 1, ActLine, outstring);
            End;

            Case ChoiceVal[Current_Choice].TypIdent Of
                'o': ; {Sollte nie vorkommen}
                'r': GrPut_Real (ChoiceVal[Current_Choice].RVal,
                        VALCOL, ACTLINE, 1);{New}
                'i': GrPut_Integer (ChoiceVal[Current_Choice].IVal,
                        VALCOL, ACTLINE, 1);
                's': IniOutTextXY (VALCOL, ACTLINE,
                        ChoiceVal[Current_Choice].SVal);
                't': IniOutTextXY (ValCol, ActLine,
                        ToggleString[ChoiceVal[Current_Choice].TVal +
                        ChoiceVal[Current_Choice].TValmin - 1]);
            End; {case}
        End; {with MENU do}
        Mauszeigen;
    End; {procedure HighLite}

Begin
    With MENU Do
    Begin
{     for pry:=1 to num_choices do
       changed[pry]:=false;}
        pry := endy - 2;

        { Bestimme die aktuelle (hervorgehobene) Wahlm�glichkeit }

        CURRENT_CHOICE := 1;

     { Erfasse die Eingabe des Benutzers solange,  bis eine zul�ssige
       Wahl getroffen wurde }

        Repeat
            ActLine := Top_Line + Current_Choice * Spacing;

            { Hebe die jetzige Wahlm�glichkeit hervor }
            HighLite (1);
            { �bernimm die nach dem Prompt eingegebene Antwort }
            Case ChoiceVal[Current_Choice].TypIdent Of
                'o': ;
                'r': GrGet_Prompted_Real (
                        ChoiceVal[Current_Choice].RVal,
                        ChoiceVal[Current_Choice].RValMin,
                        ChoiceVal[Current_Choice].RValMax,
                        FieldLength, '>',
                        ValCol + (FieldLength + 1),
                        TOP_LINE + CURRENT_CHOICE * SPACING,
                        ValCol,
                        ChoiceDesc[Current_Choice],
                        LEFT_COL,
                        pry, menu_width,
                        RESP, DIR, KeyResponse, true,
                        mausx, mausy, maustaste, mausmenu, changed[current_choice]);
                'i': GrGet_Prompted_Integer (
                        ChoiceVal[Current_Choice].IVal,
                        ChoiceVal[Current_Choice].IValMin,
                        ChoiceVal[Current_Choice].IValMax,
                        FieldLength, '>',
                        ValCol + (FieldLength + 1),
                        TOP_LINE + CURRENT_CHOICE * SPACING,
                        ValCol,
                        ChoiceDesc[Current_Choice],
                        LEFT_COL,
                        pry, menu_width,
                        RESP, DIR, KeyResponse, true,
                        mausx, mausy, maustaste, mausmenu, changed[current_choice]);
                's':
                Begin
                    SVal := ChoiceVal[Current_Choice].SVal;
                    GrGet_Prompted_String (Sval,
                        FieldLength, '>',
                        ValCol + (FieldLength + 1),
                        TOP_LINE + CURRENT_CHOICE * SPACING,
                        ValCol,
                        ChoiceDesc[Current_Choice],
                        LEFT_COL,
                        pry, menu_width,
                        RESP, DIR, KeyResponse, true,
                        mausx, mausy, maustaste, mausmenu, changed[current_choice]);
                    ChoiceVal[Current_Choice].SVal := Sval;
                End;
                't': GrGet_Prompted_Toggle (
                        ChoiceVal[Current_Choice].TVal,
                        ChoiceVal[Current_Choice].TValMin,
                        ChoiceVal[Current_Choice].TValMax,
                        Togglestring,
                        FieldLength, '<',
                        ValCol + (FieldLength + 1),
                        TOP_LINE + CURRENT_CHOICE * SPACING,
                        ValCol,
                        ChoiceDesc[Current_Choice],
                        LEFT_COL,
                        pry, menu_width,
                        RESP, DIR, KeyResponse,
                        mausx, mausy, maustaste, mausmenu, changed[current_choice]);
            End; {case}
        { �ndere die noch hervorgehobene Wahlm�glichkeit in normale
         Schrift um }
            HighLite (0);

            IniMausAssign (maustaste, resp);
            If (maustaste = 1) Then
            Begin
                y := mausy;
                CURRENT_CHOICE := ((y DIV 8) - starty -
                    menu.menuattr.firstline + 1) DIV spacing;
                If CURRENT_CHOICE < 1 Then CURRENT_CHOICE := 1;
                If CURRENT_CHOICE > NUM_CHOICES Then
                    CURRENT_CHOICE := NUM_CHOICES;
            End;

            Case RESP Of

       { �ndere die aktuell getroffene Wahl, wenn die Pfeiltasten in der
         Richtung nach oben oder nach unten gedr�ckt wurden }

                ARROW: If (DIR = DOWN) AND (CURRENT_CHOICE = NUM_CHOICES) Then
                        CURRENT_CHOICE := 1
                    Else If DIR = DOWN Then
                        CURRENT_CHOICE := CURRENT_CHOICE + 1
                    Else If (DIR = up) AND (CURRENT_CHOICE = 1) Then
                        CURRENT_CHOICE := NUM_CHOICES
                    Else If DIR = UP Then
                        CURRENT_CHOICE := CURRENT_CHOICE - 1;

                KEY: ;

                RETURN: ;
            End;
        Until RESP = ESCAPE;
        IniHideCursor;
    End;
End;


{ ---------------------------------------------------------------- }

End.
