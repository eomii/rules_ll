export module hello_world:another_world;

import std;

export namespace hello_world {

auto reincarnate() -> void {
  std::cout << "Hello from another world!" << std::endl;
}

}  // namespace hello_world
