Unit Mousdrv;

Interface

var Mausexist: boolean;
    Mausform: byte;

Const MseOK    = 1;
      MseBlock = 2;
      MseEsc   = 4;

Procedure MausInstall;
Procedure MausZeigen;
Function  IstDunkel : Boolean;
Procedure MausPosition(var cursorx, cursory, trel, tpress, mausmenu: word);
Procedure MausGrafik(mausbild: byte);
Procedure MausBereich(xmin, xmax, ymin, ymax: integer);
Procedure MausBereichAdd(xmin, xmax, ymin, ymax, mausnum: integer);
Procedure MausDunkel;
Procedure MausPressedPosition(var cursorx, cursory: word);
Procedure MausSetXY(x,y:Word);
Procedure MausPos(Var cursorx, cursory, taste, mausmenu: Word);

Implementation

var Dunkel : Boolean;
    mausposx, mausposy: word;

{******************************************************}
Procedure MausInstall;
begin
   Dunkel := True;
   Mausexist := True;  // Assume mouse exists on modern systems
   Mausform := 0;
   mausposx := 0;
   mausposy := 0;
end;

{******************************************************}
Procedure MausZeigen;
begin
   if Mausexist and Dunkel then
   begin
      Dunkel := False;
      // TODO: Show mouse cursor with modern API
   end;
end;

{******************************************************}
Procedure MausDunkel;
begin
   if Mausexist and not Dunkel then
   begin
      Dunkel := True;
      // TODO: Hide mouse cursor with modern API
   end;
end;

{******************************************************}
Function IstDunkel : Boolean;
begin
   IstDunkel := Dunkel;
end;

{******************************************************}
Procedure MausPosition(var cursorx, cursory, trel, tpress, mausmenu: word);
begin
   if Mausexist then
   begin
      // TODO: Get mouse position with modern API
      cursorx := mausposx;
      cursory := mausposy;
      trel := 0;
      tpress := 0;
      mausmenu := 0;
   end
   else
   begin
      cursorx := 0;
      cursory := 0;
      trel := 0;
      tpress := 0;
      mausmenu := 0;
   end;
end;

{******************************************************}
Procedure MausGrafik(mausbild: byte);
begin
   // TODO: Set mouse cursor shape with modern API
   Mausform := mausbild;
end;

{******************************************************}
Procedure MausBereich(xmin, xmax, ymin, ymax: integer);
begin
   // TODO: Set mouse movement bounds with modern API
end;

{******************************************************}
Procedure MausBereichAdd(xmin, xmax, ymin, ymax, mausnum: integer);
begin
   // TODO: Add mouse region with modern API
end;

{******************************************************}
Procedure MausPressedPosition(var cursorx, cursory: word);
begin
   // TODO: Get mouse press position with modern API
   cursorx := mausposx;
   cursory := mausposy;
end;

{******************************************************}
Procedure MausSetXY(x,y:Word);
begin
   // TODO: Set mouse position with modern API
   mausposx := x;
   mausposy := y;
end;

{******************************************************}
Procedure MausPos(Var cursorx, cursory, taste, mausmenu: Word);
begin
   // TODO: Get complete mouse state with modern API
   cursorx := mausposx;
   cursory := mausposy;
   taste := 0;
   mausmenu := 0;
end;

end.