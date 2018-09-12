//
//  TWEndpointAPIManager+DirectMessagesEventsList.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/6.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWEndpointAPIManager.h"

@interface TWEndpointAPIManager (DirectMessagesEventsNew)

// fake sending direct message api
+ (TWEndpointRequestOperation *)sendDirectMessage:(NSDictionary *)params completion:(void(^)(NSError *, NSDictionary *))completion;

@end
