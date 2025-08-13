Unit musikunit;

interface

uses menutyp,
     graphmenu,
     crt,
     gcurunit,
     initsc,
     graph;

procedure MusGetPattern (var IN_STRING: STRINGLINE;
                                  X, Y: integer;
                             var  RESP: RESPONSE_TYPE;
                      var KEYRESPONSE : char);

procedure MusGetPromptedPattern (var IN_STRING: STRINGLINE;
                                       STRDESC: char;
                                  DESCX, DESCY: integer;
                                        PROMPT: STRING79;
                                      PRX, PRY: integer;
                                      prlength: integer;
                                     var  RESP: RESPONSE_TYPE;
                               var KeyResponse: char);


implementation

uses getunit,
     symbols,
     noteunit,
     pageunit,
     inout;

{****************************************************************}
procedure MusGetPromptedPattern (var IN_STRING: STRINGLINE;
                                       STRDESC: char;
                                  DESCX, DESCY: integer;
                                        PROMPT: STRING79;
                                      PRX, PRY: integer;
                                      prlength: integer;
                                     var  RESP: RESPONSE_TYPE;
                               var KeyResponse: char);

{Eingabe eines Musikpatterns}

VAR i : integer;
begin
  {schreibe den Prompt}
  IniExpand(prompt, prlength);
  Prompt:=Prompt+'   ';
  IniInversWrite(PRX,PRY,PROMPT,frLow+frSmallBar);
  {Nimmt die Eingabe vor}
  MusGetPattern(IN_STRING, DESCX, DESCY, RESP, KEYRESPONSE);
end;

{****************************************************************}
procedure MusGetPattern (var IN_STRING: STRINGLINE;
                                  X, Y: integer;
                             var  RESP: RESPONSE_TYPE;
                      var KEYRESPONSE : char);

var
  IN_CHAR, c: char;           { Zeicheneingabe von Tastatur }
  I  : integer;               { ZÑhler fÅr String-LÑnge }
  inblock: stringline;
  lineattr : lineattrtype;
  direction: movement;
  idummy, xfirst, linenum, actposn, actpost: integer;
  shiftp, ctrlp: boolean;
  mausx, mausy, maustaste, mp, mausmenu: word;
  OldDispCurs : byte;
begin
   ActPost:=0;
   OldDispCurs:=DispCurs;
   DispCurs:=1;
   {Bereite das Feld vor}
   yzeropos:= y + 40;
   page[0]:= 'N            1   0   120 1 %.';
   actnumber:= 4;
   resp:= key;
   while ((Resp<>Return) and (Resp <> Escape)) do begin
     if resp <> arrow then begin
       inblock:= page[0];
       GetNoteBlock(inblock, lineattr, 0);
       SetColor(12);
{       SetBkColor(7);}
       SetFillStyle(Solidfill,7);
       Bar(X,Y,grmaxX,y+71);
       Ini3DFrame(X,Y,grmaxX, y+71, 12,5, fr3D);
       GetDrawBlock(inblock, 0, lineattr, grminx, grmaxx, idummy);
       SetColor(12);
       ThinLine(x, yzeropos, GrMaxX);
       xfirst:= IniFirstBeatPos(lineattr) - IniDxValue(lineattr);
       Beat(xfirst, yzeropos, 12, false);
     end;
     linenum:= 0;
     if inblock = '.' then begin
       PagCursorLeft(linenum, actposn, actpost);
     end;
     GcuCursorRestore;
     PagShowCurPosDistances(Linenum,ActPosn,ActPost,0);

     { Himmiherrgottzackzefixmilecktsamoaschscheissglumsverreckts }
     IniSpacedText(gmaxx div (2*charwidth) - 3,{ Der letzte!}
                    gmaxy div charheight - 5,
                    '                    ',frLow);

     Get_Response(Resp, Direction, KeyResponse, shiftp, ctrlp,
                  mausx, mausy, maustaste, mp, mausmenu);
     GcuPatternRestore;
     case resp of
       key:
         NotEdNoteLine(linenum, actposn, KeyResponse);
       specialkey: begin
         i:= ord(keyresponse);
         case i of
           71 : begin{home: begin of line}
             actposn:=29;
             GcuMoveCursor(xfirst,GcyCoord);
           end;
           79 : begin{End: end of line}
             PagCursorRight(linenum, actposn, actpost);
           end;
           82 : begin{insert}
             NotInsNote(linenum, actposn);
           end;
           83 : begin{delete}
             if shiftp then
               NotDelToEOL(linenum,actposn)
             else
               NotDelNote(linenum, actposn);
           end;
           16..50 : begin{Alt-Character, wandeln in Bereich 128..153}
             c:= IniAltChar(KeyResponse);
             NotEdNoteLine(linenum, actposn, c);
           end;
         end; {case i of}
       end; { specialkey }
       arrow: begin
         case direction of
           LEFT : begin
             i:= gcxcoord - 1;
             GetNotePosX(i, actposn, linenum,
                         true, true);
           end; {LEFT}
           RIGHT: begin
             i:= gcxcoord + 1;
             GetNotePosX(i, actposn, linenum,
                         true, false);
           end; {RIGHT}
         end; { case Direction of }
       end; { arrow }
     end; {case resp of}
   end; {while}
   in_string:= page[0];
   GetNoteBlock(in_string, lineattr, 0);
   actposn:= length(in_string);
   if in_string[actposn] = '.' then
   begin
      repeat
         delete(in_string, actposn, 1);
         actposn:= actposn - 1;
      until not IniNumChar(in_string[actposn]);
   end;
   if in_string = '.' then in_string:='';
   DispCurs:=OldDispCurs;
end;

end.