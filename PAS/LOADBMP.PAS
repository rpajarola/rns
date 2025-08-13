Unit LoadBmp;

Interface

Type PBMP16 = ^TBMP16;
     TBMP16 = Object
       XRes,YRes : Word;
       Data      : Pointer;
       Constructor Load(FileName : String);
       Destructor Done;Virtual;
       Procedure Display(XS,YS : Word);Virtual;
     End;

Procedure VGA16PutPixel(X,Y : Word;C : Byte);

Implementation

Constructor TBMP16.Load(FileName : String);
Type BitMap_File = Record
       bfType   : Array[0..1] OF Char;
       bfSize   : LongInt;
       Res0     : Array[0..3] Of Byte;
       bfOffs   : LongInt;
     End;
     BitMap_Info = Record
       biSize   : LongInt;
       biWidth  : LongInt;
       biHeight : LongInt;
       biPlanes : Word;
       biBitCnt : Word;
       biCompr  : LongInt;
       biSizeIm : LongInt;
       biXPels  : LongInt;
       biYPels  : LongInt;
       biClrUsed: LongInt;
       biClrImp : LongInt;
     End;
Var F : File;
    Header : BitMap_File;
    Info   : BitMap_Info;
    Code   : Word;
    i      : Word;
Begin
  IF FileName='' Then begin
    data:=nil;
    xres:=0;
    yres:=0;
    exit;
  end;
  Assign(F,FileName);
  FileMode:=0;
{$I-}
  ReSet(F,1);
{$I+}
  FileMode:=2;
  IF IOResult<>0 Then begin
    data:=nil;
    xres:=0;
    yres:=0;
    exit;
  end;
  BlockRead(F,Header,SizeOf(Header),Code);
  IF Code<>SizeOf(Header) Then begin
    data:=nil;
    xres:=0;
    yres:=0;
    Close(F);
    exit;
  end;
  blockRead(F,Info,SizeOf(Info),Code);
  IF Code<>SizeOf(Info) Then begin
    data:=nil;
    xres:=0;
    yres:=0;
    Close(F);
    exit;
  end;
  IF Info.biCompr<>0 Then begin
    data:=nil;
    xres:=0;
    yres:=0;
    Close(F);
    exit;
  end;
  IF Info.biBitCnt<>8 Then begin
    data:=nil;
    xres:=0;
    yres:=0;
    Close(F);
    exit;
  end;
  XRes:=Info.biWidth;
  YRes:=Info.biHeight;
  i:=(XRes+3) and $FFFC;
  GetMem(Data,i*(YRes+1));
  Seek(F,Header.bfOffs);
  BlockRead(F,Data^,i*(YRes+1),Code);
  IF Code<>i*YRes Then begin
    FreeMem(Data,i*(YRes+1));
    data:=nil;
    xres:=0;
    yres:=0;
    Close(F);
    exit;
  End;
  Close(F);
End;

Destructor TBMP16.Done;
Begin
  XRes:=(XRes+3) And $FFFC;
  FreeMem(Data,XRes*YRes);
End;
Procedure VGA16PutPixel(X,Y : Word;C : Byte);Assembler;
Asm
  PUSH AX
  PUSH CX
  PUSH DX
  PUSH DI
  PUSH ES
  MOV  AX,0A000h
  MOV  ES,AX
  MOV  DI,X
  SHR  DI,3
  MOV  AX,Y
  SHL  AX,4
  ADD  DI,AX
  SHL  AX,2
  ADD  DI,AX

  MOV  DX,03CEh
  XOR  AL,AL
  MOV  AH,C
  OUT  DX,AX
  INC  AL
  MOV  AH,0Fh
  OUT  DX,AX
  MOV  AL,08h
  MOV  CX,X
  AND  CX,7
  MOV  AH,80h
  SHR  AH,CL
  OUT  DX,AX
  MOV  AH,ES:[DI]
  MOV  ES:[DI],AL

  MOV  AX,0001h
  OUT  DX,AX
  MOV  AX,0FF08h
  OUT  DX,AX
  POP  ES
  POP  DI
  POP  DX
  POP  CX
  POP  AX
end;
{Procedure TBMP16.Display(XS,YS : Word);Assembler;
Asm
  CLD
  PUSH DS
  LES  DI,Self
  LDS  SI,ES:[DI].TBMP16.Data
  MOV  AX,DS
  OR   AX,SI
  JZ   @@END
  MOV  DX,ES:[DI].TBMP16.YRes
@@1:
  MOV  CX,ES:[DI].TBMP16.XRes
  MOV  BX,XS
  @@2:
    PUSH BX
    MOV  AX,DX
    ADD  AX,YS
    PUSH AX
    LODSB
    PUSH AX
    CALL VGA16PutPixel
    INC  BX
  LOOP @@2
  MOV  AX,ES:[DI].TBMP16.XRes
  AND  AX,3
  INC  AX
  ADD  SI,AX
  INC  SI
  DEC  DX
  JNZ  @@1
@@END:
  POP  DS
End;
}
Procedure TBMP16.Display(XS,YS : Word);Assembler;
Var XR,YR,Step : Word;
Asm
  CLD
  PUSH DS
  LES  DI,Self
  LDS  SI,ES:[DI].TBMP16.Data
  MOV  AX,DS
  OR   AX,SI
  JZ   @@END
  MOV  AX,ES:[DI].TBMP16.YRes
  MOV  YR,AX
  MOV  AX,ES:[DI].TBMP16.XRes
  MOV  XR,AX
  MOV  Step,-80d
  SHR  AX,3
  SUB  Step,AX
  MOV  AX,0A000h
  MOV  ES,AX
  MOV  DI,XS
  SHR  DI,3
  MOV  AX,YS
  ADD  AX,YR
  SHL  AX,4
  ADD  DI,AX
  SHL  AX,2
  ADD  DI,AX
  MOV  DX,03CEh
  MOV  AL,5
  OUT  DX,AL
  INC  DX
  IN   AL,DX
  AND  AL,Not 3
  OR   AL,2
  OUT  DX,AL
  DEC  DX
  MOV  AL,8
  OUT  DX,AL
  INC  DX
{ DX=Graphics Controller Data
  BL=Bit Mask BH=Dummy to load latches
  DS:SI=Source
  ES:DI=Screenpos}
@@1:
  MOV  BL,80h
  MOV  CX,XR
@@2:
  MOV  AL,BL
  OUT  DX,AL
  LODSB
  MOV  ES:[DI],AL
  MOV  BH,ES:[DI]
  ROR  BL,1
  JNC  @@3
  INC  DI
  MOV  BH,ES:[DI]
@@3:
  LOOP @@2
  ADD  DI,Step
  ADD  SI,3
  AND  SI,Not 3
  DEC  YR
  JNZ  @@1
  DEC  DX
  MOV  AL,5
  OUT  DX,AL
  INC  DX
  IN   AL,DX
  AND  AL,Not 3
  OUT  DX,AL
  DEC  DX
  MOV  AL,8
  OUT  DX,AL
  INC  DX
  MOV  AL,0FFh
  OUT  DX,AL
@@END:
  POP  DS
End;


End.