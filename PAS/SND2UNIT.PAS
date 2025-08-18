Unit Snd2Unit;

Interface

Type TPlayRNS = Object
        Constructor Init;
        Destructor Done; Virtual;
        Procedure Play(s: string; x0, y0, x1: integer); Virtual;
        Procedure Stop; Virtual;
        Procedure Pause; Virtual;
        Procedure Continue; Virtual;
        Function Playing: boolean; Virtual;
        Function Pos: integer; Virtual;
    End;

Implementation

Uses TimerUnit;

End.
