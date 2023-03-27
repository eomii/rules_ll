#include <iostream>
#include "hip_dependent.hpp"
#include "module_wrapper.hpp"

auto main() -> int {
    module_wrapper_hello();
    gpu_hello();
}
