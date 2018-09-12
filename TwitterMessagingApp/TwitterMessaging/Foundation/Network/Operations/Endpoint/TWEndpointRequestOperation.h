//
//  TWNetworkOperation.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWEndpointAPIRequest.h"

@interface TWEndpointRequestOperation : NSOperation

@property (nonatomic, strong, readonly) id<TWEndpointAPIRequest> request;

- (instancetype)initWithEndpointRequest:(id<TWEndpointAPIRequest>)request completion:(void(^)(NSError *, NSDictionary *))completion;

#pragma mark - unavailable

- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@end
