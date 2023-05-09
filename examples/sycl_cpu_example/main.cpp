#include <SYCL/sycl.hpp>
#include <iostream>

class vector_addition;

int main(int, char **) {
  sycl::float4 a = {1.0, 2.0, 3.0, 4.0};
  sycl::float4 b = {4.0, 3.0, 1.0, 1.0};
  sycl::float4 c = {0.0, 0.0, 0.0, 0.0};

  sycl::queue queue(sycl::default_selector{});
  std::cout << "Running on "
            << queue.get_device().get_info<sycl::info::device::name>() << "\n";

  {  // start of scope, ensures data copied back to host
    sycl::buffer<sycl::float4, 1> a_sycl(&a, sycl::range<1>{1});
    sycl::buffer<sycl::float4, 1> b_sycl(&b, sycl::range<1>{1});
    sycl::buffer<sycl::float4, 1> c_sycl(&c, sycl::range<1>{1});

    queue.submit([&](sycl::handler &cgh) {
      auto a_acc = a_sycl.get_access<sycl::access::mode::read>(cgh);
      auto b_acc = b_sycl.get_access<sycl::access::mode::read>(cgh);
      auto c_acc = c_sycl.get_access<sycl::access::mode::write>(cgh);

      cgh.single_task<class vector_addition>(
          [=]() { c_acc[0] = a_acc[0] + b_acc[0]; });
    });
  }  // end of scope, ensures data copied back to host

  std::cout << "  A { " << a.x() << ", " << a.y() << ", " << a.z() << ", "
            << a.w() << " }\n"
            << "+ B { " << b.x() << ", " << b.y() << ", " << b.z() << ", "
            << b.w() << " }\n"
            << "------------------\n"
            << "= C { " << c.x() << ", " << c.y() << ", " << c.z() << ", "
            << c.w() << " }" << std::endl;

  return 0;
}
