  {$M 65520,32768,655360} { Memory Sizes       }
  {$D Rhythmics 1.5 } { Description        }
{$IFDEF USER}
  {$D-}               { Debug information  }
  {$L-}               { Local Symbols      }
  {$Y-}               { Symbol information }
  {$R-}               { Range Check        }
  {$Q-}               { Overflow Check     }
{$ELSE}
  {$D+}               { Debug information  }
  {$L+}               { Local Symbols      }
  {$Y+}               { Symbol information }
  {$R+}               { Range Check        }
  {$Q+}               { Overflow Check     }
{$ENDIF}
  {$S+}               { Stack Check        }
  {$I+}               { IO-Check           }
  {$A+}               { Word align Data    }
  {$G+}               { 286 Code           }
  {$V-}               { Strict VAR Strings }
  {$B-}               { Boolean Eval       }
  {$T-}               { Typed @            }
  {$P-}               { Open Params        }
  {$X+}               { Extended Syntax    }
  {$N-}               { Coprocessor        }
  {$E-}               { Emulation          }
