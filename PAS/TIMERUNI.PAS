Unit TimerUnit;

Interface

Uses SndDraw,
     SndInput;

Type TTimer = Object
       OldTimer : Pointer;
       Speed    : Integer;
       Constructor Init;
       Destructor Done;virtual;
       Procedure SetSpeed;virtual;
       Function GetSpeed : Integer;virtual;
     End;

Implementation

Const Initialized : Boolean = False;

Procedure TimerISR;Assembler;
Asm
  NOP
  NOP
  NOP
  NOP
@@ProcedureStart:
  PUSH DS
  PUSH ES
  PUSHA
  CALL FAR PTR SndDraw.DrawSnd
  CALL FAR PTR SndInput.InputSnd
  POPA
  POP  ES
  POP  DS
  IRET
End;

Constructor TTimer.Init;Assembler;
Asm
  CMP  [Initialized],0
  JNZ  @@Abort
  MOV  [Initialized],1
  PUSH DS
  LDS  SI,Self
  MOV  CS:[Offset TimerISR],SI
  MOV  CS:[Offset TimerISR+2],DS
  MOV  AX,03508h
  INT  21h
  MOV  [SI].TTimer.OldTimer.Word,ES
  MOV  [SI].TTimer.OldTimer.Word+2,BX
  MOV  [SI].TTimer.Speed,1000
  MOV  AX,02508h
  MOV  DX,Seg TimerISR
  MOV  DS,DX
  MOV  DX,Offset TimerISR+4
  INT  21h
  POP  DS
@@Abort:
End;

Destructor TTimer.Done;Assembler;
Asm
  CMP  [Initialized],0
  JZ   @@Abort
  MOV  [Initialized],0
  PUSH DS
  LDS  SI,Self
  LDS  DX,[SI].TTimer.OldTimer
  MOV  AX,2508h
  INT  21h
  POP  DS
@@Abort:
End;

Procedure TTimer.SetSpeed;Assembler;
Asm
End;

Function TTimer.GetSpeed : integer;
Begin
   GetSpeed:=Speed;
End;
End.