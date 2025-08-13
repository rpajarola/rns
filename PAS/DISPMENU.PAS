unit DispMenu;

interface

uses MenuTyp,
     crt,
     inout,
     initsc;

procedure Display_Frame (startx, starty, endx, endy: integer;
                         titleline, hintline: boolean);

implementation

procedure Display_Frame (startx, starty, endx, endy: integer;
                         titleline, hintline: boolean);
{
BESCHREIBUNG:
    Dieses  Unterprogramm  erstellt einen Rahmen  um  einen  Aus-
    schnitt des Bildschirms
  ------------------------------------------------------------- }

var
  COL, LINE: integer;   { ZÑhler fÅr Schleifen }

begin
   TextBackground(tmbk);
   TextColor(tmtext);
   Window(startx, starty, endx, endy);
   ClrScr;
   Window(1, 1, 80, 25);
   Set_Video (0);
{ Zeichne die oberste Zeile }

  GotoXY (startx - 1, starty);
  write(Chr(218));
  for COL := startx to endx - 1 do write(Chr(196));
  write(Chr(191));

{ Zeichne alle mittleren Zeilen }
  for LINE := starty + 1 to endy - 1 do
  begin
     GotoXY(startx - 1,LINE);
     write(Chr(179));
     GotoXY (endx, LINE);
     write(Chr(179));
  end;

{Zeichne die dritte Zeile}
   if titleline then
   begin
      GotoXY (startx - 1, starty + 2);
      write(Chr(195));
      for COL := startx to endx - 1 do write(Chr(196));
      write(Chr(180));
   end;

{Zeichne die drittletzte Zeile}
   if hintline then
   begin
      GotoXY (startx - 1, endy - 2);
      write(Chr(195));
      for COL := startx to endx - 1 do write(Chr(196));
      write(Chr(180));
   end;

{ Zeichne die letzte Zeile }
  GotoXY (startx - 1, endy);
  write(Chr(192));
  for COL := startx to endx - 1 do write (Chr(196));
  mem[$B800:$0000+(endy-1)*160+((endx-1) shl 1)]:=217;{New}
{  write (Chr(217));}
  Set_Video (0);
end;

 { -----------------------------------------------------------------}


end.
