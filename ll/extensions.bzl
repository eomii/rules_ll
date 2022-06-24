# Modified version of configure.bzl from the original LLVM bazel overlay.

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@rules_ll//third-party-overlays:zlib.bzl", "llvm_zlib_disable", "llvm_zlib_system")
load("@rules_ll//third-party-overlays:terminfo.bzl", "llvm_terminfo_disable", "llvm_terminfo_system")

def llvm_disable_optional_support_deps():
    maybe(
        llvm_zlib_disable,
        name = "llvm_zlib",
    )

    maybe(
        llvm_terminfo_disable,
        name = "llvm_terminfo",
    )

def llvm_use_system_support_deps():
    maybe(
        llvm_zlib_system,
        name = "llvm_zlib",
    )

    maybe(
        llvm_terminfo_system,
        name = "llvm_terminfo",
    )

def _overlay_directories(repository_ctx):
    src_path = repository_ctx.path(Label("@llvm-raw//:WORKSPACE")).dirname
    bazel_path = src_path.get_child("utils").get_child("bazel")
    overlay_path = bazel_path.get_child("llvm-project-overlay")
    script_path = bazel_path.get_child("overlay_directories.py")

    python_bin = repository_ctx.which("python3")
    if not python_bin:
        # Windows typically just defines "python" as python3. The script itself
        # contains a check to ensure python3.
        python_bin = repository_ctx.which("python")

    if not python_bin:
        fail("Failed to find python3 binary")

    cmd = [
        python_bin,
        script_path,
        "--src",
        src_path,
        "--overlay",
        overlay_path,
        "--target",
        ".",
    ]
    exec_result = repository_ctx.execute(cmd, timeout = 20)

    if exec_result.return_code != 0:
        fail(("Failed to execute overlay script: '{cmd}'\n" +
              "Exited with code {return_code}\n" +
              "stdout:\n{stdout}\n" +
              "stderr:\n{stderr}\n").format(
            cmd = " ".join([str(arg) for arg in cmd]),
            return_code = exec_result.return_code,
            stdout = exec_result.stdout,
            stderr = exec_result.stderr,
        ))

def _llvm_configure_impl(repository_ctx):
    _overlay_directories(repository_ctx)

    # Create a starlark file with the requested LLVM targets.
    targets = repository_ctx.attr.targets
    for target in targets:
        if target not in ["AMDGPU", "NVPTX", "X86"]:
            fail(
                """rules_ll currently supports the following targets:
                 ["AMDGPU", "NVPTX", "X86"]. Got target "{}".
                 """.format(target),
            )

    repository_ctx.file(
        "llvm/targets.bzl",
        content = "llvm_targets = " + str(targets),
        executable = False,
    )

llvm_configure = repository_rule(
    implementation = _llvm_configure_impl,
    local = True,
    configure = True,
    attrs = {"targets": attr.string_list(
        allow_empty = False,
        doc = """List of target architectures to support. Currently, rules_ll
        supports ``AMDGPU``, ``NVPTX`` and ``X86``.
        """,
    )},
)

def _llvm_configure_extension_impl(ctx):
    targets = []
    for module in ctx.modules:
        commit = module.tags.configure[0].commit
        sha256 = module.tags.configure[0].sha256
        targets += [target for target in module.tags.configure[0].targets]

    RULES_LL_PATCH_URL = "https://raw.githubusercontent.com/eomii/rules_ll/main/patches/"

    http_archive(
        name = "llvm-raw",
        build_file_content = "# empty",
        sha256 = sha256,
        strip_prefix = "llvm-project-" + commit,
        urls = [
            "https://github.com/llvm/llvm-project/archive/{}.tar.gz".format(
                commit,
            ),
        ],
        # Bazel bug #14659 prevents us from using labels to reference files in
        # the patches attribute. The workaround below will be removed as soon as
        # the bug is fixed.
        remote_patches = {
            RULES_LL_PATCH_URL + "bzlmod_compatibility_patch.diff": "sha256-/HIivgu4q/nYj6DnoL5Y77kXINsGe2NB7XYxvIbbNEY=",
            RULES_LL_PATCH_URL + "compiler-rt_float128_patch.diff": "sha256-icBWHbeZ9bV3RyXWYS9CCLQ4tnVub2Xic2Rz9iD01xM=",
            RULES_LL_PATCH_URL + "clang_header_patch.diff": "sha256-TLL54/yJCrd5nPSDF5E4OfaodEMLl4VQ5PFd3eEsk1s=",
            RULES_LL_PATCH_URL + "mallinfo2_patch.diff": "sha256-sqeLZVxrUFCR37AWE1yK8zj7wVbKlebKLcvEeSYJa+Y=",
            RULES_LL_PATCH_URL + "rules_ll_overlay_patch.diff": "sha256-gIQzdkXhyNHy44pOT8nUvpePwWkGWKk2ie7wT99eTU4=",
        },
        remote_patch_strip = 1,
        # patches = [
        #     "@rules_ll//patches:bzlmod_compatibility_patch.diff",
        #     "@rules_ll//patches:compiler-rt_float128_patch.diff",
        #     "@rules_ll//patches:clang_header_patch.diff",
        #     "@rules_ll//patches:mallinfo2_patch.diff",
        # ],
        # patch_args = ["-p1"],
    )

    llvm_configure(name = "llvm-project", targets = targets)

    llvm_disable_optional_support_deps()

llvm_project_overlay = module_extension(
    implementation = _llvm_configure_extension_impl,
    tag_classes = {
        "configure": tag_class(
            attrs = {
                "commit": attr.string(),
                "sha256": attr.string(),
                "targets": attr.string_list(),
            },
        ),
    },
)
