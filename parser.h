#pragma once
#include <string>

#include <vector>
#include <memory>

#include <sstream>


#include <complex>

#include <cctype>

#include <unordered_map>

#include <cmath>

#include <iostream>

#include <map>

#include <functional>


struct Parser;

struct Expression
{
	virtual auto eval() -> std::complex<float> = 0;
	virtual auto print() -> std::string = 0;
	
	virtual auto derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression> = 0;
	
	virtual auto clone() -> std::shared_ptr<Expression> = 0;
	
	auto isZero() -> bool;
	
	auto isOne() -> bool;
	
};

struct Token
{
	virtual auto prefix(Parser* parser) -> std::shared_ptr<Expression>;
	virtual auto infix(Parser* parser, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression>;
	virtual auto priority() -> int;
};


struct Parser
{
	auto process(const std::string& input) -> std::shared_ptr<Expression>;
	
	auto next() -> std::shared_ptr<Token>;
	
	auto finish() -> bool;
	
	auto get() -> std::shared_ptr<Token>;
	
	auto parse(int p=0) -> std::shared_ptr<Expression>;
	
	auto getSymbol(const std::string& name) -> std::shared_ptr<std::complex<float>>;
	
	auto removeSymbol(const std::string& name) -> void;
	
	auto clear() -> void;
	
	std::vector<std::shared_ptr<Token>> tokens;
	int i=0; // current token
	
	std::map<std::string, std::shared_ptr<std::complex<float>>> symbol_table;
	
};

struct AddExpression : Expression
{
	auto eval() -> std::complex<float> override;
	auto print() -> std::string override;
	
	auto derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression> override;
	
	auto clone() -> std::shared_ptr<Expression> override;
	
	std::shared_ptr<Expression> left, right;

	AddExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

struct PrefixSubExpression : Expression
{
	auto eval() -> std::complex<float> override;
	auto print() -> std::string override;
	
	auto derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression> override;
	
	auto clone() -> std::shared_ptr<Expression> override;
	
	std::shared_ptr<Expression> left;
	PrefixSubExpression(std::shared_ptr<Expression> left) : left(left) {}
};

struct SubExpression : Expression
{
	auto eval() -> std::complex<float> override;
	auto print() -> std::string override;
	
	auto derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression> override;
	
	auto clone() -> std::shared_ptr<Expression> override;
	
	std::shared_ptr<Expression> left, right;
	SubExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

struct MulExpression : Expression
{
	auto eval() -> std::complex<float> override;
	auto print() -> std::string override;
	
	auto derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression> override;
	
	auto clone() -> std::shared_ptr<Expression> override;
	
	std::shared_ptr<Expression> left, right;
	MulExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

struct DivExpression : Expression
{
	auto eval() -> std::complex<float> override;
	auto print() -> std::string override;
	
	auto derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression> override;
	
	auto clone() -> std::shared_ptr<Expression> override;
	
	std::shared_ptr<Expression> left, right;
	DivExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

struct NumExpression : Expression
{
	auto eval() -> std::complex<float> override;
	auto print() -> std::string override;
	
	auto derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression> override;
	
	auto clone() -> std::shared_ptr<Expression> override;
	
	std::complex<float> num;
	NumExpression(std::complex<float> num) : num(num) {}
};

struct SymExpression : Expression
{
	auto eval() -> std::complex<float> override;
	auto print() -> std::string override;
	
	auto derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression> override;
	
	auto clone() -> std::shared_ptr<Expression> override;
	
	std::string name;
	std::shared_ptr<std::complex<float>> value;
	SymExpression(const std::string& name, std::shared_ptr<std::complex<float>> value) : name(name), value(value) {}
};

// function calls
struct FunExpression : Expression
{
	auto eval() -> std::complex<float> override;
	auto print() -> std::string override;
	
	auto derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression> override;
	
	auto clone() -> std::shared_ptr<Expression> override;
	
	std::string name;
	std::function<std::complex<float>(std::complex<float>)> f;
	std::shared_ptr<Expression> left;
	FunExpression(const std::string& name, std::function<std::complex<float>(std::complex<float>)> f, std::shared_ptr<Expression> left) : name(name), f(f), left(left) {}
};


struct ExpExpression : Expression
{
	auto eval() -> std::complex<float> override;
	auto print() -> std::string override;
	
	auto derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression> override;
	
	auto clone() -> std::shared_ptr<Expression> override;
	
	std::shared_ptr<Expression> left, right;

	ExpExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

struct AddToken : Token
{
	auto prefix(Parser* p) -> std::shared_ptr<Expression> override;
	
	auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override;
	auto priority() -> int override;
	
};

struct SubToken : Token
{
	auto prefix(Parser* p) -> std::shared_ptr<Expression> override;
	
	auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override;
	auto priority() -> int override;
	
};

struct MulToken : Token
{
	auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression>;
	auto priority() -> int override;
	
};

struct DivToken : Token
{
	auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override;
	auto priority() -> int override;
	
};

struct RParToken : Token
{
	auto priority() -> int override;
	
};

struct LParToken : Token
{
	auto prefix(Parser* p) -> std::shared_ptr<Expression> override;
	
	auto priority() -> int override;
	
	auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override;
	
};


struct NumToken : Token
{
	auto prefix(Parser*) -> std::shared_ptr<Expression> override;
	
	std::complex<float> num;

	NumToken(std::complex<float> num) : num(num) {}
};

struct SymToken : Token
{
	auto prefix(Parser* p) -> std::shared_ptr<Expression> override;
	
	auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override;
	
	std::string sym;

	SymToken(std::string sym) : sym(sym) {}
};

struct ExpToken : Token
{
	auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override;
	auto priority() -> int override;
	
};



