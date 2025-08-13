Program TestFont;

Uses TextFont,Graph;

procedure graphinit;
var
  gd,gm  : integer;
begin
  gd := detect;
  initgraph (gd,gm,'');
end;

procedure graphclose;
begin
  closegraph;
end;

Var aFont : TTextFontViewer;

Begin
  aFont.Init('C:\MUSIC\RNS\TEXTFONT\NORM');
  GraphInit;
  aFont.Write(20,20,'NORM 8x8',15,sz8x8,stnormal);
  aFont.Write(20,40,'NORM 8x16',15,sz8x16,stnormal);
  aFont.Write(20,60,'NORM 6x12',15,sz6x12,stnormal);
  aFont.Write(120,20,'BOLD 6x12',15,sz6x12,stbold);
  aFont.Write(120,50,'DOUBLE 6x12',15,sz6x12,stdouble);
  aFont.Write(120,80,'ITALIC 6x12',15,sz6x12,stitalic);
  aFont.Write(120,110,'ITALIC BOLD 6x12',15,sz6x12,stitalic+stbold);
  aFont.Write(120,140,'ITALIC DOUBLE 6x12',15,sz6x12,stitalic+stdouble);
  aFont.Write(120,170,'DOUBLE BOLD 6x12',15,sz6x12,stdouble+stbold);
  aFont.Write(120,200,'ITALIC DOUBLE BOLD 6x12',15,sz6x12,stitalic+stdouble+stbold);
  readln;
  aFont.Done;
  GraphClose;
End.