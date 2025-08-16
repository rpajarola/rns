unit timer;

interface

const
   ntimer = 3;

type
   ttimer = object
      timer: array[1..ntimer] of longint;
      procedure init;
      procedure settimer(i: word; time: longint);
      function timeout(i: word): boolean;
   end;

var
   vtimer: ttimer;
   vmstime, vmsstat: word;
   res100: longint;

Function TimActTime: longint;

implementation

uses dos, SysUtils;
{**********************************************************}
Procedure TimGetTime(var acttime: longint);
begin
   { Modern replacement for DOS interrupt timer }
   { Original: INT 1Ah function 0 - get system time in timer ticks }
   { Modern: Use system time converted to similar format }
   acttime := GetTickCount64 div 55; { Approximate conversion from ms to DOS timer ticks }
end;

{**********************************************************}
Procedure TimActCounter(var msstat, mstime: word);
begin
   { Modern replacement for assembly timer counter access }
   { Original: Direct hardware access to 8253/8254 timer chip via ports 40h/43h }
   { Modern: Use high-resolution timer simulation }
   msstat := 0; { Status - always ready in modern systems }
   mstime := Word(GetTickCount64 and $FFFF); { Current time in timer units }
end;

{**********************************************************}
Function TimActTime: longint;

var
    acttime: longint;
    racttime: real;
    mstime, msstat, mstime2, msstat2: word;

begin
   repeat
      TimActCounter(msstat, mstime);
      TimGetTime(acttime);
      TimActCounter(msstat2, mstime2);
   until msstat = msstat2;
   msstat:= msstat and 128;
   acttime:= acttime*512 + 255 - mstime;
   if msstat = 0 then
   begin
     acttime:= acttime + 255;
   end;
   racttime:= acttime/9.3582745;
   acttime:= round(racttime);
   TimActTime:= acttime;
end;

{**********************************************************}
procedure ttimer.init;

var i: word;

begin
   for i:= 1 to ntimer do
   begin
      timer[i]:= 0;
   end;
end;

{**********************************************************}
procedure ttimer.settimer(i: word; time: longint);

begin
   timer[i]:= time + TimActTime;
end;

{**********************************************************}
function ttimer.timeout(i: word): boolean;

begin
   timeout:= (timer[i] <= TimActTime);
end;

end.




