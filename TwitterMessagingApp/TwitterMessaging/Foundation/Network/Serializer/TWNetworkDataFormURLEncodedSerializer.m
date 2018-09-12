//
//  TWNetworkDataFormURLEncodedSerializer.m
//  TwitterMessaging
//
//  Created by tianren.zhu on 2018/8/7.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWNetworkDataFormURLEncodedSerializer.h"

@implementation TWNetworkDataFormURLEncodedSerializer

- (NSData *)serializeDictionary:(NSDictionary *)dictionary {
    if (![dictionary isKindOfClass:NSDictionary.class]) {
        return nil;
    }
    
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    
    NSInteger index = 0;
    for (NSString *key in dictionary.allKeys) {
        if (![key isKindOfClass:NSString.class] || ![dictionary[key] isKindOfClass:NSString.class]) {
            continue;
        }
        
        [mutableString appendFormat:@"%@=%@", key, dictionary[key]];
        if (index++ != dictionary.allKeys.count - 1) {
            [mutableString appendString:@"&"];
        }                
    }
    
    return [mutableString dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary *)deserializeData:(NSData *)data {
    NSAssert(NO, @"unimplement");
    return nil;
}

@end
