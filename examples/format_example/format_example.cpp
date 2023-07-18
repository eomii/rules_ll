import std;

auto main() -> int {
  constexpr std::string_view kExplanation =
      "You can use builtin std::format with C++20!\nMake sure to pass\n"
      "compile_flags = [\"-std=c++20\"] or\n"
      "compile_flags = [\"-std=c++2b\"]\n"
      "to ll_library and ll_binary to enable this feature.";

  std::cout << std::format("{}, {}!\n{}", "Hello", "world", kExplanation)
            << '\n';
  return 0;
}
