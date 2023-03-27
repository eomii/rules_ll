#include <iostream>
#include "hip_dependent.hpp"
#include "a_module_interface.hpp"

auto main() -> int {
    a_interface();
    hip_interface();
}
