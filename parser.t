@parser.h=
#pragma once
@includes

struct Expression
{
	@expression_method
	@expression_member
};

@expression_derive_structs

struct Parser
{
	@parser_constructor
	@parser_method
	@parser_member_variables
};

@parser.cpp
#include "parser.h"

@define_expression_method

@define_parser_constructor
@define_parser_method
@define_parser_member_variables

@includes=
#include <string>

@parser_member_variables=
std::string buffer;
int i;

@parser_constructor=
Parser(const std::string& text);

@define_parser_constructor=
Parser(const std::string& text) :
	buffer(text), i(0)
{
}

@parser_method=
auto getc() -> char;

@define_parser_method=
auto Parser::getc() -> char
{
	return buffer[i];
}

@parser_method+=
auto nextc() -> char;

@define_parser_method+=
auto Parser::nextc() -> char
{
	return buffer[++i];
}

@parser_method=
// skip whitespaces (' ', \n, \t)
auto skip() -> void;

@includes+=
#include <cctype>

@define_parser_method=
auto Parser::skip() -> void
{
	for(char c=getc(); c && !std::isspace(c); c=nextc());
}

@parser_method+=
auto nextc() -> char;

@define_parser_method+=
auto Parser::nextc() -> char
{
	return buffer[++i];
}

@includes+=
#include <memory>

@parser_method+=
auto parseAll() -> std::shared_ptr<Expression>;

@define_parser_method+=
auto Parser::parseAll() -> std::shared_ptr<Expression>
{
	@call_parse_until_finish
}

@call_parse_until_finish=
@parse_first_term
while(true) {
	@parse_binary_operation
	@break_if_buffer_empty_or_right_parenthesis
}

@parse_first_term=
parseTerm();

@parser_methods+=
auto parseTerm() -> std::shared_ptr<Expression>;

@define_parser_methods+=
auto parseTerm() -> std::shared_ptr<Expression>
{
	skip();
	@parse_whole_if_parenthesis
	@parse_number
	@parse_variable
}

@parser_member_variables+=
bool hasError = false;

@parser_method+=
auto verify(char c) -> void;

@define_parser_method+=
auto verify(char c) -> void;

@parse_whole_if_parenthesis=
if(getc() == '(') {
	
}
