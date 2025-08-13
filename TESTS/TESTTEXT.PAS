Program TestText;

Uses Graph,
     TextFont;

Var D,M : Integer;
    T   : TFastFontViewer;
    a   : byte;
Begin
  D:=VGA;
  M:=VGAHi;
  InitGraph(D,M,'');
  T.Init('NORM');
  for a:=byte('A') to byte('Z') do
    T.WriteChar((a-byte('B')+10)*20,100,char(a),(a mod 15)+1,sz8x8,stnormal);
End.