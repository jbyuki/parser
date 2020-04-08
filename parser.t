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
	virtual auto prefix(Parser* parser) -> std::shared_ptr<Expression>;
	virtual auto infix(Parser* parser, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression>;
	virtual auto priority() -> int;
};

@define_methods+=
auto Token::prefix(Parser* parser) -> std::shared_ptr<Expression> { return nullptr; }
auto Token::infix(Parser* parser, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> { return nullptr; }
auto Token::priority() -> int { return 0; }

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
struct RParToken : Token
{
	@rpar_token_methods
};

struct LParToken : Token
{
	@lpar_token_methods
};


@tokenize_par=
else if(c == '(') { iss >> c; tokens.emplace_back(new LParToken()); }
else if(c == ')') { iss >> c; tokens.emplace_back(new RParToken()); }

@includes+=
#include <complex>

@token_struct+=
struct NumToken : Token
{
	@num_token_methods
	std::complex<float> num;

	NumToken(std::complex<float> num);
};

@define_methods+=
NumToken::NumToken(std::complex<float> num) : num(num) {}

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

	SymToken(std::string sym);
};

@define_methods+=
SymToken::SymToken(std::string sym) : sym(sym) {}

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
static std::unordered_map<std::string, std::complex<float>> constants = {
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
{"i", std::complex<float>(0.f, 1.f)},

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
	if(i >= (int)tokens.size()) {
		return nullptr;
	}

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
	if(i >= (int)tokens.size()) {
		return nullptr;
	}

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
	if(!t) {
		return nullptr;
	}

	auto exp = t->prefix(this);

	while(exp && !finish() && p <= get()->priority()) {
		t = next();
		exp = t->infix(this, exp);
	}

	return exp;
}

@add_token_methods=
auto prefix(Parser* p) -> std::shared_ptr<Expression> override;

@define_methods+=
auto AddToken::prefix(Parser* p) -> std::shared_ptr<Expression>
{
	return p->parse(priority());
}

@expression_structs=
struct AddExpression : Expression
{
	@expression_virtual_methods
	std::shared_ptr<Expression> left, right;

	AddExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right);
};

@define_methods+=
AddExpression::AddExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}

@add_token_methods+=
auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override;
auto priority() -> int override;

@define_methods+=
auto AddToken::infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression>
{
	auto t = p->parse(priority());
	if(!t) {
		return nullptr;
	}

	return std::make_shared<AddExpression>(left, t);
}

auto AddToken::priority() -> int { return 50; }


@expression_structs+=
struct PrefixSubExpression : Expression
{
	@expression_virtual_methods
	std::shared_ptr<Expression> left;
	PrefixSubExpression(std::shared_ptr<Expression> left);
};

@define_methods+=
PrefixSubExpression::PrefixSubExpression(std::shared_ptr<Expression> left) : left(left) {}

@sub_token_methods=
auto prefix(Parser* p) -> std::shared_ptr<Expression> override;

@define_methods+=
auto SubToken::prefix(Parser* p) -> std::shared_ptr<Expression>
{
	auto t = p->parse(90);
	if(!t) {
		return nullptr;
	}

	return std::make_shared<PrefixSubExpression>(t);
}


@expression_structs+=
struct SubExpression : Expression
{
	@expression_virtual_methods
	std::shared_ptr<Expression> left, right;
	SubExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right);
};

@define_methods+=
SubExpression::SubExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}

@sub_token_methods+=
auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override;
auto priority() -> int override;

@define_methods+=
auto SubToken::infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression>
{
	auto t = p->parse(priority()-1);
	if(!t) {
		return nullptr;
	}
	return std::make_shared<SubExpression>(left, t);
}
auto SubToken::priority() -> int { return 50; }

@expression_structs+=
struct MulExpression : Expression
{
	@expression_virtual_methods
	std::shared_ptr<Expression> left, right;
	MulExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right);
};

@define_methods+=
MulExpression::MulExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}

@mul_token_methods=
auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression>;
auto priority() -> int override;

@define_methods+=
auto MulToken::infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression>
{
	auto t = p->parse(priority());
	if(!t) {
		return nullptr;
	}

	return std::make_shared<MulExpression>(left, t);
}

auto MulToken::priority() -> int { return 60; }


@expression_structs+=
struct DivExpression : Expression
{
	@expression_virtual_methods
	std::shared_ptr<Expression> left, right;
	DivExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right);
};

@define_methods+=
DivExpression::DivExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}

@div_token_methods=
auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override;
auto priority() -> int override;

@define_methods+=
auto DivToken::infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression>
{

	auto t = p->parse(priority()-1);
	if(!t) {
		return nullptr;
	}
	return std::make_shared<DivExpression>(left, t);
}

auto DivToken::priority() -> int { return 60; }


@lpar_token_methods=
auto prefix(Parser* p) -> std::shared_ptr<Expression> override;

@define_methods+=
auto LParToken::prefix(Parser* p) -> std::shared_ptr<Expression>
{
	auto exp = p->parse(20);
	if(!exp) {
		return nullptr;
	}

	@check_rpar
	return exp;
}

@check_rpar=
auto rpar = p->get();
if(!rpar || !std::dynamic_pointer_cast<RParToken>(rpar)) {
	return nullptr;
}
p->next(); // skip rpar

@lpar_token_methods+=
auto priority() -> int override;

@define_methods+=
auto LParToken::priority() -> int { return 100; }

@rpar_token_methods+=
auto priority() -> int override;

@define_methods+=
auto RParToken::priority() -> int { return 10; }

@expression_structs+=
struct NumExpression : Expression
{
	@expression_virtual_methods
	std::complex<float> num;
	NumExpression(std::complex<float> num);
};

@define_methods+=
NumExpression::NumExpression(std::complex<float> num) : num(num) {}

@num_token_methods=
auto prefix(Parser*) -> std::shared_ptr<Expression> override;

@define_methods+=
auto NumToken::prefix(Parser*) -> std::shared_ptr<Expression>
{
	return std::make_shared<NumExpression>(num);
}

@includes+=
#include <map>

@member_variables+=
std::map<std::string, std::shared_ptr<std::complex<float>>> symbol_table;

@methods+=
auto getSymbol(const std::string& name) -> std::shared_ptr<std::complex<float>>;

@define_methods+=
auto Parser::getSymbol(const std::string& name) -> std::shared_ptr<std::complex<float>>
{
	@return_if_existing
	@create_for_new
}

@return_if_existing=
if(symbol_table.find(name) != symbol_table.end()) {
	return symbol_table[name];
}

@create_for_new=
symbol_table[name] = std::make_shared<std::complex<float>>(0.f);
return symbol_table[name];

@expression_structs+=
struct SymExpression : Expression
{
	@expression_virtual_methods
	std::string name;
	std::shared_ptr<std::complex<float>> value;
	SymExpression(const std::string& name, std::shared_ptr<std::complex<float>> value);
};

@define_methods+=
SymExpression::SymExpression(const std::string& name, std::shared_ptr<std::complex<float>> value) : name(name), value(value) {}

@sym_token_methods+=
auto prefix(Parser* p) -> std::shared_ptr<Expression> override;

@define_methods+=
auto SymToken::prefix(Parser* p) -> std::shared_ptr<Expression>
{
	return std::make_shared<SymExpression>(sym, p->getSymbol(sym));
}

@includes+=
#include <functional>

@expression_structs+=
// function calls
struct FunExpression : Expression
{
	@expression_virtual_methods
	std::string name;
	std::function<std::complex<float>(std::complex<float>)> f;
	std::shared_ptr<Expression> left;
	FunExpression(const std::string& name, std::function<std::complex<float>(std::complex<float>)> f, std::shared_ptr<Expression> left);
};

@define_methods+=
FunExpression::FunExpression(const std::string& name, std::function<std::complex<float>(std::complex<float>)> f, std::shared_ptr<Expression> left) : name(name), f(f), left(left) {}


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
auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override;

@define_methods+=
auto LParToken::infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression>
{
	static std::unordered_map<std::string, std::function<std::complex<float>(std::complex<float>)>> funs = {
		@list_supported_functions
	};

	auto exp = p->parse(20);
	if(!exp) {
		return nullptr;
	}

	@check_rpar

	auto name = std::dynamic_pointer_cast<SymExpression>(left)->name;
	p->removeSymbol(name); // remove function name as symbol
	return std::make_shared<FunExpression>(name, funs[name], exp);
}

@expression_methods=
virtual auto eval() -> std::complex<float> = 0;
virtual auto print() -> std::string = 0;

@expression_virtual_methods=
auto eval() -> std::complex<float> override;
auto print() -> std::string override;

@define_methods+=
auto AddExpression::eval() -> std::complex<float> { return left->eval() + right->eval(); }
auto SubExpression::eval() -> std::complex<float> { return left->eval() - right->eval(); }
auto MulExpression::eval() -> std::complex<float> { return left->eval() * right->eval(); }
auto DivExpression::eval() -> std::complex<float> { return left->eval() / right->eval(); }
auto PrefixSubExpression::eval() -> std::complex<float> { return -left->eval(); }

@define_methods+=
auto AddExpression::print() -> std::string { return "(+ " + left->print() + " " + right->print() + ")"; }
auto SubExpression::print() -> std::string { return "(- " + left->print() + " " + right->print() + ")"; }
auto MulExpression::print() -> std::string { return "(* " + left->print() + " " + right->print() + ")"; }
auto DivExpression::print() -> std::string { return "(/ " + left->print() + " " + right->print() + ")"; }
auto PrefixSubExpression::print() -> std::string { return "(-" + left->print() + ")";  }


@define_methods+=
auto NumExpression::eval() -> std::complex<float> { return num; }
auto SymExpression::eval() -> std::complex<float> { return (*value); }

@define_methods+=
auto NumExpression::print() -> std::string { 
	return std::to_string(std::real(num)) + "+" + std::to_string(std::imag(num)) + "i"; 
}
auto SymExpression::print() -> std::string { return "[sym " + name + "]"; }

@define_methods+=
auto FunExpression::eval() -> std::complex<float> { return f(left->eval()); }
auto FunExpression::print() -> std::string { return "([" + name + "] " + left->print() + ")"; }


@list_supported_functions=
{"sin", [](std::complex<float> x) { return std::sin(x); }},
{"cos", [](std::complex<float> x) { return std::cos(x); }},
{"tan", [](std::complex<float> x) { return std::tan(x); }},
{"ln", [](std::complex<float> x) { return std::log(x); }},
{"log", [](std::complex<float> x) { return std::log10(x); }},
{"exp", [](std::complex<float> x) { return std::exp(x); }},
{"sqrt", [](std::complex<float> x) { return std::sqrt(x); }},
{"asin", [](std::complex<float> x) { return std::asin(x); }},
{"acos", [](std::complex<float> x) { return std::acos(x); }},
{"atan", [](std::complex<float> x) { return std::atan(x); }},
{"abs", [](std::complex<float> x) { return std::abs(x); }},
{"arg", [](std::complex<float> x) { return std::arg(x); }},

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
	@expression_virtual_methods
	std::shared_ptr<Expression> left, right;

	ExpExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right);
};

@define_methods+=
ExpExpression::ExpExpression(std::shared_ptr<Expression> left, std::shared_ptr<Expression> right) : left(left), right(right) {}

@exp_token_methods=
auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override;
auto priority() -> int override;

@define_methods+=
auto ExpToken::infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression>
{
	auto t = p->parse(priority());
	if(!t) {
		return nullptr;
	}

	return std::make_shared<ExpExpression>(left, t);
}
auto ExpToken::priority() -> int { return 70; }

@define_methods+=
auto ExpExpression::eval() -> std::complex<float> { return std::pow(left->eval(), right->eval()); }
auto ExpExpression::print() -> std::string { return "(^ " + left->print() + " " + right->print() + ")"; }

@methods+=
auto clear() -> void;

@define_methods+=
auto Parser::clear() -> void
{
	@clean_up_all
}

@clean_up_all=
symbol_table.clear();

@expression_methods+=
virtual auto derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression> = 0;

@expression_virtual_methods+=
auto derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression> override;

@expression_methods+=
virtual auto clone() -> std::shared_ptr<Expression> = 0;

@expression_virtual_methods+=
auto clone() -> std::shared_ptr<Expression> override;

@expression_methods+=
auto isZero() -> bool;

@define_methods+=
auto Expression::isZero() -> bool
{
	auto n = dynamic_cast<NumExpression*>(this);
	return n && n->num == 0.f;
}

@define_methods+=
auto AddExpression::derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression>
{ 
	auto dl = left->derive(sym);
	auto dr = right->derive(sym);

	if(dl->isZero()) { return dr; }
	else if(dr->isZero()) { return dl; }

	return std::make_shared<AddExpression>(dl, dr);
}

auto AddExpression::clone() -> std::shared_ptr<Expression>
{ 
	return std::make_shared<AddExpression>(left->clone(), right->clone());
}

@define_methods+=
auto PrefixSubExpression::derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression>
{ 
	auto dl = left->derive(sym);

	if(dl->isZero()) { return dl; }

	return std::make_shared<PrefixSubExpression>(left->derive(sym));
}

auto PrefixSubExpression::clone() -> std::shared_ptr<Expression>
{ 
	return std::make_shared<PrefixSubExpression>(left->clone());
}

@define_methods+=
auto SubExpression::derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression>
{ 
	auto dl = left->derive(sym);
	auto dr = right->derive(sym);

	if(dl->isZero()) { return std::make_shared<PrefixSubExpression>(dr); }
	else if(dr->isZero()) { return dl; }

	return std::make_shared<SubExpression>(dl, dr);
}

auto SubExpression::clone() -> std::shared_ptr<Expression>
{ 
	return std::make_shared<SubExpression>(left->clone(), right->clone());
}

@define_methods+=
auto MulExpression::derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression>
{ 
	// u'v + uv'
	auto dl = left->derive(sym);
	auto dr = right->derive(sym);

	auto p1 = std::make_shared<MulExpression>(dl, right->clone());
	auto p2 = std::make_shared<MulExpression>(left->clone(), dr);
	
	if(dl->isZero()) { return p2; }
	if(dr->isZero()) { return p1; }

	return std::make_shared<AddExpression>(p1, p2);
}

auto MulExpression::clone() -> std::shared_ptr<Expression>
{ 
	return std::make_shared<MulExpression>(left->clone(), right->clone());
}

@define_methods+=
auto DivExpression::derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression>
{ 
	// (u'v - uv')/v^2
	auto dl = left->derive(sym);
	auto dr = right->derive(sym);

	auto p1 = std::make_shared<MulExpression>(dl, right->clone());
	auto p2 = std::make_shared<MulExpression>(left->clone(), dr);
	auto den = std::make_shared<MulExpression>(right->clone(), right->clone());

	if(dl->isZero()) {
		auto d = std::make_shared<DivExpression>(p2, den);
		return std::make_shared<PrefixSubExpression>(d);
	}

	if(dr->isZero()) {
		return std::make_shared<DivExpression>(dl, right->clone());
	}

	auto num = std::make_shared<SubExpression>(p1, p2);
	return std::make_shared<DivExpression>(num, den);
}

auto DivExpression::clone() -> std::shared_ptr<Expression>
{ 
	return std::make_shared<DivExpression>(left->clone(), right->clone());
}

@define_methods+=
auto NumExpression::derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression>
{ 
	return std::make_shared<NumExpression>(0.f);
}

auto NumExpression::clone() -> std::shared_ptr<Expression>
{ 
	return std::make_shared<NumExpression>(*this);
}

@define_methods+=
auto SymExpression::derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression>
{ 
	return std::make_shared<NumExpression>(value == sym ? 1.f : 0.f);
}

auto SymExpression::clone() -> std::shared_ptr<Expression>
{ 
	return std::make_shared<SymExpression>(*this);
}

@define_methods+=
auto FunExpression::derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression>
{ 
	@derive_functions
	return nullptr;
}

auto FunExpression::clone() -> std::shared_ptr<Expression>
{ 
	return std::make_shared<FunExpression>(*this);
}

@expression_methods+=
auto isOne() -> bool;

@define_methods+=
auto Expression::isOne() -> bool
{
	auto n = dynamic_cast<NumExpression*>(this);
	return n && n->num == 1.f;
}

@composition_rule=
auto dl = left->derive(sym);
std::shared_ptr<Expression> p = std::make_shared<MulExpression>(l, dl);
if(dl->isZero()) {
	return dl;
} else if(dl->isOne()) {
	p = l;
}

@derive_functions=
if(name == "cos") {
	// -sin(u)*u'
	auto l = std::make_shared<FunExpression>("sin", [](std::complex<float> x) { return std::sin(x); }, left->clone());
	@composition_rule
	return std::make_shared<PrefixSubExpression>(p);
}

else if(name == "sin") {
	// cos(u)*u'
	auto l = std::make_shared<FunExpression>("cos", [](std::complex<float> x) { return std::cos(x); }, left->clone());
	@composition_rule
	return p;
}

else if(name == "sqrt") {
	// u'/(2*sqrt(u))
	auto dl = left->derive(sym);
	if(dl->isZero()) {
		return dl;
	}

	auto t = std::make_shared<NumExpression>(2.f);
	auto p = std::make_shared<MulExpression>(t, clone());
	auto d = std::make_shared<DivExpression>(dl, p);
	return d;
}

@define_methods+=
auto ExpExpression::derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression>
{ 
	@derive_exp
	return nullptr;
}

auto ExpExpression::clone() -> std::shared_ptr<Expression>
{ 
	return std::make_shared<ExpExpression>(left, right);
}

@derive_exp=
// for now just support constant exponents (for simplicity)
auto nr = std::dynamic_pointer_cast<NumExpression>(right);
if(nr) {
	std::complex<float> exp = nr->num;
	if(exp == 1.f) {
		return left->derive(sym);
	}
	auto n = std::make_shared<NumExpression>(exp-1.f);
	auto x = std::make_shared<ExpExpression>(left->clone(), n);
	auto l = std::make_shared<MulExpression>(nr->clone(), x);

	@composition_rule

	return p;
}

@sym_token_methods+=
auto infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> override;

@define_methods+=
auto SymToken::infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression>
{
	if(sym != "e") {
		return nullptr;
	}

	auto right = p->parse(70); // SHOULD NOT be hardcoded here
	auto base = std::make_shared<NumExpression>(10.f);
	auto exp10 = std::make_shared<ExpExpression>(base, right);
	return std::make_shared<MulExpression>(left, exp10);
}
