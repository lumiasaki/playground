//
//  TWEndpointDataSerializer.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/7.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWNetworkDataJSONSerializer.h"

@implementation TWNetworkDataJSONSerializer

+ (NSData *)serializeDictionary:(NSDictionary *)dictionary error:(NSError *__autoreleasing *)error {
    NSData *result = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:error];
    if (!*error) {
        return result;
    }
    
    return nil;
}

+ (id)deserializeData:(NSData *)data error:(NSError *__autoreleasing *)error {
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments
                                                             error:error];
    if (!*error) {
        return result;
    }
    
    return nil;
}

+ (NSString *)contentType {
    return @"application/json";
}

@end
