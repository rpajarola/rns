{$I RNS.H}

Unit prmunit;

Interface

Uses
    initsc,
    SysUtils;

Procedure PrmPrintMenu(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr);


Implementation

Uses
    imenuunit,
    printunit,
    pageunit,
    menutyp,
    graphmenu,
    crt,
    helpunit,
    DOS,
    mousdrv,
    grinout,
    fileunit;
{******************************************************************}
Procedure PrmSetOptions;
Var c: char;
    sval: string;
    y, hy: integer;
    ok: boolean;
    m: boolean;
Begin
    m := NOT istdunkel;
    If m Then
        mausdunkel;
    ImeInitPrOptionsMenu;
    UsrMenu.ChoiceVal[1].Tval := prformat;
    UsrMenu.ChoiceVal[2].Tval := prdest;
    UsrMenu.ChoiceVal[3].Sval := prfname;
    y := grmaxy - (usrmenu.num_choices * usrmenu.spacing + usrmenu.menuattr.firstline + 6) * charheight;
    hy := y DIV charheight;
    GrDisplay_Frame (grminx, y, grmaxx, grmaxy, true, true);
    GrDisplay_Menu (hfminx, hy, usrmenu, 0);
    GrGet_Menu_Values (hfminx, hy, hfmaxy, UsrMenu, c);
    prformat := UsrMenu.ChoiceVal[1].tval;
    prdest := UsrMenu.ChoiceVal[2].tval;
    If (pos (':', Togglestring[prdest + UsrMenu.ChoiceVal[2].tvalmin - 1]) = 0) Then prfile := 1 Else prfile := 0;
    If prfile = 1 Then
    Begin
        sval := UsrMenu.ChoiceVal[3].sval;
        IniLeadBlank (sval);
        UsrMenu.ChoiceVal[3].sval := sval;
        If pos ('.', UsrMenu.ChoiceVal[3].sval) = 0 Then UsrMenu.ChoiceVal[3].sval := UsrMenu.ChoiceVal[3].sval + '.eps';
        HlpTestFileName (ConcatPaths([psdir, UsrMenu.ChoiceVal[3].sval]),
            ok, grminx, grmaxx, y);
        If ok Then prfname := UsrMenu.ChoiceVal[3].sval;
    End Else prdevice := Copy (Togglestring[prdest + UsrMenu.ChoiceVal[2].tvalmin - 1], 1, 4);
    If m Then
        mauszeigen;
End;
{******************************************************************}
{******************************************************************}

Type TPageList = Array[0..255] Of integer;

{******************************************************************}

Procedure String2List(S: String; Var List: TPageList);
Var i, j, k: integer;
    r: boolean;
Begin
    r := false;
    i := 0;
    list[0] := 1;
    While (s <> '') AND (i <= 255) Do
        If iniNumChar (s[1]) Then
        Begin      { Zahl?                         }
            k := ininextnumber (s);              { zahl->k                       }
            If r Then
            Begin                   { range?                        }
                If k > list[i - 1] Then             { up/down?                      }
                    j := 1
                Else
                    j := -1;
                While list[i - 1] <> k Do
                Begin     { bis das Ziel erreicht ist     }
                    list[i] := list[i - 1] + j;         { se                            }
                    inc (i);
                End;
                r := false;
            End Else Begin
                List[i] := k;
                inc (i);
            End;
        End Else If s[1] = '-' Then
        Begin            { -> range                      }
            delete (s, 1, 1);
            r := true;
            If i = 0 Then
                inc (i);
        End Else If (s[1] = '.') AND (s[2] = '.') Then
        Begin { -> range           }
            delete (s, 1, 2);
            r := true;
            If i = 0 Then
                inc (i);
        End Else Begin                    { separator                     }
            r := false;
            delete (s, 1, 1);
        End;
    If r Then
        While (i <= 255) Do
        Begin
            list[i] := list[i - 1] + 1;
            inc (i);
        End Else
        list[i] := -1;
End;

{******************************************************************}

Procedure Printpages(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr;
    list: TPageList);

Var spagecount: integer;
    i: integer;
    inblock: stringline;
    n: integer;
Begin
    If (NOT (prfile = 1)) OR (NOT IniFileExist (ConcatPaths([psdir, prfname]))) OR
        HlpAreYouSure ('File: "' + ConcatPaths([psdir, prfname]) + '" already exists, overwrite?', hpEdit) Then
    Begin
        n := filnumpages (actptr, startptr, lastptr);
        PriPostscriptinit;
        spagecount := pagecount;
        i := 0;
        While (i < 256) AND (List[i] >= 0) Do
        Begin
            pagecount := List[i];
            inc (i);
            printeron := false;
            If pagecount = 0 Then
            Begin
                { auf n„chste seite gehen }
                If ((prpage MOD prformat) <> 0) Then
                Begin{ Seite nicht sowieso fertig? }
                    inblock := 'showpage';                 { Seite anzeigen              }
                    PriString (inblock);
                    PriSetTopMargins;                     { n„xtes Mal: obere H„lfte    }
                    Repeat
                        inc (prpage);
                    Until (prpage MOD prformat) = 0;
                End;
            End Else
            { seite "laden" ... }
            If pagecount <= n Then
            Begin
                PagShowPage (linenum, actposn, actpost, actptr, startptr, lastptr, pagecount, true);
                printeron := true;
                PriPostscript;
            End;
        End;
        PriPostscriptComplete;
        PagClearBottomLine;
        pagecount := spagecount;
        printeron := false;
        PagShowPage (linenum, actposn, actpost, actptr, startptr, lastptr, pagecount, true);
    End;
End;

{******************************************************************}
Procedure PrmPrintMenu(Var linenum, actposn, actpost: integer;
    Var actptr, startptr, lastptr: listptr);
Var dir: movement;
    c: char;
    resp: response_type;
    choicenum: byte;
    x, y, hy, i, dy: integer;
    mausx, mausy, maustaste, mausmenu: word;
    s: string;
    changed: boolean;
    list: TPageList;
Begin
    Repeat
        ImeInitPrintMenu;
        maustaste := 0;
        choicenum := 1;
        PagRefClearVal (grminx - 10, grminy - 10,
            grmaxx + 10, grmaxy + 10);
        y := grmaxy - (usrmenu.num_choices * usrmenu.spacing +
            usrmenu.menuattr.firstline + 2) * charheight;
        hy := y DIV charheight;
        GrDisplay_Frame (grminx, y, grmaxx, grmaxy, true, false);
        GrDisplay_Menu (hfminx, hy, usrmenu, 0);
        GrGet_Menu_Response (hfminx, hy, usrmenu, c, dir,
            choicenum, mausx, mausy, maustaste,
            mausmenu, false, 0);
        x := hfminx + usrmenu.menu_width + 16;
        c := UpCase (c);
        Case c Of
            'L':
            Begin
                dy := 10 + hy + 4;
                IniInversText (x - 94, dy, 'L - List  pages:                                                              ',
                    frlow);
                GrGet_String (s, x - 81, dy, x - 81, 79, resp, dir, c, false,
                    mausx, mausy, maustaste, mausmenu, changed);
                If (resp = return) AND (s <> '') Then
                Begin
                    String2List (s, list);
                    Printpages (linenum, actposn, actpost, actptr, startptr, lastptr, list);
                End;
            End;
            'P': If (NOT (prfile = 1)) OR (NOT IniFileExist (ConcatPaths([psdir, prfname]))) OR
                    (HlpAreYouSure ('File: "' + ConcatPaths([psdir, prfname]) +
                    '" already exists, overwrite?', hpEdit)) Then
                Begin
                    PriPostscriptinit;
                    PriPostscript;
                    PriPostscriptComplete;
                    PagClearBottomLine;
                End;
            'F':
            Begin       { print file    }
                For i := 0 To 255 Do
                    list[i] := i + 1;
                printpages (linenum, actposn, actpost, actptr, startptr, lastptr, list);
            End;
            'E':
            Begin
                For i := 0 To 255 Do
                    list[i] := pagecount + i;
                printpages (linenum, actposn, actpost, actptr, startptr, lastptr, list);
            End;
            'C':
            Begin
                For i := 0 To pagecount - 1 Do
                    list[i] := i + 1;
                list[pagecount] := -1;
                printpages (linenum, actposn, actpost, actptr, startptr, lastptr, list);
            End;
            'O': PrmSetOptions;
        End; {case c of}
    Until (c = #27);
End;

End.
