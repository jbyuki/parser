all: parser.cpp parser.h

parser.cpp: parser.t ; letangle.py parser.t parser.cpp > parser.cpp
parser.h: parser.t ; letangle.py parser.t parser.h > parser.h
