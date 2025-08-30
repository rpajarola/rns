{$I RNS.H}

Unit butunit;

Interface

Uses graph,
    initsc,
    menutyp,
    GcuRunit;

Type
    pbutton = ^tbutton;
    tbutton = Object
    Private
        x0, x1, y0, y1: Integer;
        resp: response_type;
        keyresponse: Char;
        mtext: string;
    Public
        Constructor init(ax0, ax1, ay0, ay1: Integer;
            aresp: response_type; akeyresponse: Char;
            amtext: string);
        Procedure draw; Virtual;
        Function activated(mausx, mausy: Integer;
            Var vresp: response_type; Var vkeyresponse: Char):
            Boolean;
        Procedure GetSize(Var aX0, aY0, aX1, aY1: Integer);
        Procedure GetSettings(Var aresp: response_type; Var akeyresp: Char;
            Var amtext: string);
    End;

    pThreeDButton = ^tThreeDButton;
    tThreeDButton = Object(Tbutton)
        FColor: Byte;
        TColor: Byte;
        Constructor init(ax0, ax1, ay0, ay1: Integer;
            aresp: response_type; akeyresponse: Char;
            amtext: string; aFC, aTC: Byte);
        Procedure draw; Virtual;
        Procedure frame(c1, c2: Byte);
    End;
    tmenubutton = Array[1..10, 1..4] Of TThreeDButton;

Var
    vmenubutton: tmenubutton;
    vpageup, vpagedn, vswap, vexit: TThreeDButton;


Procedure butdraw;
Procedure butinit;
Procedure ButActivated(mausx, mausy: Integer;
    Var vresp: response_type; Var vkeyresponse: Char);

Implementation

{*************************************************************}
Constructor TButton.init(ax0, ax1, ay0, ay1: Integer;
    aresp: response_type; akeyresponse: Char;
    amtext: string);
Begin
    x0 := ax0;
    x1 := ax1;
    y0 := ay0;
    y1 := ay1;
    resp := aresp;
    keyresponse := akeyresponse;
    mtext := amtext;
End;

{*************************************************************}
Procedure TButton.draw;

Begin
    bar (x0, y0, x1 + 2, y1);
    txtfnt.write (x0 + 2, (y0 + y1) DIV 2 + 1, mtext, getcolor, sz6x12, stnormal);
End;

{*************************************************************}
Function TButton.activated(mausx, mausy: Integer;
    Var vresp: response_type; Var vkeyresponse: Char):
Boolean;
Var res: Boolean;

Begin
    res := ((mausx > x0 - 2 + charwidth) AND (mausx < x1 + 2 + charwidth) AND
        (mausy > y0 + charheight) AND (mausy < y1 + 2 + charheight));
    If res Then
    Begin
        vresp := resp;
        vkeyresponse := keyresponse;
    End;
    activated := res;
End;

{*************************************************************}
Procedure butinit;

Const butsizex = 56;
    butsizey = 10;
    butdiffx = 4;
    butdiffy = 3;
    butxmarg = 2;
    butymarg = -1;
Var i, j: Word;
    vresp: response_type;
    vkeyresponse: Char;
    vmtext: string;
    fc, tc: Byte;

Const butmenu: Array[1..10, 1..4] Of string =
        (('1  Help  ',
        'S  Show  ',
        'C  Print ',
        'A  BegV{ '),
        ('2 Save   ',
        '  Save?  ',
        ' SplitFi ',
        '  EndV{  '),
        ('3 NoteLn ',
        '  NLDef  ',
        ' SplitLn ',
        '  BegH{  '),
        ('4 Space  ',
        '  InsPg  ',
        ' SplitPg ',
        '  EndH{  '),
        ('5 Play   ',
        '  Sound  ',
        ' SymbSnd ',
        '  VerLn  '),
        ('6 Header ',
        '  Search ',
        '  Repeat ',
        '  Ver'#18'Ln'),
        ('7 CopyLn ',
        '  Line   '{' Line'},
        ' PasteLn ',
        ' Hor3DLn '),
        ('8 MarkBl ',
        '  Block  ',
        ' PasteBl ',
        ' Ver3DLn '),
        ('9 MarkPg ',
        '  Page   ',
        ' PastePg ',
        ' SetupPg '),
        ('10 Table ',
        ' KeySwap ',
        '  Fonts  ',
        '  PgNum  '));

    ButVKeyResp: Array[1..4] Of Byte = (103, 93, 83, 58);

    Function ButTopY(n: Byte): Integer;
    Begin
        ButTopY := gmaxy - butymarg - (n * (butsizey + butdiffy));
    End;
    Function ButBotY(n: Byte): Integer;
    Begin
        ButBotY := ButTopY (n) + ButSizeY;
    End;
    Function ButLeftX(n: Byte): Integer;
    Begin
        If n < 11 Then
            butleftx := butxmarg + (n - 1) * (butsizex + butdiffx)
        Else
            butleftx := butxmarg + (n - 1) * (butsizex + butdiffx){+3};
    End;
    Function ButRightX(n: Byte): Integer;
    Begin
        If n < 11 Then
            butrightx := butleftx (n) + butsizex
        Else
            butrightx := gmaxx - butxmarg - 2{3};
    End;
    Function ButPgX: Integer;
    Begin
        ButPgX := (butrightx (11) - butleftx (11) - butdiffx) SHR 1;
    End;
Begin
    fc := framecolor + framebkcolor SHL 4;
    tc := mausmtcolor;
    For i := 1 To 10 Do
        For j := 1 To 4 Do
        Begin
            vmtext := butmenu[i, 5 - j];                       { Menutext }
            vresp  := specialkey;                           { Key-Typ  }
            vkeyresponse := Char (ButVKeyResp[j] + i);         { Scancode }
            vmenubutton[i, j].init (butleftx (i), butrightx (i),
                buttopy (j), butboty (j),
                vresp, vkeyresponse, vmtext,
                FC, TC);

        End;

    vpageup.init (butleftx (11), butleftx (11) + butpgx,
        buttopy (4), butboty (4),
        specialkey, chr (73), #23 + ' ',
        FC, TC);
    vpagedn.init (butleftx (11) + butpgx + butdiffx, butrightx (11),
        buttopy (4), butboty (4),
        specialkey, chr (81), ' ' + #22 {+ ' '},
        FC, TC);
    vswap.init (butleftx (11), butrightx (11),
        buttopy (3), butboty (2),
        specialkey, chr (133), '  ' + #17 + ' ',
        FC, TC);
    vexit.init (butleftx (11), butrightx (11),
        buttopy (1), butboty (1),
        specialkey, chr (134), 'RefPg',
        FC, TC);
End;

{*************************************************************}
Procedure butdraw;

Var i, j: Word;
    tcol: Byte;

Begin
    tcol := GetColor;
    SetColor (12);
    Line (0, grmaxy + 1, gmaxx{-1}, grmaxy + 1);  {schwarze Linie oberhalb des Mausmenus}
    Line (0, grmaxy, gmaxx{-1}, grmaxy);      {schwarze Linie oberhalb des Mausmenus}
    SetColor (framecolor{5});
    Line (0, grmaxy + 2, gmaxx - 1, grmaxy + 2);  {Linie oberhalb des Mausmenus}
    Line (0, grmaxy + 3, 0, gmaxy);           {Linie links vom Mausmenu}
    SetColor (mausmtcolor);
    SetFillStyle (1, mausmbkcolor);
    For i := 1 To 10 Do
        For j := 1 To 4 Do
            vmenubutton[i, j].draw;
    vpageup.draw;
    vpagedn.draw;
    vswap.draw;
    vexit.draw;
    SetColor (8);
    Line (grminx, gmaxy, gmaxx, gmaxy);     {dunkelgraue Linie unterhalb vom Mausmenu}

    SetColor (tcol);
    SetBkColor (bkcolor);
End;

{*************************************************************}
Procedure ButActivated(mausx, mausy: Integer;
    Var vresp: response_type; Var vkeyresponse: Char);
Var i, j: Word;
    result: Boolean;

Begin
    result := false;
    For i := 1 To 10 Do
        For j := 1 To 4 Do
            If vmenubutton[i, j].activated (mausx, mausy, vresp, vkeyresponse) Then
            Begin
                result := true;
                break;
            End;
{$IFOPT B+}{$DEFINE BOOL}{$ENDIF}{$B-}
    result := result OR vpageup.activated (mausx, mausy, vresp, vkeyresponse)
        OR vpagedn.activated (mausx, mausy, vresp, vkeyresponse)
        OR vswap.activated (mausx, mausy, vresp, vkeyresponse)
        OR vexit.activated (mausx, mausy, vresp, vkeyresponse);
{$IFDEF BOOL}{$UNDEF BOOL}{$B+}{$ENDIF}
{  i:= 1;
  while i <= 10 do begin
    j:= 1;
    while j <= 4 do begin
      if vmenubutton[i,j].activated(mausx, mausy, vresp, vkeyresponse) then begin
        result:= true;
        i:= 999;
        j:= 999;
      end;
      j:= j+1;
    end;
    i:= i+1;
  end;
  if not result then begin
    result:= vpageup.activated(mausx, mausy, vresp, vkeyresponse);
  end;
  if not result then begin
    result:= vpagedn.activated(mausx, mausy, vresp, vkeyresponse);
  end;
  if not result then begin
    result:= vswap.activated(mausx, mausy, vresp, vkeyresponse);
  end;
  if not result then begin
    result:= vexit.activated(mausx, mausy, vresp, vkeyresponse);
  end;}
{  IF (VKeyResponse='U') And (VResp=SPECIALKEY) Then
    VResp:=No_Response;}
    If (VResp = SPECIALKEY) AND (VKeyResponse = #63) Then
        GcuPatternRestore;
End;

Procedure TButton.GetSize(Var aX0, aY0, aX1, aY1: Integer);
Begin
    ax0 := x0;
    ay0 := y0;
    ax1 := x1;
    ay1 := y1;
End;

Procedure TButton.GetSettings(Var aresp: response_type; Var akeyresp: Char;
    Var amtext: string);
Begin
    aresp := resp;
    akeyresp := keyresponse;
    amtext := mtext;
End;

Constructor tThreeDButton.init(ax0, ax1, ay0, ay1: Integer;
    aresp: response_type; akeyresponse: Char;
    amtext: string; aFC, aTC: Byte);
Begin
    Inherited init (ax0, ax1, ay0, ay1, aresp, akeyresponse, amtext);
    fcolor := aFC;
    tcolor := aTC;
End;

Procedure tThreeDButton.draw;
Begin
    setcolor (tcolor);
    Inherited draw;
    frame (fcolor AND $0F, (fcolor AND $f0) SHR 4);
End;

Procedure tThreeDButton.frame(c1, c2: Byte);
Begin
    SetColor (12);
    line (x0 - 1, y0, x0 - 1, y1 + 1);    {Rahmen links}
    line (x1 + 3, y0, x1 + 3, y1 + 1);    {Rahmen rechts}
    line (x0, y0 - 1, x1 + 2, y0 - 1);        {Rahmen oben}
    line (x0 + 1, y1 + 2, x1 + 2, y1 + 2);  {Rahmen unten}
    setcolor (c1);
    line (x0, y0, x0, y1 + 1);        { left }
    line (x0, y0, x1 + 2, y0);        { top }
    setcolor (8{c2});{I'm so sorry!}
    line (x1 + 2, y0 + 1, x1 + 2, y1 + 1);  { right }
    line (x0 + 1, y1 + 1, x1 + 2, y1 + 1);  { bottom }
End;

End.
