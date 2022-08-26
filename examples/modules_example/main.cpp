#include <iostream>

import A;
import C;
import D;

auto main() -> int {
  std::cout << "a: " << A::a << "\n"
            << "b: " << A::b << "\n"
            << "c: " << C::c() << "\n"
            << "d: " << D::d() << std::endl;
  return 0;
}
