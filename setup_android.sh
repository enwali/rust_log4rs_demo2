#!/bin/bash
set -e

echo "Setting up Android NDK environment for Rust cross-compilation..."

# Set Android NDK path
export ANDROID_NDK_HOME="/Users/enlee/code/Android/SDK/ndk/23.1.7779620"
echo "Using Android NDK at: $ANDROID_NDK_HOME"

# Verify NDK exists
if [ ! -d "$ANDROID_NDK_HOME" ]; then
    echo "Error: Android NDK not found at $ANDROID_NDK_HOME"
    echo "Please make sure the NDK is installed and the path is correct"
    exit 1
fi

# Set the path to the NDK toolchain
export TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64"
echo "Using Android toolchain at: $TOOLCHAIN"

if [ ! -d "$TOOLCHAIN" ]; then
    echo "Error: Android NDK toolchain not found at $TOOLCHAIN"
    echo "Your NDK installation might be corrupted or have a different structure"
    exit 1
fi

# Verify key binaries exist
echo "Verifying Android NDK toolchain..."
MISSING_TOOLS=0

for ARCH in "aarch64" "armv7a" "i686" "x86_64"; do
    CLANG="$TOOLCHAIN/bin/${ARCH}-linux-android24-clang"
    if [ ! -f "$CLANG" ] && [ ! -f "${CLANG}.cmd" ]; then
        echo "Error: Compiler not found for $ARCH: $CLANG"
        MISSING_TOOLS=1
    else
        echo "Found compiler for $ARCH"
    fi
done

if [ "$MISSING_TOOLS" -eq 1 ]; then
    echo "Some required tools are missing. Please check your NDK installation."
    exit 1
fi

echo "Creating output directories..."
mkdir -p android/app/src/main/jniLibs/arm64-v8a
mkdir -p android/app/src/main/jniLibs/armeabi-v7a
mkdir -p android/app/src/main/jniLibs/x86
mkdir -p android/app/src/main/jniLibs/x86_64

mkdir -p rust/target/android/arm64-v8a/release
mkdir -p rust/target/android/armeabi-v7a/release
mkdir -p rust/target/android/x86/release
mkdir -p rust/target/android/x86_64/release

echo "Setup completed successfully! You can now run ./build_rust.sh" 