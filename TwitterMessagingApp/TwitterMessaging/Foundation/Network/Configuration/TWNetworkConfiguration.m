//
//  TWNetworkConfiguration.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWNetworkConfiguration.h"
#import "TWAuthorizationManager.h"
#import "TWNetworkDataJSONSerializer.h"
#import "TWNetworkDataFormURLEncodedSerializer.h"

@implementation TWNetworkConfiguration

- (Class<TWNetworkDataSerializer>)serializer:(TWNetworkDataSerializerType)serializerType {
    switch (serializerType) {
        case TWNetworkDataSerializerJSONType:
            return TWNetworkDataJSONSerializer.class;
        case TWNetworkDataSerializerFormURLEncodedType:
            return TWNetworkDataFormURLEncodedSerializer.class;
        default:
            return TWNetworkDataJSONSerializer.class;
    }
}

@end

@implementation TWNetworkConfiguration (TWEndpointAPIRequest)

- (NSDictionary *)defaultHeadersWith:(id<TWEndpointAPIRequest>)request {
    return @{};
}

@end
