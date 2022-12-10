#include <omp.h>

#include <format>
#include <iostream>

auto main() -> int {
#pragma omp parallel
  {
    auto thread_id = omp_get_thread_num();
    std::cout << std::format("Hello from thread {}!\n", thread_id);
  }

  return 0;
}
