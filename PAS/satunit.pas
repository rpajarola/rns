{$I RNS.H}

Unit satunit;

Interface

Uses menutyp,
    graphmenu,
    grinout,
    imenuunit,
    initsc,
    dos,
    graph,
    fileunit,
    crt,
    helpunit,
    UserExit,
    Texts;


Procedure SatSymbolParam(c: char);
Procedure SatSaveSym;

Implementation
{******************************************************}
Procedure SatSaveSym;

Var c: char;
    i, j: byte;
    parfile: File Of integer;
Begin
    assign (parfile, 'SYMBOLS.PAR');
    reset (parfile);
    If IOResult <> 0 Then
    Begin
        HlpHint(HntCannotOpenFile, HintWaitEsc);
        Exit;
    End;
    For c := 'a' To 'z' Do
        For i := 1 To numofpar Do
            For j := 1 To 3 Do
            Begin
                write (parfile, sympar[c, i, j]);
                If IOResult <> 0 Then
                Begin
                    close (parfile);
                    HlpHint(HntCannotWriteFile, HintWaitEsc);
                    Exit;
                End;
            End;
    close (parfile);
{   instring:= fontfile;
   Delete(instring, length(instring) - 3, 4);
   instring:= instring + '.PAR';
   FilCopyFile('symbols.par',instring);}
End;

{******************************************************}
Procedure SatSymbolParam(c: char);

Var
    i, y, hy: integer;

Begin
    ImeInitCharMenu (c);
    With UsrMenu Do
    Begin
        For i := 1 To 3 Do
        Begin
            ChoiceVal[2 * (i - 1) + 1].Ival := SymPar[c, 3, i];
            ChoiceVal[2 * (i - 1) + 2].Ival := SymPar[c, 4, i];
        End;

        y := stabymax - (num_choices * spacing +
            menuattr.firstline + 8) * charheight;
        hy := y DIV charheight{ + 1};
        GrDisplay_Frame (stabxmin - 4, y, stabxmax + 4, stabymax - 29,
            true, true);
        Line (stabxmin - 4, stabymax - 28, stabxmax + 4, stabymax - 28);
        GrDisplay_Menu (sxmin + 1, hy, UsrMenu, 0);
        GrGet_Menu_Values (sxmin + 1, hy, symax - 3, UsrMenu, c);
        For i := 1 To 3 Do
        Begin
            SymPar[c, 3, i] := ChoiceVal[2 * (i - 1) + 1].Ival;
            SymPar[c, 4, i] := ChoiceVal[2 * (i - 1) + 2].Ival;
        End;
    End;
End;

End.
