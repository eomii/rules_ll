#include <iostream>

#include "add.hip.hpp"
#include "hip/hip_runtime.h"
#include "multiply.hip.hpp"

constexpr float kInputA = 1.0F;
constexpr float kInputB = 2.0F;
constexpr float kInputC = 3.0F;
constexpr float kExpectedOutput = 9.0F;
constexpr int kDimension = 1 << 20;
constexpr auto kThreadsPerBlockX = 128;
constexpr auto kThreadsPerBlockY = 1;
constexpr auto kThreadsPerBlockZ = 1;

constexpr auto hip_assert(const hipError_t value) -> void {
  assert((value == hipSuccess));
}

__global__ auto multiply_add(float *input_a, const float *input_b,
                             const float *input_c, const int dimension)
    -> void {
  add_vector(input_a, input_b, dimension);
  multiply_vector(input_a, input_c, dimension);
}

auto count_errors(const float *result) -> int {
  int errors = 0;
  for (int i = 0; i < kDimension; i++) {
    // NOLINTNEXTLINE cppcoreguidelines-pro-bounds-pointer-arithmetic
    if (result[i] != kExpectedOutput) {
      errors++;
    }
  }

  if (errors != 0) {
    std::cout << "Vector calculation failed:" << errors << " errors\n";
  } else {
    std::cout << "Vector calculation passed.\n";
  }
  return errors;
}

auto main() -> int {
  float *host_input_a = nullptr;
  float *host_input_b = nullptr;
  float *host_input_c = nullptr;

  // NOLINTBEGIN cppcoreguidelines-pro-type-reinterpret-cast
  hip_assert(hipMallocHost(reinterpret_cast<void **>(&host_input_a),
                           kDimension * sizeof(float)));
  hip_assert(hipMallocHost(reinterpret_cast<void **>(&host_input_b),
                           kDimension * sizeof(float)));
  hip_assert(hipMallocHost(reinterpret_cast<void **>(&host_input_c),
                           kDimension * sizeof(float)));
  // NOLINTEND cppcoreguidelines-pro-type-reinterpret-cast

  // NOLINTBEGIN cppcoreguidelines-pro-bounds-pointer-arithmetic
  for (int i = 0; i < kDimension; i++) {
    host_input_a[i] = kInputA;
    host_input_b[i] = kInputB;
    host_input_c[i] = kInputC;
  }
  // NOLINTEND cppcoreguidelines-pro-bounds-pointer-arithmetic

  float *device_input_a = nullptr;
  float *device_input_b = nullptr;
  float *device_input_c = nullptr;

  hip_assert(hipMalloc(&device_input_a, kDimension * sizeof(float)));
  hip_assert(hipMalloc(&device_input_b, kDimension * sizeof(float)));
  hip_assert(hipMalloc(&device_input_c, kDimension * sizeof(float)));

  hip_assert(hipMemcpy(device_input_a, host_input_a, kDimension * sizeof(float),
                       hipMemcpyHostToDevice));
  hip_assert(hipMemcpy(device_input_b, host_input_b, kDimension * sizeof(float),
                       hipMemcpyHostToDevice));
  hip_assert(hipMemcpy(device_input_c, host_input_c, kDimension * sizeof(float),
                       hipMemcpyHostToDevice));

  dim3 grid_dim = dim3(kDimension / kThreadsPerBlockX);
  dim3 block_dim = dim3(kThreadsPerBlockX);

  hipLaunchKernelGGL(multiply_add, grid_dim, block_dim, 0, nullptr,
                     device_input_a, device_input_b, device_input_c,
                     kDimension);

  hip_assert(hipMemcpy(host_input_a, device_input_a, kDimension * sizeof(float),
                       hipMemcpyDeviceToHost));

  const int errors = count_errors(host_input_a);

  hip_assert(hipFree(device_input_a));
  hip_assert(hipFree(device_input_b));
  hip_assert(hipFree(device_input_c));

  hip_assert(hipHostFree(host_input_a));
  hip_assert(hipHostFree(host_input_b));
  hip_assert(hipHostFree(host_input_c));

  return errors;
}
