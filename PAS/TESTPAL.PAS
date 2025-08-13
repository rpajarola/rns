Program TestPal;

Type TPalette = Array[0..$FF] Of Record
       r,g,b : Byte;
     End;
Var ThePalette,Pal1: TPalette;

Procedure GetDAC(Var P : TPalette);Assembler;
Asm
  CLD                         { Clear dir flag                        }
  LES  DI,P                   { ES:DI=@Palette                        }
  MOV  CX,3*100h              { 3*100h bytes                          }
  MOV  DX,3C8h                { DAC                                   }
  XOR  AL,AL                  { Index:0                               }
  OUT  DX,AL
  INC  DX                     { Data:                                 }
@@1:
  DB   0E4h,060h              { waste some time                       }
  IN   AL,DX                  { Get Byte, Idx will be incremented auto}
  STOSB                       { store                                 }
  DEC  CX                     { =loop                                 }
  JNZ  @@1
End;
Procedure SetDAC(Var P : TPalette);Assembler;
Asm
  PUSH DS                     { save DS                               }
  LDS  SI,P                   { Source                                }
  CLD                         { clear dir flag                        }
  MOV  CX,3*100h              { 3*100h Bytes                          }
  MOV  DX,3C8h                { DAC                                   }
  XOR  AL,AL                  { Index:0                               }
  OUT  DX,AL
  INC  DX                     { Data                                  }
@@1:
  DB   0E4h,060h              { waste some time                       }
  LODSB                       { get byte                              }
  OUT  DX,AL                  { write                                 }
  DEC  CX                     { =loop                                 }
  JNZ  @@1
  POP  DS
End;

Begin
  GetDAC(ThePalette);
  SetDAC(ThePalette);
  GetDAC(Pal1);
End.