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

# Check for appropriate API level
API_LEVEL=24
for ARCH in "aarch64" "armv7a" "i686" "x86_64"; do
    CLANG="$TOOLCHAIN/bin/${ARCH}-linux-android${API_LEVEL}-clang"
    if [ ! -f "$CLANG" ] && [ ! -f "${CLANG}.cmd" ]; then
        echo "Warning: Compiler not found for $ARCH at API level $API_LEVEL"
        
        # Try to find an alternative API level
        for ALT_API in 21 22 23 25 26 27 28 29 30 31 32 33; do
            ALT_CLANG="$TOOLCHAIN/bin/${ARCH}-linux-android${ALT_API}-clang"
            if [ -f "$ALT_CLANG" ] || [ -f "${ALT_CLANG}.cmd" ]; then
                echo "Found alternative compiler at API level $ALT_API for $ARCH"
                API_LEVEL=$ALT_API
                break
            fi
        done
    else
        echo "Found compiler for $ARCH at API level $API_LEVEL"
    fi
done

echo "Using API level $API_LEVEL for Android compilation"

# Verify all required tools exist
echo "Verifying Android NDK toolchain..."
MISSING_TOOLS=0

for ARCH in "aarch64" "armv7a" "i686" "x86_64"; do
    CLANG="$TOOLCHAIN/bin/${ARCH}-linux-android${API_LEVEL}-clang"
    if [ ! -f "$CLANG" ] && [ ! -f "${CLANG}.cmd" ]; then
        echo "Error: Compiler not found for $ARCH: $CLANG"
        MISSING_TOOLS=1
    else
        echo "Found compiler for $ARCH: $CLANG"
    fi
done

if [ "$MISSING_TOOLS" -eq 1 ]; then
    echo "Some required tools are missing. Please check your NDK installation."
    exit 1
fi

# Create output directories
echo "Creating output directories..."
mkdir -p rust/target/android/arm64-v8a/release
mkdir -p rust/target/android/armeabi-v7a/release
mkdir -p rust/target/android/x86/release
mkdir -p rust/target/android/x86_64/release

# Create cargo config
echo "Creating Rust cargo config..."
mkdir -p rust/.cargo
cat > rust/.cargo/config.toml << EOF
[target.aarch64-linux-android]
rustflags = ["-C", "link-arg=-Wl,--no-rosegment"]
linker = "aarch64-linux-android${API_LEVEL}-clang"

[target.armv7-linux-androideabi]
rustflags = ["-C", "link-arg=-Wl,--no-rosegment"]
linker = "armv7a-linux-androideabi${API_LEVEL}-clang"

[target.i686-linux-android]
rustflags = ["-C", "link-arg=-Wl,--no-rosegment"]
linker = "i686-linux-android${API_LEVEL}-clang"

[target.x86_64-linux-android]
rustflags = ["-C", "link-arg=-Wl,--no-rosegment"]
linker = "x86_64-linux-android${API_LEVEL}-clang"

[target.aarch64-apple-ios]
linker = "clang"
ar = "ar"

[target.x86_64-apple-ios]
linker = "clang"
ar = "ar"
EOF

echo "Setup completed successfully! You can now run ./build_rust.sh"
echo "To build just for Android, run ./build_android.sh" 