module;

#include <iostream>

module D;

namespace D {

auto d_implementation() -> void {
  std::cout << "Hello from module D implementation!" << std::endl;
}

} // namespace D
