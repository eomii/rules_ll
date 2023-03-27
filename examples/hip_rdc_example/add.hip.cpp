#include "add.hip.hpp"

#include "hip/hip_runtime.h"

__device__ auto add_vector(float *input_a, const float *input_b,
                           const int dimension) -> void {
  const uint32_t index = hipBlockIdx_x * hipBlockDim_x + hipThreadIdx_x;
  if (index < dimension) {
    // NOLINTNEXTLINE cppcoreguidelines-pro-bounds-pointer-arithmetic
    input_a[index] += input_b[index];
  }
}
