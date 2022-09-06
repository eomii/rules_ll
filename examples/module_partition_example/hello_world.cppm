module;

#include <iostream>

export module hello_world;

import :hello;
import :world;

// Symbols from here are available for anyone that imports hello_world.
export import :another_world;

export namespace hello_world {

// Will be linked to the implementation in hello_world_impl.cpp
auto hello_from_impl() -> void;

// Uses hello() from the :hello partition and world() from the :world partition.
auto hello_from_interface() -> void {
  std::cout << hello() << " " << world() << std::endl;
}

} // namespace hello_world
