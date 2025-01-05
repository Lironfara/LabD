all: start main1A

start: start.o
	ld -m elf_i386 -o start start.o -lc -I/lib/ld-linux.so.2 -g

start.o: start.asm
	nasm -f elf32 -g -F dwarf start.asm -o start.o

main1A: main1A.o task1A.o
	ld -m elf_i386 -e main -o main1A main1A.o task1A.o -lc -I/lib/ld-linux.so.2 -g

main1A.o: main1A.asm
	nasm -f elf32 -g -F dwarf main1A.asm -o main1A.o

task1A.o: task1A.asm
	nasm -f elf32 -g -F dwarf task1A.asm -o task1A.o

clean:
	rm -f start.o start main1A.o task1A.o main1A