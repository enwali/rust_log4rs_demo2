#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

// Rust functions exposed to Dart through FFI
bool init_logger(const char* log_file_path);
void log_info(const char* message);
void log_debug(const char* message);
void log_warn(const char* message);
void log_error(const char* message);
char* string_to_c(const char* s);
void free_string(char* s); 