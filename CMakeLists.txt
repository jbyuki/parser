cmake_minimum_required(VERSION 3.1)
set(CMAKE_CXX_STANDARD 11)
project(parser)

add_executable(parser
	parser.cpp
	parser.h
	test.cpp)
