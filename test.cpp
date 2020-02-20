#include <iostream>
#include "parser.h"


auto main() -> int
{
	Parser parser;
	
	auto exp = parser.process("sin(1)*sin(1)");
	std::cout << exp->eval() << std::endl;

	system("PAUSE");
	return 0;
}

