all : multi

multi : multi.o
	gcc -m32 -o multi multi.o

multi.o : multi.s
	nasm -f elf32 multi.s -o multi.o

.PHONY : clean
clean :
	rm -f *.o multi