//
//  TWEndpointDirectMessagesEventsListRequest.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/7.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWEndpointDirectMessagesEventsListRequest.h"

@interface TWEndpointDirectMessagesEventsListRequest ()

@property (nonatomic, strong) NSDictionary *params;

@end

@implementation TWEndpointDirectMessagesEventsListRequest

- (instancetype)initWithParams:(NSDictionary *)params {
    if (self = [super init]) {
        _params = params;
    }
    return self;
}

- (NSString *)endpoint {
    return @"1.1/direct_messages/events/list.json";
}

- (NSString *)httpMethod {
    return @"GET";
}

- (NSDictionary *)params {
    return @{
             @"dialogueId" : _params[@"dialogueId"] ?: @"",
             @"senderId" : _params[@"senderId"] ?: @"",
             @"receiverId" : _params[@"receiverId"] ?: @""             
             };
}

- (NSDictionary *)headers {
    return @{@"Content-Type" : @"application/json"};
}

- (TWNetworkDataSerializerType)serializerType {
    return TWNetworkDataSerializerJSONType;
}

- (TWNetworkDataSerializerType)deserializerType {
    return TWNetworkDataSerializerJSONType;
}

@end
