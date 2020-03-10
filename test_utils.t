@test_utils.h=
#pragma once
@includes

struct Test
{
	@methods
	@member_variables
};

@define_template_methods

@test_utils.cpp=
#include "test_utils.h"

@define_methods

@includes=
#include <string>

@methods=
template<typename T>
static auto assert_eq(const std::string& name, const T& result, const T& expected);

@define_template_methods=
template<typename T>
auto Test::assert_eq(const std::string& name, const T& result, const T& expected)
{
	@show_test_header
	@test_eq
	@show_results_and_update_counters

}

@includes+=
#include <iostream>

@show_test_header=
std::cout << "TEST: " << name << std::endl;
std::cout << "RESULT: " << result << std::endl;
std::cout << "EXPECTED: " << expected << std::endl;

@includes+=
#include <vector>

@member_variables=
static int num_passed;
static int num_failed;
static std::vector<std::string> failed_names;

@define_methods=
int Test::num_passed = 0;
int Test::num_failed = 0;
std::vector<std::string> Test::failed_names;

@test_eq=
std::cout << "EQUALITY TEST" << std::endl;
bool pass = result == expected;

@show_results_and_update_counters=
if(pass) {
	std::cout << "OK" << std::endl;
	num_passed++;
} else {
	std::cout << "FAIL" << std::endl;
	num_failed++;
	failed_names.push_back(name);
}

@methods+=
auto showResults() -> void;

@define_methods+=
auto Test::showResults() -> void
{
	std::cout << "Passed: " << num_passed << std::endl;
	std::cout << "Failed: " << num_failed << std::endl;
	if(num_failed == 0) {
		std::cout << "ALL OK!" << std::endl;
	}
	for(const auto& fn : failed_names) {
		std::cout << "\t" << fn << std::endl;
	}
}

@methods+=
template<typename T>
static auto assert_neq(const std::string& name, const T& result, const T& expected);

@define_template_methods+=
template<typename T>
auto Test::assert_neq(const std::string& name, const T& result, const T& expected)
{
	@show_test_header
	@test_neq
	@show_results_and_update_counters
}

@test_neq=
std::cout << "NON EQUALITY TEST" << std::endl;
bool pass = result != expected;

@methods+=
template<typename T>
static auto assert_null(const std::string& name, const T& result);

@define_template_methods+=
template<typename T>
auto Test::assert_null(const std::string& name, const T& result)
{
	std::shared_ptr<int> expected = nullptr; // type not relevant
	@show_test_header_pointer
	@test_null
	@show_results_and_update_counters
}

@show_test_header_pointer=
std::cout << "TEST: " << name << std::endl;
std::cout << "RESULT: " << result.get() << std::endl;
std::cout << "EXPECTED: " << expected.get() << std::endl;

@test_null=
std::cout << "NULL TEST" << std::endl;
bool pass = result == nullptr;
