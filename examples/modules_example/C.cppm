module;

#include <iostream>

export module C;

export namespace C {

auto c_implementation() -> void;
auto c_interface() -> void {
  std::cout << "Hello from module C interface!" << std::endl;
}

} // namespace C
