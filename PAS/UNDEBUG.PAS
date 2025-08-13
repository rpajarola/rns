Unit UnDebug;

Interface
{$IFDEF UNDEBUG}
Procedure Int3;      Inline($CC);               { INT 3         }

Procedure SwitchMode;Inline($31/$C0/            { XOR  AX,AX    }
                            $8E/$C0/            { MOV  ES,AX    }
                            $E8/$0000/          { CALL $+3      }
                            $58/                { POP  AX       }
                            $05/$0022/          { ADD  AX,XXXX  }
                            $26/                { ES:           }
                            $A3/$0467/          { MOV [467h],AX }
                            $0E/                { PUSH CS       }
                            $8F/$06/$0469/      { POP  [0469h]  }
                            $B0/$14/{???}       { MOV  AL,14h   }
                            $E6/$70/            { OUT  70h,AL   }
                            $B0/$09/{?}         { MOV  AL,09h   }
                            $E6/$71/            { OUT  71h,AL   }
                            $FA/                { CLI           }
                            $F0/$01/$E0/        { SMSW AX       }
                            $34/$01/            { XOR  AL,01    }
                            $F0/$01/$F0/        { LMSW AX       }
                            $B0/$FE/            { MOV  AL,0FEh  }
                            $E6/$64);           { OUT  64h,AL   }

Procedure LockKbd;   Inline($E4/$21/            { IN   AL,21    }
                            $24/$FD/            { AND  AL,FD    }
                            $E6/$21);           { OUT  21,AL    }
Procedure UnLockKbd; Inline($E4/$21/            { IN   AL,21    }
                            $0C/$02/            { OR   AL,02    }
                            $E6/$21);           { OUT  21,AL    }
{$ELSE}
Procedure Int3;      Inline($90);               { NOP           }
Procedure SwitchMode;Inline($90);               { NOP           }
Procedure LockKbd;   Inline($90);               { NOP           }
Procedure UnLockKbd; Inline($90);               { NOP           }
{$ENDIF}

Implementation

End.