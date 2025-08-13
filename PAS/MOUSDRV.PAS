Unit Mousdrv;
{$D-,L-,Y-}

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

uses dos,
     graph,
     crt;

const Pfeil : array[0..31] of integer =
      (8191,4095,2047,1023,0511,0255,0127,0063
      ,0031,0015,0007,0007,0007,0127,6207,-1985
      ,0000,16384,24576,28672,30720,31744,32256,32512
      ,32640,32704,32736,32752,26112,17152,0768,0384);

      Balken : array[0..31] of word =
      ($ffff,$ffff,$f00f,$f00f,$f00f,$f00f,$f00f,$f00f
      ,$f00f,$f00f,$f00f,$f00f,$f00f,$f00f,$ffff,$ffff
      ,$0000,$0000,$0ff0,$0ff0,$0ff0,$0ff0,$0ff0,$0ff0
      ,$0ff0,$0ff0,$0ff0,$0ff0,$0ff0,$0ff0,$0000,$0000);

      mausmaxbereiche = 4;

type mausbereichtyp = record
        mausxmin, mausxmax, mausymin, mausymax: word;
        mausbereichactive: boolean;
        maustaste: word;
     end;

var Mausdruck, mausinbereich, mausposx, mausposy: word;
    mausbereiche: array[1..mausmaxbereiche] of mausbereichtyp;
    Dunkel : Boolean;
{******************************************************}
Procedure MausInstall;
var  mausvektor: pointer absolute $0000:$00cc;
     i: word;

begin
   Dunkel:=True;
   if mausvektor <> nil then
   begin
      ASM
        XOR AX,AX
        MOV Mausform,AL
        INT 33h
        MOV mausexist,AL
      End;
   end;
   FillChar(mausbereiche,SizeOf(mausbereiche),0);
{   for i:= 1 to mausmaxbereiche do
   begin
      mausbereiche[i].mausxmin:= 0;
      mausbereiche[i].mausxmax:= 0;
      mausbereiche[i].mausymin:= 0;
      mausbereiche[i].mausymax:= 0;
   end;}
end;


{******************************************************}
Procedure MausZeigen;Assembler;
Asm
  CMP Mausexist,False
  JE @001
  CMP Dunkel,False
  JE @001
  DEC Dunkel
  MOV AX,1
  INT 33h
  @001:
End;
{******************************************************}
Procedure MausDunkel;Assembler;
Asm
  CMP Mausexist,False
  JE @001
  CMP Dunkel,False
  JNE @001
  INC Dunkel
  MOV AX,2
  INT 33h
  @001:
End;
{******************************************}

Function IstDunkel : Boolean;
Begin
  IstDunkel:=Dunkel;
End;

{******************************************}
Function MausPosOk(cursorx, cursory, mausnum: word) : boolean;
{True falls entweder Graphikmaus, oder Mausposition
 innerhalb erlaubter koordinaten ist}

begin
   MausPosOk:= {((mausform > 0) or}
                (mausbereiche[mausnum].mausbereichactive and
                 (cursorx >= mausbereiche[mausnum].mausxmin) and
                 (cursorx <= mausbereiche[mausnum].mausxmax) and
                 (cursory >= mausbereiche[mausnum].mausymin) and
                 (cursory <= mausbereiche[mausnum].mausymax));
end;

{******************************************************}
Procedure MausPosition(var cursorx, cursory, trel,tpress, mausmenu: word);

Procedure CheckBereich;
var i :Word;
Begin
  for i:=2 to mausmaxbereiche do
    if (mausposok(cursorx, cursory, i)) then
      break;
  if not (((trel and MseEsc)=0) And mausposok(cursorx,cursory,i)) Then
    i:=1;
  if i > mausmaxbereiche then begin
    TRel:= 0;
  end else begin
    mausinbereich:= i;
  end;
End;
Procedure PressRelease;
Begin
  IF ((TRel and 1) = 0) Then Begin
    If ((mausdruck and 1) =1) Then Begin
      mausdruck:=mausdruck and not 1;
      TRel:=TRel or 1;
    End;
  End Else Begin
    mausdruck:=mausdruck or 1;
    TRel:=TRel and not 1;
  End;
  IF ((TRel and 2) = 0) Then Begin
    If ((mausdruck and 2) =2) Then Begin
      mausdruck:=mausdruck and not 2;
      TRel:=TRel or 2;
    End;
  End Else Begin
    mausdruck:=mausdruck or 2;
    TRel:=TRel and not 2;
  End;
  IF ((TRel and 4) = 0) Then Begin
    If ((mausdruck and 4) =4) Then Begin
      mausdruck:=mausdruck and not 4;
      TRel:=TRel or 4;
    End;
  End Else Begin
    mausdruck:=mausdruck or 4;
    TRel:=TRel and not 4;
  End;
End;
begin
   if mausexist then
   begin
      Asm
        MOV AX,3
        INT 33h
        LES DI,Cursorx
        MOV ES:[DI],CX
        LES DI,Cursory
        MOV ES:[DI],DX
        LES DI,TPress
        MOV ES:[DI],BX
      End;
      TRel:=TPress;
      CheckBereich;
      PressRelease;
      mausmenu:= mausinbereich;
      mausposx:= cursorx;
      mausposy:= cursory;
   end else begin
      cursorx:= 0;
      cursory:= 0;
      TRel:= 0;
      TPress:=0;
      mausmenu:= 0;
   end;
end;
{*****************************************************}
Procedure MausPressedPosition(var cursorx, cursory: word);

begin
   if mausexist then
   begin
      cursorx:= mausposx;
      cursory:= mausposy;
   end
   else
   begin
      cursorx:= 0;
      cursory:= 0;
   end;
end;

{******************************************************}
Procedure MausGrafik(mausbild: byte);
begin
   if mausexist then
   begin
      mausform:= mausbild;
      if mausbild > 0 then
      begin
         Asm
            MOV AX,9
            MOV BX,8
            MOV CX,BX
            CMP Mausbild,1
            JNE @001
            MOV DX,Offset Pfeil[0]
            MOV AX,Seg Pfeil[0]
            MOV ES,AX
            JMP @002
          @001:
            MOV DX,Offset Balken[0]
            MOV AX,Seg Balken[0]
            MOV ES,AX
          @002:
          INT 33h
         end
      end;
   end;
end;

{*************************************************************}
Procedure MausBereichAdd(xmin, xmax, ymin, ymax, mausnum: integer);

begin
   if mausexist then
   begin
      mausbereiche[mausnum].mausxmin:= xmin;
      mausbereiche[mausnum].mausxmax:= xmax;
      mausbereiche[mausnum].mausymin:= ymin;
      mausbereiche[mausnum].mausymax:= ymax;
      mausbereiche[mausnum].mausbereichactive:= true;
   end;
end;

{*************************************************************}
Procedure MausBereich(xmin, xmax, ymin, ymax: integer);

var i: word;

begin
   if mausexist then
   begin
      for i:= 2 to mausmaxbereiche do
      begin
         mausbereiche[i].mausbereichactive:= false;
      end;
      mausinbereich:= 0;

      if mausform = 0 then
      begin
         {Textmode Maus}
         mausbereiche[1].mausxmin:= xmin;
         mausbereiche[1].mausxmax:= xmax;
         mausbereiche[1].mausymin:= ymin;
         mausbereiche[1].mausymax:= ymax;
         mausbereiche[1].mausbereichactive:= true;
         Asm
           MOV AX,7
           XOR CX,CX
           MOV DX,640
           INT 33h
           MOV AX,8
           XOR CX,CX
           MOV DX,200
           INT 33h
         End;
      end
      else
      begin
         Asm
            MOV AX,7
            MOV CX,XMin
            MOV DX,XMax
            INT 33h
            MOV AX,8
            MOV CX,YMin
            MOV DX,YMax
            INT 33h
         end;
      end;
   end;
end;

Procedure MausSetXY(x,y:Word);Assembler;
Asm
   MOV AX,4
   MOV CX,X
   MOV DX,Y
   INT 33h
End;

Procedure MausPos(Var cursorx, cursory, taste, mausmenu: Word);
var i: integer;

begin
   if mausexist then
   begin
      Asm
        MOV AX,3
        INT 33h
        LES DI,Cursorx
        MOV ES:[DI],CX
        LES DI,Cursory
        MOV ES:[DI],DX
        MOV mausposx,CX
        MOV mausposy,DX
        LES DI,Taste
        CMP BX,3
        JNE @001
        MOV BX,7 {linke + rechte taste wie alle 3 tasten behandeln}
      @001:
        MOV ES:[DI],BX
      End;
      if taste <> 0 then
      begin
         for i:=2 to mausmaxbereiche do
           if (mausposok(cursorx, cursory, i)) then
              break;
         if not ((taste < 7) or (mausposok(cursorx,cursory,i))) then
            i:=1;
         if i > mausmaxbereiche then
         begin
            taste:= 0;
            mausmenu:=0;
         end
         else
         begin
            mausmenu:= i;
         end;
      end;
   end
   else
   begin
      cursorx:= 0;
      cursory:= 0;
      taste:= 0;
      mausmenu:= 0;
   end;
end;

Begin
   Mausexist:= false;
   Mausdruck:= 0;
   Mausinbereich:= 0;
end.