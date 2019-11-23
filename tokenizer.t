@tokenizer.h=
#pragma once
@includes

@token_struct
@expression_struct

struct Tokenizer
{
	@constructor
	@get_next
	@member_variables
};

@tokenizer.cpp=
#include "tokenizer.h"

@define_expression_methods
@define_token_methods

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


@get_next=
auto next() -> const Token&;

@member_variables+=
int i = 0;

@define_get_next=
auto Tokenizer::next() -> const Token&
{
	return tokens[i++];
}

@expression_struct+=
struct UnaryExpression : Expression
{
	std::shared_ptr<Expression> left;
};

struct BinaryExpression : Expression
{
	std::shared_ptr<Expression> left;
};
