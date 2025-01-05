all : task1A

task1A : task1A.o
	gcc -m32 -g -Wall -no-pie -o task1A task1A.o

task1A.o : task1A.s
	nasm -g -f elf -w+all -o task1A.o task1A.s

.PHONY : clean
clean :
	rm -f *.o task1A