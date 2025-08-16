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
Procedure VGA16PutPixel(X,Y : Word;C : Byte);
begin
  // TODO: Replace with modern graphics pixel drawing API
  // Original: Direct VGA hardware pixel manipulation at 0A000h
end;
Procedure TBMP16.Display(XS,YS : Word);
begin
  // TODO: Replace with modern graphics bitmap display API
  // Original: Direct VGA hardware bitmap blitting at 0A000h
  if Data = nil then
    Exit;
  // Modern implementation would use graphics library to display bitmap
end;


End.
