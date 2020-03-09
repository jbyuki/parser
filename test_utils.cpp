#include "test_utils.h"

int Test::num_passed = 0;
int Test::num_failed = 0;
std::vector<std::string> Test::failed_names;

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


