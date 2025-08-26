Program ConvFont;

Type TCharBitM = Array[0..31] Of Byte;
    PFont = ^TFont;
    TFont = Array[0..$FF] Of TCharBitM;
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

Procedure StartMsg;
Begin
    WriteLn ('Convert Font 1.0 (C) 1995 by Headbanger');
End;
Function ValidFileName(S: String): Boolean;
Begin
    ValidFileName := True;
End;
Procedure ErrorMsg;
Begin
    WriteLn ('Invalid Parameters!!!');
    WriteLn;
    WriteLn ('Syntax: CONVFONT source dest');
    WriteLn;
    WriteLn ('source is the filename of the file to be converted');
    WriteLn ('dest is the filename of the destination file');
End;
Procedure FontConvert;
Var SN, DN: String;
    SF, DF: File;
    Buf: Pointer;
    Dat: Pointer;
    Fon: PFont;
    R: Word;
    FF: TFontFile;
    W: Word;
    Function SearchStart(P: Pointer; L: Word): Pointer; Assembler;
    Asm
        cld
        les  di,P
        mov  ax,26d
        mov  cx,L
        repne SCASB
        mov  dx,es
        mov  ax,di
    End;
    Function IncPtr(P: Pointer; O: Word): Pointer; Assembler;
    Asm
        les ax,P
        add ax,O
        mov dx,es
    End;

    Function SubPtr(P1, P2: Pointer): Word; Assembler;
    Asm
        mov ax,P1.Word        { LoByte-HiByte!        }
        sub ax,P2.Word
    End;

    Procedure DoFontConvert(S, D: Pointer; XS, YS: Word); Assembler;
{ DS:SI: Source
  ES:DI: Destination
  BL   : Pixel Mask(security)
  BH   : Char Counter (0..FF)
  CX   : inner loop counter
  DX   : Fill-Byte Counter
}
    Asm
        push ds               { Save Data Segment             }
        lds  si,S             { Load Source Pointer           }
        les  di,D             { Load Destination Pointer      }
        mov  bx,0FFh          { Mask Byte and Char Counter    }
        mov  cx,8             { Compute Mask Byte             }
        sub  cx,XS
        shr  bl,cl
        mov  dx,20h           { Compute number of fill-Bytes  }
        mov  cx,YS
        sub  dx,cx
        @@1:
        lodsb                 { Get Byte                      }
        and  al,bl            { Use Mask                      }
        stosb                 { Store Byte                    }
        loop @@1              { Loop YS Times                 }
        MOV  cx,dx            { Fillbytes                     }
        jcxz @@2              { IF CX=0 then skip filling     }
        xor  al,al
        rep  STOSB
        @@2:
        inc  bh               { Increment Char Counter        }
        je   @@3              { IF overflow(BH=0) then stop   }
        MOV  cx,YS            { Else reload CX with YS        }
        jmp  @@1              { And jump to start             }
        @@3:
        pop  ds               { Restore Data Segment          }
    End;

Begin
    Write ('Converting ', paramstr (1), ' into ', paramstr (2), ' ...');
    If (ParamCount <> 2) Then
    Begin
        ErrorMsg;
        Exit;
    End;
    SN := ParamStr (1);
    DN := ParamStr (2);
    If NOT (ValidFileName (SN) AND ValidFileName (DN)) Then
    Begin
        ErrorMsg;
        Exit;
    End;
    Assign (SF, SN);
    Assign (DF, DN);
{$I-}
    ReSet (SF, 1);
    ReWrite (DF, 1);
{$I+}
    GetMem (Buf, FileSize (SF));
    BlockRead (SF, Buf^, FileSize (SF), R);
    If R <> FileSize (SF) Then
    Begin
        WriteLn ('Error reading from file', paramstr (1));
        Exit;
    End;
    Dat := SearchStart (Buf, FileSize (SF));
    W := SubPtr (Dat, Buf);
    FF.ID := 'GFON';
    FF.Ver := $0100;
    FF.XSize := Byte (Dat^);
    Dat := IncPtr (Dat, 1);
    FF.YSize := Byte (Dat^);
    Dat := IncPtr (Dat, 1);
    BlockWrite (DF, FF, SizeOf (FF), R);
    FF.DataStart := FilePos (DF);
    If R <> SizeOf (FF) Then
    Begin
        WriteLn ('Error writing to file', paramstr (2));
        Exit;
    End;
    New (Fon);
    DoFontConvert (Dat, Fon, FF.XSize, FF.YSize);
    BlockWrite (DF, Fon^, SizeOf (TFont), R);
    If R <> SizeOf (TFont) Then
    Begin
        WriteLn ('Error writing to file', paramstr (2));
        Exit;
    End;
    Dispose (Fon);
    FreeMem (Buf, FileSize (SF));
    FF.DescStart := FilePos (DF);
    BlockWrite (DF, W, 1, R);
    If R <> 1 Then
    Begin
        WriteLn ('Error writing to file', paramstr (2));
        Exit;
    End;
    BlockWrite (DF, Buf^, W, R);
    If R <> W Then
    Begin
        WriteLn ('Error writing to file', paramstr (2));
        Exit;
    End;
    Seek (DF, 0);
    BlockWrite (DF, FF, SizeOf (FF), R);
    If R <> SizeOf (FF) Then
    Begin
        WriteLn ('Error writing to file', paramstr (2));
        Exit;
    End;
    Close (SF);
    Close (DF);
    WriteLn (' finished!!! Converting successfull');
End;

Begin
    StartMsg;
    FontConvert;
End.
