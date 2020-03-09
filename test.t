@*=
@includes

auto main() -> int
{
	@init_tester
	@test_cases
	@print_tester_results

	system("PAUSE");
	return 0;
}

@includes=
#include "test_utils.h"

@init_tester=
Test test;

@print_tester_results=
test.showResults();


@includes+=
#include <iostream>
#include "parser.h"

@test_cases=
{
Parser parser;
auto r = parser.process("1+1");
test.assert_eq("1+1", r->eval(), 2.f);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("2-3");
test.assert_eq("2-3", r->eval(), -1.f);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("4*3");
test.assert_eq("4*3", r->eval(), 12.f);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("7/4");
test.assert_eq("7/4", r->eval(), 1.75f);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("2*(2+3)");
test.assert_eq("2*(2+3)", r->eval(), 10.f);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("3/(2+1)");
test.assert_eq("2*(2-1)", r->eval(), 1.f);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("3*(-2)");
test.assert_eq("3*(-2)", r->eval(), -6.f);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("(2+2)*(2+9)");
test.assert_eq("(2+2)*(2+9)", r->eval(), 44.f);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("cos(0)");
test.assert_eq("cos(0)", r->eval(), 1.f);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("cos(0)*sin(0)");
test.assert_eq("cos(0)", r->eval(), 0.f);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("cos(0");
test.assert_null("cos(0", r);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("cos(0)*");
test.assert_null("cos(0)*", r);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("*cos(0)");
test.assert_null("*cos(0)", r);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("/cos(0)");
test.assert_null("/cos(0)", r);
}

@test_cases+=
{
Parser parser;
auto a = parser.getSymbol("a");
*a = 3.f;
auto r = parser.process("a*2");
test.assert_eq("a*2 (where a = 3)", r->eval(), 6.f);
}

@test_cases+=
{
Parser parser;
auto a = parser.getSymbol("a");
*a = 4.f;
auto r = parser.process("a/2");
test.assert_eq("a/2 (where a = 4)", r->eval(), 2.f);
}

@test_cases+=
{
Parser parser;
auto a = parser.getSymbol("a");
*a = 4.f;
auto r = parser.process("a^2");
test.assert_eq("a^2 (where a = 4)", r->eval(), 16.f);
}

@test_cases+=
{
Parser parser;
auto a = parser.getSymbol("a");
*a = 4.f;
auto b = parser.getSymbol("b");
*b = 3.f;
auto r = parser.process("a^2*b");
test.assert_eq("a^2*b (where a = 4, b=3)", r->eval(), 48.f);
}
