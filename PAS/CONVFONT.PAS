Program ConvFont;

Type TCharBitM = Array[0..31] OF Byte;
     PFont = ^TFont;
     TFont = Array[0..$FF] OF TCharBitM;
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

Procedure StartMsg;
Begin
  WriteLn('Convert Font 1.0 (C) 1995 by Headbanger');
End;
Function ValidFileName(S : String) : Boolean;
Begin
  ValidFileName:=True;
End;
Procedure ErrorMsg;
Begin
  WriteLn('Invalid Parameters!!!');
  WriteLn;
  WriteLn('Syntax: CONVFONT source dest');
  WriteLn;
  WriteLn('source is the filename of the file to be converted');
  WriteLn('dest is the filename of the destination file');
End;
Procedure FontConvert;
Var SN,DN : String;
    SF,DF : File;
    Buf   : Pointer;
    Dat   : Pointer;
    Fon   : PFont;
    R     : Word;
    FF    : TFontFile;
    W     : Word;
Function SearchStart(P : Pointer;L : Word) : Pointer;Assembler;
Asm
  CLD
  LES  DI,P
  MOV  AX,26d
  MOV  CX,L
  REPNE SCASB
  MOV  DX,ES
  MOV  AX,DI
End;
Function IncPtr(P : Pointer;O : Word) : Pointer;Assembler;
Asm
  LES AX,P
  ADD AX,O
  MOV DX,ES
End;

Function SubPtr(P1,P2 : Pointer) : Word;Assembler;
Asm
  MOV AX,P1.Word        { LoByte-HiByte!        }
  SUB AX,P2.Word
End;

Procedure DoFontConvert(S,D : Pointer;XS,YS : Word);Assembler;
{ DS:SI: Source
  ES:DI: Destination
  BL   : Pixel Mask(security)
  BH   : Char Counter (0..FF)
  CX   : inner loop counter
  DX   : Fill-Byte Counter
}
Asm
  PUSH DS               { Save Data Segment             }
  LDS  SI,S             { Load Source Pointer           }
  LES  DI,D             { Load Destination Pointer      }
  MOV  BX,0FFh          { Mask Byte and Char Counter    }
  MOV  CX,8             { Compute Mask Byte             }
  SUB  CX,XS
  SHR  BL,CL
  MOV  DX,20h           { Compute number of fill-Bytes  }
  MOV  CX,YS
  SUB  DX,CX
@@1:
  LODSB                 { Get Byte                      }
  AND  AL,BL            { Use Mask                      }
  STOSB                 { Store Byte                    }
  LOOP @@1              { Loop YS Times                 }
  MOV  CX,DX            { Fillbytes                     }
  JCXZ @@2              { IF CX=0 then skip filling     }
  XOR  AL,AL
  REP  STOSB
@@2:
  INC  BH               { Increment Char Counter        }
  JE   @@3              { IF overflow(BH=0) then stop   }
  MOV  CX,YS            { Else reload CX with YS        }
  JMP  @@1              { And jump to start             }
@@3:
  POP  DS               { Restore Data Segment          }
End;

Begin
  Write('Converting ',paramstr(1),' into ',paramstr(2),' ...');
  IF (ParamCount<>2) Then Begin
    ErrorMsg;
    Exit;
  End;
  SN:=ParamStr(1);
  DN:=ParamStr(2);
  IF Not (ValidFileName(SN) And ValidFileName(DN)) Then Begin
    ErrorMsg;
    Exit;
  End;
  Assign(SF,SN);
  Assign(DF,DN);
{$I-}
  ReSet(SF,1);
  ReWrite(DF,1);
{$I+}
  GetMem(Buf,FileSize(SF));
  BlockRead(SF,Buf^,FileSize(SF),R);
  IF R<>FileSize(SF) Then Begin
    WriteLn('Error reading from file',paramstr(1));
    Exit;
  End;
  Dat:=SearchStart(Buf,FileSize(SF));
  W:=SubPtr(Dat,Buf);
  FF.ID:='GFON';
  FF.Ver:=$0100;
  FF.XSize:=Byte(Dat^);
  Dat:=IncPtr(Dat,1);
  FF.YSize:=Byte(Dat^);
  Dat:=IncPtr(Dat,1);
  BlockWrite(DF,FF,SizeOf(FF),R);
  FF.DataStart:=FilePos(DF);
  IF R<>SizeOf(FF) Then Begin
    WriteLn('Error writing to file',paramstr(2));
    Exit;
  End;
  New(Fon);
  DoFontConvert(Dat,Fon,FF.XSize,FF.YSize);
  BlockWrite(DF,Fon^,SizeOf(TFont),R);
  IF R<>SizeOf(TFont) Then Begin
    WriteLn('Error writing to file',paramstr(2));
    Exit;
  End;
  Dispose(Fon);
  FreeMem(Buf,FileSize(SF));
  FF.DescStart:=FilePos(DF);
  BlockWrite(DF,W,1,R);
  IF R<>1 Then Begin
    WriteLn('Error writing to file',paramstr(2));
    Exit;
  End;
  BlockWrite(DF,Buf^,W,R);
  IF R<>W Then Begin
    WriteLn('Error writing to file',paramstr(2));
    Exit;
  End;
  Seek(DF,0);
  BlockWrite(DF,FF,SizeOf(FF),R);
  IF R<>SizeOf(FF) Then Begin
    WriteLn('Error writing to file',paramstr(2));
    Exit;
  End;
  Close(SF);
  Close(DF);
  WriteLn(' finished!!! Converting successfull');
End;

Begin
  StartMsg;
  FontConvert;
End.