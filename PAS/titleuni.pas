{$I RNS.H}

Unit TitleUnit;

Interface

Uses symbols,
    initsc,
    textunit,
    graph,
    UserExit,
    Dos;

Procedure TitGetText(linenum, startx: integer);
Function TitVerify: Boolean;

Implementation

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure TitGetText(linenum, startx: integer);
Begin
    If (linenum >= 0) AND (linenum <= pagelim) AND (page[linenum, 1] = 'T') Then TexDrawLine (linenum, startx);
End;


{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Function TitVerify: Boolean;
Var licfile: text;
    i, j: integer;
    nsum, ndiff, isum, idiff: integer;
    dummy: stringline;
Begin
    assign (licfile, 'imie.rns');
    reset (licfile);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot open license file: IMIE.RNS');
        WriteLn ('This appears to be a demo version - license file not found.');
        TitVerify := False;
        Exit;
    End;
    readln (licfile, usrname);
    readln (licfile, usrfirstname);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot read user information from license file');
        close (licfile);
        TitVerify := False;
        Exit;
    End;
    For i := 1 To 4 Do
        readln (licfile, dummy);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot read license data from license file');
        close (licfile);
        TitVerify := False;
        Exit;
    End;
    readln (licfile, nsum);
    readln (licfile, ndiff);
    If IOResult <> 0 Then
    Begin
        WriteLn ('Error: Cannot read license verification data from license file');
        close (licfile);
        TitVerify := False;
        Exit;
    End;
    isum := 22;
    idiff := -17;
    j := 1;
    IniLeadBlank (usrname);
    IniTrailBlank (usrname);
    For i := 1 To length (usrname) Do
    Begin
        isum := isum + ord (usrname[i]) + i - 1;
        idiff := idiff + j * ord (usrname[i]) * 3;
        j := -j;
    End;
    TitVerify := ((isum = nsum) AND (idiff = ndiff));
    close (licfile);
End;


End.
