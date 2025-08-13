Unit Keys;

Interface

Uses Graph;
Type
     PKey = ^TKey;
     PKeyBoard = ^TKeyBoard;
     TKeyBoard = Object
       X0,Y0,X1,Y1 : Word;
       FFC,FBC     : Byte;
       BC          : Byte;
{       KFC,KBC,KHFC,KHBC : Byte;}
       Keys        : Array[0..101] OF PKey;
       Constructor Init(aX0,aY0,aX1,aY1 : Word;aFFC,aFBC,aBC{,
                        aKFC,aKBC,aKHFC,aKHBC }: Byte);
       Destructor Done;Virtual;
       Procedure DrawFrame;Virtual;
       Procedure DrawContents;Virtual;
       Procedure Draw;
       Function AddKey(aKey : PKey) : Byte;
       Function RemKey(i : Byte) : Boolean;
       Function GetKey(i : Byte) : PKey;
     End;
     PFrame = ^TFrame;
     TFrame = Object
       X0,Y0,X1,Y1 : Word;
       Owner : PKey;
       FC,BC : Byte;
       Constructor Init(aX0,aY0,aX1,aY1 : Word;aFC,aBC : Byte;aOwner : PKey);
       Destructor Done;Virtual;
       Procedure Draw;Virtual;
     End;
     TKey = Object
       X0,Y0,X1,Y1   : Word;
       Highlighted   : Boolean;
       Frame         : PFrame;
       FC,BC   : Byte;
       HFC,HBC : Byte;
       Owner   : PKeyBoard;
       Constructor Init(aX0,aY0,aX1,aY1 : Word;aFC,aBC,aHFC,aHBC : Byte;
                        aOwner : PKeyboard);
       Procedure InitFrame;Virtual;
       Destructor Done;Virtual;
       Procedure Draw;
       Procedure DrawFrame;Virtual;
       Procedure DrawContents;Virtual;
     End;
     PEnterFrame = ^TEnterFrame;
     TEnterFrame = Object(TFrame)
       X2,Y2 : Word;
       Constructor Init(aX0,aY0,aX1,aY1,aX2,aY2: Word;aFC,aBC : Byte;aOwner : PKey);
       Procedure Draw;Virtual;
     End;
     PEnter = ^TEnter;
     TEnter = Object(TKey)
       X2,Y2 : Word;
       Constructor Init(aX0,aY0,aX1,aY1,aX2,aY2 : Word;aFC,aBC,aHFC,aHBC : Byte;
                        aOwner : PKeyboard);
       Procedure InitFrame;Virtual;
       Procedure DrawContents;Virtual;
     End;
     PMFIIKbd = ^TMFIIKbd;
     TMFIIKbd = Object(TKeyboard)
       KSpace,KWidth,KHeight : Word;
       Constructor Init(aX0,aY0,aX1,aY1 : Word;aFFC,aFBC,aBC : Byte;
                        aKSpace,aKWidth,aKHeight : Word);
       Function AddScanKey(ScanCode : Byte;aFC,aBC,aHFC,aHBC : Byte) : Byte;Virtual;
     End;
Implementation

Type KeyDescription = Record
       Name : Char;
       X,Y : Word;
       W,H : Word;
     End;
Constructor TFrame.Init(aX0,aY0,aX1,aY1 : Word;aFC,aBC : Byte;aOwner : PKey);
Begin
  X0:=aX0;
  Y0:=aY0;
  X1:=aX1;
  Y1:=aY1;
  FC:=aFC;
  BC:=aBC;
  Owner:=aOwner;
End;
Procedure TFrame.Draw;
Var DX,DY : Word;
Begin
  IF Owner=Nil Then Begin
    DX:=0;
    DY:=0;
  End Else Begin
    IF Owner^.Owner=Nil Then Begin
      DX:=0;
      DY:=0;
    End Else Begin
      DX:=Owner^.Owner^.X0;
      DY:=Owner^.Owner^.Y0;
    End;
  End;
  SetColor(FC); {Licht}
  Line(DX+X0+2,DY+Y0  ,DX+X1-2,DY+Y0  );{Ä}
  Line(DX+X0  ,DY+Y0+1,DX+X0  ,DY+Y1  );{³}
  Line(DX+X0-1,DY+Y0+2,DX+X0-1,DY+Y1+3);{³}
  Line(DX+X0-2,DY+Y0+3,DX+X0-2,DY+Y1+6);{³}

(*SetColor(7{wie fill});
  Line(DX+X0-1,DY+Y0+2,DX+X0-1,DY+Y1+3);{³} *)

  SetColor(1{12});
  Line(DX+X0-3,DY+Y0+2,DX+X0-3,DY+Y1+8);{³} {dunkler Zwischenraum links}
  Line(DX+X1+3,DY+Y0+2,DX+X1+3,DY+Y1+8);{³} {dunkler Zwischenraum rechts}
  Line(DX+X0-3,DY+Y1+8,DX+X1+3,DY+Y1+8);{-} {dunkler Zwischenraum unten}
  PutPixel(DX+X1+2,DY+Y1+7,1{12}{GetColor}); {rechte untere Ecke abrunden}
  PutPixel(DX+X0-2,DY+Y1+7,1{12}{GetColor}); {linke untere Ecke abrunden}

  SetColor(BC); {Schatten}
  Line(DX+X0+1,DY+Y1  ,DX+X1-1,DY+Y1);{Ä}
  Line(DX+X0  ,DY+Y1+1,DX+X1-1,DY+Y1+1);{Ä}
  Line(DX+X0  ,DY+Y1+2,DX+X1-1,DY+Y1+2);{Ä}
  Line(DX+X0  ,DY+Y1+3,DX+X1-1,DY+Y1+3);{Ä}
  Line(DX+X0-1,DY+Y1+4,DX+X1-1,DY+Y1+4);{Ä}
  Line(DX+X0-1,DY+Y1+5,DX+X1-1,DY+Y1+5);{Ä}
  Line(DX+X0-1,DY+Y1+6,DX+X1-1,DY+Y1+6);{Ä}
  Line(DX+X0-1,DY+Y1+7,DX+X1-1,DY+Y1+7);{Ä}

  Line(DX+X1  ,DY+Y0+1,DX+X1  ,DY+Y1+7);{³}
  Line(DX+X1+1,DY+Y0+2,DX+X1+1,DY+Y1+7);{³}
  Line(DX+X1+2,DY+Y0+3,DX+X1+2,DY+Y1+6);{³}

End;
Destructor TFrame.Done;
Begin
End;
Constructor TKey.Init(aX0,aY0,aX1,aY1 : Word;aFC,aBC,aHFC,aHBC : Byte;
                      aOwner : PKeyboard);
Begin
  X0:=aX0;
  Y0:=aY0;
  X1:=aX1;
  Y1:=aY1;
  FC:=aFC;
  BC:=aBC;
  HFC:=aHFC;
  HBC:=aHBC;
  Highlighted:=False;
  Owner:=aOwner;
  InitFrame;
End;
Procedure TKey.InitFrame;
Begin
  Frame:=New(PFrame,Init(X0,Y0,X1,Y1,15,8,@Self));
End;
Destructor TKey.Done;
Begin
  Dispose(Frame,Done);
End;
Procedure TKey.Draw;
Begin
  DrawFrame;
  DrawContents;
End;
Procedure TKey.DrawFrame;
Begin
  Frame^.Draw;
End;
Procedure TKey.DrawContents;
Var DX,DY : Word;
Begin
  IF Owner=Nil Then Begin
    DX:=0;
    DY:=0;
  End Else Begin
    DX:=Owner^.X0;
    DY:=Owner^.Y0;
  End;
  IF HighLighted Then
    SetFillStyle(SolidFill,HBC)
  Else
    SetFillStyle(SolidFill,BC);
  Bar(DX+X0+1,DY+Y0+1,DX+X1-1,DY+Y1-1);

  PutPixel(DX+X1-1,DY+Y1-1,GetColor); {rechte untere Ecke abrunden}
  PutPixel(DX+X0+1,DY+Y0+1,15); {linke obere Ecke abrunden}
  PutPixel(DX+X1-1,DY+Y0+1,15); {rechte obere Ecke abrunden}
  PutPixel(DX+X0+1,DY+Y1-1,Getcolor); {linke untere Ecke abrunden}

End;

Constructor TKeyboard.Init(aX0,aY0,aX1,aY1 : Word;aFFC,aFBC,aBC{,
                        aKFC,aKBC,aKHFC,aKHBC }: Byte);
Begin
  X0:=aX0;
  Y0:=aY0;
  X1:=aX1;
  Y1:=aY1;
  FFC:=aFFC;
  FBC:=aFBC;
  BC:=aBC;
{  KFC:=aKFC;
  KBC:=aKBC;
  KHFC:=aKHFC;
  KHBC:=aKHBC;                  }
  FillChar(Keys,SizeOf(Keys),0);
End;
Destructor TKeyBoard.Done;
Var a : Byte;
Begin
  For a:=0 To 101 Do
    IF Keys[a]<>Nil Then
      Dispose(Keys[a],Done);
End;
Procedure TKeyBoard.DrawFrame;
Begin
  SetColor(FFC);
  Line(X0+1,Y0,X1-1,Y0);{Ä}
  Line(X0,Y0+1,X0,Y1-1);{³}
  SetColor(FBC);
  Line(X0+1,Y1,X1-1,Y1);{Ä}
  Line(X1,Y0+1,X1,Y1-1);{³}
End;
Procedure TKeyBoard.DrawContents;
Var a : Byte;
Begin
  For a:=0 To 101 Do
    IF Keys[a]<>Nil Then
      Keys[a]^.Draw;
End;
Procedure TKeyBoard.Draw;
Var a : Byte;
Begin
  DrawFrame;
  DrawContents;
End;

Function TKeyBoard.AddKey(aKey : PKey) : Byte;
Var a : Byte;
Begin
  For a:=0 To 101 Do
    IF Keys[a]=Nil Then Begin
      Keys[a]:=aKey;
      AddKey:=a;
      Break;
    End;
End;
Function TKeyBoard.RemKey(i : Byte) : Boolean;
Begin
  IF Keys[i]<>Nil Then
    Dispose(Keys[i],Done);
End;
Function TKeyBoard.GetKey(i : Byte) : PKey;
Begin
  GetKey:=Keys[i];
End;

Constructor TEnterFrame.Init(aX0,aY0,aX1,aY1,aX2,aY2: Word;aFC,aBC : Byte;aOwner : PKey);
Begin
  Inherited Init(aX0,aY0,aX1,aY1,aFC,aBC,aOwner);
  X2:=aX2;
  Y2:=aY2;
End;
Procedure TEnterFrame.Draw;
Var DX,DY : Word;
Begin
  IF Owner=Nil Then Begin
    DX:=0;
    DY:=0;
  End Else Begin
    IF Owner^.Owner=Nil Then Begin
      DX:=0;
      DY:=0;
    End Else Begin
      DX:=Owner^.Owner^.X0;
      DY:=Owner^.Owner^.Y0;
    End;
  End;
  SetColor(FC);
  Line(DX+X0+1,DY+Y0  ,DX+X1-1,DY+Y0);{o Ä}
  Line(DX+X0  ,DY+Y0+1,DX+X0  ,DY+Y2-1);{ol ³}
  Line(DX+X2  ,DY+Y2+1,DY+X2  ,DY+Y1-1);
  SetColor(BC);
  Line(DX+X0,DY+Y2,DX+X2-1,DY+Y2);
  Line(DX+X2+1,DY+Y1  ,DX+X1-1,DY+Y1);{u Ä}
  Line(DX+X1  ,DY+Y0+1,DX+X1  ,DY+Y1-1);{r ³}
End;

Constructor TEnter.Init(aX0,aY0,aX1,aY1,aX2,aY2 : Word;aFC,aBC,aHFC,aHBC : Byte;
                        aOwner : PKeyboard);
Begin
  X2:=aX2;
  Y2:=aY2;
  Inherited Init(aX0,aY0,aX1,aY1,aFC,aBC,aHFC,aHBC,aOwner);

End;

Procedure TEnter.InitFrame;
Begin
  Frame:=New(PEnterFrame,Init(X0,Y0,X1,Y1,X2,Y2,15,1,@Self));
End;
Procedure TEnter.DrawContents;
Var DX,DY : Word;
Begin
  IF Owner=Nil Then Begin
    DX:=0;
    DY:=0;
  End Else Begin
    DX:=Owner^.X0;
    DY:=Owner^.Y0;
  End;
  IF HighLighted Then
    SetFillStyle(SolidFill,HBC)
  Else
    SetFillStyle(SolidFill,HBC {BC});       {****************}
  Bar(DX+X0+1,DY+Y0+1,DX+X1-1,DY+Y2-1);
  Bar(DX+X2+1,DY+Y2  ,DX+X1-1,DY+Y1-1);
  PutPixel(DX+X2,DY+Y2,GetColor);
End;

Constructor TMFIIKbd.Init(aX0,aY0,aX1,aY1 : Word;aFFC,aFBC,aBC : Byte;
                          aKSpace,aKWidth,aKHeight : Word);
Begin
  Inherited Init(aX0,aY0,aX1,aY1,aFFC,aFBC,aBC);
  KSpace:=aKSpace;
  KWidth:=aKWidth;
  KHeight:=aKHeight;
End;

Function TMFIIKbd.AddScanKey(ScanCode : Byte;aFC,aBC,aHFC,aHBC : Byte) : Byte;
Const ScanCodes : Array[0..$39] OF KeyDescription = (
(Name: '^'; X: 36;Y: 00;W: 3;H: 3),
(Name: #0 ; X: 00;Y: 00;W: 0;H: 0),
(Name: '1'; X: 03;Y: 00;W: 3;H: 3),
(Name: '2'; X: 06;Y: 00;W: 3;H: 3),
(Name: '3'; X: 09;Y: 00;W: 3;H: 3),
(Name: '4'; X: 12;Y: 00;W: 3;H: 3),
(Name: '5'; X: 15;Y: 00;W: 3;H: 3),
(Name: '6'; X: 18;Y: 00;W: 3;H: 3),
(Name: '7'; X: 21;Y: 00;W: 3;H: 3),
(Name: '8'; X: 24;Y: 00;W: 3;H: 3),
(Name: '9'; X: 27;Y: 00;W: 3;H: 3),
(Name: '0'; X: 30;Y: 00;W: 3;H: 3),
(Name: '''';X: 33;Y: 00;W: 3;H: 3),
(Name: #0 ; X: 00;Y: 00;W: 0;H: 0),
(Name: #11; X: 39;Y: 00;W: 6;H: 3),
(Name: #9 ; X: 00;Y: 03;W: 5;H: 3),
(Name: 'Q'; X: 05;Y: 03;W: 3;H: 3),
(Name: 'W'; X: 08;Y: 03;W: 3;H: 3),
(Name: 'E'; X: 11;Y: 03;W: 3;H: 3),
(Name: 'R'; X: 14;Y: 03;W: 3;H: 3),
(Name: 'T'; X: 17;Y: 03;W: 3;H: 3),
(Name: 'Z'; X: 20;Y: 03;W: 3;H: 3),
(Name: 'U'; X: 23;Y: 03;W: 3;H: 3),
(Name: 'I'; X: 26;Y: 03;W: 3;H: 3),
(Name: 'O'; X: 29;Y: 03;W: 3;H: 3),
(Name: 'P'; X: 32;Y: 03;W: 3;H: 3),
(Name: 'š'; X: 35;Y: 03;W: 3;H: 3),
(Name: '!'; X: 38;Y: 03;W: 3;H: 3),
(Name: #13; X: 41;Y: 03;W: 4;H: 6),
(Name: #0 ; X: 00;Y: 00;W: 0;H: 0),
(Name: 'A'; X: 06;Y: 06;W: 3;H: 3),
(Name: 'S'; X: 09;Y: 06;W: 3;H: 3),
(Name: 'D'; X: 12;Y: 06;W: 3;H: 3),
(Name: 'F'; X: 15;Y: 06;W: 3;H: 3),
(Name: 'G'; X: 18;Y: 06;W: 3;H: 3),
(Name: 'H'; X: 21;Y: 06;W: 3;H: 3),
(Name: 'J'; X: 24;Y: 06;W: 3;H: 3),
(Name: 'K'; X: 27;Y: 06;W: 3;H: 3),
(Name: 'L'; X: 30;Y: 06;W: 3;H: 3),
(Name: '™'; X: 33;Y: 06;W: 3;H: 3),
(Name: 'Ž'; X: 36;Y: 06;W: 3;H: 3),
(Name: 'õ'; X: 00;Y: 00;W: 3;H: 3),
(Name: #0 ; X: 00;Y: 00;W: 0;H: 0),
(Name: '$'; X: 39;Y: 06;W: 3;H: 3),

{(Name: '<'; X: 00;Y: 09;W: 3;H: 3), }  {'<'-Taste}

(Name: 'Y'; X: 07;Y: 09;W: 3;H: 3),
(Name: 'X'; X: 10;Y: 09;W: 3;H: 3),
(Name: 'C'; X: 13;Y: 09;W: 3;H: 3),
(Name: 'V'; X: 16;Y: 09;W: 3;H: 3),
(Name: 'B'; X: 19;Y: 09;W: 3;H: 3),
(Name: 'N'; X: 22;Y: 09;W: 3;H: 3),
(Name: 'M'; X: 25;Y: 09;W: 3;H: 3),
(Name: ','; X: 28;Y: 09;W: 3;H: 3),
(Name: '.'; X: 31;Y: 09;W: 3;H: 3),
(Name: '-'; X: 34;Y: 09;W: 3;H: 3),
(Name: #0 ; X: 00;Y: 00;W: 0;H: 0),
(Name: #0 ; X: 00;Y: 00;W: 0;H: 0),
(Name: #0 ; X: 00;Y: 00;W: 0;H: 0),
(Name: ' '; X: 12;Y: 12;W:26;H: 3));

Var aKey : PKey;
    aX0,aY0,aX1,aY1,aX2,aY2 : Word;
Begin
  IF Scancodes[ScanCode].W=0 Then Begin
    AddScanKey:=$FF;
    Exit;
  End;
  IF ScanCode>$39 Then Begin
    AddScanKey:=$FF;
    Exit;
  End;
  aX0:=KSpace+ScanCodes[ScanCode].X*(KWidth+KSpace);
  aX1:=aX0+ScanCodes[ScanCode].W*KWidth;
  aY0:=KSpace+ScanCodes[ScanCode].Y*(KHeight+KSpace);
  aY1:=aY0+ScanCodes[ScanCode].H*KHeight;
  IF ScanCode=
  Name: ' '; X: 12;Y: 12;W:26;H: 3));

  IF ScanCode=$1C Then Begin
    aX2:=aX0+1*KHeight;
    aY2:=aY0+3*KHeight;
    aY1:=KSpace+(ScanCodes[ScanCode].Y+ScanCodes[ScanCode].H)*(KHeight+KSpace)-KHeight;
    aKey:=New(PEnter,Init(aX0,aY0,aX1,aY1,aX2,aY2,aFC,aBC,aHFC,aHBC,@Self));
  End Else Begin
    aKey:=New(PKey,Init(aX0,aY0,aX1,aY1,aFC,aBC,aHFC,aHBC,@Self));
  End;
  AddScanKey:=AddKey(aKey);
End;

End.