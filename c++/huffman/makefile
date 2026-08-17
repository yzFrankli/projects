

## Makefile flags
MAKEFLAGS += -L

CXX 		= clang++
CXXFLAGS 	= -g3 -Wall -Wextra -Wpedantic -Wshadow
LDFLAGS 	= -g3


## rule for phaseOne.o
phaseOne.o: phaseOne.cpp phaseOne.h main.o HuffmanCoder.o

## rule for phaseOne
phaseOne: phaseOne.cpp phaseOne.h
	${CXX} ${CXXFLAGS} -o $@ $^

## rules for main.cpp
main.o: main.cpp
	${CXX} ${LDFLAGS} -c main.cpp

## rule for HuffmanCoder.o
HuffmanCoder.o: HuffmanCoder.cpp HuffmanCoder.h
	${CXX} ${CXXFLAGS} -c HuffmanCoder.cpp


## cleanup after
clean: 
	rm *.o *~ a.out