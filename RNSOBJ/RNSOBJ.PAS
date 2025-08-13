Unit RNSOBj;

Interface

const rpFull  = rpDraw+rpErase;
      rpDraw  = 1;
      rpErase = 2;

Type PRNSObj = ^TRNSObj;
     TRNSObj = Object
     { Initialize...}
       Constructor Init;
     { And Clean Up }
       Destructor Done;virtual;
     { Repaint Area: GLOBAL COORDINATES!!! }
       Procedure Repaint(minX,minY,maxX,maxY : integer;attr : word);virtual;
     { Get Local Coordinates: Relative to Owner }
       Function GetPosX : integer;virtual;
       Function GetPosY : integer;virtual;
       Function GetminX : integer;virtual;
       Function GetminY : integer;virtual;
       Function GetmaxX : integer;virtual;
       Function GetmaxY : integer;virtual;
     { Get Global Coordinates: Relative to Screen }
       Function GetGlobalPosX : integer;
       Function GetGlobalPosY : integer;
       Function GetGlobalminX : integer;
       Function GetGlobalminY : integer;
       Function GetGlobalmaxX : integer;
       Function GetGlobalmaxY : integer;
     { Convert Gloabl<->Local coordinates }
       Function Global2LocalX(X : integer) : integer;
       Function Global2LocalY(Y : integer) : integer;
       Function Local2GlobalX(X : integer) : integer;
       Function Local2GlobalY(Y : integer) : integer;
       Owner : PRNSObj;
     End;
     PPage = ^TPage;
     TPage = Object (TRNSObj)
       Constructor Init;
       Destructor Done;virtual;
       Procedure Repaint(minX,minY,maxX,maxY : integer;attr : word);virtual;
       Function GetPosX : integer;virtual;
       Function GetPosY : integer;virtual;
       Function GetminX : integer;virtual;
       Function GetminY : integer;virtual;
       Function GetmaxX : integer;virtual;
       Function GetmaxY : integer;virtual;
       Lines    : Array[0..PageLength] of PLine
       PageNum  : integer;
       NextPage : PPage;
       PrevPage : PPage;
     End;
     PLine = ^TLine;
     TLine = Object (TRNSObj)
       Constructor Init;
       Destructor Done;virtual;
       Procedure Repaint(minX,minY,maxX,maxY : integer;attr : word);virtual;
       Function GetPosX : integer;virtual;
       Function GetPosY : integer;virtual;
       Function GetminX : integer;virtual;
       Function GetminY : integer;virtual;
       Function GetmaxX : integer;virtual;
       Function GetmaxY : integer;virtual;
       LineNum  : integer;
       NextLine : PLine;
       PrevLine : PLine;
     End;
     PTextLine = ^TTextLine;
     TTextLine = Object (TLine)
       Constructor Init;
       Destructor Done;virtual;
       Procedure Repaint(minX,minY,maxX,maxY : integer;attr : word);virtual;
       Function GetminX : integer;virtual;
       Function GetminY : integer;virtual;
       Function GetmaxX : integer;virtual;
       Function GetmaxY : integer;virtual;
       Attr : word;
       Text : string;
     End;
     PNoteLine = ^TNoteLine;
     TNoteLine = Object (TLine)
       Constructor Init;
       Destructor Done;virtual;
       Procedure Repaint(minX,minY,maxX,maxY : integer;attr : word);virtual;
       Function GetminX : integer;virtual;
       Function GetminY : integer;virtual;
       Function GetmaxX : integer;virtual;
       Function GetmaxY : integer;virtual;
       Attr : word;
       FirstNote : PNote;
       LastNote : PNote;
     End;
     PNote = ^TNote;
     TNote = Object (TRNSObj)
       Constructor Init;
       Destructor Done;virtual;
       Procedure Repaint(minX,minY,maxX,maxY : integer;attr : word);virtual;
       Function GetminX : integer;
       Function GetminY : integer;
       Function GetmaxX : integer;
       Function GetmaxY : integer;
       Attr : word;
       NextNote : PNote;
       PrevNote : PNote;
     End;
Implementation
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{ *                                                               * }
{ *   TRNSOObj                                                    * }
{ *                                                               * }
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Constructor TRNSObj.Init;
Begin
  Owner:=NIL;
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Destructor TRNSObj.Done;
Begin
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Procedure TRNSObj.Repaint(minX,minY,maxX,maxY : integer;attr : word);
Begin
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Function TRNSObj.GetPosX : integer;
Begin
  GetPosX:=0;
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Function TRNSObj.GetPosY : integer;
Begin
  GetPosY:=0;
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Function TRNSObj.GetminX : integer;
Begin
  GetminX:=0;
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Function TRNSObj.GetminY : integer;
Begin
  GetminY:=0;
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Function TRNSObj.GetmaxX : integer;
Begin
  GetmaxX:=0;
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Function TRNSObj.GetmaxY : integer;
Begin
  GetmaxY:=0;
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Function TRNSObj.GetGlobalPosX : integer;
Begin
  GetGlobalPosX:=Local2GlobalX(GetPosX);
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Function TRNSObj.GetGlobalPosY : integer;
Begin
  GetGlobalPosY:=Local2GlobalY(GetPosY);
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Function TRNSObj.GetGlobalminX : integer;
Begin
  GetGlobalminX:=Local2GlobalX(GetminX);
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Function TRNSObj.GetGlobalminY : integer;
Begin
  GetGlobalminY:=Local2GlobalY(GetminY);
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Function TRNSObj.GetGlobalmaxX : integer;
Begin
  GetGlobalmaxX:=Local2GlobalX(GetmaxX);
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Function TRNSObj.GetGlobalmaxY : integer;
Begin
  GetGlobalmaxY:=Local2GlobalY(GetmaxY);
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Function TRNSObj.Global2LocalX(X : integer) : integer;
Var tempOwner : PRNSObj;
Begin
  tempOwner:=self;
  while Owner<>NIL Do
    x:=x-tempOwner.GetPosX;
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Function TRNSObj.Global2LocalY(Y : integer) : integer;
Var tempOwner : PRNSObj;
Begin
  tempOwner:=self;
  while Owner<>NIL Do
    y:=y-tempOwner.GetPosY;
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Function TRNSObj.Local2GlobalX(X : integer) : integer;
Var tempOwner : PRNSObj;
Begin
  tempOwner:=self;
  while Owner<>NIL Do
    x:=x+tempOwner.GetPosX;
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
Function TRNSObj.Local2GlobalY(Y : integer) : integer;
Var tempOwner : PRNSObj;
Begin
  tempOwner:=self;
  while Owner<>NIL Do
    y:=y+tempOwner.GetPosY;
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{ *                                                               * }
{ * TPage                                                         * }
{ *                                                               * }
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
TPage.
Constructor TPage.Init;
Begin
End;
Destructor TPage.Done;
Begin
End;
Procedure TPage.Repaint(minX,minY,maxX,maxY : integer;attr : word);
Begin
  if (attr and rpErase)=rpErase then Begin
    {--EraseRect--}
  End;
  For a:=0 to PageLength do
    Lines[a]^.Repaint(minX,minY,maxX,maxY,attr and (not rpErase));
End;
Function TPage.GetPosX : integer;
Begin
  GetPosX:=0;
End;
Function TPage.GetPosY : integer;
Begin
  GetPosY:=0;
End;
Function TPage.GetminX : integer;
Begin
  GetminX:=0;
End;
Function TPage.GetminY : integer;
Begin
  GetminY:=0;
End;
Function TPage.GetmaxX : integer;
Begin
  GetmaxX:=639;
End;
Function TPage.GetmaxY : integer;
Begin
  GetmaxY:=479;
End;
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
{ *                                                               * }
{ * TLine                                                         * }
{ *                                                               * }
{ * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }
     TLine = Object (TRNSObj)
       Constructor Init;
       Destructor Done;virtual;
       Procedure Repaint(minX,minY,maxX,maxY : integer);virtual;
       Function GetPosX : integer;
       Function GetPosY : integer;
       Function GetminX : integer;
       Function GetminY : integer;
       Function GetmaxX : integer;
       Function GetmaxY : integer;
       LineNum  : integer;
       NextLine : PLine;
       PrevLine : PLine;
     End;
     PTextLine = ^TTextLine;
     TTextLine = Object (TLine)
       Constructor Init;
       Destructor Done;virtual;
       Procedure Repaint(minX,minY,maxX,maxY : integer);virtual;
       Function GetminX : integer;
       Function GetminY : integer;
       Function GetmaxX : integer;
       Function GetmaxY : integer;
       Attr : word;
       Text : string;
     End;
     PNoteLine = ^TNoteLine;
     TNoteLine = Object (TLine)
       Constructor Init;
       Destructor Done;virtual;
       Procedure Repaint(minX,minY,maxX,maxY : integer);virtual;
       Function GetminX : integer;
       Function GetminY : integer;
       Function GetmaxX : integer;
       Function GetmaxY : integer;
       Attr : word;
       FirstNote : PNote;
       LastNote : PNote;
     End;
     PNote = ^TNote;
     TNote = Object (TRNSObj)
       Constructor Init;
       Destructor Done;virtual;
       Procedure Repaint(minX,minY,maxX,maxY : integer);virtual;
       Function GetminX : integer;
       Function GetminY : integer;
       Function GetmaxX : integer;
       Function GetmaxY : integer;
       Attr : word;
       NextNote : PNote;
       PrevNote : PNote;
     End;
End.