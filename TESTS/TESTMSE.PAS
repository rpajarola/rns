Program TestMse;
Uses MousDrv,Crt;

Var cx,cy,tr,tp,mm : Word;

Begin
  MausInstall;
  ClrScr;
  MausZeigen;
  MausBereichAdd(10,10,60,20,1);
  MausBereichAdd(20,10,25,80,3);
  Repeat
    Window(1,1,10,15);
    MausPosition(cx,cy,tr,tp,mm);
    Delay(5);
    ClrScr;
    WriteLn('X:',CX:5);
    WriteLn('Y:',CY:5);
    WriteLn(' 1  2  3');
    WriteLn(tr and 1:2,tr and 4 :2,tr and 2:2);
    WriteLn(tp and 1:2,tp and 4 :2,tp and 2:2);
    WriteLn(mm);
    MausPressedPosition(cx,cy);
    WriteLn('X:',CX:5);
    WriteLn('Y:',CY:5);
    MausPos(CX,CY,TR,MM);
    WriteLn('X:',CX:5);
    WriteLn('Y:',CY:5);
    WriteLn(TR);
    WriteLn(MM);
  Until KeyPressed;
End.