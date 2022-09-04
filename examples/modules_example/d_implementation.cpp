module;

#include <iostream>

module d;

namespace d {

auto d_implementation() -> void {
  std::cout << "Hello from module D implementation!" << std::endl;
}

} // namespace d
