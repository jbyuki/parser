#include "test_utils.h"

#include <iostream>
#include "parser.h"

#include <cmath>


auto main() -> int
{
	Test test;
	
	{
	Parser parser;
	auto r = parser.process("1+1");
	test.assert_eq("1+1", r->eval(), 2.f);
	}
	
	{
	Parser parser;
	auto r = parser.process("2-3");
	test.assert_eq("2-3", r->eval(), -1.f);
	}
	
	{
	Parser parser;
	auto r = parser.process("4*3");
	test.assert_eq("4*3", r->eval(), 12.f);
	}
	
	{
	Parser parser;
	auto r = parser.process("7/4");
	test.assert_eq("7/4", r->eval(), 1.75f);
	}
	
	{
	Parser parser;
	auto r = parser.process("2*(2+3)");
	test.assert_eq("2*(2+3)", r->eval(), 10.f);
	}
	
	{
	Parser parser;
	auto r = parser.process("3/(2+1)");
	test.assert_eq("2*(2-1)", r->eval(), 1.f);
	}
	
	{
	Parser parser;
	auto r = parser.process("3*(-2)");
	test.assert_eq("3*(-2)", r->eval(), -6.f);
	}
	
	{
	Parser parser;
	auto r = parser.process("(2+2)*(2+9)");
	test.assert_eq("(2+2)*(2+9)", r->eval(), 44.f);
	}
	
	{
	Parser parser;
	auto r = parser.process("cos(0)");
	test.assert_eq("cos(0)", r->eval(), 1.f);
	}
	
	{
	Parser parser;
	auto r = parser.process("cos(0)*sin(0)");
	test.assert_eq("cos(0)", r->eval(), 0.f);
	}
	
	{
	Parser parser;
	auto r = parser.process("cos(0");
	test.assert_null("cos(0", r);
	}
	
	{
	Parser parser;
	auto r = parser.process("cos(0)*");
	test.assert_null("cos(0)*", r);
	}
	
	{
	Parser parser;
	auto r = parser.process("*cos(0)");
	test.assert_null("*cos(0)", r);
	}
	
	{
	Parser parser;
	auto r = parser.process("/cos(0)");
	test.assert_null("/cos(0)", r);
	}
	
	{
	Parser parser;
	auto a = parser.getSymbol("a");
	*a = 3.f;
	auto r = parser.process("a*2");
	test.assert_eq("a*2 (where a = 3)", r->eval(), 6.f);
	}
	
	{
	Parser parser;
	auto a = parser.getSymbol("a");
	*a = 4.f;
	auto r = parser.process("a/2");
	test.assert_eq("a/2 (where a = 4)", r->eval(), 2.f);
	}
	
	{
	Parser parser;
	auto a = parser.getSymbol("a");
	*a = 4.f;
	auto r = parser.process("a^2");
	test.assert_eq("a^2 (where a = 4)", r->eval(), 16.f);
	}
	
	{
	Parser parser;
	auto a = parser.getSymbol("a");
	*a = 4.f;
	auto b = parser.getSymbol("b");
	*b = 3.f;
	auto r = parser.process("a^2*b");
	test.assert_eq("a^2*b (where a = 4, b=3)", r->eval(), 48.f);
	}
	
	
	{
	Parser parser;
	auto a = parser.getSymbol("x");
	*a = 4.f;
	auto r = parser.process("x");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx(x) (where x = 4)", dr->eval(), 1.f);
	}
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 4.f;
	auto r = parser.process("x");
	auto dr = r->derive(parser.getSymbol("y"));
	test.assert_eq("d/dy(x) (where x = 4)", dr->eval(), 0.f);
	}
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 4.f;
	auto r = parser.process("x^2");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx(x^2) (where x = 4)", dr->eval(), 8.f);
	}
	
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 4.f;
	auto r = parser.process("-x");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx(-x) (where x = 4)", dr->eval(), -1.f);
	}
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 2.f;
	auto r = parser.process("x+x");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx(x+x) (where x = 2)", dr->eval(), 2.f);
	}
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 2.f;
	auto r = parser.process("3*x");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx(3*x) (where x = 2)", dr->eval(), 3.f);
	}
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 2.f;
	auto r = parser.process("3*x+2*x");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx(3*x+2*x) (where x = 2)", dr->eval(), 5.f);
	}
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 4.f;
	auto r = parser.process("x/4");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx(x/4) (where x = 4)", dr->eval(), 0.25f);
	}
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 2.f;
	auto r = parser.process("1/x");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx(1/x) (where x = 2)", dr->eval(), -0.25f);
	}
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 2.f;
	auto r = parser.process("(x+2)/x");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx((x+2)/x) (where x = 2)", dr->eval(), -0.5f);
	}
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 2.f;
	auto r = parser.process("x^3+x");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx(x^3+x) (where x = 2)", dr->eval(), 13.f);
	}
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 2.f;
	auto r = parser.process("x^3+1");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx(x^3+x) (where x = 2)", dr->eval(), 12.f);
	}
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 2.f;
	auto r = parser.process("x^3+2*x");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx(x^3+2*x) (where x = 2)", dr->eval(), 14.f);
	}
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 2.f;
	auto r = parser.process("x^3+2*x+1");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx(x^3+2*x+1) (where x = 2)", dr->eval(), 14.f);
	}
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 0.f;
	auto r = parser.process("cos(x)");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx(cos(x)) (where x = 0)", dr->eval(), 0.f);
	}
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 0.f;
	auto r = parser.process("sin(x)");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx(sin(x)) (where x = 0)", dr->eval(), 1.f);
	}
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 0.f;
	auto r = parser.process("-sin(x)");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx(-sin(x)) (where x = 0)", dr->eval(), -1.f);
	}
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 2.f;
	auto r = parser.process("sin(x^3)");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx(sin(x^2)) (where x = 2)", dr->eval(), std::cosf(8.f)*12.f);
	}
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 4.f;
	auto r = parser.process("sqrt(x)");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx(sqrt(x)) (where x = 2)", dr->eval(), 0.25f);
	}
	
	{
	Parser parser;
	auto x = parser.getSymbol("x");
	*x = 2.f;
	auto r = parser.process("sqrt(2*x)");
	auto dr = r->derive(parser.getSymbol("x"));
	test.assert_eq("d/dx(sqrt(x)) (where x = 2)", dr->eval(), 0.5f);
	}
	
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
	
	test.showResults();
	
	if(test.num_failed > 0) {
		return EXIT_FAILURE;
	}
	
	
	return 0;
}

