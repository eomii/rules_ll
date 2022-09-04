module;

#include <iostream>

export module a;

export import b;

export namespace a {

auto a() -> void { std::cout << "Hello from module A interface!" << std::endl; }

} // namespace a
