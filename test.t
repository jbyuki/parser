@*=
@includes

auto main() -> int
{
	@test_parser

	system("PAUSE");
	return 0;
}

@includes=
#include <iostream>
#include "parser.h"

@test_parser=
Parser parser;

auto exp = parser.process("sin(1)*sin(1)");
std::cout << exp->eval() << std::endl;
