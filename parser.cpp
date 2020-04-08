#include "parser.h"

auto Parser::process(const std::string& input) -> std::shared_ptr<Expression>
{
	tokens.clear();
	i = 0;
	
	std::istringstream iss(input);
	char c;
	iss >> std::ws;
	
	while((c = iss.peek()) != EOF) {
		if(c == '+') { iss >> c; tokens.emplace_back(new AddToken()); }
		else if(c == '-') { iss >> c; tokens.emplace_back(new SubToken()); }
		else if(c == '*') { iss >> c; tokens.emplace_back(new MulToken()); }
		else if(c == '/') { iss >> c; tokens.emplace_back(new DivToken()); }
		
		else if(c == '^') { iss >> c; tokens.emplace_back(new ExpToken()); }
		
		else if(c == '(') { iss >> c; tokens.emplace_back(new LParToken()); }
		else if(c == ')') { iss >> c; tokens.emplace_back(new RParToken()); }
		
		else if(c >= '0' && c <= '9') { 
			float num; iss>>num; 
			tokens.emplace_back(new NumToken{num});
		}
		
		else if((c >= 'a' && c <= 'z') || (c >= 'A' && 'Z')) { 
			if(tokens.size() > 0 && std::dynamic_pointer_cast<NumToken>(tokens.back())) {
				tokens.emplace_back(new MulToken());
			}
			
			std::string sym;
			do {
				iss >> c;
				sym += c;
			} while(std::isalnum(iss.peek()));
			
			static std::unordered_map<std::string, std::complex<float>> constants = {
				// atan(1)*4 = pi
				{"pi", 4.f*atanf(1.f)},
				{"mu0", 4*(4.f*atanf(1.f))*1e-7f},
				{"i", std::complex<float>(0.f, 1.f)},
				
			};
			
			if(constants.find(sym) != constants.end()) {
				tokens.emplace_back(new NumToken{constants[sym]});
			}
			
			else {
				tokens.emplace_back(new SymToken{sym});
			}
			
		}
		
		else { 
			std::cout << "ERROR: Unexcepted character '" << c << "'!" << std::endl; 
			iss >> c; 
		}
		
		iss >> std::ws;
		
	}
	
	return parse();
	
}


auto Token::prefix(Parser* parser) -> std::shared_ptr<Expression> { return nullptr; }
auto Token::infix(Parser* parser, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression> { return nullptr; }
auto Token::priority() -> int { return 0; }

auto Parser::next() -> std::shared_ptr<Token>
{
	if(i >= (int)tokens.size()) {
		return nullptr;
	}

	return tokens[i++];
}

auto Parser::finish() -> bool
{
	return i == (int)tokens.size();
}

auto Parser::get() -> std::shared_ptr<Token>
{
	if(i >= (int)tokens.size()) {
		return nullptr;
	}

	return tokens[i];
}

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

auto AddToken::prefix(Parser* p) -> std::shared_ptr<Expression>
{
	return p->parse(priority());
}

auto AddToken::infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression>
{
	auto t = p->parse(priority());
	if(!t) {
		return nullptr;
	}

	return std::make_shared<AddExpression>(left, t);
}

auto AddToken::priority() -> int { return 50; }


auto SubToken::prefix(Parser* p) -> std::shared_ptr<Expression>
{
	auto t = p->parse(90);
	if(!t) {
		return nullptr;
	}

	return std::make_shared<PrefixSubExpression>(t);
}


auto SubToken::infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression>
{
	auto t = p->parse(priority()-1);
	if(!t) {
		return nullptr;
	}
	return std::make_shared<SubExpression>(left, t);
}
auto SubToken::priority() -> int { return 50; }

auto MulToken::infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression>
{
	auto t = p->parse(priority());
	if(!t) {
		return nullptr;
	}

	return std::make_shared<MulExpression>(left, t);
}

auto MulToken::priority() -> int { return 60; }


auto DivToken::infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression>
{

	auto t = p->parse(priority()-1);
	if(!t) {
		return nullptr;
	}
	return std::make_shared<DivExpression>(left, t);
}

auto DivToken::priority() -> int { return 60; }


auto LParToken::prefix(Parser* p) -> std::shared_ptr<Expression>
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

auto LParToken::priority() -> int { return 100; }

auto RParToken::priority() -> int { return 10; }

auto NumToken::prefix(Parser*) -> std::shared_ptr<Expression>
{
	return std::make_shared<NumExpression>(num);
}

auto Parser::getSymbol(const std::string& name) -> std::shared_ptr<std::complex<float>>
{
	if(symbol_table.find(name) != symbol_table.end()) {
		return symbol_table[name];
	}
	
	symbol_table[name] = std::make_shared<std::complex<float>>(0.f);
	return symbol_table[name];
	
}

auto SymToken::prefix(Parser* p) -> std::shared_ptr<Expression>
{
	return std::make_shared<SymExpression>(sym, p->getSymbol(sym));
}

auto Parser::removeSymbol(const std::string& name) -> void
{
	symbol_table.erase(name);
	
}

auto LParToken::infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression>
{
	static std::unordered_map<std::string, std::function<std::complex<float>(std::complex<float>)>> funs = {
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

auto AddExpression::eval() -> std::complex<float> { return left->eval() + right->eval(); }
auto SubExpression::eval() -> std::complex<float> { return left->eval() - right->eval(); }
auto MulExpression::eval() -> std::complex<float> { return left->eval() * right->eval(); }
auto DivExpression::eval() -> std::complex<float> { return left->eval() / right->eval(); }
auto PrefixSubExpression::eval() -> std::complex<float> { return -left->eval(); }

auto AddExpression::print() -> std::string { return "(+ " + left->print() + " " + right->print() + ")"; }
auto SubExpression::print() -> std::string { return "(- " + left->print() + " " + right->print() + ")"; }
auto MulExpression::print() -> std::string { return "(* " + left->print() + " " + right->print() + ")"; }
auto DivExpression::print() -> std::string { return "(/ " + left->print() + " " + right->print() + ")"; }
auto PrefixSubExpression::print() -> std::string { return "(-" + left->print() + ")";  }


auto NumExpression::eval() -> std::complex<float> { return num; }
auto SymExpression::eval() -> std::complex<float> { return (*value); }

auto NumExpression::print() -> std::string { 
	return std::to_string(std::real(num)) + "+" + std::to_string(std::imag(num)) + "i"; 
}
auto SymExpression::print() -> std::string { return "[sym " + name + "]"; }

auto FunExpression::eval() -> std::complex<float> { return f(left->eval()); }
auto FunExpression::print() -> std::string { return "([" + name + "] " + left->print() + ")"; }


auto ExpToken::infix(Parser* p, std::shared_ptr<Expression> left) -> std::shared_ptr<Expression>
{
	auto t = p->parse(priority());
	if(!t) {
		return nullptr;
	}

	return std::make_shared<ExpExpression>(left, t);
}
auto ExpToken::priority() -> int { return 70; }

auto ExpExpression::eval() -> std::complex<float> { return std::pow(left->eval(), right->eval()); }
auto ExpExpression::print() -> std::string { return "(^ " + left->print() + " " + right->print() + ")"; }

auto Parser::clear() -> void
{
	symbol_table.clear();
	
}

auto Expression::isZero() -> bool
{
	auto n = dynamic_cast<NumExpression*>(this);
	return n && n->num == 0.f;
}

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

auto NumExpression::derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression>
{ 
	return std::make_shared<NumExpression>(0.f);
}

auto NumExpression::clone() -> std::shared_ptr<Expression>
{ 
	return std::make_shared<NumExpression>(*this);
}

auto SymExpression::derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression>
{ 
	return std::make_shared<NumExpression>(value == sym ? 1.f : 0.f);
}

auto SymExpression::clone() -> std::shared_ptr<Expression>
{ 
	return std::make_shared<SymExpression>(*this);
}

auto FunExpression::derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression>
{ 
	if(name == "cos") {
		// -sin(u)*u'
		auto l = std::make_shared<FunExpression>("sin", [](std::complex<float> x) { return std::sin(x); }, left->clone());
		auto dl = left->derive(sym);
		std::shared_ptr<Expression> p = std::make_shared<MulExpression>(l, dl);
		if(dl->isZero()) {
			return dl;
		} else if(dl->isOne()) {
			p = l;
		}
		
		return std::make_shared<PrefixSubExpression>(p);
	}
	
	else if(name == "sin") {
		// cos(u)*u'
		auto l = std::make_shared<FunExpression>("cos", [](std::complex<float> x) { return std::cos(x); }, left->clone());
		auto dl = left->derive(sym);
		std::shared_ptr<Expression> p = std::make_shared<MulExpression>(l, dl);
		if(dl->isZero()) {
			return dl;
		} else if(dl->isOne()) {
			p = l;
		}
		
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
	
	return nullptr;
}

auto FunExpression::clone() -> std::shared_ptr<Expression>
{ 
	return std::make_shared<FunExpression>(*this);
}

auto Expression::isOne() -> bool
{
	auto n = dynamic_cast<NumExpression*>(this);
	return n && n->num == 1.f;
}

auto ExpExpression::derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression>
{ 
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
	
		auto dl = left->derive(sym);
		std::shared_ptr<Expression> p = std::make_shared<MulExpression>(l, dl);
		if(dl->isZero()) {
			return dl;
		} else if(dl->isOne()) {
			p = l;
		}
		
	
		return p;
	}
	
	return nullptr;
}

auto ExpExpression::clone() -> std::shared_ptr<Expression>
{ 
	return std::make_shared<ExpExpression>(left, right);
}

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

