// Adapted from https://clang.llvm.org/docs/SourceBasedCodeCoverage.html
#define BAR(x) ((x) || (x))
template <typename T>
void foo(T x) {
  for (unsigned I = 0; I < 10; ++I) {
    BAR(I);
  }
}
