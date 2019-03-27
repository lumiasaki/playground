//
//  TWEndpointService.h
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWEndpointAPIRequest.h"
#import "TWNetworkConfiguration.h"

@protocol TWEndpointService <NSObject>

@property (nonatomic, strong, readonly) id<TWEndpointAPIRequest> request;

- (instancetype)initWithConfiguration:(TWNetworkConfiguration *)configuration;  // for injection

// for requesting API endpoint type resources
- (void)request:(id<TWEndpointAPIRequest>)request completion:(void(^)(NSURLResponse *, NSDictionary *, NSError *))completion;

// cancel a request if needed
- (void)cancel;

@end
