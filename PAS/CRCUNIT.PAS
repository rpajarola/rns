Unit CrcUnit;
{$I RNS.H}
Interface

Function GetCRC(fn: String): Word;
Function GetCRCFileEntry(fn: String; Var CRC: Word): Boolean;
Function SetCRCFileEntry(fn: String; CRC: Word): Boolean;
Function isCRCOK(fn: String): Boolean;

Implementation
Uses Dos;

Function UpString(Var Zeile: STRING): String;
    (* Umwandlung eines Strings in Gro�buchstaben *)
Var i: INTEGER;
Begin
    For i := 1 To Length (Zeile) Do Zeile[i] := UpCase (Zeile[i]);
    UpString := Zeile;
End;

Function GetCRCFileEntry(fn: String; Var CRC: Word): Boolean;
Var S: String;
    F: File;
    a: word;
Begin
    Assign (F, 'CFN.CFG');
  {$I-}
    ReSet (F, 1);
  {$I+}
    If IOResult <> 0 Then
    Begin
        GetCRCFileEntry := False;
        Exit;
    End;
    While NOT EoF (F) Do
    Begin
        BlockRead (F, s, SizeOf (s), a);
        If a <> SizeOf (s) Then
        Begin
            Close (F);
            GetCRCFileEntry := False;
            Exit;
        End;
        For a := 0 To 255 Do s[a] := char (-byte (s[a]));
        CRC := Byte (s[254]) + 256 * Byte (s[255]);
        If Upstring (s) = UpString (fn) Then
        Begin
            Close (F);
            GetCRCFileEntry := True;
            Exit;
        End;
    End;
    Close (F);
    GetCRCFileEntry := False;
End;

Function SetCRCFileEntry(fn: String; CRC: Word): Boolean;
Var S: String;
    F: File;
    a: word;
    B: Array[0..1] Of Byte;
    fm: Byte;
Begin
    fm := filemode;
    filemode := 2;
    Assign (F, 'CFN.CFG');
  {$I-}
    ReSet (F, 1);
  {$I+}
    If IOResult <> 0 Then
    Begin
        SetCRCFileEntry := False;
        Exit;
    End;
    While NOT EoF (F) Do
    Begin
        BlockRead (F, s, SizeOf (s), a);
        If a <> SizeOf (s) Then
        Begin
            Close (F);
            SetCRCFileEntry := False;
            Exit;
        End;
        For a := 0 To 255 Do s[a] := char (-byte (s[a]));
        If Upstring (s) = UpString (fn) Then
        Begin
            Seek (F, FilePos (F) - 2);
            b[0] := byte (-lo (Crc));
            b[1] := byte (-Hi (Crc));
            BlockWrite (F, b, 2, a);
            Close (F);
            SetCRCFileEntry := a = 2;
            Exit;
        End;
    End;
    s := fn;
    s[254] := char (Lo (a));
    s[255] := char (Hi (a));
    For a := 0 To 255 Do s[a] := char (-byte (s[a]));
    BlockWrite (F, s, SizeOf (s), a);
    Close (F);
    SetCRCFileEntry := a = SizeOf (s);
    filemode := fm;
End;

Function GetCRC(fn: String): Word;
Var SM: Integer;
    F:  File;
    Buf: Array[0..511] Of Word;
    Res: Word;
    CRC: Word;
    a, b: Word;
Begin
    sm := FileMode;
    FileMode := 0;
    Assign (F, fn);
  {$I-}
    ReSet (F, 1);
    If IOResult <> 0 Then
    Begin
        GetCRC := 0;
        Exit;
    End;
  {$I+}
    Crc := Word (FileSize (F));
    While NOT EoF (F) Do
    Begin
        BlockRead (F, Buf, SizeOf (Buf), Res);
        For a := 0 To (Res DIV 2) - 1 Do
        Begin
            b := Buf[a];
            { Modern Pascal replacement for assembly CRC calculation }
            CRC := ((CRC SHR 1) OR (CRC SHL 15)) XOR b;
        End;
        If Res <> SizeOf (Buf) Then
            Break;
    End;
    Close (F);
    FileMode := sm;
    GetCRC := CRC;
End;

Function isCRCOK(fn: String): Boolean;
Var FileInfo: SearchRec;
    crc: Word;
Begin
    FindFirst (fn, AnyFile, FileInfo);
    If DosError = 0 Then
    Begin
        If GetCRCFileEntry (fn, crc) Then
        Begin
            If CRC = GetCRC (fn) Then
                isCRCOK := True
            Else
                isCRCOK := False;
        End Else
            isCRCOK := False;
    End Else
        isCRCOK := False;
End;

End.
