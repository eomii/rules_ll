"""# `//ll:os.bzl`

Automatic detection of library paths, depending on operating system.
"""

IMPOSSIBLE_TO_SUPPORT = ["opensuse-leap", "debian", "void"]

KNOWN_LIBRARY_PATHS = {
    "arch": "/usr/lib64",
    "centos": "/usr/lib64",
    "fedora": "/usr/lib64",
    "gentoo": "/usr/lib64",
    "linuxmint": "/usr/lib/x86_64-linux-gnu",
    "manjaro": "/usr/lib64",
    "opensuse-tumbleweed": "/usr/lib64",
    "rhel": "/usr/lib64",
    "ubuntu": "/usr/lib/x86_64-linux-gnu",
}

def _os_id(repository_ctx):
    os_id = None
    for line in repository_ctx.read("/etc/os-release").splitlines():
        if line.startswith("ID"):
            os_id = line.split("=")[-1]

    if os_id == None:
        fail("Could not read ID from /etc/os-release.")
    if os_id in IMPOSSIBLE_TO_SUPPORT:
        fail("""rules_ll is known not to work with this distro because its glibc
             is too old. Need at least 2.33.""")

    return os_id

def library_path(repository_ctx):
    if repository_ctx.attr.path == "autodetect":
        os_id = _os_id(repository_ctx)
        if os_id not in KNOWN_LIBRARY_PATHS.keys():
            fail(
                """Cannot autodetect library path for the os ID "{}". Please
                 file a bug report so that we can add this OS to the
                 autodetection. In the meantime you can override the
                 local_library_path setting in rules_ll_dependencies.configure
                 in your MODULE.bazel file with the path that contains Scrt1.o,
                 crti.o, crtn.o and other library files.""".format(os_id),
            )
        path = KNOWN_LIBRARY_PATHS[os_id]
    else:
        path = repository_ctx.attr.path

    return path
