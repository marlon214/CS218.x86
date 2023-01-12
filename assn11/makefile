# CS 218 Assignment #11
# Simple make file for asst #11

OBJS	= makeThumb.o a11procs.o
ASM	= yasm -g dwarf2 -f elf64
CC	= g++ -g -std=c++11 

all: makeThumb

makeThumb.o: makeThumb.cpp
	$(CC) -c makeThumb.cpp

a11procs.o: a11procs.asm 
	$(ASM) a11procs.asm -l a11procs.lst

makeThumb: $(OBJS)
	$(CC) -no-pie -o makeThumb $(OBJS)

# -----
# clean by removing object files.

clean:
	rm  $(OBJS)
	rm  a11procs.lst
