program upgrade(input, output);

uses
     menutyp,
     initsc,
     crt;

Var parfile: file of integer;
    c: char;
    i, j, k: integer;

begin
   assign(parfile,paramstr(1));
   reset(parfile);
   for c:='a' to 'z' do
   begin
      for i:=1 to numofpar do
      begin
         for j:= 1 to 3 do
         begin
            read(parfile,sympar[c,i,j]);
         end;
         sympar[c,i,4]:= 440;
         sympar[c,i,5]:= 200;
      end;
   end;
   close(parfile);

   rewrite(parfile);
   for c:= 'a' to 'z' do
   begin
      for i:= 1 to numofpar do
      begin
         for j:= 1 to 5 do
         begin
            write(parfile,sympar[c,i, j]);
         end;
      end;
   end;
   close(parfile);
   writeln('Upgrade completed for file: ', paramstr(1));


end.
