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
	
	std::vector<std::shared_ptr<Token>> tokens;
	int i=0; // current token
	
	std::map<std::string, std::shared_ptr<float>> symbol_table;
	
};

struct AddExpression : Expression
{
	auto eval() -> float override;
	auto print() -> std::string override;
	
	std::shared_ptr<Expression> left, right;

	AddExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

struct PrefixSubExpression : Expression
{
	auto eval() -> float override;
	auto print() -> std::string override;
	
	std::shared_ptr<Expression> left;
	PrefixSubExpression(std::shared_ptr<Expression> left) : left(left) {}
};

struct SubExpression : Expression
{
	auto eval() -> float override;
	auto print() -> std::string override;
	
	std::shared_ptr<Expression> left, right;
	SubExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

struct MulExpression : Expression
{
	auto eval() -> float override;
	auto print() -> std::string override;
	
	std::shared_ptr<Expression> left, right;
	MulExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

struct DivExpression : Expression
{
	auto eval() -> float override;
	auto print() -> std::string override;
	
	std::shared_ptr<Expression> left, right;
	DivExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

struct NumExpression : Expression
{
	auto eval() -> float override;
	auto print() -> std::string override;
	
	float num;
	NumExpression(float num) : num(num) {}
};

struct SymExpression : Expression
{
	auto eval() -> float override;
	auto print() -> std::string override;
	
	std::string name;
	std::shared_ptr<float> value;
	SymExpression(const std::string& name, std::shared_ptr<float> value) : name(name), value(value) {}
};

// function calls
struct FunExpression : Expression
{
	auto eval() -> float override;
	auto print() -> std::string override;
	
	std::string name;
	std::function<float(float)> f;
	std::shared_ptr<Expression> left;
	FunExpression(const std::string& name, std::function<float(float)> f, std::shared_ptr<Expression> left) : name(name), f(f), left(left) {}
};


struct ExpExpression : Expression
{
	auto eval() -> float override;
	auto print() -> std::string override;
	
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
		return std::make_shared<AddExpression>(left, p->parse(priority()));
	}
	auto priority() -> int override { return 50; }
	
};

struct SubToken : Token
{
	auto prefix(Parser* p) -> std::shared_ptr<Expression> override
	{
		return std::make_shared<PrefixSubExpression>(p->parse(90));
	}
	
	
	auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override
	{
		return std::make_shared<SubExpression>(left, p->parse(priority()-1));
	}
	auto priority() -> int override { return 50; }
	
};

struct MulToken : Token
{
	auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override
	{
		return std::make_shared<MulExpression>(left, p->parse(priority()));
	}
	
	auto priority() -> int override { return 60; }
	
};

struct DivToken : Token
{
	auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override
	{
		return std::make_shared<DivExpression>(left, p->parse(priority()-1));
	}
	
	auto priority() -> int override  { return 60; }
	
};

struct LParToken : Token
{
	auto prefix(Parser* p) -> std::shared_ptr<Expression> override
	{
		auto exp = p->parse(20);
		p->next(); // skip rpar
		return exp;
	}
	
	auto priority() -> int override { return 100; }
	
	
	auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override
	{
		static std::unordered_map<std::string, std::function<float(float)>> funs = {
			{"sin", std::sinf},
			{"cos", std::cosf},
			{"tan", std::tanf},
			{"ln", std::logf},
			{"log", std::log10f},
			{"exp", std::expf},
			{"exp", std::expf},
			{"sqrt", std::sqrtf},
			{"asin", std::asinf},
			{"acos", std::acosf},
			{"atan", std::atanf},
			
		};
	
		auto exp = p->parse(20);
		p->next(); // skip rpar
	
		auto name = std::dynamic_pointer_cast<SymExpression>(left)->name;
		p->removeSymbol(name); // remove function name as symbol
		return std::make_shared<FunExpression>(name, funs[name], exp);
	}
	
};

struct RParToken : Token
{
	auto priority() -> int override { return 10; }
	
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
		return std::make_shared<ExpExpression>(left, p->parse(priority()));
	}
	auto priority() -> int override { return 70; }
	
};



