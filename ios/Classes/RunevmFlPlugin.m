#import "RunevmFlPlugin.h"

#if __has_include(<runevm_fl/runevm_fl-Swift.h>)
#import <runevm_fl/runevm_fl-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "runevm_fl-Swift.h"


#endif
#include "ObjcppBridge.h"
@implementation RunevmFlPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftRunevmFlPlugin registerWithRegistrar:registrar];
}


@end
