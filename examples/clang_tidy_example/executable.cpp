#include <iostream>

#include "lib_1/lib_1_public.hpp"
#include "lib_2/lib_2_public.hpp"

auto main() -> int {
  int an_unitinialized_variable;  // Triggers clang-tidy.

#ifndef A_LOCAL_DEFINE
  std::cout << "PASS: A_LOCAL_DEFINE was not defined in executable."
            << std::endl;
#else
  std::cout << "FAIL: A_LOCAL_DEFINE was defined in executable." << std::endl;
#endif

#ifdef A_PUBLIC_DEFINE
  std::cout << "PASS: A_PUBLIC_DEFINE was defined in executable." << std::endl;
#else
  std::cout << "FAIL: A PUBLIC_DEFINE was not defined in executable."
            << std::endl;
#endif

  print_lib_1_string();
  print_lib_1_additional_source_string();
  print_lib_2_string();
  return 0;
}
