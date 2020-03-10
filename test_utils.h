#pragma once
#include <string>

#include <iostream>

#include <vector>


struct Test
{
	template<typename T>
	static auto assert_eq(const std::string& name, const T& result, const T& expected);
	
	auto showResults() -> void;
	
	template<typename T>
	static auto assert_neq(const std::string& name, const T& result, const T& expected);
	
	template<typename T>
	static auto assert_null(const std::string& name, const T& result);
	
	static int num_passed;
	static int num_failed;
	static std::vector<std::string> failed_names;
	
};

template<typename T>
auto Test::assert_eq(const std::string& name, const T& result, const T& expected)
{
	std::cout << "TEST: " << name << std::endl;
	std::cout << "RESULT: " << result << std::endl;
	std::cout << "EXPECTED: " << expected << std::endl;
	
	std::cout << "EQUALITY TEST" << std::endl;
	bool pass = result == expected;
	
	if(pass) {
		std::cout << "OK" << std::endl;
		num_passed++;
	} else {
		std::cout << "FAIL" << std::endl;
		num_failed++;
		failed_names.push_back(name);
	}
	

}

template<typename T>
auto Test::assert_neq(const std::string& name, const T& result, const T& expected)
{
	std::cout << "TEST: " << name << std::endl;
	std::cout << "RESULT: " << result << std::endl;
	std::cout << "EXPECTED: " << expected << std::endl;
	
	std::cout << "NON EQUALITY TEST" << std::endl;
	bool pass = result != expected;
	
	if(pass) {
		std::cout << "OK" << std::endl;
		num_passed++;
	} else {
		std::cout << "FAIL" << std::endl;
		num_failed++;
		failed_names.push_back(name);
	}
	
}

template<typename T>
auto Test::assert_null(const std::string& name, const T& result)
{
	std::shared_ptr<int> expected = nullptr; // type not relevant
	std::cout << "TEST: " << name << std::endl;
	std::cout << "RESULT: " << result.get() << std::endl;
	std::cout << "EXPECTED: " << expected.get() << std::endl;
	
	std::cout << "NULL TEST" << std::endl;
	bool pass = result == nullptr;
	if(pass) {
		std::cout << "OK" << std::endl;
		num_passed++;
	} else {
		std::cout << "FAIL" << std::endl;
		num_failed++;
		failed_names.push_back(name);
	}
	
}


