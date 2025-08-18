Unit TFonts;

Interface

Const taNormal = $0000;
    taBold = $0001;
    taItalics = $0002;
    taUnderline = $0004;
    taHigh = $0008;
    taLow  = $0010;

Type TCharBitM = Array[0..31] Of Byte;
    PFontAr = ^TFontAr;
    TFontAr = Array[0..$FF] Of TCharBitM;
    TFontFile = Record
        ID: Array[0..3] Of Char; { ID = 'GFON'                   }
        Ver: Word;                { Ver= $0100 : Lo/Hi:$00,$01!!! }
        XSize, YSize: Byte;                { Normally 8x8,6x12 or 8x16     }
        DataStart: Word;                { Offset from filestart to Data }
        DescStart: Word;                { Offset from filestart to Desc }
        { here: Possibility for extensions in later versions!!!           }
        { Description: 1Byte Len,String: Char[Len]                        }
        { Data:        TCharBitM[0..$FF]                                  }
    End;
    PVGAFontViewer = ^TVGAFontViewer;
    TVGAFontViewer = Object
        Font: TFontAr;
        XS, YS: Word;
        Constructor Init(FN: String);
        Destructor Done; Virtual;
        Procedure WriteChar(X, Y: Word; C: Char; Col: Byte); Virtual;
        Procedure WriteAttrchar(X, Y: Word; C: Char; Col: Byte; Attr: Word); Virtual;
    End;
Implementation


Constructor TVGAFontViewer.Init(FN: String);
Var FF: File;
    FH: TFontFile;
    R:  Word;
Begin
{$I-}
    Assign (FF, FN);
    ReSet (FF, 1);
    If IOResult <> 0 Then Fail;
    BlockRead (FF, FH, SizeOf (FH), R);
    If R <> SizeOf (FH) Then
    Begin
        Close (FF);
        Fail;
    End;
    Seek (FF, FH.DataStart);
    BlockRead (FF, Font, SizeOf (Font), R);
    If R <> SizeOf (Font) Then
    Begin
        Close (FF);
        Fail;
    End;
    Close (FF);
End;

Destructor TVGAFontViewer.Done;
Begin
End;

Procedure TVGAFontViewer.Writechar(X, Y: Word; C: Char; Col: Byte);
    Assembler;
Asm
    push ds               { Save DS                       }
    cld                   { Clear DF                      }
    lds  si,Self          { DS:SI = @SELF                 }
    mov  al,[si].YS.Byte
    mov  bh,al

    add  si,Offset TVGAFontViewer.Font{ Compute char address}
    xor  ah,ah
    mov  al,C
    shl  ax,5
    add  si,ax

    mov  ax,0A000h        { Display Memory Segment        }
    mov  es,ax
    mov  ax,Y             { Addr=y*80+(x div 8)           }
    sub  ax,8             { Correct Y-Value (8 Pels up)   }
    mov  di,ax
    shl  di,4
    shl  ax,6
    add  di,ax

    mov  ax,X             { Add X/8 to Addr(DI)           }
    mov  cx,ax
    shr  ax,3
    add  di,ax

    and  cl,7             { Pixel Offset                  }

    mov  dx,03CEh         { GDC Controller                }
    xor  al,al            { set/reset ->Color             }
    mov  ah,bh
    out  dx,ax
    mov  ax,0003h         { Function select               }
    out  dx,ax
    mov  ax,0305h         { Write mode 3                  }
    out  dx,ax

    @@2:
    lodsb                 { Get Pixel Mask                }
    xor  ah,ah            { Clear Hibyte                  }
    ror  ax,cl
    mov  bl,es:[di]       { Load latch bytes              }
    stosb                 { Write                         }
    mov  al,ah
    mov  bl,es:[di]       { Load latch bytes              }
    stosb
    add  di,78            { Next line:+78,+2 from STOSW   }
    dec  bh               { Decrement Counter             }
    jnz  @@2              { and check for zero            }
    { Set GDC back to default       }
    MOV  ax,0005h         { Write Modeu 0                 }
    out  dx,al
    mov  ax,0F00h         { set/reset: F                  }
    out  dx,al
    pop  ds
End;
Procedure TVGAFontViewer.WriteAttrchar(X, Y: Word; C: Char; Col: Byte; Attr: Word);
    Assembler;
Asm
    push ds               { Save DS                       }
    cld                   { Clear DF                      }
    lds  si,Self          { DS:SI = @SELF                 }
    mov  al,[si].YS.Byte
    mov  bh,al

    add  si,Offset TVGAFontViewer.Font{ Compute char address}
    xor  ah,ah
    mov  al,C
    shl  ax,5
    add  si,ax

    mov  ax,0A000h        { Display Memory Segment        }
    mov  es,ax
    mov  ax,Y             { Addr=y*80+(x div 8)           }
    test Attr,taLow       { Low or Hi or normal?          }
    jz   @@L0
    sub  ax,4
    @@L0:
    test Attr,taHigh
    jz   @@L1
    sub  ax,12d
    jmp  @@L2
    @@L1:
    sub  ax,8
    @@L2:
    mov  di,ax
    shl  di,4
    shl  ax,6
    add  di,ax

    xor  ch,ch
    mov  ax,X             { Add X/8 to Addr(DI)           }
    test Attr,taItalics   { Italic horiz pixel ofs ?      }
    jz   @@I0
    add  ax,3
    @@I0:
    mov  cl,al
    shr  ax,3
    add  di,ax

    and  cl,7             { Pixel Offset                  }

    mov  dx,03CEh         { GDC Controller                }
    xor  al,al            { set/reset ->Color             }
    mov  ah,bh
    out  dx,ax
    mov  ax,0003h         { Function select               }
    out  dx,ax
    mov  ax,0305h         { Write mode 3                  }
    out  dx,ax

    @@2:
    lodsb                 { Get Pixel Mask                }
    test Attr,taUnderline
    jz   @@U0
    cmp  bh,1
    jnz  @@U0
    mov  al,0FFh
    jmp  @@B0
    @@U0:
    test Attr,taBold
    jz   @@B0
    mov  ah,al
    shr  ah,1
    or   al,ah
    @@B0:
    xor  ah,ah            { Clear Hibyte                  }
    ror  ax,cl
    mov  bl,es:[di]       { Load latch bytes              }
    stosb                 { Write                         }
    mov  al,ah
    mov  bl,es:[di]       { Load latch bytes              }
    stosb
    add  di,78            { Next line:+78,+2 from STOSW   }

    test Attr,taItalics
    jz   @@I1
    inc  ch               { Italic Counter                }
    test ch,2
    jz   @@I1
    dec  cl
    and  cl,007h
    @@I1:
    dec  bh               { Decrement Counter             }
    jnz  @@2              { and check for zero            }
    { Set GDC back to default       }
    MOV  ax,0005h         { Write Modeu 0                 }
    out  dx,al
    mov  ax,0F00h         { set/reset: F                  }
    out  dx,al
    pop  ds
End;

End.
