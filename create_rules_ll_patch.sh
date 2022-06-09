# Using this file requires cloning the LLVM project into this repo.
# git clone --depth 1 git@github.com:llvm/llvm-project.git

# Remove the existing patch.
rm patches/rules_ll_overlay_patch.diff

# Overlay the existing overlay at llvm-project/utils/bazel/llvm-project-overlay
# with the files in rules_ll/llvm-bazel-overlay.
#
# If a BUILD.bazel file is already present in the original
# llvm-project-overlay, we append the contents of the BUILD.bazel file
# in the rules_ll overlay to the existing file. This way we don't break
# the existing overlay while still being able to add targets to the
# original BUILD.bazel files.
for file in $(find llvm-project-overlay -type f); do
    if [ ! -d llvm-project/utils/bazel/${file} ]
        then mkdir -p `dirname llvm-project/utils/bazel/${file}`
    fi;
    cat ${file} >> llvm-project/utils/bazel/${file};
done

# Create a diff and write it to the patches directory.
cd llvm-project
git add utils/bazel/*
git diff --staged >> ../patches/rules_ll_overlay_patch.diff
