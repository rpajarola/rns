{$I RNS.H}

Unit UserExit;

Interface

Implementation
Uses Crt,
    HelpUnit,
    Graph,
    InitSc;

Var
    OrgExitProc: Pointer;

Function Exitcode2Msg(N: Integer): String;
Var s: String;
Begin
    Case N Of
        0: s := (' Normal Program termination');
        1: s := (' Invalid function number');
        2: s := (' File missing');
        3: s := (' Path not found');
        4: s := (' Too many open files');
        5: s := (' File access denied');
        6: s := (' Invalid file handle');
        12: s := (' Invalid file access code');
        15: s := (' Invalid drive number');
        16: s := (' Cannot remove current directory');
        17: s := (' Cannot rename across drives');
        18: s := (' No more files');
        24: s := (' Graphics driver error');
        100: s := (' Disk read error,' + #13 + ' Run CHKDSK/F to correct error');
        101: s := (' Disk write error,' + #13 + ' Run CHKDSK/F to correct error');
        102: s := (' File not assigned');
        103: s := (' File not open');
        104: s := (' File not open for input');
        105: s := (' File not open for output');
        106: s := (' Invalid numeric format');
        150: s := (' Disk is write-protected,' + #13 + ' Remove write-protection');
        151: s := (' Bad drive request struct length');
        152: s := (' Drive not ready,' + #13 + ' Insert disk');
        154: s := (' CRC error in data');
        156: s := (' Disk seek error');
        157: s := (' Unknown media type');
        158: s := (' Sector Not Found');
        159: s := (' Printer out of paper');
        160: s := (' Device write fault');
        161: s := (' Device read fault');
        162: s := (' Hardware failure');
        200: s := (' Division by zero');
        201: s := (' Range check error');
        202: s := (' Stack overflow error');
        203: s := (' Heap overflow error');
        204: s := (' Invalid pointer operation');
        205: s := (' Floating point overflow');
        206: s := (' Floating point underflow');
        207: s := (' Invalid floating point operation');
        208: s := (' Overlay manager not installed');
        209: s := (' Overlay file read error');
        210: s := (' Object not initialized');
        211: s := (' Call to abstract method');
        212: s := (' Stream registration error');
        213: s := (' Collection index out of range');
        214: s := (' Collection overflow error');
        215: s := (' Arithmetic overflow error');
        216: s := (' General Protection fault');
        217: s := (' Memory allocation error');
    Else
        s := (' Unknown error');
    End;{ case}
    ExitCode2MSg := s;
End;

Procedure NewExit;
Begin
    CloseGraph();
    ClrScr();
    IniShowCursor;
    ExitProc := @OrgExitProc;
    If (Exitcode = 0) OR (ErrorAddr = Nil) Then
        Exit;
    WriteLn (ExitCode2Msg (ExitCode));
    halt (exitCode);
End;

Begin
    OrgExitProc := ExitProc;
    ExitProc := @NewExit;
End.
