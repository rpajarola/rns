Unit MousDrv2;

Interface

Implementation
Var OldExitProc : Pointer;
Procedure DoneMse;
Begin
End;

Procedure ExitMse;Far;
Begin
  DoneMse;
End;
Procedure InitMse;
Begin
  OldExitProc:=@ExitProc;
  ExitProc:=@ExitMse;
End;

Begin
  InitMse;
End.