#include <stdio.h>  // This will tigger clang-tidy [llvm-include-order].
#include "lib_1_public.h"
#include "lib_2_public.h"

int main() {
  int a;  // This will trigger clang-tidy [cppcoreguidelines-init-variables].

#ifndef A_LOCAL_DEFINE
  printf("PASS: A_LOCAL_DEFINE was not defined in executable.\n");
#else
  printf("FAIL: A_LOCAL_DEFINE was defined in executable.\n");
#endif

#ifdef A_PUBLIC_DEFINE
  printf("PASS: A_PUBLIC_DEFINE was defined in executable.\n");
#else
  printf("FAIL: A PUBLIC_DEFINE was not defined in executable.\n");
#endif

   print_lib_1_string();
   print_lib_1_additional_source_string();
   print_lib_2_string();
   return 0;
}
