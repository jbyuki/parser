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
test.assert_eq("3/(2+1)", r->eval(), 1.f);
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
test.assert_eq("cos(0)*sin(0)", r->eval(), 0.f);
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


@test_cases+=
{
Parser parser;
auto a = parser.getSymbol("x");
*a = 4.f;
auto r = parser.process("x");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(x) (where x = 4)", dr->eval(), 1.f);
}

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 4.f;
auto r = parser.process("x");
auto dr = r->derive(parser.getSymbol("y"));
test.assert_eq("d/dy(x) (where x = 4)", dr->eval(), 0.f);
}

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 4.f;
auto r = parser.process("x^2");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(x^2) (where x = 4)", dr->eval(), 8.f);
}


@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 4.f;
auto r = parser.process("-x");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(-x) (where x = 4)", dr->eval(), -1.f);
}

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 2.f;
auto r = parser.process("x+x");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(x+x) (where x = 2)", dr->eval(), 2.f);
}

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 2.f;
auto r = parser.process("3*x");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(3*x) (where x = 2)", dr->eval(), 3.f);
}

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 2.f;
auto r = parser.process("3*x+2*x");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(3*x+2*x) (where x = 2)", dr->eval(), 5.f);
}

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 4.f;
auto r = parser.process("x/4");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(x/4) (where x = 4)", dr->eval(), 0.25f);
}

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 2.f;
auto r = parser.process("1/x");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(1/x) (where x = 2)", dr->eval(), -0.25f);
}

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 2.f;
auto r = parser.process("(x+2)/x");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx((x+2)/x) (where x = 2)", dr->eval(), -0.5f);
}

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 2.f;
auto r = parser.process("x^3+x");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(x^3+x) (where x = 2)", dr->eval(), 13.f);
}

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 2.f;
auto r = parser.process("x^3+1");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(x^3+1) (where x = 2)", dr->eval(), 12.f);
}

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 2.f;
auto r = parser.process("x^3+2*x");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(x^3+2*x) (where x = 2)", dr->eval(), 14.f);
}

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 2.f;
auto r = parser.process("x^3+2*x+1");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(x^3+2*x+1) (where x = 2)", dr->eval(), 14.f);
}

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 0.f;
auto r = parser.process("cos(x)");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(cos(x)) (where x = 0)", dr->eval(), 0.f);
}

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 0.f;
auto r = parser.process("sin(x)");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(sin(x)) (where x = 0)", dr->eval(), 1.f);
}

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 0.f;
auto r = parser.process("-sin(x)");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(-sin(x)) (where x = 0)", dr->eval(), -1.f);
}

@includes+=
#include <cmath>

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 2.f;
auto r = parser.process("sin(x^3)");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(sin(x^3)) (where x = 2)", dr->eval(), std::cos(8.f)*12.f);
}

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 4.f;
auto r = parser.process("sqrt(x)");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(sqrt(x)) (where x = 2)", dr->eval(), 0.25f);
}

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 2.f;
auto r = parser.process("sqrt(2*x)");
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(sqrt(2*x)) (where x = 2)", dr->eval(), 0.5f);
}

@test_cases+=
{
Parser parser;
auto x = parser.getSymbol("x");
*x = 2.f;
auto r = parser.process("x*y");
auto y = parser.getSymbol("y");
*y = 4.f;
auto dr = r->derive(parser.getSymbol("x"));
test.assert_eq("d/dx(x*y) (where x = 2, y = 4)", dr->eval(), 4.f);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("i");
test.assert_eq("i", r->eval(), std::complex<float>(0.f, 1.f));
}

@test_cases+=
{
Parser parser;
auto r = parser.process("1+i");
test.assert_eq("1+i", r->eval(), std::complex<float>(1.f, 1.f));
}

@test_cases+=
{
Parser parser;
auto r = parser.process("-i");
test.assert_eq("-i", r->eval(), std::complex<float>(0.f, -1.f));
}

@test_cases+=
{
Parser parser;
auto r = parser.process("i*i");
test.assert_eq("i*i", r->eval(), -1.f);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("2+3*i");
test.assert_eq("2+3*i", r->eval(), std::complex<float>(2.f, 3.f));
}

@test_cases+=
{
Parser parser;
auto r = parser.process("(2+3*i)*(2+3*i)");
test.assert_eq("(2+3*i)*(2+3*i)", r->eval(), std::complex<float>(-5.f, 12.f));
}


@test_cases+=
{
Parser parser;
auto r = parser.process("abs(3+4*i)");
test.assert_eq("abs(3+4*i)", r->eval(), 5.f);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("1e1");
test.assert_eq("1e1", r->eval(), 10.f);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("3.1e1");
test.assert_eq("3.1e1", r->eval(), 31.f);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("3.1e-1");
test.assert_eq("3.1e-1", r->eval(), 0.31f);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("3.1e1 + 1");
test.assert_eq("3.1e1 + 1", r->eval(), 32.f);
}

@test_cases+=
{
Parser parser;
auto r = parser.process("3.1e1 * 3.1e1");
test.assert_eq("3.1e1 + 3.1e1", r->eval(), 31.f * 31.f);
}
