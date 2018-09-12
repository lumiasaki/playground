//
//  TWEndpointDataSerializer.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/7.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWNetworkDataJSONSerializer.h"

@implementation TWNetworkDataJSONSerializer

- (NSData *)serializeDictionary:(NSDictionary *)dictionary {
    NSError *error;
    NSData *result = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:&error];
    if (!error) {
        return result;
    }
    
    return nil;
}

- (NSDictionary *)deserializeData:(NSData *)data {
    NSError *error;
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments
 error:&error];
    if (!error && [result isKindOfClass:NSDictionary.class]) {
        return result;
    }
    
    return nil;
}

@end
