//
//  TWNetworkDataSerializer.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/6.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TWNetworkDataSerializerType) {
    TWNetworkDataSerializerJSONType,
    TWNetworkDataSerializerFormURLEncodedType
};

@protocol TWNetworkDataSerializer <NSObject>

- (NSData *)serializeDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)deserializeData:(NSData *)data;

@end
