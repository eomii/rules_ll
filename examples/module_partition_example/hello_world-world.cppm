module;

#include <string_view>

export module hello_world:world;

export namespace hello_world {

auto world() -> std::string_view { return std::string_view{"World!"}; }

} // namespace hello_world
