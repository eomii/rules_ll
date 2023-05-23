#include <openssl/sha.h>

#include <array>
#include <format>
#include <iostream>

auto main() -> int {
  constexpr auto kMessageSize = 5;
  std::array<unsigned char, kMessageSize> message = {'h', 'e', 'l', 'l', 'o'};

  auto *hashed_message = SHA256(message.data(), message.size(), nullptr);

  std::array<std::byte, SHA256_DIGEST_LENGTH> output = {};
  std::memcpy(output.data(), hashed_message, SHA256_DIGEST_LENGTH);

  std::cout << "Calculated:\t";
  for (auto val : output) {
    std::cout << std::format("{:0>2x}", static_cast<int>(val));
  }
  std::cout << "\n";

  std::cout
      << "Expected:\t"
      << "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
      << '\n';
}
