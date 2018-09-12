//
//  TWEndpointAPIManager+FollowerListRequest.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWEndpointAPIManager.h"

@interface TWEndpointAPIManager (FollowerListRequest)

+ (TWEndpointRequestOperation *)fetchFollowerList:(NSDictionary *)params completion:(void(^)(NSError *, NSDictionary *))completion;

@end
