use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use log::{debug, error, info, trace, warn, LevelFilter};
use log4rs::append::console::ConsoleAppender;
use log4rs::append::file::FileAppender;
use log4rs::encode::pattern::PatternEncoder;
use log4rs::config::{Appender, Config, Root};
use std::sync::Once;

static INIT: Once = Once::new();

/// Initializes the log4rs configuration with console and file appenders
/// 
/// # Arguments
/// 
/// * `log_file_path` - Path to the log file in the app's sandbox directory
#[no_mangle]
pub extern "C" fn init_logger(log_file_path: *const c_char) -> bool {
    if log_file_path.is_null() {
        return false;
    }

    let log_path = unsafe {
        match CStr::from_ptr(log_file_path).to_str() {
            Ok(s) => s.to_string(),
            Err(_) => return false,
        }
    };

    INIT.call_once(|| {
        // Create a console appender
        let console = ConsoleAppender::builder()
            .encoder(Box::new(PatternEncoder::new("[{d(%Y-%m-%d %H:%M:%S)}][{l}][{t}] {m}{n}")))
            .build();

        // Create a file appender
        let file = match FileAppender::builder()
            .encoder(Box::new(PatternEncoder::new("[{d(%Y-%m-%d %H:%M:%S)}][{l}][{t}] {m}{n}")))
            .build(log_path.clone()) {
                Ok(appender) => appender,
                Err(err) => {
                    eprintln!("Failed to create file appender: {}", err);
                    return;
                }
            };

        // Build the log4rs config
        let config = match Config::builder()
            .appender(Appender::builder().build("console", Box::new(console)))
            .appender(Appender::builder().build("file", Box::new(file)))
            .build(Root::builder()
                .appender("console")
                .appender("file")
                .build(LevelFilter::Debug)) {
                    Ok(config) => config,
                    Err(err) => {
                        eprintln!("Failed to build log4rs config: {}", err);
                        return;
                    }
                };

        // Initialize the logger
        match log4rs::init_config(config) {
            Ok(_) => {
                trace!("Trace log level enabled");
                debug!("Debug log level enabled");
                info!("Logger initialized with file path: {}", log_path);
                warn!("Warning log level enabled");
                error!("Error log level enabled");
            },
            Err(err) => {
                eprintln!("Failed to initialize log4rs: {}", err);
            }
        }
    });

    true
}

/// Logs a message at the info level
/// 
/// # Arguments
/// 
/// * `message` - The message to log
#[no_mangle]
pub extern "C" fn log_info(message: *const c_char) {
    let msg = unsafe {
        if message.is_null() {
            return;
        }
        match CStr::from_ptr(message).to_str() {
            Ok(s) => s,
            Err(_) => return,
        }
    };
    
    info!("{}", msg);
}

/// Logs a message at the debug level
/// 
/// # Arguments
/// 
/// * `message` - The message to log
#[no_mangle]
pub extern "C" fn log_debug(message: *const c_char) {
    let msg = unsafe {
        if message.is_null() {
            return;
        }
        match CStr::from_ptr(message).to_str() {
            Ok(s) => s,
            Err(_) => return,
        }
    };
    
    debug!("{}", msg);
}

/// Logs a message at the warn level
/// 
/// # Arguments
/// 
/// * `message` - The message to log
#[no_mangle]
pub extern "C" fn log_warn(message: *const c_char) {
    let msg = unsafe {
        if message.is_null() {
            return;
        }
        match CStr::from_ptr(message).to_str() {
            Ok(s) => s,
            Err(_) => return,
        }
    };
    
    warn!("{}", msg);
}

/// Logs a message at the error level
/// 
/// # Arguments
/// 
/// * `message` - The message to log
#[no_mangle]
pub extern "C" fn log_error(message: *const c_char) {
    let msg = unsafe {
        if message.is_null() {
            return;
        }
        match CStr::from_ptr(message).to_str() {
            Ok(s) => s,
            Err(_) => return,
        }
    };
    
    error!("{}", msg);
}

/// Converts a Rust string to a C string
/// 
/// # Arguments
/// 
/// * `s` - The Rust string to convert
/// 
/// # Safety
/// 
/// The caller is responsible for freeing the returned pointer using `free_string`
#[no_mangle]
pub extern "C" fn string_to_c(s: &str) -> *mut c_char {
    CString::new(s).unwrap().into_raw()
}

/// Frees a C string created by `string_to_c`
/// 
/// # Arguments
/// 
/// * `s` - The C string to free
/// 
/// # Safety
/// 
/// The pointer must have been created by `string_to_c`
#[no_mangle]
pub extern "C" fn free_string(s: *mut c_char) {
    unsafe {
        if !s.is_null() {
            let _ = CString::from_raw(s);
        }
    }
} 