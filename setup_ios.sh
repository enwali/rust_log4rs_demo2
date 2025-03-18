#!/bin/bash
set -e

echo "设置iOS项目的Rust库..."

# 创建iOS库文件夹
mkdir -p ios/libs

# 复制ARM64架构（真机）的静态库
if [ -f "rust/target/aarch64-apple-ios/release/librust_log4rs_demo2.a" ]; then
    cp rust/target/aarch64-apple-ios/release/librust_log4rs_demo2.a ios/libs/
    echo "已复制ARM64架构的静态库"
fi

# 复制x86_64架构（模拟器）的静态库
if [ -f "rust/target/x86_64-apple-ios/release/librust_log4rs_demo2.a" ]; then
    cp rust/target/x86_64-apple-ios/release/librust_log4rs_demo2.a ios/libs/librust_log4rs_demo2_simulator.a
    echo "已复制x86_64架构的静态库"
fi

# 复制通用库（如果存在）
if [ -f "rust/target/universal/release/librust_log4rs_demo2.a" ]; then
    cp rust/target/universal/release/librust_log4rs_demo2.a ios/libs/librust_log4rs_demo2_universal.a
    echo "已复制通用库"
fi

# 复制头文件
if [ -f "rust/src/wrapper.h" ]; then
    cp rust/src/wrapper.h ios/libs/
    echo "已复制头文件"
else
    # 创建头文件
    cat > ios/libs/wrapper.h << EOF
#ifndef RUST_LOG4RS_DEMO_WRAPPER_H
#define RUST_LOG4RS_DEMO_WRAPPER_H

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// 这些函数应该与Rust库中的函数签名匹配
bool init_logger(const char* log_dir);
void log_debug(const char* message);
void log_info(const char* message);
void log_warn(const char* message);
void log_error(const char* message);

#ifdef __cplusplus
}
#endif

#endif // RUST_LOG4RS_DEMO_WRAPPER_H
EOF
    echo "创建了头文件wrapper.h"
fi

echo "iOS项目设置完成，请在Xcode中添加这些库文件到项目中。" 