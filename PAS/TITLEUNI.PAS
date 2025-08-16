unit TitleUnit;

interface

uses symbols,
     initsc,
     textunit,
     graph,
     UserExit,
     Dos;

procedure TitGetText(linenum, startx : integer);
Function TitVerify: Boolean;

implementation

{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
procedure TitGetText(linenum, startx : integer);
begin
  if (linenum>=0) and (linenum<=pagelim) and (page[linenum,1] = 'T') then begin
    TexDrawLine(linenum, startx);
  end;
end;


{+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++}
Function TitVerify: Boolean;
var licfile: text;
    i, j: integer;
    nsum, ndiff, isum, idiff: integer;
    dummy: stringline;
begin
  assign(licfile,'imie.rns');
  LastFileName:=FExpand('IMIE.RNS');
  reset(licfile);
  readln(licfile, usrname);
  readln(licfile, usrfirstname);
  for i:= 1 to 4 do
    readln(licfile, dummy);
  readln(licfile, nsum);
  readln(licfile, ndiff);
  isum:= 22;
  idiff:= -17;
  j:= 1;
  IniLeadBlank(usrname);
  IniTrailBlank(usrname);
  for i:= 1 to length(usrname) do begin
    isum:= isum + ord(usrname[i]) + i - 1;
    idiff:= idiff + j*ord(usrname[i])*3;
    j:= -j;
  end;
  TitVerify:= ((isum = nsum) and (idiff = ndiff));
  close(licfile);
end;


end.
