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
    LastFileName := FExpand ('IMIE.RNS');
    reset (licfile);
    readln (licfile, usrname);
    readln (licfile, usrfirstname);
    For i := 1 To 4 Do
        readln (licfile, dummy);
    readln (licfile, nsum);
    readln (licfile, ndiff);
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
