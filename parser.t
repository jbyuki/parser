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

@symbol_table_struct

struct Parser
{
	@constructor
	@methods
	@member_variables
};

@expression_structs
@token_struct


@parser.cpp=
#include "parser.h"

@define_constructor
@define_methods

@constructor=
Parser(const std::string& input);

@define_constructor=
Parser::Parser(const std::string& input)
{
	@tokenize_string
}

@base_expression_structs=
struct Expression
{
	@expression_methods
};

@base_token_struct=
struct Token
{
	virtual auto prefix(Parser* parser) -> std::shared_ptr<Expression> { return nullptr; }
	virtual auto infix(Parser* parser, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> { return nullptr; }
	virtual auto priority() -> int { return 0; }
};

@includes=
#include <vector>
#include <memory>

@member_variables=
std::vector<std::shared_ptr<Token>> tokens;
int i=0;

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
	// add mul token if num is just before symbol (2x => 2*x)
	if(tokens.size() > 0 && std::dynamic_pointer_cast<NumToken>(tokens.back())) {
		tokens.emplace_back(new MulToken());
	}

	std::string sym;
	
	do {
		iss >> c;
		sym += c;
	} while(std::isalnum(iss.peek()));

	tokens.emplace_back(new SymToken{sym});
}

@includes+=
#include <iostream>

@handle_error_tokenize=
else { 
	std::cout << "ERROR: Unexcepted character '" << c << "'!" << std::endl; 
	iss >> c; 
}

@methods=
auto next() -> std::shared_ptr<Token>;

@define_methods=
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
	return std::make_shared<PrefixSubExpression>(p->parse(100));
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
	auto exp = p->parse(priority());
	p->next(); // skip rpar
	return exp;
}

auto priority() -> int override { return 20; }

@rpar_token_methods=
auto prefix(Parser* p) -> std::shared_ptr<Expression> override
{
	return nullptr;
}

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


@symbol_table_struct=
struct SymTableEntry
{
	std::string name;
	float value;
};

@member_variables+=
std::vector<std::shared_ptr<SymTableEntry>> symbol_table;

@methods+=
auto getSymbol(const std::string& name) -> std::shared_ptr<SymTableEntry>;

@define_methods+=
auto Parser::getSymbol(const std::string& name) -> std::shared_ptr<SymTableEntry>
{
	@return_if_existing
	@create_for_new
}

@return_if_existing=
for(auto& sym : symbol_table) {
	if(sym->name == name) {
		return sym;
	}
}

@create_for_new=
symbol_table.emplace_back(new SymTableEntry{name, 0.f});
return symbol_table.back();

@expression_structs+=
struct SymExpression : Expression
{
	@evaluate_virtual_method
	std::shared_ptr<SymTableEntry> sym;
	SymExpression(std::shared_ptr<SymTableEntry> sym) : sym(sym) {}
};

@sym_token_methods=
auto prefix(Parser* p) -> std::shared_ptr<Expression> override
{
	return std::make_shared<SymExpression>(p->getSymbol(sym));
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
auto SymExpression::eval() -> float { return sym->value; }

@define_methods+=
auto NumExpression::print() -> std::string { return std::to_string(num); }
auto SymExpression::print() -> std::string { return "[sym " + sym->name + "]"; }
