module;

#include <string_view>

export module hello_world:hello;

export namespace hello_world {

auto hello() -> std::string_view { return std::string_view{"Hello"}; }

} // namespace hello_world
