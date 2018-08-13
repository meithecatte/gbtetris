.SUFFIXES:
.PHONY: all tools clean
.SECONDEXPANSION:
.PRECIOUS:
.SECONDARY:

all: tetris10.gb tetris11.gb
	md5sum -c roms.md5

tools: tools/scan_includes
tools/%: tools/%.c
	$(CC) -O3 $< -o $@

%.2bpp: %.png
	rgbgfx -d 2 -o $@ $<

%.1bpp: %.png
	rgbgfx -d 1 -o $@ $<

main10.o: main.asm $(shell tools/scan_includes main.asm)
	rgbasm -o main10.o main.asm

main11.o: main.asm $(shell tools/scan_includes main.asm)
	rgbasm -DINTERNATIONAL -o main11.o main.asm

tetris10.gb: main10.o
	rgblink -n tetris10.sym -m tetris10.map -tdp 255 -o $@ $<
	rgbfix -v -t TETRIS -n 0 -l 1 $@
	sort -o tetris10.sym tetris10.sym

tetris11.gb: main11.o
	rgblink -n tetris11.sym -m tetris11.map -tdp 255 -o $@ $<
	rgbfix -v -t TETRIS -n 1 -l 1 $@
	sort -o tetris11.sym tetris11.sym
clean:
	rm -f main10.o tetris10.gb tetris10.sym tetris10.map main11.o tetris11.gb tetris11.sym tetris11.map
	find . \( -iname '*.1bpp' -o -iname '*.2bpp' \) -exec rm {} +
