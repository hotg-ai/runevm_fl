//
//  ObjcppBridge.mm
//  Runner
//
//  Created by Kirill Delimbetov on 15.04.2021.
//

#import "ObjcppBridge.h"


#include "runetime.cpp"
@implementation ObjcppBridge

Runetime runetime;


+ (NSString*)loadManifestWithBytes: (const uint8_t *)bytes
                          ofLength:(int) len {
    runetime.logger = &logger;
    struct rune::Config cfg = {
        .rune = bytes,
        .rune_len = len,
    };
    std::string result = runetime.load(cfg);
    return [NSString stringWithCString:result.c_str() encoding:[NSString defaultCStringEncoding]];
}

    
+ (void)addInputTensor: (int) node_id  input:(NSData*)data type:(int) type dimensions:(NSArray*)dimensions; {

    NSUInteger length = [data length] ;
    uint8_t *bytes = (uint8_t *)[data bytes];
    uint32_t dimensionsList[[dimensions count]];
    for(int i =0;i<[dimensions count];i++) {
        dimensionsList[i]=(uint32_t)[(NSNumber *)[dimensions objectAtIndex:i] unsignedIntValue];
    }
    runetime.addInputTensor(node_id, bytes, (uint32_t)length, dimensionsList, [dimensions count], type);
    
}

std::string logs = "";
void logger(void *user_data, const char *msg, int len)
{
    if (logs.length()>0) {
        logs = logs + ",";
    }
    const std::string_view text{reinterpret_cast<const char *>(msg), static_cast<size_t>(len)};
    logs = logs + std::string{text};
}

+ (NSString *)getLogs{
    std::string log_output = "["+logs+"]";
    logs="";
    return [NSString stringWithCString:log_output.c_str() encoding:[NSString defaultCStringEncoding]];
}

+ (NSString*)callRune {
    std::string result = runetime.run();
    return [NSString stringWithCString:result.c_str() encoding:[NSString defaultCStringEncoding]];
}

+ (float) floatFromBytes: (const uint8_t *_Nonnull) bytes {
    return *(float *)bytes;
}

@end
