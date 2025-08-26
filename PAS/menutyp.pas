{$I RNS.H}

Unit MenuTyp;

Interface

Const FieldLength = 12;
    ClearString = '                ';

Type
    string79 = string[79];
    string16 = string[79];
    ENTRY_TYPE = integer;
    KEY_TYPE = integer;
    OTHER_TYPE = integer;

    RESPONSE_TYPE = (NO_RESPONSE, KEY, RETURN, ARROW, ESCAPE, SPECIALKEY);
    MOVEMENT = (NONE, LEFT, RIGHT, UP, DOWN);


    ChoiceTyp = Record
        Case TypIdent: char Of
            'o': (c: char);
            'i': (IVal, IValMin, IValMax: Integer);
            'r': (RVal, RValMin, RValMax: Real);
            's': (SVal: String16);
            't': (TVal, TValMin, TValMax: Integer);    {Toggle-Parameter}
    End;

    ToggleTyp = Array [1..16] Of String16;

    Menuattrtyp = Record
        highliteline: boolean; {true wenn die ganze Zeile
                              inverse angezeigt wird}
        firstline: byte;    {differenz zur ersten Zeile}
    End;

    Menu_Rec = Record
        NUM_CHOICES: integer;
        MENU_WIDTH: integer;
        spacing: integer;
        CHOICES: Array [1..16] Of char;
        DESCRIPTIONS: Array [1..16] Of STRING79;
        TITLE: STRING79;
        ChoiceVal: Array [1..16] Of ChoiceTyp;
        ChoiceDesc: Array [1..16] Of STRING79;
        menuattr: menuattrtyp;
        changed: Array [1..16] Of boolean;
    End;

Implementation

Begin
End.
