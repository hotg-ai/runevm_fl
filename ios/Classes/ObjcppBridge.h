//
//  NSObject+Bridge.h
//  Runner
//
//  Created by Kirill Delimbetov on 15.04.2021.
//

#import <Foundation/Foundation.h>

//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

@interface ObjcppBridge : NSObject

+ ( NSArray* _Nullable )loadManifestWithBytes: (const uint8_t *_Nonnull)bytes
                                      ofLength:(int) len;
+ (NSString*_Nullable)callRunewithInput: (const uint8_t *_Nonnull)input
                   withLengths: (NSArray*_Nonnull)lengths;

+ (float) floatFromBytes: (const uint8_t *_Nonnull) input;

@end

