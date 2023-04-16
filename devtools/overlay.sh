#!/bin/bash

# Using this file requires cloning the LLVM project into this repo.
# git clone --depth 1 git@github.com:llvm/llvm-project.git

# Overlay the existing overlay at llvm-project/utils/bazel/llvm-project-overlay
# with the files in rules_ll/llvm-bazel-overlay.
#
# If a BUILD.bazel file is already present in the original
# llvm-project-overlay, we append the contents of the BUILD.bazel file
# in the rules_ll overlay to the existing file. This way we don't break
# the existing overlay while still being able to add targets to the
# original BUILD.bazel files.

if [ ! -d llvm-project ]; then
    printf '%s\n' \
        "Error: llvm-project not cloned into rules_ll."
    exit 1
fi

find llvm-project-overlay -type d -exec \
    mkdir -p llvm-project/utils/bazel/{} \;

find llvm-project-overlay -type f -exec \
    sh -c 'cat "$1" >> llvm-project/utils/bazel/"$1"' sh {} \;

# Create a diff and write it to the patches directory.
cd llvm-project || exit
git add utils/bazel/*
git diff --staged > ../patches/rules_ll_overlay_patch.diff
git reset --hard
