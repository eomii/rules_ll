#include <array>
#include <cassert>
#include <iostream>

#include "cuda_runtime.h"

constexpr float kInputA = 1.0F;
constexpr float kInputB = 2.0F;
constexpr float kExpectedOutput = 3.0F;
constexpr int kDimension = 1 << 20;
constexpr auto kThreadsPerBlockX = 128;
constexpr auto kThreadsPerBlockY = 1;
constexpr auto kThreadsPerBlockZ = 1;

template <typename T>
constexpr void cuda_assert(const T value) {
  assert((value == cudaSuccess));
}

__global__ void add_vector(float *input_a, const float *input_b,
                           const int dimension) {
  const uint32_t index = blockIdx.x * blockDim.x + threadIdx.x;
  if (index < dimension) {
    // NOLINTNEXTLINE cppcoreguidelines-pro-bounds-pointer-arithmetic
    input_a[index] += input_b[index];
  }
}

void print_device_info() {
  int count = 0;
  const cudaError_t err = cudaGetDeviceCount(&count);
  if (err == cudaErrorInvalidDevice) {
    std::cout << "FAIL: invalid device" << '\n';
  }
  std::cout << "Number of devices is " << count << '\n';

  cudaDeviceProp device_prop{};
  cuda_assert(cudaGetDeviceProperties(&device_prop, 0));
  std::cout << "System major: " << device_prop.major << '\n';
  std::cout << "System minor: " << device_prop.minor << '\n';
  std::cout << "Device name : ";
  for (auto character : device_prop.name) {
    std::cout << character;
  }
  std::cout << '\n';
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
  print_device_info();

  float *host_input_a = nullptr;
  float *host_input_b = nullptr;

  // NOLINTBEGIN cppcoreguidelines-pro-type-reinterpret-cast
  cuda_assert(cudaMallocHost(reinterpret_cast<void **>(&host_input_a),
                             kDimension * sizeof(float)));
  cuda_assert(cudaMallocHost(reinterpret_cast<void **>(&host_input_b),
                             kDimension * sizeof(float)));
  // NOLINTEND cppcoreguidelines-pro-type-reinterpret-cast

  for (int i = 0; i < kDimension; i++) {
    host_input_a[i] =  // NOLINT cppcoreguidelines-pro-bounds-pointer-arithmetic
        kInputA;
    host_input_b[i] =  // NOLINT cppcoreguidelines-pro-bounds-pointer-arithmetic
        kInputB;
  }

  float *device_input_a = nullptr;
  float *device_input_b = nullptr;
  cuda_assert(cudaMalloc(&device_input_a, kDimension * sizeof(float)));
  cuda_assert(cudaMalloc(&device_input_b, kDimension * sizeof(float)));

  cuda_assert(cudaMemcpy(device_input_a, host_input_a,
                         kDimension * sizeof(float), cudaMemcpyHostToDevice));
  cuda_assert(cudaMemcpy(device_input_b, host_input_b,
                         kDimension * sizeof(float), cudaMemcpyHostToDevice));

  const dim3 grid_dim = dim3(kDimension / kThreadsPerBlockX);
  const dim3 block_dim = dim3(kThreadsPerBlockX);

  // This is not pretty, but it is close to the HIP implementation.
  // NOLINTBEGIN cppcoreguidelines-pro-type-reinterpret-cast
  // NOLINTBEGIN cppcoreguidelines-pro-type-const-cast
  std::array<void *, 3> args = {
      &device_input_a, &device_input_b,
      reinterpret_cast<void *>(const_cast<int *>(&kDimension))};
  cudaLaunchKernel(reinterpret_cast<void *>(add_vector), grid_dim, block_dim,
                   args.data(), 0, nullptr);
  // NOLINTEND cppcoreguidelines-pro-type-reinterpret-cast
  // NOLINTEND cppcoreguidelines-pro-type-const-cast

  cuda_assert(cudaMemcpy(host_input_a, device_input_a,
                         kDimension * sizeof(float), cudaMemcpyDeviceToHost));

  const int errors = count_errors(host_input_a);

  cuda_assert(cudaFree(device_input_a));
  cuda_assert(cudaFree(device_input_b));
  cuda_assert(cudaFreeHost(host_input_a));
  cuda_assert(cudaFreeHost(host_input_b));

  return errors;
}
