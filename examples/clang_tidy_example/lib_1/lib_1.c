#include <stdio.h>

#include "lib_1_private.h"

void print_lib_1_string(void) {
  int an_uninitialized_variable;  // Triggers clang-tidy.

#ifdef A_LOCAL_DEFINE
  printf("A_LOCAL_DEFINE was defined in lib_1.\n");
#endif

#ifdef A_PUBLIC_DEFINE
  printf("A_PUBLIC_DEFINE was defined in lib_1.\n");
#endif

#ifndef PRIVATE_HEADER
  printf("PRIVATE_HEADER was not defined.\n");
#endif

#ifdef PUBLIC_HEADER
  printf("PUBLIC_HEADER defined.\n");
#endif

  printf("%s", lib_1_private_string);
}
