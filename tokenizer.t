@tokenizer.h=
#pragma once
@includes

@token_struct

struct Tokenizer
{
	@constructor
	@get_next
	@member_variables
};

@tokenizer.cpp=
#include "tokenizer.h"

@define_constructor
@define_get_next

@includes=
#include <string>

@constructor=
Tokenizer(const std::string& input);

@define_constructor=
Tokenizer::Tokenizer(const std::string& input)
{
	@tokenize_string
}

@token_struct=
struct Token
{
	enum TYPE
	{
		@token_types
	} type;

	@token_values
};


@includes+=
#include <vector>

@member_variables=
std::vector<Token> tokens;

@includes+=
#include <sstream>

@tokenize_string=
std::istringstream iss(input);
char c;
@tokenize_loop_variables

@eat_whitespaces

while((c = iss.peek()) != EOF) {
	@tokenize_op
	@tokenize_par
	@tokenize_num
	@tokenize_symbol
	@handle_error_tokenize

	@eat_whitespaces
}

@add_end_token

@eat_whitespaces=
iss >> std::ws;

@tokenize_loop_variables=
Token t;

@token_types=
ADD_OP,
SUB_OP,
MUL_OP,
DIV_OP,

@tokenize_op=
if(c == '+') { iss >> c; t.type = Token::TYPE::ADD_OP; tokens.push_back(t); }
else if(c == '-') { iss >> c; t.type = Token::TYPE::SUB_OP; tokens.push_back(t); }
else if(c == '*') { iss >> c; t.type = Token::TYPE::MUL_OP; tokens.push_back(t); }
else if(c == '/') { iss >> c; t.type = Token::TYPE::DIV_OP; tokens.push_back(t); }

@token_types+=
LPAR,
RPAR,

@tokenize_par=
else if(c == '(') { iss >> c; t.type = Token::TYPE::LPAR; tokens.push_back(t); }
else if(c == ')') { iss >> c; t.type = Token::TYPE::RPAR; tokens.push_back(t); }

@token_types+=
NUM,

@token_values=
float num;

@tokenize_num=
else if(c >= '0' && c <= '9') { iss>>t.num; t.type = Token::TYPE::NUM; tokens.push_back(t);}

@token_types+=
SYMBOL,

@token_values+=
std::string symbol;

@tokenize_symbol=
else if((c >= 'a' && c <= 'z') || (c >= 'A' && 'Z')) { iss >> t.symbol; t.type = Token::TYPE::SYMBOL; tokens.push_back(t); }

@includes+=
#include <iostream>

@handle_error_tokenize=
else { std::cout << "ERROR: Unexcepted character '" << c << "'!" << std::endl; }

@token_types+=
END,

@add_end_token=
t.type = Token::TYPE::END;
tokens.push_back(t);

@get_next=
auto next() -> const Token&;

@member_variables+=
int i = 0;

@define_get_next=
auto Tokenizer::next() -> const Token&
{
	return tokens[i++];
}
