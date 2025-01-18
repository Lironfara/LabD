all : multi

multi : multi.o
	gcc -m32 -g -Wall -no-pie -o multi multi.o

multi.o : multi.asm
	nasm -g -f elf -w+all -o multi.o multi.asm

.PHONY : clean
clean :
	rm -f *.o multi