export module hello_world:world;

import std;

export namespace hello_world {

auto world() -> std::string_view { return std::string_view{"World!"}; }

}  // namespace hello_world
