.PHONY: clean main rebuild
.DEFAULT_GOAL := rebuild

main: out/main.o
	ld65 --target nes -o "out/main.nes" --dbgfile "out/main.dbg" "out/main.o"

out/main.o:
	ca65 --target nes "src/main.asm" -g -o "out/main.o"

clean:
	rm -f out/*.o \
	      out/*.nes \
	      out/*.dbg

rebuild:
	$(MAKE) clean
	$(MAKE) main
