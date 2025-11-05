#!/bin/bash
set -e

# Post-build processing: compression and checksums
# Usage: post-build.sh <build-dir> <platform-name>

BUILD_DIR=$1
PLATFORM=$2

if [ -z "$BUILD_DIR" ] || [ -z "$PLATFORM" ]; then
    echo "Usage: post-build.sh <build-dir> <platform-name>"
    exit 1
fi

if [ ! -d "$BUILD_DIR" ]; then
    echo "Error: Build directory not found: $BUILD_DIR"
    exit 1
fi

echo "Post-processing binaries in $BUILD_DIR..."

# Compress windows and linux binaries with UPX
echo "Compressing binaries..."
if [[ $PLATFORM == "windows" || $PLATFORM == "linux" ]]; then
    upx-ucl -9 "$BUILD_DIR"/*
fi

# Calculate checksums (use sha256sum on Linux/Windows, shasum on macOS)
echo "Calculating SHA256 checksums..."
if command -v sha256sum &> /dev/null; then
    sha256sum "$BUILD_DIR"/* > "$BUILD_DIR/SHA256SUMS-$PLATFORM.txt"
else
    shasum -a 256 "$BUILD_DIR"/* > "$BUILD_DIR/SHA256SUMS-$PLATFORM.txt"
fi

echo "Post-processing complete for $PLATFORM"
