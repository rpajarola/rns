program symdef(input, output);

type bit = 0..1;
     symboltyp = array[1..12, 1..12] of bit;

var symfile : file of symboltyp;
    i, j, k : integer;
    c : char;
    symarr  : array[97..122] of symboltyp;


begin
   assign(symfile,'symfile');
   rewrite(symfile);
   for i:= 97 to 122 do
      for j:= 1 to 12 do
	 for k:= 1 to 12 do
	 begin
	    symarr[i,j,k]:= 0;
	    if j = k then symarr[i,j,k]:= 1;
	 end;
   write(symfile,symarr);

end.

