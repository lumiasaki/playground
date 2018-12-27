//
//  TWNetworkOperation.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWEndpointAPIRequest.h"

@class TWNetworkConfiguration;
@protocol TWEndpointService;

@interface TWEndpointRequestOperation : NSOperation

@property (nonatomic, strong, readonly) id<TWEndpointAPIRequest> request;

- (instancetype)initWithConfiguration:(TWNetworkConfiguration *)configuration endpointRequest:(id<TWEndpointAPIRequest>)request completion:(void(^)(NSURLResponse *, NSDictionary *, NSError *))completion;

#pragma mark - unavailable

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@end
