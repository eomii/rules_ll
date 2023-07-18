#!/nix/store/a7f7xfp9wyghf44yv6l6fv9dfw492hd3-bash-5.2-p15/bin/bash
#
# Copyright 2015 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Ship the environment to the C++ action
#
set -eu

# Set-up the environment


# Call the C++ compiler
/nix/store/cqx7pimzhgvw5gr409mz70fsws55ggkj-clang-wrapper-16.0.6/bin/clang "$@"
