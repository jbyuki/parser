all: tokenizer.cpp tokenizer.h parser.cpp parser.h

tokenizer.cpp: tokenizer.t ; letangle.py tokenizer.t tokenizer.cpp > tokenizer.cpp
tokenizer.h: tokenizer.t ; letangle.py tokenizer.t tokenizer.h > tokenizer.h
parser.cpp: parser.t ; letangle.py parser.t parser.cpp > parser.cpp
parser.h: parser.t ; letangle.py parser.t parser.h > parser.h
