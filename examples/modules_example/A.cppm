module;

#include <iostream>

export module A;

export import B;

export namespace A {

auto a() -> void { std::cout << "Hello from module A interface!" << std::endl; }

} // namespace A
