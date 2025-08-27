#  -Mdelphi == enable Delphi Syntax
#  -gw3 == enable dwarf3 debugging information
#  -vm6058 == disable warning about inline function not inlined
all:
	fpc -Mdelphi -gw3 -FEobj -Foobj -vm6058 rns.pas

clean:
	-rm -f obj/*
