Unit Snd2Unit;

Interface

Type TPlayRNS = Object
       Constructor Init;
       Destructor Done;virtual;
       Procedure Play(s : string;x0,y0,x1 : integer);virtual;
       Procedure Stop;virtual;
       Procedure Pause;virtual;
       Procedure Continue;virtual;
       Function Playing : boolean;virtual;
       Function Pos : integer;virtual;
     End;

Implementation

Uses TimerUnit;

End.