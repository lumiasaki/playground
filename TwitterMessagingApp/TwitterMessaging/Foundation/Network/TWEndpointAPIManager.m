//
//  TWEndpointAPIManager.m
//  TwitterMessaging
//
//  Created by Lumia_Saki on 2018/8/4.
//  Copyright © 2018年 tianren.zhu. All rights reserved.
//

#import "TWEndpointAPIManager.h"
#import "TWEndpointRequestOperation.h"
#import "TWNetworkingOperationManager.h"

@implementation TWEndpointAPIManager

+ (TWEndpointRequestOperation *)startEndpointRequest:(id<TWEndpointAPIRequest>)request completion:(TWEndpointResponseBlock)completion {
    if (![request conformsToProtocol:@protocol(TWEndpointAPIRequest)]) {
        return nil;
    }
    
    TWEndpointRequestOperation *operation = [[TWEndpointRequestOperation alloc] initWithEndpointRequest:request completion:completion];
    
    [self startOperation:operation];
    
    return operation;
}

#pragma mark - private

+ (void)startOperation:(TWEndpointRequestOperation *)operation {
    if (!operation) {
        return;
    }
    
    [TWNetworkingOperationManager.sharedManager addOperation:operation purpose:TWNetworkingEndpointRequestPurpose];
}

@end
