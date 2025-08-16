Program upgrade;

uses
   dos,
   crt,
   menutyp,
   dispmenu,
   grinout,
   inout,
   graphmenu,
   initsc,
   userint;

const topstartx = 2;
      topstarty = 1;
      topendx = 22;
      topendy = 24;
      substartx = 24;
      substarty = 1;
      subendx = 79;
      subendy = 24;

var
    instring: string79;
    inblock: string;
    infile, outfile: text;
    c: char;
    linenum: integer;
    resp : response_type;
    dir : movement;
    KeyResp : Char;
    i,j,k,l : integer;
    ok : boolean;
    oldstring: string79;

begin
   instring:= '';
   datadir:= '';
   linenum:= 1;
   clrscr;
   oldstring:= instring;
   c:= chr(0);
   Display_Frame(substartx, substarty, subendx, subendy, true, true);
   Put_String(substartx, substarty + 1, 'Directory', 0);
   Put_String(substartx, subendy - 1,
              ' Press [Enter] to keep last choice                     ', 1);
   instring:= oldstring;
   GrGet_Prompted_String(datadir, fieldlength, '>',
                         substartx + 29 + fieldlength, substarty + 3,
                         substartx + 28,
                         'Enter Name of Directory',
                         substartx + 1, substarty + 3,
                         subendx - substartx - 2*fieldlength - 3,
                         resp, dir, Keyresp, true);
   UseFileName(instring, c);
   if c <> chr(27) then
   begin
      assign(infile, datadir + '\' + instring);
      LastFileName:=FExpand(datadir+'\'+Instring);
      reset(infile);
      assign(outfile, datadir + '\' + 'buffile.fil');
      LastFileName:=FExpand(datadir+'\'+'BUFFILE.FIL');
      rewrite(outfile);
      while not eof(infile) do
      begin
         LastFileName:=FExpand(datadir+'\'+Instring);
         readln(infile, inblock);
         GotoXY(2, 10);
         write('processing line ',linenum:4);
         linenum:= linenum + 1;
         if inblock[1] = 'T' then
         begin
            l:= length(inblock);
            for i:= 10 to l do
            begin
               if ((ord(inblock[i]) > 128) and (ord(inblock[i]) < 140)) then
               begin
                  inblock[i]:= chr(ord(inblock[i]) + 100);
               end;
            end;
         end;
         LastFileName:=FExpand(datadir+'\'+'BUFFILE.FIL');
         writeln(outfile, inblock);
      end;
      LastFileName:=FExpand(datadir+'\'+Instring);
      close(infile);
      erase(infile);
      LastFileName:=FExpand(datadir+'\'+'BUFFILE.FIL');
      close(outfile);
      rename(outfile, datadir + '\' + instring);
   end;
end.

