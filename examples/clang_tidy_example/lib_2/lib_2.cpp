#include <iostream>

#include "lib_2_private.hpp"

auto print_lib_2_string() -> void {
  std::cout << lib_2_private_string;  // Triggers clang-tidy.
}
