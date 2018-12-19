//
//  TWEndpointDirectMessagesEventsNewRequest.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/6.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWEndpointDirectMessagesEventsNewRequest.h"

@interface TWEndpointDirectMessagesEventsNewRequest ()

@property (nonatomic, strong) NSDictionary *params;

@end

@implementation TWEndpointDirectMessagesEventsNewRequest

- (instancetype)initWithParams:(NSDictionary *)params {
    if (self = [super init]) {
        _params = params;
    }
    return self;
}

- (NSString *)endpoint {
    return @"1.1/direct_messages/events/new.json";
}

- (NSString *)httpMethod {
    return @"POST";
}

- (NSDictionary *)params {
    // it's easier in swift, for constructing a params with nest dictionary
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *eventParams = [[NSMutableDictionary alloc] init];

    params[@"event"] = eventParams;
    eventParams[@"type"] = @"message_create";
    
    NSMutableDictionary *messageCreateParams = [[NSMutableDictionary alloc] init];
    eventParams[@"message_create"] = messageCreateParams;
    
    messageCreateParams[@"target"] = @{@"recipient_id": _params[@"recipient_id"] ?: @""};
    messageCreateParams[@"message_data"] = @{@"text": _params[@"text"] ?: @""};
    
    return params.copy;
}

- (NSDictionary *)additionalHeaders {
    return @{@"Content-Type" : @"application/json"};
}

- (TWNetworkDataSerializerType)serializerType {
    return TWNetworkDataSerializerJSONType;
}

- (TWNetworkDataSerializerType)deserializerType {
    return TWNetworkDataSerializerJSONType;
}

@end

