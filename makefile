all: start

start: start.o
	ld -m elf_i386 -o start start.o -lc -I/lib/ld-linux.so.2 -g

start.o: start.asm
	nasm -f elf32 -g -F dwarf start.asm -o start.o

clean:
	rm -f start.o start
