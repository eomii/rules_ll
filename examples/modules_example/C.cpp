module;

#include <iostream>

module C;

namespace C {

auto c_implementation() -> void {
  std::cout << "Hello from module C implementation!" << std::endl;
}

} // namespace C
