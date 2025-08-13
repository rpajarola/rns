unit MenuTyp;

interface

Const FieldLength = 12;
      ClearString = '                ';

type
  string79 = string[79];
  string16 = string[79];
  ENTRY_TYPE = integer;
  KEY_TYPE = integer;
  OTHER_TYPE = integer;

  RESPONSE_TYPE = (NO_RESPONSE, KEY, RETURN, ARROW, ESCAPE, SPECIALKEY);
  MOVEMENT = (NONE, LEFT, RIGHT, UP, DOWN);


  ChoiceTyp = record
    case TypIdent : char of
       'o' : (c:char);
       'i' : (IVal, IValMin, IValMax : Integer);
       'r' : (RVal, RValMin, RValMax : Real);
       's' : (SVal : String16);
       't' : (TVal, TValMin, TValMax : Integer);    {Toggle-Parameter}
    end;

  ToggleTyp = array [1..16] of String16;

  Menuattrtyp = record
     highliteline : boolean; {true wenn die ganze Zeile
                              inverse angezeigt wird}
     firstline    : byte;    {differenz zur ersten Zeile}
  end;

  Menu_Rec = record
     NUM_CHOICES : integer;
     MENU_WIDTH  : integer;
     spacing     : integer;
     CHOICES	 : array [1..16] of char;
     DESCRIPTIONS: array [1..16] of STRING79;
     TITLE	 : STRING79;
     ChoiceVal	 : array [1..16] of ChoiceTyp;
     ChoiceDesc  : array [1..16] of STRING79;
     menuattr    : menuattrtyp;
     changed     : array [1..16] of boolean;
  end;

implementation

begin
end.
