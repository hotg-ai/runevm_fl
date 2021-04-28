//
//  ObjcppBridge.mm
//  Runner
//
//  Created by Kirill Delimbetov on 15.04.2021.
//

#import "ObjcppBridge.h"

#include "runic.hpp"


@implementation ObjcppBridge

+ (NSArray*)loadManifestWithBytes: (const uint8_t *)bytes
                          ofLength:(int) len {
    const auto optCapabilities = runic_common::manifest(bytes, len, true);
    if(!optCapabilities)
        return nullptr;
    
    auto *array = [[NSMutableArray alloc] init];
    for(auto number: *optCapabilities)
        [array addObject:[NSNumber numberWithInt:number]];
    
    return array;
}

+ (NSString*)callRunewithInput: (const uint8_t *) input
                      ofLength: (int) input_length {
    const auto optJson = runic_common::callRune((uint8_t *)input, input_length );
    if(!optJson)
        return nullptr;
    
    return [NSString stringWithCString:optJson->c_str() encoding:[NSString defaultCStringEncoding]];
}

+ (float) floatFromBytes: (const uint8_t *_Nonnull) bytes {
    return *(float *)bytes;
}

@end
