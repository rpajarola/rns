Unit imenuunit;

Interface

Uses
    dos,
    crt,
    graph,
    gcurunit,
    menutyp,
    UserExit;

Procedure ImeInitSymbolMenus;
Procedure ImeInitBeatMenu;
Procedure ImeInitTopMenu;
Procedure ImeInitHFMenu;
Procedure ImeInitSearchMenu;
Procedure ImeIniVisiMenu;
Procedure ImeInitCharMenu(c: char);
Procedure ImeIniBlockMenu;
Procedure ImeIniPageMenu;
{Procedure ImeInitLineSelectMenu;}
Procedure ImeIniSwapMenu;
Procedure ImeInitPrintMenu;
Procedure ImeInitPrOptionsMenu;
Procedure ImeInitSoundMenu;
Procedure ImeInitSndOptionsMenu;
Procedure ImeInitLineMenu;

Implementation

Uses initsc,
    fileunit,
    Userint;
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeIniColors;

Begin
    SetColor (menutextcolor);
    SetFillstyle (1, menubkcolor);
End;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeInitSymbolMenus;

Var i: integer;

Begin
    SetColor (symtabcolor);
    SetFillstyle (1, symtabbkcolor);
    With SymbolMenu1 Do
    Begin
        menuattr.highliteline := true;
        menuattr.firstline := 2;

        Num_Choices := 13;
        Menu_Width := 15;
        spacing := 4;
        Choices := 'abcdefghijklm   ';
        Title := 'Keyboard: a-m              ' + fontfile;

        For i := 1 To 13 Do
        Begin
            Descriptions[i] := chr (i + 64) + ' - Alt-' + chr (i + 96);
            ChoiceVal[i].TypIdent := 'o';
            ChoiceDesc[i] :=
                '[Enter]: length and frequency of sound';
        End;
    End; {With SymbolMenu1}

    With SymbolMenu2 Do
    Begin
        menuattr.highliteline := true;
        menuattr.firstline := 2;

        Num_Choices := 13;
        Menu_Width := 15;
        spacing := 4;
        Choices := 'nopqrstuvwxyz   ';
        Title := 'Keyboard: n-z             ' + fontfile;

        For i := 1 To 13 Do
        Begin
            Descriptions[i] := chr (i + 77) + ' - Alt-' + chr (i + 109);
            ChoiceVal[i].TypIdent := 'o';
            ChoiceDesc[i] := '[Enter]: length and frequency of sound';
        End;
    End; {With SymbolMenu2}

End;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeInitCharMenu(c: char);

Var i: integer;
    cshift: char;

Begin
    ImeIniColors;
    i := ord (c);
    cshift := chr (i - 32);
    {Menu initialisieren}
    With UsrMenu Do
    Begin
        menuattr.highliteline := true;
        menuattr.firstline := 2;

        Num_Choices := 6;
        Menu_Width := 77;
        spacing := 2;
        Choices := '                ';
        Title := 'Sound: Length and Frequency';

        For i := 1 To 3 Do
        Begin
            Case i Of
                1: Descriptions[2 * (i - 1) + 1] :=
                        '    ' + c + ' - frequency';
                2: Descriptions[2 * (i - 1) + 1] :=
                        '    ' + cshift + ' - frequency';
                3: Descriptions[2 * (i - 1) + 1] :=
                        'Alt-' + c + ' - frequency';
            End;
            ChoiceVal[2 * (i - 1) + 1].TypIdent := 'i';
            ChoiceVal[2 * (i - 1) + 1].IvalMin := 0;
            ChoiceVal[2 * (i - 1) + 1].IvalMax := 20000;
            ChoiceDesc[2 * (i - 1) + 1] := 'Sound frequency: [0 - 20000] Hz';

            Case i Of
                1: Descriptions[2 * (i - 1) + 2] :=
                        '    ' + c + ' - length';
                2: Descriptions[2 * (i - 1) + 2] :=
                        '    ' + cshift + ' - length';
                3: Descriptions[2 * (i - 1) + 2] :=
                        'Alt-' + c + ' - length';
            End;
            ChoiceVal[2 * (i - 1) + 2].TypIdent := 'i';
            ChoiceVal[2 * (i - 1) + 2].IvalMin := 0;
            ChoiceVal[2 * (i - 1) + 2].IvalMax := 6000;
            ChoiceDesc[2 * (i - 1) + 2] := 'Sound length: [0 - 6000] ms';

        End;
    End; {With UsrMenu}
End;


{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeIniVisiMenu;
Var i: integer;
Begin
    ImeIniColors;
    With UsrMenu Do
    Begin
        menuattr.highliteline := true;
        menuattr.firstline := 2;

        Num_Choices := 5;
        Menu_Width := 77;
        spacing := 2;
        Choices := '                ';
        Title := 'Show/(print) or hide: [Shift]+[F1]';

        Descriptions[1] := 'Non-printing marks';
        ChoiceDesc[1] := 'Shows (working mode) or hides (presentation mode) non-printing marks';
        Descriptions[2] := 'Grids';
        ChoiceDesc[2] := 'Shows/prints or hides grid marks ([main] shows them only on the bottom line)';
        Descriptions[3] := 'Helplines';
        ChoiceDesc[3] := 'Shows/prints or hides helplines';
        Descriptions[4] := 'Jump marks';
        ChoiceDesc[4] := 'Shows/prints or hides jump marks: [' + #221 + '] and [\]';
        Descriptions[5] := 'Cursor';
        ChoiceDesc[5] := 'Shows cursor or cursor+cross (positioning) or hides it (use for hardcopies)';
        For i := 1 To Num_Choices Do
        Begin
            ChoiceVal[i].TypIdent := 't';
            ChoiceVal[i].tvalMin  := 1;
            ChoiceVal[i].tvalMax  := 2;
        End;
        ToggleString[1] := 'show';
        ToggleString[2] := 'hide';
        ChoiceVal[2].tvalMin := 3;
        ChoiceVal[2].tvalMax := 5;

        ToggleString[3] := 'hide';
        ToggleString[4] := 'show all';
        ToggleString[5] := 'show main';

        ChoiceVal[5].tvalMin := 8;
        ChoiceVal[5].tvalMax := 10;
        ToggleString[8] := 'show';
        ToggleString[9] := 'show + cross';
        ToggleString[10] := 'hide';
    End; {With BeatMenu}
End;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeIniSwapMenu;

Var i: integer;

Begin
    ImeIniColors;
    With UsrMenu Do
    Begin
        menuattr.highliteline := true;
        menuattr.firstline := 2;

        Num_Choices := 3;
        Menu_Width := 77;
        spacing := 2;
        Choices := 'KB              ';
        Title := 'Keyboard Setup: [Shift]+[F10]';

        Descriptions[1] := 'Replace/cumulate mode';
        ChoiceDesc[1] := 'Replace symbols / swapped: cumulate symbols (manual movement of cursor)';
        Descriptions[2] := 'Symbols';
        ChoiceDesc[2] := 'Normal-[Shift]-[Alt] / swapped: like [Alt]-Normal-[Shift]';
        Descriptions[3] := '[Spacebar]';
        {      ChoiceDesc  [3]:= '[Spacebar] = pause mark  [,] = time mark  / swapped: interchanged';}
        {      ChoiceDesc  [3]:= '[Space]=help mark [,]=pause mark [.]=time mark / ';}
        ChoiceDesc[3] := 'standard = help mark, swap1 = pause mark, swap2 = time mark / + [,] and [.]';

        For i := 1 To num_choices Do
        Begin
            ChoiceVal[i].TypIdent := 't';
            ChoiceVal[i].tvalMin  := 1;
            ChoiceVal[i].tvalMax  := 2;
        End;
        ToggleString[1] := 'standard';
        ToggleString[2] := 'swapped';

        ChoiceVal[3].tvalMin := 3;
        ChoiceVal[3].tvalMax := 5;
        { ' '=pause, ','=time, '.'=help -mark}
        ToggleString[3] := 'standard';      { [.] [ ] [,] }
        ToggleString[4] := 'swap1';     { [ ] [,] [.] }
        ToggleString[5] := 'swap2';     { [,] [ ] [.] }
    End; {With BeatMenu}
End;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeInitPrOptionsMenu;

Begin
    ImeIniColors;
    With UsrMenu Do
    Begin
        menuattr.highliteline := true;
        menuattr.firstline := 2;

        Num_Choices := 3;
        Menu_Width := 77;
        spacing := 2;
        Choices := '                ';
        Title := 'Print - Options: [Ctrl]+[F1]-[O]';

        Descriptions[1] := 'Format';
        ChoiceDesc[1] :=
            'Printout: 1 or 2 filepages per (A4) sheet';
        ChoiceVal[1].TypIdent := 't';
        ChoiceVal[1].tvalMin := 1;
        ChoiceVal[1].tvalMax := 2;

        ToggleString[1] := '1 filepage';
        ToggleString[2] := '2 filepages';

        Descriptions[2] := 'Destination';
        ChoiceDesc[2] :=
            'Choose printer port or EPS-file';
        ChoiceVal[2].TypIdent := 't';
        ChoiceVal[2].tvalMin := 6;
        ChoiceVal[2].tvalMax := 11;

        ToggleString[6] := 'LPT1:';
        ToggleString[7] := 'LPT2:';
        ToggleString[8] := 'LPT3:';
        ToggleString[9] := 'COM1:';
        ToggleString[10] := 'COM2:';
        ToggleString[11] := 'File';

        Descriptions[3] := 'Filename(.eps)';
        ChoiceDesc[3] :=
            'Type file to print on [max 8 (.eps)] and press [Enter]';
        ChoiceVal[3].TypIdent := 's';

    End; {With UserMenu}
End;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeInitSndOptionsMenu;

Begin
    ImeIniColors;
    With UsrMenu Do
    Begin
        menuattr.highliteline := true;
        menuattr.firstline := 2;

        Num_Choices := 10;
        Menu_Width := 77;
        spacing := 2;
        Choices := '                ';
        Title := 'Sound Options: [Shift]+[F5] - [Enter]';

        Descriptions[1] := 'Speed (in units)';
        ChoiceDesc[1] :=
            '[2.000 - 600.000] (connected to Unit)';
        ChoiceVal[1].TypIdent := 'r';
        ChoiceVal[1].rvalMin := 2;
        ChoiceVal[1].rvalMax := 600;

        Descriptions[2] := 'Unit (Beats or Lines Per Minute)';
        ChoiceDesc[2] :=
            'Use [LPM] if you want equal time for lines with different number of beats';
        ChoiceVal[2].TypIdent := 't';
        ChoiceVal[2].tvalMin := 1;
        ChoiceVal[2].tvalMax := 2;
        ToggleString[1] := 'BPM';
        ToggleString[2] := 'LPM';

        Descriptions[3] := 'Beat sound';
        ChoiceDesc[3] :=
            'Use [always] in notation mode, the others for beat training or "real mode"';
        ChoiceVal[3].TypIdent := 't';
        ChoiceVal[3].tvalMin := 3;
        ChoiceVal[3].tvalMax := 5;

        ToggleString[3] := 'no';
        ToggleString[4] := 'always';
        ToggleString[5] := 'empty only';

        Descriptions[4] := 'Mark sound';
        ChoiceDesc[4] :=
            'Standard is [no]; use [all] to "metronomize" the sound playing';
        ChoiceVal[4].TypIdent := 't';
        ChoiceVal[4].tvalMin := 6;
        ChoiceVal[4].tvalMax := 9;
        ToggleString[6] := 'no';
        ToggleString[7] := 'time mark';
        ToggleString[8] := 'pause mark';
        ToggleString[9] := 'all';

        Descriptions[5] := 'Beat frequency';
        ChoiceDesc[5] :=
            'Frequency for beat sound [1 - 20000 Hz]';
        ChoiceVal[5].TypIdent := 'i';
        ChoiceVal[5].ivalMin := 1;
        ChoiceVal[5].ivalMax := 20000;

        Descriptions[6] := 'Beat sound length';
        ChoiceDesc[6] :=
            'Duration of beat sound [1 - 1000 ms]';
        ChoiceVal[6].TypIdent := 'i';
        ChoiceVal[6].ivalMin := 1;
        ChoiceVal[6].ivalMax := 1000;

        Descriptions[7] := 'Pulse frequency';
        ChoiceDesc[7] :=
            'Frequency for pulse sound [1 - 20000 Hz]';
        ChoiceVal[7].TypIdent := 'i';
        ChoiceVal[7].ivalMin := 1;
        ChoiceVal[7].ivalMax := 20000;

        Descriptions[8] := 'Pulse sound length';
        ChoiceDesc[8] :=
            'Duration of pulse sound [1 - 1000 ms]';
        ChoiceVal[8].TypIdent := 'i';
        ChoiceVal[8].ivalMin := 1;
        ChoiceVal[8].ivalMax := 1000;

        Descriptions[9] := 'Keyboard sound';
        ChoiceDesc[9] := 'Use [on] to hear short control sounds while entering symbols';
        ChoiceVal[9].TypIdent := 't';
        ChoiceVal[9].tvalMin := 10;
        ChoiceVal[9].tvalMax := 11;
        ToggleString[10] := 'on';
        ToggleString[11] := 'off';

        Descriptions[10] := 'Warning sounds';
        ChoiceDesc[10] := 'Warning sounds at line/screen end: pulse correction, new line or line split';
        ChoiceVal[10].TypIdent := 't';
        ChoiceVal[10].tvalMin := 12;
        ChoiceVal[10].tvalMax := 15;
        ToggleString[12] := 'off';
        ToggleString[13] := 'end of line';
        ToggleString[14] := 'end of screen';
        ToggleString[15] := 'both';
    End; {With UserMenu}
End;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeInitHFMenu;

Begin
    ImeIniColors;
    With UsrMenu Do
    Begin
        menuattr.highliteline := true;
        menuattr.firstline := 2;

        Num_Choices := 4;
        Menu_Width := 78;
        spacing := 2;
        Choices := 'HUFV            ';
        Title := 'Header and/or Footer: [F6]';

        Descriptions[1] := 'Mark Header';
        ChoiceVal[1].TypIdent := 'o';

        Descriptions[3] := 'Mark Footer';
        ChoiceVal[3].TypIdent := 'o';

        Descriptions[2] := 'Unmark Header';
        ChoiceVal[2].TypIdent := 'o';

        Descriptions[4] := 'Unmark Footer';
        ChoiceVal[4].TypIdent := 'o';

    End; {With HFMenu}
End;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeInitSearchMenu;

Var i: byte;

Begin
    ImeIniColors;
    With UsrMenu Do
    Begin
        menuattr.highliteline := true;
        menuattr.firstline := 2;
        Num_Choices := 4;
        Menu_Width := 78;
        spacing := 2;
        Choices := 'RCPT            ';
        Title := 'Search and Replace: [Shift]+[F6]';
        Descriptions[4] := 'search  Text   ';
        Descriptions[3] := 'search  Pattern';
        Descriptions[2] := 'Change  text   ';
        Descriptions[1] := 'Replace pattern';
        For i := 1 To Num_choices Do ChoiceVal[i].TypIdent := 'o';
    End; {With usrmenu}
End;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeIniBlockMenu;

Var i: byte;

Begin
    ImeIniColors;
    With UsrMenu Do
    Begin
        menuattr.highliteline := true;
        menuattr.firstline := 2;

        Num_Choices := 11;
        Menu_Width := 78;
        spacing := 2;
        Choices := 'SEUCPMDUWRI     '{X for undel block};
        Title := 'Block Commands: [Shift]+[F8]           Hot-Keys or Mouse Buttons';

        Descriptions[1] := 'Start    block mark                1st time [F8] or middle mouse button';
        Descriptions[2] := 'End      block mark                2nd time [F8] or middle mouse button';
        Descriptions[3] := 'Unmark   block                     3rd time [F8] or middle mouse button';
        Descriptions[4] := 'Copy     block to block buffer     [C] when block marked';
        Descriptions[5] := 'Paste    block (copy &  paste)     [Ctrl]+[F8] or left+middle mouse button';
        Descriptions[6] := 'Move     block (cut  &  paste)     [M] when block marked';
        Descriptions[7] := 'Delete   block (cut to  buffer)    [Ctrl]+[Del]';
        Descriptions[8] := 'Undelete block (paste   buffer)    [Ctrl]+[Ins] / [Ctrl]+[F8]';
        Descriptions[9] := 'Write    block to      .buf file'  {[Ctrl]+[W] when block marked};
        Descriptions[10] := 'Read     block from    .buf file'  {[Ctrl]+[R]};
        Descriptions[11] := 'Index:   write to block buffer all headers/footers (paste on a new page)';


        For i := 1 To Num_choices Do
            ChoiceVal[i].TypIdent := 'o';
    End; {With blockmenu}
End;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeIniPageMenu;

Var i: byte;

Begin
    ImeIniColors;
    With UsrMenu Do
    Begin
        menuattr.highliteline := true;
        menuattr.firstline := 2;

        Num_Choices := 13;
        Menu_Width := 78;
        spacing := 2;
        Choices := 'GFLNISJBCPMDU   ';
        Title := 'Page Commands: [Shift]+[F9]            Hot-Keys';

        Descriptions[1] := 'Go to       page';
        ChoiceDesc[1] := 'Press [Enter] -  then type pagenumber: [Enter]';
        Descriptions[2] := 'go to First page                   [Ctrl] +[PgUp]';
        ChoiceDesc[2] := '';
        Descriptions[3] := 'go to Last  page                   [Ctrl] +[PgDn]';
        ChoiceDesc[3] := '';

        Descriptions[4] := 'go to New   page at end of file    [Shift]+[PgDn]';
        ChoiceDesc[4] := 'Jumps to the last page and adds a new one';
        Descriptions[5] := 'Insert  new page                   [Shift]+[F4]';
        ChoiceDesc[5] := 'Inserts a new page as configured in the SETUP PAGE ([Ctrl]+[F9])';
        Descriptions[6] := 'Split       page                   [Ctrl] +[F4]';
        ChoiceDesc[6] := 'Moves all information from cursor position downwards to next (new) page';
        Descriptions[7] := 'Join   next page                   [Shift]+[PgUp]';
        ChoiceDesc[7] := 'Adds from next page - at cursor position - as much information as place left';

        Descriptions[8] := 'Blockmark   page (mark/unmark)     [F9]: mark / [F9] again: unmark';
        ChoiceDesc[8] := 'Marks the whole page';
        Descriptions[9] := 'Copy        page to page buffer    [C] when page marked';
        ChoiceDesc[9] := 'Copies the whole page into page buffer';
        Descriptions[10] := 'Paste       page (copy & paste)    [Ctrl] +[F9]';
        ChoiceDesc[10] := 'Pastes page from page buffer / or: pastes marked page';
        Descriptions[11] := 'Move        page (cut  & paste)    [M] when page marked';
        ChoiceDesc[11] := 'Moves the marked page to new position';

        Descriptions[12] := 'Delete      page (cut to buffer)   [Ctrl] +[Del] when page marked';
        ChoiceDesc[12] := 'Cuts the whole page and saves it to page buffer - use as well to move page';
        Descriptions[13] := 'Undelete    page (paste  buffer)   [Ctrl] +[Ins] / [Ctrl] +[F9]';
        ChoiceDesc[13] := 'Pastes page from page buffer - use as well to move page';
        For i := 1 To Num_choices Do
            ChoiceVal[i].TypIdent := 'o';

    End; {With blockmenu}
End;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeInitPrintMenu;

Var i: byte;

Begin
    ImeIniColors;
    With UsrMenu Do
    Begin
        menuattr.highliteline := true;
        menuattr.firstline := 2;

        Num_Choices := 6;
        Menu_Width := 78;
        spacing := 2;
        Choices := 'OPFECL          ';
        Title := 'Print: [Ctrl]+[F1]';

        Descriptions[1] := 'Options';
        Descriptions[2] := 'Print page (for hardcopies use graphics.com and ptpage.col (ptscreen.col)';
        Descriptions[3] := 'Print file';
        Descriptions[4] := 'Print to end';
        Descriptions[5] := 'Print to current page';
        Descriptions[6] := 'List  (enter pagenumbers to print, for example 1,2,4-6 or 6..1 8-9 or 3+4)';
        For i := 1 To Num_choices Do
            ChoiceVal[i].TypIdent := 'o';
    End; {With blockmenu}
End;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeInitSoundMenu;

Var i: byte;

Begin
    ImeIniColors;
    With UsrMenu Do
    Begin
        menuattr.highliteline := true;
        menuattr.firstline := 2;

        Num_Choices := 5;
        Menu_Width := 78;
        spacing := 2;
        Choices := 'OLPBF           ';
        Title := 'Sound: [Shift]+[F5]                    With Cursor + Playing Key';

        Descriptions[1] := 'Options  (sound parameters)';
        Descriptions[2] := 'Line     (actual/next/last)        Put cursor on noteline and press [F5]';
        Descriptions[3] := 'Page     (forced page sound)       Put cursor on textline and press [F5]';
        Descriptions[4] := 'Buffer   (ev. last buffer)         Mark buffer with [F8] then press [F5]';
        Descriptions[5] := 'File     (no playing marks!)'     {On page without notelines: press [F5]};

        For i := 1 To Num_choices Do
            ChoiceVal[i].TypIdent := 'o';

    End; {With blockmenu}
End;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeInitBeatMenu;

Var i: integer;
    inblock: string16;

Begin
    {Beat-Menu initialisieren}
    ImeIniColors;
    With UsrMenu Do
    Begin
        menuattr.highliteline := true;
        menuattr.firstline := 2;

        Num_Choices := 5;
        Menu_Width := 77;
        spacing := 2;
        Choices := '                ';
        Title := 'Noteline Definition: [Shift]+[F3]';

        Descriptions[1] := 'Beats';
        ChoiceVal[1].TypIdent := 'i';
        ChoiceVal[1].IvalMin := 1;
        ChoiceVal[1].IvalMax := 150;
        ChoiceDesc[1] := 'Type number of beats per line: [1 - 150] and [Enter]';

        Descriptions[2] := 'Grids';
        ChoiceVal[2].TypIdent := 'i';
        ChoiceVal[2].IvalMin := 0;
        ChoiceVal[2].IvalMax := 320;
        ChoiceDesc[2] := 'Type number of grids per beat: [0 - 320] and [Enter]';

        Descriptions[resolparam] := 'Resolution';
        ChoiceVal[resolparam].TypIdent := 'i';
        ChoiceVal[resolparam].ivalMin := 8{120};
        i := GrmaxX - Grminx + 1;
        ChoiceVal[resolparam].ivalMax := i;
        Str (i, inblock);
        ChoiceDesc[resolparam] :=
            'Type number of pixels from first beat to end: [8 - ' + inblock + '] and [Enter]';

        Descriptions[4] := 'Lines';
        ChoiceVal[4].TypIdent := 'i';
        ChoiceVal[4].IvalMin := 1;
        ChoiceVal[4].IvalMax := 52;
        ChoiceDesc[4] := 'Type number of lines to be displayed at once by [F3]: [1 - 52] and [Enter]';

        Descriptions[5] := 'Line style';
        ChoiceVal[5].TypIdent := 't';
        ChoiceVal[5].TvalMin := 1;
        ChoiceVal[5].TvalMax := 5;
        ToggleString[1] := 'thick';
        ToggleString[2] := 'pitch';
        ToggleString[3] := 'thin';
        ToggleString[4] := 'dotted';
        ToggleString[5] := 'helpline';
        ChoiceDesc[5] := 'Choose a line style (pitch = 5 lines system)';

    End; {With BeatMenu}
End;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Procedure ImeInitTopMenu;

Var i: byte;
Begin
    With UsrMenu Do
    Begin
        menuattr.highliteline := true;
        menuattr.firstline := 1;

        Num_Choices := 6;
        Menu_Width := 23{19};
        spacing := 8;
        Title := 'R  H  Y  T  H  M  I  C  S';

        Choices := 'FDSPCQ          ';

        Descriptions[1] := 'F - ' + upstring (datadir) + '\ Files            ';
        Descriptions[1][0] := #24;
        Descriptions[2] := 'D - Directories         ';
        Descriptions[3] := 'S - Symbol Fonts        ';
        Descriptions[4] := 'P - Page Layout         ';
        Descriptions[5] := 'C - Colors              ';
        Descriptions[6] := 'Q - Quit                ';
        For i := 1 To Num_Choices Do
            ChoiceVal[i].TypIdent := 'o';

    End; {With TopMenu}
End;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
(*Procedure ImeInitLineSelectMenu;

var i: integer;
    inblock: stringline;
    ifile: text;
    nextlabel: boolean;

begin
   ImeIniColors;
   With UsrMenu do
   begin
      menuattr.highliteline:= true;
      menuattr.firstline:= 2;

      Num_Choices:= 15;
      Menu_Width:= 78;
      spacing:= 2;
      Choices:= 'ABCDEFGHIJKLMNOP';
      Title:='Noteline Selection: [Shift]+[F4]    (Change in [Notelines] of the main menu)';

      i:= 1;
      nextlabel:= false;
      FilAssignRnsFile(ifile, 'linepat', true);
      while i <= Num_Choices do
      begin
         LastFileName:=FExpand(TextRec(Ifile).Name);
         readln(ifile, inblock);
         if nextlabel then
         begin
            Descriptions[i]:= Copy(inblock, 1 + linemarker, labellength);
            IniExpand(Descriptions[i], 20);
            ChoiceVal[i].TypIdent:='o';
            nextlabel:= false;
            Inc(i);
         end
         else
         begin
            if inblock[1] = 'N' then
            begin
               nextlabel:= true;
               page[i]:= inblock;
            end;
         end;
      end;
      LastFileName:=FExpand(TextRec(ifile).Name);
      close(ifile);
   end; {With UsrMenu}
end;
 *)
{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}

Procedure ImeInitLineMenu;
Var i: byte;
Begin
    ImeIniColors;
    With UsrMenu Do
    Begin
        menuattr.highliteline := true;
        menuattr.firstline := 2;

        Num_Choices := 7;
        Menu_Width := 78;
        spacing := 2;
        Choices := 'CPSBEDU         ';
        Title := 'Line Commands: [Shift]+[F7]              Hot-Keys';

        Descriptions[1] := 'Copy      line to      line buffer           [F7]';
        Descriptions[2] := 'Paste     line from    line buffer   [Ctrl] +[F7]';
        Descriptions[3] := 'Split     line at cursor position    [Ctrl] +[F3]';
        Descriptions[4] := 'Delete to line begin and move rest   [Shift]+[' + #23 + '-]';
        Descriptions[5] := 'Delete to line end                   [Shift]+[Del]';
        Descriptions[6] := 'Delete    line (cut to spec.buffer)  [Ctrl] +[' + #23 + '-]';
        Descriptions[7] := 'Undelete  line (paste  spec.buffer)  [Shift]+[Ins]';

        For i := 1 To Num_choices Do ChoiceVal[i].TypIdent := 'o';
    End;
End;

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
End.
