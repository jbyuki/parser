#pragma once
#include <string>

#include <vector>
#include <memory>

#include <sstream>


#include <cctype>

#include <unordered_map>

#include <cmath>

#include <iostream>

#include <map>

#include <functional>


struct Parser;

struct Expression
{
	virtual auto eval() -> float = 0;
	virtual auto print() -> std::string = 0;
	
	virtual auto derive(std::shared_ptr<float> sym) -> std::shared_ptr<Expression> = 0;
	
	virtual auto clone() -> std::shared_ptr<Expression> = 0;
	
	auto isZero() -> bool;
	
	auto isOne() -> bool;
	
};

struct Token
{
	virtual auto prefix(Parser* parser) -> std::shared_ptr<Expression> { return nullptr; }
	virtual auto infix(Parser* parser, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> { return nullptr; }
	virtual auto priority() -> int { return 0; }
};


struct Parser
{
	auto process(const std::string& input) -> std::shared_ptr<Expression>;
	
	auto next() -> std::shared_ptr<Token>;
	
	auto finish() -> bool;
	
	auto get() -> std::shared_ptr<Token>;
	
	auto parse(int p=0) -> std::shared_ptr<Expression>;
	
	auto getSymbol(const std::string& name) -> std::shared_ptr<float>;
	
	auto removeSymbol(const std::string& name) -> void;
	
	auto clear() -> void;
	
	std::vector<std::shared_ptr<Token>> tokens;
	int i=0; // current token
	
	std::map<std::string, std::shared_ptr<float>> symbol_table;
	
};

struct AddExpression : Expression
{
	auto eval() -> float override;
	auto print() -> std::string override;
	
	auto derive(std::shared_ptr<float> sym) -> std::shared_ptr<Expression> override;
	
	auto clone() -> std::shared_ptr<Expression> override;
	
	std::shared_ptr<Expression> left, right;

	AddExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

struct PrefixSubExpression : Expression
{
	auto eval() -> float override;
	auto print() -> std::string override;
	
	auto derive(std::shared_ptr<float> sym) -> std::shared_ptr<Expression> override;
	
	auto clone() -> std::shared_ptr<Expression> override;
	
	std::shared_ptr<Expression> left;
	PrefixSubExpression(std::shared_ptr<Expression> left) : left(left) {}
};

struct SubExpression : Expression
{
	auto eval() -> float override;
	auto print() -> std::string override;
	
	auto derive(std::shared_ptr<float> sym) -> std::shared_ptr<Expression> override;
	
	auto clone() -> std::shared_ptr<Expression> override;
	
	std::shared_ptr<Expression> left, right;
	SubExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

struct MulExpression : Expression
{
	auto eval() -> float override;
	auto print() -> std::string override;
	
	auto derive(std::shared_ptr<float> sym) -> std::shared_ptr<Expression> override;
	
	auto clone() -> std::shared_ptr<Expression> override;
	
	std::shared_ptr<Expression> left, right;
	MulExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

struct DivExpression : Expression
{
	auto eval() -> float override;
	auto print() -> std::string override;
	
	auto derive(std::shared_ptr<float> sym) -> std::shared_ptr<Expression> override;
	
	auto clone() -> std::shared_ptr<Expression> override;
	
	std::shared_ptr<Expression> left, right;
	DivExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

struct NumExpression : Expression
{
	auto eval() -> float override;
	auto print() -> std::string override;
	
	auto derive(std::shared_ptr<float> sym) -> std::shared_ptr<Expression> override;
	
	auto clone() -> std::shared_ptr<Expression> override;
	
	float num;
	NumExpression(float num) : num(num) {}
};

struct SymExpression : Expression
{
	auto eval() -> float override;
	auto print() -> std::string override;
	
	auto derive(std::shared_ptr<float> sym) -> std::shared_ptr<Expression> override;
	
	auto clone() -> std::shared_ptr<Expression> override;
	
	std::string name;
	std::shared_ptr<float> value;
	SymExpression(const std::string& name, std::shared_ptr<float> value) : name(name), value(value) {}
};

// function calls
struct FunExpression : Expression
{
	auto eval() -> float override;
	auto print() -> std::string override;
	
	auto derive(std::shared_ptr<float> sym) -> std::shared_ptr<Expression> override;
	
	auto clone() -> std::shared_ptr<Expression> override;
	
	std::string name;
	std::function<float(float)> f;
	std::shared_ptr<Expression> left;
	FunExpression(const std::string& name, std::function<float(float)> f, std::shared_ptr<Expression> left) : name(name), f(f), left(left) {}
};


struct ExpExpression : Expression
{
	auto eval() -> float override;
	auto print() -> std::string override;
	
	auto derive(std::shared_ptr<float> sym) -> std::shared_ptr<Expression> override;
	
	auto clone() -> std::shared_ptr<Expression> override;
	
	std::shared_ptr<Expression> left, right;

	ExpExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

struct AddToken : Token
{
	auto prefix(Parser* p) -> std::shared_ptr<Expression> override
	{
		return p->parse(priority());
	}
	
	auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override
	{
		auto t = p->parse(priority());
		if(!t) {
			return nullptr;
		}
	
		return std::make_shared<AddExpression>(left, t);
	}
	auto priority() -> int override { return 50; }
	
};

struct SubToken : Token
{
	auto prefix(Parser* p) -> std::shared_ptr<Expression> override
	{
		auto t = p->parse(90);
		if(!t) {
			return nullptr;
		}
	
		return std::make_shared<PrefixSubExpression>(t);
	}
	
	
	auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override
	{
		auto t = p->parse(priority()-1);
		if(!t) {
			return nullptr;
		}
		return std::make_shared<SubExpression>(left, t);
	}
	auto priority() -> int override { return 50; }
	
};

struct MulToken : Token
{
	auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override
	{
		auto t = p->parse(priority());
		if(!t) {
			return nullptr;
		}
	
		return std::make_shared<MulExpression>(left, t);
	}
	
	auto priority() -> int override { return 60; }
	
};

struct DivToken : Token
{
	auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override
	{
	
		auto t = p->parse(priority()-1);
		if(!t) {
			return nullptr;
		}
		return std::make_shared<DivExpression>(left, t);
	}
	
	auto priority() -> int override  { return 60; }
	
};

struct RParToken : Token
{
	auto priority() -> int override { return 10; }
	
};

struct LParToken : Token
{
	auto prefix(Parser* p) -> std::shared_ptr<Expression> override
	{
		auto exp = p->parse(20);
		if(!exp) {
			return nullptr;
		}
	
		auto rpar = p->get();
		if(!rpar || !std::dynamic_pointer_cast<RParToken>(rpar)) {
			return nullptr;
		}
		p->next(); // skip rpar
		
		return exp;
	}
	
	auto priority() -> int override { return 100; }
	
	
	auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override
	{
		static std::unordered_map<std::string, std::function<float(float)>> funs = {
			{"sin", [](float x) { return std::sin(x); }},
			{"cos", [](float x) { return std::cos(x); }},
			{"tan", [](float x) { return std::tan(x); }},
			{"ln", [](float x) { return std::log(x); }},
			{"log", [](float x) { return std::log10(x); }},
			{"exp", [](float x) { return std::exp(x); }},
			{"sqrt", [](float x) { return std::sqrt(x); }},
			{"asin", [](float x) { return std::asin(x); }},
			{"acos", [](float x) { return std::acos(x); }},
			{"atan", [](float x) { return std::atan(x); }},
			
		};
	
		auto exp = p->parse(20);
		if(!exp) {
			return nullptr;
		}
	
		auto rpar = p->get();
		if(!rpar || !std::dynamic_pointer_cast<RParToken>(rpar)) {
			return nullptr;
		}
		p->next(); // skip rpar
		
	
		auto name = std::dynamic_pointer_cast<SymExpression>(left)->name;
		p->removeSymbol(name); // remove function name as symbol
		return std::make_shared<FunExpression>(name, funs[name], exp);
	}
	
};


struct NumToken : Token
{
	auto prefix(Parser*) -> std::shared_ptr<Expression> override
	{
		return std::make_shared<NumExpression>(num);
	}
	
	float num;

	NumToken(float num) : num(num) {}
};

struct SymToken : Token
{
	auto prefix(Parser* p) -> std::shared_ptr<Expression> override
	{
		return std::make_shared<SymExpression>(sym, p->getSymbol(sym));
	}
	
	std::string sym;

	SymToken(std::string sym) : sym(sym) {}
};

struct ExpToken : Token
{
	auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override
	{
		auto t = p->parse(priority());
		if(!t) {
			return nullptr;
		}
	
		return std::make_shared<ExpExpression>(left, t);
	}
	auto priority() -> int override { return 70; }
	
};



