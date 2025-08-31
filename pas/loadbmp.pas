{$I RNS.H}

Unit LoadBmp;

Interface

Type
    PBMP16 = ^TBMP16;

    TBMP16 = Object
        XRes, YRes: Word;
        Data: Pointer;
        Constructor Load(FileName: String);
        Destructor Done; Virtual;
        Procedure Display(XS, YS: Word); Virtual;
    End;

Procedure VGA16PutPixel(X, Y: Word; C: Byte);

Implementation


Constructor TBMP16.Load(FileName: String);
Type
    BitMap_File = Record
        bfType: Array[0..1] Of Char;
        bfSize: LongInt;
        Res0: Array[0..3] Of Byte;
        bfOffs: LongInt;
    End;

    BitMap_Info = Record
        biSize: LongInt;
        biWidth: LongInt;
        biHeight: LongInt;
        biPlanes: Word;
        biBitCnt: Word;
        biCompr: LongInt;
        biSizeIm: LongInt;
        biXPels: LongInt;
        biYPels: LongInt;
        biClrUsed: LongInt;
        biClrImp: LongInt;
    End;
Var
    F: File;
    Header: BitMap_File;
    Info: BitMap_Info;
    Code: Word;
    i: Word;
Begin
    If FileName = '' Then
    Begin
        data := nil;
        xres := 0;
        yres := 0;
        exit;
    End;
    Assign (F, FileName);
    FileMode := 0;
{$I-}
    ReSet (F, 1);
{$I+}
    FileMode := 2;
    If IOResult <> 0 Then
    Begin
        data := nil;
        xres := 0;
        yres := 0;
        exit;
    End;
    BlockRead (F, Header, SizeOf (Header), Code);
    If Code <> SizeOf (Header) Then
    Begin
        data := nil;
        xres := 0;
        yres := 0;
        Close (F);
        exit;
    End;
    blockRead (F, Info, SizeOf (Info), Code);
    If Code <> SizeOf (Info) Then
    Begin
        data := nil;
        xres := 0;
        yres := 0;
        Close (F);
        exit;
    End;
    If Info.biCompr <> 0 Then
    Begin
        data := nil;
        xres := 0;
        yres := 0;
        Close (F);
        exit;
    End;
    If Info.biBitCnt <> 8 Then
    Begin
        data := nil;
        xres := 0;
        yres := 0;
        Close (F);
        exit;
    End;
    XRes := Info.biWidth;
    YRes := Info.biHeight;
    i := (XRes + 3) AND $FFFC;
    GetMem (Data, i * (YRes + 1));
    Seek (F, Header.bfOffs);
    BlockRead (F, Data^, i * (YRes + 1), Code);
    If Code <> i * YRes Then
    Begin
        FreeMem (Data, i * (YRes + 1));
        data := nil;
        xres := 0;
        yres := 0;
        Close (F);
        exit;
    End;
    Close (F);
End;


Destructor TBMP16.Done;
Begin
    XRes := (XRes + 3) AND $FFFC;
    FreeMem (Data, XRes * YRes);
End;


Procedure VGA16PutPixel(X, Y: Word; C: Byte);
Begin
    // TODO: Replace with modern graphics pixel drawing API
    // Original: Direct VGA hardware pixel manipulation at 0A000h
End;


Procedure TBMP16.Display(XS, YS: Word);
Begin
    // TODO: Replace with modern graphics bitmap display API
    // Original: Direct VGA hardware bitmap blitting at 0A000h
    If Data = nil Then
        Exit;
    // Modern implementation would use graphics library to display bitmap
End;


End.
