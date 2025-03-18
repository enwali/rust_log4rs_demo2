#!/bin/bash
set -e  # 当脚本中的任何命令返回非零状态时立即退出

# 构建Android和iOS平台的Rust库
cd "$(dirname "$0")"  # 切换到脚本所在目录

# 确保已安装cargo和rustup工具
if ! command -v cargo &> /dev/null; then
    echo "未找到cargo，请安装Rust: https://www.rust-lang.org/tools/install"
    exit 1
fi

if ! command -v rustup &> /dev/null; then
    echo "未找到rustup，请安装Rust: https://www.rust-lang.org/tools/install"
    exit 1
fi

# 设置Android NDK路径 - 使用用户指定的路径
export ANDROID_NDK_HOME="/Users/enlee/code/Android/SDK/ndk/23.1.7779620"
echo "使用Android NDK路径: $ANDROID_NDK_HOME"

# 设置NDK工具链路径
export TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64"
echo "使用Android工具链路径: $TOOLCHAIN"

# 将Android工具链添加到PATH环境变量
export PATH="$TOOLCHAIN/bin:$PATH"

# 更新Rust工具链（如需要）
# rustup update

# 添加Android目标平台
rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android

# 添加iOS目标平台
rustup target add aarch64-apple-ios x86_64-apple-ios

# 创建输出目录
mkdir -p rust/target/android/arm64-v8a/release        # 64位ARM架构（最新设备）
mkdir -p rust/target/android/armeabi-v7a/release      # 32位ARM架构（旧设备）
mkdir -p rust/target/android/x86/release              # 32位x86架构（模拟器）
mkdir -p rust/target/android/x86_64/release           # 64位x86架构（模拟器）

# 构建Android库
echo "开始构建Android库..."
cd rust

# 创建.cargo/config.toml文件，配置正确的链接器路径
mkdir -p .cargo
cat > .cargo/config.toml << EOF
[target.aarch64-linux-android]
rustflags = ["-C", "link-arg=-Wl,--no-rosegment"]  # 特定的链接器标志，解决某些Android版本的链接问题
linker = "$TOOLCHAIN/bin/aarch64-linux-android24-clang"  # 使用NDK中的clang编译器作为链接器
ar = "$TOOLCHAIN/bin/llvm-ar"  # 使用NDK中的ar工具

[target.armv7-linux-androideabi]
rustflags = ["-C", "link-arg=-Wl,--no-rosegment"]
linker = "$TOOLCHAIN/bin/armv7a-linux-androideabi24-clang"
ar = "$TOOLCHAIN/bin/llvm-ar"

[target.i686-linux-android]
rustflags = ["-C", "link-arg=-Wl,--no-rosegment"]
linker = "$TOOLCHAIN/bin/i686-linux-android24-clang"
ar = "$TOOLCHAIN/bin/llvm-ar"

[target.x86_64-linux-android]
rustflags = ["-C", "link-arg=-Wl,--no-rosegment"]
linker = "$TOOLCHAIN/bin/x86_64-linux-android24-clang"
ar = "$TOOLCHAIN/bin/llvm-ar"
EOF

# 构建ARM64架构
echo "构建ARM64架构..."
cargo build --release --target aarch64-linux-android
cp target/aarch64-linux-android/release/librust_log4rs_demo2.so target/android/arm64-v8a/release/

# 构建ARMv7架构
echo "构建ARMv7架构..."
cargo build --release --target armv7-linux-androideabi
cp target/armv7-linux-androideabi/release/librust_log4rs_demo2.so target/android/armeabi-v7a/release/

# 构建x86架构
echo "构建x86架构..."
cargo build --release --target i686-linux-android
cp target/i686-linux-android/release/librust_log4rs_demo2.so target/android/x86/release/

# 构建x86_64架构
echo "构建x86_64架构..."
cargo build --release --target x86_64-linux-android
cp target/x86_64-linux-android/release/librust_log4rs_demo2.so target/android/x86_64/release/

# 构建iOS库
echo "开始构建iOS库..."
# 从PATH中移除Android工具链，避免iOS构建使用Android工具
export PATH=$(echo $PATH | tr ':' '\n' | grep -v "Android" | tr '\n' ':' | sed 's/:$//')

# 设置iOS SDK路径
export IOS_SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path)  # 获取iOS设备SDK路径
export IOS_SIMULATOR_SDK_PATH=$(xcrun --sdk iphonesimulator --show-sdk-path)  # 获取iOS模拟器SDK路径
echo "使用iOS SDK路径: $IOS_SDK_PATH"
echo "使用iOS模拟器SDK路径: $IOS_SIMULATOR_SDK_PATH"

# 设置iOS环境变量
export IOS_CC=$(xcrun -find -sdk iphoneos clang)  # 找到iOS设备的clang编译器
export IOS_AR=$(xcrun -find -sdk iphoneos ar)     # 找到iOS设备的ar工具
export IOS_SIM_CC=$(xcrun -find -sdk iphonesimulator clang)  # 找到iOS模拟器的clang编译器
echo "使用iOS clang编译器: $IOS_CC"
echo "使用iOS模拟器clang编译器: $IOS_SIM_CC"
echo "使用iOS ar工具: $IOS_AR"

# 创建iOS特定的cargo配置
cat > .cargo/config.toml << EOF
[target.aarch64-apple-ios]
rustflags = [
    "-C", "link-arg=-arch",
    "-C", "link-arg=arm64",
    "-C", "link-arg=-isysroot",
    "-C", "link-arg=$IOS_SDK_PATH"
]
linker = "$IOS_CC"
ar = "$IOS_AR"

[target.x86_64-apple-ios]
rustflags = [
    "-C", "link-arg=-arch",
    "-C", "link-arg=x86_64",
    "-C", "link-arg=-isysroot",
    "-C", "link-arg=$IOS_SIMULATOR_SDK_PATH"
]
linker = "$IOS_SIM_CC"
ar = "$IOS_AR"
EOF

# 提供跳过iOS构建的选项（用于调试）
if [ "${SKIP_IOS_BUILD:-no}" = "yes" ]; then
    echo "根据请求跳过iOS构建"
else
    # 构建iOS设备库（仅ARM64架构，用于实际设备）
    echo "构建iOS ARM64架构..."
    cargo build --release --target aarch64-apple-ios
    
    # 创建iOS输出目录
    mkdir -p target/ios/release
    
    # 复制iOS库文件（如果存在）
    if [ -f "target/aarch64-apple-ios/release/librust_log4rs_demo2.a" ]; then
        cp target/aarch64-apple-ios/release/librust_log4rs_demo2.a target/ios/release/
    fi
    
    if [ -f "target/aarch64-apple-ios/release/librust_log4rs_demo2.dylib" ]; then
        cp target/aarch64-apple-ios/release/librust_log4rs_demo2.dylib target/ios/release/
    fi
    
    # 构建iOS模拟器库（x86_64架构）
    echo "构建iOS模拟器（x86_64架构）..."
    cargo build --release --target x86_64-apple-ios || echo "iOS模拟器构建失败，继续执行..."
fi

echo "Rust构建完成！"
echo "运行'flutter build apk'构建Android应用，或'flutter build ios'构建iOS应用，以包含Rust库。"
cd .. 