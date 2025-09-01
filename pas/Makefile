#  -Mdelphi == enable Delphi Syntax
#  -gw3 == enable dwarf3 debugging information
#  -bl == generate local symbol info
#  -vm6058 == disable warning about inline function not inlined
#  -Sew = halt on warnings (-Sen = halt on notes)
#  -vw = show warnings
all:
	fpc -Fusdl2 -Sew -Mdelphi -gw3 -bl -FEobj -Foobj -vm6058 rns.pas

clean:
	-rm -f obj/*
