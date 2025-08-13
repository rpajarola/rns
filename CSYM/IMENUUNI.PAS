unit imenuunit;

interface

uses
    dos,
    crt,
    graph,
    menutyp;


Procedure ImeInitSymbolMenus;
Procedure ImeInitMenus;
Procedure ImeInitCharMenu(c: char);

implementation

uses initsc;
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeInitSymbolMenus;

var i: integer;

begin
   With SymbolMenu1 do
   begin
      menuattr.highliteline:= true;
      menuattr.firstline:= 4;

      Num_Choices:= 13;
      Menu_Width:= 16;
      spacing:= 2;
      Choices:= 'abcdefghijklm   ';
      Title:=' group a..m ';

      for i:= 1 to 13 do
      begin
	 Descriptions[i]:= chr(i+64) + ' - [Alt]+' + chr(i+96);
	 ChoiceVal[i].TypIdent:='o';
      end;
   end; {With SymbolMenu1}

   With SymbolMenu2 do
   begin
      menuattr.highliteline:= true;
      menuattr.firstline:= 4;

      Num_Choices:= 13;
      Menu_Width:= 16;
      spacing:= 2;
      Choices:= 'nopqrstuvwxyz   ';
      Title:=' group n..z ';

      for i:= 1 to 13 do
      begin
	 Descriptions[i]:= chr(i+77) + ' - [Alt]+' + chr(i+109);
	 ChoiceVal[i].TypIdent:='o';
      end;
   end; {With SymbolMenu2}

end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeInitCharMenu(c: char);

var i: integer;
    inblock: string16;
    cshift: char;

begin
   i:= ord(c);
   cshift:= chr(i - 32);
   {Menu initialisieren}
   With UsrMenu do
   begin
      menuattr.highliteline:= true;
      menuattr.firstline:= 1;

      Num_Choices:= 12;
      Menu_Width:= 54;
      spacing:= 2;
      Choices:= '                ';
      Title:='Symbol parameters';

      ToggleString[1]:= 'replace';
      ToggleString[2]:= 'add';

      For i:= 1 to 3 do
      begin
	 case i of
	    1: Descriptions[4 * (i - 1) + 1]:=
			    '      '+ c + ' - vertical shift';
	    2: Descriptions[4 * (i - 1) + 1]:=
			    '      '+ cshift + ' - vertical shift';
	    3: Descriptions[4 * (i - 1) + 1]:=
			    '[Alt]+'+ c + ' - vertical shift';
	 end;
	 ChoiceVal[4 * (i - 1) + 1].TypIdent:='i';
	 ChoiceVal[4 * (i - 1) + 1].IvalMin:=-99;
	 ChoiceVal[4 * (i - 1) + 1].IvalMax:=99;
	 ChoiceDesc[4 * (i - 1) + 1]:='Up or down shift [-99 to +99]';

	 case i of
	    1: Descriptions[4 * (i - 1) + 2]:=
			    '      '+ c + ' - symbol type';
	    2: Descriptions[4 * (i - 1) + 2]:=
			    '      '+ cshift + ' - symbol type';
	    3: Descriptions[4 * (i - 1) + 2]:=
			    '[Alt]+'+ c + ' - symbol type';
	 end;

	 ChoiceVal[4 * (i - 1) + 2].TypIdent:='t';
	 ChoiceVal[4 * (i - 1) + 2].TvalMin:=1;
	 ChoiceVal[4 * (i - 1) + 2].TvalMax:=2;
	 ChoiceDesc[4 * (i - 1) + 2]:='Replace or add symbols';

	 case i of
	    1: Descriptions[4 * (i - 1) + 3]:=
			    '      '+ c + ' - frequency';
	    2: Descriptions[4 * (i - 1) + 3]:=
			    '      '+ cshift + ' - frequency';
	    3: Descriptions[4 * (i - 1) + 3]:=
			    '[Alt]+'+ c + ' - frequency';
	 end;
	 ChoiceVal[4 * (i - 1) + 3].TypIdent:='i';
	 ChoiceVal[4 * (i - 1) + 3].IvalMin:=0;
	 ChoiceVal[4 * (i - 1) + 3].IvalMax:=20000;
	 ChoiceDesc[4 * (i - 1) + 3]:='Sound frequency [0Hz..20000Hz]';

	 case i of
	    1: Descriptions[4 * (i - 1) + 4]:=
			    '      '+ c + ' - length';
	    2: Descriptions[4 * (i - 1) + 4]:=
			    '      '+ cshift + ' - length';
	    3: Descriptions[4 * (i - 1) + 4]:=
			    '[Alt]+'+ c + ' - length';
	 end;
	 ChoiceVal[4 * (i - 1) + 4].TypIdent:='i';
	 ChoiceVal[4 * (i - 1) + 4].IvalMin:=0;
	 ChoiceVal[4 * (i - 1) + 4].IvalMax:=1000;
	 ChoiceDesc[4 * (i - 1) + 4]:='Sound length [10ms..1000ms]';

      end;
  end; {With UsrMenu}
end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeIniColors;

var infile: text;

begin
   assign(infile,'colors.csy');
   reset(infile);
   readln(infile, menutextcolor);
   readln(infile, menubkcolor);
   readln(infile, imenutextcolor);
   readln(infile, imenubkcolor);
   readln(infile, cursorcolor);
   close(infile);

end;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeInitMenus;
{initialisiert alle Menus}

begin
   ImeInitSymbolMenus;
   ImeIniColors;
end;

end.


