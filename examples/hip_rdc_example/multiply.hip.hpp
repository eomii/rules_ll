#include "hip/hip_runtime.h"

__device__ auto multiply_vector(float *input_a, const float *input_b,
                                const int dimension) -> void;
