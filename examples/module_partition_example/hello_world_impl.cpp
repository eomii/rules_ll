module hello_world;

import std;

namespace hello_world {

auto hello_from_impl() -> void {
  std::cout << "Hello from hello_world impl!" << std::endl;
}

}  // namespace hello_world
