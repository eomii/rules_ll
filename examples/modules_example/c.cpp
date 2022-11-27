module;

#include <iostream>

module c;

namespace c {

auto c_implementation() -> void {
  std::cout << "Hello from module C implementation!" << std::endl;
}

}  // namespace c
