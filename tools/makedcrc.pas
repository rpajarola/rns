Program MakeDCrc;

Uses CRCUnit;

Var s: String;
    SF: Text;
    DF: File;
    a: Word;
{$I-}
Begin
    Randomize;
    WriteLn ('MAKE Demo CRC File 1.0     (c) 1996 by Rico Pajarola   Jan 9. 1996 ');
    If paramcount < 1 Then
    Begin
        WriteLn;
        WriteLn ('Syntax: MAKEDCRC sourcefile');
    End Else
        s := ParamStr (1);
    Assign (SF, s);
    Assign (DF, 'CFN.CFG');
    ReSet (SF);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error opening file ', s);
        WriteLn ('does it exist? (I think it doesn''t)');
        Exit;
    End;
    ReWrite (DF, 1);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error opening file CFN.CFG');
        WriteLn ('Maybe it''s read-only (or whatever...)');
        Exit;
    End;
    While NOT EoF (SF) Do
    Begin
        ReadLn (SF, S);
        For a := Length (S) + 1 To 255 Do
            s[a] := char (Random ($100));
        a := GetCRC (S);
        s[254] := char (Lo (a));
        s[255] := char (Hi (a));
        For a := 0 To 255 Do s[a] := char (-byte (s[a]));
        BlockWrite (DF, s, SizeOf (s), a);
        If a <> SizeOf (s) Then
        Begin
            Close (SF);
            Close (DF);
            WriteLn ('Error writing to file CFN.CFG');
            WriteLn ('Fix the problem (lack of diskspace, read-only-attr...) and try again');
            Exit;
        End;
    End;
    Close (SF);
    Close (DF);
End.
