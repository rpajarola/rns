{$I RNS.H}

Unit SDUnit;

Interface

Uses InitSc,
    MenuTyp,
    Dos,
    Helpunit,
    Texts,
    Graph,
    MousDrv,
    XCrt;
Procedure SdUSodir(Disponly: Boolean; Var Selected: Boolean; ShowSel: Boolean;
    Var instring: string79; Mask: String16;
    dir: string79; Dirorfile: Boolean;
    x, y: integer; Cols, rows: Byte;
    Var mausx, mausy, maustaste: Word; actmenu: word;
    selX, selY: integer; GoUp: Boolean);

Implementation
Procedure SduSodir(Disponly: Boolean; Var Selected: Boolean; ShowSel: Boolean;
    Var instring: string79; Mask: String16;
    dir: string79; Dirorfile: Boolean;
    x, y: integer; Cols, rows: Byte;
    Var mausx, mausy, maustaste: Word; actmenu: word;
    selX, selY: integer; GoUp: Boolean);

Const CursorUp = #72;
    CursorDown = #80;
    Cursorleft = #75;
    CursorRight = #77;
    PgUp = #73;
    PgDn = #81;
    Cursorend = #79;
    CursorHome = #71;
    CtrlPgUp = #132;
    CtrlPgDn = #118;
    ESC  = #27;
    RETURN = #13;
    Null = #0;
    MaxC = 40;
    MaxR = 3;
    MaxEntries = 511;

Type  TEntry = Record
        Attrib: Byte;
        Used: Boolean;
        Name: String[8];
        Ext:  String[3];
    End;
    PFilePage = ^TFilePage;
    TFilePage = Record
        Entries: Array[0..511] Of TEntry;
    End;
Var Cancel: Boolean Absolute Disponly;
    Files: PFilePage;
    EntryC: Word;
    SelEntry: Word;
    Page: Word;
    c: Char;
    Shift, Ctrl: Boolean;
    MausMenu: Word;
    Mp: Word;
    Procedure QSort(N: INTEGER);
(* Sortierroutine, die nach dem Verfahren des Quicksort arbeitet.
   Sie arbeitet in AbhÑngigkeit des Parameters ORDER auf den ver-
   schiedenen Array-Feldern. *)

        Function Kleiner(i1, i2: TEntry): BOOLEAN;{Assembler;
   (* Vergleich zweier Arrayelemete in AbhÑngigkeit der
      von der gewÅnschten Recordkomponente.
   *)
   Asm
     PUSH DS
     CLD
     LES DI,I1
     LDS SI,I2
     ADD SI,Offset TEntry.Name
     ADD DI,Offset TEntry.Name
     LODSB
     MOV CL,AL
     XOR CH,CH
     REPE CMPSB
     DEC SI
     DEC DI

     PUSH DS
     PUSH SI
     PUSH CX
     CALL Near Ptr @CHIFFRES
     ADD  SP,6

     OR   AX,AX
     JZ   @NOTACHIFFRE
     PUSH AX

     PUSH ES
     PUSH DI
     PUSH CX
     CALL Near Ptr @CHIFFRES
     ADD  SP,6

     POP  BX
     OR   AX,AX
     JZ   @NOTACHIFFRE
     CMP  AL,BL
     JE   @NOTACHIFFRE
     JMP  @COMP
   @NOTACHIFFRE:
     LODSB
     MOV BL,ES:[DI]
   @COMP:
     CMP AL,BL
     JB  @B
     XOR AX,AX
     JMP @A
   @B:
     MOV AX,1
   @A:
     POP  DS
     JMP  @END
  @CHIFFRES:
    PUSH BP
    MOV  BP,SP
    PUSH DS
    PUSH SI
    PUSH CX
    MOV  CL,SS:[BP+06h]
    XOR  CH,CH
    LDS  SI,SS:[BP+08h]
  @L:
    LODSB
    CMP  AL,'0'
    JB @F
    CMP  AL,'9'
    JA @F
    LOOP @L
  @F:
    MOV  AL,SS:[BP+06h]
    SUB  AL,CL
    POP  CX
    POP  SI
    PUSH DS
    POP  BP
    RETN
  @END:
   End;}
        Begin
            Kleiner := i1.name < i2.name;
        End;

        Procedure Swap(i1, j1: INTEGER);
        (* Vertauschen von zwei ArrayeintrÑgen *)
        Var tmp: TEntry;
        Begin
            tmp := Files^.entries[i1];
            Files^.entries[i1] := Files^.entries[j1];
            Files^.entries[j1] := tmp;
        End;

        Procedure Sortiere(l, r: INTEGER);
        (* Quicksort-Routine *)
        Var i, j: INTEGER;
            M: TEntry;
        Begin
            i := l;                (* Startwert fÅr linken Laufindex  *)
            j := r;                (* Startwert fÅr rechten LAufindex *)
            M := Files^.Entries[(l + r) DIV 2]; (* Mittelelement *)
            Repeat
                While Kleiner (files^.Entries[i], M) Do INC (i);
                While Kleiner (M, files^.Entries[j]) Do DEC (j);
                If i <= j Then
                Begin
                    If i <> j Then Swap (i, j);  (* Nur Tausch, wenn Indizes *)
                    INC (i);                     (* nicht auf gleiches Elem. *)
                    DEC (j);                     (* zeigen *)
                End;
            Until i > j;
            If l < j Then Sortiere (l, j);   (* rekursive Aufrufe *)
            If i < r Then Sortiere (i, r);
        End;
    Begin
        If N > 0 Then
            Sortiere (0, N);
    End;

    Procedure Init;
    Var i: Integer;
        b: Byte;
        D: SearchRec;
        at: byte;
        m: string16;
    Begin
        SelEntry := 0;
        Page := 0;
        If Cols > MaxC Then
            Cols := MaxC;
        If Rows > MaxR Then
            Rows := MaxR;
        New (Files);
        For i := 0 To MaxEntries Do
            With Files^.Entries[i] Do
            Begin
                Used := False;
                Name := '        ';
                Ext  := '   ';
            End;
        EntryC := 0;
        If dirorfile Then
            at := directory
        Else
            at := anyfile;
        While mask <> '' Do
        Begin
            inileadblank (mask);
            If pos (' ', mask) = 0 Then
            Begin
                m := mask;
                mask := '';
            End Else Begin
                m := copy (mask, 1, pos (' ', mask));
                delete (mask, 1, pos (' ', mask));
            End;
            inileadblank (m);
            initrailblank (m);
            FindFirst (Dir + M, At, D);
            While (DosError = 0) AND (EntryC <= MaxEntries) Do
            Begin
                If (D.Name[1] <> '.') Then
                    With Files^.Entries[EntryC] Do
                        If ((d.attr AND directory) <> 0) = dirorfile Then
                        Begin
                            Attrib := D.Attr;
                            Used := True;
                            b := Pos ('.', D.Name);
                            If b <> 0 Then
                            Begin
                                Name := Copy (D.Name, 1, b - 1);
                                Ext  := Copy (D.Name, b + 1, byte (d.Name[0]) - b);
                            End Else Begin
                                Name := D.Name;
                                Ext  := '';
                            End;
                            Inc (EntryC);
                        End;
                FindNext (D);
            End;
        End;{ while mask<>'' }
        If EntryC = 0 Then cancel := True{    HlpText(substartx, subendx, substarty + 6,
           'No files found', true);
    Delay(HintNormalTime);} Else If EntryC = MaxEntries Then
        Begin
            If DosError = 0 Then
                HlpHint (HntTooManyFiles, HintNormalTime);
        End Else
            Dec (EntryC);
        QSort (EntryC);
    End;
    Procedure Done;
    Begin
        Dispose (Files);
    End;

    Function GetNr(AX, AY, Page: integer): word;
        { maxentries+1 wenn nichts, maxentries+2 wenn pgdn und maxentries+3 wenn pgdn}
    Begin
        AX := AX - X;
        AY := AY - Y - 6;
        If (AX < 0) OR (AX > rows * 8 * 19) Then
        Begin
            GetNr := MaxEntries + 1;
            Exit;
        End;
        If (AY < 0) Then
        Begin
            If (ay > -16 - 6) Then
                GetNr := MaxEntries + 3
            Else
                GetNr := MaxEntries + 1;
            Exit;
        End;
        If (AY >= cols * 16) Then
        Begin
            If (AY < cols * 17) Then
                GetNr := MaxEntries + 2
            Else
                GetNr := MaxEntries + 1;
            Exit;
        End;
        AX := AX DIV 8;{=DIV 8, Charheight}
        AY := AY DIV 16;{=DIV 16,(Charheight*2}
        If (AX MOD 19) > 14 Then
        Begin
            GetNr := MaxEntries + 1;
            Exit;
        End;
        GetNr := (AX DIV 19) * Cols + AY + page;
    End;
    Procedure ShowNr(Nr: Word);
    Var s: String;
        AX, AY: Integer;
    Begin
        With Files^.Entries[Nr] Do
        Begin
            If NOT Used Then
                Exit;
            s := Name;
            IniExpand (s, 8);
            If Ext <> '' Then
            Begin
                s := s + '.' + Ext;
                IniExpand (s, 12);
            End Else
                IniExpand (s, 12);
        End;
        ax := 19 * ((Nr - Page) DIV Cols);
        ay := ((Nr - Page) MOD Cols) * 2;
        IniGraphXY (Ax, Ay);
        Ax := Ax + X + 16;
        Ay := Ay + Y + 8;
        If (Nr = SelEntry) AND ShowSel Then
            IniSpacedWrite (Ax, Ay, s, frHigh)
        Else Begin
            SetFillStyle (1, 7); {11=gepunktet,13=lila} {(Solidfill,7);}
            Bar (ax - 3, ay - charheight, ax + 13 * charwidth + 1, ay + charheight + 1);
            SetColor (12);
            txtfnt.write (ax, ay, s, 12, sz8x8, stnormal);
        End;
    End;
    Procedure ShowPage;
    Var SaveColor: Byte;
        i: Byte;
        X0, X1, Y0, Y1: integer;
    Begin
        SaveColor := GetColor;
        SetFillStyle (Solidfill, 7);{!!!}
        Y0 := Y;
        Y1 := Y + (Cols) * 2 * CharHeight + 8;
        {  Bar(x-24,y,(x+19*Charwidth*(Rows-1)+15*charwidth)+19,(y+2*(Cols+1)*Charheight)+15);}
        SetColor (5);
        {  Line(x-25,y,x-25,y+350);}{wegen ZahnlÅcke}{Runtime bei Alt-F10}
        For i := 0 To rows - 1 Do
        Begin
            X0 := X + i * 152;
            X1 := X + (i * 19 + 14) * 8 + 4;
            Bar (X0 + 1, Y0 + 1, X1 - 1, Y1 - 1);
            SetColor (5);
            Line (X0, Y1, X1, Y1);
            Line (X1, Y1, X1, Y0);
            SetColor (12);
            Line (X0, Y0, X1, Y0);
            Line (X0, Y0, X0, Y1);
(*    SetFillStyle(1,7); {11=gepunktet, 13=lila}
    Bar(X0+1,Y0+1,X1-1,Y1-1);   *)
        End;
        SetColor (SaveColor);
        If (EntryC - Page) >= Cols * Rows Then
            For i := 0 To Cols * Rows - 1 Do
                ShowNr (i + Page) Else For i := 0 To (EntryC MOD (Cols * Rows)) Do
                ShowNr (i + Page);
    End;
    Procedure CalcPage;
    Begin
        Page := SelEntry - (SelEntry MOD (Cols * Rows));
    End;
    Procedure ShowAll;
    Begin
        CalcPage;
        ShowPage;
    End;
    Procedure SetSel(Nr, c: Integer);
    Var Temp: Word;
    Begin
        If (C = -1) AND (Nr = 0) Then
        Begin
            If NOT GoUp Then
            Begin
                Inc (C);
                Exit;
            End;
            showsel := False;
            ShowNr (0);
            Selected := False;
            Cancel := True;
        End;
        If (Nr + c < 0) OR (Nr + c > MaxEntries) Then
            Exit;
        If SelEntry = (Nr + C) Then
            Exit;
        If Files^.Entries[Nr + c].Used Then
        Begin
            ShowSel := False;
            ShowNr (SelEntry);
            SelEntry := Nr + c;
        End Else
            Exit;
        Temp := Page;
        CalcPage;
        If Page <> Temp Then
            ShowAll;
        ShowSel := True;
        ShowNr (SelEntry);
    End;

Begin
    mausdunkel;
    mausmenu := 0;
    Init;
    If Disponly Then
    Begin
        ShowAll;
        Done;
        Exit;
    End;
    Cancel := False;
    ShowSel := True;
    ShowNr (SelEntry);
    While NOT (Selected OR Cancel) Do
    Begin
        Repeat
            MausZeigen;
            c := ' ';
            If XKeyPressed Then c := XReadKey (Shift, Ctrl) Else If Maustaste = 0 Then
            Begin
                MausPosition (mausx, mausy, maustaste, mp, mausmenu);
                If mausmenu = actmenu Then
                Begin
                    If maustaste = 1 Then
                    Begin
                        MausMenu := GetNr (MausX, MausY, Page);
                        Case MausMenu Of
                            MaxEntries + 1: ;
                            MaxEntries + 2:
                            Begin { pgdn}
                                SelEntry := Page;
                                SetSel (SelEntry, +Rows * Cols);
                            End;
                            Maxentries + 3:
                            Begin { pgup}
                                SelEntry := Page;
                                SetSel (SelEntry, -Rows * Cols);
                            End;
                            0..MaxEntries: If Files^.Entries[mausmenu].Used Then
                                Begin
                                    MausDunkel;
                                    SetSel (MausMenu, 0);
                                    c := #13;
                                End;
                        End;
                    End;
                End Else If maustaste = 1 Then
                    c := #27;
                If maustaste = 2 Then
                    c := #27;
                maustaste := 0;
            End;
            Maustaste := 0;
        Until c <> ' ';
        MausDunkel;

        Case c Of
            Null:  { Steuer-Tasten }
            Begin
                c := xReadKey (shift, ctrl);     { Lesen welche  }
                Case c Of
                    CursorUp: SetSel (SelEntry, -1);
                    CursorDown: SetSel (SelEntry, +1);
                    Cursorleft: SetSel (SelEntry, -Cols);
                    Cursorright: SetSel (SelEntry, +Cols);
                    PgUp:
                    Begin
                        SelEntry := Page;
                        SetSel (SelEntry, -Rows * Cols);
                    End;
                    PgDn:
                    Begin
                        SelEntry := Page;
                        SetSel (SelEntry, +Rows * Cols);
                    End;
                    CursorHome: SetSel (Page, 0);
                    CursorEnd: If Page + cols * Rows > EntryC Then
                            SetSel (EntryC, 0)
                        Else
                            SetSel (Page + cols * Rows - 1, 0);
                    CtrlPgUp: SetSel (0, 0);
                    CtrlPgDn: SetSel (EntryC, 0);
                End; { Case }
            End; { Null }

            ESC:
            Begin
                Cancel := True;
                Selected := False;
                ShowSel := False;
                ShowNr (SelEntry);
{        Page:=0;
        SelEntry:=0;
        ShowAll;}
            End;
            RETURN:
            Begin
                ShowSel := True;
                ShowNr (SelEntry);
                With Files^.Entries[SelEntry] Do
                Begin
                    instring := Name + '.' + Ext;
                    If used Then
                    Begin
                        selected := True;
                        Cancel := False;
                        Maustaste := 0;
                        Mauszeigen;
                    End Else Begin
                        selected := False;
                        cancel := True;
                    End;
                End;
            End;
        End; { Case }
    End; { While }
    Mauszeigen;
    Done;
End;
End.
