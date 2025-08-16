Unit Textfont;

Interface

Const sz8x8  = 0;    { Sizes }
      sz8x16 = 1;
      sz6x12 = 2;
      stNormal     = $00;
      stBold       = $01;
      stDouble     = $02;
      stItalic     = $04;
      stUndeline   = $08;
      stHigh       = $10;
      stLow        = $20;

Type TTextFont = array[0..2,1..4200] of char;
     PTextFontViewer = ^TTextFont;
     TTextFontViewer = Object
       Font : TTextFont;
       Constructor Init(Name : String);
       Destructor Done;Virtual;
       Procedure WriteChar(X,Y : Word;Ch : Char;Color : Byte;Size : Integer;
                           Style : Byte);Virtual;
       Procedure Write(X,Y : Word;St : String;Color : Byte;Size : Integer;
                       Style : Byte);
     End;

Implementation

Uses Graph;

Constructor TTextFontViewer.Init(Name : String);
var
  fnttab : array[0..2] of string[82];
  a,b    : integer;
  datei  : file of char;
  fs     : longint;
  ch     : char;
begin
  fnttab[0]:=name+'8x8.tft';
  fnttab[1]:=name+'8x16.tft';
  fnttab[2]:=name+'6x12.tft';
  for a := 0 to 2 do
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
    fs:=filesize(datei)-b;
    for b := 1 to fs do
    begin
      read(datei,ch);
      font[a,b]:= ch;
    end;
    close(datei);
  end;
end;

Destructor TTextFontViewer.Done;
Begin
End;

Procedure TTextFontViewer.WriteChar(X,Y : Word;Ch : Char;Color : Byte;Size : Integer;Style : Byte);
{ stNormal stBold stDouble stItalic stUndeline stHigh stLow }
var
  a,b,f,c,charstart,xmin,xmax,ymin,ymax  : integer;

begin
{  if (Style and stItalic)<>0 then x:=x+6;}
  if size=sz8x8  then begin
    dec(Y,9);
  end else if size=sz8x16 then begin
    dec(Y,9);
  end else if size=sz6x12 then begin
    dec(Y,7);
  end;
  charstart:=Byte(ch)*Byte(font[size,2])+3;
  xmin:=x+1;
  xmax:=x+Byte(font[size,1]);
  ymin:=y+1;
  ymax:=y+Byte(font[size,2]);
  for a := ymin to ymax do
  begin
{    if ((Style and stItalic)<>0) and ((a and 1)<>0) then dec(x);}
    c := 128;
    f:=Byte(font[size,charstart]);
    for b := xmin to xmax do begin
      if (f and c) <> 0 then Begin
        if (Style and stDouble)=0 then begin
          PutPixel(b,a,Color);
          if (Style and stBold)<>0 Then Begin
            PutPixel(b+1,a,Color);
            if (Style and stDouble)<>0 Then Begin
              PutPixel(b  ,a+1,Color);
              PutPixel(b+1,a+1,Color);
            End;
          End;
        End else begin
          PutPixel(2*b,2*a,Color);
          if (Style and stBold)<>0 Then Begin
            PutPixel(2*b+1,2*a,Color);
            if (Style and stDouble)<>0 Then Begin
              PutPixel(2*b  ,2*a+1,Color);
              PutPixel(2*b+1,2*a+1,Color);
            End;
          End;
        end;
      end;
      c := c shr 1;
    end;
    inc(charstart);
  end;
end;

Procedure TTextFontViewer.Write(X,Y : Word;St : String;Color : Byte;Size : Integer;Style : Byte);
var
  a,dx  : integer;
begin
  dx:=Byte(font[size,1]);
  if size=sz8x16 then
    inc(dx);
  if (style and stdouble)<>0 Then
    dx:=dx+Byte(font[size,1])-1;
  for a := 1 to length(St) do
  begin
    writechar(x,y,St[a],color,size,style);
    x := x + dx
  end;
end;


End.
