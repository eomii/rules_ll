#include <iostream>

import A;
import C;
import D;

auto main() -> int {
  A::a();

  B::b();

  C::c_interface();
  C::c_implementation();

  D::d_interface();
  D::d_implementation();

  std::cout << "Hello from main!" << std::endl;

  return 0;
}
