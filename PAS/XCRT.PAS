{$I RNS.H}
unit Xcrt;
{$D-}
{$L-}
{$Y-}
interface

function XReadKey(var shiftp, ctrlp: boolean): char;
Function XKeypressed: Boolean;
Procedure XClearKbd;

implementation

var lastkey: char;
    extended: boolean;

function XReadKey(var shiftp, ctrlp: boolean): char;assembler;
asm
  xor  al,al
  les  di,ctrlp
  mov  es:[di],al
  les  di,shiftp
  mov  es:[di],al
  cmp  extended,0
  jz   @@notextended

  mov  extended,al
  mov  bl,LastKey
  jmp  @@3
@@notextended:
  mov  ah,10h
  int  16h
  or   al,al                    {al=0 or al=224->extended key           }
  jz   @@isext
  cmp  al,224d
  jnz  @@noext
@@isext:
  mov  extended,TRUE
  mov  lastkey,ah
  xor  al,al
@@noext:
  mov  bx,ax
  mov  ah,12h                   {get kbd flags...:)                     }
  int  16h
  test al,3                     {shift? left or right...                }
  jz   @@1
  les  di,shiftp
  mov  byte ptr es:[di],1
@@1:
  test al,4                     {ctrl?                                  }
  jz   @@2
  les  di,ctrlp
  mov  byte ptr es:[di],1
@@2:
  test ah,8                     {???                                    }
  jz   @@3                      {exchange scancodes: 44<->21            }
  cmp  lastkey,21d
  jnz  @@4
  mov  lastkey,44d
  jmp  @@3
@@4:
  cmp  lastkey,44d
  jnz  @@3
  mov  lastkey,21d
@@3:
  mov  al,bl
end;

Function XKeyPressed: Boolean;Assembler;
Asm
  XOR AX,AX
  MOV ES,AX
  MOV AX,Word PTR ES:[$041A]
  XOR AX,Word PTR ES:[$041C]
  OR  AL,extended
  RET
@001:
end;

{*********************************}
Procedure XClearKbd;Assembler;
{L”scht den Tastatur-Buffer}
Asm
  XOR AX,AX
  MOV ES,AX
  MOV Extended,AL
  CLI
  MOV AX,Word PTR ES:[$041A]
  MOV Word PTR ES:[$041C],AX
  STI
End;

begin
   extended:= false;
end.