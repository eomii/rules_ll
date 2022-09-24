#include "shared.hpp"
#include "subdir/shared.hpp"

auto main() -> int {
  printer();
  subdir_printer();
  return 0;
}
