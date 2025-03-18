# Rust log4rs Demo with Flutter

This project demonstrates how to integrate Rust's log4rs library with a Flutter application to:
1. Log messages from Rust to the console
2. Save log files to the device's sandbox directory

## Prerequisites

- Flutter SDK
- Rust toolchain
- For Android: Android NDK (tested with NDK 23.1.7779620)
- For iOS: Xcode and Cocoapods

## Setup

1. Install Flutter and Rust if you haven't already.
2. For Android development, install the Android NDK.
3. For iOS development, install Xcode and Cocoapods.

### Setting up Rust for Cross-Compilation

First, add the required targets for Rust:

```bash
rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android
rustup target add aarch64-apple-ios x86_64-apple-ios
```

### Android NDK Setup

The build script expects the Android NDK at the following path:
```
/Users/enlee/code/Android/SDK/ndk/23.1.7779620
```

If your NDK is in a different location, edit the `build_android.sh` script and update the `ANDROID_NDK_HOME` variable with your actual NDK path.

## Building

### 1. Verify Android NDK setup (for Android builds)

Run the setup script to verify your NDK installation:

```bash
./setup_android.sh
```

### 2. Build the Rust libraries

For Android only:
```bash
./build_android.sh
```

For all platforms:
```bash
./build_rust.sh
```

This will:
- Build the Rust library for Android (arm64-v8a, armeabi-v7a, x86, x86_64)
- Build the Rust library for iOS (arm64, x86_64)
- Create a universal binary for iOS

### 3. Build the Flutter app

```bash
flutter pub get
flutter build apk  # For Android
flutter build ios  # For iOS
```

## Troubleshooting

### Android NDK Issues

- If you get an error about missing Android toolchain, make sure your NDK is installed correctly and the path is set properly in the build script.
- The error `error: linker 'aarch64-linux-android24-clang' not found` means the build script can't find the Android NDK toolchain. Update the `ANDROID_NDK_HOME` path in the build scripts.

### Rust Compilation Issues

- If you're getting errors about missing targets, make sure you've added the required targets using rustup:
  ```
  rustup target add aarch64-linux-android armv7-linux-androideabi i686-linux-android x86_64-linux-android
  ```

## How it works

1. The Flutter app gets the app's documents directory path.
2. This path is passed to the Rust code via FFI.
3. Rust initializes log4rs with both console and file appenders.
4. Log messages are written to both the console and the log file.

## Project Structure

- `lib/` - Flutter Dart code
- `rust/` - Rust library code using log4rs
- `ios/` - iOS specific configurations
- `android/` - Android specific configurations
