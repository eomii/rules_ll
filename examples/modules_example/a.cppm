export module a;

import std;

export import b;

export namespace a {

auto a() -> void { std::cout << "Hello from module A interface!" << std::endl; }

}  // namespace a
