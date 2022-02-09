#include <cmath>
#include <iostream>

int main() {
  std::cout << "Hello, World!" << std::endl;
#ifdef _LIBCPP_VERSION
  std::cout << "PASS: This binary was linked to libc++ version "
            << _LIBCPP_VERSION << std::endl;
  std::cout << "libc++ std version is " << _LIBCPP_STD_VER << std::endl;
#else
  std::cout << "FAIL: This binary was not linked against libc++." << std::endl;
#endif

  return 0;
}
