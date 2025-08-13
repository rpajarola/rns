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

uses dos;
{**********************************************************}
Procedure TimGetTime(var acttime: longint);

var regs: registers;

begin
   regs.ah:= 0;
   Intr($1A, regs);
   acttime:= regs.cx;
   acttime:= acttime*65536 + regs.dx;
end;

{**********************************************************}
Procedure TimActCounter(var msstat, mstime: word); assembler;
asm
{   MOV AX, 0}
   XOR AX,AX
   MOV AL, 11000010b               ;{Counter latch and status vorbereiten}
   OUT 43h, AL                     ;{Control word absetzen}
   IN  AL, 40h                     ;{Status einlesen}
{   LES BX, MSSTAT
   MOV ES:[BX], AX                 ;}{Status speichern}
   MOV Word Ptr MSSTAT,AX
   IN  AL, 40h                     ;{Counter LSB einlesen}
   IN  AL, 40h                     ;{Counter MSB einlesen}
{   LES BX, MSTIME
   MOV ES:[BX], AX                 ;}{Counter speichern}
   MOV Word Ptr MSTIME,AX
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




