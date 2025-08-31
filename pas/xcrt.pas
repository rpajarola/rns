{$I RNS.H}
Unit Xcrt;

Interface

Function XReadKey(Var shiftp, ctrlp: boolean): char;
Function XKeyPressed: Boolean;
Procedure XClearKbd;

Implementation

Uses
    Crt;

Var
    lastkey: char;
    extended: boolean;


Function XReadKey(Var shiftp, ctrlp: boolean): char;
Var
    ch: char;
Begin
    // TODO: Replace with modern keyboard input API
    // For now, use basic CRT functions and assume no modifier keys
    shiftp := False;
    ctrlp  := False;

    If extended Then
    Begin
        extended := False;
        XReadKey := lastkey;
    End
    Else
    Begin
        ch := ReadKey;
        // Check for extended keys (function keys, arrow keys, etc.)
        If ch = #0 Then
        Begin
            extended := True;
            lastkey  := ReadKey; // Get the scan code
            XReadKey := #0;
        End
        Else
            XReadKey := ch;
    End;
End;


Function XKeyPressed: Boolean;
Begin
    // TODO: Replace with modern keyboard status API
    XKeyPressed := KeyPressed OR extended;
End;


Procedure XClearKbd;
Begin
    // TODO: Replace with modern keyboard buffer clear API
    // Clear any pending keys
    While KeyPressed Do
        ReadKey;
    extended := False;
End;

Begin
    extended := false;
End.
