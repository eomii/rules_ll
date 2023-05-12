"""# `//ll:transitions.bzl`

Transitions used by the `ll_toolchain` rule.
"""

COMPILATION_MODES = [
    "bootstrap",
    "cpp",
    "omp_cpu",
    "cuda_nvptx",
    "hip_amdgpu",
    "hip_nvptx",
    "wasm",
]

def _ll_transition_impl(
        settings,  # @unused
        attr):
    for mode in COMPILATION_MODES:
        if attr.compilation_mode == mode:
            return {"//ll:current_ll_toolchain_configuration": mode}

    fail("Invalid compilation_mode. Could not transition.")

ll_transition = transition(
    implementation = _ll_transition_impl,
    inputs = ["//ll:current_ll_toolchain_configuration"],
    outputs = ["//ll:current_ll_toolchain_configuration"],
)

def _transition_to_bootstrap_impl(
        settings,  # @unused
        attr):  # @unused
    return {"//ll:current_ll_toolchain_configuration": "bootstrap"}

transition_to_bootstrap = transition(
    implementation = _transition_to_bootstrap_impl,
    inputs = ["//ll:current_ll_toolchain_configuration"],
    outputs = ["//ll:current_ll_toolchain_configuration"],
)

def _transition_to_cpp_impl(
        settings,  # @unused
        attr):  # @unused
    return {"//ll:current_ll_toolchain_configuration": "cpp"}

transition_to_cpp = transition(
    implementation = _transition_to_cpp_impl,
    inputs = ["//ll:current_ll_toolchain_configuration"],
    outputs = ["//ll:current_ll_toolchain_configuration"],
)
