#!/bin/bash
set -e

echo "Building Rust libraries for Android..."

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

# Add Android toolchain to PATH
export PATH="$TOOLCHAIN/bin:$PATH"

# Check if the Android clang compiler for ARM64 is available
CLANG_AARCH64="$TOOLCHAIN/bin/aarch64-linux-android24-clang"
if [ ! -f "$CLANG_AARCH64" ]; then
    echo "Warning: ARM64 compiler not found at $CLANG_AARCH64"
    echo "Checking other possible locations..."
    
    # Try other API levels
    for API in 21 22 23 24 25 26 27 28 29 30 31 32 33; do
        ALT_CLANG="$TOOLCHAIN/bin/aarch64-linux-android${API}-clang"
        if [ -f "$ALT_CLANG" ]; then
            echo "Found alternative compiler at $ALT_CLANG"
            echo "Updating .cargo/config.toml to use API level $API"
            
            # Update the cargo config
            mkdir -p rust/.cargo
            cat > rust/.cargo/config.toml << EOF
[target.aarch64-linux-android]
rustflags = ["-C", "link-arg=-Wl,--no-rosegment"]
linker = "aarch64-linux-android${API}-clang"

[target.armv7-linux-androideabi]
rustflags = ["-C", "link-arg=-Wl,--no-rosegment"]
linker = "armv7a-linux-androideabi${API}-clang"

[target.i686-linux-android]
rustflags = ["-C", "link-arg=-Wl,--no-rosegment"]
linker = "i686-linux-android${API}-clang"

[target.x86_64-linux-android]
rustflags = ["-C", "link-arg=-Wl,--no-rosegment"]
linker = "x86_64-linux-android${API}-clang"

[target.aarch64-apple-ios]
linker = "clang"
ar = "ar"

[target.x86_64-apple-ios]
linker = "clang"
ar = "ar"
EOF
            break
        fi
    done
else
    echo "ARM64 compiler found at $CLANG_AARCH64"
    
    # Create standard cargo config
    mkdir -p rust/.cargo
    cat > rust/.cargo/config.toml << EOF
[target.aarch64-linux-android]
rustflags = ["-C", "link-arg=-Wl,--no-rosegment"]
linker = "aarch64-linux-android24-clang"

[target.armv7-linux-androideabi]
rustflags = ["-C", "link-arg=-Wl,--no-rosegment"]
linker = "armv7a-linux-androideabi24-clang"

[target.i686-linux-android]
rustflags = ["-C", "link-arg=-Wl,--no-rosegment"]
linker = "i686-linux-android24-clang"

[target.x86_64-linux-android]
rustflags = ["-C", "link-arg=-Wl,--no-rosegment"]
linker = "x86_64-linux-android24-clang"

[target.aarch64-apple-ios]
linker = "clang"
ar = "ar"

[target.x86_64-apple-ios]
linker = "clang"
ar = "ar"
EOF
fi

# List clang compilers to help debugging
echo "Available Android clang compilers:"
ls -la $TOOLCHAIN/bin/*-clang 2>/dev/null || echo "No clang compilers found"

# Create output directories
mkdir -p rust/target/android/arm64-v8a/release
mkdir -p rust/target/android/armeabi-v7a/release
mkdir -p rust/target/android/x86/release
mkdir -p rust/target/android/x86_64/release

# Build for Android
echo "Building for Android..."
cd rust

# ARM64 (aarch64)
echo "Building for ARM64..."
ANDROID_TARGET=aarch64-linux-android
if cargo build --release --target $ANDROID_TARGET; then
    echo "✅ Build successful for $ANDROID_TARGET"
    cp target/$ANDROID_TARGET/release/librust_log4rs_demo2.so target/android/arm64-v8a/release/
else
    echo "❌ Build failed for $ANDROID_TARGET"
fi

# ARMv7 (armv7)
echo "Building for ARMv7..."
ANDROID_TARGET=armv7-linux-androideabi
if cargo build --release --target $ANDROID_TARGET; then
    echo "✅ Build successful for $ANDROID_TARGET"
    cp target/$ANDROID_TARGET/release/librust_log4rs_demo2.so target/android/armeabi-v7a/release/
else
    echo "❌ Build failed for $ANDROID_TARGET"
fi

# x86 (i686)
echo "Building for x86..."
ANDROID_TARGET=i686-linux-android
if cargo build --release --target $ANDROID_TARGET; then
    echo "✅ Build successful for $ANDROID_TARGET"
    cp target/$ANDROID_TARGET/release/librust_log4rs_demo2.so target/android/x86/release/
else
    echo "❌ Build failed for $ANDROID_TARGET"
fi

# x86_64
echo "Building for x86_64..."
ANDROID_TARGET=x86_64-linux-android
if cargo build --release --target $ANDROID_TARGET; then
    echo "✅ Build successful for $ANDROID_TARGET"
    cp target/$ANDROID_TARGET/release/librust_log4rs_demo2.so target/android/x86_64/release/
else
    echo "❌ Build failed for $ANDROID_TARGET"
fi

echo "Android build completed!"
echo "Run 'flutter build apk' to create the Android app with the compiled Rust libraries."
cd .. 