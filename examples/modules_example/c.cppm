export module c;

import std;

export namespace c {

auto c_implementation() -> void;
auto c_interface() -> void {
  std::cout << "Hello from module C interface!" << std::endl;
}

}  // namespace c
