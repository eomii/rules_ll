"""# `//ll:llvm_project_deps.bzl`

Convenience variable to depend on LLVM and Clang. Useful when building something
that would normally require forking the llvm-project repo. Put this in the
`llvm_project_deps` attribute to make them available to a target.
"""

LLVM_PROJECT_DEPS = [
    # Clang libraries.
    "@llvm-project//clang:analysis",
    "@llvm-project//clang:ast",
    "@llvm-project//clang:ast_matchers",
    "@llvm-project//clang:basic",
    "@llvm-project//clang:driver",
    "@llvm-project//clang:edit",
    "@llvm-project//clang:frontend",
    "@llvm-project//clang:lex",
    "@llvm-project//clang:parse",
    "@llvm-project//clang:sema",
    "@llvm-project//clang:serialization",
    "@llvm-project//clang:support",
    "@llvm-project//clang:tooling",

    # LLVM libraries.
    "@llvm-project//llvm:attributes_gen",
    "@llvm-project//llvm:AggressiveInstCombine",
    "@llvm-project//llvm:Analysis",
    "@llvm-project//llvm:AsmParser",
    "@llvm-project//llvm:BinaryFormat",
    "@llvm-project//llvm:BitReader",
    "@llvm-project//llvm:BitWriter",
    "@llvm-project//llvm:BitstreamReader",
    "@llvm-project//llvm:BitstreamWriter",
    "@llvm-project//llvm:CFGuard",
    "@llvm-project//llvm:Coroutines",
    "@llvm-project//llvm:CodeGen",
    "@llvm-project//llvm:Core",
    "@llvm-project//llvm:DebugInfoDWARF",
    "@llvm-project//llvm:Demangle",
    "@llvm-project//llvm:FrontendOpenMP",
    "@llvm-project//llvm:IPO",
    "@llvm-project//llvm:InstCombine",
    "@llvm-project//llvm:Instrumentation",
    "@llvm-project//llvm:IRReader",
    "@llvm-project//llvm:MC",
    "@llvm-project//llvm:MCParser",
    "@llvm-project//llvm:Object",
    "@llvm-project//llvm:Option",
    "@llvm-project//llvm:Passes",
    "@llvm-project//llvm:ProfileData",
    "@llvm-project//llvm:Remarks",
    "@llvm-project//llvm:Scalar",
    "@llvm-project//llvm:Support",
    "@llvm-project//llvm:TextAPI",
    "@llvm-project//llvm:TransformUtils",
    "@llvm-project//llvm:Vectorize",
    "@llvm-project//llvm:WindowsDriver",

    # External dependencies.
    # TODO(aaronmondal): @libxml2
    "@zlib",
]
