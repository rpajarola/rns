{$A+,B-,D+,E-,F-,G+,I+,L+,N-,O-,P-,Q+,R+,S+,T-,V-,X+,Y+}
{$M 16384,0,655360}
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
Procedure SdUSodir(Disponly : Boolean;var Selected : Boolean;ShowSel : Boolean;
                    var instring : string79;Mask : String16;
                    dir : string79;Dirorfile : Boolean;
                    x,y : integer;Cols,rows : Byte;
                    var mausx, mausy, maustaste : Word;actmenu : word;
                    selX,selY : integer;GoUp : Boolean);

Implementation
Procedure SduSodir(Disponly : Boolean;var Selected : Boolean;ShowSel : Boolean;
                    var instring : string79;Mask : String16;
                    dir : string79;Dirorfile : Boolean;
                    x,y : integer;Cols,rows : Byte;
                    var mausx, mausy, maustaste : Word;actmenu : word;
                    selX,selY : integer;GoUp : Boolean);

Const CursorUp   = #72;
      CursorDown = #80;
      Cursorleft = #75;
      CursorRight= #77;
      PgUp       = #73;
      PgDn       = #81;
      Cursorend  = #79;
      CursorHome = #71;
      CtrlPgUp   = #132;
      CtrlPgDn   = #118;
      ESC        = #27;
      RETURN     = #13;
      Null       = #0;
      MaxC       = 40;
      MaxR       = 3;
      MaxEntries = 511;

Type  TEntry = Record
        Attrib   : Byte;
        Used     : Boolean;
        Name     : String[8];
        Ext      : String[3];
      End;
      PFilePage = ^TFilePage;
      TFilePage = Record
        Entries : Array[0..511] OF TEntry;
      End;
Var Cancel     : Boolean Absolute Disponly;
    Files      : PFilePage;
    EntryC     : Word;
    SelEntry   : Word;
    Page       : Word;
    c          : Char;
    Shift,Ctrl : Boolean;
    MausMenu   : Word;
    Mp         : Word;
PROCEDURE QSort(N : INTEGER);
(* Sortierroutine, die nach dem Verfahren des Quicksort arbeitet.
   Sie arbeitet in AbhÑngigkeit des Parameters ORDER auf den ver-
   schiedenen Array-Feldern. *)

   FUNCTION Kleiner(i1, i2 : TEntry) : BOOLEAN;{Assembler;
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
  BEGIN
       Kleiner := i1.name < i2.name;
     END;

   PROCEDURE Swap (i1, j1 : INTEGER);
   (* Vertauschen von zwei ArrayeintrÑgen *)
     VAR tmp : TEntry;
     BEGIN
       tmp := Files^.entries[i1];
       Files^.entries[i1] := Files^.entries[j1];
       Files^.entries[j1] := tmp;
     END;

   PROCEDURE Sortiere(l, r : INTEGER);
   (* Quicksort-Routine *)
     VAR i, j : INTEGER;
            M : TEntry;
     BEGIN
       i := l;                (* Startwert fÅr linken Laufindex  *)
       j := r;                (* Startwert fÅr rechten LAufindex *)
       M := Files^.Entries[(l+r) DIV 2]; (* Mittelelement *)
       REPEAT
         WHILE Kleiner(files^.Entries[i], M) DO INC(i);
         WHILE Kleiner(M, files^.Entries[j]) DO DEC(j);
         IF i <= j THEN BEGIN
           IF i <> j THEN Swap(i, j);  (* Nur Tausch, wenn Indizes *)
           INC(i);                     (* nicht auf gleiches Elem. *)
           DEC(j);                     (* zeigen *)
         END;
       UNTIL i > j;
       IF l < j THEN Sortiere(l, j);   (* rekursive Aufrufe *)
       IF i < r THEN Sortiere(i, r);
     END;
BEGIN
  IF N>0 Then
    Sortiere(0,N);
END;

Procedure Init;
Var i : Integer;
    b : Byte;
    D : SearchRec;
    at: byte;
    m : string16;
Begin
  SelEntry:=0;
  Page:=0;
  IF Cols>MaxC Then
    Cols:=MaxC;
  IF Rows>MaxR Then
    Rows:=MaxR;
  New(Files);
  For i := 0 To MaxEntries Do
  Begin
    With Files^.Entries[i] Do Begin
      Used:=False;
      Name:='        ';
      Ext:='   ';
    End;
  End;
  EntryC:=0;
  if dirorfile then
    at:=directory
  else
    at:=anyfile;
  while mask<>'' do begin
    inileadblank(mask);
    if pos(' ',mask)=0 then begin
      m:=mask;
      mask:='';
    end else begin
      m:=copy(mask,1,pos(' ',mask));
      delete(mask,1,pos(' ',mask));
    end;
    inileadblank(m);
    initrailblank(m);
    FindFirst(Dir+M,At,D);
    While (DosError=0) And (EntryC<=MaxEntries) Do Begin
      IF (D.Name[1]<>'.') Then Begin
        With Files^.Entries[EntryC] Do Begin
          if ((d.attr and directory)<>0) = dirorfile then Begin
            Attrib:=D.Attr;
            Used:=True;
            b:=Pos('.',D.Name);
            IF b<>0 Then Begin
              Name:=Copy(D.Name,1,b-1);
              Ext:=Copy(D.Name,b+1,byte(d.Name[0])-b);
            End Else Begin
              Name:=D.Name;
              Ext:='';
            End;
            Inc(EntryC);
          End;
        End;
      End;
      FindNext(D);
    End;
  end;{ while mask<>'' }
  IF EntryC=0 Then Begin
{    HlpText(substartx, subendx, substarty + 6,
           'No files found', true);
    Delay(HintNormalTime);}
    cancel:=True;
  End Else IF EntryC=MaxEntries Then Begin
    IF DosError=0 Then
      HlpHint(HntTooManyFiles,HintNormalTime);
  End Else
    Dec(EntryC);
  QSort(EntryC);
End;
Procedure Done;
Begin
  Dispose(Files);
End;

Function GetNr(AX,AY,Page : integer) : word;
{ maxentries+1 wenn nichts, maxentries+2 wenn pgdn und maxentries+3 wenn pgdn}
Begin
  AX:=AX-X;
  AY:=AY-Y-6;
  IF (AX<0) Or (AX>rows*8*19) Then Begin
    GetNr:=MaxEntries+1;
    Exit;
  End;
  IF (AY<0) then begin
    if (ay>-16-6) then
      GetNr:=MaxEntries+3
    else
      GetNr:=MaxEntries+1;
    Exit;
  end;
  IF (AY>=cols*16) Then Begin
    if (AY<cols*17) Then
      GetNr:=MaxEntries+2
    else
      GetNr:=MaxEntries+1;
    Exit;
  End;
  AX:=AX div 8;{=DIV 8, Charheight}
  AY:=AY div 16;{=DIV 16,(Charheight*2}
  IF (AX Mod 19)>14 Then Begin
    GetNr:=MaxEntries+1;
    Exit;
  End;
  GetNr:=(AX Div 19)*Cols+AY+page;
End;
Procedure ShowNr(Nr : Word);
Var s : String;
    AX,AY : Integer;
Begin
  With Files^.Entries[Nr] Do Begin
    IF Not Used Then
      Exit;
    s:=Name;
    IniExpand(s,8);
    IF Ext<>'' Then Begin
      s:=s+'.'+Ext;
      IniExpand(s,12);
    End Else
      IniExpand(s,12);
  End;
  ax:=19*((Nr-Page) Div Cols);
  ay:=((Nr-Page) Mod Cols)*2;
  IniGraphXY(Ax, Ay);
  Ax:=Ax+X+16;
  Ay:=Ay+Y+8;
  IF (Nr=SelEntry) And ShowSel Then
    IniSpacedWrite(Ax, Ay, s,frHigh)
  Else Begin
    SetFillStyle(1,7); {11=gepunktet,13=lila} {(Solidfill,7);}
    Bar(ax-3,ay-charheight,ax+13*charwidth+1,ay+charheight+1);
    SetColor(12);
    txtfnt.write(ax,ay,s,12,sz8x8,stnormal);
  End;
End;
Procedure ShowPage;
Var SaveColor   : Byte;
    i           : Byte;
    X0,X1,Y0,Y1 : integer;
Begin
  SaveColor:=GetColor;
  SetFillStyle(Solidfill,7);{!!!}
  Y0:=Y;
  Y1:=Y+(Cols)*2*CharHeight+8;
{  Bar(x-24,y,(x+19*Charwidth*(Rows-1)+15*charwidth)+19,(y+2*(Cols+1)*Charheight)+15);}
  SetColor(5);
{  Line(x-25,y,x-25,y+350);} {wegen ZahnlÅcke} {Runtime bei Alt-F10}
  For i:=0 to rows-1 Do Begin
    X0:=X+i*152;
    X1:=X+(i*19+14)*8+4;
    Bar(X0+1,Y0+1,X1-1,Y1-1);
    SetColor(5);
    Line(X0,Y1,X1,Y1);
    Line(X1,Y1,X1,Y0);
    SetColor(12);
    Line(X0,Y0,X1,Y0);
    Line(X0,Y0,X0,Y1);
(*    SetFillStyle(1,7); {11=gepunktet, 13=lila}
    Bar(X0+1,Y0+1,X1-1,Y1-1);   *)
  End;
  SetColor(SaveColor);
  IF (EntryC-Page)>=Cols*Rows Then Begin
    For i:=0 To Cols*Rows-1 do
      ShowNr(i+Page);
  end Else Begin
    for i:=0 To (EntryC Mod (Cols*Rows)) Do
      ShowNr(i+Page);
  End;
End;
Procedure CalcPage;
Begin
  Page:=SelEntry-(SelEntry Mod (Cols*Rows));
End;
Procedure ShowAll;
Begin
  CalcPage;
  ShowPage;
End;
Procedure SetSel(Nr,c: Integer);
Var Temp : Word;
Begin
  IF (C=-1) And (Nr=0) Then Begin
    IF Not GoUp Then Begin
      Inc(C);
      Exit;
    End;
    showsel:=False;
    ShowNr(0);
    Selected:=False;
    Cancel:=True;
  End;
  IF (Nr+c<0) Or (Nr+c>MaxEntries) Then
    Exit;
  IF SelEntry=(Nr+C) Then
    Exit;
  IF Files^.Entries[Nr+c].Used Then Begin
    ShowSel:=False;
    ShowNr(SelEntry);
    SelEntry:=Nr+c
  End Else
    Exit;
  Temp:=Page;
  CalcPage;
  IF Page<>Temp Then
    ShowAll;
  ShowSel:=True;
  ShowNr(SelEntry);
End;

Begin
  mausdunkel;
  mausmenu:=0;
  Init;
  IF Disponly Then Begin
    ShowAll;
    Done;
    Exit;
  End;
  Cancel:=False;
  ShowSel:=True;
  ShowNr(SelEntry);
  While Not (Selected or Cancel) Do Begin
    Repeat
      MausZeigen;
      c:=' ';
      IF XKeyPressed Then Begin
        c:=XReadKey(Shift,Ctrl);
      End Else Begin
        IF Maustaste = 0 Then Begin
          MausPosition(mausx, mausy, maustaste, mp, mausmenu);
          IF mausmenu = actmenu Then Begin
            IF maustaste = 1 Then Begin
              MausMenu:=GetNr(MausX,MausY,Page);
                Case MausMenu of
                  MaxEntries+1:;
                  MaxEntries+2: begin { pgdn}
                    SelEntry:=Page;
                    SetSel(SelEntry,+Rows*Cols);
                  end;
                  Maxentries+3: begin { pgup}
                    SelEntry:=Page;
                    SetSel(SelEntry,-Rows*Cols);
                  end;
                  0..MaxEntries: begin
                    if Files^.Entries[mausmenu].Used then begin
                      MausDunkel;
                      SetSel(MausMenu,0);
                      c:= #13;
                    end;
                  End;
                End;
            End;
          End Else if maustaste = 1 then
            c:= #27;
          IF maustaste = 2 then
             c:= #27;
          maustaste:= 0;
        End;
      End;
      Maustaste:=0;
    until c <> ' ';
    MausDunkel;

    Case c OF
      Null :  { Steuer-Tasten }
        Begin
          c:= xReadKey(shift,ctrl);     { Lesen welche  }
          Case c OF
            CursorUp : Begin
              SetSel(SelEntry,-1);
            End;
            CursorDown : Begin
              SetSel(SelEntry,+1);
            End;
            Cursorleft : Begin
              SetSel(SelEntry,-Cols);
            End;
            Cursorright: Begin
              SetSel(SelEntry,+Cols);
            End;
            PgUp : Begin
              SelEntry:=Page;
              SetSel(SelEntry,-Rows*Cols);
            End;
            PgDn : Begin
              SelEntry:=Page;
              SetSel(SelEntry,+Rows*Cols);
            End;
            CursorHome : Begin
              SetSel(Page,0);
            End;
            CursorEnd : Begin
              IF Page+cols*Rows>EntryC Then
                SetSel(EntryC,0)
              Else
                SetSel(Page+cols*Rows-1,0);
            End;
            CtrlPgUp : Begin
              SetSel(0,0);
            End;
            CtrlPgDn : Begin
              SetSel(EntryC,0);
            End;
          End; { Case }
        End; { Null }

      ESC : begin
        Cancel:=True;
        Selected:=False;
        ShowSel:=False;
        ShowNr(SelEntry);
{        Page:=0;
        SelEntry:=0;
        ShowAll;}
      End;
      RETURN: begin
        ShowSel:=True;
        ShowNr(SelEntry);
        With Files^.Entries[SelEntry] Do Begin
          instring:=Name+'.'+Ext;
          IF used then Begin
            selected:=True;
            Cancel:=False;
            Maustaste:=0;
            Mauszeigen;
          End Else Begin
            selected:=False;
            cancel:=True;
          End;
        End;
      end;
    END; { Case }
  END; { While }
  Mauszeigen;
  Done;
End;
End.

