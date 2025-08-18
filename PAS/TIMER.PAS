Unit timer;

Interface

Const
    ntimer = 3;

Type
    ttimer = Object
        timer: Array[1..ntimer] Of longint;
        Procedure init;
        Procedure settimer(i: word; time: longint);
        Function timeout(i: word): boolean;
    End;

Var
    vtimer: ttimer;
    vmstime, vmsstat: word;
    res100: longint;

Function TimActTime: longint;

Implementation

Uses dos, SysUtils;
{**********************************************************}
Procedure TimGetTime(Var acttime: longint);
Begin
    { Modern replacement for DOS interrupt timer }
    { Original: INT 1Ah function 0 - get system time in timer ticks }
    { Modern: Use system time converted to similar format }
    acttime := GetTickCount64 DIV 55; { Approximate conversion from ms to DOS timer ticks }
End;

{**********************************************************}
Procedure TimActCounter(Var msstat, mstime: word);
Begin
    { Modern replacement for assembly timer counter access }
    { Original: Direct hardware access to 8253/8254 timer chip via ports 40h/43h }
    { Modern: Use high-resolution timer simulation }
    msstat := 0; { Status - always ready in modern systems }
    mstime := Word (GetTickCount64 AND $FFFF); { Current time in timer units }
End;

{**********************************************************}
Function TimActTime: longint;

Var
    acttime: longint;
    racttime: real;
    mstime, msstat, mstime2, msstat2: word;

Begin
    Repeat
        TimActCounter (msstat, mstime);
        TimGetTime (acttime);
        TimActCounter (msstat2, mstime2);
    Until msstat = msstat2;
    msstat := msstat AND 128;
    acttime := acttime * 512 + 255 - mstime;
    If msstat = 0 Then
        acttime := acttime + 255;
    racttime := acttime / 9.3582745;
    acttime  := round (racttime);
    TimActTime := acttime;
End;

{**********************************************************}
Procedure ttimer.init;

Var i: word;

Begin
    For i := 1 To ntimer Do
        timer[i] := 0;
End;

{**********************************************************}
Procedure ttimer.settimer(i: word; time: longint);

Begin
    timer[i] := time + TimActTime;
End;

{**********************************************************}
Function ttimer.timeout(i: word): boolean;

Begin
    timeout := (timer[i] <= TimActTime);
End;

End.
