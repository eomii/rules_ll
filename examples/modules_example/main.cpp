import std;
import a;
import c;
import d;

auto main() -> int {
  a::a();

  b::b();

  c::c_interface();
  c::c_implementation();

  d::d_interface();
  d::d_implementation();

  std::cout << "Hello from main!" << std::endl;

  return 0;
}
