#!/bin/bash

# Build script for target architecture inside Docker
TARGET=$1
OUTPUT_DIR=$2

if [ -z "$TARGET" ] || [ -z "$OUTPUT_DIR" ]; then
    echo "Usage: $0 <target> <output_dir>"
    echo "Example: $0 x86_64-unknown-linux-gnu output_x86_64"
    exit 1
fi

echo "Building for target: $TARGET"

# Create output directory
mkdir -p "/workspace/$OUTPUT_DIR"

# Check if nymyac directory exists
if [ ! -d "/workspace/nymyac" ]; then
    echo "Error: nymyac directory not found"
    exit 1
fi

# Build the compiler for the specific target
cd /workspace/nymyac
cargo build --target "$TARGET" --release

if [ -f "target/$TARGET/release/nymyac" ]; then
    cp "target/$TARGET/release/nymyac" "/workspace/$OUTPUT_DIR/nymyac"
    echo "Successfully built nymyac for $TARGET"
else
    echo "Error: Binary not found for $TARGET at target/$TARGET/release/nymyac"
    exit 1
fi

# Copy the main nymya executable script
cp "/workspace/nymya" "/workspace/$OUTPUT_DIR/nymya"
chmod +x "/workspace/$OUTPUT_DIR/nymya"

echo "Build completed for $TARGET in /workspace/$OUTPUT_DIR"
