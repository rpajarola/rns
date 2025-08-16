{$I RNS.H}
Unit UserExit;

Interface

Var LastFileName : String;

Implementation
Uses Crt,
     HelpUnit,
     Graph,
     InitSc;
var
    OrgExitProc : Pointer;
    WhereY: Byte Absolute $0000:$0451;
    WhereX: Byte Absolute $0000:$0450;
function HexWord(w: Word) : String;
const
  hexChars: array [0..$F] of Char =
    '0123456789ABCDEF';
BEGIN
   HexWord:=(hexChars[Hi(w) shr 4]+
        hexChars[Hi(w) and $F]+
        hexChars[Lo(w) shr 4]+
        hexChars[Lo(w) and $F]);
END;
Function S(V : Byte) : String;
Var X : String;
Begin
  Str(V,X);
  S:=X;
End;

Function Exitcode2Msg(N : Integer) : String;
var s : String;
Begin
  case N of
      0 : s:=(' Normal Program termination');
      1 : s:=(' Invalid function number');
      2 : s:=(' File '+lastfilename+' missing');
      3 : s:=(' Path not found('+lastfilename+')');
      4 : s:=(' Too many open files('+lastfilename+')');
      5 : s:=(' File '+lastfilename+' access denied');
      6 : s:=(' Invalid file handle('+lastfilename+')');
     12 : s:=(' Invalid file access code('+lastfilename+')');
     15 : s:=(' Invalid '+lastfilename+' drive number');
     16 : s:=(' Cannot remove current directory('+lastfilename+')');
     17 : s:=(' Cannot rename across drives');
     18 : s:=(' No more files');
     24 : s:=(' Graphics driver error');
    100 : s:=(' Disk read error,'+#13+' Run CHKDSK/F to correct error');
    101 : s:=(' Disk write error,'+#13+' Run CHKDSK/F to correct error');
    102 : s:=(' File not assigned '+lastfilename);
    103 : s:=(' File '+lastfilename+' not open');
    104 : s:=(' File '+lastfilename+' not open for input');
    105 : s:=(' File '+lastfilename+' not open for output');
    106 : s:=(' Invalid numeric format');
    150 : s:=(' Disk is write-protected,'+#13+' Remove write-protection');
    151 : s:=(' Bad drive request struct length');
    152 : s:=(' Drive not ready,'+#13+' Insert disk');
    154 : s:=(' CRC error in data');
    156 : s:=(' Disk seek error');
    157 : s:=(' Unknown media type');
    158 : s:=(' Sector Not Found');
    159 : s:=(' Printer out of paper');
    160 : s:=(' Device write fault');
    161 : s:=(' Device read fault');
    162 : s:=(' Hardware failure');
    200 : s:=(' Division by zero');
    201 : s:=(' Range check error');
    202 : s:=(' Stack overflow error');
    203 : s:=(' Heap overflow error');
    204 : s:=(' Invalid pointer operation');
    205 : s:=(' Floating point overflow');
    206 : s:=(' Floating point underflow');
    207 : s:=(' Invalid floating point operation');
    208 : s:=(' Overlay manager not installed');
    209 : s:=(' Overlay file read error');
    210 : s:=(' Object not initialized');
    211 : s:=(' Call to abstract method');
    212 : s:=(' Stream registration error');
    213 : s:=(' Collection index out of range');
    214 : s:=(' Collection overflow error');
    215 : s:=(' Arithmetic overflow error');
    216 : s:=(' General Protection fault');
    217 : s:=(' Memory allocation error');
    Else
          s:=(' Unknown error');
  end;{ case}
  ExitCode2MSg:=s;
End;

Function ErrorAddress(N : Integer;P : Pointer) : String;
Var st : String;
Begin
  if st<>'' then
    case ExitCode of
            1..99:  st:=st+'DOS';
         100..149:  st:=st+'Input/Output';
         150..199:  st:=st+'critical';
         200..255:  st:=st+'non mascable';
    end;
  ErrorAddress:=St;
End;
procedure DebugExit;Far;
Begin
  {if erroraddr=nil then begin}
    ExitProc:=OrgExitProc;
    CloseGraph;
    HercGraphicsMode := false;
    IniShowCursor;
    exit;
  end;
{  if HlpAsk('Your program makes shit! '+ExitCode2Msg(ExitCode),
            ErrorAddress(ExitCode,ErrorAddr),false) Then begin

  end;
  ExitProc:=OrgExitProc;
  CloseGraph;
  HercGraphicsMode := false;
  IniShowCursor;
End;}
procedure NewExit;FAR;
Var St : String[80];
begin
   Asm
     MOV AX,0003
     INT 10h
   End;
   IF ExitCode=217 Then Begin { Wrong dir }
     Writeln;
     Writeln;
     Writeln;
     Writeln;
     Writeln;
     Writeln;
     Writeln;
     Writeln;
     Writeln;
     Writeln;
     WriteLn('                                                                               ');
     WriteLn('     Cannot find file COLORS.RNS                                               ');
     WriteLn('     Maybe you are in the wrong directory                                      ');
     WriteLn('     Change to your Rhythmics directory and try again                          ');
     WriteLn('                                                                               ');
     ExitCode:=0;
     ErrorAddr:=Nil;
     Exit;
   End;
   TextBackGround(0);
   ClrScr;
   TextColor(15);
   TextBackGround(4);
   IF (Exitcode=0) Or (ErrorAddr=Nil) Then
     Exit;
   WriteLn;
   st:=ExitCode2Msg(ExitCode);
   if exitcode<>0 then Begin
      write(St);
   End;
   st:=ErrorAddress(ExitCode,ErrorAddr);
   While St[0]<#80 Do Begin
     st:=St+' ';
     IF St[0]<#80 Then
       st:=' '+St;
   End;
   write(St);
   While WhereX<>0 Do
      Write(' ');
   ExitProc:=@OrgExitProc;
   erroraddr:=NIL;
   halt(exitCode);
end;

begin
   OrgExitProc := ExitProc;
   ExitProc    := @DebugExit;
   LastFileName:='';
end.
