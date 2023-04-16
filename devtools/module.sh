#!/bin/bash

# Usage:
#
#   ./create_release.sh <tag>
#
# This script creates a directory for a module registry. The output is a
# directory named <tag>, containing the MODULE.bazel file and a source.json file
# as required for bazel registries. This directory can then be copied to the
# modules directory of a bazel registry. The registries' metadata.json still
# needs to be modified manually to make the tagged version available.

if [[ $# != 1 ]]; then
    echo 1>&2 "$0: Error: Missing tag argument."
    exit 2
fi

TAG="$1";

RELEASE_DIR=$TAG;

ARTIFACT=$(printf '%s.zip' "$TAG");

ARTIFACT_URL=$(
    printf 'https://github.com/eomii/rules_ll/archive/refs/tags/%s.zip' "$TAG"
);

STRIP_PREFIX=$(printf 'rules_ll-%s' "$TAG");

wget "$ARTIFACT_URL" || {
    echo "$0: Error: Couldn't get archive. Is the tag valid?";
    exit 2;
}

mkdir "$RELEASE_DIR";

unzip -p "$ARTIFACT" "$STRIP_PREFIX/MODULE.bazel" > "$RELEASE_DIR/MODULE.bazel";

SHA256=$(openssl sha256 -binary "$ARTIFACT" | openssl base64 -A);

printf '{
    "integrity": "sha256-%s",
    "strip_prefix": "%s",
    "url": "%s"
}
' "$SHA256" "$STRIP_PREFIX" "$ARTIFACT_URL" > "$RELEASE_DIR/source.json";

rm "$ARTIFACT";
