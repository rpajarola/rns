{$I RNS.H}
unit editunit;

interface

uses
     Graph,
     GCurUnit,
     Symbols,
     GetUnit,
     TitleUnit,
     InitSc,
     menutyp,
     inout,
     fileunit,
     pageunit,
     comunit,
     noteunit,
     markunit,
     helpunit,
     strings,
     butunit,
     timer,
     dos,
     crt,
     xcrt,
     UserExit,
     Texts;

procedure EdiRythmEdit(instring,bakname: string79; defpagesetup, demloc: boolean);
Function EdiSavePossible(fn : String) : Boolean;
implementation

uses mousdrv,
     CRCUnit;

Const crcOK  = 0;
      crcNIL = 1;
      crcNOK = 2;


Function EdiCheckCRC(instring : String) : Byte;
Var crc : Word;
Begin
  if GetCRCFileEntry(instring,crc) Then Begin
    if GetCRC(instring)=crc Then
      EdiCheckCRC:=crcOK
    else
      EdiCheckCRC:=crcNOK;
  End Else
    EdiCheckCRC:=crcNIL;
End;
Procedure EdiCopyFile(N1,N2 : String);
Var P      : Pointer;
    S      : LongInt;
    C,C1,M : Word;
    F1,F2  : File;
Begin
  Assign(F1,N1);
  Assign(F2,N2);
  FileMode:=0;
  LastFileName:=FExpand(N1);
  ReSet(F1,1);
  FileMode:=1;
  LastFileName:=FExpand(N2);
  ReWrite(F2,1);
  FileMode:=2;
  S:=FileSize(F1);
  IF S>65528 Then
    M:=65528
  Else
    M:=S;
  GetMem(P,M);
  C:=1;
  While (S>0) And (C<>0) Do Begin
    if S>M Then Begin
      BlockRead(F1,P^,M,C)
    End Else Begin
      BlockRead(F1,P^,S,C)
    End;
    Dec(S,C);
    LastFileName:=FExpand(N2);
    BlockWrite(F2,P^,C,C1);
    IF C1<>C Then
      C:=0;
    LastFileName:=FExpand(N1);
  End;
  FreeMem(P,M);
  Close(F1);
  LastFileName:=FExpand(N2);
  Close(F2);
End;

Function EdiCheckDemoFileName(instring : String;var f : Text) : Boolean;
{ Check if file is in list and CRC ok }
Begin
  instring:=UpString(instring);
  Case EdiCheckCRC(instring) Of
    crcOK: Begin
      EdiCheckDemoFileName:=True;
{      if pos('TESTFILE.RNS',instring)=0 Then
        SetFAttr(infile, ReadOnly);}
    end;
    crcNIL: Begin
      HlpHint(HntDemoNIL,0);
      EdiCheckDemoFileName:=False;
    End;
    crcNOK: Begin
      if pos('TESTFILE.RNS',instring)=0 Then Begin
        HlpHint(HntDemoCRC,0);
        EdiCheckDemoFileName:=False;
      End Else Begin
        HlpAsk('Demoversion: TESTFILE.RNS has been changed, restoring previous one',
               'Press [Enter] to continue',hpEdit,[#13]);
{        HlpHint(HntDemoCRCTestfile,0);}
        IF isCRCOK('DEMODIR\DEMOTEST.PRE') Then Begin
          EdiCopyFile('DEMODIR\DEMOTEST.PRE','DEMODIR\TESTFILE.RNS');
          SetCRCFileEntry('DEMODIR\TESTFILE.RNS',GetCRC('DEMODIR\TESTFILE.RNS'));
          EdiCheckDemoFileName:=True;
        End Else Begin
          IF isCRCOK('TESTFILE.RNS') Then Begin
            EdiCopyFile('TESTFILE.RNS','DEMODIR\TESTFILE.RNS');
            SetCRCFileEntry('DEMODIR\TESTFILE.RNS',GetCRC('DEMODIR\TESTFILE.RNS'));
            EdiCheckDemoFileName:=True;
          End Else Begin
            EdiCheckDemoFileName:=False;
          End;
        End;
      End;
    End;
  End;
End;
{******************************************************}
procedure EdiRythmEdit(instring,bakname: string79; defpagesetup, demloc: boolean);

var
    i,j,k                                : integer;
    c                                    : char;
    Response                             : Response_Type;
    Direction                            : Movement;
    KeyResponse                          : Char;
    Result                               : integer;
    actpost, actposn                     : integer;
    actptr, startptr, lastptr            : listptr;
    linenum                              : integer;
    firstpage                            : byte;
    inblock                              : stringline;
    ifile                                : text;
    ok, shiftp, ctrlp                    : boolean;
    mausx, mausy, maustaste, mp, mausmenu: word;
    attr                                 : word;
    Savepat                              : boolean;

begin
  soundattr:=0;
  Mausdunkel;
  symcount:=0;
  Mark(heapmark);
  Response:= No_Response;
  firstpage:= 1;
  actposn:= 1;
  actpost:= 1;
  vtimer.init;
  if defsetuppage in actedit then begin
    firstpage:= 0;
  end;
  {$IFNDEF DEMO }if demLOC then {$ENDIF}
    IF Not EdiCheckDemoFileName(instring,infile) Then Begin
      Exit;
    End;
  if defpagesetup then begin
    FilAssignRnsFile(infile, instring, true);
    Reset(infile);
    instring:= instring + exts;
    readln(infile,inblock);
    if inblock='$$$RNSBUFFER$$$' then
      bufffile:=true
    else
      bufffile:=false;
    ReSet(infile);
  end else begin
    assign(infile, instring);
{    if ((demloc) and (Pos('TESTFILE.RNS',instring) = 0)) then begin
      SetFAttr(infile, ReadOnly);
    end else}
  end;

  if ((not IniFileExist(instring)) and
     (not (defsetuppage in actedit))) then begin
    firstpage:=0;
    pagesav:= 1;
    actedit:= actedit + [setuppage];
    IniSwapColors;
    FilAssignRnsFile(ifile, 'pageset', true);
    LastFileName:=FExpand(TextRec(INFile).Name);
    Rewrite(infile);
    ReSet(ifile);
    for linenum:= topmargin to pagelength do begin
      LastFileName:=FExpand(TextRec(IFile).Name);
      Readln(ifile, inblock);
      LastFileName:=FExpand(TextRec(INFile).Name);
      Writeln(infile, inblock);
    end;
    Close(infile);
    LastFileName:=FExpand(TextRec(ifile).Name);
    Close(ifile);
    {leeren von Pagefil.rns Dieses File wird nach Abschluss
     des Pagelayout in Sp2Unit zur�ckgeladen}
    Assign(ifile, 'PAGEFIL.RNS');
    LastFileName:=FExpand('PAGEFIL.RNS');
    rewrite(ifile);
    close(ifile);
  end;
  if not defpagesetup then begin
    LastFileName:=FExpand(TextRec(Infile).Name);
    reset(infile);
    readln(infile,inblock);
    if inblock='$$$RNSBUFFER$$$' then
      bufffile:=true
    else
      bufffile:=false;
    ReSet(infile);
  end;
  actfilename:= instring;
  FilFileToHeap(infile, actptr, startptr, lastptr, ok);
  GetFAttr(infile, attr);
  if ((attr and readonly) <> 0) then begin
    Mauszeigen;
    HlpHintFrame(grminx, grmaxy - 22, grmaxx, grmaxy+32);
    txtfnt.write(grminx + 16, grmaxy - 5,
       'Read only file, changes will not be saved!',
       getcolor,sz8x16,stnormal);
    txtfnt.write(grminx + 16, grmaxy + 15,
        'Press [Esc] to quit or any other key to continue ',
        getcolor,sz8x16,stnormal);
    ok:=False;
    While Not OK Do
      ok:=(ReadKey<>#27);
    While KeyPressed Do ReadKey;
    Mausdunkel;
  end;
  if ok then begin
    IniSetAllDACRegs(ThePalette);
    MarkInit;
    IniRefInit;
    ButInit;
    nextresponse:= NO_RESPONSE;
    FilFindPage(firstpage, result, actptr, startptr, lastptr);
    GcuCursorClear;
    GcuPatternRestore;
    PagDisplayPage(actptr, startptr, lastptr);
    i:=HntHideBase;
    j:=1000;
    IF DispSpec=2 Then Begin
      i:=i+HntDispSpec;
      j:=0;
    End;
    IF DispGrid=1 Then
      i:=i+HntDispGrid;
    IF DispHidLines=2 Then
      i:=i+HntDispHidLines;
    IF DispCurs=3 Then Begin
      i:=i+HntDispCurs;
      j:=0;
    End;
    IF i<>HntHideBase Then
      HlpHint(i,j);
    if (linestyles in actedit) then begin
      linenum := linestyletop;
    end else begin
      linenum:= TopMargin+1;
    end;
    PagCursorLeft(linenum, actposn, actpost);
    GcuCursorRestore;
    MausInstall;
    MausGrafik(1);
    MausBereich(0+9, GetMaxX+5, 0+9, GetMaxY);
    MausZeigen;

    while (Response <> ESCAPE) And Not
         ((Response=SPECIALKEY) And (Keyresponse=#85)) do begin
      if not showmenus then begin
        PagShowCurPosDistances(Linenum,ActPosn,ActPost,0);
      end;
      if nextresponse = no_response then begin
        Get_Response(Response, Direction, KeyResponse, shiftp, ctrlp,
                     mausx, mausy, maustaste, mp, mausmenu);
      end else begin
        response:= nextresponse;
        keyresponse:= nextkey;
        nextresponse:= NO_RESPONSE;
        shiftp:= nextshift;
        ctrlp:= nextctrl;
      end;
      MausDunkel;
      IniRefInit;
      if Response = NO_RESPONSE then begin
        SavePat:=ComEdMaus(mausx, mausy-line2thick,
                  maustaste,
                  linenum, actposn, actpost);
        ComMouseAssign(mausx, mausy, maustaste,
                       Response, KeyResponse, shiftp, ctrlp);
      end Else Begin
        GcuPatternRestore;
        SavePat:=True;
      End;
      case Response of
        ESCAPE     : ComEdEscape(linenum, actposn, actpost, actptr,
                                 startptr, lastptr, Response);
        ARROW      : ComEdArrow(Direction, linenum, actposn, actpost);
        RETURN     : ComEdReturn(linenum, actposn, actpost,
                                 shiftp, ctrlp);
        KEY        : ComEdKey(linenum, actposn, actpost, actptr,
                     startptr, lastptr, KeyResponse,shiftp,ctrlp);
        SPECIALKEY : ComEdSpecial(linenum, actposn, actpost, actptr,
                     startptr, lastptr,
                     KeyResponse, shiftp, ctrlp);
      end; { case Response of }
      PagRefreshPage(refxmin, refymin, refxmax, refymax+3); {+3 ###, wegen Refresh nach F5 - Esc}
      IF SavePat Then
        GcuCursorRestore;
      SavePat:=True;
      if mausform <> 1 then begin
        MausGrafik(1);
        MausBereich(0+9, GetMaxX+5, 0+9, GetMaxY);
      end;
      MausZeigen;
    end; { while Response <> ESCAPE do }
    IF Response = ESCAPE Then
      FileChanged:=2;
    FilSavePage(1, PageLength, actptr, startptr, lastptr);
    Mausdunkel;
    soundattr:=soundattr and not saRhythm;
    if defpagesetup then begin
      LastFileName:=FExpand(TextRec(infile).Name);
      rewrite(infile);
      FilHeapToFile(infile, actptr, startptr, lastptr, true, true, true);
    end else if EdiSavePossible(actfilename) Then Begin
      IF FileChanged=2 Then Begin
        FileChanged:=0;
        FileMode:=2;
        {$I-}
        ReWrite(InFile);
        {$I+}
        IF IOResult=0 then begin
          if bufffile then begin
            WriteLn(infile,'$$$RNSBUFFER$$$');
            WriteLn(infile,'    -1    -1    -1    -1    -1    -1    -1');

            FilHeapToFile(infile, actptr, startptr, lastptr, true, true, false);
            FilCutBlockFile(FExpand(TextRec(infile).Name));
          end else begin
            FilHeapToFile(infile, actptr, startptr, lastptr, true, true, true)
          end;
        end Else begin
          GetFAttr(infile,attr);
          if attr and ReadOnly<>0 then
            HlpHint(HntReadOnly,HintWaitEsc)
          else
            HlpHint(HntFileAccesDenied,HintWaitEsc);
        end;
      End;
    end Else Begin
      HlpHintFrame(grminx, grmaxy - 48, grmaxx, grmaxy);
      txtfnt.write(grminx + 20, grmaxy - 32,
         'Demoversion: not saved',
         getcolor,sz8x16,stnormal);
      txtfnt.write(grminx + 20, grmaxy - 16,
         'Press any key to continue',
         getcolor,sz8x16,stnormal);
      XClearKbd;
      Repeat Until KeyPressed;
      XClearKbd;
    End;
    FilBufClear;
    MarkInit;
  end;
  {$IFDEF DEMO}
    EdiCopyFile('DEMODIR\TESTFILE.RNS','DEMODIR\DEMOTEST.PRE');
    SetCRCFileEntry('DEMODIR\DEMOTEST.PRE',GetCRC('DEMODIR\DEMOTEST.PRE'))
  {$ENDIF};
  Release(heapmark);
  Mausdunkel;
end;
Function EdiSavePossible(fn : String) : Boolean;
Begin
  EdiSavePossible:={$IFNDEF DEMO}((IniFileExist('imie.rns')) and TitVerify) Or{$ENDIF}(pos('TESTFILE.RNS',fn)<>0);
End;
end.
