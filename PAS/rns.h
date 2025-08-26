  {$M 65520,32768,655360} { Memory Sizes       }
{$IFDEF USER}
  {$D-}               { Debug information  }
  {$R-}               { Range Check        }
  {$Q-}               { Overflow Check     }
{$ELSE}
  {$D+}               { Debug information  }
  {$R+}               { Range Check        }
  {$Q+}               { Overflow Check     }
{$ENDIF}
  {$S+}               { Stack Check        }
  {$I-}               { No IO-Check        }
  {$A+}               { Word align Data    }
  {$V-}               { Strict VAR Strings }
  {$B-}               { Boolean Eval       }
  {$T-}               { Typed @            }
  {$P-}               { Open Params        }
  {$X+}               { Extended Syntax    }
