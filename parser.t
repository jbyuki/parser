@parser.h=
#pragma once
@includes

@expression_structs

struct Parser
{
	@constructor
	@method
	@member_variables
};

@parser.cpp=
#include "parser.h"

@define_constructor
@define_method

@includes=
#include <string>

@constructor=
Parser(const std::string& text);

@includes+=
#include "tokenizer.h"

@member_variables=
Tokenizer tokenizer;

@define_constructor=
Parser::Parser(const std::string& text) :
	tokenizer(text)
{
}
