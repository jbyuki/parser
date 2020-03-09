#include "test_utils.h"

#include <iostream>
#include "parser.h"


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
	test.showResults();
	
	

	system("PAUSE");
	return 0;
}

