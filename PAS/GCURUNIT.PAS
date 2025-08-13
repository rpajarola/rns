unit gcurunit;

interface

uses graph,
     xcrt,
     crt,
     Mousdrv;

Const CursorXSize  = 9;
      CursorYSize  = 13;
      CurGridXStep = 6;
      CurGridYStep = 8;
      CurGridXS    = 640 Div CurGridXStep;
      CurGridYS    = 424 Div CurGridYStep;

type CursorArr = Array[0..CursorXSize,0..CursorYSize] of word;

var PatternSave, GraphCursor : CursorArr;
    gcxcoord, gcycoord: integer;
    dispcurs: byte; {1= display cursor, 2 = display cursor and grid
                     3= dont display cursor}
    CurGridX : Array[1..CurGridXS] of Word;
    CurGridY:  Array[1..CurGridYS] of word;



procedure GcuCursorClear;{Clear saved patterns}
Procedure GcuIniCursor;{Clear saved patterns+create cursor shape}
procedure GcuMoveCursor(x,y : integer);{move cursor w/o draw}
procedure GcuPatternRestore;{hide cursor}
Procedure GcuCursorRestore;{draw cursor}
Function GcuRightMargin : integer;{zero}
procedure GcuPatternStore;{save pattern}

Type TImg = Record
       XSize,YSize : Word;
       Planes      : Array[0..3] Of Pointer;
     End;

Type TCurImg = Array[0..CursorYSize] Of Word;
Type TCursor = Object
       X,Y                                  : Word;
       V                                    : Boolean;
       MinX,MaxX,MinY,MaxY                  : Word;
       CursorShape,BackGround,XGrids,YGrids : TImg;
       OrgCurShape,EmptyCurShape            : Pointer;
       PatSave                              : Boolean;
       Constructor Init;        { Create cursor shape, clear patterns... }
       Destructor Done;         { Hide cursor, dispose of patterns...    }
       Procedure ReSet;Virtual; { Reset backgrounds, reload shape...     }
       Procedure Show;Virtual;  { draw cursor on screen, save patterns...}
       Procedure Hide;Virtual;  { hide cursor, (restore patterns)        }
       Function Visible : Boolean;{ no comment                           }
       Procedure Move(aX,aY : Word);{ move to pos X,Y, draw if visible   }
       Procedure LoadCursor;    { Load Cursor shape from CURSOR.SHP      }
       Procedure SavePat(X0,Y0,XS,YS : Word;Var I : TImg);{ Save Pattern }
       Procedure DrawPat(X0,Y0 : Word;I : TImg);{ Draw Pattern           }
     End;

implementation

uses initsc;

Var CursorIsOn : Boolean;
{**************************************************************}
Function GcuRightMargin : integer;
begin
  GcuRightMargin:= 0;
end;
{**************************************************************}
procedure MinMax(var imin,imax,jmin,jmax : integer);
begin
  imax:= gcxcoord + (CursorXSize div 2);
  imin:= gcxcoord - (CursorXSize div 2);
  jmax:= gcycoord + (CursorYSize div 2) - 1;
  jmin:= gcycoord - (CursorYSize div 2) - 1;
  if imin>grmaxx then begin
    imin:=grmaxx-(cursorxsize div 2);
    imax:=imin+cursorXSize;
  end;
  if jmin>grmaxy then begin
    jmin:=grmaxy-(cursorysize div 2);
    jmax:=+cursorySize;
  end;
end;

{**************************************************************}
Function GcuGridPosX(i: integer) : integer;
Var a : integer;
begin
  a:=grminx-2+i*curgridxstep;
  IF (a>grmaxx) or (a<1) Then
    a:=4;
  GcuGridPosX:=a;
end;
{**************************************************************}
Function GcuGridPosY(i: integer) : integer;
Var a : Integer;
begin
  a:=grminy-5+i*curgridystep;
  IF (A>grmaxY) or (a<2) then
    a:=3;
  GcuGridPosY:=a;
end;

{**************************************************************}
procedure GcuPatternStore;
var i,j,imin,imax,jmin,jmax : integer;
    b : Boolean;
begin
   b:=not istdunkel;
   if b then mausdunkel;
   MinMax(imin,imax,jmin,jmax);

   for j:= jmin to jmax do
      for i:= imin to imax do
         PatternSave[i-imin,j-jmin]:= GetPixel(i,j);

  if dispcurs = 2 then begin
    for i:= 1 to curgridxs do
      IF Page[gcycoord div linethick-1,1]<>'N' Then
        curgridx[i]:= GetPixel(GcuGridPosX(i), jmin-1);
    for i:= 1 to curgridys do
      curgridy[i]:= GetPixel(gcxcoord, GcuGridPosY(i));
  end;
  if b then mauszeigen;
end;

{**************************************************************}
procedure GcuCursorClear;
var i,j,imin,imax,jmin,jmax : integer;
begin
  MinMax(imin,imax,jmin,jmax);
  for j:= jmin to jmax do
    for i:= imin to imax do
      PatternSave[i-imin,j-jmin]:= bkcolor;
  if dispcurs = 2 then begin
    for i:= 1 to curgridxs do
      curgridx[i]:= bkcolor;
    for i:= 1 to curgridys do
      curgridy[i]:= bkcolor;
  end;
end;

{**************************************************************}
procedure GcuPatternRestore;
var i,j,imin,imax,jmin,jmax : integer;
    b : Boolean;
begin
  IF Not CursorIsOn Then
    Exit;
  CursorIsOn:=False;
  b:=not istdunkel;
  if b then mausdunkel;
  MinMax(imin,imax,jmin,jmax);
  for j:= jmin to jmax do
    for i:= imin to imax do
      PutPixel(i,j,PatternSave[i-imin,j-jmin]);
  if dispcurs = 2 then
  begin
    for i:= 1 to curgridxs do
      IF Page[gcycoord div linethick-1,1]<>'N' Then
        PutPixel(GcuGridPosX(i), jmin-1, curgridx[i]);
    for i:= 1 to curgridys do
      PutPixel(gcxcoord, GcuGridPosY(i), curgridy[i]);
  end;
  if b then mauszeigen;
end;

{**************************************************************}
procedure GcuDrawCursor;

var i, j, imin, imax, jmin, jmax, icorr, jcorr : integer;
    b : Boolean;
begin
  b:=not istdunkel;
  if b then mausdunkel;
  IF Not CursorisOn Then
    GcuPatternStore;
  CursorIsOn:=True;
  if ((not xKeyPressed) and (dispcurs < 3)) then begin
    MinMax(imin,imax,jmin,jmax);
    for j:= jmin to jmax do
      for i:= imin to imax do
        if (i > 1) And (j> 1) And (i < GetmaxX) And (j < GetmaxY-56) then
          PutPixel(i,j,GraphCursor[i-imin,jmax-j]);
    if dispcurs = 2 then begin
      for i:= 1 to curgridxs do
        IF Page[gcycoord div linethick-1,1]<>'N' Then
          PutPixel(GcuGridPosX(i), jmin-1, gridcolor);
      for i:= 1 to curgridys do
        PutPixel(gcxcoord, GcuGridPosY(i), gridcolor);
    end;
  end Else if (dispcurs < 3) Then Begin
    MinMax(imin,imax,jmin,jmax);
    for i:= imin+2 to imax-2 do
      if (i > 1) And (jmin> 1) And (i < GetmaxX)
         And (jmin < GetmaxY-56) then
        PutPixel(i,jmin,GraphCursor[CursorXSize SHR 1,CursorYSize Shr 1]);
  End;
  if b then mauszeigen;
end;

{**************************************************************}
Procedure GcuMoveCursor(x,y : integer);
begin
  gcxcoord:= x;
  gcycoord:= y;
end;

{**************************************************************}
Procedure GcuCursorRestore;
begin
  GcuMoveCursor(gcxcoord, gcycoord);
  GcuDrawCursor;
end;

{**************************************************************}
Procedure GcuIniCursor;
var i,j,k,pfeil : integer;
begin
{initialisiere Cursor-Bild}
  for i:= 0 to CursorYSize do
    for j:= 0 to CursorXSize do
      GraphCursor[j,i]:= bkcolor;
  for i:= 1 to curgridxs do
    curgridx[i]:= bkcolor;
  for i:= 1 to curgridys do
    curgridy[i]:= bkcolor;
{ Pfeil malen }
  pfeil:= CursorXSize div 2 + 2;
  for j:= 0 to CursorYSize - pfeil do
    for i:= CursorXSize div 2 - 2  to CursorXSize div 2 + 2 do
      GraphCursor[i,j]:= curcolor;
  for j:= CursorYSize - pfeil + 1 to CursorYSize - 1 do begin
    k:= j - CursorYSize + pfeil - 1;
    for i:= k to CursorXSize - 1 - k do
      GraphCursor[i,j]:= curcolor;
  end;
end;

Function MemNeed(X,Y : Word) : Word;
Begin
  IF (X And 7)=0 Then
    MemNeed:=(X Div 8)*Y
  Else
    MemNeed:=((X Div 8)+1)*Y;
End;

Procedure DisposeImg(p : TImg);
Var a : Byte;
Begin
  For a:=0 To 3 Do Begin
    FreeMem(p.Planes[a],MemNeed(p.xsize,p.ysize));
  End;
End;

Constructor TCursor.Init;        { Create cursor shape, clear patterns... }
Var a : Byte;
Begin
  LoadCursor;
  BackGround.XSize:=CursorShape.XSize;
  BackGround.YSize:=CursorShape.YSize;
  XGrids.XSize:=1;
  XGrids.YSize:=480;
  YGrids.XSize:=640;
  YGrids.YSize:=1;
  For a:=0 To 3 Do Begin
    GetMem(BackGround.Planes[a],MemNeed(BackGround.XSize,BackGround.YSize));
    FillChar(BackGround.Planes[a]^,MemNeed(BackGround.XSize,BackGround.YSize),0);
    GetMem(XGrids.Planes[a],MemNeed(XGrids.XSize,XGrids.YSize));
    FillChar(XGrids.Planes[a],MemNeed(XGrids.XSize,XGrids.YSize),0);
    GetMem(YGrids.Planes[a],MemNeed(YGrids.XSize,YGrids.YSize));
    FillChar(YGrids.Planes[a],MemNeed(YGrids.XSize,YGrids.YSize),0);
  End;
End;
Destructor TCursor.Done;         { Hide cursor, dispose of patterns...    }
Begin
  Hide;
  DisposeImg(CursorShape);
  DisposeImg(BackGround);
  DisposeImg(XGrids);
  DisposeImg(YGrids);
End;
Procedure TCursor.ReSet;        { Reset backgrounds, reload shape...     }
Var a : Byte;
Begin
  Hide;
  DisposeImg(CursorShape);
  LoadCursor;
  For a:=0 To 3 Do Begin
    FillChar(BackGround.Planes[a]^,MemNeed(BackGround.XSize,BackGround.YSize),0);
    FillChar(XGrids.Planes[a],MemNeed(XGrids.XSize,XGrids.YSize),0);
    FillChar(YGrids.Planes[a],MemNeed(YGrids.XSize,YGrids.YSize),0);
  End;
  Show;
End;
Procedure TCursor.Show;          { draw cursor on screen, save patterns...}
Begin
  IF Not V Then Begin
    V:=True;
    IF PatSave Then
      SavePat(X,Y,BackGround.XSize,BackGround.YSize,BackGround);
    DrawPat(X,Y,CursorShape);
  End;
End;
Procedure TCursor.Hide;          { hide cursor, (restore patterns)        }
Begin
  IF V Then Begin
    V:=False;
    DrawPat(X,Y,BackGround);
  End;
End;
Function TCursor.Visible : Boolean;{ no comment                           }
Begin
  Visible:=V;
End;
Procedure TCursor.Move(aX,aY : Word);{ move to pos X,Y, draw if visible     }
Begin
  IF V Then Begin
    Hide;
    X:=aX;
    Y:=aY;
    Show;
  End Else Begin
    X:=aX;
    Y:=aY;
  End;
End;
Procedure TCursor.LoadCursor;    { Load Cursor shape from CURSOR.SHP      }
Var F : File;
    a : Byte;
Begin
  Assign(F,'CURSOR.SHP');
  System.ReSet(F,1);
  BlockRead(F,CursorShape,4);
  GetMem(OrgCurShape,MemNeed(CursorShape.XSize,CursorShape.YSize));
  GetMem(EmptyCurShape,MemNeed(CursorShape.XSize,CursorShape.YSize));
  BlockRead(F,OrgCurShape^,MemNeed(CursorShape.XSize,CursorShape.YSize));
  FillChar(EmptyCurShape^,MemNeed(CursorShape.XSize,CursorShape.YSize),0);
  For a:=0 To 3 Do Begin
    IF CurColor And (1 Shl a)<>0 Then
      CursorShape.Planes[a]:=OrgCurShape
    Else
      CursorShape.Planes[a]:=EmptyCurShape
  End;
End;
Procedure TCursor.SavePat(X0,Y0,XS,YS : Word;Var I : TImg);Assembler;{ Save Pattern }
{TImg = Record
  XSize,YSize : Word;
  Planes      : Array[0..3] Of Pointer;
End;}
Asm
(*  MOV  DX,03CEh
  MOV  AL,08   { Pixel mask     }
  MOV AH,Mask*)
End;
Procedure TCursor.DrawPat(X0,Y0 : Word;I : TImg);Assembler;{ Draw Pattern }
Asm
End;

begin
  dispcurs:= 1;
  CursorIsOn:=False;
end.
