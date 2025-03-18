#!/bin/bash
set -e

echo "Searching for Android NDK installations..."

# Common paths where NDK might be installed
COMMON_PATHS=(
    "$HOME/Library/Android/sdk/ndk"
    "$HOME/Android/Sdk/ndk"
    "$HOME/code/Android/SDK/ndk"
    "/Applications/Android/sdk/ndk"
    "/usr/local/android-sdk/ndk"
    "/opt/android/sdk/ndk"
)

# Function to check if path contains NDK
check_ndk() {
    local path=$1
    if [ -d "$path" ]; then
        echo "Found potential NDK directory: $path"
        if [ -d "$path/toolchains" ]; then
            echo "✅ Confirmed NDK at: $path (contains toolchains directory)"
            
            # Check for clang compilers
            if [ -d "$path/toolchains/llvm/prebuilt" ]; then
                local prebuilt_dirs=("$path/toolchains/llvm/prebuilt"/*)
                for dir in "${prebuilt_dirs[@]}"; do
                    if [ -d "$dir/bin" ]; then
                        echo "  Platform: $(basename "$dir")"
                        if ls "$dir/bin/"*-clang >/dev/null 2>&1; then
                            echo "  Clang compilers found in: $dir/bin"
                            echo "  Available API levels:"
                            ls "$dir/bin/"*-clang | grep -o "[0-9]\+-clang" | grep -o "[0-9]\+" | sort -u | tr '\n' ' '
                            echo ""
                        else
                            echo "  ⚠️ No clang compilers found in $dir/bin"
                        fi
                    fi
                done
            else
                echo "⚠️ No LLVM toolchain found at $path/toolchains/llvm/prebuilt"
            fi
            return 0
        fi
    fi
    return 1
}

# Search for NDK in Android SDK environment variables
if [ -n "$ANDROID_SDK_ROOT" ] || [ -n "$ANDROID_HOME" ]; then
    echo "Checking environment variables..."
    if [ -n "$ANDROID_SDK_ROOT" ]; then
        echo "ANDROID_SDK_ROOT is set to: $ANDROID_SDK_ROOT"
        check_ndk "$ANDROID_SDK_ROOT/ndk"
    fi
    
    if [ -n "$ANDROID_HOME" ]; then
        echo "ANDROID_HOME is set to: $ANDROID_HOME"
        check_ndk "$ANDROID_HOME/ndk"
    fi
fi

# Check if ANDROID_NDK_HOME is set
if [ -n "$ANDROID_NDK_HOME" ]; then
    echo "ANDROID_NDK_HOME is set to: $ANDROID_NDK_HOME"
    check_ndk "$ANDROID_NDK_HOME"
fi

# Search in common paths
echo "Checking common paths for NDK installations..."
for path in "${COMMON_PATHS[@]}"; do
    if [ -d "$path" ]; then
        echo "Checking $path..."
        # Check for versioned directories
        for version_dir in "$path"/*; do
            if [ -d "$version_dir" ]; then
                check_ndk "$version_dir"
            fi
        done
    fi
done

# Recommendation for build_android.sh
echo ""
echo "===== RECOMMENDATION ====="
echo "Update build_android.sh with the full path to your NDK:"
echo "export ANDROID_NDK_HOME=\"/path/to/your/ndk\""
echo ""
echo "For example, if using NDK version 23.1.7779620:"
echo "export ANDROID_NDK_HOME=\"/Users/enlee/code/Android/SDK/ndk/23.1.7779620\"" 