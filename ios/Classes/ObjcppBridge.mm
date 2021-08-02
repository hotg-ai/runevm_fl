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

+ (NSString*)callRunewithInput: (const uint8_t *_Nonnull)input
                   withLengths: (NSArray*_Nonnull)lengths {
    

    
    std::vector<uint8_t *> input_vector;
    std::vector<uint32_t> input_length_vector;
    int i;
    int pos =0;
    for (i = 0; i < lengths.count; ++i)
    {

        input_vector.push_back(reinterpret_cast<uint8_t*>(const_cast<uint8_t*>(input+pos)));
        input_length_vector.push_back((uint32_t)[lengths[i] intValue]);
        pos = pos + [lengths[i] intValue];
    }

    
    const auto optJson = runic_common::callRune(input_vector, input_length_vector );
    if(!optJson)
        return nullptr;
    
    return [NSString stringWithCString:optJson->c_str() encoding:[NSString defaultCStringEncoding]];
}

+ (float) floatFromBytes: (const uint8_t *_Nonnull) bytes {
    return *(float *)bytes;
}

@end
