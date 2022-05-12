#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint runevm_fl.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'runevm_fl'
  s.version          = '0.0.1'
  s.summary          = 'RuneVM for flutter plugin'
  s.description      = <<-DESC
  RuneVM for flutter plugin
                       DESC
  s.homepage         = 'http://hotg.ai'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Hammer Of The Gods' => 'admin@hotg.ai' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.1'
  s.public_header_files = 'Classes/**/*.h'
  s.xcconfig = { 
    'LIBRARY_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/ios/install-ios-rel/lib/"', 
    'HEADER_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/ios/install-ios-rel/include/" "${PODS_TARGET_SRCROOT}/ios/Classes/"',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++17',
    'CLANG_CXX_LIBRARY' => 'libc++'
  }
  # Flutter.framework does not contain a i386 slice.
  s.vendored_libraries = 'install-ios-rel/lib/*.a'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'ENABLE_BITCODE' => 'NO' }
  s.swift_version = '5.0'
end
