unit dmemunit;

interface

uses dos,
     graph,
     initsc;

Procedure DmePlaceWord(x,y : integer; w : word);
Procedure DmeDispChar(x, y: integer; c : char; blnum: integer);

implementation

uses helpunit;

{******************************************************************}
Procedure DmeDispChar(x, y: integer; c : char; blnum: integer);

var i, j : integer;
    muster : word;

begin
  if ((x>=0) and (y>1) and (x<=gmaxx) and (y < (gmaxy - 1))) then begin
    for i:= 1 to 15 do begin
      muster:= symarr[c, i, blnum];
      if y-8+i<=grmaxy Then
        DmePlaceWord(x - 7, y - 8 + i , muster);
    end;
  end;
end;

{******************************************************************}
Procedure DmePlaceWord(x,y : integer; w : word);

var acolor: byte;

begin
   acolor:= getcolor;
   Asm
     CLD
     MOV AX,W
     MOV CX,16
   @001:
     SHL AX,1
     JNC @002
     PUSH AX
     PUSH CX
     MOV BX,16
     SUB BX,CX
     ADD BX,X
     CMP BX,1
     JLE @003
     CMP BX,639
     JGE @003
     PUSH BX
     PUSH Y
     PUSH Word Ptr ACOLOR
     CALL PutPixel
   @003:
     POP CX
     POP AX
   @002:
     LOOP @001
   End;
end;

end.
