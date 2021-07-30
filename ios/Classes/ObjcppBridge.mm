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

+ (NSString*)callRunewithInput: (uint8_t *_Nonnull)input
                   withLengths: (NSArray*_Nonnull)lengths {
    

    
    std::vector<uint8_t *> input_vector;
    std::vector<uint32_t> input_length_vector;
    int i;
    int pos =0;
    for (i = 0; i < lengths.count; ++i)
    {

        printf("######## Input %i first values [%i %i %i %i] with length %i\n",i,*(input+pos),*(input+pos+1),*(input+pos+2),*(input+pos+3),[lengths[i] intValue]);
        input_vector.push_back((input+pos));
        printf("######## Input vector %i first values [%i %i %i %i] with length %lu\n",i,*(input_vector.at(i)),*(input_vector.at(i)+1),*(input_vector.at(i)+2),*(input_vector.at(i)+3),input_vector.size());
        
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
