#include <array>
#include <format>
#include <iostream>
#include <vector>

#include "hip_dependent.hpp"
#include "hip/hip_runtime.h"

constexpr float kInputA = 1.0F;
constexpr float kInputB = 2.0F;
constexpr float kExpectedOutput = 3.0F;
constexpr int kDimension = 1 << 20;
constexpr auto kThreadsPerBlockX = 128;
constexpr auto kThreadsPerBlockY = 1;
constexpr auto kThreadsPerBlockZ = 1;

template <typename T>
constexpr void hip_assert(const T value) {
  assert((value == hipSuccess));
}

__global__ auto add_vector(float *input_a, const float *input_b,
                           const int dimension) -> void {
  int index = hipBlockIdx_x * hipBlockDim_x + hipThreadIdx_x;
  if (index < dimension) {
    // NOLINTNEXTLINE cppcoreguidelines-pro-bounds-pointer-arithmetic
    input_a[index] += input_b[index];
  }
}

void print_device_info() {
  int count = 0;
  hipError_t err = hipGetDeviceCount(&count);
  if (err == hipErrorInvalidDevice) {
    std::cout << "FAIL: invalid device" << std::endl;
  }
  std::cout << "Number of devices is " << count << std::endl;

  hipDeviceProp_t device_prop;
  hip_assert(hipGetDeviceProperties(&device_prop, 0));
  std::cout << "System major: " << device_prop.major << std::endl;
  std::cout << "System minor: " << device_prop.minor << std::endl;
  std::cout << "Device name : ";
  for (auto character : device_prop.name) {
    std::cout << character;
  }
  std::cout << std::endl;
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

auto gpu_calculation() -> int {
  print_device_info();

  float *host_input_a = nullptr;
  float *host_input_b = nullptr;

  // NOLINTBEGIN cppcoreguidelines-pro-type-reinterpret-cast
  hip_assert(hipHostMalloc(reinterpret_cast<void **>(&host_input_a),
                           kDimension * sizeof(float)));
  hip_assert(hipHostMalloc(reinterpret_cast<void **>(&host_input_b),
                           kDimension * sizeof(float)));
  // NOLINTEND cppcoreguidelines-pro-type-reinterpret-cast

  // NOLINTBEGIN cppcoreguidelines-pro-bounds-pointer-arithmetic
  for (int i = 0; i < kDimension; i++) {
    host_input_a[i] = kInputA;
    host_input_b[i] = kInputB;
  }
  // NOLINTEND cppcoreguidelines-pro-bounds-pointer-arithmetic

  float *device_input_a = nullptr;
  float *device_input_b = nullptr;

  hip_assert(hipMalloc(&device_input_a, kDimension * sizeof(float)));
  hip_assert(hipMalloc(&device_input_b, kDimension * sizeof(float)));

  hip_assert(hipMemcpy(device_input_a, host_input_a, kDimension * sizeof(float),
                       hipMemcpyHostToDevice));
  hip_assert(hipMemcpy(device_input_b, host_input_b, kDimension * sizeof(float),
                       hipMemcpyHostToDevice));

  dim3 grid_dim = dim3(kDimension / kThreadsPerBlockX);
  dim3 block_dim = dim3(kThreadsPerBlockX);

  hipLaunchKernelGGL(add_vector, grid_dim, block_dim, 0, nullptr,
                     device_input_a, device_input_b, kDimension);

  hip_assert(hipMemcpy(host_input_a, device_input_a, kDimension * sizeof(float),
                       hipMemcpyDeviceToHost));

  const int errors = count_errors(host_input_a);

  hip_assert(hipFree(device_input_a));
  hip_assert(hipFree(device_input_b));

  hip_assert(hipHostFree(host_input_a));
  hip_assert(hipHostFree(host_input_b));

  return errors;
}

auto gpu_hello() -> void {
  std::cout << std::format("Hello from the gpu with result {}.", gpu_calculation()) << std::endl;
}
