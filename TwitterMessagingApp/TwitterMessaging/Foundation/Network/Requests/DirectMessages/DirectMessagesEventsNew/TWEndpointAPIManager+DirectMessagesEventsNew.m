//
//  TWEndpointAPIManager+DirectMessagesEventsList.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/6.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWEndpointAPIManager+DirectMessagesEventsNew.h"
#import "TWEndpointDirectMessagesEventsNewRequest.h"

@implementation TWEndpointAPIManager (DirectMessagesEventsNew)

+ (TWEndpointRequestOperation *)sendDirectMessage:(NSDictionary *)params completion:(void(^)(NSError *, NSDictionary *))completion {
    __unused TWEndpointDirectMessagesEventsNewRequest *request = [[TWEndpointDirectMessagesEventsNewRequest alloc] initWithParams:params];
    
    // fake sending...
    
    if (completion) {
        // TODO:
        NSDictionary *response = request.params;
        completion(nil, response);
    }
    
    return nil;
}

@end
