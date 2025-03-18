Pod::Spec.new do |s|
  s.name             = 'rust_log4rs_demo2'
  s.version          = '0.1.0'
  s.summary          = 'Rust library for log4rs integration'
  s.description      = <<-DESC
A Rust library that implements logging with log4rs for use in Flutter apps.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'your-email@example.com' }
  s.source           = { :path => '.' }
  s.platform         = :ios, '11.0'
  s.source_files     = '../ios/Runner/bridge_generated.h'
  s.vendored_libraries = 'target/universal/release/librust_log4rs_demo2.a'
  s.static_framework = true
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2',
  }
  s.script_phase = {
    :name => 'Build Rust Library',
    :script => <<-EOS
    set -e
    cd "$PODS_TARGET_SRCROOT"
    mkdir -p target/universal/release
    
    if [ -f "target/aarch64-apple-ios/release/librust_log4rs_demo2.a" ] && [ -f "target/x86_64-apple-ios/release/librust_log4rs_demo2.a" ]; then
      lipo -create \
        target/aarch64-apple-ios/release/librust_log4rs_demo2.a \
        target/x86_64-apple-ios/release/librust_log4rs_demo2.a \
        -output target/universal/release/librust_log4rs_demo2.a
    elif [ -f "target/aarch64-apple-ios/release/librust_log4rs_demo2.a" ]; then
      cp target/aarch64-apple-ios/release/librust_log4rs_demo2.a target/universal/release/
    elif [ -f "target/x86_64-apple-ios/release/librust_log4rs_demo2.a" ]; then
      cp target/x86_64-apple-ios/release/librust_log4rs_demo2.a target/universal/release/
    fi
    EOS
  }
end 