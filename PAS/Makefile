#  -Mdelphi == enable Delphi Syntax
#  -gw2 == enable dwarf2 debugging information
#  -vm6058 == disable warning about inline function not inlined
all:
	fpc -Mdelphi -gw2 -FEobj -Foobj -vm6058 rns.pas

clean:
	-rm -f obj/*
