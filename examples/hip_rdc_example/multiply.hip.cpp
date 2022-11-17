#include "multiply.hip.hpp"

#include "hip/hip_runtime.h"

__device__ auto multiply_vector(float *input_a, const float *input_b,
                                const int dimension) -> void {
  int index = blockIdx.x * blockDim.x + threadIdx.x;
  if (index < dimension) {
    // NOLINTNEXTLINE cppcoreguidelines-pro-bounds-pointer-arithmetic
    input_a[index] *= input_b[index];
  }
}
