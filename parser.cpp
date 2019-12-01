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
			
			static std::unordered_map<std::string, float> constants = {
				// atan(1)*4 = pi
				{"pi", 4.f*atanf(1.f)},
				{"mu0", 4*(4.f*atanf(1.f))*1e-7f},
				
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


auto Parser::next() -> std::shared_ptr<Token>
{
	return tokens[i++];
}

auto Parser::finish() -> bool
{
	return i == (int)tokens.size();
}

auto Parser::get() -> std::shared_ptr<Token>
{
	return tokens[i];
}

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



auto Parser::getSymbol(const std::string& name) -> std::shared_ptr<float>
{
	if(symbol_table.find(name) != symbol_table.end()) {
		return symbol_table[name];
	}
	
	symbol_table[name] = std::make_shared<float>(0.f);
	return symbol_table[name];
	
}

auto Parser::removeSymbol(const std::string& name) -> void
{
	symbol_table.erase(name);
	
}

auto AddExpression::eval() -> float { return left->eval() + right->eval(); }
auto SubExpression::eval() -> float { return left->eval() - right->eval(); }
auto MulExpression::eval() -> float { return left->eval() * right->eval(); }
auto DivExpression::eval() -> float { return left->eval() / right->eval(); }
auto PrefixSubExpression::eval() -> float { return -left->eval(); }

auto AddExpression::print() -> std::string { return "(+ " + left->print() + " " + right->print() + ")"; }
auto SubExpression::print() -> std::string { return "(- " + left->print() + " " + right->print() + ")"; }
auto MulExpression::print() -> std::string { return "(* " + left->print() + " " + right->print() + ")"; }
auto DivExpression::print() -> std::string { return "(/ " + left->print() + " " + right->print() + ")"; }
auto PrefixSubExpression::print() -> std::string { return "(-" + left->print() + ")";  }


auto NumExpression::eval() -> float { return num; }
auto SymExpression::eval() -> float { return (*value); }

auto NumExpression::print() -> std::string { return std::to_string(num); }
auto SymExpression::print() -> std::string { return "[sym " + name + "]"; }

auto FunExpression::eval() -> float { return f(left->eval()); }
auto FunExpression::print() -> std::string { return "([" + name + "] " + left->print() + ")"; }


auto ExpExpression::eval() -> float { return std::powf(left->eval(), right->eval()); }
auto ExpExpression::print() -> std::string { return "(^ " + left->print() + " " + right->print() + ")"; }

