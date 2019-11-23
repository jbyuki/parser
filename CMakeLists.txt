cmake_minimum_required(VERSION 3.1)
set(CMAKE_CXX_STANDARD 11)
project(parser)

add_library(parser STATIC
	tokenizer.cpp
	tokenizer.h
	parser.cpp
	parser.h)
