########################################################################
#
#  Makefile for local stuff.
#
#  Set LOCAL_ROOT to the root of the local stuff tree.
#
########################################################################

PROGRAMS	= hd nth

CFLAGS          = -O2
CXXFLAGS        = -O2


all: 		$(PROGRAMS)

install: 	all
	cp $(PROGRAMS) ../bin/

clean:
	rm -f $(PROGRAMS)

hd: 		hd.c

nth:		nth.c

