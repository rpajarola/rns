ifeq ($(OS),Windows_NT) 
    ACT_OS := Windows
else
    ACT_OS := $(shell sh -c 'uname 2>/dev/null || echo Unknown')
endif

ifeq ($(ACT_OS),Darwin) 
# MacPorts
LD_LIBS=-Fl/opt/local/lib -Fu../sdl2
# HomeBrew
#LD_LIBS=-Fl/opt/homebrew/lib -Fu../sdl2

DEBUG_PFLAGS=-gw
else
# SDL2 library is in default path
LD_LIBS=-Fu../sdl2

DEBUG_PFLAGS=-gw3
endif

#  -Mdelphi == enable Delphi Syntax
#  -gw == enable dwarf2 debugging information
#  -gw3 == enable dwarf3 debugging information
#  -bl == generate local symbol info
#  -vm6058 == disable warning about inline function not inlined
#  -Sew = halt on warnings (-Sen = halt on notes)
PFLAGS=-Sew -Mdelphi -bl -vm6058 $(DEBUG_PFLAGS)

SRC=graph.pas

all:
	fpc $(LD_LIBS) $(PFLAGS) -FEobj -Foobj $(SRC)

clean:
	-rm -f obj/*
