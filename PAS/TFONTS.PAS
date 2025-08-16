Unit TFonts;

Interface

const taNormal    = $0000;
      taBold      = $0001;
      taItalics   = $0002;
      taUnderline = $0004;
      taHigh      = $0008;
      taLow       = $0010;

Type TCharBitM = Array[0..31] OF Byte;
     PFontAr = ^TFontAr;
     TFontAr = Array[0..$FF] OF TCharBitM;
     TFontFile = Record
       ID         : Array[0..3] OF Char; { ID = 'GFON'                   }
       Ver        : Word;                { Ver= $0100 : Lo/Hi:$00,$01!!! }
       XSize,YSize: Byte;                { Normally 8x8,6x12 or 8x16     }
       DataStart  : Word;                { Offset from filestart to Data }
       DescStart  : Word;                { Offset from filestart to Desc }
       { here: Possibility for extensions in later versions!!!           }
       { Description: 1Byte Len,String: Char[Len]                        }
       { Data:        TCharBitM[0..$FF]                                  }
     End;
     PVGAFontViewer = ^TVGAFontViewer;
     TVGAFontViewer = Object
       Font  : TFontAr;
       XS,YS : Word;
       Constructor Init(FN : String);
       Destructor Done;Virtual;
       Procedure WriteChar(X,Y : Word;C : Char;Col : Byte);Virtual;
       Procedure WriteAttrchar(X,Y : Word;C : Char;Col : Byte;Attr : Word);Virtual;
     End;
Implementation


Constructor TVGAFontViewer.Init(FN : String);
Var FF : File;
    FH : TFontFile;
    R  : Word;
Begin
{$I-}
  Assign(FF,FN);
  ReSet(FF,1);
  IF IOResult<>0 Then Fail;
  BlockRead(FF,FH,SizeOf(FH),R);
  IF R<>SizeOf(FH) Then Begin
    Close(FF);
    Fail;
  End;
  Seek(FF,FH.DataStart);
  BlockRead(FF,Font,SizeOf(Font),R);
  IF R<>SizeOf(Font) Then Begin
    Close(FF);
    Fail;
  End;
  Close(FF);
End;

Destructor TVGAFontViewer.Done;
Begin
End;

Procedure TVGAFontViewer.Writechar(X,Y : Word;C : Char;Col : Byte);
Assembler;
Asm
  PUSH DS               { Save DS                       }
  CLD                   { Clear DF                      }
  LDS  SI,Self          { DS:SI = @SELF                 }
  MOV  AL,[SI].YS.Byte
  MOV  BH,AL

  ADD  SI,Offset TVGAFontViewer.Font{ Compute char address}
  XOR  AH,AH
  MOV  AL,C
  SHL  AX,5
  ADD  SI,AX

  MOV  AX,0A000h        { Display Memory Segment        }
  MOV  ES,AX
  MOV  AX,Y             { Addr=y*80+(x div 8)           }
  SUB  AX,8             { Correct Y-Value (8 Pels up)   }
  MOV  DI,AX
  SHL  DI,4
  SHL  AX,6
  ADD  DI,AX

  MOV  AX,X             { Add X/8 to Addr(DI)           }
  MOV  CX,AX
  SHR  AX,3
  ADD  DI,AX

  AND  CL,7             { Pixel Offset                  }

  MOV  DX,03CEh         { GDC Controller                }
  XOR  AL,AL            { set/reset ->Color             }
  MOV  AH,BH
  OUT  DX,AX
  MOV  AX,0003h         { Function select               }
  OUT  DX,AX
  MOV  AX,0305h         { Write mode 3                  }
  OUT  DX,AX

@@2:
  LODSB                 { Get Pixel Mask                }
  XOR  AH,AH            { Clear Hibyte                  }
  ROR  AX,CL
  MOV  BL,ES:[DI]       { Load latch bytes              }
  STOSB                 { Write                         }
  MOV  AL,AH
  MOV  BL,ES:[DI]       { Load latch bytes              }
  STOSB
  ADD  DI,78            { Next line:+78,+2 from STOSW   }
  DEC  BH               { Decrement Counter             }
  JNZ  @@2              { and check for zero            }
                        { Set GDC back to default       }
  MOV  AX,0005h         { Write Modeu 0                 }
  OUT  DX,AL
  MOV  AX,0F00h         { set/reset: F                  }
  OUT  DX,AL
  POP  DS
End;
Procedure TVGAFontViewer.WriteAttrchar(X,Y : Word;C : Char;Col : Byte;Attr : Word);
Assembler;
Asm
  PUSH DS               { Save DS                       }
  CLD                   { Clear DF                      }
  LDS  SI,Self          { DS:SI = @SELF                 }
  MOV  AL,[SI].YS.Byte
  MOV  BH,AL

  ADD  SI,Offset TVGAFontViewer.Font{ Compute char address}
  XOR  AH,AH
  MOV  AL,C
  SHL  AX,5
  ADD  SI,AX

  MOV  AX,0A000h        { Display Memory Segment        }
  MOV  ES,AX
  MOV  AX,Y             { Addr=y*80+(x div 8)           }
  TEST Attr,taLow       { Low or Hi or normal?          }
  JZ   @@L0
  SUB  AX,4
@@L0:
  TEST Attr,taHigh
  JZ   @@L1
  SUB  AX,12d
  JMP  @@L2
@@L1:
  SUB  AX,8
@@L2:
  MOV  DI,AX
  SHL  DI,4
  SHL  AX,6
  ADD  DI,AX

  XOR  CH,CH
  MOV  AX,X             { Add X/8 to Addr(DI)           }
  TEST Attr,taItalics   { Italic horiz pixel ofs ?      }
  JZ   @@I0
  ADD  AX,3
@@I0:
  MOV  CL,AL
  SHR  AX,3
  ADD  DI,AX

  AND  CL,7             { Pixel Offset                  }

  MOV  DX,03CEh         { GDC Controller                }
  XOR  AL,AL            { set/reset ->Color             }
  MOV  AH,BH
  OUT  DX,AX
  MOV  AX,0003h         { Function select               }
  OUT  DX,AX
  MOV  AX,0305h         { Write mode 3                  }
  OUT  DX,AX

@@2:
  LODSB                 { Get Pixel Mask                }
  TEST Attr,taUnderline
  JZ   @@U0
  CMP  BH,1
  JNZ  @@U0
  MOV  AL,0FFh
  JMP  @@B0
@@U0:
  TEST Attr,taBold
  JZ   @@B0
  MOV  AH,AL
  SHR  AH,1
  OR   AL,AH
@@B0:
  XOR  AH,AH            { Clear Hibyte                  }
  ROR  AX,CL
  MOV  BL,ES:[DI]       { Load latch bytes              }
  STOSB                 { Write                         }
  MOV  AL,AH
  MOV  BL,ES:[DI]       { Load latch bytes              }
  STOSB
  ADD  DI,78            { Next line:+78,+2 from STOSW   }

  TEST Attr,taItalics
  JZ   @@I1
  INC  CH               { Italic Counter                }
  TEST CH,2
  JZ   @@I1
  DEC  CL
  AND  CL,007h
@@I1:
  DEC  BH               { Decrement Counter             }
  JNZ  @@2              { and check for zero            }
                        { Set GDC back to default       }
  MOV  AX,0005h         { Write Modeu 0                 }
  OUT  DX,AL
  MOV  AX,0F00h         { set/reset: F                  }
  OUT  DX,AL
  POP  DS
End;
    
End.