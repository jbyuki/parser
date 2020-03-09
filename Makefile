all: parser.cpp parser.h test.cpp test_utils.cpp test_utils.h

parser.cpp: parser.t ; letangle.exe parser.t parser.cpp > parser.cpp
parser.h: parser.t ; letangle.exe parser.t parser.h > parser.h
test_utils.cpp: test_utils.t ; letangle.exe test_utils.t test_utils.cpp > test_utils.cpp
test_utils.h: test_utils.t ; letangle.exe test_utils.t test_utils.h > test_utils.h
test.cpp: test.t; letangle.exe test.t > test.cpp
