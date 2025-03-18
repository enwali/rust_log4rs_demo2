#ifndef RustLoggerBridge_h
#define RustLoggerBridge_h

#include <stdbool.h>

// ������Rust�����ĺ���
#ifdef __cplusplus
extern "C" {
#endif

// ��Щ����Ӧ����Rust���еĺ���ǩ��ƥ��
bool init_logger(const char* log_dir);
void log_debug(const char* message);
void log_info(const char* message);
void log_warn(const char* message);
void log_error(const char* message);

#ifdef __cplusplus
}
#endif

#endif /* RustLoggerBridge_h */ 