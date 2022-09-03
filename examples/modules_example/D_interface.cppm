module;

#include <iostream>

export module D;

export namespace D {
auto d_implementation() -> void;
auto d_interface() -> void {
  std::cout << "Hello from module D interface!" << std::endl;
}
} // namespace D
