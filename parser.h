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


struct Token;
struct Expression;

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

struct Expression
{
	virtual auto eval() -> std::complex<float> = 0;
	virtual auto print() -> std::string = 0;
	
	virtual auto derive(std::shared_ptr<std::complex<float>> sym) -> std::shared_ptr<Expression> = 0;
	
	virtual auto clone() -> std::shared_ptr<Expression> = 0;
	
	auto isZero() -> bool;
	
	auto isOne() -> bool;
	
};


