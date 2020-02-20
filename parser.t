@desc=
"This is using a Pratt's parser to parse the input text."
"The blog post here http://effbot.org/zone/simple-top-down-parsing.htm was used as"
"a reference."

@parser.h=
#pragma once
@includes

struct Parser;

@base_expression_structs
@base_token_struct

struct Parser
{
	@methods
	@member_variables
};

@expression_structs
@token_struct


@parser.cpp=
#include "parser.h"

@define_methods

@includes=
#include <string>

@base_expression_structs=
struct Expression
{
	@expression_methods
};

@methods=
auto process(const std::string& input) -> std::shared_ptr<Expression>;

@define_methods=
auto Parser::process(const std::string& input) -> std::shared_ptr<Expression>
{
	@clear_tokens
	@tokenize_string
	@parse_string
}


@base_token_struct=
struct Token
{
	virtual auto prefix(Parser* parser) -> std::shared_ptr<Expression> { return nullptr; }
	virtual auto infix(Parser* parser, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> { return nullptr; }
	virtual auto priority() -> int { return 0; }
};

@includes+=
#include <vector>
#include <memory>

@member_variables=
std::vector<std::shared_ptr<Token>> tokens;
int i=0; // current token

@clear_tokens=
tokens.clear();
i = 0;

@includes+=
#include <sstream>


@tokenize_string=
std::istringstream iss(input);
char c;
@eat_whitespaces
while((c = iss.peek()) != EOF) {
	@tokenize_op
	@tokenize_par
	@tokenize_num
	@tokenize_symbol
	@handle_error_tokenize
	@eat_whitespaces
}

@eat_whitespaces=
iss >> std::ws;

@token_struct=
struct AddToken : Token
{
	@add_token_methods
};

struct SubToken : Token
{
	@sub_token_methods
};

struct MulToken : Token
{
	@mul_token_methods
};

struct DivToken : Token
{
	@div_token_methods
};

@tokenize_op=
if(c == '+') { iss >> c; tokens.emplace_back(new AddToken()); }
else if(c == '-') { iss >> c; tokens.emplace_back(new SubToken()); }
else if(c == '*') { iss >> c; tokens.emplace_back(new MulToken()); }
else if(c == '/') { iss >> c; tokens.emplace_back(new DivToken()); }

@token_struct+=
struct LParToken : Token
{
	@lpar_token_methods
};

struct RParToken : Token
{
	@rpar_token_methods
};

@tokenize_par=
else if(c == '(') { iss >> c; tokens.emplace_back(new LParToken()); }
else if(c == ')') { iss >> c; tokens.emplace_back(new RParToken()); }

@token_struct+=
struct NumToken : Token
{
	@num_token_methods
	float num;

	NumToken(float num) : num(num) {}
};

@tokenize_num=
else if(c >= '0' && c <= '9') { 
	float num; iss>>num; 
	tokens.emplace_back(new NumToken{num});
}

@token_struct+=
struct SymToken : Token
{
	@sym_token_methods
	std::string sym;

	SymToken(std::string sym) : sym(sym) {}
};

@includes+=
#include <cctype>

@tokenize_symbol=
else if((c >= 'a' && c <= 'z') || (c >= 'A' && 'Z')) { 
	@add_mul_token_if_num_just_before
	@get_all_char_sym
	@create_num_token_if_constant
	@otherwise_crete_sym_token
}

@add_mul_token_if_num_just_before=
if(tokens.size() > 0 && std::dynamic_pointer_cast<NumToken>(tokens.back())) {
	tokens.emplace_back(new MulToken());
}

@get_all_char_sym=
std::string sym;
do {
	iss >> c;
	sym += c;
} while(std::isalnum(iss.peek()));

@includes+=
#include <unordered_map>

@create_num_token_if_constant=
static std::unordered_map<std::string, float> constants = {
	@list_constants
};

if(constants.find(sym) != constants.end()) {
	tokens.emplace_back(new NumToken{constants[sym]});
}

@includes+=
#include <cmath>

@list_constants=
// atan(1)*4 = pi
{"pi", 4.f*atanf(1.f)},
{"mu0", 4*(4.f*atanf(1.f))*1e-7f},

@otherwise_crete_sym_token=
else {
	tokens.emplace_back(new SymToken{sym});
}

@includes+=
#include <iostream>

@handle_error_tokenize=
else { 
	std::cout << "ERROR: Unexcepted character '" << c << "'!" << std::endl; 
	iss >> c; 
}

@methods+=
auto next() -> std::shared_ptr<Token>;

@define_methods+=
auto Parser::next() -> std::shared_ptr<Token>
{
	return tokens[i++];
}

@methods+=
auto finish() -> bool;

@define_methods+=
auto Parser::finish() -> bool
{
	return i == (int)tokens.size();
}

@methods+=
auto get() -> std::shared_ptr<Token>;

@define_methods+=
auto Parser::get() -> std::shared_ptr<Token>
{
	return tokens[i];
}

@parse_string=
return parse();

@methods+=
auto parse(int p=0) -> std::shared_ptr<Expression>;

@define_methods+=
auto Parser::parse(int p) -> std::shared_ptr<Expression>
{
	auto t = next();
	auto exp = t->prefix(this);

	while(!finish() && p <= get()->priority()) {
		t = next();
		exp = t->infix(this, exp);
	}

	return exp;
}



@add_token_methods=
auto prefix(Parser* p) -> std::shared_ptr<Expression> override
{
	return p->parse(priority());
}

@expression_structs=
struct AddExpression : Expression
{
	@evaluate_virtual_method
	std::shared_ptr<Expression> left, right;

	AddExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

@add_token_methods+=
auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override
{
	return std::make_shared<AddExpression>(left, p->parse(priority()));
}
auto priority() -> int override { return 50; }

@expression_structs+=
struct PrefixSubExpression : Expression
{
	@evaluate_virtual_method
	std::shared_ptr<Expression> left;
	PrefixSubExpression(std::shared_ptr<Expression> left) : left(left) {}
};

@sub_token_methods=
auto prefix(Parser* p) -> std::shared_ptr<Expression> override
{
	return std::make_shared<PrefixSubExpression>(p->parse(90));
}


@expression_structs+=
struct SubExpression : Expression
{
	@evaluate_virtual_method
	std::shared_ptr<Expression> left, right;
	SubExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

@sub_token_methods+=
auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override
{
	return std::make_shared<SubExpression>(left, p->parse(priority()-1));
}
auto priority() -> int override { return 50; }

@expression_structs+=
struct MulExpression : Expression
{
	@evaluate_virtual_method
	std::shared_ptr<Expression> left, right;
	MulExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

@mul_token_methods=
auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override
{
	return std::make_shared<MulExpression>(left, p->parse(priority()));
}

auto priority() -> int override { return 60; }

@expression_structs+=
struct DivExpression : Expression
{
	@evaluate_virtual_method
	std::shared_ptr<Expression> left, right;
	DivExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

@div_token_methods=
auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override
{
	return std::make_shared<DivExpression>(left, p->parse(priority()-1));
}

auto priority() -> int override  { return 60; }

@lpar_token_methods=
auto prefix(Parser* p) -> std::shared_ptr<Expression> override
{
	auto exp = p->parse(20);
	p->next(); // skip rpar
	return exp;
}

auto priority() -> int override { return 100; }


@rpar_token_methods=
auto priority() -> int override { return 10; }

@expression_structs+=
struct NumExpression : Expression
{
	@evaluate_virtual_method
	float num;
	NumExpression(float num) : num(num) {}
};

@num_token_methods=
auto prefix(Parser*) -> std::shared_ptr<Expression> override
{
	return std::make_shared<NumExpression>(num);
}

@includes+=
#include <map>

@member_variables+=
std::map<std::string, std::shared_ptr<float>> symbol_table;

@methods+=
auto getSymbol(const std::string& name) -> std::shared_ptr<float>;

@define_methods+=
auto Parser::getSymbol(const std::string& name) -> std::shared_ptr<float>
{
	@return_if_existing
	@create_for_new
}

@return_if_existing=
if(symbol_table.find(name) != symbol_table.end()) {
	return symbol_table[name];
}

@create_for_new=
symbol_table[name] = std::make_shared<float>(0.f);
return symbol_table[name];

@expression_structs+=
struct SymExpression : Expression
{
	@evaluate_virtual_method
	std::string name;
	std::shared_ptr<float> value;
	SymExpression(const std::string& name, std::shared_ptr<float> value) : name(name), value(value) {}
};

@sym_token_methods=
auto prefix(Parser* p) -> std::shared_ptr<Expression> override
{
	return std::make_shared<SymExpression>(sym, p->getSymbol(sym));
}

@includes+=
#include <functional>

@expression_structs+=
// function calls
struct FunExpression : Expression
{
	@evaluate_virtual_method
	std::string name;
	std::function<float(float)> f;
	std::shared_ptr<Expression> left;
	FunExpression(const std::string& name, std::function<float(float)> f, std::shared_ptr<Expression> left) : name(name), f(f), left(left) {}
};


@methods+=
auto removeSymbol(const std::string& name) -> void;

@define_methods+=
auto Parser::removeSymbol(const std::string& name) -> void
{
	@remove_symbol_if_exists
}

@remove_symbol_if_exists=
symbol_table.erase(name);

@lpar_token_methods+=
auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override
{
	static std::unordered_map<std::string, std::function<float(float)>> funs = {
		@list_supported_functions
	};

	auto exp = p->parse(20);
	p->next(); // skip rpar

	auto name = std::dynamic_pointer_cast<SymExpression>(left)->name;
	p->removeSymbol(name); // remove function name as symbol
	return std::make_shared<FunExpression>(name, funs[name], exp);
}

@expression_methods=
virtual auto eval() -> float = 0;
virtual auto print() -> std::string = 0;

@evaluate_virtual_method=
auto eval() -> float override;
auto print() -> std::string override;

@define_methods+=
auto AddExpression::eval() -> float { return left->eval() + right->eval(); }
auto SubExpression::eval() -> float { return left->eval() - right->eval(); }
auto MulExpression::eval() -> float { return left->eval() * right->eval(); }
auto DivExpression::eval() -> float { return left->eval() / right->eval(); }
auto PrefixSubExpression::eval() -> float { return -left->eval(); }

@define_methods+=
auto AddExpression::print() -> std::string { return "(+ " + left->print() + " " + right->print() + ")"; }
auto SubExpression::print() -> std::string { return "(- " + left->print() + " " + right->print() + ")"; }
auto MulExpression::print() -> std::string { return "(* " + left->print() + " " + right->print() + ")"; }
auto DivExpression::print() -> std::string { return "(/ " + left->print() + " " + right->print() + ")"; }
auto PrefixSubExpression::print() -> std::string { return "(-" + left->print() + ")";  }


@define_methods+=
auto NumExpression::eval() -> float { return num; }
auto SymExpression::eval() -> float { return (*value); }

@define_methods+=
auto NumExpression::print() -> std::string { return std::to_string(num); }
auto SymExpression::print() -> std::string { return "[sym " + name + "]"; }

@define_methods+=
auto FunExpression::eval() -> float { return f(left->eval()); }
auto FunExpression::print() -> std::string { return "([" + name + "] " + left->print() + ")"; }


@list_supported_functions=
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

@token_struct+=
struct ExpToken : Token
{
	@exp_token_methods
};

@tokenize_op+=
else if(c == '^') { iss >> c; tokens.emplace_back(new ExpToken()); }

@expression_structs+=
struct ExpExpression : Expression
{
	@evaluate_virtual_method
	std::shared_ptr<Expression> left, right;

	ExpExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}
};

@exp_token_methods=
auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override
{
	return std::make_shared<ExpExpression>(left, p->parse(priority()));
}
auto priority() -> int override { return 70; }

@define_methods+=
auto ExpExpression::eval() -> float { return std::powf(left->eval(), right->eval()); }
auto ExpExpression::print() -> std::string { return "(^ " + left->print() + " " + right->print() + ")"; }
