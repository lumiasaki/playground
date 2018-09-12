//
//  TWEndpointAPIManager+DirectMessagesEventsList.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/7.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWEndpointAPIManager.h"

@interface TWEndpointAPIManager (DirectMessagesEventsList)

// fake receiving direct message api
+ (TWEndpointRequestOperation *)pullLatestDirectMessage:(NSDictionary *)params completion:(void(^)(NSError *, NSDictionary *))completion;

@end
