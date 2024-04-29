"""# `//ll:llvm_project_deps.bzl`

Targets from the `llvm-project-overlay` used in `depends_on_llvm`.
"""

LLVM_PROJECT_DEPS = [
    # Clang libraries.
    "@llvm-project//clang:analysis",
    "@llvm-project//clang:apinotes",
    "@llvm-project//clang:arc_migrate",
    "@llvm-project//clang:ast",
    "@llvm-project//clang:ast-diff",
    "@llvm-project//clang:ast_matchers",
    "@llvm-project//clang:ast_matchers_dynamic",
    "@llvm-project//clang:basic",
    "@llvm-project//clang:clang-driver",
    "@llvm-project//clang:codegen",
    "@llvm-project//clang:config",
    "@llvm-project//clang:crosstu",
    "@llvm-project//clang:driver",
    "@llvm-project//clang:edit",
    "@llvm-project//clang:extract_api",
    "@llvm-project//clang:format",
    "@llvm-project//clang:frontend",
    "@llvm-project//clang:frontend_rewrite",
    "@llvm-project//clang:frontend_tool",
    "@llvm-project//clang:index",
    "@llvm-project//clang:interpreter",
    "@llvm-project//clang:lex",
    "@llvm-project//clang:libclang",
    "@llvm-project//clang:libclang_static",
    "@llvm-project//clang:parse",
    "@llvm-project//clang:rewrite",
    "@llvm-project//clang:sema",
    "@llvm-project//clang:serialization",
    "@llvm-project//clang:static_analyzer_checkers",
    "@llvm-project//clang:static_analyzer_core",
    "@llvm-project//clang:static_analyzer_core_options",
    "@llvm-project//clang:static_analyzer_frontend",
    "@llvm-project//clang:support",
    "@llvm-project//clang:tooling",
    "@llvm-project//clang:tooling_core",
    "@llvm-project//clang:tooling_dependency_scanning",
    "@llvm-project//clang:tooling_inclusions",
    "@llvm-project//clang:tooling_refactoring",
    "@llvm-project//clang:tooling_syntax",
    "@llvm-project//clang:transformer",

    # LLVM libraries.
    "@llvm-project//llvm:AggressiveInstCombine",
    "@llvm-project//llvm:AllTargetsAsmParsers",
    "@llvm-project//llvm:AllTargetsCodeGens",
    "@llvm-project//llvm:AllTargetsDisassemblers",
    "@llvm-project//llvm:AllTargetsMCAs",
    "@llvm-project//llvm:Analysis",
    "@llvm-project//llvm:AsmParser",
    "@llvm-project//llvm:BinaryFormat",
    "@llvm-project//llvm:BitReader",
    "@llvm-project//llvm:BitWriter",
    "@llvm-project//llvm:BitstreamReader",
    "@llvm-project//llvm:BitstreamWriter",
    "@llvm-project//llvm:CFGuard",
    "@llvm-project//llvm:CodeGen",
    "@llvm-project//llvm:CodeGenTypes",
    "@llvm-project//llvm:Core",
    "@llvm-project//llvm:Coroutines",
    "@llvm-project//llvm:Coverage",
    "@llvm-project//llvm:DWP",
    "@llvm-project//llvm:DebugInfo",
    "@llvm-project//llvm:DebugInfoBTF",
    "@llvm-project//llvm:DebugInfoCodeView",
    "@llvm-project//llvm:DebugInfoDWARF",
    "@llvm-project//llvm:DebugInfoGSYM",
    "@llvm-project//llvm:DebugInfoLogicalView",
    "@llvm-project//llvm:DebugInfoMSF",
    "@llvm-project//llvm:DebugInfoPDB",
    "@llvm-project//llvm:Debuginfod",
    "@llvm-project//llvm:Demangle",
    "@llvm-project//llvm:ExecutionEngine",
    # "@llvm-project//llvm:Exegesis",  # Not working properly.
    "@llvm-project//llvm:FileCheckLib",
    "@llvm-project//llvm:FrontendDriver",
    "@llvm-project//llvm:FrontendHLSL",
    "@llvm-project//llvm:FrontendOffloading",
    "@llvm-project//llvm:FrontendOpenACC",
    "@llvm-project//llvm:FrontendOpenMP",
    "@llvm-project//llvm:HipStdPar",
    "@llvm-project//llvm:IPO",
    "@llvm-project//llvm:IRPrinter",
    "@llvm-project//llvm:IRReader",
    "@llvm-project//llvm:InstCombine",
    "@llvm-project//llvm:Instrumentation",
    "@llvm-project//llvm:InterfaceStub",
    "@llvm-project//llvm:Interpreter",
    "@llvm-project//llvm:LTO",
    "@llvm-project//llvm:LibDriver",
    "@llvm-project//llvm:LineEditor",
    "@llvm-project//llvm:Linker",
    "@llvm-project//llvm:TableGenGlobalISel",
    "@llvm-project//llvm:MC",
    "@llvm-project//llvm:MCA",
    "@llvm-project//llvm:MCDisassembler",
    "@llvm-project//llvm:MCParser",
    "@llvm-project//llvm:MLPolicies",
    "@llvm-project//llvm:ObjCARC",
    "@llvm-project//llvm:Object",
    "@llvm-project//llvm:ObjectYAML",
    "@llvm-project//llvm:Option",
    "@llvm-project//llvm:Passes",
    "@llvm-project//llvm:ProfileData",
    "@llvm-project//llvm:Remarks",
    "@llvm-project//llvm:Scalar",
    "@llvm-project//llvm:Support",
    "@llvm-project//llvm:Symbolize",
    "@llvm-project//llvm:TableGen",
    "@llvm-project//llvm:Target",
    "@llvm-project//llvm:TargetParser",
    "@llvm-project//llvm:TextAPI",
    "@llvm-project//llvm:TransformUtils",
    "@llvm-project//llvm:Vectorize",
    "@llvm-project//llvm:WindowsDriver",
    "@llvm-project//llvm:attributes_gen",
    "@llvm-project//llvm:common_transforms",
    "@llvm-project//llvm:config",
    "@llvm-project//llvm:remark_linker",

    # LLD
    "@llvm-project//lld:ELF",
    "@llvm-project//lld:Common",

    # External dependencies.
    "@zlib-ng//:zlib",
    "@zstd//:zstd",

    # TODO: Ideally we'd only need to explicitly specify the AllTargets*
    # equivalents of these targets, but then we can't build new compilers
    # targeting these architectures. Check whether this is an error in the llvm
    # overlay or intended behavior.

    # AMDGPU
    "@llvm-project//llvm:AMDGPUCodeGen",
    "@llvm-project//llvm:AMDGPUDisassembler",
    "@llvm-project//llvm:AMDGPUAsmParser",
    "@llvm-project//llvm:AMDGPUTargetMCA",
    "@llvm-project//llvm:AMDGPUUtilsAndDesc",
    "@llvm-project//llvm:AMDGPUInfo",

    # WebAssembly
    "@llvm-project//llvm:WebAssemblyCodeGen",
    "@llvm-project//llvm:WebAssemblyDisassembler",
    "@llvm-project//llvm:WebAssemblyAsmParser",
    "@llvm-project//llvm:WebAssemblyTargetMCA",
    "@llvm-project//llvm:WebAssemblyUtilsAndDesc",
    "@llvm-project//llvm:WebAssemblyInfo",

    # AArch64
    "@llvm-project//llvm:AArch64CodeGen",
    "@llvm-project//llvm:AArch64Disassembler",
    "@llvm-project//llvm:AArch64AsmParser",
    "@llvm-project//llvm:AArch64TargetMCA",
    "@llvm-project//llvm:AArch64UtilsAndDesc",
    "@llvm-project//llvm:AArch64Info",

    # BPF
    "@llvm-project//llvm:BPFCodeGen",
    "@llvm-project//llvm:BPFDisassembler",
    "@llvm-project//llvm:BPFAsmParser",
    "@llvm-project//llvm:BPFTargetMCA",
    "@llvm-project//llvm:BPFUtilsAndDesc",
    "@llvm-project//llvm:BPFInfo",

    # Lanai
    "@llvm-project//llvm:LanaiCodeGen",
    "@llvm-project//llvm:LanaiDisassembler",
    "@llvm-project//llvm:LanaiAsmParser",
    "@llvm-project//llvm:LanaiTargetMCA",
    "@llvm-project//llvm:LanaiUtilsAndDesc",
    "@llvm-project//llvm:LanaiInfo",

    # MSP430
    "@llvm-project//llvm:MSP430CodeGen",
    "@llvm-project//llvm:MSP430Disassembler",
    "@llvm-project//llvm:MSP430AsmParser",
    "@llvm-project//llvm:MSP430TargetMCA",
    "@llvm-project//llvm:MSP430UtilsAndDesc",
    "@llvm-project//llvm:MSP430Info",

    # AVR
    "@llvm-project//llvm:AVRCodeGen",
    "@llvm-project//llvm:AVRDisassembler",
    "@llvm-project//llvm:AVRAsmParser",
    "@llvm-project//llvm:AVRTargetMCA",
    "@llvm-project//llvm:AVRUtilsAndDesc",
    "@llvm-project//llvm:AVRInfo",

    # Hexagon
    "@llvm-project//llvm:HexagonCodeGen",
    "@llvm-project//llvm:HexagonDisassembler",
    "@llvm-project//llvm:HexagonAsmParser",
    "@llvm-project//llvm:HexagonTargetMCA",
    "@llvm-project//llvm:HexagonUtilsAndDesc",
    "@llvm-project//llvm:HexagonInfo",

    # VE
    "@llvm-project//llvm:VECodeGen",
    "@llvm-project//llvm:VEDisassembler",
    "@llvm-project//llvm:VEAsmParser",
    "@llvm-project//llvm:VETargetMCA",
    "@llvm-project//llvm:VEUtilsAndDesc",
    "@llvm-project//llvm:VEInfo",

    # NVPTX
    "@llvm-project//llvm:NVPTXCodeGen",
    "@llvm-project//llvm:NVPTXDisassembler",
    "@llvm-project//llvm:NVPTXAsmParser",
    "@llvm-project//llvm:NVPTXTargetMCA",
    "@llvm-project//llvm:NVPTXUtilsAndDesc",
    "@llvm-project//llvm:NVPTXInfo",

    # XCore
    "@llvm-project//llvm:XCoreCodeGen",
    "@llvm-project//llvm:XCoreDisassembler",
    "@llvm-project//llvm:XCoreAsmParser",
    "@llvm-project//llvm:XCoreTargetMCA",
    "@llvm-project//llvm:XCoreUtilsAndDesc",
    "@llvm-project//llvm:XCoreInfo",

    # X86
    "@llvm-project//llvm:X86CodeGen",
    "@llvm-project//llvm:X86Disassembler",
    "@llvm-project//llvm:X86AsmParser",
    "@llvm-project//llvm:X86TargetMCA",
    "@llvm-project//llvm:X86UtilsAndDesc",
    "@llvm-project//llvm:X86Info",

    # RISCV
    "@llvm-project//llvm:RISCVCodeGen",
    "@llvm-project//llvm:RISCVDisassembler",
    "@llvm-project//llvm:RISCVAsmParser",
    "@llvm-project//llvm:RISCVTargetMCA",
    "@llvm-project//llvm:RISCVUtilsAndDesc",
    "@llvm-project//llvm:RISCVInfo",

    # Mips
    "@llvm-project//llvm:MipsCodeGen",
    "@llvm-project//llvm:MipsDisassembler",
    "@llvm-project//llvm:MipsAsmParser",
    "@llvm-project//llvm:MipsTargetMCA",
    "@llvm-project//llvm:MipsUtilsAndDesc",
    "@llvm-project//llvm:MipsInfo",

    # PowerPC
    "@llvm-project//llvm:PowerPCCodeGen",
    "@llvm-project//llvm:PowerPCDisassembler",
    "@llvm-project//llvm:PowerPCAsmParser",
    "@llvm-project//llvm:PowerPCTargetMCA",
    "@llvm-project//llvm:PowerPCUtilsAndDesc",
    "@llvm-project//llvm:PowerPCInfo",

    # SystemZ
    "@llvm-project//llvm:SystemZCodeGen",
    "@llvm-project//llvm:SystemZDisassembler",
    "@llvm-project//llvm:SystemZAsmParser",
    "@llvm-project//llvm:SystemZTargetMCA",
    "@llvm-project//llvm:SystemZUtilsAndDesc",
    "@llvm-project//llvm:SystemZInfo",

    # ARM
    "@llvm-project//llvm:ARMCodeGen",
    "@llvm-project//llvm:ARMDisassembler",
    "@llvm-project//llvm:ARMAsmParser",
    "@llvm-project//llvm:ARMTargetMCA",
    "@llvm-project//llvm:ARMUtilsAndDesc",
    "@llvm-project//llvm:ARMInfo",

    # Sparc
    "@llvm-project//llvm:SparcCodeGen",
    "@llvm-project//llvm:SparcDisassembler",
    "@llvm-project//llvm:SparcAsmParser",
    "@llvm-project//llvm:SparcTargetMCA",
    "@llvm-project//llvm:SparcUtilsAndDesc",
    "@llvm-project//llvm:SparcInfo",
]

POSIX_DEFINES = [
    "LLVM_ON_UNIX=1",
    "HAVE_BACKTRACE=1",
    "BACKTRACE_HEADER=<execinfo.h>",
    'LTDL_SHLIB_EXT=".so"',
    'LLVM_PLUGIN_EXT=".so"',
    "LLVM_ENABLE_THREADS=1",
    "LLVM_ENABLE_PLUGINS=1",
    "HAVE_DEREGISTER_FRAME=1",
    "HAVE_LIBPTHREAD=1",
    "HAVE_PTHREAD_GETNAME_NP=1",
    "HAVE_PTHREAD_H=1",
    "HAVE_PTHREAD_SETNAME_NP=1",
    "HAVE_REGISTER_FRAME=1",
    "HAVE_SETENV_R=1",
    "HAVE_STRERROR_R=1",
    "HAVE_SYSEXITS_H=1",
    "HAVE_UNISTD_H=1",
]

LINUX_DEFINES = POSIX_DEFINES + [
    "LLVM_VERSION_MAJOR=17",
    "_GNU_SOURCE",
    "HAVE_LINK_H=1",
    "HAVE_LSEEK64=1",
    "HAVE_MALLINFO=1",
    "HAVE_SBRK=1",
    "HAVE_STRUCT_STAT_ST_MTIM_TV_NSEC=1",
]
