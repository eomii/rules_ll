export module d;

import std;

export namespace d {
auto d_implementation() -> void;
auto d_interface() -> void {
  std::cout << "Hello from module D interface!" << std::endl;
}
}  // namespace d
