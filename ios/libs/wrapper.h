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
