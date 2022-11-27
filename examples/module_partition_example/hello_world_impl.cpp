module;

#include <iostream>

module hello_world;

namespace hello_world {

auto hello_from_impl() -> void {
  std::cout << "Hello from hello_world impl!" << std::endl;
}

}  // namespace hello_world
