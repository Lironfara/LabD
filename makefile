all : task1A

task1A : task1A.o
	gcc -m32 -g -Wall -no-pie -o task1A task1A.o

task1A.o : task1A.asm
	nasm -g -f elf -w+all -o task1A.o task1A.asm

.PHONY : clean
clean :
	rm -f *.o task1A