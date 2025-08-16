{$I RNS.H}
unit Xcrt;

interface

function XReadKey(var shiftp, ctrlp: boolean): char;
Function XKeyPressed: Boolean;
Procedure XClearKbd;

implementation

uses Crt;

var lastkey: char;
    extended: boolean;

function XReadKey(var shiftp, ctrlp: boolean): char;
var ch: char;
begin
  // TODO: Replace with modern keyboard input API
  // For now, use basic CRT functions and assume no modifier keys
  shiftp := False;
  ctrlp := False;
  
  if extended then
  begin
    extended := False;
    XReadKey := lastkey;
  end
  else
  begin
    ch := ReadKey;
    // Check for extended keys (function keys, arrow keys, etc.)
    if ch = #0 then
    begin
      extended := True;
      lastkey := ReadKey; // Get the scan code
      XReadKey := #0;
    end
    else
      XReadKey := ch;
  end;
end;

Function XKeyPressed: Boolean;
begin
  // TODO: Replace with modern keyboard status API
  XKeyPressed := KeyPressed or extended;
end;

Procedure XClearKbd;
begin
  // TODO: Replace with modern keyboard buffer clear API
  // Clear any pending keys
  while KeyPressed do
    ReadKey;
  extended := False;
end;

begin
   extended := false;
end.
