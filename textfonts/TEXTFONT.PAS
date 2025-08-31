uses dos,crt,graph;

const
  farbe : integer = 14;{14=gelb, 12=schwarz im RNS}

var
  font   : array[1..3,1..4200] of char;
  ch     : char;
  a,x,y  : integer;
  uli    : string;

procedure graphinit;
var
  gd,gm  : integer;
begin
  gd := detect;
  initgraph (gd,gm,'');
end;

procedure graphclose;
begin
  closegraph;
end;

procedure loadfont (name : string);
var
  fnttab : array[1..3] of string[82];
  a,b    : integer;
  datei  : file of char;
  fs     : longint;
  ch     : char;
begin
  fnttab[1]:=name+'8x8.fnt';
  fnttab[2]:=name+'8x16.fnt';
  fnttab[3]:=name+'6x12.fnt';
  for a := 1 to 3 do
  begin
    assign (datei,fnttab[a]);
    reset (datei);
    ch := #0;
    b := 0;
    while (ch<>#26) do
    begin
      read (datei,ch);
      inc (b);
    end;
    fs:=filesize(datei)-b+1;
    for b := 1 to fs do
    begin
      read(datei,ch);
      font[a,b]:= ch;
    end;
    close(datei);
  end;
end;

procedure writecharslanted (x,y,size:integer;ch:char);
var
  a,b,f,c,d  : integer;
begin
  if size=8  then f := 1 else
  if size=16 then f := 2 else
  if size=12 then f := 3;
  d:=6;
  for a := 1 to ord(font[f,2]) do
  begin
    c := 128;
    if (odd(a)) then dec (d);
    for b := 1 to ord(font[f,1]) do
    begin
      if (ord(font[f,ord(ch)*ord(font[f,2])+2+a]) and c) <> 0 then
      putpixel (x+b+d,a+y,farbe);
      c := c div 2;
    end;
  end;
end;

procedure writechar (x,y,size:integer;ch:char);
var
  a,b,f,c  : integer;
begin
  if size=8  then f := 1 else
  if size=16 then f := 2 else
  if size=12 then f := 3;
  for a := 1 to ord(font[f,2]) do
  begin
    c := 128;
    for b := 1 to ord(font[f,1]) do
    begin
      if (ord(font[f,ord(ch)*ord(font[f,2])+2+a]) and c) <> 0 then
      putpixel (x+b,a+y,farbe);
      c := c div 2;
    end;
  end;
end;

procedure writechardouble (x,y,size:integer;ch:char);
var
  a,b,f,c  : integer;
begin
  if size=8  then f := 1 else
  if size=16 then f := 2 else
  if size=12 then f := 3;
  for a := 1 to ord(font[f,2]) do
  begin
    c := 128;
    for b := 1 to ord(font[f,1]) do
    begin
      if (ord(font[f,ord(ch)*ord(font[f,2])+2+a]) and c) <> 0 then
      putpixel (x+2*b,2*a+y,farbe);
      c := c div 2;
    end;
  end;
end;

procedure writechar2bold (x,y,size:integer;ch:char);
var
  a,b,f,c  : integer;
begin
  if size=8  then f := 1 else
  if size=16 then f := 2 else
  if size=12 then f := 3;
  for a := 1 to ord(font[f,2]) do
  begin
    c := 128;
    for b := 1 to ord(font[f,1]) do
    begin
      if (ord(font[f,ord(ch)*ord(font[f,2])+2+a]) and c) <> 0 then
      begin
        putpixel (x+2*b,2*a+y,farbe);
        putpixel (1+x+2*b,2*a+y,farbe);
        putpixel (x+2*b,1+2*a+y,farbe);
        putpixel (1+x+2*b,1+2*a+y,farbe);
      end;
      c := c div 2;
    end;
  end;
end;

procedure writecharbold (x,y,size:integer;ch:char);
var
  a,b,f,c  : integer;
begin
  if size=8  then f := 1 else
  if size=16 then f := 2 else
  if size=12 then f := 3;
  for a := 1 to ord(font[f,2]) do
  begin
    c := 128;
    for b := 1 to ord(font[f,1]) do
    begin
      if (ord(font[f,ord(ch)*ord(font[f,2])+2+a]) and c) <> 0 then
      begin
        putpixel (x+b,a+y,farbe);
        putpixel (x+b+1,a+y,farbe);
      end;
      c := c div 2;
    end;
  end;
end;

procedure writetextxy (x,y,size : integer; txt:string);
var
  a,f  : integer;
begin
  if size=8  then f := 1 else
  if size=16 then f := 2 else
  if size=12 then f := 3;
  for a := 1 to length(txt) do
  begin
    writechar(x,y,size,txt[a]);
    x := x + ord(font[f,1]);
  end;
end;

procedure writetextxyslanted (x,y,size : integer; txt:string);
var
  a,f  : integer;
begin
  if size=8  then f := 1 else
  if size=16 then f := 2 else
  if size=12 then f := 3;
  for a := 1 to length(txt) do
  begin
    writecharslanted(x,y,size,txt[a]);
    x := x + ord(font[f,1]);
  end;
end;

procedure writetextxybold (x,y,size : integer; txt:string);
var
  a,f  : integer;
begin
  if size=8  then f := 1 else
  if size=16 then f := 2 else
  if size=12 then f := 3;
  for a := 1 to length(txt) do
  begin
    writecharbold(x+a,y,size,txt[a]);
    x := x + ord(font[f,1]);
  end;
end;

procedure writetextxydouble (x,y,size : integer; txt:string);
var
  a,f  : integer;
begin
  if size=8  then f := 1 else
  if size=16 then f := 2 else
  if size=12 then f := 3;
  for a := 1 to length(txt) do
  begin
    writechardouble(x+(a-1)*size,y,size,txt[a]);
    x := x + ord(font[f,1]);
  end;
end;

procedure writetextxydoublebold (x,y,size : integer; txt:string);
var
  a,f  : integer;
begin
  if size=8  then f := 1 else
  if size=16 then f := 2 else
  if size=12 then f := 3;
  for a := 1 to length(txt) do
  begin
    writechar2bold(x+(a-1)*size,y,size,txt[a]);
    x := x + ord(font[f,1]);
  end;
end;


begin
  graphinit;
  loadfont('norm');
  clearviewport;
  writetextxy (40,50,12,'FONT 6x12: normal');
  writetextxy (40,70,8,'FONT 8x8: normal');
  writetextxy (40,90,16,'FONT 8x16: normal');
  writetextxybold (40,120,12,'FONT 6x12 bold');
  writetextxybold (40,140,8,'FONT 8x8 bold');
  writetextxybold (40,160,16,'FONT 8x16 bold');
  writetextxyslanted (40,190,12,'FONT 6x12 slanted');
  writetextxyslanted (40,210,8,'FONT 8x8 slanted');
  writetextxyslanted (40,230,16,'FONT 8x16 slanted');
  writetextxydouble (40,260,12,'FONT 6x12 double');
  writetextxydouble (40,290,8,'FONT 8x8 double');
  writetextxydouble (40,320,16,'FONT 6x16 double');
  writetextxydoublebold (40,360,12,'FONT 6x12 doublebold');
  writetextxydoublebold (40,390,8,'FONT 8x8 doublebold');
  writetextxydoublebold (40,420,16,'FONT 8x16 doublebold');

  writetextxy (300,150,16,'Taste 2 mal drÅcken fÅr mehr...');

  farbe:=1;
  uli := 'Was man damit alles machen kann...';
  ch:=#0;
  repeat
    x:=40;
    for a := 1 to length(uli) do
    begin
      writechar2bold(x,12,16,uli[a]);
      inc (farbe);
      if (uli[a]=' ') then dec (farbe);
      if (farbe mod 16 = 0) then inc (farbe);
      inc (x,16);
    end;
    if (keypressed) then ch := readkey
  until (ch<>#0);
  ch:=#0;
  repeat
    ch:=readkey;
  until (ch<>#0);
  clearviewport;
  farbe := 13;
  writetextxy (10,2,8,'Hallo Peo... GrÅ·e von Uli!!');
  inc (farbe);
  x := 10;
  y := 0;
  for a := 0 to 255 do
  begin
    x := x + 70;
    str (a:3,uli);
    uli := uli +' = '+chr(a);
    if (a mod 9)=0 then
    begin
      x := 10;
      y := y + 16;
    end;
    writetextxy (x,y,16,uli);
  end;
  uli:=chr(2)+' 1993/94/95 by Ulrich Franzke / Bochum / Germany';
  farbe:=10;
  writetextxy (332,468,12,uli);
  repeat
    ch:=readkey;
  until (ch<>#0);
  clearviewport;
  graphclose;
end.


