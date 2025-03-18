#!/bin/bash
set -e

# Build Rust libraries for Android and iOS
cd "$(dirname "$0")"

# Ensure cargo and rustup are available
if ! command -v cargo &> /dev/null; then
    echo "cargo not found, please install Rust: https://www.rust-lang.org/tools/install"
    exit 1
fi

if ! command -v rustup &> /dev/null; then
    echo "rustup not found, please install Rust: https://www.rust-lang.org/tools/install"
    exit 1
fi

# Set Android NDK path - using the one specified by the user
export ANDROID_NDK_HOME="/Users/enlee/code/Android/SDK/ndk/23.1.7779620"
echo "Using Android NDK at: $ANDROID_NDK_HOME"

# Set the path to the NDK toolchain
export TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64"
echo "Using Android toolchain at: $TOOLCHAIN"

# Add Android toolchain to PATH
export PATH="$TOOLCHAIN/bin:$PATH"

# Update rust toolchains if needed
# rustup update

# Add Android targets
rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android

# Add iOS targets
rustup target add aarch64-apple-ios x86_64-apple-ios

# Create output directories
mkdir -p rust/target/android/arm64-v8a/release
mkdir -p rust/target/android/armeabi-v7a/release
mkdir -p rust/target/android/x86/release
mkdir -p rust/target/android/x86_64/release

# Build for Android
echo "Building for Android..."
cd rust

# Create .cargo/config.toml with proper linker paths
mkdir -p .cargo
cat > .cargo/config.toml << EOF
[target.aarch64-linux-android]
linker = "$TOOLCHAIN/bin/aarch64-linux-android24-clang"
ar = "$TOOLCHAIN/bin/llvm-ar"

[target.armv7-linux-androideabi]
linker = "$TOOLCHAIN/bin/armv7a-linux-androideabi24-clang"
ar = "$TOOLCHAIN/bin/llvm-ar"

[target.i686-linux-android]
linker = "$TOOLCHAIN/bin/i686-linux-android24-clang"
ar = "$TOOLCHAIN/bin/llvm-ar"

[target.x86_64-linux-android]
linker = "$TOOLCHAIN/bin/x86_64-linux-android24-clang"
ar = "$TOOLCHAIN/bin/llvm-ar"

[target.aarch64-apple-ios]
linker = "clang"
ar = "ar"

[target.x86_64-apple-ios]
linker = "clang"
ar = "ar"
EOF

# ARM64
echo "Building for ARM64..."
cargo build --release --target aarch64-linux-android
cp target/aarch64-linux-android/release/librust_log4rs_demo2.so target/android/arm64-v8a/release/

# ARMv7
echo "Building for ARMv7..."
cargo build --release --target armv7-linux-androideabi
cp target/armv7-linux-androideabi/release/librust_log4rs_demo2.so target/android/armeabi-v7a/release/

# x86
echo "Building for x86..."
cargo build --release --target i686-linux-android
cp target/i686-linux-android/release/librust_log4rs_demo2.so target/android/x86/release/

# x86_64
echo "Building for x86_64..."
cargo build --release --target x86_64-linux-android
cp target/x86_64-linux-android/release/librust_log4rs_demo2.so target/android/x86_64/release/

# Build for iOS
echo "Building for iOS..."
cargo build --release --target aarch64-apple-ios
cargo build --release --target x86_64-apple-ios

# Create universal library for iOS
mkdir -p target/universal/release
# Check if both files exist before attempting to create universal binary
if [ -f "target/aarch64-apple-ios/release/librust_log4rs_demo2.a" ] && [ -f "target/x86_64-apple-ios/release/librust_log4rs_demo2.a" ]; then
  lipo -create \
    target/aarch64-apple-ios/release/librust_log4rs_demo2.a \
    target/x86_64-apple-ios/release/librust_log4rs_demo2.a \
    -output target/universal/release/librust_log4rs_demo2.a
elif [ -f "target/aarch64-apple-ios/release/librust_log4rs_demo2.a" ]; then
  cp target/aarch64-apple-ios/release/librust_log4rs_demo2.a target/universal/release/
elif [ -f "target/x86_64-apple-ios/release/librust_log4rs_demo2.a" ]; then
  cp target/x86_64-apple-ios/release/librust_log4rs_demo2.a target/universal/release/
fi

echo "Rust build completed!"
cd .. 