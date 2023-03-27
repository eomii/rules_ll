#include <iostream>
#include "hip.hpp"
#include "a_wrapper.hpp"

auto main() -> int {
    a_wrapper();
    std::cout << hip_func() << std::endl;
}
