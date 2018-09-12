//
//  TWEndpointFollowerListRequest.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWEndpointFollowerListRequest.h"

@interface TWEndpointFollowerListRequest ()

@property (nonatomic, strong) NSDictionary *params;

@end

@implementation TWEndpointFollowerListRequest

- (instancetype)initWithParams:(NSDictionary *)params {
    if (self = [super init]) {
        _params = params;
    }
    return self;
}

- (NSString *)endpoint {
    return @"1.1/followers/list.json";
}

- (NSString *)httpMethod {
    return @"GET";
}

- (NSDictionary *)params {
    return _params ?: @{};
}

- (NSDictionary *)headers {
    return @{};
}

- (TWNetworkDataSerializerType)serializerType {
    return TWNetworkDataSerializerJSONType;
}

- (TWNetworkDataSerializerType)deserializerType {
    return TWNetworkDataSerializerJSONType;
}

@end
