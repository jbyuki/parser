all: parser.cpp parser.h test.cpp

parser.cpp: parser.t ; letangle.exe parser.t parser.cpp > parser.cpp
parser.h: parser.t ; letangle.exe parser.t parser.h > parser.h
test.cpp: test.t; letangle.exe test.t > test.cpp
