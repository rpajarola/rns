Uses Keys,Graph;

Var Kbd : PMFIIKbd;
    Driver,Mode : Integer;
    a,b         : Byte;
Begin
  Driver:=VGA;
  Mode:=VGAHi;
  InitGraph(Driver,Mode,'');
  Kbd:=New(PMFIIKbd,Init(50,50,590,430,7,1,15,2,08,08));
  SetBkColor(7);
  ClearViewPort;
  With Kbd^ do Begin
    For a:=0 to $39 Do Begin
      b:=AddScanKey(a,1,7,7,6);
      IF b<>$FF Then
        GetKey(b)^.Draw;
    End;
{    For a:=0 To 11 Do
      AddKey(New(PKey,Init(20+a*35,10,40+a*35,30,  1,7,15,4,Kbd)));
    For a:=0 To 11 Do
      AddKey(New(PKey,Init(30+a*35,45,50+a*35,65,  1,7,15,4,Kbd)));
    For a:=0 To 10 Do
      AddKey(New(PKey,Init(10+a*35,80,30+a*35,100, 1,7,15,4,Kbd)));
    AddKey(New(PEnter,Init(20+12*35,10,
                           55+12*35,65,
                           30+12*35,30,
                           1,7,15,4,Kbd)));
    Draw;
    ReadLn(a);
    GetKey(a)^.Highlighted:=True;
    Draw;
    ReadLn;}
  End;
End.