Unit TimerUnit;

Interface

Uses SndDraw,
    SndInput;

Type TTimer = Object
        OldTimer: Pointer;
        Speed: Integer;
        Constructor Init;
        Destructor Done; Virtual;
        Procedure SetSpeed; Virtual;
        Function GetSpeed: Integer; Virtual;
    End;

Implementation

Const Initialized: Boolean = False;

Procedure TimerISR; Assembler;
Asm
    nop
    nop
    nop
    nop
    @@ProcedureStart:
    push ds
    push es
    pusha
    call FAR PTR SndDraw.DrawSnd
    call FAR PTR SndInput.InputSnd
    popa
    pop  es
    pop  ds
    iret
End;

Constructor TTimer.Init; Assembler;
Asm
    cmp  [Initialized],0
    jnz  @@Abort
    mov  [Initialized],1
    push ds
    lds  si,Self
    mov  cs:[Offset TimerISR],si
    mov  cs:[Offset TimerISR+2],ds
    mov  ax,03508h
    int  21h
    mov  [si].TTimer.OldTimer.Word,es
    mov  [si].TTimer.OldTimer.Word+2,bx
    mov  [si].TTimer.Speed,1000
    mov  ax,02508h
    mov  dx,Seg TimerISR
    mov  ds,dx
    mov  dx,Offset TimerISR+4
    int  21h
    pop  ds
    @@Abort:
End;

Destructor TTimer.Done; Assembler;
Asm
    cmp  [Initialized],0
    jz   @@Abort
    mov  [Initialized],0
    push ds
    lds  si,Self
    lds  dx,[si].TTimer.OldTimer
    mov  ax,2508h
    int  21h
    pop  ds
    @@Abort:
End;

Procedure TTimer.SetSpeed; Assembler;
Asm
End;

Function TTimer.GetSpeed: integer;
Begin
    GetSpeed := Speed;
End;
End.
