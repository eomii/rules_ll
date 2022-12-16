#include <iostream>

#include "lib_1_private.hpp"

auto print_lib_1_string() -> void {
  int an_uninitialized_variable;  // Triggers clang-tidy.

#ifdef A_LOCAL_DEFINE
  std::cout << "A_LOCAL_DEFINE was defined in lib_1.\n";
#endif

#ifdef A_PUBLIC_DEFINE
  std::cout << "A_PUBLIC_DEFINE was defined in lib_1.\n";
#endif

#ifndef PRIVATE_HEADER
  std::cout << "PRIVATE_HEADER was not defined.\n";
#endif

#ifdef PUBLIC_HEADER
  std::cout << "PUBLIC_HEADER defined.\n";
#endif

  std::cout << lib_1_private_string;
}
