{$I RNS.H}

Unit TitleUnit;

Interface

Uses
    symbols,
    initsc,
    textunit,
    graph;

Procedure TitGetText(linenum, startx: integer);

Implementation

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure TitGetText(linenum, startx: integer);
Begin
    If (linenum >= 0) AND (linenum <= pagelim) AND (page[linenum, 1] = 'T') Then
        TexDrawLine (linenum, startx);
End;

End.
