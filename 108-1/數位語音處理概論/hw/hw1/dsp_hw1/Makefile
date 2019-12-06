.PHONY: all clean

LDFLAGS+=-lm     # link to math library

TARGET=train test 

all: $(TARGET) 

train: src/train.cpp inc/hmm.h
	g++ -O3 src/train.cpp -o train

test: src/test.cpp inc/hmm.h
	g++ -O3 src/test.cpp -o test

clean:
	rm $(TARGET) 