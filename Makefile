#Makefile 

.PHONY		: epkg help
.DEFAULT	: all

all		: epkg  

epkg		: epkg.pas args.pas unixtools.pas
		fpc epkg.pas

help		:
		@echo "usage:";
		@echo "make all         compile"
		@echo "make clean       clean"
		@echo "make help        help"
	
clean		:
		rm *.o
		rm *.ppu
		
install		:
		cp epkg /usr/bin/
uninstall	:
		rm /usr/bin/epkg
		