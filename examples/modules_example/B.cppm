module;

#include <iostream>

export module B;

export namespace B {

auto b() -> void { std::cout << "Hello from module B interface!" << std::endl; }

} // namespace B
