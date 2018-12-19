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

@interface TWNetworkConfiguration ()

@property (nonatomic, strong) TWNetworkDataJSONSerializer *jsonSerializer;
@property (nonatomic, strong) TWNetworkDataFormURLEncodedSerializer *formURLEncodedSerializer;

@end

@implementation TWNetworkConfiguration

+ (instancetype)sharedConfiguration {
    static TWNetworkConfiguration *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TWNetworkConfiguration alloc] init];
    });
    return instance;
}

- (NSString *)authToken {
    return TWAuthorizationManager.sharedManager.authToken;
}

- (NSString *)baseUrl {
    return @"https://api.twitter.com/";
}

- (id<TWNetworkDataSerializer>)serializer:(TWNetworkDataSerializerType)serializerType {
    switch (serializerType) {
        case TWNetworkDataSerializerJSONType:
            return self.jsonSerializer;
        case TWNetworkDataSerializerFormURLEncodedType:
            return self.formURLEncodedSerializer;
        default:
            return self.jsonSerializer;
    }
}

#pragma mark - getters

- (TWNetworkDataJSONSerializer *)jsonSerializer {
    if (!_jsonSerializer) {
        _jsonSerializer = [[TWNetworkDataJSONSerializer alloc] init];
    }
    return _jsonSerializer;
}

- (TWNetworkDataFormURLEncodedSerializer *)formURLEncodedSerializer {
    if (!_formURLEncodedSerializer) {
        _formURLEncodedSerializer = [[TWNetworkDataFormURLEncodedSerializer alloc] init];
    }
    return _formURLEncodedSerializer;
}

@end

@implementation TWNetworkConfiguration (TWEndpointAPIRequest)

- (NSDictionary *)defaultHeadersWith:(id<TWEndpointAPIRequest>)request {
    return @{};
}

@end
