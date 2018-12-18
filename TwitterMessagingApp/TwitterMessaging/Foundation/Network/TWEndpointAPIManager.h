//
//  TWEndpointAPIManager.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWEndpointAPIRequest.h"
@class TWEndpointRequestOperation;

typedef void(^TWEndpointResponseBlock)(NSURLResponse *, NSDictionary *, NSError *);

@interface TWEndpointAPIManager : NSObject

// shouldn't invoke this method directly, using methods in category is a better approach.
+ (TWEndpointRequestOperation *)startEndpointRequest:(id<TWEndpointAPIRequest>)request completion:(TWEndpointResponseBlock)completion;

@end
