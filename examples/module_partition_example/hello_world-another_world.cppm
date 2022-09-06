module;

#include <iostream>

export module hello_world:another_world;

export namespace hello_world {

auto reincarnate() -> void {
  std::cout << "Hello from another world!" << std::endl;
}

} // namespace hello_world
