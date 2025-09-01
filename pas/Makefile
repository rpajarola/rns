ifeq ($(OS),Windows_NT) 
    ACT_OS := Windows
else
    ACT_OS := $(shell sh -c 'uname 2>/dev/null || echo Unknown')
endif

#  -Mdelphi == enable Delphi Syntax
#  -gw3 == enable dwarf3 debugging information
#  -bl == generate local symbol info
#  -vm6058 == disable warning about inline function not inlined
#  -Sew = halt on warnings (-Sen = halt on notes)
PFLAGS=-Sew -Mdelphi -gw -bl -vm6058

ifeq ($(ACT_OS),Darwin) 
# MacPorts
LD_LIBS=-Fl/opt/local/lib -Fusdl2

# HomeBrew
#LD_LIBS=-Fl/opt/homebrew/lib -Fusdl2

endif

SRC=rns.pas

all:
	fpc $(LD_LIBS) $(PFLAGS) -FEobj -Foobj $(SRC)

clean:
	-rm -f obj/*
